# Pedido de Venda — Delphi + FireDAC + Firebird

Aplicação Delphi (VCL) para registro de Pedidos de Venda com persistência transacional em Firebird 3.0, desenvolvida como parte de teste técnico para vaga de Analista Desenvolvedor Delphi.

## Stack

- **Delphi 11 Alexandria** (RAD Studio 23.0)
- **FireDAC** (componentes nativos, sem terceiros)
- **Firebird 3.0**
- **VCL** (Windows 32-bit)

## Estrutura

```
delphi-case/
├── src/
│   ├── View/           # Formulários (.pas/.dfm)
│   ├── Service/        # Regras de negócio (totalização, validação, transação)
│   ├── Repository/     # Acesso a dados (SQL parametrizado)
│   ├── Model/          # Entidades (TCliente, TProduto, TPedido, TPedidoItem)
│   └── Infra/          # ConnectionFactory (leitura do config.ini)
├── db/
│   ├── db.sql          # DDL + seeds (script único de criação)
│   └── migrations/     # Evoluções incrementais
├── bin/                # fbclient.dll + executável compilado
├── config.ini.example  # Template de configuração (sem credenciais reais)
└── README.md
```

## Pré-requisitos

- Delphi 11 ou superior (com FireDAC instalado)
- Firebird Server 3.0+ rodando localmente ou em rede
- `fbclient.dll` compatível com a versão do servidor Firebird

## Setup

### 1. Criar o banco

(Instruções detalhadas serão adicionadas nas próximas fases.)

### 2. Configurar o INI

(A ser detalhado.)

### 3. Compilar e executar

(A ser detalhado.)

## Roteiro de testes manuais

(A ser detalhado.)

## Decisões técnicas

(A ser detalhado.)
