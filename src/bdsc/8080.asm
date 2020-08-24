        macro sta addr
        ld (addr),a ;ok
        endm
        
        macro lda addr
        ld a,(addr) ;ok
        endm
        
        macro shld addr
        ld (addr),hl ;ok
        endm
        
        macro lhld addr
        ld hl,(addr) ;ok
        endm
        