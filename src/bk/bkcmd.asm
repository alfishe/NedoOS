PANIC
 if debug_stop = 0
 _Loop_
 else
 jr $
 endif

loopc
       _LoopC

CLRB_COMB_INCB_DECB
        ld a,c
        add a,a
        jr c,INCB_DECB
        jp m,COMBer
;CLRBer        
        ld a,c
       ex af,af' ;'
        ;ld a,1
        ;dec a
        xor a ;обнуляет перенос и V, так надо
        ld c,a
       ex af,af' ;'
        PUTDEST8_Loop
COMBer
        GETDEST8_cmdc
	ex af,af' ;' ;keep a=cmdLSB
       ld l,a
        ld a,c
        cpl
        ld c,a ;TODO флаги?
       ld a,l
       ex af,af' ;'
        PUTDEST8_Loop
INCB_DECB
        jp m,DECBer
;INCBer
        GETDEST8_cmdc
        ex af,af' ;'
        inc c
        ex af,af' ;'
        PUTDEST8_Loop
DECBer
        GETDEST8_cmdc
        ex af,af' ;'
        dec c
        ex af,af' ;'
        PUTDEST8_Loop

CLR_COM_INC_DEC
        ld a,c
        add a,a
        jr c,INC_DEC
        jp m,COMer
;CLRer
        ld a,c
       ex af,af' ;'
        ;ld a,1
        ;dec a
        xor a ;обнуляет перенос и V, так надо
        ld b,a
        ld c,a
       ex af,af' ;'
        PUTDEST_Loop       
COMer
        GETDEST_cmdc
	ex af,af' ;' ;keep a=cmdLSB
       ld l,a
        ld a,c
        cpl
        ld c,a
        ld a,b
        cpl
        ld b,a ;TODO флаги?
       ld a,l
       ex af,af' ;'
        PUTDEST_Loop       
INC_DEC
        jp m,DECer
        GETDEST_cmdc
        ex af,af' ;'
     rra ;keep CF in a7
        ld hl,1
        or a
        adc hl,bc
        ld b,h
        ld c,l
     rla ;CF from a7
        ex af,af' ;'
        PUTDEST_Loop       
DECer
        GETDEST_cmdc
        ex af,af' ;'
     rra ;keep CF in a7
        ld h,b
        ld l,c
        ld bc,1
        or a
        sbc hl,bc
        ld b,h
        ld c,l
     rla ;CF from a7
        ex af,af' ;'
        PUTDEST_Loop       

NEG_ADC_SBC_TST
        ld a,c
        add a,a
        jp m,ADC_TST
        jr c,SBCer
;NEGer
        GETDEST_cmdc
        ex af,af' ;'
     rra ;keep CF in a7
        ld hl,0
        or a
        sbc hl,bc
        ld b,h
        ld c,l
     rla ;CF from a7
        ex af,af' ;'
        PUTDEST_Loop
SBCer        
        GETDEST_cmdc
        ex af,af' ;'
        ld h,b
        ld l,c
        ld bc,0
        sbc hl,bc
        ld b,h
        ld c,l
        ex af,af' ;'
        PUTDEST_Loop

ADC_TST
        jr c,TSTer
;ADCer
        GETDEST_cmdc
        ex af,af' ;'
        ld hl,0
        adc hl,bc
        ld b,h
        ld c,l
        ex af,af' ;'
        PUTDEST_Loop
TSTer
        GETDEST_cmdc_autoinc
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
        ex af,af' ;'
       _LoopC

XORer
       ;jr $
        ;ld b,a
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
         ;ld l,(hl) ;TODO
       ld a,c
        ld c,(hl)
        inc l
        ld b,(hl) ;bc=src
       push bc
        GETDEST_cmda
       pop hl
        ex af,af' ;'
     rra
     ld hx,a ;keep CF
        ld a,h ;src
        xor b
        ld b,a
        ld a,l ;src
        xor c
        ld c,a
        ;ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,hx
     rla ;CF
        ex af,af' ;'
        PUTDEST_Loop
        
NEGB_ADCB_SBCB_TSTB
        ld a,c
        add a,a
        jp m,ADCB_TSTB
        jr c,SBCBer
;NEGBer
        GETDEST8_cmdc
        ex af,af' ;'
     rra ;keep CF in a7
     ld h,a
        xor a
        sub c
        ld c,a
     ld a,h
     rla ;CF from a7
        ex af,af' ;'
        PUTDEST8_Loop
SBCBer
        GETDEST8_cmdc
        ex af,af' ;'
        ld a,c
        sbc a,0
        ld c,a
        ex af,af' ;'
        PUTDEST8_Loop

ADCB_TSTB
        jr c,TSTBer
;ADCBer
        GETDEST8_cmdc
        ex af,af' ;'
        ld a,c
        adc a,0
        ld c,a
        ex af,af' ;'
        PUTDEST8_Loop
TSTBer
        GETDEST8_cmdc_autoinc
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,c
        or a ;TODO сбросить V?
     ld a,h
     rla ;CF
        ex af,af' ;'
       _LoopC

MOVer
;15df, 02d8, ffb4 ;mov #1330, @#177664
;0001 0101 1101 1111
;0 001 010 111 011 111
     ;(Rn)+;r7 ;@(Rn)+;r7

;15c1, 4000 ;mov #40000,r1
;0001 0101 1100 0001
;0 001 010 111 000 001
     ;(Rn)+;r7 ;rn;r1
        ;ld b,a
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
        ;TODO сбросить V
        ex af,af' ;'
        PUTDEST_Loop

CMPer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda_autoinc
        ld h,b
        ld l,c
       pop bc
        ex af,af' ;'
        or a
        sbc hl,bc
        ccf
        ex af,af' ;'
       _LoopC

BITer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda_autoinc
       pop hl
	;ex af,af' ;' ;keep a=cmdLSB
        ld a,l ;src
        and c
        ld c,a
        ld a,h ;src
        and b
        ld b,a
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
        ex af,af' ;'
       _LoopC

BICer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda
       pop hl
	ex af,af' ;' ;keep a=cmdLSB
     rra
     ld hx,a ;keep CF
        ld a,h ;src
        cpl
        and b
        ld b,a
        ld a,l ;src
        cpl
        and c
        ld c,a
        ;ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,hx
     rla ;CF
        ex af,af' ;'
        PUTDEST_Loop

BISer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda
       pop hl
	ex af,af' ;' ;keep a=cmdLSB
     rra
     ld hx,a ;keep CF
        ld a,h ;src
        or b
        ld b,a
        ld a,l ;src
        or c
        ld c,a
        ;ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,hx
     rla ;CF
        ex af,af' ;'
        PUTDEST_Loop

ADDer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda
       pop hl
        ex af,af' ;'
        or a
        adc hl,bc
        ex af,af' ;'
        ld b,h
        ld c,l
        PUTDEST_Loop

SUBer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST_cmda
        ld h,b
        ld l,c
       pop bc
        ex af,af' ;'
        or a
        sbc hl,bc
        ccf
        ex af,af' ;'
        ld b,h
        ld c,l
        PUTDEST_Loop

MOVBer
        call readsource8op ;out: bc=sourceop, a=cmdLSB
        ex af,af' ;'
     rra
     ld h,a ;keep CF
       ld a,c
       rla
       sbc a,a
       ld b,a ;for textshow
        ld a,c
        or a
        ;TODO сбросить V
     ld a,h
     rla ;CF
        ex af,af' ;'
        ;PUTDEST8_Loop
        PUTDEST_Loop ;for textshow

CMPBer
;ac=cmd
        call readsource8op ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST8_cmda_autoinc
       pop hl
        ex af,af' ;'
        ld a,c
        sub l
        ld c,a
        ccf
        ex af,af' ;'
       _LoopC

BITBer
;ac=cmd
        call readsource8op ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST8_cmda_autoinc
       pop hl
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,c
        and l ;TODO keep CY?
     ld a,h
     rla ;CF
        ex af,af' ;'
       _LoopC

BICBer
;ac=cmd
        call readsource8op ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST8_cmda
       pop hl
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,l ;src
        cpl
        and c
        ld c,a
     ld a,h
     rla ;CF
        ex af,af' ;'
        PUTDEST8_Loop

BISBer
;ac=cmd
        call readsource8op ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST8_cmda
       pop hl
        ex af,af' ;'
     rra
     ld h,a ;keep CF
        ld a,c
        or l
        ld c,a
     ld a,h
     rla ;CF
        ex af,af' ;'
        PUTDEST8_Loop

CALLer
;jsr link, addr работает так: mov link=>-(sp);mov pc=>link; mov addr=>pc

;09f7 - относительный call
;0000 1001 1111 0111
;0 000 100 111 110 111<-link
          ;src ;X(rn) ;dst

;09f7 - абсолютный call???
;0000 1001 1101 1111
;0 000 100 111 011 111<-link
          ;src ;@(Rn)+ ;dst

        ld a,c
        rla
        and 0x0e
       cp 0x0e
       jr z,CALLerPC
;TODO test
        ld l,a
        ld h,_R0/256
       push hl
        ld c,(hl)
        inc l
        ld b,(hl) ;bc=link
       inc bc
       inc bc
        putmemspBC
        
        get
        next
        ld c,a
        get
        next
        ld b,a ;bc=X

        decodePC
        
        ld a,e
        add a,c
        ld c,a
        ld a,d
        adc a,b
        ld b,a ;bc=pc+X
        
       pop hl
        ld (hl),e
        inc l
        ld (hl),d
bctoPCLoop
        ld d,b
        ld e,c
loopcjp
       _LoopC_JP

CALLerPC
;jsr PC, addr работает так: mov PC=>-(sp);mov addr=>pc
        ld a,(pc_high)
        xor d
        and 0xc0
        xor d
        ld b,a
        ld c,e ;bc=link
       inc bc
       inc bc
        putmemspBC
        
        get
        next
        ld c,a
        get
        next
        ld b,a ;bc=X

        decodePC
        
        ld a,e
        add a,c
        ld e,a
        ld a,d
        adc a,b
        ld d,a ;bc=pc+X
       _LoopC_JP

SOBer
;Subtract One and Branch: Reg < Reg - 1; if Reg ? 0 then PC < PC - 2 ? Offset
;TODO pc,sp?
        rra
        ld a,c
        rra
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
       ld a,c
        ld c,(hl)
        inc l
        ld b,(hl)
        cpd
        ld (hl),c
        inc hl
        ld (hl),b
        jp po,loopc ;jump if 0
        and 0x3f
        add a,a
        ld c,a
        decodePC        
        ld a,e
        sub c
        ld e,a
        jr nc,$+3
        dec d
       _LoopC_JP

exaBR
        ex af,af' ;'
BRer
        decodePC 
       sla c
       sbc a,a
       ld b,a
        ld a,e
        add a,c
        ld e,a
        ld a,d
        adc a,b
        ld d,a
       _LoopC_JP

BNEer
        ex af,af' ;'
        jr nz,exaBR
        ex af,af' ;'
       _LoopC
BEQer
        ex af,af' ;'
        jr z,exaBR
        ex af,af' ;'
       _LoopC
BGEer ;Branch if greater than or equal (N ? V) = 0
;TODO
        jr $
       _LoopC
BLTer ;Branch if less than (N ? V) = 1
;TODO
        jr $
       _LoopC
BGTer ;Branch if greater than (Z ? (N ? V)) = 0
;TODO
        jr $
       _LoopC
BLEer ;Branch if less than or equal (Z ? (N ? V)) = 1
;TODO
        jr $
       _LoopC
BPLer
        ex af,af' ;'
        jp p,exaBR
        ex af,af' ;'
       _LoopC
BMIer
        ex af,af' ;'
        jp m,exaBR
        ex af,af' ;'
       _LoopC
BHIer ;(C ? Z) = 0
        ex af,af' ;'
        jr c,$+4
        jr nz,exaBR
        ex af,af' ;'
       _LoopC
BLOSer ;(C ? Z) = 1
        ex af,af' ;'
        jr c,exaBR
        jr z,exaBR
        ex af,af' ;'
       _LoopC
BVCer ;Branch if overflow clear V = 0
        ex af,af' ;'
        jp po,exaBR ;po=no overflow
        ex af,af' ;'
       _LoopC
BVSer ;Branch if overflow set V = 1
        ex af,af' ;'
        jp pe,exaBR ;pe=overflow
        ex af,af' ;'
       _LoopC
BCCer ;BCC or BHIS	Branch if carry clear, or Branch if higher or same C = 0
        ex af,af' ;'
        jr nc,exaBR
        ex af,af' ;'
       _LoopC
BCSer ;BCS or BLO	Branch if carry set, or Branch if lower C = 1
        ex af,af' ;'
        jr c,exaBR
        ex af,af' ;'
       _LoopC

RTI_JMP_RTS_SWAB
;0000.. см. ниже
;0001??	JMP	Jump: PC < Src
;00020r	RTS	Return from subroutine: PC < Reg; Reg < (SP)+
;0002??	d5=1,d4=0	Ccc ;flags &= ~(d3..d0 (NZVC))
;0002??	d5=1,d4=1	Scc ;flags |= (d3..d0 (NZVC))
;0003dr	SWAB	Swap bytes of word: Dest < Swap-bytes(Dest)
        ;ld b,a
        ld a,c
        add a,a
        jr c,c0002_0003
        jp m,JMPer;c0001
;000000	HALT
;000001	WAIT
;000002	RTI	Return from interrupt: PC < (SP)+; PS < (SP)+
;000003	BPT	Breakpoint trap: -(SP) < PS; -(SP) < PC; PC < (14); PS < (16)
;000004	IOT	I/O trap: -(SP) < PS; -(SP) < PC; PC < (20); PS < (22)
;000005	RESET
;000006	RTT	Return from trap: PC < (SP)+; PS < (SP)+
;TODO
        jr $
        
c0002_0003
;a=cmdLSB*2
        jp m,SWABer;c0003
;00020r	RTS	Return from subroutine: PC < Reg; Reg < (SP)+
        cp 8*2 ;с=0x80..0x87
        jr c,RTSer
;0002??	d5=1,d4=0	Ccc ;flags &= ~(d3..d0 (NZVC))
;0002??	d5=1,d4=1	Scc ;flags |= (d3..d0 (NZVC))
        bit 4,c
        jr nz,SCCer
       ld a,c
       push af
        call getflags_bc
       pop af
       and 0x0f
       cpl
       and c
       ld c,a
        call makeflags_frombc
       _LoopC
SCCer
       ld a,c
       push af
        call getflags_bc
       pop af
       and 0x0f
       or c
       ld c,a
        call makeflags_frombc
       _LoopC

RTSer
        ;and 0x0e
       cp 0x0e
       jr z,RTSerPC
;TODO test
        ld l,a
        ld h,_R0/256
        ld e,(hl)
        inc l
        ld d,(hl)
       push hl
        getmemspBC
       pop hl
        ld (hl),b
        dec l
        ld (hl),c
       _LoopC_JP
RTSerPC
        getmemspBC
        ld d,b
        ld e,c
       _LoopC_JP

JMPer
;?c=cmd
        GETDEST_cmdc_autoinc ;call readsourceop ;out: bc=sourceop, a=cmdLSB
        ld d,b
        ld e,c
       _LoopC_JP


RORB_ROLB_ASRB_ASLB
        ld a,c
        add a,a
        jr c,ASRB_ASLB
        jp m,ROLBer
;RORBer
        GETDEST8_cmdc
	ex af,af' ;'
        rr c
	ex af,af' ;'
        PUTDEST8_Loop
ROLBer
        GETDEST8_cmdc
	ex af,af' ;'
        rl c
	ex af,af' ;'
        PUTDEST8_Loop
ASRB_ASLB
        jp m,ASLBer
;ASRer
        GETDEST8_cmdc
	ex af,af' ;' ;keep a=cmdLSB
        sra c ;TODO проверить
	ex af,af' ;'
        PUTDEST8_Loop
ASLBer
        GETDEST8_cmdc
	ex af,af' ;' ;keep a=cmdLSB
        sla c
	ex af,af' ;'
        PUTDEST8_Loop


ROR_ROL_ASR_ASL
        ld a,c
        add a,a
        jr c,ASR_ASL
        jp m,ROLer
;RORer
        GETDEST_cmdc
	ex af,af' ;'
        rr b
        rr c
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
	ex af,af' ;'
        PUTDEST_Loop
ROLer
        GETDEST_cmdc
	ex af,af' ;'
        rl c
        rl b
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
	ex af,af' ;'
        PUTDEST_Loop
ASR_ASL
        jp m,ASLer
;ASRer
        GETDEST_cmdc
	ex af,af' ;' ;keep a=cmdLSB
        sra b
        rr c
     rra
     ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ld a,h
     rla ;CF
	ex af,af' ;'
        PUTDEST_Loop
ASLer
        GETDEST_cmdc
	ex af,af' ;' ;keep a=cmdLSB
        ld h,b
        ld l,c
        or a
        adc hl,hl
        ld b,h
        ld c,l
	ex af,af' ;'
        PUTDEST_Loop

c0064_MFPI_MTPI_SXT
;TODO
        jr $
MTPS_MFPD_MTPD_MFPS
;TODO
        jr $
MULer
        jr $
DIVer
        jr $
ASHer
        jr $
ASHCer
        jr $

SWABer
        GETDEST_cmdc
        ld h,b
        ld b,c
        ld c,h
        PUTDEST_Loop

