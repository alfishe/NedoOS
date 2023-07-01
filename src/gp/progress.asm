initprogress
;NOTE: must not change flags
	ld hl,0
	ld (musicprogress),hl
	ld (progressacc),hl
	ret

setprogressdelta
;a = music size
;progressdelta = xlen/64 8.8 fixed point number
	or a
	jr nz,$+3
;set a=255 if a=0 to avoid infinite loop in updateprogress
	dec a
	rlca
	rlca
	ld h,a
	and %11111100
	ld l,a
	ld a,%0000011
	and h
	ld h,a
	ld (progressdelta),hl
	ret

updateprogress
;a = current position
musicprogress=$+1
	ld bc,0
	cp c
	ret c
	ret z
	ld c,a
progressacc=$+1
	ld hl,0
progressdelta=$+1
	ld de,0
.progressupdateloop
	ld a,h
	cp c
	jr nc,.progressupdatedone
	add hl,de
	inc b
	jr .progressupdateloop
.progressupdatedone
	ld (musicprogress),bc
	ld (progressacc),hl
	ret
