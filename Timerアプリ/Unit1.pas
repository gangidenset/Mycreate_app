unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Notification, DateUtils;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Label_Time: TLabel;
    Button_Start: TButton;
    Button_Stop: TButton;
    Button_Reset: TButton;
    ProgressBar1: TProgressBar;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Pop_show: TMenuItem;
    Pop_reset: TMenuItem;
    Pop_Exit: TMenuItem;
    Pop_start: TMenuItem;
    Pop_toggle: TMenuItem;
    Button_SetTime: TButton;
    NotificationCenter1: TNotificationCenter;
    Label_EndTime: TLabel;
    Button_5min: TButton;
    Button_10min: TButton;
    Button_30min: TButton;
    Button_60min: TButton;
    Button_3min: TButton;
    procedure Button_StartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button_StopClick(Sender: TObject);
    procedure Button_ResetClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Pop_showClick(Sender: TObject);
    procedure Pop_stopClick(Sender: TObject);
    procedure Pop_resetClick(Sender: TObject);
    procedure Pop_ExitClick(Sender: TObject);
    procedure Pop_restartClick(Sender: TObject);
    procedure Pop_startClick(Sender: TObject);
    procedure Pop_toggleClick(Sender: TObject);
    procedure Button_SetTimeClick(Sender: TObject);
    procedure Button_3minClick(Sender: TObject);
    procedure Button_5minClick(Sender: TObject);
    procedure Button_10minClick(Sender: TObject);
    procedure Button_30minClick(Sender: TObject);
    procedure Button_60minClick(Sender: TObject);
  private
    RemainingSec: Integer;
    procedure UpdateTimeLabel;
    procedure WMSize(var Msg: TMessage); message WM_SIZE;
    procedure SetTimer(Minutes: Integer);
    procedure ShowNotification(const Title, Body: string);
    procedure ShowFromTray;
    procedure HideToTray;
  public
  end;

var
  Form1: TForm1;
  EndTime: TDateTime;
  Min: Integer;

implementation

{$R *.dfm}

procedure TForm1.SetTimer(Minutes: Integer);
begin
  RemainingSec := Minutes * 60;
  EndTime := IncMinute(Now, Minutes);

  ProgressBar1.Max := RemainingSec;
  ProgressBar1.Position := RemainingSec;

  UpdateTimeLabel;
  Timer1.Enabled := True;
  Label_EndTime.Caption := '終了予定：' + FormatDateTime('hh:mm:ss', EndTime);
end;

procedure TForm1.ShowNotification(const Title, Body: string);
var
  N: TNotification;
begin
  N := NotificationCenter1.CreateNotification;
  try
    N.Title := Title;
    N.AlertBody := Body;
    NotificationCenter1.PresentNotification(N);
  finally
    N.Free;
  end;
end;

procedure TForm1.ShowFromTray;
begin
  Show;
  Application.Restore;
  TrayIcon1.Visible := False;
end;

procedure TForm1.HideToTray;
begin
  Hide;
  TrayIcon1.Visible := True;
end;

procedure TForm1.Button_SetTimeClick(Sender: TObject);
var
  S: string;
begin
  S := InputBox('時間設定', '何分にセットしますか？', '');
  if TryStrToInt(S, Min) and (Min > 0) then
  begin
    SetTimer(Min);
    ShowMessage(Format('%d 分にセットしました！', [Min]));
  end
  else
    ShowMessage('正しい分数を入れてください！');
end;

procedure TForm1.Button_3minClick(Sender: TObject);
begin
  SetTimer(3);
end;

procedure TForm1.Button_5minClick(Sender: TObject);
begin
  SetTimer(5);
end;

procedure TForm1.Button_10minClick(Sender: TObject);
begin
  SetTimer(10);
end;

procedure TForm1.Button_30minClick(Sender: TObject);
begin
  SetTimer(30);
end;

procedure TForm1.Button_60minClick(Sender: TObject);
begin
  SetTimer(60);
end;

procedure TForm1.Button_ResetClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  RemainingSec := 0;
  ProgressBar1.Position := RemainingSec;
  UpdateTimeLabel;
  Label_EndTime.Caption := '終了予定：'
end;

procedure TForm1.Button_StartClick(Sender: TObject);
begin
  ProgressBar1.Max := RemainingSec;
  ProgressBar1.Position := RemainingSec;
  UpdateTimeLabel;
  Timer1.Enabled := True;
end;

procedure TForm1.Button_StopClick(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
  if Timer1.Enabled then
    Button_Stop.Caption := 'ストップ'
  else
    Button_Stop.Caption := '再開';
end;

procedure TForm1.Pop_ExitClick(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
  HideToTray;
end;

procedure TForm1.Pop_restartClick(Sender: TObject);
begin
  UpdateTimeLabel;
  Timer1.Enabled := True;
end;

procedure TForm1.Pop_resetClick(Sender: TObject);
begin
  RemainingSec := 0;
  ProgressBar1.Position := RemainingSec;
  UpdateTimeLabel;
end;

procedure TForm1.Pop_showClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TForm1.Pop_startClick(Sender: TObject);
begin
  SetTimer(3);
end;

procedure TForm1.Pop_stopClick(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TForm1.Pop_toggleClick(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
  if Timer1.Enabled then
    Pop_toggle.Caption := 'stop（一時停止）'
  else
    Pop_toggle.Caption := 'restart（再開）';
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Dec(RemainingSec);
  if RemainingSec <= 0 then
  begin
    RemainingSec := 0;
    Timer1.Enabled := False;
    ShowNotification('タイマー完了', '時間になりました！');
    SetForegroundWindow(Self.Handle);
  end;
  ProgressBar1.Position := RemainingSec;
  UpdateTimeLabel;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TForm1.UpdateTimeLabel;
var
  mm, ss: Integer;
begin
  mm := RemainingSec div 60;
  ss := RemainingSec mod 60;
  Label_Time.Caption := Format('%.2d:%.2d', [mm, ss]);
  TrayIcon1.Hint := '残り時間：' + Format('%.2d:%.2d', [mm, ss]);
end;

procedure TForm1.WMSize(var Msg: TMessage);
begin
  inherited;
  if Msg.WParam = SIZE_MINIMIZED then
    HideToTray;
end;

end.

