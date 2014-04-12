unit edit;

interface

uses                                                         
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Mask;

type
  TeditForm = class(TForm)
    stringGrid: TStringGrid;
    edName: TEdit;
    edHeight: TEdit;
    cbContinent: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure stringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  editForm: TeditForm;

implementation

{$R *.DFM}

procedure TeditForm.stringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then with stringGrid do begin
//    key:=9;
    if col=1
     then col:=col+1
     else begin
       col:=1;
       if row < 12
        then row:=row+1
        else row:=1;
     end;
  end;
end;

end.
