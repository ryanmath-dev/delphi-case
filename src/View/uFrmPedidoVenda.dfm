object FrmPedidoVenda: TFrmPedidoVenda
  Left = 0
  Top = 0
  Caption = 'Pedido de Venda'
  ClientHeight = 520
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlCliente: TPanel
    Left = 8
    Top = 8
    Width = 804
    Height = 89
    BevelOuter = bvLowered
    Caption = ' '
    TabOrder = 0
    object lblCodigoCliente: TLabel
      Left = 12
      Top = 10
      Width = 95
      Height = 15
      Caption = 'Codigo do Cliente'
    end
    object lblNomeCaption: TLabel
      Left = 144
      Top = 10
      Width = 31
      Height = 15
      Caption = 'Nome'
    end
    object lblNomeValor: TLabel
      Left = 144
      Top = 32
      Width = 380
      Height = 19
      AutoSize = False
      Caption = ' '
      Color = clWindow
      ParentColor = False
      Transparent = False
    end
    object lblCidadeCaption: TLabel
      Left = 530
      Top = 10
      Width = 35
      Height = 15
      Caption = 'Cidade'
    end
    object lblCidadeValor: TLabel
      Left = 530
      Top = 32
      Width = 200
      Height = 19
      AutoSize = False
      Caption = ' '
      Color = clWindow
      ParentColor = False
      Transparent = False
    end
    object lblUFCaption: TLabel
      Left = 740
      Top = 10
      Width = 14
      Height = 15
      Caption = 'UF'
    end
    object lblUFValor: TLabel
      Left = 740
      Top = 32
      Width = 50
      Height = 19
      AutoSize = False
      Caption = ' '
      Color = clWindow
      ParentColor = False
      Transparent = False
    end
    object edCodigoCliente: TEdit
      Left = 12
      Top = 30
      Width = 121
      Height = 23
      NumbersOnly = True
      TabOrder = 0
      OnExit = edCodigoClienteExit
    end
  end
  object pnlItem: TPanel
    Left = 8
    Top = 104
    Width = 804
    Height = 89
    BevelOuter = bvLowered
    Caption = ' '
    TabOrder = 1
    object lblCodigoProduto: TLabel
      Left = 12
      Top = 10
      Width = 96
      Height = 15
      Caption = 'Codigo do Produto'
    end
    object lblDescricaoCaption: TLabel
      Left = 144
      Top = 10
      Width = 53
      Height = 15
      Caption = 'Descricao'
    end
    object lblDescricaoValor: TLabel
      Left = 144
      Top = 32
      Width = 380
      Height = 19
      AutoSize = False
      Caption = ' '
      Color = clWindow
      ParentColor = False
      Transparent = False
    end
    object lblQuantidade: TLabel
      Left = 530
      Top = 10
      Width = 60
      Height = 15
      Caption = 'Quantidade'
    end
    object lblValorUnitario: TLabel
      Left = 638
      Top = 10
      Width = 75
      Height = 15
      Caption = 'Valor Unitario'
    end
    object edCodigoProduto: TEdit
      Left = 12
      Top = 30
      Width = 121
      Height = 23
      NumbersOnly = True
      TabOrder = 0
      OnExit = edCodigoProdutoExit
    end
    object edQuantidade: TEdit
      Left = 530
      Top = 30
      Width = 100
      Height = 23
      TabOrder = 1
      Text = '1'
    end
    object edValorUnitario: TEdit
      Left = 638
      Top = 30
      Width = 152
      Height = 23
      TabOrder = 2
    end
    object btnInserirAtualizarItem: TButton
      Left = 638
      Top = 58
      Width = 152
      Height = 25
      Caption = 'Inserir Item'
      TabOrder = 3
      OnClick = btnInserirAtualizarItemClick
    end
  end
  object grdItens: TStringGrid
    Left = 8
    Top = 200
    Width = 804
    Height = 230
    DefaultRowHeight = 22
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goThumbTracking]
    TabOrder = 2
    OnKeyDown = grdItensKeyDown
  end
  object pnlRodape: TPanel
    Left = 8
    Top = 438
    Width = 804
    Height = 74
    BevelOuter = bvLowered
    TabOrder = 3
    object lblValorTotalCaption: TLabel
      Left = 12
      Top = 12
      Width = 117
      Height = 19
      Caption = 'Valor Total do Pedido:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblValorTotal: TLabel
      Left = 144
      Top = 8
      Width = 200
      Height = 28
      AutoSize = False
      Caption = '0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnGravarPedido: TButton
      Left = 638
      Top = 40
      Width = 152
      Height = 28
      Caption = 'Gravar Pedido'
      Enabled = False
      TabOrder = 0
    end
  end
end
