OR20FORBRACKETS=0;0x20
IXADD=0x50;0x80
IYADD=0x70;0xa0

       macro MATCH_NOGET s1
        cp s1
        ret nz
        asmnextchar ;eat
       endm
       macro MATCH s1
        MATCH_NOGET s1
        asmgetchar
       endm

       macro MATCHOPENBRACKET
        cp '('
        jr z,$+5
         cp '['|OR20FORBRACKETS
         ret nz
        asmnextchar ;eat
        asmgetchar
       endm
       
       macro CPCLOSEBRACKET_NOEAT
        cp ')'
        jr z,$+4
        cp ']'|OR20FORBRACKETS
       endm
       macro MATCHCLOSEBRACKET_NOGET
        CPCLOSEBRACKET_NOEAT
        ret nz
        asmnextchar ;eat
       endm
       macro MATCHCLOSEBRACKET
        MATCHCLOSEBRACKET_NOGET
        asmgetchar
       endm
       macro MATCHBRACKET_OR_i8BRACKET_NOGET
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
       endm
       macro MATCHBRACKET_OR_i8BRACKET
        MATCHBRACKET_OR_i8BRACKET_NOGET
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
       
       macro JPMATCHENDWORD_BACK1
        jp matchendword_back1
       endm

       macro JPMATCHENDWORD_BACK2
        jp matchendword_back2
       endm

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

matchcc
;a=first char ;съедает слово! если error, то откатывает как было
;NZ=error
;out: a=0x20+0,8..0x38 for 'nz'/'z'/'nc'/'c'/'po'/'pe'/'p'/'m'
        cp 'p'
        jr z,matchcc_p
        cp 'm'
        jr z,matchcc_m
matchcc_for_jr
        cp 'n'
        jr z,matchcc_n
        cp 'c'
        jr z,matchcc_c
        cp 'z'
        ;jr z,matchcc_z
        ret nz
;matchcc_z
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x08
        JPMATCHENDWORD_BACK1
matchcc_m
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x38
        JPMATCHENDWORD_BACK1
matchcc_p
        asmnextchar ;eat
        asmgetchar
        cp 'o'
        jr z,matchcc_po
        cp 'e'
        jr z,matchcc_pe
        ld c,0x20+0x30
        JPMATCHENDWORD_BACK1
matchcc_po
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x20
        JPMATCHENDWORD_BACK2
matchcc_pe
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x28
        JPMATCHENDWORD_BACK2
matchcc_c
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x18
        JPMATCHENDWORD_BACK1
matchcc_n
        asmnextchar ;eat
        asmgetchar
        cp 'z'
        jr z,matchcc_nz
        cp 'c'
        jp nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x10
        JPMATCHENDWORD_BACK2
matchcc_nz
        asmnextchar ;eat
        asmgetchar
        ld c,0x20+0x00
        JPMATCHENDWORD_BACK2

matchrb_ora
        cp 'a'
        jr z,matchrb_a
matchrb
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
        JPMATCHENDWORD_BACK1
matchrb_e
        asmnextchar ;eat
        asmgetchar
        ld c,3
        JPMATCHENDWORD_BACK1
matchrb_b
        asmnextchar ;eat
        asmgetchar
        ld c,0
        JPMATCHENDWORD_BACK1
matchrb_c
        asmnextchar ;eat
        asmgetchar
        ld c,1
        JPMATCHENDWORD_BACK1
matchrb_a
        asmnextchar ;eat
        asmgetchar
        ld c,7
        JPMATCHENDWORD_BACK1
matchrb_l
;l/lx/ly
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,matchrb_lx
        cp 'y'
        jr z,matchrb_ly
        ld c,5 ;'l'
        JPMATCHENDWORD_BACK1
matchrb_h
;h/hx/hy
        asmnextchar ;eat
        asmgetchar
        cp 'x'
        jr z,matchrb_hx
        cp 'y'
        jr z,matchrb_hy
        ld c,4 ;'h'
        JPMATCHENDWORD_BACK1
matchrb_hx
        asmnextchar ;eat
        asmgetchar
        ld c,4+IXADD ;'h'
        JPMATCHENDWORD_BACK2
matchrb_hy
        asmnextchar ;eat
        asmgetchar
        ld c,4+IYADD ;'h'
        JPMATCHENDWORD_BACK2
matchrb_lx
        asmnextchar ;eat
        asmgetchar
        ld c,5+IXADD ;'l'
        JPMATCHENDWORD_BACK2
matchrb_ly
        asmnextchar ;eat
        asmgetchar
        ld c,5+IYADD ;'l'
        JPMATCHENDWORD_BACK2

matchrp_orsp
        cp 's'
        jr z,matchrp_s
matchrp
;a=first char
;out: c=0/0x10/0x20 (bc/de/hl)
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
        jr nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x10
        JPMATCHENDWORD_BACK2
matchrp_h
        asmnextchar ;eat
        asmgetchar
        cp 'l'
        jr nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x20
        JPMATCHENDWORD_BACK2
matchrp_b
        asmnextchar ;eat
        asmgetchar
        cp 'c'
        jr nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0
        JPMATCHENDWORD_BACK2
matchrp_s
        asmnextchar ;eat
        asmgetchar
        cp 'p'
        jr nz,asm_backchar
        asmnextchar ;eat
        asmgetchar
        ld c,0x30
        JPMATCHENDWORD_BACK2

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

matchendword_back1
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
ora
        or a
        ret ;nz

matchendword_back2
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
        asmback2chars ;!=0
        or a
        ret ;nz

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
