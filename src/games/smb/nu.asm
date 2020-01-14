;hl'=tileaddr for line end
;bc'=40
;hl=addrstack
;b=hgt
;c=-((width+3)/4)
_prtilesfast0
        ld sp,hl ;addrstack for this line
        ld a,c
        exx
	add a,l ;(это вычитание) без переноса, т.к. читаем тайлы через inc e
        ld e,a
	ld d,h
;hl=tileaddr for line end
;de=tileaddr for line start
	ld (prtilesfast0lineend),hl ;tileaddr for line end
	ld a,(hl)
	ex af,af'
	ld (hl),ENDLINETILE;0xfe ;patch after last tile
	ld a,(de)
	inc e
	ld l,a
	or 0xc0
	ld h,a
	jp (hl)
proc_endline
prtilesfast0lineend=$+1
	ld hl,0 ;tileaddr for line end
	ex af,af'
	ld (hl),a ;unpatch after last tile
	ld de,32
	add hl,de
        exx
	inc h ;move addrstack addr
	djnz _prtilesfast0
