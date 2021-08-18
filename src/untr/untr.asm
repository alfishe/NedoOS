        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

OLDTTYPES=0

;freemem_start=0x8000

MAXTIME=65536;4096

MAXNTRACKS=64

SCRNTRACKS=23;8
TRACKX=8
SCRTRACKWID=64-TRACKX

NOTE_SPACE=0 ;надо удобно на уровне mem! на уровне mem упаковывать
NOTE_GLISS=0xfe
NOTE_PAUSE=0xff
NOTE_RLE=0xe0
NOTE_LOWEST=1;0

COLOR=7
TIMECOLOR=0x04
TYPESCOLOR=0x06

MAXSONGNAME=64

;pgsamples содержит 256 байт на сэмпл (там все, кроме smp_pause), т.е. 37 строчек + зацикливание

        include "struct.asm"

smp_pause=0x4000
smp_snare=0x4000+(_s*256)
smp_tone=0x4000+(_t*256)
smp_maj=0x4000+(_p*256)
smp_bass=0x4000+(_b*256)
smp_crash=0x4000+(_c*256)
smp_drum=0x4000+(_d*256)
smp_hihat=0x4000+(_h*256)
smp_orn1of3=0x4000+(_1*256)
smp_orn2of6=0x4000+(_2*256)

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
        ;ld a,h
        ld (player4000page),a

        OS_NEWPAGE
        ld a,e
        ld (pgsamples),a

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
        
        call setpgsamples
        ld de,0x4000;smp_pause
        ld a,0x40
killsamples0
        ld hl,wassmp_pause
        ld bc,256;szsmp_pause
        ldir
        dec a
        jr nz,killsamples0
        ld hl,wassmp_snare
        ld de,smp_snare
        ld bc,szsmp_snare
        ldir
        ld hl,wassmp_bass
        ld de,smp_bass
        ld bc,szsmp_bass
        ldir
        ld hl,wassmp_maj
        ld de,smp_maj
        ld bc,szsmp_maj
        ldir
        ld hl,wassmp_tone
        ld de,smp_tone
        ld bc,szsmp_tone
        ldir
        ld hl,wassmp_crash
        ld de,smp_crash
        ld bc,szsmp_crash
        ldir
        ld hl,wassmp_drum
        ld de,smp_drum
        ld bc,szsmp_drum
        ldir
        ld hl,wassmp_hihat
        ld de,smp_hihat
        ld bc,szsmp_hihat
        ldir
        ld hl,wassmp_orn1of3
        ld de,smp_orn1of3
        ld bc,szsmp_orn1of3
        ldir
        ld hl,wassmp_orn2of6
        ld de,smp_orn2of6
        ld bc,szsmp_orn2of6
        ldir
        
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
        ;ld (ix+chn.channel_in),0
        call initchnnote_pause ;делает smpcuraddr=smp_pause и nogliss
        call setpgsamples
        call playsample ;после этого канал можно микшировать
        call setpgroots

;;;;;;;;;;;;;;;;;;;;;
        ;call setneedredraw
        call prcurcur
mainloop
        xor a
        ld (tracksmode),a
mainloop_nokey
        YIELD
        call updatescr
        ;call prcurcur
        GET_KEY
        or a
        jr z,mainloop_nokey
        ;push af
        ;call prcurcur
        ;pop af
         cp key_tab
         jp z,tracksloop
        ld hl,mainloop
        push hl
        ld c,0
        cp key_F2
        jp z,untr_save
        cp key_F3
        jp z,untr_load
        cp ss0
        jp z,untr_step0
        cp ss1
        jp z,untr_step1
        cp ss2
        jp z,untr_step2
        cp ss3
        jp z,untr_step3
        cp ss4
        jp z,untr_step4
        cp ss5
        jp z,untr_step5
        cp ss6
        jp z,untr_step6
        cp ss7
        jp z,untr_step7
        cp ss8
        jp z,untr_step8
        cp 'Y'
        jp z,untr_copy
        cp 'Q'
        jp z,untr_setplayall
        cp 'W'
        jp z,untr_setplaybegin
        cp 'E'
        jp z,untr_setplayend
        cp 'R'
        jp z,untr_startplay
        cp 'T'
        jp z,untr_stopplay
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
        cp _t;CHNTYPE_NOTES
        jr z,enternote
        pop af
        call keytodigit
        jr c,untr_afternotekey_alltracksiforder
        push af
        ld a,(newdigit)
        ld (olddigit),a
        pop af
        ld (newdigit),a
        call pokecurtime_curtrack_c
untr_afternotekey_alltracksiforder
        call setneedredraw_alltracksiforder
        jp untr_afternotekey;untr_right

untr_copy
;fromdigit,todigit,csY
        ;ld hy,0 ;track
        ld a,(curtrack)
        ld hy,a
;untr_copy0
        ld a,(olddigit)
        ld ly,a ;part
;ly=part
        ld a,hy ;a=track
        call getendaddr ;de=end or 0
        ex de,hl
untr_copybytes0
;hl=index
olddigit=$+2
        ld ly,0 ;part
        ld a,hy ;a=track
        call peektrackpartindex
        ld c,a
newdigit=$+2
        ld ly,0 ;part
        ld a,hy ;a=track
        call poketrackpartindex_c
        ld a,h
        or l
        dec hl
        jr nz,untr_copybytes0
        ;inc hy
        ;ld a,(ntracks)
        ;cp hy
        ;jr nz,untr_copy0
        jp setneedpralltracks

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

        call setneedredraw_curtrack
        call updatescr

       ld a,(nowplaying)
        or a
        jr nz,untr_afternotekey_noplay

       ld hl,(curtime)
       ld (playtime),hl
        call inittracks ;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
        call initnote

playnote0
        halt
        call playnote
        call checknotekeys_pressed
        jr nz,playnote0

        call shutay
untr_afternotekey_noplay
        ;call setneedredraw
curstep=$+1
        ld b,0
        ld a,b
        or a
        ret z
step0
        push bc
        call untr_right
        pop bc
        djnz step0
        ret

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

untr_step8
        inc c
untr_step7
        inc c
untr_step6
        inc c
untr_step5
        inc c
untr_step4
        inc c
untr_step3
        inc c
untr_step2
        inc c
untr_step1
        inc c
untr_step0
        ld a,c
        ld (curstep),a
        ret

tracksloop
        ld a,1
        ld (tracksmode),a
tracksloop_nokey
        YIELD
        call updatescr
        ;call prtrackscur
        GET_KEY
        or a
        jr z,tracksloop_nokey
        ;push af
        ;call prtrackscur
        ;pop af
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
;если мы на треке a=MAXNTRACKS-2, то надо сдвинуть 4 байта (1 строчку)
;если мы на треке a=MAXNTRACKS-3, то надо сдвинуть 4*2 байта (2 строчки)
;значит, надо сдвинуть MAXNTRACKS-a-1 строчек
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        call amulchnsstep_tohl
        ld b,h
        ld c,l
        ;add a,a
        ;add a,a
        ;ld c,a
        ;ld b,0
        ld hl,tracks_end-1-chnsstep;4
        ld de,tracks_end-1
        lddr
;вставить трек в ttypes
        ld hl,ttypes_end-1-8
        ld de,ttypes_end-1
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        add a,a
        add a,a
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
        ld ly,0 ;part=0..63
tracks_del0
        ld a,(curtrack)
;ly=part
;a=track
        call getendaddr
        ex de,hl
tracks_del1
        ld a,(curtrack)
        ld c,0 ;c=data
;hl=index
;ly=part
;a=track
;c=data
        call poketrackpartindex_c
        ld a,h
        or l
        dec hl
        jr nz,tracks_del1
        inc ly
        ld a,ly
        cp 64
        jr nz,tracks_del0
        
;удалить трек в tracks
        ld a,(curtrack)
        or a
        ret z ;don't delete order
        ;add a,a
        ;add a,a
        ;ld e,a
        ;ld d,0
        call amulchnsstep_tohl
        ld de,tracks
        add hl,de
        ld d,h
        ld e,l
        ld bc,chnsstep
        add hl,bc
;если мы на треке a=MAXNTRACKS-2, то надо сдвинуть chnsstep байт (1 строчку)
;если мы на треке a=MAXNTRACKS-3, то надо сдвинуть chnsstep*2 байт (2 строчки)
;значит, надо сдвинуть MAXNTRACKS-a-1 строчек
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        ;add a,a
        ;add a,a
        ;ld c,a
        ;ld b,0
        push de
        push hl
        call amulchnsstep_tohl
        ld b,h
        ld c,l
        pop hl
        pop de
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
        ld a,(curtrack)
        cpl
        add a,MAXNTRACKS
        add a,a
        add a,a
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

untr_setplaybegin
        ld hl,(curtime)
        ld (playbegin),hl
        ret

untr_setplayend
        ld hl,(curtime)
        ld (playend),hl
        ret

untr_setplayall
        ld hl,0
        ld (playbegin),hl
        ld (playend),hl
        ret

untr_startplay
startplay
        ld a,1
        ld (nowplaying),a
         ld hl,(curtime)
         ld (playtime),hl
        call initplayer
        call inittracks ;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
player4000page=$+1
	 ld a,0
         ld hl,player
         OS_SETMUSIC 
        ret
        
untr_stopplay
stopplay
        xor a
        ld (nowplaying),a
	 ld a,(player4000page)
         ld hl,play_reter
         OS_SETMUSIC 

        call shutay
        ret

untr_play
        call startplay

        jr playenter0_go
        ;OS_GETTIMER ;out: hlde=timer
        ;ld (playenter_oldtimer),de
playenter0
;        OS_GETTIMER ;out: hlde=timer
;        ex de,hl
;playenter_oldtimer=$+1
;        ld de,0
;        ld (playenter_oldtimer),hl
        
        ;call untr_right ;TODO check end and loop
        halt
playenter_curxy=$+1
        ld bc,0
          ;call prcur
playenter0_go
        call updatescr
        call getcurplayx
        ld c,a
        call getcury
        ld b,a
        ld (playenter_curxy),bc
          ;call prcur
          ;jr playenter0
        call checknotekeys_pressed
        jr nz,playenter0
         ld hl,(playtime)
         call untr_pgdown_ok

        call stopplay

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
;ly=part
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
;ly=part
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
;ly=part
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
;ly=part
untr_ins0
        push de
        ld a,(curtrack)
        call poketrackpartindex_c ;c<->mem(hl)
        pop de
         inc hl ;add hl,de
        djnz untr_ins0
        dec hx
        jr nz,untr_ins0
        jp setneedredraw_alltracksiforder

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
        ld hl,(curtime)
        ld a,(curtrack)
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
       ld a,d
       or e
       jr z,untr_home_left
untr_home_ok
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
        jp untr_pgdown_ok
untr_home_left
;уже в начале текущей части, пытаемся найти предыдущую
        ld a,h
        or l
        ret z
        dec hl
        ld a,(curtrack)
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        jr untr_home_ok

untr_end
;переход на конец текущей части в текущем треке
        ld a,(curtrack)
        ld hl,(curtime)
       push hl ;curtime
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
        push hl ;beg
        call getendaddr ;de=end index
        pop hl ;beg
        add hl,de ;time=index+beg (beg=time-index)
       pop de ;curtime
        or a
        sbc hl,de ;time>curtime?
        add hl,de
        jr c,untr_end_findnext
        jp nz,untr_pgdown_ok
untr_end_findnext
        ex de,hl ;hl=curtime
;уже на конце текущей части в текущем треке
;пытаемся найти следующую часть
        ld a,(curtrack)
        inc hl
        push hl
        call gettrackorder ;номер ордера (0=нет)
        pop hl
        or a ;канал подписан на ордер?
        ret z ;не подписан
        ex de,hl
        xor a ;TODO номер канала ордера
        ld ly,0 ;у ордера всегда берём дефолтную часть (part=0), т.к. ордер не подчиняется ордерам
        call getroot
        call findright ;out: de=nonempty index (or 0xffff), a=data (1..62 or 0)
         ld a,d
         and e
         inc a
         ret z
        ex de,hl
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
        call amulchnsstep_tohl
        ld de,chns-2;tracks
        add hl,de
        set 7,(hl)
        ret
setneedpralltracks
;keep a!
        ld ix,chns;tracks
        ld a,(ntracks)
        ld b,a
        ld de,chnsstep
setneedpralltracks0
        set 7,(ix-2);(hl)
        add ix,de
        ;inc hl
        ;inc hl
        ;inc hl
        ;inc hl
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

amulchnsstep_tohl
_=chnsstep
        ld e,a
        ld d,0
        if _&0x80
        ;ld h,d
        ;ld l,e
__=1
        else
        ;ld h,d
        ;ld l,d
__=0
        endif
_=_*2
        dup 7
        if __ != 0
        add hl,hl
__=__*2
        endif
        if _&0x80
        if __ != 0
        add hl,de
        else
        ld h,d
        ld l,e
        endif
__=__+1
        endif
_=_*2
        edup
        ret

getcurplayxonscreen
;out: a=0=offscreen
        call isplayxonscreen
        ld a,0
        ret c
        add hl,bc
        ld a,l
        add a,TRACKX
        ret

isplayxonscreen
;CY=offscreen
        ld hl,(playtime)
        ld bc,(lefttime)
        or a
        sbc hl,bc
        ret c
        ld bc,SCRTRACKWID
        ;or a
        sbc hl,bc
        ccf
        ret

getcurplayx
        push bc
        ld hl,(playtime)
        ld bc,(lefttime)
        or a
        sbc hl,bc
        ld a,l
        add a,TRACKX
        pop bc
;a=x
        ret

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
        ret

prcurcur
        call getcurx
        ld c,a
        call getcury
        ld b,a
        ld (oldcurxonscreen),bc
        jp prcur

        if 1==0
prtrackscur
        ld a,(tracks_curx)
        ld c,a
        call getcury
        ld b,a
        ld (oldcurxonscreen),bc
        jp prcur
        endif

findsamplelengthandloop
;find sample length and loop line
;hl=sample
;out: e=length, d=loopsize
        ld de,0 ;e=length, d=loopsize
        ld bc,7
findsamplelength0
        inc e ;length = 1..
        add hl,bc
        ld a,(hl)
        inc a
        jr nz,findsamplelength0
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        add hl,bc
;hl=sampleloop
        ld bc,7
findsampleloop0
        inc d ;loopsize = 1..
        add hl,bc
        ld a,(hl)
        inc a
        jr nz,findsampleloop0
        ret

        include "view.asm"
        include "scroll.asm"
        include "save.asm"

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

C8ADD=0x000f-0x0ef8

wassmp_drum
;-0187 01 TN- F (+3353 для орнамента -96)
;-0352 00 T-- E
;-0608 00 T-- D
            ;fsrohENT  ;s ;v ;f       ;n (o=outerenv)
        tn 0b11000011,-96,15,C4ADD+187,1
        tn 0b11000001,-96,15,C4ADD+352,0
        tn 0b11000001,-96,15,C4ADD+608,0
        tn 0b11001000,  0, 0,        0,0
        db -1
        dw -2-SMPLINE ;loop to line with hole
szsmp_drum=$-wassmp_drum

wassmp_hihat
;+0471 05 TN- F (+3353 для орнамента -96)
;+0471 04 TN- D
;+0471 04 -N- C
;+0471 03 -N- B
;+0471 03 -N- A
;+0471 02 -N- 9
;+0471 02 -N- 8
;+0471 01 -N- 7
;+0471 01 -N- 5
;+0471 01 -N- 5
;+0471 01 -N- 4
;+0471 01 -N- 4
;+0471 01 -N- 3
;+0471 01 -N- 3
;+0471 01 -N- 2
;+0471 01 -N- 2
;+0471 01 -N- 1
;+0471 01 -N- 1
            ;fsrohENT  ;s ;v ;f       ;n (o=outerenv)
        tn 0b11000011,-96,15,C4ADD-471,5
        tn 0b11000011,-96,13,C4ADD-471,4
        tn 0b11000010,-96,12,C4ADD-471,4
        tn 0b11000010,-96,11,C4ADD-471,3
        tn 0b11000010,-96,10,C4ADD-471,3
        tn 0b11000010,-96, 9,C4ADD-471,2
        tn 0b11000010,-96, 8,C4ADD-471,2
        tn 0b11000010,-96, 7,C4ADD-471,1
        tn 0b11000010,-96, 5,C4ADD-471,1
        tn 0b11000010,-96, 5,C4ADD-471,1
        tn 0b11000010,-96, 4,C4ADD-471,1
        tn 0b11000010,-96, 4,C4ADD-471,1
        tn 0b11000010,-96, 3,C4ADD-471,1
        tn 0b11000010,-96, 3,C4ADD-471,1
        tn 0b11000010,-96, 2,C4ADD-471,1
        tn 0b11000010,-96, 2,C4ADD-471,1
        tn 0b11000010,-96, 1,C4ADD-471,1
        tn 0b11000010,-96, 1,C4ADD-471,1
        tn 0b11001000,  0, 0,        0,0
        db -1
        dw -2-SMPLINE ;loop to line with hole
szsmp_hihat=$-wassmp_hihat

wassmp_crash ;B-8!!!
;-0000 07 TN- F
;-0000 10 -N- E
;-0000 10 TN- E
;-0000 14 -N- D
;-0000 14 -N- C
;-0000 14 -N- C
;-0000 14 -N- C
;-0000 14 -N- B
;-0000 14 -N- B
;-0000 14 -N- B etc
            ;fsrohENT  ;s ;v ;f       ;n (o=outerenv)
        tn 0b11000011,-96,15,C8ADD+0,7
        tn 0b11000010,-96,14,C8ADD+0,10
        tn 0b11000011,-96,14,C8ADD+0,10
        tn 0b11000010,-96,13,C8ADD+0,14
        tn 0b11000011,-96,12,C8ADD+0,14
        tn 0b11000011,-96,12,C8ADD+0,14
        tn 0b11000011,-96,12,C8ADD+0,14
        tn 0b11000011,-96,11,C8ADD+0,14
        tn 0b11000011,-96,11,C8ADD+0,14
        tn 0b11000011,-96,11,C8ADD+0,14
        tn 0b11000011,-96,10,C8ADD+0,14
        tn 0b11000011,-96,10,C8ADD+0,14
        tn 0b11000011,-96,10,C8ADD+0,14
        tn 0b11000011,-96, 9,C8ADD+0,14
        tn 0b11000011,-96, 9,C8ADD+0,14
        tn 0b11000011,-96, 9,C8ADD+0,14
        tn 0b11000011,-96, 8,C8ADD+0,14
        tn 0b11000011,-96, 8,C8ADD+0,14
        tn 0b11000011,-96, 8,C8ADD+0,14
        tn 0b11000011,-96, 7,C8ADD+0,14
        tn 0b11000011,-96, 7,C8ADD+0,14
        tn 0b11000011,-96, 7,C8ADD+0,14
        tn 0b11000011,-96, 6,C8ADD+0,14
        tn 0b11000011,-96, 6,C8ADD+0,14
        tn 0b11000011,-96, 6,C8ADD+0,14
        tn 0b11000011,-96, 5,C8ADD+0,14
        tn 0b11000011,-96, 5,C8ADD+0,14
        tn 0b11000011,-96, 5,C8ADD+0,14
        tn 0b11000011,-96, 4,C8ADD+0,14
        tn 0b11000011,-96, 4,C8ADD+0,14
        tn 0b11000011,-96, 4,C8ADD+0,14
        tn 0b11000011,-96, 3,C8ADD+0,14
        tn 0b11000011,-96, 3,C8ADD+0,14
        tn 0b11000011,-96, 3,C8ADD+0,14
        tn 0b11000011,-96, 2,C8ADD+0,14
        ;tn 0b11000011,-96, 2,C8ADD+0,14
        ;tn 0b11000011,-96, 2,C8ADD+0,14
        ;tn 0b11000011,-96, 1,C8ADD+0,14
        ;tn 0b11000011,-96, 1,C8ADD+0,14
        ;tn 0b11000011,-96, 1,C8ADD+0,14
        tn 0b11001000,  0, 0,        0,0
        db -1
        dw -2-SMPLINE ;loop to line with hole
szsmp_crash=$-wassmp_crash

wassmp_snare
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
wassmp_pause
        tn 0b11001000,  0, 0,        0,0
        db -1
        dw -2-SMPLINE ;loop to line with hole
szsmp_pause=$-wassmp_pause
szsmp_snare=$-wassmp_snare

wassmp_bass
        tne 0b11000100,0,+5*12,0x0e,    0,0
        db -1
        dw -2-SMPLINE ;loop to first line
szsmp_bass=$-wassmp_bass

wassmp_maj
        tn 0b11000001,2*12+0,11,     0,0
        tn 0b11000001,2*12+4,11,     0,0
        tn 0b11000001,2*12+7,11,     0,0
        db -1
        dw wassmp_maj-($+1) ;loop to first line
szsmp_maj=$-wassmp_maj

        macro t4 msk,vol
        db msk|0b11000000,2*12,0,vol,  0,0,0
        endm

wassmp_orn2of6
        tn 0b11001000,  0, 0,        0,0
        tn 0b11001000,  0, 0,        0,0
        tn 0b11001000,  0, 0,        0,0
        tn 0b11001000,  0, 0,        0,0
        tn 0b11000001,2*12+0,15,     0,0
        tn 0b11000001,2*12+0,15,     0,0
        db -1
        dw wassmp_orn2of6-($+1) ;loop to first line
szsmp_orn2of6=$-wassmp_orn2of6

wassmp_orn1of3
        tn 0b11001000,  0, 0,        0,0
        tn 0b11001000,  0, 0,        0,0
        tn 0b11000001,2*12+0,15,     0,0
        db -1
        dw wassmp_orn1of3-($+1) ;loop to first line
szsmp_orn1of3=$-wassmp_orn1of3

wassmp_tone
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
szsmp_tone=$-wassmp_tone

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
wasfrq
        incbin "tb_st.bin"

        ds 0x8000-$
tfrq
        ds 512
        include "mem.asm"
        include "play.asm"
        include "mix.asm"

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
        db _D,_0,_t,_O,_p, 0,_f, 0;"D0tOp1f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        db _B,_5,_d,_O, 0, 0,_f, 0;"B5dO  f "
        db _B,_2,_t,_O,_t, 0,_f, 0;"B2tOt f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        db _B,_0,_t,_O,_b, 0,_f, 0;"B0tOb f "
        db _C,_5,_d,_O, 0, 0,_f, 0;"C5dO  f "
        db _C,_5,_t,_O,_t, 0,_f, 0;"C2tOt f "
        db _C,_0,_t,_O,_p, 0,_f, 0;"C0tOp1f "
        db  0, 0,_g, 0, 0, 0, 0, 0;"  g     "
        ds ttypes+(MAXNTRACKS*8)-$
ttypes_end
        endif

;смотрим тип текущего канала
gettracktype
        push de
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,ttypes+2
        add hl,de
        ld a,(hl)
        pop de
        ret

gettrackorder
        push de
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,ttypes+3
        add hl,de
        ld a,(hl)
        pop de
        ret

tracks
chns=tracks+2
        CHNTYPE 0x80+CHNTYPE_ORDER  ,0;,0;-1
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1;,0;Adrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Atone
        CHNTYPE 0x80+CHNTYPE_FILTER ,1;,0;Filter_Avib
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Apad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0;,0;Filter_Avol
         ;CHNTYPE 0x80+CHNTYPE_FILTER ,0,0;Filter_Bvol
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1;,0;Bdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Btone
        CHNTYPE 0x80+CHNTYPE_FILTER ,0;,0;Filter_Bvol
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Bbass
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1;,0;Cdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Ctone
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1;,0;Cpad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0;,0;Filter_Cvol
         ;CHNTYPE 0x80+CHNTYPE_FILTER ,0;,0;Filter_Cvol
        ds tracks+(chnsstep*MAXNTRACKS)-$,-1
tracks_end
        ;db -1

emptychn
        chn

chip0
        chip
chip1
        chip


lefttime
        dw 0
playtime
        dw 0
curtime
        dw 0
curtrack
        db 0
toptrack
        db 0
ntracks
        db 14 ;числотреков N

        align 4
freemem_start
cmd_end


	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "untr.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "../../us/user.l"
