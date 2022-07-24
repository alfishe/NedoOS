readbmphead_pal
        ld de,bgpush_bmpbuf
        ld hl,14+2;54+(4*16)
;de=buf
;hl=size
        call readstream_file
        ld de,bgpush_bmpbuf
        ld hl,(bgpush_bmpbuf+14)
        dec hl
        dec hl
;de=buf
;hl=size
        call readstream_file
       ld hl,(bgpush_bmpbuf+2)
       ld a,l
       ld b,4
       srl h
       rra
       djnz $-3
       ld (bmpwid),a
        ld de,bgpush_bmpbuf
        ld hl,+(4*16)
;de=buf
;hl=size
        call readstream_file

        ld hl,bgpush_bmpbuf;+54
        ld ix,pal
        ld b,16
recodepal0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld l,(hl) ;e=B, d=G, l=R
        call readfile_rgbtopal
        pop hl
        inc hl
        inc hl
        djnz recodepal0
        ret
bmpwid
        dw 0

readfile_rgbtopal
;e=B, d=G, l=R
        call calcRGBtopal_pp
        ld (ix+1),a
        call calcRGBtopal_pp
        ld (ix),a
        inc ix
        inc ix
        ret

calcRGBtopal_pp
;e=B, d=G, l=R
;DDp palette: %grbG11RB(low),%grbG11RB(high), ??oN????N
        xor a
        rl e  ;B
        rra
        rl l  ;R
        rra
        rrca
        rrca
        rl d  ;G
        rra
        rl e  ;b
        rra
        rl l  ;r
        rra
        rl d  ;g
        rra
        cpl
        ret 

bgpush_ldbmp_line
;hl=начало строки ld-push
;a=pushwid/2
        push bc
        ;push de

         push af
        ;push de
        push hl
        push ix
        ld de,bgpush_bmpbuf
        ld h,0
        ld l,a
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ;ld hl,320
;de=buf
;hl=size
        push hl
        push de
        call readstream_file
        pop de
        pop hl
        add hl,de
        ex de,hl ;de=gfx end addr
        pop ix
        pop hl
        ;pop de
         pop bc
        ;pop af
        ;ld b,a
        dec de ;gfx addr
        ld a,(ix+3)
        call bgpush_ldbmp_layerline
        dec de
        dec de
        ld a,(ix+2);(ix+1)
        call bgpush_ldbmp_layerline
        dec de
        dec de
        ld a,(ix+1);(ix+2)
        call bgpush_ldbmp_layerline        
        dec de
        dec de
        ld a,(ix+0)
        call bgpush_ldbmp_layerline        
        ;pop de
        pop bc
        ret

bgpush_ldbmp_layerline
;пишем каждый четвёртый байт с конца в ld-push
;de=gfx
;hl=начало строки ld-push
;a=pg
;b=pushwid/2
        ;ld b,pushwid/2
        push bc
        SETPG8000;SETPGPUSHBASE
        pop bc
        push bc
        push de
        push hl
        ;inc hl
        ;inc hl ;мы на втором байте первого слова данных в ld bc
bgpush_ldbmp_bytes0
        inc hl
        inc hl
        RECODEBYTE
        ld (hl),a
        dec hl
         dec de
         dec de
         dec de
         dec de
         dec de
         dec de
        RECODEBYTE
        ld (hl),a
        inc hl
         dec de
         dec de
         dec de
         dec de
         dec de
         dec de
        inc hl
        inc hl
        djnz bgpush_ldbmp_bytes0
        pop hl
        pop de
        pop bc
        ret
