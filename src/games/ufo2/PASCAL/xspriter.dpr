program xspriter;

{$APPTYPE CONSOLE}

uses
  SysUtils;

{Преобразует TIFF-файлы оформления НЛО-2 в файл спрайтов }
//uses Crt,Graph;
const
 Nblock=8;
 fn:array [1..Nblock] of string=('xearth',
                            'xweapon',
                            'xbutton',
                            'xsign',
                            'xparam',
                            'xkey',
                            'xlabel',
                            'xSCAN'
                            );
 fl:array [1..Nblock,1..2] of byte=((24,15),    {размер X*Y*8 байт}
                                 (4,2*15),
                                 (4,4+3+4),
                                 (3,3*12),
                                 (3,2*10),
                                 (12,6+2),
                                 (2,2*26),
                                 (1,12)
                                );
var
 TF,ZF:File of Char;
 name,name1,name2:string;
 fln:array[1..Nblock] of integer;
 b:array [0..(5*64-1),0..31] of byte;
 c:char;
 n:Longint;
 aa,bb,cc,dd:byte;
 gr,modd,i,j,k,m,jj:integer;
 x,y:integer;

begin
  //ClrScr;
  n:=0;
  Writeln('Конвертация TIFF-файлoв');
  Writeln('игрового оформления НЛО-2');
  Writeln('в eдиный файл спрайтов ');
  Name:='..\';
  name2:=Name+'data\xsprites.dat';
  Assign(TF,name2);
  Rewrite(TF);
  jj:=0;
//  gr:=detect;
//  InitGraph(gr,modd,'d:\tp7\bgi\');

 for n:=1 to Nblock do begin
  name1:=Name+'images\'+fn[n]+'.tif';
  Assign(ZF,name1);
//  ClearViewPort;
  Reset(ZF);
  x:=fl[n,1];
  y:=fl[n,2];
  fln[n]:=jj;
  jj:=jj+x*y*8;

  for i:=1 to 194 do begin
       read(ZF,c);            {read TIF prefix}
       end;

  for m:=0 to (y)*8-1 do                       {read TIF screen}
        for i:=0 to x-1 do
          begin
            read(ZF,c);
            {for gr:=0 to 7 do
             putpixel(i*8+gr,m,(ord(c) shr (7-gr) and 1)*14);}
            c:=chr(ord(c) xor $FF);
            write(TF,c);
          end;
  Close(ZF);
  end;
  Close(TF);
//  CloseGraph;
//  ClrScr;
  for i:=1 to Nblock do
   writeln('Блок графики ',fn[i],' c адреса ',fln[i]);
  writeln('Cледующий адрес ',jj);
  //repeat until KeyPressed;

end.
