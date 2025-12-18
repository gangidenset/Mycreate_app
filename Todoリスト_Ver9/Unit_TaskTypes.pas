unit Unit_TaskTypes;

interface

uses
  System.SysUtils;

type
  TTaskStatus = (tsNotStarted, tsInProgress, tsOnHold);

  TTaskItem = record
    Text: string;
    Priority: Integer;
    Category: string;
    Deadline: TDate;
    Completed: Boolean;
    Status: TTaskStatus;
    Tags: TArray<string>;
  end;

implementation

end.

