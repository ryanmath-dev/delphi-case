unit uModels;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TCliente = record
    Codigo: Integer;
    Nome: string;
    Cidade: string;
    UF: string;
  end;

  TProduto = record
    Codigo: Integer;
    Descricao: string;
    PrecoVenda: Currency;
  end;

  TPedidoItem = class
  public
    CodigoProduto: Integer;
    Descricao: string;
    Quantidade: Double;
    ValorUnitario: Currency;
    function ValorTotal: Currency;
  end;

  TPedidoItemList = TObjectList<TPedidoItem>;

  TPedido = class
  private
    FItens: TPedidoItemList;
  public
    NumeroPedido: Integer;
    DataEmissao: TDateTime;
    CodigoCliente: Integer;
    ValorTotal: Currency;
    Observacao: string;
    constructor Create;
    destructor Destroy; override;
    property Itens: TPedidoItemList read FItens;
  end;

implementation

{ TPedidoItem }

function TPedidoItem.ValorTotal: Currency;
begin
  Result := Quantidade * ValorUnitario;
end;

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  FItens := TPedidoItemList.Create(True);
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  inherited Destroy;
end;

end.
