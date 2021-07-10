OR20FORBRACKETS=0;0x20
IXADD=0x50;0x80
IYADD=0x70;0xa0

       macro MATCH s1
        cp s1
        ret nz
        asmnextchar ;eat
        asmgetchar
       endm
       
       macro CPCLOSEBRACKET_NOEAT
        cp ')'
        jr z,$+4
        cp ']'|OR20FORBRACKETS
       endm
       macro MATCHCLOSEBRACKET
        CPCLOSEBRACKET_NOEAT
        ret nz
        asmnextchar ;eat
        asmgetchar
       endm
       macro MATCHBRACKET_OR_i8BRACKET
        ld c,0
        cp ')'
        jr z,1f;asmcmd_ld_bracket_iz_noshift
        cp ']'|OR20FORBRACKETS
        jr z,1f;asmcmd_ld_bracket_iz_noshift
        call matchexpr
        ret nz
        CPCLOSEBRACKET_NOEAT
        ret nz
1;asmcmd_ld_bracket_iz_noshift
        asmnextchar ;eat
        asmgetchar
       endm

       macro SKIPSPACES ;ret nz (error) if eol ;остаётся на первом непробеле и его возвращает в a
        call asmskipspaces
        ret nz
       endm

       macro SKIPSPACES_BEFORECOMMA
        ;SKIPSPACES
       endm

       macro MATCHSPACES ;ret nz (error) if not spaces or if eol ;остаётся на первом непробеле и его возвращает в a
        cp ' '
        jr z,$+4
         cp 9 ;tab
        call z,asmskipspaces_next
        ret nz
       endm
       
       macro MATCHENDWORD
        call matchendword ;z=endword ;не ест символ
        ret nz
       endm

       macro JPMATCHENDWORD
        jp matchendword ;z=endword ;не ест символ
        ;ret
       endm

       macro JPMATCHENDWORD_BACK
        JPMATCHENDWORD ;TODO отмотка назад на 1 символ
       endm

;out: nz (error) if eol ;остаётся на первом непробеле и его возвращает в a
asmskipspaces_next
        asmnextchar
        asmgetchar
asmskipspaces
        cp 9 ;tab
        jr z,asmskipspaces_next
        cp ' '
        jr z,asmskipspaces_next
        ret c ;error (nz)
        cp a ;z
        ret

asmcmd
;de=cmd text
;hl=code generated ;out: after the code
;out: NZ=error
        ;ld de,asmtestcmd
        asmgetchar
        cp 'l'
        jp z,asmcmd_l
        
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
        asmgetchar
        asmputbyte 0xb0 ;ldir
        cp a ;Z
        ret
asmcmd_ldd_
;ldd/lddr
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        cp 'r'
        jr z,asmcmd_lddr
        asmputbyte 0xa8 ;ldd
        cp a ;Z
        ret
asmcmd_lddr
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xb8 ;lddr
        cp a ;Z
        ret

asmcmd_ld_reg_bracket_i
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
asmcmd_ld_reg_bracket
;ld r,[hl]/[iz+]
        asmnextchar ;eat
        asmgetchar
        cp 'i'
        jr z,asmcmd_ld_reg_bracket_i
;ld r,[hl]
        MATCH 'h'
        MATCH 'l'
        MATCHCLOSEBRACKET
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
        MATCH 'p'
        ld bc,0x7b31 ;ld sp,(mm), ld sp,nn
asmcmd_ld_rp_nn_bmm_cnn
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
        asmgetchar
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
        MATCH 'a'
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
        MATCH 'a'
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
        jp z,asmcmd_ld_a_i
        cp 'r'
        jp z,asmcmd_ld_a_r
;ld a,a/reg/n
        cp 'a'
        jr z,asmcmd_ld_a_a
        call matchrb
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
asmcmd_ld_a_a
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0x7f ;ld a,a
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
        MATCHBRACKET_OR_i8BRACKET
        asmputbyte_c
        cp a ;Z
        ret

asmcmd_ld_a_i
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        asmputbyte 0x57 ;ld a,i
        cp a ;Z
        ret
asmcmd_ld_a_r
        asmnextchar ;eat
        asmgetchar
        asmputbyte 0xed
        asmputbyte 0x5f ;ld a,r
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
        MATCH 'a'
        asmputbyte 0xed
        asmputbyte 0x47 ;ld i,a
        cp a ;Z
        ret
        
matchrb_ora
        cp 'a'
        jr z,matchrb_a
matchrb
;for ld only!!!
;a=first char ;съедает слово! если error, то откатывает как было
;в команде ld уже проверено 'a', 'i' для первого и второго параметра
;опознаёт b/c/d/e/h/l/hx/lx/hy/ly
;NZ=error
;out: a=0..7 for 'b'/'c'/'d'/'e'/'h'/'l'
        cp 'c'
        jr z,matchrb_c
        cp 'e'
        jr z,matchrb_e
        cp 'l'
        jr z,matchrb_l
        cp 'h'
        jr z,matchrb_h
        cp 'b'
        jr z,matchrb_b
        cp 'd'
        ;jr z,matchrb_d
        ret nz ;z/nz
;matchrb_d
        asmnextchar ;eat
        asmgetchar
        ld c,2
        JPMATCHENDWORD
matchrb_e
        asmnextchar ;eat
        asmgetchar
        ld c,3
        JPMATCHENDWORD
matchrb_b
        asmnextchar ;eat
        asmgetchar
        ld c,0
        JPMATCHENDWORD
matchrb_c
        asmnextchar ;eat
        asmgetchar
        ld c,1
        JPMATCHENDWORD
matchrb_a
        asmnextchar ;eat
        asmgetchar
        ld c,7
        JPMATCHENDWORD
matchrb_l
;l/lx/ly
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,matchrb_lx
        cp 'y'
        jr z,matchrb_ly
        ld c,5 ;'l'
        JPMATCHENDWORD
matchrb_h
;h/hx/hy
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,matchrb_hx
        cp 'y'
        jr z,matchrb_hy
        ld c,4 ;'h'
        JPMATCHENDWORD
matchrb_hx
        asmnextchar ;eat
        asmgetchar
        ld c,4+IXADD ;'h'
        JPMATCHENDWORD_BACK
matchrb_hy
        asmnextchar ;eat
        asmgetchar
        ld c,4+IYADD ;'h'
        JPMATCHENDWORD_BACK
matchrb_lx
        asmnextchar ;eat
        asmgetchar
        ld c,5+IXADD ;'l'
        JPMATCHENDWORD_BACK
matchrb_ly
        asmnextchar ;eat
        asmgetchar
        ld c,5+IYADD ;'l'
        JPMATCHENDWORD_BACK

matchrp
;a=first char
;bc/de/hl=0/0x10/0x20
        cp 'h'
        jr z,matchrp_h
        cp 'b'
        jr z,matchrp_b
        cp 'd'
        ;jr z,matchrp_d
        ret nz ;z/nz
;matchrp_d
        asmnextchar ;eat
        asmgetchar
        cp 'e'
        jp nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x10
        JPMATCHENDWORD_BACK
matchrp_h
        asmnextchar ;eat
        asmgetchar
        cp 'l'
        jp nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x20
        JPMATCHENDWORD_BACK
matchrp_b
        asmnextchar ;eat
        asmgetchar
        cp 'c'
        jp nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0
        JPMATCHENDWORD_BACK

matchexpr
;a=char (двигает курсор до первого символа, не годящегося для вычисления выражения, возвращает его в a)
;out: bc=result
        call matchval
        ret nz ;error
;TODO +/-
        ret

matchval_plus
        asmnextchar ;eat
        asmgetchar
matchval
;TODO labels
        cp '-'
        jr z,matchval_minus
        cp '('
        jr z,matchval_bracket
        cp '#'
        jr z,matchval_hex
        cp '+'
        jr z,matchval_plus
        sub '0'
        cp 10
        jr nc,matchval_nodigit
        push hl
        ld bc,0
        ld h,b
        ld l,c
matchval_dec0 ;bc=hl
        add hl,hl ;*2
        add hl,hl ;*4
        add hl,bc ;*5
        add hl,hl ;*10
        add a,l
        ld l,a
        jr nc,$+3
         inc h
        ld b,h
        ld c,l
        asmnextchar ;eat
        asmgetchar
        sub '0'
        cp 10
        jr c,matchval_dec0
        pop hl
        ;add a,'0' ;как было
        asmgetchar        
        cp a ;z
        ret
matchval_nodigit
        ;ld c,'0'
        ;add a,c ;как было (для следующих match)
        ;dec c ;nz (error)
        or a ;nz (error)
        asmgetchar        
        ret

matchval_hex
        asmnextchar ;eat
        asmgetchar
        ld bc,0
matchval_hex0
        sub '0'+10
        cp -10
        jr c,matchval_hex_nodigit
matchval_hex_add
        add a,10
       dup 4
        sla c
        rl b
       edup
        or c
        ld c,a
        asmnextchar ;eat
        asmgetchar
        jr matchval_hex0
matchval_hex_nodigit
        sub 'a'-('0'+10)
        cp 6
        jr c,matchval_hex_add
        sub 'A'-'a'
        cp 6
        jr c,matchval_hex_add
        ;sub -'A' ;как было
        asmgetchar
        cp a ;z
        ret

matchval_minus
        asmnextchar ;eat
        asmgetchar
        call matchval
        ret nz
       ;push af
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a
       ;pop af
        asmgetchar
        cp a ;z
        ret

matchval_bracket
        asmnextchar ;eat
        asmgetchar
        call matchexpr
        ret nz
        MATCH ')'
        ret

matchendword
;a=char
;Z=конец слова, NZ=не конец
        cp ' '+1
        jr c,matchendword_ok
        cp ')'
        ret z
        cp ']'|OR20FORBRACKETS
        ret z
        cp ','
        ret ;z/nz
matchendword_ok
        cp a
        ret

matchendword_back
;a=char
;Z=конец слова, NZ=не конец (откручиваем назад)
        cp ' '+1
        jr c,matchendword_ok
        cp ')'
        ret z
        cp ']'|OR20FORBRACKETS
        ret z
        cp ','
        ret z
asm_backchar
        asmbackchar ;!=0
        or a
        ret ;nz

asmtestcmd
        db "ld a,5",0
