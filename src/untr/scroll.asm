scrollleft
;hl=linestart
;c=scroll amount
;c=1: scrollleft_rld с c=0
;c=2: scrollleft_ld с c=1
;c=3: scrollleft_rld с c=1
        srl c
        jp c,scrollleft_rld
scrollleft_ld
;hl=linestart
;c=scroll amount
        ld d,h
        ld a,l
        add a,c
        ld e,a
        ex de,hl
;hl=from
;de=to
        ld a,SCRTRACKWID/2
        sub c
        ld c,a
;c=SCRTRACKWID/2-scrollamount
        ld b,8
scrollleft_ld0
        push bc
        push de
        push hl
        ld b,0
        ldir
        pop hl
        pop de
        pop bc
        inc d
        inc h
        djnz scrollleft_ld0
        ret

scrollright
;hl=linestart
;c=scroll amount
;c=1: scrollright_rrd с c=0
;c=2: scrollright_ld с c=1
;c=3: scrollright_rrd с c=1
        srl c
        jp c,scrollright_rrd
scrollright_ld
;hl=linestart
;c=scroll amount
        ld a,l
        add a,SCRTRACKWID/2-1
        ld l,a
        ld d,h
        sub c
        ld e,a
        ex de,hl
;hl=from
;de=to
        ld a,SCRTRACKWID/2
        sub c
        ld c,a
;c=SCRTRACKWID/2-scrollamount
        ld b,8
scrollright_ld0
        push bc
        push de
        push hl
        ld b,0
        lddr
        pop hl
        pop de
        pop bc
        inc d
        inc h
        djnz scrollright_ld0
        ret

scrollleft_rld
;hl=linestart
        ;ld c,0
;c=scroll amount
        ld d,h
        ld a,l
        add a,c
        ld e,a
        ex de,hl
;hl=from
;de=to
        ld a,SCRTRACKWID/2
        sub c
        ld c,a
;c=SCRTRACKWID/2-scrollamount
        ld b,8
scrollleft0p
        push bc
        push de
        push hl
        ld b,0
        ld a,l
        cp e
        jr z,scrollleft_noldir
        ldir
scrollleft_noldir
        add hl,bc
        dec hl
        xor a
       dup SCRTRACKWID/2-1
        rld
        dec l
       edup
        rld
        pop hl
        pop de
        pop bc
        inc d
        inc h
        djnz scrollleft0p
        ret

scrollright_rrd
;hl=linestart
        ;ld c,0
;c=scroll amount
        ld a,l
        add a,SCRTRACKWID/2-1
        ld l,a
        ld d,h
        sub c
        ld e,a
        ex de,hl
        ld a,SCRTRACKWID/2
        sub c
        ld c,a
;c=SCRTRACKWID/2-scrollamount
        ld b,8
scrollright0p
        push bc
        push de
        push hl
        ld b,0
        ld a,l
        cp e
        jr z,scrollright_nolddr
        lddr
scrollright_nolddr
        or a
        sbc hl,bc
        inc hl
        xor a
        dup SCRTRACKWID/2-1
        rrd
        inc l
        edup
        rrd
        pop hl
        pop de
        pop bc
        inc d
        inc h
        djnz scrollright0p
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scroll_left_c
;c=scroll amount (in chars)
;hx=toptrack
;b=scrntracks
        ld a,c
        ld (scrollleft_Nchars),a
        push bc
        call setscrpg
        pop bc
scrollleft0
        push bc
        push hl
        call scrollleft ;scrollleft_rld
        pop hl
;обновить бар слева
        push hl
        ld d,h
        ld e,l
        dec e
        ld c,0x01
        ld a,(curlefttime)
        sub 8
        ld l,a
        and 7
        call prbar_or_nobar
        call setpgroots
;допечатать столбик справа и его бар
        call prtrack_gettype ;uses hx
        pop hl
        push hl
        ld d,h
        ld a,l
        add a,SCRTRACKWID/2-1
        ld e,a
curlefttime=$+1
        ld hl,0;(curlefttime)
        ld bc,SCRTRACKWID-1
        add hl,bc
scrollleft_Nchars=$+2
        ld bc,1*256+0xf0
;de=scr
;hx=track
;c=0x0f/0xf0
;b=SCRTRACKWID
;hl=time
        push bc
        push de
        push bc
        ld a,c
        dec b
        jr z,scrollleft_beforeprtrack0q
scrollleft_beforeprtrack0
        dec hl
        rlca
        rlca
        rlca
        rlca
        jr c,$+3
        dec e
        djnz scrollleft_beforeprtrack0
scrollleft_beforeprtrack0q
        pop bc
        ld c,a
        call prtrack_Nchars
        pop de
        call setscrpg
        ld a,(curlefttime)
        add a,SCRTRACKWID-8
        ld l,a
        pop bc ;ld b,1
        ld c,0x01
scrollleft_prbars0
        push de
        ld a,l
        and 7
        call prbar_or_nobar
        pop de
        dec l
        ld a,c
        rlca
        rlca
        rlca
        rlca
        ld c,a
        jr nc,$+3
        dec e
        djnz scrollleft_prbars0
        pop hl
        call nextchrline_hl
        pop bc
        inc hx ;track
        dec b
        jp nz,scrollleft0
        ret

scroll_right_c
;c=scroll amount (in chars)
        ld a,c
        ld (scrollright_Nchars),a
        push bc
        call setscrpg
        pop bc
scrollright0
        push bc
        push hl
        call scrollright ;scrollright_rrd
        pop hl
;обновить бар слева (вне поля скролла)
        push hl
        ld d,h
        ld e,l
        push de
        dec e
        ld c,0x01
        ld a,(curlefttime)
        sub 8
        ld l,a
        and 7
        call prbar_or_nobar
        call setpgroots
;допечатать столбик слева и его бар
        call prtrack_gettype ;uses hx
        pop de
        ld hl,(curlefttime)
scrollright_Nchars=$+2
        ld bc,1*256+0x0f
;de=scr
;hx=track
;c=0x0f/0xf0
;b=SCRTRACKWID
;hl=time
        push bc
        push de
        call prtrack_Nchars
        pop de
        call setscrpg
        ld a,(curlefttime)
        add a,1-8
        ld l,a
        pop bc;ld b,1
        ld c,0x10
scrollright_prbars0
        push de
        ld a,l
        and 7
        call prbar_or_nobar
        pop de
        inc l
        ld a,c
        rlca
        rlca
        rlca
        rlca
        ld c,a
        jr c,$+3
        inc e
        djnz scrollright_prbars0
        
        pop hl
        call nextchrline_hl
        pop bc
        inc hx ;track
        dec b
        jp nz,scrollright0
        ret
