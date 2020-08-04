        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

EGA=0

nextfigx=4
nextfigy=8
        
fieldwid=10
fieldhgt=23
fieldx=16-fieldwid/2
fieldy=0
centerfield=fieldx+(fieldwid/2)
coordsEndPlayField=(fieldx*2-1)+(256*fieldy)
coordsBeginPlayField=(fieldx-1)+(256*fieldy)
coordsDropFig=(coordsBeginPlayField+coordsEndPlayField)/2
fieldmarginsymbol='x'
dangerattr1=0x38+2 ;red
dangerattr2=0x38+4 ;green
dangerattr3=0x38+1 ;blue
scoreattr=dangerattr3
wallattr=dangerattr1
emptyattr=0x38

attrs=0x3800 ;0x600

;fieldEx=32
;fieldEy=24
centr=0x0b0b;(fieldEx/2)+(256*fieldEy/2)

dir_r=key_right;;#09
dir_l=key_left;#08
dir_u=key_up;#0b
dir_d=key_down;#0a
        
        org PROGSTART
begin
        OS_HIDEFROMPARENT
        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,d
        ;SETPG16K

        call setpgs_scr
       
        call cls
        call prfield
        call newfig
        call copybuftoscr

        ld a,(curfalldelay) 
        ld (falldelaycount),a

gameloop_newfig 
        call setpgs_scr
       
        call newfig
    
        ld bc,nextfigy*256 + nextfigx
        ld de,prfig_pixel_cleanout ;de=адрес процедуры
        ld hl,nextfig
        ld a,(nextfigcolor)
        call prfig_hl_a
        
        call collide ;nz=collision
	jr nz,gameover
        ld a,1
        ld (figmoved),a
        
gameloop
        call setpgs_scr
        call copybuftoscr
       
        ld bc,(curxy) ;bc=yx 
        ld de,prfig_pixel ;de=адрес процедуры
figmoved=$+1
        ld a,0
        or a
        call nz,prfig
        xor a
        ld (figmoved),a
        ld (figcleared),a
        
        call prscore

        YIELD ;call delay

	xor a
	ld (downneeded),a
	
        call storeposition
        GET_KEY
         cp key_esc
         jr z,quit
         cp key_redraw
         push af
         call z,redraw
         pop af
;a=key
        call controlkey ;двигаем координаты фигуры (устанавливает downneeded по down)

        ld a,(figmoved)
        or a
        jr z,nokey

        call undraw_oldfig_ifneeded
        call collide
        call nz,restoreposition ;отменяем движение координат, если нельзя поставить фигуру
nokey

        call movedownifneeded
        ld a,(figmoved)
        or a
        jr z,nocollidedown

        call undraw_oldfig_ifneeded
        call collide
        jr nz,figureonground
nocollidedown
        jr gameloop
figureonground
        call stopfig
	jp gameloop_newfig
gameover
        jr $
        ld hl,endtext
        ld bc,centr
        call prtext
gameoverloop
        YIELD
        GET_KEY
        cp key_esc
        jr nz,gameoverloop
quit
        QUIT

copybuftoscr
        ld hl,attrs
        ld de,0x5800
        ld bc,0x300
        ldir
        ret

redraw
        call setpgs_scr
        ;jr $
        ;call cls
        ld e,0
        OS_CLS
        call copybuftoscr
        call prfield
;TODO напечатать текущее заполнение поля
;TODO напечатать будущую фигуру
        ret

setpgs_scr
        if EGA
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok
        SETPG32KHIGH
        else
        ld a,(user_scr0_high) ;ok
        SETPG16K
        endif
        ret


storeposition
        ld bc, 4
        ld hl, curfig
        ld de, oldcurfig
        ldir
        ld hl,(curxy)
        ld (oldcurxy),hl
        ret

restoreposition
        ld hl,(oldcurxy)
        ld (curxy),hl
        ld bc, 4
        ld de, curfig
        ld hl, oldcurfig
        ldir
        ret

undraw_oldfig_ifneeded
        ld bc,(oldcurxy) ;bc=yx 
        ld de,prfig_clearpixel ;de=адрес процедуры
        ld hl,oldcurfig
figcleared=$+1
        ld a,0
        or a
        call z,prfig_hl
        ld a,1
        ld (figcleared),a
        ret

collide
;nz=collision
        ld bc,(curxy) ;bc=yx 
        ld de,prfig_checkpixel ;de=адрес процедуры
        call prfig
        ld a,hx
        or a 
        ret
        
stopfig
        ld bc,(oldcurxy) ;bc=yx 
        ld de,prfig_pixel ;de=адрес процедуры
        call prfig
        
        ld hl,dellineslist
        ld bc,fieldx+(256*fieldy)
        ld ix,fieldhgt ;hx=0
finddellines0
        push bc
        ld (hl),b
        call calcattraddr
        call checkfilledline ;nz значит сжечь
        jr z,finddellines_nofire
        inc hl
        inc hx
finddellines_nofire
        pop bc
        inc b ;y
        dec lx
        jr nz,finddellines0
        ld (hl),#ff
        
        ld c,hx
        ld b,0
        ld hl,scoreadds
        add hl,bc
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld hl,(curscore)
        add hl,bc
        ld (curscore),hl
        
        ld hl,dellineslist
firelines0
        ld a,(hl)
        cp #ff
        jr z,firelinesq
        inc hl
        ld b,a ;y
        ld c,fieldx
        ld a,emptyattr
        ld (curattr),a
        ld e,fieldwid
firelines1
        ld a,' '
        call prcharxy
        inc c
        dec e
        jr nz,firelines1
        ld c,fieldx
        ld a,b ;y
        dec a
        push hl
        call shiftblock ;bc=левый нижний угол, a=количество сдвигаемых строк
        pop hl
        jr firelines0
firelinesq
        ret

newfig  
        ld hl,nextfig
        ld de,curfig
        ld bc,4
        ldir
        ld a,(nextfigcolor)
        ld (curfigcolor),a
        
        ld c,nfigs
        call rnd
        add a,a
        add a,a
        ld c,a
        ld b,0
        ld hl,figs
        add hl,bc
        ld de,nextfig
        ld  c,4
        ldir
        ld c,4
        call rnd
        add a,2 ;red...
        add a,a
        add a,a
        add a,a
        ld (nextfigcolor),a
        
        ld hl,coordsDropFig
        ld (curxy),hl
        ret

shiftblock
;bc=левый нижний угол, a=количество сдвигаемых строк
shiftblockline
        push af
        call calcscraddr
        ex de,hl ;hl=адрес текущей строки
        dec b ;y
        call calcscraddr ;de=адрес предыдущей строки
        ex de,hl ;de=адрес текущей строки, hl=адрес предыдущей строки
        push bc
        ld a,8
shiftblockline0
        ld bc,fieldwid
        push de
        push hl
        ldir
        pop hl
        pop de
        inc h
        inc d
        dec a
        jr nz,shiftblockline0
        dec h
        dec d
        call calcattraddr_fromscr
        ex de,hl
        call calcattraddr_fromscr
        ex de,hl
        ld bc,fieldwid
        ldir
        pop bc
        pop af
        dec a
        jr nz,shiftblockline
        ret

checkfilledline
;de=attraddr
        ld b,fieldwid
checkfilledline0
        ld a,(de)
        inc de
        cp emptyattr
        ret z
        djnz checkfilledline0
        ret ;nz

movedownifneeded
downneeded=$+1
	ld a,0
	or a
	jr nz,movedownok
        ld a,(falldelaycount)
        dec a
        jr nz, falldelaycount_q ;если не 0, то обходим
movedownok
        ld a,1
        ld (figmoved),a
        ld a,(curfalldelay)
        ld bc,(curxy)
        inc b
        ld (curxy),bc
falldelaycount_q
        ld (falldelaycount),a  
        ret

controlkey
        cp dir_u
        jr z,rotfig
        ld bc,(curxy)
        dec c
        cp dir_l
        jr z,moveok
        inc c
        inc c
        cp dir_r
        jr z,moveok
        dec c
        cp dir_d
	ret nz
	ld a,1
	ld (downneeded),a
        ret
moveok
        ld (curxy),bc       
        ld a,1
        ld (figmoved),a
        ret    
        
rotfig
        ld bc,(curfig)
        ld de,(curfig+2)
        ld hl,curfig
        ld lx,4
rotfig_lines
        xor a
        rr c 
        rla
        rr b 
        rla
        rr e
        rla
        rr d 
        rla
        ld (hl),a 
        inc hl
        dec lx  
        jr nz, rotfig_lines
        ld a,1
        ld (figmoved),a
        ret

rnd
;0..c-1
        ld a,r
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

cls
	ld hl,#4000
	ld de,#4001
        ld bc,#17ff
        ld (hl),0;#ff
        ldir
	ld hl,attrs;#5800
	ld de,attrs+1;#5801
	ld (hl),emptyattr
	ld bc,767
	ldir
        call copybuftoscr
        ret
        
prfield
        ld a,wallattr
        ld (curattr),a
        ld bc,fieldx-1+256*(fieldy+fieldhgt) ;bottom
        ld e,fieldwid+2
prfieldhor0
        ld a,fieldmarginsymbol
        call prcharxy
        inc c
        dec e
        jr nz,prfieldhor0
        ld bc,coordsBeginPlayField ;left
        call prfieldver
        ld bc,coordsEndPlayField ;right
prfieldver
        ld e,fieldhgt
prfieldver0
        ld a,fieldmarginsymbol
        call prcharxy
        inc b
        dec e
        jr nz,prfieldver0
        ret
      
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

prscore
        ld hl,(curscore)
        ld de,#4000
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
;de=#4000 + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,#40
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        ret
        
calcattraddr
        call calcscraddr
        ;call calcattraddr_fromscr
calcattraddr_fromscr
;de=#5800 + (y&#18)/8+((y*32)&#ff+x)
        ld a,d
        ;sub #40
        rra
        rra
        rra
        and 3
        add a,attrs/256;#58
        ld d,a ;de=attraddr
        ret

prcharxy
;a=code
;bc=yx
        push bc
        push de
        push hl
        push af
        call calcscraddr
        pop af
        push de
        call prcharin
        pop de
        call calcattraddr_fromscr
curattr=$+1
        ld a,0
        ld (de),a
        pop hl
        pop de
        pop bc
        ret
        
prcharin
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;#3c00
        add hl,bc
        ld b,8
prchar0
        ld a,(hl) ;font
        ld (de),a ;scr
        inc hl
        inc d ;+256
        djnz prchar0
        ret

;text
;        db "Hello world!",0
endtext
        db "Game over!",0
curxy 
        dw 0
oldcurxy 
        dw 0
    
        
prfig
;bc=yx 
        ld hl,curfig ;hl=указатель на фигуру
prfig_hl
curfigcolor=$+1
        ld a,6
prfig_hl_a
;hl=указатель на фигуру
;de=адрес процедуры
        ld lx,a
        ld hx,0 ;lx=атрибут, hx=0
        ld (prfig_calladdr),de
        ld e,4
prfig_lines
        push de
        ld d,(hl) ;%0000????
        inc hl
        rlc d
        rlc d
        rlc d
        rlc d ;%????0000
        push bc
        ld e,4
prfig_pixels
        rl d
prfig_calladdr=$+1
        call prfig_pixel
        inc c ;x
        dec e
        jr nz,prfig_pixels
        pop bc
        inc b ;y
        pop de
        dec e
        jr nz,prfig_lines
        ret
        
;bc=yx
prfig_pixel
        ret nc
        push bc
        push de
        push hl
        ld a,lx
        ld (curattr),a
        ld a,'X'
        call prcharxy
        pop hl
        pop de
        pop bc
        ret
prfig_pixel_cleanout
        push bc
        push de
        push hl
        ld a,emptyattr
        ld (curattr),a
        ld a,' '
        jr nc,prfig_pixel_cleanout_ok
        ld a,lx
        ld (curattr),a
        ld a,'X'
prfig_pixel_cleanout_ok
        call prcharxy
        pop hl
        pop de
        pop bc
        ret
prfig_checkpixel
        ret nc
        push bc
        push de
        push hl
        call calcattraddr
        ld a,(de)
        cp emptyattr
        jr z,checkpixelempty
        inc hx
checkpixelempty   
        pop hl
        pop de
        pop bc
        ret
prfig_clearpixel
;bc=yx
        ret nc
        push bc
        push de
        push hl
        ld a,emptyattr
        ld (curattr),a
        ld a,' '
        call prcharxy
        pop hl
        pop de
        pop bc
        ret
        
figs
;квадрат
        db %0000
        db %0110
        db %0110
        db %0000
;палка
        db %0100
        db %0100
        db %0100
        db %0100
;сапог правый
        db %0100
        db %0100
        db %0110
        db %0000
;сапог левый
        db %0010
        db %0010
        db %0110
        db %0000
;зигзаг1
        db %0000
        db %0011
        db %0110
        db %0000
;зигзаг2
        db %0000
        db %1100
        db %0110
        db %0000
;T
        db %0000
        db %1110
        db %0100
        db %0000
nfigs=($-figs)/4
curfig
        ds 4
oldcurfig
        ds 4        
nextfig
        ds 4

scoreadds
        dw 0
        dw 10 ;1 line
        dw 30 ;2 lines
        dw 50 ;3 lines
        dw 100 ;4 lines

falldelaycount
        db 0
curfalldelay
        db 16
curscore
        dw 0
nextfigcolor
        db 0


dellineslist
        ds 4+1 ;max 4 линии + #ff

;oldtimer
;        dw 0

        ;align 256
font
        incbin "zx.fnt"

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "tetris.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
