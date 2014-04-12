program klima;

uses
  Forms,
  mainform in 'mainform.pas' {KlimaForm},
  config in 'config.pas' {configForm},
  edit in 'edit.pas' {editForm},
  utool in 'utool.pas',
  about in 'about.pas' {aboutForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Klima';
  Application.CreateForm(TKlimaForm, KlimaForm);
  Application.CreateForm(TeditForm, editForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.
