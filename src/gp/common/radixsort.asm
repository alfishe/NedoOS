RADIXSORT_HISTOGRAM = 0xc000
RADIXSORT_WORKBUFFER = RADIXSORT_HISTOGRAM + 512

radixsort
;a = key size in bytes
;ix = array of dwords, each element is an offset to n-th byte of the key
;hl = items ptr (input)
;de = item size
;bc = num items
;iy = sorted items ptr (output)
	push iy
	push ix
	push af
	ld (.itemsize),de
;adjust data for djnz+dec_c loop
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld (.numitems),bc
;create array with pointers to items
	ld ix,RADIXSORT_WORKBUFFER
	ld (.srcbuf),ix
.fillptrsloop
	ld (ix),hl
	add hl,de
	inc ix
	inc ix
	djnz .fillptrsloop
	dec c
	jr nz,.fillptrsloop
	ld (.dstbuf),ix
;main loop iterating through the key
	pop bc
	pop hl
.keysizeloop
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (.keyoffset),de
	ld (.keyoffset1),de
	push bc
	push hl
;clear histogram
	ld hl,RADIXSORT_HISTOGRAM
	ld de,RADIXSORT_HISTOGRAM+1
	ld bc,511
	ld (hl),0
	ldir
;fill histogram
.srcbuf=$+2
	ld ix,0
.numitems=$+1
	ld bc,0
.buildhistogramloop
	ld hl,(ix)
	inc ix
	inc ix
.keyoffset=$+1
	ld de,0
	add hl,de
	ld e,(hl)
	ld d,0
	ld hl,RADIXSORT_HISTOGRAM
	add hl,de
	add hl,de
	inc (hl)
	jr nz,$+4
	inc hl
	inc (hl)
	djnz .buildhistogramloop
	dec c
	jr nz,.buildhistogramloop
;histogram prefix sum
	ld ix,RADIXSORT_HISTOGRAM
.dstbuf=$+1
	ld hl,0
	ld b,0
.prefixsumloop
	ld de,(ix)
	ld (ix),hl
	add hl,de
	add hl,de
	inc ix
	inc ix
	djnz .prefixsumloop
;shuffle pointers
	ld ix,(.srcbuf)
	ld iy,(.numitems)
.copypointersloop
	ld bc,(ix)
	inc ix
	inc ix
.keyoffset1=$+1
	ld hl,0
	add hl,bc
	ld e,(hl)
	ld d,0
	ld hl,RADIXSORT_HISTOGRAM
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ex de,hl
	ld (hl),d
	dec hl
	ld (hl),e
	dec iyh
	jr nz,.copypointersloop
	dec iyl
	jr nz,.copypointersloop
;swap buffers
	ld hl,(.srcbuf)
	ld de,(.dstbuf)
	ld (.srcbuf),de
	ld (.dstbuf),hl
	pop hl
	pop bc
	dec b
	jp nz,.keysizeloop
;move sorted items to destination buffer
	ld iy,(.numitems)	
	ld ix,de
	pop de
.copyitemsloop
	ld hl,(ix)
	inc ix
	inc ix
.itemsize=$+1
	ld bc,0
	ldir
	dec iyh
	jr nz,.copyitemsloop
	dec iyl
	jr nz,.copyitemsloop
	ret
