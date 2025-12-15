unit Unit3;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids;

type
  TForm3 = class(TForm)
    StringGrid_Completed: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  // StringGrid_Completedの設定など
  StringGrid_Completed.ColCount := 5;  // 必要な列数に設定
  StringGrid_Completed.RowCount := 1;  // ヘッダー行用に1行追加
  StringGrid_Completed.Cells[0, 0] := '完了';  // ヘッダー設定
  StringGrid_Completed.Cells[1, 0] := 'タスク';
  StringGrid_Completed.Cells[2, 0] := '優先度';
  StringGrid_Completed.Cells[3, 0] := 'カテゴリ';
  StringGrid_Completed.Cells[4, 0] := '期限';
end;

end.

