; Fast NeoGS data pump for IAR Z80 / NedoOS.
; Matches NeoTracker Save_Block / save_NGS WD loop.
;
; C ABI (iccz80 -ml):
;   ptr -> DE, 2nd uint -> BC
;   unsigned char return -> A
; Preserve IY. No EXX / EX AF,AF'.

	MODULE gs_io
	PUBLIC gs_send_bytes
	PUBLIC gs_recv_bytes

GSCOM	EQU	187
GSDAT	EQU	179

	RSEG CODE

; unsigned char gs_send_bytes(const unsigned char *src, unsigned int len);
; DE=src, BC=len. A=1 ok, A=0 timeout.
gs_send_bytes:
	push iy
	ld a,b
	or c
	jr z,send_ok
send_loop:
	ld a,(de)
	out (GSDAT),a
	inc de
	push bc
	ld bc,0		; ~65k spins max per byte
send_wd:
	in a,(GSCOM)
	rlca
	jr nc,send_wd_ok
	dec bc
	ld a,b
	or c
	jr nz,send_wd
	pop bc
	xor a		; timeout
	pop iy
	ret
send_wd_ok:
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,send_loop
send_ok:
	ld a,1
	pop iy
	ret

; unsigned char gs_recv_bytes(unsigned char *dst, unsigned int len);
; DE=dst, BC=len. A=1 ok, A=0 timeout.
gs_recv_bytes:
	push iy
	ld a,b
	or c
	jr z,recv_ok
recv_loop:
	push bc
	ld bc,0
recv_wn:
	in a,(GSCOM)
	rlca
	jr c,recv_wn_ok
	dec bc
	ld a,b
	or c
	jr nz,recv_wn
	pop bc
	xor a
	pop iy
	ret
recv_wn_ok:
	pop bc
	in a,(GSDAT)
	ld (de),a
	inc de
	dec bc
	ld a,b
	or c
	jr nz,recv_loop
recv_ok:
	ld a,1
	pop iy
	ret

	ENDMOD
	END
