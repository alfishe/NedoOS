PANIC
 if debug_stop = 0
 _Loop_
 else
 jr $
 endif

CLR_COM_INC_DEC
        ld a,c
        cp 0x40
        jr c,CLRer
        
;TODO
loopc
       _LoopC
CLRer
;TODO разные адресации
        rla
         and 0x0e
        ld l,a
        ld h,_R0/256
        ld (hl),0
        inc l
       ex af,af' ;'
        ;ld a,1
        ;dec a
        xor a ;обнуляет перенос и V, так надо
        ld (hl),a
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
        ;TODO сбросить V
        ex af,af' ;'        
        PUTDEST_Loop

CMPer
;TODO
       _LoopC

BITer
;TODO
       _LoopC

BICer
;TODO
       _LoopC

BISer
;TODO
       _LoopC

ADDer
        ;ld b,a
;ac=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB
        
        rla
         and 0x0e
        ld l,a
        ld h,_R0/256
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        ex de,hl
        ex af,af' ;'
        or a
        adc hl,bc
        ex af,af' ;'
        ex de,hl
        ld (hl),d
        dec l
        ld (hl),e
        ld a,l
        cp 0x0e
        jp z,poprecodePCLoop ;de=new PC
       pop de
       _LoopC

SUBer
;TODO
       _LoopC

MOVBer
;TODO
       _LoopC

CMPBer
;TODO
       _LoopC

BITBer
;TODO
       _LoopC

BICBer
;TODO
       _LoopC

BISBer
;TODO
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
        jp m,SWABer;c0003
;00020r	RTS	Return from subroutine: PC < Reg; Reg < (SP)+
        cp 8*2 ;с=0x80..0x87
        jr c,RTSer
;0002??	d5=1,d4=0	Ccc ;flags &= ~(d3..d0 (NZVC))
;0002??	d5=1,d4=1	Scc ;flags |= (d3..d0 (NZVC))
        
        jr $

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
        PUTDEST_Loop

NEG_ADC_SBC_TST
;TODO
c0064_MFPI_MTPI_SXT
;TODO
CLRB_COMB_INCB_DECB
;TODO
NEGB_ADCB_SBCB_TSTB
;TODO
RORB_ROLB_ASRB_ASLB
;TODO
MTPS_MFPD_MTPD_MFPS
;TODO
        jr $

SWABer
;TODO
        jr $

