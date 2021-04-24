Program utrkseq;
{(c) Медноногов В.С. 1996}
var
 tf:text;
 be,en,i,j,k,l:longint;
 name,s1,s2,s3,s4,hex:string;

function hexa(i:longint):string;
const
 dig:string='0123456789ABCDEF';
var
 j,k,l:integer;
 hx:string;
begin
  if i=0 then begin hexa:=dig[1];exit;end;
  hx:='';
  while i>0 do
    begin
     k:=i mod 16 +1;
     i:=i div 16;
     hx:=dig[k]+hx;
    end;
  hexa:=hx;
end;

{-------------------}
{
        Формат диска 1 (720)
        80 дорожек по 512
        t0-0
        t1-0
        9,9,9,9 (по 1024)
        остальные
        F5,F6,F7,F8,F9,FA,FB,FC,FD
        Верхняя сторона дублирует нижнюю

        Данные:
         1024 загрузчик
         далее - файлы, выровненые на границу сектора
}
begin
writeln;
writeln('НЛО-2. Дьяволы бездны');
writeln;
writeln('Cоздание описателей дорожек диска 1 для  FDA');
for i:=0 to 79 do
for j:=0 to 1 do
begin
str(i,s1);
str(j,s2);
name:='d:\''ufo2''\xd1\trk'+s1+'-'+s2+'.seq';
assign(tf,name);
rewrite(tf);
{format}
writeln(tf,';Xcom track sequence for disk1 (c) 1996');
writeln(tf,';');
writeln(tf,' Double:');
if (i=0) then
  begin
    writeln(tf,'F 4 3 112 244');
    en:=3;
  end
else
  begin
    writeln(tf,'F 9 2 112 244');
    en:=8;
  end;
be:=$F5;
for k:=be to be+en do
   if (i=0) then writeln (tf,' 0 ',s2,' 9 3')
     else
        begin
        str(k,s3);
        writeln(tf,' ',s1,' ',s2,' ',s3,' 2');
        end;
{data}
hex:=hexa(512*9*(i-1)+1024)+'H';
if (i<>0) then
  writeln(tf,'W ',s1,' ',s2,' ',be,' 2 N ',hex,' 4608 255 255 27')
else
   for k:=0 to en do
     begin
      writeln(tf,'W 0 ',s2,' 9 3 N 0H 1024 255 255 27');
     end;
writeln(tf,'END');
close(tf);
end;
{-------------------}
{
        Формат диска 2 (800)
        80 дорожек
        t0-0
        9  [1024]
        t1-0..t1-15
        10,11,12,13,14,15,16,17,18 (hex)
        t0-1..t0-3  [256]
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 (dec)
        t1-16..t1-79
        t0-4..t0-79
        F4,F5,F6,F7,F8  [1024]
        Верхняя сторона с t1-16 дублирует t0-4

        Даные:
          1024 - загрузчик
          далее - файлы
}

writeln('Cоздание описателей дорожек диска 2 для  FDA');
for i:=0 to 79 do
for j:=0 to 1 do
begin
str(i,s1);
str(j,s2);
name:='d:\''ufo2''\xd2\trk'+s1+'-'+s2+'.seq';
assign(tf,name);
rewrite(tf);
{format2}
writeln(tf,';');
writeln(tf,';Xcom track sequence for data disk2 (c) 1996');
writeln(tf,';         Автор Вячеслав Медоногов');
writeln(tf,';');
writeln(tf,'   Double:');
if (j=1) and (i<16) then
  begin
    case i of
    0,9 : writeln(tf,'F 9 2 112 240');
    1,11: writeln(tf,'F 9 2 80 246');
    2,14: writeln(tf,'F 9 2 99 101');
    3,15: writeln(tf,'F 9 2 63 222');
    4,8 : writeln(tf,'F 9 2 91 060');
    5,13: writeln(tf,'F 9 2 105 245');
    6,12: writeln(tf,'F 9 2 68 250');
    7,10: writeln(tf,'F 9 2 114 030')
     else writeln('error');
    end;
    be:=$10;
    en:=be+8;
    s4:='2';
  end;
if ((j=0) and (i>=4)) or ((j=1) and (i>=16)) then
  begin
    writeln(tf,'F 5 3 111 246');
    be:=$F4;
    en:=be+4;
    s4:='3';
  end;
if (j=0) and (i>0) and (i<4) then
  begin
    writeln(tf,'F 16 1 50 246');
    be:=1;
    en:=be+15;
    s4:='1';
  end;
if (i=0) and (j=0) then
  begin
    writeln(tf,'F 2 3 112 246');
    be:=9;
    en:=be+1;
    s4:='3';
  end;

for k:=be to en do
      begin
        str(k,s3);
        writeln(tf,' ',s1,' ',s2,' ',s3,' ',s4);
      end;
{data2}
if (j=0) and (i=0) then
    writeln(tf,'W ',s1,' ',s2,' ',be,' ',s4,' N 0H 1024 255 255 27');
if (j=0) and (i>=4) and (i<70) then
  begin
    hex:=hexa(512*10*(i-4)+1024)+'H';
    writeln(tf,'W ',s1,' ',s2,' ',be,' ',s4,' N ',hex,' 5120 255 255 27');
  end;
if (j=1) and (i>=16) then
  begin
    hex:=hexa(512*10*(i-16)+1024)+'H';
    writeln(tf,'W ',s1,' ',s2,' ',be,' ',s4,' N ',hex,' 5120 255 255 27');
  end;
writeln(tf,'END');
close(tf);
end;
end.