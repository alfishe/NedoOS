inittracks
;настраивает треки по заданным параметрам
;в каналах с пустышкой включает паузу, форсирует ретриггер огибающей
        ld iy,ttypes
        ld hl,tracks
inittrackspars0
        ld a,(hl) ;chntype
        inc a
        jp z,inittrackspars0q
        ld a,(iy+2) ;track type
        ld c,CHNTYPE_ORDER
        cp _O
        jr z,inittrackspars_typeok
        ld c,CHNTYPE_NOTES
        cp _t
        jr z,inittrackspars_typeok
        ld c,CHNTYPE_SAMPLES
        cp _d
        jr z,inittrackspars_typeok
        ld c,CHNTYPE_FILTER
inittrackspars_typeok
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
         jr z,inittrackspars0ok
         cp CHNTYPE_FILTER
         jr z,inittrackspars0filter
        ld (ix+chn.oldnote_in),0 ;for gliss
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
        ld b,(hl) ;TODO add sample offset (par2?)
        ld (ix+chn.smp_in),c
        ld (ix+chn.smp_in+1),b
        ld a,(iy+5) ;par2
        ld (ix+chn.par2_in),a
        ld a,(iy+6) ;par3
        ;ld (ix+chn.par3_in),a
         sub 1+15
        ld (ix+chn.volume_in),a
        pop hl
inittrackspars0ok
        ld bc,8
        add iy,bc
        jr inittrackspars0
inittrackspars0filter
        push hl
        ld a,(iy+2) ;track type (filter type)
        ld bc,filterhandler_vol
        cp _g
        jr z,inittrackspars_filtertypeok
        ld bc,filterhandler_vib
        cp _v
        jr z,inittrackspars_filtertypeok
        cp _V
        jr z,inittrackspars_filtertypeok
        ld bc,filterhandler_env
        cp _e
        jr z,inittrackspars_filtertypeok
        cp _E
        jr z,inittrackspars_filtertypeok
        ld bc,filterhandler_noise
        cp _n
        jr z,inittrackspars_filtertypeok
        ld bc,reter
inittrackspars_filtertypeok
        ld (ix+filter.handler),c
        ld (ix+filter.handler+1),b
        ld a,(iy+4) ;par1
        ld (ix+filter.par1),a
        ld a,(iy+5) ;par2
        ld (ix+filter.par2),a
        ld a,(iy+6) ;par3
        ld (ix+filter.par3),a
        pop hl
        jr inittrackspars0ok
inittrackspars0q

        ld a,0x80 ;точно не совпадёт, так что будет retrigenv
        ld (chip0+chip.envtype),a
        ld (chip1+chip.envtype),a

        ld hl,tracks
        ld hy,0 ;track
inittracks0
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
         jr z,inittracks0skip
        ld a,b
        and c
        inc a
        jr z,inittracks0skip
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
        call z,initchnnote_pause ;устанавливает сэмпл паузы, выключает глисс
inittracks0skip
        inc hy ;track
        jr inittracks0

initnote
;инициализирует ноты в каналах в процессе проигрывания
        ld hl,tracks
        ld ix,0 ;no channel for filter
        ld hy,0 ;track
initnote0
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
         jp z,initnotefilter;inittracks0skip
         cp CHNTYPE_SAMPLES+1
         jp z,initnotesamples;inittracks0skip
         cp CHNTYPE_ORDER+1
         jr z,initnote0skip
        ;ld a,b
        ;and c
        ;inc a
        ;jr z,initnote0skip
        ld hx,b
        ld lx,c
        push hl
        ld a,hy ;a=track
        push ix
        call peekcurtime_tracka
        pop ix
        pop hl
        cp NOTE_SPACE
        jr z,initnote0skip
        cp NOTE_GLISS
        ld c,(ix+chn.oldnote_in)
        ld (ix+chn.oldnote_in),a
        jr z,initnotegliss
;если ближайшая нота слева - глисс, то не переинициализировать сэмпл
        dec a
        ld (ix+chn.note_in),a
        ;ld (ix+chn.curgliss),0
        ;ld (ix+chn.curgliss+1),0
        ;ld (ix+chn.glissspeed_in),0
        ;ld (ix+chn.glissspeed_in+1),0
        inc c
        inc c ;cp NOTE_GLISS
        ld d,c
        ld e,c
        jp z,initnoteglissq_de;initnotelegato ;de=0
        ld de,smp_pause
        cp NOTE_PAUSE-1
        jr z,initnote0_pause
        ld e,(ix+chn.smp_in)
        ld d,(ix+chn.smp_in+1)
initnote0_pause
        call initchnnote_setsmpde_nogliss ;устанавливает сэмпл, как указано в канале, выключает глисс
initnote0skip
        inc hy ;track
        jr initnote0
;initnotelegato
;        jr initnote0skip
initnotegliss
;найти ближайшую ноту справа - цель глисса
       push hl
       push ix
        ld a,hy;(curtrack)
        ld hl,(curtime)
        push hl
        call tracktime_totrackpartindex ;hl=index ;lx=part ;a=track
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
       push hl ;beg
        call getroot ;out: hl=root
;hl=track root (4 bytes: left poi, right poi)
;de=index
        inc de ;не на месте, а только вправо
        call findright ;out: de=nonempty index (or ffff), a=data
       pop hl ;beg
        add hl,de ;time=index+beg (beg=time-index)
;hl=righttime
;a=rightval
       pop ix
        or a
        ld d,a
        ld e,a
        jr z,initnoteglissq ;de=0
        ld de,(curtime)
        ;or a
        sbc hl,de ;hl=glisstime
        ld d,h
        ld e,l
        add hl,hl
        add hl,de ;*3 ;TODO умножить на темп
       push hl ;hl=glisstime
;где взять glisshgt, она же зависит от рабочей октавы!!!??? рабочая октава в параметрах канала? (нельзя брать из первого фрейма сэмпла, т.к. там может быть всплеск! можно из текущего?)
;и как делать глисс на огибающей? отдельные поля chn? но где взять glisshgt, он же зависит от envsemitoneshift? (нельзя брать из первого фрейма сэмпла, т.к. там может быть всплеск! можно из текущего?)
        ld l,(ix+chn.smpcuraddr)
        ld h,(ix+chn.smpcuraddr+1)
        inc hl ;skip mask
;вычисляем частоту будущей ноты
       dec a
        add a,(hl) ;semitone shift
        jp po,initnotegliss_nosemitoneshift2 ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
initnotegliss_nosemitoneshift2
        ld c,a
        ld b,tfrq/256
        ld a,(bc)
        ld e,a
        inc b
        ld a,(bc)
        ld d,a ;hl=частота будущей ноты
;вычисляем частоту текущей ноты
        ld a,(ix+chn.note_in)
        add a,(hl) ;semitone shift
        jp po,initnotegliss_nosemitoneshift ;no signed overflow
        rla
        sbc a,a ;a=0 for negative overflow, a=255 for positive overflow
        xor 0x80 ;a=-128 for negative overflow, a=127 for positive overflow
initnotegliss_nosemitoneshift
        ld c,a
        ld a,(bc)
        ld h,a
        dec b
        ld a,(bc)
        ld l,a ;hl=частота текущей ноты
        ex de,hl
        or a
        sbc hl,de ;hl=частота будущей ноты - частота текущей ноты
       pop de ;de=glisstime
        call divsignedfixedpoint3 ;hl = hl/de = +-12./16. = +-12.3
        ex de,hl ;de = glissspeed_in = glisshgt/glisstime = +-12./16. = +-12.3
initnoteglissq
       pop hl
initnoteglissq_de
        xor a
        ld (ix+chn.curgliss),a
        ld (ix+chn.curgliss+1),a
        ld (ix+chn.glissspeed_in),e
        ld (ix+chn.glissspeed_in+1),d
        jr initnote0skip
initnotesamples
        ld hx,b
        ld lx,c
        push hl
        ld a,hy ;a=track
        push ix
        call peekcurtime_tracka
        pop ix
        pop hl
        or a
        jp z,initnote0skip ;SPACE
        ld (ix+chn.note_in),3*12 ;C-4
        add a,a
        ld l,a
        ld h,0
        ld bc,tsamples
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (ix+chn.smpcuraddr),c
        ld (ix+chn.smpcuraddr+1),b
        jp initnote0skip
initnotefilter
         ld a,hx
         or a
         jp z,initnote0skip ;когда фильтр по ошибке стоит выше любого канала

        push hl
        push ix
        push bc ;filter
;ищем ближайшее число слева (или на месте) и ближайшее число справа
;(если справа ничего нет, то такое же число, как слева)
;текущее значение для фильтра - это линейная интерполяция между ними
;k = (curtime-lefttime)/(righttime-lefttime)
;val = leftval + k*(rightval-leftval)
        ld a,hy;(curtrack)
        ld hl,(curtime)
        push hl
        call tracktime_totrackpartindex ;hl=index
        ex de,hl ;de=index
        pop hl
        or a
        sbc hl,de ;beg=time-index (index=time-beg)
       push hl ;beg
       push de ;index
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
        ld (initnotefilter_lefttime),hl
        or a
        jr nz,$+4
         ld a,1+15 ;"f"
        ld (initnotefilter_leftval),a

        ;ld a,hy;(curtrack)
        ;ld hl,(curtime)
        ;call tracktime_totrackpartindex ;hl=index
        ;ex de,hl
       pop de ;index
;de=index
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
        or a
         jr nz,$+5
         ld a,(initnotefilter_leftval)
        push af ;ld (rightval),a
;k = (curtime-lefttime)/(righttime-lefttime)
initnotefilter_lefttime=$+1
        ld bc,0
        or a
        sbc hl,bc ;righttime-lefttime
        ex de,hl ;de=righttime-lefttime
        ld hl,(curtime)
        or a
        sbc hl,bc ;hl=curtime-lefttime
        call divlessthan1 ;out: k = bc = hl / de (.16)
;val = leftval + k*(rightval-leftval)
        pop af ;rightval
initnotefilter_leftval=$+1
        ld e,0
        sub e
        call mulsigned8bylessthan1 ;a = +-a*bc
        add a,e
        pop ix ;filter
        ld (ix+filter.curvalue),a
        pop ix
        pop hl
        jp initnote0skip

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
        
initchnnote_pause
        ld de,smp_pause
initchnnote_setsmpde_nogliss
        ld (ix+chn.smpcuraddr),e
        ld (ix+chn.smpcuraddr+1),d
        xor a
        ld (ix+chn.curgliss),a
        ld (ix+chn.curgliss+1),a
        ld (ix+chn.glissspeed_in),a
        ld (ix+chn.glissspeed_in+1),a
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

divsignedfixedpoint3
;hl / de
;out: hl
;+-12./16. = +-12.3
;домножаем делимое на 8 и делим нацело
        add hl,hl
        add hl,hl
        add hl,hl
;divsignedhl_de
        bit 7,h
        jr z,_DIV.
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a
        call _DIV.
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a
        ret
;hl / de
;out: hl
;работает так: hl.ca - de и т.д.
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
