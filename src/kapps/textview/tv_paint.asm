;
; One 80-column row: CP866 bytes -> ATM font codes, straight into text VRAM.
; void tv_paint_row(unsigned char y, unsigned char attr);  IAR: E=y, C=attr
; Source: tv_row_ptr (80 bytes). Restores tv_scr_home at C000.
;
	MODULE tv_paint
	PUBLIC tv_paint_row
	PUBLIC tv_scr_pg_text, tv_scr_pg_attr, tv_scr_home
	PUBLIC tv_row_ptr
	EXTERN SETPG32KHIGH

	RSEG UDATA0
tv_scr_pg_text:	DEFS 1
tv_scr_pg_attr:	DEFS 1
tv_scr_home:	DEFS 1
tv_row_ptr:	DEFS 2
tp_y:		DEFS 1
tp_attr:	DEFS 1
tp_scr:		DEFS 2
tp_src:		DEFS 2

	RSEG CODE

tv_paint_row:
	push ix
	push iy
	push bc
	push de
	ld a,e
	ld (tp_y),a
	ld a,c
	ld (tp_attr),a

	ld a,(tv_scr_pg_text)
	ld e,a
	call SETPG32KHIGH

	ld a,(tp_y)
	ld d,a
	ld e,0
	call countxy
	ld (tp_scr),hl
	ld hl,(tv_row_ptr)
	ld (tp_src),hl

	ld b,80
tp_text:
	ld de,(tp_src)
	ld a,(de)
	inc de
	ld (tp_src),de
	or a
	jr nz,tp_nz
	ld a,' '
tp_nz:
	ld l,a
	ld h,0
	ld de,cp866_atm
	add hl,de
	ld a,(hl)
	ld hl,(tp_scr)
	ld (hl),a
	call step_xy
	ld (tp_scr),hl
	djnz tp_text

	ld a,(tv_scr_pg_attr)
	ld e,a
	call SETPG32KHIGH

	ld a,(tp_y)
	ld d,a
	ld e,0
	call countxy
	ld (tp_scr),hl
	ld a,(tp_attr)
	ld c,a
	ld b,80
tp_aloop:
	ld hl,(tp_scr)
	push hl
	ld a,h
	xor 020h
	ld h,a
	and 020h
	jr nz,tp_as
	inc l
tp_as:
	ld (hl),c
	pop hl
	call step_xy
	ld (tp_scr),hl
	djnz tp_aloop

	ld a,(tv_scr_home)
	ld e,a
	call SETPG32KHIGH

	pop de
	pop bc
	pop iy
	pop ix
	ret

; BDOS countxy: D=y, E=x -> HL screen address (even/odd bit in H.5)
countxy:
	ld a,d
	sub 079h
	rra
	ld h,a
	ld a,0
	rra
	sra h
	rra
	ld l,e
	srl l
	jr c,countxy_odd
	res 5,h
countxy_odd:
	add a,l
	ld l,a
	ret

step_xy:
	ld a,h
	xor 020h
	ld h,a
	and 020h
	ret nz
	inc l
	ret

cp866_atm:
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
