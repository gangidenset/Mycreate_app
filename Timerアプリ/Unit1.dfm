object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 240
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  TextHeight = 15
  object Label_Time: TLabel
    Left = 44
    Top = 17
    Width = 100
    Height = 54
    Caption = 'Timer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -40
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label_EndTime: TLabel
    Left = 21
    Top = 217
    Width = 78
    Height = 15
    Caption = #32066#20102#20104#23450#26178#21051
  end
  object Button_Start: TButton
    Left = 21
    Top = 122
    Width = 67
    Height = 40
    Caption = #12473#12479#12540#12488
    TabOrder = 0
    OnClick = Button_StartClick
  end
  object Button_Stop: TButton
    Left = 102
    Top = 122
    Width = 67
    Height = 40
    Caption = #12473#12488#12483#12503
    TabOrder = 1
    OnClick = Button_StopClick
  end
  object Button_Reset: TButton
    Left = 21
    Top = 168
    Width = 67
    Height = 40
    Caption = #12522#12475#12483#12488
    TabOrder = 2
    OnClick = Button_ResetClick
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 84
    Width = 182
    Height = 16
    TabOrder = 3
  end
  object Button_SetTime: TButton
    Left = 102
    Top = 168
    Width = 67
    Height = 40
    Caption = #26178#38291#35373#23450
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Button_Settime'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = Button_SetTimeClick
  end
  object Button_5min: TButton
    Left = 196
    Top = 53
    Width = 67
    Height = 40
    Caption = '5'#20998
    TabOrder = 5
    OnClick = Button_5minClick
  end
  object Button_10min: TButton
    Left = 196
    Top = 99
    Width = 67
    Height = 40
    Caption = '10'#20998
    TabOrder = 6
    OnClick = Button_10minClick
  end
  object Button_30min: TButton
    Left = 196
    Top = 146
    Width = 67
    Height = 40
    Caption = '30'#20998
    TabOrder = 7
    OnClick = Button_30minClick
  end
  object Button_60min: TButton
    Left = 196
    Top = 192
    Width = 67
    Height = 40
    Caption = '60'#20998
    TabOrder = 8
    OnClick = Button_60minClick
  end
  object Button_3min: TButton
    Left = 196
    Top = 7
    Width = 67
    Height = 40
    Caption = '3'#20998
    TabOrder = 9
    OnClick = Button_3minClick
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 472
    Top = 408
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = TrayIcon1DblClick
    Left = 512
    Top = 408
  end
  object PopupMenu1: TPopupMenu
    Left = 552
    Top = 408
    object Pop_show: TMenuItem
      Caption = 'show'#65288#38283#12367#65289
      OnClick = Pop_showClick
    end
    object Pop_toggle: TMenuItem
      Caption = 'stop'#65288#19968#26178#20572#27490#65289
      OnClick = Pop_toggleClick
    end
    object Pop_reset: TMenuItem
      Caption = 'reset'#65288#12522#12475#12483#12488#65289
      OnClick = Pop_resetClick
    end
    object Pop_start: TMenuItem
      Caption = 'start'#65288#38283#22987#65289
      OnClick = Pop_startClick
    end
    object Pop_Exit: TMenuItem
      Caption = 'Exit'#65288#32066#20102#65289
      OnClick = Pop_ExitClick
    end
  end
  object NotificationCenter1: TNotificationCenter
    Left = 432
    Top = 408
  end
end
