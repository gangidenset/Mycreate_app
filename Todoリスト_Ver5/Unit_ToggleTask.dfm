object Form_ToggleTask: TForm_ToggleTask
  Left = 0
  Top = 0
  Caption = 'Form_ToggleTask'
  ClientHeight = 225
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label_Toggle: TLabel
    Left = 24
    Top = 16
    Width = 59
    Height = 15
    Caption = #36861#21152#12539#32232#38598
  end
  object Label_ToggleTask: TLabel
    Left = 24
    Top = 48
    Width = 54
    Height = 15
    Caption = #12479#12473#12463#21517#65306
  end
  object Label_ToggleCategory: TLabel
    Left = 24
    Top = 112
    Width = 50
    Height = 15
    Caption = #12459#12486#12468#12522#65306
  end
  object Label_TogglePriority: TLabel
    Left = 24
    Top = 80
    Width = 52
    Height = 15
    Caption = #20778#20808#24230#65306
  end
  object Label_ToggleDeadline: TLabel
    Left = 24
    Top = 146
    Width = 39
    Height = 15
    Caption = #26399#38480#65306
  end
  object Edit_ToggleTask: TEdit
    Left = 88
    Top = 45
    Width = 521
    Height = 23
    TabOrder = 0
  end
  object ComboBox_TogglePriority: TComboBox
    Left = 88
    Top = 77
    Width = 521
    Height = 23
    TabOrder = 1
    Items.Strings = (
      ''
      '1'
      '2'
      '3'
      '4'
      '5')
  end
  object ComboBox_ToggleCategory: TComboBox
    Left = 88
    Top = 109
    Width = 521
    Height = 23
    TabOrder = 2
    Items.Strings = (
      #20181#20107
      #36259#21619
      #23398#32722
      #12381#12398#20182)
  end
  object DateTimePicker_ToggleDeadline: TDateTimePicker
    Left = 88
    Top = 142
    Width = 521
    Height = 23
    Date = 46006.000000000000000000
    Time = 0.587797025465988600
    TabOrder = 3
  end
  object Button_ToggleOK: TButton
    Left = 440
    Top = 184
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = Button_ToggleOKClick
  end
  object Button_ToggleCancel: TButton
    Left = 534
    Top = 184
    Width = 75
    Height = 25
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 5
    OnClick = Button_ToggleCancelClick
  end
end
