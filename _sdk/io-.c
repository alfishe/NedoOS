#include "../_sdk/io.h"
#include "../_sdk/str.h"

STRUCT FCB{
  CHAR mode; //0 = free, 'r' = read, 'w' = write
//copy of TR-DOS descriptor
  CHAR fn;
  CHAR fn1;
  CHAR fn2;
  CHAR fn3;
  CHAR fn4;
  CHAR fn5;
  CHAR fn6;
  CHAR fn7;
  CHAR ext;
  BYTE block; //cur block for write, next block for read (start LSB)
  BYTE blockpad; // (start HSB)
  BYTE lastlenLSB; BYTE lastlenHSB; //length of block in bytes //TODO выравнивание!!!
  BYTE secinblk; //sectors remained in block (for read), block size (for write)
  BYTE firstsectorLSB; BYTE firstsectorHSB; //first sector of block (for write) //TODO выравнивание!!!
//end of TR-DOS descriptor
  BYTE cursectorLSB; BYTE cursectorHSB; //cur sector for write, next sector for read //TODO выравнивание!!!
  BYTE remain; //remaining bytes in buf (for read)
  BYTE secwritten; //sectors written (for write)
  BYTE descpos; //position of descriptor (for write) 0..127
  //BYTE buf; //256 bytes padded
};

/**
_fin
	EXPORT _fin
	DW 0
_fout
	EXPORT _fout
	DW 0
_waseof
	EXPORT _waseof
	DB 0

FCB1=0x4800 ;aligned ;len=0x0200
DOSBUF=0xff00 ;aligned
*/
EXPORT VAR PBYTE _fin;
EXPORT VAR PBYTE _fout;
EXPORT VAR BOOL _waseof;
CONST PBYTE FCB1; // = 0x4800; //aligned ;len=0x0200
//#define FCB1 (PBYTE)(0x4800) /**aligned, len = 0x0200 every FCB*/
CONST PBYTE DOSBUF; // = 0xff00; //aligned
//#define DOSBUF (PBYTE)(0xff00) /**aligned*/

#define DOSBUFfreesectorsLSB (PBYTE)(DOSBUF+0x00e5)
#define DOSBUFfreesectorsHSB (PBYTE)(DOSBUF+0x00e6)
#define DOSBUFfiles (PBYTE)(DOSBUF+0x00e4)
#define DOSBUFfreesectorLSB (PBYTE)(DOSBUF+0x00e1)
#define DOSBUFfreesectorHSB (PBYTE)(DOSBUF+0x00e2)

/**
findlastslash
findlastslash.A.=$+1
	ld hl,0
;hl = poi to filename in string
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
nfopenfnslashq.
	ex de,hl
;hl = after last slash
	ret
*/
EXPORT FUNC PCHAR findlastslash(PCHAR s)
{
VAR PCHAR slast;
VAR CHAR c;
  loopslash:
    slast = s;
  loop:
    c = *(PCHAR)s;
    INC s;
    IF (c == '\0') goto quit;
    IF (c == '/') goto loopslash;
    goto loop;
  quit:
RETURN slast;
}

/**
nfopen
;todo проверять наличие файла при открытии на чтение
	EXPORT nfopen
	xor a
	ld hl,FCB1-0x0200

	inc h
	inc h
	cp [hl]
	jr nz,$-3

;nfopenFCB
nfopen.B.=$+1
	EXPORT nfopen.B.
	ld a,[0] ;poi to mode ("wb"/"rb")
	ld [hl],a ;mode in FCB
	inc hl ;poi to fn in FCB
	push hl ;poi to fn in FCB
	ld d,h
	ld e,l
	inc de
	ld [hl],' '
	ld bc,8
	ldir ;empty filename
nfopen.A.=$+1
	EXPORT nfopen.A.
	ld hl,0 ;poi to filename in string
	ld [findlastslash.A.],hl
	call findlastslash
	ex de,hl
;de = after last slash
	pop hl ;poi to fn in FCB
	ld b,9
nfopenfn0.
	ld a,[de]
	or a
	jr z,nfopenfnq. ;no extension in string
	inc de
	cp '.'
	jr z,nfopenfndot.
	ld [hl],a
	inc hl
	djnz nfopenfn0.
;9 bytes in filename, no dot (9th byte goes to extension)
	jr nfopenfnq.
nfopenfndot.
	inc hl
	djnz $-1 ;hl points to extension in FCB
	dec hl
	ld a,[de] ;extension in string
	ld [hl],a ;extension in FCB
nfopenfnq.
	xor a
	ld l,FCB.block
	ld [hl],a;0 ;cur block for write, next block for read
	inc hl
	ld [hl],0x60 ;(padding for "start")
	inc hl
	ld [hl],a;0 ;lastlen LSB ;???
	inc hl
	ld [hl],a;0 ;lastlen HSB ;???
	inc hl
	ld [hl],a;0 ;sectors remained in block (for read), block size (for write)
	ld l,FCB.remain
	ld [hl],0xff ;remain (0xff = no data) for read
	inc hl
	ld [hl],a;0 ;sectors written (for write)
	ld l,a;0;FCB.mode
	ret ;hl = poi to FCB
*/
EXPORT FUNC PBYTE nfopen(PCHAR filename, PCHAR pmode)
{
VAR FCB* pfcb = (FCB*)((UINT)FCB1 - 0x0200);
VAR BYTE i = 0x09;
VAR CHAR c;
VAR PBYTE pdesc;
  REPEAT {
    pfcb = (FCB*)((UINT)pfcb + 0x0200);
  }UNTIL (*(PBYTE)pfcb == 0x00); //first free FCB
  pfcb->mode = *(PCHAR)pmode;
  pdesc = (PBYTE)&(pfcb->fn); //poi to fn in FCB
  memcopy((PBYTE)"         ", 9, pdesc); //from, len, to
  filename = findlastslash(filename); //after last slash
  REPEAT {
    c = *(PCHAR)filename;
    IF (c == '\0') goto nfopenfnq; //no extension in string
    INC filename;
    IF (c == '.') goto nfopenfndot;
    POKE *(PCHAR)(pdesc) = c;
    INC pdesc;
    DEC i;
  }UNTIL (i == 0x00);
//9 bytes in filename, no dot (9th byte goes to extension)
  goto nfopenfnq;
nfopenfndot:
  pfcb->ext = *(PCHAR)filename;
nfopenfnq:
  pfcb->block = 0x00; //cur block for write, next block for read
  pfcb->blockpad = 0x60; //padding for "start"
  pfcb->lastlenLSB = 0x00;
  pfcb->lastlenHSB = 0x00;
  pfcb->secinblk = 0x00; //sectors remained in block (for read), block size (for write)
  pfcb->remain = 0xff; //remain (0xff = no data) for read
  pfcb->secwritten = 0x00; //sectors written (for write)
RETURN (PBYTE)pfcb;
}

/**
topenwr.
	db "wb"
	db 0

openwrite
	EXPORT openwrite
	ld hl,topenwr.
	ld [nfopen.B.],hl
openwrite.A.=$+1
	EXPORT openwrite.A.
	ld hl,0 ;filename
	ld [nfopen.A.],hl
	jp nfopen

*/
EXPORT FUNC PBYTE openwrite(PCHAR s)
{
RETURN nfopen(s, "wb");
}

/**
flushdesc
flushdesc.A.=$+1
	ld hl,0
	push hl ;poi to FCB
	ld l,FCB.descpos
	ld l,[hl]
	ld d,0 ;track of descriptor
	ld h,d;0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,h ;sector of descriptor
	ld h,DOSBUF.>>8
	push hl ;hl = poi to descriptor
	push de ;track,sector of descriptor
	call rdsecDOSBUF.
	pop bc ;track,sector of descriptor
	pop de ;poi to descriptor
	pop hl ;poi to FCB
	ld l,FCB.fn
	push bc ;track,sector of descriptor
	ld bc,16
	ldir
	pop de ;track,sector of descriptor
	ld hl,DOSBUF.
	call wrsec.
	ret
*/
//write descriptor
//if created or finished
PROC flushdesc(FCB* pfcb)
{
VAR UINT trsec = (UINT)((pfcb->descpos)>>0x04);
VAR PBYTE pdesc = (PBYTE)((UINT)DOSBUF + (UINT)((pfcb->descpos)<<0x04));
  readsectors(DOSBUF, trsec, 0x01);
//  memcopy(/**from*/(PBYTE)&(pfcb->fn)/**(PBYTE)((UINT)pfcb+1)*/, 16, /**to*/pdesc); //содержимое структуры зависит от порядка байтов в слове и размера UINT!!!
  memcopy((PBYTE)&(pfcb->fn), 11, pdesc); //from,len,to
  pdesc = &pdesc[11];
  POKE *(PBYTE)(pdesc) = pfcb->lastlenLSB;
  INC pdesc;
  POKE *(PBYTE)(pdesc) = pfcb->lastlenHSB;
  INC pdesc;
  POKE *(PBYTE)(pdesc) = pfcb->secinblk;
  INC pdesc;
  POKE *(PBYTE)(pdesc) = pfcb->firstsectorLSB;
  INC pdesc;
  POKE *(PBYTE)(pdesc) = pfcb->firstsectorHSB;
  writesectors(DOSBUF, trsec, 0x01);
}

/**
flushwritebuf
flushwritebuf.A.=$+1
	ld hl,0
;write buf
	ld l,FCB.cursector
	push hl ;poi to cursector
	ld e,[hl]
	inc hl
	ld d,[hl]
	ld l,0
	inc h ;poi to buf
	call wrsec.
	ex de,hl ;ld de,(0x5cf4) ;de=next sector
	pop hl ;poi to cursector
	ld [hl],e
	inc hl
	ld [hl],d
;increase secwritten
;get new block if this block filled up
	ld l,FCB.secinblk
	ld a,[hl]
	ld l,FCB.secwritten
	inc [hl]
	sub [hl]
	jr nz,flushnblk. ;not filled up
;block is filled up
;zero secwritten
	;ld l,FCB.secwritten
	ld [hl],a;0 ;block not created
;write descriptor
	ld l,0
	ld (flushdesc.A.),hl
	push hl
	call flushdesc
	pop hl
;increase block number (after flushdesc!!!)
	ld l,FCB.block
	inc [hl] ;cur block for write, next block for read
;теперь дескриптор невалидный, пока не создадим его в начале другого flush
;zero lastlen (after flushdesc!!!)
	ld l,FCB.lastlen+1 ;(HSB), LSB is already 0 if not fclose
	ld [hl],0
flushnblk.
	ret
*/
PROC flushwritebuf(FCB* pfcb)
{
VAR UINT cursector;
//1раз
  cursector = writesectors((PBYTE)((UINT)pfcb+0x100), (UINT)(pfcb->cursectorLSB) + ((UINT)(pfcb->cursectorHSB)<<8), 0x01);
  pfcb->cursectorLSB = (BYTE)cursector;
  pfcb->cursectorHSB = (BYTE)(cursector>>8);
  INC *(&(pfcb->secwritten)); //pfcb->secwritten = pfcb->secwritten + 0x01;
  IF (pfcb->secwritten == pfcb->secinblk) { //block is filled up
//не попали
    pfcb->secwritten = 0x00;
    flushdesc(pfcb);
    INC *(&(pfcb->block)); //pfcb->block = pfcb->block + 0x01; //cur block for write, next block for read
    //теперь дескриптор невалидный, пока не создадим его в начале другого flush
    pfcb->lastlenLSB = 0x00;
    pfcb->lastlenHSB = 0x00;
  };
}

/**
flush_
flush_.A.=$+1
	ld hl,0 ;hl = poi to FCB
;if secwritten == 0 then reserve sectors, reserve descriptor
	ld l,FCB.secwritten
	ld a,[hl]
	or a
	jr nz,flushnnew.
;глючит, если последний блок <256
;потому что fclose второй раз вызывает flush
	ld l,FCB.secinblk
	ld [hl],16 ;TR-DOS reserves 16 sectors per block
;update sec8
	push hl ;poi to FCB
	ld de,0x0008
	push de
	ld hl,DOSBUF
	call rdsec.
	pop de ;0x0008
	ld hl,[DOSBUF+0xe5] ;free sectors
	ld bc,-16
	add hl,bc
	 ;bit 7,h
	 ;jr nz,$ ;no free sectors
	ld [DOSBUF+0xe5],hl ;free sectors

	ld hl,DOSBUF+0xe4 ;files
	ld a,[hl] ;descriptor position 0..127
	 ;or a
	 ;jp m,$ ;128 files, can't add
	inc [hl] ;files

	ld l,0xe1 ;free sector
	ld c,[hl]
	inc hl
	ld b,[hl]
	inc [hl] ;add 16 sectors = add 1 track

	pop hl ;poi to FCB
	ld l,FCB.descpos
	ld [hl],a ;descriptor position 0..127
	ld l,FCB.firstsector
	ld [hl],c
	inc hl
	ld [hl],b
	ld l,FCB.cursector
	ld [hl],c
	inc hl
	ld [hl],b

	push hl ;poi to FCB
	ld hl,DOSBUF
	;ld de,0x0008
	call wrsec. ;write sec8
	pop hl ;poi to FCB
flushnnew.
	ld l,0
	ld (flushwritebuf.A.),hl
	jp flushwritebuf
*/
//ручной flush пока невозможен!!!
//can create zero length file
PROC flush_(FCB* pfcb)
{
VAR BYTE firstsectorLSB;
VAR BYTE firstsectorHSB;
VAR UINT freesectors;
  IF (pfcb->secwritten == 0x00) { //reserve sectors, reserve descriptor
    //глючит, если последний блок <256
    //потому что fclose второй раз вызывает flush
    pfcb->secinblk = 0x10; //TR-DOS reserves 16 sectors per block
    //update sec8
    readsectors(DOSBUF, 0x0008, 0x01);
    //POKE *(PUINT)(/**(UINT)DOSBUF+0x00e5*/DOSBUFfreesectors) = *(PUINT)(/**(UINT)DOSBUF+0x00e5*/DOSBUFfreesectors) - 16; //free sectors //todo check < 0
    freesectors = ((UINT)*(PBYTE)DOSBUFfreesectorsHSB << 8) + (UINT)*(PBYTE)DOSBUFfreesectorsLSB - 16;
//    freesectors = (UINT)*(PBYTE)DOSBUFfreesectorsLSB + ((UINT)*(PBYTE)DOSbuffreesectorsHSB << 8) - 16; //todo найти глюк в ассемблере!!! почему не находит метку DOSbuffreesectorsHSB???
    POKE *(PBYTE)(DOSBUFfreesectorsLSB) = (BYTE)freesectors;
    POKE *(PBYTE)(DOSBUFfreesectorsHSB) = (BYTE)(freesectors>>8);
    pfcb->descpos = *(PBYTE)(/**(UINT)DOSBUF+0x00e4*/DOSBUFfiles); //descriptor position 0..127
    POKE *(PBYTE)(/**(UINT)DOSBUF+0x00e4*/DOSBUFfiles) = pfcb->descpos + 0x01; //files //todo check >=128
    //*(PUINT)(/**(UINT)DOSBUF+0x00e1*/DOSBUFfreesector); //free sector
    firstsectorLSB = *(PBYTE)DOSBUFfreesectorLSB;
    firstsectorHSB = *(PBYTE)DOSBUFfreesectorHSB;
    pfcb->firstsectorLSB = firstsectorLSB;
    pfcb->firstsectorHSB = firstsectorHSB;
    pfcb->cursectorLSB = firstsectorLSB;
    pfcb->cursectorHSB = firstsectorHSB;
    //POKE *(PUINT)(/**(UINT)DOSBUF+0x00e1*/DOSBUFfreesector) = firstsector + 0x0100; //add 16 sectors = add 1 track
    POKE *(PBYTE)(DOSBUFfreesectorHSB) = firstsectorHSB + 0x01;
//1раз
//goto l1;l1:
    writesectors(DOSBUF, 0x0008, 0x01);
//goto l2;l2:
  };
  flushwritebuf(pfcb);
}

/**
comparedesc
comparedesc.A.=$+1 ;filename
	ld hl,0
	ld [findlastslash.A.],hl
	call findlastslash
	ex de,hl
;de = after last slash
comparedesc.B.=$+1 ;desc
	ld hl,0
;compare until '.' or '\0' or 8 loops
	ld b,8
comparedesc0.
	ld a,[de] ;filename
	inc de ;todo test '\0', descbuf all spaces
	cp '.'
	jr z,comparedescdot.
	cp [hl] ;descriptor
	jr nz,comparedescfalse.
	inc hl
	djnz comparedesc0.
	ld a,[de] ;filename
	inc de
	cp '.'
	jr z,comparedescdot8. ;filenam8.ext
	;filenam8 (without ext)
	ld a,[hl]
	cp ' '
	jr nz,comparedescfalse.
comparedesctrue.
	ld a,0xff ;TRUE
	ret
comparedescdot.
	inc hl
	djnz $-1 ;hl = descriptor ext
comparedescdot8.
	ld a,[de] ;filename ext
	cp [hl] ;descriptor ext
	jr z,comparedesctrue.
comparedescfalse.
	xor a ;FALSE
	ret
*/
/**
FUNC BOOL comparedesc(PCHAR filename, PBYTE desc)
{
VAR CHAR c;
VAR BOOL res;
VAR BYTE i = 0x08;
  filename = findlastslash(filename);
  loop:
    c = *(PCHAR)filename;
    INC filename;
    IF (c == '.') { //todo test '\0', descbuf all spaces
      dot:
      //desc = (PBYTE)((UINT)desc + (UINT)i);
      res = (*(PCHAR)((UINT)desc + (UINT)i) == *(PCHAR)filename);
      goto quit;
    };
    IF (c != *(PCHAR)desc) {
      res = +FALSE;
      goto quit;
    };
    INC desc;
    DEC i;
    IF (i == 0x00) {
      c = *(PCHAR)filename;
      INC filename;
      //IF (c == '.') 
              goto dot;
      //res = (*(PCHAR)desc == ' '); //filenam8 (without ext) //TODO
      //goto quit;
    };
    goto loop;
  quit:
RETURN res;
}
*/

/**
fread_readnextsector
fread_readnextsector.A.=$+1
	ld hl,0
	ld l,FCB.cursector
	push hl ;poi to cursector
	ld e,[hl]
	inc hl
	ld d,[hl]
	inc h
	ld l,0;a;0 ;poi to buf
	call rdsec.
	ex de,hl ;ld de,[0x5cf4] ;de=next sector
	pop hl ;poi to cursector
	ld [hl],e
	inc hl
	ld [hl],d
	ret
*/
/**
PROC fread_readnextsector(FCB* pfcb)
{
  pfcb->cursector = readsectors((PBYTE)((UINT)pfcb+0x100), pfcb->cursector, 0x01);
}
*/

/**
fread1sec
fread1sec.A.=$+1
	ld hl,0
	ld (fread_readnextsector.A.),hl
	push hl
	call fread_readnextsector
	pop hl
;if last sector of block, then remain = -lastlen and shift data in buf to the end
;else remain = 0 (read + 255 bytes)
	xor a
	ld l,FCB.secinblk
	dec [hl] ;sectors remained in block
	jr nz,fread1nlast.
;last sector in block: shift data to the end of buf
	ld l,FCB.lastlen
	ld c,[hl] ;1..256
	ld b,a;0
	dec c ;0..255
	ld l,c ;end of data
	inc h
	inc bc ;1..256
	ld d,h
	ld e,0xff
	lddr
	;hl = poi to buf - 1
	;h = poi to FCB
	ld a,e ;0xfe (1 byte) ... -1 (256 bytes)
	inc a ;remain = 0xff (read + no data) ... 0 (read + 255 bytes)
fread1nlast.
	ld l,FCB.remain
	ld [hl],a
        ret
*/
PROC fread1sec(FCB* pfcb)
{
VAR BYTE eod;
VAR UINT cursector;
//1раз
  //fread_readnextsector(pfcb);
  cursector = readsectors((PBYTE)((UINT)pfcb+0x100), (UINT)(pfcb->cursectorLSB) + ((UINT)(pfcb->cursectorHSB)<<8), 0x01);
  pfcb->cursectorLSB = (BYTE)cursector;
  pfcb->cursectorHSB = (BYTE)(cursector>>8);
  //if last sector of block, then remain = -lastlen and shift data in buf to the end
  //else remain = 0 (read + 255 bytes)
  pfcb->remain = 0x00;
  DEC *(&(pfcb->secinblk)); //sectors remained in block
  IF (pfcb->secinblk == 0x00) {
    //last sector in block: shift data to the end of buf
    eod = pfcb->lastlenLSB - 0x01; //1..256 => 0..255
    memcopyback(
      (PBYTE)((UINT)pfcb + 0x0100 + (UINT)eod), //end of data
      (UINT)eod + 1, //1..256
      (PBYTE)((UINT)pfcb + 0x01ff) //end of buf
    );
    pfcb->remain = ~eod; //0xff (read + no data) ... 0 (read + 255 bytes)
  };
}

/**
fread1blkq
fread1blkq.A.=$+1 ;FCB
        ld hl,0
fread1blkq.B.=$+1 ;desc
        ld de,0
;de = poi to descriptor ;+ 10
;hl = FCB
	ld l,FCB.fn ;+ 10
	ex de,hl
;hl = poi to descriptor ;+ 10
;de = poi to filename ;+ 10
	ld bc,16;6 ;padding, len(LSB), len(HSB), secinblk, sec, track
	ldir
	ex de,hl
	ld l,FCB.firstsector
	ld e,[hl]
	inc hl
	ld d,[hl]
	ld l,FCB.cursector
	ld [hl],e
	inc hl
	ld [hl],d
;secinblk = (lastlen+255)/256 = (lastlen-1)/256 + 1
;иначе нельзя будет выделять блоки навырост (как делает TR-DOS)
	ld l,FCB.lastlen
	ld e,[hl]
	inc hl
	ld d,[hl]
	dec de
	inc d
	inc hl ;ld l,FCB.secinblk
	ld [hl],d
	jr z,fread1qEOF. ;(secinblk == 0)
	ld l,FCB.block
	inc [hl] ;cur block for write, next block for read
        ld a,0xff ;TRUE ;no EOF
        ret
fread1qEOF.
        xor a
        ret
*/
FUNC BOOL fread1blkq(FCB* pfcb, PBYTE pdesc)
{
VAR BOOL res = +FALSE; //EOF
  //memcopy(pdesc, 16, (PBYTE)&(pfcb->fn)); //from, len, to //содержимое структуры зависит от порядка байтов в слове и размера UINT!!!
  memcopy(pdesc, 11, (PBYTE)&(pfcb->fn)); //from, len, to
  pdesc = &pdesc[11];
  pfcb->lastlenLSB = *(PBYTE)(pdesc);
  pfcb->lastlenHSB = *(PBYTE)((UINT)pdesc+1);
  pdesc = &pdesc[2];
  pfcb->secinblk = *(PBYTE)(pdesc);
  INC pdesc;
  pfcb->firstsectorLSB = *(PBYTE)(pdesc);
  pfcb->firstsectorHSB = *(PBYTE)((UINT)pdesc+1);
  pfcb->cursectorLSB = pfcb->firstsectorLSB;
  pfcb->cursectorHSB = pfcb->firstsectorHSB;
  //secinblk = (lastlen+255)/256 = (lastlen-1)/256 + 1
  //иначе нельзя будет выделять блоки навырост (как делает TR-DOS)
  pfcb->secinblk = (BYTE)(((UINT)(pfcb->lastlenLSB) + ((UINT)(pfcb->lastlenHSB)<<8) + 0x00ff) >> 8);
  IF (pfcb->secinblk != 0x00) {
    INC *(&(pfcb->block)); //cur block for write, next block for read
    res = +TRUE; //no EOF
  };
RETURN res;
}

/**
readnewbuf
;read new buf (if exists)
readnewbuf.A.=$+1
        ld hl,0
	ld l,FCB.secinblk
	xor a
	cp [hl] ;sectors remained in block (0 means none)
	jr nz,fread1sec. ;a = 0
;find new block if exists
;find Nth block of file with hl pointed filename (10 bytes: name, ext, block N)
	ld b,8 ;sectors
findfile0.
	push bc
	push hl
	ld d,0 ;track
	ld a,8
	sub b
	ld e,a ;sector
	ld hl,DOSBUF
	ld b,1
	call rdsectors.
	pop hl
	pop bc
;hl=filename
;b=sectors
	ld de,DOSBUF
findfilecp0.
        ld l,0
        ld (fread1blkq.A.),hl ;FCB
        ld (fread1blkq.B.),de ;desc
	ld l,FCB.fn ;poi to fn
	push bc
	ld bc,0x0a00 ;b=bytes to compare, c=errors
findfilecp00.
	ld a,[de]
	sub [hl]
	or c
	ld c,a ;errors
	inc hl
	inc de
	djnz findfilecp00.
	pop bc
	jr z,fread1blkq. ;ret z ;found (carry = off, a = 0)
	ld a,e
	add a,6
	ld e,a
	jr nz,findfilecp0. ;next descriptor
	djnz findfile0. ;next sector
;not found
        xor a ;EOF
        ret
fread1blkq.
;de = poi to descriptor ;+ 10
;hl = poi to fn ;+ 10
        push hl
        call fread1blkq
        pop hl
        or a ;EOF
        ret z;jr z,fread1EOF.
fread1sec.
	ld l,0
	ld (fread1sec.A.),hl
        call fread1sec
        ld a,0xff ;not EOF
        ret
*/
FUNC BOOL readnewbuf(FCB* pfcb)
{
VAR PBYTE pdesc;
VAR PBYTE pfn;
VAR BYTE sector;
VAR BYTE i;
VAR BYTE b;
VAR BOOL res = +FALSE; //EOF
  IF (pfcb->secinblk == 0x00) { //sectors remained in block (0 means none)
    //find new block if exists
    //find Nth block of file with hl pointed filename (10 bytes: name, ext, block N)
    sector = 0x00;
    REPEAT {
      readsectors(DOSBUF, (UINT)sector, 0x01);
      pdesc = DOSBUF;
#define DOSBUFEND (UINT)(DOSBUF+0x0100)
      REPEAT {
        pfn = (PBYTE)&(pfcb->fn);
        i = 0x00;
        REPEAT {
          b = *(PBYTE)pfn;
          INC pfn;
          IF (pdesc[i] != b) goto wrong;
          INC i;
        }UNTIL (i == 0x0a); //bytes to compare
        goto found;
        wrong:
        pdesc = (PBYTE)((UINT)pdesc + 16);
      }UNTIL ((UINT)pdesc == DOSBUFEND); //next descriptor
      INC sector;
    }UNTIL (sector == 0x08); //next sector
    //not found
    goto quit; //EOF
    found:
    IF (!fread1blkq(pfcb, pdesc)) goto quit; //EOF
  };
  fread1sec(pfcb);
  res = +TRUE; //not EOF
quit:
RETURN res;
}

/**
fputs
	EXPORT fputs
;todo optimize
fputs.A.=$+1
	EXPORT fputs.A.
	ld bc,0 ;poi to string
	jp fputsgo.
fputs0.
fputs.B.=$+1
	EXPORT fputs.B.
	ld hl,0 ;poi to FCB
	call fwrite1. ;a=data
	inc bc
fputsgo.
	ld a,[bc]
	or a
	jp nz,fputs0.
	ret ;end of string ;(TODO hl = non-negative value)
*/
EXPORT FUNC INT fputs(PCHAR s, PBYTE file)
{
VAR CHAR c;
loop:
  c = *(PCHAR)s;
  IF (c == '\0') goto quit;
  fwrite((PBYTE)&c, 1, 1, file);
  INC s;
  goto loop;
quit:
RETURN +1; //OK
}

/**
closewrite
	EXPORT closewrite
fclose
	EXPORT fclose
closewrite.A.=$+1
	EXPORT closewrite.A.
fclose.A.=$+1
	EXPORT fclose.A.
	ld hl,0 ;poi to FCB
	ld a,[hl]
	ld [hl],l;0
	cp 'w'
	ret nz ;hl!=0
;hl = poi to FCB
	push hl
	ld (flush_.A.),hl
	call flush_
	pop hl
	;следующая проверка не годится, если будет ручной flush:
	ld l,FCB.secwritten
	ld a,[hl]
	or a
	ret z ;no sectors written - descriptor already saved
	ld l,0
	ld (flushdesc.A.),hl
	call flushdesc
	;ld l,1 ;OK TODO
	ret ;hl!=0
*/
EXPORT FUNC INT fclose(PBYTE file)
{
VAR FCB* pfcb = (FCB*)file;
VAR CHAR mode = pfcb->mode;
  pfcb->mode = '\0';
  IF (mode == 'w') {
    flush_(pfcb);
    IF (pfcb->secwritten != 0x00) {
      flushdesc(pfcb);
    };
  };
RETURN +1; //OK
}
/**
EXPORT PROC closewrite(PBYTE file)
{
  fclose(file);
}
*/