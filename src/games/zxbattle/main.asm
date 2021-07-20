            DEVICE ZXSPECTRUM1024
TCP=1
        ifdef CLIENT
VIRTUALKEYS=1
        else
VIRTUALKEYS=0
        endif
JOYMASK_SELECT=0b00100000
JOYMASK_START =0b00010000
JOYMASK_FIRE  =0b10000000
JOYMASK_FIRE2 =0b01000000
JOYMASK_UP    =0b00001000
JOYMASK_DOWN  =0b00000100
JOYMASK_LEFT  =0b00000010
JOYMASK_RIGHT =0b00000001
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 

MANYLIVES=0;1 ;убрать при релизе!!!
TILES87=0
TILEHGT=8-TILES87
DRAWFOREST=1
KEMPSTON=1
            DEFINE  ProjName        ZXBattleCity
            DEFINE  ProjVer         1_6

        include "../../_sdk/sys_h.asm"

;************************* Возможные номера ошибок (errno)*************************
SHUT_RDWR 		EQU 2
ERR_EAGAIN		EQU 35		;/* Try again */
ERR_EWOULDBLOCK	EQU ERR_EAGAIN	;/* Operation would block */
ERR_INTR 		EQU 4
ERR_NFILE 		EQU 23
ERR_ALREADY 	EQU 37
ERR_NOTSOCK 	EQU 38
ERR_EMSGSIZE 	EQU 40    ;/* Message too long */
ERR_PROTOTYPE 	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_ECONNABORTED EQU	53	/* Software caused connection abort */
ERR_CONNRESET 	EQU 54
ERR_NOTCONN 	EQU 57

;************************* Протоколы соединений *************************
SOCK_STREAM EQU 0x01		;tcp/ip
SOCK_ICMP 	EQU 0x02		;icmp
SOCK_DGRAM 	EQU 0x03		;udp/ip

AF_INET EQU 2

TOPYLOAD=32;0
TOPY=0;32
TOPYVISIBLE=TOPY+8
        if TILES87
MAXY=(30-2)*8;224
        else
MAXY=(26-2)*8
        endif

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=200

pushbase=0x8000
        macro SETPGPUSHBASE
        SETPG32KLOW
        endm

        macro RECODEBYTE
        ld a,(de)
        ld ($+4),a
        ld a,(trecodebyteright)
        ld c,a
        dec de
        ld a,(de)
        dec de
        ld ($+4),a
        ld a,(trecodebyteleft)
        or c
        endm        

STACK=0x3ff0
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00

;TILEFLAGBIT=2
TILEFLAG0=0x18
TILEFLAG1=0x1c

WATERANIMTILE=102
NWATERANIMTILES=2

SPSIZ16=2
SPACT=32
SPSIZ8=0

SPRDROP=256+34
SPRBULLETUP=52
SPRBULLETRIGHT=54

SPRCLOUD0=256+44
SPRCLOUD1=256+46

;сейчас спрайты лежат так (реально есть только чётные номера):
;0..31,64..95,... (my tank level 0,1, enemy1) в spr0 (+256 - mirror hrz, +512 - mirror vert)
;32..63,96..127,... в spr1 (+256 - mirror hrz, +512 - mirror vert)
;TODO:
;256+ (my tank level 2 (+16),3 (+128+16), enemy2 (+0)) в spr2
;512+ (enemy 3 (+0),4 (+64),5 (+128)) в spr3

SPRMYTANKLEVEL0=0
SPRMYTANKLEVEL1=16
SPRMYTANKLEVEL2=256+16
SPRMYTANKLEVEL3=256+128+16

;my tank level 0,1,2,3 - sprite 0,16,256+16,256+128+16
;enemy tank sprites (add 8 for red version):
;SPRENEMY1=0+8;256+128
;SPRENEMY2=0+16;256+128+128
;SPRENEMY3=0+24;256+128+128+128
;SPRENEMY4=64+0;256+128+256+128
;SPRENEMY5=64+8;256+128+256+256
SPRENEMY1=0+64;256+128
SPRENEMY2=256;256+128+128
SPRENEMY3=512;256+128+128+128
SPRENEMY4=512+64;256+128+256+128
SPRENEMY5=512+128;256+128+256+256

SPRMEGASHIP=32;256+36

SPRBONUS0=96;80;256+128+16
SPRBONUS1=98;82;256+128+18
SPRBONUS2=100;84;256+128+20
SPRBONUS3=102;86;256+128+22
SPRBONUS4=104;88;256+128+24
SPRBONUS5=106;90;256+128+26
SPRBONUS6=108;92;256+128+28
SPRBONUS7=110;94;256+128+30
SPRBONUS8=112;192+32;256+128+32

SPRSTAR0=120;256+48
SPRSTAR1=122;256+50
SPRSTAR2=124;256+52
SPRSTAR3=126;256+54

SPRENE0=128+64+46;256+128+46
SPRENE1=128+64+48;256+128+48
SPRENE2=128+64+50;256+128+50
SPRENE3=128+64+52;256+128+52
SPRENE4=128+64+54;256+128+54

SPRBOOM0=56
SPRBOOM1=58
SPRBOOM2=60
SPRBOOM0_=48;256+56 ;big boom
SPRBOOM2_=50;256+60

SPRGAMEOVER0=256+40
SPRGAMEOVER1=256+42

BYTESPERTILE=1;2
BYTESPERTILELINE=(BYTESPERTILE*64);256

        macro PRCHAR_TILEMAP_HL
        ld (hl),a
         set 3,h
         ld (hl),TILEFLAG1 ;при печати тайла ставим биты изменения обоих экранов (а при печати спрайта надо только на текущем экране)
         res 3,h
         set 4,h
         ld (hl),TILEFLAG1 ;при печати тайла ставим биты изменения обоих экранов (а при печати спрайта надо только на текущем экране)
         res 4,h
        endm

        macro TILEMAPLINEUP
       	;LD	BC,-256
       	LD	BC,-BYTESPERTILELINE;-256
	ADD	HL,BC
        endm

        macro TILEMAPLINEDOWN
       	;LD	BC,256
       	LD	BC,BYTESPERTILELINE;256
	ADD	HL,BC
        endm

        macro TILEMAPLEFTLINEDOWN
       	;LD	BC,256-2
       	LD	BC,BYTESPERTILELINE-BYTESPERTILE;256-2
	ADD	HL,BC
        endm

        macro TILEMAPLEFT
        dup BYTESPERTILE
       	dec hl
        edup
	;dec hl
        endm

        macro TILEMAPRIGHT
        dup BYTESPERTILE
       	inc hl
        edup
	;inc hl
        endm

        org PROGSTART
begin
	jp MAINGO ;patched by prspr
MAINGO
        ld sp,STACK
        ;OS_HIDEFROMPARENT
        ld e,0 + 0x80 ;EGA + keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode) +8=noturbo, +0x80=keep gfx pages
        ld de,path
        OS_CHDIR
         ld e,1
         OS_SETSCREEN
         ld e,0
         OS_CLS
         ld e,0
         OS_SETSCREEN
         ld e,0
         OS_CLS

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        LD (pgmain4000),A
        ld a,h
        LD (pgmain8000),A
        ld a,l
        LD (pgmainc000),A

        OS_NEWPAGE
        ld a,e
        ld (pgmuzmain),a
        OS_NEWPAGE
        ld a,e
        ld (pgmuzend),a
        OS_NEWPAGE
        ld a,e
        ld (pgspr0),a
        OS_NEWPAGE
        ld a,e
        ld (pgspr1),a
        OS_NEWPAGE
        ld a,e
        ld (pgspr2),a
        OS_NEWPAGE
        ld a,e
        ld (pgspr3),a
        OS_NEWPAGE
        ld a,e
        ld (pgtiles),a
        OS_NEWPAGE
        ld a,e
        ld (pglvl0),a
        OS_NEWPAGE
        ld a,e
        ld (pglvl1),a
        OS_NEWPAGE
        ld a,e
        ld (pglvl2),a
        OS_NEWPAGE
        ld a,e
        ld (pgarea),a

	CALL	INSREADY				;Loading Hi-Score table, music, palette, sound FX and palette initialisation
	LD	HL,48000				;Sound FX initialisation
	CALL	AFXINIT
        
        ld hl,prsprqwid
        ld (0x0101),hl ;спрайты в файле подготовлены так, что выходят в 0x0100

       ifdef CLIENT
       
       if TCP
       if CLIENT
;create socket:
CONNECTIONERROR
	ld de,SOCK_STREAM+(AF_INET<<8)
	OS_NETSOCKET
	ld a,l
	or a
	jp m,CONNECTIONERROR;?C_EXIT
	ld (datasoc),a
	LD DE,web_ia
	OS_NETCONNECT
         ld a,l ;DimkaM 12.03.2019
	or a
	jp p,connect_ok
createsoc_err
	ld a,(datasoc)
	ld e,0
	OS_NETSHUTDOWN
	jp CONNECTIONERROR
;CONNECTIONERROR
connect_ok
       else ;SERVER
;SOCKET  OS_NETSOCKET(unsigned int);
;#define socket(domain, type, protocol) OS_NETSOCKET((domain<<8)+type)
        ;ld bc,1 ;domain???
	LD DE,513 ;type???
	OS_NETSOCKET ;Подключить TCP/IP сокет к хосту.???
        ld a,l
	or a
	jp m,CONNECTIONERROR;?C_EXIT
	LD (soc),A
	;a=socket
	LD DE,web_ia
;signed char OS_BIND(const struct sockaddr_in * addr, SOCKET socket);
;#define bind(socket, addr, address_len) OS_BIND(addr,socket)
	OS_BIND ;Присвоение сокету конкретного номера исходящего порта.
	LD a,(soc) ;socket
	;LD DE,0 ;backlog???
;signed char OS_LISTEN(int, SOCKET socket);
;#define listen(socket, backlog) OS_LISTEN(backlog,socket)
	OS_LISTEN ;Включить режим прослушивания исходящего порта(режим сервера) TCP/IP сокета.
WAIT_CLIENTS0
	LD a,(soc) ;socket
	;LD DE,0 ;addr???
;SOCKET OS_ACCEPT(const struct sockaddr_in * addr, SOCKET socket);
;#define accept(socket, addr, address_len) OS_ACCEPT(addr,socket)
	OS_ACCEPT ;ждём, когда подсоединятся
	BIT 7,L
	JR Z,ESTABLISHED
	CP ERR_EAGAIN
	JP NZ,ERR_EXIT	;обработка ошибки
	OS_YIELD		;не обязательно. Если время реагирования на подключение не критично,
						;то отдадим квант времени системе.
	JR WAIT_CLIENTS0	;никто не подключился, ждём
ESTABLISHED
	LD A,L				;удачно
	LD (datasoc),A	;сохраняем дескриптор сокета.
;	Возвращаемые значения в регистрах:
;		L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
;		А - errno при ошибке.
;	Возможные ошибки:
;		ERR_NOTSOCK 		- не действительный дескриптор сокета
;		ERR_ECONNABORTED	- общая ошибка сокета
;		ERR_EAGAIN			- входящих подключений пока нет
CONNECTIONERROR
ERR_EXIT
       endif
       
       else ;UDP
       
	ld de,0x0203
	OS_NETSOCKET
	ld a,l
	ld (soc),a
	or a
	jp m,inet_exiterr_nosoc
inet_exiterr_nosoc ;TODO
       if CLIENT==0
	ld a,(soc)
	LD DE,port_ia
	OS_BIND
        ld a,l
	or a
	jp m,inet_exiterr
inet_exiterr ;TODO
       endif 
       
       endif ;UDP
       endif 

	JP	PRESTART;S

        ds 0x200-$
sprlist
	ds 85*6
sprlistsz=$-sprlist
;+0: y
;+1: 2(ysize:SPSIZ16) +0x20(SPACT) +0x40(deact) +0x80(mirrorvert) +1(SPSIZBS)
;+2: x
;+3: 2(xsize:SPSIZ16) +1(SPSIZBS) +0x80(mirrorhor)
;+4,5: pattern number

       macro DWBIGENDIAN data
        db data/256
        db data&0xff
       endm

       ifdef CLIENT 
soc
        db 0
datasoc
        db 0

       if TCP
;TCP:
curport=$+1
web_ia:
	defb 0
        DWBIGENDIAN 20001 ;db 0,80
        db 192,168,1,177;127,0,0,1 ;ip (big endian) ;connect to 192.168.1.177
        ds 8 ;reserved
       else
;UDP:
;struct sockaddr_in {unsigned char sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};
        if CLIENT
;client: from 192.168.1.2 to 192.168.1.177
port_ia:
	defb 0
        DWBIGENDIAN 20001 ;db 0,80
        db 192,168,1,177;127,0,0,1 ;ip (big endian)
;port_iarecv:
;	defb 0
;        db 100,53 ;port (big endian)
;        db 192,168,1,177 ;ip (big endian)

        else

;server: from 192.168.1.177 to 192.168.1.2
port_ia:
	defb 0
        DWBIGENDIAN 20001 ;db 0,80
        db 255,255,255,255 ;ip (big endian)
;port_iasend:
;	defb 0
;        db 100,53 ;port (big endian)
;        db 192,168,1,2 ;ip (big endian)
        endif
       endif
        
       endif ;ifdef CLI

PRESTART;S
	;LD	A,(ENN) ;resources loaded?
	;CP	1
	;JP	Z,ZZZZ2 ;skip load
       call loadresources
			;LD      HL,(#5CF4)				;Save position of Levels on disk
			;LD		(DiskAddrLevels),HL

;vertical scroll
        call setpgsscr40008000
        ld de,bgfilename
        call bgpush_prepare
        call setpgsmain40008000

        call swapimer      

       ifdef CLIENT
        ld de,fn_log
        OS_CREATEHANDLE
        ld a,b
        ld (loghandle),a
        
        OS_HIDEFROMPARENT
       endif

STARTS
;сюда можем попасть из игры
        ld sp,STACK

	 LD A,1
	 LD (NEWLEVEL),A ;иначе рычит в меню
         ld a,5
	 ld (SOUNDGO),a ;иначе остаток от рычания после гамовера?
         call afxinit
	LD	HL,BONUS2
	LD	DE,BONUS
	LD	BC,96
	LDIR
	;LD	BC,PAGE3
	;LD	A,#C3
	;OUT	(C),A
        call setpgc3
	CALL	#C000 ;init muzmain
	CALL	#CBB8 ;init muzboss
	LD	A,200+24
	LD	(SOUNDW),A ;time until music stops
	CALL	POINTHI ;формирует в TEXT4 строку со счётом
	XOR	A
	LD	(NEWTAN1),A
	LD	(NEWTAN2),A
	LD	A,(MAP)
	CP	255
	JR	Z,FGF2
        XOR	A ;first level
	 ;ld a,31 ;18"19" и 23"24" трудные
	LD	(MAP),A
FGF2

ZZZZ2
        ;ld ix,UNITS
        ;ld (ix+UNIT_YESORNOT),0
         ;xor a
         ;ld (sprlist+1),a ;disable sprite #0
         call clearsprlist
         call clstiles

	;LD	BC,VCONFIG; CHANGE VIDEO RESOLUCION 1
	;LD	A,VID321X+1
	;OUT	(C),A
	;LD	BC,VPAGE; VRAM CHANGE
	;LD	A,#10
	;OUT	(C),A
	;LD	BC,BORDER
	;LD	A,1
	;OUT	(C),A
        call border1
	CALL	CLSSTART ;???
	LD	A,2
	LD	(FIGH),A ;какой-то признак deact спрайтов??? (потом не обнуляется!)

        ld hl,108
        ld (callpush_curscroll),hl

;Main menu cycle!
;K inject here! TODO
         call doscreen
         call doscreen
         ;ld b,24
         ;halt
         ;djnz $-1
       ld a,(timer)
       ld (KERNSoldtimer),a
       ld (scrolloldtimer),a
;цикл показа и обработки меню
KERNS
     ifdef CLIENT
      if CLIENT
       call sendjoyTMP
       ld hl,menucheckkeys
       call readfrominet_tojoy1joy2 ;читать ровно одно сообщение, выполнить логику. и так пока есть сообщения
      else
       call readfrominet_tojoy2 ;может быть принято сколько угодно сообщений - берём последнее
       call sendjoy1joy2 ;в каждом цикле логики
       call menucheckkeys
      endif
     else
      call menucheckkeys
     endif

      call menuchangetimer ;при окончании таймера вызывает autounpress start
      call menudraw
      jr KERNS

menudraw
	LD	A,(STR6) ;time in startmenu
	;CP	218
	;CALL	Z,STR77 ;autounpress start
	;CP	219
	;CALL	Z,menu_printcopyrights;STR7 ;print text TEXT3 (copyrights), TEXT4 (hiscores)
	CP	220
	JP	nc,noscroll;STR4
        ld hl,(callpush_curscroll)
        bit 7,h
        jr nz,noscroll;STR4 ;end of scroll
      call menuscroll
       ;call setpgc3
       ;call #C000 ;init muzmain
       ld a,(SOUNDW)
       or a
       call z,afxinit ;stop sound
	ret;jp KERNS
noscroll;STR4
       call menuscreen_tank
         call doscreen        
	ret;JP KERNS ;STR44

stopscroll_draw
        ld de,512-200-8
        ld (callpush_curscroll),de
        call bgpush_draw ;359975t
	CALL menu_printcopyrights;STR7 ;print text TEXT3 (copyrights), TEXT4 (hiscores)
       call menuscreen_tank
         call doscreen ;содержит changescrpg и waitchangescr
        ;call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
        ;halt
        call bgpush_draw ;359975t
	CALL menu_printcopyrights;STR7 ;print text TEXT3 (copyrights), TEXT4 (hiscores)
        call setpgsmain40008000
        ld h,-1
        ld (callpush_curscroll),hl
       call menuscreen_tank
         jp doscreen        
        ;ret
        
        if 1==1
STR3
	LD	A,(STR)
	DEC	A
	LD	(STR),A ;--scroll page?
	LD	HL,65535-228
	LD	(STR2),HL ;scroll position?
	JP	STR5
        endif

STR77
	PUSH	AF
	LD	A,1 ;start unpressed
	LD	(STAKEY),A
	POP	AF
	RET

menuchangetimer
        ld a,(timer)
KERNSoldtimer=$+1
        ld b,0
        ld (KERNSoldtimer),a
        sub b
        ld c,a
        ld b,0
        ret z ;jr z,STR44
       ld a,(STR6)
      cp 220
       ret nc
       add a,c
       ld (STR6),a ;time in start menu
      cp 220
        ret nc
	CALL STR77 ;autounpress start
        ret

menuscroll
       if 1==1
        ld a,(timer)
scrolloldtimer=$+1
        ld bc,0
        ld (scrolloldtimer),a
        sub c
        ld c,a
        ld hl,(callpush_curscroll)
        ;bit 7,h
        ;jr nz,STR4 ;end of scroll
        ld de,512-200-8
        or a
        sbc hl,de
	jr nc,stopscroll
        call bgpush_inccurscroll ;bc=scroll increment (signed)
scroll_wait0
       ld a,(timer)
lastscrtimer=$+1
       cp 0
       jr z,scroll_wait0 ;wait screen change
        call bgpush_draw ;359975t
        call setpgsmain40008000
       ld a,(timer)
       ld (lastscrtimer),a
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
        ret;jp STR44
stopscroll
        call stopscroll_draw
STR5
       else
	INC	A
	LD	(STR6),A ;++time in startmenu
	LD	A,(STR) ;scroll page?
	CP	15
	JP	Z,STR4 ;end of scroll?
	LD	HL,(STR2) ;scroll position?
	LD	A,H
	CP	#C0
	JP	Z,STR3 ;go to previous scroll page
	LD	DE,256
	SBC	HL,DE
STR5	LD	(STR2),HL ;scroll position?
       if 1==0
	PUSH	HL
	POP	DE
	LD	HL,#C000
	LD	B,51 ;wid/8-1?
	LD	C,154 ;hgt-1?
	LD	A,#C2
	LD	(PAGEFR),A
	LD	A,(STR)
	LD	(PAGETO),A
	LD	A,%00010001
	CALL	DMASTART
       endif
       endif
;STR44
        ret

menuscreen_tank
	LD	HL,(KORM);---X
	LD	BC,(KORM2);----Y
       if TILES87
       else
        ld a,c
        sub 16 ;костыль
        ld c,a
       endif
	LD	A,(TANK) ;sprite phase
	ADD	A,4;44 ;sprite pattern number
	LD	D,2 ;size
	CALL	PRINT
	LD	A,(TANKP) ;anim timer
	INC	A
	CP	4
	CALL	Z,TANKP2 ;next sprite phase
	CP	8
	CALL	Z,TANKP3 ;prev sprite phase
	LD	(TANKP),A ;anim timer
	;LD	BC,TSCONFIG; SPRITE PRINT
	;LD	A,%10000000
	;OUT	(C),A
        ret

menucheckkeys
	CALL	EXIT ;if break, set (MAP)=31
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_START
       else
	LD      HL,(Keys1PlStart)
	LD      B,H
	LD      C,#FE
	IN      A,(C)
        AND     L
       endif
oldkeystart1=$+1
       ld c,0xff
       ld (oldkeystart1),a
	CALL	Z,STR8 ;press start
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_FIRE
       else
	LD      HL,(Keys1PlFr)
	LD      B,H
	LD      C,#FE
	IN      A,(C)
        AND     L
       endif
oldkeyfire1=$+1
       ld c,0xff
       ld (oldkeyfire1),a
	CALL	Z,STR8 ;press start
        ;ret
;menucheckkeys_up_down
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_DOWN
       else
	LD      HL,(Keys1PlDn)		;LD		HL,Keys1PlDn+2
	LD      B,H					;LD		BC,(Keys1PlDn)
	LD      C,#FE				;CALL	CHBIT
	IN      A,(C)
        AND     L
       endif
oldkeydd2=$+1
       ld c,0xff
       ld (oldkeydd2),a
	CALL	Z,KEYDD2
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_UP
       else
	LD      HL,(Keys1PlUp)		;LD		HL,Keys1PlUp+2
	LD      B,H					;LD		BC,(Keys1PlUp)
	LD      C,#FE				;CALL	CHBIT
	IN      A,(C)
        AND     L
       endif
oldkeyuu2=$+1
       ld c,0xff
       ld (oldkeyuu2),a
	CALL	Z,KEYUU2
        ret
        
STR8
;press start
      if 1
       cp c
       ret z
        call stopscroll_draw
        jp CHEKSTA ;use menu option depending on Y (KORM2)
      else
        LD	A,(STAKEY) ;start unpressed?
	CP	1
	jp	Z,CHEKSTA ;use menu option depending on Y (KORM2)
	LD	A,(STR6) ;time in startmenu
	CP	220
	JR	Z,STR10 ;wait start key unpress
	LD	A,219
	LD	(STR6),A ;??? time in startmenu
       if 1==1
        call stopscroll_draw
	;RET
       else
	LD	HL,#C000+26+8192+1024
	LD	(STR2),HL ;scroll position in page?
	LD	A,#10
	LD	(STR),A ;scroll page?
	CALL	CLSSTART ;???
	RET
       endif
STR10
      if 1==0
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_START
       else
	LD      HL,(Keys1PlStart)
	LD      B,H
	LD      C,#FE
	IN      A,(C)
        AND     L
       endif
	JR	Z,STR10
       if VIRTUALKEYS
        ld a,(joy1state)
        and JOYMASK_FIRE
       else
	LD      HL,(Keys1PlFr)
	LD      B,H
	LD      C,#FE
	IN      A,(C)
        AND     L
       endif
	JR	Z,STR10
      endif
	LD	A,1
	LD	(STAKEY),A ;start unpressed
	RET
      endif

CHEKSTA
	LD	HL,(KORM2) ;Y
	LD	A,L
	CP	126
	JP	Z,FIGHT
	CP	136
	JP	Z,FIGHT
	CP	146
	JP	Z,EDITOR;START ;editor
	CP	156
	JP	Z,REDIFIN
	RET

CLSSTART
        if 1==1 ;???
        call clstiles
        else
	LD	HL,25998
	LD	A,%00010001
	LD	(HL),A
	INC	HL
	LD	(HL),A
	DEC	HL
	LD	DE,#C000
	LD	B,95 ;wid/8-1?
	LD	C,240 ;hgt-1?
	LD	A,#05
	LD	(PAGEFR),A
	LD	A,#10
	LD	(PAGETO),A
	LD	A,%00110100
	CALL	DMASTART
	HALT
	HALT
        endif
	RET

STAKEY	DEFB	0 ;1=start unpressed
STR	DEFB	#13 ;scroll page?
STR2	DEFW	65535-228 ;scroll position in page?
STR6	DEFB	0 ;time in startmenu

EXIT
	LD      BC,#7FFE
	IN	A,(C)
	AND	%0000001
	RET	NZ
	LD	BC,#FEFE
	IN	A,(C)
	AND	%0000001
	RET	NZ
       halt
       call setpgc3
       CALL	#C000 ;init muzmain
       call swapimer
       QUIT
	;LD	A,31
	;LD	(MAP),A
	;RET

reter
        ret

KERNF
      ifdef CLIENT
      if CLIENT
       call sendjoyTMP
      else
       call readfrominet_tojoy2 ;может быть принято сколько угодно сообщений - берём последнее
      endif
      endif

        call doscreen_and_logic

;TODO эти события тоже обслуживать в logic:
        CALL	ENDGAME
	LD		A,(NEWLEVEL)
	CP		1
	CALL	Z,END5

	JR	KERNF

doscreen
        call showsprites
;закончили рисовать
       ld a,(timer)
       push af
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
       pop bc ;b=timer на момент changescrpg
       jp waitchangescr0

doscreen_and_logic
;logic=56000..103000
        call showsprites
;закончили рисовать
       ld a,(timer)
       push af
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали

;логика
;... её вызывать столько раз, сколько прошло прерываний!
mainloop_uvwaittimer0
        ld a,(timer)
uvoldtimer=$+1
        ld b,0
        ld (uvoldtimer),a
        sub b
        ld b,a
        jr z,mainloop_uvwaittimer0 ;если ни одного прерывания не прошло, крутимся тут
        cp 4
        jr c,$+4
        ld b,4
;b=сколько прошло прерываний
      ifdef CLIENT
      if CLIENT
       ;call sendjoyTMP
       ld hl,logic
       call readfrominet_tojoy1joy2 ;читать одно сообщение, выполнить логику - и так пока есть сообщения
      else
mainloop_uvlogic0
        push bc
       ;call readfrominet_tojoy2 ;может быть принято сколько угодно сообщений - берём последнее
       call sendjoy1joy2 ;в каждом цикле логики
        call logic
        pop bc
        djnz mainloop_uvlogic0
      endif
      else
mainloop_uvlogic0
        push bc
        call logic
        pop bc
        djnz mainloop_uvlogic0
      endif


;ждём физического переключения экрана!
;можем начать новую отрисовку, только если с момента changescrpg прошло хотя бы одно прерывание (возможно, внутри logic)
       pop bc ;b=timer на момент changescrpg
waitchangescr0
        ld a,(timer)
        cp b
        jr z,waitchangescr0
        ret

;pal
       include "pal.ast"

clearsprlist
        ld hl,sprlist
        ld de,sprlist+1
        ld bc,sprlistsz-1
        ld (hl),0
        ldir
        ret

clstiles
        ld hl,tilemap
        ld de,tilemap+1
        ld bc,BYTESPERTILELINE*30-1
        ld (hl),0
        ldir
        ld bc,TILEFLAG1*0x0101
       if TILES87
        ld hl,tilemap+0x800+BYTESPERTILELINE
       else
        ld hl,tilemap+0x800+(BYTESPERTILELINE*TOPYVISIBLE/8)
       endif
        call resettileflags
       if TILES87
        ld hl,tilemap+0x1000+BYTESPERTILELINE
       else
        ld hl,tilemap+0x1000+(BYTESPERTILELINE*TOPYVISIBLE/8)
       endif
        ;call resettileflags
        jp resettileflags

clstiles_field
        call clstiles
        ld hl,tilemap+34
        ld de,BYTESPERTILELINE-6
        ld bc,0x600+30 ;b=wid, c=hgt (chrs)
clstileblock0
        push bc
        ld (hl),0xe0
        inc hl
        djnz $-3
        pop bc
        add hl,de
        dec c
        jr nz,clstileblock0
        ret

clstiles_white
        call clstiles
        ld hl,tilemap
        ld de,BYTESPERTILELINE-40
        ld bc,40*256+30 ;b=wid, c=hgt (chrs)
        jr clstileblock0

prchar_tilemap_hl
;a=char (kept)
;hl=tilemap
        ;ex de,hl
        ;call prchar_tilemap
        ;ex de,hl
        PRCHAR_TILEMAP_HL
        ret
prchar_tilemap
;a=char (kept)
;de=tilemap
        ld (de),a
         if BYTESPERTILE == 2
         inc de
         ex de,hl
         ld (hl),0xc0 ;при печати тайла ставим биты изменения обоих экранов (а при печати спрайта надо только на текущем экране)
         ex de,hl
         dec de
         else
         ex de,hl
         set 3,h
         ld (hl),TILEFLAG1 ;при печати тайла ставим биты изменения обоих экранов (а при печати спрайта надо только на текущем экране)
         res 3,h
         set 4,h
         ld (hl),TILEFLAG1 ;при печати тайла ставим биты изменения обоих экранов (а при печати спрайта надо только на текущем экране)
         res 4,h
         ex de,hl
         endif
        ret


loadfile
;de=filename
;hl=addr
        push hl ;addr
        OS_OPENHANDLE
        pop de ;addr
        push bc ;b=handle
        ld hl,0x4000 ;max size
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

savefile
;de=filename
;hl=addr
;bc=size
        push hl ;addr
        push bc ;size
        OS_CREATEHANDLE
        pop hl ;size
        pop de ;addr
        push bc ;b=handle
        OS_WRITEHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

bgfilename ;needs 40008000?
        db "menu.bmp",0

        macro PRTILE
       dup TILEHGT-1
        ld a,(de)
        inc d
        ld (hl),a
         set 6,h
        ld a,(de)
        inc d
        ld (hl),a
         set 5,h
        ld a,(de)
        inc d
        ld (hl),a
         res 6,h
        ld a,(de)
        inc d
        ld (hl),a
        add hl,bc
       edup
        ld a,(de)
        inc d
        ld (hl),a
         set 6,h
        ld a,(de)
        inc d
        ld (hl),a
         set 5,h
        ld a,(de)
        inc d
        ld (hl),a
         res 6,h
        ld a,(de)
        ld (hl),a   
        endm

drawlefttile
        ;jp drawleftandrighttiles
        ld hl,-2-0x800
        add hl,sp
;de=screen line start
     push de
        res 3,h
         ld a,l
         and 0x3f
         add a,e
         ld e,a
         jr nc,$+3
          inc d
        ld l,(hl)
        ex de,hl
        ld d,0x60
        PRTILE
     pop de
        ret

drawrighttile
        ;jp drawleftandrighttiles
        ld hl,-2+1-0x800
        add hl,sp
;de=screen line start
     push de
        res 3,h
         ld a,l
         and 0x3f
         add a,e
         ld e,a
         jr nc,$+3
          inc d
        ld l,(hl)
        ex de,hl
        ld d,0x60
        PRTILE
     pop de
        ret

drawleftandrighttiles
        ld hl,-2+1-0x800
        add hl,sp
;de=screen line start
     push de
        res 3,h
        ld a,(hl) ;right tile
        ex af,af' ;'
        dec l
         ld a,l
         and 0x3f
         add a,e
         ld e,a
         jr nc,$+3
          inc d
        ld l,(hl) ;left tile
        ex de,hl
       push hl ;screen (even x)
        ld d,0x60
        PRTILE
       pop hl ;screen (even x)
       inc l ;screen (odd x)
        ex af,af' ;'
        ld e,a ;right tile
        ld d,0x60
        PRTILE
     pop de
        ret

nexttileliner
        ld hl,TILEHGT*40;-40
        add hl,de ;screen
        ex de,hl
        ld hl,BYTESPERTILELINE-40-2
        add hl,sp
        ld sp,hl
        ret

showtiles
        ld (showtilessp),sp
showtilesaddrpatch=$+1
       if TILES87
        ld sp,tilemap+0x800+BYTESPERTILELINE
       else
        ld sp,tilemap+0x800+(BYTESPERTILELINE*TOPYVISIBLE/8)
       endif
        ld de,0x8000
        ld bc,40-0x2000
       ret
;если флаг отрисовки хранится отдельно (через set N,d), то:
        ;ret -> пропуск или рисование левого или правого или обоих тайлов
;но тогда надо флаги для 0 и 1 экранов хранить в отдельных таблицах, т.к. они запарываются стеком. и после отрисовки залить текущую таблицу push'ами
endtileliner
showtilessp=$+1
        ld sp,0
;сейчас при куче спрайтов
;53000 + 8419(resettileflags)
;TODO делать reset только там, где отрисовка, и по прерыванию (причём прерывание должно восстанавливать адрес nexttileliner)
        ret

resettileflags
;hl=start of visible tiles
        ;ld bc,TILEFLAG0*0x0101
;bc=TILEFLAG0*0x0101 or TILEFLAG1*0x0101
        ld (filltileflagsp),sp
       if TILES87
        ld de,28*64+40+2
        ld hx,29
       else
        ld de,24*64+40+2
        ld hx,25
       endif
        add hl,de
        ld de,endtileliner
filltileflagline0
        ld sp,hl
        push de
        dup 40/2
        push bc
        edup
        ld de,-BYTESPERTILELINE
        add hl,de
        ld de,nexttileliner
        dec hx
        jp nz,filltileflagline0
filltileflagsp=$+1
        ld sp,0
        ret

showsprites
        ld hl,tileaddrpatch+1
        ld a,(hl)
        xor 0x18
        ld (hl),a
        ld hl,showtilesaddrpatch+1
        ld a,(hl)
        xor 0x18
        ld (hl),a
        
        call setpgsscr8000c000
        call setpgc2_4000;setpggfxc000
         ;jr $
        call showtiles
        
        ld hl,(showtilesaddrpatch)
        ld bc,TILEFLAG0*0x0101
         ;ld bc,TILEFLAG1*0x0101
        call resettileflags
        
        call setpgsscr40008000
       ;jp showsprites0q 
        ld ix,sprlist
        ld b,85
showsprites0
;+0: y
;+1: 2(ysize:SPSIZ16) +0x20(SPACT) +0x40(deact) +0x80(mirrorvert) +1(SPSIZBS)
;+2: x
;+3: 2(xsize:SPSIZ16) +1(SPSIZBS) +0x80(mirrorhor)
;+4,5: pattern number
        ld a,(ix+1)
        or a
        jp z,showsprites0skip
        bit 6,a
        jp nz,showsprites0skip
        ;jp nz,showsprites0q ;не видно бонус
        bit 5,a
        jp z,showsprites0skip
;ix+1 bit7 = mirror vert
;ix+3 bit7 = mirror hor
        rla
        ld a,(ix+3)
        rla
        rla
        and 3 ;%000000vh
        or 0xc0
        ld (prspr_type+1),a
       push bc
        ld a,(ix+4) ;sprite pattern ;00(up/down),04(left/right)
        ld (prspr_type),a
        bit 5,a
        jr nz,prspr_setpgright
       bit 0,(ix+5) ;+256
        call z,setpgc0 ;left sprites (tanks)
        call nz,setpgspr2
       bit 1,(ix+5) ;+512
        call nz,setpgspr3
        jp prspr_setpgq
prspr_setpgright
        call setpgc1 ;right sprites (bullets)
prspr_setpgq
       if TILES87
        ld c,(ix+0) ;y
        ld a,c
         add a,4+(2*8)
        rra
        rra
        rra
        and 0x1f ;*1/8
        cpl
        ;inc a
        add a,c ;*7/8 (округление такое: 0,1,2,3,3,4,5,6, 7,8,9,10,10,11,12,13...
         add a,sprmaxhgt-1 +2 -6;7
         cp 199+sprmaxhgt-1 ;защита от второго взрыва сверху с отрицательным y
         jp nc,showsprites0popbcskip
         sub sprmaxhgt-1;6;7
         ;sub 6;7
       else
        ld a,(ix+0) ;y
        add a,sprmaxhgt-1 -TOPYVISIBLE
         cp 199+sprmaxhgt-1 ;защита от второго взрыва сверху с отрицательным y
         jp nc,showsprites0popbcskip
         sub sprmaxhgt-1;6;7       
       endif
        ld c,a ;y
        ld a,(ix+3) ;xsize, xhsb
        rra
        ld a,(ix+2) ;x
        rra
        add a,sprmaxwid-1
        ld e,a
prspr_type=$+2
        ld iy,(0xc000)
;e=x = -(sprmaxwid-1)..159 (кодируется как x/2+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
       push ix
       push de
         ld a,(iy-3) ;sprhgt
         cp 16
         jr nz,prspr_bighgt
        call prspr
       pop de
       pop ix
       ;ставим флаги обновления на тайлах под спрайтом
        ld c,(ix+0) ;y
       ld a,e ;x/2
       sub sprmaxwid-1
       jr nc,$+3
        xor a
       and 0xfc
       ld e,a ;x/2
       ld a,c ;y
       and 0xf8
        cp 8*29;30
        jr c,$+3
         xor a
       ld l,a
       ld h,0
       ld d,h;0
       add hl,hl
       add hl,hl
       add hl,hl ;Y*64
       if BYTESPERTILE == 2
        add hl,hl ;*128
       endif
       srl e
       if BYTESPERTILE == 1
       srl e
       endif
       add hl,de
tileaddrpatch=$+1
       ld de,tilemap+0x800
       add hl,de
        ld a,(ix+2) ;x
        and 7
       ld a,TILEFLAG1
       ld (hl),a
        jr z,prsprwid2
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       ld de,BYTESPERTILELINE-(2*BYTESPERTILE)
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
      if TILES87
;из-за тайлов высотой 7 при y=6 приходится обновить четыре ряда:
        ld a,c ;y
        cpl
        and 7
        jr nz,prsprhgt3q
        ld a,TILEFLAG1
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
      endif
       jp prsprhgt3q

prsprwid2
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       ld de,BYTESPERTILELINE-(1*BYTESPERTILE)
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
      if TILES87
;из-за тайлов высотой 7 при y=6 приходится обновить четыре ряда:
        ld a,c ;y
        cpl
        and 7
        jr nz,prsprhgt3q
        ld a,TILEFLAG1
       add hl,de
       ld (hl),a
       dup BYTESPERTILE
       inc l
       edup
       ld (hl),a
      endif
       jp prsprhgt3q
prspr_bighgt
        call prspr
       pop de
       pop ix
     if 1==1
       ;ставим флаги обновления на тайлах под спрайтом
        ld c,(ix+0) ;y
       ld a,e ;x/2
       sub sprmaxwid-1
       jr nc,$+3
        xor a
       and 0xfc
       ld e,a ;x/2
       ld a,c ;y
       and 0xf8
       ld l,a
       ld h,0
       ld d,h;0
       add hl,hl
       add hl,hl
       add hl,hl ;Y*64
       if BYTESPERTILE == 2
        add hl,hl ;*128
       endif
       srl e
       if BYTESPERTILE == 1
       srl e
       endif
       add hl,de
       ld de,(tileaddrpatch)
       add hl,de
       ld de,BYTESPERTILELINE-(4*BYTESPERTILE)
      if TILES87
       ld b,6
      else
       ld b,5
      endif
prspr_bighgt1
       ld a,TILEFLAG1
       ld (hl),a
      dup 4
       dup BYTESPERTILE
       inc hl ;нельзя l, не компенсируется add
       edup
       ld (hl),a
      edup
      ld a,h
       add hl,de
      xor h
      and 0xf8 ;остаёмся в рамках одной карты флагов!
      xor h
      ld h,a
       djnz prspr_bighgt1
     endif
       jp prsprhgt3q
prsprhgt3q

;если спрайт - танк (не бонус)
;draw tree (one or many) above sprite if needed
       if TILES87 || !DRAWFOREST
       else
        bit 5,(ix+4)
        jp nz,prspr_tree_q ;не танк
        call setpgc1 ;right sprites (bullets)
        ld a,(ix+0) ;y
         and 0xf0
        ld l,a ;y for tilemap
        sub TOPYVISIBLE
        ;add a,sprmaxhgt-1 -TOPYVISIBLE
         ;cp 199+sprmaxhgt-1 ;защита от второго взрыва сверху с отрицательным y
         ;jp nc,showsprites0popbcskip
         ;sub sprmaxhgt-1;6;7       
        ld c,a ;y for prspr
        ld a,(ix+3) ;xsize, xhsb
        rra
        ld a,(ix+2) ;x
        rra
         and 0xf8
       ld e,a ;x/2 for tilemap
        add a,sprmaxwid-1
        ld b,a ;x/2 for prspr
       ;ld l,c ;y = Y*8
       ld h,0
       ld d,h;0
       add hl,hl
       add hl,hl
       add hl,hl ;Y*64
       srl e
       srl e ;x/8
       add hl,de
       ld de,tilemap;+(TOPYVISIBLE/8*BYTESPERTILELINE)
       add hl,de
       push bc
       push hl
       ld e,b ;x/2
       ld a,(hl)
       cp 24 ;tree
        ld iy,(0xc000+62)
;e=x = -(sprmaxwid-1)..159 (кодируется как x/2+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
       push ix
        call z,prspr ;округление x влево, y вверх
       pop ix
       pop hl
       pop bc
       
        ld a,(ix+2) ;x
        and 0x0e
        jr z,prspr_tree_xrightq ;округлять x вправо не требуется
       push bc
       push hl
       inc l
       inc l
       ld a,b ;x/2
       add a,8
       ld e,a
       ld a,(hl)
       cp 24 ;tree
        ld iy,(0xc000+62)
;e=x = -(sprmaxwid-1)..159 (кодируется как x/2+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
       push ix
        call z,prspr ;округление x влево, y вверх
       pop ix
       pop hl
       pop bc
prspr_tree_xrightq
       
        ld a,(ix+0) ;y
        and 0x0f
        jr z,prspr_tree_q ;округлять y вниз не требуется
       ld de,BYTESPERTILELINE*2
       add hl,de
       ld a,c
       add a,16
       ld c,a ;y
       push bc
       push hl
       ld e,b ;x/2
       ld a,(hl)
       cp 24 ;tree
        ld iy,(0xc000+62)
;e=x = -(sprmaxwid-1)..159 (кодируется как x/2+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
       push ix
        call z,prspr ;округление x влево, y вверх
       pop ix
       pop hl
       pop bc

        ld a,(ix+2) ;x
        and 0x0e
        jr z,prspr_tree_q ;округлять x вправо не требуется
       inc l
       inc l
       ld a,b ;x/2
       add a,8
       ld e,a
       ld a,(hl)
       cp 24 ;tree
        ld iy,(0xc000+62)
;e=x = -(sprmaxwid-1)..159 (кодируется как x/2+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
       push ix
        call z,prspr ;округление x влево, y вверх
       pop ix       
prspr_tree_q
       endif
        
       
showsprites0popbcskip
       pop bc
showsprites0skip
        ld de,6
        add ix,de
        dec b
        jp nz,showsprites0
showsprites0q
;сейчас примерно 82000 при куче спрайтов

        call setpgsmain40008000
        ;call setpg8
        ;ret
setpg8 ;area?
pgarea=$+1
        ld a,0
        SETPGC000
        ret

border1
        xor a
        ld (curborder),a
        ;ld e,0;1
        ;OS_SETBORDER
        ret
border8
        ld a,12
        ld (curborder),a
        ;ld e,12
        ;OS_SETBORDER
        ret

setpgc ;ending music
pgmuzend=$+1
        ld a,0
        SETPGC000
        ret
setpg16 ;levels 01-16
pglvl0=$+1
        ld a,0
        SETPGC000
        ret
setpg17 ;levels 17-32
pglvl1=$+1
        ld a,0
        SETPGC000
        ret
setpg18 ;level 00 user
pglvl2=$+1
        ld a,0
        SETPGC000
        ret
setpgc0 ;spr0 ;left sprites (tanks)
pgspr0=$+1
        ld a,0
        SETPGC000
        ret
setpgc1 ;spr1 ;right sprites (bullets)
pgspr1=$+1
        ld a,0
        SETPGC000
        ret
setpgc2_4000
        ld a,(pgtiles)
        SETPG4000
        ret
setpgc2 ;tiles
pgtiles=$+1
        ld a,0
        SETPGC000
        ret
setpgc3 ;main music, boss music
pgmuzmain=$+1
        ld a,0
        SETPGC000
        ret
setpgspr2
pgspr2=$+1
        ld a,0
        SETPGC000
        ret
setpgspr3
pgspr3=$+1
        ld a,0
        SETPGC000
        ret
setpg
;a=(SM1),(SM2) ;#10..#13???
       ret
        ;ld ($+4),a
        ;ld a,(tpgs)
         ld c,a
         ld b,tpgs/256
         ld a,(bc)
        SETPGC000
        ret


genpush_newpage
;заказывает страницу, заносит в tpushpgs, a=pg
        push bc
        push de
        push hl
        push ix
        OS_NEWPAGE
        pop ix
        ld a,e
        ld (ix),a
        ld de,4
        add ix,de
        pop hl
        pop de
        pop bc
        ret

	INCLUDE	"bgpush.asm"
	INCLUDE	"bmp.asm"
        include "../../_sdk/file.asm"
bgpush_bmpbuf=0x4000 ;ds 1024;320 ;заголовок bmp или одна строка
bgpush_loadbmplinestack=bgpush_bmpbuf+1024 ;ds pushhgt*2+32

        align 256
trecodebyteleft
        dup 256
;%00003210 => %.3...210
_3=$&8
_210=$&7
        db (_3*0x08) + (_210*0x01)
        edup
        
trecodebyteright
        dup 256
;%00003210 => %3.210...
_3=$&8
_210=$&7
        db (_3*0x10) + (_210*0x08)
        edup

        align 256
tpushpgs ;номера 0..15
tpgs ;номера 16..
        ds 256
        ;align 256
        ds TILEFLAG0*256+TILEFLAG0-$
        ret
        ds TILEFLAG0*256+TILEFLAG1-$
        jp drawlefttile
        ds TILEFLAG1*256+TILEFLAG0-$
        jp drawrighttile
        ds TILEFLAG1*256+TILEFLAG1-$
        jp drawleftandrighttiles

	INCLUDE	"int.asm"

        ds 0x2000-$
tilemap
       if BYTESPERTILE == 1
        ds 64*32*BYTESPERTILE
        ds 64*32*BYTESPERTILE ;scr0 update flags
       endif
        ds 64*35*BYTESPERTILE ;scr1 update flags ;40*25 ;35 - запас на любой y при обновлении 4 рядов

	INCLUDE	"mem.asm"
	INCLUDE	"prspr.asm"

	;display $,"<0x3ee0"
        ds 0x3ee0-$
        ds 0x4000-$

	INCLUDE	"units.asm"
        INCLUDE	"XASASM1.a80"
	INCLUDE	"BC1.a80"
	INCLUDE	"BC2.a80"
	INCLUDE	"BC3.a80"
	INCLUDE	"BC4.a80"

path
        db "zxbattle",0
fn_log
        db "zxbattle.log",0
fn_hiscore
        db "hi_score.dat",0
fn_soundfx
        db "sound_fx.bin",0
fn_muzmain
        db "muz_main.dat",0
fn_muzboss
        db "muz_boss.dat",0
fn_muzend
        db "muz_end.dat",0
        if TILES87
fn_lvl0116
        db "lvl_0116.dat",0
fn_lvl1732
        db "lvl_1732.dat",0
        else
fn_lvl0116
        db "lvln0116.dat",0
fn_lvl1732
        db "lvln1732.dat",0
        endif
fn_lvl00us
        db "lvl_00us.dat",0
fn_spr0
        db "spr0.dat",0
fn_spr1
        db "spr1.dat",0
fn_spr2
        db "spr2.dat",0
fn_spr3
        db "spr3.dat",0
fn_tiles
        db "font.bin",0

       ifdef CLIENT
inetbuf_sz=256
inetbuf
        ds inetbuf_sz
       endif

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
        display "UP1=",UP1
        display "MAP=",MAP

       ifdef CLIENT
	if CLIENT
		savebin "zxbatcli.com",begin,end-begin
	else
		savebin "zxbatsrv.com",begin,end-begin
	endif
       else
        savebin "zxbattle.com",begin,end-begin
       endif

	LABELSLIST "../../../us/user.l"
