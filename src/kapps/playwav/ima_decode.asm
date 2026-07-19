;
; Fast MS IMA ADPCM block decoder -> 16K Covox pages.
; Replaces slow IAR C wav_ima_decode_block_pages.
;
; Call (IAR Z80):
;   DE = block, BC = block_len
;   stack: info*, page_idx*, page_off*, max_pages
;   return HL = samples written
;
; Stereo: MS WAV IMA ? per-channel (pred,step,res), then 4-byte
; L/R groups; downmix to mono Covox.
;
	MODULE ima_decode
	PUBLIC wav_ima_decode_block_pages
	EXTERN sample_pages
	EXTERN SETPG32KHIGH

	RSEG UDATA0
dec_page_idx:	DEFS 1
dec_max_pages:	DEFS 1
dec_out_lo:	DEFS 1
dec_out_hi:	DEFS 1
dec_idx_ptr:	DEFS 2
dec_off_ptr:	DEFS 2
dec_pred0:	DEFS 2
dec_pred1:	DEFS 2
dec_step0:	DEFS 1
dec_step1:	DEFS 1
dec_src:	DEFS 2
dec_src_end:	DEFS 2
dec_dst:	DEFS 2
dec_tmp:	DEFS 1
dec_buf_l:	DEFS 8
dec_buf_r:	DEFS 8

	RSEG CONST
ima_index_table:
	DEFB	-1,-1,-1,-1,2,4,6,8
	DEFB	-1,-1,-1,-1,2,4,6,8

ima_step_table:
	DEFW	7,8,9,10,11,12,13,14,16,17
	DEFW	19,21,23,25,28,31,34,37,41,45
	DEFW	50,55,60,66,73,80,88,97,107,118
	DEFW	130,143,157,173,190,209,230,253,279,307
	DEFW	337,371,408,449,494,544,598,658,724,796
	DEFW	876,963,1060,1166,1282,1411,1552,1707,1878,2066
	DEFW	2272,2499,2749,3024,3327,3660,4026,4428,4871,5358
	DEFW	5894,6484,7132,7845,8630,9493,10442,11487,12635,13899
	DEFW	15289,16818,18500,20350,22385,24623,27086,29794,32767

	RSEG CODE

wav_ima_decode_block_pages:
	push	iy
	push	ix
	ld	ix,0
	add	ix,sp
	push	bc
	push	de

	xor	a
	ld	(dec_out_lo),a
	ld	(dec_out_hi),a

	ld	l,(ix+6)
	ld	h,(ix+7)
	ld	de,6
	add	hl,de
	ld	a,(hl)
	cp	1
	jr	z,ch_ok
	cp	2
	jp	nz,ret0
ch_ok:
	ld	c,a

	ld	a,(ix-2)
	or	(ix-1)
	jp	z,ret0

	ld	l,(ix+8)
	ld	h,(ix+9)
	ld	(dec_idx_ptr),hl
	ld	a,(hl)
	ld	(dec_page_idx),a
	ld	b,(ix+12)
	ld	a,b
	ld	(dec_max_pages),a
	ld	a,(dec_page_idx)
	cp	b
	jp	nc,ret0

	ld	l,(ix+10)
	ld	h,(ix+11)
	ld	(dec_off_ptr),hl

	ld	a,c
	add	a,a
	add	a,a
	ld	e,a
	ld	d,0
	ld	l,(ix-2)
	ld	h,(ix-1)
	or	a
	sbc	hl,de
	jp	c,ret0

	ld	l,(ix-4)
	ld	h,(ix-3)
	ld	(dec_src),hl
	ld	e,(ix-2)
	ld	d,(ix-1)
	add	hl,de
	ld	(dec_src_end),hl

	ld	l,(ix+10)
	ld	h,(ix+11)
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,h
	or	0C0h
	ld	h,a
	ld	(dec_dst),hl

	ld	a,c
	dec	a
	jp	nz,do_stereo

;======== MONO ================================================
	ld	hl,(dec_src)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(dec_pred0),de
	ld	a,(hl)
	inc	hl
	cp	89
	jr	c,m_stok
	ld	a,88
m_stok:
	ld	(dec_step0),a
	inc	hl
	ld	(dec_src),hl

	ld	hl,(dec_pred0)
	call	pred_to_covox
	call	page_store
	jp	c,finish

m_loop:
	ld	hl,(dec_src)
	ld	de,(dec_src_end)
	or	a
	sbc	hl,de
	jp	nc,finish
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	(dec_src),hl
	ld	(dec_tmp),a		; ima_update clobbers C

	and	15
	ld	hl,(dec_pred0)
	ld	b,a
	ld	a,(dec_step0)
	ld	e,a
	ld	a,b
	call	ima_update
	ld	(dec_pred0),hl
	ld	a,e
	ld	(dec_step0),a
	call	pred_to_covox
	call	page_store
	jp	c,finish

	ld	a,(dec_tmp)
	rra
	rra
	rra
	rra
	and	15
	ld	hl,(dec_pred0)
	ld	b,a
	ld	a,(dec_step0)
	ld	e,a
	ld	a,b
	call	ima_update
	ld	(dec_pred0),hl
	ld	a,e
	ld	(dec_step0),a
	call	pred_to_covox
	call	page_store
	jp	c,finish
	jp	m_loop

;======== STEREO ==============================================
do_stereo:
	ld	hl,(dec_src)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(dec_pred0),de
	ld	a,(hl)
	inc	hl
	cp	89
	jr	c,s0ok
	ld	a,88
s0ok:
	ld	(dec_step0),a
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(dec_pred1),de
	ld	a,(hl)
	inc	hl
	cp	89
	jr	c,s1ok
	ld	a,88
s1ok:
	ld	(dec_step1),a
	inc	hl
	ld	(dec_src),hl

	ld	hl,(dec_pred0)
	call	pred_to_covox
	ld	c,a
	ld	hl,(dec_pred1)
	call	pred_to_covox
	ld	b,a
	call	mix_covox
	call	page_store
	jp	c,finish

s_loop:
	ld	hl,(dec_src)
	ld	de,(dec_src_end)
	or	a
	sbc	hl,de
	jp	nc,finish
	add	hl,de
	ex	de,hl
	or	a
	sbc	hl,de
	ld	a,h
	or	a
	jr	nz,s_have8
	ld	a,l
	cp	8
	jp	c,s_tail
s_have8:
	ld	de,(dec_src)
	ld	hl,(dec_pred0)
	ld	a,(dec_step0)
	ld	b,a
	ld	iy,dec_buf_l
	call	decode_4bytes_buf
	ld	(dec_pred0),hl
	ld	a,b
	ld	(dec_step0),a
	ld	(dec_src),de

	ld	hl,(dec_pred1)
	ld	a,(dec_step1)
	ld	b,a
	ld	iy,dec_buf_r
	call	decode_4bytes_buf
	ld	(dec_pred1),hl
	ld	a,b
	ld	(dec_step1),a
	ld	(dec_src),de

	ld	hl,dec_buf_l
	ld	de,dec_buf_r
	ld	b,8
s_emit:
	ld	c,(hl)
	ld	a,(de)
	push	bc
	push	de
	push	hl
	ld	b,a
	call	mix_covox
	call	page_store
	pop	hl
	pop	de
	pop	bc
	jp	c,finish
	inc	hl
	inc	de
	djnz	s_emit
	jp	s_loop

; Partial group at EOF: low nibble=L, high=R per byte
s_tail:
	ld	hl,(dec_src)
st_loop:
	ld	de,(dec_src_end)
	or	a
	sbc	hl,de
	jp	nc,finish
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	(dec_src),hl
	ld	(dec_tmp),a		; ima_update clobbers C

	and	15
	ld	hl,(dec_pred0)
	ld	b,a
	ld	a,(dec_step0)
	ld	e,a
	ld	a,b
	call	ima_update
	ld	(dec_pred0),hl
	ld	a,e
	ld	(dec_step0),a

	ld	a,(dec_tmp)
	rra
	rra
	rra
	rra
	and	15
	ld	hl,(dec_pred1)
	ld	b,a
	ld	a,(dec_step1)
	ld	e,a
	ld	a,b
	call	ima_update
	ld	(dec_pred1),hl
	ld	a,e
	ld	(dec_step1),a

	ld	hl,(dec_pred0)
	call	pred_to_covox
	ld	c,a
	ld	hl,(dec_pred1)
	call	pred_to_covox
	ld	b,a
	call	mix_covox
	call	page_store
	jp	c,finish
	ld	hl,(dec_src)
	jp	st_loop

;--------------------------------------------------------------
; DE=src, HL=pred, B=step, IY=dest[8]
; Out: DE+=4, HL=pred, B=step
;--------------------------------------------------------------
decode_4bytes_buf:
	ld	c,4
d4_byte:
	ld	a,(de)
	inc	de
	ld	(dec_tmp),a
	push	de
	push	bc			; B=step, C=count
	; low nibble
	and	15
	ld	e,b
	call	ima_update
	ld	b,e
	call	pred_to_covox
	ld	(iy+0),a
	inc	iy
	; high nibble
	ld	a,(dec_tmp)
	rra
	rra
	rra
	rra
	and	15
	ld	e,b
	call	ima_update
	ld	b,e
	call	pred_to_covox
	ld	(iy+0),a
	inc	iy
	ld	a,b
	pop	bc
	ld	b,a
	pop	de
	dec	c
	jr	nz,d4_byte
	ret

;==============================================================
pred_to_covox:
	ld	a,h
	add	a,128
	ret	nz
	ld	a,1
	ret

mix_covox:
	ld	l,c
	ld	h,0
	ld	e,b
	ld	d,0
	add	hl,de
	inc	hl
	srl	h
	rr	l
	ld	a,l
	ret

; Store A at dec_dst. CF=1 if pages exhausted.
page_store:
	push	af
	ld	a,(dec_page_idx)
	ld	b,a
	ld	a,(dec_max_pages)
	cp	b
	jr	z,ps_fail
	jr	c,ps_fail
	pop	af
	ld	hl,(dec_dst)
	ld	(hl),a
	inc	hl
	ld	(dec_dst),hl
	ld	hl,dec_out_lo
	inc	(hl)
	jr	nz,ps_chk
	inc	hl
	inc	(hl)
ps_chk:
	ld	hl,(dec_dst)
	ld	a,h
	or	l
	jr	nz,ps_ok
	ld	a,(dec_page_idx)
	inc	a
	ld	(dec_page_idx),a
	ld	b,a
	ld	a,(dec_max_pages)
	cp	b
	jr	z,ps_wrap
	jr	c,ps_wrap
	ld	l,b
	ld	h,0
	ld	de,sample_pages
	add	hl,de
	ld	e,(hl)
	push	bc
	call	SETPG32KHIGH
	pop	bc
ps_wrap:
	ld	hl,0C000h
	ld	(dec_dst),hl
ps_ok:
	or	a
	ret
ps_fail:
	pop	af
	scf
	ret

; A=nibble, E=step_idx, HL=pred -> HL=pred, E=step_idx
ima_update:
	ld	c,a
	ld	b,e
	push	hl
	ld	l,b
	ld	h,0
	add	hl,hl
	ld	de,ima_step_table
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,e
	ld	h,d
	srl	h
	rr	l
	srl	h
	rr	l
	srl	h
	rr	l
	bit	2,c
	jr	z,iu_n4
	add	hl,de
iu_n4:
	push	de
	bit	1,c
	jr	z,iu_n2
	srl	d
	rr	e
	add	hl,de
iu_n2:
	pop	de
	bit	0,c
	jr	z,iu_n1
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl,de
iu_n1:
	ex	de,hl
	pop	hl
	push	bc			; B=step_idx, C=nibble (sat_* clobbers C)
	bit	3,c
	jr	nz,iu_sub
	call	sat_add
	jr	iu_idx
iu_sub:
	call	sat_sub
iu_idx:
	pop	bc
	push	hl
	ld	a,c
	and	15
	ld	e,a
	ld	d,0
	ld	hl,ima_index_table
	add	hl,de
	ld	a,(hl)
	add	a,b
	jp	m,iu_i0
	cp	89
	jr	c,iu_iok
	ld	a,88
	jr	iu_iok
iu_i0:
	xor	a
iu_iok:
	ld	e,a
	pop	hl
	ret

; HL += DE (unsigned mag), saturate to int16
sat_add:
	ld	a,h
	rla
	sbc	a,a
	ld	c,a
	add	hl,de
	ld	a,c
	adc	a,0
	or	a
	jr	z,sa_pos
	cp	0FFh
	ret	z
	bit	7,a
	jr	nz,sa_min
sa_max:
	ld	hl,7FFFh
	ret
sa_min:
	ld	hl,8000h
	ret
sa_pos:
	bit	7,h
	ret	z
	jr	sa_max

; HL -= DE (unsigned mag), saturate to int16
sat_sub:
	ld	a,h
	rla
	sbc	a,a
	ld	c,a
	or	a
	sbc	hl,de
	ld	a,c
	sbc	a,0
	or	a
	jr	z,ss_pos
	cp	0FFh
	ret	z
	bit	7,a
	jr	nz,sa_min
	jr	sa_max
ss_pos:
	bit	7,h
	jr	nz,sa_max
	ret

finish:
	ld	hl,(dec_idx_ptr)
	ld	a,(dec_page_idx)
	ld	(hl),a
	ld	hl,(dec_dst)
	ld	a,h
	and	03Fh
	ld	h,a
	ex	de,hl
	ld	hl,(dec_off_ptr)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	a,(dec_out_lo)
	ld	l,a
	ld	a,(dec_out_hi)
	ld	h,a
	jr	ret_hl

ret0:
	ld	hl,0
ret_hl:
	ld	sp,ix
	pop	ix
	pop	iy
	ret

	ENDMOD
	END
