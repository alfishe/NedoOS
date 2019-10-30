
;ÑÖåéçëíêÄñàéççõâ êÖÜàå

NNN_D	;§•¨Æ-‡•¶®¨
	EI
        ;jr $
	CALL MEM6
	CALL ANIMTR ;6
	CALL SPLIN  ;6
	CALL cTIC   ;6
	CALL MEM0
	CALL  d_LIFE ;*
	CALL ACTION ;0
	CALL SHED_H ;0
	CALL SHED_K ;0
	CALL BULLER ;0
	CALL hSCAN  ;0
	CALL kSCAN  ;0
	CALL MEM7
	CALL O12X12 ;m OU_SCR
	LD A,(CONTRB)
	OR A
	JR Z,NNN_D
	RET

d_LIFE	LD HL,KUNGE+5
	LD DE,16
	LD B,10
d_L1	LD (HL),200
	ADD HL,DE
	DJNZ d_L1
	;
d_CTRL	CALL loop_H
d_C2	LD A,(IX+9)
	OR A
	JR NZ,d_C1
	LD (IX+10),24
	LD (IX+11),30
	CALL IX_93
d_C1	ADD IX,DE
	DJNZ d_C2
	;
	LD A,4
	LD (makTRY),A
	;
	LD HL,0
	LD (MX),HL
	;
d_NEW	LD A,(TIC)
	CP 1
	RET NZ
	LD A,R
	LD C,13
	AND 2
	JR Z,d_N1
	DEC C
d_N1	CALL RND
	AND 15
	INC A
	LD B,A
	LD A,R
	AND 15
	ADD A,16
	LD L,A
	LD H,16
d_N2	PUSH HL
	PUSH BC
	CALL stayON
	POP BC
	PUSH BC
	LD A,C
	EX AF,AF
	XOR A
	CALL NEWHER
	POP BC
	POP HL
	DJNZ d_N2
	RET

DEMO	DI
	CALL MEM0	;0
	CALL setMAP	;0
	CALL shadwS	;1

        ld b,50
showflags0
        push bc
        YIELD
        pop bc
        djnz showflags0
        if EGA
        call setpal
        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
        endif

	CALL ANIset	;1
	CALL NEWALL ;1
	CALL NEWenm ;1
	LD HL,#1412
	LD (X0),HL
	;
d_FRAM	;¢Î¢ §•¨Æ Æ‰Æ‡¨´
	CALL MEM7
	LD HL,0
	LD BC,#1820
	PUSH HL
	PUSH BC
	LD E,L
	CALL STS
	CALL ATRBAR
	CALL O12X12
	CALL STS
	LD A,R
	AND 1
	INC A
	OUT (254),A
	POP BC
	POP HL
	ADD A,#30
	LD E,A
	CALL ATRBAR
	LD HL,#202
	LD BC,#1414
	LD E,#70
	CALL ATRBAR
	JP NNN_D

