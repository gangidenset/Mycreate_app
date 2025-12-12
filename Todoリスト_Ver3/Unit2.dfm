object Form_TaskEdit: TForm_TaskEdit
  Left = 0
  Top = 0
  Caption = 'Form_TaskEdit'
  ClientHeight = 238
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label_EditTask: TLabel
    Left = 36
    Top = 51
    Width = 54
    Height = 15
    Caption = #12479#12473#12463#21517#65306
  end
  object Label_EditCategory: TLabel
    Left = 40
    Top = 91
    Width = 50
    Height = 15
    Caption = #12459#12486#12468#12522#65306
  end
  object Label_EditPriority: TLabel
    Left = 38
    Top = 131
    Width = 52
    Height = 15
    Caption = #20778#20808#24230#65306
  end
  object Label_EditDeadline: TLabel
    Left = 47
    Top = 174
    Width = 39
    Height = 15
    Caption = #26399#38480#65306
  end
  object Label_EditToggle: TLabel
    Left = 16
    Top = 16
    Width = 3
    Height = 15
  end
  object Edit_Task: TEdit
    Left = 96
    Top = 48
    Width = 505
    Height = 23
    TabOrder = 0
    OnKeyDown = Edit_TaskKeyDown
  end
  object ComboBox_Category: TComboBox
    Left = 96
    Top = 88
    Width = 505
    Height = 23
    TabOrder = 1
    OnKeyDown = ComboBox_CategoryKeyDown
  end
  object ComboBox_Priority: TComboBox
    Left = 96
    Top = 128
    Width = 505
    Height = 23
    TabOrder = 2
    OnKeyDown = ComboBox_PriorityKeyDown
  end
  object dtp_Deadline: TDateTimePicker
    Left = 96
    Top = 168
    Width = 505
    Height = 23
    Date = 46001.000000000000000000
    Time = 0.670696956018218800
    TabOrder = 3
    OnKeyDown = dtp_DeadlineKeyDown
  end
  object Button_OK: TButton
    Left = 432
    Top = 205
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = Button_OKClick
  end
  object Button_Cancel: TButton
    Left = 526
    Top = 205
    Width = 75
    Height = 25
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 5
    OnClick = Button_CancelClick
  end
end
