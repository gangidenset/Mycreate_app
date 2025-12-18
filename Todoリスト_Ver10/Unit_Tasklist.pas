unit Unit_Tasklist;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  System.Generics.Collections, System.Generics.Defaults, System.TypInfo,
  System.DateUtils, System.JSON, System.IOUtils, System.IniFiles,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Unit_TaskTypes, Unit_CompletedTask, Vcl.Menus, Vcl.ExtCtrls;

type
  TDeadlineLevel = record
    Days: Integer;
    Color: TColor;
  end;

type
  TForm_TaskList = class(TForm)
    Label_Search: TLabel;
    Edit_Search: TEdit;
    Label_FilterTop: TLabel;
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
    ComboBox_Status: TComboBox;
    Label_Status: TLabel;
    Label_FilterBottom: TLabel;
    ComboBox_Tag: TComboBox;
    Label_Tag: TLabel;
    PopupMenu_Priority: TPopupMenu;
    MenuPriority1: TMenuItem;
    MenuPriority2: TMenuItem;
    MenuPriority3: TMenuItem;
    MenuPriority4: TMenuItem;
    MenuPriority5: TMenuItem;
    Timer_Notify: TTimer;
    Button_Undo: TButton;
    Button_Redo: TButton;
    Label_RedoUndo: TLabel;
    Label1: TLabel;
    Button_Export: TButton;
    Button_Import: TButton;
    OpenDialog1: TOpenDialog;
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
    procedure ComboBox_StatusChange(Sender: TObject);
    procedure ComboBox_TagChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer_NotifyTimer(Sender: TObject);
    procedure Button_UndoClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button_RedoClick(Sender: TObject);
    procedure Button_ExportClick(Sender: TObject);
    procedure Button_ImportClick(Sender: TObject);
  private
    FTasks: TArray<TTaskItem>;
    FRowIndexMap: array of Integer;
    FSortCol: Integer;
    FSortDescending: Boolean;
    FIni: TIniFile;
    FSaving: Boolean;
    FUndoStack: TStack<TArray<TTaskItem>>;
    FRedoStack: TStack<TArray<TTaskItem>>;
    SelectedTag: string;
    procedure InitGrid;
    procedure SortTasks;
    procedure SaveTasksToFile;
    procedure LoadTasksFromFile;
    procedure LoadSettings(Ini: TIniFile);
    procedure BackupTasksFile;
    procedure UpdateTagComboBox;
    procedure MenuPriorityClick(Sender: TObject);
    procedure PushUndo;
    procedure Undo;
    procedure UpdateUndoRedoState;
    procedure Redo;
    procedure ExportToCSV(const FileName: string);
    procedure ImportFromCSV(const FileName: string);
  public
    procedure RefreshGrid;
    procedure PrepareGrid;
    procedure BuildVisibleTaskRows;
    function IsTaskVisible(const Task: TTaskItem): Boolean;
    procedure SetTaskCompleted(Index: Integer; Completed: Boolean);
  end;

var
  Form_TaskList: TForm_TaskList;
  FDeadlineLevels: array[1..3] of TDeadlineLevel;

//バックアップの個数
const
  MAX_BACKUP_COUNT = 10;

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

function JoinTags(Tags: TArray<string>): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(Tags) do
  begin
    if i > 0 then
      Result := Result + ', ';  // カンマで区切る
    Result := Result + Tags[i];
  end;
end;

function TForm_TaskList.IsTaskVisible(const Task: TTaskItem): Boolean;
var
  j: Integer;
begin
  Result := True;

  // 検索
  if (Edit_Search.Text <> '') and
     (Pos(Edit_Search.Text, Task.Text) = 0) then
    Exit(False);

  // 優先度
  if ComboBox_Priority.ItemIndex > 0 then
    if IntToStr(Task.Priority) <>
       ComboBox_Priority.Items[ComboBox_Priority.ItemIndex] then
      Exit(False);

  // カテゴリ
  if (ComboBox_Category.Text <> '') and
     (Task.Category <> ComboBox_Category.Text) then
    Exit(False);

  // ステータス
  if ComboBox_Status.ItemIndex > 0 then
    case ComboBox_Status.ItemIndex of
      1: if Task.Status <> tsNotStarted then Exit(False);
      2: if Task.Status <> tsInProgress then Exit(False);
      3: if Task.Status <> tsOnHold then Exit(False);
    end;

  // タグ
  if ComboBox_Tag.Text <> '' then
  begin
    Result := False;
    for j := 0 to High(Task.Tags) do
      if Task.Tags[j] = ComboBox_Tag.Text then
        Exit(True);
  end;
end;


{ ===================== 初期化 / 終了 ===================== }

procedure TForm_TaskList.FormCreate(Sender: TObject);
var
  IniFileName: string;
begin
  InitGrid;
  FSortCol := 4;
  FSortDescending := False;
  FUndoStack := TStack<TArray<TTaskItem>>.Create;
  FRedoStack := TStack<TArray<TTaskItem>>.Create;
  IniFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'setting.ini');
  FIni := TIniFile.Create(IniFileName);
  LoadSettings(FIni);

  LoadTasksFromFile;
  RefreshGrid;
  UpdateTagComboBox;

  MenuPriority1.OnClick := MenuPriorityClick;
  MenuPriority2.OnClick := MenuPriorityClick;
  MenuPriority3.OnClick := MenuPriorityClick;
  MenuPriority4.OnClick := MenuPriorityClick;
  MenuPriority5.OnClick := MenuPriorityClick;

  UpdateUndoRedoState;
end;

procedure TForm_TaskList.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) then
  begin
    case Key of
      Ord('Z'): Undo;
      Ord('Y'): Redo;
    end;
  end;
end;

procedure TForm_TaskList.FormResize(Sender: TObject);
begin
  StringGrid_Tasklist.ColWidths[0] := Trunc(StringGrid_Tasklist.Width * 0.10);
  StringGrid_Tasklist.ColWidths[1] := Trunc(StringGrid_Tasklist.Width * 0.335);
  StringGrid_Tasklist.ColWidths[2] := Trunc(StringGrid_Tasklist.Width * 0.10);
  StringGrid_Tasklist.ColWidths[3] := Trunc(StringGrid_Tasklist.Width * 0.10);
  StringGrid_Tasklist.ColWidths[4] := Trunc(StringGrid_Tasklist.Width * 0.15);
  StringGrid_Tasklist.ColWidths[5] := Trunc(StringGrid_Tasklist.Width * 0.10);
  StringGrid_Tasklist.ColWidths[6] := Trunc(StringGrid_Tasklist.Width * 0.10);
end;

procedure TForm_TaskList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveTasksToFile;
  FIni.Free;
  FUndoStack.Free;
  FRedoStack.Free;
end;

procedure TForm_TaskList.InitGrid;
begin
  // 列の数や初期設定
  StringGrid_Tasklist.ColCount := 7;
  StringGrid_Tasklist.FixedRows := 1;
  StringGrid_Tasklist.RowCount := 1;

  // ヘッダー行の設定
  StringGrid_Tasklist.Cells[0, 0] := '完了';
  StringGrid_Tasklist.Cells[1, 0] := 'タスク';
  StringGrid_Tasklist.Cells[2, 0] := '優先度';
  StringGrid_Tasklist.Cells[3, 0] := 'カテゴリ';
  StringGrid_Tasklist.Cells[4, 0] := '期限';
  StringGrid_Tasklist.Cells[5, 0] := '進行状況';
  StringGrid_Tasklist.Cells[6, 0] := 'タグ';
end;

procedure TForm_TaskList.PushUndo;
begin
  FUndoStack.Push(Copy(FTasks));
  FRedoStack.Clear;
  UpdateUndoRedoState;
end;

procedure TForm_TaskList.Undo;
begin
  if FUndoStack.Count = 0 then Exit;

  FRedoStack.Push(Copy(FTasks));
  FTasks := FUndoStack.Pop;

  RefreshGrid;
  UpdateUndoRedoState;
end;

procedure TForm_TaskList.Redo;
begin
  if FRedoStack.Count = 0 then Exit;

  FUndoStack.Push(Copy(FTasks));
  FTasks := FRedoStack.Pop;

  RefreshGrid;
  UpdateUndoRedoState;
end;

procedure TForm_TaskList.UpdateUndoRedoState;
begin
  Button_Undo.Enabled := FUndoStack.Count > 0;
  Button_Redo.Enabled := FRedoStack.Count > 0;
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
        1: // Text（タスク名）で比較
          begin
            Result := CompareStr(A.Text, B.Text);
            if Result = 0 then
              Result := CompareDateTime(A.Deadline, B.Deadline);
          end;
        2: // Priorityで比較
          begin
            Result := A.Priority - B.Priority;
            if Result = 0 then
              Result := CompareStr(A.Text, B.Text);
          end;
        3: // Categoryで比較
          begin
            Result := CompareStr(A.Category, B.Category);
            if Result = 0 then
              Result := CompareDateTime(A.Deadline, B.Deadline);
          end;
        4: // Deadlineで比較
          begin
            Result := CompareDateTime(A.Deadline, B.Deadline);
            if Result = 0 then
              Result := CompareStr(A.Text, B.Text);
          end;
        5: // Statusで比較（列挙型の文字列比較）
          begin
            Result := CompareStr(GetEnumName(TypeInfo(TTaskStatus), Ord(A.Status)),
                                  GetEnumName(TypeInfo(TTaskStatus), Ord(B.Status)));
            if Result = 0 then
              Result := CompareStr(A.Text, B.Text); // 同じStatusならTextで並べ替え
          end;
      else
        Result := 0;
      end;

      // 降順ソートを反映
      if FSortDescending then
        Result := -Result;
    end
  );

  // タスクのソート
  TArray.Sort<TTaskItem>(FTasks, Comparer);
end;


{ ===================== 表示更新 ===================== }

procedure TForm_TaskList.RefreshGrid;
begin
  SortTasks;
  PrepareGrid;
  BuildVisibleTaskRows;
  UpdateUndoRedoState;
end;

procedure TForm_TaskList.PrepareGrid;
begin
  StringGrid_Tasklist.RowCount := 1;
  SetLength(FRowIndexMap, 0);
end;

procedure TForm_TaskList.BuildVisibleTaskRows;
var
  i, j, Row: Integer;
  ShowTask: Boolean;
  TagsText: string;
begin
  Row := 1;

  for i := 0 to High(FTasks) do
  begin
    if FTasks[i].Completed then
      Continue;

    ShowTask := IsTaskVisible(FTasks[i]);

    if not ShowTask then
      Continue;

    StringGrid_Tasklist.RowCount := Row + 1;
    StringGrid_Tasklist.Cells[1, Row] := FTasks[i].Text;
    StringGrid_Tasklist.Cells[2, Row] := IntToStr(FTasks[i].Priority);
    StringGrid_Tasklist.Cells[3, Row] := FTasks[i].Category;
    StringGrid_Tasklist.Cells[4, Row] := DateToStr(FTasks[i].Deadline);

    case FTasks[i].Status of
      tsNotStarted: StringGrid_Tasklist.Cells[5, Row] := '未着手';
      tsInProgress: StringGrid_Tasklist.Cells[5, Row] := '進行中';
      tsOnHold:     StringGrid_Tasklist.Cells[5, Row] := '保留';
    end;

    TagsText := JoinTags(FTasks[i].Tags);
    StringGrid_Tasklist.Cells[6, Row] := TagsText;

    SetLength(FRowIndexMap, Row);
    FRowIndexMap[Row - 1] := i;

    Inc(Row);
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
  TextWidth: Integer;
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

  if ACol = 1 then // タスク名の列
  begin
    Text := StringGrid_Tasklist.Cells[ACol, ARow];
    TextWidth := StringGrid_Tasklist.Canvas.TextWidth(Text);  // テキストの幅を計算

    // もしテキストの幅が現在の列幅よりも大きければ、列幅を更新
    if TextWidth > StringGrid_Tasklist.ColWidths[1] then
    begin
      StringGrid_Tasklist.ColWidths[1] := TextWidth + 10;  // 余白を加える
    end;
  end
  else if ACol = 6 then // タグの列
  begin
    Text := StringGrid_Tasklist.Cells[ACol, ARow];
    TextWidth := StringGrid_Tasklist.Canvas.TextWidth(Text);  // テキストの幅を計算

    // もしテキストの幅が現在の列幅よりも大きければ、列幅を更新
    if TextWidth > StringGrid_Tasklist.ColWidths[6] then
    begin
      StringGrid_Tasklist.ColWidths[6] := TextWidth + 10;  // 余白を加える
    end;
  end;

  // セルの描画（通常通り）
  if ACol in [2..5] then
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
    PushUndo;
    FTasks[TaskIndex].Completed := not FTasks[TaskIndex].Completed;
    RefreshGrid;
  end;

  if (Button = mbRight) and (Row > 0) and (Row <= Length(FRowIndexMap)) then
  begin
    TaskIndex := FRowIndexMap[Row - 1];
    PopupMenu_Priority.Tag := TaskIndex; // 後でどのタスクか分かるように Tag に格納
    PopupMenu_Priority.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  end;
end;

procedure TForm_TaskList.Timer_NotifyTimer(Sender: TObject);
var
  i: Integer;
  DaysLeft: Integer;
  Msg: string;
begin
  for i := 0 to High(FTasks) do
  begin
    if FTasks[i].Completed then
      Continue;

    DaysLeft := DaysBetween(FTasks[i].Deadline, Date);

    case DaysLeft of
      1:  // 期限1日前
        begin
          Msg := Format('タスク "%s" は明日が期限です', [FTasks[i].Text]);
          ShowMessage(Msg);
        end;
      0:  // 期限当日
        begin
          Msg := Format('タスク "%s" は今日が期限です', [FTasks[i].Text]);
          ShowMessage(Msg);
        end;
    else
      if DaysLeft < 0 then  // 過ぎたタスク
      begin
        Msg := Format('タスク "%s" の期限が過ぎています', [FTasks[i].Text]);
        ShowMessage(Msg);
      end;
    end;
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
      PushUndo;
      T := Dlg.GetTask;
      FTasks := FTasks + [T];
      RefreshGrid;
      UpdateTagComboBox;
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
      PushUndo;
      FTasks[FRowIndexMap[Row - 1]] := Dlg.GetTask;
      RefreshGrid;
      UpdateTagComboBox;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm_TaskList.Button_ExportClick(Sender: TObject);
begin
  if Length(FRowIndexMap) = 0 then
  begin
    ShowMessage('エクスポートするタスクがありません');
    Exit;
  end;

  with TSaveDialog.Create(Self) do
  try
    Filter := 'CSV files (*.csv)|*.csv';
    DefaultExt := 'csv';
    if Execute then
      ExportToCSV(FileName);
  finally
    Free;
  end;
end;

procedure TForm_TaskList.Button_DeleteClick(Sender: TObject);
var
  i, j, TaskIndex, Row: Integer;
  RowsToDelete: TList<Integer>;
begin
  RowsToDelete := TList<Integer>.Create;
  try
    // 選択行を収集
    for Row := StringGrid_Tasklist.Selection.Top
           to StringGrid_Tasklist.Selection.Bottom do
    begin
      if (Row > 0) and (Row <= Length(FRowIndexMap)) then
        RowsToDelete.Add(Row - 1); // 表示行 → RowIndexMap
    end;

    if RowsToDelete.Count = 0 then Exit;

    if MessageDlg('選択したタスクを削除しますか？',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
    PushUndo;

    // 後ろから削除
    RowsToDelete.Sort;
    for i := RowsToDelete.Count - 1 downto 0 do
    begin
      TaskIndex := FRowIndexMap[RowsToDelete[i]];

      for j := TaskIndex to High(FTasks) - 1 do
        FTasks[j] := FTasks[j + 1];

      SetLength(FTasks, Length(FTasks) - 1);
    end;

    RefreshGrid;
  finally
    RowsToDelete.Free;
  end;
end;

procedure TForm_TaskList.Button_RedoClick(Sender: TObject);
begin
  Redo;
end;

procedure TForm_TaskList.Button_ResetClick(Sender: TObject);
begin
  if Length(FTasks) = 0 then Exit;

  if (MessageDlg('すべてのタスクを削除しますか？', mtWarning, [mbYes, mbNo], 0) = mrYes) and
     (MessageDlg('本当によろしいですか？', mtWarning, [mbYes, mbNo], 0) = mrYes) then
  begin
    PushUndo;
    FTasks := [];
    RefreshGrid;
  end;
end;

procedure TForm_TaskList.Button_UndoClick(Sender: TObject);
begin
  Undo;
end;

procedure TForm_TaskList.Button_FilterResetClick(Sender: TObject);
begin
  Edit_Search.Text := '';
  ComboBox_Priority.ItemIndex := -1;
  ComboBox_Category.ItemIndex := -1;
  ComboBox_Status.ItemIndex := -1;
  ComboBox_Tag.ItemIndex := -1;
  RefreshGrid;
end;

procedure TForm_TaskList.Button_ImportClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;

  if MessageDlg('現在のタスクをすべて置き換えますか？',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  ImportFromCSV(OpenDialog1.FileName);
end;

procedure TForm_TaskList.ComboBox_PriorityChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TForm_TaskList.ComboBox_StatusChange(Sender: TObject);
begin
  RefreshGrid;
end;

procedure TForm_TaskList.ComboBox_TagChange(Sender: TObject);
begin
  SelectedTag := ComboBox_Tag.Text;
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
  TagArr: TJSONArray;
  Tag: string;
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
        Obj.AddPair('status', TJSONNumber.Create(Integer(T.Status)));

        // タグの保存
        TagArr := TJSONArray.Create;
        for Tag in T.Tags do
          TagArr.Add(Tag);  // 各タグを JSON 配列に追加
        Obj.AddPair('tags', TagArr);

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
  TagArr: TJSONArray;
  Tag: string;
  FileName, BackupFile: string;
  Text: string;
begin
  FileName := TPath.Combine(TPath.GetDocumentsPath, 'tasks.json');
  if not TFile.Exists(FileName) then
  begin
    ShowMessage('File does not exist: ' + FileName);
    Exit;
  end;

  try
    // ファイルをUTF-8エンコーディングで読み込む
    Text := TFile.ReadAllText(FileName, TEncoding.UTF8);

    // JSONをパースする
    Arr := TJSONObject.ParseJSONValue(Text) as TJSONArray;
    if Arr = nil then
      raise Exception.CreateFmt('JSON parse error in file: %s', [FileName]);

    SetLength(FTasks, 0);

    // JSON配列からタスクデータを取り出す
    for V in Arr do
    begin
      Obj := V as TJSONObject;
      T.Text := Obj.GetValue<string>('text');
      T.Priority := Obj.GetValue<Integer>('priority');
      T.Category := Obj.GetValue<string>('category');
      T.Deadline := StrToDate(Obj.GetValue<string>('deadline'));
      T.Completed := Obj.GetValue<Boolean>('completed');
      T.Status := TTaskStatus(Obj.GetValue<Integer>('status'));

      // タグの読み込み
      TagArr := Obj.GetValue<TJSONArray>('tags');
      SetLength(T.Tags, TagArr.Count);
      for var i := 0 to TagArr.Count - 1 do
        T.Tags[i] := TagArr.Items[i].Value;  // JSON配列のタグを読み込み

      FTasks := FTasks + [T];
    end;

  except
    on E: Exception do
    begin
      ShowMessage('Error loading JSON file: ' + E.Message);
    end;
  end;
end;

procedure TForm_TaskList.MenuPriorityClick(Sender: TObject);
var
  SelectedRow: Integer;
  PriorityValue: Integer;
begin
  // 右クリックで選択された行を取得
  SelectedRow := StringGrid_Tasklist.Row;
  if (SelectedRow <= 0) or (SelectedRow > Length(FRowIndexMap)) then Exit;

  // メニュー項目ごとの優先度を取得
  if Sender = MenuPriority1 then PriorityValue := 1
  else if Sender = MenuPriority2 then PriorityValue := 2
  else if Sender = MenuPriority3 then PriorityValue := 3
  else if Sender = MenuPriority4 then PriorityValue := 4
  else if Sender = MenuPriority5 then PriorityValue := 5
  else Exit;

  PushUndo;
  // タスクデータを更新
  FTasks[FRowIndexMap[SelectedRow - 1]].Priority := PriorityValue;
  RefreshGrid;
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
procedure TForm_TaskList.UpdateTagComboBox;
var
  i, j: Integer;
  TaskTags: TArray<string>;
begin
  // ComboBox_Tagのアイテムを一度クリア
  ComboBox_Tag.Items.Clear;

  // 「すべて」を最初に追加して、最初に選択できるようにする
  ComboBox_Tag.Items.Add('');

  // すべてのタスクのタグを調べて、重複しないタグを追加
  for i := 0 to High(FTasks) do
  begin
    TaskTags := FTasks[i].Tags;
    for j := 0 to High(TaskTags) do
    begin
      // すでにタグがComboBoxに存在しない場合のみ追加
      if ComboBox_Tag.Items.IndexOf(TaskTags[j]) = -1 then
        ComboBox_Tag.Items.Add(TaskTags[j]);
    end;
  end;

  // ComboBoxの最初の状態は「すべて」を選択した状態に
  ComboBox_Tag.ItemIndex := 0;  // 「すべて」を選択状態に設定
end;

procedure TForm_TaskList.ExportToCSV(const FileName: string);
var
  SL: TStringList;
  i, j: Integer;
  Line, Tags: string;
begin
  SL := TStringList.Create;
  try
    // ヘッダー
    SL.Add('完了,タスク,優先度,カテゴリ,期限,進行状況,タグ');

    for i := 0 to High(FRowIndexMap) do
    begin
      j := FRowIndexMap[i];

      Tags := '';
      if Length(FTasks[j].Tags) > 0 then
        Tags := StringReplace(JoinTags(FTasks[j].Tags), ', ', '|', [rfReplaceAll]);

      Line :=
        Format('%s,"%s",%d,"%s",%s,"%s","%s"', [
          BoolToStr(FTasks[j].Completed, True),
          StringReplace(FTasks[j].Text, '"', '""', [rfReplaceAll]),
          FTasks[j].Priority,
          FTasks[j].Category,
          DateToStr(FTasks[j].Deadline),
          StringGrid_Tasklist.Cells[5, i + 1],
          Tags
        ]);

      SL.Add(Line);
    end;

    SL.SaveToFile(FileName, TEncoding.UTF8); // ← ここ重要
  finally
    SL.Free;
  end;
end;

procedure TForm_TaskList.ImportFromCSV(const FileName: string);
var
  SL: TStringList;
  i: Integer;
  Fields: TArray<string>;
  T: TTaskItem;
  D: TDateTime;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FileName, TEncoding.UTF8);

    PushUndo;
    FTasks := [];

    for i := 1 to SL.Count - 1 do // ヘッダー飛ばす
    begin
      Fields := SL[i].Split([',']);

      if Length(Fields) < 6 then Continue;

      T.Completed := SameText(Fields[0], 'True');
      T.Text      := Fields[1].Trim(['"']);
      T.Priority  := StrToIntDef(Fields[2], 1);
      T.Category  := Fields[3].Trim(['"']);
      if TryStrToDateTime(Fields[4], D) then
        T.Deadline := D
      else
        T.Deadline := 0; // 未設定扱い

      // Tags
      T.Tags := [];
      if Length(Fields) > 6 then
        T.Tags := Fields[6].Trim(['"']).Split(['|']);

      FTasks := FTasks + [T];
    end;

    RefreshGrid;
    UpdateTagComboBox;
  finally
    SL.Free;
  end;
end;


end.

