program Tasklist;

uses
  Vcl.Forms,
  Unit_Tasklist in 'Unit_Tasklist.pas' {Form_TaskList},
  Unit_ToggleTask in 'Unit_ToggleTask.pas' {Form_EditTask},
  Unit_CompletedTask in 'Unit_CompletedTask.pas' {Form_CompletedTasklist},
  Unit_TaskTypes in 'Unit_TaskTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_TaskList, Form_TaskList);
  Application.CreateForm(TForm_CompletedTasklist, Form_CompletedTasklist);
  Application.Run;
end.
