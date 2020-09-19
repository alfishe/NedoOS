        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"


tracks=0x8000
MAXTIME=1000
NTRACKS=14
tracks_sz=MAXTIME*NTRACKS
SCRNTRACKS=14
TRACKX=8
SCRTRACKWID=64-TRACKX

NOTE_SPACE=-2
NOTE_PAUSE=-1

        include "struct.asm"

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT
        ld e,3+0x80 ;6912 + keep gfx pages
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld e,0
        OS_CLS
        
        ld a,(user_scr0_high) ;ok
        SETPG16K
        
        ld hl,0x5800
        ld de,0x5801
        ld bc,0x2ff
        ld (hl),7
        ldir

        ld hl,tracks
        ld de,tracks+1
        ld bc,tracks_sz-1
        ld (hl),'a';0
        ldir

        ld hl,wasfrq
        ld de,tfrq
        ld b,96
refrq0
        ld a,(hl)
        ld (de),a
        inc hl
        inc d
        ld a,(hl)
        ld (de),a
        inc hl
        dec d
        inc e
        djnz refrq0
        ld a,e
        sub 3*12
        ld l,a
        ld h,d
refrq1
        ld a,(hl)
        add a,3
        srl a
        srl a
        srl a
        ld (de),a
        inc l
        inc d
        xor a
        ld (de),a
        dec d
        inc e
        jp p,refrq1
        ld l,0
;notes -128..-1 equal to 0
refrq2
        ld a,(hl)
        ld (de),a
        inc d
        inc h
        ld a,(hl)
        ld (de),a
        dec h
        dec d
        inc e
        jr nz,refrq2

        call gennotefont
        if 1==0
        ld de,0x4000
        ld c,0xf
        ld a,0
testprnote0
        push af
        call prcharnote
        pop af
        inc a
        cp 3*12
        jr nz,testprnote0
        jr $
        endif

;for example: 0=bass/pad, 2=tone, 5=drum
        ld ix,Adrum
        ld (ix+chnout.keepme_in),5
        ld de,smp_snare
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Bdrum
        ld (ix+chnout.keepme_in),5
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Cdrum
        ld (ix+chnout.keepme_in),5
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Atone
        ld (ix+chnout.keepme_in),2
        ld de,smp_tone
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Btone
        ld (ix+chnout.keepme_in),2
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Ctone
        ld (ix+chnout.keepme_in),2
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Apad
        ld (ix+chnout.keepme_in),0
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Bbass
        ld (ix+chnout.keepme_in),0
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d
        ld ix,Cpad
        ld (ix+chnout.keepme_in),0
        ld (ix+chnout.smp_in),e
        ld (ix+chnout.smp_in+1),d

;;;;;;;;;;;;;;;;;;;;;
        call setneedredraw
mainloop
        call updatescr
        call prcurcur
mainloop_nokey
        YIELDGETKEYLOOP
        or a
        jr z,mainloop_nokey
        push af
        call prcurcur
        pop af
        ld hl,mainloop
        push hl
        cp key_left
        jp z,untr_left
        cp key_right
        jp z,untr_right
        cp key_up
        jp z,untr_up
        cp key_down
        jp z,untr_down
        cp key_enter
        jp z,untr_play
        cp key_del
        jp z,untr_del
        cp key_ins
        jp z,untr_ins
        cp key_backspace
        jp z,untr_backspace
        cp ' '
        jp z,untr_space
        cp 'a'
        jp z,untr_pause
        cp key_esc
        jp z,untr_quit
        ld hl,tnotekeys
        ld bc,3*12
        cpir
        ret nz
        ld a,c
        push af
        call getcuraddr
        pop af
        ld (hl),a
        
        ld ix,Adrum
        ld a,1
        call initchnnote
        ld ix,Atone
        ld a,2
        call initchnnote
testsmp0
        halt
        ld ix,Atone
        call playsample
        ld ix,Adrum
        call playsample
        ld iy,Atone
        ld ix,Adrum
        call mixchn
        ld ix,Adrum
        ld hl,Btone;drum
        ld de,Ctone;drum
        ld iy,chip0
;ix=fromA
;hl=fromB
;de=fromC
;iy=chip
        call rendchip
        ld hl,chip0
        call outchip
        call checknotekeys_pressed
        
        jr nz,testsmp0
        
        call shutay
        
untr_afternotekey
        call setneedredraw
        jp untr_right

initchnnote
;a=track
        call getcuraddr_tracka
        ld a,(hl)
        ld (ix+chnout.note_in),a;3*12 ;C-4
        ld e,(ix+chnout.smp_in)
        ld (ix+chnout.smpcuraddr),e
        ld e,(ix+chnout.smp_in+1)
        ld (ix+chnout.smpcuraddr+1),e
        ret

untr_pause
        call getcuraddr
        ld (hl),NOTE_PAUSE
        jp untr_afternotekey
      
untr_space
        call getcuraddr
        ld (hl),NOTE_SPACE
        jp untr_afternotekey
      
untr_backspace
        ld hl,(curtime)
        ld a,h
        or l
        ret z
        call untr_left

untr_del
        call getcuraddr
        push hl
        call getendaddr
        pop de ;de=curaddr
        push hl ;hl=endaddr
        or a
        sbc hl,de
        ld de,NTRACKS
        call _DIV. ;hl = hl/de
        ex de,hl
        inc de
;de=число нот до конца трека        
;0x0101 - 1 проход
;0x0102 - 2 прохода
;0x0100 - 256 проходов
;0x0201 - 257 проходов
;b=LSB
;hx=HSB = ((num-1)/256)+1
        ld b,e
        dec de
        inc d
        ld hx,d
        
        pop hl
        
        ld de,-NTRACKS
        ld c,NOTE_SPACE
untr_del0
        ld a,c
        ld c,(hl)
        ld (hl),a
        add hl,de
        djnz untr_del0
        dec hx
        jr nz,untr_del0
        
        jr setneedredraw
        
untr_ins
        call getcuraddr
        push hl ;hl=endaddr
        push hl
        call getendaddr
        pop de ;de=curaddr
        or a
        sbc hl,de
        ld de,NTRACKS
        call _DIV. ;hl = hl/de
        ex de,hl
        inc de
;de=число нот до конца трека        
;0x0101 - 1 проход
;0x0102 - 2 прохода
;0x0100 - 256 проходов
;0x0201 - 257 проходов
;b=LSB
;hx=HSB = ((num-1)/256)+1
        ld b,e
        dec de
        inc d
        ld hx,d

        pop hl

        ld de,NTRACKS
        ld c,NOTE_SPACE
untr_ins0
        ld a,c
        ld c,(hl)
        ld (hl),a
        add hl,de
        djnz untr_ins0
        dec hx
        jr nz,untr_ins0
        jr setneedredraw

untr_quit        
        QUIT

shutay
        ld de,0x0e00
shutay0
        dec d
        ld bc,0xfffd
        out (c),d
        ld b,0xbf
        out (c),e
        jr nz,shutay0
        ret


checknotekeys_pressed
        ld a,0x81
        in a,(0xfe)
        cpl
        and 0x1f
        ret nz
        ld a,0x7f ;space..B
        in a,(0xfe)
        cpl
        and 0x1c ;BNM
        ret nz
        ld a,0xfe ;cs..V
        in a,(0xfe)
        cpl
        and 0x1e
        ret

untr_up
        ld hl,curtrack
        ld a,(hl)
        or a
        ret z
        dec (hl)
        ld a,(hl)
        ld hl,toptrack
        cp (hl)
        ret nc
        dec (hl)
setneedredraw
        ld a,1
        ld (untr_needredraw),a
        ret

untr_down
        ld hl,curtrack
        ld a,(ntracks)
        dec a
        cp (hl)
        ret z
        inc (hl)
        ld c,(hl)
        ld hl,toptrack
        ld a,(hl)
        add a,SCRNTRACKS
        ld b,a
        ld a,c
        cp b
        ret c
        inc (hl)
        jr setneedredraw

untr_right
        ld hl,(curtime)
        ld de,MAXTIME-1
        or a
        sbc hl,de
        add hl,de
        ret nc
        inc hl
        ld (curtime),hl
        ex de,hl
        ld hl,(lefttime)
        ld bc,SCRTRACKWID
        add hl,bc
        ex de,hl ;de=lefttime+SCRTRACKWID
        or a
        sbc hl,de
        add hl,de
        ret c
        ld hl,(lefttime)
        inc hl
        ld (lefttime),hl
        jr setneedredraw

untr_left
        ld hl,(curtime)
        ld a,h
        or l
        ret z
        dec hl
        ld (curtime),hl
        ld de,(lefttime)
        or a
        sbc hl,de
        add hl,de
        ret nc
        dec de
        ld (lefttime),de
        jr setneedredraw

untr_play
        ret

getcuraddr
        ld a,(curtrack)
getcuraddr_tracka
        ld hl,(curtime)
        ld d,h
        ld e,l
        add hl,hl
        add hl,de
        add hl,hl ;*6
        add hl,de ;*7
        add hl,hl ;*14
        ld de,tracks
        add hl,de
        ld e,a
        ld d,0
        add hl,de
;hl=addr
        ret
        
getendaddr
        ld hl,tracks+(MAXTIME-1)*NTRACKS
        ld a,(curtrack)
        ld e,a
        ld d,0
        add hl,de
;hl=addr ;последний байт трека
        ret

;hl / de
;out: hl
_DIV.
	ld c,h
	ld a,l
	ld hl,0
	ld b,16
;don't mind carry
_DIV0.
;shift left hlca
	rla
	rl c
	adc hl,hl
;no carry
;try sub
	sbc hl,de
	jr nc,$+3
	add hl,de
;carry = inverted bit of result
	djnz _DIV0.
	rla
	cpl
	ld l,a
	ld a,c
	rla
	cpl
	ld h,a
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

ttypes
        db "Master",13
        db "Adrum",13
        db "Atone",13
        db "Apad",13
        db "Avol",13
        db "Avib 1",13
        db "Bdrum",13
        db "Btone",13
        db "Bbass",13
        db "Bvol",13
        db "Cdrum",13
        db "Ctone",13
        db "Cpad",13
        db "Cvol",13
        db 0

Adrum
        chnout
Atone
        chnout
Apad
        chnout
Bdrum
        chnout
Btone
        chnout
Bbass
        chnout
Cdrum
        chnout
Ctone
        chnout
Cpad
        chnout
chip0
        chip
        
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
        ld a,c
        xor 0xff
        ld c,a
        ret m
        inc e
        ret

ntracks
        db 14
lefttime
        dw 0
curtime
        dw 0
curtrack
        db 0
toptrack
        db 0

getcurx
        push bc
        ld hl,(curtime)
        ld bc,(lefttime)
        or a
        sbc hl,bc
        ld a,l
        add a,TRACKX
        pop bc
;a=x
        ret

getcury
        ld a,(curtrack)
        ld hl,toptrack
        sub (hl)
;a=y
        ret

prcurcur
        call getcurx
        ld c,a
        call getcury
        ld b,a

prcur
;bc=YX
;0b000YYyyy 0b00XXXXXx
;0b010YY000 0byyyXXXXX
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
        ret

updatescr
;TODO по модели вьювера
untr_needredraw=$+1
        ld a,0
        or a
        ret z
        xor a
        ld (untr_needredraw),a
        ld de,0x4000
        ld c,0x0f
        ld hl,ttypes
        call prtext
        ;jr $
        ld hl,(lefttime)
        ld d,h
        ld e,l
        add hl,hl
        add hl,de
        add hl,hl ;*6
        add hl,de ;*7
        add hl,hl ;*14
        ld de,tracks
        add hl,de
        ld de,0x4000+(TRACKX/2)
        ld b,SCRNTRACKS
updatescr_tracks0
        push bc
        push de
        push hl
        ld c,0x0f
        call prtrack
        pop hl
        inc hl
        pop de
        ld a,e
        add a,32
        ld e,a
        jr nc,$+6
         ld a,d
         add a,8
         ld d,a
        pop bc
        djnz updatescr_tracks0
        ret

prtrack
;hl=addr
;de=scr
        ld b,SCRTRACKWID
prtrack0
        ld a,(hl)
        call prcharnote
        push bc
        ld bc,SCRNTRACKS
        add hl,bc
        pop bc
        djnz prtrack0
        ret

        include "mix.asm"

        macro tn msk,semi,vol,frq,noi
        db msk,semi,vol
        dw frq
        db noi
        endm

C4ADD=-3353
smp_snare
;-0288 00 TN- F (+3353 для орнамента -96)
;+0202 06 TN- C
;-0512 06 TN- B
;-0970 06 TN- A
;      06 -N- 9
;      06 -N- 8
;      05 -N- 7
;      05 -N- 6
;      05 -N- 5
;      05 -N- 4
;      05 -N- 3
;      05 -N- 2
;      05 -N- 1
            ;fsrohENT  ;s ;v ;f       ;n
        tn 0b11000011,-96,15,C4ADD+288,0
        tn 0b11000011,-96,12,C4ADD-202,6
        tn 0b11000011,-96,11,C4ADD+512,6
        tn 0b11000011,-96,10,C4ADD+970,6
        db 0b00000010,     9,          6
        db 0b00000010,     8,          6
        db 0b00000010,     7,          5
        db 0b00000010,     6,          5
        db 0b00000010,     5,          5
        db 0b00000010,     4,          5
        db 0b00000010,     3,          5
        db 0b00000010,     2,          5
        db 0b00000010,     1,          5
        db 0b00001000,     0
        db -1
        dw -2-2 ;loop to line with hole

        macro t4 msk,vol
        db msk|0b01000000,2*12,vol
        endm

smp_tone
        t4 0b00000001,15
        t4 0b00000001,14
        t4 0b00000001,14
        t4 0b00000001,14
        t4 0b00000001,14
        t4 0b00000001,13
        t4 0b00000001,13
        t4 0b00000001,13
        t4 0b00000001,13
        t4 0b00000001,12
        t4 0b00000001,12
        t4 0b00000001,12
        t4 0b00000001,12
        t4 0b00000001,11
        t4 0b00000001,11
        t4 0b00000001,11
        t4 0b00000001,11
        t4 0b00000001,10
        t4 0b00000001,10
        t4 0b00000001,10
        t4 0b00000001,10
        t4 0b00000001,9
        t4 0b00000001,9
        t4 0b00000001,9
        t4 0b00000001,9
        t4 0b00000001,8
        t4 0b00000001,8
        t4 0b00000001,8
        t4 0b00000001,8
        t4 0b00000001,7
        t4 0b00000001,7
        t4 0b00000001,7
        t4 0b00000001,7
        t4 0b00001000,0
        db -1
        dw -2-2 ;loop to line with hole

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

gennotefont
        ld hl,notefont
        ld de,notefont+1
        ld bc,2048-1
        ld (hl),0
        ldir
        
        ld e,0
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
        call gennotefont12 ;ноты сдвинуты вверх
        ret

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

tnotekeys
        db "MJNHBGVCDXSZ"
        db "mjnhbgvcdxsz"
        db ".-,^*",ssG,"/?",ssD,ssX,ssS,ssZ
tnotefont
        db "CcDdEFfGgAaB"
        
        align 256
tfrq
        ds 512
        align 256
font
        incbin "64qua.fnt"
notefont
        ds 2048
wasfrq
        incbin "tb_st.bin"  

cmd_end


	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
