unit uPedidoRepository;

interface

uses
  System.SysUtils,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  uModels;

type
  TPedidoRepository = class
  public
    class function ObterProximoNumero(AConn: TFDConnection): Integer;
    class procedure InserirCabecalho(AConn: TFDConnection; APedido: TPedido);
    class procedure InserirItem(AConn: TFDConnection; ANumeroPedido: Integer;
      AItem: TPedidoItem);
    class function CarregarPorNumero(AConn: TFDConnection; ANumero: Integer;
      APedido: TPedido): Boolean;
    class procedure ExcluirItens(AConn: TFDConnection; ANumero: Integer);
    class procedure ExcluirCabecalho(AConn: TFDConnection; ANumero: Integer);
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

  SQL_SELECT_PEDIDO =
    'SELECT NUMERO_PEDIDO, DATA_EMISSAO, CODIGO_CLIENTE, VALOR_TOTAL, OBSERVACAO ' +
    'FROM PEDIDO ' +
    'WHERE NUMERO_PEDIDO = :numero';

  SQL_SELECT_ITENS =
    'SELECT I.CODIGO_PRODUTO, P.DESCRICAO, I.QUANTIDADE, I.VLR_UNITARIO, I.VLR_TOTAL ' +
    'FROM PEDIDO_ITEM I ' +
    'JOIN PRODUTO P ON P.CODIGO = I.CODIGO_PRODUTO ' +
    'WHERE I.NUMERO_PEDIDO = :numero ' +
    'ORDER BY I.ID';

  SQL_DELETE_ITENS =
    'DELETE FROM PEDIDO_ITEM WHERE NUMERO_PEDIDO = :numero';

  SQL_DELETE_PEDIDO =
    'DELETE FROM PEDIDO WHERE NUMERO_PEDIDO = :numero';

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

class function TPedidoRepository.CarregarPorNumero(AConn: TFDConnection;
  ANumero: Integer; APedido: TPedido): Boolean;
var
  LQuery: TFDQuery;
  LItem: TPedidoItem;
begin
  Result := False;
  APedido.Itens.Clear;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_SELECT_PEDIDO;
    LQuery.ParamByName('numero').AsInteger := ANumero;
    LQuery.Open;
    if LQuery.Eof then
      Exit;

    APedido.NumeroPedido  := LQuery.FieldByName('NUMERO_PEDIDO').AsInteger;
    APedido.DataEmissao   := LQuery.FieldByName('DATA_EMISSAO').AsDateTime;
    APedido.CodigoCliente := LQuery.FieldByName('CODIGO_CLIENTE').AsInteger;
    APedido.ValorTotal    := LQuery.FieldByName('VALOR_TOTAL').AsCurrency;
    APedido.Observacao    := LQuery.FieldByName('OBSERVACAO').AsString;
    Result := True;
  finally
    LQuery.Free;
  end;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_SELECT_ITENS;
    LQuery.ParamByName('numero').AsInteger := ANumero;
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LItem := TPedidoItem.Create;
      LItem.CodigoProduto := LQuery.FieldByName('CODIGO_PRODUTO').AsInteger;
      LItem.Descricao     := LQuery.FieldByName('DESCRICAO').AsString;
      LItem.Quantidade    := LQuery.FieldByName('QUANTIDADE').AsFloat;
      LItem.ValorUnitario := LQuery.FieldByName('VLR_UNITARIO').AsCurrency;
      APedido.Itens.Add(LItem);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

class procedure TPedidoRepository.ExcluirItens(AConn: TFDConnection;
  ANumero: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_DELETE_ITENS;
    LQuery.ParamByName('numero').AsInteger := ANumero;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

class procedure TPedidoRepository.ExcluirCabecalho(AConn: TFDConnection;
  ANumero: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_DELETE_PEDIDO;
    LQuery.ParamByName('numero').AsInteger := ANumero;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
