opmwritemusiconlychip0
;e = register
;d = value
	ld a,e
	cp 8
	ret c
	jp opmwritechip0

opmwritemusiconlychip1
;e = register
;d = value
	ld a,e
	cp 8
	ret c
	jp opmwritechip1
