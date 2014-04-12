unit mainform;

{$MODE Delphi}
{$ALIGN OFF}
interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Grids, Spin, Menus,
  clipbrd, iniFiles, printers, Buttons, uTool;

const
      defaultSzX = 413; // > 0!
      defaultSzY = 285; // > 0!
      defaultLineWidth   = 1;
      defaultCircleWidth = 1;
      defaultGap  = 40;
      defaultLLen = 4;

      maxSeg = 40;   numSegX = 12;

      maxDataSets = 10000;
      maxPossibleRain = 3000;
      minPossibleRain = 0;
      maxPossibleTemp = 100;
      minPossibleTemp = -100;
      keyTab = #9;
      keyEnter = #13;
      keyEsc = #27;
      Months : array[1..12] of String = ('Januar',
               'Februar','März','April','Mai','Juni','Juli',
               'August','September','Oktober','November',
               'Dezember');
      Continents : array[1..6] of String = ('Afrika','Amerika',
                   'Antarktis','Asien','Australien','Europa');

      convStrWIN = 'äöüÄÖÜß';
      convStrDOS = chr($84)+chr($94)+chr($81)+chr($8e)+chr($99)+chr($9a)+chr($e1);

//      exportSizeX = 413; exportSizeY = 277;

type
  TDataSet = record
               Name : String[20];
               One:Byte;
               Continent  : Byte;
               sHeight    : String[4];
               sTemp      : array[1..12] of String[5];
               sRain      : array[1..12] of String[4];
               sAvgTemp   : String[5];
               sSumRain   : String[7];
             end;

  TConvDirection = (cdDosToWin, cdWinToDos);
  TExportDest = (edFile, edClipboard);

  TKLIFile = File of TDataSet;

  TKlimaForm = class(TForm)
    OpenDialog: TOpenDialog;
    StatusBar: TStatusBar;
    cbStation: TComboBox;
    stringGrid: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    edHeight: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    cbShowAridHumid: TCheckBox;
    cbShowTemp: TCheckBox;
    cbShowRain: TCheckBox;
    cbShowAll: TCheckBox;
    GroupBox1: TGroupBox;
    MainMenu1: TMainMenu;
    Klimadiagramm1: TMenuItem;
    Oeffnen1: TMenuItem;
    Speichern1: TMenuItem;
    N1: TMenuItem;
    Beenden1: TMenuItem;
    Konfiguration1: TMenuItem;
    Neu1: TMenuItem;
    ToolBar: TToolBar;
    iconList: TImageList;
    tbEmpty1: TToolButton;
    Klimadiagramm2: TMenuItem;
    InDateispeichern1: TMenuItem;
    InZwischenablagekopieren1: TMenuItem;
    BMPSaveDialog: TSaveDialog;
    PaintBox: TPaintBox;
    pmDiagram: TPopupMenu;
    IndieZwischenablagekopieren1: TMenuItem;
    InDateispeichern2: TMenuItem;
    cbColor: TCheckBox;
    cbShowName: TCheckBox;
    N2: TMenuItem;
    Stationhinzufgen1: TMenuItem;
    Stationlschen1: TMenuItem;
    edContinent: TEdit;
    Stationeditieren1: TMenuItem;
    edGridsize: TSpinEdit;
    KLISaveDialog: TSaveDialog;
    N4: TMenuItem;
    Speichernunter1: TMenuItem;
    Schrift1: TMenuItem;
    Schrift2: TMenuItem;
    FontDialog: TFontDialog;
    tbEmpty2: TToolButton;
    Datensatz1: TMenuItem;
    btnNewFile: TSpeedButton;
    btnLoad: TSpeedButton;
    btnSave: TSpeedButton;
    btnAdd: TSpeedButton;
    btnRemove: TSpeedButton;
    btnEdit: TSpeedButton;
    btnCopyToClipboard: TSpeedButton;
    btnSaveBitmap: TSpeedButton;
    btnPrintDiagram: TSpeedButton;
    btnFont: TSpeedButton;
    Info1: TMenuItem;
    N3: TMenuItem;
    ToolButton1: TToolButton;
    btnInfo: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure cbStationChange(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edGridSizeChange(Sender: TObject);
    procedure cbShowAridHumidClick(Sender: TObject);
    procedure cbShowTempClick(Sender: TObject);
    procedure cbShowRainClick(Sender: TObject);
    procedure cbShowAllClick(Sender: TObject);
    procedure Beenden1Click(Sender: TObject);
    procedure Oeffnen1Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure Konfiguration1Click(Sender: TObject);
    procedure berKlima021Click(Sender: TObject);
    procedure cbColorClick(Sender: TObject);
    procedure cbShowNameClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Stationeditieren1Click(Sender: TObject);
    procedure Stationhinzufgen1Click(Sender: TObject);
    procedure Stationlschen1Click(Sender: TObject);
    procedure InZwischenablagekopieren1Click(Sender: TObject);
    procedure InDateispeichern1Click(Sender: TObject);
    procedure Speichern1Click(Sender: TObject);
    procedure Speichernunter1Click(Sender: TObject);
    procedure Neu1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Schrift1Click(Sender: TObject);
    procedure Info1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    loading : Boolean;
    numDataSets : Integer;
    multGridSz  : Real;
    gridSz      : Integer;
    startSeg, endSeg : Integer;
    dataSets    : array[1..maxDataSets] of TDataSet;
    numSegY, zeroPosY, hundredPosY   : Integer;
    relPos, interPos,segPosX,rainY, tempY : array[0..numSegX+1] of Integer;
    segPosY,segValY   : array[0..maxSeg] of Integer;
    rain, temp        : array[1..12] of Real;
    convTableDosToWin, convTableWinToDos : array[#0..#255] of Char;
    minTemp, maxRain  : Integer;
    dataShown         : Boolean;
    lastFilename      : String;
    numFilesOpen      : Integer;
    exportSizeX, exportSizeY : Integer;
    inifilename       : String;
    fDataModified     : Boolean;
    gap, lLen         : Integer;
    zoomFactor        : Real;
    drawFont          : TFont;
    procedure setDataModified(b:Boolean);
    property dataModified:Boolean read fDataModified write setDataModified;
    function getValPos(val:Real):Integer;
    function getRainY(x:Integer):Integer;
    function getTempY(x:Integer):Integer;
    procedure loadData;
    procedure updateStatus;
    function forgetOldData:Boolean;
    procedure sortDatasets;
    procedure numDatasetsChanged;
    procedure updateDisplay;
    procedure drawDiagram(canvas:TCanvas;szX, szY: Integer;data:TDataSet;minVal, maxVal : Integer);
    procedure putData(var data:TDataSet; stringGrid:TStringGrid; onMainForm:Boolean);
    procedure getData(var data:TDataSet; stringGrid:TStringGrid);
    procedure buildStationList;
    function showAridHumid:Boolean;
    function showTemp:Boolean;
    function showRain:Boolean;
    function showName:Boolean;
    function allowDataModification:Boolean;
    function equal(a,b:TDataset):Boolean;
    function editDataSet(var data:TDataSet; mustConfirm:Boolean):Boolean;
    function calcMultGridSz(sz:Integer):Real;
    function remindSave(msg:String):Boolean;
    procedure calcTables(szx,szy,minVal,maxVal,scaleStart,scaleEnd:Integer);
    procedure drawBody(canvas:TCanvas;szx,szy:Integer);
    procedure convertString(var s:String; direction:TConvDirection);
    procedure exportGraphic(destination:TExportDest);
    procedure saveConfig;
    procedure loadConfig;
    procedure process(var data:TDataSet);
    procedure checkForDupes;
    procedure saveData(filename:String);
    procedure executeSaveDataAsDialog;
    procedure genericSave;
  public
    { Public-Deklarationen }
  end;

const emptyDataSet:TDataSet = (name:'';one:1;continent:49;sHeight:'';
                               sTemp:('','','','','','','','','','','','');
                               sRain:('','','','','','','','','','','','');
                               sAvgTemp:''; sSumRain:'');

var
  KlimaForm: TKlimaForm;
  
implementation

uses config, about, edit;

{$R *.lfm}


function myStrToFloat(s:String):Real;
var code:Integer;
    errorMsg:String;
begin
  errorMsg:='"'+s+'" ist keine gültiger Fließkommawert!';
  val(s,result,code);
  if code<>0 then begin
    MessageDlg(errorMsg,mtError,[mbOk],0);
    result:=0;
  end;
end;


function myStrToInt(s:String):Integer;
var code:Integer;
    errorMsg:String;
begin
  errorMsg:='"'+s+'" ist keine gültige Ganzzahl!';
  val(s,result,code);
  if code<>0 then begin
    MessageDlg(errorMsg,mtError,[mbOk],0);
    result:=0;
  end;
end;

procedure cut(var s:String);
begin
  while (s<>'') and (s[1]=' ') do delete(s,1,1);
  while (s<>'') and (s[length(s)]=' ') do delete(s,length(s),1);
end;

procedure toInt(var s:String);
var i:Integer;
begin
  i:=1;
  while i<=length(s) do if s[i] in ['0'..'9','-'] then inc(i) else delete(s,i,1);
end;

procedure toFloat(var s:String);
var i:Integer;
begin
  for i:=1 to length(s) do if s[i]=',' then s[i]:='.';
  i:=1;
  while i<=length(s) do if s[i] in ['0'..'9','.','-'] then inc(i) else delete(s,i,1);
end;

function TKlimaForm.calcMultGridSz(sz:Integer):Real;
begin result := (2/826) * exp(sz*ln(1.1)) end;

procedure TKlimaForm.FormCreate(Sender: TObject);
var i:Integer;
    ch:Char;
begin
  caption:=versionTag;
  Application.Title := versionTag;
  btnInfo.Hint:='Über '+versionTag;
  numDataSets := 0;
  numFilesOpen:=1;
  lastFilename:='';
  dataModified:=False;
  loading:=False;
  dataShown:=False;
  multGridSz:=calcMultGridSz(edGridSize.Value);
//  gridSz := edGridSize.Value;
  drawFont:=fontDialog.Font;

  DecimalSeparator := '.';
  stringGrid.col:=0; stringGrid.row:=0;
  for ch:=#0 to #255 do begin
    convTableDosToWin[ch]:=ch;
    convTableWinToDos[ch]:=ch;
  end;
  for i:=1 to length(convStrDos) do begin
    convTableDosToWin[convStrDos[i]]:=convStrWin[i];
    convTableWinToDos[convStrWin[i]]:=convStrDos[i];
  end;
  configForm:=TConfigForm.Create(self);
  inifilename:=changeFileExt(paramstr(0),'.INI');
  loadConfig;
  if configForm.cbAutoOpen.Checked then loadData;
  updateStatus;
end;

procedure TKlimaForm.numDatasetsChanged;
begin
  cbStation.Enabled:=(numDatasets<>0);
  dataShown := (numDatasets<>0) and (cbStation.itemIndex>=0);
  buildStationList;
  updateStatus;
  updateDisplay;
end;


function TKlimaForm.forgetOldData:Boolean;
begin
  forgetOldData:= (numDataSets = 0)
               or (configForm.rgOpen.itemIndex = 0)
               or (   (configForm.rgOpen.itemIndex = 2)
                   and(mrYes=MessageDlg('Alte Klimastationen vergessen?',mtConfirmation,[mbYes,mbNo],0))
                  );
end;

procedure TKlimaForm.putData(var data:TDataSet;stringgrid:TStringGrid; onMainForm:Boolean);
var actRain, i, sumRain  : Integer;
    rMinTemp, actTemp, sumTemp  : Real;
begin
  for i:=1 to 12 do stringGrid.cells[0,i]:=Months[i];
  stringGrid.Cells[1,0]:='Temperatur';
  stringGrid.Cells[2,0]:='Niederschlag';
  if onMainform then begin
    stringGrid.cells[0,13]:='Mittelwert';
    stringGrid.cells[0,14]:='Summe';
  end;
  sumTemp:=0; sumRain:=0;
  with data do begin
    maxRain:=100;
    rminTemp:=0;
    for i:=1 to 12 do begin
      if (sTemp[i]='') or (sTemp[i]='-')
       then actTemp:=0
       else actTemp:=myStrToFloat(sTemp[i]);
      temp[i]:=actTemp;
      if (actTemp > maxPossibleTemp) then begin
        actTemp:=maxPossibleTemp;
        sTemp[i]:=intToStr(maxPossibleTemp);
      end;
      if (actTemp < minPossibleTemp) then begin
        actTemp:=minPossibleTemp;
        sTemp[i]:=intToStr(minPossibleTemp);
      end;

      if (sRain[i]='') or (sRain[i]='-')
       then actRain:=0
       else actRain:=myStrToInt(sRain[i]);
      if (actRain > maxPossibleRain) then begin
        actRain:=maxPossibleRain;
        sRain[i]:=intToStr(maxPossibleRain);
      end;
      if (actRain < minPossibleRain) then begin
        actRain:=minPossibleRain;
        sRain[i]:=intToStr(minPossibleRain);
      end;
      rain[i]:=actRain / 2;
      sumTemp:=sumTemp+actTemp;       inc(sumRain,actRain);
      if (actRain > maxRain) then maxRain:=actRain;
      if (actTemp < rminTemp) then rminTemp:=actTemp;
    end;
    for i:=1 to 12 do begin
      stringGrid.cells[1,i]:=sTemp[i];
      stringGrid.cells[2,i]:=sRain[i];
    end;
    sAvgTemp:=FloatToStrF(sumTemp/12,ffFixed,5,1);
    sSumRain:=IntToStr(sumRain);
    if onMainForm then begin
      stringGrid.cells[1,13]:=sAvgTemp;
      stringGrid.cells[2,13]:=FloatToStrF(sumRain/12,ffFixed,5,1);
      stringGrid.cells[1,14]:='';
      stringGrid.cells[2,14]:=sSumRain;

      edHeight.Text:=sHeight;
      if continent in [49..54] then edContinent.text:=continents[continent-48];
    end
    else begin
      editForm.edHeight.Text:=sHeight;
      editForm.cbContinent.itemIndex:=continent-49;
      editForm.edName.Text:=Name;
    end;

    minTemp:=round(rmintemp-0.49);
    while ((minTemp mod 10) <> 0) do dec(minTemp);
    while ((maxRain mod 200) <> 100) do inc(maxRain);
  end;
end;


procedure TKlimaForm.getData(var data:TDataSet; stringGrid:TStringGrid);
var i: Integer;
begin
  with data do begin
    sHeight:=editForm.edHeight.Text;
    Name := editForm.edName.Text;
    continent := editForm.cbContinent.itemIndex+49;
    for i:=1 to 12 do begin
      sTemp[i]:=stringGrid.cells[1,i];
      sRain[i]:=stringGrid.cells[2,i];
    end;
  end;
  process(data);
end;



procedure TKlimaForm.updateDisplay;
var i,j:Integer;
    canvRect:TRect;
begin
  if (numDatasets > 0) and (cbStation.itemIndex>=0)
   then begin
     putData(dataSets[cbStation.itemIndex+1],stringGrid,True);
     drawDiagram(paintbox.canvas,paintbox.width,paintbox.height,dataSets[cbStation.itemIndex+1],minTemp,maxRain div 2);
   end
   else begin
     for i:=1 to 2 do for j:=1 to 14 do stringgrid.cells[i,j]:='';
     edHeight.Text:=''; edContinent.Text:='';
     with canvRect do begin
       with topleft do begin x:=0; y:=0 end;
       with bottomright do begin x:=paintbox.width-1; y:=paintbox.height-1; end;
     end;
     paintbox.canvas.fillRect(canvRect);
   end;
end;

procedure TKlimaForm.updateStatus;
var s:String;
begin
  if numDataSets = 1
   then s:='Ein Datensatz'
   else s:=intToStr(numDataSets)+' Datensätze';
  if not ((numFilesOpen=1) and (lastFileName='')) then begin
    s:=s+' aus ';
    if numFilesOpen=1
     then s:=s+'der Datei "'+lastFileName+'"'
     else s:=s+intToStr(numFilesOpen)+' Dateien';
  end;
  s:=s+' im Speicher';
  StatusBar.Panels[1].Text := s;
  if dataModified
   then StatusBar.Panels[0].Text := 'Datensätze verändert'
   else StatusBar.Panels[0].Text := ''
end;

procedure TKlimaForm.loadData;
var f: TKLIFile;
    s:String;
    error : Boolean;
    tmpf: file of byte;
begin
  if (openDialog.Execute) and (fileexists(opendialog.filename)) then begin
    error := False;
    assignFile(tmpf,opendialog.filename); reset(tmpf);
    if (fileSize(tmpf) mod sizeof(TDataSet)) <> 0 then error:=True;
    closeFile(tmpf);
    if (not error) then begin
      if forgetOldData then begin
        if remindSave('Daten wurden geändert. Änderungen speichern?') then begin
          numDataSets:=0;
          cbStation.Items.Clear;
          numFilesOpen := 0;
          dataModified := False;
        end
        else exit;  
      end
      else if (dataModified) and (numFilesOpen=1) and (numDatasets>0) then begin
        if not remindSave('Wenn Sie Datensätze aus mehreren Dateien '
                  +'laden, können Sie diese hinterher nicht in '
                  +'die verschiedenen Dateien zurückschreiben. '
                  +'Wollen Sie nun die bisher geladenen Dateien speichern?')
        then  exit;
      end;
    end;
    assignfile(f, openDialog.Filename);
    reset(f);
    loading:=True;
    while (not error) and (not eof(f)) do begin
      inc(numDataSets);
      read(f,datasets[numdatasets]);
      s:=dataSets[numDataSets].name;
      convertString(s,cdDosToWin);
      dataSets[numDataSets].name:=s;
//      cbStation.Items.Add(s);
    end;
    closeFile(f);
    loading:=False;
    if error then begin
//    numDatasets:=0;
//    cbStation.Items.Clear;
      messageBox(0,'Dies ist keine gültige KLI Datei','Fehler',0);
    end
    else begin
      inc(numfilesopen);
      lastFilename := opendialog.filename;
    end;
    //if numdatasets >= 0 then cbStation.ItemIndex:=0;
    buildStationList;
    numDatasetsChanged;
    updateStatus;
    updateDisplay;
  end;
end;

procedure TKlimaForm.btnLoadClick(Sender: TObject);
begin
  loadData;
end;

procedure TKlimaForm.sortDatasets;
var i,j,h:Integer;
    val:TDataSet;
    ch:Char;
    table : array[#0..#255] of Char;
 function bigger(a,b :String):boolean;
 var i:Integer;
 begin
   for i:=1 to length(a) do a[i]:=table[a[i]];
   for i:=1 to length(b) do b[i]:=table[b[i]];
   result := a > b;
 end;
begin
  for ch:=#0 to #255 do begin
    table[ch]:=upcase(ch);
    if table[ch] = 'Ä' then table[ch] := 'A';
    if table[ch] = 'Ö' then table[ch] := 'O';
    if table[ch] = 'Ü' then table[ch] := 'U';
    if table[ch] = 'ä' then table[ch] := 'A';
    if table[ch] = 'ö' then table[ch] := 'O';
    if table[ch] = 'ü' then table[ch] := 'U';
  end;
  h:=1;
  repeat h:=3*h+1 until h > numDatasets;
  repeat
    h:=h div 3;
    for i:=h+1 to numDatasets do begin
      j:=i;
      val:=datasets[j];
      while bigger(datasets[j-h].name,val.name) do begin
        datasets[j]:=datasets[j-h];
        j:=j-h;
        if j<=h then break;
      end;
      datasets[j]:=val;
    end;
  until h=1;
end;

function TKlimaForm.getValPos(val:Real):Integer;
var i:Integer;
begin
  if val < segValY[0]
   then result:=segPosY[0]
   else if val > segValY[numSegY]
    then result := segPosY[numSegY]
    else begin
      i:=0;
      while val > segValY[i+1] do inc(i);
      result := segPosY[i] + round( (segPosY[i+1] - segPosY[i]) * ((val-SegValY[i]) / (SegValY[i+1]-segValY[i])) );
    end;
end;


function TKlimaForm.getRainY(x:Integer):Integer;
var i:Integer;  rel : Real;
begin
  i:=0;  while x > interPos[i+1] do inc(i);
  rel := (x - interPos[i]) / (interPos[i+1] - interPos[i]);
  result := rainY[i] + round(rel * (rainY[i+1]-rainY[i]));
end;

function TKlimaForm.getTempY(x:Integer):Integer;
var i:Integer;  rel : Real;
begin
  i:=0;  while x > interPos[i+1] do inc(i);
  rel := (x - interPos[i]) / (interPos[i+1] - interPos[i]);
  result := tempY[i] + round(rel * (tempY[i+1]-tempY[i]));
end;

procedure TKlimaForm.calcTables(szx,szy,minVal,maxVal,scaleStart,scaleEnd:Integer);
var tmp,i:Integer;
begin
  tmp:=scaleStart;//minVal;
  numSegY:=0;

  segValY[0]:=scaleStart;//minVal;
  repeat
     inc(numSegY);
     if tmp < 50 then tmp:=tmp+10 else tmp:=tmp+100;
     segValY[numSegY]:=tmp;
  until tmp>=scaleEnd;//maxVal;
  zeroPosY:=szY-gap; hundredPosY:=gap; // damit der Compiler sich nicht beschwert

  for i:=0 to numSegY do begin
    segPosY[i] := szY - gap - round((i/numSegY) * (szY-2*gap));
    if segValY[i]=0 then zeroPosY := segPosY[i];
    if segValY[i]=50 then hundredPosY := segPosY[i];
  end;
  startSeg := 0; while segValY[startSeg] < minVal do inc(startSeg);
  endSeg:=numSegY; while segValY[endSeg] > maxVal do dec(endSeg);

  for i:=0 to numSegX do segPosX[i] := gap + round((i/numSegX) * (szX-2*gap));
  rainY[0]:=getValPos(round((Rain[1]+Rain[numSegX])/2)); rainY[13]:=rainY[0];
  tempY[0]:=getValPos(round((Temp[1]+Temp[numSegX])/2)); tempY[13]:=tempY[0];
  interPos[0]:=gap;
  interPos[numSegX+1]:=szX-gap;
  for i:=1 to numSegX do begin
    interPos[i]:=round((segPosX[i-1]+segPosX[i])/2);
    rainY[i]:=getValPos(Rain[i]);
    tempY[i]:=getValPos(Temp[i])
  end;
  for i:=1 to 12 do if tempY[i] = rainY[i]
   then relPos[i]:=0
   else if tempY[i] > rainY[i]
    then relPos[i]:=1
    else relPos[i]:=-1;
end;

procedure TKlimaForm.drawBody(canvas:TCanvas;szx,szy:Integer);
var i:Integer;
    s:String;
    extent:TSize;
begin
  with canvas do begin
    moveTo(gap,segPosY[endSeg]{szY-gap});  lineTo(gap,segPosY[startSeg]{gap}); // linke Y-Achse

    moveTo(gap,zeroPosY);    lineTo(szX-gap,zeroPosY); // X-Achse
    moveTo(szX-gap,segPosY[endSeg]{szY-gap}); lineTo(szX-gap,segPosY[startSeg]{gap});      // rechte Y-Achse
    { Monatsnamen }
    for i:=0 to numSegX do begin
      moveTo(segPosX[i],zeroPosY+(lLen div 2));
      lineTo(segPosX[i],zeroPosY-(lLen div 2));
      if i>0 then begin
        s:=months[i,1];
        extent := textExtent(s);
        TextOut(round((segPosX[i-1]+segPosX[i]-extent.cx)/2), zeroPosY+(lLen div 2),s);
      end;
    end;
    for i:=startSeg to endSeg do begin
      { Temperaturachse beschriften }

      if (cbColor.checked) and (configForm.cbColorLabels.checked) then canvas.Font.Color := clRed;
      if (segValY[i] <= 50) then begin
        moveTo(gap-(lLen div 2), segPosY[i]);
        lineTo(gap+(lLen div 2), segPosY[i]);
        s:=intTostr(segValY[i]);  extent:=TextExtent(s);
        TextOut(gap - lLen - extent.cx,segPosY[i] - (extent.cy div 2),s);
      end;

      { Niederschlagsachse beschriften }
      if (cbColor.checked) and (configForm.cbColorLabels.checked) then canvas.Font.Color := clblue;
      if segValY[i] >= 0 then begin
        moveTo(szX-gap-(lLen div 2), segPosY[i]);
        lineTo(szX-gap+(lLen div 2), segPosY[i]);
        s:=intTostr(segValY[i]*2);  extent:=TextExtent(s);
        TextOut(szX-gap + lLen,segPosY[i] - (extent.cy div 2),s);
      end;
      Font.Color := drawFont.Color;
    end;
  end;
end;

procedure TKlimaForm.drawDiagram(canvas:TCanvas;szX,szY:Integer;data:TDataSet;minVal, maxVal : Integer);
var i, j, y1,y2,actX  : Integer;
    extent    : TSize;
    s         : String;
    rect,
    canvRect  : TRect;
    color     : TColor;
    intZoomFactor : Integer;
    scaleMin, scaleMax : Integer;
 function minReal(a,b:Real):Real;
 begin if a<b then result:=a else result:=b end;
begin
  zoomFactor := //(0.5 * ((szX / {exportSizeX}defaultSzX) + (szY / {exportSizeY}defaultSzY)));
                minReal(szX/defaultSzX, szY/defaultSzY);
  intZoomFactor:=round(zoomFactor);
  gap:=round(defaultGap*zoomFactor);
  lLen:=round(defaultLLen*zoomFactor);
  gridSz := round(multGridSz * szX);

  with canvRect do begin
    with topleft do begin x:=0; y:=0 end;
    with bottomright do begin x:=szx-1; y:=szy-1; end;
  end;
  scaleMin:=minVal;
  scaleMax:=maxVal;
  with configForm do begin
    if (cbExtendTemp.checked) and (strToInt(edExtendTemp.Text) < scaleMin)
     then scaleMin := strToInt(edExtendTemp.Text);
    if (cbExtendRain.checked) and (strToInt(edExtendRain.Text) div 2 > scaleMax)
     then scaleMax := strToInt(edExtendRain.Text) div 2;
  end;

  calcTables(szx,szy,minVal,maxVal,scaleMin,scaleMax);
  with canvas do begin
    pen.width := round(defaultLineWidth*zoomFactor);
    Font:=drawFont;
    Font.Height := round(zoomFactor * drawFont.Height);

    brush.color:=clWhite;
    fillRect(canvRect);
    drawBody(canvas,szx,szy);
    { Überschrift }
    s:=data.sHeight+' m   '+data.sAvgTemp+' °C   '+data.sSumRain+' mm';
    extent:=textExtent(s);
    y1 :=gap - round(1.5*extent.cy){segPosY[numSegY]-2*extent.cy};
    if showName then textOut(interPos[1],y1,data.name);
    textOut(interPos[12]-extent.cx,y1,s);
    if (cbColor.Checked) and (configForm.cbColorLabels.checked) then Font.Color := clRed;
    s:='°C'; extent:=TextExtent(s);     textOut(gap-extent.cx-lLen,y1,s);
    if (cbColor.Checked) and (configForm.cbColorLabels.checked) then Font.Color := clBlue;
    s:='mm'; extent:=TextExtent(s);     textOut(szX-gap+lLen,y1,s);

    if showRain then begin
      if cbColor.checked then pen.color:=clBlue;
      if (not configForm.cbSolidRainLine.checked) then canvas.pen.Style := psDashDot;
      MoveTo(gap,rainY[0]);
      for i:=1 to 12 do LineTo(interPos[i],rainY[i]);
      LineTo(szX-gap,rainY[0]);
      pen.color:=clBlack;
      if (not configForm.cbSolidRainLine.checked) then canvas.pen.Style := psSolid;
    end;
    if showTemp then begin
      if cbColor.checked then canvas.pen.color := clRed;
      MoveTo(gap,tempY[0]);
      for i:=1 to 12 do LineTo(interPos[i],tempY[i]);
      LineTo(szX-gap,tempY[0]);
      canvas.pen.color := clBlack;
    end;

     { Streifen / Punktieren }
     if cbColor.checked then Pen.color:=clBlue;
     if showAridHumid then for actX:=(gap-1) div gridSz+1 to ((szX-gap) div gridSz) do begin
       y1 := getRainY(actX*gridSz);
       if (odd(actX))
         then y2 := hundredPosY
         else y2 := getTempY(actX*gridSz);
       if y2>zeroPosY then y2:=zeroPosY;
       if (not odd(actX)) or (y1 < hundredPosY) then begin
         if odd(actX) or (y2>y1)
          then begin moveTo(actX*gridSz,y1); lineTo(actX*gridSz,y2) end
          else begin
            if cbColor.checked
             then color:=clRed
             else color:=clBlack;
            if (intZoomFactor <= 1)
             then for i:=y1 downto y2 do if (i mod gridSz)=0
              then pixels[actX*gridSz,i]:=color
              else
             else for i:=y1 downto y2 do if (i mod gridSz)=0
              then begin
                brush.color:=color;
                with rect do begin
                  left := actX*gridSz - (intZoomFactor div 2);
                  right := left + intZoomFactor {-1};
                  top := i - (intZoomFactor div 2);
                  bottom := top + intZoomFactor {-1};
                end;
                fillrect(rect);
              end;
          end;
       end;
     end;
     pen.color:=clblack;
     brush.color:=clBlack;

     for i:=1 to numSegX do for j:=startSeg to EndSeg do begin // 0 to numSegY do begin
       with rect do begin
         left := segPosX[i] - (intZoomFactor div 2);
         top := segPosY[j] - (intZoomFactor div 2);
         right := left + intZoomFactor;
         bottom := top + intZoomFactor;
       end;
       fillrect(rect);
       with rect do begin
         left := interPos[i] - (intZoomFactor div 2);
         right := left + intZoomFactor;
       end;
       fillrect(rect);
{      Pixels[segPosX[i],segPosY[j]]:=clBlack;
       Pixels[interPos[i],segPosY[j]]:=clBlack; }
     end;
     brush.color := clWhite;
  end;
end;

procedure TKlimaForm.convertString(var s:String; direction:TConvDirection);
var i:Integer;
begin
  case direction of
    cdDosToWin: for i:=1 to length(s) do s[i]:=convTableDosToWin[s[i]];
    cdWinToDos: for i:=1 to length(s) do s[i]:=convTableWinToDos[s[i]];
  end;
end;

procedure TKlimaForm.cbStationChange(Sender: TObject);
begin
  if (not loading) and (numDatasets>0) then begin
    sortDatasets;
//    if (cbStation.itemIndex >= 0) then cbContinent.Enabled:=True;

    updateDisplay;
  end;
end;

procedure TKlimaForm.exportGraphic(destination:TExportDest);
var bitmap:TBitmap;
begin
  if numDataSets = 0 then begin
    messageBox(0,'Es wurden keine Datensätze geladen.','Fehler',0);
    exit;
  end;
  bitmap:=TBitmap.create;
  bitmap.width  := exportSizeX;
  bitmap.height := exportSizeY;
//bitmap.canvas.Font:=Paintbox.font;
  drawDiagram(bitmap.canvas,exportSizeX,exportSizeY,dataSets[cbStation.itemIndex+1],minTemp,maxRain div 2);
  case destination of
    edFile: if BMPSaveDialog.execute then bitmap.saveToFile(bmpSaveDialog.fileName);
    edClipboard: clipboard.assign(bitmap);
  end;
  bitmap.free;
end;

procedure TKlimaForm.btnQuitClick(Sender: TObject);
begin
  close;
end;

procedure TKlimaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  saveConfig;
  configform.free;
end;

procedure TKlimaForm.edGridSizeChange(Sender: TObject);
begin
  multGridSz:= calcMultGridSz(edGridSize.Value);
  updateDisplay;
end;

function TKlimaForm.showAridHumid:Boolean;
begin result := (cbShowAll.checked) or (cbShowAridHumid.checked) end;

function TKlimaForm.showTemp:Boolean;
begin result := (cbShowAll.checked) or (cbShowTemp.checked) end;

function TKlimaForm.showRain:Boolean;
begin result := (cbShowAll.checked) or (cbShowRain.checked) end;

function TKlimaForm.showName:Boolean;
begin result := (cbShowAll.checked) or (cbShowName.checked) end;

procedure TKlimaForm.cbShowAridHumidClick(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaForm.cbShowTempClick(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaForm.cbShowRainClick(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaForm.cbShowAllClick(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaForm.Beenden1Click(Sender: TObject);
begin
  close;
end;

procedure TKlimaForm.Oeffnen1Click(Sender: TObject);
begin
  loadData;
end;

procedure TKlimaForm.ToolButton8Click(Sender: TObject);
begin
  close;
end;

procedure TKlimaForm.PaintBoxPaint(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaForm.Konfiguration1Click(Sender: TObject);
begin
  configForm.showModal;
  numDatasetsChanged;
  with configform do begin
    exportSizeX:=myStrToInt(edExportWidth.Text);
    exportSizeY:=myStrToInt(edExportHeight.Text);
  end
end;

procedure TKlimaForm.berKlima021Click(Sender: TObject);
begin
  aboutForm.showModal;
end;

procedure TKlimaForm.cbColorClick(Sender: TObject);
begin
  updateDisplay;
end;


procedure TKlimaForm.saveConfig;
var ini:TInifile;
begin
  ini:=TInifile.Create(iniFilename);
  with ini do with configForm do begin
    writeInteger('config','dupeshandle',rgDupes.itemIndex);
    writeInteger('config','openhandle',rgOpen.itemIndex);
    writeInteger('config','exportWidth',myStrToInt(edExportWidth.Text));
    writeInteger('config','exportHeight',myStrToInt(edExportHeight.Text));
    writeBool('config','warnNotSaved',cbWarnNotSaved.checked);
    writeBool('config','Confirm modification',cbConfirmModify.checked);

    writeBool('config','Confirm delete',configForm.cbConfirmDelete.checked);
    writebool('config','Confirm add',configForm.cbConfirmAdd.checked);
    writebool('config','Open dialog',configForm.cbAutoOpen.checked);
    writeBool('config','Make Backups',configForm.cbMakeBackups.Checked);
    writeBool('config','Save unchanged files',cbSaveUnchanged.Checked);
    writeBool('config','color axis labels',cbColorLabels.checked);
    writeBool('config','solid lines', cbSolidRainLine.checked);
    writeBool('config','doExtendTemp', cbExtendTemp.checked);
    writeInteger('config','extendTemp', StrToInt(edExtendTemp.Text));
    writeBool('config','doExtendRain', cbExtendRain.checked);
    writeInteger('config','extendRain', StrToInt(edExtendRain.Text));

    writeBool('display','show Arid/Humid',cbShowAridHumid.checked);
    writeBool('display','show Temperature',cbShowTemp.checked);
    writeBool('display','show Rain',cbShowRain.checked);
    writeBool('display','show Name',cbShowName.checked);
    writeBool('display','show all',cbShowAll.checked);
    writeBool('display','use colors',cbColor.checked);

    writeInteger('display','grid',edGridSize.Value);

    writeString('font','name',FontDialog.Font.Name);
    writeInteger('font','size',FontDialog.Font.size);
    ini.free;
  end;
end;

procedure TKlimaForm.loadConfig;
var ini:TInifile;
begin
  ini:=TInifile.Create(iniFilename);
  with ini do with configform do begin
    configForm.rgDupes.itemIndex:=readInteger('config','dupeshandle',0);
    configForm.rgOpen.itemIndex:=readInteger('config','openhandle',2);

    exportSizeX:=readInteger('config','exportWidth',defaultSzX);
    exportSizeY:=readInteger('config','exportHeight',defaultSzY);

    edExportWidth.Text:=intToStr(exportSizeX);
    edExportHeight.Text:=intToStr(exportSizeY);

    configForm.cbWarnNotSaved.checked:=readBool('config','warnNotSaved',True);
    configForm.cbConfirmModify.checked:=readbool('config','Confirm modification',False);

    cbConfirmDelete.checked:=readbool('config','Confirm delete',True);
    cbConfirmAdd.checked:=readbool('config','Confirm add',False);
    cbAutoOpen.checked:=readbool('config','Open dialog',False);
    cbMakeBackups.Checked:=readBool('config','Make Backups',True);
    cbSaveUnchanged.Checked:=readBool('config','Save unchanged files',False);
    cbColorLabels.checked:=readBool('config','color axis labels',True);
    cbSolidRainLine.checked:=readBool('config','solid lines', False);

    cbExtendTemp.checked:=readBool('config','doExtendTemp', True);
    edExtendTemp.Text:=IntToStr(readInteger('config','extendTemp', -30));
    cbExtendRain.checked:=readBool('config','doExtendRain', True);
    edExtendRain.Text:=IntToStr(readInteger('config','extendRain', 500));

    cbShowAridHumid.checked:=readBool('display','show Arid/Humid',True);
    cbShowTemp.checked:=readBool('display','show Temperature',True);
    cbShowRain.checked:=readBool('display','show Rain',True);
    cbShowName.checked:=readBool('display','show Name',True);
    cbShowAll.checked:=readBool('display','show all',False);
    cbColor.checked:=readBool('display','use colors',False);

    edGridSize.Value:=readInteger('display','grid',14);

    FontDialog.Font.Name := readString('font','name','MS Sans Serif');
    FontDialog.Font.Size := readInteger('font','size',8);

    ini.free;
  end;
end;


procedure TKlimaForm.cbShowNameClick(Sender: TObject);
begin
  updateDisplay;
end;

procedure TKlimaform.process(var data:TDataSet);
var i:Integer;
    s:string;
begin
  with data do begin
    s:=name;     cut(s); name:=s;
    s:=sHeight;  cut(s); toInt(s);   sHeight:=s;
    s:=sAvgTemp; cut(s); toFloat(s); sAvgTemp:=s;
    s:=sSumRain; cut(s); toInt(s);   sSumRain:=s;
    for i:=1 to 12 do begin
      s:=sTemp[i]; cut(s); toFloat(s); sTemp[i]:=s;
      s:=sRain[i]; cut(s); toInt(s);   sRain[i]:=s;
    end;
  end;
end;

{procedure TKlimaform.extractData;
var i:Integer;
    s:String;
begin
  if dataShown then begin
    for i:=1 to 14 do begin
      s:=stringgrid.cells[1,i]; tofloat(s);  stringgrid.cells[1,i]:=s;
      s:=stringgrid.cells[2,i]; toint(s); stringgrid.cells[2,i]:=s;
    end;
    getData(dataSets[cbStation.itemIndex+1],stringGrid);
    updateDisplay;
  end;
end; }


{procedure TKlimaForm.checkModify(var key:Char);
begin
  if (key <> keyEnter) and (key <> keyTab) and (key <> keyEsc) then begin
    if (allowDataModification)
     then dataModified:=True
     else key:=keyEnter;
  end;
end; }

procedure TKlimaform.setDataModified(b:Boolean);
begin
  fDataModified:=b;
  updateStatus;
end;

function TKlimaForm.allowDataModification:Boolean;
 function askIfModify:Boolean;
 begin
   askIfModify:=(mrYes=MessageDlg('Sollen die Stationsdaten wirklich geändert werden?',mtConfirmation,[mbYes,mbNo],0))
 end;
begin
  result := (not configForm.cbConfirmModify.checked)
             or (askIfModify);
end;

procedure TKlimaForm.Button1Click(Sender: TObject);
begin
  editform.showmodal;
end;

procedure TKlimaForm.Stationeditieren1Click(Sender: TObject);
begin
  if numDatasets=0
   then  messageBox(0,'Es wurden keine Datensätze geladen.','Fehler',0)
   else //if (dataModified) or(allowDataModification) then
    editDataSet(dataSets[cbStation.itemIndex+1],True);
end;

function TKlimaForm.editDataSet(var data:TDataSet;mustConfirm:Boolean):Boolean;
var modified : Boolean;
    backup   : TDataSet;
    backupName : String;
begin
  modified:=False;
  putData(data,editform.stringgrid,False);
  backup:=data;
  if editForm.showModal = mrOk then begin
    getData(data,editform.stringgrid);
    modified := not equal(data, backup);
    if modified and (mustConfirm) and (not allowDataModification) then begin
      data:=Backup;
      modified:=False;
    end;
    if modified then with cbStation do begin
      Items[itemIndex]:=data.name;
      backupname:=data.name;
      buildStationlist;
      Itemindex:=items.indexOf(backupname);
    end;
  end;
  if modified then dataModified:=True;
  result:=modified;
end;

procedure TKlimaform.buildStationList;
var i :Integer;
    backupname : String;
begin
  checkForDupes;
//  sortDatasets; // In checkForDupes enthalten
//  backupname := cbStation.Items[cbStation.itemindex];
  cbStation.Items.Clear;
  for i:=1 to numDatasets do cbStation.Items.Add(datasets[i].name);
 // cbStation.itemIndex:=cbStation.Items.indexOf(backupName);
  if (cbStation.itemIndex < 0) and (numdatasets>0) then cbStation.itemindex:=0;
end;

function TKlimaform.equal(a,b:TDataset):Boolean;
begin result:=comparemem(@a,@b,sizeof(TDataset)) end;

procedure TKlimaform.checkForDupes;
var dupesExist:Boolean;
    pos,dest,i:Integer;
begin
  if (configform.rgDupes.itemIndex=1) or (numDatasets < 2) then exit;
  sortDatasets;
  dupesExist:=False;
  for i:=1 to numDatasets-1 do if equal(datasets[i],datasets[i+1])
   then dupesExist:=True;
  if     (dupesExist)
     and (  (configForm.rgDupes.itemIndex=0)
          or((idYes=MessageBox(0,'Doppelte Datensätze entdeckt. Überzählige Datensätze löschen?','Frage',4))))
  then begin
    pos:=1;
    dest:=1;
    repeat
      inc(pos);
      if not equal(datasets[pos],datasets[dest])
       then begin
         inc(dest);
         datasets[dest]:=datasets[pos];
       end;
    until (pos = numDatasets);
    numDatasets := dest;
  end;
end;

procedure TKlimaForm.Stationhinzufgen1Click(Sender: TObject);
begin
  if (not configForm.cbConfirmAdd.checked)
//      or dataModified
      or (idYes=MessageBox(0,'Neue Station hinzufügen?','Bestätigung',4))
  then begin
    inc(numdatasets);
    datasets[numdatasets]:=emptyDataset;
    if not editDataset(datasets[numdatasets],False) then dec(numDatasets) else begin
      dataModified := True;
      numdatasetschanged;
    end;
  end;
  updateDisplay;
end;

procedure TKlimaForm.Stationlschen1Click(Sender: TObject);
begin
  if numDatasets=0
   then  messageBox(0,'Es wurden keine Datensätze geladen.','Fehler',0)
   else if (not configForm.cbConfirmDelete.checked)
   //      or dataModified
           or(mrYes = MessageDlg('Datensatz wirklich löschen?',mtConfirmation,[mbYes,mbNo],0))
//            or (idYes=MessageBox(0,'Datensatz wirklich löschen?','Bestätigung',4))
    then begin
      dataSets[cbStation.itemIndex+1]:=datasets[numdatasets];
      dec(numdatasets);
      dataModified := True;
      sortDatasets;
      buildStationList;
      numdatasetsChanged;
    end;
end;

procedure TKlimaForm.InZwischenablagekopieren1Click(Sender: TObject);
begin
  exportGraphic(edClipboard);
end;

procedure TKlimaForm.InDateispeichern1Click(Sender: TObject);
begin
  exportGraphic(edFile);
end;

procedure TKlimaform.savedata(filename:String);
var f:TKLIFile;
    i:Integer;
    error:Boolean;
    abort : Boolean;
    bakFileName : String;
begin
  if filename='' then begin
    if not KLISaveDialog.execute
     then exit
     else filename:=KLISaveDialog.filename;
  end;
  abort := False;
  if (configForm.cbMakeBackups.Checked) and FileExists(filename)
   then begin
     bakFileName:=changeFileExt(filename,'.BAK');
     error := False;

     if fileExists(bakFilename) then begin
       try
         assignFile(f,bakfilename);
         erase(f);
       except
         on EInOuterror do error:=True;
       end
     end;
     if not error then error:=not renameFile(filename,bakFileName);
     if error then abort:=(idNo=MessageBox(0,'Backup-Datei konnte nicht angelegt werden. Trotzdem speichern?','Fehler',4));
   end;
  if abort then exit;

  assignFile(f,filename); rewrite(f);
  for i:=1 to numDatasets do write(f,datasets[i]);
  closeFile(f);
  dataModified:=False;
end;

procedure TKlimaform.genericSave;
begin
  if numDatasets=0
   then messageBox(0,'Es wurden keine Datensätze geladen.','Fehler',0)
   else begin
     if (not configForm.cbSaveUnchanged.checked) and (not dataModified) then exit;
     if (numFilesOpen = 1)
      then saveData(lastFilename)
      else executeSaveDataAsDialog;
   end;
end;

procedure TKlimaForm.Speichern1Click(Sender: TObject);
begin
  genericSave;
end;

procedure TKlimaForm.executeSaveDataAsDialog;
begin
  if numDatasets=0
   then  messageBox(0,'Es wurden keine Datensätze geladen.','Fehler',0)
   else if KLISaveDialog.execute then saveData(KLISaveDialog.filename);
end;

procedure TKlimaForm.Speichernunter1Click(Sender: TObject);
begin
  executeSaveDataAsDialog;
end;

function TKlimaForm.remindSave(msg:String):Boolean;
var answer:Integer;
    pmsg:PChar;
begin

  if    (not dataModified)
     or (numDatasets=0)
     or (not configForm.cbWarnNotSaved.checked)
  then result:=True
  else begin
    getmem(pmsg,200);   strpcopy(pmsg,msg);
//    answer:=MessageDlg(msg,mtConfirmation,[mbYes,mbNo,mbCancel],0);
    answer := MessageBox(0,pmsg,'Hinweis', MB_YESNOCANCEL + MB_ICONQUESTION);
    if answer = idYes then genericSave;
    result := (answer <> idCancel);
    freemem(pmsg,200);
  end;
end;

procedure TKlimaForm.Neu1Click(Sender: TObject);
begin
  if remindSave('Datensätze wurden geändert. Änderungen speichern?')
   then begin
     numDataSets:=0;
     numFilesOpen:=1;
     lastFilename:='';
     numDataSetsChanged;
     updateStatus;
   end;
end;

procedure TKlimaForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  canClose := remindSave('Daten wurden geändert. Änderungen speichern?');
end;

procedure TKlimaForm.Schrift1Click(Sender: TObject);
begin
  if fontDialog.Execute then begin
    drawFont := fontDialog.Font;
    updateDisplay;
  end;
end;

procedure TKlimaForm.Info1Click(Sender: TObject);
begin
  aboutform.showmodal;
end;

end.
