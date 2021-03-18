swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038
        jp 0x0038+3

on_int
;restore stack with de
        EX DE,HL
	EX (SP),HL ;de="hl", в стеке "de"
	LD (on_int_jp),HL
	;EX DE,HL
	;POP DE
	LD (on_int_sp),SP
	LD SP,INTSTACK        
        push af
        push bc
        push de ;"hl"
        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

        ld hl,_palChange
        xor a
        cp (hl)
        ld (hl),a
        jp z,int_nochangepal
	ld de,(_palBright)
	ld a,d
	add a,high palBrightTable
	ld b,a
        ld lx,e
	ld hl,_palette
        ld de,CURPAL
	dup 16
	ld a,(hl)
	add a,lx
	ld c,a
	ld a,(bc)
        ld (de),a
        inc de
        ld (de),a
        inc de
	inc l
	edup
	ld a,(_borderCol)
        ld e,a
	OS_SETBORDER
        ld de,CURPAL
        OS_SETPAL
int_nochangepal
        call oldimer

        GET_KEY
       ld (curmouse),de
       ld a,l
       ld (curmousebuttons),a
        ;ld a,c ;кнопка без учёта языка
        ;or a
        ;jr z,$+5
        ;ld (curkey),a
	;CALL .. ;ваш обработчик прерываний
        
        ld a,(curpg16k) ;ok
        push af
        ld a,(curpg32klow) ;ok
        push af
        ld a,(curpg32khigh) ;ok
        push af

	ld a,SND_PAGE
        call setpg4000

	ld a,(musicPage)
	or a
	jr z,.noMusic
        call setpg8000
	ld bc,#fffd
	ifdef TFM
	ld a,%11111000		;второй чип Turbo FM
	else
	ld a,#fe		;второй чип Turbo Sound
	endif
		;если Turbo Sound нет, звуки и музыка
	out (c),a		;играют на одном чипе, иначе на разных

	ifdef TFM
	ld a,(TURBOFMON)
	or a
	call nz,PT3_FRAME
	else
	call PT3_FRAME
	endif

	ifdef TFM
	;jr .sfx ;wrong TS detection on TFM?
	else
	ld a,(turboSound)
	or a
	jr z,.sfx
	endif

.noMusic
	ifdef TFM
	;ld a,(TURBOFMON)
	;or a
	;call nz,PT3_MUTE ;reset_ay
	ld a,1
	call reset_ay_ay
	else
	ld a,1
	call reset_ay
	endif
.sfx

	ifdef TFM
	ld bc,#fffd
	ld a,%11111001		;1-й чип Turbo FM
	;ld a,%11111011		;1-й чип Turbo FM, no wait sync
	out (c),a
	else
	ld bc,#fffd		;первый чип
	out (c),b
	endif

	call AFX_FRAME

	;счётчик кадров

	ld hl,_time
	ld b,4
.time1
	inc (hl)
	jr nz,.time2
	inc hl
	djnz .time1
.time2
        
        pop af
        SETPG32KHIGH
        pop af
        SETPG32KLOW
        pop af
        SETPG16K
        
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop hl
        pop bc
        pop af
on_int_sp=$+1
	ld sp,0
        pop de
	EI
on_int_jp=$+1
	jp 0

curmouse
        dw 0
curmousebuttons
        db 0
