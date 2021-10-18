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
        ld a,c ;GETDEST8_cmdc ;сначала читаем, потом обнуляем? не может ни на что повлиять?
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
        ld a,c ;GETDEST_cmdc ;сначала читаем, потом обнуляем? не может ни на что повлиять?
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
        ;jr $
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
       push bc ;src
        GETDEST_cmda_autoinc
       ; ld h,b
       ; ld l,c
       ;pop bc ;hl=dest, bc=src
       pop hl ;hl=src, bc=dest
        ex af,af' ;'
        or a
        sbc hl,bc
        ;ccf
        ex af,af' ;'
       _LoopC

BITer
;ac=cmd
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrcop ;out: bc=sourceop, a=cmdLSB
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
        call rdsrc8op ;out: bc=sourceop, a=cmdLSB
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
      if CRUTCH
      and 0x3f
      ;cp 0xe0
      cp 0x08
      jr nc,MOVB_minusr0 ;любая адресация, кроме простого Rn
      endif
        PUTDEST_Loop ;for textshow
MOVB_minusr0
        PUTDEST8_Loop

CMPBer
;ac=cmd
        call rdsrc8op ;out: bc=sourceop, a=cmdLSB
       push bc
        GETDEST8_cmda_autoinc
       pop hl
        ex af,af' ;'
        ld a,l;c
        sub c;l
        ld c,a
        ;ccf
        ex af,af' ;'
       _LoopC

BITBer
;ac=cmd
        call rdsrc8op ;out: bc=sourceop, a=cmdLSB
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
        call rdsrc8op ;out: bc=sourceop, a=cmdLSB
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
        call rdsrc8op ;out: bc=sourceop, a=cmdLSB
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
       if 0 ;не помогло для nocopper, вообще исчезла надпись
       ld h,a
       ld a,c
       rla
       sbc a,a
       ld b,a
       ld a,h
       PUTDEST_Loop
       else
        PUTDEST8_Loop
       endif

CALLer_relative
       push hl
        ld c,(hl)
        inc l
        ld b,(hl) ;bc=link
       ;inc bc
       ;inc bc
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
        jr CALLer_q

CALLer
;jsr link, addr работает так: mov link=>-(sp);mov pc=>link; mov addr=>pc
        rra
        ld a,c
        rra
        and 0xe0
       cp 0xe0
       jr z,CALLerPC
       rrca
       rrca
       rrca
       rrca
;TODO test
       ;jr $
;leopol(0da4): 091f = 004437 = jsr R4, @#sub_110346
;абсолютный call
;0 000 100 lnk 011 111
          ;src ;@(Rn)+ ;dst

;pacman(10c6): 0937 = 004467 = jsr r4,...
;относительный call
;0 000 100 lnk 110 rrr
          ;src ;@X(rn) ;dst
        ld l,a
        ld h,_R0/256       

        ld a,c
        and 0x38
      jp z,JMPer_error
       cp 0x30
       jr z,CALLer_relative
        cp 0x18
        jr nz,$
        
       push hl
        ld c,(hl)
        inc l
        ld b,(hl) ;bc=link
       ;inc bc
       ;inc bc
        putmemspBC
        
        get
        next
        ld c,a
        get
        next
        ld b,a ;bc=X

        decodePC
        ;ld a,e
        ;add a,c
        ;ld c,a
        ;ld a,d
        ;adc a,b
        ;ld b,a ;bc=pc+X
CALLer_q
       pop hl
        ld (hl),e
        inc l
        ld (hl),d
bctoPCLoop
        ld d,b
        ld e,c
loopcjp
       _LoopC_JP

;09f7 - относительный call
;0000 1001 1111 0111
;0 000 100 111 110 111<-link
          ;src ;X(rn) ;dst
;09df - абсолютный call
;0000 1001 1101 1111
;0 000 100 111 011 111<-link
          ;src ;@(Rn)+ ;dst
CALLerPC
;jsr PC, addr работает так: mov PC=>-(sp);mov addr=>pc
       ld a,c
       push af
       sub 0xc8
       cp 8
       jr c,CALLerPC_rn ;call (r1) = 04711 = 09c9
        decodePC_to_ae
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
       pop af
       cp 0xdf
       jp z,bctoPCLoop
      if DEBUG
       cp 0xf7
       jr nz,$
      endif
        decodePC
        ld a,e
        add a,c
        ld e,a
        ld a,d
        adc a,b
        ld d,a ;bc=pc+X
       _LoopC_JP

CALLerPC_rn ;call (r1) = 04711 = 09c9
        decodePC_to_ae
        ld b,a
        ld c,e ;bc=link
        putmemspBC
       pop af
        and 7
        add a,a
        ld l,a
        ld h,_R0/256
        ld e,(hl)
        inc l
        ld d,(hl)
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
BGTer ;Branch if greater than (Z v (N (+) V)) = 0
;for pipedoc
        ex af,af' ;'
       jr z,exanoBR
        ex af,af' ;'
BGEer ;Branch if greater than or equal (N (+) V) = 0
;for ninza, leopol
        ex af,af' ;'
       jp pe,BGEoverflow
       jp p,exaBR
exanoBR
        ex af,af' ;'
       _LoopC
BGEoverflow
BLTnooverflow
       jp m,exaBR
        ex af,af' ;'
       _LoopC
BLEer ;Branch if less than or equal (Z v (N (+) V)) = 1
        ex af,af' ;'
       jr z,exaBR
        ex af,af' ;'
BLTer ;Branch if less than (N (+) V) = 1
;for digger, leopol
        ex af,af' ;'
       jp po,BLTnooverflow
       jp p,exaBR
        ex af,af' ;'
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
        jp nc,exaBR
        ex af,af' ;'
       _LoopC
BCSer ;BCS or BLO	Branch if carry set, or Branch if lower C = 1
        ex af,af' ;'
        jp c,exaBR
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
        jp c,c0002_0003
        jp m,JMPer;c0001
;000000	HALT
;000001	WAIT
;000002	RTI	Return from interrupt: PC < (SP)+; PS < (SP)+
;000003	BPT	Breakpoint trap: -(SP) < PS; -(SP) < PC; PC < (14); PS < (16)
;000004	IOT	I/O trap: -(SP) < PS; -(SP) < PC; PC < (20); PS < (22)
;000005	RESET
;000006	RTT	Return from trap: PC < (SP)+; PS < (SP)+
;TODO
        jr z,halter ;HALT
        cp 1*2
        jp z,WAITer ;WAIT ;for cputest, hny2020? программа не работает
        cp 2*2
        jr z,RTIer ;for movblobs
        cp 4*2
        jp z,looper ;IOT
        cp 5*2
        jp z,looper ;RESET ;for pacman
        cp 6*2
        jr z,RTTer
        cp 15*2
        jp z,looper ;STEP ;for cputest
        jr $
RTIer
RTTer
        getmemspBC
       push bc
        getmemspBC
       pop de
       _LoopC_JP
WAITer
halter
wrmemrom_LoopC
;Команда 000000 – это HALT. Вызывает прерывание по 4-му вектору. Когда встречается Halt, нужно положить в стек слово состояния процессора и адрес, следующий за командой HALT. Затем перейти по адресу, который записан в ячейке 4. При этом слово состояния процессора взять из ячейки 6.
        call getflags_bc
        putmemspBC
       decodePC_to_ae
        LD b,a
        ld c,e ;=old PC
        putmemspBC
        ld bc,6
        call rdmem_bc_to_bc
        call makeflags_frombc
        ld bc,4
        call rdmem_bc_to_bc
        jp bctoPCLoop 
      
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
looper
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
       ;jr $
;TODO test ;leopol(90f0=110360): 0084 = 000204 = rts r4
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
;почему jmp (r3) с адресацией (Rn) работает как jmp r3? (cputest 0x0258 -> 0x3dc8)
;jmp X(pc) работает как jmp pc+x (cputest 0x3dfc)
       ld a,c
       and 0x38
       ;cp 0x00
       ;jr z,JMPer_000
      jp z,JMPer_error
       cp 0x08
       jr z,JMPer_001
       cp 0x10
       jp z,JMPer_010
       cp 0x18
       jr z,JMPer_011
       cp 0x30
       jp z,JMPer_110
       jr $
;дальше неправильно общий случай (надо переходить без лишнего чтения памяти!)
        GETDEST_cmdc_autoinc ;call rdsrcop ;out: bc=sourceop, a=cmdLSB
        ld d,b
        ld e,c
       _LoopC_JP
JMPer_000 ;pc=rn ;for cputest
JMPer_001 ;pc=rn
        ld a,c
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        ld e,(hl)
        inc l
        ld d,(hl)
       _LoopC_JP
JMPer_010 ;pc=rn++
        ld a,c
        rla
        and 0x0e
        ld l,a ;0000rrr0
        ld h,_R0/256
        ld e,(hl)
        inc l
        ld d,(hl)
       inc de
       inc de
        ld (hl),d
        dec l
        ld (hl),e
       dec de
       dec de
       _LoopC_JP
JMPer_011 ;pc=(Rn++)
        ld a,c
        rla
        and 0x0e
       cp 0x0e
       jr z,JMPer_011_pc ;pc=(pc++)
        ld l,a ;0000rrr0
        ld h,_R0/256
        ld e,(hl)
        inc l
        ld d,(hl)
        ex de,hl
        ld a,h
        and 0xc0
	ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
        ld e,(hl)
        inc l
        call z,inchnextpg
        ld d,(hl)
       _LoopC_JP
JMPer_011_pc ;pc=(pc++)
        get
        next
        ld c,a
        get
        next
        ld d,a
        ld e,c
       _LoopC_JP
JMPer_110 ;pc=rn+x
        ld a,c
        rla
        and 0x0e
       cp 0x0e
       jr z,JMPer_110_pc
        ld l,a ;0000rrr0
        ld h,_R0/256
        get
        next
        add a,(hl)
        ld c,a
        get
        ;next
        inc l
        adc a,(hl)
        ld d,a
        ld e,c
       _LoopC_JP
JMPer_110_pc ;pc=pc+x
        get
        next
        ld c,a
        get
        next
        ld b,a
       decodePC_to_ae
        ld h,a
       ld a,c
       add a,e
       ld e,a
       ld a,b
       adc a,h ;ac=pc+X
       ld d,a
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
        ld a,c
        add a,a
        jp m,MFPI_SXT
;c0064_MTPI
        jr nc,$
;MTPIer ;Move to previous I space: Dest < (SP)+
        ld hl,(_R6)
        inc hl
        inc hl
        ld (_R6),hl
        dec hl
        dec hl
        PUTDEST_Loop
MFPI_SXT
        jr c,SXTer
;MFPIer ;Move from previous I space: ?(SP) < Src
        GETDEST_cmdc_autoinc
        ld hl,(_R6)
        dec hl
        dec hl
        ld (_R6),hl
        WRMEM_hl_LoopC
SXTer ;Sign extend: if N flag ? 0 then Dest < -1 else Dest < 0
        ex af,af' ;'
        ld bc,0
        jp p,$+3+1
        dec bc
        ex af,af' ;'
        PUTDEST_Loop

MTPS_MFPD_MTPD_MFPS
        ld a,c
        add a,a
        jp m,MFPD_MFPS
;MTPS_MTPD
        jr c,MTPDer
;MTPSer ;Move to PSW: PSW < Src
        GETDEST_cmdc_autoinc
        call makeflags_frombc
       _LoopC
MTPDer ;Move to previous D space: Dest < (SP)+
        ld hl,(_R6)
        inc hl
        inc hl
        ld (_R6),hl
        dec hl
        dec hl
        PUTDEST_Loop

MFPD_MFPS
        jr c,MFPDer
;MFPSer ;Move from PSW: Dest < PSW
       ld a,c
       push af
        call getflags_bc
       pop af
        PUTDEST_Loop
MFPDer ;Move from previous D space: ?(SP) < Src
        GETDEST_cmdc_autoinc
        ld hl,(_R6)
        dec hl
        dec hl
        ld (_R6),hl
        WRMEM_hl_LoopC
        
MULer
        jr $
DIVer
        jr $
ASHer
        jr $
ASHCer
        jr $

SWABer
;Z,N по мл. байту результата, C,V сбросить
        GETDEST_cmdc
        ld h,b
        ld b,c
        ld c,h
       ex af,af' ;'
        ld a,c
        inc a
        dec a
        scf
        ccf
       ex af,af' ;'
        PUTDEST_Loop

EMTer_q
       _LoopC
EMTer
;TODO убрать ловушки
       ld a,c
       cp 0x18 ;draw pixel (БК-0010)
       jp z,EMT_drawpixelR1R2
       cp 0x3b ;draw pixel (БК-0011)
       jp z,EMT_drawpixelR0R1
       cp 0x39 ;get color (БК-0011)
       jp z,EMT_getcolor
       cp 0x0e ;set color (БК-0010) ;pentis, mona
       jp z,EMT_setcolor
       cp 0x38 ;set color (БК-0011)
       jp z,EMT_setcolor
     if 1
       cp 0x06
       jp z,EMT_readkbd
        cp 0x0c ;bubbler,mona,cputest ;EMT 14 - инициализация экрана и установка всех векторов прерывания;
        jp z,EMT_cls
        cp 0x16 ;bubbler ;EMT 26 - получение координат курсора: R1 = X, R2 = Y;
        jp z,GETXYer
        cp 0x14 ;labyrinh ;EMT 24 - установка курсора по координатам X = R1, Y = R2;
        jp z,SETXYer
        cp 0x10 ;labyrinh,cputest ;EMT 20 - вывод строки; вход: R1 - адрес строки; R2 - длина строки в младшем байте; символ-ограничитель в старшем байте;
        jp z,PRSTRINGer
        cp 0x1a ;labyrinh после вывода пикселя
        jr z,EMTer_q
        cp 0x12 ;packmanria ;EMT 22 - вывод символа в служебную строку; вход: R0 - код символа (0 - очистка строки); R1 - номер позиции в служебной строке;
        jr z,EMTer_q
        cp 0x1c ;pentis ;EMT 34 - получение в R0 слова состояния дисплея, в котором каждый разряд является индикатором включения соответствующего режима (табл. 15): 0 - выключено, 1 - включено;
        jr z,EMTer_q
         or a
         jr z,EMTer_q ;metaballs11, cafelogo256
         cp 0x29
         jr z,EMTer_q ;metaballs11
         cp 0x32
         jr z,EMTer_q ;road2cafe
         cp 0x2f
         jr z,EMTer_q ;road2cafe
         cp 0x33
         jr z,EMTer_q ;road2cafe
    endif
;Emulator trap: -(SP) < PS; -(SP) < PC; PC < (30); PS < (32)
        call getflags_bc
        putmemspBC
        decodePC_to_ae
        ld b,a
        ld c,e
        putmemspBC
        ld bc,0x1a ;032
        call rdmem_bc_to_bc
        call makeflags_frombc
        ld bc,0x18 ;030
        call rdmem_bc_to_bc
        ld d,b
        ld e,c
       _LoopC_JP
EMT_readkbd
;EMT 6 - чтение кода символа с клавиатуры (выходной параметр - код нажатой клавиши в R0)
        ;ld a,55+128 ;"or a"
        ;ld (iskeymessage),a ;no message
        ld a,(bk_curkey) ;TODO правильно сделать ожидание?
        or a
        jr z,EMT_readkbd
        ld c,a
        ld b,0
        ld (_R0),bc
        ;ld a,55 ;"scf"
        ;ld (iskeymessage),a ;message
        xor a
        ld (bk_curkey),a ;no message (INT прочитает новую кнопку)
       _LoopC

EMT_drawpixelR0R1
        ld hl,(_R1) ;y
        ld bc,(_R0) ;x
        jr EMT_drawpixel_go
EMT_drawpixelR1R2
        ld hl,(_R2) ;y
        ld bc,(_R1) ;x
EMT_drawpixel_go
       ld a,h
       or a
       jr nz,emt_drawpixel_q
        ld h,l
        ld l,0
        srl h
        rr l
        srl h
        rr l ;y*64
       push bc
        ld b,0
        srl c
        srl c ;x/4
        add hl,bc
        ld a,(tpgs+0x40)
	set 7,h
        set 6,h
	SETPGC000
       pop bc
        ld a,c
        cpl
        ld c,3
        and c;3
        inc a
        ld b,a
bk_curcolor_recoded=$+1
        ld a,0 ;0..3
rollcolor0
        rrc c
        rrc c ;mask
        rrca
        rrca ;pixel
        djnz rollcolor0
        xor (hl)
        and c
        xor (hl)
        ld (hl),a
        ld c,a
        call putscreen_c
emt_drawpixel_q
       _LoopC
EMT_getcolor
bk_curcolor=$+1
        ld hl,0
        ld (_R0),hl
       _LoopC
EMT_setcolor
        ld hl,(_R0) ;ascii code
        ld (bk_curcolor),hl
        ld a,l
       dec a
       cpl
        and 3
        ld (bk_curcolor_recoded),a
       _LoopC

EMT_cls
        push de
        call cls_bk
        call cls_for_curgfxmode
       ld hl,0x0200
       ld (intcursorposition),hl
        pop de
       _LoopC

cls_for_curgfxmode
        ld a,(user_scr0_high) ;ok
       call clpga
curgfxmode=$+1
        ld a,0
        or a
        ret z ;не чистим атрибут, если mono (он установлен в setgfxmode)
        ld a,(user_scr0_low) ;ok
       jp clpga

redraw_for_curgfxmode
        ld bc,0x4000
redraw_for_curgfxmode0
        push bc
        call rdmem_bc_to_bc ;TODO optimize
        pop hl
        push hl
        call putscreen_c
        pop hl
        push hl
        inc hl
        ld c,b
        call putscreen_c
        pop bc
        inc bc
        bit 7,b
        jr z,redraw_for_curgfxmode0
        ret

;EMT 26 - получение координат курсора: R1 = X, R2 = Y;
GETXYer
       ld hl,(intcursorposition)
       ld a,h
       sub 5
       ld h,0
        ld (_R1),hl
       ld l,a
        ld (_R2),hl
       _LoopC
;EMT 24 - установка курсора по координатам X = R1, Y = R2;
SETXYer
        ld hl,(_R1)
        ld a,(_R2)
       add a,5 ;для Labyrinh и первого экрана klad, но потом в klad неправильно печатается счёт!
        ld h,a
       ld (intcursorposition),hl
       _LoopC


PRSTRINGer
;EMT 20 - вывод строки; вход: R1 - адрес строки; R2 - длина строки в младшем байте; символ-ограничитель в старшем байте
;TODO в cputest байты в начале:
;232 233 224 236 221 234
;9a 9b 94 9e 91 9c
;232 переключение индикации курсора
;233 установка числа символов в строке 32/64 - получается 32 (параметра нет - почему?)
;221..224 управление яркостью: красный, зелёный, синий, чёрный
;236 установка режимов формирования индикаторов в служебной строке
;234 установка режима негативной индикации символов

;потом в тексте: 234 012 - вроде как ставит без инверсии
        ld hl,(_R2)
PRSTRINGer0
        ld bc,(_R1)
        push hl
        call rdmem_bc_to_bc
        ld hl,(_R1)
        inc hl
        ld (_R1),hl
        pop hl
        ld a,c
        cp h ;символ-ограничитель
        jr z,PRSTRINGerq
       cp 10
        jr z,PRSTRINGerLF
       cp 12
        jr z,PRSTRINGerCLS
       cp 7
       jr z,PRSTRINGer_skip ;TODO bell
       cp 0xa0
       jr nc,PRSTRINGer_noskip ;rus
       cp 0x80
       jr nc,PRSTRINGer_skip ;TODO
PRSTRINGer_noskip
        push hl
        ld h,tkoi/256
        ld l,a
        ld a,(hl)
        call prchar
        pop hl
PRSTRINGer_skip
       inc l
       dec l
       jr z,PRSTRINGer0 ;для CPUTEST L=0
        dec l
        jr nz,PRSTRINGer0 ;для всего остального
PRSTRINGerq
       _LoopC
       
PRSTRINGerLF
       ld bc,(intcursorposition)
       inc b ;TODO scroll?
       ld c,0
       ld (intcursorposition),bc
       jr PRSTRINGer_skip
PRSTRINGerCLS
        push hl
        push de
        call cls_bk
        call cls_for_curgfxmode
       ld hl,0x0200
       ld (intcursorposition),hl
        pop de
        pop hl
       jr PRSTRINGer_skip
       
       
prchar
;Писать символ и атрибут в текущей позиции курсора (zaxon, km, nstalker, pipes)
;Вход:
;BH = номер видео страницы
;AL = записываемый символ (ASCII код)
;CX = счетчик (сколько экземпляров символа записать)
;BL = видео атрибут (текстовый режим) или цвет (графический режим)
;Примечание:
;При записи с помощью этой функции курсор не сдвигается!
;В графических режимах не рекомендуется использовать значение CX, отличное от единицы, т.к. не везде правильно реализован повтор символа
;Если программа работает под управлением PTS-DOS, то значения в BH, BL и CX могут быть проигнорированны)
       push de
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font;0x1a6e+0xa000
        add hl,bc
        ld a,(tpgs+0x40) ;scr
        SETPGC000
       push hl
intcursorposition=$+1
        ld de,0x0200 ;bkscr=0x4000+(2*64*8)
        ld l,d ;y
        ld h,0
         ld d,h ;de=x
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;y*64
        add hl,hl
        add hl,hl
        add hl,hl ;y*64*8
         set 7,h
         set 6,h
        add hl,de
        add hl,de
       pop de ;gfx
       ;jr $
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ld bc,64
        add hl,bc
        call cgaput2bytes
        ;ld bc,80-0x2000
        ;add hl,bc
        ld hl,(intcursorposition)
        inc l
        ld a,l
        cp 32
        jr c,prchar_nonewline
        ld l,0
        inc h ;todo scroll?
prchar_nonewline
        ld (intcursorposition),hl
       pop de
        ret

cgaput2bytes
        ld a,(de)
        ld c,a
        xor a
        rl c
        rra
        rrca
        rl c
        rra
        rrca
        rl c
        rra
        rrca
        rl c
        rra
        ld b,a
        rrca
        or b
        ld (hl),a
       push bc
        ld c,a
        call putscreen_c
       pop bc
        
        inc l
        xor a
        rl c
        rra
        rrca
        rl c
        rra
        rrca
        rl c
        rra
        rrca
        rl c
        rra
        ld b,a
        rrca
        or b
        ld (hl),a
        ld c,a
        call putscreen_c

        dec l
        inc de
        ret


TRAPer
;General trap: -(SP) < PS; -(SP) < PC; PC < (34); PS < (36)
        call getflags_bc
        putmemspBC
        decodePC_to_ae
        ld b,a
        ld c,e
        putmemspBC
        ld bc,0x1e ;036
        call rdmem_bc_to_bc
        call makeflags_frombc
        ld bc,0x1c ;034
        call rdmem_bc_to_bc
        ld d,b
        ld e,c
       _LoopC_JP

FFFFer
;for Piramania
       _LoopC
