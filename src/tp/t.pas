Program t;
type
  Attributes = (Constant,Formula,Txt,OverWritten,Locked,Calculated);
var
  bb: Boolean;
  i: Integer;
begin
  bb := (Txt in [Txt]);
  for i:=1 to 10 do begin
    WriteLn('Hello ',i);
  end;
end.
