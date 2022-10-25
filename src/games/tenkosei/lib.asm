calc_next_v_addr:
        LD  A,H
        XOR 0x40
        BIT 6,H
        LD  H,A
        ret z   ;JR Z,.nxsQ
        LD  A,H
        XOR 0x20
        BIT 5,H
        LD  H,A
        ret z   ;JR Z,.nxsQ
        INC HL 
.nxsQ:
        ret


;--------------------------------------------------

src_mem_buf_calc:
        bit 6,h
        jr z,.l1   ;0x8000-0xa00 range, set membuf1

        ;range is 0xc000 - 0xe00
        ;modif to match 0x8000 - 0xa000 range
        ;set membuf2

        ld a,h
        and 0b10111111
        ld h,a
        ld a,(mem_buf2)
        jr .l2

.l1:
        ;0x8000-0xa00 range, set membuf1
        ld a,(mem_buf1)
.l2:        
        push hl
        SETPG8000
        pop hl
        ret
;-------

src_mem_buf2_calc:
        bit 6,h
        jr z,.l1   ;0x8000-0xa00 range, set membuf1

        ;range is 0xc000 - 0xe00
        ;modif to match 0x8000 - 0xa000 range
        ;set membuf2

        ld a,h
        and 0b10111111
        ld h,a
        ld a,(mem_buf4)
        jr .l2

.l1:
        ;0x8000-0xa00 range, set membuf1
        ld a,(mem_buf3)
.l2:        
        push hl
        SETPG8000
        pop hl
        ret
;-------
dest_scr_calc:
        ;hl to 0xc000 range with set scr high / low

        bit 6,h
        jr z,.l1   ;0x8000-0xa00 range, set membuf1

        ;range is 0xc000 - 0xe00
        ;set scr high
        push hl
        call set_scr_high
        jr .l2

.l1:
        ;0x8000-0xa00 range, set membuf1

        ld a,h
        add a,0x40  ;0x8000 to 0xc000 conversion
        ld h,a
        push hl
        call set_scr_low
        
.l2:        
        pop hl
        ret    
;----------------------