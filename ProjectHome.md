## Intro ##

### English ###
Renders climate diagrams for use in high schools. This app was written for 32bit Windows in 1999 using Delphi 4.0. The UI is in German and not internationalized.

### Deutsch ###
Rendert Klimadiagramme fuer den Schulgebrauch.
Die Klimadiagramma koennen in eine .bmp Datei, auf den Durcker und in die Zwischenablage exportiert werden. Das Programm wurde 1999 unter Delphi 4 fuer Windows geschrieben.

### Where to download ###
Binaries may be downloaded from:

http://www.tobias-thierer.de/download.html

## Technical notes for developers ##

### Checking out Klima 0.9 for Delphi and Klima 1.0 for Lazarus ###

There are two versions of the source available for download:
  1. the original version 0.9 for Delphi 4, which I wrote in 1999
    * can be checked out from https://klima.googlecode.com/svn/trunk
  1. a port to Lazarus which I branched from the (a) in 2011
    * builds successfully under Lazarus (lazarus.freepascal.org) on 64bit Windows 7.
    * I dropped support for printing to be able to do the port
    * rendering climate diagrams and export to a .bmp file and the clipboard still works.
    * can be checked out from https://klima.googlecode.com/svn/branches/lazarus-win64

### File format (.kli) used by the application ###
This file format was chosen for compatibility with a DOS program (written in presumably Turbo Pascal by someone other than me) from the late 1980s or early 90s which produced files in the same format. This file format however is pretty limiting: It is a binary format that stores all values as byte (even decimal values such as temperature/rain). It also limits the location name to 20 characters. This legacy file format is represented in the code as the following struct:
```
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
```
Note that Strings are stored in the old Turbo Pascal format in the binary representation: Each String is preceded by a single byte indicating the length of the String, ie. the 20 bytes indicating the name are preceded by a single byte of value between 0 and 20 indicating how long the name actually is.

I don't remember what the Byte does which I called "One", but if it actually always has the value 1 then that might indicate that the original DOS program was storing the continent as a `String[1]` that always had length 1.