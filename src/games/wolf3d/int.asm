on_int
;store DE in stack
        ex de,hl
        EX (SP),HL
        LD (on_int_jp),HL
        LD (IMSP),SP
        LD SP,INTSTACK
	push de

	push af
	push bc

        push ix
        push iy
        ex af,af' ;'
        exx
        push af
        push bc
        push de
        push hl
       
       if doublescr
       if atm       
on_int_0026=$+1
        ld hl,0
        ld (0x0026),hl ;восстановили запоротый стек 0x0028 (=40)
        ld a,(curscrnum)
        ld e,a
        OS_SETSCREEN ;вызываем здесь, а не в рандомном месте, иначе даже с одной задачей можем получить непредсказуемую задержку, которую не фиксирует наш таймер? с несколькими задачами надо учитывать и системный - TODO
curpalette=$+1
        ld de,wolfpal
        OS_SETPAL
        call oldimer ;ei
        GET_KEY
        or a
        jr z,$+5
        ld (curkey),a
       else ;~atm
        call my_int
        LD A,(newscr)
        LD (curscr),A
curpg=$+1
        LD A,#10
        CALL SETPG
       endif
       endif
       
timer=$+1
        LD HL,0
        inc hl
        LD (timer),HL
       IF showfps
IMframe=$+1
        LD A,1
        DEC A
        jr nz,IMNSEC
        ld hl,0x3939 ;!=colour
        ld (0x5800),hl
        ld e,a;0 ;LD DE,0x4000;#4100
       ;LD DE,#4100<1
       ;RR D
IMfps=$+1
        LD A,0
        LD C,10
        CALL PRDIG
        LD C,1
        CALL PRDIG
        ;XOR A
        LD (IMfps),A
        LD A,50
IMNSEC
        LD (IMframe),A
       ENDIF 

        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af' ;'
        pop iy
        pop ix

	pop bc
	pop af

        pop de
IMSP=$+1
        LD SP,0
        POP HL
        ex de,hl
       if !atm
        ei
       endif
on_int_jp=$+1
	jp 0

       IF showfps
PRDIG
        LD L,15
        INC L
        SUB C
        jr NC,$-2
        ADD A,C
        PUSH AF
        LD A,L
        ADD A,A
        ADD A,A
        ADD A,A
        ;INC A
        LD L,A
        LD H,#3D
        ;PUSH DE
        ld d,0x40
        LD B,7;6
        LD A,(HL)
        ld (DE),A
        INC L,D
        DJNZ $-4
        ;POP DE
        POP AF
        INC E
        RET 
       ENDIF 

       if atm
swapimer
	di
         ld hl,(0x0026) ;ok
         ld (on_int_0026),hl
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
       endif
