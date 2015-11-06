program sim6809win;

uses
  Forms,
  SIM6809 in 'sim6809.pas',
  win6809 in 'win6809.pas' {SimForm},
  thread in 'thread.pas',
  Info in 'Info.pas' {InfoForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSimForm, SimForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.Run;
end.
