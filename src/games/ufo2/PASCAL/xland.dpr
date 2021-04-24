program xland;

{$APPTYPE CONSOLE}

uses
  SysUtils;

{Преобразует экранный файл в файл спрайтов 2х4 з.м.}
//uses Crt,Dos,Graph;
const
 Show=0;{0/1/2-не выводить/выводить/и печатать}
 Nland=22;
 fn:array [1..Nland] of string=('xm0',
                            'xm1',
                            'xm2',
                            'xm3',
                            'xm4',
                            'xm5',
                            'xm6',
                            'xm7',
                            'xm8',
                            'xm9',
                            'xm10',
                            'xm11',
                            'xm12','xm13','xm14','xm15','xm16','xm17',
                            'xm18','xm19','xm20',
                            'xmarker');
 fl:array [1..Nland] of byte=(1,    {размер fl*2048 байт}
                              3,
                              2,
                              2,
                              5,
                              5,
                              5,
                              5,
                              5,
                              5,
                              5,
                              5,
                              5,5,2,2,2,2,
                              2,2,2,
                              1);
  GrMode : byte = 5;         {0 .. 5}
  Size   : integer = 256;    {1 .. 512}
  Double : byte = 1;         {1 .. 2}
  Ins    : boolean =false;
  Column : byte = 1;         {1 .. 4}
  Row    : byte = 1;         {1 ...}

var
 TF,ZF:File of Char;
 name,name1,name2:string;
 b:array [0..(5*64-1),0..31] of byte;
 c:char;
 n:Longint;
 aa,bb,cc,dd:byte;
 gr,modd,i,j,k,m,jj:integer;
 s:string;
// R : registers;

{------------------------------}
{Procedure  Print(s : string);
var
  i:word;

begin
  for i:=1 to length(s) do
    begin
      repeat
      r.ah:=2;
      r.dx:=0;
      Intr($17,r);
      until (r.ah and $90)=$90;
      r.ah:=0;
      r.dx:=0;
      r.al:=ord(s[i]);
      Intr($17,r);
    end
end;
{---------------------}
{Function PrintLine(pos : integer) : boolean;
var
 rw,x,y,i,len :integer;
 d,b : byte;
begin
 PrintLine:=true;
 len:=Size*Column*Double;
 s:=#27'*'+chr(GrMode)+chr(len mod 256)+chr(len div 256);
 print(s);
 y:=pos*8;
 for rw:=1 to Column do
 for x:=0 to Size-1 do
  begin
   b:=0;
   for i:=0 to 7 do
     b:=b shl 1 + ( (GetPixel(x,y+i) shr 1) and 1 ) xor 1;
   for d:=1 to Double do  print(chr(b));
   if KeyPressed then
       if Readkey=#27  then
        begin
          PrintLine:=false;
          Exit;
        end;
  end;
end;
{---------------------------------------}
{Procedure Pause;
begin
  repeat until KeyPressed;
  c:=ReadKey;
  if c=#0 then c:=ReadKey;
end;
{---------------------------------------}
{Procedure PrintZXscr(endline:byte);
begin
  SetColor(Red);
  OutTextXY(20,340,'Printing ... press a key');
  Pause;
  print (#13#10);
  print(fn[n]);
  print(#13#10);
  for i:=1 to Row do
   begin
   print(#27#51#23);
   for j:=0 to endline do
    if not PrintLine(j) then
        begin
           R.AH:=1;
           R.DX:=0;
           Intr($17,R);
           Print(#13#10);
           exit;
        end
      else Print(#13#10);
   end
end;}
{---------------------------------------}
begin
//  ClrScr;
  n:=0;
  Writeln('Конвертация экранного файла');
  Writeln('формата TR DOS');
  Writeln('в файл спрайтов 2х4 для НЛО-2');
  Writeln;

 for n:=1 to Nland do begin name:='..\';
  name1:=Name+'images\'+fn[n]+'.tif';
  name2:=Name+'ZX_DISC\'+fn[n]+'.dat';
  //gr:=detect;
  {if (Show<>0) then
  InitGraph(gr,modd,'d:\tp7\bgi\')
  else} Writeln('Создан ',name2);

  Assign(ZF,name1);
  Reset(ZF);
  Assign(TF,name2);
  Rewrite(TF);

  for i:=1 to 194 do begin
       read(ZF,c);            {read TIF prefix}
       end;

  for m:=0 to fl[n]-1 do                       {read TIF screen}
    for k:=0 to 63 do
        for i:=0 to 31 do
          begin
            read(ZF,c);
            b[m*64+k,i]:=ord(c) xor $FF;
            {if(Show<>0) then
            for gr:=0 to 7 do
             putpixel(i*8+gr,m*64+k,(ord(c) shr (7-gr) and 1)*14);}
          end;

  Close(ZF);
  //if(Show=2) then printZxScr(fl[n]*8-1); {print land sprites}
  for i:=0 to fl[n]-1 do  {write DATA land sprites}
  begin
    if(n=Nland) then jj:=3 else jj:=15;
    for j:=0 to jj do
    begin
      for k:=0 to 31 do
      begin
        for m:= 0 to 1 do
        begin
        bb:=b[i*64+k+32,j*2+m];
        aa:=b[i*64+k,j*2+m] xor bb;
        c:=chr(bb);
        write(TF,c);
        c:=chr(aa);
        write(TF,c);
        end;
      end;
    end;
  end;

  Close(TF);

  end;
//  repeat until KeyPressed;
//  CloseGraph;

end.
