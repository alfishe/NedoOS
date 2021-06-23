;EGA=1
        include "settings.ast"

xHERO=0xc000
xDIE	EQU xHERO+#3000
xBOOM	EQU xDIE+#300
xBUM	EQU xBOOM+#300
xBULL	EQU xBUM+#480

STACK=0x4000
COMBATSTACK=0x3f80;#8F7E

        macro Ms _a;$	MAC
	LD	A,_a ;=0
	CALL	MEM
	ENDM

        macro PUSHs;$	MAC
	PUSH	HL
	PUSH	DE
	PUSH	BC
	ENDM
        macro POPs;POP$	MAC
	POP	BC
	POP	DE
	POP	HL
	ENDM

        macro pushs;$	MAC
	PUSH	BC
	PUSH	HL
	ENDM
        macro pops;pop$	MAC
	POP	HL
	POP	BC
	ENDM
        macro WRDs _hl,_a;$    MAC
	LD HL,_hl;=0
	LD (SX),HL
	LD A,_a;=1
	CALL NWRDM
	ENDM
