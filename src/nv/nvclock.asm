printRTC
	ld hl,displaytimer
	inc (hl)
	ret nz

	ld hl,displaytimer
	ld a,100
	ld (hl),a

printRTCnow
	ld de, 0x0600
	SETCOLOR_
    ld de, 0074
	MYSETXY
	ld hl, stringTime
    call printZ
	
	call cmdcalccurxy
	MYSETXY

    call readTime

	ld a, (oldminutes)
	ld d,a
	ld a, (minutes)
	cp d					; Update only if minutes changed
	ret z

	ld (oldminutes), a
  	ld h,0
	ld a,(hours) ;часы
	ld l,a
	call toDecimal
	ld hl,decimalS+3
    ld de, stringTime    
    call strcopy;nv_strcopy_hltode
    dec de
    ld a,':'
    ld (de),a
	
    ld h,0
	ld a,(minutes) ;минуты
	ld l,a
	call toDecimal
	ld hl,decimalS+3
    ld de, stringTime+3    
    call strcopy;nv_strcopy_hltode
	;dec de
    ;ld a,']'
    ;ld (de),a
	ret

toDecimal		;конвертирует 2 байта в 5 десятичных цифр
				;на входе в HL число
	ld de,10000 ;десятки тысяч
	ld a,255
toDecimal10k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal10k
	add hl,de
	add a,48
	ld (decimalS),a
	ld de,1000 ;тысячи
	ld a,255
toDecimal1k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal1k
	add hl,de
	add a,48
	ld (decimalS+1),a
	ld de,100 ;сотни
	ld a,255
toDecimal01k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal01k
	add hl,de
	add a,48
	ld (decimalS+2),a
	ld de,10 ;десятки
	ld a,255
toDecimal001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal001k
	add hl,de
	add a,48
	ld (decimalS+3),a
	ld de,1 ;единицы
	ld a,255
toDecimal0001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal0001k
	add hl,de
	add a,48
	ld (decimalS+4),a
    xor a
    ld (decimalS+5),a				
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


readTime
    OS_GETTIME;out: ix=date, hl=time
	di
	push ix
	pop bc
	ei

	push hl
	pop de
	ld a,e
    add a,a
    and 63	;seconds
	ld (seconds),a
    	
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
seconds
	db 0
decimalS	ds 7 ;десятичные цифры
stringTime
    db "00:00",0
oldminutes		; не убирать под услоаие
	db 255
displaytimer
	db 100