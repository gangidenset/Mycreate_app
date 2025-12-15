unit Unit_Tasklist;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Unit_TaskTypes, Unit_CompletedTask;

type
  TForm_TaskList = class(TForm)
    Label_Search: TLabel;
    Edit_Search: TEdit;
    Label_Filter: TLabel;
    Label_Priority: TLabel;
    Label_Category: TLabel;
    ComboBox_Priority: TComboBox;
    ComboBox_Category: TComboBox;
    Label_Tasklist: TLabel;
    StringGrid_Tasklist: TStringGrid;
    Button_Reset: TButton;
    Button_Delete: TButton;
    Button_Add: TButton;
    Button_Completed: TButton;
    Button_Edit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button_AddClick(Sender: TObject);
    procedure Button_EditClick(Sender: TObject);
    procedure StringGrid_TasklistMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Button_CompletedClick(Sender: TObject);
  private
    FTasks: TArray<TTaskItem>;
    procedure InitGrid;
    procedure RefreshGrid;
  public
    { Public 宣言 }
  end;

var
  Form_TaskList: TForm_TaskList;

implementation

uses
  Unit_ToggleTask;

{$R *.dfm}

procedure TForm_TaskList.RefreshGrid;
var
  i: Integer;
begin
  StringGrid_Tasklist.RowCount := Length(FTasks) + 1;

  for i := 0 to High(FTasks) do
  begin
    StringGrid_Tasklist.Cells[0, i+1] := IfThen(FTasks[i].Completed, '👍', '');
    StringGrid_Tasklist.Cells[1, i+1] := FTasks[i].Text;
    StringGrid_Tasklist.Cells[2, i+1] := IntToStr(FTasks[i].Priority);
    StringGrid_Tasklist.Cells[3, i+1] := FTasks[i].Category;
    StringGrid_Tasklist.Cells[4, i+1] := DateToStr(FTasks[i].Deadline);
  end;
end;

procedure TForm_TaskList.StringGrid_TasklistMouseDown(
  Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  StringGrid_Tasklist.MouseToCell(X, Y, Col, Row);

  // ヘッダー行は選択不可
  if Row <= 0 then Exit;

  // チェック列（0列）だけ反応
  if Col = 0 then
  begin
    FTasks[Row - 1].Completed := not FTasks[Row - 1].Completed;
    RefreshGrid;
  end;
end;

procedure TForm_TaskList.Button_AddClick(Sender: TObject);
var
  T: TTaskItem;
  Dlg: TForm_ToggleTask;
begin
  Dlg := TForm_ToggleTask.Create(Self);
  try
    Dlg.SetupForAdd;

    if Dlg.ShowModal = mrOk then
    begin
      T := Dlg.GetTask;
      FTasks := FTasks + [T];
      RefreshGrid;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm_TaskList.Button_CompletedClick(Sender: TObject);
var
  Dlg: TForm_CompletedTasklist;
begin
  Dlg := TForm_CompletedTasklist.Create(Self);
  try
    Dlg.ShowCompletedTasks(FTasks);
    if Dlg.ShowModal = mrOk then
      RefreshGrid;
  finally
    Dlg.Free;
  end;
end;

procedure TForm_TaskList.Button_EditClick(Sender: TObject);
var
  Row: Integer;
  Dlg: TForm_ToggleTask;
begin
  Row := StringGrid_Tasklist.Row;
  if Row <= 0 then Exit;

  Dlg := TForm_ToggleTask.Create(Self);
  try
    Dlg.SetupForToggle(FTasks[Row - 1]);

    if Dlg.ShowModal = mrOk then
    begin
      FTasks[Row - 1] := Dlg.GetTask;
      RefreshGrid;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm_TaskList.FormCreate(Sender: TObject);
begin
  InitGrid;
end;

procedure TForm_TaskList.InitGrid;
begin
  StringGrid_Tasklist.ColCount := 5;
  StringGrid_Tasklist.FixedRows := 1;
  StringGrid_Tasklist.RowCount := 1;

  StringGrid_Tasklist.Cells[0,0] := '完了';
  StringGrid_Tasklist.Cells[1,0] := 'タスク';
  StringGrid_Tasklist.Cells[2,0] := '優先度';
  StringGrid_Tasklist.Cells[3,0] := 'カテゴリ';
  StringGrid_Tasklist.Cells[4,0] := '期限';
end;

end.
