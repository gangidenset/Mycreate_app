object Form_TaskList: TForm_TaskList
  Left = 0
  Top = 0
  Caption = 'Form_TaskList'
  ClientHeight = 441
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Label_Search: TLabel
    Left = 40
    Top = 32
    Width = 39
    Height = 15
    Caption = #26908#32034#65306
  end
  object Label_Filter: TLabel
    Left = 32
    Top = 8
    Width = 47
    Height = 15
    Caption = #12501#12451#12523#12479#12540
  end
  object Label_Priority: TLabel
    Left = 27
    Top = 61
    Width = 52
    Height = 15
    Caption = #20778#20808#24230#65306
  end
  object Label_Category: TLabel
    Left = 29
    Top = 90
    Width = 50
    Height = 15
    Caption = #12459#12486#12468#12522#65306
  end
  object Label_Tasklist: TLabel
    Left = 24
    Top = 147
    Width = 55
    Height = 15
    Caption = 'ToDo'#12522#12473#12488
  end
  object Label_Status: TLabel
    Left = 14
    Top = 119
    Width = 65
    Height = 15
    Caption = #36914#34892#29366#27841#65306
  end
  object Edit_Search: TEdit
    Left = 77
    Top = 29
    Width = 444
    Height = 23
    TabOrder = 0
    OnChange = Edit_SearchChange
  end
  object ComboBox_Priority: TComboBox
    Left = 77
    Top = 58
    Width = 348
    Height = 23
    TabOrder = 1
    OnChange = ComboBox_PriorityChange
    Items.Strings = (
      ''
      '1'
      '2'
      '3'
      '4'
      '5')
  end
  object ComboBox_Category: TComboBox
    Left = 77
    Top = 87
    Width = 348
    Height = 23
    TabOrder = 2
    OnChange = ComboBox_CategoryChange
    Items.Strings = (
      ''
      #20181#20107
      #36259#21619
      #23398#32722
      #12381#12398#20182)
  end
  object StringGrid_Tasklist: TStringGrid
    Left = 24
    Top = 168
    Width = 497
    Height = 265
    RowCount = 6
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
    TabOrder = 3
    OnDrawCell = StringGrid_TasklistDrawCell
    OnMouseDown = StringGrid_TasklistMouseDown
  end
  object Button_Reset: TButton
    Left = 541
    Top = 408
    Width = 75
    Height = 25
    Caption = #21021#26399#21270
    TabOrder = 4
    OnClick = Button_ResetClick
  end
  object Button_Delete: TButton
    Left = 541
    Top = 377
    Width = 75
    Height = 25
    Caption = #21066#38500
    TabOrder = 5
    OnClick = Button_DeleteClick
  end
  object Button_Add: TButton
    Left = 541
    Top = 315
    Width = 75
    Height = 25
    Caption = #36861#21152
    TabOrder = 6
    OnClick = Button_AddClick
  end
  object Button_Completed: TButton
    Left = 541
    Top = 284
    Width = 75
    Height = 25
    Caption = #23436#20102#12479#12473#12463
    TabOrder = 7
    OnClick = Button_CompletedClick
  end
  object Button_Edit: TButton
    Left = 541
    Top = 346
    Width = 75
    Height = 25
    Caption = #32232#38598
    TabOrder = 8
    OnClick = Button_EditClick
  end
  object Button_FilterReset: TButton
    Left = 431
    Top = 58
    Width = 90
    Height = 81
    Caption = #12522#12475#12483#12488
    TabOrder = 9
    WordWrap = True
    OnClick = Button_FilterResetClick
  end
  object ComboBox_Status: TComboBox
    Left = 77
    Top = 116
    Width = 348
    Height = 23
    TabOrder = 10
    OnChange = ComboBox_StatusChange
    Items.Strings = (
      ''
      #26410#30528#25163
      #36914#34892#20013
      #20445#30041)
  end
end
