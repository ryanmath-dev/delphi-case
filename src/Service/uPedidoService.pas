unit uPedidoService;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  uModels;

type
  EPedidoValidationError = class(Exception);

  TPedidoService = class
  public
    class function GravarPedido(AConn: TFDConnection; APedido: TPedido): Integer;
  end;

implementation

uses
  uPedidoRepository;

{ TPedidoService }

class function TPedidoService.GravarPedido(AConn: TFDConnection;
  APedido: TPedido): Integer;
var
  LItem: TPedidoItem;
  LTotal: Currency;
begin
  if APedido = nil then
    raise EPedidoValidationError.Create('Pedido nao informado.');
  if APedido.CodigoCliente <= 0 then
    raise EPedidoValidationError.Create('Cliente nao informado.');
  if APedido.Itens.Count = 0 then
    raise EPedidoValidationError.Create('Pedido deve conter ao menos um item.');

  LTotal := 0;
  for LItem in APedido.Itens do
  begin
    if LItem.CodigoProduto <= 0 then
      raise EPedidoValidationError.Create('Item com produto invalido.');
    if LItem.Quantidade <= 0 then
      raise EPedidoValidationError.Create('Item com quantidade invalida.');
    if LItem.ValorUnitario < 0 then
      raise EPedidoValidationError.Create('Item com valor unitario invalido.');
    LTotal := LTotal + LItem.ValorTotal;
  end;

  APedido.DataEmissao := Now;
  APedido.ValorTotal  := LTotal;

  AConn.StartTransaction;
  try
    APedido.NumeroPedido := TPedidoRepository.ObterProximoNumero(AConn);
    TPedidoRepository.InserirCabecalho(AConn, APedido);
    for LItem in APedido.Itens do
      TPedidoRepository.InserirItem(AConn, APedido.NumeroPedido, LItem);
    AConn.Commit;
  except
    AConn.Rollback;
    raise;
  end;

  Result := APedido.NumeroPedido;
end;

end.
