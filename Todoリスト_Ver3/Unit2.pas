unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Samples.Spin;

type
  TForm_TaskEdit = class(TForm)
    Edit_Task: TEdit;
    Label_EditTask: TLabel;
    ComboBox_Category: TComboBox;
    Label_EditCategory: TLabel;
    ComboBox_Priority: TComboBox;
    Label_EditPriority: TLabel;
    dtp_Deadline: TDateTimePicker;
    Label_EditDeadline: TLabel;
    Button_OK: TButton;
    Button_Cancel: TButton;
    Label_EditToggle: TLabel;
    procedure Button_OKClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox_CategoryKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_TaskKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox_PriorityKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dtp_DeadlineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form_TaskEdit: TForm_TaskEdit;

implementation

{$R *.dfm}

procedure TForm_TaskEdit.Button_CancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TForm_TaskEdit.Button_OKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TForm_TaskEdit.ComboBox_CategoryKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    ComboBox_Priority.SetFocus;
  end;
end;

procedure TForm_TaskEdit.ComboBox_PriorityKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if Key = VK_RETURN then
  begin
    Key := 0;
    dtp_Deadline.SetFocus;
  end;
end;

procedure TForm_TaskEdit.dtp_DeadlineKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_RETURN then
  begin
    Key := 0;
    ModalResult := mrOk;  // 確定
  end;
end;

procedure TForm_TaskEdit.Edit_TaskKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0; // Enter のデフォルト処理を止める
    ComboBox_Category.SetFocus;
  end;
end;

procedure TForm_TaskEdit.FormCreate(Sender: TObject);
begin
  ComboBox_Category.Items.Clear;
  ComboBox_Category.Items.Add('仕事');
  ComboBox_Category.Items.Add('プライベート');
  ComboBox_Category.Items.Add('学習');
  ComboBox_Category.Items.Add('その他');

  ComboBox_Priority.Items.Clear;
  ComboBox_Priority.Items.Add('1');
  ComboBox_Priority.Items.Add('2');
  ComboBox_Priority.Items.Add('3');
  ComboBox_Priority.Items.Add('4');
  ComboBox_Priority.Items.Add('5');

  dtp_Deadline.Date := Date;
end;

end.
