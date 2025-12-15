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
    procedure Button_ToggleOKClick(Sender: TObject);
    procedure Button_ToggleCancelClick(Sender: TObject);
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
  if FMode = tmAdd then
    Result.Completed := False
  else
    Result.Completed := FOriginalCompleted;
end;

end.
