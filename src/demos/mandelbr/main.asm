        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

SCRHGT=192

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        org PROGSTART
begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ld hl,1234
        OS_HIDEFROMPARENT
        ld e,0+0x80 ;EGA + keep gfx pages
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld e,0
        OS_CLS

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        call start
        
        YIELDGETKEYLOOP
        QUIT

;General Mandelbrot calculation idea was taken from https://www.pouet.net/prod.php?which=87739
;(C) litwr 2021
;Thanks to reddie for some help with optimization
;for pasmo assembler
;128x256 Mandelbrot for the Amstrad CPC, 16 color mode

;SCR_SET_MODE            EQU #BC0E
;SCR_SET_INK             EQU #BC32   
;KM_WAIT_CHAR			EQU #BB06

start

sqrbase equ 0x6000 ;must be $xx00
initer	equ	7
idx	equ	-36       ;-.0703125
idy	equ	18        ;.03515625
ix0	equ	-62*idx
imx	equ	10*idx		; x move
sf4	equ	436/4		; sf/4

    ld hl,sqrbase
    ;push hl
    ld bc,0
    ld de,0
sqrloop:
    ;pop hl
    ld (hl),c
    inc l
    ld (hl),b
    inc hl
   push hl
    inc e
    push de
    ld h,d
    ld l,e
    add hl,hl
    ld d,l
    ld e,h
    ld a,e
r0l:
    ld hl,0
    add hl,de
    ld (r0l+1),hl
    adc a,c
    ld c,a
    ld a,0
    adc a,b
    ld b,a
r4l:
    ld hl,sqrbase
    dec hl
    ld (hl),b
    dec l
    ld (hl),c
    ld (r4l+1),hl
    pop de
   pop hl
    ;jr c,mandel0

    inc de
    jr nc,sqrloop

;mandel0: 
        ;pop hl
        
        
        
mandel:
    ld ixl,0
        ld hl,0x8000;$c040  ;scrtop
        ld c,SCRHGT
        exx;push hl
    ld hl,(dy)
    ld a,h
    ld h,l
    srl h
    rra
    ld l,a       ;dy*128
    ld (r5),hl
loop0:
        exx
        ld b,160;40
        exx
x0=$+1
    ld hl,ix0
    ld (r4),hl
loop2:
    ld hl,(r4)
    ld de,(dx)
     sra d
     rr e
    add hl,de
    ld (r4),hl
    ld b,h
    ld c,l   ;r0
niter=$+2
    ld ixh,initer
    ld hl,(r5)
loc1:
    ld d,h
    ld e,l
    res 0,l
    ld a,sqrbase/256
    add a,h
    ld h,a
    ld a,(hl)
    inc l
    ld h,(hl)
    ld l,a
    ex de,hl  ;de = r3 = sqr[r1&0xfffe]
    add hl,bc   ;r1 += r0
    ld a,b
    ld b,h
    ld h,a
    ld a,c
    ld c,l
    ld l,a
    res 0,l
    ld a,sqrbase/256
    add a,h
    ld h,a
    ld a,(hl)
    inc l
    ld h,(hl)
    ld l,a       ;r0 = sqr[r0&0xfffe]
    add hl,de
    ld a,h
    cp 8
    jr nc,loc2

    push hl   ;r0 += r3
    ld h,b
    ld l,c
    ld a,sqrbase/256
    add a,h
    ld h,a
    res 0,l
    ld a,(hl)
    inc l
    ld h,(hl)
    ld l,a      ;r1 = sqr[r1&0xfffe]
r5=$+1
    ld bc,0
    add hl,bc    ;add	r5, r1  ;sets C=0
    pop bc   ;r0
    sbc hl,bc  ;sub	r0, r1
    push hl
r4=$+1
    ld hl,0
    add hl,bc    ;r0 += r4
    sbc hl,de    ;r0 -= r3
    sbc hl,de
    ld b,h     ;r0 -= r3
    ld c,l
    pop hl
    dec ixh
    jr nz,loc1
loc2:
    ld a,ixh   ;color
    and 15   ;16 colors
    ld hl,c8t
    add a,l
    ld l,a
    ld a,(hl)
    ;ld c,(hl)
    ;ld a,ixl
    ;xor 1
    ;ld ixl,a
    ;jp nz,lx1

;tcolor=$+1
;    ld a,0
;    or c
        exx;pop hl  ;scrtop
        ;dec hl
        ld (hl),a
        ld a,h
        xor 0x40
        ld h,a
        bit 6,h
        jr nz,nextpixelq
        xor 0x20
        ld h,a
        and 0x20
        jr nz,$+3
         inc hl
nextpixelq
        dec b
        exx;push hl
    ;ld c,a
    ;ld a,$3f
    ;xor h
    ;ld h,a
    ;ld a,$c0
    ;xor l
    ;ld l,a
    ;ld (hl),c
    ;ld a,l
    ;and $3f
    jp nz,loop2

;next line
        ;exx;pop hl  ;scrtop
        ;ld de,40;$840
        ;add hl,de
        ;jr nc,lx10
        ;ld de,$c040
        ;add hl,de
;lx10:
        ;exx;push hl
        
    ld de,(dy)
    ld hl,(r5)
    sbc hl,de   ;it seems, C=0 is always here
    ld (r5),hl
        exx
        dec c
        exx
    jp nz,loop0

;next frame

    ld hl,(x0)
    ld de,(mx)
    add hl,de
    ld (x0),hl   ;x0 += mx
    ld hl,niter
    inc (hl)     ;iter++
    ld hl,dx
    ;push hl
lx5:
    ;pop hl
    ld a,l
    cp (mx&0xff)+2
    jp z,lx2 ;перебираем dx, dy, mx

    ld (dx1p),a
    ld (dx2p),a
    ;add a,2
    ;ld l,a
   push hl
    ld de,sqrbase-sf4
dx1p=$+1
    ld hl,(dx)
    push hl
    add hl,de
    res 0,l
    ld c,(hl)
    inc l
    ld b,(hl)
    ld de,sqrbase+sf4
    pop hl
    add hl,de
    res 0,l
    or a ;sets C=0
    ld a,(hl)
    inc l
    ld h,(hl)
    ld l,a
    sbc hl,bc  ;C=0
dx2p=$+1
    ld (dx),hl
   pop hl
    inc hl
    inc hl
    jr lx5

lx2:
        ;pop hl
    ;call KM_WAIT_CHAR
    jp mandel

;lx1:ld a,c
;    rrca
;    ld (tcolor),a
;    jp loop2

dx:  	dw idx
dy:	dw idy
mx:     dw imx
c8t:    ;db 0, 8, $22, $88, $2a, $28, 2, $8a
        ;db $80, $20, $a0, $a8, $82, $a2, $aa, $a
_=0
        dup 8
        db _*9
_=_+1
        edup
_=0
        dup 8
        db _*9+0xc0
_=_+1
        edup
        
end

	display "End=",end
	display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "mandelbr.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l"
