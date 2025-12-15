unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Grids, System.JSON, System.IOUtils, System.IniFiles, System.StrUtils,
  Vcl.CheckLst, System.Generics.Collections, System.Generics.Defaults, Unit2, Unit3;

type
  TCheckItem = record
    ID: Integer;
    Text: string;
    Checked: Boolean;
    Priority: Integer;
    Category: string;
    Deadline: TDateTime;
  end;

  TForm1 = class(TForm)
    Button_add: TButton;
    Button_delete: TButton;
    Button_reset: TButton;
    Button_path: TButton;
    Label_checklist: TLabel;
    Memo_Completed: TMemo;
    Label2: TLabel;
    StringGrid1: TStringGrid;
    Button_Edit: TButton;
    Edit_search: TEdit;
    Label_Search: TLabel;
    Label1: TLabel;
    ComboBox_FilterPriority: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox_FilterCategory: TComboBox;
    Button_Complited: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_addClick(Sender: TObject);
    procedure Button_deleteClick(Sender: TObject);
    procedure Edit_searchChange(Sender: TObject);
    procedure Button_resetClick(Sender: TObject);
    procedure Button_pathClick(Sender: TObject);
    procedure Memo_CompletedDblClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Button_EditClick(Sender: TObject);
    procedure ComboBox_FilterPriorityChange(Sender: TObject);
    procedure ComboBox_FilterCategoryChange(Sender: TObject);
    procedure Button_ComplitedClick(Sender: TObject);
  private
    LastSelectedIndex: Integer;
    FItems: TArray<TCheckItem>;
    FSortAscending: Boolean;
    procedure RefreshList;
    procedure SaveData;
    procedure LoadData;
    procedure LoadDeadlineConfig;
    procedure AdjustTaskColumnWidth(Grid: TStringGrid);
    procedure SortByPriority;
    procedure SortByCategory;
    procedure SortByDeadline;
  public
    procedure RefreshView;
  end;

var
  Form1: TForm1;
  YellowDays, RedDays: Integer;

// 薄い赤と薄い黄色の定義
const
  LightRed    = $00C0C0FF;  // BGR 形式
  LightYellow = $00E0FFFF;

implementation

procedure AdjustColumnWidths(Grid: TStringGrid);
begin
  Grid.ColWidths[0] := 40;   // チェックボックス列
  Grid.ColWidths[1] := 325;  // タスク名
  Grid.ColWidths[2] := 60;   // 優先度
  Grid.ColWidths[3] := 90;  // カテゴリ
  Grid.ColWidths[4] := 90;  // 期限
end;


procedure TForm1.AdjustTaskColumnWidth(Grid: TStringGrid);
var
  Row: Integer;
  MaxWidth, W: Integer;
begin
  // タスク列は 1 列目（Cells[1, *]）と仮定
  MaxWidth := Grid.Canvas.TextWidth(Grid.Cells[1, 0]); // ヘッダ行の幅

  for Row := 1 to Grid.RowCount - 1 do
  begin
    W := Grid.Canvas.TextWidth(Grid.Cells[1, Row]);
    if W > MaxWidth then
      MaxWidth := W;
  end;

  Grid.ColWidths[1] := MaxWidth + 20; // 少し余白を足す
end;


{$R *.dfm}

function GetProjectRootPath: string;
begin
  Result := ExtractFileDir(ParamStr(0));
end;

function GetIniFullPath: string;
begin
  Result := TPath.Combine(GetProjectRootPath, 'CheckList.json');
end;

function PrettyJSON(const S: string): string;
var
  i, indent: Integer;
  c: Char;
  inString: Boolean;
  Line: string;
  SL: TStringList;

  function CountPrecedingBackslashes(pos: Integer): Integer;
  var k, cnt: Integer;
  begin
    cnt := 0;
    k := pos - 1;
    while (k >= 1) and (S[k] = '\') do
    begin
      Inc(cnt);
      Dec(k);
    end;
    Result := cnt;
  end;

  procedure FlushLine;
  begin
    if Trim(Line) <> '' then
      SL.Add(Line);
    Line := '';
  end;

begin
  SL := TStringList.Create;
  try
    indent := 0;
    inString := False;
    Line := '';

    for i := 1 to Length(S) do
    begin
      c := S[i];
      case c of
        '"':
          begin
            Line := Line + c;
            if (CountPrecedingBackslashes(i) mod 2) = 0 then
              inString := not inString;
          end;
        '{', '[':
          begin
            Line := Line + c;
            if not inString then
            begin
              FlushLine;
              Inc(indent);
              Line := StringOfChar(' ', indent * 2);
            end;
          end;
        '}', ']':
          begin
            if not inString then
            begin
              FlushLine;
              Dec(indent);
              Line := StringOfChar(' ', indent * 2) + c;
            end
            else
              Line := Line + c;
          end;
        ',':
          begin
            Line := Line + c;
            if not inString then
            begin
              FlushLine;
              Line := StringOfChar(' ', indent * 2);
            end;
          end
        else
          Line := Line + c;
      end;
    end;

    FlushLine;
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure TForm1.RefreshList;
var
  i: Integer;
begin
  StringGrid1.RowCount := Length(FItems) + 1;

  for i := 0 to High(FItems) do
  begin
    StringGrid1.Cells[0, i + 1] := '';
    StringGrid1.Cells[1, i + 1] := FItems[i].Text;
    StringGrid1.Cells[2, i + 1] := IntToStr(FItems[i].Priority);
    StringGrid1.Cells[3, i + 1] := FItems[i].Category;
    StringGrid1.Cells[4, i + 1] := DateToStr(FItems[i].Deadline);
  end;

  AdjustColumnWidths(StringGrid1);
  StringGrid1.Invalidate;
end;

procedure TForm1.Button_resetClick(Sender: TObject);
var
  J: TJSONObject;
begin
  if MessageDlg('本当に初期化しますか？', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  J := TJSONObject.Create;
  try
    J.AddPair('items', TJSONArray.Create);
    J.AddPair('completed', TJSONArray.Create);
    TFile.WriteAllText(GetIniFullPath, PrettyJSON(J.ToString), TEncoding.UTF8);
    ShowMessage('JSON 初期化完了！');
  finally
    J.Free;
  end;

  SetLength(FItems, 0);
  Memo_Completed.Clear;
  RefreshList;
end;

procedure TForm1.ComboBox_FilterCategoryChange(Sender: TObject);
begin
    RefreshView;
end;

procedure TForm1.ComboBox_FilterPriorityChange(Sender: TObject);
begin
    RefreshView;
end;

procedure TForm1.Button_pathClick(Sender: TObject);
begin
  ShowMessage('保存パス: ' + GetIniFullPath);
end;

procedure TForm1.Button_addClick(Sender: TObject);
var
  dlg: TForm_TaskEdit;
  newItem: TCheckItem;
begin
  dlg := TForm_TaskEdit.Create(Self);
  dlg.Label_EditToggle.Caption := '新規タスク追加';
  try
    if dlg.ShowModal = mrOk then
    begin
      newItem.Text := dlg.Edit_Task.Text;
      newItem.Category := dlg.ComboBox_Category.Text;
      newItem.Priority := dlg.ComboBox_Priority.ItemIndex + 1;
      newItem.Deadline := dlg.dtp_Deadline.Date;
      newItem.Checked := False;

      FItems := FItems + [newItem];
      RefreshList;
    end;
  finally
    dlg.Free;
  end;
end;


procedure TForm1.Button_ComplitedClick(Sender: TObject);
var
  dlg: TForm3;
begin
  // Unit3のフォームを作成
  dlg := TForm3.Create(Self);
  try
    // 完了タスクフォームを表示
    dlg.ShowModal;
  finally
    dlg.Free;
  end;
end;



procedure TForm1.Button_deleteClick(Sender: TObject);
var
  i: Integer;
begin
  if LastSelectedIndex < 0 then Exit;
  for i := LastSelectedIndex to High(FItems) - 1 do
    FItems[i] := FItems[i + 1];
  SetLength(FItems, Length(FItems) - 1);
  LastSelectedIndex := -1;
  RefreshList;
end;

procedure TForm1.Button_EditClick(Sender: TObject);
var
  dlg: TForm_TaskEdit;
  idx: Integer;
begin
  idx := LastSelectedIndex;
  if (idx < 0) or (idx > High(FItems)) then Exit;

  dlg := TForm_TaskEdit.Create(Self);
  try
    // 初期値を設定
    dlg.Label_EditToggle.Caption := '編集';
    dlg.Edit_Task.Text := FItems[idx].Text;
    dlg.ComboBox_Category.Text := FItems[idx].Category;
    dlg.ComboBox_Priority.ItemIndex := FItems[idx].Priority - 1;
    dlg.dtp_Deadline.Date := FItems[idx].Deadline;

    if dlg.ShowModal = mrOk then
    begin
      FItems[idx].Text := dlg.Edit_Task.Text;
      FItems[idx].Category := dlg.ComboBox_Category.Text;
      FItems[idx].Priority := dlg.ComboBox_Priority.ItemIndex + 1;
      FItems[idx].Deadline := dlg.dtp_Deadline.Date;
      RefreshList;
    end;
  finally
    dlg.Free;
  end;
end;

procedure TForm1.SaveData;
var
  Obj, It: TJSONObject;
  ArrItems, ArrCompleted: TJSONArray;
  i: Integer;
begin
  Obj := TJSONObject.Create;
  try
    ArrItems := TJSONArray.Create;
    ArrCompleted := TJSONArray.Create;

    for i := 0 to High(FItems) do
    begin
      It := TJSONObject.Create;
      It.AddPair('ID', TJSONNumber.Create(FItems[i].ID));
      It.AddPair('Text', FItems[i].Text);
      It.AddPair('Checked', TJSONBool.Create(FItems[i].Checked));
      It.AddPair('Priority', TJSONNumber.Create(FItems[i].Priority));
      It.AddPair('Category', FItems[i].Category);
      It.AddPair('Deadline', DateToStr(FItems[i].Deadline));
      ArrItems.AddElement(It);
    end;

    for i := 0 to Memo_Completed.Lines.Count - 1 do
    begin
      It := TJSONObject.Create;
      It.AddPair('Text', Memo_Completed.Lines[i]);
      ArrCompleted.AddElement(It);
    end;

    Obj.AddPair('items', ArrItems);
    Obj.AddPair('completed', ArrCompleted);

    TFile.WriteAllText(GetIniFullPath, PrettyJSON(Obj.ToString), TEncoding.UTF8);
  finally
    Obj.Free;
  end;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  DaysLeft: Integer;
  Task: TCheckItem;
begin
  if ARow = 0 then Exit;

  Task := FItems[ARow - 1];
  DaysLeft := Trunc(Task.Deadline - Date);

  // --- ① まず背景色（期限による色分け）を決める ---
  if DaysLeft <= RedDays then
    StringGrid1.Canvas.Brush.Color := LightRed
  else if DaysLeft <= YellowDays then
    StringGrid1.Canvas.Brush.Color := LightYellow
  else
    StringGrid1.Canvas.Brush.Color := clWindow;

  // --- ② 行が選択されているなら背景を上書き ---
  if gdSelected in State then
  begin
    StringGrid1.Canvas.Brush.Color := $00FFE4B5;
  end;

  StringGrid1.Canvas.FillRect(Rect);

  // --- ③ チェックボックス or テキスト描画 ---
  if ACol = 0 then
    DrawFrameControl(StringGrid1.Canvas.Handle, Rect, DFC_BUTTON,
      DFCS_BUTTONCHECK or (Integer(Task.Checked) * DFCS_CHECKED))
  else
    StringGrid1.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2,
      StringGrid1.Cells[ACol, ARow]);
end;


procedure TForm1.SortByPriority;
begin
  TArray.Sort<TCheckItem>(FItems,
    TComparer<TCheckItem>.Construct(
      function(const L, R: TCheckItem): Integer
      begin
        if FSortAscending then
          Result := L.Priority - R.Priority  // 昇順
        else
          Result := R.Priority - L.Priority; // 降順
      end));
  RefreshList;
end;


procedure TForm1.SortByCategory;
begin
  TArray.Sort<TCheckItem>(FItems,
    TComparer<TCheckItem>.Construct(
      function(const L, R: TCheckItem): Integer
      begin
        if FSortAscending then
          Result := CompareText(L.Category, R.Category)
        else
          Result := CompareText(R.Category, L.Category);
      end));
  RefreshList;
end;

procedure TForm1.SortByDeadline;
begin
  TArray.Sort<TCheckItem>(FItems,
    TComparer<TCheckItem>.Construct(
      function(const L, R: TCheckItem): Integer
      begin
        if FSortAscending then
        begin
          if L.Deadline < R.Deadline then Result := -1
          else if L.Deadline > R.Deadline then Result := 1
          else Result := 0;
        end
        else
        begin
          if L.Deadline > R.Deadline then Result := -1
          else if L.Deadline < R.Deadline then Result := 1
          else Result := 0;
        end;
      end));
  RefreshList;
end;

procedure TForm1.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
  dlg: TForm3;
begin
  StringGrid1.MouseToCell(X, Y, ACol, ARow);

  // チェック列クリック → 完了処理
  if (ACol = 0) and (ARow > 0) and (ARow < StringGrid1.RowCount) then
  begin
    FItems[ARow - 1].Checked := not FItems[ARow - 1].Checked;

    if FItems[ARow - 1].Checked then
    begin
      // 完了タスクをUnit3のStringGrid_Completedに追加
      dlg := TForm3.Create(Self);
      try
        // Unit3を表示（すでに表示中かもしれませんが、その場合は再表示）
        dlg.Show;

        // StringGrid_Completedに完了タスクを追加
        dlg.StringGrid_Completed.RowCount := dlg.StringGrid_Completed.RowCount + 1;
        dlg.StringGrid_Completed.Cells[0, dlg.StringGrid_Completed.RowCount - 1] := '';  // チェックボックス列（表示しない場合もあります）
        dlg.StringGrid_Completed.Cells[1, dlg.StringGrid_Completed.RowCount - 1] := FItems[ARow - 1].Text;
        dlg.StringGrid_Completed.Cells[2, dlg.StringGrid_Completed.RowCount - 1] := IntToStr(FItems[ARow - 1].Priority);
        dlg.StringGrid_Completed.Cells[3, dlg.StringGrid_Completed.RowCount - 1] := FItems[ARow - 1].Category;
        dlg.StringGrid_Completed.Cells[4, dlg.StringGrid_Completed.RowCount - 1] := DateToStr(FItems[ARow - 1].Deadline);

        // 完了タスクをFItemsから削除
        Delete(FItems, ARow - 1, 1);
      finally
        dlg.Free;
      end;
    end;

    // リストを再描画
    RefreshList;
  end;
end;




procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  item: TCheckItem;
begin
  if ARow <= 0 then Exit;

  item := FItems[ARow - 1];

  LastSelectedIndex := ARow - 1;
end;

procedure TForm1.LoadData;
var
  Obj, It: TJSONObject;
  ArrItems, ArrCompleted: TJSONArray;
  Json: string;
  i, idx: Integer;
  tmpDate: TDateTime;
begin
  if not TFile.Exists(GetIniFullPath) then Exit;

  Json := TFile.ReadAllText(GetIniFullPath, TEncoding.UTF8);
  Obj := TJSONObject.ParseJSONValue(Json) as TJSONObject;
  if Obj = nil then Exit;

  try
    if Obj.TryGetValue('items', ArrItems) then
    begin
      SetLength(FItems, 0);
      for i := 0 to ArrItems.Count - 1 do
      begin
        It := ArrItems.Items[i] as TJSONObject;
        idx := Length(FItems);
        SetLength(FItems, idx + 1);

        FItems[idx].ID := (It.GetValue('ID') as TJSONNumber).AsInt;
        FItems[idx].Text := It.GetValue('Text').Value;
        FItems[idx].Checked := (It.GetValue('Checked') as TJSONBool).AsBoolean;
        FItems[idx].Priority := (It.GetValue('Priority') as TJSONNumber).AsInt;
        FItems[idx].Category := It.GetValue('Category').Value;

        if not TryStrToDate(It.GetValue('Deadline').Value, tmpDate) then
          tmpDate := Date;
        FItems[idx].Deadline := tmpDate;
      end;
    end;

    if Obj.TryGetValue('completed', ArrCompleted) then
    begin
      for i := 0 to ArrCompleted.Count - 1 do
      begin
        It := ArrCompleted.Items[i] as TJSONObject;
        Memo_Completed.Lines.Add(It.GetValue('Text').Value);
      end;
    end;
  finally
    Obj.Free;
  end;

  RefreshList;
end;

procedure TForm1.LoadDeadlineConfig;
var
  ini: TIniFile;
  iniPath: string;
begin
  iniPath := TPath.Combine(ExtractFileDir(ParamStr(0)), 'settings.ini'); // ← exeと同じ場所
  if TFile.Exists(iniPath) then
  begin
    ini := TIniFile.Create(iniPath);
    try
      YellowDays := ini.ReadInteger('DeadlineWarning', 'YellowDays', 7);
      RedDays    := ini.ReadInteger('DeadlineWarning', 'RedDays', 3);
    finally
      ini.Free;
    end;
  end
  else
  begin
    YellowDays := 7;
    RedDays    := 3;
  end;
end;

procedure TForm1.Memo_CompletedDblClick(Sender: TObject);
var
  line: string;
  newItemIdx: Integer;
  item: TCheckItem;
  ln: Integer;
  p1, p2: Integer;
  sPriority, sCategory, sDeadline: string;
begin
  ln := Memo_Completed.CaretPos.Y;
  if (ln < 0) or (ln >= Memo_Completed.Lines.Count) then Exit;

  line := Memo_Completed.Lines[ln];
  p1 := Pos(' [', line);
  if p1 = 0 then Exit;

  item.Text := Copy(line, 1, p1 - 1);

  p2 := Pos('優先度:', line);
  if p2 > 0 then
    sPriority := Copy(line, p2 + Length('優先度:'), Pos(', カテゴリ:', line) - (p2 + Length('優先度:')))
  else
    sPriority := '1';
  item.Priority := StrToIntDef(Trim(sPriority), 1);

  p2 := Pos('カテゴリ:', line);
  if p2 > 0 then
    sCategory := Copy(line, p2 + Length('カテゴリ:'), Pos(', 期限:', line) - (p2 + Length('カテゴリ:')))
  else
    sCategory := '';
  item.Category := Trim(sCategory);

  p2 := Pos('期限:', line);
  if p2 > 0 then
  begin
    sDeadline := Copy(line, p2 + Length('期限:'), Length(line));
    if sDeadline.EndsWith(']') then
      Delete(sDeadline, Length(sDeadline), 1);
    sDeadline := Trim(sDeadline);
  end
  else
    sDeadline := '';

  if not TryStrToDate(sDeadline, item.Deadline) then
    item.Deadline := Date;
  item.Checked := False;

  newItemIdx := Length(FItems);
  SetLength(FItems, newItemIdx + 1);
  FItems[newItemIdx] := item;

  Memo_Completed.Lines.Delete(ln);
  RefreshList;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetLength(FItems, 0);
  LastSelectedIndex := -1;
  FSortAscending := True;

  StringGrid1.Cells[0, 0] := '完了';
  StringGrid1.Cells[1, 0] := 'タスク';
  StringGrid1.Cells[2, 0] := '優先度';
  StringGrid1.Cells[3, 0] := 'カテゴリ';
  StringGrid1.Cells[4, 0] := '期限';
  StringGrid1.DefaultRowHeight := 20;

  ComboBox_FilterCategory.Items.Clear;
  ComboBox_FilterCategory.Items.Add('仕事');
  ComboBox_FilterCategory.Items.Add('プライベート');
  ComboBox_FilterCategory.Items.Add('学習');
  ComboBox_FilterCategory.Items.Add('その他');

  ComboBox_FilterPriority.Items.Clear;
  ComboBox_FilterPriority.Items.Add('1');
  ComboBox_FilterPriority.Items.Add('2');
  ComboBox_FilterPriority.Items.Add('3');
  ComboBox_FilterPriority.Items.Add('4');
  ComboBox_FilterPriority.Items.Add('5');

  LoadDeadlineConfig;
  LoadData;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveData;
end;

procedure TForm1.RefreshView;
var
  s: string;
  i, displayRow: Integer;
  catFilter: string;
  priFilter: Integer;
  tempList: TArray<TCheckItem>;
begin
  s := Trim(Edit_search.Text);

  // フィルタ
  catFilter := ComboBox_FilterCategory.Text;   // '(すべて)' or '仕事' etc.
  priFilter := ComboBox_FilterPriority.ItemIndex + 1; // 0=すべて

  tempList := Copy(FItems);

  // ソート例：優先度昇順
  TArray.Sort<TCheckItem>(tempList,
    TComparer<TCheckItem>.Construct(
      function(const A, B: TCheckItem): Integer
      begin
        if FSortAscending then
          Result := A.Priority - B.Priority
        else
          Result := B.Priority - A.Priority;
      end
    )
  );

  StringGrid1.RowCount := 1;
  displayRow := 1;

  for i := 0 to High(tempList) do
  begin
    // 🔍 検索ワード（空なら無視）
    if (s <> '') and
       not (ContainsText(tempList[i].Text, s) or
            ContainsText(tempList[i].Category, s) or
            ContainsText(IntToStr(tempList[i].Priority), s) or
            ContainsText(DateToStr(tempList[i].Deadline), s)) then
      Continue;

    // 🏷 カテゴリフィルタ（"(すべて)" なら無視）
    if (catFilter <> '(すべて)') and
       (catFilter <> '') and
       (tempList[i].Category <> catFilter) then
      Continue;

    // ⭐ 優先度フィルタ（0＝すべて）
    if (priFilter > 0) and
       (tempList[i].Priority <> priFilter) then
      Continue;

    // ここに来たら表示
    StringGrid1.RowCount := displayRow + 1;
    StringGrid1.Cells[0, displayRow] := '';
    StringGrid1.Cells[1, displayRow] := tempList[i].Text;
    StringGrid1.Cells[2, displayRow] := IntToStr(tempList[i].Priority);
    StringGrid1.Cells[3, displayRow] := tempList[i].Category;
    StringGrid1.Cells[4, displayRow] := DateToStr(tempList[i].Deadline);

    Inc(displayRow);
  end;

  StringGrid1.Invalidate;
end;

procedure TForm1.Edit_searchChange(Sender: TObject);
begin
  RefreshView;
end;

end.

