Program UfoBookScreen;
uses Crt,Dos,Graph;
type
  Data = string[25];
const
  Max=59;
  N : word = 94;
  current : byte = 1;
  Path : string = 'D:\SPECTRUM\NAKL-60\';
  GrMode : byte = 1;         {0 .. 5}
  Size   : integer = 249;    {1 .. 512}
  Double : byte = 1;         {1 .. 2}
  Ins    : boolean =false;
  Column : byte = 1;         {1 .. 4}
  Row    : byte = 1;         {1 ...}
var
  Sc : array [0..31,0..191] of byte;
  Num : array [0..9] of pointer;
  Sym : array [1..10] of pointer;
  i,j,k : integer;
  F : Text;
  FName,s: string;
  c : char;
  R : registers;
{---------------------------------------}
Procedure  Print(s : string);
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
{---------------------------------------}
Procedure GetZXscr;
begin
  Assign(F,FName);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult<>0 then begin SetTextStyle(1,0,5);
                            for i:=0 to 31 do for j:=0 to 191 do
                                 Sc[i,j]:=$AA;
                            OutTextXY(20,320,'File Absent');
                            FName:=Path+'Compact.$c';
                            n:=94;
                            exit;
                          end;
  for i:=1 to 17 do begin Read(F,c);end;
  for k:=0 to 6143 do
    begin
      Read(F,c);
      i:=k mod 32;
      j:=k mod 2048;
      j:=j div 256 + j mod 256 div 32 * 8 + (k - j) div 32;
      Sc[i,j]:=ord(c);
    end;
  close(f);
end;
{---------------------------------------}
Procedure Pause;
begin
  repeat until KeyPressed;
  c:=ReadKey;
  if c=#0 then c:=ReadKey;
end;
{---------------------------------------}
Function InputStr(mess:string):string;
var nx:byte;
begin
  while Keypressed do ReadKey;
  SetFillStyle(1,Black);
  OutTextXY(1,250,mess);
  s:='';
  nx:=0;
  repeat
  OutTextXY(1,290,'>'+s);
  Pause;
  case c of
   ' '..#126: if nx < 40 then
                          begin
                            s:=s+c;
                            nx:=nx+1;
                          end;
   #13:begin InputStr:=s; exit; end;
   #0:ReadKey;
   #08:if nx > 0 then
                          begin
                            Delete(s,length(s),1);
                            nx:=nx-1;
                            Bar(1,290,800,330);
                          end;
  end;
  until false;
end;
{---------------------------------------}
Procedure GetFName;
var
  nn : integer;
  name:string[8];
begin
  SetColor(Green);
  SetBkColor(Black);
  if ins then
    begin
      name:=InputStr('Input Cassette Number:');
      val(name,nn,i);
      if i<>0 then exit;
      n:=nn;
      str(n,name);
      name:=name+'-60';
    end
  else
    begin
     name:=InputStr('Input ZX Screen Name:');
     if name='' then exit;

    end;
  FName:=Path+name+'.$C';
end;
{---------------------------------------}
Procedure OpenGr;
begin
  j:=detect;
  i:=1;
  InitGraph(j,i,'D:\TP7\BGI');
  if GraphResult <> grOk then begin writeln('Graph Mode Error');Halt(1);end;
  SetColor(LightGray);
end;
{---------------------------------------}
Procedure CloseGr;
begin CloseGraph end;
{---------------------------------------}
Procedure ViewZXscr(x:word);
var m:byte;
begin
 for i:=0 to 191 do
  begin
  SetColor(Red);
  Line(x+0,i+2,x+255,i+2);
  for j:=0 to 31 do
   begin
   m:=Sc[j,i];
   for k:=0 to 7 do
      begin
      PutPixel(x+j*8+k,i,(1-(128 and m) div 128)*LightGray);
      m:=m shl 1
     end;
   end;
  end;
end;
{---------------------------------------}

Function PrintLine(pos : integer) : boolean;
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
     b:=b shl 1 + ( GetPixel(x,y+i) and 1 ) xor 1;
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
Procedure PrintZXscr;
var
  endline:byte;
begin
  endline:=23;
  if Ins then endline:=26;
  SetColor(Red);
  OutTextXY(20,280,'Printing...');
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
end;
{---------------------------------------}
Procedure Setup;
begin
 ClrScr;
 TextColor(Yellow);
 GoToXY(5,5);WriteLn('MultiPRINT v4.0   (c) 1993,94  Mednonogov bros.');
 GoToXY(1,10);
 TextColor(Cyan);
 Write('Раздел экранных файлов (',Path,'): ');Readln(s);
 if s<>'' then Path:=s;
 Write('Использовать боковую вставку [Y/n]? ');Readln(s);
 if (s='n') or (s='N') then Ins:=false else Ins:=true;
 Write('Ширина картинки (',Size,'): ');Readln(s);
 if s<>'' then Val(s,Size,i);
 Write('Графический режим (',GrMode,'): ');Readln(s);
 if s<>'' then Val(s,GrMode,i);
 case GrMode of
  1,2: Double:=2;
  3  : Double:=4;
  else Double:=1;
 end
end;
{---------------------------------------}
Procedure ClrZXscr;
begin
  SetFillStyle(1,Black);
  Bar(0,0,520,217);
end;
{---------------------------------------}
Procedure CCat;
label
  Bye;
const
      us:array [0..23] of string=('b1','b2','b3','b4',
                                  'b5','b6','b7','b8',
                                  'b9','b10','b11','b12',
                                  'b13','b14','b15','b16',
                                  'ng','nh','ni','nj',
                                  'nk1','nk2','nk3','nk4');
var
  oldDouble,OldGrMode,oldSize,page,sc,i,j,k,mm:integer;
  oldIns,void:boolean;
  name: string;
  ns:array[0..1] of string;
begin
  oldSize:=Size;
  oldIns:=Ins;
  oldDouble:=Double;
  oldGrMode:=GrMode;
  Size:=512;
  Ins:=False;
  Double:=1;
  GrMode:=5;
  sc:=0;
      for mm:=0 to 2 do
      begin
      ClrZXscr;
      for i:=0 to 3 do
       begin
        for j:=0 to 1 do
        begin
          Fname:=us[sc]+'.$c';
          sc:=sc+1;
          GetZXscr;
          ViewZXscr(j*256);
        end;
        print(#27#51#23);
        for j:=0 to 23 do
         begin
            void:=not PrintLine(j);
            print(#13);
            if void or not PrintLine(j)  then
             begin
               R.AH:=1;
               R.DX:=0;
               Intr($17,R);
               Print(#13#10);
               goto Bye;
             end
            else Print(#13#10);
         end;
       end;
       ClrZXscr;
       SetColor(Yellow);
       OutTextXY(20,40,'End of page ');
       Pause;
       if c=#27 then begin ClrZXscr; goto Bye end;
    end;
Bye: ClrZXscr;
   OutTextXY(20,100,'End of book graphics!');
   Pause;
   ClrZXscr;
   Size:=oldSize;
   Ins:=oldIns;
   GrMode:=oldGrMode;
   Double:=oldDouble;
end;
{---------------------------------------}
Procedure Single ;
label
     Bye;
const
      us:array [0..3] of string=('nb','n1','n5','n4');
var
  oldDouble,OldGrMode,oldSize,page,sc,i,j,k,mm:integer;
  oldIns,void:boolean;
  name: string;
  ns:array[0..1] of string;
begin
  oldSize:=Size;
  oldIns:=Ins;
  oldDouble:=Double;
  oldGrMode:=GrMode;
  Size:=512;
  Ins:=False;
  Double:=1;
  GrMode:=5;
  sc:=0;
      for i:=0 to 1 do
       begin
        for j:=0 to 1 do
        begin
          Fname:=us[sc]+'.$c';
          sc:=sc+1;
          GetZXscr;
          ViewZXscr(j*256);
        end;
        print(#27#51#23);
        for j:=0 to 23 do
         begin
            void:=not PrintLine(j);
            print(#13);
            if void or not PrintLine(j)  then
             begin
               R.AH:=1;
               R.DX:=0;
               Intr($17,R);
               Print(#13#10);
               goto Bye;
             end
            else Print(#13#10);
         end;
       end;
BYE: ClrZXscr;
   OutTextXY(20,100,'End of Single graphics!');
   Pause;
   ClrZXscr;
   Size:=oldSize;
   Ins:=oldIns;
   GrMode:=oldGrMode;
   Double:=oldDouble;
end;
{---------------------------------------}

Procedure MainMenu;
begin
  repeat
  SetFillStyle(1,Black);
  Bar (1,216,500,380);
  SetColor(LightGray);
  SetTextStyle(1,0,4);
  OutTextXY(02,390,'Print  graphics for');
  OutTextXY(02,420,'UFO book (press B or 1)');
  Pause;
  case c of
  #0:Readkey;
  'B','b':CCat;
  '1':single;
  #27,'Q','q':begin CloseGr; Halt(0); end;
  end;
  until false;
end;
{---------------------------------------}
begin
{  SetUp;}
  OpenGr;
  MainMenu;
end.