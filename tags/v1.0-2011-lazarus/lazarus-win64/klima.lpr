program klima;

{$MODE Delphi}

uses
  Forms, Interfaces,
  mainform in 'mainform.pas' {KlimaForm},
  config in 'config.pas' {configForm},
  edit in 'edit.pas' {editForm},
  utool in 'utool.pas',
  about in 'about.pas' {aboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Klima';
  Application.CreateForm(TKlimaForm, KlimaForm);
  Application.CreateForm(TeditForm, editForm);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.
