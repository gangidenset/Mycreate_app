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
    procedure Button_CompletedReturnClick(Sender: TObject);
    procedure Button_CompletedDeleteClick(Sender: TObject);
  private
    FIndexMap: array of Integer;
    FSelectedIndex: Integer;
    procedure InitGrid;
    procedure StringGrid_CompletedTasklistMouseDown(
      Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    procedure ShowCompletedTasks(const Tasks: TArray<TTaskItem>);
    property SelectedIndex: Integer read FSelectedIndex;

  end;


var
  Form_CompletedTasklist: TForm_CompletedTasklist;

implementation

{$R *.dfm}

procedure TForm_CompletedTasklist.ShowCompletedTasks(
  const Tasks: TArray<TTaskItem>);
var
  i, Row: Integer;
begin
  StringGrid_CompletedTasklist.RowCount := 1;
  SetLength(FIndexMap, 0);
  FSelectedIndex := -1;
  Row := 1;

  for i := 0 to High(Tasks) do
  begin
    if Tasks[i].Completed then
    begin
      StringGrid_CompletedTasklist.RowCount := Row + 1;

      StringGrid_CompletedTasklist.Cells[0, Row] := 'check';
      StringGrid_CompletedTasklist.Cells[1, Row] := Tasks[i].Text;
      StringGrid_CompletedTasklist.Cells[2, Row] := IntToStr(Tasks[i].Priority);
      StringGrid_CompletedTasklist.Cells[3, Row] := Tasks[i].Category;
      StringGrid_CompletedTasklist.Cells[4, Row] := DateToStr(Tasks[i].Deadline);

      SetLength(FIndexMap, Length(FIndexMap) + 1);
      FIndexMap[High(FIndexMap)] := i;

      Inc(Row);
    end;
  end;
end;

procedure TForm_CompletedTasklist.StringGrid_CompletedTasklistMouseDown(
  Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  StringGrid_CompletedTasklist.MouseToCell(X, Y, Col, Row);
  if Row <= 0 then Exit;

  FSelectedIndex := FIndexMap[Row - 1];
end;


procedure TForm_CompletedTasklist.Button_CompletedDeleteClick(Sender: TObject);
begin
  if FSelectedIndex < 0 then Exit;

  if MessageDlg('このタスクを削除しますか？',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    ModalResult := mrYes;
end;


procedure TForm_CompletedTasklist.Button_CompletedReturnClick(Sender: TObject);
begin
  if FSelectedIndex < 0 then Exit;
  ModalResult := mrOk;
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
