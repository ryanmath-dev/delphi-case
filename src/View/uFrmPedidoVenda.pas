unit uFrmPedidoVenda;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Comp.Client,
  uModels;

type
  TFrmPedidoVenda = class(TForm)
    pnlCliente: TPanel;
    lblCodigoCliente: TLabel;
    edCodigoCliente: TEdit;
    lblNomeCaption: TLabel;
    lblNomeValor: TLabel;
    lblCidadeCaption: TLabel;
    lblCidadeValor: TLabel;
    lblUFCaption: TLabel;
    lblUFValor: TLabel;

    pnlItem: TPanel;
    lblCodigoProduto: TLabel;
    edCodigoProduto: TEdit;
    lblDescricaoCaption: TLabel;
    lblDescricaoValor: TLabel;
    lblQuantidade: TLabel;
    edQuantidade: TEdit;
    lblValorUnitario: TLabel;
    edValorUnitario: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edCodigoClienteExit(Sender: TObject);
    procedure edCodigoProdutoExit(Sender: TObject);
  strict private
    FConn: TFDConnection;
    FClienteAtual: TCliente;
    FProdutoAtual: TProduto;
    procedure LimparCliente;
    procedure LimparProduto;
  end;

var
  FrmPedidoVenda: TFrmPedidoVenda;

implementation

uses
  uConnectionFactory,
  uClienteRepository,
  uProdutoRepository;

{$R *.dfm}

procedure TFrmPedidoVenda.FormCreate(Sender: TObject);
begin
  try
    FConn := TConnectionFactory.CreateConnection;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar('Falha ao conectar ao banco:' + sLineBreak + E.Message),
        'Pedido de Venda', MB_OK or MB_ICONERROR);
      Application.Terminate;
    end;
  end;
  LimparCliente;
  LimparProduto;
end;

procedure TFrmPedidoVenda.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FConn);
end;

procedure TFrmPedidoVenda.LimparCliente;
begin
  FClienteAtual := Default(TCliente);
  lblNomeValor.Caption := '';
  lblCidadeValor.Caption := '';
  lblUFValor.Caption := '';
end;

procedure TFrmPedidoVenda.LimparProduto;
begin
  FProdutoAtual := Default(TProduto);
  lblDescricaoValor.Caption := '';
  edValorUnitario.Text := '';
end;

procedure TFrmPedidoVenda.edCodigoClienteExit(Sender: TObject);
var
  LCodigo: Integer;
begin
  LimparCliente;
  if Trim(edCodigoCliente.Text) = '' then
    Exit;

  if not TryStrToInt(Trim(edCodigoCliente.Text), LCodigo) then
  begin
    Application.MessageBox('Codigo do cliente deve ser numerico.',
      'Pedido de Venda', MB_OK or MB_ICONWARNING);
    edCodigoCliente.SetFocus;
    Exit;
  end;

  if not TClienteRepository.BuscarPorCodigo(FConn, LCodigo, FClienteAtual) then
  begin
    Application.MessageBox('Cliente nao encontrado.',
      'Pedido de Venda', MB_OK or MB_ICONWARNING);
    edCodigoCliente.SetFocus;
    Exit;
  end;

  lblNomeValor.Caption := FClienteAtual.Nome;
  lblCidadeValor.Caption := FClienteAtual.Cidade;
  lblUFValor.Caption := FClienteAtual.UF;
end;

procedure TFrmPedidoVenda.edCodigoProdutoExit(Sender: TObject);
var
  LCodigo: Integer;
begin
  LimparProduto;
  if Trim(edCodigoProduto.Text) = '' then
    Exit;

  if not TryStrToInt(Trim(edCodigoProduto.Text), LCodigo) then
  begin
    Application.MessageBox('Codigo do produto deve ser numerico.',
      'Pedido de Venda', MB_OK or MB_ICONWARNING);
    edCodigoProduto.SetFocus;
    Exit;
  end;

  if not TProdutoRepository.BuscarPorCodigo(FConn, LCodigo, FProdutoAtual) then
  begin
    Application.MessageBox('Produto nao encontrado.',
      'Pedido de Venda', MB_OK or MB_ICONWARNING);
    edCodigoProduto.SetFocus;
    Exit;
  end;

  lblDescricaoValor.Caption := FProdutoAtual.Descricao;
  edValorUnitario.Text := FormatFloat('#,##0.00', FProdutoAtual.PrecoVenda);
end;

end.
