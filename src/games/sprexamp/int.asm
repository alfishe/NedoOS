swapimer
	di
         ld hl,(0x0038+3) ;адрес intjp
         ld (intjpaddr),hl        
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

on_int
;restore stack with de
        EX DE,HL
	EX (SP),HL ;de="hl", в стеке "de"
intjpaddr=$+1
	LD (0),hl ;(on_int_jp),HL
	;EX DE,HL
	;POP DE
	LD (on_int_sp),SP
	LD SP,INTSTACK
        
        push af
        push bc
        push de
        push hl
        exx
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        
        GET_KEY
        ld a,c ;кнопка без учёта языка
        or a
        jr z,$+5
        ld (curkey),a
        
        OS_GETKEYMATRIX
	rr c ;'a'
	rla ;A
	rr c ;'s'
	rla ;B
	ld c,lx
	rr c ;'Space'
	rla ;Select
	ld c,hx
	rr c ;'Enter'
	rla ;Start
	add a,a
	bit 3,h ;7
	jr z,$+3
	inc a ;Up
	add a,a
	bit 4,h ;6
	jr z,$+3
	inc a ;Down
	add a,a
	bit 4,e ;5
	jr z,$+3
	inc a ;Left
	add a,a
	bit 2,h ;8
	jr z,$+3
	inc a ;Right
        cpl 
        ld (joystate),a
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
	;CALL .. ;ваш обработчик прерываний (не забывайте сохранить CURPG...)
        ld a,(CURPG16K) ;ok ;(curpg4000)
        SETPG16K
        ld a,(CURPG32KLOW) ;ok ;(curpg8000)
        SETPG32KLOW
;curpgc000=$+1
;        ld a,0
        ld a,(CURPG32KHIGH) ;ok
        SETPG32KHIGH

        ld hl,timer
        inc (hl)
        
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        exx
        pop hl
        pop de
        pop bc
        pop af
        
on_int_sp=$+1
	ld sp,0
;	EI
;on_int_jp=$+1
;	jp 0
        ;push de
        ;ex de,hl
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        jp 0x0038+5

;вход в стандартный обработчик:
        ;ex de,hl ;de="hl", hl="de"
        ;ex (sp),hl ;hl=адрес выхода, de="hl", в стеке "de"
        ;ld (intjp),hl ;TODO писать не прямо в intjp, а в промежуточную локацию (иначе хвост обработчика нельзя с ei - он сам не может сменить режим обработки прерывания после jp)
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        ;ld l,a
;user_fdvalue6=$+1
        ;ld a,fd_system
        ;out (0xfd),a ;10 b

timer
        db 0
