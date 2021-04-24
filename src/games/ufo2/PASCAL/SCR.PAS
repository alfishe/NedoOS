Program Scr;
uses Crt,Graph;
const
  TIFprefix : string =
    #73#73#42#0#8#0#0#0#15#0#254#0#4#0#1#0#0#0#0#0#0#0#0#1#4#0
   +#1#0#0#0#0#1#0#0#1#1#4#0#1#0#0#0#192#0#0#0#2#1#3#0#1#0#0#0
   +#1#0#0#0#3#1#3#0#1#0#0#0#1#0#0#0#6#1#3#0#1#0#0#0#1#0#0#0#17
   +#1#4#0#1#0#0#0#194#0#0#0#21#1#3#0#1#0#0#0#1#0#0#0#22#1#4#0
   +#1#0#0#0#192#0#0#0#23#1#4#0#1#0#0#0#0#24#0#0#26#1#5#0#1#0#0
   +#0#194#24#0#0#27#1#5#0#1#0#0#0#202#24#0#0#28#1#3#0#1#0#0#0
   +#1#0#0#0#40#1#3#0#1#0#0#0#2#0#0#0#61#1#3#0#1#0#0#0#1#0#0#0
   +#0#0#0#0;
  TIFpostfix : string =
    #80#0#0#0#1#0#0#0#80#0#0#0#1#0#0#0;
var
 TF,ZF:File of Char;
 name,name1,name2:string;
 b:array [0..191,0..31] of byte;
 c:char;
 n:Longint;
 gr,modd,i,j,k,m:integer;

begin
  ClrScr;
  n:=0;
  Writeln('Конвертация экранного файла');
  Writeln('формата SCR');
  Writeln('в графический TIFF-файл');
  Writeln('(Black & White  256x192).');
  Write('Имя  SCR-файла : ');Readln(name);
  name1:=Name+'.scr';
  name2:='d:\'#39'slava'#39'\images\'+Name+'.tif';
  gr:=detect;
  InitGraph(gr,modd,'d:\tp7\bgi\');

  Assign(ZF,name1);
  Reset(ZF);

{  for i:=1 to 17 do read(ZF,c);            {read TR DOS prefix}

  for m:=0 to 2 do                       {read TR DOS screen}
    for k:=0 to 7 do
      for j:=0 to 7 do
        for i:=0 to 31 do
          begin
            read(ZF,c);
            b[m*64+j*8+k,i]:=ord(c);
            for gr:=0 to 7 do
             putpixel(i*8+gr,m*64+j*8+k,(ord(c) shr (7-gr) and 1 xor 1)*14);
          end;

  Close(ZF);

  Assign(TF,name2);
  Rewrite(TF);

  for i:=1 to 194 do write(TF,TIFprefix[i]);  {save TIFF prefix}

  for i:=0 to 191 do                          {save  TIFF screen}
     for j:=0 to 31 do
       begin
         c:=chr (not b[i,j]);
         write(TF,c);
       end;

  for i:=1 to 16 do write(TF,TIFpostfix[i]);  {save TIFF postfix}

  Close(TF);

  repeat until KeyPressed;
  CloseGraph;

end.