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
    class function CarregarPedido(AConn: TFDConnection; ANumero: Integer;
      APedido: TPedido): Boolean;
    class procedure CancelarPedido(AConn: TFDConnection; ANumero: Integer);
    class function CalcularTotal(APedido: TPedido): Currency;
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

class function TPedidoService.CarregarPedido(AConn: TFDConnection;
  ANumero: Integer; APedido: TPedido): Boolean;
begin
  if APedido = nil then
    raise EPedidoValidationError.Create('Pedido nao informado.');
  if ANumero <= 0 then
    raise EPedidoValidationError.Create('Numero de pedido invalido.');

  Result := TPedidoRepository.CarregarPorNumero(AConn, ANumero, APedido);
end;

class procedure TPedidoService.CancelarPedido(AConn: TFDConnection;
  ANumero: Integer);
begin
  if ANumero <= 0 then
    raise EPedidoValidationError.Create('Numero de pedido invalido.');

  AConn.StartTransaction;
  try
    TPedidoRepository.ExcluirItens(AConn, ANumero);
    TPedidoRepository.ExcluirCabecalho(AConn, ANumero);
    AConn.Commit;
  except
    AConn.Rollback;
    raise;
  end;
end;

class function TPedidoService.CalcularTotal(APedido: TPedido): Currency;
var
  LItem: TPedidoItem;
begin
  Result := 0;
  if APedido = nil then
    Exit;
  for LItem in APedido.Itens do
    Result := Result + LItem.ValorTotal;
end;

end.
