unit uClienteRepository;

interface

uses
  System.SysUtils,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  uModels;

type
  TClienteRepository = class
  public
    class function BuscarPorCodigo(AConn: TFDConnection; ACodigo: Integer;
      out ACliente: TCliente): Boolean;
  end;

implementation

const
  SQL_BUSCAR_POR_CODIGO =
    'SELECT CODIGO, NOME, CIDADE, UF ' +
    'FROM CLIENTE ' +
    'WHERE CODIGO = :codigo';

{ TClienteRepository }

class function TClienteRepository.BuscarPorCodigo(AConn: TFDConnection;
  ACodigo: Integer; out ACliente: TCliente): Boolean;
var
  LQuery: TFDQuery;
begin
  ACliente := Default(TCliente);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := SQL_BUSCAR_POR_CODIGO;
    LQuery.ParamByName('codigo').AsInteger := ACodigo;
    LQuery.Open;

    Result := not LQuery.Eof;
    if Result then
    begin
      ACliente.Codigo := LQuery.FieldByName('CODIGO').AsInteger;
      ACliente.Nome   := LQuery.FieldByName('NOME').AsString;
      ACliente.Cidade := LQuery.FieldByName('CIDADE').AsString;
      ACliente.UF     := LQuery.FieldByName('UF').AsString;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
