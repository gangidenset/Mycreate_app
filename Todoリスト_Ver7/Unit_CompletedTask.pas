unit Unit_CompletedTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  Unit_TaskTypes, Vcl.StdCtrls;

type
  TForm_CompletedTasklist = class(TForm)
    StringGrid_CompletedTasklist: TStringGrid;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid_CompletedTasklistMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FIndexMap: array of Integer;
    FTasks: TArray<TTaskItem>; // 参照用配列を保持
    procedure InitGrid;
  public
    procedure ShowCompletedTasks(const Tasks: TArray<TTaskItem>);
  end;

var
  Form_CompletedTasklist: TForm_CompletedTasklist;

implementation

{$R *.dfm}

uses
  Unit_Tasklist;

procedure TForm_CompletedTasklist.ShowCompletedTasks(
  const Tasks: TArray<TTaskItem>);
var
  i, Row: Integer;
begin
  FTasks := Tasks; // 参照を保持
  StringGrid_CompletedTasklist.RowCount := 1;
  SetLength(FIndexMap, 0);
  Row := 1;

  for i := 0 to High(FTasks) do
  begin
    if FTasks[i].Completed then
    begin
      StringGrid_CompletedTasklist.RowCount := Row + 1;

      StringGrid_CompletedTasklist.Cells[0, Row] := '✔';
      StringGrid_CompletedTasklist.Cells[1, Row] := FTasks[i].Text;
      StringGrid_CompletedTasklist.Cells[2, Row] := IntToStr(FTasks[i].Priority);
      StringGrid_CompletedTasklist.Cells[3, Row] := FTasks[i].Category;
      StringGrid_CompletedTasklist.Cells[4, Row] := DateToStr(FTasks[i].Deadline);

      SetLength(FIndexMap, Length(FIndexMap) + 1);
      FIndexMap[High(FIndexMap)] := i;

      Inc(Row);
    end;
  end;
end;

procedure TForm_CompletedTasklist.StringGrid_CompletedTasklistMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row, TaskIndex: Integer;
  TaskForm: TForm_TaskList;
begin
  StringGrid_CompletedTasklist.MouseToCell(X, Y, Col, Row);
  if (Row <= 0) or (Col <> 0) then Exit;

  TaskIndex := FIndexMap[Row - 1];  // 完了タスクの元配列でのインデックス
  FTasks[TaskIndex].Completed := False;

  // ✔を外して表示更新
  ShowCompletedTasks(FTasks);

  // 親フォームの未完了タスク一覧も更新
  if Owner is TForm_TaskList then
  begin
    TaskForm := TForm_TaskList(Owner);
    TaskForm.RefreshGrid;
  end;
end;

procedure TForm_CompletedTasklist.FormCreate(Sender: TObject);
begin
  InitGrid;
end;

procedure TForm_CompletedTasklist.InitGrid;
begin
  StringGrid_CompletedTasklist.ColCount := 5;
  StringGrid_CompletedTasklist.FixedRows := 1;
  StringGrid_CompletedTasklist.RowCount := 1;

  StringGrid_CompletedTasklist.Cells[0,0] := '完了';
  StringGrid_CompletedTasklist.Cells[1,0] := 'タスク';
  StringGrid_CompletedTasklist.Cells[2,0] := '優先度';
  StringGrid_CompletedTasklist.Cells[3,0] := 'カテゴリ';
  StringGrid_CompletedTasklist.Cells[4,0] := '期限';

  StringGrid_CompletedTasklist.ColWidths[0] := 40;  // 完了チェック用
  StringGrid_CompletedTasklist.ColWidths[1] := 353; // タスク名
  StringGrid_CompletedTasklist.ColWidths[2] := 60;  // 優先度
  StringGrid_CompletedTasklist.ColWidths[3] := 60; // カテゴリ
  StringGrid_CompletedTasklist.ColWidths[4] := 100; // 期限
end;

end.

