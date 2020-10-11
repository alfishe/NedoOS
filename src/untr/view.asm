cls
        call setscrpg
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x17ff
        ld (hl),l;0
        ldir
        jp setpgroots

        if 1==0
downhl
        inc h
downhl_afterinch
        ld a,h
        and 7
        ret nz
        ld a,l
        add a,32
        ld l,a
        ret c
        ld a,h
        sub 8
        ld h,a
        ret
        endif

nextchrline_de
        ld a,e
        add a,32
        ld e,a
        ret nc;jr nc,$+6
         ld a,d
         add a,8
         ld d,a
        ret

nextchrline_hl
        ld a,l
        add a,32
        ld l,a
        ret nc;jr nc,$+6
         ld a,h
         add a,8
         ld h,a
        ret

prchardig
        push de
        ;push hl
        ld h,digfont/256
        jr prchar_h
prcharnote
        push de
        ;push hl
        ld h,notefont/256
        jr prchar_h
prchar
        push de
        ;push hl
        ld h,font/256
prchar_h
        ld l,a
        push bc
        call setscrpg
        pop bc
        dup 7
        ld a,(de)
        xor (hl)
        and c
        xor (hl)
        ld (de),a
        inc h
        inc d
        edup
        ld a,(de)
        xor (hl)
        and c
        xor (hl)
        ld (de),a
        ;pop hl
        pop de
        push bc
        call setpgroots
        pop bc
        ld a,c
        xor 0xff
        ld c,a
        ret m
        inc e
        ret

prcur
;bc=YX
;0b000YYyyy 0b00XXXXXx
;0b010YY000 0byyyXXXXX
        push bc
        call setscrpg
        pop bc
        ld a,b
        and 0x18
        add a,0x40
        ld d,a
        ld a,c
        add a,a
        add a,a ;0bXXXXXx00
        rr b
        rra
        rr b
        rra
        rr b
        rra ;0xbyyyXXXXX, CY=x
        ld e,a
        sbc a,a
        xor 0xf0
        ld c,a
        dup 7
        ld a,(de)
        xor c
        ld (de),a
        inc d
        edup
        ld a,(de)
        xor c
        ld (de),a
        call setpgroots
        ret

prtext
prtext0keepde
        ld (prtext_cr_de),de
        ld a,c
        ld (prtext_cr_c),a
prtext0
        ld a,(hl)
        or a
        ret z
        inc hl
        cp 13
        jr z,prtext_cr
        push hl
        call prchar
        pop hl
        jr prtext0
prtext_cr
prtext_cr_c=$+1
        ld c,0
prtext_cr_de=$+1
        ld de,0
        call nextchrline_de
        jr prtext0keepde

        if 1==0
;lx=background color %33210210
;hx=color %33210210
;de=font char
;hl=screen
prchar48ega_hxoncolor0
        ld b,hx
        ld a,(de)
        ld c,a
        ld a,lx
        rl c
        jr nc,$+2+4
         xor b
         and 0xb8;%10111000
         xor b
        rl c
        jr nc,$+2+4
         xor b
         and 0x47;%01000111
         xor b
        ld (hl),a
        set 6,h
        ld a,lx
        rl c
        jr nc,$+2+4
         xor b
         and 0xb8;%10111000
         xor b
        rl c
        jr nc,$+2+4
         xor b
         and 0x47;%01000111
         xor b
        ld (hl),a
        inc d
        ld bc,+(40-0x4000)
        add hl,bc
        dec hy
        jp nz,prchar48ega_hxoncolor0

;c=ink (IIiiiiii)
;b=paper (PPpppppp)
        ld a,(hl)
        rla
        sbc a,a
        ld e,a ;RRRRRRRR
        ld a,(hl)
        rla
        rla
        sbc a,a ;LLLLLLLL
        xor e
        and 0b01000111
        xor e
        ld d,a
;a=%RLRRRLLL        
        and c ;ink (IIiiiiii)
        ld e,a
        ld a,d
        cpl
        and b ;paper (PPpppppp)
        or e
        ld (hl),a 

;несколько шрифтов в зависимости от цвета:
;один шрифт = 2(столбца)*8(высота)*2(байта)*256(символов) = 0x2000
;с версией, сдвинутой на 1 пикс. вправо, он даже не поместится в страницу
        pop de
        ld a,(hl)
        and e
        or d
        ld (hl),a
        add hl,bc
;43t/b (последний add не нужен, так что 41.625t/b)
;но неудобно вычислять начальный адрес (+33t) и сохранять стек (+36t или 16t всегда на одной глубине), причём первое слово надо брать не из стека (+12t), итого 51.75t/b

;или
        ld a,(de)
        and (hl)
        inc d
        ex de,hl
        or (hl)
        ex de,hl
        ld (hl),a
        inc d
        add hl,bc
;55t/b (последний inc d и add не нужны, так что 53.125t/b)

;или
        ld a,(de)
        and (hl)
        inc h
        or (hl)
        ld (de),a
        inc h
        ld a,e
        add a,c
        ld e,a
        jp nc,$+3 ;10.625t
         inc d
;10.625+28+20 = 58.625t/b (последний inc h и пересчёт не нужны, так что 55.3t/b)

;или (с огромной таблицей перехода по стеку для всех случаев)
        pop de
        ld a,(de)
        and (hl)
        inc h
        or (hl)
        ld (de),a
        inc h
;46t/b (45.5 без последнего inc h), но надо сохранять стек (+36t/8) = 50t/b
        endif

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

        align 256
font
        incbin "64qua.fnt"
notefont=0x6000
        ;ds 2048
digfont=0x6800
        ;ds 2048

;;;;;;;;;;;;;;;;;;;;;;;;; high level view ;;;;;;;;;;;;;;;;;;;;;;;;
getscrntracks
        ld a,(ntracks)
        ld b,SCRNTRACKS
        cp b
        ret nc
        ld b,a
        ret

setneedprtypes
        ld a,55 ;"scf"
        ld (needprtypes),a
        ret
setneedprtracks
        ld a,-1
        ld (oldtoptrack),a
        ret

updatescr
;сейчас виден курсор

;обновляем, если изменился lefttime или toptrack
;при смене toptrack также перерисовать описатели треков
        call getcurplayxonscreen
        ld (curplayxonscreen),a
oldcurplayxonscreen=$+1
oldcurplayyonscreen=$+2
        ld bc,0
        ;cp c
        ;jr z,updatescr_noplaycur
        ld a,c
        or a
        call nz,prcur
updatescr_noplaycur

        call getcurx
tracksmode=$+1
        ld c,0
        dec c
        jr nz,$+5
         ld a,(tracks_curx) ;edit tracks mode
        ld (curxonscreen),a
oldcurxonscreen=$+1
oldcuryonscreen=$+2
        ld bc,0
        ;cp c
        ;jr z,updatescr_nocur
        call prcur
updatescr_nocur

;теперь курсор не виден
        ld a,(toptrack)
oldtoptrack=$+1
        ld c,-1
        ld (oldtoptrack),a
        ld hl,(lefttime)
        ld (curlefttime),hl
oldlefttime=$+1
        ld de,0x8000
        ld (oldlefttime),hl
        cp c
        jp nz,updatescr_scrollupdown
        or a
        sbc hl,de
        jr nz,updatescr_scroll
        jp updatescr_scrollq
updatescr_scrollupdown
        call setneedpralltracks
        call setneedprtypes
        jp updatescr_scroll_noprall

updatescr_scroll
;hl=lefttime-oldlefttime
;если скролл на 1 символ, то реально скроллим, иначе перепечатываем?
        bit 7,h
        jp nz,updatescr_scroll_right
        ;ld a,l
        ;and h
        ;inc a
        ;jp z,updatescr_scroll_right
        ;ld a,l
        ;dec a
        ;or h
        ;jp nz,updatescr_scroll_prall
        
updatescr_scroll_left
        ld bc,9
        or a
        sbc hl,bc
        jp nc,updatescr_scroll_prall
        add hl,bc
        ld c,l;1
;c=scroll amount (in chars)
        ld a,c
        ld (scrollleft_Nchars),a
        push bc
        call setscrpg
        pop bc
        ld hl,0x4020+(TRACKX/2);+(SCRTRACKWID/2)-1
        call getscrntracks;ld b,SCRNTRACKS
        ld a,(toptrack)
        ld hx,a;0 ;track
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
        call setpgroots
        jp updatescr_scroll_noprall

updatescr_scroll_right
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a ;hl=-hl
        ld bc,9
        or a
        sbc hl,bc
        jp nc,updatescr_scroll_prall
        add hl,bc
        ld c,l;1
;c=scroll amount (in chars)
        ld a,c
        ld (scrollright_Nchars),a
        push bc
        call setscrpg
        pop bc
        ld hl,0x4020+(TRACKX/2)
        call getscrntracks;ld b,SCRNTRACKS
        ld a,(toptrack)
        ld hx,a;0 ;track
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
        call setpgroots
        jp updatescr_scroll_noprall

updatescr_scroll_prall
        call setneedpralltracks
updatescr_scroll_noprall
;показывать время только при скролле (TODO по одной цифре)
        ld de,0x4000+(TRACKX/2)
        ld b,SCRTRACKWID
        ld c,0x0f
        ld hl,(curlefttime)
        inc hl
        inc hl
updatescr_time0
;печатаем только на барах (32), 2 цифры слева и 2 справа
        ld a,l
        and 31
        cp 4
        ld a,'.'
        jr nc,updatescr_time0_skip
        ld a,l
        and 0xfc
        bit 1,l
        jr nz,$+3
         ld a,h
        bit 0,l
        jr nz,$+6
         rra
         rra
         rra
         rra
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
updatescr_time0_skip
        push hl
        call prchar
        pop hl
        inc hl
        inc c
        djnz updatescr_time0

updatescr_scrollq
        ;xor a
        ;ld (untr_needredraw),a
        ;ld de,0x4001
        ;ld c,0x0f
        ;ld hl,ttypes
needprtypes=$
        scf
        call c,prtypes
        ld a,55+128 ;"or a"
        ld (needprtypes),a

;needpralltracks=$
;        scf
        ;jr nc,updatescr_prcurtrack
;обновлять только треки, которые изменились (обновление одного не прокатит при асинхронном рисовании!!!)
        ld de,0x4020+(TRACKX/2)
        call getscrntracks;ld b,SCRNTRACKS
        ld a,(toptrack)
        ld hx,a;0 ;track
updatescr_tracks0
        push bc
        push de
        ld c,0x0f
        ld b,SCRTRACKWID
        call prtrack
        pop de
        call nextchrline_de
        pop bc
        inc hx ;track
        djnz updatescr_tracks0
;        ld a,55+128 ;"or a"
;        ld (needpralltracks),a
;        jr updatescr_prcurtrackq
;updatescr_prcurtrack
;        ld a,(curtrack)
;        ld hx,a
;        ld c,0x0f
;        call prtrack
;updatescr_prcurtrackq

        ld hl,(FreeMem_value)
        ld de,0x4000
        ld c,0x0f
        push hl
        ld a,h
        call prhex
        pop hl
        ld a,l
        call prhex

;draw cursors
curplayxonscreen=$+1
        ld a,0
        ld (oldcurplayxonscreen),a
        ld c,a
        xor a ;call getcury
        ld (oldcurplayyonscreen),a
        ld b,a
        ld a,c
        or a
        call nz,prcur

curxonscreen=$+1
        ld a,0
        ld (oldcurxonscreen),a
        ld c,a
        call getcury
        ld (oldcuryonscreen),a
        ld b,a
        call prcur

        ret
prhex
        call prhexdig
prhexdig
        rrca
        rrca
        rrca
        rrca
        push af
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
        call prchar
        pop af
        ret

prtypes
        ld hl,ttypes
        ld a,(toptrack)
        add a,a
        add a,a
        add a,a
        ld e,a
        ld d,0
        add hl,de
        ld de,0x4020
        call getscrntracks;ld b,SCRNTRACKS
prtypes0
        push bc
        push de
        ld bc,0x070f
prtypes0new0
        ld a,(hl)
        push hl
        call prchardig
        pop hl
        inc hl
        djnz prtypes0new0
        inc hl
        pop de
        call nextchrline_de
        pop bc
        djnz prtypes0
        ret

prtrack_gettype
        ld a,hx
        call gettracktype
        ld hl,prcharnote
        cp _t;CHNTYPE_NOTES
        jr z,$+5
         ld hl,prchardig
        ld (prtrack_prproc),hl
        ret

prtrack_Nchars
;(after prtrack_gettype)
;de=scr
;hx=track
;c=0x0f/0xf0
;b=SCRTRACKWID
;hl=time
prtrack0
        push hl
        push de
        ld a,hx ;track
        call tracktime_totrackpartindex ;out: a=track, hl=index, ly=part
        call peektrackpartindex
        pop de
prtrack_prproc=$+1
        call prcharnote
        pop hl
         inc hl
        djnz prtrack0
        ret

prtrack
;de=scr
;hx=track
;c=0x0f/0xf0
;b=SCRTRACKWID
        push de
        ld a,hx
        call amulchnsstep_tohl
        ld de,chns-2;tracks
        add hl,de
        pop de
        ld a,(hl)
        or a
        ret p ;трек не обновился
         res 7,(hl)
        call prtrack_gettype

        ld hl,(curlefttime)
        push de
        call prtrack_Nchars
        pop de
        
        call setscrpg

        ld hl,(curlefttime)
        ld c,0x01
        dec e
        push hl
        ld a,l
        sub 8
        ld l,a
        and 7
        push de
        call prbar_or_nobar
        pop de
        pop hl
        inc e
        ld a,l
        cpl
        and 7 ;если l&7=0, то прибавляем 3... если 7, то прибавляем 0
        rra
        add a,e
        ld e,a
        bit 0,l
        jr z,$+4
         ld c,0x10         
        ld b,SCRTRACKWID/8
prtrack_bars0
        push de
        call prbar
        pop de
        ld a,e
        add a,4
        ld e,a
        djnz prtrack_bars0

        call setpgroots
        ret

        macro BARPIXEL
        ld a,(de)
        or c
        ld (de),a
        endm
        
        macro NOBARPIXEL
        ld a,(de)
        cpl
        or c
        cpl
        ld (de),a
        endm
        
nobar
;c=0x10/0x01
        dup 7
        NOBARPIXEL
        inc d
        edup
        NOBARPIXEL
        ret

prbar_or_nobar
        jr nz,nobar
prbar
;l=lefttime
        ld a,l
        add a,8
        ld l,a
        and 3*8
        jr z,prbar_lined
prbar_dotted
;c=0x10/0x01
        BARPIXEL
        inc d
        NOBARPIXEL
        inc d
        BARPIXEL
        inc d
        NOBARPIXEL
        inc d
        BARPIXEL
        inc d
        NOBARPIXEL
        inc d
        BARPIXEL
        inc d
        NOBARPIXEL
        ret

prbar_lined
        ld a,l
        and 3*16
        jr z,prbar_solid
;c=0x10/0x01
        BARPIXEL
        inc d
        BARPIXEL
        inc d
        BARPIXEL
        inc d
        NOBARPIXEL
        inc d
        BARPIXEL
        inc d
        BARPIXEL
        inc d
        BARPIXEL
        inc d
        NOBARPIXEL
        ret

prbar_solid
;c=0x10/0x01
        dup 7
        BARPIXEL
        inc d
        edup
        BARPIXEL
        ret

;========================== init =====================
gennotefont
        ld hl,notefont
        ld de,notefont+1
        ld bc,2*2048-1 ;digfont тоже
        ld (hl),l;0
        ldir
        
        ld hx,font/256
        ld de,digfont+1
        ld hl,tdigfont
        ld bc,62*256+8
        call gennotefont120
        
        ld hl,tpausefont
        ld de,notefont+(NOTE_GLISS&0xff)
        ld bc,2*256+8
        ld hx,font/256
        call gennotefont120

        ld e,NOTE_LOWEST
        ld c,7
        ld hx,font/256
        ld d,notefont/256+1
        call gennotefont12 ;ноты сдвинуты вниз
        ld c,8
        ld hx,font/256
        ld d,notefont/256
        call gennotefont12
        ld c,7
        ld hx,font/256+1
        ld d,notefont/256
        ;call gennotefont12 ;ноты сдвинуты вверх
        ;ret

gennotefont12
;c=nlines
;hx=font/256+
;d=notefont/256+
        ld hl,tnotefont
        ld b,12
gennotefont120
        push bc
        push hl
        ld l,(hl)
        ld a,hx
        ld h,a;font/256
        push de
        ld b,c
gennotefont121
        ld a,(hl)
        inc h
        ld (de),a
        inc d
        djnz gennotefont121
        pop de
        pop hl
        pop bc
        inc hl
        inc e ;next symbol in notefont
        djnz gennotefont120
        ret

tpausefont
        db "-|"
tnotefont
;в шрифте начиная с кода 1
        db "CcDdEFfGgAaB"
tdigfont
;в шрифте начиная с кода 1
        db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
