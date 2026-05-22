unit uFrmPedidoVenda;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
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
    lblObservacao: TLabel;
    edObservacao: TEdit;

    pnlItem: TPanel;
    lblCodigoProduto: TLabel;
    edCodigoProduto: TEdit;
    lblDescricaoCaption: TLabel;
    lblDescricaoValor: TLabel;
    lblQuantidade: TLabel;
    edQuantidade: TEdit;
    lblValorUnitario: TLabel;
    edValorUnitario: TEdit;
    btnInserirAtualizarItem: TButton;

    grdItens: TStringGrid;

    pnlRodape: TPanel;
    lblValorTotalCaption: TLabel;
    lblValorTotal: TLabel;
    btnGravarPedido: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edCodigoClienteExit(Sender: TObject);
    procedure edCodigoProdutoExit(Sender: TObject);
    procedure btnInserirAtualizarItemClick(Sender: TObject);
    procedure grdItensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure EditPulaCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edValorUnitarioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  strict private
    FConn: TFDConnection;
    FClienteAtual: TCliente;
    FProdutoAtual: TProduto;
    FItens: TPedidoItemList;
    FIndiceEdicao: Integer;
    FFmt: TFormatSettings;
    procedure LimparCliente;
    procedure LimparProduto;
    procedure LimparCamposItem;
    procedure ConfigurarGrid;
    procedure RenderGrid;
    procedure RecalcularTotal;
    procedure AtualizarHabilitacaoGravar;
    procedure LimparPedido;
    procedure Aviso(const ATexto: string);
    procedure Erro(const ATexto: string);
    function ValidarCamposItem(out AQtd: Double; out AValor: Currency): Boolean;
  end;

var
  FrmPedidoVenda: TFrmPedidoVenda;

implementation

uses
  uConnectionFactory,
  uClienteRepository,
  uProdutoRepository,
  uPedidoService;

{$R *.dfm}

const
  COL_CODIGO    = 0;
  COL_DESCRICAO = 1;
  COL_QTD       = 2;
  COL_VLR_UNIT  = 3;
  COL_VLR_TOTAL = 4;

procedure TFrmPedidoVenda.FormCreate(Sender: TObject);
begin
  FFmt := TFormatSettings.Create('pt-BR');
  FFmt.DecimalSeparator  := ',';
  FFmt.ThousandSeparator := '.';

  try
    FConn := TConnectionFactory.CreateConnection;
  except
    on E: Exception do
    begin
      Erro('Falha ao conectar ao banco:' + sLineBreak + E.Message);
      Application.Terminate;
      Exit;
    end;
  end;
  FItens := TPedidoItemList.Create(True);
  FIndiceEdicao := -1;
  ConfigurarGrid;
  LimparCliente;
  LimparProduto;
  RecalcularTotal;
  btnGravarPedido.Enabled := False;
end;

procedure TFrmPedidoVenda.Aviso(const ATexto: string);
begin
  Application.MessageBox(PChar(ATexto), 'Pedido de Venda',
    MB_OK or MB_ICONWARNING);
end;

procedure TFrmPedidoVenda.Erro(const ATexto: string);
begin
  Application.MessageBox(PChar(ATexto), 'Pedido de Venda',
    MB_OK or MB_ICONERROR);
end;

procedure TFrmPedidoVenda.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FItens);
  FreeAndNil(FConn);
end;

procedure TFrmPedidoVenda.ConfigurarGrid;
begin
  grdItens.ColCount := 5;
  grdItens.RowCount := 2;
  grdItens.FixedRows := 1;
  grdItens.FixedCols := 0;
  grdItens.DefaultRowHeight := 22;
  grdItens.Cells[COL_CODIGO, 0]    := 'Cod. Produto';
  grdItens.Cells[COL_DESCRICAO, 0] := 'Descricao';
  grdItens.Cells[COL_QTD, 0]       := 'Quantidade';
  grdItens.Cells[COL_VLR_UNIT, 0]  := 'Vlr. Unitario';
  grdItens.Cells[COL_VLR_TOTAL, 0] := 'Vlr. Total';
  grdItens.ColWidths[COL_CODIGO]    := 90;
  grdItens.ColWidths[COL_DESCRICAO] := 360;
  grdItens.ColWidths[COL_QTD]       := 90;
  grdItens.ColWidths[COL_VLR_UNIT]  := 110;
  grdItens.ColWidths[COL_VLR_TOTAL] := 120;
  grdItens.Rows[1].Clear;
end;

procedure TFrmPedidoVenda.RenderGrid;
var
  i: Integer;
  LItem: TPedidoItem;
begin
  if FItens.Count = 0 then
  begin
    grdItens.RowCount := 2;
    grdItens.Rows[1].Clear;
    Exit;
  end;

  grdItens.RowCount := FItens.Count + 1;
  for i := 0 to FItens.Count - 1 do
  begin
    LItem := FItens[i];
    grdItens.Cells[COL_CODIGO, i + 1]    := IntToStr(LItem.CodigoProduto);
    grdItens.Cells[COL_DESCRICAO, i + 1] := LItem.Descricao;
    grdItens.Cells[COL_QTD, i + 1]       := FormatFloat('#,##0.###', LItem.Quantidade, FFmt);
    grdItens.Cells[COL_VLR_UNIT, i + 1]  := FormatFloat('#,##0.00', LItem.ValorUnitario, FFmt);
    grdItens.Cells[COL_VLR_TOTAL, i + 1] := FormatFloat('#,##0.00', LItem.ValorTotal, FFmt);
  end;
end;

procedure TFrmPedidoVenda.RecalcularTotal;
var
  LSoma: Currency;
  LItem: TPedidoItem;
begin
  LSoma := 0;
  for LItem in FItens do
    LSoma := LSoma + LItem.ValorTotal;
  lblValorTotal.Caption := FormatFloat('#,##0.00', LSoma, FFmt);
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

procedure TFrmPedidoVenda.LimparCamposItem;
begin
  edCodigoProduto.Text := '';
  edQuantidade.Text := '1';
  LimparProduto;
  FIndiceEdicao := -1;
  btnInserirAtualizarItem.Caption := 'Inserir Item';
  edCodigoProduto.SetFocus;
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
    Aviso('Codigo do cliente deve ser numerico.');
    edCodigoCliente.SetFocus;
    Exit;
  end;

  try
    if not TClienteRepository.BuscarPorCodigo(FConn, LCodigo, FClienteAtual) then
    begin
      Aviso('Cliente nao encontrado.');
      edCodigoCliente.SetFocus;
      Exit;
    end;
  except
    on E: Exception do
    begin
      Erro('Erro ao consultar cliente:' + sLineBreak + E.Message);
      edCodigoCliente.SetFocus;
      Exit;
    end;
  end;

  lblNomeValor.Caption := FClienteAtual.Nome;
  lblCidadeValor.Caption := FClienteAtual.Cidade;
  lblUFValor.Caption := FClienteAtual.UF;
  AtualizarHabilitacaoGravar;
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
    Aviso('Codigo do produto deve ser numerico.');
    edCodigoProduto.SetFocus;
    Exit;
  end;

  try
    if not TProdutoRepository.BuscarPorCodigo(FConn, LCodigo, FProdutoAtual) then
    begin
      Aviso('Produto nao encontrado.');
      edCodigoProduto.SetFocus;
      Exit;
    end;
  except
    on E: Exception do
    begin
      Erro('Erro ao consultar produto:' + sLineBreak + E.Message);
      edCodigoProduto.SetFocus;
      Exit;
    end;
  end;

  lblDescricaoValor.Caption := FProdutoAtual.Descricao;
  edValorUnitario.Text := FormatFloat('#,##0.00', FProdutoAtual.PrecoVenda, FFmt);
end;

function TFrmPedidoVenda.ValidarCamposItem(out AQtd: Double;
  out AValor: Currency): Boolean;
var
  LValorFloat: Double;
begin
  Result := False;
  AQtd := 0;
  AValor := 0;

  if FProdutoAtual.Codigo = 0 then
  begin
    Aviso('Informe um produto valido antes de inserir o item.');
    edCodigoProduto.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(Trim(edQuantidade.Text), AQtd, FFmt) or (AQtd <= 0) then
  begin
    Aviso('Quantidade deve ser numerica e maior que zero.');
    edQuantidade.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(Trim(edValorUnitario.Text), LValorFloat, FFmt) or (LValorFloat < 0) then
  begin
    Aviso('Valor unitario invalido.');
    edValorUnitario.SetFocus;
    Exit;
  end;
  AValor := LValorFloat;
  Result := True;
end;

procedure TFrmPedidoVenda.btnInserirAtualizarItemClick(Sender: TObject);
var
  LQtd: Double;
  LValor: Currency;
  LItem: TPedidoItem;
begin
  if not ValidarCamposItem(LQtd, LValor) then
    Exit;

  if FIndiceEdicao < 0 then
  begin
    LItem := TPedidoItem.Create;
    FItens.Add(LItem);
  end
  else
    LItem := FItens[FIndiceEdicao];

  LItem.CodigoProduto := FProdutoAtual.Codigo;
  LItem.Descricao     := FProdutoAtual.Descricao;
  LItem.Quantidade    := LQtd;
  LItem.ValorUnitario := LValor;

  RenderGrid;
  RecalcularTotal;
  LimparCamposItem;
  AtualizarHabilitacaoGravar;
end;

procedure TFrmPedidoVenda.grdItensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LIndice: Integer;
  LItem: TPedidoItem;
begin
  LIndice := grdItens.Row - 1;
  if (LIndice < 0) or (LIndice >= FItens.Count) then
    Exit;

  case Key of
    VK_RETURN:
      begin
        LItem := FItens[LIndice];
        FProdutoAtual.Codigo     := LItem.CodigoProduto;
        FProdutoAtual.Descricao  := LItem.Descricao;
        FProdutoAtual.PrecoVenda := LItem.ValorUnitario;

        edCodigoProduto.Text     := IntToStr(LItem.CodigoProduto);
        lblDescricaoValor.Caption := LItem.Descricao;
        edQuantidade.Text        := FormatFloat('#,##0.###', LItem.Quantidade, FFmt);
        edValorUnitario.Text     := FormatFloat('#,##0.00', LItem.ValorUnitario, FFmt);

        FIndiceEdicao := LIndice;
        btnInserirAtualizarItem.Caption := 'Atualizar Item';
        edQuantidade.SetFocus;
        Key := 0;
      end;

    VK_DELETE:
      begin
        if Application.MessageBox('Confirma a exclusao do item selecionado?',
          'Pedido de Venda', MB_YESNO or MB_ICONQUESTION) <> ID_YES then
          Exit;

        FItens.Delete(LIndice);
        if FIndiceEdicao = LIndice then
          LimparCamposItem
        else if FIndiceEdicao > LIndice then
          Dec(FIndiceEdicao);

        RenderGrid;
        AtualizarHabilitacaoGravar;
        Key := 0;
      end;
  end;
end;

procedure TFrmPedidoVenda.AtualizarHabilitacaoGravar;
begin
  btnGravarPedido.Enabled := (FClienteAtual.Codigo > 0) and (FItens.Count > 0);
end;

procedure TFrmPedidoVenda.LimparPedido;
begin
  FItens.Clear;
  FIndiceEdicao := -1;
  edCodigoCliente.Text := '';
  edObservacao.Text := '';
  LimparCliente;
  edCodigoProduto.Text := '';
  edQuantidade.Text := '1';
  LimparProduto;
  btnInserirAtualizarItem.Caption := 'Inserir Item';
  RenderGrid;
  RecalcularTotal;
  AtualizarHabilitacaoGravar;
  edCodigoCliente.SetFocus;
end;

procedure TFrmPedidoVenda.btnGravarPedidoClick(Sender: TObject);
var
  LPedido: TPedido;
  LItemOrig, LItemCopia: TPedidoItem;
  LNumero: Integer;
begin
  btnGravarPedido.Enabled := False;
  try
    LPedido := TPedido.Create;
    try
      LPedido.CodigoCliente := FClienteAtual.Codigo;
      LPedido.Observacao    := Trim(edObservacao.Text);
      for LItemOrig in FItens do
      begin
        LItemCopia := TPedidoItem.Create;
        LItemCopia.CodigoProduto := LItemOrig.CodigoProduto;
        LItemCopia.Descricao     := LItemOrig.Descricao;
        LItemCopia.Quantidade    := LItemOrig.Quantidade;
        LItemCopia.ValorUnitario := LItemOrig.ValorUnitario;
        LPedido.Itens.Add(LItemCopia);
      end;

      try
        LNumero := TPedidoService.GravarPedido(FConn, LPedido);
      except
        on E: Exception do
        begin
          Erro('Erro ao gravar pedido:' + sLineBreak + E.Message);
          Exit;
        end;
      end;

      Application.MessageBox(PChar(Format('Pedido n. %d gravado com sucesso.',
        [LNumero])), 'Pedido de Venda', MB_OK or MB_ICONINFORMATION);
      LimparPedido;
    finally
      LPedido.Free;
    end;
  finally
    AtualizarHabilitacaoGravar;
  end;
end;

procedure TFrmPedidoVenda.EditPulaCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SelectNext(Sender as TWinControl, True, True);
    Key := 0;
  end;
end;

procedure TFrmPedidoVenda.edValorUnitarioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnInserirAtualizarItem.Click;
    Key := 0;
  end;
end;

end.
