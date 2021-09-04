PANIC
 if debug_stop = 0
 _Loop_
 else
 jr $
 endif

loopc
       _LoopC

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
        GETDEST
       ld l,a
        ld a,c
        cpl
        ld c,a
        ld a,b
        cpl
        ld b,a ;TODO флаги?
       ld a,l
        PUTDEST_Loop       
INC_DEC
        jp m,DECer
        GETDEST
        ex af,af' ;'
     rra ;keep CF in a7
        ld hl,1
        or a
        adc hl,bc
     rla ;CF from a7
        ex af,af' ;'
        PUTDEST_Loop       
DECer
        GETDEST
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
        ;ex af,af' ;'
        ;TODO сбросить V
        ;ex af,af' ;'
        PUTDEST_Loop

CMPer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
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
       push hl
        GETDEST
       pop hl
        ;ex af,af' ;'
        ld a,l ;src
        and c
        ld c,a
        ld a,h ;src
        and b
        ld b,a
     ;rra
     ;ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ;ld a,h
     ;rla ;CF
        ex af,af' ;'
       _LoopC

BICer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
       pop hl
        ;ex af,af' ;'
        ld a,l ;src
        cpl
        and c
        ld c,a
        ld a,h ;src
        cpl
        and b
        ld b,a
     ;rra
     ;ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ;ld a,h
     ;rla ;CF
        ex af,af' ;'
       _LoopC

BISer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
       pop hl
        ;ex af,af' ;'
        ld a,l ;src
        or c
        ld c,a
        ld a,h ;src
        or b
        ld b,a
     ;rra
     ;ld h,a ;keep CF
        ld a,c
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
     ;ld a,h
     ;rla ;CF
        ex af,af' ;'
       _LoopC

ADDer
        ;ld b,a
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
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
       push hl
        GETDEST
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
        call readsourceop ;out: bc=sourceop, a=cmdLSB
        ;ex af,af' ;'
        ;TODO сбросить V
        ;ex af,af' ;'
        PUTDEST8_Loop

CMPBer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
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
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
       pop hl
        ex af,af' ;'
        ld a,c
        and l ;TODO keep CY?
        ex af,af' ;'
       _LoopC

BICBer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
       pop hl
        ex af,af' ;'
        ld a,l ;src
        cpl
        and c
        ld c,a ;TODO keep CY?
        ex af,af' ;'
       _LoopC

BISBer
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
       push hl
        GETDEST
       pop hl
        ex af,af' ;'
        ld a,c
        or l
        ld c,a ;TODO keep CY?
        ex af,af' ;'
       _LoopC

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
        ld a,e
        add a,c
        jr nc,$+3
        dec d
        add a,c
        jr nc,$+3
        dec d
        ld e,a
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
        GETDEST ;call readsourceop ;out: bc=sourceop, a=cmdLSB
        ld d,b
        ld e,c
       _LoopC_JP


RORB_ROLB_ASRB_ASLB
        ld a,c
        add a,a
        jr c,ASRB_ASLB
        jp m,ROLBer
;RORBer
        GETDEST
	ex af,af' ;'
        rr c
	ex af,af' ;'
        PUTDEST8_Loop
ROLBer
        GETDEST
	ex af,af' ;'
        rl c
	ex af,af' ;'
        PUTDEST8_Loop
ASRB_ASLB
        jp m,ASLBer
;ASRer
        GETDEST
        sra c ;TODO проверить
	ex af,af' ;'
        PUTDEST8_Loop
ASLBer
        GETDEST
        sla c
	ex af,af' ;'
        PUTDEST8_Loop


ROR_ROL_ASR_ASL
        ld a,c
        add a,a
        jr c,ASR_ASL
        jp m,ROLer
;RORer
        GETDEST
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
        GETDEST
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
        GETDEST
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
        GETDEST
        ld h,b
        ld l,c
        or a
        adc hl,hl
        ld b,h
        ld c,l
	ex af,af' ;'
        PUTDEST_Loop

NEG_ADC_SBC_TST
;TODO
c0064_MFPI_MTPI_SXT
;TODO
CLRB_COMB_INCB_DECB
;TODO
NEGB_ADCB_SBCB_TSTB
;TODO
MTPS_MFPD_MTPD_MFPS
;TODO
        jr $

SWABer
        GETDEST
        ld h,b
        ld b,c
        ld c,h
        PUTDEST_Loop

