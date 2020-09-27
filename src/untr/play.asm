playnote_inittracks
;настраивает треки по заданным параметрам
;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
        ld iy,ttypes
        ld hl,tracks
playnote_inittrackspars0
        ld a,(hl) ;chntype
        inc a
        jp z,playnote_inittrackspars0q
        ld a,(iy+2) ;track type
        ld c,CHNTYPE_ORDER
        cp _O
        jr z,playnote_inittrackspars_typeok
        ld c,CHNTYPE_NOTES
        cp _t
        jr z,playnote_inittrackspars_typeok
        ld c,CHNTYPE_SAMPLES
        cp _d
        jr z,playnote_inittrackspars_typeok
        ld c,CHNTYPE_FILTER
playnote_inittrackspars_typeok
        ld a,(hl)
        xor c
        and 0x80
        xor c
        ld (hl),a        
        inc hl
         ld c,(iy+3) ;order (_O/0)
         ld (hl),c
        ;ld a,(hl) ;order
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld hx,b
        ld lx,c
         and CHNTYPEMASK
         cp CHNTYPE_ORDER
         jr z,playnote_inittrackspars0ok
         cp CHNTYPE_FILTER
         jr z,playnote_inittrackspars0filter
        ld a,(iy+0) ;channel
        sub _A
        ld (ix+chn.channel_in),a
        ld a,(iy+1) ;priority
        sub _0
        ld (ix+chn.keepme_in),a
        push hl
        ld a,(iy+4) ;sample
        add a,a
        ld l,a
        ld h,0
        ld bc,tsamples
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (ix+chn.smp_in),c
        ld (ix+chn.smp_in+1),b
        ld a,(iy+5) ;par2
        ld (ix+chn.par2_in),a
        ld a,(iy+6) ;par3
        ld (ix+chn.par3_in),a
        pop hl
playnote_inittrackspars0ok
        ld bc,8
        add iy,bc
        jr playnote_inittrackspars0
playnote_inittrackspars0filter
        push hl
        ld a,(iy+2) ;track type (filter type)
        ld bc,filterhandler_vol
        cp _g
        jr z,playnote_inittrackspars_filtertypeok
        ld bc,filterhandler_vib
        cp _v
        jr z,playnote_inittrackspars_filtertypeok
        cp _V
        jr z,playnote_inittrackspars_filtertypeok
        ld bc,filterhandler_env
        cp _e
        jr z,playnote_inittrackspars_filtertypeok
        cp _E
        jr z,playnote_inittrackspars_filtertypeok
        ld bc,filterhandler_noise
        cp _n
        jr z,playnote_inittrackspars_filtertypeok
        ld bc,reter
playnote_inittrackspars_filtertypeok
        ld (ix+filter.handler),c
        ld (ix+filter.handler+1),b
        ld a,(iy+4) ;par1
        ld (ix+filter.par1),a
        ld a,(iy+5) ;par2
        ld (ix+filter.par2),a
        ld a,(iy+6) ;par3
        ld (ix+filter.par3),a
        pop hl
        jr playnote_inittrackspars0ok
playnote_inittrackspars0q

        ld a,0x80 ;точно не совпадёт, так что будет retrigenv
        ld (chip0+chip.envtype),a ;TODO TurboSound

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
         and CHNTYPEMASK
         cp CHNTYPE_FILTER+1
         jr z,playnote_inittracks0skip
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
;         jr z,playnote_inittracks0pause
;        call initchnnote ;устанавливает сэмпл, как указано в канале
;        jr playnote_inittracks0skip
;playnote_inittracks0pause
        call z,initchnnote_pause ;устанавливает сэмпл паузы
playnote_inittracks0skip
        inc hy ;track
        jr playnote_inittracks0

playenter_inittracks
;инициализирует ноты в каналах в процессе проигрывания
        ld hl,tracks
        ld ix,0 ;no channel for filter
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
         and CHNTYPEMASK
         cp CHNTYPE_FILTER+1
         jr z,playenter_filter;inittracks0skip
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
playenter_filter
         ld a,hx
         or a
         jr z,playenter_inittracks0skip ;т.е. фильтр по ошибке стоит выше любого канала
        if 1==1
        push hl
        push ix
        push bc ;filter
;ищем ближайшее число слева (или на месте) и ближайшее число справа
;(если справа ничего нет, то такое же число, как слева)
;текущее значение для фильтра - это линейная интерполяция между ними
;k = (curtime-lefttime)/(righttime-lefttime)
;val = leftval + k*(rightval-leftval)

        ;jr $
        ld a,hy;(curtrack)
        ld hl,(curtime)
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
       push hl ;beg
       push hl ;beg
        ld a,hy;(curtrack)
        call getroot ;out: hl=root
;hl=track root (4 bytes: left poi, right poi)
;de=index
        call findleft ;out: de=nonempty index (or 0), a=data
       pop hl ;beg
        add hl,de ;time=index+beg (beg=time-index)
;hl=lefttime
;a=leftval
        ld (lefttime),hl
        or a
        jr nz,$+4
        ld a,16 ;"f"
        ld (leftval),a

        ld a,hy;(curtrack)
        ld hl,(curtime)
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        ld a,hy;(curtrack)
        call getroot ;out: hl=root
;hl=track root (4 bytes: left poi, right poi)
;de=index
        inc de ;не на месте, а только вправо
        call findright ;out: de=nonempty index (or ffff), a=data
       pop hl ;beg
        add hl,de ;time=index+beg (beg=time-index)
;hl=righttime
;a=rightval
        ;ld (righttime),hl
        or a
        ;jr nz,$+4
        ;ld a,16 ;"f"
         jr nz,$+5
         ld a,(leftval)
        push af ;ld (rightval),a
;k = (curtime-lefttime)/(righttime-lefttime)
        ;ld hl,(righttime)
        ld de,(lefttime)
        or a
        sbc hl,de
        ex de,hl
        ld hl,(curtime)
        ld bc,(lefttime)
        or a
        sbc hl,bc
        call divlessthan1 ;out: bc = hl / de (.16)
        ;ld (k),bc
;val = leftval + k*(rightval-leftval)
;rightval=$+1
;        ld a,0
        pop af ;rightval
leftval=$+1
        ld e,0
        sub e
        call mulsigned8bylessthan1
        add a,e
        pop ix ;filter
        ld (ix+filter.curvalue),a
        pop ix
        pop hl
        endif

        jr playenter_inittracks0skip

mulsigned8bylessthan1
;a = +-a*bc
        rla
        jr nc,mul8bylessthan1
        neg
        call mul8bylessthan1
        neg
        ret
mul8bylessthan1
        ld hl,0
        dup 7
        srl b
        rr c
        rla
        jr nc,$+3
        add hl,bc
        edup
        ld a,h
        srl a
        ret

playnote_tracksplaysample
        ld hl,tracks
        ld ix,0
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
         and CHNTYPEMASK
         cp CHNTYPE_FILTER+1
         jr z,playnote_filter;playnote_tracksplaysample0skip
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
playnote_filter
;bc=filter addr
         ld a,hx
         or a
         jr z,playnote_tracksplaysample0skip ;т.е. фильтр по ошибке стоит выше любого канала
        push hl
        push ix
        ld hx,b
        ld lx,c
        ld l,(ix+filter.handler)
        ld h,(ix+filter.handler+1)
        ld b,(ix+filter.par1)
        ld c,(ix+filter.par2)
        ld d,(ix+filter.par3)
        ld e,(ix+filter.curvalue)
        pop ix
        push ix
        pop iy
        call jphl
        pop hl
        jr playnote_tracksplaysample0skip

jphl
        jp (hl)

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
         and CHNTYPEMASK
         cp CHNTYPE_FILTER+1
         jr z,mixchn_all_channela0skip
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

divlessthan1
;out: bc = hl / de (0.16)
	ld b,8
divlessthan10.
;shift left hlca
	add hl,hl
;no carry
;try sub
	sbc hl,de
	jr nc,$+3
	add hl,de
;carry = inverted bit of result
        rla
	djnz divlessthan10.
        cpl
        ld c,a
	ld b,8
divlessthan11.
;shift left hlca
	add hl,hl
;no carry
;try sub
	sbc hl,de
	jr nc,$+3
	add hl,de
;carry = inverted bit of result
        rla
	djnz divlessthan11.
        ld b,c
        cpl
	ld c,a
        ret
