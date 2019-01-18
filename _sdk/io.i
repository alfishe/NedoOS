;length 0 while reading means either absence of files of zero length file (any sector length)

readf
	EXPORT readf
readf.A.=$+1
	EXPORT readf.A.
	ld hl,0 ;poi to FCB
	jr fread1. ;a=data ;keeps bc
readfin
	EXPORT readfin
	ld hl,[_fin] ;poi to FCB
fread1.
;a=data
 ;;if ok then inc de?
;keeps bc
	ld l,FCB.remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ld e,[hl]
	ld d,h
	inc d
	inc e
	ld a,[de]
	ld [hl],e ;inc [hl] ;remain
	ret nz

	push bc
	 ;push de
        push hl
        ld l,0
        ld (readnewbuf.A.),hl ;FCB
        call readnewbuf
        pop hl
	 ;pop de
	pop bc
        ;ld l,FCB.remain
        or a
        jr z,fread1EOF.
;hl = poi to remain
	ld l,[hl]
	inc h
	ld a,[hl]
	 ;inc de
	ret
;EOF - next block doesn't exist
fread1EOF.
       ld a,TRUE
       ld [_waseof],a
       ld a,'\n' ;EOF returns '\n'
;set vars as they were (next time EOF again)
	dec [hl] ;remain = 0xff
	ret

fread
	EXPORT fread
fread.A.=$+1
	EXPORT fread.A.
	ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes
fread.C.=$+1
	EXPORT fread.C.
	ld bc,0 ;count
fread0.
	push bc
fread.B.=$+1
	EXPORT fread.B.
	ld bc,0 ;size
fread00.
	push hl
fread.D.=$+1
	EXPORT fread.D.
	ld hl,0 ;poi to FCB
	call fread1. ;a=data ;keeps bc
	pop hl
	ld [hl],a
       ld a,[_waseof]
       or a ;FALSE
       jr nz,freadpopret.
	;cpi
	db 0xed,0xa1
	jp pe,fread00.
	pop bc
	dec hl
	;cpi
	db 0xed,0xa1
	jp pe,fread0.
	 ;ex de,hl ;hl = total processed bytes
	ret
freadpopret.
	pop bc
	ret

writebyte
	EXPORT writebyte
writebyte.A.=$+1
	EXPORT writebyte.A.
	ld hl,0 ;file
writebyte.B.=$+1
	EXPORT writebyte.B.
	ld a,0
	jp fwrite1.
writefout
	EXPORT writefout
	ld hl,[_fout]
writefout.A.=$+1
	EXPORT writefout.A.
	ld a,0
;hl = poi to FCB
;a=data
;keeps bc
fwrite1.
	ld l,FCB.lastlenLSB
	ld e,[hl]
	ld d,h
	inc d
	ld [de],a
	inc [hl] ;lastlen (LSB)
	;Z = end of buf
	ret nz
	inc l
	inc [hl] ;lastlen (HSB)
	push bc
	ld l,0
	ld (flush_.A.),hl
	call flush_
	pop bc
	ret

fwrite
	EXPORT fwrite
fwrite.A.=$+1
	EXPORT fwrite.A.
	ld hl,0 ;poi to data
	 ;ld de,0 ;total processed bytes TODO
fwrite.C.=$+1
	EXPORT fwrite.C.
	ld bc,0 ;count
fwrite0.
	push bc
fwrite.B.=$+1
	EXPORT fwrite.B.
	ld bc,0 ;size
fwrite00.
	ld a,[hl]
	push hl
	 ;push de
fwrite.D.=$+1
	ld hl,0 ;poi to FCB
	call fwrite1. ;a=data ;keeps bc
	 ;pop de
	 ;inc de
	pop hl
	;cpi
	db 0xed,0xa1
	jp pe,fwrite00.
	pop bc
	dec hl
	;cpi
	db 0xed,0xa1
	jp pe,fwrite0.
	 ;ex de,hl ;hl = total processed bytes
	ret

;FUNC UINT readsectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
readsectors
readsectors.A.=$+1 ;buf
	ld hl,0
readsectors.B.=$+1 ;trsec
	ld de,0
readsectors.C.=$+2 ;count
	ld bc,0x0105
dos3d13.
	call 0x3d13
	ld hl,[0x5cf4] ;return hl=next sector
	ret

;FUNC UINT writesectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
writesectors
writesectors.A.=$+1 ;buf
	ld hl,0
writesectors.B.=$+1 ;trsec
	ld de,0
writesectors.C.=$+2 ;count
	ld bc,0x0106
	jr dos3d13.
