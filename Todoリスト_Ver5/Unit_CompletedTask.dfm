object Form_CompletedTasklist: TForm_CompletedTasklist
  Left = 0
  Top = 0
  Caption = 'Form_CompletedTasklist'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label_Completed: TLabel
    Left = 24
    Top = 16
    Width = 80
    Height = 15
    Caption = #23436#20102#12479#12473#12463#19968#35239
  end
  object StringGrid_CompletedTasklist: TStringGrid
    Left = 24
    Top = 37
    Width = 489
    Height = 396
    TabOrder = 0
    OnMouseDown = StringGrid_CompletedTasklistMouseDown
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object Button_CompletedReturn: TButton
    Left = 533
    Top = 408
    Width = 75
    Height = 25
    Caption = #25147#12427
    TabOrder = 1
  end
  object Button_CompletedDelete: TButton
    Left = 533
    Top = 368
    Width = 75
    Height = 25
    Caption = #21066#38500
    TabOrder = 2
  end
end
