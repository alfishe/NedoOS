{Картинки к энциклопедии}
Program xup;
uses Crt,Graph;
const
 _n=26;
 numb:array[1..60] of byte = (
                   17,14,39,
                   15,13,18,
                   21,20,36,
                   24,40,37,
                    38,12,11,
                    16,10,9,
                    1,2,8,
                      3,19,5,
                      4,6,7,
                      33,26,22,
                      23,34,35,
                  42,46,45,
                  43,44,48,
                  47,50,49,
                   25,41,31,
                   27,30,28,
                   32,55,29,
                    51,60,57,
                    58,56,59,
                    52,53,54);

var
 TF,ZF:File of Char;
 name,name1,name2:string;
 b:array [0..191,0..31] of byte;
 c,cc:char;
 n:Longint;
 gr,modd,i,j,k,m,ix,ixx,iyy:integer;
label
     Laba;

begin
  ClrScr;
  n:=0;
  Writeln('Конвертация TIFF-файлов');
  Writeln('(Black & White  224x192)');
  Writeln('в картинки Уфопедии по три'#10#10);
  gr:=detect;
  InitGraph(gr,modd,'d:\tp7\bgi\');
for ixx:=0 to 19 do
begin
  str(ixx+1,Name);
  name2:='d:\'#39'ufo2'#39'\data\xup'+Name+'.dat';
  Assign(ZF,name2);
  rewrite(ZF);
 for iyy:=1 to 3 do begin
  str(numb[iyy+ixx*3],Name);
  name1:='d:\'#39'ufo2'#39'\images\x'+Name+'.tif';
  Assign(TF,name1);
  Reset(TF);

  for i:=1 to 194 do read(TF,c);         {read TIFF prefix}
  cc:=#0;
  for i:=0 to 191 do
    for j:=0 to 27 do                     {read & display TIFF screen}
       begin
         read (TF,c);
        { for m:=0 to 7 do putpixel(j*8+m,i,(ord(c) shr (7-m) and 1)*7);}
         mem[$a000+i*5:0000+j]:=ord(c);
         c:=chr(not ord(c));
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