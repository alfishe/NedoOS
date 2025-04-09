opmwritemusiconlychip0
;e = register
;d = value
	ld a,e
	cp 8
	ret c
	jp opmwrite0

opmwritemusiconlychip1
;e = register
;d = value
	ld a,e
	cp 8
	ret c
	jp opmwrite1

opmwaittimer100hz
.counter=$+1
	ld a,0
	dec a
	jr nz,$+4
	ld a,2
	ld (.counter),a
	ret z
	YIELD
	ret
