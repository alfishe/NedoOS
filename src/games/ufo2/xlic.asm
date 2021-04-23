MENUC   ;выв меню с копир
	CALL MENU
	CALL MEM7
	JP COPYAT

SETPER	;установить ПЕРИОД
	LD C,4
	LD A,(DAT+13)
	CP 8
	JR NC,SPER
	LD A,(DAT+14)
	LD C,0
	CP 2
	JR C,SPER
	INC C ;1
	CP 3
	JR C,SPER
	INC C ;2
	CP 5
	JR C,SPER
	INC C ;3
	CP 8
	JR C,SPER
	INC C ;4
SPER	LD A,(RS+49)
	OR A
	JR NZ,SPE2
	LD C,5
	LD A,(RS+58)
	OR A
	JR NZ,SPE2
	INC C
SPE2	LD A,C
	LD (PERIOD),A
	RET

T50     DEFB 5
TIM50   LD HL,T50 ;Z-sec
	DEC (HL)
        RET NZ
TIM50_  LD (HL),50
        RET

TIMS    LD      HL,TIM+7 ;Счёт времени (NC-переход в начало)
        INC     (HL)
        LD      A,(HL)
        CP      10
        RET     C
        LD      (HL),0
	DEC     HL
	INC     (HL)
	LD      A,(HL)
        CP      6
        RET     C
        LD      (HL),0
        RET
TIMM    LD      HL,TIM+4
	INC     (HL)
	LD      A,(HL)
        CP      10
        RET     C
        LD      (HL),0
        DEC     HL
        INC     (HL)
        LD      A,(HL)
        CP      6
        RET     C
	LD      (HL),0
        RET
TIMH    LD      HL,TIM+1
        INC     (HL)
	LD      A,(HL)
        CP      4
        JR      NZ,T2
        DEC     HL
        LD      A,(HL)
	CP      2
        RET     C
	XOR     A
        LD      (HL),A
        INC     HL
        LD      (HL),A
        RET
T2      CP      10
        RET     C
	LD      (HL),0
        DEC     HL
        INC     (HL)
        SCF
        RET

DATE    LD HL,nDAT
        INC (HL)
        JR NZ,DM4
        INC HL
	INC (HL)
DM4     LD HL,MNT
        LD A,(DAT+14)
	CALL WA
        LD E,A
        INC HL
        LD D,(HL)
        LD HL,(DAT)
	PUSH HL
        OR A
        SBC HL,DE
        POP HL
        JR NZ,DM1
        LD HL,#100
DM2     LD (DAT),HL
        RET
DM1     INC H
        LD A,H
        CP 10
	JR C,DM2
        INC L
	LD H,255
        JR DM1

MONTH   LD HL,DAT+14
        INC (HL)
	LD A,(HL)
        CP 12
        JR C,DM3
        XOR A
	LD (HL),A
DM3     PUSH AF
        ADD A,A
        LD HL,MNAME
        CALL DD
        LD DE,DAT+2
	LD BC,8
        LDIR
	POP AF
        RET

YEAR    LD HL,DAT+13
        INC (HL)
	LD A,(HL)
	CP 10
        RET ;>2019-end


PD4     CALL PD2
PD2     CALL PDD
PDD     PUSH HL
        LD L,(HL)
        LD H,0
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
	LD BC,FONT+1
	ADD HL,BC
        LD B,6
        PUSH DE
PD0     LD A,(HL)
	LD (DE),A
	INC HL
	INC D
        DJNZ PD0
        POP DE
        POP HL
        INC E
        INC HL
        RET

PUTDAT   ;вывод времени
        LD DE,SCR+24
PDDS    LD HL,TIM
        CALL PD4
        CALL PD4
	LD E,32+27
        CALL PD2
        LD E,64+24
        CALL PD4
	CALL PD4
	LD E,96+26
        CALL PD4
	RET

;вывод карты
XEARTH  Ms 3+#80
        XOR A
        LD (T_M),A
        CALL STD
        CALL OFFD
        LD A,(C_ONOF)
        OR A
        LD HL,#6960
        JR Z,XE7
        LD HL,#6838
XE7     PUSH HL
        LD A,L
	LD BC,#1809 ;монитор
        LD HL,#F00
        CALL ATRBAR
	LD DE,xEARTH
        LD HL,0
	LD BC,#180F
        CALL PUTSIM
        POP AF;цвет карты
        CALL ATRBAR
        LD L,24
        LD BC,#804
        LD A,#68;цвет часов
        CALL ATRBAR
        LD H,4
        LD C,20
        LD A,#30;кнопки
        CALL ATRBAR
XEART2  LD DE,xLABEL+128
	LD C,5
XE0     LD B,2
        LD L,24
XE1     PUSH BC
        PUSH HL
	PUSH DE
        LD DE,xBUTTON
	LD BC,#404
        CALL PUTSIM
        POP DE
        LD BC,#202
        INC H
        INC L
        CALL PUTSIM
        LD HL,32
        ADD  HL,DE
        EX DE,HL
        POP HL
	LD L,28
        POP BC
	DJNZ XE1
        LD A,4
        ADD A,H
        LD H,A
        DEC C
	JR NZ,XE0
;;		CALL OUTPER
        JP MEM7

OUTPER	CALL STD ;выв периода войны []
	LD HL,#115
	LD (SX),HL
	LD A,(PERIOD)	
	JP WB

TARBUT  Ms 3
        LD DE,xLABEL+416;кнопки целей
        LD BC,#202
        LD HL,#1519
        CALL STD
        CALL PUTSIM
        LD DE,xLABEL+448
        LD L,#1D
	CALL PUTSIM
        LD HL,#519
        LD DE,xLABEL+480
        EXX
	LD B,4
        LD HL,T_UFO
TB0     LD C,2
TB1     LD A,(HL)
        INC HL
	EXX
        EX AF,AF
	CALL PUTSIM
        EX AF,AF
        XOR #FF
        CALL Z,SIMBAR
        LD A,32
        ADD A,E
        LD E,A
	JR NC,TB3
        INC D
TB3     LD L,#1D
        EXX
        DEC C
        JR NZ,TB1
	EXX
        LD A,4
        ADD A,H
        LD H,A
        LD L,#19
	EXX
        DJNZ TB0
	LD L,#38
TARBU2  CALL MEM7
        CALL STS
        LD A,L
        LD HL,#418
	LD BC,#814
        CALL ATRBAR
        LD HL,DSCR+25
        LD DE,SCR+25
        LD A,192
TB5     LDI
        LDI
        INC L
	INC L
        INC E
        INC E
        LDI
        LDI
	LD BC,26
        ADD HL,BC
	EX DE,HL
        ADD HL,BC
        EX DE,HL
	DEC A
        JR NZ,TB5
        RET

PMAP    INC L ;Перекрестье цели(HL)
        INC H
        LD B,8
Pmp     PUSH BC
        PUSH HL
        CALL STS
	CHNs XOR_
        LD D,H
        LD L,1
        LD E,190
        CALL LINE
	POP HL
        PUSH HL
	LD E,L
	LD H,1
	LD D,118
	CALL LINE
	CALL E_I
	CALL INT0
	POP HL
	POP BC
	DJNZ Pmp
	RET

T_M     DEFB    0 ;0/1-НЕТ/ЕСТЬ СТАТ
T_D     DEFB    0 ;0/1-НЕТ/ЕСТЬ ДИН
T_SW    DEFB    0
INT0    LD A,(T_SW) ;выв. объектов
	INC A
	LD (T_SW),A
	RRCA
	JR C,I0
	CALL PUTDAT
	LD A,(T_D)
	XOR 1
	LD (T_D),A
	JP SHOWD
I0      AND 3 ;flash
	RET NZ
	LD A,(T_M)
	XOR 1
        LD (T_M),A
        CALL SHOWT
SHOWS     ;вывод баз
        LD A,SCR/256
        CALL SELSCR
	CHNs XOR_
        LD DE,SPM+4
        LD BC,#103
        EXX
        LD B,8
	LD HL,XBASE
        LD DE,BASE
SWS0    LD A,(DE)
        INC DE
        CP 100
	EX AF,AF
        LD A,(HL)
        EX AF,AF
        INC HL
        LD A,(HL)
        INC HL
        JR NC,SWS2
        EXX
        LD H,A
        EX AF,AF
	LD L,A
        CALL PUTSPR
        EXX
SWS2    DJNZ SWS0
        RET

SHOWD    ;вывод истр. и НЛО
	LD A,SCR/256
        CALL SELSCR
        CHNs XOR_
	LD A,(T_INTR)
        LD DE,SPM
        LD BC,#103
        LD HL,(INTR)
        CP 255
        CALL NZ,PUTSPR
        LD DE,SPM+8
        LD A,(T_UFO)
        CP 255
        RET Z
	LD A,(UFOV)
        OR A
        LD HL,(UFO)
        CALL Z,PUTSPR
        RET

SHOWT    ;вывод целей
	LD A,SCR/256
        CALL SELSCR
        CHNs XOR_
	LD IY,SWST
        LD IX,T_SHP
        LD DE,SPM+12
        LD BC,#104
        EXX
        LD B,7
SWS1    EXX
        LD A,(IX)
        CP 255
        JR Z,SWS3
	LD L,(IY)
        LD H,(IY+1)
        CALL WT
        CALL PUTSPR
SWS3    INC DE
	INC DE
        INC DE
	INC DE
        INC IX
        INC IY
	INC IY
        EXX
        DJNZ SWS1
        RET
SWST    DEFW SHIP,PORT,ISLN,XBASE,UCOLON,UBASE,TLETH

NBUTT   LD HL,(MX);N КНОПКИ (0-9)
        LD A,L
        CP #E0
        LD B,0
	JR C,NUI
        INC B
NUI     LD A,H
        SUB 32
        RRCA
	RRCA
        RRCA
	RRCA
        AND #E
        ADD A,B
	RET

T_COOR  LD B,A
        LD HL,(UFO) ;A-n,HL-coord
        OR A
        RET Z
        LD HL,T_UFO
        CALL BA
        LD C,A
        LD A,B
	LD HL,SWST-2
        CALL WT
        LD A,C
        JP WT

SELTAR  LD A,(T_INTR)
        RLA
	JR NC,NQY
        LD A,27
NQ_NO   CALL DISPL
	JR NQR4
NQY     LD A,(AQU)
        OR A
        JR NZ,NQW
        LD A,41
        JR NQ_NO
NQW     LD HL,T_UFO
        LD B,8
NQQ     LD A,(HL)
        INC HL
	RLA
        JR NC,NQS
        DJNZ NQQ
        LD A,17
        CALL DISPL
	JR NQR4
NQS     CALL TARBUT
NQR0    CALL INT0
        CALL MARK_
        JR C,NQR0
NQR1    CALL INT0
        CALL MARK_
        JR NC,NQR1
        CALL NBUTT
        CP 8
        JR Z,NQI
        JR NC,NQR4
        LD B,A
        LD HL,T_UFO
        CALL BA
	CP 255
        JR Z,NQR1
        LD A,B
        CP 7
        JR NZ,NQR11
	LD A,(T_INTR)
        CP 2
	JR Z,NQR11
        LD A,31
        CALL DISPL
	JR NQR1
NQR11   LD A,B
        LD (T_TYPE),A
        CALL T_COOR
        LD (INTR_T),HL
        CALL PMAP
        LD A,(T_TYPE)
        ADD A,145
        LD (DSDAT),A
        LD A,21
	CALL DISPLX
NQR4    CALL INT0
        CALL MARK_
        JR C,NQR4
        Ms 3+#40
	LD HL,#418
        CALL XEART2
	LD L,#30
        CALL TARBU2
        JP T_SLOW
NQI     LD A,18
        CALL DISPLX
        LD B,145
        LD HL,T_UFO
NQI1    pushs
        LD A,(HL)
        CP 255
        JR Z,NQI2
        LD A,B
        LD (DSDAT),A
	CP 147
        LD A,19
        JR C,NQI3
        LD A,B
        CP 150
	LD A,19
        JR NC,NQI3
	LD A,B
        LD C,216
        CP 148
	JR Z,NQI4
        LD C,192
        JR NC,NQI4
        LD C,200
NQI4    LD A,(HL)
        ADD A,C
        LD (DSDAT+1),A
        LD A,20
NQI3    CALL DISPLX
        pops
	pushs
        LD A,B
        SUB 145
        CALL T_COOR
        CALL PMAP
NQI2    pops
        INC HL
	INC B
        LD A,B
        CP 153
	JR C,NQI1
	JP NQR1

       if PROTECT
CHK_2	LD A,#80 ;[] check CRC2
	CALL MEM
	LD HL,SCR
	PUSH HL
	LD BC,#2000
	ADD HL,BC
	POP DE
Crt1	LD A,(DE)
	CP (HL)
	JR Z,Crt1_
	DEC C
	ADD A,B
	ADD A,(HL)
	LD B,A
Crt1_	INC HL
	INC DE
	LD A,H
	OR L
	JR NZ,Crt1
	RET
       endif

I_RET   LD A,255
	LD (T_TYPE),A
        LD A,(T_INTR)
        RLA
        LD A,27
        JR C,I_RE2
        LD HL,(XBASE)
	LD DE,(INTR)
        PUSH HL
        SBC HL,DE
        POP HL
        LD A,42
	JP Z,I_RE2
        LD (INTR_T),HL
	LD A,3
I_RE2   CALL DISPL
	JR T_SLOW

GOhome	LD A,255
	LD (T_TYPE),A
	LD HL,(XBASE)
	LD (INTR_T),HL
	RET

STOP_T  XOR A
        INC A
        LD (ST_TIM),A
        RET

ST_TIM  DEFB 0 ;не 0 -вызов Т_SLOW
T_SLOW  LD HL,#400+50
        LD DE,LNXT
	JR FMS

T_MID   LD HL,#800+1
	LD DE,LNXT
	JR FMS

T_FAST  LD HL,#C00+1
	LD DE,LLF2
FMS     XOR A
	LD (ST_TIM),A
	LD (LLF1+1),DE
	LD A,L
	LD (TIM50_+1),A
	LD (T50),A
	LD L,28
	PUSH HL
	CALL STS
	ATRs #41C,#40C,#30
	POP HL
	LD C,4
	LD A,#68
	CALL ATRBAR
	JR LOOP

LOOPT   DEFW XMENUS,T_SLOW,I_RET,T_MID,SELTAR
	DEFW T_FAST,UPEDIA,OPTION,FINANS,INFO

XMR     CALL NOKEYw
MLOOP   LD SP,#403E
	CALL MEM7
	CALL XEARTH;*******Главный цикл
	LD DE,DSCR+24
	CALL PDDS
	CALL LODMON
	LD A,(SYSINI)
	OR A
	JR Z,M_LOOP
	CALL DISPL
	XOR A
	LD (SYSINI),A
M_LOOP  CALL INIBUT
	CALL RECRUT
	CALL CALC
	CALL RS254
	CALL SETPER
	XOR A
	LD (T_D),A
	CALL isTLEF
	JP T_SLOW
LOOP    CALL STDCFG
	CALL INT0
	CALL TIM50
	JR NZ,LNXT
	CALL TIMS
LLF1    JP C,LNXT
LLF2    CALL ACTM
	CALL TIMM
	JR C,LNXT
	CALL ACTH
	CALL TARh
	CALL TIMH
	JR C,LNXT
	CALL DATE
	PUSH AF
	CALL ACTD
	POP AF
	JR C,LNXT
	CALL Mn_FIN
	CALL MONTH
	JR C,LNXT
	CALL YEAR
	JR C,LNXT
        CALL SMERT
LNXT    LD BC,#FDFE
        IN A,(C)
        CPL
        AND %1110
        JR Z,ML2
        RRA
        PUSH AF
	CALL MARK_
        POP AF
        RRA
        JP C,T_SLOW
	RRA
        JP C,T_MID
	RRA
        JP C,T_FAST
ML2     LD A,(ST_TIM)
        OR A
        JP NZ,T_SLOW
        CALL MARK_
	JR NC,LOOP
	CALL NBUTT
        LD HL,LOOPT
        CALL WT
        JP (HL)

MU00    DEFW    #301,#001C,T+89
        DEFB    8
MU01    DEFW    #204,#117,T+1,12,RS
        DEFW    #903,#118,T+13,3,RS+12
        DEFW    #A04,#118,T+16,3,RS+15
        DEFW    #906,#118,T+19,3,RS+18
	DEFW    #203,#113,T+22,12,RS+21
        DEFW    #707,#115,T+34,9,RS+33
	DEFW    #504,#118,T+43,9,RS+42
        DEFW    #604,#118,T+52,9,RS+51


LODMON  CALL MEM7
        LD HL,MONINI
        LD A,(HL)
	OR A
        JR NZ,LDM1
        INC (HL)
        CALL    STD
        LD      HL,#F00 ;восст диспл
        LD      DE,ScrBU
        LD      BC,#1809
	CALL    PUTSIM
LDM1    CALL    COPYAT
        LD      A,255
        LD      BC,#1801
	LD      HL,#1700
        CALL      SIMBAR
	LD      HL,#FFFF
        LD      (MBEG),HL
        RET

SAVMON  CALL MRK2
        XOR A
        LD (MONINI),A
        CALL    STS
        LD      HL,#F00 ;сохр диспл
        LD      DE,ScrBU
        LD      BC,#1809
        JP      GETSIM

optN    DEFW op1,op2,op3,opOK
optD    DEFB 1,1,1,171
XMopt   LD HL,(KEYS)
        LD (_KEYS),HL
        LD HL,(KEYJOY)
	LD (_KEYJ),HL
XMooo   ;опции
	LD DE,optD
        LD A,(C_ONOF)
        ADD A,174
        LD (DE),A
        INC DE
        LD A,(KEYN)
        ADD A,176
        LD (DE),A
        INC DE
        LD A,(_KEYJ+1)
        ADD A,180
        LD (DE),A
        LD IX,MUopt
        CALL SELM
	JR NC,XORT
        LD HL,optN
        CALL WT
        LD (XMO+1),HL
XMO     CALL #38
        JR XMooo

op1     LD HL,C_ONOF
op31    LD A,(HL)
        XOR 1
        LD (HL),A
        RET
op3     LD HL,_KEYJ+1
        JR op31
op2     LD HL,KEYN
        LD A,(HL)
        DEC (HL)
        OR A
        JR NZ,op21
        LD (HL),3
	LD A,1
op22    LD (_KEYJ),A
        RET
op21    LD L,(HL)
	LD E,10
        CALL MULB
	LD HL,KBR
        ADD HL,DE
        LD (_KEYS),HL
        XOR A
        JR op22
opOK    POP DE
XORT    LD HL,(_KEYS)
        LD (KEYS),HL
        LD HL,(_KEYJ)
        LD (KEYJOY),HL
        RET

_KEYS   DEFW #202
_KEYJ   DEFW #202

MUopt   DEFW #C00,#471B,optD
        DEFB 4

STDCFG  LD BC,#FEFE ;станд СFG
        IN A,(C)
	AND %1100 ;C
        RET NZ
        XOR A
        LD (KEYJOY),A
        LD (PMOUSE),A
        LD (KEYN),A
        LD HL,KBR
        LD (KEYS),HL
        LD A,#48
        JP DISPLX

UPEDIA  CALL    SAVMON
	CALL	RESNUM
	LD	HL,(R_NUM-1)
	CP	H
	CALL	NZ,OFFNUM
        CALL    BACK
UP_XX   LD      IX,MU00
	CALL    SELM
        JR      NC,UP9
        LD      IX,MU01-10
        LD      DE,10
        INC     A
        LD      B,A
UP8     ADD     IX,DE
        DJNZ    UP8
        CALL    SELM
        JR      NC,UP_XX
        LD      L,(IX+4)
        LD      H,(IX+5)
        LD      DE,T
        OR      A
        SBC     HL,DE
        ADD     A,L
        DEC     A
        LD      (USN),A
        XOR     A
        LD      (UST),A
	CALL    UP
        CALL    MEM7
UP9     CALL    MARK_
        JR      C,UP9
        JP      MLOOP

;---------------------работа с маркером

OFLINE  LD HL,MTMP  ;выкл.пункт
        LD A,(HL)
        DEC HL
        LD D,(HL)
        LD (HL),A
        INC HL
        CP D
        RET Z
        INC D
        RET Z
        DEC D
        INC HL
ONOFL   INC HL
        LD E,(HL)
        INC HL
        LD B,(HL)
        CALL SCOORD
        LD C,8
	LD E,L
        LD D,B
ONOF1   LD A,(HL)
        CPL
        LD (HL),A
        INC L
        DJNZ ONOF1
        LD B,D
        LD L,E
        INC H
        DEC C
        JR NZ,ONOF1
        RET

ONLINE  LD DE,(MXSH)   ;вкл.пункт
        LD A,L
        SUB E
        JR C,NOLINE
        CP D
        JR NC,NOLINE
	LD DE,(MBEG)
        LD A,H
        CP E
        JR C,NOLINE
        CP D
        JR Z,ONL1
        JR C,ONL1
NOLINE  LD HL,MTMP
        LD (HL),255
        INC HL
        LD (HL),255
        RET
ONL1    LD HL,MOLD
        CP (HL)
	RET Z
        INC HL
        LD (HL),A
        LD D,A
        INC HL
        SUB E
	LD (HL),A
        XOR A
        LD (NEW_M),A
        JR ONOFL

;сохранить изображение под стрелкой
GETBUF  LD A,D  ;DE-YX
        CP 176
        JR C,M112
        LD D,176
M112    LD A,E
        CP 232
        JR C,M115
        LD E,232
M115    CALL PCOORD
        LD DE,MBU
        LD B,16
M110    PUSH BC
        PUSH HL
        LDI
	LDI
        LDI
        POP HL
        INC H
        LD A,H
        AND %111
        JR NZ,M114
        LD A,H
        SUB 8
        LD H,A
        LD A,L
        ADD A,32
        LD  L,A
        JR NC,M114
	LD A,8
        ADD A,H
        LD H,A
M114    POP BC
        DJNZ M110
        RET

;восстановить изображение под стрелкой
PUTBUF  LD A,D ;de-xy
        CP 176
        JR C,M192
        LD D,176
M192    LD A,E
        CP 232
        JR C,M195
        LD E,232
M195    CALL PCOORD
        LD DE,MBU
        EX DE,HL
        LD B,16
M190    PUSH BC
        PUSH DE
        LDI
        LDI
        LDI
        POP DE
	INC D
        LD A,D
        AND %111
        JR NZ,M194
        LD A,D
        SUB 8
        LD D,A
        LD A,E
        ADD A,32
        LD  E,A
        JR NC,M194
        LD A,8
        ADD A,D
        LD D,A
M194    POP BC
        DJNZ M190
        RET

;вывод стрелки в DSCR
ARROW   PUSH DE      ;de-xy
	LD A,176
        LD C,16
        SUB D
        JR NC,M17W
        ADD A,C
        LD C,A
M17W    CALL PCOORD
        POP DE
        LD A,E
        AND %110
        RRCA
        ADD A,MBU2/256
        LD D,A
        LD E,0
	LD A,L
        AND #1F
        SUB 30
        CPL
        JR NC,M179
        XOR A
M179    ADD A,3
        LD (ARW+1),A
ARW     LD B,3
        PUSH HL
        PUSH DE
ARW0    LD A,(DE)
        INC E
        OR (HL)
        LD (HL),A
        LD A,(DE)
        INC E
        XOR (HL)
        LD (HL),A
        INC L
	DJNZ ARW0
        POP DE
        POP HL
        LD A,E
        ADD A,6
        LD E,A
	INC H
        LD A,H
        AND %111
        JR NZ,M174
        LD A,H
        SUB 8
        LD H,A
        LD A,L
        ADD A,32
        LD  L,A
        JR NC,M174
        LD A,8
        ADD A,H
        LD H,A
M174    DEC C
        JR NZ,ARW
        RET

;инициализация при входе в меню
ARRINI  LD DE,MRK
	LD HL,MBU2
        CALL ARIS
        LD DE,MRK+32
        LD HL,MBU2+1
ARIS    LD C,0
ARIS0   LD B,16
        PUSH HL
        PUSH DE
A0IS0   PUSH BC
        CALL RRCB
        LD (HL),A
        INC L
        INC L
        LD (HL),B
	CALL RRCB
        OR (HL)
        LD (HL),A
        INC L
        INC L
        LD (HL),B
	INC L
        INC L
        POP BC
        DJNZ A0IS0
        POP DE
        POP HL
        INC H
        INC C
        LD A,C
        CP 4
        JR NZ,ARIS0
        RET
RRCB    LD A,C
        OR A
	LD A,(DE)
        LD B,C
        INC DE
        RET Z
        LD B,0
        EX AF,AF
	LD A,C
RRC1    EX AF,AF
        SRL A
        RR B
        SRL A
        RR B
        EX AF,AF
        DEC A
        JR NZ,RRC1
        EX AF,AF
        RET

;МЕНЮ: отображение стрелки и подсвеченного пункта в SCR
w_band  EQU 29
MRK1    CALL E_I
        LD A,(PMOUSE)
        OR A
        JR Z,MRK1N
        LD A,(MYOLD)
        CALL MRK1_
MRK1N   LD A,(MY)
        LD (MYOLD),A
MRK1_   AND #FE
        SUB 11
        JR NC,M11
        XOR A
        JR M10
M11     CP 192-w_band
        JR C,M10
        LD A,192-w_band
M10     LD D,A
        LD E,0
        CALL BCOORD
        PUSH HL
	LD BC,SCR-DSCR
        ADD HL,BC
        POP DE
        EX DE,HL
        LD B,w_band
M12     PUSHs
	LD BC,32
        LDIR
        POPs
        INC D
        INC H
        LD A,H
        AND %111
        JR NZ,M14
        LD A,H
        SUB 8
        LD H,A
        LD A,L
        ADD A,32
        LD  L,A
	LD  E,A
        JR NC,M15
        LD A,8
        ADD A,H
        LD H,A
M15     LD A,+(SCR-DSCR)/256
	ADD A,H
        LD D,A
M14     DJNZ M12
        RET

;КНОПКИ: отображение стрелки в SCR
wB_band EQU 20
MYOLD   DEFB 0
MRK2    CALL E_I
	CALL STD
        LD A,(PMOUSE)
        OR A
        JR Z,MRK2N
        LD A,(MYOLD)
        CALL MRK2_
MRK2N   LD A,(MY)
        LD (MYOLD),A
MRK2_   AND #FE
        SUB 2
        CP 191-wB_band
        JR C,M210
	LD A,191-wB_band
M210    LD D,A
        LD E,0
        CALL BCOORD
        PUSH HL
        LD BC,SCR-DSCR
        ADD HL,BC
        POP DE
        EX DE,HL
        LD B,wB_band
M212    PUSHs
        LD A,E
        ADD A,24
        LD E,A
	LD L,A
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        POPs
        INC D
        INC H
        LD A,H
        AND %111
        JR NZ,M214
        LD A,H
        SUB 8
        LD H,A
        LD A,L
        ADD A,32
        LD  L,A
        LD  E,A
        JR NC,M215
        LD A,8
        ADD A,H
        LD H,A
M215    LD A,+(SCR-DSCR)/256
        ADD A,H
        LD D,A
M214    DJNZ M212
        RET

;*************работа со стрелкой
NEW_M   DEFB 2 ;0 -смена пункта
MARK    XOR     A;C выводом трёх нижних строк
mark_0  CALL    mark_
        JR      C,mark_1
        LD A,(NEW_M)
        OR A
        JR NZ,mark_0
        CPL
        LD (NEW_M),A
mark_1  LD A,(MPOS)
        RET
MARK_   LD      A,1     ;Без вывода трёх нижних строк
mark_   LD      (MC21),A
        CALL    STD
        CALL    MMOV
	JR	C,MMV1 ;учёт прав кнопки мыши
	RR	C
MMV1	PUSH    AF
        LD      HL,(MX)
        RES     0,L
        RES     0,H
        PUSH    HL
        SRL     H
        SRL     H
        SRL     H
        SRL     L
        SRL     L
        SRL     L
        CALL    ONLINE
        CALL    OFLINE
        POP     DE
        PUSH    DE
        CALL    GETBUF
        POP     DE
        PUSH    DE
        CALL    ARROW
MRKN    CALL    MRK1
        POP     DE
        CALL    PUTBUF
        CALL    COPY21
        POP     AF
        RET;вых:C/NC-нажат или нет FIRE, A-номер пункта или 255 (вне меню)

INIMNU  LD DE,MRK1  ;инит для работы с меню
        LD HL,#101
IniMB   LD (MRKN+1),DE
        LD (MWINX),HL
        LD A,(MY)
        LD (MYOLD),A
        LD (NEW_M),A
        JP ARRINI
INIBUT  LD HL,#FFFF  ;инит для работы с картой
        LD (MOLD),HL
        LD (MBEG),HL
        LD HL,(MX)
        LD A,#22
        CP H
        JR C,IB1
        LD H,A
IB1     LD A,#C4
        CP L
        JR C,IB2
        LD L,A
IB2     LD (MX),HL
        LD DE,MRK2
        LD HL,#21C3
        JR IniMB

COPY21  LD      HL,MC21
        LD      A,(HL)
        OR      A
        RET     NZ
        INC     (HL)
        LD      HL,DSCR+#10A0
        LD      DE,SCR+#10A0
        LD      B,8
C210    PUSHs
        LD      BC,#60
        LDIR
        POPs
        INC H
        INC D
        DJNZ C210
        RET

;----------------- исследования
RS254   LD      B,0 ;новые иссл.
        LD      DE,RS
RS21    LD      A,(DE)
        CP      255
        JR      NZ,RS22
        LD      A,B
        PUSH    BC
        LD      BC,RSCH
        LD      L,A
        LD      H,0
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,BC
        POP     BC
        LD      A,(HL)
        OR      A
        JR      Z,RS25
        PUSH    HL
        LD      HL,S_GUN
        CALL    WA
        OR      A
        POP     HL
        JR      Z,RS22
        INC     HL
        LD      A,(HL)
        OR      A
        JR      Z,RS23
        DEC     HL
RS25    INC     HL
        LD      C,(HL)
        INC     HL
        LD      A,(HL)
        INC     HL
        LD      H,(HL)
        LD      L,A
RS24    PUSH    HL
        LD      A,(HL)
        LD      HL,RS
        CALL    BT
        POP     HL
        OR      A
        JR      NZ,RS22
        INC     HL
        DEC     C
        JR      NZ,RS24
RS23    EXX
        LD      BC,80*256
        LD      HL,RS
RSEX    LD A,(HL) ;не более 17 иссл
        INC HL
        CP 254
        JR NZ,RSE1
        INC C
RSE1    DJNZ RSEX
        LD A,C
        CP 17
        RET NC
        EXX
        LD      A,254
        LD      (DE),A
        LD      A,B
        INC     A
        LD      (DSDAT),A
        LD      A,51
        CALL    DISPLX
        CALL    STOP_T
        JR      RS254
RS22    INC     DE
        INC     B
        LD      A,B
        CP      80
        RET     NC
        JR      C,RS21

;ОЧЕРЁДНОСТЬ исследований
RSCH    DEFW 0,0
        DEFW 0,0
        DEFW    #302,_R2
        DEFW    #103,_R3
        DEFW 0,0
        DEFW    #105,_R5
        DEFW    #200,_R6
        DEFW    #300,_R7
        DEFW    #108,_R8
        DEFW    #109,_R9
        DEFW    #10A,_R10
        DEFW 0,0
        DEFW    #30C,_R12
        DEFW 0,0
        DEFW 0,0
        DEFW    #300,_R15
        DEFW    #300+33,_R16
        DEFW    #300,_R17
        DEFW 0,0
        DEFW    #300,_R19
        DEFW    #200,_R20
        DEFW    55,0
        DEFW    #100,_R22
        DEFW    57,0
        DEFW    #100+58,_R24
        DEFW    59,0
        DEFW    60,0
        DEFW    #100+61,_R27
        DEFW    63,0
        DEFW    #200,_R29
        DEFW    #100,_R30
        DEFW    #100,_R31
        DEFW    #100,_R32
        DEFW    19,0
        DEFW    20,0
        DEFW    21,0
        DEFW    22,0
        DEFW    23,0
        DEFW    24,0
        DEFW    #400,_R39
        DEFW    #400,_R40
        DEFW    #300,_R41
        DEFW    #300+33,_R42
        DEFW    #100+25,_R43
        DEFW    26,0
        DEFW    27,0
        DEFW    28,0
        DEFW    29,0
        DEFW    30,0
        DEFW    #300+31,_R49
        DEFW    32,0
        DEFW    #100,_R51
        DEFW    #200,_R52
        DEFW    #200,_R53
        DEFW    #100,_R54
        DEFW    #100,_R55
        DEFW    #300,_R56
        DEFW    #100,_R57
        DEFW    #300+62,_R58
        DEFW 0,0
        DEFW    #200+35,_R60;
        DEFW    #100+36,_R61
        DEFW    #100+37,_R62
        DEFW    #100+38,_R63
        DEFW    #100+39,_R64;
        DEFW    #100+40,_R65
        DEFW    #100+41,_R66
        DEFW    #100+42,_R67
        DEFW    #100+43,_R68;
        DEFW    #100+44,_R69
	DEFW    #100+45,_R70
        DEFW    #100+46,_R71
        DEFW    #100+47,_R72;
        DEFW    #100+48,_R73
        DEFW    #100+49,_R74
        DEFW    #100+50,_R75
        DEFW    #100+51,_R76
        DEFW    #200+52,_R77
        DEFW    #100+53,_R78
        DEFW    #200+54,_R79

_R2     DEFB    3,9,16
_R3     DEFB    10
_R5     DEFB    8
_R6     DEFB    9,5
_R7     DEFB    6,10,19
_R8     DEFB    50
_R9     DEFB    8
_R10    DEFB    8
_R12    DEFB    2,48,79
_R15    DEFB    11,13,14
_R16    DEFB    15,23,63
_R17    DEFB    16,20,69
_R19    DEFB    43,44,50
_R20    DEFB    19,42
_R22    DEFB    60
_R24    DEFB    47
_R27    DEFB    78
_R29    DEFB    50,64
_R30    DEFB    67
_R31    DEFB    77
_R32    DEFB    62
_R39    DEFB    61,33,35,37
_R40    DEFB    74,34,36,38
_R41    DEFB    76,39,40
_R42    DEFB    41,43,44
_R43    DEFB    50
_R49    DEFB    52,53,55
_R51    DEFB    75
_R52    DEFB    69,51
_R53    DEFB    66,54
_R54    DEFB    68
_R55    DEFB    73
_R56    DEFB    70,45,46
_R57    DEFB    65
_R58    DEFB    71,56,49
_R60	DEFB	62,63
_R61    DEFB    21
_R62    DEFB    61
_R63    DEFB    61
_R64
_R65    DEFB    22
_R66    DEFB    64
_R67    DEFB    65
_R68
_R69    DEFB    23
_R70
_R71    DEFB    69
_R72
_R74    DEFB    24
_R73
_R75    DEFB    72
_R76
_R78    DEFB    25
_R77
_R79    DEFB    76,78

RSDAY   LD      B,0     ;ведение иссл.
	LD      HL,RS
RY1     LD      A,(HL)
        OR      A
        JR      Z,RY2
	CP      254
        JR      NC,RY2
	LD      A,(RSN)
        ADD     A,4
        SRL     A
        SRL     A
        SRL     A
        LD      D,A
	LD      A,(HL)
        SUB     D
        JR      NC,RY3
        XOR     A
RY3     LD      (HL),A
        OR      A
        RET	NZ
        INC     B
	LD      A,B
        LD      (DSDAT),A
        LD      A,5
        CALL    DISPLX
	LD      A,(DSDAT)
        CP      19
	LD      A,6
        CALL    C,DISPL
        CALL    STOP_T
	LD	HL,R_NUM
	INC	(HL)
        JP	RS254
RY2     INC     HL
        INC     B
	LD      A,B
        CP      80
        JR      C,RY1
	RET 	NC
RY4	CALL	RESNUM
	LD	HL,R_NUM
	CP 	A
        RET

;----Program Data
;Дни в месяце
MNT     DEFB    3,1, 2,8, 3,1, 3,0, 3,1, 3,0, 3,1, 3,1, 3,0, 3,1, 3,0, 3,1
;Названия месяцев
MNAME   DEFB    15,47,30,18,16,33,47,15
        DEFB    37,21,18,33,16,28,47,15
        DEFB    15,29,16,33,35,16,15,15
	DEFB    15,16,32,33,21,28,47,15
        DEFB    15,15,29,16,47,15,15,15
	DEFB    15,15,25,46,30,47,15,15
	DEFB    15,15,25,46,28,47,15,15
        DEFB    16,18,19,36,34,35,16,15
        DEFB    34,21,30,35,47,17,33,47
        DEFB    31,27,35,47,17,33,47,15
        DEFB    15,30,31,47,17,33,47,15
	DEFB    20,21,27,16,17,33,47,15
;Курсор-стрелочка
MRK     DEFW    #C0,#E0,#F0,#F8,#FC,#FE,#FF,#80FF,#C0FF,#E0FF
        DEFW    #F0FF,#F0FF,#F8,#F0,#E0,#C0
        DEFW    #00,#40,#60,#50,#48,#44,#42,#0041,#8040,#4040
        DEFW    #E047,#0048,#50,#60,#40,#00
;Условные знаки
SPM     DEFB    #40,#E0,#40,0 ;истр
	DEFB    #E0,#A0,#E0,0 ;база
        DEFB    #A0,#40,#A0,0 ;НЛО
        DEFB    #50,#F8,#78,0
        DEFB    #E0,#E0,#E0,0
	DEFB    #C0,#C0,0,0
        DEFB    #04,#0C,#04,0
	DEFB    #60,#90,#90,#60
	DEFB    #60,#F0,#F0,#60
        DEFB    #F0,#90,#90,#F0

;Координаты: -баз
XBASE   DEFB    95,19, 123,54, 56,37, 81,64
	DEFB    22,87, 75,110, 135,105, 171,28
;-портов
PORT    DEFB    98,20, 102,32, 11,20, 28,40
	DEFB    169,96, 102,12, 161,18, 112,30
	DEFB    80,23, 92,86, 140,48, 45,95
	DEFB    24,74, 46,28, 166,53, 74,33
;-островов
ISLN    DEFB    183,101,111,78,51,25,2,35
	DEFB    161,45,69,68,79,77,84,34
	DEFB    165,37,90,36,12,96,2,86
	DEFB    187,45,129,102,136,58,68,40
;-колонии
UCOLON  DEFB    154,4,99,7,68,20,168,72
	DEFB    27,3,133,79,9,65,45,49
	DEFB    107,107,67,112,177,37,71,80
	DEFB    11,54,57,9,162,105,113,66
;-базы врагов
UBASE   DEFB    56,90,173,110,107,98,180,20
	DEFB    60,33,120,60,29,106,152,100
	DEFB    7,2,78,100,82,13,62,62
	DEFB    139,85,39,36,155,59,178,55
;-корабли
SHIP    DEFB    70,88,129,67,64,54,97,39
	DEFB    25,53,152,77,168,45,12,82
        DEFB    93,105,71,29,117,83,119,5
        DEFB    51,57,31,95,186,83,89,9
;-Тлеф
TLETH   DEFB    42,40

;------------------------------------------
SEA_T   DEFW    SEA0,SEA1,SEA2,SEA3,SEA4

SEABAT  ;бой под водой
        CALL SAVMON
SEB     CALL LODALX
	CALL ALEX
        PUSH AF
        CALL LDASM1
        POP AF
        JR NC,SEB
	PUSH AF
        ADD A,#3B
        LD (MUsea+3),A
        CALL BACK
        LD IX,MUsea
        CALL MENUC
        POP AF
	LD HL,SEA_T
	CALL WT
        JP (HL)

MUsea   DEFW #404,#FF16
SEA0    ;гибель ufo
SEA3    ;поломка intr (или эвак)
	CALL TMOF
SEA3_	LD A,255
	LD (TARlst),A
	LD (T_UFO),A
	JR SEA2_
SEA4    XOR A
	LD (AQU),A
	DEC A
	LD (T_INTR),A ;гибель intr
	LD B,10
	LD HL,AQNAVT
SEA4_	LD (HL),0
	LD DE,16
	ADD HL,DE
	DJNZ SEA4_

SEA2    CALL TMOF ;ничья
SEA2_	CALL OFFS
	CALL GOhome
	JP XMR

SEA1    CALL YES_NO
	JR NZ,SEA3_
        LD A,1
        LD (MONINI),A
        JP BATTL1

MU55    DEFW #201,#3717
        DEFW 0
        DEFW MNY1
	DEFW MNY2
	DEFW MNY3
	DEFW DOLG
	DEFW ITOGO
	DEFW MONEY

MNY1    EQU MXDM
MNY2    EQU MNY1+4
MNY3    EQU MNY1+8
ITOGO   EQU MNY1+12

FINANS  ;фин.отч
	LD HL,#BDBC
	CALL F_O
	CALL XMR

F_O     LD (MU55+4),HL
	CALL MARK_
	CALL SAVMON
	CALL BACK
	LD HL,MNY1
	LD DE,MNY1+1
	LD (HL),0
	LD BC,16
	LDIR
	LD HL,ITOGO
	PUSH HL
	LD A,(RSN)
	OR A
	JR Z,FA1
	LD IX,MNY1
	LD B,A
FA0     LD HL,(ZP)
	PUSH HL
	CALL INCR
	POP HL
	EX (SP),IX
	CALL INCR
	EX (SP),IX
	DJNZ FA0
FA1     LD A,(ENG)
	OR A
	JR Z,FA2
	LD IX,MNY2
	LD B,A
FA3     LD HL,(ZP+2)
	PUSH HL
	CALL INCR
	POP HL
	EX (SP),IX
	CALL INCR
	EX (SP),IX
	DJNZ FA3
FA2     LD A,(AQU)
	OR A
	JR Z,FA6
	LD IX,MNY3
	LD B,A
FA5     LD HL,(ZP+4)
	PUSH HL
	CALL INCR
	POP HL
	EX (SP),IX
	CALL INCR
	EX (SP),IX
	DJNZ FA5
FA6     POP AF
	LD HL,(ITOGO)
	LD DE,(DOLG)
	ADD HL,DE
	LD (ITOGO),HL
	LD HL,(ITOGO+2)
	LD DE,(DOLG+2)
	ADC HL,DE
	LD (ITOGO+2),HL
	LD IX,MU55
	JP MNU

MU56    DEFW 0,#381e
SMERT   LD IX,MU56
	CALL MNU
	CALL TMOF
	JP EX__

Mn_FIN  ;итоги за прош мес
	LD A,(RNB)
	LD (RNAgen),A
	LD HL,#BFBE
	CALL F_O
	;долги?
	LD HL,0
	LD (DOLG),HL
	LD (DOLG+2),HL
	LD DE,(ITOGO)
	LD HL,(MONEY)
	XOR A
	SBC HL,DE
	LD (MONEY),HL
	LD DE,(ITOGO+2)
	LD HL,(MONEY+2)
	SBC HL,DE
	LD (MONEY+2),HL
	JR C,BAD_M
	;рейтинг
	LD HL,REYTING
	LD A,(HL)
	LD (HL),0
	PUSH AF
	ADD A,191
	LD (MU79+6),A
	LD IX,MU79
	CALL MNU
	POP AF
	CP 2
	JR NC,RIP
	;баз>=4
	LD HL,BASE
	LD BC,#800
F_BS    LD A,(HL)
	INC HL
	CP 100
	JR NC,F_BS2
	INC C
F_BS2   DJNZ F_BS
	LD A,C
	CP 4
	JR C,BAD_B
	CALL XEARTH
	CALL LODMON
	CALL INIBUT
	JP STOP_T

MU81    DEFW 0,#511E
MU80    DEFW #602,#501A
MU79    DEFW #1400,#4F1E,MONEY
	DEFB 192

BAD_B   LD IX,MU82
	JR BAD_
BAD_M   LD IX,MU80
BAD_    CALL MNU
RIP     LD IX,MU81
	CALL MENUC
	CALL TMOF
	CALL NW_GE
	CALL MLOOP
MU82    DEFW #802,#5218

ACTD    ;действия кжд день
	CALL baseUP
	CALL hlthUP
	LD A,(DAT+14)
	LD HL,MNT
	CALL WT
	EX DE,HL
	XOR A
	LD HL,(DAT)
	PUSH HL
	SBC HL,DE
	POP HL
	JR Z,LST_D
	XOR A
	LD DE,#201
	SBC HL,DE
	RET NZ
	LD A,(DAT+14)
        CP 4
	RET NZ
	CALL STOP_T
	LD A,30
        JR B_D
LST_D   LD A,57
B_D     JP DISPL

baseUP  LD B,8
	LD HL,BASE
BUP0    LD A,(HL)
        OR A
        JR Z,BUP1
        CP 100
        JR NC,BUP1
        CP 9
        JR C,BUP2
        SUB 4
BUP2    DEC A
        LD (HL),A
BUP1    INC HL
        DJNZ BUP0
	RET

hlthUP  LD A,(DAT+1)
        OR A
	JR Z,HUP1
        CP 6
	RET NZ
HUP1    LD DE,AQNAVT
        LD HL,AQNAVT+6
        LD B,10
HUP0    PUSH BC
        LD A,(HL)
        OR A
        JR Z,HUP2
        LD A,(DE)
        OR A
        JR Z,HUP2
        DEC (HL)
        JR NZ,HUP2
        PUSH HL
	PUSH DE
	DEC A
        LD (DSDAT),A
        LD A,83
	CALL DISPLX
        POP DE
	POP HL
HUP2    LD BC,16
        ADD HL,BC
        EX DE,HL
        ADD HL,BC
	EX DE,HL
	POP BC
	DJNZ HUP0
	RET

;================= генератор целей ==============
AN_UFO  DEFB 6,9,8,5,7,9,11,13,17 ;макс к-во на НЛО
AN_OBJ  DEFB 18,19,14,19,17,14,20,21,22,16 ;макс к-во на объектах

PREBAT  ;предустановки боя
	CALL SET_U
	CALL SET_AR
	CALL SET_AN
	RET

SET_U   LD A,(T_UFO) ;тип НЛО (0..8) T_UFO->L_UFO
	CP 1
	JR C,SEU0
	JR Z,SEU1
	LD A,8
	JR SEU
SEU1    CALL RND
	AND 1
	ADD A,6
	JR SEU
SEU0    CALL RND
	AND 7
	CP 6
	JR NC,SEU0
SEU     LD (L_UFO),A
	RET

SET_AR  ;SET раса (1..5)
	LD A,(L_LAND)
	CP 9
	JR NZ,SER1
	LD A,3
SER0    LD (A_RASA),A
	RET
SER1    LD A,(PERIOD)
	LD HL,W_RASA
	CALL DD
	LD C,1
	CALL R100
	LD B,A
	XOR A
SER2    ADD A,(HL)
	INC HL
	CP B
	JR NC,SER3
	INC C
	LD E,A
	LD A,C
	CP 5
	LD A,E
	JR C,SER2
SER3    LD A,C
	JR SER0

SET_AN  LD A,(L_LAND) ;к_во врагов
	OR A
	LD HL,AN_OBJ-1
	JR NZ,SEN0
	LD A,(L_UFO)
	LD HL,AN_UFO
SEN0    CALL BT
	LD (A_NUM),A
       if PROTECT
	CALL CHK_3
	LD HL,(TX)
	LD A,(CRC3)
	CP L
	CALL NZ,OFFS
       endif
	JP MEM7

;6 периодов ведения войны
;появл врагов в %
W_RASA  DEFB 97,1,0,1;1
	DEFB 50,5,0,5;40
	DEFB 25,22,5,23;25
	DEFB 10,20,20,25;25
	DEFB 1,15,40,14;30
	DEFB 0,10,70,10;10
	DEFB 0,2,90,2;6
;появл НЛО в %
W_UFO   DEFB 95,95+5;0
        DEFB 83,83+15;2
        DEFB 75,75+17;8
        DEFB 55,55+30;15
        DEFB 40,40+35;25
	DEFB 10,10+55;35
	DEFB 10,10+30;60
;появл целей в % (UFO,sh,port,isl,Xb,Uc;Ub)
W_OBJ   DEFB 90,02,04,05,00,00;00 ;
	DEFB 80,04,10,07,00,00;00 ; НЕТ Xb,Uc,Ub!
	DEFB 70,07,08,10,00,06;00
	DEFB 60,08,09,05,03,10;05
	DEFB 49,11,02,05,08,10;15
	DEFB 20,05,09,01,25,15;25
	DEFB 10,05,02,03,70,02;03

OBJ_N   DEFB 1  ;(тип 0..6)
OBJ_MOD DEFB 1  ;(модификация)
NEWOBJ  ;генерация нов.объекта
	LD A,(PERIOD)
	ADD A,A
	LD B,A
	ADD A,A
	ADD A,B;x6
	LD HL,W_OBJ
	CALL BA
	LD C,0
	CALL R100
	LD B,A
	XOR A
NJ2     ADD A,(HL)
	INC HL
	CP B
	JR NC,NJ3
	INC C
	LD E,A
	LD A,C
	CP 6
	LD A,E
	JR C,NJ2
NJ3     LD A,C
	LD (OBJ_N),A
	OR A
	JR Z,NJ0
	CP 4
	JR Z,NJ4
	CALL RNDG ;кор,порт,остр,Ub,Uc (0..15)
	AND #F
	JR NJR
NJ4     LD B,80
NJ4_	CALL RND  ;Xb (1..7)
	AND 7
	JR Z,NJ4_
	LD C,A
	LD HL,BASE
	CALL BA
	CP 100
	LD A,C
	JR C,NJR
	DJNZ NJ4_
	JR NEWOBJ ;нет живых Xb
NJ0     LD A,(PERIOD) ;ufo (0..2)
	LD HL,W_UFO
	CALL WA
	CALL R100
	LD C,0
	CP (HL)
	JR C,NJ00
	INC C
	INC HL
	CP (HL)
	JR C,NJ00
	INC C
NJ00    LD A,C
NJR     LD (OBJ_MOD),A
	RET

RNDG	PUSH	HL ;пост случ посл
	LD	HL,(RNAgen)
	INC	HL
	LD	A,H ;;;
	AND	#1F
	LD	H,A
	LD	A,(RNBgen)
	RRCA
	RRCA
	RRCA
	XOR	(HL)
	SUB 	L
	ADD 	A,%11101
	LD	(RNAgen),HL
	LD	(RNBgen),A
	POP	HL
	RET

R100	CALL RNDG ; (rnd 1..100)
	AND #7F
	CP 100
	JR NC,R100
	INC A
	RET

TR_N1	DEFB 198-2,0,202-1,218-1,194-1;перв назв
TARh    ;генератор целей
	LD HL,TARoff
	LD A,(HL)
	OR A
	JR Z,TRon
	DEC (HL)
	RET NZ
	INC HL   ;нов
	CALL RNDG
	AND #1F
	ADD A,4
; LD A,6;---------
	LD (HL),A ;время жизни (4..19)
	CALL NEWOBJ
	LD E,A
	LD A,(OBJ_N)
	LD (TARlst),A
	PUSH AF
	LD HL,TR_N1
	CALL BA
	ADD A,E
	LD (DSDAT),A
	POP AF
	PUSH AF
	OR A
	CALL Z,UFOst
	POP AF
	PUSH AF
	LD HL,T_UFO
	CALL BA
	LD (HL),E
	LD A,84
	CALL DISPL
	POP AF
	ADD A,85
	CALL DISPLX
	CALL STOP_T
	JP REMAP

TRon	INC HL
	DEC (HL)
	RET NZ
	DEC HL
	CALL RNDG
	AND #1F
	ADD A,2;время межд целями (2..33)
	LD (HL),A
; LD (HL),1 ;-----------
	;убрать стар цель
	LD A,(TARlst)
	CP 200
	RET NC
	LD E,A
	LD HL,T_UFO ;цель была уничтожена
	CALL BA
	LD A,(HL)
	CP 200
	RET NC
	LD A,E
	PUSH AF
	CP 4
	JR Z,TRxb
	JR NC,TRubc ;для Ub,Uc
	OR A
	JR Z,TRufo
	LD HL,REYTING ;для гор,остр,кор
	LD A,(HL)
	CP 2
	JR NC,TR_
	INC (HL)
	JR TR_
TRxb	LD A,(T_BAS);для XB
	LD HL,BASE
	CALL BA
	LD (HL),255
	JR TR_
TRufo	LD A,(T_UFO)
	CP 3
	LD A,92    ;для ufo
	CALL C,DISPL
TR_     POP AF
	PUSH AF
	LD HL,T_UFO
	CALL BA
	LD (HL),255
TRubc	POP AF
	LD HL,T_TYPE
	CP (HL)
	CALL Z,GOhome ;цель потеряна
	LD A,255
	LD (TARlst),A
	JP REMAP

UFOst	;Новые коорд НЛО
	PUSH DE
Ust	CALL UFORND
	CALL isSEA
	JR Z,Ust
	LD (UFO),HL
	CALL UFORND
	LD (UFO_T),HL
	POP DE
	RET

UFORND	CALL RND ;случ коорд
	AND #7F
	CP 116
	JR NC,UFORND
	LD H,A
UC1	CALL RND
	CP 190
	JR NC,UC1
	LD L,A
	RET


REMAP	;восст карты
	XOR A
	LD (T_D),A
	LD (T_SW),A
	LD HL,DSCR
	LD DE,SCR
	LD C,8
	CALL RE_64
	LD HL,DSCR+#800
	LD DE,SCR+#800
	LD C,7
RE_64	LD B,8
	PUSH DE
	PUSH HL
RE_8	PUSHs
	LDI
	LDI
	LDI
	LDI;4
	LDI
	LDI
	LDI
	LDI;8
	LDI
	LDI
	LDI
	LDI;12
	LDI
	LDI
	LDI
	LDI;16
	LDI
	LDI
	LDI
	LDI;20
	LDI
	LDI
	LDI
	LDI;24
	POPs
	INC H
	INC D
	DJNZ RE_8
	POP HL
	POP DE
	LD A,L
	ADD A,32
	LD L,A
	LD A,E
	ADD A,32
	LD E,A
	DEC C
	JR NZ,RE_64
	RET


isSEA	;HL - это океан ? NZ-да, Z-нет
	PUSH HL
	EX DE,HL
	LD IX,DATA01
	LD A,E
	AND %111
	LD (ISE0+2),A
	CALL STD
	CALL PCOORD
ISE0	LD A,(IX+0)
	AND (HL)
	POP HL
	RET

ACTM    LD A,(T_D)
	AND 1
	LD A,1
	LD (T_D),A
	JR Z,AKM0
	CALL SHOWD
AKM0	LD HL,(UFO_T) ;UFO move
	PUSH HL
	LD DE,(UFO)
	CALL LINini
	CALL LINnx_
	LD (UFO),DE
	POP HL
	XOR A
	SBC HL,DE
	JR NZ,AKM1
	CALL UFORND
	LD (UFO_T),HL
AKM1	LD HL,(UFO) ;intr move
	LD A,(T_TYPE)
	OR A
	JR Z,AKM2
	LD HL,(INTR_T)
AKM2	PUSH HL
	LD DE,(INTR)
	XOR A
	SBC HL,DE
	POP HL
	JR Z,AKM4
	PUSH HL
	CALL LINini
	CALL LINnx_
	LD (INTR),DE
	POP HL
	XOR A
	SBC HL,DE
	JP NZ,SHOWD
AKM4	LD A,(T_TYPE)
	CP 100
	JP NC,SHOWD
	OR A
	JR NZ,AKM3
	LD HL,(UFO)
	CALL isSEA
	JP Z,SHOWD
	LD A,(xHAC2)
	CP #D6
	JP Z,SEA1
	CALL BATTLE
AKM3	;вызов боя
	CALL BATTL1

isTLEF	LD A,(RS+58)
	OR A
	RET NZ
	LD (Tleth),A
	RET

EVAC	;эвакуация
	CALL BADDER
	JP SEA2_

ALLDIE	;все погибли
	CALL MEM7
	CALL BACK
	LD IX,MU93
	CALL MENUC
	CALL TMOF
	CALL BADDER
	JP SEA4

MU93	DEFW #A02,#5D1A

TARRES	LD A,(T_TYPE) ;откл цель
	PUSH AF
	LD HL,T_UFO
	CALL BA
	LD B,(HL)
	LD (HL),255
	POP AF
	OR A
	RET
BADDER	;плохие рез-ты
	CALL TARRES
	RET Z ;для нло
	CP 4
	JR Z,BDxb
	RET NC ;для Ub,Uc
	LD HL,REYTING ;для гор,остр,кор
	LD A,(HL)
	CP 2
	RET NC
	INC (HL)
	RET
BDxb	LD A,B;для XB
	LD HL,BASE
	CALL BA
	LD (HL),255
	RET

POSTBAT ;итоги после боя
       if PROTECT
	CALL CHECK4
       endif
	CALL TARRES
	CALL PICKER
	JP U2S

CLEAR	;очистка врем хран
	LD HL,U_GUN
	LD B,U_len
CLE0	LD (HL),0
	INC HL
	DJNZ CLE0
	RET

PICKER  CALL STD ;сообщения о собр
	CALL OFFD
	LD HL,#5
	LD (SX),HL
	LD A,199
	CALL NWRDM
	LD B,0
	LD HL,#201
	LD (SX),HL
PK1	PUSH BC
	LD A,B
	LD HL,U_GUN
	CALL BA
	OR A
	JR Z,PK4
	PUSH AF
	LD A,B
	CP 15
	JR C,PK2
	ADD A,43-15
	CP 51
	JR C,PK2
	ADD A,111-51
PK2	CALL NWRDM
	POP AF
	LD HL,SX
	LD (HL),22
	PUSH HL
	CALL WB
	POP HL
	LD (HL),1
	INC HL
	INC (HL)
PK4	POP BC
	INC B
	LD A,B
	CP U_len
	JR C,PK1
	CALL STS
	CALL OFFS
	CALL COPY
	ATRs #0,#1618,#70
	LD L,22
	LD B,6
	LD A,#68
	CALL ATRBAR
	CALL PT128
	JP TMOF

UplusS	LD A,(DE)
	INC DE
	ADD A,(HL)
	LD (HL),A
	INC HL
	JR NC,UpS
	INC (HL)
UpS	INC HL
	DJNZ UplusS
	RET

U2S	;из U_XXX в S_XXX
	LD B,5  ;инопл-профессионалы
	LD HL,U_LIV
	LD DE,S_PROF
U2S30	LD C,(HL)
U2S3	LD A,C
	OR A
	JR Z,U2S4
	DEC C
	CALL RND
	AND %1000 ;только 1 из 2х
	JR Z,U2S7
	LD A,(S_ART+18)
	INC A
	LD (S_ART+18),A
	JR U2S3
U2S7	PUSH HL
	CALL RND
	AND 3
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,DE
	INC (HL)
	POP HL
	JR U2S3
U2S4	INC HL
	PUSH HL
	LD HL,8
	ADD HL,DE
	EX DE,HL
	POP HL
	DJNZ U2S30
	;артеф и оруж
	LD B,15
	LD DE,U_GUN
	LD HL,S_GUN
	CALL UplusS
	LD HL,S_ART
	LD B,10
	CALL UplusS
	LD HL,S_LIV
	LD B,7
	CALL UplusS
	LD A,(S_ART+12)
	CP 5
	JR C,U2S1
	LD (S_TMP),A ;5 пси-контр
U2S1	LD A,(L_LAND)
	OR A
	RET NZ
	LD A,(L_UFO) ;тип НЛО
	LD HL,S_UFO
	CALL WA
	INC (HL)
	RET

OFFNUM	LD HL,RS-55 ;откл иссл
	LD BC,#80FF
OFNU	LD (HL),C
	INC HL
	DJNZ OFNU
	RET

DEMBEL	;демобилизация
	CALL RNDG
	AND %00011111
	CP 10
	RET NC
	ADD A,A
	ADD A,A
	LD HL,AQNAVT
	CALL DD
	LD A,(HL)
	LD (DSDAT),A
	OR A
	RET Z
	INC HL
	LD A,(HL)
	CP 7
	RET C
	DEC HL
	LD (HL),0
	LD HL,AQU
	DEC (HL)
	LD A,96
	CALL DISPLX
	JP STOP_T

;опции =================================================
MUL480  LD L,A
        LD H,0
        LD DE,480
        CALL MUL
        LD HL,ALLDAT
	ADD HL,DE
        RET

GAMs    DEFB 25,51,65,48,15,0
        DEFB 15,15,15,0,0,15,0,0,15,0,0,15
	DEFB 0,0,99,0,0,99,2,0,0,0,#7F

GM_DAT  ;строка игры (A=1..5)
	LD (GAMs+5),A
	DEC A
        CALL MUL480
        LD DE,TIM-DATA
        ADD HL,DE
        Ms 3+#C0
        LD DE,GAMs+9
        LD BC,8
        LDIR
        INC DE
        LDI
        LDI
	INC DE
        PUSH DE
	LD BC,10
        ADD HL,BC
        LD DE,GAMs+26
	LDI
        LDI
        LD A,(HL)
	INC A
	CALL WTRB
        LD HL,DCS+8
        POP DE
        LDI
        LDI
	LD HL,GAMs+21
        LD A,(HL)
        CP 15
        JP NZ,MEM7
        LD (HL),0
        JP MEM7

MU_4CD  DEFW #400,#4C1E,T+138
	DEFB 5

GAMLST  LD IX,MU_4CD
	LD (MU_4CD+3),A
        CALL MENU
        LD HL,#E02
	LD B,5
GAL     pushs
        LD A,B
        LD (SX),HL
        CALL GM_DAT
        LD HL,GAMs
	LD (TXT),HL
        CALL WORD
        pops
        DEC H
        DJNZ GAL
        CALL INIMNU
	LD HL,SELmr
        LD (sx1+1),HL ;HL-Sub.ADR
	LD (sx2+1),HL
        JP COPYAT

LD_M    LD A,#4D
        CALL GAMLST
        CALL SELTN
	RET NC
	CALL MUL480
        LD DE,DATA
OP_M    Ms 3
        LD BC,DATLEN
        LDIR
	JP MEM7

SV_M    LD A,#4C
        CALL GAMLST
        CALL SELTN
        RET NC
	CALL MUL480
        LD DE,DATA
	EX DE,HL
        JR OP_M

MU_4A   DEFW #503,#4A16,T+182
        DEFB 6
DO_T    DEFW SV_M,LD_M,NW_G,SV_D,LD_D,EX_G
MU_4B   DEFW #B00,#4B18

OPTION  ;Диск.операции
	CALL SAVMON
        CALL    BACK
	LD      IX,MU_4A
        CALL    SELM
        JP      NC,UP9
        LD      HL,DO_T
        CALL    WT
        LD      DE,OPTR
	PUSH    DE
	JP (HL)
OPTR    JP MLOOP

EX_G    LD IX,MU_4B
	CALL MENUC
	CALL YES_NO
	RET NZ
EX__    LD HL,#4000
        LD DE,#4001
        LD (HL),E
        LD BC,#2000
	LDIR
        ;LD BC,#7FFD
	;XOR A
        ;OUT (C),A
        ;CALL 0
        jp quit

MU_4E   DEFW #301,#4E1A
NW_G    LD IX,MU_4E
	CALL MENUC
	CALL YES_NO
        RET NZ
NW_GE   Ms 3+#C0
        LD HL,NEWDAT
        LD DE,DATA
        LD BC,DATLEN
	LDIR
        CALL MEM7
NGG     CALL RND
        CP 192
        JR NC,NGG
	INC A
        LD (N_AQU),A
	LD A,R
        LD (RNBgen+1),A
	LD HL,(RNA)
	LD (RNAgen),HL
        LD A,28
        LD (SYSINI),A
	RET

SV_D    LD IX,MU53
	LD A,194
	LD (MU53+4),A
	CALL MENUC
	CALL YES_NO
	RET NZ
       if PROTECT
	CALL CHK_2 ;[]
	LD HL,(CRC2)
	OR A
	SBC HL,BC
	JR NZ,LD_RTN
       endif
LD_RTR  Ms 3+#80
LD_RTN	LD DE,DSCR+1
	LD HL,ALLDAT
	LD BC,480*5
	LDIR
	LD HL,C_ONOF
	LD C,CFGLEN
	LDIR
	LD HL,DATA
	LD BC,600
	LDIR
       if PROTECT
	CALL XORDAT
	LD (DSCR),A
       endif
	CALL MEM7
	;save DSCR,4k
	CALL S_DSCR
	CALL OFFD
	;load DSCR,4k
	CALL L_DSCR
	Ms 3+#80
       if PROTECT
	CALL XORDAT
	CALL XORDAT
        LD HL,DSCR
        CP (HL)
        JR NZ,LD_RTR
       endif
        JP MEM7

MU53    DEFW #901,#351A
	DEFB 196

LD_D    LD IX,MU53
	LD A,195
	LD (MU53+4),A
        CALL MENUC
        CALL YES_NO
	RET NZ
 	;load DSCR,4k
	CALL L_DSCR
        Ms 3+#40
       if PROTECT
        CALL XORDAT
        CALL XORDAT
	LD HL,DSCR
        CP (HL)
        JP NZ,LD_ER
	CALL XORDAT
       endif
	LD HL,DSCR+1
	LD DE,ALLDAT
	LD BC,480*5
	LDIR
	LD DE,C_ONOF
	LD C,CFGLEN
	LDIR
	LD DE,DATA
	LD BC,DATLEN
	LDIR
	JP MEM7

SET_LS	XOR A
	LD (SIDE),A
	LD HL,DSCR
	LD B,16
	LD DE,#201
	RET

L_DSCR  CALL LDASM3
	LD B,3
L_DS	PUSH BC
	CALL TR000
	CALL SET_LS
L_D1	PUSH BC
	LD B,1
	CALL D_READ
	POP BC
	JR C,L_D_ER
	DEC H
	DEC H
	DEC H
	DJNZ L_D1
	POP BC
	JP LDASM2
L_D_ER	POP BC
	DJNZ L_DS
	JP LDASM2

S_DSCR  CALL LDASM3
	CALL TR000
	CALL SET_LS
	CALL D_WRITE
	JP LDASM2

       if PROTECT
XORDAT  ;xor DSCR+1,len=3000 CRC->A
	LD A,#A9
	EX AF,AF
	LD HL,DSCR+1
	LD DE,SCR+200
	LD BC,3000
XD0     LD A,(DE)
	XOR (HL)
	LD (HL),A
	EX AF,AF
	XOR (HL)
	EX AF,AF
	INC DE
	INC HL
	DEC BC
	LD A,C
	OR B
	JR NZ,XD0
	EX AF,AF
	RET

	PUSH AF
CHECK4	; []#4
	LD A,70
	LD HL,TAB100+7
	CALL BT
	RRCA
	RRCA
	LD C,A
	LD A,22
	CALL BA
	CP C
	RET Z
	POP AF
	JP B_LOOP
       endif

LD_ER   CALL XEARTH
	CALL COPYAT
	LD IX,MU54
        CALL BEEP
        JP MNU
MU54    DEFW #307,#3610

