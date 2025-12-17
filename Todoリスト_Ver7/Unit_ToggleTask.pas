unit Unit_ToggleTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Unit_TaskTypes;

type
  TToggleMode = (tmAdd, tmEdit);

type
  TForm_ToggleTask = class(TForm)
    Label_Toggle: TLabel;
    Label_ToggleTask: TLabel;
    Label_ToggleCategory: TLabel;
    Label_TogglePriority: TLabel;
    Label_ToggleDeadline: TLabel;
    Edit_ToggleTask: TEdit;
    ComboBox_TogglePriority: TComboBox;
    ComboBox_ToggleCategory: TComboBox;
    DateTimePicker_ToggleDeadline: TDateTimePicker;
    Button_ToggleOK: TButton;
    Button_ToggleCancel: TButton;
    ComboBox_ToggleStatus: TComboBox;
    Label_ToggleStatus: TLabel;
    Button_1week: TButton;
    Label_ToggleExtendDeadline: TLabel;
    Button_2week: TButton;
    Button_1month: TButton;
    Button_3days: TButton;
    procedure Button_ToggleOKClick(Sender: TObject);
    procedure Button_ToggleCancelClick(Sender: TObject);
    procedure Button_1weekClick(Sender: TObject);
    procedure Button_3daysClick(Sender: TObject);
    procedure Button_2weekClick(Sender: TObject);
    procedure Button_1monthClick(Sender: TObject);
  private
    FMode: TToggleMode;
    FOriginalCompleted: Boolean;
  public
    procedure SetupForAdd;
    procedure SetupForToggle(const Task: TTaskItem);
    function GetTask: TTaskItem;
  end;

implementation

{$R *.dfm}

procedure TForm_ToggleTask.SetupForAdd;
begin
  FMode := tmAdd;
  Label_Toggle.Caption := 'タスク追加';

  Edit_ToggleTask.Text := '';
  FOriginalCompleted := False;
  ComboBox_TogglePriority.ItemIndex := 0;
  ComboBox_ToggleCategory.ItemIndex := -1;
  DateTimePicker_ToggleDeadline.Date := Date;
  ComboBox_ToggleStatus.ItemIndex := 0;
end;

procedure TForm_ToggleTask.SetupForToggle(const Task: TTaskItem);
begin
  FMode := tmEdit;
  Label_Toggle.Caption := 'タスク編集';

  Edit_ToggleTask.Text := Task.Text;
  FOriginalCompleted := Task.Completed;
  ComboBox_TogglePriority.ItemIndex := Task.Priority;
  ComboBox_ToggleCategory.Text := Task.Category;
  DateTimePicker_ToggleDeadline.Date := Task.Deadline;
  case Task.Status of
    tsNotStarted: ComboBox_ToggleStatus.ItemIndex := 0;
    tsInProgress: ComboBox_ToggleStatus.ItemIndex := 1;
    tsOnHold: ComboBox_ToggleStatus.ItemIndex := 2;
  end;
end;

procedure TForm_ToggleTask.Button_3daysClick(Sender: TObject);
begin
  DateTimePicker_ToggleDeadline.Date := DateTimePicker_ToggleDeadline.Date + 3;
end;

procedure TForm_ToggleTask.Button_1weekClick(Sender: TObject);
begin
  DateTimePicker_ToggleDeadline.Date := DateTimePicker_ToggleDeadline.Date + 7;
end;

procedure TForm_ToggleTask.Button_2weekClick(Sender: TObject);
begin
  DateTimePicker_ToggleDeadline.Date := DateTimePicker_ToggleDeadline.Date + 14;
end;

procedure TForm_ToggleTask.Button_1monthClick(Sender: TObject);
begin
  DateTimePicker_ToggleDeadline.Date := DateTimePicker_ToggleDeadline.Date + 30;
end;

procedure TForm_ToggleTask.Button_ToggleCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;


procedure TForm_ToggleTask.Button_ToggleOKClick(Sender: TObject);
begin
  if Edit_ToggleTask.Text = '' then
  begin
    ShowMessage('タスク名を入力してください');
    Exit;
  end;

  ModalResult := mrOk;
end;

function TForm_ToggleTask.GetTask: TTaskItem;
begin
  Result.Text := Edit_ToggleTask.Text;
  Result.Priority := ComboBox_TogglePriority.ItemIndex;
  Result.Category := ComboBox_ToggleCategory.Text;
  Result.Deadline := DateTimePicker_ToggleDeadline.Date;

  case ComboBox_ToggleStatus.ItemIndex of
    0: Result.Status := tsNotStarted;
    1: Result.Status := tsInProgress;
    2: Result.Status := tsOnHold;
  end;

  if FMode = tmAdd then
    Result.Completed := False
  else
    Result.Completed := FOriginalCompleted;
end;


end.
