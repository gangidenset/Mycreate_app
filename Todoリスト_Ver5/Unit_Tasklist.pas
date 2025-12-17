unit Unit_Tasklist;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Generics.Collections, System.Generics.Defaults,
  System.DateUtils, System.JSON, System.IOUtils, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Unit_TaskTypes, Unit_CompletedTask;

type
  TDeadlineLevel = record
    Days: Integer;
    Color: TColor;
  end;

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
    Button_FilterReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_AddClick(Sender: TObject);
    procedure Button_EditClick(Sender: TObject);
    procedure StringGrid_TasklistMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_CompletedClick(Sender: TObject);
    procedure Edit_SearchChange(Sender: TObject);
    procedure ComboBox_PriorityChange(Sender: TObject);
    procedure ComboBox_CategoryChange(Sender: TObject);
    procedure Button_FilterResetClick(Sender: TObject);
    procedure Button_DeleteClick(Sender: TObject);
    procedure Button_ResetClick(Sender: TObject);
    procedure StringGrid_TasklistDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    FTasks: TArray<TTaskItem>;
    FRowIndexMap: array of Integer;
    FSortCol: Integer;
    FSortDescending: Boolean;
    FIni: TIniFile;
    FSaving: Boolean; // 保存中フラグ
    procedure InitGrid;
    procedure SortTasks;
    procedure SaveTasksToFile;
    procedure LoadTasksFromFile;
    procedure LoadSettings(Ini: TIniFile);
    procedure BackupTasksFile;
  public
    procedure RefreshGrid;
    procedure SetTaskCompleted(Index: Integer; Completed: Boolean);
  end;

var
  Form_TaskList: TForm_TaskList;
  FDeadlineLevels: array[1..3] of TDeadlineLevel;

const
  MAX_BACKUP_COUNT = 100;

implementation

uses
  Unit_ToggleTask;

{$R *.dfm}

{ ===================== ユーティリティ ===================== }

function ReadColor(Ini: TIniFile; const Section, Ident: string; Default: TColor): TColor;
var
  S: string;
  V: Integer;
begin
  S := Ini.ReadString(Section, Ident, '');
  if S <> '' then
  begin
    if TryStrToInt(S, V) then
      Exit(V);
  end;
  Result := Default;
end;

function GetLatestBackupFile: string;
var
  Dir: string;
  Files: TArray<string>;
begin
  Result := '';
  Dir := TPath.Combine(TPath.GetDocumentsPath, 'TaskBackups');
  if not TDirectory.Exists(Dir) then Exit;

  Files := TDirectory.GetFiles(Dir, 'tasks_*.json');
  if Length(Files) = 0 then Exit;

  TArray.Sort<string>(Files);
  Result := Files[High(Files)];
end;

{ ===================== 初期化 / 終了 ===================== }

procedure TForm_TaskList.FormCreate(Sender: TObject);
var
  IniFileName: string;
begin
  InitGrid;
  FSortCol := 4;
  FSortDescending := False;

  IniFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'setting.ini');
  FIni := TIniFile.Create(IniFileName);
  LoadSettings(FIni);

  LoadTasksFromFile;
  RefreshGrid;
end;

procedure TForm_TaskList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveTasksToFile;
  FIni.Free;
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

  StringGrid_Tasklist.ColWidths[0] := 40;
  StringGrid_Tasklist.ColWidths[1] := 353;
  StringGrid_Tasklist.ColWidths[2] := 60;
  StringGrid_Tasklist.ColWidths[3] := 60;
  StringGrid_Tasklist.ColWidths[4] := 100;
end;

{ ===================== ソート ===================== }

procedure TForm_TaskList.SortTasks;
var
  Comparer: IComparer<TTaskItem>;
begin
  Comparer := TComparer<TTaskItem>.Construct(
    function(const A, B: TTaskItem): Integer
    begin
      case FSortCol of
        1: Result := CompareStr(A.Text, B.Text);
        2: Result := A.Priority - B.Priority;
        3: Result := CompareStr(A.Category, B.Category);
        4: Result := CompareDateTime(A.Deadline, B.Deadline);
      else
        Result := 0;
      end;
      if FSortDescending then Result := -Result;
    end
  );
  TArray.Sort<TTaskItem>(FTasks, Comparer);
end;

{ ===================== 表示更新 ===================== }

procedure TForm_TaskList.RefreshGrid;
var
  i, Row: Integer;
  ShowTask: Boolean;
begin
  SortTasks;
  Row := 1;
  StringGrid_Tasklist.RowCount := 1;
  SetLength(FRowIndexMap, 0);

  for i := 0 to High(FTasks) do
  begin
    if FTasks[i].Completed then Continue;

    ShowTask := True;
    if (Edit_Search.Text <> '') and (Pos(Edit_Search.Text, FTasks[i].Text) = 0) then
      ShowTask := False;
    if (ComboBox_Priority.Text <> '') and (IntToStr(FTasks[i].Priority) <> ComboBox_Priority.Text) then
      ShowTask := False;
    if (ComboBox_Category.Text <> '') and (FTasks[i].Category <> ComboBox_Category.Text) then
      ShowTask := False;

    if ShowTask then
    begin
      StringGrid_Tasklist.RowCount := Row + 1;
      StringGrid_Tasklist.Cells[0, Row] := '';
      StringGrid_Tasklist.Cells[1, Row] := FTasks[i].Text;
      StringGrid_Tasklist.Cells[2, Row] := IntToStr(FTasks[i].Priority);
      StringGrid_Tasklist.Cells[3, Row] := FTasks[i].Category;
      StringGrid_Tasklist.Cells[4, Row] := DateToStr(FTasks[i].Deadline);

      SetLength(FRowIndexMap, Row);
      FRowIndexMap[Row - 1] := i;
      Inc(Row);
    end;
  end;
end;

{ ===================== セル描画 ===================== }

procedure TForm_TaskList.StringGrid_TasklistDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  TaskIndex: Integer;
  DaysLeft: Integer;
  BGColor: TColor;
  TextRect: TRect;
  Text: string;
begin
  StringGrid_Tasklist.Canvas.Font.Assign(StringGrid_Tasklist.Font);
  if ARow = 0 then
  begin
    StringGrid_Tasklist.Canvas.Brush.Color := clBtnFace;
    StringGrid_Tasklist.Canvas.FillRect(Rect);
    Text := StringGrid_Tasklist.Cells[ACol, ARow];
    TextRect := Rect;
    DrawText(StringGrid_Tasklist.Canvas.Handle, PChar(Text), Length(Text),
      TextRect, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
    Exit;
  end;

  BGColor := clWhite;

  if (ARow > 0) and (ARow <= Length(FRowIndexMap)) and (ACol <> 0) then
  begin
    TaskIndex := FRowIndexMap[ARow - 1];
    DaysLeft := DaysBetween(Date, FTasks[TaskIndex].Deadline);

    if DaysLeft <= FDeadlineLevels[1].Days then
      BGColor := FDeadlineLevels[1].Color
    else if DaysLeft <= FDeadlineLevels[2].Days then
      BGColor := FDeadlineLevels[2].Color
    else if DaysLeft <= FDeadlineLevels[3].Days then
      BGColor := FDeadlineLevels[3].Color;
  end;

  if gdSelected in State then
    BGColor := clHighlight;

  StringGrid_Tasklist.Canvas.Brush.Color := BGColor;
  StringGrid_Tasklist.Canvas.FillRect(Rect);

  if ACol = 0 then
  begin
    StringGrid_Tasklist.Canvas.Pen.Color := clBlack;
    StringGrid_Tasklist.Canvas.Rectangle(
      Rect.Left + (Rect.Width - 12) div 2,
      Rect.Top + (Rect.Height - 12) div 2,
      Rect.Left + (Rect.Width - 12) div 2 + 12,
      Rect.Top + (Rect.Height - 12) div 2 + 12
    );
    Exit;
  end;

  if gdSelected in State then
    StringGrid_Tasklist.Canvas.Font.Color := clHighlightText
  else
    StringGrid_Tasklist.Canvas.Font.Color := clBlack;

  if ACol in [2..4] then
  begin
    if (ARow > 0) and (ARow <= Length(FRowIndexMap)) then
      Text := StringGrid_Tasklist.Cells[ACol, ARow]
    else
      Text := '';
    TextRect := Rect;
    DrawText(StringGrid_Tasklist.Canvas.Handle, PChar(Text), Length(Text),
      TextRect, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end
  else
    StringGrid_Tasklist.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2,
      StringGrid_Tasklist.Cells[ACol, ARow]);

  if (gdFocused in State) and (gdSelected in State) then
    StringGrid_Tasklist.Canvas.DrawFocusRect(Rect);
end;

{ ===================== 各種操作 ===================== }

procedure TForm_TaskList.StringGrid_TasklistMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row, TaskIndex: Integer;
begin
  StringGrid_Tasklist.MouseToCell(X, Y, Col, Row);

  if Row = 0 then
  begin
    if FSortCol = Col then FSortDescending := not FSortDescending
    else
    begin
      FSortCol := Col;
      FSortDescending := False;
    end;
    RefreshGrid;
    Exit;
  end;

  if (Col = 0) and (Row > 0) and (Row <= Length(FRowIndexMap)) then
  begin
    TaskIndex := FRowIndexMap[Row - 1];
    FTasks[TaskIndex].Completed := not FTasks[TaskIndex].Completed;
    RefreshGrid;
  end;
end;

procedure TForm_TaskList.SetTaskCompleted(Index: Integer; Completed: Boolean);
begin
  if (Index < 0) or (Index > High(FTasks)) then Exit;
  FTasks[Index].Completed := Completed;
  RefreshGrid;
end;

procedure TForm_TaskList.Button_AddClick(Sender: TObject);
var
  Dlg: TForm_ToggleTask;
  T: TTaskItem;
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

procedure TForm_TaskList.Button_EditClick(Sender: TObject);
var
  Row: Integer;
  Dlg: TForm_ToggleTask;
begin
  Row := StringGrid_Tasklist.Row;
  if (Row <= 0) or (Row > Length(FRowIndexMap)) then Exit;

  Dlg := TForm_ToggleTask.Create(Self);
  try
    Dlg.SetupForToggle(FTasks[FRowIndexMap[Row - 1]]);
    if Dlg.ShowModal = mrOk then
    begin
      FTasks[FRowIndexMap[Row - 1]] := Dlg.GetTask;
      RefreshGrid;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm_TaskList.Button_DeleteClick(Sender: TObject);
var
  Row, TaskIndex: Integer;
begin
  Row := StringGrid_Tasklist.Row;
  if (Row <= 0) or (Row > Length(FRowIndexMap)) then Exit;

  TaskIndex := FRowIndexMap[Row - 1];

  if MessageDlg('削除しますか？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FTasks := Copy(FTasks, 0, TaskIndex) +
              Copy(FTasks, TaskIndex + 1, Length(FTasks) - TaskIndex - 1);
    RefreshGrid;
  end;
end;

procedure TForm_TaskList.Button_ResetClick(Sender: TObject);
begin
  if Length(FTasks) = 0 then Exit;

  if (MessageDlg('すべてのタスクを削除しますか？', mtWarning, [mbYes, mbNo], 0) = mrYes) and
     (MessageDlg('本当によろしいですか？', mtWarning, [mbYes, mbNo], 0) = mrYes) then
  begin
    FTasks := [];
    RefreshGrid;
  end;
end;

procedure TForm_TaskList.Button_FilterResetClick(Sender: TObject);
begin
  Edit_Search.Text := '';
  ComboBox_Priority.ItemIndex := -1;
  ComboBox_Category.ItemIndex := -1;
  RefreshGrid;
end;

procedure TForm_TaskList.ComboBox_PriorityChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TForm_TaskList.ComboBox_CategoryChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TForm_TaskList.Edit_SearchChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TForm_TaskList.Button_CompletedClick(Sender: TObject);
var
  Dlg: TForm_CompletedTasklist;
begin
  Dlg := TForm_CompletedTasklist.Create(Self);
  try
    Dlg.ShowCompletedTasks(FTasks);
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

{ ===================== 保存 / 読込 ===================== }

procedure TForm_TaskList.SaveTasksToFile;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  T: TTaskItem;
  FileName: string;
begin
  if FSaving then Exit;
  FSaving := True;
  try
    Arr := TJSONArray.Create;
    try
      for T in FTasks do
      begin
        Obj := TJSONObject.Create;
        Obj.AddPair('text', T.Text);
        Obj.AddPair('priority', TJSONNumber.Create(T.Priority));
        Obj.AddPair('category', T.Category);
        Obj.AddPair('deadline', DateToStr(T.Deadline));
        Obj.AddPair('completed', TJSONBool.Create(T.Completed));
        Arr.AddElement(Obj);
      end;

      FileName := TPath.Combine(TPath.GetDocumentsPath, 'tasks.json');
      TFile.WriteAllText(FileName, Arr.Format);
      BackupTasksFile;
    finally
      Arr.Free;
    end;
  finally
    FSaving := False;
  end;
end;

procedure TForm_TaskList.LoadTasksFromFile;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  V: TJSONValue;
  T: TTaskItem;
  FileName, BackupFile: string;
begin
  FileName := TPath.Combine(TPath.GetDocumentsPath, 'tasks.json');
  if not TFile.Exists(FileName) then Exit;

  Arr := nil;
  try
    Arr := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName)) as TJSONArray;
    if Arr = nil then raise Exception.Create('JSON parse error');
  except
    BackupFile := GetLatestBackupFile;
    if BackupFile <> '' then
    begin
      TFile.Copy(BackupFile, FileName, True);
      Arr := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName)) as TJSONArray;
      if Arr = nil then Exit;
    end
    else
      Exit;
  end;

  try
    SetLength(FTasks, 0);
    for V in Arr do
    begin
      Obj := V as TJSONObject;
      T.Text := Obj.GetValue<string>('text');
      T.Priority := Obj.GetValue<Integer>('priority');
      T.Category := Obj.GetValue<string>('category');
      T.Deadline := StrToDate(Obj.GetValue<string>('deadline'));
      T.Completed := Obj.GetValue<Boolean>('completed');
      FTasks := FTasks + [T];
    end;
  finally
    Arr.Free;
  end;
end;

procedure TForm_TaskList.LoadSettings(Ini: TIniFile);
begin
  FDeadlineLevels[1].Days := Ini.ReadInteger('Deadline', 'Level1Days', 1);
  FDeadlineLevels[1].Color := ReadColor(Ini, 'Deadline', 'Level1Color', $00AAAAFF);
  FDeadlineLevels[2].Days := Ini.ReadInteger('Deadline', 'Level2Days', 3);
  FDeadlineLevels[2].Color := ReadColor(Ini, 'Deadline', 'Level2Color', $00AAFFAA);
  FDeadlineLevels[3].Days := Ini.ReadInteger('Deadline', 'Level3Days', 7);
  FDeadlineLevels[3].Color := ReadColor(Ini, 'Deadline', 'Level3Color', $00FFFFAA);
end;

procedure TForm_TaskList.BackupTasksFile;
var
  Dir, FileName: string;
begin
  Dir := TPath.Combine(TPath.GetDocumentsPath, 'TaskBackups');
  if not TDirectory.Exists(Dir) then
    TDirectory.CreateDirectory(Dir);

  FileName := TPath.Combine(Dir, Format('tasks_%s.json', [FormatDateTime('yyyymmdd_HHMMSS', Now)]));
  TFile.Copy(TPath.Combine(TPath.GetDocumentsPath, 'tasks.json'), FileName);
end;

end.

