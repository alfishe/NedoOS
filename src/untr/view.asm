prcharnote
        push de
        push hl
        ld h,notefont/256
        jr prchar_h
prchar
        push de
        push hl
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
        pop hl
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
        call prchar
        jr prtext0
prtext_cr
prtext_cr_c=$+1
        ld c,0
prtext_cr_de=$+1
        ld de,0
        ld a,e
        add a,32
        ld e,a
        jr nc,prtext0keepde
        ld a,d
        add a,8
        ld d,a
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

        align 256
font
        incbin "64qua.fnt"
notefont
        ds 2048

;;;;;;;;;;;;;;;;;;;;;;;;; high level view ;;;;;;;;;;;;;;;;;;;;;;;;
updatescr
;TODO по модели вьювера
untr_needredraw=$+1
        ld a,0
        or a
        ret z
        xor a
        ld (untr_needredraw),a
        ld de,0x4001
        ld c,0x0f
        ld hl,ttypes
        call prtext

        call prchannels

;TODO обновлять только треки, которые изменились
        ld de,0x4000+(TRACKX/2)
        ld b,SCRNTRACKS
        ld c,0
updatescr_tracks0
        push bc
        push de
        ld hx,c ;track
        ld a,c ;track
        ld hl,(lefttime)
        call tracktime_toaddr
        ld c,0x0f
        call prtrack
        pop de
        ld a,e
        add a,32
        ld e,a
        jr nc,$+6
         ld a,d
         add a,8
         ld d,a
        pop bc
        inc c
        djnz updatescr_tracks0
        
;TODO показывать время только при скролле (по одной цифре)
        ld de,0x48c0+(TRACKX/2)
        ld b,SCRTRACKWID
        ld c,0x0f
        ld hl,(lefttime)
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
        call prchar
        inc hl
        inc c
        djnz updatescr_time0
        
        ret

prchannels
        ld hl,channels
        ld de,0x4000
prchannels0
        ld a,(hl) ;chntype
        inc a
        ret z
        inc hl
        ;ld a,(hl) ;order
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ;cp CHNTYPE_...-1
        ld a,b
        and c
        inc a
        jr z,prchannels0skip
        push de
        push hl
        ld hx,b
        ld lx,c
        ld c,0x0f
        ld a,(ix+chn.channel_in)
        add a,'A'
        call prchar
        ld a,(ix+chn.keepme_in)
        add a,'0'
        call prchar
        pop hl
        pop de
prchannels0skip
        ld a,e
        add a,32
        ld e,a
        jr nc,$+6
         ld a,d
         add a,8
         ld d,a
        jr prchannels0

prtrack
;hl=addr
;de=scr
;hx=track
        push hl
        ld a,hx
        call getchntype
        ld hl,prcharnote
        cp CHNTYPE_NOTES
        jr z,$+5
         ld hl,prchar
        ld (prtrack_prproc),hl
        pop hl

        push de
        ld b,SCRTRACKWID
prtrack0
        push de
        ld a,hx
        call peekaddr
        pop de
prtrack_prproc=$+1
        call prcharnote
         inc hl
        djnz prtrack0
        pop de
        
        call setscrpg

        ld hl,(lefttime)
        ld c,0x01
        dec e
        push hl
        ld a,l
        sub 8
        ld l,a
        ld a,l
        and 7
        push de
        call z,prbar
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

prbar
        ld a,l
        add a,8
        ld l,a
        and 3*8
        jr z,prbar_lined
prbar_dotted
;c=0x10/0x01
        ld a,(de)
        or c
        ld (de),a
        inc d
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        inc d
        ld a,(de)
        or c
        ld (de),a
        ret

prbar_lined
        ld a,l
        and 3*16
        jr z,prbar_solid
;c=0x10/0x01
        ld a,(de)
        or c
        ld (de),a
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        ld a,(de)
        or c
        ld (de),a
        inc d
        ld a,(de)
        or c
        ld (de),a
        ret

prbar_solid
;c=0x10/0x01
        dup 7
        ld a,(de)
        or c
        ld (de),a
        inc d
        edup
        ld a,(de)
        or c
        ld (de),a
        ret

;========================== init =====================
gennotefont
        ld hl,notefont
        ld de,notefont+1
        ld bc,2048-1
        ld (hl),l;0
        ldir
        
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

tnotefont
        db "CcDdEFfGgAaB"
