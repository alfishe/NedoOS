;
; Direct text-VRAM spans for panel rows and the status line.
; One OS_PRCHAR switches C000 three times; a whole row used to do that
; 38 times. Here the text page is mapped once, then the attr page once.
;
; CP866 -> ATM font matches textview/tv_paint.asm (same as kernel trecode).
; Screen address is BDOS countxy (window at C000).
;
; C sets nco_vx, nco_vy, nco_vn, nco_va, nco_vp before the call.
; nco_vram_begin saves the current C000 page (curpgc000) and maps text.
; nco_vram_end maps that page back.
;
	MODULE nco_vram
	PUBLIC nco_vram_span
	PUBLIC nco_vram_begin
	PUBLIC nco_vram_text
	PUBLIC nco_vram_attr_begin
	PUBLIC nco_vram_attr
	PUBLIC nco_vram_end
	EXTERN SETPG32KHIGH
	EXTERN nco_vx, nco_vy, nco_vn, nco_va, nco_vp
#include "sysdefs.asm"

	RSEG UDATA0
nv_home:	DEFS 1
nv_scr:		DEFS 2
nv_src:		DEFS 2

	RSEG CODE

nco_vram_span:
	push	ix
	push	iy
	call	nv_begin
	call	nv_text
	call	nv_attr_begin
	call	nv_attr
	call	nv_end
	pop	iy
	pop	ix
	ret

nco_vram_begin:
	push	ix
	push	iy
	call	nv_begin
	pop	iy
	pop	ix
	ret

nco_vram_text:
	push	ix
	push	iy
	call	nv_text
	pop	iy
	pop	ix
	ret

nco_vram_attr_begin:
	push	ix
	push	iy
	call	nv_attr_begin
	pop	iy
	pop	ix
	ret

nco_vram_attr:
	push	ix
	push	iy
	call	nv_attr
	pop	iy
	pop	ix
	ret

nco_vram_end:
	push	ix
	push	iy
	call	nv_end
	pop	iy
	pop	ix
	ret

nv_begin:
	ld	a,(curpgc000)
	ld	(nv_home),a
	ld	a,(user_scr0_high)
	ld	e,a
	jp	SETPG32KHIGH

nv_end:
	ld	a,(nv_home)
	ld	e,a
	jp	SETPG32KHIGH

nv_attr_begin:
	ld	a,(user_scr0_low)
	ld	e,a
	jp	SETPG32KHIGH

nv_load_xy:
	ld	a,(nco_vn)
	or	a
	ret	z
	ld	b,a
	ld	a,(nco_vy)
	ld	d,a
	ld	a,(nco_vx)
	ld	e,a
	call	nv_countxy
	ld	(nv_scr),hl
	ld	a,1
	or	a
	ret

nv_text:
	call	nv_load_xy
	ret	z
	ld	hl,(nco_vp)
	ld	(nv_src),hl
nv_tloop:
	ld	hl,(nv_src)
	ld	a,(hl)
	inc	hl
	ld	(nv_src),hl
	ld	hl,nco_recode
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	ld	hl,(nv_scr)
	ld	(hl),a
	call	nv_step
	ld	(nv_scr),hl
	djnz	nv_tloop
	ret

nv_attr:
	call	nv_load_xy
	ret	z
	ld	a,(nco_va)
	ld	c,a
nv_aloop:
	ld	hl,(nv_scr)
	ld	a,h
	xor	020h
	ld	h,a
	and	020h
	jr	nz,nv_as
	inc	l
nv_as:
	ld	(hl),c
	ld	hl,(nv_scr)
	call	nv_step
	ld	(nv_scr),hl
	djnz	nv_aloop
	ret

; D=y E=x -> HL. Same shifts as BDOS_countxy / tv_paint countxy.
nv_countxy:
	ld	a,d
	sub	079h
	rra
	ld	h,a
	ld	a,0
	rra
	sra	h
	rra
	ld	l,e
	srl	l
	jr	c,nv_xy_odd
	res	5,h
nv_xy_odd:
	add	a,l
	ld	l,a
	ret

nv_step:
	ld	a,h
	xor	020h
	ld	h,a
	and	020h
	ret	nz
	inc	l
	ret

	RSEG CONST
nco_recode:
	DEFB 000h,001h,002h,003h,004h,005h,006h,007h,008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh
	DEFB 010h,011h,012h,013h,014h,015h,016h,017h,018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh
	DEFB 020h,021h,022h,023h,024h,025h,026h,027h,028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh
	DEFB 030h,031h,032h,033h,034h,035h,036h,037h,038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh
	DEFB 040h,041h,042h,043h,044h,045h,046h,047h,048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh
	DEFB 050h,051h,052h,053h,054h,055h,056h,057h,058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh
	DEFB 060h,061h,062h,063h,064h,065h,066h,067h,068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh
	DEFB 070h,071h,072h,073h,074h,075h,076h,077h,078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh
	DEFB 0C1h,0C2h,0D7h,0C7h,0C4h,0C5h,0D6h,0DAh,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh,0D0h
	DEFB 0D2h,0D3h,0D4h,0D5h,0C6h,0C8h,0C3h,0DEh,0DBh,0DDh,0DFh,0D9h,0D8h,0DCh,0C0h,0D1h
	DEFB 0E1h,0E2h,0F7h,0E7h,0E4h,0E5h,0F6h,0FAh,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh,0F0h
	DEFB 080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh
	DEFB 090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh
	DEFB 0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h,0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh
	DEFB 0F2h,0F3h,0F4h,0F5h,0E6h,0E8h,0E3h,0FEh,0FBh,0FDh,0FFh,0F9h,0F8h,0FCh,0E0h,0F1h
	DEFB 0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h,0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh

	ENDMOD
	END
