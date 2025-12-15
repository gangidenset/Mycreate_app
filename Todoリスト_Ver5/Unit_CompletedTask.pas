unit Unit_CompletedTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Unit_TaskTypes;

type
  TForm_CompletedTasklist = class(TForm)
    Label_Completed: TLabel;
    StringGrid_CompletedTasklist: TStringGrid;
    Button_CompletedReturn: TButton;
    Button_CompletedDelete: TButton;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid_CompletedTasklistMouseDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FTasks: TArray<TTaskItem>;
    FIndexMap: array of Integer;
    procedure InitGrid;
  public
    procedure ShowCompletedTasks(var Tasks: TArray<TTaskItem>);
  end;


var
  Form_CompletedTasklist: TForm_CompletedTasklist;

implementation

{$R *.dfm}

procedure TForm_CompletedTasklist.ShowCompletedTasks(
  var Tasks: TArray<TTaskItem>);
var
  i, Row: Integer;
begin
  FTasks := Tasks; // 参照共有（TArrayは参照型）

  StringGrid_CompletedTasklist.RowCount := 1;
  SetLength(FIndexMap, 0);
  Row := 1;

  for i := 0 to High(FTasks) do
  begin
    if FTasks[i].Completed then
    begin
      StringGrid_CompletedTasklist.RowCount := Row + 1;

      StringGrid_CompletedTasklist.Cells[0, Row] := '👍';
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
begin
  StringGrid_CompletedTasklist.MouseToCell(X, Y, Col, Row);
  if Row <= 0 then Exit;

  if Col = 0 then
  begin
    TaskIndex := FIndexMap[Row - 1];
    FTasks[TaskIndex].Completed := False;
    //ModalResult := mrOk;
    //FTasks[TaskIndex].Completed := False;
    ShowCompletedTasks(FTasks);
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
  StringGrid_CompletedTasklist.RowCount := 3;

  StringGrid_CompletedTasklist.Cells[0,0] := '完了';
  StringGrid_CompletedTasklist.Cells[1,0] := 'タスク';
  StringGrid_CompletedTasklist.Cells[2,0] := '優先度';
  StringGrid_CompletedTasklist.Cells[3,0] := 'カテゴリ';
  StringGrid_CompletedTasklist.Cells[4,0] := '期限';

end;

end.
