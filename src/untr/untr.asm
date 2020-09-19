        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"


tracks=0x8000
MAXTIME=1000
tracks_sz=MAXTIME*14
SCRNTRACKS=14
TRACKX=8
SCRTRACKWID=64-TRACKX

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
        push af
        
        ld ix,chnA
        ld (ix+chnout.note_in),3*12 ;C-4
        ld (ix+chnout.keepme_in),2 ;for example: 0=bass/pad, 1=tone, 2=drum
        ld b,20
        ld hl,smp_snare
testsmp0
        push bc
        halt
        ld ix,chnA
        call playsample
        push hl
        ld ix,chnA
        ld hl,chnB
        ld de,chnC
        ld iy,chip0
;ix=fromA
;hl=fromB
;de=fromC
;iy=chip
        call rendchip
        ld hl,chip0
        call outchip
        pop hl
        pop bc
        djnz testsmp0
        
        call getcuraddr
        pop af
        ld (hl),a
        jr setneedredraw
        
        QUIT

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

getcuraddr
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
        ld a,(curtrack)
        ld e,a
        ld d,0
        add hl,de
;hl=addr
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

prchar
        push de
        push hl
        ld h,font/256
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
        call prchar
        push bc
        ld bc,SCRNTRACKS
        add hl,bc
        pop bc
        djnz prtrack0
        ret

        STRUCT chip
retriggers BYTE ;A,B,C
Atonefrq WORD
Btonefrq WORD
Ctonefrq WORD
noisefrq BYTE
masks   BYTE ;!AT,!BT,!CT,!AN,!BN,!CN
Avolume BYTE
Bvolume BYTE
Cvolume BYTE
envfrq  WORD
envtype BYTE ;+retrigenvbit
        ENDS

;masks (T,N,E,hole,outerenv,retrigtone)
;+-96 semitone shift
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1)
;+-4095 tonefrq shift
;16 volume
;32 noisefrq
;16*2 envtype +retrigenvbit
;в этой структуре накопления запрещены!
        STRUCT chnout
note_in BYTE
keepme_in BYTE ;priority for keep on top (bigger is more priority)
tonefrq WORD ;0..32767 (cut to 0..4095)
masks   BYTE ;T,N,E,hole,outerenv,retrigtone ;дырка управляется отдельно!!! т.к. уровень для !T!N отличается от T vol 0
keepme  BYTE ;priority for keep on top (bigger is more priority)
volume  BYTE ;volume = +-127 (cut to 0..15)
noisefrq BYTE ;noise = 0..255 (cut to 0..31)
envtype BYTE ;+retrigenvbit
envfrq  WORD
        ENDS

MASKBIT_T=0
MASKBIT_N=1
MASKBIT_E=2
MASKBIT_HOLE=3
MASKBIT_OUTERENV=4
MASKBIT_RETRIGTONE=5

retrigenvbit=7

filtervolume
;ix=from=to
;e=volume shift (+-15)
        ld a,(ix+chnout.volume)
        add a,e
        ld (ix+chnout.volume),a
        ret po ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
        ret

filternoise
;ix=from=to
;e=noise shift (+-15)
        ld a,(ix+chnout.noisefrq)
        add a,e
        ld (ix+chnout.noisefrq),a
        ret po ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
        ret

filtertone
;ix=from=to
;de=tone shift (+-4095)
        ld a,(ix+chnout.tonefrq)
        add a,e
        ld e,a
        ld a,(ix+chnout.tonefrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chnout.tonefrq),e
        ld (ix+chnout.tonefrq+1),d
        ret

filterenv
;ix=from=to
;de=env shift
        ld a,(ix+chnout.envfrq)
        add a,e
        ld e,a
        ld a,(ix+chnout.envfrq+1)
        adc a,d
        ld d,a
        jp p,$+6
         ld de,0
        ld (ix+chnout.envfrq),e
        ld (ix+chnout.envfrq+1),d
        ret

mixchn
;ix=from1=to
;iy=from2
;в release должен быть понижен приоритет канала
;если в from1 есть огибающая, то игнорируем from1, если его KEEPME <= чем у from2
;т.к. огибающую должен перекрывать тональник!!!
        bit MASKBIT_E,(ix+chnout.masks)
        jr nz,mixchn_keep2
;если в from1 есть шум, то игнорируем from2, если его KEEPME <= чем у from1
        ;bit MASKBIT_N,(ix+chnout.masks)
        ;jr nz,mixchn_keep1
;если в from2 дырка, то берём from1
        bit MASKBIT_HOLE,(iy+chnout.masks)
        jr nz,mixchn_keep1
;если в from1 дырка, то берём from2
        bit MASKBIT_HOLE,(iy+chnout.masks)
        jr nz,mixchn_keep2
;берём самый громкий по тональнику
;TODO низкие ноты не считать громкими
        ld a,(iy+chnout.volume)
        add a,0x80
        ld e,a
        ld a,(ix+chnout.volume)
        add a,0x80
        cp e
        jr c,mixchn_keep2
mixchn_keep1
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep2outerenv
        ld a,(ix+chnout.keepme)
        cp (iy+chnout.keepme)
        ret nc ;при равенстве keepme оставляем from1
        jr mixchn_keep2_ok
mixchn_keep2
        bit MASKBIT_OUTERENV,(iy+chnout.masks)
        jr nz,mixchn_keep1outerenv
        ld a,(iy+chnout.keepme)
        cp (ix+chnout.keepme)
        jr c,mixchn_keep1 ;при равенстве keepme оставляем from2
mixchn_keep2_ok
        push iy
        pop hl
        push ix
        pop de
        ld bc,chnout
        ldir
        ret
mixchn_keep1outerenv
        ld a,(iy+chnout.envfrq)
        ld (ix+chnout.envfrq),a
        ld a,(iy+chnout.envfrq+1)
        ld (ix+chnout.envfrq+1),a
        ret
mixchn_keep2outerenv
        push iy
        pop hl
        push ix
        pop de
        ld bc,chnout
        ldir
        ld a,(ix+chnout.envfrq)
        ld (iy+chnout.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chnout.envfrq+1),a
        ret

;надо в дырке такое поведение:
;       ||
;      |||        
;|||||||||____
;т.е. в дырке ставим громкость 0 (а не маску !T!N)
rendchip
;ix=fromA
;hl=fromB
;de=fromC
;iy=chip
        push de ;fromC
        push hl ;fromB
        ld bc,0x00ff ;b=ретриггеры A,B,C ;c=masks: все выключены
        ld d,b ;текущий приоритет шума
        ld e,b ;текущий приоритет огибающей
        ld h,(iy+chip.envtype) ;бывший тип огибающей
        res retrigenvbit,h

        xor a
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Anoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Anoenv
        ld e,(ix+chnout.keepme) ;текущий приоритет огибающей
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
        ld a,16
rendchip_Anoenv
        ld (iy+chip.Avolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Anotone
        dec c ;res 0,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Atonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Atonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+3
        inc b ;set 0,b сумма ретриггеров
rendchip_Anotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Anonoise
        res 3,c
        ld d,(ix+chnout.keepme) ;текущий приоритет шума
        ld a,(ix+chnout.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Anonoise

        pop ix ;fromB
        xor a
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Bnoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Bnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Buseenv
        ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
rendchip_Buseenv
        ld a,16
rendchip_Bnoenv
        ld (iy+chip.Bvolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Bnotone
        res 1,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Btonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Btonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+4
         set 1,b ;сумма ретриггеров
rendchip_Bnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Bnonoise
        res 4,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Bnonoise
        ld d,a
        ld a,(ix+chnout.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Bnonoise
        
        pop ix ;fromC
        xor a
        bit MASKBIT_HOLE,(ix+chnout.masks)
        jr nz,rendchip_Cnoenv
        ld a,(ix+chnout.volume)
        cp 16
        jr c,$+7
         rla
         sbc a,a
         cpl
         and 15
        bit MASKBIT_E,(ix+chnout.masks)
        jr z,rendchip_Cnoenv
        ld a,(ix+chnout.keepme)
        cp e ;текущий приоритет огибающей
        jr c,rendchip_Cuseenv
        ;ld e,a
        ld a,(ix+chnout.envfrq)
        ld (iy+chip.envfrq),a
        ld a,(ix+chnout.envfrq+1)
        ld (iy+chip.envfrq+1),a
        ld l,(ix+chnout.envtype) ;текущий тип огибающей
rendchip_Cuseenv
        ld a,16
rendchip_Cnoenv
        ld (iy+chip.Cvolume),a
        bit MASKBIT_T,(ix+chnout.masks)
        jr z,rendchip_Cnotone
        res 2,c
        ld a,(ix+chnout.tonefrq+1)
        cp 4096/256
        jr c,$+4
         ld a,-1 ;overflow
        ld (iy+chip.Ctonefrq+1),a
        jr nc,$+5 ;overflow
         ld a,(ix+chnout.tonefrq)
        ld (iy+chip.Ctonefrq),a
        bit MASKBIT_RETRIGTONE,(ix+chnout.masks)
        jr z,$+4
         set 2,b ;сумма ретриггеров
rendchip_Cnotone
        bit MASKBIT_N,(ix+chnout.masks)
        jr z,rendchip_Cnonoise
        res 5,c
        ld a,(ix+chnout.keepme)
        cp d ;текущий приоритет шума
        jr c,rendchip_Cnonoise
        ;ld d,a
        ld a,(ix+chnout.noisefrq)
        cp 32
        jr c,$+5;7
         rla
         sbc a,a
         cpl
         ;and 31
        ld (iy+chip.noisefrq),a
rendchip_Cnonoise

        ld (iy+chip.retriggers),b
        ld (iy+chip.masks),c
        ld a,l
        cp h ;несовпадение в том числе при retrigenvbit (в h он сброшен)
        ret z
         set retrigenvbit,a
         ld (iy+chip.envtype),a ;текущий тип огибающей
        ret

outchip
;hl=chip (байт флагов ретриггера (ABC) + 13 байт данных AY)
        xor a
        LD C,0xfd
        LD E,0xBF
        bit 0,(hl)
        jr z,outchip_noretrigA
        ld d,0
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigA
        bit 1,(hl)
        jr z,outchip_noretrigB
        ld d,2
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigB
        bit 2,(hl)
        jr z,outchip_noretrigC
        ld d,4
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
        inc d
        ld b,0xff
        out (c),d
        ld b,e
        out (c),a
outchip_noretrigC
        inc hl
        ;xor a
        ld d,0xff
       dup 12
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        inc a
       edup
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        bit retrigenvbit,(hl)
        ret z ;no env retrigger
        inc a
        ld b,d;0xff
        OUT (C),a
        LD B,E
        OUTI
        ret

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

;Sample:
;256 masks (T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent), одна из комбинаций означает loop (например, -1)
noisefrqpresent=1
envtypepresent=2
semitoneshiftpresent=6
tonefrqshiftpresent=7
;+-96 semitone shift (в потоке при наличии semitoneshiftpresent)
;+-96 env semitone shift (fair tone ratio guaranteed for 1:1, 3:4, 1:2, 1:4, 3:1, 5:2, 2:1, 3:2 + 4:1) (в потоке при наличии E)
;8*2 envtype + retrigenv (в потоке при наличии E)
;16 volume (в потоке при отсутствии E)
;+-4095 tonefrq shift (в потоке при наличии tonefrqshiftpresent)
;32 noisefrq (в потоке при наличии N)
;>1 >256 loop addrshift

playsample_loop
        ld e,(hl)
        inc hl
        ld d,(hl)
        add hl,de
playsample
;ix=chnout
;в любом случае полностью определяет текущие значения полей chnout:
;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenv)
;volume  BYTE ;volume = 0..15 (в потоке при отсутствии E)
;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N)
;keepme  BYTE ;priority for keep on top (bigger is more priority)
;envfrq  WORD
;tonefrq WORD
        ld b,(hl) ;masks
        inc hl
        inc b
        jr z,playsample_loop
        dec b
        ld (ix+chnout.masks),b ;masks   BYTE ;T,N,E,hole,outerenv,retrigtone, semitoneshiftpresent,tonefrqshiftpresent (должен быть первым байтом строки в потоке)
        ld a,(ix+chnout.note_in)

        bit semitoneshiftpresent,b
        jr z,playsample_nosemitoneshift
        add a,(hl)
        inc hl
        jp po,playsample_nosemitoneshift ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
playsample_nosemitoneshift

        bit envtypepresent,b
        jr z,playsample_noenvsemitoneshift
        add a,(hl) ;envsemitoneshift
        ld e,a
        ld d,tfrq/256
;cout env frq (use frq table)
        ld a,(de)
        ld c,a
        inc d
        ld a,(de)
        ;ld d,a
        ld (ix+chnout.envfrq),c
        ld (ix+chnout.envfrq+1),a;d
;count tone frq (TODO use ratio)
;временная затычка - частота тона по частотной таблице без envsemitoneshift
        ld a,e
        sub (hl)
        ld e,a
        ld a,(de)
        ld c,a
        dec d
        ld a,(de)
        ld e,a
        ld d,c
        ;ld a,(hl) ;envsemitoneshift

        inc hl
        ld a,(hl)
        inc hl
        ld (ix+chnout.envtype),a ;envtype BYTE (в потоке при наличии E, значения 8..15 (15 как 4, 9 как 1) + retrigenvbit) ;тип огибающей без E не используется
        jr playsample_noenvsemitoneshiftq
playsample_noenvsemitoneshift
;count tone frq (use frq table)
        ld e,a
        ld d,tfrq/256
;cout env frq (use frq table)
        ld a,(de)
        ld c,a
        inc d
        ld a,(de)
        ld d,a
        ld e,c
        ld a,(hl)
        inc hl
        ld (ix+chnout.volume),a ;volume  BYTE ;volume = 0..15 ;громкость при E не используется
playsample_noenvsemitoneshiftq

        bit tonefrqshiftpresent,b
        jr z,playsample_notonefrqshift
        ld a,(hl)
        add a,e
        ld e,a
        inc hl
        ld a,(hl)
        adc a,d
        ld d,a ;correct tone frq
        inc hl
playsample_notonefrqshift
        ld (ix+chnout.tonefrq),e
        ld (ix+chnout.tonefrq+1),d
        
        bit noisefrqpresent,b
        jr z,playsample_nonoisefrq
        ld a,(hl)
        inc hl
        ld (ix+chnout.noisefrq),a ;noisefrq BYTE ;noise = 0..31 (в потоке при наличии N) ;noisefrq без N не используется
playsample_nonoisefrq
        ld a,(ix+chnout.keepme_in)
        ld (ix+chnout.keepme),a ;keepme  BYTE ;priority for keep on top (bigger is more priority)

;out: hl=next line in sample
        ret

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

chnA
        chnout
chnB
        chnout
chnC
        chnout
chip0
        chip
        

        
        align 256
tfrq
        ds 512
        align 256
font
        incbin "64qua.fnt"
wasfrq
        incbin "tb_st.bin"  

cmd_end


	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
