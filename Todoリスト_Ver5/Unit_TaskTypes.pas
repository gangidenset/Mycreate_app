unit Unit_TaskTypes;

interface

uses
  System.SysUtils;

type
  TTaskItem = record
    Text: string;
    Priority: Integer;
    Category: string;
    Deadline: TDate;
    Completed: Boolean;
  end;

implementation

end.

