;PROC setim(UINT vectoraddr); //divisible by 0x100 //reserves 0x200 bytes
pause
	export pause
	ld a,1
	ld (_PAUSED),a
	ret
unpause
	export unpause
	ld a,0
	ld (_PAUSED),a
	ret	
setim
setim.A.=$+1
        ld hl,0
        ld a,h
        ld d,h
        ld e,l
        inc e
        ld (hl),h
        inc (hl)
        ld bc,0x100
        ldir
        ld l,h
        ld (hl),0xc3
        inc l
        ld (hl),on_int.&0xff
        inc l
        ld (hl),on_int.>>8
        ld i,a
        im 2
        ret

setimffff
        ld a,0x18 ;jr
        ld (0xffff),a
        ld a,0xc3 ;jp
        ld (0xfff4),a
        ld hl,on_int.
        ld (0xfff5),hl
        ld a,59
        ld i,a
        im 2
        ret

im1
	export im1
        ld iy,23610
        im 1
        ld a,0x3f
        ld i,a
        ret
        
;keeps de in (sp)
;uses _IMSTACK
;restores 7ffd
on_int.
        ex de,hl
        ex (sp),hl ;keeps de in (sp)
        ld (imjp.),hl
	ld (imstack.),sp
	ld sp,_IMSTACK
        push af
        push bc
        ;push de
        push de;hl
        push ix
        push iy
        ex af,af'
        push af
        call _USERINT1
        ld bc,0x7ffd
        ld a,(_CURSCR)
_SONGPG=$+1
        or 0x10
        out (c),a
_PAUSED=$+1
        ld a,0
        or a
        call z,PLAY
        call afxFRAME
        call _USERINT2
_TIMER=$+1
	ld hl,0
	inc hl
	ld (_TIMER),hl
        ld bc,0x7ffd
_CURPG=$+1
        ld a,0x10
        out (c),a
        pop af
        ex af,af'
        pop iy
        pop ix
        pop hl
        ;pop de
        pop bc
        pop af
imstack.=$+1
        ld sp,0
        pop de
        ei
imjp.=$+1
        jp 0

;PROC set7ffd(BYTE pg); //out (0x7ffd), pg|_CURSCR
set7ffd
        ld bc,0x7ffd
set7ffd.A.=$+1
        ld a,0x10
_CURSCR=$+1
        or 0
        ld (_CURPG),a
        out (c),a
        ret

;PROC setborder(BYTE n); //out (0xfe), n
setborder
setborder.A.=$+1
        ld a,0
        ld (_CURBORDER),a
        out (0xfe),a
        ret

halter
        halt
        ret
