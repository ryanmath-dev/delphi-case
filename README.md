# Pedido de Venda — Delphi + FireDAC + Firebird

Aplicação Delphi (VCL) para registro de Pedidos de Venda com persistência transacional em Firebird 3.0, desenvolvida como parte de teste técnico para vaga de Analista Desenvolvedor Delphi.

## Stack

- **Delphi 11 Alexandria** (RAD Studio 23.0) — Win32
- **FireDAC** (componentes nativos, sem terceiros)
- **Firebird 3.0+**
- **VCL**
- **DUnitX** (testes unitários da regra de totalização)

## Estrutura de pastas

```
delphi-case/
├── PedidoVenda.dpr / .dproj      # Aplicação principal
├── src/
│   ├── View/                     # uFrmPedidoVenda.pas + .dfm
│   ├── Service/                  # uPedidoService.pas (validação, transação)
│   ├── Repository/               # uClienteRepository, uProdutoRepository, uPedidoRepository
│   ├── Model/                    # uModels.pas (TCliente, TProduto, TPedido, TPedidoItem)
│   └── Infra/                    # uConnectionFactory.pas (lê config.ini)
├── db/
│   ├── db.sql                    # DDL + generators + triggers + indices + FKs + seeds
│   └── migrations/
│       └── 001_add_observacao.sql
├── tests/
│   ├── PedidoVendaTests.dpr
│   └── uTestPedidoService.pas    # DUnitX (totalização)
├── bin/
│   └── fbclient.dll              # distribuído junto da aplicação
├── config.ini.example            # template (config.ini real é gitignored)
└── README.md
```

## Pré-requisitos

- Delphi 11+ com FireDAC.
- Firebird Server 3.0+ em execução (Windows: serviço `FirebirdServerDefaultInstance`).
- `fbclient.dll` compatível com o servidor — já incluído em `bin/`.
- Microsoft Visual C++ 2010 Redistributable (x86) — exigido pelo `fbclient.dll`.

## Setup

### 1. Criar o banco

Edite o caminho conforme seu ambiente e execute via `isql`:

```bash
# 1. Criar a base
echo "CREATE DATABASE 'localhost:C:\pedidos\PEDIDOS.FDB' \
      USER 'SYSDBA' PASSWORD 'masterkey' \
      DEFAULT CHARACTER SET UTF8;" | isql -q

# 2. Aplicar o script (DDL + seeds)
isql -user SYSDBA -password masterkey \
     -i db/db.sql \
     "localhost:C:\pedidos\PEDIDOS.FDB"
```

O script `db/db.sql` cria as quatro tabelas (`CLIENTE`, `PRODUTO`, `PEDIDO`, `PEDIDO_ITEM`), generators (`GEN_PEDIDO_NUMERO`, `GEN_PEDIDO_ITEM_ID`), triggers `BEFORE INSERT`, índices em FKs, constraints de FK e popula 12 clientes + 15 produtos.

**Migrations:** para bases criadas antes da Fase 7, aplique `db/migrations/001_add_observacao.sql` para adicionar a coluna `OBSERVACAO` no `PEDIDO`. Bases novas já vêm com a coluna.

### 2. Configurar o INI

```bash
cp config.ini.example config.ini
```

Edite `config.ini` apontando para sua base. O arquivo segue o template:

```ini
[Database]
Database=C:\pedidos\PEDIDOS.FDB
Username=SYSDBA
Password=masterkey
Server=localhost
Port=3050
ClientLibrary=.\bin\fbclient.dll
```

`config.ini` está no `.gitignore` e nunca deve ser versionado (contém credenciais).

### 3. Compilar e executar

Abra `PedidoVenda.dproj` no Delphi 11, defina plataforma **Win32**, build. O executável é gerado em `bin/PedidoVenda.exe`. Garanta que `config.ini` esteja na mesma pasta do executável.

### 4. Rodar os testes (DUnitX)

Abra `tests/PedidoVendaTests.dpr` no Delphi, compile e execute. Saída em modo console; também gera relatório NUnit XML.

## Roteiro de testes manuais

**Cenário feliz:**

1. Abrir a aplicação. Conexão validada na inicialização.
2. Digitar `1` em **Codigo do Cliente** → Nome/Cidade/UF aparecem.
3. Pressionar Enter, digitar `1` em **Codigo do Produto** → Descrição aparece, **Valor Unitario** vem preenchido com `3.499,90`.
4. Quantidade `2`, Enter, Enter → item é inserido no grid.
5. Adicionar mais 2 produtos diferentes.
6. Conferir o **Valor Total do Pedido** no rodapé.
7. (Opcional) Preencher **Observacao**.
8. Clicar **Gravar Pedido** → mensagem de sucesso com o número gerado. Tela limpa.

**Edge cases para validar:**

| Cenário | Esperado |
|---|---|
| Cliente inexistente (código `9999`) | Aviso "Cliente nao encontrado", foco volta. |
| Produto inexistente | Aviso "Produto nao encontrado". |
| Quantidade zero ou negativa | Aviso "Quantidade deve ser numerica e maior que zero". |
| Valor unitário negativo | Aviso "Valor unitario invalido". |
| Editar valor unitário (`589,00` → `500,00`) | Total recalcula imediatamente. |
| **ENTER** sobre item no grid | Item carrega para os campos para edição. |
| **DEL** sobre item no grid | Confirmação; após excluir, total recalcula imediatamente. |
| Produto repetido (mesmo código duas vezes) | Linhas distintas no grid, somam no total. |
| Cliente válido mas sem itens | Botão Gravar permanece desabilitado. |
| Banco indisponível na inicialização | Mensagem clara e aplicação encerra. |
| Carregar Pedido com número inexistente | Aviso "Pedido n. X nao encontrado". |
| Cancelar Pedido carregado | Confirmação; itens + cabeçalho removidos em transação. |

## Decisões técnicas

- **Camadas:** `View → Service → Repository → Infra`. View não conhece SQL; Service não conhece VCL; Repository não tem regra de negócio.
- **Transação atômica:** `TPedidoService.GravarPedido` e `CancelarPedido` operam dentro de `StartTransaction/Commit`, com `Rollback` em qualquer exceção e re-raise para a View.
- **Queries 100% parametrizadas** (`:param`) — sem concatenação de strings. Senha lida do INI e nunca logada.
- **Numeração:** `NUMERO_PEDIDO` obtido via `SELECT NEXT VALUE FOR GEN_PEDIDO_NUMERO` antes do INSERT, para retornar imediatamente ao operador. `PEDIDO_ITEM.ID` gerado por trigger `BEFORE INSERT` (não exposto à aplicação).
- **Totalização** centralizada em `TPedidoService.CalcularTotal` (pura, testável sem banco). View não confia no operador para o total — Service recalcula antes de persistir.
- **`TFormatSettings` pt-BR** dedicado ao formulário para parse/formatação de `Quantidade` (3 casas) e valores (2 casas), evitando depender da configuração regional do Windows.
- **UX de operador:** Enter avança o foco entre campos; Enter no Valor Unitário dispara Inserir/Atualizar; mensagens centralizadas em helpers `Aviso`/`Erro`.
- **Sem componentes de terceiros** — apenas VCL, FireDAC, RTL e DUnitX (testes).
- **`fbclient.dll` versionado em `bin/`** conforme requisito do enunciado ("incluir junto com a aplicação").

## Bonus implementados

- **Carregar Pedido:** botão no rodapé pede o número via `InputBox`, carrega cabeçalho + itens via `JOIN` com `PRODUTO`, popula a tela e habilita Cancelar.
- **Cancelar Pedido:** habilitado após carregamento. Confirma com o usuário e remove itens + cabeçalho em transação única.
- **DUnitX:** cobertura da regra de totalização (`tests/uTestPedidoService.pas`) — pedido vazio, item único, múltiplos itens, quantidade zero, fracionários, produto repetido em linhas distintas, pedido `nil`.
