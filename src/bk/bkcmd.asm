PANIC
 if debug_stop = 0
 _Loop_
 else
 jr $
 endif

MOVer
;TODO
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
        jp z,recodePCLoop ;de=new PC
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
        ld l,a
        ld h,_R0/256
       push hl
        ld c,(hl)
        inc l
        ld b,(hl) ;bc=link
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
       _LoopC_JP
