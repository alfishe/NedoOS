;PROC prspr(BYTE x, BYTE y, PBYTE data);
;wid8xhgt sprite (wid8, hgt, (antimask, antipixels, ...))
;клипирования нет!
prspr
;bc=yx
;hl'=gfx data
        COORDSBC_TOSCRDE
        if 1==0
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scrbuf/256
	ld d,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld e,a
        endif
;de=screen addr
	ld a,c
	and 7
	;a=shift right 0..7
	exx
	ld c,(hl) ;wid8
	inc hl
	ld b,(hl) ;hgt
	inc hl
	dec c
	jp z,prspr8.
	dec c
	jp z,prspr16. ;умеет инвалидацию
	dec c
	jp z,prspr24.
	dec c
	jp z,prspr32.
	ret

;8xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0:  5411 =12.1/byteshift
;x=1:  5043
;x=2:  4675
;x=3:  4307
;x=4:  3939
;x=5:  3571
;x=6:  3203 =50.0/byteshift
;x=7:  2835 =44.3/byte (no shift) (159 before loop)
prspr8.
	;a=shift right 0..7
	add a,a
	add a,a
	ld (prspr8jr.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1f
	 ret nc
         exx
;b = counter
;hl = data (2 accesses)
;hl' = pixels
;de' = screen (4 accesses)
;ac' = mask
prspr8line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld c,a ;mask1
	exx
	ld a,(hl) ;pixels1
	inc hl
	exx
	ld l,a ;pixels1

	xor a
	ld h,a
prspr8jr.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	xor h ;pixels0
	ld (de),a ;scr0
	inc e
	ld a,(de) ;scr1
	or c ;mask1
	xor l ;pixels1
	ld (de),a ;scr1
	dec e
	inc d
	ld a,d
	and 7
	jr z,prspr8down.
	exx
	djnz prspr8line.
	ret
prspr8down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	djnz prspr8line.
	ret

;16xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0:  7932 =11.8/byteshift
;x=1:  7452
;x=2:  6972
;x=3:  6492
;x=4:  6012
;x=5:  5532
;x=6:  5052 =52.6/byteshift
;x=7:  4572 =47.6/byte (no shift)
prspr16.
	;a=shift right 0..7
	add a,a
	ld (prspr16jr1.),a
	ld (prspr16jr2.),a
         ;exx
	 ;ld a,e
	 ;and 0x1f
	 ;cp 0x1e
	 ;ret nc
         ;exx
;b = counter
;ade = pixels
;hl = data (4 accesses)
;de' = screen (6 accesses)
;chl' = mask, masked
prspr16line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld h,a ;mask1
	exx
	ld d,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld l,a ;mask2

	xor a
prspr16jr1.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +14 = shift left 0 (right 8)
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ld c,a ;masked0
	inc e
	inc e
	ld a,(de) ;scr2
	or l ;mask2
	ex af,af' ;keep masked2
	exx
	ld e,(hl) ;pixels2
	inc hl

	ex de,hl
	xor a
prspr16jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +14 = shift left 0 (right 8)
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	ex de,hl

	ex af,af' ;masked2, keep pixels0
	xor e ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or h ;mask1
	exx
	xor d ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor c ;masked0
	ld (de),a ;scr0
	inc d
	ld a,d
	and 7
	jr z,prspr16down.
	exx
	djnz prspr16line.
	ret
prspr16down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	djnz prspr16line.
	ret
        
;PROC prspr24(BYTE x, BYTE y, PBYTE data);
;24xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0: 10951 =12.2/byteshift
;x=1: 10210
;x=2:  9474
;x=3:  8738
;x=4:  8002
;x=5:  7266
;x=6:  6530 =51.0/byteshift
;x=7:  5794 =45.3/byte (no shift)
prspr24.
	;a=shift right 0..7
	add a,a
	add a,a
	ld (prspr24jr1.),a
	ld (prspr24jr2.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1d
	 ret nc
         exx
;b = counter
;hl = data (6 accesses)
;acde = pixels
;de' = screen (8 accesses)
;bchl' = mask, masked
prspr24line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld c,a ;mask1
	exx
	ld c,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld h,a ;mask2
	exx
	ld d,(hl) ;pixels2
	inc hl
	ld a,(hl) ;mask3
	inc hl
	exx
	ld l,a ;mask3

	xor a
prspr24jr1.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ld b,a ;masked0
	inc e
	inc e
	inc e
	ld a,(de) ;scr3
	or l ;mask3
	ex af,af' ;keep masked3
	exx
	ld e,(hl) ;pixels3
	inc hl

	ex de,hl
	xor a
prspr24jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	ex de,hl

	ex af,af' ;masked3, keep pixels0
	xor e ;pixels3
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr2
	or h ;mask2
	exx
	xor d ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or c ;mask1
	exx
	xor c ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor b ;masked0
	ld (de),a ;scr0

	inc d
	ld a,d
	and 7
	jr z,prspr24down.
	exx
	djnz prspr24line.
	ret
prspr24down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	dec b
	jp nz,prspr24line.
	ret

;PROC prspr32(BYTE x, BYTE y, PBYTE data);
;32xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0: 14101 =12.6/byteshift
;x=1: 13109
;x=2: 12117
;x=3: 11125
;x=4: 10133
;x=5:  9141
;x=6:  8149 =50.9/byteshift
;x=7:  7157 =44.7/byte (no shift)
prspr32.
	;a=shift right 0..7
	ld c,a
	add a,a
	add a,c
	add a,a
	ld (prspr32jr1.),a
	ld (prspr32jr2.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1c
	 ret nc
         exx
	ld hx,b
;hx = counter
;hl = data (6 accesses)
;abcde = pixels
;de' = screen (8 accesses)
;abchl'/lbcha' = mask, masked
prspr32line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld b,a ;mask1
	exx
	ld b,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld c,a ;mask2
	exx
	ld c,(hl) ;pixels2
	inc hl
	ld a,(hl) ;mask3
	inc hl
	exx
	ld h,a ;mask3
	exx
	ld d,(hl) ;pixels3
	inc hl
	ld a,(hl) ;mask4
	inc hl
	exx
	ld l,a ;mask4

	xor a
prspr32jr1.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +7*6 = shift left 0 (right 8)
;max 217 (43.4/byte)
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ex af,af' ;masked0
	ld a,e
	add a,4
	ld e,a
	ld a,(de) ;scr4
	or l ;mask3
	ex af,af' ;masked0, keep masked4
	ld l,a ;masked0
	exx
	ld e,(hl) ;pixels4
	inc hl

	ex de,hl
	xor a
prspr32jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +7*6 = shift left 0 (right 8)
;max 217 (43.4/byte)
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	ex de,hl

	ex af,af' ;masked4, keep pixels0
	xor e ;pixels4
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr3
	or h ;mask2
	exx
	xor d ;pixels3
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr2
	or c ;mask2
	exx
	xor c ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or b ;mask1
	exx
	xor b ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor l ;masked0
	ld (de),a ;scr0

	inc d
	ld a,d
	and 7
	jr z,prspr32down.
	exx
	dec hx
	jp nz,prspr32line.
	ret
prspr32down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	dec hx
	jp nz,prspr32line.
	ret
