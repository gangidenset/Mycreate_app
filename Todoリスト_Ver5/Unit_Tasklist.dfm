object Form_TaskList: TForm_TaskList
  Left = 0
  Top = 0
  Caption = 'Form_TaskList'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label_Search: TLabel
    Left = 24
    Top = 8
    Width = 26
    Height = 15
    Caption = #26908#32034
  end
  object Label_Filter: TLabel
    Left = 24
    Top = 58
    Width = 47
    Height = 15
    Caption = #12501#12451#12523#12479#12540
  end
  object Label_Priority: TLabel
    Left = 27
    Top = 79
    Width = 52
    Height = 15
    Caption = #20778#20808#24230#65306
  end
  object Label_Category: TLabel
    Left = 248
    Top = 79
    Width = 50
    Height = 15
    Caption = #12459#12486#12468#12522#65306
  end
  object Label_Tasklist: TLabel
    Left = 24
    Top = 105
    Width = 54
    Height = 15
    Caption = 'ToDo'#12522#12473#12488
  end
  object Edit_Search: TEdit
    Left = 24
    Top = 29
    Width = 497
    Height = 23
    TabOrder = 0
  end
  object ComboBox_Priority: TComboBox
    Left = 77
    Top = 76
    Width = 145
    Height = 23
    TabOrder = 1
  end
  object ComboBox_Category: TComboBox
    Left = 304
    Top = 76
    Width = 145
    Height = 23
    TabOrder = 2
  end
  object StringGrid_Tasklist: TStringGrid
    Left = 24
    Top = 126
    Width = 497
    Height = 307
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    TabOrder = 3
    OnMouseDown = StringGrid_TasklistMouseDown
  end
  object Button_Reset: TButton
    Left = 541
    Top = 408
    Width = 75
    Height = 25
    Caption = #21021#26399#21270
    TabOrder = 4
  end
  object Button_Delete: TButton
    Left = 541
    Top = 368
    Width = 75
    Height = 25
    Caption = #21066#38500
    TabOrder = 5
  end
  object Button_Add: TButton
    Left = 541
    Top = 288
    Width = 75
    Height = 25
    Caption = #36861#21152
    TabOrder = 6
    OnClick = Button_AddClick
  end
  object Button_Completed: TButton
    Left = 541
    Top = 248
    Width = 75
    Height = 25
    Caption = #23436#20102#12479#12473#12463
    TabOrder = 7
    OnClick = Button_CompletedClick
  end
  object Button_Edit: TButton
    Left = 541
    Top = 328
    Width = 75
    Height = 25
    Caption = #32232#38598
    TabOrder = 8
    OnClick = Button_EditClick
  end
end
