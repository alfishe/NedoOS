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
;TODO

;15c1, 4000 ;mov #40000,r1
;0001 0101 1100 0001
;0 001 010 111 000 001
     ;(Rn)+;r7 ;rn;r1
        ld b,a
;bc=cmd
        call readsourceop ;out: bc=sourceop, a=cmdLSB

        rla
         and 0x0e
        ld l,a
        ld h,_R0/256
        ex af,af' ;'
        ;TODO сбросить V
        ex af,af' ;'
        ld (hl),c
        ld a,l
        inc l
        ld (hl),b
        cp 0x0e
        jp z,recodePCLoop ;de=new PC
       _LoopC

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
        ld b,a
;TODO

;15-12 Opcode
;11-9 Src
;8-6 Register
;5-3 Dest
;2-0 Register

;0n	Register	Rn	The operand is in Rn
;1n	Register deferred	(Rn)	Rn contains the address of the operand
;2n	Autoincrement	(Rn)+	Rn contains the address of the operand, then increment Rn
;3n	Autoincrement deferred	@(Rn)+	Rn contains the address of the address of the operand, then increment Rn by 2
;4n	Autodecrement	?(Rn)	Decrement Rn, then use the result as the address of the operand
;5n	Autodecrement deferred	@?(Rn)	Decrement Rn by 2, then use the result as the address of the address of the operand
;6n	Index	X(Rn)	Rn+X is the address of the operand
;7n	Index deferred	@X(Rn)	Rn+X is the address of the address of the operand

ADDregreg

;bc=cmd
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



BRer
;TODO
       _LoopC
BNEer
;TODO
       _LoopC
BEQer
;TODO
       _LoopC
BGEer
;TODO
       _LoopC
BLTer
;TODO
       _LoopC
BGTer
;TODO
       _LoopC
BLEer
;TODO
       _LoopC
BPLer
;TODO
       _LoopC
BMIer
;TODO
       _LoopC
BHIer
;TODO
       _LoopC
BLOSer
;TODO
       _LoopC
BVCer
;TODO
       _LoopC
BVSer
;TODO
       _LoopC
BCCer ;BCC or BHIS	Branch if carry clear, or Branch if higher or same C = 0
;TODO
       _LoopC
BCSer ;BCS or BLO	Branch if carry set, or Branch if lower C = 1
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
;TODO

        decodePC
        
        ld a,e
        add a,c
        ld e,a
        ld a,d
        adc a,b
        ld d,a ;bc=pc+X
       _LoopC_JP

RTI_JMP_RTS_SWAB
;TODO
NEG_ADC_SBC_TST
;TODO
ROR_ROL_ASR_ASL
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
        jp PANIC
