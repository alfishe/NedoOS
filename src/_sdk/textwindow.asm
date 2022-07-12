prwindow_edit
;hl=window DE=texteditaddr c=texteditsize
;out: CY=OK, de=filename
	push de
	push bc
        call prwindow_text ;de=YX of last line
	pop bc
	pop hl
        push hl
        ld a,c ;a=maxsz
        call editline
        pop de ;de=filename
        cp key_esc
        ret z ;cancel
        scf
        ret

prwindow_waitkey
;hl=window
;out: CY=OK
;        ld (prwindow_waitkey_addr),hl; commented by demige 190511
        call prwindow_text; insert by demige 190511
; comment by demige 190511: for why reprinting window after each keypress? On second print getmarkedfiles returns wrong value.
prwindow_waitkey0
;prwindow_waitkey_addr=$+1 ; comment by demige 190511
;        ld hl,0 ; comment by demige 190511
;        call prwindow_text ; comment by demige 190511
       if PRSTDIO
        call yieldgetkeyloop
       else
        YIELDGETKEYLOOP
       endif
        ld a,c
        cp key_esc
        ret z
        cp 'n'
        ret z
        ;cp 'N'
        ;ret z
        cp key_redraw
        ret z
        cp 'y'
        jr z, prwindow_waitkey_keyyes
        ;cp 'Y'
        ;jr z, prwindow_waitkey_keyyes
        cp key_enter
        jr nz,prwindow_waitkey0
prwindow_waitkey_keyyes
        scf
        ret

upwindow_text
	ld a,0
	jr prwindow_text0

prwindow_text
	ld a,1
prwindow_text0
;hl = window text
;out: ;de=YX of last line
        ld e,(hl) ;x
        inc hl
        ld d,(hl) ;y
        inc hl
        ld c,(hl) ;wid
        inc hl
        ld b,(hl) ;hgt
        inc hl

        push hl ;text

        push de
	or a
        call nz,prwin
        pop de
	inc d
        inc e
        inc e
        call nv_setxy ;keeps de,hl,ix
        
        pop hl ;text
prwindow_waitkey_text0
        ld a,(hl)
        or a
        ret z
        dec a;cp 1
        jr z,prwindow_waitkey_textnfiles
        dec a;cp 2
        jr z,prwindow_waitkey_textoutertext
        dec a;cp 3
        jr z,prwindow_waitkey_textnextline
        push de
         ld c,0
        call prtext
        pop de
        jr prwindow_waitkey_text0
prwindow_waitkey_textnfiles
        inc hl
        push de
        push hl
	call getmarkedfiles;countmarkedfiles
        call prdword
        pop hl
        pop de
        jr prwindow_waitkey_text0
prwindow_waitkey_textoutertext
        inc hl
        push de
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ex de,hl
         ld c,0
        call prtext
        pop hl
        pop de
        jr prwindow_waitkey_text0
prwindow_waitkey_textnextline
        inc hl
        inc d
        call nv_setxy ;keeps de,hl,ix
        jr prwindow_waitkey_text0

prwin
;de=yx
;bc=hgt,wid
        call setdrawtablesneeded
        ld a,c
        sub 2
        ld (winbeginstroka_wid),a
        ld (winmidstroka_wid),a
        ld (winendstroka_wid),a
	ld hl,winbeginstroka
	call prtableline
	dec b
        dec b
winlineN_0
	inc d 
	ld hl,winmidstroka
	call prtableline
	djnz winlineN_0
	inc d
	ld hl,winendstroka
	;jr prtableline

prtableline
;hl=tableline data
;de=yx
;b=hgt
;keeps bc,de,ix
        push bc
        call nv_setxy ;keeps de,hl
prtableline0
	ld a,(hl)
	or a
	jr z,prtablelineq
	inc hl
	ld b,(hl)
	inc hl
	call prNsymbol
	jr prtableline0
prtablelineq
        pop bc
        ret

prNsymbol
;a=symbol
;b=count
	push de
	push hl 
	push ix
        ld c,a
prNsymbol0
	push bc
        ld a,c
       if PRSTDIO
        PRCHAR_
       else
        PRCHAR
       endif
	pop bc
	djnz prNsymbol0
        pop ix
	pop hl
	pop de 
	ret

winbeginstroka
	db 0xc9;'г'
	db 1
	db 0xcd;'='
winbeginstroka_wid=$
	db 12;wdtcolumn1 
	db 0xbb;'┐'
	db 1
	db 0

winmidstroka
	db 0xba;'│'
	db 1
	db ' '
winmidstroka_wid=$
	db 12;wdtcolumn1 
	db 0xba;'│'
	db 1
	db 0

winendstroka
	db 0xc8;'L'
	db 1
	db 0xcd;'='
winendstroka_wid=$
	db 12;wdtcolumn1 
	db 0xbc;'-'
	db 1
	db 0
