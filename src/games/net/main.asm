        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

EGA=1
      
        if EGA
attrs=0x3800 ;0x600
attrs_sz=0x600
fieldwid=38
fieldhgt=23
        else
attrs=0x5800
attrs_sz=0x300
fieldwid=30
fieldhgt=22
        endif

STACK=0x4000
        

dangerattr1=0x38+2 ;red
dangerattr2=0x38+4 ;green
dangerattr3=0x38+1 ;blue
scoreattr=dangerattr3
wallattr=dangerattr1
snakeattr=dangerattr2
rabbitattr=0x40+0x30 ;bright yellow
emptyattr=0x38

snakecoordssize=fieldwid*fieldhgt*2;768*2

dir_r=key_right;cs8;0x09
dir_l=key_left;cs5;0x08
dir_u=key_up;cs7;0x0b
dir_d=key_down;cs6;0x0a


IPPROTO_TCP EQU 6
IPPROTO_UDP EQU 17

AF_UNSPEC EQU 0
AF_INET EQU 2
AF_INET6 EQU 23

SOCK_STREAM EQU 0x01	;tcp/ip
SOCK_DGRAM 	EQU 0x03		;udp/ip

SHUT_RDWR 		EQU 2
ERR_INTR 		EQU 4
ERR_NFILE 		EQU 23
ERR_ALREADY 	EQU 37
ERR_NOTSOCK 	EQU 38
ERR_EMSGSIZE 	EQU 40    ;/* Message too long */
ERR_PROTOTYPE 	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_CONNRESET 	EQU 54
ERR_NOTCONN 	EQU 57
;struct sockaddr_in {short sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};


        
        org PROGSTART
begin
        ld sp,STACK

        if EGA
        ld e,0
        else
        ld e,3
        endif
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        if EGA
        ld a,e
        SETPG32KLOW
        ld a,d
        SETPG32KHIGH
        else
        ld a,d
        SETPG16K
        endif

        call cls
        
        ld hl,attrs
        ld de,attrs+1
        ld bc,attrs_sz-1
        ld (hl),emptyattr
        ldir

        call prfield

        ld hl,0x0101
        ld (snakecoords),hl
        ld hl,0x1001
        ld (snakecoords2),hl
        ;ld bc,0x0a1e
        ;call prrabbit
        call genrabbit

	ld de,0x0203
	OS_NETSOCKET
	ld a,l
	ld (soc),a
	or a
	jp m,inet_exiterr_nosoc
;	ld de,0x0203
;	OS_NETSOCKET
;	ld a,l
;	ld (socrecv),a
;	or a
;	jp m,inet_exiterr_nosocrecv
	
        ;if MASTER

;	ld a,(socsend)
;	LD DE,port_iasend
;	OS_NETCONNECT
;       ld a,l
;	or a
;	jp m,inet_exiterr
        
        ;else ;slave

	ld a,(soc)
	LD DE,port_ia
	OS_BIND
    ld a,l
	or a
	jp m,inet_exiterr
	
	ld a,(soc)
	LD DE,port_ia
	OS_NETCONNECT
        ld a,l
	or a
	jp m,inet_exiterr
        ;endif

;начальная синхронизация        
;если master - при этом посылаем свои клавиши, если slave - принимаем клавиши
;TODO для двух игроков:
;???
        if MASTER ;посылаем событие старта

        ld a,1
        call sendbyte
        
        else ;slave - принимаем событие старта
        
waitbegin0
        call receivebyte
        jr z,waitbegin0
       
        endif
        
        
gameloop
        if EGA
        ld bc,0*256+18
        call calcscraddr
        else
        ld de,0x4000+14
        endif
        ld hl,(curlength)
        call prnum
        if EGA
        ld bc,24*256+18
        call calcscraddr
        else
        ld de,0x50e0+14
        endif
        ld hl,(curlength2)
        call prnum
        
        if MASTER
        call delay
        endif
         
        call getkey ;если master - при этом посылаем свои клавиши, если slave - принимаем клавиши
        
        call shrink
        call shrink2
        call proldheadastail
        call proldheadastail2
        call move_grow ;bc=новые координаты головы
        push bc
        call move_grow2 ;bc=новые координаты головы
        push bc
        call collide_rabbit_startgrow
        call collide_rabbit_startgrow2
        
        call collide_walls_self2 ;Z=collision
        ;jr z,gameover
        call z,stopsnake2
        pop bc
        call nz,prhead2
        call collide_walls_self ;Z=collision
        ;jr z,gameover
        call z,stopsnake
        pop bc
        call nz,prhead
	jp gameloop

gameover
        ld hl,endtext
        if EGA
        ld bc,0x0b0f
        else
        ld bc,0x0b0b
        endif
        call prtext
gameoverloop
        YIELD
        GET_KEY
        cp key_esc
        jr nz,gameoverloop
inet_exiterr
inet_exitcode
quit
	LD	a,(soc)
	LD	E,0
	OS_NETSHUTDOWN
inet_exiterr_nosoc
;	LD	a,(socsend)
;	LD	E,0
;	OS_NETSHUTDOWN
;inet_exiterr_nosockets
        QUIT
        
rnd
;0..c-1
        ;ld a,r
;Patrik Rak
rndseed1=$+1
        ld  hl,0xA280   ; xz -> yw
rndseed2=$+1
        ld  de,0xC0DE   ; yw -> zt
        ld  (rndseed1),de  ; x = y, z = w
        ld  a,e         ; w = w ^ ( w << 3 )
        add a,a
        add a,a
        add a,a
        xor e
        ld  e,a
        ld  a,h         ; t = x ^ (x << 1)
        add a,a
        xor h
        ld  d,a
        rra             ; t = t ^ (t >> 1) ^ w
        xor d
        xor e
        ld  h,l         ; y = z
        ld  l,a         ; w = t
        ld  (rndseed2),hl
        ;ex de,hl
        ;ld hl,0
        ;res 7,c ;int
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

collide_rabbit_startgrow
        call getheadcoords
        call calcattraddr
        ;de=attraddr (head)
        ld a,(de)
        cp rabbitattr
        ret nz
        ld a,5
        ld (curgrow),a
        jp genrabbit

collide_rabbit_startgrow2
        call getheadcoords2
        call calcattraddr
        ;de=attraddr (head)
        ld a,(de)
        cp rabbitattr
        ret nz
        ld a,5
        ld (curgrow2),a
        jp genrabbit

genrabbit
        ld c,fieldhgt
        call rnd
        inc a
        ld b,a
        ld c,fieldwid
        call rnd
        inc a
        ld c,a
        
;genrabbit, если попало на хвост:
        ;call calcscraddr
        call calcattraddr;_fromscr
        ;de=attraddr (rabbit)
        ld a,(de)
        cp emptyattr
        jr nz,genrabbit
        
prrabbit
;bc=yx
        ld a,rabbitattr
        ld (curattr),a
        ;ld a,'Y'
        ;jp prcharxy
        ld hl,tilerabbit
        jp prtilexy
        
collide_walls_self
;out: Z=collision
        call getheadcoords
        ;call calcscraddr
        call calcattraddr;_fromscr
        ;de=attraddr (head)
        ld a,(de)
        cp dangerattr1
        ret z
        cp dangerattr2
        ret

collide_walls_self2
;out: Z=collision
        call getheadcoords2
        call calcattraddr
        ;de=attraddr (head)
        ld a,(de)
        cp dangerattr1
        ret z
        cp dangerattr2
        ret

delay
        ld b,5
delay0
        push bc
        YIELD
        pop bc
        djnz delay0
        ret

getkey
;если master - при этом посылаем свои клавиши, если slave - принимаем клавиши
;TODO для двух игроков:
;master посылает клавиши и получает состояние (или список событий)
;slave генерирует список событий и периодически их рассылает на master
;потом оба обрабатывают события

        GET_KEY
         cp key_esc
         jp z,quit
        push af

        if 1==0
        call sendbyte
waitkey0
        call receivebyte
        jr z,waitkey0
        or a
        jr z,$+5
        if MASTER 
			ld (curdirection2),a
        else
			ld (curdirection),a
        endif
        endif
        if MASTER
       
        push af
        call sendbyte
        pop af
       
        ld c,dir_l
        cp 'a';dir_l
        jr z,getkey_ok2
        ld c,dir_r
        cp 'd';dir_r
        jr z,getkey_ok2
        ld c,dir_u
        cp 'w';dir_u
        jr z,getkey_ok2
        ld c,dir_d
        cp 's';dir_d
        jr nz,waitkey0
getkey_ok2
;player2 key pressed - disable net
        ld hl,receivebyte_fake
        ld (waitkey_receivebytepatch),hl
        ld a,c
        jr mastergetkeyskipreceive
waitkey0
         ld a,0xfd
         in a,(0xfe) ;костыль D=start second player
         bit 2,a ;D
         jr z,mastergetkeyskipreceiveq
waitkey_receivebytepatch=$+1
        call receivebyte
        jr z,waitkey0
        or a
        jr z,mastergetkeyskipreceiveq
mastergetkeyskipreceive
        ld (curdirection2),a
mastergetkeyskipreceiveq
        else ;slave

        push af
waitkey0
        call receivebyte
        jr z,waitkey0
        or a
        jr z,$+5
        ld (curdirection),a
        pop af
        call sendbyte
       
        endif

        pop af
         
        cp dir_l
        jr z,getkey_ok
        cp dir_r
        jr z,getkey_ok
        cp dir_u
        jr z,getkey_ok
        cp dir_d
        ret nz;jr z,getkey_ok
getkey_ok
        if MASTER
        ld (curdirection),a
        else
        ld (curdirection2),a
        endif
        ret

shrink
        ld a,(curgrow)
        or a
        jr z,shrink_nogrow
        dec a
        ld (curgrow),a
        ret
shrink_nogrow
        ld bc,(snakecoords)
        call cltail
        ld hl,snakecoords+2-2
        ld de,snakecoords-2
        ld bc,snakecoordssize-2+2
        ldir
        ld hl,(curlength)
        dec hl
        ld (curlength),hl
        ret

shrink2
        ld a,(curgrow2)
        or a
        jr z,shrink2_nogrow
        dec a
        ld (curgrow2),a
        ret
shrink2_nogrow
        ld bc,(snakecoords2)
        call cltail2
        ld hl,snakecoords2+2-2
        ld de,snakecoords2-2
        ld bc,snakecoordssize-2+2
        ldir
        ld hl,(curlength2)
        dec hl
        ld (curlength2),hl
        ret

stopsnake
;keep f
        ld hl,snakecoords+snakecoordssize-1-2
        ld de,snakecoords+snakecoordssize-1
        ld bc,snakecoordssize-2+2
        lddr
        ret

stopsnake2
;keep f
        ld hl,snakecoords2+snakecoordssize-1-2
        ld de,snakecoords2+snakecoordssize-1
        ld bc,snakecoordssize-2+2
        lddr
        ret

getheadcoords
        ld hl,(curlength) ;не считая головы
        add hl,hl
        ld bc,snakecoords
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ret

getheadcoords2
        ld hl,(curlength2) ;не считая головы
        add hl,hl
        ld bc,snakecoords2
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ret

move_grow
;out: bc=новые координаты головы        
        call getheadcoords
;bc=старые координаты головы        
        ld a,(curdirection)
        dec c
        cp dir_l
        jr z,moveq
        inc c
        inc c
        cp dir_r
        jr z,moveq
        dec c
        inc b
        cp dir_d
        jr z,moveq
        dec b
        dec b
moveq
;bc=новые координаты головы        
        ld (hl),c
        inc hl
        ld (hl),b
        ld hl,(curlength)
        inc hl
        ld (curlength),hl
        ret
        
move_grow2
;out: bc=новые координаты головы        
        call getheadcoords2
;bc=старые координаты головы        
        ld a,(curdirection2)
        dec c
        cp dir_l
        jr z,move2q
        inc c
        inc c
        cp dir_r
        jr z,move2q
        dec c
        inc b
        cp dir_d
        jr z,move2q
        dec b
        dec b
move2q
;bc=новые координаты головы        
        ld (hl),c
        inc hl
        ld (hl),b
        ld hl,(curlength2)
        inc hl
        ld (curlength2),hl
        ret
        
cls
        if EGA
        ld e,0
        OS_CLS
        else
	ld hl,0x4000
	ld de,0x4001
        ld bc,0x17ff
        ld (hl),0;0xff
        ldir
	ld hl,0x5800
	ld de,0x5801
	ld (hl),emptyattr
	ld bc,767
	ldir
        endif
        ret
        
prfield
        ld a,wallattr
        ld (curattr),a
        ld bc,0x0000
        ld e,fieldwid+2
        call prfieldhor ;top
        ld bc,256*(fieldhgt+1);0x1700
        ld e,fieldwid+2
        call prfieldhor ;bottom
        ld bc,0x0100
        ld e,fieldhgt
        call prfieldver ;left
        ld bc,0x0100+(fieldwid+1);0x011f
        ld e,fieldhgt
        ;call prfieldver ;right
        ;ret
prfieldver
;bc=yx
;e=len
prfieldver0
        ;ld a,fieldmarginsymbol
        ;call prcharxy
        ld hl,tilebrick
        call prtilexy
        inc b
        dec e
        jr nz,prfieldver0
        ret
        
prfieldhor
;bc=yx
;e=len
prfieldhor0
        ;ld a,fieldmarginsymbol
        ;call prcharxy
        ld hl,tilebrick
        call prtilexy
        inc c
        dec e
        jr nz,prfieldhor0
        ret
     
proldheadastail
        call getheadcoords
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnake
        jp prtilexy

proldheadastail2
        call getheadcoords2
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnake2
        jp prtilexy

prhead
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnakehead
        jp prtilexy

prhead2
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnakehead2
        jp prtilexy

cltail
cltail2
;bc=yx
        ld a,emptyattr
        ld (curattr),a
        ;ld a,' '
        ;jp prcharxy
        ld hl,tileempty
        jp prtilexy
       
prtext
;bc=координаты
;hl=text
        ld a,emptyattr
        ld (curattr),a
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext

prnum
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;push hl
        ;call prchar
        ;pop hl
        ;ret
prchar
;a=code
;de=screen
        push de
        push hl
        call prcharin
        pop hl
        pop de
        inc e
        ret
        
calcscraddr
;bc=yx
;можно портить bc
        if EGA
        ex de,hl
        ld a,c ;x
        ld l,b ;y
        ld h,0
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
         add hl,hl
         add hl,hl
         add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x80
        ld h,a
        ex de,hl
        else
;de=0x4000 + (y&0x18)+((y*32)&0xff+x)
        ld a,b ;y
        and 0x18
        add a,0x40
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        endif
        ret

calcattraddr
;bc=yx
;нельзя портить bc
        if EGA
;de=attrs + (y&0x18)/4+((y*64)&0xff+x)
        ld a,b
        rrca
        rrca
        ld d,a
        and 0xc0
        add a,c
        ld e,a
        sub c
        xor d
        add a,attrs/256
        ld d,a ;de=attraddr
        else
;de=0x5800 + (y&0x18)/8+((y*32)&0xff+x)
        ld a,b
        rrca
        rrca
        rrca
        ld d,a
        and 0xe0
        add a,c
        ld e,a
        sub c
        xor d
        add a,attrs/256;0x58
        ld d,a ;de=attraddr
        endif
        ret
        
prtilexy
;hl=tile
;bc=yx
        push de
        push bc
        call calcscraddr
        ;push de
        call prcharin_go
        ;pop de
        pop bc
        call calcattraddr;_fromscr
        ld a,(curattr)
        ld (de),a
        pop de
        ret
        
prcharxy
;a=code
;bc=yx
        push de
        push hl
        push bc
        push af
        ;jr $
        call calcscraddr
        pop af
        ;push de
        call prcharin
        ;pop de
        pop bc
        call calcattraddr;_fromscr
curattr=$+1
        ld a,0
        ld (de),a
        pop hl
        pop de
        ret
        
prcharin
        if EGA
        sub 32
        ld l,a
        ld h,0
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
        ;ld bc,font-(32*32)
        ;add hl,bc
        ld a,h
        add a,font/256
        ld h,a
prcharin_go1
        ex de,hl
        
        if 1==1
        ld bc,40
        push hl
        push hl
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 5,h
        push hl
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        
        else
        ld bc,40-0x6000
        dup 8
        ld a,(de) ;font
        inc de
        ld (hl),a ;scr
        set 6,h
        ld a,(de) ;font
        inc de
        ld (hl),a ;scr
        res 6,h
        set 5,h
        ld a,(de) ;font
        inc de
        ld (hl),a
        set 6,h
        ld a,(de) ;font
        inc de
        ld (hl),a ;scr
        ;res 6,h
        ;res 5,h
        add hl,bc
        edup
        endif
        
        ret
        else
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;0x3c00
        add hl,bc
        endif

        if EGA
        if 1==1
prcharin_go=prcharin_go1
        else
prcharin_go
        ex de,hl
        ld bc,40
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        set 5,h
        ld (hl),a
        res 5,h
        inc de
        add hl,bc
        edup
        endif
        else
prcharin_go
        ld b,8
prchar0
        ld a,(hl) ;font
        ld (de),a ;scr
        inc hl
        inc d ;+256
        djnz prchar0
        endif
        ret

getbreak
	ld a,0x7f
	in a,(0xfe)
	rra
	ret c
	ld a,0xfe
	in a,(0xfe)
	rra
	ret

sendbyte
        ld (sendbuf),a
        
	ld hl,1
	LD	a,(soc)
	LD	DE,sendbuf
	OS_WIZNETWRITE
	bit 7,h
	jp nz,inet_exitcode

        ret
  
receivebyte_fake
        xor a
        dec a ;nz
        ld a,0
        ret
  
receivebyte
;from UDP
;z=no data

receivebyte0
	call getbreak
	jp nc,quit

	ld hl,1
	LD	a,(soc)
	LD	DE,recvbuf
	OS_WIZNETREAD
	ld a,h
	or l
	ret z ;jr z,receivebyte0

        ld a,(recvbuf)
        ret

sendbuf
        ds 256
recvbuf
        ds 256

soc
        db 0
;socrecv
;        db 0

        if MASTER
;master(net1): from 192.168.1.2 to 192.168.1.177
port_ia:
	defb 0
        db 100,53 ;port (big endian)
        db 192,168,1,177 ;ip (big endian)
;port_iarecv:
;	defb 0
;        db 100,53 ;port (big endian)
;        db 192,168,1,177 ;ip (big endian)

        else

;slave(net2): from 192.168.1.177 to 192.168.1.2
port_ia:
	defb 0
        db 100,53 ;port (big endian)
        db 192,168,1,2 ;ip (big endian)
;port_iasend:
;	defb 0
;        db 100,53 ;port (big endian)
;        db 192,168,1,2 ;ip (big endian)
        endif

        macro cols data
_l=data/16
_r=data&15
        db ((_r&8)<<4) + ((_r&7)<<3) + ((_l&8)<<3) + (_l&7)
        endm
        
        macro cols8 d0,d1,d2,d3,d4,d5,d6,d7
        cols d0
        cols d1
        cols d2
        cols d3
        cols d4
        cols d5
        cols d6
        cols d7
        endm
        
tileempty
        if EGA
        ds 32
        else
        ds 8
        endif

tilebrick
        if EGA
        cols8 0x00,0x22,0xaa,0x22,0x00,0x22,0x2a,0x22
        cols8 0x00,0x20,0x20,0x20,0x00,0x22,0xaa,0x22
        cols8 0x00,0x22,0x2a,0x22,0x00,0x22,0xaa,0x22
        cols8 0x00,0x22,0xaa,0x22,0x00,0x20,0x20,0x20
        else
        db %00000000
        db %11101111
        db %00101000
        db %11101111
        db %00000000
        db %11111110
        db %10000010
        db %11111110
        endif
        
tilesnake
        if EGA
        cols8 0x00,0x00,0x04,0x4c,0x4c,0x4c,0x04,0x00
        cols8 0x00,0x44,0xcc,0xcc,0xcc,0xcc,0xcc,0x44
        cols8 0x00,0x40,0xc4,0xcc,0xcc,0xcc,0xc4,0x40
        cols8 0x00,0x00,0x00,0x40,0x40,0x40,0x00,0x00
        else
        db %00000000
        db %00111000
        db %01000100
        db %10000010
        db %10000010
        db %10000010
        db %01000100
        db %00111000
        endif
        
tilesnake2
        if EGA
        cols8 0x00,0x00,0x05,0x5d,0x5d,0x5d,0x05,0x00
        cols8 0x00,0x55,0xdd,0xdd,0xdd,0xdd,0xdd,0x55
        cols8 0x00,0x50,0xd5,0xdd,0xdd,0xdd,0xd5,0x50
        cols8 0x00,0x00,0x00,0x50,0x50,0x50,0x00,0x00
        else
        db %00000000
        db %00111000
        db %01000100
        db %10000010
        db %10000010
        db %10000010
        db %01000100
        db %00111000
        endif
        
tilesnakehead
        if EGA
        cols8 0x00,0x00,0x04,0x4c,0x4c,0x4c,0x04,0x00
        cols8 0x00,0x44,0xcc,0xfc,0xcc,0x22,0xcc,0x44
        cols8 0x00,0x40,0xc4,0xfc,0xcc,0x2c,0xc4,0x40
        cols8 0x00,0x00,0x00,0x40,0x40,0x40,0x00,0x00
        else
        db %00000000
        db %00111000
        db %01000100
        db %10101010
        db %10000010
        db %10111010
        db %01000100
        db %00111000
        endif
        
tilesnakehead2
        if EGA
        cols8 0x00,0x00,0x05,0x5d,0x5d,0x5d,0x05,0x00
        cols8 0x00,0x55,0xdd,0xfd,0xdd,0x22,0xdd,0x55
        cols8 0x00,0x50,0xd5,0xfd,0xdd,0x2d,0xd5,0x50
        cols8 0x00,0x00,0x00,0x50,0x50,0x50,0x00,0x00
        else
        db %00000000
        db %00111000
        db %01000100
        db %10101010
        db %10000010
        db %10111010
        db %01000100
        db %00111000
        endif
        
tilerabbit
        if EGA
        cols8 0x00,0x77,0x7f,0x7f,0x07,0x07,0x07,0x00
        cols8 0x00,0x00,0x70,0x70,0xf7,0x0f,0xf2,0x77
        cols8 0x00,0x07,0x7f,0x7f,0xf7,0x07,0xf7,0x70
        cols8 0x00,0x70,0x70,0x70,0x00,0x00,0x00,0x00
        else
        db %00000000
        db %11000110
        db %10101010
        db %10101010
        db %01101100
        db %01010100
        db %01101100
        db %00111000
        endif
        
endtext
        db "GAME OVER!",0

oldtimer
        dw 0

        if EGA
        align 256
font
        incbin "fontgfx"
        else
font
        incbin "zx.fnt"
        endif

curgrow
        db 7
curgrow2
        db 7
curdirection
        db dir_r
curdirection2
        db dir_r
curlength
        dw 0 ;не считая головы
curlength2
        dw 0 ;не считая головы

        dw 2 ;на случай возврата змеи
snakecoords
;y,x (голова в конце)
        ds snakecoordssize
        
        dw 2 ;на случай возврата змеи
snakecoords2
;y,x (голова в конце)
        ;ds snakecoordssize
        
end

	display "End=",end
	;display "Free after end=",/d,0xc000-end
	display "Size ",/d,end-begin," bytes"
	
	;savebin "snake.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
