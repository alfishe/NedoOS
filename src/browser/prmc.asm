fnt
        incbin "1125vert.fnt"

prnum123
;d=y, e=x8
;hl=num
         call setpgs_scr
         push hl
         call setxymc
         pop de
         ld bc,100
         call prdigmc
         ld bc,10
         call prdigmc
         ld bc,1
         jr prdigmc
         
prnumfrac
;d=y, e=x8
;hl=time (frames)
         call setpgs_scr
         push hl
         call setxymc
         pop de
         ld bc,5000
         call prdigmc
         ld bc,500
         call prdigmc
         ld bc,50
         call prdigmc
         push de
         ld a,'.'
         call prcharmc
         pop de
         ld bc,5
         call prdigmc
         sla e
         ld bc,1
         ;call prdigmc
prdigmc
;hl=scraddr
;de=number
;bc=divisor
        ex de,hl
        ld a,'0'-1
        or a
prdigmc0
        inc a
        sbc hl,bc
        jr nc,prdigmc0
        add hl,bc
        ex de,hl
        push de
        call prcharmc
        pop de
        ret
        
prtextmc
prtextmc0
        ld a,(de)
        or a
        ret z
        push de
        call prcharmc
        pop de
        inc de
        jp prtextmc0

initprcharmc
;a=attr
        ld (prcharmc_attr),a
        xor a
        ld (prcharmc_italic1),a
        ld (prcharmc_italic2),a
        ld (prcharmc_italic3),a
        ld (prcharmc_italic4),a
        ld (prcharmc_stroke),a
        ld (prcharmc_underline),a
        ret
        
prcharmc
;a=code
;hl=scraddr
        ld e,a
        ld d,fnt/256
        ld bc,40
        ;push hl
        dup 4
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
prcharmc_italic1=$
        nop ;/add a,a
prcharmc_stroke=$+1
        or 0
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic2=$
        nop ;/add a,a
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic3=$
        nop ;/add a,a
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic4=$
        nop ;/add a,a
prcharmc_underline=$
        nop ;/cpl
        ld (hl),a
        
        res 6,h
prcharmc_attr=$+1
        ld a,7
        ld bc,-40
        dup 7
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        
        ;set 6,h
        ;pop hl
        ld a,h
        xor 0x60
        cp 0xe0;h
        ld h,a
        ret nc
        inc l
        ret

prcharmc_stateful_setattr
        ld hl,prcharmc_stateful_setattr_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setattr_handler
        dec a
        ld hl,tfontweight
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        ld (prcharmc_attr),a
        jr prcharmc_stateful_resethandler
tfontweight
        db 0+64 ;S
        db 7 ;W
        db 1 ;B
        db 15 ;C
        db 4+64 ;g
        db 4+64 ;g
        db 4+64 ;g
        db 4+64 ;g
        ;db 4 ;G
        ds 8,6*8 ;marked

prcharmc_stateful_setitalic
        ld hl,prcharmc_stateful_setitalic_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setitalic_handler
        dec a
        rra
        sbc a,a
        and 0x87;add a,a
        ld (prcharmc_italic1),a
        ld (prcharmc_italic2),a
        ld (prcharmc_italic3),a
        ld (prcharmc_italic4),a
        jr prcharmc_stateful_resethandler
        
prcharmc_stateful_setstroke
        ld hl,prcharmc_stateful_setstroke_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setstroke_handler
        dec a
        rra
        sbc a,a
        ld (prcharmc_stroke),a
        jr prcharmc_stateful_resethandler
        
prcharmc_stateful_setunderline
        ld hl,prcharmc_stateful_setunderline_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setunderline_handler
        dec a
        rra
        sbc a,a
        and 0x2f;cpl
        ld (prcharmc_underline),a
prcharmc_stateful_resethandler
        ld hl,prcharmc_stateful_normal
        ld (prcharmc_stateful_patch),hl
        ret

prcharmc_tab_stateful
        ld de,(prcharmc_stateful_xy)
        ld a,e
        add a,8
        and 0xf8
        ld e,a
        call setxymc_stateful
        jr prcharmc_tab_statefulq

prcharmc_stateful
;a=code
prcharmc_stateful_patch=$+1
        jp prcharmc_stateful_normal
prcharmc_stateful_normal
        cp 1
        jr z,prcharmc_stateful_setattr
        cp 2
        jr z,prcharmc_stateful_setitalic
        cp 3
        jr z,prcharmc_stateful_setstroke
        cp 4
        jr z,prcharmc_stateful_setunderline

        ;halt
        push af
        call setpgs_scr
        pop af
prcharmc_stateful_scr=$+1
        ld hl,0
        call prcharmc
        ld (prcharmc_stateful_scr),hl
        call setpgtemp8000
prcharmc_stateful_xy=$+1
prcharmc_stateful_x=prcharmc_stateful_xy
        ld de,0
        inc e
        ld a,e
prcharmc_tab_statefulq
        ld (prcharmc_stateful_xy),de
        cp 80
        ret ;c
        
prcharmc_crlf_stateful
        ;ld hl,(curprintvirtualy)
        ;inc hl
        ;ld (curprintvirtualy),hl
        ld de,(prcharmc_stateful_xy)
        ld e,0
        ld a,d
        add a,8
        ld d,a
        cp 8*(HTMLTOPY+HTMLHGT)
        jr c,setxymc_stateful
        sub 8
        ld d,a
        push de
        call scrollmcup
        pop de
setxymc_stateful
;de=yx
        ld (prcharmc_stateful_xy),de
        call setxymc
        ld (prcharmc_stateful_scr),hl
        ret
        
scrollmcdown
        call setpgs_scr
        ld hl,0x8000+(40*8*(HTMLTOPY+HTMLHGT-1))
        ld b,HTMLHGT-1
scrollmcdown_rows0
        push bc
        ld d,h
        ld e,l
        ld bc,-40*8
        add hl,bc
        push hl
        call scrollmc_row
        pop hl
        pop bc
        djnz scrollmcdown_rows0
        ld hl,0xc000+(40*8*(HTMLTOPY))
        jr scrollmc_clearq
        
scrollmcup
        call setpgs_scr
        ld hl,0x8000+(40*8*(HTMLTOPY))
        ld b,HTMLHGT-1
scrollmcup_rows0
        push bc
        ld d,h
        ld e,l
        ld bc,40*8
        add hl,bc
        push hl
        call scrollmc_row
        pop hl
        pop bc
        djnz scrollmcup_rows0
        ld hl,0xc000+(40*8*(HTMLTOPY+HTMLHGT-1))
scrollmc_clearq
        xor a
        call cleanlinemc
        jp setpgtemp8000

cleanlinemc
;hl=0xc000+
        push af
        xor a
        call scrollmcup_clblock
        set 5,h;ld hl,0xe000+(40*200)-(40*8)
        call scrollmcup_clblock
        pop af
        res 6,h;ld hl,0xa000+(40*200)-(40*8)
        call scrollmcup_clblock
        res 5,h;ld hl,0x8000+(40*200)-(40*8)
        ;call scrollmcup_clblock
        ;ret        
scrollmcup_clblock
        push hl
        ld d,h
        ld e,l
        inc de
        ld bc,40*8-1
        ld (hl),a;0
        ldir
        pop hl
        ret

scrollmc_row
        ld b,8
scrollmc_row0        
        push bc
        push hl
        push de
        call scrollmc_line
        pop hl
        ld bc,40
        add hl,bc
        ex de,hl
        pop hl
        add hl,bc
        pop bc
        djnz scrollmc_row0
        ret
        
scrollmc_line
        ld bc,39
        ldir
        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        ld c,39
        lddr
        ld a,(hl)
        ld (de),a
        set 6,h
        set 6,d
        ld c,39
        ldir
        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d
        ld c,40
        lddr
        ret

setxymc
;de=yx (kept)
;out: hl=0xc000+
        ld b,0
        ld c,d
        ld h,b
        ld l,c
        add hl,hl
        add hl,hl
        add hl,bc ;*5
        add hl,hl
        add hl,hl
        add hl,hl ;*40
        ld c,e
         srl c
        ld b,0xc0
         jr nc,$+4
         ld b,0xe0
        add hl,bc
        ret
