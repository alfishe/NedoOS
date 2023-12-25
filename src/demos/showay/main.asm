        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

STACK=0x4000
scrbase=0x8000

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

        ld e,0+0x80
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        
        ld e,0 ;color byte 0bRLrrrlll
        OS_CLS

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
	
	ld de,pal
	OS_SETPAL
        
	;ld hl,0;0x8000
	;ld de,0x8001
	;ld bc,0x7fff
	;ldir

;смещаем таблицу частот на серединки между нотами, чтобы легче сравнивать
	ld hl,tb_st
	ld de,0x0fff ;previous freq
	ld lx,96
retb0
	ld c,(hl)
	inc l
	ld b,(hl)
	dec l
	push bc ;previous freq
	ex de,hl
	add hl,bc
	;inc hl
	srl h
	rr l
	ex de,hl
	ld (hl),e
	inc l
	ld (hl),d
	inc hl
	pop de ;previous freq
	dec lx
	jr nz,retb0
	
loop
pause_on=$+1
	or a
	jr c,pauseq
	call drawnotes
        call scrollleft
pauseq
	YIELD
        GET_KEY ;GETKEY_ ;OS_GETKEYNOLANG
        ld a,c ;keynolang
	cp ' '
	call z,pause
	cp '1'
	call z,shut_a
	cp '2'
	call z,shut_b
	cp '3'
	call z,shut_c
        ;cp NOKEY
	;jr z,loop
        cp key_esc
	jr nz,loop
	
        QUIT
	
pause
	ld hl,pause_on
switch
	ex af,af' ;'
	ld a,(hl)
	xor 128
	ld (hl),a
	ex af,af' ;'
	ret
	
shut_a
	ld hl,a_on
	jr switch
shut_b
	ld hl,b_on
	jr switch
shut_c
	ld hl,c_on
	jr switch
	
drawnotes
	ld a,0xfe
	ld bc,0xfffd
	out (c),a
	call drawnotes_chip
	ld bc,0xfffd
	out (c),b
drawnotes_chip
	ld a,7
	call getreg
	ld c,a ;..cbaCBA (cba шум, CBA тон, инвертированные)
	set 7,c ;no env
	set 6,c ;wrong noise
	
	ld a,6
	call getreg
	or a
	jr nz,$+4
	res 6,c ;noise is analyzable
	
a_on=$
	or a
	ld a,0
	call nc,drawnotes_channel
b_on=$
	or a
	ld a,1
	call nc,drawnotes_channel
c_on=$
	or a
	ld a,2
	call nc,drawnotes_channel
	bit 7,c
	ret nz
;env
	ld a,11
	call getfreq
	ld a,13
	call getreg
	and 15
	cp 8
	ret c
	bit 0,a
	ret nz ;нечётный тип огибающей - не рисовать
	bit 1,a ;a/e?
	jr z,noslowenv
	sla e
	rl d
noslowenv
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	call drawfreq
	ret

drawnotes_channel
	ld (drawnotes_channel_a),a
	add a,8
	call getreg_setenvflag
	jr z,drawnotes_noA
	 cp 7;8
	 jr c,drawnotes_noA
	bit 0,c
	jr nz,drawnotes_noA
	bit 3,c
	jr nz,drawnotes_nonoiseA ;no noise
	bit 6,c
	jr nz,drawnotes_noA ;wrong noise
drawnotes_nonoiseA
drawnotes_channel_a=$+1
	ld a,0
	add a,a
	call getfreq
	push bc
	call drawfreq
	pop bc
drawnotes_noA
	ld a,c
	rra
	xor c
	and 0x3f
	xor c
	ld c,a
	ret

getfreq
	ld d,a
	call getreg
	ld e,a
	ld a,d
	inc a
	call getreg
	ld d,a
	ret
	
drawfreq
	ld hl,tb_st
;сейчас в таблице частоты на четверть тона ниже
	ld lx,96
findfreq0
	ld c,(hl)
	inc l
	ld a,(hl)
	cp d
	jr c,findfreq_overflow ;наш период de больше, чем табличный
	jr nz,findfreq_next
	ld a,c
	cp e
	jr c,findfreq_overflow ;наш период de больше, чем табличный
findfreq_next
	inc hl
	dec lx
	jr nz,findfreq0
findfreq_overflow ;наш период de больше, чем табличный
;первый F# (ми) = 59

;если lx=96, то наша нота ниже, чем самая нижняя возможная
;правильные ноты 95..0
	ld a,95
	sub lx ;=-1..95
	adc a,0
	
	cp 12
	ret c
	cp 96-12
	ret nc
	
	ld l,a ;нота 0..95 ;первый F# (ми) = 6
	ld h,tcolor/256
	ld c,(hl) ;4..15 ;первый F# (ми) цвет 9
	ld a,c
	and 8
	ld b,a
	rla
	or b
	rlca
	rlca
	rlca ;0xc0
	ld b,a
	ld a,c
	and 7
	ld c,a
	rlca
	rlca
	rlca
	or c
	or b
	 ld c,a

	ld h,ty/256
	ld a,95*2
	sub l
	sub l
	ld l,a ;y
	ld a,(hl)
	inc h
	ld h,(hl)
	ld l,a
	 ld a,c
	ld bc,39+0x8000+0x6000
	add hl,bc
	ld (hl),a;0xff
	ret
	
getreg_setenvflag
	call getreg
	bit 4,a
	jr z,$+4
	res 7,c ;env
	or a
	ret

getreg
	push bc
	ld bc,0xfffd
	out (c),a
	in a,(c)
	pop bc
	ret

scrollleft
;01          89          01    ;low+0x0000
;   23          ab          23 ;high+0x0000
;      45          cd          ;low+0x2000
;         67          ef       ;high+0x2000

	ld hl,0x8000+(12*40*2)
	ld hx,96-12-12
scroll0
       push hl ;+0x0000
	push hl ;+0x0000
	ld d,h
	ld e,l
	set 6,h
	dup 39
	ldi
	edup
	ld a,(hl)
	ld (de),a
	pop hl ;+0x0000
	ld d,h
	ld e,l
	set 5,h
	set 6,d
	push hl ;+0x2000
	dup 39
	ldi
	edup
	ld a,(hl)
	ld (de),a
	pop hl ;+0x2000
	push hl ;+0x2000
	ld d,h
	ld e,l
	set 6,h
	dup 39
	ldi
	edup
	ld a,(hl)
	ld (de),a
	pop hl ;+0x2000
	ld d,h
	ld e,l
	res 5,h
	inc l;hl
	set 6,d
	dup 39
	ldi
	edup
	xor a
	ld (de),a
       pop hl ;+0x0000
	ld bc,40*2
	add hl,bc
	dec hx
	jp nz,scroll0
	ret

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

	align 256
tb_st
	incbin "tb_st.bin"

	align 256
tcolor
	dup 8
	db 4,5,6,7,8,9,10,11,12,13,14,15
	edup

pal
	;dw 0x3c3c ;9 (ля, малиновое)
	;dw 0x1c1c ;4 (ми, пурпурное)
	;dw 0x5c5c ;11 (си, фиолетовое)
	;dw 0x1e1e ;6 (фа-диез, синее) - blue note
	;dw 0x8e8e ;1 (до-диез, сине-голубое)
	;dw 0x0e0e ;8 (соль-диез, голубое)
	;dw 0x2e2e ;3 (ре-диез, сине-зелёное)
	;dw 0x0f0f ;10 (ля-диез, зелёное)
	;dw 0x4d4d ;5 (фа, жёлто-зелёное)
	;dw 0x0d0d ;0 (до, жёлтое)
	;dw 0x8d8d ;7 (соль, оранжевое)
	;dw 0x1d1d ;2 (ре, красное)
	;dw 0x0c0c ;W
	;dw 0xecec ;w
	;dw 0x1f1f ;grey
	;dw 0xffff ;black
;в Sound Tracker строй си-бемоль ("до" называется D и т.д.)
	dw 0xffff ;black
	dw 0x1f1f ;grey
	dw 0xecec ;w
	dw 0x0c0c ;W
	dw 0x0f0f ;10 (ля-диез = си-бемоль, зелёное) -- C
	dw 0x5c5c ;11 (си, фиолетовое)               -- C#
	dw 0x0d0d ;0 (до, жёлтое)                    -- D
	dw 0x8e8e ;1 (до-диез, сине-голубое)         -- D#
	dw 0x1d1d ;2 (ре, красное)                   -- E
	dw 0x2e2e ;3 (ре-диез, сине-зелёное)         -- F   +
	dw 0x1c1c ;4 (ми, пурпурное)                 -- F#
	dw 0x4d4d ;5 (фа, жёлто-зелёное)             -- G
	dw 0x1e1e ;6 (фа-диез, синее) - blue note    -- G#  +
	dw 0x8d8d ;7 (соль, оранжевое)               -- A   +
	dw 0x0e0e ;8 (соль-диез, голубое)            -- A#
	dw 0x3c3c ;9 (ля, малиновое)                 -- B
	
end

	savebin "showay.com",begin,end-begin
	LABELSLIST "../../../us/user.l",1
