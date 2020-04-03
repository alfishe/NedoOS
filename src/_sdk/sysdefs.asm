BDOS=0x0005
COMMANDLINE=0x0080
COMMANDLINE_sz=0x0080
PROGSTART=0x0100

MAXPATH_sz=256;64

;------------------------СТРУКТУРЫ CP/M --------------------------------------
;from CP/M (try to avoid use!):
CMD_PRCHAR=0x05 ;e=char
CMD_SETDRV=0x0e ;e=drive ;out: a!=0 => not mounted, [l=number of drives]
CMD_FOPEN=0x0f ;de = pointer to unopened FCB
CMD_FCLOSE=0x10 ;de = pointer to opened FCB
CMD_FSEARCHFIRST=0x11 ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
CMD_FSEARCHNEXT=0x12 ;(NOT CP/M compatible!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA. DTA had to set every time
CMD_FDEL=0x13 ;DE = Pointer to unopened FCB
CMD_FREAD=0x14 ;DE = Pointer to opened FCB, read 128 bytes in DTA, out: a=128^bytes actually read (not CP/M!)
CMD_FWRITE=0x15 ;DE = Pointer to opened FCB, write 128 bytes from DTA
CMD_FCREATE=0x16 ;DE = Pointer to unopened FCB
CMD_SETDTA=0x1a ;DE = data transfer address (DTA)

;from MSX-DOS:
CMD_SEEKHANDLE=0x4a ;b=file handle, dehl=offset [signed, a=method:0=begin,1=cur,2=end TODO]
CMD_OPENHANDLE=0x43 ;DE = Drive/path/file ASCIIZ string
                        ;[A = Open mode. b0 set => no write, b1 set => no read, b2 set => inheritable, b3..b7   -  must be clear]
                        ;out: B = new file handle, A=error
CMD_CREATEHANDLE=0x44 ;DE = Drive/path/file ASCIIZ string
                        ;[A = Open mode. b0 set => no write, b1 set => no read, b2 set => inheritable, b3..b7   -  must be clear]
                        ;[B = b0..b6 = Required attributes, b7 = Create new flag]
                        ;out: B = new file handle, A=error
CMD_CLOSEHANDLE=0x45 ;B = file handle, out: A=error
CMD_READHANDLE=0x48 ;B = file handle, DE = Buffer address, HL = Number of bytes to read, out: HL = Number of bytes actually read, A=error(=0)
CMD_WRITEHANDLE=0x49 ;B = file handle, DE = Buffer address, HL = Number of bytes to write, out: HL = Number of bytes actually written, A=error(=0)
CMD_RENAME=0x4e ;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string (NOT MSXDOS compatible! with Drive/path!) ;RENAME OR MOVE FILE
CMD_CHDIR=0x5a ;DE = Pointer to ASCIIZ string. Out A=error
CMD_PARSEFNAME=0x5c ;de(dotname) -> hl(cpmname) ;out: de=pointer to termination character, hl=buffer filled in
CMD_GETPATH=0x5e ;DE = Pointer to 64 byte (MAXPATH_sz!) buffer ;out: DE = Filled in with whole path string (WITH DRIVE! Finished by slash only if root dir), HL = Pointer to start of last item
CMD_DELETE=0x4d ;DE = Drive/path/file ASCIIZ string, out: A = Error

;invented:
CMD_SETMUSIC=0xd5 ;hl=muzaddr (0x4000..0x7fff), a=muzpg
CMD_READSECTORS=0xd6 ;b=drive, de=buffer, ixhl=sector number, a=count
CMD_WRITESECTORS=0xd7 ;b=drive, de=buffer, ixhl=sector number, a=count
CMD_SETBORDER=0xd8 ;e=0..15
CMD_SETWAITING=0xd9 ;set WAITING state for current task
CMD_GETFILESIZE=0xda ;b=handle, out: dehl=file size
CMD_WIZNETOPEN=0xdb ;A=SOCKET, L=subfunction (see sys_h.asm)
CMD_WIZNETCLOSE=0xdc ;A=SOCKET, E=(0 - закрыть сразу, 1 - закрыть только если буфер приёма пуст)
CMD_WIZNETREAD=0xdd 	;if TCP: A=SOCKET, de=buffer_ptr, HL=sizeof(buffer)
						;else:	 A=SOCKET, IX=buffer_ptr, HL=sizeof(buffer), de=sockaddr_in ptr
						;out: HL=count if HL < 0 then A=error
CMD_WIZNETWRITE=0xde 	;if TCP: A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) 
						;else:	 A=SOCKET, IX=buffer_ptr, HL=sizeof(buffer), de=sockaddr_in ptr
						;out: HL=count if HL < 0 then A=error
CMD_DROPAPP=0xdf ;e=id
CMD_GETAPPMAINPAGES=0xe0 ;e=id ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
CMD_GETXY=0xe1 ;out: de=yx ;GET CURSOR POSITION
CMD_GETTIME=0xe2 ;out: ix=date, hl=time
CMD_GETFILETIME=0xe3 ;de=Drive/path/file ASCIIZ string, out: ix=date, hl=time
CMD_SETFILETIME=0xe4 ;de=Drive/path/file ASCIIZ string, ix=date, hl=time
CMD_TELLHANDLE=0xe5 ;b=file handle, out: dehl=offset ;GET POSITION IN FILE
CMD_SCROLLUP=0xe6 ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
CMD_SCROLLDOWN=0xe7 ;de=topyx, hl=hgt,wid ;x, wid even ;TEXTMODE ONLY
CMD_FWRITE_NBYTES=0xe8 ;hl=bytes, de=FCB ;don't use! ;TODO выбросить
CMD_SETMAINPAGE=0xe9 ;e=page for 0x0000
CMD_SETSYSDRV=0xea ;out: a!=0 => not mounted, l=number of drives
CMD_MKDIR=0xeb ;DE = Pointer to ASCIIZ string, out: a
CMD_WAITPID=0xec ;e=id ;check if app closed, out: a=0 => OK (and reset waiting), or else a!=0
CMD_FREEZEAPP=0xed ;e=id ;disable app and make non-graphic
CMD_GETATTR=0xee ;out: a ;READ ATTR AT CURSOR POSITION
CMD_MOUNT=0xef ;e=drive, out: a
CMD_GETKEYMATRIX=0xf0 ;out: bcdehlix = halfrows cs...space
CMD_GETTIMER=0xf1 ;out: hlde=timer
CMD_YIELD=0xf2 ;schedule to another app (use YIELD macro instead of HALT!!!)
CMD_RUNAPP=0xf3 ;e=id ;ACTIVATE DISABLED APP
CMD_NEWAPP=0xf4 ;out: b=id, a=error, dehl=newapp pages in 0000,4000,8000,c000 ;MAKE NEW DISABLED APP
CMD_PRATTR=0xf5 ;e=color byte ;DRAW ATTR AT CURSOR POSITION
CMD_CLS=0xf6 ;e=color byte
CMD_SETCOLOR=0xf7 ;e=color byte
CMD_SETXY=0xf8 ;de=yx ;SET CURSOR POSITION
CMD_SETGFX=0xf9 ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
CMD_SETPAL=0xfa ;de=palette (32 bytes)
CMD_GETMAINPAGES=0xfb ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags
CMD_NEWPAGE=0xfc ;out: a=0 (OK)/!=0 (fail), e=page
CMD_DELPAGE=0xfd ;e=page ;GIVE SOME PAGE BACK TO THE OS
CMD_SETSCREEN=0xfe ;e=screen=0..1
;TODO ещё установку текущего обрабатываемого экрана? и "начал рисовать", "закончил рисовать"
CMD_GETSCREENPAGES=0xff ;out: de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)

;        STRUCT FCB
FCB_drv=0 ;drv             BYTE; /* drive number */
FCB_FNAME=1 ;FNAME           BLOCK 11;
FCB_EXTENTNUMBERLO=12 ;EXTENTNUMBERLO  BYTE; ;NU
FCB_FATTRIB=13 ;FATTRIB         BYTE;
FCB_EXTENTNUMBERHI=14 ;EXTENTNUMBERHI  BYTE; ;NU
FCB_RECORDCOUNT=15 ;RECORDCOUNT     BYTE; ;NU
FCB_FSIZE=16 ;FSIZE           DWORD;
FCB_FTIME=20 ;FTIME           WORD;
FCB_FFSFCB=22 ;FFSFCB          WORD; /* TRDOSFCB или FIL */
FCB_DIRPOS=24 ;DIRPOS          WORD; /* привязка к точке поиска */
;RESERVED        BLOCK 2 ;reserved (14 in MS-DOS???)
FCB_RECORDSIZE=28 ;RECORDSIZE      WORD; /* must be 128 */
FCB_FDATE=30 ;FDATE           WORD
FCB_FRECORD=32 ;FRECORD         BYTE; /*номер записи внутри экстента*/
;	ENDS
FCB_sz=33

FATTRIB_DIR=0x10 ;mask for FCB_FATTRIB

;Application flags:

factive=0 ;0=zombie, 1=scheduled ;TODO есть сообщения: SET при добавлении сообщения, RES при взятии последнего сообщения
;fcritical=4 (чтобы не портить hl)
fgfx=5 ;app can take focus
;ffocus=6 ;app has focus (only one can)
fwaiting=7 ;app is waiting for another app, can't take focus by hand

;Internal keyboard values:

extbase=0xb0 ;with H=1 ;can't mix with 32..127 ;temporary internal code
csbase=0xf3 ;temporary internal code
extenter=csbase+12 ;temporary internal code
graphlock=extenter ;temporary internal code
csnoshifts=0;NOKEY ;cs release result for AltGr ;temporary internal code
csspace=27 ;temporary internal code
csss=9 ;Tab ;temporary internal code
key_extspace=0;NOKEY ;extbase+14 ;unusable because happens simultaneously with extZ because of keyboard matrix
cssspress=csss ;temporary internal code (impossible to type without AltGr before language recoding)
ssnoshifts=0xd1 ;temporary internal code (impossible to type without AltGr before language recoding)
ext0=extbase+0
ext1=extbase+1
ext2=extbase+2
ext3=extbase+3
ext4=extbase+4
ext5=extbase+5
ext6=extbase+6
ext7=extbase+7
ext8=extbase+8
ext9=extbase+9
cs0=8 ;as extH (CP/M) ;csbase+0 reserved
cs1=csbase+1 ;readable only in keynolang (switches language)
cs2=csbase+2 ;readable only in keynolang (switches Caps Lock)
cs3=csbase+3
cs4=csbase+4
cs5=csbase+5
cs6=csbase+6
cs7=csbase+7
cs8=csbase+8
cs9=csbase+9

;Usable key codes:

extA=1
extB=2
extC=3
extD=4
extE=5
extF=6
extG=7
extH=8 ;as cs0 (BackSpace)
extI=9 ;as csss (Tab)
extJ=10
extK=11
extL=12
extM=13 ;as Enter
extN=14
extO=15
extP=16
extQ=17
extR=18
extS=19
extT=20
extU=21
extV=22
extW=23
extX=24
extY=25
extZ=26

ss1='!'
ss2='@'
ss3='#'
ss4='$'
ss5='%'
ss6='&'
ss7=0x27;'\''
ss8='('
ss9=')'
ssA='~'
ssB='*'
ssC='?'
ssD=0x5c;'\\'
ssE=30;extbase+30
ssF='{'
ssG='}'
ssH='^'
ssI=127;extbase+12
ssJ='-'
ssK='+'
ssL='='
ssM='.'
ssN=','
ssO=';'
ssP=0x22;'"'
ssQ=28;extbase+28
ssR='<'
ssS='|'
ssT='>'
ssU=']'
ssV='/'
ssW=29;extbase+29
ssX='`'
ssY='['
ssZ=':'

key_home=ssQ
key_end=ssE
key_ins=ssW
key_enter=13
key_left=cs5
key_right=cs8
key_up=cs7
key_down=cs6
key_pgup=cs3
key_pgdown=cs4
key_backspace=cs0
key_del=cs9
key_ssleft=ext5
key_ssright=ext8
key_ssup=ext7
key_ssdown=ext6
key_sspgup=ext3
key_sspgdown=ext4
key_ssbackspace=ext0
key_ssdel=ext9
key_tab=csss
key_esc=csspace
key_csenter=csbase+10
key_ssspace=csbase+11
key_F1=ext1
key_F2=ext2
key_F3=ext3
key_F4=ext4
key_F5=ext5
key_F6=ext6
key_F7=ext7
key_F8=ext8
key_F9=ext9
key_F10=ext0

NOKEY=0
key_redraw=31 ;if equal to ssEnter, then scheduling through idle will catch ssEnter twice
;single ext (Tab) is returned at key release (TODO keypress in keynolang)
;single ss, cs keypresses are not returned, or else CP/M-like apps can't filter them out (TODO in keynolang, and all other key releases too)
