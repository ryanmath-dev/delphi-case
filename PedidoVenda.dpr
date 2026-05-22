program PedidoVenda;

uses
  Vcl.Forms,
  uFrmPedidoVenda in 'src\View\uFrmPedidoVenda.pas' {FrmPedidoVenda},
  uModels in 'src\Model\uModels.pas',
  uClienteRepository in 'src\Repository\uClienteRepository.pas',
  uProdutoRepository in 'src\Repository\uProdutoRepository.pas',
  uConnectionFactory in 'src\Infra\uConnectionFactory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Pedido de Venda';
  Application.CreateForm(TFrmPedidoVenda, FrmPedidoVenda);
  Application.Run;
end.
