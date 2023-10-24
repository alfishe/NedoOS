
CS_SYMLEN	equ	32 ;length of checksum in ascii: 32 for MD5


CS_PREPARE:	; precalculate tables

		;kills: everything

		ret




CS_START:	;start/init calculation anew

		;kills: everything

		xor	a
		ld	[phase],a

		ld	hl,bitLEN
		ld	b,8
.clrbitlen
		ld	[hl],a
		inc	hl
		djnz	.clrbitlen

		ld	hl,initABCD
		ld	de,stA
		ld	bc,16
		ldir

		ret


CS_APPEND:	;append chunk of data to calculation
		;in: bc - size
		;in: hl - ptr
	
		;kills: everything

.append_loop
		ld	a,b
		or	c
		ret	z

		ld	a,[phase]
		cpl
		add	a,65	;remaining place in msg buffer

		inc	b
		dec	b
		jr	nz,.buf_size

		;bc = 00xx

		cp	c
		jr	z,.buf_size
		jr	nc,.incoming_size
.buf_size
		;free size of msg buffer determines how many bytes to append

		push	bc

		ld	c,a
		ld	b,0
		ld	de,[phase]
		ld	d,msg/256

		ldir

		pop	bc

		neg
		add	a,c
		ld	c,a
		ld	a,0xFF
		adc	a,b
		ld	b,a

		push	hl
		push	bc

		ld	hl,bitLEN+1
		ld	a,2	;2*256=512=64*8
		add	a,[hl]
		ld	[hl],a
		jr	nc,.len_modified
.propagate_carry
		inc	hl
		inc	[hl]
		jr	z,.propagate_carry
.len_modified

		call	MD5_COMPRESS

		pop	bc
		pop	hl

		xor	a
		ld	[phase],a

		jr	.append_loop

.incoming_size
		;size to append determined by BC(<64), guaranteed not to overflow buffer and not to leave it in full state

		ld	a,[phase]
		ld	e,a
		add	a,c
		ld	[phase],a

		ld	d,msg/256
		ldir

		ret


CS_FINALIZE:	;finish calculation, generate asciiz string with checksum

		;in: HL - place of CS_SYMLEN+1 bytes to place asciiz string of checksum

		;kills: everything

		push	hl


		;update length
		ld	a,[phase]
		ld	b,0

		add	a,a
		rl	b
		add	a,a
		rl	b
		add	a,a
		rl	b

		ld	hl,bitLEN
		push	hl
		add	a,[hl]
		ld	[hl],a
		inc	hl
		ld	a,b
		adc	a,[hl]
		ld	[hl],a
		jr	nc,.len_updated
.propagate_carry
		inc	hl
		inc	[hl]
		jr	z,.propagate_carry
.len_updated



		ld	h,msg/256
		ld	a,[phase]
		ld	l,a

		ld	[hl],0x80
		inc	l

		ld	a,64	;must have at least 8 bytes after 0x01 appending to put length there
		sub	l
		sub	8
		jr	nc,.no_extra_block
		;append extra block
.append_zeros
		ld	[hl],0
		inc	l
		dec	a
		jr	nz,.append_zeros

		call	MD5_COMPRESS
		ld	hl,msg
		ld	a,64-8
		or	a
.no_extra_block
		jr	z,.append_len
.extra_zeros
		ld	[hl],0
		inc	l
		dec	a
		jr	nz,.extra_zeros
.append_len
		pop	de	;bitLEN
		exd
		ld	bc,8
		ldir

		call	MD5_COMPRESS


		;convert to HEX string
		pop	hl
		ld	de,stA

		ld	b,16
.convert
		call	hexconv
		djnz	.convert

		ld	[hl],0

		ret

hexconv
	ld	a,[de]
	rrca
	rrca
	rrca
	rrca
	call	.digit
	ld	a,[de]
	inc	de
.digit
	or	0xf0
	daa
	add	a,0xa0
	adc	a,0x40
	ld	[hl],a
	inc	hl
	ret


initABCD:	dh	"01234567"
		dh	"89abcdef"
		dh	"fedcba98"
		dh	"76543210"



MD5_ROUND1	MACRO	A,B,C,D,key,const,shift

		;calc F = (B&C)|(~B&D) = D^((C^D)&B)


		ld	hl,[D]	;16
		ld	de,[C]	;20

		ld	a,d
		xor	h
		ld	d,a
		ld	a,e
		xor	l
		ld	e,a
		
		ld	hl,[D+2]	;16
		ld	bc,[C+2]	;20

		ld	a,b
		xor	h
		ld	b,a
		ld	a,c
		xor	l
		ld	c,a

		;BCDE holds C^D

		ld	hl,[B]	;16

		ld	a,d
		and	h
		ld	d,a
		ld	a,e
		and	l
		ld	e,a

		ld	hl,[B+2]	;16

		ld	a,b
		and	h
		ld	b,a
		ld	a,c
		and	l
		ld	c,a

		;BCDE holds (C^D)&B

		ld	hl,[D]	;16

		ld	a,d
		xor	h
		ld	d,a
		ld	a,e
		xor	l
		ld	e,a

		ld	hl,[D+2]	;16

		ld	a,b
		xor	h
		ld	b,a
		ld	a,c
		xor	l
		ld	c,a

		;BCDE holds D^((C^D)&B) = result of F, 248tc
;	call	LOGBCDE

		; add key

		ld	hl,[key]	;16
		add	hl,de		;11
		exd
		ld	hl,[key+2]	;16
		adc	hl,bc		;15

		;HLDE contains F + key[]
;	call	LOGHLDE

		; add constant

		exd
		ld	bc,const&0xFFFF
		add	hl,bc	;11
		exd
		ld	bc,const>>16
		adc	hl,bc	;15

		;HLDE contains F + key[] + const
;	call	LOGHLDE


		; add A

		exd
		ld	bc,[A]	;20
		add	hl,bc	;11
		exd
		ld	bc,[A+2]	;20
		adc	hl,bc		;15

		;HLDE contains F + key[] + const + A, 190tc
;	call	LOGHLDE


		 IF	 shift==7
		; ROL 7 = 8-1
		ld	a,e
		rra
		rr	h	;8
		rr	l	;8
		rr	d	;8
		rr	e	;8
		ld	a,h
		ld	h,l
		ld	l,d
		ld	d,e
		ld	e,a	;60tc

		 ELSEIF	 shift==12
		; ROL 12 = 16-4
		exd	;DEHL
		xor	a
		add	hl,hl
		rl	e
		rl	d
		rla
		add	hl,hl
		rl	e
		rl	d
		rla
		add	hl,hl
		rl	e
		rl	d
		rla
		add	hl,hl
		rl	e
		rl	d
		rla
		or	l
		; ADEH -- ROR(!) 4, now rol/ror 16
		; A->D, D->E, E->H, H->L
		ld	l,h
		ld	h,e
		ld	e,d
		ld	d,a

		 ELSEIF	 shift==17
		; ROL 17 = 16+1
		ld	a,h
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		exd

		 ELSEIF	 shift==22
		; ROL 22 = 24-2
		ld	a,e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		;HLDE->EHLD
		; E->H, H->L, L->D, D->E
		ld	a,e
		ld	e,d
		ld	d,l
		ld	l,h
		ld	h,a

		 ENDIF

		;HLDE is now properly rotated, now add B
;	call	LOGHLDE

		exd	;extra? ROL 17 also has EXD at the end
		ld	bc,[B]
		add	hl,bc
		ld	bc,[B+2]
		exd
		adc	hl,bc

		;HLDE is new A
;	call	LOGHLDE

		ld	[A],de
		ld	[A+2],hl
		
		ENDM

MD5_ROUND2	MACRO	A,B,C,D,key,const,shift

		;calc G = (D&B)|(~D&C) = C^((B^C)&D)


		ld	hl,[B]	;16
		ld	de,[C]	;20

		ld	a,d
		xor	h
		ld	d,a
		ld	a,e
		xor	l
		ld	e,a
		
		ld	hl,[B+2]	;16
		ld	bc,[C+2]	;20

		ld	a,b
		xor	h
		ld	b,a
		ld	a,c
		xor	l
		ld	c,a

		;BCDE holds B^C

		ld	hl,[D]	;16

		ld	a,d
		and	h
		ld	d,a
		ld	a,e
		and	l
		ld	e,a

		ld	hl,[D+2]	;16

		ld	a,b
		and	h
		ld	b,a
		ld	a,c
		and	l
		ld	c,a

		;BCDE holds (B^C)&D

		ld	hl,[C]	;16

		ld	a,d
		xor	h
		ld	d,a
		ld	a,e
		xor	l
		ld	e,a

		ld	hl,[C+2]	;16

		ld	a,b
		xor	h
		ld	b,a
		ld	a,c
		xor	l
		ld	c,a

		;BCDE holds C^((B^C)&D) = result of F, 248tc
;	call	LOGBCDE

		; add key

		ld	hl,[key]	;16
		add	hl,de		;11
		exd
		ld	hl,[key+2]	;16
		adc	hl,bc		;15

		;HLDE contains F + key[]
;	call	LOGHLDE

		; add constant

		exd
		ld	bc,const&0xFFFF
		add	hl,bc	;11
		exd
		ld	bc,const>>16
		adc	hl,bc	;15

		;HLDE contains F + key[] + const
;	call	LOGHLDE


		; add A

		exd
		ld	bc,[A]	;20
		add	hl,bc	;11
		exd
		ld	bc,[A+2]	;20
		adc	hl,bc		;15

		;HLDE contains F + key[] + const + A, 190tc
;	call	LOGHLDE


		 IF	 shift==5
		; ROL 5
		ld	a,h
		 DUP	 5
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		 EDUP

		 ELSEIF	 shift==9
		; ROL 9 = 8+1
		ld	a,h
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		ld	a,h
		ld	h,l
		ld	l,d
		ld	d,e
		ld	e,a

		 ELSEIF	 shift==14
		; ROL 14 = 16-2
		ld	a,e
		 DUP	 2
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		 EDUP
		exd

		 ELSEIF	 shift==20
		; ROL 20 = 16+4
		ld	a,h
		 DUP	 4
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		 EDUP
		exd

		 ENDIF

		;HLDE is now properly rotated, now add B
;	call	LOGHLDE

		exd ; shift==20 has extra EXD ?
		ld	bc,[B]
		add	hl,bc
		ld	bc,[B+2]
		exd
		adc	hl,bc

		;HLDE is new A
;	call	LOGHLDE

		ld	[A],de
		ld	[A+2],hl
		
		ENDM

MD5_ROUND3	MACRO	A,B,C,D,key,const,shift

		;calc H = B^C^D

		ld	de,[B]
		ld	bc,[C]
		ld	hl,[D]
		ld	a,d
		xor	b
		xor	h
		ld	d,a
		ld	a,e
		xor	c
		xor	l
		ld	e,a

		ld	bc,[B+2]
		ld	hl,[C+2]
		ld	a,b
		xor	h
		ld	b,a
		ld	a,c
		xor	l
		ld	hl,[D+2]
		xor	l
		ld	c,a
		ld	a,b
		xor	h
		ld	b,a

		;BCDE holds B^C^D
;	call	LOGBCDE

		; add key

		ld	hl,[key]	;16
		add	hl,de		;11
		exd
		ld	hl,[key+2]	;16
		adc	hl,bc		;15

		;HLDE contains F + key[]
;	call	LOGHLDE

		; add constant

		exd
		ld	bc,const&0xFFFF
		add	hl,bc	;11
		exd
		ld	bc,const>>16
		adc	hl,bc	;15

		;HLDE contains F + key[] + const
;	call	LOGHLDE


		; add A

		exd
		ld	bc,[A]	;20
		add	hl,bc	;11
		exd
		ld	bc,[A+2]	;20
		adc	hl,bc		;15

		;HLDE contains F + key[] + const + A, 190tc
;	call	LOGHLDE


		 IF	 shift==4
		; ROL 4
		ld	a,h
		 DUP	 4
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		 EDUP

		 ELSEIF	 shift==11
		; ROL 11 = 3 + 8
		ld	a,h
		 DUP	 3
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		 EDUP
		ld	a,h
		ld	h,l
		ld	l,d
		ld	d,e
		ld	e,a

		 ELSEIF	 shift==16
		; ROL 16
		exd

		 ELSEIF	 shift==23
		; ROL 23 = 24 - 1
		ld	a,e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		ld	a,e
		ld	e,d
		ld	d,l
		ld	l,h
		ld	h,a

		 ENDIF

		;HLDE is now properly rotated, now add B
;	call	LOGHLDE

		exd ; shift==20 has extra EXD ?
		ld	bc,[B]
		add	hl,bc
		ld	bc,[B+2]
		exd
		adc	hl,bc

		;HLDE is new A
;	call	LOGHLDE

		ld	[A],de
		ld	[A+2],hl
		
		ENDM

MD5_ROUND4	MACRO	A,B,C,D,key,const,shift

		;calc I = C ^ (B | (~D))

		ld	de,[C]
		ld	bc,[B]
		ld	hl,[D]
		ld	a,h
		cpl
		or	b
		xor	d
		ld	d,a
		ld	a,l
		cpl
		or	c
		xor	e
		ld	e,a

		ld	bc,[B+2]
		ld	hl,[D+2]
		ld	a,h
		cpl
		or	b
		ld	b,a
		ld	a,l
		cpl
		or	c
		ld	hl,[C+2]
		xor	l
		ld	c,a
		ld	a,b
		xor	h
		ld	b,a

		;BCDE holds B^C^D
;	call	LOGBCDE

		; add key

		ld	hl,[key]	;16
		add	hl,de		;11
		exd
		ld	hl,[key+2]	;16
		adc	hl,bc		;15

		;HLDE contains F + key[]
;	call	LOGHLDE

		; add constant

		exd
		ld	bc,const&0xFFFF
		add	hl,bc	;11
		exd
		ld	bc,const>>16
		adc	hl,bc	;15

		;HLDE contains F + key[] + const
;	call	LOGHLDE


		; add A

		exd
		ld	bc,[A]	;20
		add	hl,bc	;11
		exd
		ld	bc,[A+2]	;20
		adc	hl,bc		;15

		;HLDE contains F + key[] + const + A, 190tc
;	call	LOGHLDE


		 IF	 shift==6
		; ROL 6 = 8 - 2
		ld	a,e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		ld	a,h
		ld	h,l
		ld	l,d
		ld	d,e
		ld	e,a

		 ELSEIF	 shift==10
		; ROL 10 = 2 + 8
		ld	a,h
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		add	a,a
		rl	e
		rl	d
		adc	hl,hl
		ld	a,h
		ld	h,l
		ld	l,d
		ld	d,e
		ld	e,a

		 ELSEIF	 shift==15
		; ROL 15 = 16 - 1
		ld	a,e
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		exd

		 ELSEIF	 shift==21
		; ROL 21 = 24 - 3
		ld	a,e
		 DUP	 3
		rra
		rr	h
		rr	l
		rr	d
		rr	e
		 EDUP
		ld	a,e
		ld	e,d
		ld	d,l
		ld	l,h
		ld	h,a

		 ENDIF

		;HLDE is now properly rotated, now add B
;	call	LOGHLDE

		exd ; shift==20 has extra EXD ?
		ld	bc,[B]
		add	hl,bc
		ld	bc,[B+2]
		exd
		adc	hl,bc

		;HLDE is new A
;	call	LOGHLDE

		ld	[A],de
		ld	[A+2],hl
		
		ENDM



MD5_COMPRESS	;make transformations in tmp
		ld	hl,stA
		ld	de,tmpA
		ld	bc,16
		ldir

		; rounds...
;	call	LOGTMP
		MD5_ROUND1	tmpA,tmpB,tmpC,tmpD, msg+ 0*4, 0xd76aa478,  7
;	call	LOGTMP
		MD5_ROUND1	tmpD,tmpA,tmpB,tmpC, msg+ 1*4, 0xe8c7b756, 12
;	call	LOGTMP
		MD5_ROUND1	tmpC,tmpD,tmpA,tmpB, msg+ 2*4, 0x242070db, 17
;	call	LOGTMP
		MD5_ROUND1	tmpB,tmpC,tmpD,tmpA, msg+ 3*4, 0xc1bdceee, 22
;	call	LOGTMP
		MD5_ROUND1	tmpA,tmpB,tmpC,tmpD, msg+ 4*4, 0xf57c0faf,  7
;	call	LOGTMP
		MD5_ROUND1	tmpD,tmpA,tmpB,tmpC, msg+ 5*4, 0x4787c62a, 12
;	call	LOGTMP
		MD5_ROUND1	tmpC,tmpD,tmpA,tmpB, msg+ 6*4, 0xa8304613, 17
;	call	LOGTMP
		MD5_ROUND1	tmpB,tmpC,tmpD,tmpA, msg+ 7*4, 0xfd469501, 22
;	call	LOGTMP
		MD5_ROUND1	tmpA,tmpB,tmpC,tmpD, msg+ 8*4, 0x698098d8,  7
;	call	LOGTMP
		MD5_ROUND1	tmpD,tmpA,tmpB,tmpC, msg+ 9*4, 0x8b44f7af, 12
;	call	LOGTMP
		MD5_ROUND1	tmpC,tmpD,tmpA,tmpB, msg+10*4, 0xffff5bb1, 17
;	call	LOGTMP
		MD5_ROUND1	tmpB,tmpC,tmpD,tmpA, msg+11*4, 0x895cd7be, 22
;	call	LOGTMP
		MD5_ROUND1	tmpA,tmpB,tmpC,tmpD, msg+12*4, 0x6b901122,  7
;	call	LOGTMP
		MD5_ROUND1	tmpD,tmpA,tmpB,tmpC, msg+13*4, 0xfd987193, 12
;	call	LOGTMP
		MD5_ROUND1	tmpC,tmpD,tmpA,tmpB, msg+14*4, 0xa679438e, 17
;	call	LOGTMP
		MD5_ROUND1	tmpB,tmpC,tmpD,tmpA, msg+15*4, 0x49b40821, 22
;	call	LOGTMP

;	call	LOGTMP
		MD5_ROUND2	tmpA,tmpB,tmpC,tmpD, msg+ 1*4, 0xf61e2562,  5
;	call	LOGTMP
		MD5_ROUND2	tmpD,tmpA,tmpB,tmpC, msg+ 6*4, 0xc040b340,  9
;	call	LOGTMP
		MD5_ROUND2	tmpC,tmpD,tmpA,tmpB, msg+11*4, 0x265e5a51, 14
;	call	LOGTMP
		MD5_ROUND2	tmpB,tmpC,tmpD,tmpA, msg+ 0*4, 0xe9b6c7aa, 20
;	call	LOGTMP
		MD5_ROUND2	tmpA,tmpB,tmpC,tmpD, msg+ 5*4, 0xd62f105d,  5
;	call	LOGTMP
		MD5_ROUND2	tmpD,tmpA,tmpB,tmpC, msg+10*4, 0x02441453,  9
;	call	LOGTMP
		MD5_ROUND2	tmpC,tmpD,tmpA,tmpB, msg+15*4, 0xd8a1e681, 14
;	call	LOGTMP
		MD5_ROUND2	tmpB,tmpC,tmpD,tmpA, msg+ 4*4, 0xe7d3fbc8, 20
;	call	LOGTMP
		MD5_ROUND2	tmpA,tmpB,tmpC,tmpD, msg+ 9*4, 0x21e1cde6,  5
;	call	LOGTMP
		MD5_ROUND2	tmpD,tmpA,tmpB,tmpC, msg+14*4, 0xc33707d6,  9
;	call	LOGTMP
		MD5_ROUND2	tmpC,tmpD,tmpA,tmpB, msg+ 3*4, 0xf4d50d87, 14
;	call	LOGTMP
		MD5_ROUND2	tmpB,tmpC,tmpD,tmpA, msg+ 8*4, 0x455a14ed, 20
;	call	LOGTMP
		MD5_ROUND2	tmpA,tmpB,tmpC,tmpD, msg+13*4, 0xa9e3e905,  5
;	call	LOGTMP
		MD5_ROUND2	tmpD,tmpA,tmpB,tmpC, msg+ 2*4, 0xfcefa3f8,  9
;	call	LOGTMP
		MD5_ROUND2	tmpC,tmpD,tmpA,tmpB, msg+ 7*4, 0x676f02d9, 14
;	call	LOGTMP
		MD5_ROUND2	tmpB,tmpC,tmpD,tmpA, msg+12*4, 0x8d2a4c8a, 20
;	call	LOGTMP

;	call	LOGTMP
		MD5_ROUND3	tmpA,tmpB,tmpC,tmpD, msg+ 5*4, 0xfffa3942,  4
;	call	LOGTMP
		MD5_ROUND3	tmpD,tmpA,tmpB,tmpC, msg+ 8*4, 0x8771f681, 11
;	call	LOGTMP
		MD5_ROUND3	tmpC,tmpD,tmpA,tmpB, msg+11*4, 0x6d9d6122, 16
;	call	LOGTMP
		MD5_ROUND3	tmpB,tmpC,tmpD,tmpA, msg+14*4, 0xfde5380c, 23
;	call	LOGTMP
		MD5_ROUND3	tmpA,tmpB,tmpC,tmpD, msg+ 1*4, 0xa4beea44,  4
;	call	LOGTMP
		MD5_ROUND3	tmpD,tmpA,tmpB,tmpC, msg+ 4*4, 0x4bdecfa9, 11
;	call	LOGTMP
		MD5_ROUND3	tmpC,tmpD,tmpA,tmpB, msg+ 7*4, 0xf6bb4b60, 16
;	call	LOGTMP
		MD5_ROUND3	tmpB,tmpC,tmpD,tmpA, msg+10*4, 0xbebfbc70, 23
;	call	LOGTMP
		MD5_ROUND3	tmpA,tmpB,tmpC,tmpD, msg+13*4, 0x289b7ec6,  4
;	call	LOGTMP
		MD5_ROUND3	tmpD,tmpA,tmpB,tmpC, msg+ 0*4, 0xeaa127fa, 11
;	call	LOGTMP
		MD5_ROUND3	tmpC,tmpD,tmpA,tmpB, msg+ 3*4, 0xd4ef3085, 16
;	call	LOGTMP
		MD5_ROUND3	tmpB,tmpC,tmpD,tmpA, msg+ 6*4, 0x04881d05, 23
;	call	LOGTMP
		MD5_ROUND3	tmpA,tmpB,tmpC,tmpD, msg+ 9*4, 0xd9d4d039,  4
;	call	LOGTMP
		MD5_ROUND3	tmpD,tmpA,tmpB,tmpC, msg+12*4, 0xe6db99e5, 11
;	call	LOGTMP
		MD5_ROUND3	tmpC,tmpD,tmpA,tmpB, msg+15*4, 0x1fa27cf8, 16
;	call	LOGTMP
		MD5_ROUND3	tmpB,tmpC,tmpD,tmpA, msg+ 2*4, 0xc4ac5665, 23
;	call	LOGTMP

;	call	LOGTMP
		MD5_ROUND4	tmpA,tmpB,tmpC,tmpD, msg+ 0*4, 0xf4292244,  6
;	call	LOGTMP
		MD5_ROUND4	tmpD,tmpA,tmpB,tmpC, msg+ 7*4, 0x432aff97, 10
;	call	LOGTMP
		MD5_ROUND4	tmpC,tmpD,tmpA,tmpB, msg+14*4, 0xab9423a7, 15
;	call	LOGTMP
		MD5_ROUND4	tmpB,tmpC,tmpD,tmpA, msg+ 5*4, 0xfc93a039, 21
;	call	LOGTMP
		MD5_ROUND4	tmpA,tmpB,tmpC,tmpD, msg+12*4, 0x655b59c3,  6
;	call	LOGTMP
		MD5_ROUND4	tmpD,tmpA,tmpB,tmpC, msg+ 3*4, 0x8f0ccc92, 10
;	call	LOGTMP
		MD5_ROUND4	tmpC,tmpD,tmpA,tmpB, msg+10*4, 0xffeff47d, 15
;	call	LOGTMP
		MD5_ROUND4	tmpB,tmpC,tmpD,tmpA, msg+ 1*4, 0x85845dd1, 21
;	call	LOGTMP
		MD5_ROUND4	tmpA,tmpB,tmpC,tmpD, msg+ 8*4, 0x6fa87e4f,  6
;	call	LOGTMP
		MD5_ROUND4	tmpD,tmpA,tmpB,tmpC, msg+15*4, 0xfe2ce6e0, 10
;	call	LOGTMP
		MD5_ROUND4	tmpC,tmpD,tmpA,tmpB, msg+ 6*4, 0xa3014314, 15
;	call	LOGTMP
		MD5_ROUND4	tmpB,tmpC,tmpD,tmpA, msg+13*4, 0x4e0811a1, 21
;	call	LOGTMP
		MD5_ROUND4	tmpA,tmpB,tmpC,tmpD, msg+ 4*4, 0xf7537e82,  6
;	call	LOGTMP
		MD5_ROUND4	tmpD,tmpA,tmpB,tmpC, msg+11*4, 0xbd3af235, 10
;	call	LOGTMP
		MD5_ROUND4	tmpC,tmpD,tmpA,tmpB, msg+ 2*4, 0x2ad7d2bb, 15
;	call	LOGTMP
		MD5_ROUND4	tmpB,tmpC,tmpD,tmpA, msg+ 9*4, 0xeb86d391, 21
;	call	LOGTMP

		; add transformed tmp to st
		ld	hl,tmpA
		ld	de,stA
		ld	b,4
.add_result
		ld	a,[de]
		add	a,[hl]
		ld	[de],a
		inc	e
		inc	l
		 REPT	 3
		ld	a,[de]
		adc	a,[hl]
		ld	[de],a
		inc	e
		inc	l
		 EDUP
		djnz	.add_result

;	call	LOGST

		ret


LOGBCDE
		push	bc
		push	de
		push	hl

		ld	[tmparea],de
		ld	[tmparea+2],bc

		ld	de,tmparea
		ld	hl,pri1
		call	logtmp1

		pop	hl
		pop	de
		pop	bc
		ret
LOGHLDE
		push	bc
		push	de
		push	hl

		ld	[tmparea],de
		ld	[tmparea+2],hl

		ld	de,tmparea
		ld	hl,pri1
		call	logtmp1

		pop	hl
		pop	de
		pop	bc
		ret

LOGST
		ld	de,stA
		ld	hl,pri1
		jr	LOGTMP4

LOGTMP
		ld	de,tmpA
		ld	hl,pri1
LOGTMP4
		call	hexconv
		call	hexconv
		call	hexconv
		call	hexconv
		ld	[hl],' '
		inc	hl
		call	hexconv
		call	hexconv
		call	hexconv
		call	hexconv
		ld	[hl],' '
		inc	hl
logtmp2
		call	hexconv
		call	hexconv
		call	hexconv
		call	hexconv
		ld	[hl],' '
		inc	hl
logtmp1
		call	hexconv
		call	hexconv
		call	hexconv
		call	hexconv
		ld	[hl],13
		inc	hl
		ld	[hl],10
		inc	hl
		ld	[hl],0

		ld	hl,pri1
		jp	prtext

tmparea	ds	4

pri1	ds	40






phase		ds	1	;0..63

bitLEN		ds	8	;length in BITs

		org	($+255)&0xFF00

msg		ds	64

stA		ds	4
stB		ds	4
stC		ds	4
stD		ds	4

tmpA		ds	4
tmpB		ds	4
tmpC		ds	4
tmpD		ds	4

