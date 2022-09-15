;startup
FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
	include "../../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100
_STRLEN=80
_STRMAX=(_STRLEN-1)
	org PROGSTART
        ld hl,0xe800 ;FCB1
        ld de,0xe801
        ld bc,0x17ff
        ld [hl],0
        ldir

	ld hl,COMMANDLINE
skipword0
        ld a,(hl)
        inc hl
        or a
        jr z,cmdquit ;если параметров вообще нет
        cp ' '
        jr nz,skipword0
skipwordq
        
	ld de,fn_os.
	call copyfn.
	;ld de,fn.
	;ld (main.fn),de
	;call copyfn.

        ld de,fn_os.
        ld c,CMD_OPENHANDLE
        call 0x0005
        ld a,b
        ld (curhandle),a

        call movedisk
curhandle=$+1
        ld b,0
        ld c,CMD_CLOSEHANDLE
        call 0x0005
cmdquit
        ld hl,0 ;result (TODO)
        rst 0x00 ;QUIT

copyfn.
l0.
	ld a,(hl)
	inc hl
	ld (de),a
	inc de
	cp ' '+1
	jr nc,l0. ;read until space or CR
	xor a
	dec de
	ld (de),a ;'\0'
	ret

;from io.c:
findlastslash
findlastslash.A.=$+1
	ld hl,0
;hl = poi to filename in string
findlastslashok.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
findlastslash0.
	ld a,[hl]
	inc hl
	or a
	jr z,findlastslashq.
	cp '/'
	jr nz,findlastslash0.
	jr findlastslashok.
findlastslashq.
	ex de,hl
;hl = after last slash
	ret 

positioning_in_fn_os
;hl=trsec
        ld a,l
        add a,a
        add a,a
        add a,a
        add a,a
        ld l,a ;hl = trdsec*16
        xor a
        ld d,a;0
        add hl,hl
        rla
        add hl,hl
        rla
        add hl,hl
        rla
        add hl,hl
        rla
        ld e,a ;dehl = trdsec*256
;dehl=offset
        ld a,(curhandle)
        ld b,a
        ld c,CMD_SEEKHANDLE
        call 0x0005        
        ret

;FUNC UINT readsectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
readsectors
readsectors.B.=$+1 ;trsec
	ld hl,0
        call positioning_in_fn_os
readsectors.A.=$+1 ;buf
	ld de,0
readsectors.C.=$+2 ;count
	ld hl,0x0100
        ld a,(curhandle)
        ld b,a
        ld c,CMD_READHANDLE
        call 0x0005        
        ret

;FUNC UINT writesectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
writesectors
writesectors.B.=$+1 ;trsec
	ld de,0
        call positioning_in_fn_os
writesectors.A.=$+1 ;buf
	ld de,0
writesectors.C.=$+2 ;count
	ld hl,0x0100
        ld a,(curhandle)
        ld b,a
        ld c,CMD_WRITEHANDLE
        call 0x0005        
        ret

	include "movedisk.ast"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/io_os.i"

fn_os.
	db "test.trd"
	db 0
        ds 255 ;for long filenames
;fn.
;	db "bin.f"
;	db 0
;       ds 255 ;for long filenames

	include "movedisk.var"
