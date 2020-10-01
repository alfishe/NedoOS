        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

OLDTTYPES=0

freemem_start=0x8000

MAXTIME=65536;4096

MAXNTRACKS=64

SCRNTRACKS=23;8
TRACKX=8
SCRTRACKWID=64-TRACKX

NOTE_SPACE=0 ;надо удобно на уровне mem! на уровне mem упаковывать
NOTE_GLISS=0xfe
NOTE_PAUSE=0xff
NOTE_LOWEST=1;0

COLOR=7
TIMECOLOR=0x04
TYPESCOLOR=0x06

        include "struct.asm"

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT
        ld e,3+0x80 ;6912 + keep gfx pages
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;ld e,0
        ;OS_CLS

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (pgroots),a
        ;ld a,l
        ;ld (pgdynmem),a

        call cls
        call setscrpg
        ld hl,0x5800
        ld de,0x5801
        ld bc,0x0020
        ld (hl),TIMECOLOR
        ldir
        push hl
        ld bc,4
        ld (hl),TYPESCOLOR
        ldir
        ld bc,31-4
        ld (hl),COLOR
        ldir
        pop hl
        ld bc,0x02c0
        ldir
        call gennotefont
        call setpgroots

        ld hl,0x4000
        ld de,0x4001
        ld bc,0x3fff
        ld (hl),l;0
        ldir ;чистим roots

        call initmem
        ld c,1
        call pokecurtime_curtrack_c ;set part 0 in the beginning

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
        rra
        rra
        rra
        and 0x1f
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

;for example: 0=bass/pad, 2=tone, 5=drum
        ld ix,emptychn
        ;ld (ix+chn.keepme_in),5
        ld de,smp_pause
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),0
        ;call initchnnote_pause ;делает nogliss
       if 1==0
        ld ix,Adrum
        ;ld (ix+chn.keepme_in),5
        ;ld de,smp_snare
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Bdrum
        ;ld (ix+chn.keepme_in),5
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Cdrum
        ;ld (ix+chn.keepme_in),5
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),2
        call initchnnote_pause
        ld ix,Atone
        ;ld (ix+chn.keepme_in),2
        ;ld de,smp_tone
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Btone
        ;ld (ix+chn.keepme_in),2
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Ctone
        ;ld (ix+chn.keepme_in),2
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),2
        call initchnnote_pause
        ld ix,Apad
        ;ld (ix+chn.keepme_in),0
        ;ld (ix+chn.smp_in),smp_maj&0xff
        ;ld (ix+chn.smp_in+1),smp_maj/256
        ;ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Bbass
        ;ld (ix+chn.keepme_in),0
        ;ld (ix+chn.smp_in),smp_bass&0xff
        ;ld (ix+chn.smp_in+1),smp_bass/256
        ;ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Cpad
        ;ld (ix+chn.keepme_in),0
        ;ld (ix+chn.smp_in),e
        ;ld (ix+chn.smp_in+1),d
        ;ld (ix+chn.channel_in),2
        call initchnnote_pause

        ;ld ix,Filter_Avib
        ;ld (ix+filter.handler),filterhandler_vib&0xff
        ;ld (ix+filter.handler+1),filterhandler_vib/256
        ;ld (ix+filter.par1),50
        ;ld (ix+filter.par2),5
        ;ld ix,Filter_Avol
        ;ld (ix+filter.handler),filterhandler_vol&0xff
        ;ld (ix+filter.handler+1),filterhandler_vol/256
        ;ld ix,Filter_Bvol
        ;ld (ix+filter.handler),filterhandler_vol&0xff
        ;ld (ix+filter.handler+1),filterhandler_vol/256
        ;ld ix,Filter_Cvol
        ;ld (ix+filter.handler),filterhandler_vol&0xff
        ;ld (ix+filter.handler+1),filterhandler_vol/256
       endif

;;;;;;;;;;;;;;;;;;;;;
        ;call setneedredraw
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
         cp key_tab
         jp z,tracksloop
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
        cp key_pgup
        jp z,untr_pgup
        cp key_pgdown
        jp z,untr_pgdown
        cp key_home
        jp z,untr_home
        cp key_end
        jp z,untr_end
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
        cp key_esc
        jp z,untr_quit

        push af
;смотрим тип текущего канала
        ld a,(curtrack)
        call gettracktype
        and CHNTYPEMASK
        cp CHNTYPE_NOTES
        jr z,enternote
        pop af
        call keytodigit
        call pokecurtime_curtrack_c
untr_afternotekey_alltracksiforder
        call setneedredraw_alltracksiforder
        jp untr_afternotekey;untr_right

keytodigit
;ввод цифры 0..9a..zA..Z -> 1..62 (пробел -> 0)
;out: CY=error
        sub ' '
        ld c,a;0
        jr z,enterdigok
        sub '0'-' '
        cp 10
        ld c,1
        jr c,enterdigok
        sub 'a'-'0'
        cp 26
        ld c,1+10
        jr c,enterdigok
        sub 'A'-'a'
        cp 26
        ld c,1+10+26
        ccf
        ret c ;wrong digit!
enterdigok
        add a,c
        ld c,a
        ret

enternote
        pop af
        cp 'a'
        jp z,untr_pause
        cp 'f'
        jp z,untr_keygliss

        ld hl,tnotekeys
        ld bc,3*12
        cpir
        ret nz
         inc c ;add c,NOTE_LOWEST
        call pokecurtime_curtrack_c

untr_afternotekey
        call inittracks ;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
        call initnote

        call setneedredraw_curtrack
        call updatescr

playnote0
        halt
        call playnote
        call checknotekeys_pressed
        jr nz,playnote0

        call shutay

        ;call setneedredraw
        jp untr_right

untr_keygliss
        ld c,NOTE_GLISS
        jr untr_pauseq
untr_pause
        ld c,NOTE_PAUSE
untr_pauseq
        call pokecurtime_curtrack_c
        jp untr_afternotekey

untr_space
        ld c,NOTE_SPACE
        call pokecurtime_curtrack_c
        jp untr_afternotekey_alltracksiforder

tracksloop
        call updatescr
        call prtrackscur
tracksloop_nokey
        YIELDGETKEYLOOP
        or a
        jr z,tracksloop_nokey
        push af
        call prtrackscur
        pop af
         cp key_tab
         jp z,mainloop
        ld hl,tracksloop
        push hl
        cp key_left
        jp z,tracks_left
        cp key_right
        jp z,tracks_right
        cp key_up
        jp z,untr_up
        cp key_down
        jp z,untr_down
        cp key_ins
        jp z,tracks_ins
        cp key_del
        jp z,tracks_del
        ;push af
        ld hl,(curtrack)
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl ;*8
tracks_curx=$+1
        ld bc,0
        add hl,bc
        ld bc,ttypes
        add hl,bc
        ;pop af
        call keytodigit ;out: CY=error, a=digit
        ret c
        ld (hl),a
        jp setneedprtypes

tracks_ins
        ld hl,ntracks
        ld a,(hl)
        cp MAXNTRACKS
        ret z
        inc (hl)
;вставить трек в tracks
        ld hl,tracks_end-1-4
        ld de,tracks_end-1
;если мы на треке a=MAXNTRACKS-2, то надо сдвинуть 4 байта (1 строчку)
;если мы на треке a=MAXNTRACKS-3, то надо сдвинуть 4*2 байта (2 строчки)
;значит, надо сдвинуть MAXNTRACKS-a-1 строчек
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        add a,a
        add a,a
        ld c,a
        ld b,0
        lddr
;вставить трек в ttypes
        ld hl,ttypes_end-1-8
        ld de,ttypes_end-1
        add a,a
        ld c,a
        ;ld b,0
        rl b
        lddr
;сдвинуть roots треков, начиная с curtrack
        ld a,(curtrack)
        ld hl,0x4000+0x3eff
        ld de,0x4000+0x3fff
        cpl
        add a,64;MAXNTRACKS
        ld b,a
        ;ld c,0
        lddr
        inc hl
        ld d,h
        ld e,l
        inc de
        ld (hl),l;0
        dec c ;bc=0x00ff
        ldir

        jp setneedprtracks

tracks_del
        ld hl,ntracks
        ld a,(hl)
        dec a
        ret z
        dec (hl)
;очистить трек
        ld hl,0
        ld lx,0 ;part=0..63
tracks_del0
        ld a,(curtrack)
;lx=part
;a=track
        call getendaddr
        ex de,hl
tracks_del1
        ld a,(curtrack)
        ld c,0 ;c=data
;hl=index
;lx=part
;a=track
;c=data
        call poketrackpartindex_c
        ld a,h
        or l
        dec hl
        jr nz,tracks_del1
        inc lx
        ld a,lx
        cp 64
        jr nz,tracks_del0
        
;удалить трек в tracks
        ld a,(curtrack)
        or a
        ret z ;don't delete order
        add a,a
        add a,a
        ld e,a
        ld d,0
        ld hl,tracks
        add hl,de
        ld d,h
        ld e,l
        inc hl
        inc hl
        inc hl
        inc hl
;если мы на треке a=MAXNTRACKS-2, то надо сдвинуть 4 байта (1 строчку)
;если мы на треке a=MAXNTRACKS-3, то надо сдвинуть 4*2 байта (2 строчки)
;значит, надо сдвинуть MAXNTRACKS-a-1 строчек
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        add a,a
        add a,a
        push af
        ld c,a
        ld b,0
        ldir
;удалить трек в ttypes
        ld a,(curtrack)
        add a,a
        add a,a
        add a,a
        ld e,a
        ld d,b;0
        ld hl,ttypes
        add hl,de
        ld d,h
        ld e,l
        ld c,8
        add hl,bc
        pop af
        add a,a
        ld c,a
        ;ld b,0
        rl b
        ldir

;сдвинуть roots треков, начиная с curtrack
        ld a,(curtrack)
        add a,0x40
        ld d,a
        inc a
        ld h,a
        ld l,0
        ld e,l;0
        ld a,(curtrack)
        cpl
        add a,64;MAXNTRACKS
        ld b,a
        ;ld c,0
        ldir
        
        call cls
        jp setneedprtracks

tracks_left
        ld hl,tracks_curx
        ld a,(hl)
        or a
        ret z
        dec (hl)
        ret

tracks_right
        ld hl,tracks_curx
        ld a,(hl)
        cp 6;7
        ret z
        inc (hl)
        ret

;A0gO123

;bass, pad и tone имеют параметры:
;сэмпл
;громкость
;смещение в сэмпле
;рабочая октава

;фильтр имеет параметры:
;тип фильтра (g=gain, Vv=vib/gliss up/down, Ee=env(vib/gliss up/down), n=noise down)
;для вибрато: глубина (0=бесконечность, т.е. gliss)
;для вибрато: период
;для вибрато и глисса: скорость изменения

playnote
        call playnote_tracksplaysample

        ;call filter_all_tracks

        ld a,2
        call mixchn_all_channela
        push ix ;chn для C
        ld a,1
        call mixchn_all_channela
        push ix ;chn для B
        ld a,0
        call mixchn_all_channela
        ;push ix ;chn для A

        ;ld iy,Atone
        ;ld ix,Adrum
        ;call mixchn

;TODO что делать, если нет ни одного трека для какого-то канала?
;надо как-то использовать chnempty
        ;ld ix,Adrum
        ;ld hl,Btone;drum
        ;ld de,Ctone;drum
        ;pop ix ;chn для A
        pop hl ;chn для B
        pop de ;chn для C
        ld iy,chip0
;ix=fromA
;hl=fromB
;de=fromC
;iy=chip
        call rendchip
        ld hl,chip0
        call outchip
        ret

untr_play
        call inittracks ;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
        jr playenter0go
playenter0
        halt
          call prcurcur
playenter0go
        call initnote
        call playnote
        halt
        call playnote
        halt
        call playnote
        call untr_right ;TODO check end and loop
         call updatescr
          call prcurcur
          ;jr playenter0
        call checknotekeys_pressed
        jr nz,playenter0

        call shutay

        jp untr_afternotekey

untr_del_popret
        pop hl
        ret

untr_backspace
        ld hl,(curtime)
        ld a,h
        or l
        ret z
        call untr_left
        ;jp untr_del
untr_del
        ld a,(curtrack)
        ld hl,(curtime)
        call tracktime_totrackpartindex
;hl=index
;lx=part
;a=track
        push hl ;hl=curaddr
        call getendaddr ;de=end or 0
        ex de,hl
        pop de ;de=curaddr
        push hl ;hl=endaddr
        xor a
        sbc hl,de ;endaddr-curaddr
        jr c,untr_del_popret
        ex de,hl
        inc de
;de=число нот до конца трека включительно
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

        pop hl ;hl=endaddr

        ;ld de,-NTRACKS
        ld c,NOTE_SPACE
;hl=index
;lx=part
untr_del0
        push de
        ld a,(curtrack)
        call poketrackpartindex_c ;c<->mem(hl)
        pop de
         dec hl ;add hl,de
        djnz untr_del0
        dec hx
        jr nz,untr_del0

        jp setneedredraw_alltracksiforder

untr_ins
        ld a,(curtrack)
        ld hl,(curtime)
        call tracktime_totrackpartindex
;hl=index
;lx=part
;a=track
        push hl ;hl=curaddr
        push hl ;hl=curaddr
        call getendaddr ;de=end or 0
        ex de,hl
        pop de ;de=curaddr
        or a
        sbc hl,de ;endaddr-curaddr
        jr c,untr_del_popret
        ex de,hl
        inc de
        inc de
;de=число нот до конца трека включительно
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

        pop hl ;hl=curaddr

        ;ld de,NTRACKS
        ld c,NOTE_SPACE
;hl=index
;lx=part
untr_ins0
        push de
        ld a,(curtrack)
        call poketrackpartindex_c ;c<->mem(hl)
        pop de
         inc hl ;add hl,de
        djnz untr_ins0
        dec hx
        jr nz,untr_ins0
        jr setneedredraw_alltracksiforder

untr_quit
        QUIT

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

untr_home
;переход на начало текущей части
        ld a,(curtrack)
        ld hl,(curtime)
       if 1==1
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
       else
;тест поиска непустого на месте или влево
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        ld a,(curtrack)
        call getroot ;out: hl=root
;hl=track root (4 bytes: left poi, right poi)
;de=index
        call findleft ;out: de=nonempty index (or 0), a=data
        ex de,hl
        ld a,h
        and 7
        ld h,a
       endif
        jp untr_pgdown_ok

untr_end
;переход на конец текущей части в текущем канале
        ld a,(curtrack)
        ld hl,(curtime)
       if 1==1
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
        push hl ;beg
        call getroot ;out: hl=root
        ld de,0xffff
;hl=track root (4 bytes: left poi, right poi)
;de=index
        call findleft ;de=end index
        pop hl ;beg
        add hl,de ;time=index+beg (beg=time-index)
       else
;тест поиска непустого на месте или вправо
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        call getroot ;out: hl=root
;hl=track root (4 bytes: left poi, right poi)
;de=index
        call findright ;out: de=nonempty index (or 0xffff), a=data
        ex de,hl
        ld a,h
        and 7
        ld h,a
       endif
        jp untr_pgdown_ok

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
        ret;jp setneedprtypes ;setneedredraw

setneedredraw_alltracksiforder
        ld a,(curtrack)
        or a
        call z,setneedpralltracks ;keep a!
setneedredraw_curtrack
        ;ld a,1
        ;ld (untr_needredraw),a ;forced redraw (even if lefttime has not changed)
        ld a,(curtrack)
        call gettracktype
        set 7,(hl)
        ret
setneedpralltracks
;keep a!
        ld hl,tracks
        ld a,(ntracks)
        ld b,a
setneedpralltracks0
        set 7,(hl)
        inc hl
        inc hl
        inc hl
        inc hl
        djnz setneedpralltracks0
        ;ld a,55 ;"scf"
        ;ld (needpralltracks),a
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
        ret;jp setneedprtypes;setneedredraw

checkeof
        ld de,MAXTIME-1
        or a
        sbc hl,de
        add hl,de
        ret c
        ld h,d
        ld l,e
        ret ;nc=eof, hl=eof time

untr_pgdown
        ld hl,(curtime)
         ;inc hl
         ;inc hl
         ;inc hl
         ;inc hl
         ;inc hl
        ld a,l
        and 0xf8
        ld l,a
        ld bc,8
        add hl,bc
        ret c
        call checkeof
untr_pgdown_ok
        ld (curtime),hl
;установим курсор в центр, если это возможно
        ld bc,SCRTRACKWID/2
        xor a
        sbc hl,bc
        jr nc,$+4
         ld h,a
         ld l,a
        push hl
        add hl,bc
        pop hl
        jr nc,$+5
         ld hl,0x10000-(SCRTRACKWID/2)
        ld (lefttime),hl
        ret

untr_right
        ld hl,(curtime)
        call checkeof ;nc=eof
        ret nc
        inc hl
;untr_right_ok
        ld (curtime),hl
        ex de,hl
        ld hl,(lefttime)
        ld bc,SCRTRACKWID
        add hl,bc
        ex de,hl ;de=lefttime+SCRTRACKWID
        or a
        sbc hl,de
        add hl,de ;curtime < (lefttime+SCRTRACKWID)?
        ret c
        ld hl,(lefttime)
        inc hl
        ld (lefttime),hl
        ret

untr_pgup
        ld hl,(curtime)
        ld a,h
        or l
        ret z
        dec hl
         ;dec hl
         ;dec hl
         ;dec hl
         ;dec hl
        ld a,l
        and 0xf8
        ld l,a
        jr untr_pgdown_ok

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
        ret

ttypes
        if OLDTTYPES
        db "ORDER ",13
        db "drum *",13
        db "tone *",13
        db "vib 1*",13
        db "pad  *",13
        db "vol   ",13
         ;db "vol   ",13
        db "drum *",13
        db "tone *",13
        db "vol   ",13
        db "bass *",13
        db "drum *",13
        db "tone *",13
        db "pad  *",13
        db "vol   "
        db 0

        else
;A0gOS2v*
        db  0, 0,_O, 0, 0, 0, 0, 0;"  O     "
        db _A,_5,_d,_O, 0, 0,_f, 0;"A5dO  f "
        db _A,_2,_t,_O,_t, 0,_f, 0;"A2tOt f "
        db  0, 0,_V,_O,_3,_1,_1, 0;"  VO311 "
        db _A,_0,_t,_O,_p,_1,_f, 0;"A0tOp1f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        db _B,_5,_d,_O, 0, 0,_f, 0;"B5dO  f "
        db _B,_2,_t,_O,_t, 0,_f, 0;"B2tOt f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        db _B,_0,_t,_O,_b, 0,_f, 0;"B0tOb f "
        db _C,_5,_d,_O, 0, 0,_f, 0;"C5dO  f "
        db _C,_5,_t,_O,_t, 0,_f, 0;"C2tOt f "
        db _C,_0,_t,_O,_p,_1,_f, 0;"C0tOp1f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        ds ttypes+(MAXNTRACKS*8)-$
ttypes_end
        endif

tsamples
;0
        dw smp_pause
;1 '0'
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause
        dw smp_pause ;10 '9'
;11 'a'
        dw smp_pause ;a
        dw smp_bass ;b
        dw smp_pause ;c
        dw smp_pause ;d
        dw smp_pause ;e
        dw smp_pause ;f
        dw smp_pause ;g
        dw smp_pause ;h
        dw smp_pause ;i
        dw smp_pause ;j
        dw smp_pause ;k
        dw smp_pause ;l
        dw smp_pause ;m
        dw smp_pause ;n
        dw smp_pause ;o
        dw smp_maj ;p
        dw smp_pause ;q
        dw smp_pause ;r
        dw smp_snare ;s
        dw smp_tone ;t
        dw smp_pause ;u
        dw smp_pause ;v
        dw smp_pause ;w
        dw smp_pause ;x
        dw smp_pause ;y
        dw smp_pause ;36 'z'
;37 'A'
        dw smp_pause ;A
        dw smp_pause ;B
        dw smp_pause ;C
        dw smp_pause ;D
        dw smp_pause ;E
        dw smp_pause ;F
        dw smp_pause ;G
        dw smp_pause ;H
        dw smp_pause ;I
        dw smp_pause ;J
        dw smp_pause ;K
        dw smp_pause ;L
        dw smp_pause ;M
        dw smp_pause ;N
        dw smp_pause ;O
        dw smp_pause ;P
        dw smp_pause ;Q
        dw smp_pause ;R
        dw smp_pause ;S
        dw smp_pause ;T
        dw smp_pause ;U
        dw smp_pause ;V
        dw smp_pause ;W
        dw smp_pause ;X
        dw smp_pause ;Y
        dw smp_pause ;62 'Z'

;смотрим тип текущего канала
gettracktype
        add a,a
        add a,a
        ld hl,tracks
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld a,(hl)
        ret

tracks
        CHNTYPE 0x80+CHNTYPE_ORDER  ,0,-1
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Adrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Atone
        CHNTYPE 0x80+CHNTYPE_FILTER ,1,Filter_Avib
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Apad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,Filter_Avol
         ;CHNTYPE 0x80+CHNTYPE_FILTER ,0,Filter_Bvol
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Bdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Btone
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,Filter_Bvol
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Bbass
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Cdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Ctone
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Cpad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,Filter_Cvol
         ;CHNTYPE 0x80+CHNTYPE_FILTER ,0,Filter_Cvol
        ds tracks+(4*MAXNTRACKS)-$,-1
tracks_end
        db -1

emptychn
        chn
Adrum
        chn
Atone
        chn
Apad
        chn
Bdrum
        chn
Btone
        chn
Bbass
        chn
Cdrum
        chn
Ctone
        chn
Cpad
        chn
chip0
        chip
chip1
        chip

Filter_Avib
        filter
Filter_Avol
        filter
Filter_Bvol
        filter
Filter_Cvol
        filter

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
        inc a
;a=y
reter
        ret

prcurcur
        call getcurx
        ld c,a
        call getcury
        ld b,a
        jp prcur

prtrackscur
        ld a,(tracks_curx)
        ld c,a
        call getcury
        ld b,a
        jp prcur

        include "mix.asm"
        include "view.asm"
        include "mem.asm"
        include "play.asm"

        macro tn msk,semi,vol,frq,noi
        db msk,semi,0,vol
        dw frq
        db noi
        endm

        macro tne msk,semi,envsemi,vol,frq,noi
        db msk,semi,envsemi,vol
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
            ;fsrohENT  ;s ;v ;f       ;n (o=outerenv)
        tn 0b11000011,-96,15,C4ADD+288,0
        tn 0b11000011,-96,12,C4ADD-202,6
        tn 0b11000011,-96,11,C4ADD+512,6
        tn 0b11000011,-96,10,C4ADD+970,6
        tn 0b00000010,  0, 9,        0,6
        tn 0b00000010,  0, 8,        0,6
        tn 0b00000010,  0, 7,        0,5
        tn 0b00000010,  0, 6,        0,5
        tn 0b00000010,  0, 5,        0,5
        tn 0b00000010,  0, 4,        0,5
        tn 0b00000010,  0, 3,        0,5
        tn 0b00000010,  0, 2,        0,5
        tn 0b00000010,  0, 1,        0,5
smp_pause
        tn 0b11001000,  0, 0,        0,0
        db -1
        dw -2-SMPLINE ;loop to line with hole

smp_bass
        tne 0b11000100,0,+5*12,0x0e,    0,0
        db -1
        dw -2-SMPLINE ;loop to first line

smp_maj
        tn 0b11000001,2*12+0,11,     0,0
        tn 0b11000001,2*12+4,11,     0,0
        tn 0b11000001,2*12+7,11,     0,0
        db -1
        dw smp_maj-($+1) ;loop to first line

        macro t4 msk,vol
        db msk|0b11000000,2*12,0,vol,  0,0,0
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
        dw -2-SMPLINE ;loop to line with hole

;A0gO123

;bass, pad и tone имеют параметры:
;сэмпл
;громкость
;смещение в сэмпле
 ;канал [рабочая октава не нужна, она в сэмпле]
 ;приоритет

;drum имеет параметры:
;
;громкость
;[смещение в сэмпле не нужно?]
 ;канал [рабочая октава]
 ;приоритет

;фильтр имеет параметры:
;тип фильтра (d=drum channel, t=tone channel(bass/pad/tone), g=gain, Vv=vib/gliss up/down, Ee=env(vib/gliss up/down), n=noise down)
;для вибрато и глисса: скорость изменения
;для вибрато: глубина (0=бесконечность, т.е. gliss)
;для вибрато: период

;0,0,0,0,1,0,0,0,0,-1
;0,0,0,1,1,0,0,0,-1,-1

tnotekeys
        db "MJNHBGVCDXSZ"
        db "mjnhbgvcdxsz"
        db ssM,ssJ,ssN,ssH,ssB,ssG,ssV,ssC,ssD,ssX,ssS,ssZ
        align 256
tfrq
        ds 512
wasfrq
        incbin "tb_st.bin"

cmd_end


	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "../../us/user.l"
