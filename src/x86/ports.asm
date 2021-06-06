;in al,0x40          ; Read timer counter 0 
INali8
        get
        next
        ld c,a
        ld b,0
INal_bc
        call IN_bc_to_bc
        ld a,c
	ld (_AL),a
       _Loop_
INaldx
        ld bc,(_DX)
        jr INal_bc

INaxi8
        get
        next
        ld c,a
        ld b,0
INax_bc
        call IN_bc_to_bc
	ld (_AL),bc
       _Loop_
INaxdx
        ld bc,(_DX)
        jr INax_bc

OUTi8al
        get
        next
        ld c,a
        ld b,0
        ld hl,(_AL)
        call OUTbc_l
        _LoopC
OUTi8ax
        get
        next
        ld c,a
        ld b,0
        ld hl,(_AX)
        call OUTbc_hl
        _LoopC
OUTdxal
        ld bc,(_DX)
        ld hl,(_AL)
        call OUTbc_l
        _LoopC
OUTdxax
        ld bc,(_DX)
        ld hl,(_AX)
        call OUTbc_hl
        _LoopC

OUTbc_hl
        ret
OUTbc_l
        ret

IN_bc_to_bc
        ld hl,0x0040
        or a
        sbc hl,bc
        jr nz,IN_skip
	ld bc,(timer)
        ret
IN_skip
        ld bc,0xffff
        ret
