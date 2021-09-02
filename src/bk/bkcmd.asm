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


;TODO subroutine
        ld a,b
        rra
        ld a,c
        rra ;rrr?????
         rra
         rra
         rra
         rra
         and 0x0e
        ld l,a
        ld h,_R0/256
         ;ld l,(hl)
;0000rrr0
         ld a,c
        ld c,(hl)
        inc l
        ld b,(hl)
        
        
        
        rla
         and 0x0e
        ld l,a
       push de
        ld e,(hl)
        inc l
        ld d,(hl)
        ex de,hl
        ex af,af' ;'
        add hl,bc
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

recodePCLoop
;de=new PC
       pop af ;ignore
       _LoopC_JP

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

