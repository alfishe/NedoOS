;PROC setxy FORWARD(BYTE x, BYTE y);
setxy
setxy.A.=$+1
;setxy.x=$+1
setxy.B.=$+2
;setxy.y=$+2
	ld de,0
        ;OS_SETXY
        ld c,CMD_SETXY;0xf8
        call BDOS;0x0005
	ret

;PROC prchar FORWARD(CHAR c);
prchar
prchar.A.=$+1
;prchar.c=$+1
	ld a,0
prcharA.
        rst 0x10
	ret

;PROC nprintf FORWARD(
;  PCHAR s,
;  UINT d0,
;  UINT d1,
;  UINT d2,
;  UINT d3,
;  UINT d4,
;  UINT d5,
;  UINT d6,
;  UINT d7,
;  UINT d8,
;  UINT d9
;);
nprintf
nprintf.A.=$+1
;nprintf.s=$+1
	ld de,0
	ld hl,nprintf.B. ;poi to 1st data
nprintf0.
	ld a,[de]
	or a
	ret z
	inc de
	cp '%'
	jr z,nprintf0.format.
nprintf0.formatq
	push de
	push hl
	call prcharA.
	pop hl
	pop de
	jr nprintf0.
nprintf0.format.
	ld a,[de]
	inc de
	cp 'c'
	jr z,nprintf0.format.c.
	cp 'd'
	jr z,nprintf0.format.d.
	cp 's'
	jr z,nprintf0.format.s.
	cp 'x'
	jr z,nprintf0.format.x.
	cp '%'
	jr z,nprintf0.formatq
	ret
nprintf0.format.c.
	ld a,[hl]
	inc hl
	inc hl
	push hl
	call prcharA.
	pop hl
	jr nprintf0.
nprintf0.format.d.
	push de
	ld e,[hl]
	inc hl
	ld d,[hl]
	inc hl
	push hl
	ex de,hl
	ld bc,10000
	call nprintf.dig.
	ld bc,1000
	call nprintf.dig.
	ld bc,100
	call nprintf.dig.
	ld bc,10
	call nprintf.dig.
	ld bc,1
	call nprintf.dig.
	pop hl
	pop de
	jr nprintf0.
nprintf0.format.s.
	push de
	ld e,[hl]
	inc hl
	ld d,[hl]
	inc hl
	push hl
nprintfs0.
	ld a,[de]
	or a
	jr z,nprintfsq.
	inc de
	push de
	push hl
	call prcharA.
	pop hl
	pop de
	jr nprintfs0.
nprintfsq.
	pop hl
	pop de
	jr nprintf0.
nprintf0.format.x.
	push de
	ld e,[hl]
	inc hl
	ld d,[hl]
	inc hl
	push hl
	ld a,d
	call nprintf.hdig.
	call nprintf.hdig.
	ld a,e
	call nprintf.hdig.
	call nprintf.hdig.
	pop hl
	pop de
	jp nprintf0.

nprintf.hdig.
	rrca
	rrca
	rrca
	rrca
	push af
	or 0xf0
	daa
	add a,0xa0
	adc a,0x40
	push de
	call prcharA.
	pop de
	pop af
	ret

nprintf.dig.
	ld a,'0'-1
	or a
nprintf.dig0.
	inc a
	sbc hl,bc
	jr nc,nprintf.dig0.
	add hl,bc
	push hl
	call prcharA.
	pop hl
	ret

nprintf.B.
	dw 0
nprintf.C.
	dw 0
nprintf.D.
	dw 0
nprintf.E.
	dw 0
nprintf.F.
	dw 0
nprintf.G.
	dw 0
nprintf.H.
	dw 0
nprintf.I.
	dw 0
nprintf.J.
	dw 0
nprintf.K.
	dw 0
