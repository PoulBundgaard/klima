unit utool;

{$MODE Delphi}

interface

const versionTag = 'Klima 1.0';

function isInt(s:String):Boolean;

implementation    


function isInt(s:String):Boolean;
var i,code:Integer;
begin
  val(s,i,code);
  result:=(code=0);
{$hints off}
end;
{$hints on}


end.
