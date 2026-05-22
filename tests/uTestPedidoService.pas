unit uTestPedidoService;

interface

uses
  DUnitX.TestFramework,
  uModels;

type
  [TestFixture]
  TPedidoServiceTotalTests = class
  private
    FPedido: TPedido;
    function AdicionarItem(ACodigo: Integer; AQtd: Double;
      AValor: Currency): TPedidoItem;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TotalDePedidoVazio_DeveSerZero;
    [Test]
    procedure TotalComUmItem_DeveSerQuantidadeVezesValor;
    [Test]
    procedure TotalComMultiplosItens_DeveSomarTodos;
    [Test]
    procedure ValorTotalItem_QuantidadeZero_DeveSerZero;
    [Test]
    procedure ProdutoRepetido_EmLinhasDistintas_DeveSomarAmbos;
    [Test]
    procedure ValorTotal_AceitaFracionarios;
    [Test]
    procedure CalcularTotal_PedidoNil_RetornaZero;
  end;

implementation

uses
  System.SysUtils,
  uPedidoService;

{ TPedidoServiceTotalTests }

procedure TPedidoServiceTotalTests.Setup;
begin
  FPedido := TPedido.Create;
end;

procedure TPedidoServiceTotalTests.TearDown;
begin
  FreeAndNil(FPedido);
end;

function TPedidoServiceTotalTests.AdicionarItem(ACodigo: Integer; AQtd: Double;
  AValor: Currency): TPedidoItem;
begin
  Result := TPedidoItem.Create;
  Result.CodigoProduto := ACodigo;
  Result.Descricao     := 'Produto ' + IntToStr(ACodigo);
  Result.Quantidade    := AQtd;
  Result.ValorUnitario := AValor;
  FPedido.Itens.Add(Result);
end;

procedure TPedidoServiceTotalTests.TotalDePedidoVazio_DeveSerZero;
begin
  Assert.AreEqual(Currency(0), TPedidoService.CalcularTotal(FPedido));
end;

procedure TPedidoServiceTotalTests.TotalComUmItem_DeveSerQuantidadeVezesValor;
begin
  AdicionarItem(1, 3, 10);
  Assert.AreEqual(Currency(30), TPedidoService.CalcularTotal(FPedido));
end;

procedure TPedidoServiceTotalTests.TotalComMultiplosItens_DeveSomarTodos;
begin
  AdicionarItem(1, 2, 10);    // 20
  AdicionarItem(2, 1, 15.50); // 15.50
  AdicionarItem(3, 4, 2.25);  // 9.00
  Assert.AreEqual(Currency(44.50), TPedidoService.CalcularTotal(FPedido));
end;

procedure TPedidoServiceTotalTests.ValorTotalItem_QuantidadeZero_DeveSerZero;
var
  LItem: TPedidoItem;
begin
  LItem := AdicionarItem(1, 0, 99.99);
  Assert.AreEqual(Currency(0), LItem.ValorTotal);
  Assert.AreEqual(Currency(0), TPedidoService.CalcularTotal(FPedido));
end;

procedure TPedidoServiceTotalTests.ProdutoRepetido_EmLinhasDistintas_DeveSomarAmbos;
begin
  AdicionarItem(7, 2, 5);  // 10
  AdicionarItem(7, 3, 5);  // 15
  Assert.AreEqual(Currency(25), TPedidoService.CalcularTotal(FPedido));
end;

procedure TPedidoServiceTotalTests.ValorTotal_AceitaFracionarios;
var
  LItem: TPedidoItem;
begin
  LItem := AdicionarItem(1, 2.5, 4.00);
  Assert.AreEqual(Currency(10.00), LItem.ValorTotal);
end;

procedure TPedidoServiceTotalTests.CalcularTotal_PedidoNil_RetornaZero;
begin
  Assert.AreEqual(Currency(0), TPedidoService.CalcularTotal(nil));
end;

initialization
  TDUnitX.RegisterTestFixture(TPedidoServiceTotalTests);

end.
