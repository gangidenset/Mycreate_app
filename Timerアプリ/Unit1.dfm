object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 225
  ClientWidth = 198
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  TextHeight = 15
  object Label_Time: TLabel
    Left = 50
    Top = 24
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
  object Button1: TButton
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
    OnClick = Button1Click
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
