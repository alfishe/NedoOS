        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

STACK=0x4000
scrbase=0x8000

ROTATEDFONT=1
MAKEROTATEDFONT=0;1
WIN1251=1
MAKEWIN1251=0;1

        macro NEXTCOLUMN
	bit 6,h
	set 6,h
	jr z,1f;shapes_linehorR_incxok
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,1f;shapes_linehorR_incxok
	inc hl
1;shapes_linehorR_incxok
        endm

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        
        ld e,0 ;color byte 0bRLrrrlll
        OS_CLS

       if MAKEWIN1251
;make 1251 font
        ld hl,propfont
        ld de,waspropfont
        ld bc,0x900
        ldir

        ld e,0
mk1251_chars0        
        ld d,twinto866/256
        ld a,(de)
        ld l,a
        ld d,propfont/256
        ld h,waspropfont/256
        ld b,9
mk1251_char0
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        djnz mk1251_char0
        inc e
        jr nz,mk1251_chars0
       endif
        
       if MAKEROTATEDFONT
        ld l,0
mkrotfont0
       push hl
        ld h,propfont/256
        ld de,chardata
        ld b,8
mkrotfont_copychar0
        ld a,(hl)
        ld (de),a
        inc h
        inc e
        djnz mkrotfont_copychar0
       ;ld c,(hl) ;charwidth
        ex de,hl
        ld d,propfont/256 + 7
        ld b,8
mkrotfont_rotchar0
        ld hl,chardata
        dup 8
        rl (hl)
        rla
        inc l
        edup
        ld (de),a
        dec d
        djnz mkrotfont_rotchar0
       pop hl
        inc l
        jr nz,mkrotfont0
       endif
        
        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000
        
;01          89          01    ;low+0x0000
;   23          ab          23 ;high+0x0000
;      45          cd          ;low+0x2000
;         67          ef       ;high+0x2000

        ;ld hl,0x8000
        ;ld b,10
        ;ld c,0xff        
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=wid/2
        ;call drawhorline
        ;jr $
        
        ld l,1
        ld e,10
        ld hx,0b00111111 ;fill color byte 0bRLrrrlll
        ld lx,0b00000000 ;11111111 ;brush color byte 0bRLrrrlll
        ld b,100-1 ;hgt-1
        ld c,159 ;wid/2
;l=x/2
;e=y
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        call drawwindow

        ld hl,0x8000+(40*100)
        ld e,0
pr0
        push hl
        ld ly,1;0 ;phase
        ld d,32
pr1
        push de
        ld a,e ;char
        ex de,hl
        call prcharprop
        ex de,hl
        pop de
        inc e
        dec d
        jr nz,pr1
        pop hl
        ld bc,8*40
        add hl,bc
        inc e
        dec e
        jr nz,pr0
        
        jr $
        
        QUIT

xytoscraddr
;l=x/2
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        ld h,tx/256
        ld d,ty/256
        ld a,(de) ;(y*40)
        add a,(hl) ;x div 4
        ld (xytoscraddr_l),a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
xytoscraddr_l=$+1
        ld l,0
        ret

        if 1==0
prpixel
;bc=x (не портится)
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        push bc
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ;ld d,ty/256
        ;ld h,tx/256
        ld a,(de) ;(y*40)
        jr c,prpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
prpixel_color_l=$+1
        or 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
prpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
prpixel_color_r=$+1
        or 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
        endif

drawwindow
;l=x/2
;e=y
        ld hy,e
        ld a,l
        ld ly,a
;ly=x/2
;hy=y
        call xytoscraddr
;hl=screen addr
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        
drawwindowfill0
        push bc
        push hl
        ld c,hx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        call drawverline
        pop hl
        NEXTCOLUMN
        pop bc
        dec c
        jr nz,drawwindowfill0
        
        pop hl ;screen addr
        pop bc

        push bc

        push bc
        push hl
        call drawbox
        pop hl
        pop bc
        NEXTCOLUMN
        ld de,40*2
        add hl,de ;второй бокс внутри первого
        dec c
        dec c
        ld a,b
        sub 4
        ld b,a
        call drawbox
        
        pop bc ;b=hgt-1, c=wid/2
        
;ly=x/2
;hy=y
        ld e,hy
        inc e
        call drawwindowhormarks
        
        ld a,hy
        add a,b ;+hgt-1
        dec a
        ld e,a
        call drawwindowhormarks

        push bc
        call drawwindowvermarks
        pop bc
        ld a,ly
        add a,c ;wid/2
        dec a
        ld ly,a
        call drawwindowvermarks
        
        ret
        
drawwindowvermarks
;ly=x/2
;hy=y
;b=hgt-1
;lx=color byte 0bRLrrrlll
        ld a,ly
        ld l,a
        ld a,hy
        add a,6
        ld e,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ld a,ly
        ld l,a
        ld a,hy
        add a,b ;+hgt-1
        sub 6
        ld e,a
;l=x/2
;e=y        
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ret

        
drawwindowhormarks
;ly=x/2
;e=y
;c=wid/2
        ld a,ly
        add a,3
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a

        ld a,ly
        add a,c ;+wid/2
        sub 3+1
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a
        ret
        

drawbox
;hl=screen addr
;lx=color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        push bc
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        call drawverline ;left line
        pop bc
        ld b,c ;wid/2
        ex (sp),hl
        ld c,lx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        push bc
        call drawhorline ;top line
        pop bc ;b=wid/2, c=color byte 0bRLrrrlll
        ex (sp),hl ;bottom of left line
        call drawhorline ;bottom line
        pop hl ;rightmost byte of top line
        ld de,40
        add hl,de
        pop bc
        dec b ;b=hgt/2
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        ;call drawverline ;right line
        ;ret
drawverline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=hgt
        ld de,40
drawverline0
        ld (hl),c
        add hl,de
        djnz drawverline0
        ret

drawhorline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=wid/2
        ld de,0x4000
        jr drawhorline0go
drawhorline0
        NEXTCOLUMN
drawhorline0go
        ld (hl),c
        djnz drawhorline0
        ret

    if !ROTATEDFONT
prcharprop_shch
        ld a,30
        call prcharprop_do
        ld a,31
        jr prcharprop_do
    endif
prcharprop
;print with proportional font (any char width up to 8)
;de=screen addr
;ly=phase (even=left pixel [of next screen addr], odd=right pixel)
;a=char
    if ROTATEDFONT
        ld l,a
        ld h,propfont/256 + 8
        ld a,ly ;phase
       ld c,a ;phase
        add a,(hl) ;charwidth
        dec h
        ld ly,a ;nextphase = phase + charwidth
       inc a
       or 1
       sub c ;phase
       rra
       ld hy,a ;number of 2 pixel columns = (((nextphase+1)|1) - phase)/2      
        ld bc,40
        ld a,b ;0
       jr nc,prcharprop_columns0_skipbyte ;odd phase = blank left pixel in same screen addr
;de=screen addr
;hl=gfx addr
prcharprop_columns0
	bit 6,d
	set 6,d
	jr z,$+2+4+2+2+1
	 ld a,d
	 xor 0x60
	 ld d,a
	 and 0x20
	 jr nz,$+3
	 inc de
        ld a,(hl)
        dec h
prcharprop_columns0_skipbyte
        push de ;screen addr
        push hl ;gfx addr
        ld h,(hl)
        ld l,a
        ex de,hl
        dup 7
        ld a,(hl)
        rl e ;CY=left pixel
        jr nc,$+4
        or 0x47 ;hx
        rl d ;CY=right pixel
        jr nc,$+4
        or 0xb8 ;lx
        ld (hl),a
        add hl,bc
        edup
        ld a,(hl)
        rl e ;CY=left pixel
        jr nc,$+4
        or 0x47 ;hx
        rl d ;CY=right pixel
        jr nc,$+4
        or 0xb8 ;lx
        ld (hl),a
;3. next column and loop
        pop hl ;gfx addr
        dec h
        pop de ;screen addr
        dec hy
        jp nz,prcharprop_columns0
;de=next screen addr
        ret
    
    else ;~ROTATEDFONT
    
;Щ (Shch) doesn't fit in 8 bits + scroll
;print it as Ш (Sh) + tail
       if WIN1251
        cp '┘'
       else
        cp 'Щ'
       endif
        jr z,prcharprop_shch
prcharprop_do
       push de
        ld l,a
        ld h,propfont/256
        ld de,chardata
;1. copy char data
;shift 1 pix right if needed
        ld a,ly ;phase
        rra
        jr nc,prcharprop_copyfontnoscroll
        dup 7
        ld a,(hl)
        rrca
        ld (de),a
        inc h
        inc e
        edup
        ld a,(hl)
        rrca
        jp prcharprop_copyfontq
prcharprop_copyfontnoscroll
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc e
        edup
        ld a,(hl)
prcharprop_copyfontq
        ld (de),a
        inc h
        ld b,(hl) ;charwidth
        ld a,ly ;phase
        add a,b
        ld ly,a ;next phase = phase + charwidth
        sub b ;ld a,c ;phase
        and 1 ;phase&1
        inc a
        add a,b ;charwidth
        rra
        ld hy,a ;number of 2 pixel columns = (charwidth + (phase&1) + 1)/2
       pop hl
;hl=screen addr
;hy=number of 2 pixel columns = (charwidth + (phase&1) + 1)/2
;ly=next phase (even=left, odd=right pixel)
;2. print 2 pixel vertical line (scroll left bits 7,6 in char data)
        ld bc,40
prcharprop_columns0
        push hl
        ld de,chardata
        dup 7
        ex de,hl
        ld a,(de)
        rl (hl) ;CY=left pixel
        jr nc,$+4
        or 0x47 ;hx
        rl (hl) ;CY=right pixel
        jr nc,$+4
        or 0xb8 ;lx
        ld (de),a
        ex de,hl
        add hl,bc
        inc e
        edup
        ex de,hl
        ld a,(de)
        rl (hl) ;CY=left pixel
        jr nc,$+4
        or 0x47 ;hx
        rl (hl) ;CY=right pixel
        jr nc,$+4
        or 0xb8 ;lx
        ld (de),a
;3. next column and loop
        pop hl
        ld d,h
        ld e,l ;this will be next screen addr if the char ends in odd column ((ly&1) = 1)
	bit 6,h
	set 6,h
	jr z,$+2+4+2+2+1
	 ld a,h
	 xor 0x60
	 ld h,a
	 and 0x20
	 jr nz,$+3
	 inc hl
        dec hy
        jp nz,prcharprop_columns0
        ld a,ly ;ly=next phase (even=left, odd=right pixel)
        rra
        ret c ;old screen addr if the char ends in odd column ((ly&1) = 1)
        ex de,hl
;hl=next screen addr
        ret
    endif ;~ROTATEDFONT

        align 8
chardata
        ds 8 ;any place for inc l

        align 256
propfont
      if ROTATEDFONT & !MAKEROTATEDFONT
       if WIN1251 & !MAKEWIN1251
        incbin "prot1251.bin" ;0x800 font + 0x100 width
       else
        incbin "protfont.bin" ;0x800 font + 0x100 width
       endif
      else
       if WIN1251 & !MAKEWIN1251
        incbin "prop1251.bin" ;0x800 font + 0x100 width
       else
        incbin "propfont.bin" ;0x800 font + 0x100 width
       endif
      endif

       if MAKEWIN1251
waspropfont
        ds 0x900
        align 256
twinto866
        incbin "winto866"
       endif

        align 256
tx
        dup 256
        db ($&0xff)/4
        edup
        dup 64
        db 0x80
        db 0xc0
        db 0xa0
        db 0xe0
        edup
ty
        dup 200
        db 0xff&(($&0xff)*40)
        edup
        ds 56,0xff&8000
        dup 200
        db (($&0xff)*40)/256
        edup
        ds 56,8000/256

end

      if !ROTATEDFONT
;fix font
        org propfont+30 ;Ш without spacing instead of Щ
        db 0
        org $+255
        db 0x82
        org $+255
        db 0x92
        org $+255
        db 0x92
        org $+255
        db 0x92
        org $+255
        db 0x92
        org $+255
        db 0xfe
        org $+255
        db 0
        org $+255
        db 7

        org propfont+31 ;tail
        db 0
        org $+255
        db 0
        org $+255
        db 0
        org $+255
        db 0
        org $+255
        db 0
        org $+255
        db 0
        org $+255
        db 0x80
        org $+255
        db 0x80
        org $+255
        db 1
      endif

	savebin "gfxtest.com",begin,end-begin
	LABELSLIST "../../../us/user.l",1
