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
        cp 'a'
        jp z,asmcmd_a
        cp 'o'
        jp z,asmcmd_o
        cp 'x'
        jp z,asmcmd_x
        cp 's'
        jp z,asmcmd_s
        cp 'e'
        jp z,asmcmd_e
        cp 'b'
        jp z,asmcmd_b
        cp 'r'
        jp z,asmcmd_r
        
        ret

asmcmd_e
;ei/ex/exx
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_ex_
        MATCH 'i'
        asmputbyte 0xfb ;ei
        jp matchendword
asmcmd_ex_
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,asmcmd_exx
        MATCHSPACES
;ex de,hl/ex af,af'/ex (sp),hl/iz
        cp 'a'
        jr z,asmcmd_ex_a
        cp 'd'
        jr z,asmcmd_ex_d
        MATCHOPENBRACKET
        MATCH 's'
        MATCH 'p'
        MATCHCLOSEBRACKET
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        cp 'i'
        jr z,asmcmd_ex_bracket_sp_bracket_i
        MATCH 'h'
        MATCH_NOGET 'l'
asmcmd_ex_bracket_sp_bracket_hl
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xe3 ;ex (sp),hl
        jp matchendword
asmcmd_ex_bracket_sp_bracket_i
        asmnextchar ;eat
        asmgetchar
        MATCHXY_PUTDDFD_NOGET
        jr asmcmd_ex_bracket_sp_bracket_hl
asmcmd_ex_d
        asmnextchar ;eat
        asmgetchar
        MATCH 'e'
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCH 'h'
        MATCH_NOGET 'l'
        asmputbyte 0xeb ;ex de,hl
        cp a ;Z
        ret
asmcmd_exx
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xd9 ;exx
        jp matchendword
asmcmd_ex_a
        asmnextchar ;eat
        asmgetchar
        MATCH 'f'
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCH 'a'
        MATCH 'f'
        MATCH_NOGET 0x27 ;'
        asmputbyte 0x08 ;ex af,af'
        cp a ;Z
        ret

asmcmd_r
;ret/res/rl*/rlc*/rr*/rrc*/rst
        asmnextchar ;eat
        asmgetchar
        cp 'e'
        jr z,asmcmd_re_
        cp 'l'
        jr z,asmcmd_rl_
        cp 'r'
        jr z,asmcmd_rr_
        MATCH 's'
        MATCH 't'
        MATCHSPACES
        call matchexpr
        ret nz
        ld a,c
        or 0xc7
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_re_
        asmnextchar ;eat
        asmgetchar
        cp 't'
        jr z,asmcmd_ret
        MATCH_NOGET 's'
        ld lx,0x80 ;res base
        jp asmcmd_res
asmcmd_ret
        asmnextchar ;eat
        asmgetchar
        call matchspaces
        jr nz,asmcmd_ret_nocc
        call matchcc
        ld a,0xc0-0x20 ;ret cc
        jp z,asmcmd_putaplusc
asmcmd_ret_nocc
        asmputbyte 0xc9 ;ret
        cp a ;Z
        ret
        
asmcmd_rl_
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        jr z,asmcmd_rla
        cp 'c'
        ld b,0x10 ;rl base
        jr nz,asmcmd_anycbshift_noeat
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        ld b,0x00 ;rlc base
        jr nz,asmcmd_anycbshift_noeat
        asmputbyte 0x07 ;rlca
        cp a ;Z
        ret
asmcmd_rla
        asmputbyte 0x17 ;rla
        cp a ;Z
        ret
asmcmd_rr_
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        jr z,asmcmd_rra
        cp 'c'
        ld b,0x18 ;rr base
        jr nz,asmcmd_anycbshift_noeat
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        ld b,0x08 ;rrc base
        jr nz,asmcmd_anycbshift_noeat
        asmputbyte 0x0f ;rrca
        cp a ;Z
        ret
asmcmd_rra
        asmputbyte 0x1f ;rra
        cp a ;Z
        ret

asmcmd_s
;sub/sbc/scf/set/srl/sra/sla/sli
        asmnextchar ;eat
        asmgetchar
        cp 'u'
        jp z,asmcmd_su_
        cp 'b'
        jp z,asmcmd_sb_
        cp 'c'
        jr z,asmcmd_sc_
        cp 'e'
        jp z,asmcmd_se_
        cp 'r'
        jr z,asmcmd_sr_
        MATCH 'l'
        cp 'a'
        ld b,0x20 ;sla base
        jr z,asmcmd_anycbshift
        cp 'i'
        ret nz
        ld b,0x30 ;sli base
asmcmd_anycbshift
        asmnextchar ;eat
        asmgetchar
asmcmd_anycbshift_noeat
        MATCHSPACES
        call matchrb_ora
        jr nz,asmcmd_anycbshift_noreg
        asmputbyte 0xcb
        ld a,c
        cp 8
        jp c,asmcmd_putaplusb
        ret ;nz (error) if hx/hy/lx/ly

asmcmd_sc_
        asmnextchar ;eat
        asmgetchar
        MATCH 'f'
        asmputbyte 0x37 ;scf
        jp matchendword

asmcmd_sr_
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        ld b,0x28 ;sra base
        jr z,asmcmd_anycbshift
        cp 'l'
        ld b,0x38 ;srl base
        jr z,asmcmd_anycbshift
        ret ;nz (error)
asmcmd_anycbshift_bracket_i
        asmnextchar ;eat
        asmgetchar
        MATCHXY_PUTDDFD_NOGET
        asmnextchar ;eat
        asmputbyte 0xcb
        ld a,b ;anycbshift base
        add a,6 ;(hl)
       ex af,af' ;'
        asmgetchar
        call matchexpr
        ret nz
        MATCHCLOSEBRACKET_NOGET
        asmputbyte_c
       ex af,af' ;'
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_anycbshift_noreg
        MATCHOPENBRACKET
;[hl]/[iz+]
        cp 'i'
        jr z,asmcmd_anycbshift_bracket_i
        MATCH 'h'
        MATCH 'l'
        MATCHCLOSEBRACKET_NOGET
        asmputbyte 0xcb
        ld a,b ;anycbshift base
        add a,6 ;(hl)
        asmputbyte_a
        cp a ;Z
        ret

asmcmd_b
        ld lx,0x40 ;bit base
        asmnextchar ;eat
        asmgetchar
        cp 'i'
        jr z,asmcmd_bise
        ret ;nz (error)
asmcmd_se_
        ld lx,0xc0 ;set base
asmcmd_bise
        asmnextchar ;eat
        asmgetchar
        MATCH_NOGET 't'
asmcmd_res
        asmgetchar
        MATCHSPACES
        call matchexpr
        ret nz
        ld a,c
        and 7
        add a,a
        add a,a
        add a,a
        add a,lx ;base
        ld b,a
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb_ora
        jr nz,asmcmd_anycbshift_noreg;asmcmd_bitresset_noreg
        asmputbyte 0xcb
        bit 4,c
        jp z,asmcmd_putcand7plusb ;bit #
        ret ;nz (error) ;hx/lx/hy/ly

asmcmd_su_
        asmnextchar ;eat
        asmgetchar
        MATCH 'b'
        ld b,0x90 ;sub base
        jp asmcmd_ALU
asmcmd_sb_
        asmnextchar ;eat
        asmgetchar
        MATCH 'c'
        MATCHSPACES
        cp 'a'
        ld b,0x98 ;sbc a base
        jp z,asmcmd_aluop_a
        ld b,0x42 ;sbc hl,rp base
        jr asmcmd_adcsbc_hl

asmcmd_a
;add/adc/and
        asmnextchar ;eat
        asmgetchar
        cp 'd'
        jr z,asmcmd_ad_
        MATCH 'n'
        MATCH 'd'
        ld b,0xa0 ;and base
        jp asmcmd_ALU ;b=ALUop base
asmcmd_add_i
        asmnextchar ;eat
        asmgetchar
       ld c,a
        MATCHXY_PUTDDFD_NOGET
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
;add iz,rp/iz
        cp 'i'
        jr z,asmcmd_add_iz_comma_i
        call matchrp_orsp
        ret nz
        ld a,c
        cp 0x20 ;h
        jr nz,asmcmd_add_hl_rp
        or a ;nz (error)
        ret
asmcmd_add_iz_comma_i
        asmnextchar ;eat
        asmgetchar
       cp c
        ret nz ;nz (error)
        asmnextchar ;eat
        asmgetchar
        ;call matchendword
        ;ret nz
        asmputbyte 0x29 ;add hl,hl
        cp a ;Z
        ret
asmcmd_ad_
        asmnextchar ;eat
        asmgetchar
        cp 'd'
        jr z,asmcmd_add
        MATCH 'c'
        MATCHSPACES
        cp 'a'
        ld b,0x88 ;adc a base
        jr z,asmcmd_aluop_a
        ld b,0x4a ;adc hl,rp base
asmcmd_adcsbc_hl
        MATCH 'h'
        MATCH 'l'
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrp_orsp ;c=0/0x10/0x20/0x30 (bc/de/hl/sp)
        asmputbyte 0xed
        ld a,b
        jp asmcmd_putaplusc
asmcmd_add
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES
        cp 'a'
        ld b,0x80 ;add a base
        jr z,asmcmd_aluop_a
;add hl/iz
        cp 'i'
        jr z,asmcmd_add_i
        MATCH 'h'
        MATCH 'l'
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrp_orsp ;c=0/0x10/0x20/0x30 (bc/de/hl/sp)
asmcmd_add_hl_rp
        ld a,0x09 ;add hl,rp
        jp asmcmd_putaplusc
        ;add a,c
        ;asmputbyte_a ;add hl,rp
        ;cp a ;Z
        ;ret

;asmcmd_adc_a
        ;ld b,0x88 ;adc a base
        ;jr asmcmd_adx_a
;asmcmd_add_a
        ;ld b,0x80 ;add a base
asmcmd_aluop_a
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        jp asmcmd_ALU_nospaces ;b=ALUop base

asmcmd_out_bracket_c
        asmnextchar ;eat
        asmgetchar
        call matchendword_back1
        jr nz,asmcmd_out_expr
        MATCHCLOSEBRACKET
        MATCH ','
        asmputbyte 0xed
        cp '0'
        jr z,asmcmd_out_c_0
        call matchrb_ora        
        ld a,c ;reg
        add a,a
        add a,a
        add a,a
        ret m ;nz: индексный регистр - error
        add a,0x41 ;out (c),r
        asmputbyte_a
        cp a ;Z
        ret
        
asmcmd_out_c_0
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0x71 ;out (c),0
        jp matchendword
asmcmd_ou_
        asmnextchar ;eat
        asmgetchar
        MATCH 't'
        cp 'i'
        jr z,asmcmd_outi
        cp 'd'
        jr z,asmcmd_outd
        MATCHSPACES
;out (c),r/0/out (n),a
        MATCHOPENBRACKET
        cp 'c'
        jr z,asmcmd_out_bracket_c
asmcmd_out_expr
        call matchexpr
        ret nz
        MATCHCLOSEBRACKET
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCH 'a'
        asmputbyte 0xd3 ;out (n),a
        asmputbyte_c
        jp matchendword
        
asmcmd_outd
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        asmputbyte 0xab ;outd
        jp matchendword
asmcmd_outi
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        asmputbyte 0xa3 ;outi
        jp matchendword

asmcmd_o
;or/out*/ot*
        asmnextchar ;eat
        asmgetchar
        cp 'r'
        jr z,asmcmd_or
        cp 'u'
        jr z,asmcmd_ou_
        MATCH 't'
        asmputbyte 0xed
        cp 'i'
        jr z,asmcmd_oti_
        MATCH 'd'
        MATCH 'r'
        asmputbyte 0xbb ;otdr
        jp matchendword
asmcmd_oti_
        asmnextchar ;eat
        asmgetchar
        MATCH 'r'
        asmputbyte 0xb3 ;otir
        jp matchendword

asmcmd_or
        ld b,0xb0 ;or base
        asmnextchar ;eat
        asmgetchar
        jr asmcmd_ALU ;b=ALUop base

asmcmd_x
;xor
        asmnextchar ;eat
        asmgetchar
        MATCH 'o'
        MATCH 'r'
        ld b,0xa8 ;xor base
        jr asmcmd_ALU ;b=ALUop base

asmcmd_cp_
        asmnextchar ;eat
        asmgetchar
        cp 'i'
        jr z,asmcmd_cpi_
        cp 'd'
        jr z,asmcmd_cpd_
;cp r/i8/(hl)/(iz+)
        ld b,0xb8 ;cp base
asmcmd_ALU ;b=ALUop base
        MATCHSPACES
asmcmd_ALU_nospaces
;cp(ALUop) r/i8/(hl)/(iz+)
        call matchrb_ora
        jr nz,asmcmd_cp_noreg
        ld a,c ;reg
        cp 8
        jr c,asmcmd_putaplusb
        or 0xdd
        asmputbyte_a
asmcmd_putcand7plusb
        ld a,c ;reg(4/5)+0x50/0x70
        and 7
asmcmd_putaplusb
        add a,b ;ALUop base
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_cp_noreg
        ;cp '('
        ;jp z,asmcmd_ld_reg_bracket;asmcmd_cp_bracket
        ;cp '['|OR20FORBRACKETS
        ;jp z,asmcmd_ld_reg_bracket;asmcmd_cp_bracket
        CPOPENBRACKET_JP asmcmd_ld_reg_bracket
        ;ld c,a
        ld a,b
        add a,0xfe-0xb8
        asmputbyte_a ;cp i8
        asmgetchar;ld a,c
        jp asmmatchexpr_putc
asmcmd_cpi_
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_cpir
        asmputbyte 0xa1 ;cpi
        jp matchendword
asmcmd_cpir
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xb1 ;cpir
        jp matchendword
asmcmd_cpd_
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_cpdr
        asmputbyte 0xa9 ;cpd
        jp matchendword
asmcmd_cpdr
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xb9 ;cpdr
        jp matchendword

asmcmd_c
;call/cp/ccf/cpi*/cpd*
        asmnextchar ;eat
        asmgetchar
        cp 'a'
        jr z,asmcmd_ca_
        cp 'p'
        jr z,asmcmd_cp_
        MATCH 'c'
        MATCH_NOGET 'f'
        asmputbyte 0x3f ;ccf
        jp matchendword
asmcmd_ca_
        asmnextchar ;eat
        asmgetchar
        MATCH 'l'
        MATCH 'l'
        MATCHSPACES
        call matchcc
        jr z,asmcmd_callcc
        asmputbyte 0xcd ;call
        jp asmmatchexpr_emitword_bc        
asmcmd_callcc
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        ;ld b,a
        ld a,c ;0x20+cc*8
        add a,0xc4-0x20
        asmputbyte_a ;call cc
        asmgetchar;ld a,b
        jp asmmatchexpr_emitword_bc        
        
asmcmd_ini_
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_inir
        asmputbyte 0xa2 ;ini
        jp matchendword
asmcmd_inir
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xb2 ;inir
        jp matchendword
asmcmd_ind_
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_indr
        asmputbyte 0xaa ;ind
        jp matchendword
asmcmd_indr
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xba ;indr
        jp matchendword
asmcmd_i
;inc/in/ini*/ind*/im
        asmnextchar ;eat
        asmgetchar
        cp 'n'
        jr z,asmcmd_in_
        MATCH 'm'
        MATCHSPACES
        call matchexpr
        ret nz
        asmputbyte 0xed
        ld a,2
        sub c
        ret c ;nz
        dec a
        ld a,0x56
        jr z,asmcmd_im1
        ld a,0x5e
        jp m,asmcmd_im2
        ld a,0x46
asmcmd_im1
asmcmd_im2
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_inf
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        asmputbyte 0x70 ;inf
        jp matchendword
asmcmd_in_
        asmnextchar ;eat
        asmgetchar
        cp 'c'
        jr z,asmcmd_inc
        cp 'i'
        jr z,asmcmd_ini_
        cp 'd'
        jr z,asmcmd_ind_
        cp 'f'
        jr z,asmcmd_inf
;in r,(c)/in a,(i8)
        MATCHSPACES
        call matchrb_ora
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        MATCHOPENBRACKET
        cp 'c'
        jr z,asmcmd_in_bracket_c
asmcmd_in_expr
        ;ld b,a
        ld a,c
        cp 7
        ret nz
        asmgetchar;ld a,b
        call matchexpr
        ret nz
        MATCHCLOSEBRACKET_NOGET
        asmputbyte 0xdb ;in a,(n)
        asmputbyte_c
        cp a ;Z
        ret
asmcmd_in_bracket_c
        asmnextchar ;eat
        asmgetchar
        call matchendword_back1
        jr nz,asmcmd_in_expr
        MATCHCLOSEBRACKET_NOGET
        asmputbyte 0xed
        ld a,c ;reg
        add a,a
        add a,a
        add a,a
        ret m ;nz: индексный регистр - error
        add a,0x40
        asmputbyte_a ;in r,(c)
        cp a ;Z
        ret
asmcmd_inc
        asmnextchar ;eat
        asmgetchar
        ld b,0x34-6 ;b=reg*8+0x40 (к нему прибавляется 6, получается код команды)
        jr asmcmd_dec
        
asmcmd_dec_hz
;a=reg*4
        ld b,a
        ld a,c
        or 0xdd
        asmputbyte_a
        ld a,b
        add a,a ;(4..5)*8 + (0x50..0x70)*8
        add a,0x85-(0x35-6) ;dec h/l
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
        add a,0x05-(0x35-6) ;dec r
        jp asmcmd_putaplusb ;0x34-6=0x2e(inc)/0x35-6=0x2f(dec)
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
        ld b,0x35-6 ;b=reg*8+0x40 (к нему прибавляется 6, получается код команды)
asmcmd_dec
        MATCHSPACES
        cp 'i'
        jr z,asmcmd_dec_i
        ;cp '('
        ;jr z,asmcmd_ld_reg_bracket;asmcmd_dec_bracket
        ;cp '['|OR20FORBRACKETS
        ;jr z,asmcmd_ld_reg_bracket;asmcmd_dec_bracket
        CPOPENBRACKET_JR asmcmd_ld_reg_bracket
;dec r/rp
        call matchrb_ora
        jr z,asmcmd_dec_rb
        call matchrp_orsp
        ret nz
        ld a,0x03
        bit 0,b ;0x34-6=0x2e(inc)/0x35-6=0x2f(dec)
        jr z,$+4
        ld a,0x0b ;a=0x03(inc rp)/0x0b(dec rp)        
asmcmd_putaplusc
        add a,c ;0/0x10/0x20/0x30
        asmputbyte_a
        cp a ;Z
        ret
asmcmd_dec_i
;dec ix/iy
        asmnextchar ;eat
        asmgetchar
        MATCHXY_PUTDDFD_NOGET
        asmnextchar ;eat
        ;asmgetchar
        ld a,0x23
        bit 0,b ;0x34-6=0x2e(inc)/0x35-6=0x2f(dec)
        jr z,$+4
        ld a,0x2b ;a=0x23(inc)/0x2b(dec)
        asmputbyte a;0x2b ;dec hl
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
        jp matchendword
asmcmd_ldir
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xb0 ;ldir
        jp matchendword
asmcmd_ldd_
;ldd/lddr
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_lddr
        asmputbyte 0xa8 ;ldd
        jp matchendword
asmcmd_lddr
        asmnextchar ;eat
        ;asmgetchar
        asmputbyte 0xb8 ;lddr
        jp matchendword

asmcmd_ld_reg_bracket_i
;b=reg*8+0x40
        asmnextchar ;eat
        asmgetchar
        MATCHXY_PUTDDFD_NOGET
;ld r,[iz+]
        ld a,b ;reg*8+0x40
        add a,6 ;ld r,[hl]
        asmputbyte_a
        jp asmcmd_anycmd_bracket_iz_bracket
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
        ld a,6 ;ld r,[hl]
        jp asmcmd_putaplusb
        ;add a,b ;reg*8+0x40
        ;asmputbyte_a
        ;cp a ;Z
        ;ret
        
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
        ;cp '('
        ;jp z,asmcmd_ld_bracket
        ;cp '['|OR20FORBRACKETS
        ;jp z,asmcmd_ld_bracket
        CPOPENBRACKET_JP asmcmd_ld_bracket
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
        ld b,0x58;'e'
        jr z,asmcmd_ld_reg
        ret ;nz (error)
asmcmd_ld_c
        ld b,0x48;'c'
asmcmd_ld_reg
        asmnextchar ;eat
        asmgetchar
asmcmd_ld_reg_gotnextchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        ;cp '('
        ;jp z,asmcmd_ld_reg_bracket
        ;cp '['|OR20FORBRACKETS
        ;jp z,asmcmd_ld_reg_bracket
        CPOPENBRACKET_JP asmcmd_ld_reg_bracket
        call matchrb_ora
        jr nz,asmcmd_ld_reg_noreg
        ld a,c ;reg2
        cp 8
        jp c,asmcmd_putaplusb
        or 0xdd ;c было 0x54/55(hx/lx)/74/75(hy/ly)
        asmputbyte_a
        ld a,b
        cp 0x1f+0x40 ;b нельзя 'h','l','(hl)','a' - a тут не попадёт
        jp c,asmcmd_putcand7plusb
        ret ;nz (error)
asmcmd_ld_reg_noreg
        ld a,b ;reg1*8+0x40
        add a,6-0x40
        asmputbyte_a ;ld r8,i8
        asmgetchar
        jp asmmatchexpr_putc

asmcmd_ld_b
;b/bc
        asmnextchar ;eat
        asmgetchar
        cp 'c'
        ld b,0x40;'b'
        jr nz,asmcmd_ld_reg_gotnextchar
        ld bc,0x4b01 ;ld bc,(mm), ld bc,nn
        jr asmcmd_ld_rp_nn_bmm_cnn
asmcmd_ld_d
;d/de
        asmnextchar ;eat
        asmgetchar
        cp 'e'
        ld b,0x50;'d'
        jr nz,asmcmd_ld_reg_gotnextchar
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
        jr nz,asmcmd_ld_reg_gotnextchar
asmcmd_ld_hx
;ld hx,reg/n (reg!=h,l,hy,ly)
        asmputbyte 0xdd
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb_ora
        jr nz,asmcmd_ld_reg_noreg;asmcmd_ld_hx_noreg
        ld a,c
        cp IYADD ;+4/5 = hy/ly
        jr c,asmcmd_ld_hz_reg
        ret ;nz (error)
asmcmd_ld_l
;l/lx/ly
        asmnextchar ;eat
        asmgetchar
        ld b,0x68;'l'
        cp 'x'
        jr z,asmcmd_ld_hx;lx
        cp 'y'
        jp nz,asmcmd_ld_reg_gotnextchar
        ;jr z,asmcmd_ld_hy;ly
asmcmd_ld_hy
;ld hy,reg/n (reg!=h,l,hx,lx)
        asmputbyte 0xfd
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        call matchrb_ora
        jr nz,asmcmd_ld_reg_noreg;asmcmd_ld_hx_noreg
        ld a,c
        and 0b00100111 ;hx,lx -> h,l
asmcmd_ld_hz_reg
        sub 4 ;4,5 = h,l
        cp 2
        jp nc,asmcmd_putcand7plusb
        ret ;nz (error)

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
        ;cp '('
        ;jr z,asmcmd_ld_rp_bracket
        ;cp '['|OR20FORBRACKETS
        ;jr z,asmcmd_ld_rp_bracket
        CPOPENBRACKET_JR asmcmd_ld_rp_bracket
        asmputbyte_c; 0x31 ;ld sp,nn
        jr asmmatchexpr_emitword_bc
asmcmd_ld_rp_bracket
        asmputbyte 0xed
        asmputbyte_b; 0x7b ;ld sp,(mm)
        jr asmmatchexpr_bracket_emitword_bc ;eats

asmcmd_ld_i
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        cp ','
        jp z,asmcmd_ld_i_comma
        MATCHXY_PUTDDFD_NOGET
asmcmd_ld_hl
;ld hl,nn/(mm)
        asmnextchar ;eat
        asmgetchar
        SKIPSPACES_BEFORECOMMA
        MATCH ','
        SKIPSPACES
        ;cp '('
        ;jr z,asmcmd_ld_hl_bracket
        ;cp '['|OR20FORBRACKETS
        ;jr z,asmcmd_ld_hl_bracket
        CPOPENBRACKET_JR asmcmd_ld_hl_bracket
        asmputbyte 0x21 ;ld hl,nn
asmmatchexpr_emitword_bc
        call matchexpr
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
        MATCHCLOSEBRACKET_NOGET
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
        MATCHXY_PUTDDFD_NOGET
        asmputbyte 0x22 ;ld (),hl
        jr asmeat_putbc
asmcmd_ld_bracket_mm_bracket_comma_a
        asmputbyte 0x32 ;ld (),a
asmeat_putbc
        asmnextchar ;eat
        ;asmgetchar
        jr asmputbc
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
        ld a,0x02 ;ld (rp),a
        jp asmcmd_putaplusc
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
        ;cp '('
        ;jr z,asmcmd_ld_a_bracket
        ;cp '['|OR20FORBRACKETS
        ;jr z,asmcmd_ld_a_bracket
        CPOPENBRACKET_JR asmcmd_ld_a_bracket
        cp 'i'
        jr z,asmcmd_ld_a_i
        cp 'r'
        jr z,asmcmd_ld_a_r
;ld a,reg/i8
        call matchrb_ora
        ld a,0x78
        jp z,asmcmd_putaplusc
        ;jr z,asmcmd_ld_a_rb
        asmputbyte 0x3e ;ld a,i8
        jp asmmatchexpr_putc
;asmcmd_ld_a_rb
        ;ld a,c
        ;add a,0x78 ;ld a,rb
        ;asmputbyte_a
        ;cp a ;Z
        ;ret

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

asmcmd_ld_i_comma
        asmnextchar ;eat
        asmgetchar
        MATCH_NOGET 'a'
        asmputbyte 0xed
        asmputbyte 0x47 ;ld i,a
        cp a ;Z
        ret
