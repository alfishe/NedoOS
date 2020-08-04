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
        

dangerattr1=#38+2 ;red
dangerattr2=#38+4 ;green
dangerattr3=#38+1 ;blue
scoreattr=dangerattr3
wallattr=dangerattr1
snakeattr=dangerattr2
rabbitattr=#40+#30 ;bright yellow
emptyattr=#38

snakecoordssize=fieldwid*fieldhgt*2;768*2

dir_r=key_right;cs8;#09
dir_l=key_left;cs5;#08
dir_u=key_up;cs7;#0b
dir_d=key_down;cs6;#0a
        
        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

        if EGA
        ld e,0
        else
        ld e,3
        endif
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;if EGA
        ;ld a,e
        ;SETPG32KLOW
        ;ld a,d
        ;SETPG32KHIGH
        ;else
        ;ld a,d
        ;SETPG16K
        ;endif

        ld hl,attrs
        ld de,attrs+1
        ld bc,attrs_sz-1
        ld (hl),emptyattr
        ldir
        
        call redraw

        ld hl,#0101
        ld (snakecoords),hl
        ;ld bc,#0a1e
        ;call prrabbit
        call genrabbit
gameloop
        call setpgs_scr

        if EGA
        ld bc,0*256+18
        call calcscraddr
        else
        ld de,#4000+14
        endif
        ld hl,(curlength)
        call prnum
        call delay
        GET_KEY
         cp key_esc
         jr z,quit
         cp key_redraw
         push af
         call z,redrawall
         pop af
;a=key
        call getkey
        call shrink
        call proldheadastail
        call move_grow ;bc=новые координаты головы
        push bc
        call collide_rabbit_startgrow
        call collide_walls_self ;Z=collision
        pop bc
        jr z,gameover
        call prhead
	jp gameloop

redrawall
        call redraw
        call prsnake
        call getheadcoords
        call prhead
rabbitxy=$+1
        ld bc,0
        jp prrabbit
redraw
        call setpgs_scr
        call cls        
        jp prfield

setpgs_scr
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok
        SETPG32KHIGH
        ret

redrawgameover
        call redrawall
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
        cp key_redraw
        jr z,redrawgameover
        cp key_esc
        jr nz,gameoverloop
quit
        QUIT
        
rnd
;0..c-1
        ld a,r
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

collide_rabbit_startgrow
        call getheadcoords
        ;call calcscraddr
        call calcattraddr;_fromscr
        ;de=attraddr (head)
        ld a,(de)
        cp rabbitattr
        ret nz
        ld a,5
        ld (curgrow),a
        ;call genrabbit
        ;ret

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
        ld (rabbitxy),bc
        
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

delay
        ld b,5
delay0
        push bc
        YIELD
        pop bc
        djnz delay0
        ret

getkey
        cp dir_l
        jr z,getkey_ok
        cp dir_r
        jr z,getkey_ok
        cp dir_u
        jr z,getkey_ok
        cp dir_d
        ret nz;jr z,getkey_ok
getkey_ok
        ld (curdirection),a
        ret

shrink
        ld a,(curgrow)
        or a
        jr z,nogrow
        dec a
        ld (curgrow),a
        ret;jr growq
nogrow
        ld bc,(snakecoords)
        call cltail
        ld hl,snakecoords+2
        ld de,snakecoords
        ld bc,snakecoordssize-2
        ldir
        ld hl,(curlength)
        dec hl
        ld (curlength),hl
;growq
        ret

prsnake
        ld hl,snakecoords
        ld bc,(curlength)
prsnake0
        push bc
        push hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        call prtailelement
        pop hl
        pop bc
        inc hl
        cpi
        jp pe,prsnake0
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

curgrow
        db 7
curdirection
        db dir_r
curlength
        dw 0 ;не считая головы
        
cls
        if EGA
        ld e,0
        OS_CLS
        else
	ld hl,#4000
	ld de,#4001
        ld bc,#17ff
        ld (hl),0;#ff
        ldir
	ld hl,#5800
	ld de,#5801
	ld (hl),emptyattr
	ld bc,767
	ldir
        endif        ret
        
prfield
        ld a,wallattr
        ld (curattr),a
        ld bc,#0000
        ld e,fieldwid+2
        call prfieldhor ;top
        ld bc,256*(fieldhgt+1);#1700
        ld e,fieldwid+2
        call prfieldhor ;bottom
        ld bc,#0100
        ld e,fieldhgt
        call prfieldver ;left
        ld bc,#0100+(fieldwid+1);#011f
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
prtailelement
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnake
        jp prtilexy
prhead
;bc=yx
        ld a,snakeattr
        ld (curattr),a
        ;ld a,'O'
        ;jp prcharxy
        ld hl,tilesnakehead
        jp prtilexy
cltail
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
prchar;a=code;de=screen        push de        push hl
        call prcharin
        pop hl        pop de        inc e        ret        
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
;de=#4000 + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,#40
        ld d,a
        ld a,b ;y
        add a,a ;*2        add a,a ;*4        add a,a ;*8        add a,a ;*16        add a,a ;*32
        add a,c ;x
        ld e,a
        endif
        ret

calcattraddr
;bc=yx
;нельзя портить bc
        if EGA
;de=attrs + (y&#18)/4+((y*64)&#ff+x)
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
;de=#5800 + (y&#18)/8+((y*32)&#ff+x)
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
        add a,attrs/256;#58
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
        ld l,a        ld h,0         add hl,hl         add hl,hl         add hl,hl         add hl,hl         add hl,hl        ;ld bc,font-(32*32)
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
        ld a,(de) ;font        ld (hl),a ;scr
        inc de        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font        ld (hl),a ;scr
        inc de        add hl,bc
        edup
        pop hl
        set 5,h
        push hl
        ;ld d,font/256
        dup 8
        ld a,(de) ;font        ld (hl),a ;scr
        inc de        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font        ld (hl),a ;scr
        inc de        add hl,bc
        edup
        
        else
        ld bc,40-0x6000
        dup 8
        ld a,(de) ;font        inc de        ld (hl),a ;scr
        set 6,h
        ld a,(de) ;font        inc de        ld (hl),a ;scr
        res 6,h
        set 5,h
        ld a,(de) ;font        inc de        ld (hl),a
        set 6,h
        ld a,(de) ;font        inc de        ld (hl),a ;scr
        ;res 6,h        ;res 5,h        add hl,bc        edup
        endif
        
        ret
        else        ld l,a        ld h,0        add hl,hl        add hl,hl        add hl,hl        ld bc,font-256;#3c00        add hl,bc
        endif

        if EGA
        if 1==1
prcharin_go=prcharin_go1
        else
prcharin_go
        ex de,hl
        ld bc,40
        dup 8
        ld a,(de) ;font        ld (hl),a ;scr
        set 5,h
        ld (hl),a
        res 5,h        inc de        add hl,bc        edup
        endif
        elseprcharin_go
        ld b,8prchar0        ld a,(hl) ;font        ld (de),a ;scr        inc hl        inc d ;+256        djnz prchar0
        endif
        ret
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
        cols8 #00,#22,#aa,#22,#00,#22,#2a,#22
        cols8 #00,#20,#20,#20,#00,#22,#aa,#22
        cols8 #00,#22,#2a,#22,#00,#22,#aa,#22
        cols8 #00,#22,#aa,#22,#00,#20,#20,#20
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
        cols8 #00,#00,#04,#4c,#4c,#4c,#04,#00
        cols8 #00,#44,#cc,#cc,#cc,#cc,#cc,#44
        cols8 #00,#40,#c4,#cc,#cc,#cc,#c4,#40
        cols8 #00,#00,#00,#40,#40,#40,#00,#00
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
        cols8 #00,#00,#04,#4c,#4c,#4c,#04,#00
        cols8 #00,#44,#cc,#fc,#cc,#22,#cc,#44
        cols8 #00,#40,#c4,#fc,#cc,#2c,#c4,#40
        cols8 #00,#00,#00,#40,#40,#40,#00,#00
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
        cols8 #00,#77,#7f,#7f,#07,#07,#07,#00
        cols8 #00,#00,#70,#70,#f7,#0f,#f2,#77
        cols8 #00,#07,#7f,#7f,#f7,#07,#f7,#70
        cols8 #00,#70,#70,#70,#00,#00,#00,#00
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

;oldtimer
;        dw 0

        if EGA
        align 256
font
        incbin "fontgfx"
        else
font
        incbin "zx.fnt"
        endif

snakecoords
;y,x (голова в конце)
        ;ds snakecoordssize        
end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "snake.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
