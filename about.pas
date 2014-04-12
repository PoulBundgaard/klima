unit about;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, utool;

type
  TaboutForm = class(TForm)
    info: TLabel;
    btnOk: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  aboutForm: TaboutForm;

implementation

{$R *.lfm}

procedure TaboutForm.FormCreate(Sender: TObject);
begin
  Caption := '�ber '+versionTag;
  Info.Caption := versiontag+' f�r Windows'#13+
                  '� 1999-2011 Tobias Thierer';
  Info.Left := (width-info.width) div 2;
  btnOk.Left:=(width - btnOk.width) div 2;
end;

end.
