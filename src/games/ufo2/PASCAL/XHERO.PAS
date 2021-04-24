Program xHERO;
{Преобразует экранный файл в файл спрайтов 2х3 з.м. с маской}
uses Crt,Graph;
const
 fn2='xhero';
 frow=10;{к-во рядов}
var
 TF,ZF:File of Char;
 name,name1,name2:string;
 b:array [0..frow*48-1,0..31] of byte;
 c:char;
 n:Longint;
 aa,bb,cc,dd:byte;
 gr,modd,i,j,k,m:integer;

procedure her(fnn:string);
begin
  ClrScr;
  n:=0;
  Writeln('Конвертация экранных файлов');
  Writeln('формата TIFF');
  Writeln('в файлы спрайтов героев 2х3 для НЛО-2');

 begin name:='d:\''ufo2''\';
  name1:=Name+'images\'+fnn+'.tif';
  name2:=Name+'data\'+fnn+'.dat';
  gr:=detect;
  InitGraph(gr,modd,'d:\tp7\bgi\');

  Assign(ZF,name1);
  Reset(ZF);
  Assign(TF,name2);
  Rewrite(TF);

  for i:=0 to 193 do begin
       read(ZF,c);            {read/write Tiff prefix}
       end;

  for m:=0 to frow-1 do                       {read Tiff screen}
    for k:=0 to 47 do
        for i:=0 to 31 do
          begin
            read(ZF,c);
            b[m*48+k,i]:=ord(c) xor $ff;
            for gr:=0 to 7 do
             putpixel(i*8+gr,m*48+k,(ord(c) shr (7-gr) and 1)*14);
          end;

  Close(ZF);
  for i:=0 to frow-1 do
  begin
    for j:=0 to 15 do
    begin
      for k:=0 to 23 do
      begin
        for m:= 0 to 1 do
        begin
        bb:=b[i*48+k+24,j*2+m];
        aa:=b[i*48+k,j*2+m] xor bb;
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
  repeat until KeyPressed;
  CloseGraph;
  ReadLn;
end;

begin
 her(fn2);
end.