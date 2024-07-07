printRTC					;Получение и отображение времени из RTC
	ld hl,displaytimer
	dec (hl)
	ret nz					; Обновляем время с интервалом 155 опросов клавиатуры (порядка 3х секунд).

printRTCnow					; Если нужно отобразить часы сдесь и сейчас.
	ld hl,displaytimer
	ld a,155
	ld (hl),a

	ld de, 0x0600
	SETCOLOR_
    ld de, 0074
	MYSETXY
	ld hl, stringTime
    call printZ
	
	call cmdcalccurxy		; Восстановим положение курсора для командной строки.
	MYSETXY

    call readTime			; Получить время из RTC

	ld a, (oldminutes)
	ld d,a
	ld a, (minutes)
	cp d					; Запускаем конвертацию в текст только если поменялась минута
	ret z

	ld (oldminutes), a

  	ld h,0					; Конвертация времени в текст
	ld a,(hours) ;часы
	ld l,a
	ld bc, decimalS
	call prword_hl_tobc ;для печати в буфер ;hl=num bc=buf

	ld hl,decimalS+3
    ld de, stringTime    
    call strcopy;nv_strcopy_hltode
    dec de
    ld a,':'
    ld (de),a
	
    ld h,0
	ld a,(minutes) ;минуты
	ld l,a
	ld bc, decimalS
	call prword_hl_tobc ;для печати в буфер ;hl=num bc=buf
	ld hl,decimalS+3
    ld de, stringTime+3    
    call strcopy;nv_strcopy_hltode
	ret

printZ
	ld a,(hl)
	or a
	ret z
	inc hl
	push hl
    MYPRCHAR
	pop hl
	jr printZ


readTime	; получение  из OS даты и времени и конвертация из DOS-time
    OS_GETTIME;out: ix=date, hl=time
	di
	push ix
	pop bc
	ei

	push hl
	pop de
    	
	ld a,d
    rra
    rra
    rra
    and 31 		;hours
	ld (hours),a

    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    ld a,d
    and 63       ;minutes
 	ld (minutes),a
 	ret

hours
	db 0
minutes
	db 0
decimalS
	ds 7 ;десятичные цифры
stringTime
    db "00:00",0
oldminutes
	db 255
displaytimer
	db 1