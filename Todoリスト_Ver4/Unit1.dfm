object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 604
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Label_checklist: TLabel
    Left = 24
    Top = 211
    Width = 55
    Height = 15
    Caption = 'ToDo'#12522#12473#12488
  end
  object Label2: TLabel
    Left = 24
    Top = 107
    Width = 310
    Height = 15
    Caption = #23436#20102#12479#12473#12463#19968#35239#65288#12480#12502#12523#12463#12522#12483#12463#12391'ToDo'#12522#12473#12488#12408#12398#24489#20803#21487#33021#65289
  end
  object Label_Search: TLabel
    Left = 24
    Top = 8
    Width = 26
    Height = 15
    Caption = #26908#32034
  end
  object Label1: TLabel
    Left = 24
    Top = 54
    Width = 47
    Height = 15
    Caption = #12501#12451#12523#12479#12540
  end
  object Label3: TLabel
    Left = 24
    Top = 78
    Width = 52
    Height = 15
    Caption = #20778#20808#24230#65306
  end
  object Label4: TLabel
    Left = 264
    Top = 78
    Width = 50
    Height = 15
    Caption = #12459#12486#12468#12522#65306
  end
  object Button_add: TButton
    Left = 520
    Top = 284
    Width = 75
    Height = 25
    Caption = #36861#21152
    TabOrder = 0
    OnClick = Button_addClick
  end
  object Button_delete: TButton
    Left = 520
    Top = 377
    Width = 75
    Height = 25
    Caption = #21066#38500
    TabOrder = 1
    OnClick = Button_deleteClick
  end
  object Button_path: TButton
    Left = 520
    Top = 346
    Width = 75
    Height = 25
    Caption = #12497#12473#30906#35469
    TabOrder = 2
    OnClick = Button_pathClick
  end
  object Button_reset: TButton
    Left = 520
    Top = 408
    Width = 75
    Height = 25
    Caption = #21021#26399#21270
    TabOrder = 3
    OnClick = Button_resetClick
  end
  object Memo_Completed: TMemo
    Left = 24
    Top = 128
    Width = 490
    Height = 77
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
    WordWrap = False
    OnDblClick = Memo_CompletedDblClick
  end
  object StringGrid1: TStringGrid
    AlignWithMargins = True
    Left = 24
    Top = 232
    Width = 490
    Height = 201
    DefaultColWidth = 98
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    ParentFont = False
    TabOrder = 5
    OnDrawCell = StringGrid1DrawCell
    OnMouseDown = StringGrid1MouseDown
    OnSelectCell = StringGrid1SelectCell
  end
  object Button_Edit: TButton
    Left = 520
    Top = 315
    Width = 75
    Height = 25
    Caption = #32232#38598
    TabOrder = 6
    OnClick = Button_EditClick
  end
  object Edit_search: TEdit
    Left = 24
    Top = 25
    Width = 490
    Height = 23
    TabOrder = 7
    OnChange = Edit_searchChange
  end
  object ComboBox_FilterPriority: TComboBox
    Left = 77
    Top = 75
    Width = 145
    Height = 23
    TabOrder = 8
    OnChange = ComboBox_FilterPriorityChange
  end
  object ComboBox_FilterCategory: TComboBox
    Left = 320
    Top = 75
    Width = 145
    Height = 23
    TabOrder = 9
    OnChange = ComboBox_FilterCategoryChange
  end
  object Button_Complited: TButton
    Left = 521
    Top = 253
    Width = 75
    Height = 25
    Caption = #23436#20102#12479#12473#12463
    TabOrder = 10
    OnClick = Button_ComplitedClick
  end
end
