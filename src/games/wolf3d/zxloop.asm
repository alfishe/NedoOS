ZXLOOP
       if atm
       call changescrpg
;        ld a,1
;curscreen=$+1
;        xor 1
;        ld (curscreen),a
;         add a,a
;         add a,a
;         add a,a
;         ld (imer_curscreen_value),a
	ld hl,(timer)
        ld (endoflastredrawtimer),hl
       endif

        ;LD A,pgscale
        ;CALL SETPG

;------------------------
       IF atm
        call setpgmap4000
       ENDIF 
        LD HL,(timer)
oldtimer=$+1
        LD BC,0
        LD (oldtimer),HL
        OR A
        SBC HL,BC
        jr Z,nONTIMER
         ld bc,8
         or a
         sbc hl,bc
         add hl,bc
         jr c,ONTIMER0
         ld h,b
         ld l,c ;hl<=8
ONTIMER0
        PUSH HL
        CALL CONTROL ;там же логика
        POP HL
        DEC HL
        LD A,H
        OR L
        jr NZ,ONTIMER0
nONTIMER
       IF atm == 0
       IF doublescr
        LD A,#10
        CALL SETPG
       ENDIF 
       ENDIF 
       ;HALT
        CALL SCAN

       IF doublescr
;ждать флаг ожидания готовности экрана (включается по прерыванию)
;иначе будет так:
;фрейм 1:
;видим экран0, рисуем экран1
;фрейм 2:
;видим экран0, закончили рисовать экран1, [вот тут нужно ожидание], начали рисовать экран0 (хотя его видим)
;фрейм 3:
;видим экран1
;готовность - это когда текущий таймер != таймер конца прошлой отрисовки
;проверяем оба таймера, а то могло случиться системное прерывание
EmulatePPU_waitforscreenready0
        ld hl,(timer)
endoflastredrawtimer=$+1
        ld de,0
        or a
        sbc hl,de
        jr z,EmulatePPU_waitforscreenready0
       ENDIF 

       IF atm
pgscalersnum=$+1
        LD A,0
        setpgafast
        
;        LD A,2
;setpgs_scr_xor=$+1
;        XOR 2
;        LD ($-1),A
;setpgs_scr_low=$+1
;        XOR 0xff-1;#7F-pgattr1
;        ld (curscrpg_low),a
;       PUSH AF
;        SETPG4000
       call getuser_scr_low
       SETPG4000
        CALL DWCLSALL
        xor a;LD A,0
        CALL DRAWWALLS
       call getuser_scr_high
       SETPG4000
;       POP AF
;setpgs_scr_high_xor_low=$+1
;        XOR 4;pgattr1^pgpix1
;        SETPG4000
        
        CALL DWCLSALL
        LD A,1
        CALL DRAWWALLS
       IF sprites
       CALL SCANMONS
       CALL DRAWSPRITES
       ENDIF 

       ELSE ;~atm

        CALL CLSCRBUF
        CALL DRAWWALLS
        CALL CHECKHEIGHTS
       IF sprites
       CALL SCANMONS
       CALL DRAWSPRITES
       ENDIF 
       IF crosshair
        CALL CROSSHAIR
       ENDIF 
       IF doublescr
        LD A,(curscr)
newscr=$+1
        CP 0
        jr Z,nohalt
        HALT ;if CPU is too fast
nohalt
        LD A,#17
        CALL SETPG
       ENDIF 
        CALL EORFILL
       IF doublescr
        LD A,(newscr)
        XOR 8
        LD (newscr),A
       ENDIF 
       ENDIF 
;-----------------------
       IF showfps
        LD HL,IMfps
        INC (HL)
       ENDIF 

	if atm
curkey=$+1
        ld a,0
        cp key_esc
        jr z,ZXLOOPQUIT
        cp key_redraw
        call z,redraw
	endif
       
       ;LD A,0xfe
       ;IN A,(0xFE)
       ;rra ;caps shift
       ;JP c,ZXLOOP
       ;LD A,0x7F
       ;IN A,(0xFE)
       ;RRA ;space
       ;JP NC,ZXLOOPQUIT
       
        jr ZXLOOP
ZXLOOPQUIT
        ret

	if atm
redraw
        xor a
        ld (curkey),a ;чтобы redraw не повторялся
        call redraw_cls
        ld a,1
redraw_cls
        ;ld (curscrnum),a ;for interrupt
        ld e,a
        OS_SETSCREEN
        ld e,0
        OS_CLS
        ret
	endif

sfxplay
       if atm
        push af
pgsfx=$+1
        ld a,0
        SETPG8000
        pop af
        jp 0x8000 ;SFXPLAY
       else
	ret ;TODO
       endif
