prwindow_edit
;hl=window
;out: CY=OK, de=filename
        call prwindow_text ;de=YX of last line
        ld hl,tnewfilename ;hl=textaddr
        ld a,tnewfilename_sz ;a=maxsz
        push hl
        call editline
        pop de ;de=filename
        cp csSpace
        ret z ;cancel
        scf
        ret

prwindow_waitkey
;hl=window
;out: CY=OK
        ld (prwindow_waitkey_addr),hl
prwindow_waitkey0
prwindow_waitkey_addr=$+1
        ld hl,0
        call prwindow_text
        YIELDGETKEYLOOP
        cp csSpace
        ret z
        cp key_redraw
        ret z
        cp Enter
        jr nz,prwindow_waitkey0
	scf
        ret

prwindow_text
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
        call prwin
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
        ;jr $
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
;out: hl'hl=files (без ".", "..")
        ld hl,0
        exx
        ld l,(ix+PANEL.filesdirs)
        ld h,(ix+PANEL.filesdirs+1)
        ret

countfiles
        ld hl,proc_count
        jp processfiles ;hl'hl=files (без ".", "..")
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
	;ld a,(ix+PANEL.pg)
	;SETPG32KHIGH
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
	ex de,hl
        call isthisdotdir_hl
processfiles_proc=$+1
	call nz,0 ;copy может переключать страницы (сейчас не переключает)
	pop hl
	pop bc
	dec bc
	jp processfiles0
processfilesq
        push iy
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
        ;TODO setpgpointers
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
         ;push bc
	ld a,(ix+PANEL.pg) ;TODO from de
	SETPG32KHIGH
         ;pop bc
        ret

putfilepointer_de_tohl
;out: hl=next pointer
         ;push bc
	ld a,(ix+PANEL.pg) ;TODO from de
	SETPG32KHIGH
         ;pop bc
	ld (hl),e	
	inc hl
	ld (hl),d
	inc hl
        ret

swapfilepointers_hl_de
;out: hl=next pointer
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
        ld e,COLOR
        call nv_setcolor
        call getmarkedfiles
        ld a,h
        or l
        push af ;z = no marked
        call z,getfiles
        push ix
        call prdword
        ld hl,wordfiles
        call prtext
        pop ix
        pop af ;z = no marked
        jr nz,drawpanelfilesandsize_markedsize
        call getfilessize
        jr drawpanelfilesandsize_markedsizeq
drawpanelfilesandsize_markedsize
        call getmarkedfilessize
drawpanelfilesandsize_markedsizeq
        push ix
        call prdword
        ld hl,wordbytes
        call prtext
        pop ix
        ret

nv_setxy
;de=yx (kept)
;keeps hl
        push de
        push hl
        push ix
        OS_SETXY
        pop ix
        pop hl
        pop de
        ret
        
setpanelcolor
	ld e,PANELCOLOR
nv_setcolor
;e=color
        push ix
        OS_SETCOLOR
        pop ix
        ret
        
getfcbaddrundercursor
        call nv_getdirpos_hl
getfcbaddrunderhl
	ld ix,(curpanel)
	;ld a,(ix+PANEL.pg)
	;SETPG32KHIGH
        ex de,hl
        ;ld l,(ix+PANEL.pointers)
        ;ld h,(ix+PANEL.pointers+1)
	;add hl,de
	;add hl,de
        call gotofilepointer_numberde
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
        PRCHAR
        pop hl
        pop bc
        inc c
        inc hl
        ld a,c
        cp 37
        jp nz,panelprtext0
panelprtextq
        pop ix
        ret

prtext
;out: hl=after terminator
prtext0
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR ;testing (351/352t) (was 986/987t)
        pop hl
        jp prtext0

cmdprNchars
;hl=word
;b=size word
        push bc
        ld a,(hl)
        inc hl
        push hl
        PRCHAR
        pop hl
        pop bc
        djnz cmdprNchars
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
      
readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,+(#c000+PROGSTART)/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,e
        SETPG32KHIGH
        ld a,#c000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,h
        SETPG32KHIGH
        ld a,#c000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,l
        SETPG32KHIGH
        ld a,#c000/256
        jp cmd_loadpage

cmd_savepage
;hl=size
;out: a=error
        push hl
        ld de,#8000
        OS_SETDTA
        pop hl
        ld de,fcb2
        OS_FWRITE_NBYTES
        ret
        
prwin
;de=yx
;bc=hgt,wid
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
	ld b,CONST_HGT_TABLE	
prtable0	
	inc d 
	ld hl,prmidstroka
	call prtableline
	djnz prtable0
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
	PRCHAR
	pop bc
	djnz prNsymbol0
        pop ix
	pop hl
	pop de 
	ret

;;;;;;;;;;;;;;;;;;
prNNcmd
;a=NN
        ld c,10
        call prNcmd
        add a,'0'
        PRCHAR
        ret
prNcmd
;a=NN
;c=divisor
        ld b,'0'-1
        sub c
        inc b
        jr nc,$-2
        add a,c
        push af
        ld a,b
        PRCHAR
        pop af
        ret
        
cmdprchar
        push hl
	push ix
        PRCHAR
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
	push af
	ld ix,(curpanel)
	call count_filecursor_y
	ld d,a
	;ld e,(ix+PANEL.xy)
	inc d
	inc e
	pop af
	push af
	call nv_setxy
	pop af ;color
	ret

prfilecursor
;a=color
	call setfilecursorxy
	call drawfilecursor ;a=old color
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
	
minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

drawfilecursor
;de=yx
;a=color
;out: a=oldcolor
	ld b,12
drawfilecursor_sizeb
	ld (drawfilecursor_color),a
	push bc
	push de
	call nv_setxy
	OS_GETATTR
	pop de
        pop bc
	push af ;oldcolor
drawfilecursor0
	push bc
	push de
	call nv_setxy
drawfilecursor_color=$+1
	ld e,FILECURSORCOLOR
	OS_PRATTR
	pop de
	pop bc
	inc e
	djnz drawfilecursor0
	pop af ;oldcolor
	ret

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
        ld de,fcb2
        jr nv_closefcb_de
nv_closefcb
        ld de,fcb
nv_closefcb_de
;out: nz=error
        push ix
        OS_FCLOSE
        pop ix
        or a
        ret

copy_to_fcb_filename
        ld de,fcb_filename
copy_to_defcb_filename
        ld bc,11
        ldir
        ret

winbeginstroka
	db 'Й'
	db 1
	db 'Н'
winbeginstroka_wid=$
	db 12;wdtcolumn1 
	db '»'
	db 1
	db 0
	
winmidstroka
	db 'є'
	db 1
	db ' '
winmidstroka_wid=$
	db 12;wdtcolumn1 
	db 'є'
	db 1	
	db 0

winendstroka
	db 'И'
	db 1
	db 'Н'
winendstroka_wid=$
	db 12;wdtcolumn1 
	db 'ј'
	db 1	
	db 0

prbeginstroka
	db 'Й'
	db 1
	db 'Н'
	db 12;wdtcolumn1 
	db 'С'
	db 1
	db 'Н'
	db 10;wdtcolumn2
	db 'С'
	db 1
	db 'Н'
	db 14;wdtcolumn3 
	db '»'
	db 1
	db 0

prmidstroka
	db 'є'
	db 1
	db ' '
	db 12;wdtcolumn1 
	db 'і'
	db 1
	db ' '
	db 10;wdtcolumn2
	db 'і'
	db 1
	db ' '
	db 14;wdtcolumn3 
	db 'є'
	db 1	
	db 0

prendstroka
	db 'И'
	db 1
	db 'Н'
	db 12;wdtcolumn1 
	db 'П'
	db 1
	db 'Н'
	db 10;wdtcolumn2
	db 'П'
	db 1
	db 'Н'
	db 14;wdtcolumn3 
	db 'ј'
	db 1	
	db 0
