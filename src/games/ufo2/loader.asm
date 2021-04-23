        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,3
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

	ld de,file_path
	OS_CHDIR

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000  
        ld a,l
        ld (tpgs+0),a

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,(user_scr1_high) ;ok
       if EGA
         ;ld (scrpg7),a
       else 
         ld (getttexpgs_basepg7),a
       endif
       
        OS_NEWPAGE
        ld a,e
        ld (tpgs+6),a

        ld hl,texfilename
        ld b,ntexfilenames
getttexpgs0
        push bc
        ld a,(hl)
        or a
        ld a,(tpgs+0)
        jr z,getttexpgs7
        ld a,(hl)
       if EGA==0
        cp 7
getttexpgs_basepg7=$+1
        ld a,0
        jr z,getttexpgs7
       endif
        push de
        push hl
        OS_NEWPAGE
        ld a,e
        pop hl
        pop de
getttexpgs7
        ld c,(hl)
        ld b,tpgs/256
        ld (bc),a
        inc hl
        push hl
        SETPG32KHIGH

        ld a,(hl)
        cp ' '
        jr nc,gettexpgs_noskipdata
        inc hl
gettexpgs_noskipdata
        ex de,hl
        push af
        OS_OPENHANDLE
        pop af ;CY=skip data, a=number of 8Ks to skip
        jr nc,gettexpgs_noskipdata2
        push bc
        ld de,0
        ld hl,0
        rra
        rr h
        rra
        rr h
        rra
        rr h
        OS_SEEKHANDLE ;dehl=offset
        pop bc
gettexpgs_noskipdata2
        push bc
        ld de,0xc000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
                
        pop hl
        ld b,1
        xor a
        cpir ;after 0
        pop bc
        djnz getttexpgs0
        jp JP_ST

        align 256
tpgs
        ds 64
        
quit
        ld hl,0 ;result
        QUIT
        
PT128	LD	A,6;Cтандартная страница
	JR	MEM

MEM7	LD	A,7
MEM	OR	%11011000
_128	;LD	BC,#7FFD
	;OUT	(C),A
        ld b,tpgs/256
        and 7
        ld c,a
        ld a,(bc)
        SETPGC000
	RET

LODmlz	LD HL,#4000 ;c компр
	;CALL WT
;WT
        RLCA
	ADD	A,L
	LD	L,A
	JR	NC,wWT_
	INC	H
wWT_	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	;RET
	XOR A
	CALL MEM
	;JP DELPC

;DEC40
        include "unmegalz.asm"

file_path
        db "ufo2",0

texfilename
        db 0,"ufo20.dat",0
        db 1,"ufo21.dat",0
        db 3,"ufo23.dat",0
        db 4,"ufo24.dat",0
        ;db 6,"br6.dat",0
        db 7,"ufo27.dat",0
        if EGA==0
ntexfilenames=5
        else
        endif
