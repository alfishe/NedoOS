;_STRLEN=80
;_STRMAX=79

strcopy
	EXPORT strcopy
strcopy.A.=$+1
	EXPORT strcopy.A.
	ld hl,0 ;from
strcopy.B.=$+1
	EXPORT strcopy.B.
	ld bc,0 ;len
strcopy.C.=$+1
	EXPORT strcopy.C.
	ld de,0 ;to
	push bc
	inc bc ;copy with terminator
	ldir
	pop hl ;result
	ret

memcopy
	EXPORT memcopy
memcopy.A.=$+1
	EXPORT memcopy.A.
	ld hl,0 ;from
memcopy.B.=$+1
	EXPORT memcopy.B.
	ld bc,0 ;len
memcopy.C.=$+1
	EXPORT memcopy.C.
	ld de,0 ;to
	ldir
	ret

memcopyback
	EXPORT memcopyback
memcopyback.A.=$+1
	EXPORT memcopyback.A.
	ld hl,0 ;from
memcopyback.B.=$+1
	EXPORT memcopyback.B.
	ld bc,0 ;len
memcopyback.C.=$+1
	EXPORT memcopyback.C.
	ld de,0 ;to
	;lddr
	db 0xed,0xb8
	ret

strjoineol
	EXPORT strjoineol
strjoineol.D.=$+1
	EXPORT strjoineol.D.
	ld a,0
	jp strjoingo.
strjoin
	EXPORT strjoin
	xor a
strjoingo.
;terminator is not copied
strjoin.C.=$+1
	EXPORT strjoin.C.
strjoineol.C.=$+1
	EXPORT strjoineol.C.
	ld hl,0 ;from
	ld bc,_STRMAX+1
	;cpir
	db 0xed,0xb1
strjoin.B.=$+1
	EXPORT strjoin.B.
strjoineol.B.=$+1
	EXPORT strjoineol.B.
	ld de,0 ;tolen
	ld a,e
	;add a,_STRMAX
	sub c ;fromlen = _STRMAX. - bc ;sumlen = fromlen + tolen
	;cp _STRMAX
	;jr c,$+4
	;ld a,_STRMAX ;IF (sumlen > _STRMAX) sumlen = _STRMAX;
	 jp m,$+4
	 xor a
	 add a,_STRMAX
	sub e ;fromlen = sumlen - tolen;
	ld c,a ;fromlen ;может быть 0!!!
	 inc c ;против 0
	add a,e ;a = sumlen
strjoin.A.=$+1
	EXPORT strjoin.A.
strjoineol.A.=$+1
	EXPORT strjoineol.A.
	ld hl,0 ;to
	add hl,de ;to = to + tolen
	ex de,hl ;de = to
	ld hl,[strjoin.C.] ;from
	ldir
	ld l,a ;sumlen
	ld h,b;0
	ret

stradd
	EXPORT stradd
stradd.B.=$+1
	EXPORT stradd.B.
	ld hl,0 ;len
	ld a,l
	cp _STRMAX
	ret nc ;hl = len
	ex de,hl
stradd.A.=$+1
	EXPORT stradd.A.
	ld hl,0 ;s
	add hl,de
stradd.C.=$+1
	EXPORT stradd.C.
	ld [hl],0 ;c
	ex de,hl
	inc hl ;len
	ret

strcp
	EXPORT strcp
strcp.A.=$+1
	EXPORT strcp.A.
	ld hl,0 ;s1
strcp.B.=$+1
	EXPORT strcp.B.
	ld de,0 ;s2
strcp0.
	ld a,[de] ;s2
	cp [hl] ;s1
	jr nz,strcpbad.
	inc hl
	inc de
	or a
	jp nz,strcp0.
	cpl ;TRUE
	ret
strcpbad.
	xor a ;FALSE
	ret

;FUNC UINT hash(PBYTE pstr)
hash
	EXPORT hash
hash.A.=$+1
	EXPORT hash.A.
        ld de,0
        xor a
        ld h,a
        ld l,a
hash0.
        xor l
        add hl,hl
        add a,l
        ld l,a
        ld a,[de]
        inc de
        or a
        jp nz,hash0.
        ret
