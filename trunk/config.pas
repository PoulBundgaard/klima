unit config;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, uTool, Mask;

type
  TconfigForm = class(TForm)
    rgDupes: TRadioGroup;
    rgOpen: TRadioGroup;
    btnOk: TButton;
    cbWarnNotSaved: TCheckBox;
    btnPrinterSetup: TButton;
    PrinterSetupDialog: TPrinterSetupDialog;
    cbConfirmModify: TCheckBox;
    cbAutoOpen: TCheckBox;
    cbConfirmAdd: TCheckBox;
    cbConfirmDelete: TCheckBox;
    cbMakeBackups: TCheckBox;
    Label1: TLabel;
    edExportWidth: TEdit;
    Label2: TLabel;
    edExportHeight: TEdit;
    cbSaveUnchanged: TCheckBox;
    cbColorLabels: TCheckBox;
    cbSolidRainLine: TCheckBox;
    cbExtendTemp: TCheckBox;
    Label3: TLabel;
    edExtendTemp: TEdit;
    edExtendRain: TEdit;
    cbExtendRain: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    procedure btnPrinterSetupClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  configForm: TconfigForm;

implementation

{$R *.DFM}

procedure TconfigForm.btnPrinterSetupClick(Sender: TObject);
begin
  printersetupdialog.execute;
end;



procedure TconfigForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var b1,b2,b3:Boolean;
begin
  b1 := (isInt(edExportWidth.Text) and (isInt(edExportHeight.Text)));
  b2 := (isInt(edExtendRain.Text)  and (StrToInt(edExtendRain.Text)  >= 100));
  b3 := (isInt(edExtendTemp.Text)  and (StrToInt(edExtendTemp.Text)  <= 0));
  if (not b1)
   then MessageDlg('Bitte geben Sie Ganzzahlen für die Höhe und Breite des Grafikexports an',mtError,[mbOk],0)
   else if (not b2)
    then MessageDlg('Bitte geben Sie eine Ganzzahl >= 100 für die Niederschlagsskala an',mtError,[mbOk],0)
    else if (not b3)
     then MessageDlg('Bitte geben Sie eine Ganzzahl <= 0 für die Temperaturskala an',mtError,[mbOk],0);
  canClose:=(b1 and b2 and b3);
end;

end.
