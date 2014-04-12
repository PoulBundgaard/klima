unit about;

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

{$R *.DFM}

procedure TaboutForm.FormCreate(Sender: TObject);
begin
  Caption := 'Über '+versionTag;
  Info.Caption := versiontag+' für Windows'#13+
                  '© 1999 Tobias Thierer'#13+
                  ''#13+
                  'pHreaX (http://www.phreax.net)'#13;
  Info.Left := (width-info.width) div 2;
  btnOk.Left:=(width - btnOk.width) div 2;
end;

end.
