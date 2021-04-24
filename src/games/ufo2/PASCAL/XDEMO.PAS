Program xdemo;
uses Crt,Graph;
const
  ZXname : string = 'fromIBM C'#0#64#0#27#0#27#206#104;
var
 TF,ZF:File of Char;
 name,name1,name2:string;
 b:array [0..191,0..31] of byte;
 c,cc:char;
 n:Longint;
 gr,modd,i,j,k,m,ix,ixx:integer;
label
     Laba;

begin
  ClrScr;
  n:=0;
  Writeln('Конвертация TIFF-файлов');
  Writeln('(Black & White  128х128)');
  Writeln('в демо-файлы'#10#10);
  gr:=CGA;
  InitGraph(gr,modd,'d:\tp7\bgi\');
Laba:  for ix:=0 to 2 do begin
  str(ix,Name);
  name2:='d:\'#39'ufo2'#39'\data\xdemo'+Name+'.dat';
  Assign(ZF,name2);
  rewrite(ZF);
  for ixx:=1 to 8 do begin
  str(ixx+ix*8,Name);
  name1:='d:\'#39'ufo2'#39'\xdemo\XD'+Name+'.tif';
  Assign(TF,name1);
  Reset(TF);

  for i:=1 to 194 do read(TF,c);         {read TIFF prefix}
  cc:=#0;
  for i:=0 to 127 do
    for j:=0 to 15 do                     {read & display TIFF screen}
       begin
         read (TF,c);
         for m:=0 to 7 do putpixel(j*8+m,i,(ord(c) shr (7-m) and 1)*7);
         c:=chr(not ord(c));
         if (cc='э') and (c='э') then
                   begin
                     inc (c);
                     writeln('Warning: #ED #ED');
                   end;
         cc:=c;
         write (ZF,c);
       end;

  Close(TF);
  end;

  Close(ZF);
  end;
{  goto Laba;}
  repeat until KeyPressed;
  CloseGraph;

end.