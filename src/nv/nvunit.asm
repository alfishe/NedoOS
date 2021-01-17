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
        call nv_setxy ;keeps de,hl
        
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
        call nv_setxy ;keeps de,hl
        jr prwindow_waitkey_text0

getmarkedfiles
;ix = panel
;out: hl'hl = files
        ld hl,0
        exx
        ld l,(ix+PANEL.markedfiles)
        ld h,(ix+PANEL.markedfiles+1)
        ret

changemark_hl
        push hl
	ld a,(hl)
	xor 1
	ld (hl),a
        ld bc,FCB_FSIZE
        add hl,bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
;bcde = file size
        ld l,(ix+PANEL.markedfiles)
        ld h,(ix+PANEL.markedfiles+1)
        inc hl
        jr nz,changemark_hlq ;set mark
;remove mark
        dec hl
        dec hl
        xor a
        sub e
        ld e,a
        ld a,0
        sbc a,d
        ld d,a
        ld a,0
        sbc a,c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;bcde= -bcde
changemark_hlq
        ld a,(ix+PANEL.markedsize)
        add a,e
        ld (ix+PANEL.markedsize),a
        ld a,(ix+PANEL.markedsize+1)
        adc a,d
        ld (ix+PANEL.markedsize+1),a
        ld a,(ix+PANEL.markedsize+2)
        adc a,c
        ld (ix+PANEL.markedsize+2),a
        ld a,(ix+PANEL.markedsize+3)
        adc a,b
        ld (ix+PANEL.markedsize+3),a
        ld (ix+PANEL.markedfiles),l
        ld (ix+PANEL.markedfiles+1),h
        pop hl
        ret

getmarkedfilessize
;ix = panel
;out: hl'hl = files
        ld l,(ix+PANEL.markedsize+2)
        ld h,(ix+PANEL.markedsize+3)
        exx
        ld l,(ix+PANEL.markedsize)
        ld h,(ix+PANEL.markedsize+1)
        ret
        
getfiles
;ix = panel
;out: hl'hl=files (without ".", "..")
        ld hl,0
        exx
        ld l,(ix+PANEL.filesdirs)
        ld h,(ix+PANEL.filesdirs+1)
        ret

countfiles
        ld hl,proc_count
        jp processfiles ;hl'hl=files (without ".", "..")
proc_count
	inc iy
	ret

getfilessize
;ix = panel
        ;exx
        ld l,(ix+PANEL.totalsize+2)
        ld h,(ix+PANEL.totalsize+3)
        exx
        ld l,(ix+PANEL.totalsize)
        ld h,(ix+PANEL.totalsize+1)
        ret ;hl'hl=size

processfiles
;ix = panel address (kept)
;hl = procedure address (uses hl=fcb, hl'iy = accumulator)
;out: hl'hl = result
	ld (processfiles_proc),hl

        call nv_getpanelfiles_bc

	ld l,(ix+PANEL.pointers)
	ld h,(ix+PANEL.pointers+1)
        exx
        ld hl,0
        exx
	ld iy,0
processfiles0
	ld a,b
	or c
	jr z,processfilesq
	push bc
        call getfilepointer_de_fromhl
	push hl
	push ix
	ex de,hl
        call isthisdotdir_hl
        display "processfiles_proc ",$
processfiles_proc=$+1
	call nz,0 ;copy может переключать страницу (сейчас не переключает)
	pop ix
	pop hl
	pop bc
	dec bc
	jp processfiles0
processfilesq
        push iy
       push ix
	call nv_batch ;исполнить всё, что запомнили в nv_batch_pushrecord?
       pop ix
	pop hl
        ret

gotofilepointer_numberde
        ld l,(ix+PANEL.pointers)
        ld h,(ix+PANEL.pointers+1)
	add hl,de
	add hl,de
        ret

getfilepointer_de_fromhl
;out: hl=next pointer
	ld a,(ix+PANEL.poipg)
	SETPG32KHIGH
	ld a,(hl)
	and 0xe0
	ld e,a
        xor (hl)
	inc hl
	ld d,(hl)
	inc hl
	;ld a,e
	;and 31
	add a,(ix+PANEL.pgadd)
	PGW3strpg
	;push af
	;ld a,e
	;and 0xe0
	;ld e,a
	;pop af
        ret

putfilepointer_de_tohl
;out: hl=next pointer
	ld a,(ix+PANEL.poipg)
	SETPG32KHIGH
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
        ret

swapfilepointers_hl_de
;out: hl=next pointer
	ld a,(ix+PANEL.poipg)
	SETPG32KHIGH
	ld a,(de)
	ldi
	dec hl
	ld (hl),a
	inc hl
	ld a,(de)
	ldi
	dec hl
	ld (hl),a
	inc hl
        ret

isthisdotdir_hl
;out: z="." or ".."
        inc hl
        ld a,(hl)
        cp '.'
        dec hl
        ret

drawpanelfilesandsize
;ix=panel
        call nv_getpanelxy_de
        ld a,d
        add a,22
        ld d,a
        inc e
        inc e
        call nv_setxy
        ld de,_PANELDIRCOLOR;_PANELFILECOLOR
        call nv_setcolor
        call getmarkedfiles
        ld a,h
        or l
        push af ;z = no marked
        call z,getfiles
	pop af
	push af
	ld de,_PANELSELECTCOLOR
	call nz,nv_setcolor
        ;push ix
        ld de,wordfiles
        call prdword_de_withspaces
        ;ld hl,wordfiles
        ; ld c,0
        ;call prtext
        ;pop ix
        pop af ;z = no marked
        jr nz,drawpanelfilesandsize_markedsize
        call getfilessize
        jr drawpanelfilesandsize_markedsizeq
drawpanelfilesandsize_markedsize
        call getmarkedfilessize
drawpanelfilesandsize_markedsizeq
        ld de,wordbytes
        call prdword_de_withspaces
        push ix
        ld hl,wordfiles;bytes
         ld c,0
        call prtext
        pop ix
        ret

nv_setxy
;de=yx (kept)
;keeps hl
        push de
        push hl
        push ix
       if PRSTDIO
        SETXY_
       else
        OS_SETXY
       endif
        pop ix
        pop hl
        pop de
        ret

setpanelcolor
	ld de,_PANELCOLOR
nv_setcolor
;d=paper, e=ink
        push hl
        push ix
       if PRSTDIO
        SETCOLOR_
       else
        ;ld a,d
        ;add a,a
        ;add a,a
        ;add a,a
        ;add a,e
        ;ld e,a
        OS_SETCOLOR
       endif
        pop ix
        pop hl
        ret

getfcbaddrundercursor
        call nv_getdirpos_hl
getfcbaddrunderhl
	ld ix,(curpanel)
	;ld a,(ix+PANEL.pg)
	;SETPG32KHIGH
        ex de,hl
        call gotofilepointer_numberde ;hl=file pointer
	;ld a,(hl)
	;inc hl
	;ld h,(hl)
	;ld l,a ;hl=FCB
        call getfilepointer_de_fromhl
        ex de,hl ;hl=FCB
	ret

getfcbundercursor
	call getfcbaddrundercursor
getfcbfromhl
        ld de,fcb
        ld bc,FCB_sz
        ldir
        ret

panelprtext
;print max 37 chars (dir)
;hl = text
;keeps ix
        push ix
panelprtext0
        ld a,(hl)
        or a
        jr z,panelprtextq
        push bc
        push hl
       if PRSTDIO
        PRCHAR_
       else
        PRCHAR
       endif
        pop hl
        pop bc
        inc c
        inc hl
        ld a,c
        cp PANELDIRCHARS37
        jp nz,panelprtext0
panelprtextq
        pop ix
        ret

changedir_fromfcb
	call setcurpaneldir
	ld hl,fcb_filename
	ld de,filenametext
	push de
	call cpmname_to_dotname
	pop de
        OS_CHDIR
        ret

        if 1==0
readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,+(0xc000+PROGSTART)/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,e
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,h
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,l
        SETPG32KHIGH
        ld a,0xc000/256
        jp cmd_loadpage
        endif

readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,0xc100/256
        call cmd_loadpage
        ret nz
        ld a,e
        call cmd_loadfullpage
        ret nz
        ld a,h
        call cmd_loadfullpage
        ret nz
        ld a,l
cmd_loadfullpage
        SETPG32KHIGH
        ld a,0xc000/256
cmd_loadpage
;out: a=error, bc=bytes read
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
        call readcurhandle
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        ret

readcurhandle
curhandle=$+1
        ld b,0
        OS_READHANDLE
        ret

cmd_savepage
;hl=size
;out: a=error
        ;push hl
        ld de,0x8000
        ;OS_SETDTA
        ;pop hl
        ;ld de,fcb2
        ;OS_FWRITE_NBYTES
        ld a,(curhandle)
        ld b,a
        OS_WRITEHANDLE
        ret

setdrawtablesneeded
        ld ix,leftpanel
        res 0,(ix+PANEL.drawtableunneeded)
        ld ix,rightpanel
        res 0,(ix+PANEL.drawtableunneeded)
        ret

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
	jr prtableline

prtable
;de=yx
	ld hl,prbeginstroka
	call prtableline
        push ix
	ld b,CONST_HGT_TABLE
prtable0
	inc d 
	;ld hl,prmidstroka
	;call prtableline
        push bc
        push de
        call nv_setxy ;keeps de,hl
        ld de,tmidstroka
        ld hl,tmidstroka_sz
        call sendchars
        pop de
        pop bc
	djnz prtable0
        pop ix
	inc d
	ld hl,prendstroka
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

;;;;;;;;;;;;;;;;;;

cmdprchar
        push hl
	push ix
       if PRSTDIO
        PRCHAR_
       else
        PRCHAR
       endif
	pop ix
        pop hl
        ret

nv_getpanelxy_de
	ld e,(ix+PANEL.xy)
	ld d,(ix+PANEL.xy+1)
        ret

nv_getdirscroll_bc
	ld c,(ix+PANEL.dirscroll)
	ld b,(ix+PANEL.dirscroll+1)
        ret
nv_setdirscroll_bc
	ld (ix+PANEL.dirscroll),c
	ld (ix+PANEL.dirscroll+1),b
        ret

nv_getpanelfiles_bc
        ld c,(ix+PANEL.files)
        ld b,(ix+PANEL.files+1)
        ret
nv_getdirpos_hl
        ld l,(ix+PANEL.dirpos)
        ld h,(ix+PANEL.dirpos+1)
        ret

cpfiles_setdirpos
;hl=suggested dirpos (might be >= files)
;out: hl=dirpos
        call nv_getpanelfiles_bc
        dec bc
        call minhl_bc_tobc
        ld h,b
        ld l,c
nv_setdirpos_hl
        ld (ix+PANEL.dirpos),l
        ld (ix+PANEL.dirpos+1),h
        ret
nv_setdirpos_zero
        ld hl,0
        jr nv_setdirpos_hl

count_filecursor_y
;out: a=y, de=PANEL.xy
        call nv_getpanelxy_de
	ld a,(ix+PANEL.dirpos)
	sub (ix+PANEL.dirscroll)
	add a,d;(ix+PANEL.xy+1) ;y
	ret

setfilecursorxy
	;push af
	ld ix,(curpanel)
	call count_filecursor_y
	ld d,a
	;ld e,(ix+PANEL.xy)
	inc d
	inc e
	;pop af
	;push af
	call nv_setxy
	;pop af ;color
	ret

prfilecursor_reprintfile
;hl=color
        push hl
        ;ex de,hl
        ;SETCOLOR_
	call setfilecursorxy
        ld ix,(curpanel)
        ;call getfcbaddrundercursor
        ;jp prdirfile
        call getfcbundercursor
        ld ix,fcb
        pop de
        jp prdirfile_ix_decolor
        ;push hl
        ;pop ix
        ;call prdirfile_copyfilename
	;;ld ix,(curpanel)
        ;ld de,filelinebuf
        ;ld hl,8+1+3
        ;jp sendchars

prfilecursor
;hl=color
        push hl
	call setfilecursorxy
        pop hl
	ld b,12
	call drawfilecursor_sizeb_colorhl ;hl=old color
	ld ix,(curpanel)
	ret

editcmd_readprompt_setendcmdx
        ld ix,(curpanel)
        call setpaneldir_makeprompt ;->prompt
        ld hl,cmdbuf
        call strlen
        ld a,l
        ld (curcmdx),a
        ret

getanotherpanel_ix
curpanel=$+1
	ld bc,leftpanel
        ld hl,0xffff&(leftpanel+rightpanel)
        or a
        sbc hl,bc
        push hl
        pop ix
        ret

setanotherpaneldir
        call getanotherpanel_ix
        jr setpaneldir

setcurpaneldir
        ld ix,(curpanel)
setpaneldir
;ix=panel
	push ix
	pop hl
	ld de,PANEL.dir
	add hl,de
        ex de,hl ;de=path
	OS_CHDIR
	ret

drawfilecursor_sizeb_colorhl
;de=yx
;hl=color
;b=size
       if PRSTDIO
	push bc
        push hl
	call nv_setxy
        pop de
        SETCOLOR_
        call setcolor_invisible 
        pop bc
        ld de,tspaces
        ld h,0
        ld l,b
        call sendchars
        jp setcolor_visible 
       else
        ;ld a,d
        ;add a,a
        ;add a,a
        ;add a,a
        ;add a,e
        ;ld e,a
        ;OS_SETCOLOR
drawfilecursor_sizeb0
        push bc
        push de
        push hl ;color
        OS_SETXY
        pop de ;color
        push de ;color
        OS_PRATTR
        pop hl ;color
        pop de
        pop bc
        inc e ;x
        djnz drawfilecursor_sizeb0
        ret
       endif

        if 1==0
nv_openfcb
;if success, autopush nv_closefcb
;out: nz=error
        push ix
        ld de,fcb
        OS_FOPEN
        pop ix
        or a
        ret nz ;error
        ld hl,nv_closefcb
        ex (sp),hl
        jp (hl)

nv_createfcb2
;if success, autopush nv_closefcb2
;out: nz=error
        ld de,fcb2
        push ix
        OS_FCREATE
        pop ix
        or a
        ret nz ;error
        ld hl,nv_closefcb2
        ex (sp),hl
        jp (hl)

nv_closefcb2
;keep de and flags!!!
        push de
        ld de,fcb2
        jr nv_closefcb_de_
nv_closefcb
;keep de and flags!!!
        push de
        ld de,fcb
nv_closefcb_de_
;out: keep flags!!!
        push af
        push ix
        OS_FCLOSE
        pop ix
        pop af
        pop de
        ;or a
        ret
        endif

copy_to_fcb_filename
        ld de,fcb_filename
copy_to_defcb_filename
        ld bc,11
        ldir
        ret

nv_closehandle
;keep de and flags!!!
        push af
        push de
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
        pop de
        pop af
        ret

tdoublehoriz
        ds PANELDIRCHARS37,0xcd

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

prbeginstroka
	db 0xc9;'г'
	db 1
	db 0xcd;'='
	db 14;wdtcolumn1 
	db 0xcd;0xd1;'T'
	db 1
	db 0xcd;'='
	db 10;wdtcolumn2
	db 0xd1;'T'
	db 1
	db 0xcd;'='
	db 12;wdtcolumn3 
	db 0xbb;'┐'
	db 1
	db 0

tmidstroka
	db 0xba;'│'
       if PRSTDIO
        db 0x1b,"[25C"
	db 0xb3;'│'
        db 0x1b,"[12C"
       else
        ds 25,' '
	db 0xb3;'│'
        ds 12,' '
       endif
	db 0xba;'│'
tmidstroka_sz=$-tmidstroka
        if 1==0
prmidstroka
	db 0xba;'│'
	db 1
	db ' '
	db 14;wdtcolumn1 
	db ' ';0xb3;'│'
	db 1
	db ' '
	db 10;wdtcolumn2
	db 0xb3;'│'
	db 1
	db ' '
	db 12;wdtcolumn3 
	db 0xba;'│'
	db 1
	db 0
        endif

prendstroka
	db 0xc8;'L'
	db 1
	db 0xcd;;'='
	db 14;wdtcolumn1 
	db 0xcd;0xcf;'│'
	db 1
	db 0xcd;'='
	db 10;wdtcolumn2
	db 0xcf;'│'
	db 1
	db 0xcd;'='
	db 12;wdtcolumn3 
	db 0xbc;'-'
	db 1
	db 0
        
prcrlf
        ld de,tcrlf
        ld hl,2
        jp sendchars
tcrlf
        db 0x0d,0x0a

        if PRSTDIO==0
nv_copyscreen0to1
	OS_GETMAINPAGES
	push hl
	;OS_GETSCREENPAGES
        ld a,(user_scr1_low) ;ok
        ld l,a
        ld a,(user_scr1_high) ;ok
        ld h,a
        ld a,(user_scr0_low) ;ok
        ld e,a
        ld a,(user_scr0_high) ;ok
        ld d,a
	push hl ;1 screen
	push de ;0 screen
	ld a,l
	SETPG32KHIGH
	pop de
	push de
	ld a,e
	SETPG32KLOW
	ld bc,0x4000
	ld hl,0x8000
	ld de,0xC000
	ldir
	pop de
	pop hl
	push de
	ld a,h
	SETPG32KHIGH
	pop de
	ld a,d
	SETPG32KLOW
	ld bc,0x4000
	ld hl,0x8000
	ld de,0xC000
	ldir
	pop hl
	push hl
	ld a,l
	SETPG32KHIGH
	pop hl
	ld a,h
	SETPG32KLOW
	ret

nv_copyscreen1to0
	OS_GETMAINPAGES
	push hl
	;OS_GETSCREENPAGES
        ld a,(user_scr1_low) ;ok
        ld l,a
        ld a,(user_scr1_high) ;ok
        ld h,a
        ld a,(user_scr0_low) ;ok
        ld e,a
        ld a,(user_scr0_high) ;ok
        ld d,a
	push hl ;1 screen
	push de ;0 screen
	ld a,l
	SETPG32KHIGH
	pop de
	push de
	ld a,e
	SETPG32KLOW
	ld bc,0x4000
	ld hl,0xc000
	ld de,0x8000
	ldir
	pop de
	pop hl
	push de
	ld a,h
	SETPG32KHIGH
	pop de
	ld a,d
	SETPG32KLOW
	ld bc,0x4000
	ld hl,0xc000
	ld de,0x8000
	ldir
	pop hl
	push hl
	ld a,l
	SETPG32KHIGH
	pop hl
	ld a,h
	SETPG32KLOW
	ret
        
;sendchar
;        PRCHAR
;        ret
        
sendchars
;de=buf, hl=size, c=x
;out: A=error, c=x
sendchars0
        push bc
        push de
        push hl
        ld a,(de)
        PRCHAR
        pop hl
        pop de
        pop bc
        inc de
        inc c ;x
        dec l
        jr nz,sendchars0
        xor a ;no error
        ret
        
clearrestofline_crlf
        ;call clearrestofline
        ;ld a,0x0d
        ;PRCHAR
        ;ld a,0x0a
        ;PRCHAR
        ;ret
clearrestofline
;c=x
clearrestofline0
        push bc
        ld a,' '
        PRCHAR
        pop bc
        inc c
        ld a,c
        cp 80
        jr nz,clearrestofline0
        ret
        
        endif