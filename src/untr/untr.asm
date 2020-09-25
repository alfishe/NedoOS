        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

freemem_start=0x8000
;tracks=freemem_start
MAXTIME=65536;4096
NTRACKS=14
;tracks_sz=MAXTIME*NTRACKS
SCRNTRACKS=14
TRACKX=8
SCRTRACKWID=64-TRACKX

NOTE_SPACE=0;-2 ;надо удобно на уровне mem! на уровне mem упаковывать
NOTE_PAUSE=-1
NOTE_LOWEST=1;0

        include "struct.asm"

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT
        ld e,3+0x80 ;6912 + keep gfx pages
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0
        OS_CLS

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (pgroots),a
        ;ld a,l
        ;ld (pgdynmem),a

        ld hl,0x4000
        ld de,0x4001
        ld bc,0x3fff
        ld (hl),l;0
        ldir ;чистим roots

        call setscrpg
        ld hl,0x5800
        ld de,0x5801
        ld bc,0x2ff
        ld (hl),7
        ldir
        call gennotefont
        call setpgroots

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

;for example: 0=bass/pad, 2=tone, 5=drum
        ld ix,Adrum
        ld (ix+chn.keepme_in),5
        ld de,smp_snare
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Bdrum
        ld (ix+chn.keepme_in),5
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Cdrum
        ld (ix+chn.keepme_in),5
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),2
        call initchnnote_pause
        ld ix,Atone
        ld (ix+chn.keepme_in),2
        ld de,smp_tone
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Btone
        ld (ix+chn.keepme_in),2
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Ctone
        ld (ix+chn.keepme_in),2
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),2
        call initchnnote_pause
        ld ix,Apad
        ld (ix+chn.keepme_in),0
        ld (ix+chn.smp_in),smp_maj&0xff
        ld (ix+chn.smp_in+1),smp_maj/256
        ld (ix+chn.channel_in),0
        call initchnnote_pause
        ld ix,Bbass
        ld (ix+chn.keepme_in),0
        ld (ix+chn.smp_in),smp_bass&0xff
        ld (ix+chn.smp_in+1),smp_bass/256
        ld (ix+chn.channel_in),1
        call initchnnote_pause
        ld ix,Cpad
        ld (ix+chn.keepme_in),0
        ld (ix+chn.smp_in),e
        ld (ix+chn.smp_in+1),d
        ld (ix+chn.channel_in),2
        call initchnnote_pause

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
;ввод цифры 0..9A..Za..z -> 1..62
        sub '0'
        cp 10
        ld c,1
        jr c,enterdigok
        sub 'A'-'0'
        cp 26
        ld c,1+10
        jr c,enterdigok
        sub 'a'-'A'
        cp 26
        ld c,1+10+26
        ret nc ;wrong digit!
enterdigok
        add a,c
        ld c,a
        call pokecurtime_curtrack_c
untr_afternotekey_alltracksiforder
        call setneedredraw_alltracksiforder
        jp untr_afternotekey;untr_right
        
enternote
        pop af
        cp 'a'
        jp z,untr_pause
        
        ld hl,tnotekeys
        ld bc,3*12
        cpir
        ret nz
         inc c ;add c,NOTE_LOWEST
        call pokecurtime_curtrack_c

untr_afternotekey
        call playnote_inittracks

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

playnote_inittracks
        ld a,0x80 ;точно не совпадёт, так что будет retrigenv
        ld (chip0+chip.envtype),a
        ld hl,tracks
        ld hy,0 ;track
playnote_inittracks0
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
        jr z,playnote_inittracks0skip
        ld hx,b
        ld lx,c
        push hl
        ld a,hy
;a=track
        ;ld a,(ix+chn.channel_in)
        push ix
        call peekcurtime_tracka
        pop ix
        pop hl
         cp NOTE_SPACE
         jr z,playnote_inittracks0pause
        call initchnnote ;устанавливает сэмпл, как указано в канале
playnote_inittracks0skip
        inc hy ;track
        jr playnote_inittracks0
playnote_inittracks0pause
        call initchnnote_pause ;устанавливает сэмпл паузы
        jr playnote_inittracks0skip

playenter_inittracks
;инициализирует ноты в каналах в процессе проигрывания
        ld hl,tracks
        ld hy,0 ;track
playenter_inittracks0
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
        jr z,playenter_inittracks0skip
        ld hx,b
        ld lx,c
        push hl
        ld a,hy
;a=track
        ;ld a,(ix+chn.channel_in)
        push ix
        call peekcurtime_tracka
        pop ix
        pop hl
        call initchnnote ;устанавливает сэмпл, как указано в канале
playenter_inittracks0skip
        inc hy ;track
        jr playenter_inittracks0

playnote_tracksplaysample
        ld hl,tracks
playnote_tracksplaysample0
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
        jr z,playnote_tracksplaysample0skip
        push hl
        ld hx,b
        ld lx,c
        call playsample
        pop hl
playnote_tracksplaysample0skip
        jr playnote_tracksplaysample0

playnote
        call playnote_tracksplaysample
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
        
;TODO что делать, если нет ни одного подканала для какого-то канала?
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
        call playnote_inittracks

playenter0
        halt
        call playenter_inittracks
        call playnote
        halt
        call playnote
        halt
        call playnote
        call untr_right ;TODO check end and loop
        call checknotekeys_pressed
        jr nz,playenter0
        
        call shutay
        
        jp untr_afternotekey

mixchn_all_channela
;a=channel=0..2
;out: ix=chn, куда всё смикшировалось
;микшируем сверху вниз все подканалы, у которых канал == a
         ld (mixchn_all_channela_a),a
        ld ix,0
        ld hl,tracks
mixchn_all_channela0
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
        jr z,mixchn_all_channela0skip
        ld hy,b
        ld ly,c ;подходящий подканал попадает в iy
mixchn_all_channela_a=$+1
        ld a,0
        cp (iy+chn.channel_in)
        jr nz,mixchn_all_channela0skip
        ld a,hx
        or lx
        jr z,mixchn_all_channela0_first ;первый подходящий подканал попадает в ix
        push hl
        call mixchn
        pop hl
        jr mixchn_all_channela0_firstq
mixchn_all_channela0_first
        ld hx,b
        ld lx,c
mixchn_all_channela0_firstq
mixchn_all_channela0skip
        jr mixchn_all_channela0
        
initchnnote
;a=note
        cp NOTE_SPACE
        ret z
        cp NOTE_PAUSE
        jr z,initchnnote_pause
        dec a ;sub NOTE_LOWEST
        ld (ix+chn.note_in),a;3*12 ;C-4
        ld e,(ix+chn.smp_in)
        ld (ix+chn.smpcuraddr),e
        ld e,(ix+chn.smp_in+1)
        ld (ix+chn.smpcuraddr+1),e
        ret
initchnnote_pause
        ld (ix+chn.note_in),NOTE_PAUSE
        ld (ix+chn.smpcuraddr),smp_pause&0xff
        ld (ix+chn.smpcuraddr+1),smp_pause/256
        ret

untr_pause
        ld c,NOTE_PAUSE
        call pokecurtime_curtrack_c
        jp untr_afternotekey

untr_space
        ld c,NOTE_SPACE
        call pokecurtime_curtrack_c
        jp untr_afternotekey_alltracksiforder

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
        jp setneedprtypes ;setneedredraw

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
        ld b,NTRACKS
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
        jp setneedprtypes;setneedredraw

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
        add hl,de
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

ttypes
        db "ORDER ",13
        db "drum *",13
        db "tone *",13
        db "vib 1*",13
        db "pad  *",13
        db "vol   ",13
        db "drum *",13
        db "tone *",13
        db "bass *",13
        db "vol   ",13
        db "drum *",13
        db "tone *",13
        db "pad  *",13
        db "vol   "
        db 0

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

CHNTYPEMASK=0x7f
CHNTYPE_ORDER=0 ;цифры, которые означают начало i-го фрагмента (для привязанных к ордеру каналов)
CHNTYPE_FILTER=1 ;цифры, между которыми эффект плавно изменяется. эффект влияет на предыдущий канал
CHNTYPE_NOTES=2 ;буквы нот (3 октавы)
CHNTYPE_SAMPLES=3 ;буквы сэмплов
;CHNTYPE_CHORDS=4
        macro CHNTYPE chntype,usedorder,addr
        db chntype ;+0x80=надо перерисовать
        db usedorder ;0=не привязан к ордеру
        dw addr ;описатель канала
        endm
tracks
        CHNTYPE 0x80+CHNTYPE_ORDER  ,0,-1
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Adrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Atone
        CHNTYPE 0x80+CHNTYPE_FILTER ,1,-1
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Apad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,-1
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Bdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Btone
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Bbass
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,-1
        CHNTYPE 0x80+CHNTYPE_SAMPLES,1,Cdrum
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Ctone
        CHNTYPE 0x80+CHNTYPE_NOTES  ,1,Cpad
        CHNTYPE 0x80+CHNTYPE_FILTER ,0,-1
        db -1

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
        jp prcur

        include "mix.asm"
        include "view.asm"
        include "mem.asm"

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
smp_pause
        db 0b00001000,     0
        db -1
        dw -2-2 ;loop to line with hole

smp_bass
        db 0b00000100,+5*12,0x0e
        db -1
        dw -2-3 ;loop to first line

smp_maj
        db 0b01000001,2*12+0,11
        db 0b01000001,2*12+4,11
        db 0b01000001,2*12+7,11
        db -1
        dw smp_maj-($+1) ;loop to first line

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
