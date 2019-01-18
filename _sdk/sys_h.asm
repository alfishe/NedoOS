
        include "atm.asm"
COMMANDLINE=0x0080
COMMANDLINE_sz=0x0080
PROGSTART=0x0100

;do define oldtimer (2 bytes)
        macro YIELD
_1=$;1
        OS_YIELD
        OS_GETTIMER ;hlde=timer
        ld hl,(oldtimer)
        ld (oldtimer),de
        or a
        sbc hl,de
        jr z,_1;1b
        endm
        macro YIELDGETKEYLOOP
_1=$;1;prwindow_waitkey_nokey
	YIELD ;halt ;если сделать просто di:rst 0x38, то 1.сдвинем таймер и 2.можем потер€ть кадровое прерывание, а если без ei, то будут глюки
        GET_KEY
        cp NOKEY
        jr z,_1;1b;prwindow_waitkey_nokey
        endm
        
;from CP/M        
        macro OS_PRCHAR
        ld c,CMD_PRCHAR
        CALLBDOS
        endm
        macro OS_SETDRV
        ld c,CMD_SETDRV
        CALLBDOS
        endm
        macro OS_FOPEN
        ld c,CMD_FOPEN
        CALLBDOS
        endm
        macro OS_FCLOSE
        ld c,CMD_FCLOSE
        CALLBDOS
        endm
        macro OS_FSEARCHFIRST
        ld c,CMD_FSEARCHFIRST
        CALLBDOS
        endm
        macro OS_FSEARCHNEXT
        ld c,CMD_FSEARCHNEXT
        CALLBDOS
        endm
        macro OS_FDEL
        ld c,CMD_FDEL
        CALLBDOS
        endm
        macro OS_FREAD
        ld c,CMD_FREAD
        CALLBDOS
        endm
        macro OS_FWRITE
        ld c,CMD_FWRITE
        CALLBDOS
        endm
        macro OS_FCREATE
        ld c,CMD_FCREATE
        CALLBDOS
        endm
        macro OS_SETDTA
        ld c,CMD_SETDTA
        CALLBDOS
        endm

;from MSX-DOS
        macro OS_SEEKHANDLE
        ld c,CMD_SEEKHANDLE
        CALLBDOS
        endm
        macro OS_OPENHANDLE
        ld c,CMD_OPENHANDLE
        CALLBDOS
        endm
        macro OS_CREATEHANDLE
        ld c,CMD_CREATEHANDLE
        CALLBDOS
        endm
        macro OS_CLOSEHANDLE
        ld c,CMD_CLOSEHANDLE
        CALLBDOS
        endm
        macro OS_READHANDLE
        ld c,CMD_READHANDLE
        CALLBDOS
        endm
        macro OS_WRITEHANDLE
        ld c,CMD_WRITEHANDLE
        CALLBDOS
        endm
        macro OS_RENAME
        ld c,CMD_RENAME
        CALLBDOS
        endm
        macro OS_CHDIR
        ld c,CMD_CHDIR
        CALLBDOS
        endm
        macro OS_PARSEFNAME
        ld c,CMD_PARSEFNAME
        CALLBDOS
        endm
        macro OS_GETPATH
        ld c,CMD_GETPATH
        CALLBDOS
        endm

;invented  
        macro OS_WIZNETOPEN
        ld c,CMD_WIZNETOPEN
	CALLBDOS
        endm
        macro OS_WIZNETCLOSE
        ld c,CMD_WIZNETCLOSE
	CALLBDOS
        endm
        macro OS_WIZNETREAD
        ld c,CMD_WIZNETREAD
	CALLBDOS
        endm
        macro OS_WIZNETWRITE
        ld c,CMD_WIZNETWRITE
	CALLBDOS
        endm
        macro OS_DROPAPP
        ld c,CMD_DROPAPP
	CALLBDOS
        endm
        macro OS_GETAPPMAINPAGES
        ld c,CMD_GETAPPMAINPAGES
	CALLBDOS
        endm
        macro OS_GETXY
        ld c,CMD_GETXY
	CALLBDOS
        endm
        macro OS_GETTIME
        ld c,CMD_GETTIME
        CALLBDOS
        endm
        macro OS_GETFILETIME
        ld c,CMD_GETFILETIME
        CALLBDOS
        endm
        macro OS_SETFILETIME
        ld c,CMD_SETFILETIME
        CALLBDOS
        endm
        macro OS_TELLHANDLE
        ld c,CMD_TELLHANDLE
        CALLBDOS
        endm
        macro OS_SCROLLUP
        ld c,CMD_SCROLLUP
        CALLBDOS
        endm
        macro OS_SCROLLDOWN
        ld c,CMD_SCROLLDOWN
        CALLBDOS
        endm
        macro OS_FWRITE_NBYTES
        ld c,CMD_FWRITE_NBYTES
        CALLBDOS
        endm
        macro OS_GETKEYNOLANG
        ld c,CMD_GETKEYNOLANG
        CALLBDOS
        endm
        macro OS_SETSYSDRV
        ld c,CMD_SETSYSDRV
        CALLBDOS
        endm
        macro OS_MKDIR
        ld c,CMD_MKDIR
        CALLBDOS
        endm
        macro OS_WAITPID
        ld c,CMD_WAITPID
        CALLBDOS
        endm
        macro OS_FREEZEAPP
        ld c,CMD_FREEZEAPP
        CALLBDOS
        endm
        macro OS_GETATTR
        ld c,CMD_GETATTR
        CALLBDOS
        endm
        macro OS_MOUNT
        ld c,CMD_MOUNT
        CALLBDOS
        endm
        macro OS_GETKEYMATRIX
        ld c,CMD_GETKEYMATRIX
        CALLBDOS
        endm
        macro OS_GETTIMER
        ld c,CMD_GETTIMER
	CALLBDOS
        endm
        macro OS_YIELD
        ld c,CMD_YIELD
	CALLBDOS
        endm
        macro OS_RUNAPP
        ld c,CMD_RUNAPP
	CALLBDOS
        endm
        macro OS_NEWAPP
        ld c,CMD_NEWAPP
	CALLBDOS
        endm
        macro OS_PRATTR
        ld c,CMD_PRATTR
	CALLBDOS
        endm
        macro OS_CLS
        ld c,CMD_CLS
	CALLBDOS
        endm
        macro OS_SETCOLOR
        ld c,CMD_SETCOLOR
	CALLBDOS
        endm
        macro OS_SETXY
        ld c,CMD_SETXY
	CALLBDOS
        endm
        macro OS_SETGFX
        ld c,CMD_SETGFX
	CALLBDOS
        endm
        macro OS_SETPAL
        ld c,CMD_SETPAL
	CALLBDOS
        endm
        macro OS_GETMAINPAGES
        ld c,CMD_GETMAINPAGES
	CALLBDOS
        endm
        macro OS_NEWPAGE
        ld c,CMD_NEWPAGE
	CALLBDOS
        endm
        macro OS_DELPAGE
        ld c,CMD_DELPAGE
	CALLBDOS
        endm
        macro OS_SETSCREEN
        ld c,CMD_SETSCREEN
	CALLBDOS
        endm
        macro OS_GETSCREENPAGES
        ld c,CMD_GETSCREENPAGES
	CALLBDOS
        endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        macro QUIT
        rst 0 ;close app
        endm

        macro CALLBDOS ;don't use CALLBDOS or call 0x0005 directly!!!
        ex af,af'
        call 0x0005 ;c=CMD
        endm

        macro GET_KEY
        rst 0x08 ;out: a=key (NOKEY=no key), de=mouse delta (dy,dx), l=mouse buttons (bits 0,1,2: 0=pressed), TODO h=high bits of key
        endm

        macro PRCHAR
        rst 0x10 ;a=char
        endm

        macro SETPG16K
        rst 0x18 ;set page "a" in 0x4000
        endm
        
        macro SETPG32KLOW
        rst 0x20 ;set page "a" in 0x8000
        endm
        
        macro SETPG32KHIGH
        rst 0x28 ;set page "a" in 0xc000
        endm

        macro STANDARDPAL
        dw 0xf3f3,0xf2f2,0xf1f1,0xf0f0,0xe3e3,0xe2e2,0xe1e1,0xe0e0
        dw 0xf3f3,0xd2d2,0xb1b1,0x9090,0x6363,0x4242,0x2121,0x0000
        endm

;------------------------—“–” “”–џ CP/M --------------------------------------
;from CP/M:
CMD_PRCHAR=0x05 ;e=char
CMD_SETDRV=0x0e ;e=drive ;out: a!=0 => not mounted, l=number of drives
CMD_FOPEN=0x0f ;de = pointer to unopened FCB
CMD_FCLOSE=0x10 ;de = pointer to opened FCB
CMD_FSEARCHFIRST=0x11 ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
CMD_FSEARCHNEXT=0x12 ;(NOT CP/M!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
CMD_FDEL=0x13 ;DE = Pointer to unopened FCB
CMD_FREAD=0x14 ;DE = Pointer to opened FCB, read 128 bytes in DTA, out: a=128^bytes actually read
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
CMD_RENAME=0x4e ;DE = Drive/path/file ASCIIZ string, HL = New filename ASCIIZ string (NOT MSXDOS! with Drive/path!) ;RENAME OR MOVE FILE
CMD_CHDIR=0x5a ;DE = Pointer to ASCIIZ string
CMD_PARSEFNAME=0x5c ;de(dotname) -> hl(cpmname) ;out: de=pointer to termination character, hl=buffer filled in
CMD_GETPATH=0x5e ;DE = Pointer to 64 byte buffer ;out: DE = Filled in with whole path string (WITH DRIVE!), HL = Pointer to start of last item

;invented:
CMD_WIZNETOPEN=0xdb
CMD_WIZNETCLOSE=0xdc
CMD_WIZNETREAD=0xdd ;de=pointer, hl=buffer size ;out: hl=size
CMD_WIZNETWRITE=0xde ;de=pointer, hl=size
CMD_DROPAPP=0xdf ;e=id
CMD_GETAPPMAINPAGES=0xe0 ;e=id ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags
CMD_GETXY=0xe1 ;out: de=yx ;GET CURSOR POSITION
CMD_GETTIME=0xe2 ;out: ix=date, hl=time
CMD_GETFILETIME=0xe3 ;de=Drive/path/file ASCIIZ string, out: ix=date, hl=time
CMD_SETFILETIME=0xe4 ;de=Drive/path/file ASCIIZ string, ix=date, hl=time
CMD_TELLHANDLE=0xe5 ;b=file handle, out: dehl=offset
CMD_SCROLLUP=0xe6 ;de=topyx, hl=hgt,wid ;x, wid even
CMD_SCROLLDOWN=0xe7 ;de=topyx, hl=hgt,wid ;x, wid even
CMD_FWRITE_NBYTES=0xe8 ;hl=bytes, de=FCB
CMD_GETKEYNOLANG=0xe9 ;
CMD_SETSYSDRV=0xea ;out: a!=0 => not mounted, l=number of drives
CMD_MKDIR=0xeb ;DE = Pointer to ASCIIZ string, out: a
CMD_WAITPID=0xec ;e=id ;check if app closed, out: a=0 => OK
CMD_FREEZEAPP=0xed ;e=id ;disable app and make non-graphic
CMD_GETATTR=0xee ;out: a ;READ ATTR AT CURSOR POSITION
CMD_MOUNT=0xef ;e=drive, out: a
CMD_GETKEYMATRIX=0xf0 ;out: bcdehlix = полур€ды cs...space
CMD_GETTIMER=0xf1 ;out: hlde=timer
CMD_YIELD=0xf2 ;schedule to another app (use YIELD macro instead of HALT!!!)
CMD_RUNAPP=0xf3 ;e=id ;ACTIVATE DISABLED APP
CMD_NEWAPP=0xf4 ;out: b=id, a=error, dehl=номера страниц в 0000,4000,8000,c000 нового приложени€ ;MAKE NEW DISABLED APP
CMD_PRATTR=0xf5 ;e=color byte ;DRAW ATTR AT CURSOR POSITION
CMD_CLS=0xf6 ;e=color byte
CMD_SETCOLOR=0xf7 ;e=color byte
CMD_SETXY=0xf8 ;de=yx ;SET CURSOR POSITION
CMD_SETGFX=0xf9 ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx
CMD_SETPAL=0xfa ;de=palette
CMD_GETMAINPAGES=0xfb ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags
CMD_NEWPAGE=0xfc ;out: a=0 (OK), e=page
CMD_DELPAGE=0xfd ;e=page
CMD_SETSCREEN=0xfe ;e=screen=0..1
;TODO ещЄ установку текущего обрабатываемого экрана
CMD_GETSCREENPAGES=0xff ;out: de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)

        STRUCT FCB
drv             BYTE; /* drive number */
FNAME           BLOCK 11;
EXTENTNUMBERLO  BYTE; ;NU
FATTRIB         BYTE;
EXTENTNUMBERHI  BYTE; ;NU
RECORDCOUNT     BYTE; ;NU
FSIZE           DWORD;
FTIME           WORD;
FFSFCB          WORD; /* TRDOSFCB или FIL */
DIRPOS          WORD; /* прив€зка к точке поиска */
RESERVED        BLOCK 2 ;reserved (14 in MS-DOS???)
RECORDSIZE      WORD; /* must be 128 */
FDATE           WORD
FRECORD         BYTE; /*номер записи внутри экстента*/
	ENDS
FCB_sz=33
FATTRIB_DIR=0x10

factive=0 ;0=zombie, 1=scheduled ;TODO есть сообщени€: SET при добавлении сообщени€, RES при вз€тии последнего сообщени€
;fcritical=4 (чтобы не портить hl)
fgfx=5 ;app can take focus

;TODO 9-битные коды клавиш, чтобы поддержать русские буквы
NOKEY=0
extbase=0xd0
cs0=8
        IF 1==0
cs1='1'-32 ;...
cs2='2'-32
cs3='3'-32
cs4='4'-32
cs5='5'-32
cs6='6'-32
cs7='7'-32
cs8='8'-32
cs9='9'-32
        ELSE
cs1=0xf7 ;код не выдаЄтс€ при чтении через GET_KEY
cs2=0xf8 ;код не выдаЄтс€ при чтении через GET_KEY
cs3=0xf9
cs4=0xfa
cs5=0xfb
cs6=0xfc
cs7=0xfd
cs8=0xfe
cs9=0xff
        ENDIF
Enter=13;31
ext0=extbase+0;"0"
ext1=extbase+1;"1"
ext2=extbase+2;"2"
ext3=extbase+3;"3"
ext4=extbase+4;"4"
ext5=extbase+5;"5"
ext6=extbase+6;"6"
ext7=extbase+7;"7"
ext8=extbase+8;"8"
ext9=extbase+9;"9"
ssQ=extbase+10;"{"
Home=ssQ
ssW=extbase+11;"|"
Ins=ssW
ssE=extbase+12;"}"
End=ssE
extEnter=extbase+13;Enter
csss=extbase+14;ssnoshifts
;sscs=extbase+16;csnoshifts
extSpace=extbase+15 ;из-за матрицы выдаетс€ вместе с extZ
extA=1;"a"+extbase
extB=2;"b"+extbase
extC=3;"c"+extbase
extD=4;"d"+extbase
extE=5;"e"+extbase
extF=6;"f"+extbase
extG=7;"g"+extbase
extH=8;"h"+extbase
extI=9;"i"+extbase
extJ=10;"j"+extbase
extK=11;"k"+extbase
extL=12;"l"+extbase
extM=13;"m"+extbase
extN=14;"n"+extbase
extO=15;"o"+extbase
extP=16;"p"+extbase
extQ=17;"q"+extbase
extR=18;"r"+extbase
extS=19;"s"+extbase
extT=20;"t"+extbase
extU=21;"u"+extbase
extV=22;"v"+extbase
extW=23;"w"+extbase
extX=24;"x"+extbase
extY=25;"y"+extbase
extZ=26;"z"+extbase
ssnoshifts=1;29
csnoshifts=2;30
ss=28 ;???
cs=(csnoshifts-32)&0xff ;???
csSpace=27;" "-32
ssSpace=28
csEnter=29;(Enter-32)&0xff
ssEnter=30;27
ssI=31;26

key_redraw=ssEnter ;TODO with H=1 (если сделать равным ssEnter, то при шедулинге через idle ssEnter словитс€ второй раз)

;всего управл€ющих комбинаций:
;1: nokey
;1: Enter
;12: цифры с CS, cs+Space, cs+Enter
;3: ss, cs, sscs
;6: ss+Q,+W,+E,+I,+Enter,+Space
;38 ext+кнопка
;=23+38=61, можно уместить в два набора 0..31, но так не помест€тс€ символы 0..31 как символы

;SO, SI занимать нельз€
;упр. коды, необходимые дл€ CP/M, передавать непосредственно (чем их меньше, тем больше отдельных ext+keys можно предусмотреть)
;ext+keys передавать как 0..31 (чтобы можно было ввести любой упр.код CP/M, надо ещЄ несколько клавиш дл€ остальных кодов)
;символы 0..31 передавать как SO, код+0xb0, SI
;остальные упр. коды (cs+digit, ext+digit, extSpace, extEnt, ssQWE) передавать как SO, код+0xd0, SI
;отдельный ext (Tab) передавать по отжатию
;нажати€ отдельных ss, cs не передавать, иначе CP/M приложени€ не смогут их отфильтровать (отжати€ клавиш тоже передать невозможно)

;00*nokey ^@ NUL - TODO убрать (GET_KEY будет сам делать YIELD до прихода событи€ клавиатуры/мыши, а чьЄ событие - как-то кодировать в H)
;01       ^A SOH All (WordLeft в TP) -- home
;02       ^B STX -- left
;03       ^C ETX Copy (PgDn в TP) (close app в MS-DOS) -- close app
;04       ^D EOT (Right в TP и ATM CP/M) -- del
;05       ^E ENQ (Up в TP) -- end
;06       ^F ACK Find (WordRight в TP) -- right
;07       ^G BEL Replace (Del в TP)
;08 cs0   ^H BS  BS! (BS в MS-DOS) (Up в TPlib) -- bs
;09       ^I HT  Tab! (Tab в MS-DOS) -- tab
;0A       ^J LF (Enter в ATM CP/M)
;0B       ^K VT (Left в TPlib) -- kill line
;0C       ^L FF  (FindNext в TP) -- update screen
;0D Enter ^M CR  Enter! (Enter в ATM CP/M и Notepad++) (Right в TPlib) (режим выделени€ в Win) -- enter
;0E       ^N SO  New -- next
;0F       ^O SI  Open -- flush
;10       ^P DEL Del (Down в TPlib) -- previous
;11       ^Q DC1 -- verbatim?
;12       ^R DC2 (PgUp? в TP) -- search back
;13       ^S DC3 Save (Left в TP и ATM CP/M) -- search forward
;14       ^T DC4 (DelWordRight в TP)
;15       ^U NAK -- numeric?
;16       ^V SYN Paste (Ins в TP) -- verbatim? pgup?
;17       ^W ETB
;18       ^X CAN Cut (Down в TP) (delete command в ATM CP/M)
;19       ^Y EM  DelLn
;1A       ^Z SUB Undo (EOF)
;1B csSpc ^[ SUB (Esc key, Esc symbol)
;1C ssSpc ^\ FS
;1D csEnt ^] GS
;1E ssEnt ^^ RS
;1F ssI   ^_ US

