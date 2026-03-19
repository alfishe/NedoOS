;==============================================================        
disable_anim:
        ;swith off animations
        xor a
        ld (alock),a
        ret   

disable_anim_switches:
        ld b,16
        ld hl,anim_switches
.aaf    ld (hl),0
        inc hl
        djnz .aaf
        ret
clear_anim_stack:
        ;clear animations stack
        ld hl,anim_stack
        ld de,anim_stack+1
        ld (hl),0xff
        ld bc,1023
        ldir

        ld hl,nameslots_tbl_bk
        ld de,nameslots_tbl
        ld bc,nameslots_tbl_bke-nameslots_tbl_bk
        ldir
        ret 



store_name:
        push hl
        ld hl,namebuf
        ld de,namebuf+1
        ld bc,13
        ld (hl),0
        ldir
        pop hl
;        push hl
        ld de,namebuf
        call copystr_hlde
;        pop hl
        push hl,de,bc
        ld hl,namebuf
        ld de,namesslot_temp
        ld bc,4
        ldir
        pop bc,de,hl
        ret        





cmpr_dehl:
        ld a,(de)
        and a
        ret z   ;string fully equally and dtring in de not begin from 0

        cpi
        ret nz
        inc de
        jr cmpr_dehl

C_Time_D:
;Outputs:
;     A is the result
;     B is 0
     ld b,8          ;7           7
     xor a           ;4           4
       rlca          ;4*8        32
       rlc c         ;8*8        64
       jr nc,$+3     ;(12|11)    96|88
         add a,d     ;--
       djnz $-6      ;13*7+8     99
     ret             ;10         10



;___________________________________
;A15	A14	A13	A12	A11	A10	 A9	 A8
; G0	 R0	 B0	 G1	 1	 1	 R1	 B1
	      	
; D7	 D6	 D5	 D4	 D3	 D2	 D1	 D0
; G2	 R2	 B2	 G3	 1	 1	 R3	 B3
palette_precalc:
                call setcorepage
                        call palette_precalc_sub
                jp unsetcorepage



fade_toblack:
        ;dec lx
        ld hl,0x2ddd
        xor a
        jr fade_to
fade_towhite:
        ;inc lx
        ld a,15
        ld hl,0x2cdd
fade_to:        
        call setcorepage
                call fade_to_sub
        jp unsetcorepage


fade_fromblack:
        ;inc lx
        ld hl,0x2cdd
        xor a
        jr fade_from
fade_fromwhite:
        ;dec lx
        ld a,15
        ld hl,0x2ddd
fade_from:
        call setcorepage
                call fade_from_sub
        jp unsetcorepage



