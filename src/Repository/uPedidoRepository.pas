unit uPedidoRepository;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  uModels;

type
  TPedidoRepository = class
  public
    class function ObterProximoNumero(AConn: TFDConnection): Integer;
    class procedure InserirCabecalho(AConn: TFDConnection; APedido: TPedido);
    class procedure InserirItem(AConn: TFDConnection; ANumeroPedido: Integer;
      AItem: TPedidoItem);
  end;

implementation

const
  SQL_PROX_NUMERO =
    'SELECT NEXT VALUE FOR GEN_PEDIDO_NUMERO AS PROX FROM RDB$DATABASE';

  SQL_INSERT_PEDIDO =
    'INSERT INTO PEDIDO ' +
    '  (NUMERO_PEDIDO, DATA_EMISSAO, CODIGO_CLIENTE, VALOR_TOTAL, OBSERVACAO) ' +
    'VALUES (:numero, :data_emissao, :codigo_cliente, :valor_total, :observacao)';

  SQL_INSERT_ITEM =
    'INSERT INTO PEDIDO_ITEM ' +
    '  (NUMERO_PEDIDO, CODIGO_PRODUTO, QUANTIDADE, VLR_UNITARIO, VLR_TOTAL) ' +
    'VALUES (:numero_pedido, :codigo_produto, :quantidade, :vlr_unitario, :vlr_total)';

{ TPedidoRepository }

class function TPedidoRepository.ObterProximoNumero(AConn: TFDConnection): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_PROX_NUMERO;
    LQuery.Open;
    Result := LQuery.FieldByName('PROX').AsInteger;
  finally
    LQuery.Free;
  end;
end;

class procedure TPedidoRepository.InserirCabecalho(AConn: TFDConnection;
  APedido: TPedido);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_INSERT_PEDIDO;
    LQuery.ParamByName('numero').AsInteger          := APedido.NumeroPedido;
    LQuery.ParamByName('data_emissao').AsDateTime   := APedido.DataEmissao;
    LQuery.ParamByName('codigo_cliente').AsInteger  := APedido.CodigoCliente;
    LQuery.ParamByName('valor_total').AsCurrency    := APedido.ValorTotal;
    if Trim(APedido.Observacao) = '' then
      LQuery.ParamByName('observacao').Clear
    else
      LQuery.ParamByName('observacao').AsString := APedido.Observacao;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

class procedure TPedidoRepository.InserirItem(AConn: TFDConnection;
  ANumeroPedido: Integer; AItem: TPedidoItem);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_INSERT_ITEM;
    LQuery.ParamByName('numero_pedido').AsInteger  := ANumeroPedido;
    LQuery.ParamByName('codigo_produto').AsInteger := AItem.CodigoProduto;
    LQuery.ParamByName('quantidade').AsFloat       := AItem.Quantidade;
    LQuery.ParamByName('vlr_unitario').AsCurrency  := AItem.ValorUnitario;
    LQuery.ParamByName('vlr_total').AsCurrency     := AItem.ValorTotal;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
