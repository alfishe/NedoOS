asmcmd
;de=cmd text
;hl=code generated ;out: after the code
;out: NZ=error
        ;ld de,asmtestcmd
        asmgetchar
        cp 'l'
        jp z,asmcmd_l
        cp 'c'
        jp z,asmcmd_c
        cp 'i'
        jp z,asmcmd_i
        cp 'd'
        jp z,asmcmd_d
        
        ret
        
asmcmd_c
;TODO call/cp/ccf/cpi*/cpd*
        asmnextchar ;eat
        asmgetchar

        ret
        
asmcmd_i
;TODO inc/in/ini*/ind*/im
        asmnextchar ;eat
        asmgetchar

        ret
        
asmcmd_dec_hz
        ld b,a
        ld a,c
        or 0xdd
        asmputbyte_a
        ld a,b
        add a,a ;(4..5)*8 + (0x50..0x70)*8
        add a,0x85 ;dec h/l
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_dec_rb
;dec r/hx/hy/lx/ly
        ld a,c ;reg
        add a,a
        add a,a
        jr c,asmcmd_dec_hz
        add a,a
        add a,0x05 ;dec r
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_d
;dec/di/daa
        asmnextchar ;eat
        asmgetchar
        cp 'e'
        jr z,asmcmd_de
        cp 'i'
        jr z,asmcmd_di
        MATCH 'a'
        MATCH 'a'
        asmputbyte 0x27 ;daa
        cp a ;Z
        ret
asmcmd_di
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xf3 ;di
        cp a ;Z
        ret
asmcmd_de
        asmnextchar ;eat
        asmgetchar
        MATCH 'c'
        MATCHSPACES
        cp '('
        jr z,asmcmd_dec_bracket
        cp '['|OR20FORBRACKETS
        jr z,asmcmd_dec_bracket
;dec r/rp/iz
        cp 'i'
        jr z,asmcmd_dec_i
        call matchrb_ora
        jr z,asmcmd_dec_rb
        call matchrp_orsp
        ret nz
        ld a,c ;0/0x10/0x20/0x30
        add a,0x0b ;dec rp
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_dec_i
;dec ix/iy
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_dec_ix
        cp 'y'
        ret nz
        asmputbyte 0xfd
        jr asmcmd_dec_hl
asmcmd_dec_ix
        asmputbyte 0xdd
asmcmd_dec_hl
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0x2b
        cp a ;Z
        ret

asmcmd_ldi_
;ldi/ldir
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_ldir
        asmputbyte 0xa0 ;ldi
        cp a ;Z
        ret
asmcmd_ldir
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xb0 ;ldir
        cp a ;Z
        ret
asmcmd_ldd_
;ldd/lddr
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_lddr
        asmputbyte 0xa8 ;ldd
        cp a ;Z
        ret
asmcmd_lddr
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xb8 ;lddr
        cp a ;Z
        ret

asmcmd_ld_reg_bracket_i
;b=reg*8+0x40
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_ld_reg_bracket_ix
        cp 'y'
        ;jr z,asmcmd_ld_reg_bracket_iy
        ret nz
;asmcmd_ld_reg_bracket_iy
        asmputbyte 0xfd
        jr asmcmd_ld_reg_bracket_iz
asmcmd_ld_reg_bracket_ix
        asmputbyte 0xdd
asmcmd_ld_reg_bracket_iz
;ld r,[iz+]
        ld a,b ;reg*8+0x40
        add a,6 ;ld r,[hl]
        asmputbyte_a
        jp asmcmd_anycmd_bracket_iz_bracket
asmcmd_inc_bracket
;inc [hl]/[iz+]
        ld b,0x34-6 ;b=reg*8+0x40 (к нему прибавляется 6, получается код команды)
        jr asmcmd_ld_reg_bracket
asmcmd_dec_bracket
;dec [hl]/[iz+]
        ld b,0x35-6 ;b=reg*8+0x40 (к нему прибавляется 6, получается код команды)
        ;jp asmcmd_ld_reg_bracket
asmcmd_ld_reg_bracket
;b=reg*8+0x40
;ld r,[hl]/[iz+]
        asmnextchar ;eat
        asmgetchar
        cp 'i'
        jr z,asmcmd_ld_reg_bracket_i
;ld r,[hl]
        MATCH 'h'
        MATCH 'l'
        MATCHCLOSEBRACKET_NOGET
        ld a,b ;reg*8+0x40
        add a,6 ;ld r,[hl]
        asmputbyte_a
        cp a ;Z
        ret
        
asmcmd_l
        asmnextchar ;eat
        asmgetchar
        MATCH 'd'
        cp 'i'
        jr z,asmcmd_ldi_
        cp 'd'
        jr z,asmcmd_ldd_
        MATCHSPACES
        cp 'a'
        jp z,asmcmd_ld_a
        cp '('
        jp z,asmcmd_ld_bracket
        cp '['|OR20FORBRACKETS
        jp z,asmcmd_ld_bracket
        cp 'h'
        jr z,asmcmd_ld_h
        cp 'd'
        jr z,asmcmd_ld_d
        cp 'b'
        jr z,asmcmd_ld_b
        cp 'l'
        jp z,asmcmd_ld_l
        cp 'c'
        jr z,asmcmd_ld_c
        cp 'i'
        jp z,asmcmd_ld_i
        cp 's'
        jp z,asmcmd_ld_s
        cp 'r'
        jp z,asmcmd_ld_r
        cp 'e'
        ;jr z,asmcmd_ld_reg
        ret nz
        ld b,0x58;'e'
        jr asmcmd_ld_reg
asmcmd_ld_c
        ld b,0x48;'c'
asmcmd_ld_reg
        asmnextchar ;eat
        asmgetchar
asmcmd_ld_reg_gotnextchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp '('
        jp z,asmcmd_ld_reg_bracket
        cp '['|OR20FORBRACKETS
        jp z,asmcmd_ld_reg_bracket
        call matchrb
        jr nz,asmcmd_ld_reg_noreg
        ld a,c
        or a
        jp p,asmcmd_ld_reg_noindex
        or 0xdd ;c было 0x54/55(hx/lx)/74/75(hy/ly)
        asmputbyte_a
asmcmd_ld_reg_noindex
        ld a,b ;reg1*8
        add a,c ;reg2
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_ld_reg_noreg
        ld a,b ;reg1*8+0x40
        add a,6-0x40
        asmputbyte_a ;ld r8,i8
        asmgetchar
        call matchexpr
        ret nz
        asmputbyte_c
        cp a ;Z
        ret

asmcmd_ld_b
;b/bc
        asmnextchar ;eat
        asmgetchar
        cp 'c'
        ;jr z,asmcmd_ld_bc
        ld b,0x40;'b'
        jr nz,asmcmd_ld_reg_gotnextchar
;asmcmd_ld_bc
        ld bc,0x4b01 ;ld bc,(mm), ld bc,nn
        jr asmcmd_ld_rp_nn_bmm_cnn
asmcmd_ld_d
;d/de
        asmnextchar ;eat
        asmgetchar
        cp 'e'
        ;jr z,asmcmd_ld_de
        ld b,0x50;'d'
        jr nz,asmcmd_ld_reg_gotnextchar
;asmcmd_ld_de
        ld bc,0x5b11 ;ld de,(mm), ld de,nn
        jr asmcmd_ld_rp_nn_bmm_cnn
asmcmd_ld_h
;h/hl/hx/hy
        asmnextchar ;eat
        asmgetchar
        cp 'l'
        jp z,asmcmd_ld_hl
        ld b,0x60;'h'
        cp 'y'
        jr z,asmcmd_ld_hy
        cp 'x'
        ;jr z,asmcmd_ld_hx
        jr nz,asmcmd_ld_reg_gotnextchar
asmcmd_ld_hx
;ld hx,reg/n (reg!=h,l,hy,ly)
        asmputbyte 0xdd
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb
        jr nz,asmcmd_ld_reg_noreg;asmcmd_ld_hx_noreg
        ld a,c
        cp IYADD ;+4/5 = hy/ly
        ret nc ;nz (error)
        jr asmcmd_ld_hz_reg
        
asmcmd_ld_hy
;ld hy,reg/n (reg!=h,l,hx,lx)
        asmputbyte 0xfd
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb
        jr nz,asmcmd_ld_reg_noreg;asmcmd_ld_hx_noreg
        ld a,c
        and 0b00100111 ;hx,lx -> h,l
asmcmd_ld_hz_reg
        sub 4 ;4,5 = h,l
        cp 2
        ret c ;nz (error)
        ld a,c
        add a,b ;'h'*8
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_ld_l
;l/lx/ly
        asmnextchar ;eat
        asmgetchar
        ld b,0x68;'l'
        cp 'y'
        jr z,asmcmd_ld_hy;ly
        cp 'x'
        ;jr z,asmcmd_ld_lx
        jp nz,asmcmd_ld_reg_gotnextchar
        jr z,asmcmd_ld_hx;lx

asmcmd_ld_s
        asmnextchar ;eat
        asmgetchar
        cp 'p'
        ret nz
        ld bc,0x7b31 ;ld sp,(mm), ld sp,nn
asmcmd_ld_rp_nn_bmm_cnn
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp '('
        jr z,asmcmd_ld_sp_bracket
        cp '['|OR20FORBRACKETS
        jr z,asmcmd_ld_sp_bracket
        asmputbyte_c; 0x31 ;ld sp,nn
        jr asmmatchexpr_emitword_bc
asmcmd_ld_sp_bracket
        asmputbyte 0xed
        asmputbyte_b; 0x7b ;ld sp,(mm)
        jr asmmatchexpr_bracket_emitword_bc ;eats

asmcmd_ld_ix
;ld ix,nn/(mm)
        asmputbyte 0xdd
        ;jr asmcmd_ld_hl
asmcmd_ld_hl
;ld hl,nn/(mm)
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp '('
        jr z,asmcmd_ld_hl_bracket
        cp '['|OR20FORBRACKETS
        jr z,asmcmd_ld_hl_bracket
        asmputbyte 0x21 ;ld hl,nn
asmmatchexpr_emitword_bc
        call matchexpr
        ;jr z,asmputbc
        ret nz ;nz (error)
asmputbc
        asmputbyte_c
        asmputbyte_b
        cp a ;Z
        ret
asmcmd_ld_hl_bracket
        asmputbyte 0x2a ;ld hl,(mm)
asmmatchexpr_bracket_emitword_bc
        asmnextchar ;eat (
        asmgetchar
asmmatchexpr_bracket_emitword_bc_noeatopenbracket
        call matchexpr
        ret nz ;error
        CPCLOSEBRACKET_NOEAT
        ret nz
asmeat_putbc
        asmnextchar ;eat
        ;asmgetchar
        jr asmputbc

asmcmd_ld_bracket
;ld (rp),a/ld (hl),r/ld (iz+),r/ld (mm),a/rp/iz
        asmnextchar ;eat
        asmgetchar
        cp 'i'
        jr z,asmcmd_ld_bracket_i
        call matchrp
        jr z,asmcmd_ld_bracket_rp
asmcmd_ld_bracket_matchexpr
;ld (mm),a/hl/ix/iy/rp
        call matchexpr
        ret nz
        MATCHCLOSEBRACKET
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp 'a'
        jr z,asmcmd_ld_bracket_mm_bracket_comma_a
        cp 'i'
        jr z,asmcmd_ld_bracket_mm_bracket_comma_i
       push bc
        call matchrp       
        jr z,asmcmd_ld_bracket_mm_bracket_comma_rp
       pop bc
        ret ;nz (error)
asmcmd_ld_bracket_mm_bracket_comma_rp
;ld (mm),rp
        ld a,c
       pop bc
        cp 0x20
        jr z,asmcmd_ld_bracket_mm_bracket_comma_hl
        asmputbyte 0xed
        add a,0x43
        asmputbyte_a ;ld (),rp
        jr asmputbc
asmcmd_ld_bracket_mm_bracket_comma_hl
        asmputbyte 0x22 ;ld (),hl
        jr asmputbc
asmcmd_ld_bracket_mm_bracket_comma_i
;ld (mm),iz
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_ld_bracket_mm_bracket_comma_ix
        cp 'y'
        ;jr z,asmcmd_ld_bracket_mm_bracket_comma_iy
        ret nz
;asmcmd_ld_bracket_mm_bracket_comma_iy
        asmputbyte 0xfd
        jr asmcmd_ld_bracket_mm_bracket_comma_iz
asmcmd_ld_bracket_mm_bracket_comma_ix
        asmputbyte 0xdd
asmcmd_ld_bracket_mm_bracket_comma_iz
        asmputbyte 0x22 ;ld (),hl
        jr asmeat_putbc
asmcmd_ld_bracket_mm_bracket_comma_a
        asmputbyte 0x32 ;ld (),a
        jr asmeat_putbc
asmcmd_ld_bracket_i
;ld (iz+),r/return to ld (mm),a/rp/iz
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_ld_bracket_ix
        cp 'y'
        jr z,asmcmd_ld_bracket_iy
        asmbackchar
        jr asmcmd_ld_bracket_matchexpr
asmcmd_ld_bracket_rp
;ld (rp),a/ld (hl),r ;c=rp*0x10
        MATCHCLOSEBRACKET
        bit 5,c ;0x20
        jr nz,asmcmd_ld_bracket_hl_bracket
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCH_NOGET 'a'
        ld a,c
        add a,0x02
        asmputbyte_a ;ld (rp),a
        cp a ;Z
        ret
asmcmd_ld_bracket_hl_bracket
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb_ora
        jr nz,asmcmd_ld_bracket_hl_bracket_comma_noreg
        ld a,c
        ;cp 8
        ;ret c ;nz (error)
        add a,0x70
        ret m ;nz (error)
        asmputbyte_a ;ld (hl),r
        cp a ;Z
        ret
asmcmd_ld_bracket_hl_bracket_comma_noreg
        asmputbyte 0x36 ;ld (hl),i8
asmmatchexpr_putc
        call matchexpr
        ret nz
        asmputbyte_c
        cp a ;Z
        ret
asmcmd_ld_bracket_ix
        asmputbyte 0xdd
        jr asmcmd_ld_bracket_iz
asmcmd_ld_bracket_iy
        asmputbyte 0xfd
asmcmd_ld_bracket_iz
        asmnextchar ;eat
        asmgetchar
        MATCHBRACKET_OR_i8BRACKET
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        ld b,c
        call matchrb_ora
        jr nz,asmcmd_ld_bracket_iz_bracket_noreg
        ld a,c
        add a,0x70
        ret m ;nz (error)
        asmputbyte_a ;ld (hl),r
        asmputbyte_b ;shift
        cp a ;Z
        ret
asmcmd_ld_bracket_iz_bracket_noreg
        asmputbyte 0x36 ;ld (hl),i8
        asmputbyte_b ;shift
        jr asmmatchexpr_putc

asmcmd_ld_r
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCH_NOGET 'a'
        asmputbyte 0xed
        asmputbyte 0x4f ;ld r,a
        cp a ;Z
        ret

asmcmd_ld_a
;ld a,i/r/n/(/reg
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp '('
        jr z,asmcmd_ld_a_bracket
        cp '['|OR20FORBRACKETS
        jr z,asmcmd_ld_a_bracket
        cp 'i'
        jr z,asmcmd_ld_a_i
        cp 'r'
        jr z,asmcmd_ld_a_r
;ld a,reg/n
        call matchrb_ora
        jr z,asmcmd_ld_a_rb
        call matchexpr
        ret nz
        asmputbyte 0x3e ;ld a,n
        asmputbyte_c
        cp a ;Z
        ret
asmcmd_ld_a_rb
        ld a,c
        add a,0x78 ;ld a,rb
        asmputbyte_a
        cp a ;Z
        ret

asmcmd_ld_a_bracket
;ld a,(mm)/(rp)/(iz+)
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES
        cp 'i'
        jr z,asmcmd_ld_a_bracket_i
;ld a,(mm)/(rp)
        ;cp 'h'
        ;jr z,asmcmd_ld_a_bracket_h
        call matchrp ;c=rp*0x10
        jr nz,asmcmd_ld_a_bracket_norp
        ld a,c
        add a,0x0a
        cp 0x20 ;'hl'
        jr c,$+4
         ld a,0x7e
        asmputbyte_a ;ld a,(rp)
        cp a ;Z
        ret
asmcmd_ld_a_bracket_norp
;ld a,(mm)
        asmputbyte 0x3a ;ld a,(nn)
        jp asmmatchexpr_bracket_emitword_bc_noeatopenbracket
asmcmd_ld_a_bracket_i
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_ld_a_bracket_ix
        cp 'y'
        jr z,asmcmd_ld_a_bracket_iy
        call matchexpr
        ret nz
        asmputbyte 0x3a ;ld a,()
        asmputbyte_c
        asmputbyte_b
        ret
asmcmd_ld_a_bracket_ix
        asmputbyte 0xdd
        jr asmcmd_ld_a_bracket_iz
asmcmd_ld_a_bracket_iy
        asmputbyte 0xfd
asmcmd_ld_a_bracket_iz
;ld a,(ix/iy+/-/)
        asmputbyte 0x7e ;ld a,(hl)
asmcmd_anycmd_bracket_iz_bracket
        asmnextchar ;eat
        asmgetchar
        MATCHBRACKET_OR_i8BRACKET_NOGET
        asmputbyte_c
        cp a ;Z
        ret

asmcmd_ld_a_i
        ld c,0x57 ;ld a,i
        jr asmcmd_eat_put_ed_c
asmcmd_ld_a_r
        ld c,0x5f ;ld a,r
asmcmd_eat_put_ed_c
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xed
        asmputbyte_c ;0x5f ;ld a,r
        cp a ;Z
        ret

asmcmd_ld_i
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        cp ','
        jr z,asmcmd_ld_i_comma
        cp 'x'
        ld c,0xdd
        jp z,asmcmd_ld_ix
        cp 'y'
        ;jr z,asmcmd_ld_iy
        ret nz
        asmputbyte 0xfd
        jp asmcmd_ld_hl
        
asmcmd_ld_i_comma
        asmnextchar ;eat
        asmgetchar
        MATCH_NOGET 'a'
        asmputbyte 0xed
        asmputbyte 0x47 ;ld i,a
        cp a ;Z
        ret
        
;asmtestcmd
;        db "ld a,5",0
