;-----ЧВ Работа со спрайтами ---
step_B	EQU	0 ;нач шаг курс
oumDEL	EQU	3 ;задержка на вывод карты
ouFAST	EQU	5 ;ускорение вывода экрана

;---выв.спрайтов карты----
SQROUT	;hl-adr spr ;DE-scr adr
        if EGA
        call setpgsscr40008000
        endif
	LD B,D
	LD C,E
	LD E,(HL)
	INC L
	LD D,(HL)
	INC L
        
        if EGA

	LD (SQUsp),SP
	LD SP,HL
	LD L,C
	LD H,B
        
        ld hx,16/4
        jp prtile16columngo
prtile16column
	POP DE
prtile16columngo
        ld bc,40
        
	LD (HL),E ;0
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;1
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;2
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;3
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;+0
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;+1
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;+2
	add hl,bc
	LD (HL),D
	add hl,bc
	POP DE
	LD (HL),E ;+3
	add hl,bc
	LD (HL),D
        
        ld bc,0x4000-(15*40)
        ld a,0x9f;0xa0
        cp h
        adc hl,bc ;de = 0x4000 - ((sprhgt-1)*40)
        jp pe,prtile16column ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
         dec hx
         jp nz,prtile16column

SQUsp=$+1
        ld sp,0
        jp setpgsmain40008000
        
        else ;~EGA

	LD (SET_SP+1),SP
	LD SP,HL
	LD L,C
	LD H,B
        
	LD B,2
SQU1	LD (HL),E ;0
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;1
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;2
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;3
	INC H
	LD (HL),D
	POP DE
	LD A,L
	ADD A,32
	LD L,A
	LD A,H
	SUB 7
	LD H,A
	LD (HL),E ;+0
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;+1
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;+2
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E ;+3
	INC H
	LD (HL),D
	POP DE
	LD A,H
	SUB 7
	LD H,A
	LD A,L
	SUB 31
	LD L,A
	DJNZ SQU1
        
	JP SET_SP
        
        endif ;~EGA

P12X12	LD HL,(X0)
	CALL GMAP
        if EGA
        ;call setpgsscr40008000
	LD DE,scrbase
        ;jr $
        else
	LD DE,DSCR
        endif
	LD C,12
PX0	LD B,12
PX1	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
	CALL GSADR
	CALL NC,SQROUT
	POP DE
	POP HL
	POP BC
        if EGA
	INC E
	INC E
        else
	INC E
	INC E
        endif
	INC HL
	DJNZ PX1
        if EGA
        push hl
        ld hl,-24+(40*16)
        add hl,de
        ex de,hl
        pop hl
        else
	LD A,E
	ADD A,40
	LD E,A
	JR NC,PX2
	LD A,D
	ADD A,8
	LD D,A
PX2	
        endif
        LD A,L
	ADD A,52
	JR NC,PX3
	INC H
PX3	LD L,A
	DEC C
	JR NZ,PX0
        if EGA
        ;call setpgsmain40008000
        endif
	RET


N12X12	;покрытие невидимых полей
	LD HL,(X0)
	CALL GMAP
        if EGA
        ;call setpgsscr40008000
        ;jr $
	LD DE,scrbase
        else
	LD DE,DSCR
        endif
	LD C,12
NPX0	LD B,12
NPX1	LD A,(HL)
	RLA
	JR NC,NPXN
	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
        if EGA
        ld a,28
        call _128
        ld hl,128*(383-256)+0xc000 ;тайл 383
        else
	LD HL,shadwA
        endif
	CALL SQROUT
	POP DE
	POP HL
	POP BC
NPXN	
        if EGA
	INC E
	INC E
        else
	INC E
	INC E
        endif
	INC HL
	DJNZ NPX1
        if EGA
        push hl
        ld hl,-24+(40*16)
        add hl,de
        ex de,hl
        pop hl
        else
	LD A,E
	ADD A,40
	LD E,A
	JR NC,NPX2
	LD A,D
	ADD A,8
	LD D,A
NPX2	
        endif
        LD A,L
	ADD A,52
	JR NC,NPX3
	INC H
NPX3	LD L,A
	DEC C
	JR NZ,NPX0
        if EGA
        ;call setpgsmain40008000
        endif
	RET

;вывод строчки при скролле
PXLO	LD HL,(X0)
	LD DE,DSCR+#10C0
	LD A,11
	ADD A,H
	LD H,A
	JR Px_
PXHI	LD HL,(X0)
	LD DE,DSCR
Px_	CALL GMAP
	LD B,12
PxH1	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
	CALL GSADR
       if EGA==0 ;TODO
	CALL NC,SQROUT
       endif
	POP DE
	POP HL
	POP BC
	INC E
	INC E
	INC L
	DJNZ PxH1
	RET

NXLO	LD HL,(X0)
	LD DE,DSCR+#10C0
	LD A,11
	ADD A,H
	LD H,A
	JR Nx_
NXHI	LD HL,(X0)
	LD DE,DSCR
Nx_	CALL GMAP
	LD B,12
NxH1	LD A,(HL)
	RLA
	JR NC,NxHN
	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
	LD HL,shadwA
       if EGA==0 ;TODO
	CALL SQROUT
       endif
	POP DE
	POP HL
	POP BC
NxHN	INC E
	INC E
	INC L
	DJNZ NxH1
	RET

PYRT	LD HL,(X0)
	LD DE,DSCR+22
	LD A,L
	ADD A,11
	LD L,A
	JR Py_
PYLF	LD HL,(X0)
	LD DE,DSCR
Py_	CALL GMAP
	LD B,12
Py1	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
	CALL GSADR
       if EGA==0 ;TODO
	CALL NC,SQROUT
       endif
	POP DE
	POP HL
	POP BC
	LD A,E
	ADD A,64
	LD E,A
	JR NC,Py2
	LD A,D
	ADD A,8
	LD D,A
Py2	LD A,L
	ADD A,64
	JR NC,Py3
	INC H
Py3	LD L,A
	DJNZ Py1
	RET

NYRT	LD HL,(X0)
	LD DE,DSCR+22
	LD A,L
	ADD A,11
	LD L,A
	JR Ny_
NYLF	LD HL,(X0)
	LD DE,DSCR
Ny_	CALL GMAP
	LD B,12
Ny1	LD A,(HL)
	RLA
	JR NC,NyN
	PUSH BC
	PUSH HL ;adr in map
	PUSH DE ;adr in scr
	LD HL,shadwA
       if EGA==0 ;TODO
	CALL SQROUT
       endif
	POP DE
	POP HL
	POP BC
NyN	LD A,E
	ADD A,64
	LD E,A
	JR NC,Ny2
	LD A,D
	ADD A,8
	LD D,A
Ny2	LD A,L
	ADD A,64
	JR NC,Ny3
	INC H
Ny3	LD L,A
	DJNZ Ny1
	RET

;------------------

GMAP	; вхHL-XY, выхHL-pos in map
	LD A,L
	RLCA
	RLCA
	SRL H
	RRA
	SRL H
	RRA
	LD L,A
	LD A,H
	ADD A,MAP/256
	LD H,A
	RET

GMAP2	; вхHL-XY, выхHL-pos in map2
	LD A,L
	RLCA
	RLCA
	SRL H
	RRA
	SRL H
	RRA
	LD L,A
	LD A,H
	ADD A,MAP2/256
	LD H,A
	RET

shadwS	;выбор адр невидим поля
	LD A,(shadwT)
	PUSH AF
	CALL MEM1
	POP AF
	OR A
	LD DE,shadwA
	JR Z,sha0
	LD HL,SHADOW
	LD BC,32
	LDIR
	RET
sha0	LD A,#FF
	LD B,32
sha1	LD (DE),A
	INC DE
	DJNZ sha1
	RET

GSADR	;вхHL-pos in map;  выхHL-adr in LAND ;NC/C-видим,не видим
        if EGA
	LD A,(HL)
	SLA A
	RET C
;тайл=128 байт, всего 384 тайла (3 страницы)
         ;jr $
	CP 226
	JR NC,GSA2
GSA0
;pg26,27
        rrca
	LD h,a
        ld l,0
        rla
        ld a,l;0
        adc a,26 ;NC
        scf
        rr h
        rr l ;NC
        set 6,h
        jp _128
GSA2	CP 240
	JR NC,GSA3
	EX AF,AF'	;вода
	LD A,(ANIM)
	OR A
	JR Z,GSA2A
GSA2C	DEC A
	JR Z,GSA2B
	EX AF,AF'
	ADD A,10
	EX AF,AF'
	JR GSA2C
GSA2B	EX AF,AF'
	JR GSA0        
GSA2A	EX AF,AF'
	SUB 226-112
	JR GSA0
GSAT	DEFW 1,65,64,63,-1,-65,-64,-63 ;смещение на карте до центра здания
GSA3
	RRCA ;120..127 - кайма зданий
	SUB 120
;a=0..7
	PUSH DE
	PUSH AF ;0..7 номер места около домика
	PUSH HL 	;здания
	LD HL,GSAT
	CALL WT ;a=(hl+a)
	POP DE
	ADD HL,DE
	LD A,(HL) ;нашли на карте центр здания = 78..127
	AND #7F
	CP 108
	JR NC,GSA3A ;>=108: домик 2x2
;домик 3x3
	SUB 78
	ADD A,A
	ADD A,A
	ADD A,A
	POP DE
	ADD A,D ;0..7 номер места около домика
	JR GSA11
GSA3A
;>=108: домик 2x2
	SUB 108
	LD E,A
	ADD A,A
	ADD A,E
	POP DE
	ADD A,D ;0..7 номер места около домика
        add a,368-128
GSA11	
;pg27,28
        POP DE
	LD h,a
        ld l,0
        rla
        ld a,l;0
        adc a,27 ;NC
        scf
        rr h
        rr l ;NC
        set 6,h
        jp _128
        
        else ;~EGA

	LD A,(HL)
	SLA A
	RET C
	CP 226
	JR NC,GSA2
GSA0	LD L,A
	LD H,LAND/4096
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	RET
GSA2	CP 240
	JR NC,GSA3
	EX AF,AF	;вода
	LD A,(ANIM)
	OR A
	JR Z,GSA2A
GSA2C	DEC A
	JR Z,GSA2B
	EX AF,AF
	ADD A,10
	EX AF,AF
	JR GSA2C
GSA2B	EX AF,AF
	JR GSA0
GSA2A	EX AF,AF
	SUB 226-112
	JR GSA0
GSAT	DEFW 1,65,64,63,-1,-65,-64,-63
GSA3	RRCA
	SUB 120
	PUSH DE
	PUSH AF
	PUSH HL 	;здания
	LD HL,GSAT
	CALL WT
	POP DE
	ADD HL,DE
	LD A,(HL)
	AND #7F
	CP 108
	JR NC,GSA3A
	SUB 78
	ADD A,A
	ADD A,A
	ADD A,A
	POP DE
	ADD A,D
	LD DE,128*32+LAND
	JR GSA11
GSA3A	SUB 108
	LD E,A
	ADD A,A
	ADD A,E
	POP DE
	ADD A,D
	LD DE,368*32+LAND
GSA11	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,DE
	POP DE
	RET
        endif ;~EGA

ScorrP	LD A,L
	ADD A,32
	LD L,A
	JR C,Sco1
	LD A,H
	SUB 8
	LD H,A
Sco1	LD A,E
	ADD A,32
	LD E,A
	RET C
	LD A,D
	SUB 8
	LD D,A
	RET

ScorrM	LD A,L
	SUB 32
	LD L,A
	JR C,Sco3
	LD A,H
	ADD A,8
	LD H,A
Sco3	LD A,E
	SUB 32
	LD E,A
	RET C
	LD A,D
	ADD A,8
	LD D,A
	RET

;---------------

SdUR	CALL ScU1
	JP Z,ScRT
	CALL ScR1
	JP Z,ScUP1
	CALL SW_OFF
       if EGA
        call O12X12
       else
	;--CALL ScU2+ScR2
	 CALL PXLO
	 CALL PYLF
	 CALL SXLO
	 CALL SYLF
	 CALL NXLO
	 CALL NYLF
	CALL MEM7
	CALL ScUR_
       endif
	JP ScNZ

SdDL	CALL ScD1
	JP Z,ScLF
	CALL ScL1
	JR Z,ScDW1
	CALL SW_OFF
       if EGA
        call O12X12
       else
	;--CALL ScD2+ScL2
	 CALL PXHI
	 CALL PYRT
	 CALL SXHI
	 CALL SYRT
	 CALL NXHI
	 CALL NYRT
	CALL MEM7
	CALL ScDL_
       endif
	JP ScNZ


SdUL	CALL ScU1
	JP Z,ScLF
	CALL ScL1
	JR Z,ScUP1
	CALL SW_OFF
       if EGA
        call O12X12
       else
	;--CALL ScU2+ScL2
	 CALL PXLO
	 CALL PYRT
	 CALL SXLO
	 CALL SYRT
	 CALL NXLO
	 CALL NYRT
	CALL MEM7
	CALL ScUL_
       endif
	JR ScNZ


SdDR	CALL ScD1
	JP Z,ScRT
	CALL ScR1
	JR Z,ScDW1
	CALL SW_OFF
       if EGA
        call O12X12
       else
	;--CALL ScD2+ScR2
	 CALL PXHI
	 CALL PYLF
	 CALL SXHI
	 CALL SYLF
	 CALL NXHI
	 CALL NYLF
	CALL MEM7
	CALL ScDR_
       endif
	JR ScNZ

ScDW	CALL ScD1
	JP Z,noROT
ScDW1	CALL SW_OFF
       if EGA
        call O12X12
       else
	CALL ScD2
	CALL MEM7
	JP ScD_
ScD2	CALL PXHI
	CALL SXHI
	CALL NXHI
       endif
	JR ScNZ
ScD1	LD HL,Y0
	LD A,(HL)
	OR A
	RET Z
	DEC (HL)
	OR A
	RET

ScUP	CALL ScU1
	JP Z,noROT
ScUP1	CALL SW_OFF
       if EGA
        call O12X12
       else
	CALL ScU2
	CALL MEM7
	JP ScU_
ScU2	CALL PXLO
	CALL SXLO
	CALL NXLO
       endif
ScNZ	CALL BMOV
	LD HL,isROT
	LD (HL),1
	RET
ScU1	LD HL,Y0
	LD A,(HL)
	CP 52
	RET Z
	INC (HL)
	RET

ScLF	CALL ScL1
	JP Z,noROT
	CALL SW_OFF
       if EGA
        call O12X12
       else
	CALL ScL2
	CALL MEM7
	JP ScL_
ScL2	CALL PYRT
	CALL SYRT
	CALL NYRT
       endif
	JR ScNZ
ScL1	LD HL,X0
	LD A,(HL)
	CP 52
	RET Z
	INC (HL)
	RET

ScRT	CALL ScR1
	JP Z,noROT
	CALL SW_OFF
       if EGA
        call O12X12
       else
	CALL ScR2
	CALL MEM7
	JP ScR_
ScR2	CALL PYLF
	CALL SYLF
	CALL NYLF
       endif
	JR ScNZ
ScR1	LD HL,X0
	LD A,(HL)
	OR A
	RET Z
	DEC (HL)
	OR A
	RET

        if EGA==0

ScD_	CALL B_SETI
	LD HL,SCR+#17A0
	LD DE,SCR+#17E0
	LD BC,#1602
ScD0	PUSH BC
	CALL B_NXTI
	LD A,8
ScD10	PUSH HL
	PUSH DE
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	POP DE
	POP HL
	DEC H
	DEC D
	DEC A
	JP NZ,ScD10
	CALL ScorrM
	CALL BL_ONN
	POP BC
	DJNZ ScD0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60 ;!
	LD H,A
	LD B,2
	JR ScD0

ScDR_	CALL B_SETI
	LD HL,SCR+#17A0+21
	LD DE,SCR+#17E0+23
	LD BC,#1602
ScDR0	PUSH BC
	CALL B_NXTI
	LD A,8
ScDR1	EX AF,AF
	PUSH HL
	PUSH DE
	LD BC,22
	LDDR
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDD
	LDD
	POP DE
	POP HL
	DEC H
	DEC D
	EX AF,AF
	DEC A
	JP NZ,ScDR1
	CALL ScorrM
	CALL BL_ONN
	POP BC
	DJNZ ScDR0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60
	LD H,A
	LD B,2
	JR ScDR0

ScDL_	CALL B_SETI
	LD HL,SCR+#17A0+2
	LD DE,SCR+#17E0
	LD BC,#1602
ScDL0	PUSH BC
	CALL B_NXTI
	LD A,8
ScDL1	EX AF,AF
	PUSH HL
	PUSH DE
	LD BC,22
	LDIR
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDI
	LDI
	POP DE
	POP HL
	DEC H
	DEC D
	EX AF,AF
	DEC A
	JP NZ,ScDL1
	CALL ScorrM
	CALL BL_ONN
	POP BC
	DJNZ ScDL0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60
	LD H,A
	LD B,2
	JR ScDL0

ScU_	CALL B_SETN
	LD HL,SCR+#0040
	LD DE,SCR
	LD BC,#1602
ScU0	PUSH BC
	CALL B_NXTN
	LD A,8
ScU10	PUSH HL
	PUSH DE
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	POP DE
	POP HL
	INC H
	INC D
	DEC A
	JP NZ,ScU10
	CALL ScorrP
	CALL BL_ONN
	POP BC
	DJNZ ScU0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LD B,2
	JR ScU0

ScUR_	CALL B_SETN
	LD HL,SCR+#0040+21
	LD DE,SCR+23
	LD BC,#1602
ScUR0	PUSH BC
	CALL B_NXTN
	LD A,8
ScUR1	EX AF,AF
	PUSH HL
	PUSH DE
	LD BC,22
	LDDR
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDD
	LDD
	POP DE
	POP HL
	INC H
	INC D
	EX AF,AF
	DEC A
	JP NZ,ScUR1
	CALL ScorrP
	CALL BL_ONN
	POP BC
	DJNZ ScUR0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LD B,2
	JR ScUR0

ScUL_	CALL B_SETN
	LD HL,SCR+#0040+2
	LD DE,SCR
	LD BC,#1602
ScUL0	PUSH BC
	CALL B_NXTN
	LD A,8
ScUL1	EX AF,AF
	PUSH HL
	PUSH DE
	LD BC,22
	LDIR
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDI
	LDI
	POP DE
	POP HL
	INC H
	INC D
	EX AF,AF
	DEC A
	JP NZ,ScUL1
	CALL ScorrP
	CALL BL_ONN
	POP BC
	DJNZ ScUL0
	DEC C
	JP Z,B_U2B
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LD B,2
	JR ScUL0


ScL_	CALL B_SET0
	LD HL,SCR+2
	LD DE,SCR
	LD B,24
ScL00	PUSH BC
	CALL B_NXT0
	LD A,8
ScL0	EX AF,AF
	PUSH HL
	PUSH DE
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDI
	LDI
	POP DE
	POP HL
	INC H
	INC D
	EX AF,AF
	DEC A
	JR NZ,ScL0
	CALL ScorrP
	CALL BL_ONN
	POP BC
	DJNZ ScL00
	JP B_U2B

ScR_	CALL B_SET0
	LD HL,SCR+21
	LD DE,SCR+23
	LD B,24
ScR00	PUSH BC
	CALL B_NXT0
	LD A,8
ScR0	EX AF,AF
	PUSH HL
	PUSH DE
	LDD;
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD;
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD
	LDD;
	LDD
	LDD
	LDD
	LDD
	LDD
	LD L,E
	LD A,D
	XOR #60;!
	LD H,A
	LDD
	LDD
	POP DE
	POP HL
	INC H
	INC D
	EX AF,AF
	DEC A
	JR NZ,ScR0
	CALL ScorrP
	CALL BL_ONN
	POP BC
	DJNZ ScR00
	JP B_U2B

        endif ;~EGA

ROTsub	DEFW ScLF,ScRT,000,ScUP,SdUL,SdUR,000,ScDW,SdDL,SdDR

;        if EGA
;ROTsub	DEFW O12X12,O12X12,000,O12X12,O12X12,O12X12,000,O12X12,O12X12,O12X12
;        endif

ROTATE	LD A,(BENTER)
	OR A
	JR Z,rotCOR
ROt1	LD A,(CONTRB)
	AND %1111
	JR ROt2
rotCOR	LD C,0
	LD HL,(MX)
	LD A,L
	OR A
	JR NZ,rC1
	SET 1,C
rC1	CP 248
	JR C,rC2
	SET 0,C
rC2	LD A,H
	OR A
	JR NZ,rC3
	SET 3,C
rC3	CP 184
	JR C,rC5
	SET 2,C
rC5	LD A,(PMOUSE)
	OR A
	LD A,C
	JR NZ,ROt2
	LD A,(CONTRB)
	AND C
ROt2	OR A
	JR Z,noRO1
	CP %1011
	JR NC,noRO1
	LD HL,ROTsub-2
	CALL WT
	LD A,L
	OR H
	JR Z,noRO1
	PUSH HL
	LD A,(isROT)
	OR A
	JR NZ,RO_ON
	INC A
	LD (isSWFF),A
	JR RO_1
RO_ON	HALT
RO_1	CALL MEM1
	POP HL
	JP (HL)
noRO1	LD A,(isROT)
	OR A
	RET Z
noROT	CALL MEM7
	CALL B_OFF
	LD A,(isSWFF)
	OR A
	JR NZ,noRO2
        if EGA==0
	CALL V_GET1
	CALL V_GET2
        endif
noRO2	XOR A
	LD (V_FLAG),A
	LD (isROT),A
	RET

SW_OFF	LD A,(isSWFF)
	OR A
	RET Z
	XOR A
	LD (isSWFF),A
	LD A,2
	LD (V_FLAG),A
	CALL MEM7
        if EGA==0
	CALL V_PUT1
	CALL V_PUT2
        endif
	JP MEM1

FRAME	;выв игр оформл
        if EGA
        ret
        else
	CALL MEM7
	CALL STS ;выбор основного экрана (не теневого)
	;bar-color
	ATRs #18,#208,#50
	ATRs #19,#106,#70
	ATRs #218,#208,#50
	ATRs #219,#104,#60
	LD L,#70
	LD H,L
	LD (ATR+93),HL
	ATRs #418,#508,#38
	ATRs #41D,#401,#58
	ATRs #41E,#401,#68
	;меню-батт
	ATRs #1418,#408,#68
	;land-color
	LD A,(COLOR)
	AND %00111000
	CP #28
	LD A,#68
	JR NZ,FRA_Ls
	LD A,#58
FRA_Ls	LD (COLRsc),A
FRA_L	LD A,(isCOLR)
	OR A
	JR Z,FRA2
	LD A,(MASTER)
	OR A
	LD A,#30
	JR Z,FRA1
	LD A,#28
FRA1	LD (MCOLOR),A
	LD A,(COLOR)
	JR FRA_L1
FRA2	LD A,#38
	LD (MCOLOR),A
	LD A,#30
FRA_L1	PUSH AF
	LD E,A
	LD HL,0
	LD BC,#118
	CALL STS ;выбор основного экрана (не теневого)
	CALL ATRBAR
	LD HL,#017
	LD BC,#1801
	CALL ATRBAR
	POP AF
	OR #40
	LD E,A
	LD HL,#100
	LD BC,#1717
	CALL ATRBAR
	LD A,(MCOLOR)
	LD E,A
	LD HL,#918
	LD BC,#B08
	CALL ATRBAR
	LD A,#20
	LD (ATR+632),A
	LD (ATR+639),A
	RET
        endif

typMAP	;определить тип карты (обычн/подземн -> LEV_T=0/1)
	LD HL,MAP
	LD A,(HL)
	OR A
	PUSH AF
	JR Z,iTM0
	;уровень - подземелье (без зданий, если [MAP+0]==1)
	XOR A
	LD (HL),A
	INC A	 ;A=1
	LD L,99 ;длина осмотра в подземельях
	LD E,2	;макс число трассировок
	LD C,12 ;число ударов по дверям
	JR iTMm
iTM0	XOR A	 ;A=0
	LD L,64  ;длина осмотра в обычн уровнях
	LD E,5
	LD C,60  ;число ударов по лесу
iTMm	LD (LEV_T),A
	LD A,L
	LD (MAXLEN),A
	LD A,E
	LD (MAXTRY),A
	LD A,C
	LD (BrWOOD),A
	POP AF
	RET

OUMAIN	;выв карты/поля
	LD A,(isMAP)
	OR A
	JR Z,OU_SCR

OU_MAP	;режим-карта
	LD HL,delMAP
	LD A,(HL)
	OR A
	JR Z,oum1
	DEC (HL)
	RET
oum1	LD (HL),oumDEL ;велич, задержки
	CALL MEM6
	CALL MP_OUT ;6
	CALL BLITER ;7
	LD HL,G_MAP1
	LD (G_IMG),HL
	RET

OU_SCR	;режим-экран
	 LD BC,#FDFE ;'F'-fast
	 IN A,(C)
	 AND %1000
	 JR NZ,OU_S1
	 LD HL,fram
	 INC (HL)
	 LD A,(HL)
	 CP ouFAST
	 RET C
	 LD (HL),0
OU_S1	CALL O12X12
	LD A,(begBOX)
	OR A
	RET NZ
OU_RT	CALL ROTATE
	LD A,(isROT)
	OR A
	JR NZ,OU_RT
	RET Z

O12X12	CALL MEM7
	CALL M_PLAT ;7
	CALL MEM1
	CALL P12X12 ;1
	CALL S12X12 ;m
	CALL N12X12 ;1
	CALL MEM4
	CALL outBOX ;4
	CALL MEM0
	CALL flpSEL ;0
	CALL HiENER ;0[**]
	CALL BLITER ;7
	LD HL,G_IMG1
	LD (G_IMG),HL
	RET


MAPon	XOR A
	LD (delMAP),A
	CALL MP_OFF ;очистка
	CALL BLITER
        if EGA==0
	LD A,(COLOR)
	XOR %01011001
	CALL FRA_L1
        endif
	CALL OU_MAP
	CALL MAPwin
	LD (isMAP),A
	RET

MAPoff	XOR A
	LD (isMAP),A
	CALL O12X12
        if EGA
        ret
        else
	JP FRA_L
        endif

MAPwin	;выв окна видимости
	CALL STS
	LD DE,(X0)
	LD A,E
	ADD A,E
	ADD A,E
	RRCA
	RRCA
	RRCA
	AND %11111
	LD L,A
	LD A,D
	ADD A,D
	ADD A,D
	RRCA
	RRCA
	RRCA
	AND %11111
	LD H,A
	CALL ACOORD
	LD DE,27
	LD C,5
mwi0	LD B,5
mwi1	LD A,(HL)
	XOR %00011001
	LD (HL),A
	INC L
	DJNZ mwi1
	ADD HL,DE
	DEC C
	JR NZ,mwi0
	RET

movWIN	;перемещ окна в карте по enter (BC-центр окна)
	LD A,C
	CALL iW
	LD L,A
	LD A,B
	CALL iW
	LD H,A
	LD (X0),HL
	RET
iW	SUB 5
	JR NC,iW1
	XOR A
iW1	CP 52
	RET C
	LD A,51
	RET

        if EGA==0
MP_OFF	CALL MP_OF1 ;очистка map в DSCR
	LD (DSCR),HL
	RET
MP_OF1	LD HL,#FFFF
	LD (SET_SP+1),SP
	LD SP,DSCR+#1800-6
	LD B,236
mp09	DEFS 13,#E5;PUSH HL
	DJNZ mp09
	JP SET_SP
        endif

MANUAL	;обработка управляющ воздейств
	CALL BMOV
	;H-вкл паузу
	LD BC,#BFFE
	IN A,(C)
	AND %10000
	JR NZ,maz0
	LD (onPAUS),A
	CPL
	JR mau0ht
maz0	;Z-вкл/выкл карту
	LD A,(BENTER)
	OR A
	JR NZ,mau4
	LD B,#FE
	IN A,(C)
	AND %111
	CP %101
	LD A,(Z_LOCK)
	JR NZ,mau2
	OR A
	JR NZ,mau1
mau0	LD A,(isMAP)
mau0ht	OR A
	PUSH AF
	CALL Z,MAPon
	POP AF
	CALL NZ,MAPoff
	LD A,1
	JR mau1
mau2	XOR A
mau1	LD (Z_LOCK),A
mau4	;нажатый FIRE (0-none,1-space,2-caps)
	LD A,(CONTRB)
	BIT 4,A
	JR NZ,maf1
	AND %100000
	JR NZ,maf2
	LD BC,#FEFE
	IN A,(C)
	AND %1111
	CP %1110
	JR Z,maf2
	XOR A
	JR maf0
maf1	LD A,1
	JR maf0
maf2	LD A,(BX)
	CP 24
	JR C,maf2_
	LD A,(begBOX)
	OR A
	JR Z,maf1;CAP->SPACE
maf2_	LD A,2
maf0	LD (T_FIRE),A ;(0-none,1-space,2-caps)
	CP 1
	RET Z
	XOR A
	LD (fixTAR),A ;расфиксировать цель
	RET


SEEonn	;подключить onsee/onsee2
	LD A,#C3 ;код jp
	JR SEExx
SEEoff	;отключть их
	LD A,#C9 ;код ret
SEExx	LD (ONSEE),A
	LD (ONSEE2),A
	RET

;-----------для работы с меню
gmMENU	CALL MEM7
	XOR A
	LD (isMAP),A
	CALL M_MENU
	CALL aSETUP
	JP MEM0

MU_BOX	;бох меню DE-coord,bc-размер
	PUSH HL
	DEC B
	DEC B
	LD H,B
	DEC C
	DEC C
	LD L,E
	LD A,99
	CALL PRINT
meb1	LD A,100
	CALL PRINT
	DJNZ meb1
	LD A,101
	CALL PRINT
meb2	LD B,H
	LD E,L
	INC D
	LD A,103
	CALL PRINT
meb4	LD A,10
	CALL PRINT
	DJNZ meb4
	LD A,104
	CALL PRINT
	DEC C
	JR NZ,meb2
	LD B,H
	LD E,L
	INC D
	LD A,105
	CALL PRINT
meb5	LD A,106
	CALL PRINT
	DJNZ meb5
	LD A,107
	CALL PRINT
	POP HL
	RET

_oSani	;анимация для Setup (A->DE)
_oSA1	EX AF,AF
	CALL MEM1
	EX AF,AF
	CALL GSADR+1
       if EGA==0 ;TODO
	CALL SQROUT
       endif
	JP MEM7

_shdw	;уст темноты
	CALL shadwS+3
	JP MEM7

aSETUP	;исполнение установок
	CALL TMOM   ;7
	CALL shadwS ;--1
	CALL ANIset ;1
	LD A,(MUSONF)
	OR A
	JR NZ,aSS1
	CALL MEM6   ;--6
	CALL WMUSIC ;6
	CALL MEM0
aSS1	JP MAPoff

UP_TIM	 ;повыш уровня врага (через TIME=0:40-N)
	 LD HL,kARC
	 LD B,4
upTT0	 LD A,(HL)
	 CP 2
	 JR NC,upTT1
	 INC (HL)
upTT1	 INC HL
	 DJNZ upTT0
	 ;
UP_DIF	 ;повыш сложность (DIFFIC=1)
	 LD HL,levMAX ;+1
	 INC (HL)
	 LD HL,lev1ST ;3/4
	 CALL uppd34
	 LD HL,levDEL ;3/4
uppd34	 SRL (HL)
	 LD A,(HL)
	 SRL (HL)
	 ADD A,(HL)
	 LD (HL),A
	 RET

PAUSE	;пауза с выводом задания по "H"
	LD HL,onPAUS
	LD A,(HL)
	OR A
	RET NZ
	INC (HL)
        if EGA
;выключить стрелочку 
;стереть стрелочку
	LD A,2
	LD (V_FLAG),A
	CALL V_PUT1
        endif
	LD DE,#301
	LD BC,#1612
	CALL MU_BOX
	;параметры
	LD DE,#503
	PUSH DE  ;N ур
	LD HL,TU_1
	CALL tuPR
	LD A,(MASTER)
	OR A
	LD HL,TU_7
	JR Z,tu2
	LD HL,TU_8
tu2	CALL PRINTS
	LD A,(LEVEL)
	CP 10
	JR C,tu3
	SUB 10
	PUSH AF
	LD A,1
	CALL PRINT
	POP AF
tu3	CALL PRINT
	POP DE
	INC D
	INC D
	PUSH DE  ;сложн
	LD HL,TU_2
	CALL tuPR
	LD A,(DIFFIC)
	OR A
	LD HL,TU_5
	JR Z,tu1
	LD HL,TU_6
tu1	CALL PRINTS
	POP DE
	INC D
	INC D
	CALL TUtime
	INC D
	INC D
	INC D
	PUSH DE
	LD E,8
	LD HL,TU_9
	CALL PRINTS
	POP DE
	INC D
	INC D
	DEC E
	;задание
	LD B,3
	LD HL,TASK_M
aus1	PUSH DE
	PUSH BC
	CALL PRINTS
	POP BC
	POP DE
	INC HL
	INC D
	DJNZ aus1
        if EGA
;прочитать стрелочку
;включить стрелочку
	CALL V_GET1
	xor a
	LD (V_FLAG),A
        else
	CALL BLITER ;иначе показывает другой экран
        endif
	CALL bWAIT
	JP TMOM

TUarr	DEFB 10,109,10,127 ;_>_
TU_1	DEFB 31,64,62,50,53,61,74,127 ;Уровень
TU_2	DEFB 29,59,62,54,61,62,65,66,74,127 ;Cложность
TU_3	DEFB 14,64,53,60,79,127 ;Время
TU_4	DEFB 26,49,73,53,53,127 ;Общее
TU_5	DEFB 81,26,82,24,127; NORM
TU_6	DEFB 25,84,110,25,127; HiGH
TU_7	DEFB 23,78,52,56,91,127;Люди-
TU_8	DEFB 22,67,61,51,56,91,127;Кунги-
TU_9	DEFB 19,48,52,48,61,56,53,43,127;Задание:

TUtime	;выв.времени ур-ня/игры
	PUSH DE ;вр ур
	LD HL,TU_3
	CALL tuPR
	LD HL,LEVRES
	CALL PRINTS
	POP DE
	INC D
	INC D
	PUSH DE ;общ вр
	LD HL,TU_4
	CALL tuPR
	LD HL,RESULT
	CALL PRINTS
	POP DE
	RET

tuPR	CALL PRINTS
	LD HL,TUarr
	JP PRINTS

Evic1	DEFB 27,26,13,17,16,12,47, 127 ;ПОБЕДА!
Evic2	DEFB 19,48,52,48,61,56,53, 10, 50,75,63,62,59,61,53,61,62,47, 127
Emis1	DEFB 14,75,10,63,62,66,53,64,63,53,59,56, 127
Emis2	DEFB 63,62,64,48,54,53,61,56,53,47, 127
Emis3	DEFB 27,62,63,75,66,48,57,66,53,65,74, 10, 53,73,80, 127 ;try again
Ey_n	DEFB 87,86,90,81,88,44, 127

bHmine	EQU  255 ;здоровье шахты
bHEALT	;здоровье зданий
	DEFB 200,160,132,130,150,140,160,250,80
	DEFB 0
	DEFB 200,160,132,130,150,140,160,250,80
OFFSEE	;выкл видим
	LD HL,MAP+65
	LD C,62
fE1	LD B,62
fE0	SET 7,(HL)
	INC HL
	DJNZ fE0
	INC HL
	INC HL
	DEC C
	JR NZ,fE1
	RET


ANIMTR	LD HL,ANIM
	INC (HL)
	LD A,(HL)
	CP 4
	RET C
	XOR A
	LD (HL),A
	RET

go_Max	EQU 52 ;номер макс прох поля

setMAP	LD HL,MAP2 ;заполнение мап2
	LD DE,MAP
	LD C,64
tE1	LD B,64
tE0	LD A,(DE)
	OR A
	JR Z,tE2
	CP go_Max
	LD A,0
	JR C,tE3
	INC A
tE2	INC A
tE3	LD (HL),A
	INC DE
	INC HL
	DJNZ tE0
	DEC C
	JR NZ,tE1
	RET



;------часто используемые п/п------
IX0_HL	LD (IX),L
	LD (IX+1),H
	RET

HL_IX0	LD L,(IX)
	LD H,(IX+1)
	RET

IXt_HL	LD (IX+10),L
	LD (IX+11),H
	RET

HL_IXt	LD L,(IX+10)
	LD H,(IX+11)
	RET

IX_98	XOR A ;стой
	LD (IX+9),A
	LD (IX+8),A
	RET

IX_92	LD (IX+9),2
	JR IX_93a
IX_93	LD (IX+9),3 ;иди
IX_93a	LD (IX+8),#80
	RET

IMPIX3	LD A,%11000000
	LD (IX+3),A
	JP HERMOV

loop_K	LD B,48
loopKb	LD IX,KUNGE
	LD DE,16
	RET

loop_H	LD B,48
loopHb	LD IX,HUMAN
	LD DE,16
	RET

DIST2	;расст по ф-ле: max(|L-ix0|,|H-ix1|) Вх.XY-HL;Вых.A
	LD A,L
	SUB (IX+0)
	JR NC,d2t1
	NEG
d2t1	LD B,A
	LD A,H
	SUB (IX+1)
	JR NC,d2t2
	NEG
d2t2	CP B
	RET NC
	LD A,B
	RET


;------------

isEND	LD A,(TheEND)
	OR A
	JP NZ,MU_EN_
	;
	LD A,(LEV_T)
	OR A
	CALL NZ,isEND2
	LD A,(TIC)
	AND %11111
	CP 5
	RET NZ
	CALL isEND1
	LD (END_1),A
	RET

MU_EN_ ;[--14]
        if 1==0
	PUSH AF
	LD HL,WX_LEN+82
	LD A,(WX_BAD+14)
	CP (HL)
	JR NZ,isEND1 ;err
	POP AF
        endif
	JP MU_END

isEND1	;проверка окончания боя (Z/NZ-ok/конец (A=1/2-победа наших/врагов)
	LD HL,KUNGE
	LD B,48+6
	LD DE,16
iee0	LD A,(HL)
	OR A
	JR NZ,iee2
	ADD HL,DE
	DJNZ iee0
	LD HL,KBUILD
	LD E,8
	LD B,#20
iee1	LD A,(HL)
	OR A
	JR NZ,iee2
	ADD HL,DE
	DJNZ iee1
	XOR A
	INC A
	RET NZ;1
iee2	LD HL,HUMAN
	LD E,16
	LD B,48
iee20	LD A,(HL)
	OR A
	JR NZ,iee3
	ADD HL,DE
	DJNZ iee20
	LD HL,HBUILD
	LD E,8
	LD B,#20
iee21	LD A,(HL)
	OR A
	JR NZ,iee3
	ADD HL,DE
	DJNZ iee21
	XOR A
	INC A
	INC A
	RET NZ;2
iee3	XOR A
	RET Z;0

isEND2	CALL loop_H ;князь в туннеле
ien0	LD A,(IX+4)
	CP 22
	JR C,ien1
	CP 24
	JR NC,ien1
	CALL HL_IX0
	LD A,L
	OR A
	JR Z,ien1
	CALL GMAP
	LD A,(HL)
	AND #7F
	CP 5
	JR NZ,ien1
	LD A,1
	LD (END_2),A
ien1	ADD IX,DE
	DJNZ ien0
	RET


;****** главн цикл *****

CONTgm
;загрузка отл игры
        if 1==0
        CALL INI_D2
        endif
	CALL LOD1st
	SCF
	CALL LOADms ;C=1
	CALL shadwS ;--1
	CALL MEM6   ;--6
	CALL WMUSIC ;6
	EI
	JP ENTRY

LODrtr	;рестарт уровня
	LD HL,LEVEL
	DEC (HL)
	LD HL,hCLRI_ ;восст осн врем/закл
	LD DE,hCLRIC
	LD BC,12
	LDIR
LODnxt	;нов.уровень
	LD A,2
	LD (V_FLAG),A
        if 1==0
	CALL CHNGd2
        endif
	CALL MEM6
	CALL WMUSIC
	DI
	JR LODn1

LODnew	;новая игра
        if 1==0
	CALL INI_D2
        endif
	CALL LOD1st	;6 i/o
	;загрузка и иниц. данных ур-ня
LODn1	CALL LODlev
	LD HL,hCLRIC ;копия осн врем/закл
	LD DE,hCLRI_
	LD BC,12
	LDIR
	XOR A
         ;jr $
	CALL LOADms	;i/o;C=0
_start	CALL shadwS	;--1
	CALL ANIset	;1
	CALL MEM0	;--0
	CALL typMAP	;0
	CALL Z,iniBLT	;0
	CALL setBLT	;0
     CALL OFFSEE     ;0
	CALL vieBLT	;0
	CALL MEM1	;--1
	CALL NEWALL	;1
	CALL NEWenm	;1
	CALL MEM0	;--0
	CALL pntINI	;0
	CALL pcINI	;0lev
	CALL MEM6	;--6
	CALL XY1st	;6
	CALL peonN	;6 \
	LD (peon_W),HL	;  /
	CALL WMUSIC	;6
	CALL bWAIT	;0
	XOR A
	LD (TIC_UP),A
	;
ENTRY	;общая точка входа для нов. игры и отгрузки
        if EGA
        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0
 	OS_SETSCREEN
        ld e,0
        OS_CLS
        ld e,1
 	OS_SETSCREEN
        ld e,0
        OS_CLS ;там была 6912 картинка
        call setpal
        endif
        
	XOR A
	LD (isMAP),A
	CALL putBAR ;--7
	CALL MEM0   ;--0
	CALL cBUini ;0
	CALL FRAME  ;--7
	CALL EVENTr ;*
	CALL OUMAIN ;7
NNN	;игровой цикл
	CALL MANUAL ;7
	CALL MEM6    ;---6
	CALL TIMER  ;6
	CALL SLOWER ;6
	CALL RNDcrr ;6
	CALL cTIC   ;6
	CALL dMAGIC ;6
	CALL SPLIN  ;6
	CALL REpeon ;6
	LD SP,STACK;#403E ;???
	CALL MEM1   ;---1
	CALL REMONT ;1
	CALL MEM0   ;---0
	CALL isRUN  ;0
	CALL ANIMTR ;0
	CALL selTAR ;0
	CALL ACTION ;0
	CALL SHED_H ;0
	CALL SEEoff ;0
	CALL SHED_K ;0
	CALL SHED_p ;0
	CALL BULLER ;0
	CALL hSCAN  ;0
	CALL kSCAN  ;0
	CALL SEEonn ;0
	CALL MINER  ;0
	CALL HOMER  ;0
	CALL pntACT ;0
	CALL COMPUT ;0
	CALL pcLOOP ;0lev
	CALL MEM7   ;--7
;	     LD BC,#FBFE ;чит - след уровень
;	     IN A,(C)
;	     AND %10000
;	     JR NZ,noHACK
;	     LD A,1
;	     LD (TheEND),A
noHACK	       ;
	CALL isEND  ;7
        if 1==0 ;???
	CALL _TST#6 ;7[**]
        endif
	CALL OUTBAR ;7
	CALL OUMAIN ;7
	CALL PAUSE  ;7
	CALL NNN ;!*

SYLF	CALL vrYLF
	CALL vXPUT
	JR SxS
SYRT	CALL vrYRT
	CALL vXPUT
	JR SxS
SXHI	CALL vrXUP
	CALL vXPUT
	JR SxS
SXLO	CALL vrXDW
	CALL vXPUT
	JR SxS
S12X12	CALL XY0pos
	CALL vSORT
	CALL vXPUT
SxS	CALL vBULL
	CALL vFLAME
	JP MEM1

;wMAIN	 ;ОТЛАД
;  CALL MEM0	 ;0 отлад
;  CALL SEEonn	 ;0 отлад
;  CALL setC1	 ;0 отлад
;  CALL setMAP	 ;0 отлад
  JP _start ;отладочн т.входа ;???
	;---demo
wMAIN  ;в этом порядке
	DI
;;;;;;;;*F W_CRC
	CALL MEM6
	LD A,(#EEC9) ;портится прерываниями ;патч к музыке
	PUSH AF
	LD A,(#F221) ;портится прерываниями ;патч к музыке
	PUSH AF
	CALL DEMO
	DI
	CALL MEM6
	POP AF
	LD (#F221),A ;восст
	POP AF
	LD (#EEC9),A ;восст
	;---start menu
	CALL LDI123;!!>>

bWAIT	CALL CONTR
	LD A,(CONTRB)
	AND %10000
	JR Z,bWAIT
	RET NZ

putBAR	;выв панели
	CALL OFFS
        if EGA
        ld a,24;29
        call _128
        call putBARdoscr
putBARdoscr
        call changescrpg_current
	LD DE,0xc000;DSCR
	LD HL,0x4000+0x0018
	LD BC,#1808
	JP PUTSYM
        else
	LD DE,DSCR
	LD HL,#0018
	LD BC,#1808
	JP PUTSYM
        endif

        if 1==0 ;???
_TST#6	LD A,(RNB) ;[**]mem7
	AND %11101111
	RET NZ
	LD DE,#C900
TST#6	XOR A
	LD HL,#4080
	LD BC,#3500
	JP tst60a
        endif

ONSEE1	CALL MEM0 ;newall и onsee - в разн. страницах
	CALL ONSEE
	JP MEM1

;-----------------------------


;низ +
;трупы +
;воины по очереди +
;пули,взрывы,закл +
;дым пожарищ+
;невидим квадраты  +
;курсор +

