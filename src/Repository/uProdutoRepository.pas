unit uProdutoRepository;

interface

uses
  System.SysUtils,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  uModels;

type
  TProdutoRepository = class
  public
    class function BuscarPorCodigo(AConn: TFDConnection; ACodigo: Integer;
      out AProduto: TProduto): Boolean;
  end;

implementation

const
  SQL_BUSCAR_POR_CODIGO =
    'SELECT CODIGO, DESCRICAO, PRECO_VENDA ' +
    'FROM PRODUTO ' +
    'WHERE CODIGO = :codigo';

{ TProdutoRepository }

class function TProdutoRepository.BuscarPorCodigo(AConn: TFDConnection;
  ACodigo: Integer; out AProduto: TProduto): Boolean;
var
  LQuery: TFDQuery;
begin
  AProduto := Default(TProduto);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_BUSCAR_POR_CODIGO;
    LQuery.ParamByName('codigo').AsInteger := ACodigo;
    LQuery.Open;

    Result := not LQuery.Eof;
    if Result then
    begin
      AProduto.Codigo     := LQuery.FieldByName('CODIGO').AsInteger;
      AProduto.Descricao  := LQuery.FieldByName('DESCRICAO').AsString;
      AProduto.PrecoVenda := LQuery.FieldByName('PRECO_VENDA').AsCurrency;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
