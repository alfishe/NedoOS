program mkspr;

{$APPTYPE CONSOLE}

uses
  SysUtils, Graphics;

const
 bmphgt=4096;
 sprhgt=16;
 sprwid=16;
  maxhgt=1024;
  maxwid=1024;

var
 xbase,ybase,sprnr,curaddr,spraddr,sprpg,filenr:integer;
 bshift,bhgt:longword;
 bmp:array[0..bmphgt-1,0..255] of byte;
 tspraddr:array[0..255,0..2] of byte;
 foutbuf:array[0..16384] of byte;
 foutbufpos:integer;
 filename:string;
  dump: array [0..1048575]of byte;
  pic: array [0..(maxhgt-1),0..(maxwid-1)] of byte; //картинка [Y,X]
  pal: array [0..255] of byte;
  zeros: array [0..255] of byte;
  img1,imgresult: TBitMap;
  bmtex, bmbg: TBitMap;
  fin,fout: file of byte;
  frame:integer;
 pg,pgplane,i,j,picdisp,paldisp,addr,hgt,wid,x,y:integer;
 b,br,bg,bb:byte;
 plane:integer;

function atmcol(left,right:byte):byte;
begin //rlrrrlll
 atmcol:=(right and $08)shl 4 +
         (left and $08)shl 3 +
         (right and $07)shl 3 +
         (left and $07);
end;

procedure foutflush;
begin
      //sprites are listed as 0..254(255=exit) and accessed via table as 1..255
      //(inc e:ret z:ld a,(de)...)
      //thus, sprnr+1
  tspraddr[sprnr+1,0]:=spraddr and $ff;
  tspraddr[sprnr+1,1]:=(spraddr and $ff00)shr 8;
  tspraddr[sprnr+1,2]:=sprpg; //pg
  BlockWrite(fout,foutbuf,foutbufpos);
  foutbufpos:=0;
end;

procedure wrbyte(b:byte);
begin
  //BlockWrite(fout,b,1);
  foutbuf[foutbufpos]:=b;
  inc(foutbufpos);
  inc(curaddr);
end;

function sprisempty:boolean;
var
 isempty:boolean;
 x,y:integer;
begin
 isempty:=true;
 x:=xbase;
 while x<(xbase+sprwid) do
 begin
   y:=ybase;
   while y<(ybase+sprhgt) do
   begin
    if (bmp[y,x]<>16) //transparent_color
    then isempty:=false;
    inc(y);
   end;
   inc(x);
 end;
 sprisempty:=isempty;
end;

procedure mksprite(xbase,ybase,sprwid,sprhgt:integer);
var
 x,y:integer;
 mask,pixel:byte;
 curscraddr,oldscraddr,scraddrdelta,oldde:integer;

  function colisempty(col1,col2:byte):boolean;
  begin
   if (col1=16) and (col2=16) //transparent_color
   then colisempty:=true
   else colisempty:=false;
  end;

  function coltopixel(col1,col2:byte):byte;
  begin //transparent_color and $0f = 0!!!
   coltopixel:=(col1 and $08)shl 3 + (col1 and $07) + (col2 and $08)shl 4 + (col2 and $07)shl 3;
  end;

  function coltomask(col1,col2:byte):byte;
  var
   mask:byte;
  begin
   if col1=$10 then mask:=$47 else mask:=0;
   if col2=$10 then mask:=mask or $b8;
   coltomask:=mask;
  end;

begin
  x:=xbase+6;
  oldde:=65536; //false value
  while x>=xbase do //4 layers
  begin //start of the layer
    wrbyte(225); //pop hl
    oldscraddr:=0;
    curscraddr:=0;
    while x<(xbase+sprwid) do //layer columns
    begin
     for y:=ybase to ybase+15 do
     begin
      scraddrdelta:=curscraddr-oldscraddr;
      if not colisempty(bmp[y,x],bmp[y,x+1])
      then begin
        if (scraddrdelta<>0)
        then
          if (scraddrdelta<>40)
          then begin
           if (scraddrdelta<>oldde)
           then begin
             if (oldde<>65536) and ((scraddrdelta and $ff00)=(oldde and $ff00))
             then begin //ld e,N
               wrbyte(30); //ld e,N
               wrbyte(scraddrdelta and $ff);
             end
             else begin //ld de,N
               wrbyte(17); //ld de,N
               wrbyte(scraddrdelta and $ff);
               wrbyte((scraddrdelta and $ff00)shr 8);
             end;
             oldde:=scraddrdelta;
           end;
           wrbyte(25); //add hl,de
          end
          else begin //scraddrdelta=40
           wrbyte(9); //add hl,bc
          end;
        oldscraddr:=curscraddr;
        mask:=coltomask(bmp[y,x],bmp[y,x+1]);
        pixel:=coltopixel(bmp[y,x],bmp[y,x+1]);
        if (mask=0)
        then begin
          if (pixel=0)
          then wrbyte(112) //ld (hl),b
          else begin
            wrbyte(54); //ld (hl),N
            wrbyte(pixel);
          end;
        end
        else begin //mask<>0
          wrbyte(126); //ld a,(hl)
          wrbyte(230); //and N
          wrbyte(mask);
          if (pixel<>0)
          then begin
            wrbyte(246); //or N
            wrbyte(pixel);
          end;
          wrbyte(119); //ld (hl),a
        end;
      end; //nonempty
      curscraddr:=curscraddr+40;
     end; //y
     curscraddr:=curscraddr-(40*sprhgt)+1;
     inc(x,8);
    end; //x in layer
    x:=x-sprwid-2;
  end; //layers
  wrbyte($fd); //$fd
  wrbyte(233); //jp (iy)
end;

begin
  if paramcount<1
  then filename:='pic.bmp'
  else filename:=ParamStr(1);
  AssignFile(fin,filename); //256c 256x256
  Reset(fin);
  if(filesize(fin)=0)then Halt(1);
  writeln('input file=',filename);

  img1:=TBitMap.Create;
  img1.Height:=448;
  img1.Width:=320;
  img1.PixelFormat:=pf24bit;
  //bmtex:=TBitMap.Create;
//  bmtex.Height:=256;
//  bmtex.Width:=256;
  //bmtex.LoadFromFile(fn);
//  bmtex.PixelFormat:=pf24bit;
  //Image2.Picture.Assign(bmtex);

  BlockRead(fin,dump,FileSize(fin));
  CloseFile(fin);

  for i:=0 to 255 do zeros[i]:=0;

  picdisp:=dump[10] + dump[11] shl 8 + dump[12] shl 16 + dump[12] shl 24;
  paldisp:=dump[14] + dump[15] shl 8 + dump[16] shl 16 + dump[17] shl 24 + 14;
  wid:=dump[18] + dump[19] shl 8 + dump[20] shl 16 + dump[21] shl 24;
  hgt:=dump[22] + dump[23] shl 8 + dump[24] shl 16 + dump[25] shl 24;

//get pal
  addr:=paldisp;
  for i:=0 to 255 do begin
   bb:=dump[addr] and $c0;
   bg:=dump[addr+1] and $c0;
   br:=dump[addr+2] and $c0;
   b:=$ff;
   if (bb >= $80) then b:=b-$01;
   if (br >= $80) then b:=b-$02;
   if (bg >= $80) then b:=b-$10;
   if (bb and $40)>0 then b:=b-$20;
   if (br and $40)>0 then b:=b-$40;
   if (bg and $40)>0 then b:=b-$80;
   pal[i]:=b;
   inc(addr,4)
  end;

//4bpp
//get pic [Y,X]
  addr:=picdisp;
  for i:=0 to hgt-1 do begin
   y:=hgt-1-i;
   for j:=0 to (wid div 2)-1 do begin
    x:=j*2;
    pic[y,x]:=dump[addr] shr 4;
    pic[y,x+1]:=dump[addr] and $0f;
    inc(addr);
   end;
  end;

  for pg:=0 to 1 do begin
  AssignFile(fout,IntToStr(pg)+filename+'x');
  Rewrite(fout);
  for pgplane:=0 to 1 do begin
  plane:=pgplane*2+pg;
  for i:=0 to hgt-1 do begin
   for j:=0 to (wid div 8)-1 do begin
    x:=j*8+2*plane{0/2/4/6};
    b:=atmcol(pic[i,x],pic[i,x+1]);
    BlockWrite(fout,b,1);
   end;
  end;
  if pgplane=0
  then begin
   BlockWrite(fout,pal,16);
   BlockWrite(fout,zeros,192-16)
  end //if 0
  else BlockWrite(fout,zeros,192-16);
  end; //pgplane
  CloseFile(fout);
  end; //pg

end.
