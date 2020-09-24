        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

freemem_start=0x8000
tracks=freemem_start
MAXTIME=1000
NTRACKS=14
tracks_sz=MAXTIME*NTRACKS
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
        ld (hl),NOTE_SPACE;0
        ldir

        call initmem

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
        cp 'a'
        jp z,untr_pause
        cp key_esc
        jp z,untr_quit
        
        push af
;смотрим тип текущего канала
        ld a,(curtrack)
        call getchntype
        cp CHNTYPE_NOTES
        jr z,enternote        
        pop af
        ld c,a
        ld a,(curtrack)
        call pokeaddr_c_tracka
        jr untr_afternotekey
        
enternote
        pop af
        
        ld hl,tnotekeys
        ld bc,3*12
        cpir
        ret nz
         inc c ;add c,NOTE_LOWEST
        ld a,(curtrack)
        call pokeaddr_c_tracka

        call playnote_initchannels

playnote0
        halt
        call playnote
        call checknotekeys_pressed
        jr nz,playnote0
        
        call shutay
        
untr_afternotekey
        call setneedredraw
        jp untr_right

playnote_initchannels
        ld a,0x80 ;точно не совпадёт, так что будет retrigenv
        ld (chip0+chip.envtype),a
        ld hl,channels
        ld hy,0 ;track
playnote_initchannels0
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
        jr z,playnote_initchannels0skip
        ld hx,b
        ld lx,c
        push hl
        ld a,hy
;a=track
        ;ld a,(ix+chn.channel_in)
        call peekaddr_tracka
        pop hl
         cp NOTE_SPACE
         jr z,playnote_initchannels0pause
        call initchnnote ;устанавливает сэмпл, как указано в канале
playnote_initchannels0skip
        inc hy ;track
        jr playnote_initchannels0
playnote_initchannels0pause
        call initchnnote_pause ;устанавливает сэмпл паузы
        jr playnote_initchannels0skip

playenter_initchannels
;инициализирует ноты в каналах в процессе проигрывания
        ld hl,channels
        ld hy,0 ;track
playenter_initchannels0
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
        jr z,playenter_initchannels0skip
        ld hx,b
        ld lx,c
        push hl
        ld a,hy
;a=track
        ;ld a,(ix+chn.channel_in)
        call peekaddr_tracka
        pop hl
        call initchnnote ;устанавливает сэмпл, как указано в канале
playenter_initchannels0skip
        inc hy ;track
        jr playenter_initchannels0

playnote_playsamplechannels
        ld hl,channels
playnote_playsamplechannels0
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
        jr z,playnote_playsamplechannels0skip
        push hl
        ld hx,b
        ld lx,c
        call playsample
        pop hl
playnote_playsamplechannels0skip
        jr playnote_playsamplechannels0

playnote
        call playnote_playsamplechannels
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
        call playnote_initchannels

playenter0
        halt
        call playenter_initchannels
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
        ld hl,channels
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
        ld a,(curtrack)
        call pokeaddr_c_tracka
        jp untr_afternotekey

untr_space
        ld c,NOTE_SPACE
        ld a,(curtrack)
        call pokeaddr_c_tracka
        jp untr_afternotekey

untr_backspace
        ld hl,(curtime)
        ld a,h
        or l
        ret z
        call untr_left

untr_del_popret
        pop hl
        ret

untr_del
        ld a,(curtrack)
        call getaddr_tracka
        push hl ;hl=curaddr
        ld a,(curtrack)
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
untr_del0
        ;ld a,(hl)
        ;ld (hl),c
        ;ld c,a
        push de
        ld a,(curtrack)
        call pokeaddr ;c<->mem(hl)
        pop de
         dec hl ;add hl,de
        djnz untr_del0
        dec hx
        jr nz,untr_del0

        jp setneedredraw

untr_ins
        ld a,(curtrack)
        call getaddr_tracka
        push hl ;hl=curaddr
        push hl ;hl=curaddr
        ld a,(curtrack)
        call getendaddr ;de=end or 0
        ex de,hl
        pop de ;de=curaddr
        or a
        sbc hl,de ;endaddr-curaddr
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
untr_ins0
        ;ld a,(hl)
        ;ld (hl),c
        ;ld c,a
        push de
        ld a,(curtrack)
        call pokeaddr ;c<->mem(hl)
        pop de
         inc hl ;add hl,de
        djnz untr_ins0
        dec hx
        jr nz,untr_ins0
        jr setneedredraw

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
;FIXME: пока тут костыль - тест поиска непустого на месте или влево
        ld a,(curtrack)
        ld hl,(curtime)
        call tracktime_toaddr
        ex de,hl
        ld a,(curtrack)
        call getroot ;ld hl,0x8000 ;root
;hl=track pointer (4 bytes: left poi, right poi)
;de=timeshift
        call findleft
;out: de=nonempty shift (or 0), a=data
        ex de,hl
        ld a,h
        and 7
        ld h,a
        ld (curtime),hl
        ld (lefttime),hl
        jr setneedredraw

untr_end
;FIXME: пока тут костыль - тест поиска непустого на месте или вправо
        ld a,(curtrack)
        ld hl,(curtime)
        call tracktime_toaddr
        ex de,hl
        ld a,(curtrack)
        call getroot ;ld hl,0x8000 ;root
;hl=track pointer (4 bytes: left poi, right poi)
;de=timeshift
        call findright
;out: de=nonempty shift (or 0xffff), a=data
        ex de,hl
        ld a,h
        and 7
        ld h,a
        ld (curtime),hl
        ld (lefttime),hl
        jr setneedredraw

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
        db "Master",13
        db "drum  ",13
        db "tone  ",13
        db "pad   ",13
        db "vol   ",13
        db "vib 1 ",13
        db "drum  ",13
        db "tone  ",13
        db "bass  ",13
        db "vol   ",13
        db "drum  ",13
        db "tone  ",13
        db "pad   ",13
        db "vol   "
        db 0

;смотрим тип текущего канала
getchntype
        add a,a
        add a,a
        ld hl,channels
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld a,(hl)
        ret

CHNTYPE_ORDER=0 ;цифры, которые означают начало i-го фрагмента (для привязанных к ордеру каналов)
CHNTYPE_FILTER=1 ;цифры, между которыми эффект плавно изменяется. эффект влияет на предыдущий канал
CHNTYPE_NOTES=2 ;буквы нот (3 октавы)
CHNTYPE_SAMPLES=3 ;буквы сэмплов
;CHNTYPE_CHORDS=4
        macro CHNTYPE chntype,usedorder,addr
        db chntype
        db usedorder ;0=не привязан к ордеру
        dw addr ;описатель канала
        endm
channels
        CHNTYPE CHNTYPE_ORDER  ,0,-1
        CHNTYPE CHNTYPE_SAMPLES,0,Adrum
        CHNTYPE CHNTYPE_NOTES  ,0,Atone
        CHNTYPE CHNTYPE_NOTES  ,0,Apad
        CHNTYPE CHNTYPE_FILTER ,0,-1
        CHNTYPE CHNTYPE_FILTER ,0,-1
        CHNTYPE CHNTYPE_SAMPLES,0,Bdrum
        CHNTYPE CHNTYPE_NOTES  ,0,Btone
        CHNTYPE CHNTYPE_NOTES  ,0,Bbass
        CHNTYPE CHNTYPE_FILTER ,0,-1
        CHNTYPE CHNTYPE_SAMPLES,0,Cdrum
        CHNTYPE CHNTYPE_NOTES  ,0,Ctone
        CHNTYPE CHNTYPE_NOTES  ,0,Cpad
        CHNTYPE CHNTYPE_FILTER ,0,-1
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
