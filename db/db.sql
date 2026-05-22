/* =====================================================================
   Pedido de Venda - Script de Criacao do Banco
   Firebird 3.0+
   ---------------------------------------------------------------------
   Como executar:
     1) Crie o banco (ajuste o caminho conforme seu ambiente):
        isql -user SYSDBA -password masterkey -e ^
          -i db.sql

     OU, criando manualmente antes:
        CREATE DATABASE 'localhost:C:\firebird\data\PEDIDOS.FDB'
          USER 'SYSDBA' PASSWORD 'masterkey'
          DEFAULT CHARACTER SET UTF8;

     2) Conecte e execute este script.
   ===================================================================== */

SET SQL DIALECT 3;
SET NAMES UTF8;

/* =====================================================================
   1) TABELAS
   ===================================================================== */

CREATE TABLE CLIENTE (
  CODIGO  INTEGER      NOT NULL,
  NOME    VARCHAR(100) NOT NULL,
  CIDADE  VARCHAR(60),
  UF      CHAR(2),
  CONSTRAINT PK_CLIENTE PRIMARY KEY (CODIGO)
);

CREATE TABLE PRODUTO (
  CODIGO       INTEGER        NOT NULL,
  DESCRICAO    VARCHAR(120)   NOT NULL,
  PRECO_VENDA  NUMERIC(15, 2) NOT NULL,
  CONSTRAINT PK_PRODUTO PRIMARY KEY (CODIGO)
);

CREATE TABLE PEDIDO (
  NUMERO_PEDIDO   INTEGER        NOT NULL,
  DATA_EMISSAO    TIMESTAMP      NOT NULL,
  CODIGO_CLIENTE  INTEGER        NOT NULL,
  VALOR_TOTAL     NUMERIC(15, 2) NOT NULL,
  OBSERVACAO      VARCHAR(255),
  CONSTRAINT PK_PEDIDO PRIMARY KEY (NUMERO_PEDIDO)
);

CREATE TABLE PEDIDO_ITEM (
  ID              INTEGER        NOT NULL,
  NUMERO_PEDIDO   INTEGER        NOT NULL,
  CODIGO_PRODUTO  INTEGER        NOT NULL,
  QUANTIDADE      NUMERIC(15, 3) NOT NULL,
  VLR_UNITARIO    NUMERIC(15, 2) NOT NULL,
  VLR_TOTAL       NUMERIC(15, 2) NOT NULL,
  CONSTRAINT PK_PEDIDO_ITEM PRIMARY KEY (ID)
);

COMMIT;

/* =====================================================================
   2) GENERATORS (Sequences) para auto-incremento
   ===================================================================== */

CREATE SEQUENCE GEN_PEDIDO_NUMERO;
CREATE SEQUENCE GEN_PEDIDO_ITEM_ID;

COMMIT;

/* =====================================================================
   3) TRIGGERS BEFORE INSERT para popular PKs automaticamente
      caso o cliente nao informe (defensivo).
   ===================================================================== */

SET TERM ^ ;

CREATE TRIGGER TRG_PEDIDO_BI FOR PEDIDO
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.NUMERO_PEDIDO IS NULL) THEN
    NEW.NUMERO_PEDIDO = NEXT VALUE FOR GEN_PEDIDO_NUMERO;
END^

CREATE TRIGGER TRG_PEDIDO_ITEM_BI FOR PEDIDO_ITEM
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = NEXT VALUE FOR GEN_PEDIDO_ITEM_ID;
END^

SET TERM ; ^

COMMIT;

/* =====================================================================
   4) INDICES (alem das PKs)
   ===================================================================== */

CREATE INDEX IDX_PEDIDO_CLIENTE       ON PEDIDO (CODIGO_CLIENTE);
CREATE INDEX IDX_PEDIDO_ITEM_PEDIDO   ON PEDIDO_ITEM (NUMERO_PEDIDO);
CREATE INDEX IDX_PEDIDO_ITEM_PRODUTO  ON PEDIDO_ITEM (CODIGO_PRODUTO);

COMMIT;

/* =====================================================================
   5) FOREIGN KEYS
   ===================================================================== */

ALTER TABLE PEDIDO
  ADD CONSTRAINT FK_PEDIDO_CLIENTE
  FOREIGN KEY (CODIGO_CLIENTE) REFERENCES CLIENTE (CODIGO);

ALTER TABLE PEDIDO_ITEM
  ADD CONSTRAINT FK_PEDIDO_ITEM_PEDIDO
  FOREIGN KEY (NUMERO_PEDIDO) REFERENCES PEDIDO (NUMERO_PEDIDO);

ALTER TABLE PEDIDO_ITEM
  ADD CONSTRAINT FK_PEDIDO_ITEM_PRODUTO
  FOREIGN KEY (CODIGO_PRODUTO) REFERENCES PRODUTO (CODIGO);

COMMIT;

/* =====================================================================
   6) CARGA DE DADOS PARA TESTE
   ===================================================================== */

INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (1,  'Joao da Silva',          'Sao Paulo',      'SP');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (2,  'Maria Oliveira',         'Rio de Janeiro', 'RJ');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (3,  'Carlos Pereira',         'Belo Horizonte', 'MG');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (4,  'Ana Souza',              'Curitiba',       'PR');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (5,  'Pedro Santos',           'Porto Alegre',   'RS');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (6,  'Juliana Costa',          'Salvador',       'BA');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (7,  'Ricardo Almeida',        'Fortaleza',      'CE');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (8,  'Patricia Lima',          'Recife',         'PE');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (9,  'Fernando Rocha',         'Florianopolis',  'SC');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (10, 'Beatriz Martins',        'Goiania',        'GO');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (11, 'Lucas Ferreira',         'Manaus',         'AM');
INSERT INTO CLIENTE (CODIGO, NOME, CIDADE, UF) VALUES (12, 'Camila Ribeiro',         'Brasilia',       'DF');

COMMIT;

INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (1,  'Notebook Dell Inspiron 15',          3499.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (2,  'Mouse Logitech MX Master 3',          589.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (3,  'Teclado Mecanico Keychron K2',        749.50);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (4,  'Monitor LG 27 polegadas 4K',         2199.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (5,  'Webcam Logitech C920',                399.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (6,  'Headset HyperX Cloud II',             549.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (7,  'SSD Kingston NV2 1TB',                429.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (8,  'Memoria RAM Corsair 16GB DDR4',       289.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (9,  'Cadeira Gamer DT3 Sports',           1499.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (10, 'Mesa Digitalizadora Wacom One',       899.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (11, 'Roteador TP-Link Archer AX23',        349.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (12, 'Hub USB-C Anker 7 em 1',              279.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (13, 'Cabo HDMI 2.1 Belkin 2m',              89.90);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (14, 'Suporte Articulado p/ Monitor',       219.00);
INSERT INTO PRODUTO (CODIGO, DESCRICAO, PRECO_VENDA) VALUES (15, 'No-Break APC Back-UPS 1500VA',        899.00);

COMMIT;
