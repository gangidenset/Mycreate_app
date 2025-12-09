unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Notification;

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
    Button1: TButton;
    NotificationCenter1: TNotificationCenter;
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
    procedure Button1Click(Sender: TObject);
  private
    RemainingSec: Integer;
    procedure UpdateTimeLabel;
    procedure WMSize(var Msg: TMessage);
    message WM_SIZE;
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  S: string;
  Min: Integer;
begin
  //分数を入力してもらう
  S := InputBox('時間設定', '何分にセットしますか？', '3');

  //数値として読めたかチェック
  if TryStrToInt(S, Min) and (Min > 0) then
  begin
    RemainingSec := Min * 60;

    ProgressBar1.Max := RemainingSec;
    ProgressBar1.Position := RemainingSec;

    UpdateTimeLabel;

    ShowMessage(Format('%d 分にセットしました！', [Min]));
  end
  else
    ShowMessage('正しい分数を入れてください！');
end;

procedure TForm1.Button_ResetClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  RemainingSec := 0;
  ProgressBar1.Position := RemainingSec;
  UpdateTimeLabel;
end;

procedure TForm1.Button_StartClick(Sender: TObject);
begin
  ProgressBar1.Max := RemainingSec; // 最大値セット
  ProgressBar1.Position := RemainingSec; // 初期値(満タン)

  UpdateTimeLabel;
  Timer1.Enabled := True;
end;

procedure TForm1.Button_StopClick(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Timer1.Enabled := False;
    Button_Stop.Caption := '再開';
  end
  else
  begin
    Timer1.Enabled := True;
    Button_Stop.Caption := 'ストップ';
  end;
end;

procedure TForm1.Pop_ExitClick(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;  // フォームを閉じても隠すだけ
  TrayIcon1.Visible := True;
  Hide;
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
  Show;
  Application.Restore;
  TrayIcon1.Visible := False;
end;

procedure TForm1.Pop_startClick(Sender: TObject);
begin
  RemainingSec := 180;

  ProgressBar1.Max := RemainingSec; // 最大値セット
  ProgressBar1.Position := RemainingSec; // 初期値(満タン)

  UpdateTimeLabel;
  Timer1.Enabled := True;
end;

procedure TForm1.Pop_stopClick(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TForm1.Pop_toggleClick(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Timer1.Enabled := False;
    Pop_toggle.Caption := 'restart（再開）';
  end
  else
  begin
    Timer1.Enabled := True;
    Pop_toggle.Caption := 'stop（一時停止）';
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  N: TNotification;
begin
  Dec(RemainingSec);

  if RemainingSec <= 0 then
  begin
    RemainingSec := 0;
    Timer1.Enabled := False;

    // トースト通知作成
    N := NotificationCenter1.CreateNotification;
    try
      N.Title := 'タイマー完了';
      N.AlertBody := '時間になりました！';
      NotificationCenter1.PresentNotification(N);
    finally
      N.Free;
    end;
  end;

  ProgressBar1.Position := RemainingSec;

  UpdateTimeLabel;
end;


procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  Show;
  Application.Restore;
  TrayIcon1.Visible := False;
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
  begin
    Hide;
    TrayIcon1.Visible := True;
  end;
end;


end.
