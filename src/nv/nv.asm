        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

HEAPSORT_LH=1 ;byte order in poiters: LSB,HSB
	
NVOLUMES=8;5
        
MAXCMDSZ=COMMANDLINE_sz-1-4 ;not counting terminator (-4 for "cmd ")
txtscrhgt=25
txtscrwid=80
CMDLINEY=23;24

COLOR=7
PANELCOLOR=0x4f;0xf
PANELSELECTCOLOR=0x17
CURSORCOLOR=0x38
FILECURSORCOLOR=0x38
COLOR_RED=0x17

PROGRESBARWINXY=0x0e16 ;0x0919 + 051f ;de=yx
PROGRESBARWINHGTWID=0x0324 ;0x051f ;bc=hgt,wid


CONST_HGT_TABLE=21

;8192fcbs*32bytes*2panels = 32 pages
DIRPAGES=16

catbuf_left=0xc000
catbuf_right=0xc000
FILES_POINTERS_left=0xc000;0x3700
FILES_POINTERS_right=0xc000;0x3b00
left_panel_xy=0x0000
right_panel_xy=0x0028
firstfiley=left_panel_xy/256 + 1

        macro PGW2elpg0
        ;LD A,(HS_elpg)
	ld a,(ix+PANEL.poipg)
        SETPG32KLOW
        endm
        
        macro PGW2elpg
                ;LD      A,H
                ;RLCA 
                ;RLCA 
                ;AND     1
        ;LD A,(HS_elpg)
        ;jr z,$+5
        ;LD A,(HS_elpg+1)
	ld a,(ix+PANEL.poipg)
        SETPG32KLOW
        endm

        macro PGW2strpg
        ld ($+4),a
        LD A,(HS_strpg)
        SETPG32KLOW
        endm

        macro PGW3elpg
                ;LD      A,H
                ;RLCA 
                ;RLCA 
                ;AND     1
        ;LD A,(HS_elpg)
        ;jr z,$+5
        ;LD A,(HS_elpg+1)
	ld a,(ix+PANEL.poipg)
        SETPG32KHIGH
        endm

        macro PGW3strpg
        ld ($+4),a
        LD A,(HS_strpg)
        SETPG32KHIGH
        endm

        org PROGSTART
cmd_begin
        ld sp,0x4000

        ld e,6 ;textmode
        OS_SETGFX
        
        GET_KEY ;съедаем key_redraw
        
        ld e,COLOR
        OS_CLS
        
        ld de,nvpal
        OS_SETPAL
        
        OS_GETSCREENPAGES
;de=pages of screen 0 (d=higher page), hl=pages of screen 1 (h=higher page)
        ld a,e
        ld (cmdpgscreen0_0),a

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000(copybuf),8000,c000
        push hl
        ld e,h
        OS_DELPAGE
        pop hl
        ld e,l
        OS_DELPAGE

	OS_NEWPAGE ; Выделяем по одной страничке для каталогов
        ld hl,HS_strpg
        ld (hl),e
	inc hl
	xor a
	ld (hl),a ;Маркер конца списка страниц

	OS_NEWPAGE
	ld hl, HS_strpg+DIRPAGES+1
        ld (hl),e
	inc hl
	xor a
	ld (hl),a ;Маркер конца списка страниц
        
	ld hl,left_panel_xy
	ld (leftpanel+PANEL.xy),hl
	OS_NEWPAGE
	ld a,e
	ld (leftpanel+PANEL.poipg),a
	ld hl,FILES_POINTERS_left
	ld (leftpanel+PANEL.pointers),hl
        ld hl,catbuf_left
	ld (leftpanel+PANEL.catbuf),hl
	xor a
	ld (leftpanel+PANEL.pgadd),a

	ld hl,right_panel_xy
	ld (rightpanel+PANEL.xy),hl
	OS_NEWPAGE
	ld a,e
	ld (rightpanel+PANEL.poipg),a
	ld hl,FILES_POINTERS_right
	ld (rightpanel+PANEL.pointers),hl
        ld hl,catbuf_right
	ld (rightpanel+PANEL.catbuf),hl
	ld a,DIRPAGES+1
	ld (leftpanel+PANEL.pgadd),a

	ld hl,compareext
	ld (leftpanel+PANEL.dirsortproc),hl
	ld (rightpanel+PANEL.dirsortproc),hl

	;ld a,0xc3
	;ld (leftpanel+PANEL.sorterjp),a
	;ld (rightpanel+PANEL.sorterjp),a
	;ld hl,sorter1
	;ld (leftpanel+PANEL.sorter),hl
	;ld hl,sorter2
	;ld (rightpanel+PANEL.sorter),hl
	
        ld hl,rightpanel
        call editcmd_setpaneldirfromcurdir_panelhl
        ld hl,leftpanel
        call editcmd_setpaneldirfromcurdir_panelhl

        ;ld e,0
        ;OS_SETDRV
;l=NVOLUMES
        
	call readpanels_reprint
	
mainloop
        call editcmd_readprompt_setendcmdx
        call controlloop
        jp mainloop

strdelpages ;удаляем str страницы. IX - панель. Первую страничку не удаляем
	ld hl, HS_strpg
	ld de, (ix+PANEL.pgadd)
	adc hl, de
strdelpages_next
        inc hl
        ld a, (hl)
        or a
        ret z
        ld e, a
        push hl
	OS_DELPAGE
	pop hl
        xor a
        ld (hl), a
        jr strdelpages_next

strnewpage ;выделяем новую страничку IX - панель, E номер странички в HS_strpg
	push hl
	push de

	push de
	OS_NEWPAGE
	ld a, e
	ld hl, HS_strpg
	pop de
	adc hl, de
	ld de, (ix+PANEL.pgadd)
	adc hl, de
	ld (hl), a
	xor a
	inc hl
	ld (hl),a ; маркер конца списка

	pop de
	pop hl
	ret

nvpal
        dw 0xf3f3,0x1313,0xf1f1,0xf0f0,0xe3e3,0xe2e2,0xe1e1,0xe0e0 ;NB color 1
        dw 0xf3f3,0xd2d2,0xb1b1,0x9090,0x6363,0x4242,0x2121,0x0000
        
printhint
        ld de,24*256
        call nv_setxy
        ld hl,thint
prhint0
        ld a,(hl)
        inc hl
        or a
        ret z
        cp '{'
        jr z,prhint_color0
        cp '}'
        jr z,prhint_color1
        push hl
        PRCHAR ;testing (351/352t) (was 986/987t)
        pop hl
        jr prhint0
prhint_color0
        ld e,7
        jr prhint_color
prhint_color1
        ld e,5*8
prhint_color
        call nv_setcolor
        jr prhint0
thint
        db "{1}LeftDrv { 2}RightDrv { 3}View { 4}Edit { 5}Copy { 6}Rename { 7}MkDir { 8}Del  { 9}     { 0}Quit ",0
        
readpanels_reprint
	ld e,COLOR
	OS_CLS
        call printhint
	ld ix,leftpanel
	call readsortdrawpanel
	ld ix,rightpanel
readsortdrawpanel
	call readdir
	call sortfiles
	jp drawpanel_with_files

readpanels_reprint_keepcursor
	ld e,COLOR
	OS_CLS
        call printhint
	ld ix,leftpanel
	call readsortdrawpanel_keepcursor
	ld ix,rightpanel
readsortdrawpanel_keepcursor
	call readdir_keepcursor
	call sortfiles
	jp drawpanel_with_files

	
drawpanel_with_files
;ix=panel
	call setpanelcolor
        call nv_getpanelxy_de
	call prtable ;keeps ix
	call setpaneldir_makeprompt ;keeps ix
        ld e,7
        call nv_setcolor
        call nv_getpanelxy_de
        inc e
	inc e
        call nv_setxy
	push ix
	pop hl
	ld de,PANEL.dir
	add hl,de
        ld c,0
        call panelprtext

        call drawpanelfilesandsize
        
drawpanel_files
;ix=panel
	;ld a,(ix+PANEL.pg)
	;SETPG32KHIGH

	call setpanelcolor
	ld l,(ix+PANEL.files)
	ld h,(ix+PANEL.files+1)
        call nv_getdirscroll_bc
	push bc ;dirscroll
	or a
	sbc hl,bc ;hl=number of files in panel - scroll in panel
	ld bc,CONST_HGT_TABLE
	call minhl_bc_tobc ;bc = min(CONST_HGT_TABLE, number of files in panel - scroll in panel)
	pop de ;dirscroll
	;ld l,(ix+PANEL.pointers)
	;ld h,(ix+PANEL.pointers+1)
	;add hl,de
	;add hl,de
        call gotofilepointer_numberde

        call nv_getpanelxy_de
	inc d 
	inc e
	ld b,c ;files to show

        ld a,b
        or a
        ret z
prNfiles	
	push bc	
	push de
        call nv_setxy ;keeps de,hl
	;ld e,(hl)
	;inc hl
	;ld d,(hl)
	;inc hl
        call getfilepointer_de_fromhl
	push hl
	ex de,hl
        push ix
	call prdirfile
        pop ix
	pop hl
	pop de	
	pop bc
	inc d
	djnz prNfiles
	ret	

prdirfile
;hl=fcb
	ld a,(hl) ;mark
	and 1
	ld e,PANELCOLOR
	jr z,$+4
        ld e,PANELSELECTCOLOR
	push hl
        call nv_setcolor
	pop hl
	push hl
	inc hl
        ld b,8
        call cmdprNchars
	pop ix
	push ix
        ld a,(ix+FCB_FATTRIB)
        and FATTRIB_DIR
        xor '.'
        call cmdprchar
        ld b,3
        call cmdprNchars
	ld a,'і'
        PRCHAR
        pop ix
        ld l,(ix+FCB_FSIZE+2)
        ld h,(ix+FCB_FSIZE+3)
	exx
        ld l,(ix+FCB_FSIZE)
	ld h,(ix+FCB_FSIZE+1)
        push ix
        call prdword
        ld a,'і'
        PRCHAR
        pop ix
	ld l,(ix+FCB_FDATE)
        ld h,(ix+FCB_FDATE+1)
	push ix 
        push hl
        ld a,h
        srl a
        sub 20
        jr nc,$+4
        add a,100 ;XX century
        call prNNcmd ;year
        ld a,'-'	
        PRCHAR
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and #0f
        call prNNcmd ;month
        ld a,'-'
        PRCHAR
        pop af
        and #1f
        call prNNcmd ;day
        ld a,' '
        PRCHAR
	pop ix
        ld l,(ix+FCB_FTIME)
        ld h,(ix+FCB_FTIME+1)
        push hl
        ld a,h
        rra
        rra
        rra
        and #1f
        call prNNcmd ;hour
        ld a,':'
        PRCHAR
        pop hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and #3f
        jp prNNcmd ;minute

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readdir
;ix=panel
        call readdir_keepcursor
nv_setcursor_zero
        ld bc,0
        call nv_setdirscroll_bc
        jp nv_setdirpos_zero

readdir_keepcursor
;ix=panel
        xor a
        ld (ix+PANEL.totalsize),a
        ld (ix+PANEL.totalsize+1),a
        ld (ix+PANEL.totalsize+2),a
        ld (ix+PANEL.totalsize+3),a
        ld (ix+PANEL.markedsize),a
        ld (ix+PANEL.markedsize+1),a
        ld (ix+PANEL.markedsize+2),a
        ld (ix+PANEL.markedsize+3),a
        ld (ix+PANEL.markedfiles),a
        ld (ix+PANEL.markedfiles+1),a

	push ix
	call setpaneldir
	call strdelpages
	ld de,fcb
        OS_SETDTA ;set disk transfer address = de
        ;call makeemptymask
        ld de,fcbmask
        OS_FSEARCHFIRST
	pop ix
        or a

	ld e,(ix+PANEL.catbuf)     ;00
	ld d,(ix+PANEL.catbuf+1)   ;c0
	ld l,(ix+PANEL.pointers)   ;00  номер страницы
	ld h,(ix+PANEL.pointers+1) ;c0  номер файла
        ld bc,0 ;nfiles
        jp nz,loaddir_error
		ld a,(fcb+1)
		cp '.'
		jp z,loaddir_onedot
loaddir0
        push bc

	push de
	push hl
	ld a,e
	and 31
	add a,(ix+PANEL.pgadd)
	PGW3strpg
	ld a,e
	and 0xe0 ;отбрасываем младшую часть (<32) с номером страницы, остается только номер файла
	ld e,a
	xor a
	ld (de),a ;mark
	inc de
        ld hl,fcb+1
        ld bc,31;FCB_sz 
        ldir ; копируем fcb в catbuf
	pop hl
	pop de
        call putfilepointer_de_tohl ; возвращает в верхнее окно страницу poipg и в pointers заносит de
	ex de,hl
	ld bc,32
	add hl,bc
	ex hl,de ; увеличили на 32 catbuf
	jr nc,nonewpg ; всё ещё убираемся в страницу
	inc de ;next page de
	call strnewpage
	set 7,d 
	set 6,d ;de=c0pg
nonewpg:
        ;TODO через процедуру
	push hl
        ld l,(ix+PANEL.totalsize)
        ld h,(ix+PANEL.totalsize+1)
        ld bc,(fcb+FCB_FSIZE)
        add hl,bc
        ld (ix+PANEL.totalsize),l
        ld (ix+PANEL.totalsize+1),h
        ld l,(ix+PANEL.totalsize+2)
        ld h,(ix+PANEL.totalsize+3)
        ld bc,(fcb+FCB_FSIZE+2)
        adc hl,bc
        ld (ix+PANEL.totalsize+2),l
        ld (ix+PANEL.totalsize+3),h
	pop hl
        
        pop bc
        inc bc ;nfiles
        bit 5,b;1,b ;страничка pgtemp закончилась? max 512 файлов по 32 байта
        jr nz,loaddirq
loaddir_onedot
        push bc
        push de ;catbuf
	push hl
        push ix
        ld de,fcb
        OS_SETDTA ;set disk transfer address = de
         ld de,fcbmask ;в CP/M не нужно, но отсутствие вредит многозадачности
        OS_FSEARCHNEXT
        pop ix
	pop hl
        pop de ;catbuf
        pop bc ;nfiles
        or a
        jr z,loaddir0
loaddir_error
loaddirq
;bc=nfiles
	ld (ix+PANEL.files),c
	ld (ix+PANEL.files+1),b

	if 1==0
	ld l,(ix+PANEL.pointers)
	ld h,(ix+PANEL.pointers+1)
	ld e,(ix+PANEL.catbuf)
	ld d,(ix+PANEL.catbuf+1)
sortfiles_0
	push bc
	;ld (hl),e	
	;inc hl
	;ld (hl),d
	;inc hl
        call putfilepointer_de_tohl
	ex hl,de
	ld bc,32
	add hl,bc
	ex hl,de
	 jr nc,$+3
	 inc de ;next page
	pop bc
	dec bc	
	ld a,b
	or c
	jr nz,sortfiles_0
	endif

        call countfiles
        ld (ix+PANEL.filesdirs),l
        ld (ix+PANEL.filesdirs+1),h
        
        ex de,hl
        call nv_getdirpos_hl
        or a
        sbc hl,de ;dirpos<files?
        ret c ;OK
	jp nv_setcursor_zero

controlloop
        call fixscroll_prcmd
controlloop_noprline
        ld hl,controlloop
        push hl
        ld ix,(curpanel)
        ld a,(ix+PANEL.files)
        or (ix+PANEL.files+1)
        call z,nv_setdirpos_zero ;can't move cursor if 0 files
        call cmdcalccurxy
        call nv_setxy
        ld e,CURSORCOLOR;#38
        OS_PRATTR ;draw cursor
	ld a,FILECURSORCOLOR
	call prfilecursor
	 push af ;color under file cursor
        YIELDGETKEYLOOP
	 pop de ;d=color under file cursor
        push af
	ld a,d
	call prfilecursor ;remove file cursor
        call cmdcalccurxy
        call nv_setxy
        ld e,COLOR;7
        OS_PRATTR ;remove cursor
         ld e,COLOR
         call nv_setcolor ;even if we didn't reprint command line, draw windows with its color
        pop af
        ld hl,tnvcmds
        ld bc,nnvcmds
        cpir
        jp nz,editcmd_keyfail
;bc=nnvcmds-(#команды+1) = 0..(nnvcmds-1)
        add hl,bc
;hl=tnvcmds+nnvcmds
        add hl,bc
        add hl,bc
;hl=tnvcmds+nnvcmds+ 2*(nnvcmds-(#команды+1))
        ld c,(hl)
        inc hl
        ld h,(hl)
        ld l,c
        push hl ;jump addr
        ld hl,cmdbuf
        ld ix,(curpanel)
        ret
editcmd_keyfail
        cp 0x20
        ret c ;прочие системные кнопки не нужны
editcmd_typein
;keeps ix
        ld e,a
        ld hl,cmdbuf
        call strlen ;hl=length
        ld bc,MAXCMDSZ
        or a
        sbc hl,bc
        ret nc ;некуда вводить
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc a
        ld (curcmdx),a
        jp strinsch

editcmd_space
	ld a,(cmdbuf)
	or a
	ld a,' '
        jr nz,editcmd_typein
        call getfcbaddrundercursor;hl=addr fcb ;ix=curpanel
        call isthisdotdir_hl
        call nz,changemark_hl
	push hl
	call setfilecursorxy
	pop hl
	call prdirfile
        ld ix,(curpanel)
        call drawpanelfilesandsize
	jp editcmd_down
        
editcmd_backspace
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        jr z,editcmddirback;editcmdok ;нечего удалять
        dec a
        ld (curcmdx),a
        jp strdelch
        
editcmddirback
	call setpaneldir
	ld de,tdotdot
	OS_CHDIR
	jp editcmd_setpaneldirfromcurdir

editcmd_left
        ld a,(curcmdx)
        or a
        ret z ;некуда влево
        dec a
        ld (curcmdx),a
        ret
      
editcmd_right
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc (hl)
        dec (hl)
        ret z ;некуда право, стоим на терминаторе
        inc a
        ld (curcmdx),a
        ret
      
editcmd_pageDown
	call count_filecursor_y
	cp CONST_HGT_TABLE-1+firstfiley -1 ;???
        jr c,editcmd_pageDown_nolastvisible ;not last visible file
        call nv_getdirpos_hl
	ld bc,CONST_HGT_TABLE
        add hl,bc
editcmd_pageDown_end_q        
        call cpfiles_setdirpos ;hl=dirpos
	ld bc,CONST_HGT_TABLE-1
        xor a
        sbc hl,bc
        jr nc,$+4
        ld h,a
        ld l,a;0
        jr editcmd_pageUpq
editcmd_pageDown_nolastvisible
        call nv_getdirscroll_bc
	ld hl,CONST_HGT_TABLE-1
        add hl,bc ;last visible file
        call cpfiles_setdirpos
	jp drawpanel_files      

editcmd_pageUp
        call count_filecursor_y
        cp firstfiley
        jr nc,editcmd_pageDown_nofirstvisible ;not first visible file
        call nv_getdirpos_hl
	ld bc,CONST_HGT_TABLE-1
        xor a
        sbc hl,bc
        jr nc,$+4
        ld h,a
        ld l,a;0
        call nv_setdirpos_hl
editcmd_pageUpq
        ld b,h
        ld c,l
        call nv_setdirscroll_bc
	jp drawpanel_files      
editcmd_pageDown_nofirstvisible
        call nv_getdirscroll_bc
        ld h,b
        ld l,c
        call nv_setdirpos_hl
	jp drawpanel_files    

editcmd_End
        ld hl,-1 ;>=files
        jp editcmd_pageDown_end_q

editcmd_Home
        xor a
        ld h,a
        ld l,a;0
        call nv_setdirpos_hl
        ld b,h
        ld c,l
        call nv_setdirscroll_bc
        jp drawpanel_files    

        
editcmd_up
         ld hl,controlloop_noprline
         ex (sp),hl
        call nv_getdirpos_hl
	ld a,h
	or l
        ret z ;first file
        dec hl
        call nv_setdirpos_hl
	call count_filecursor_y
	cp firstfiley-2;or a
        ret nz ;not above first visible file
        call nv_getdirscroll_bc
	dec bc
        call nv_setdirscroll_bc
         push bc
        call nv_getpanelxy_de
        inc d
        push de
        ld hl,CONST_HGT_TABLE*256 + 40
        OS_SCROLLDOWN
        pop de
        inc e
        call nv_setxy
	 pop hl ;file number
        call getfcbaddrunderhl
	jp prdirfile

editcmd_down
         ld hl,controlloop_noprline
         ex (sp),hl
        call nv_getdirpos_hl
        call nv_getpanelfiles_bc
	inc hl
	or a
	sbc hl,bc
	add hl,bc
        ret z ;last file
        call nv_setdirpos_hl
	call count_filecursor_y
	cp CONST_HGT_TABLE-1+firstfiley
        ret c ;not last visible file
        call nv_getdirscroll_bc
	inc bc
        call nv_setdirscroll_bc
        ld hl,CONST_HGT_TABLE-1
        add hl,bc
         push hl
        call nv_getpanelxy_de
        inc d
        push de
        ld hl,CONST_HGT_TABLE*256 + 40
        OS_SCROLLUP
        pop de
        ld a,d
        add a,CONST_HGT_TABLE-1
        ld d,a
        inc e
        call nv_setxy
	 pop hl ;file number
        call getfcbaddrunderhl
	jp prdirfile

editcmd_ss1
	ld hl,comparefilename
	jr editcmd_setsortmodehl
editcmd_ss2
	ld hl,compareext
	jr editcmd_setsortmodehl
editcmd_ss3
	ld hl,comparesize
	jr editcmd_setsortmodehl
editcmd_ss4
	ld hl,comparedate
	jr editcmd_setsortmodehl
editcmd_ss5
	ld hl,compareempty
editcmd_setsortmodehl
        call ifcmdnonempty_typedigit
	ld c,(ix+PANEL.dirsortproc)
	ld b,(ix+PANEL.dirsortproc+1)
	xor a
	sbc hl,bc
	add hl,bc
	jr nz,editcmd_setsortmodehl_noold
	ld a,(ix+PANEL.dirsortmode)
	cpl
editcmd_setsortmodehl_noold
	ld (ix+PANEL.dirsortmode),a
	ld (ix+PANEL.dirsortproc),l
	ld (ix+PANEL.dirsortproc+1),h
	jp editcmd_reprintcurpanel

editcmd_tab
        call getanotherpanel_ix
	ld (curpanel),ix
        jp editcmd_readprompt_setendcmdx

editcmd_enter
	ld a,(cmdbuf)
	or a
        jr nz,editcmd_enter_runcmd
        call getfcbundercursor ;->fcb
	ld a,(fcb+FCB_FATTRIB)
	and FATTRIB_DIR;#10
	jp z,editcmd_enter_run
        call changedir_fromfcb
editcmd_setpaneldirfromcurdir
        ld hl,editcmd_reprintcurpanel
        push hl
	ld hl,(curpanel)
editcmd_setpaneldirfromcurdir_panelhl
	ld de,PANEL.dir
	add hl,de
        ex de,hl ;de=pointer to 64 byte (MAXPATH_sz!) buf
        OS_GETPATH
        ret

editcmd_enter_runcmd
;run "cmd <command to run>"
        OS_SETSYSDRV ;TODO каталог cmd
        ld hl,cmd_filename
        call copy_to_fcb_filename
        ;---
        ld de,#1800
        call nv_setxy
        ld a,#0d
        PRCHAR
        ld a,#0a
        PRCHAR
        ;---
        ld hl,cmdbuf
         ;jr $
	 ;call setcurpaneldir
        call loadandrun ;nz=error, e=id
        jp nz,execcmd_error
;команда scratch - реально cmd scratch, запускает scratch по фону и выходит
        ;YIELD ;дать время задаче cmd захватить фокус
        ;ld e,-1
        ;OS_SETGFX ;disable gfx, give focus
        WAITPID
execcmd_runfocusq
        ;YIELD ;дать время системе передать фокус рандомной задаче
        ;ld b,25
;execcmd_waitchildredraw0
        ;push bc
        ;YIELD ;дать время задаче scratch захватить фокус и перерисовать (но загрузить картинку и перерисовать не успеет)
        ;pop bc
        ;djnz execcmd_waitchildredraw0
        ;ld e,6 ;textmode
        ;OS_SETGFX ;take focus (can be random after closing cmd)
        ld hl,cmdbuf
        ld (hl),0
        jp editcmd_reprintall

editcmd_enter_run
	call setpaneldir
        ld hl,fcb_filename+8
	ld a,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
	cp '$'
	jp z,editcmd_enter_runfile_hobeta
        or #20
        cp 'c'
        jr nz,editcmd_enter_runfile_nocom
        ld a,c
        or #20
        cp 'o'
        jr nz,editcmd_enter_runfile_nocom
        ld a,b
        or #20
        cp 'm'
        jr nz,editcmd_enter_runfile_nocom
editcmd_enter_runfile_com
        ld hl,cmdbuf
        ld (hl),0
;hl=rest of command line
        jp loadandrun ;nz=error, e=id

execcmd_error
        jp execcmd_runfocusq;editcmd_reprintall
        
editcmd_enter_runfile_nocom
        ld hl,runfile_nocomq
        push hl
        call makeprompt_filename
        
        call runfile_findhandler ;find fcb_filename ext (spoiled) in "nv.ext"
        ret nz ;jp nz,execcmd_error

        ld de,cmdbuf
        ld hl,fcb_filename
        OS_PARSEFNAME ;de->hl
        
        OS_SETSYSDRV ;TODO директория cmd
        ld hl,cmdprompt
        jp loadandrun ;nz=error, e=id

makeprompt_filename
        call setpaneldir_makeprompt ;keeps ix
        call getfcbundercursor ;->fcb
        ld hl,cmdprompt
        xor a
        cpir
        dec hl ;hl=адрес терминатора
        ld a,'/'
        dec hl
        cp (hl)
        inc hl
        jr z,$+4
         ld (hl),a
         inc hl
        ex de,hl ;de=prompt = "d:/path/" без терминатора
        ld hl,fcb_filename
        call cpmname_to_dotname ;prompt = "d:/path/filename"
        ret
        
runfile_findhandler
;find fcb_filename ext (spoiled) in "nv.ext"
;out: nz=error, cmdbuf=handler
        ld hl,fcb_filename+8
        ld de,ext
        ld b,3
runfile_nocom_recodeext0
        ld a,(hl)
        or #20
        ld (de),a
        inc hl
        inc de
        djnz runfile_nocom_recodeext0
        OS_SETSYSDRV ;TODO директория nv
        ld hl,ext_filename
        call copy_to_fcb_filename
        call nv_openfcb ;autopush nv_closefcb
        ret nz ;error
        ld iy,file_buf_end
runfile_nocom_extloop
        call checkoneext ;c=ошибки, z=нет ошибок
	jr c,runfile_nocom_readerror
        jr z,runfile_nocom_extok
        call checkcomma
	jr c,runfile_nocom_readerror
        jr z,runfile_nocom_extloop
        call skiptonextline
        jr nz,runfile_nocom_extloop ;no EOF
runfile_nocom_readerror
        xor a
        dec a
        ret ;nz
runfile_nocom_extok
        call skiptocolon ;пройти после ':'
        ld hl,cmdbuf
        call loadtoendline
        xor a
        ret ;z
        
runfile_nocomq
        ld hl,cmdbuf
        ld (hl),0
        ld ix,(curpanel)
setpaneldir_makeprompt
	call setpaneldir ;keeps ix
        jp makeprompt ;-> prompt ;keeps ix

        macro READBYTE_A
;out: z=EOF
        inc ly
        call m,readbyte_readbuf
        ld a,(iy)
        endm

checkoneext
        ld hl,ext
        ld bc,3*256
checkoneext0
        READBYTE_A
        ret z ;EOF
        cp #0a
        jr z,checkoneext0 ;skip LF
        or #20
        xor (hl)
        inc hl
        or c
        ld c,a
        djnz checkoneext0
;c=ошибки, z=нет ошибок
        ret

skiptocolon
        READBYTE_A
        ret z ;EOF
        cp ':'
        jr nz,skiptocolon
        ret

checkcomma
        READBYTE_A
        cp ','
        ret ;TODO проверить EOF
        
loadtoendline
;hl=buf
        READBYTE_A
        jr z,loadtoendlineq
        cp #0d
        jr z,loadtoendlineq
        ld (hl),a
        inc hl
        jr loadtoendline
loadtoendlineq
        ld (hl),0
        ret

skiptonextline
        READBYTE_A
        ret z ;EOF
        cp #0d
        jr nz,skiptonextline
        or a
        ret ;nz

readbyte_readbuf
;out: z=EOF
        push bc
        push de
        push hl
        push ix
        ld de,file_buf
        push de
        OS_SETDTA ;set disk transfer address = de
        ld de,fcb
        OS_FREAD
        cp 128 ;128=no bytes read
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        ret
        

editcmd_enter_runfile_hobeta
hobetarunner=#4100
        ld a,(cmdpgscreen0_0)
	sub 4-1 ;ld a,#ff-4 ;pgkillable
	SETPG16K

        ld hl,washobetarunner
        ld de,hobetarunner
        ld bc,hobetarunner_sz
        ldir
cmdpgscreen0_0=$+1
	ld a,#ff-1
	SETPG32KLOW
        inc a ;ld a,#ff-0
	SETPG32KHIGH

        call loadhobeta
        ret nz ;error
        ld hl,#6000
        ld bc,(#6000-17+11) ;len
        add hl,bc
        dec hl ;hl=load end
        ex de,hl
        ld hl,(#6000-17+9) ;start
        ld (hobetarunner_jp),hl
        add hl,bc
        dec hl
        ex de,hl ;de=destination end
        lddr
	jp hobetarunner

loadhobeta        
        call nv_openfcb ;autopush nv_closefcb
        ret nz ;error
        ld de,#6000-17
        OS_SETDTA
editcmd_enter_runfile_hobeta_fcb0      
        ld de,fcb
        OS_FREAD
        or a
        jr z,editcmd_enter_runfile_hobeta_fcb0
;editcmd_enter_runfile_hobeta_fcbq
        ret ;call nv_closefcb

loadandrun
;hl=rest of command line
;out: nz=error, e=id
;load file in fcb from system current dir with parameters in tcmd, then set curpaneldir and run
        ld (loadandrun_restcmd),hl
        call nv_openfcb ;autopush nv_closefcb
        ret nz ;error
        ;set current drive and dir (will be copied into new app)
	call setcurpaneldir
        
        OS_NEWAPP
        or a
        ret nz ;error
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id
        ld a,d
        SETPG32KHIGH
        push de
        push hl
        ld hl,fcb_filename
        ld de,#c000+COMMANDLINE
        call cpmname_to_dotname ;de указывает на терминатор
loadandrun_restcmd=$+1
        ld hl,0
         ld a,(hl)
         or a
         jr z,loadandrun_noparams
        ld a,' '
        ld (de),a
        inc de
loadandrun_noparams
        ld bc,COMMANDLINE_sz;-tcmd_sz
        ldir ;copy command line ;можем залезть за #0100!
        xor a
        ld (#c000+COMMANDLINE+COMMANDLINE_sz-1),a
        pop hl
        pop de

        call readfile_pages_dehl

        pop de
        ld e,d ;e=id
;run "cmd <commandline>"
        push de
        OS_RUNAPP
        pop de
        xor a
        ret ;z

editcmd_1
        call ifcmdnonempty_typedigit
        ld hl,leftpanel
        ld a,10
        jr editcmd_drvselector
editcmd_2
        call ifcmdnonempty_typedigit
        ld hl,rightpanel
        ld a,50
editcmd_drvselector
        ld (windrv),a ;x
        ld (curpanel),hl
        ld hl,editcmd_reprintcurpanel;editcmd_reprintall_onlyreadcurdir
        push hl

seldrv_redraw_mainloop
        ld hl,windrv
;hl=window
        call prwindow_text ;de=YX of last line
seldrv_mainloop
        ld de,(windrv)
seldrv_cury=$+1
        ld a,0
        add a,d
        add a,2
        ld d,a
        inc e
        inc e
        inc e
        push de
        ld a,CURSORCOLOR;#38
        ld b,4
        call drawfilecursor_sizeb ;draw cursor
        YIELDGETKEYLOOP
        pop de
        push af
        ld a,COLOR
        ld b,4
        call drawfilecursor_sizeb ;remove cursor
        pop af
        cp key_redraw
        jr z,seldrv_redraw_mainloop
        ld hl,seldrv_cury
        cp key_enter
        jr z,seldrv_ok
        cp key_esc
        ret z
        ld bc,seldrv_mainloop
        push bc
        cp key_down
        jr z,seldrv_down
        cp key_up
        jr z,seldrv_up
        ret
seldrv_ok
        ld a,(hl);(seldrv_cury)
        add a,'A'
        ld ix,(curpanel)
        ld (ix+PANEL.dir),a
        ld (ix+PANEL.dir+1),':'
        ld (ix+PANEL.dir+2),'/'
        ld (ix+PANEL.dir+3),0
        ret
seldrv_down
        ld a,(hl)
        inc a
        cp 15; drives
        ret z
        ld (hl),a
        ret
seldrv_up
        ld a,(hl)
        or a
        ret z
        dec (hl)
        ret

editcmd_4
        call ifcmdnonempty_typedigit
        call getfcbundercursor ;->fcb
	ld a,(fcb+FCB_FATTRIB)
	and FATTRIB_DIR;#10
        ret nz

        ld hl,editcmd_reprintall_noreaddir
        push hl

        call makeprompt_filename
        
        ;call runfile_findhandler ;find fcb_filename ext (spoiled) in "nv.ext"
        ;ret nz ;jp nz,execcmd_error

        ;ld de,cmdbuf
        ;ld hl,fcb_filename
        ;OS_PARSEFNAME ;de->hl
        
        OS_SETSYSDRV ;TODO директория texted
        
        ld hl,texted_filename
        call copy_to_fcb_filename
        
        ;ld hl,cmdbuf
        ;ld (hl),0
        ld hl,cmdprompt
;load file in fcb from system current dir with parameters in tcmd, then set curpaneldir and run
        jp loadandrun ;nz=error, e=id
        
editcmd_9
        call ifcmdnonempty_typedigit
        ret

editcmd_reprintall_keepcursor
	call readpanels_reprint_keepcursor
        jp editcmd_readprompt_setendcmdx

editcmd_reprintcurdir
        ld hl,leftpanel+PANEL.dir
        ld de,rightpanel+PANEL.dir
        call strcp
        jr nz,editcmd_reprintcurpanel
editcmd_reprintall
	call readpanels_reprint
        jp editcmd_readprompt_setendcmdx
editcmd_reprintcurpanel
	ld ix,(curpanel)
	call readdir
	call sortfiles
	call drawpanel_with_files
        jp editcmd_readprompt_setendcmdx
editcmd_reprintall_noreaddir
	ld e,COLOR
	OS_CLS
        call printhint
	ld ix,leftpanel
	call drawpanel_with_files
	ld ix,rightpanel
	jp drawpanel_with_files
;editcmd_reprintall_onlyreadcurdir
;	ld e,COLOR
;	OS_CLS
;       call printhint
;       call getanotherpanel_ix
;	call drawpanel_with_files
;       jp editcmd_reprintcurpanel
        
editcmd_invfiles
;ix=curpanel
        ld hl,changemark_hl
        call processfiles
        jp drawpanel_with_files

editcmd_6 ;ren
        call ifcmdnonempty_typedigit
        ld hl,editcmd_reprintall
        push hl
	call setpaneldir
        call getfcbundercursor
        ld hl,fcb_filename
        ld de,tnewfilename
        push de
        call cpmname_to_dotname
        pop hl
        ld de,filenametext
        ld bc,12
        ldir

        ld hl,winrename
        call prwindow_edit ;CY=OK
        ret nc ;cancel
;если в имени есть символы :,/,\, то выйти с ошибкой
        ld hl,tnewfilename
editcmd_ren_checkname0
        ld a,(hl)
        or a
        jr z,editcmd_ren_checknameq
        inc hl
        cp ':'
        ret z ;error
        cp '/'
        ret z ;error
        cp 0x5c;'\\'
        ret z ;error
        jr editcmd_ren_checkname0
editcmd_ren_checknameq
        ld de,filenametext
        ld hl,tnewfilename
        OS_RENAME
        ;todo error
        ret

editcmd_7 ;mkdir
        call ifcmdnonempty_typedigit
        ld hl,editcmd_reprintall
        push hl
	call setpaneldir

        ld hl,winmkdir
        call prwindow_edit ;CY=OK, de=filename
        ret nc ;cancel
        OS_MKDIR
        ;TODO error
        ret

editcmd_8 ;del
        call ifcmdnonempty_typedigit
        ;ld ix,(curpanel)
        call getmarkedfiles;countmarkedfiles
        ld a,h
        or l
        jr nz,editcmd_8_0       
        call getfcbaddrundercursor;hl=fcb
        call isthisdotdir_hl
        ret z ;"." or ".."
        call changemark_hl ;ld (hl),1
editcmd_8_0  
        ld e,COLOR_RED
        call nv_setcolor
        ld hl,windel
        call prwindow_waitkey ;CY=OK
        jp nc,editcmd_reprintall_noreaddir
	ld hl,editcmd_reprintall
        push hl
	ld hl,proc_del_file
	ld ix,(curpanel)
	jp processfiles
        
proc_del_file
	bit 0,(hl)
	ret z
	call getfcbfromhl
	call setcurpaneldir
        ld a,(fcb+FCB_FATTRIB)
        and FATTRIB_DIR;#10 ;dir?
        jr nz,editcmd_deldir
        ld de,fcb
        OS_FDEL
        ret
editcmd_deldir
        call changedir_fromfcb
;check if dir is empty (contains only "." and "..")
	ld de,fcb2
        OS_SETDTA ;set disk transfer address = de
        ;call makeemptymask
        ld de,fcbmask
        OS_FSEARCHFIRST
        or a
        ret nz
	ld de,fcb2
        OS_SETDTA ;set disk transfer address = de
        ld de,fcbmask
        OS_FSEARCHNEXT
        or a
        ret nz
	ld de,fcb2
        OS_SETDTA ;set disk transfer address = de
        ld de,fcbmask
        OS_FSEARCHNEXT
        or a
        ret z ;at least 3 files = there is a real file
	call setcurpaneldir
        ld de,fcb
        OS_FDEL
        ret

editcmd_5 ;copy
        call ifcmdnonempty_typedigit
        ;ld ix,(curpanel)
        call getmarkedfiles;countmarkedfiles
        ld a,h
        or l
        jr nz,editcmd_5_0       
        call getfcbaddrundercursor;hl=fcb
        call isthisdotdir_hl
        ret z ;"." or ".."
        call changemark_hl ;ld (hl),1
editcmd_5_0        
        ld hl,wincopy
        call prwindow_waitkey ;CY=OK
        jp nc,editcmd_reprintall_noreaddir

        ld hl,editcmd_reprintall
        push hl;НЕ ТРОГАТЬ !!

        ld hl,0
        ld (filescopied),hl
        
        ld de,PROGRESBARWINXY
        ld bc,PROGRESBARWINHGTWID
        call prwin
        ld hl,proceditcmd_copy
        ld ix,(curpanel)
	jp processfiles

proceditcmd_copy
        bit 0,(hl)
	ret z
        call getfcbfromhl
        call setcurpaneldir

        if 1==1

        ld hl,proceditcmd_copy_q
        push hl

        ld de,filenametext;wordbuf ;de=drive/path/file
         push de
         ld hl,fcb_filename
         call cpmname_to_dotname
         pop de
        OS_OPENHANDLE
        or a
        ret nz ;jp nz,cmd_error_wrongfile
        ld a,b
        ld (cmd_copy_close_file1_handle),a
        ld hl,cmd_copy_close_file1
        push hl

        ld de,filenametext
        OS_GETFILETIME ;ix=date, hl=time
        ld (proceditcmd_copy_time),hl
        ld (proceditcmd_copy_date),ix

     	call setanotherpaneldir
        
        ld de,filenametext;swordbuf2 ;de=drive/path/file
        OS_CREATEHANDLE
        or a
        ret nz ;jp nz,cmd_error_cant_copy
        ld a,b
        ld (cmd_copy_close_file2_handle),a
        ld hl,cmd_copy_close_file2
        push hl
cmd_copy0
        ld hl,copybuf_sz
        ld de,copybuf
        ld a,(cmd_copy_close_file1_handle)
        ld b,a
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push de
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        pop de
        ld a,h
        or l
        ret z ;0 bytes remain
        ld a,(cmd_copy_close_file2_handle)
        ld b,a
;B = file handle, DE = Buffer address, HL = Number of bytes to write
        OS_WRITEHANDLE
        jr cmd_copy0
        
cmd_copy_close_file1
cmd_copy_close_file1_handle=$+1
        ld b,0
        OS_CLOSEHANDLE
        ret
        
cmd_copy_close_file2
cmd_copy_close_file2_handle=$+1
        ld b,0
        OS_CLOSEHANDLE
proceditcmd_copy_time=$+1
        ld hl,0
proceditcmd_copy_date=$+2
        ld ix,0
        ld de,filenametext
        OS_SETFILETIME
        ret
        
        else ;CP/M-like functions
        
        ld hl,fcb_filename
        ld de,fcb2_filename
        call copy_to_defcb_filename
        call nv_openfcb ;autopush nv_closefcb
        ret nz ;jp nz,editcmd_copy_error_wrongfile
     	call setanotherpaneldir
        call nv_createfcb2 ;autopush nv_closefcb2
        ret nz ;jp nz,editcmd_copy_error_cant_copy
editcmd_copy0
        ld de,copybuf
        OS_SETDTA
        ld de,fcb
        OS_FREAD
        xor 128
        jp z,proceditcmd_copy_q ;прочитали 0 байт - успешный выход
         ld l,a
         ld h,0
         push hl
        ld de,copybuf
        OS_SETDTA
         pop hl
        ld de,fcb2
        OS_FWRITE_NBYTES
        or a
        jr z,editcmd_copy0
;can't write
        ;ret
        
        endif
        
proceditcmd_copy_q
filescopied=$+1
        ld hl,0
        inc hl
        ld (filescopied),hl
        ;ld bc,32
        ;ex de,hl ;ld de,(percentcopyfile)
        ;call mulbcde_ahl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        push hl
        ld ix,(curpanel)
;ix = panel
        call getmarkedfiles ;out: hl'hl = files
        ex de,hl ;de=files
        pop hl ;filescopied*32
        call divhlde
        ld a,l
        or a
        ret z
        ld b,a
        ld de,PROGRESBARWINXY+#0102
proceditcmd_copy_q_progress0       
        push de
        push bc
        OS_SETXY
        ld e,#ff
        OS_PRATTR
        pop bc
        pop de
        inc e
        djnz proceditcmd_copy_q_progress0
        ret 
        
mulbcde_ahl
;bc * de результат в ahl
        xor a
        ld h,a
        ld l,a
        dup 8
        rlc b
        jr nc,$+5 ; c - был перенос, nc - не было переноса    
        add hl,de
        adc a,0
        add hl,hl
        rla
        edup
        dup 7
        rlc c
        jr nc,$+5 ; c - был перенос, nc - не было переноса    
        add hl,de
        adc a,0
        add hl,hl
        rla
        edup
        rlc c
        ret nc
        add hl,de
        adc a,0
        ret
        
;hl / de результат в hl
divhlde
	ld c,h
	ld a,l
	ld hl,0
	ld b,16
;don't mind carry
_DIV0.
;shift left hlca
	rla
	rl c
	adc hl,hl
;no carry
;try sub
	sbc hl,de
	jr nc,$+3
	add hl,de
;carry = inverted bit of result
	djnz _DIV0.
	rla
	cpl
	ld l,a
	ld a,c
	rla
	cpl
	ld h,a
        ret
        
editcmd_0
editcmd_quit
        ld e,COLOR_RED
        call nv_setcolor
        ld hl,winquit
        call prwindow_waitkey ;CY=OK
        jp nc,editcmd_reprintall
        QUIT

ifcmdnonempty_typedigit
;keeps ix
        ld c,a
        ld a,(cmdbuf)
        or a
        ld a,c
        ret z ;cmd is empty
         pop bc ;skip return to editcmdN
        jp editcmd_typein

windrv
        dw 0x0003 ;de=yx
        dw 256*(3+15)+9;0x0809 ;bc=hgt,wid
        db "Drive",0
        db 3 ;next line
        db "  A:",0,3
        db "  B:",0,3
        db "  C:",0,3
        db "  D:",0,3
        db "  E:",0,3
        db "  F:",0,3
        db "  G:",0,3
        db "  H:",0,3
        db "  I:",0,3
        db "  J:",0,3
        db "  K:",0,3
        db "  L:",0,3
        db "  M:",0,3
        db "  N:",0,3
        db "  O:",0,3
        db 0 ;end of window
        
winmkdir
        dw 0x0a0f ;de=yx
        dw 0x0520 ;bc=hgt,wid
        db "Create new directory:",0
        db 3 ;next line
        db 2 ;print outer text
        dw tnewfilename
        db 0 ;end of window

winrename
        dw 0x0a0f ;de=yx
        dw 0x0520 ;bc=hgt,wid
        db "Rename file:",0
        db 3 ;next line
        db 2 ;print outer text
        dw tnewfilename
        db 0 ;end of window
        
tnewfilename
        db "12345678.123",0
tnewfilename_sz=12

winquit
        dw 0x0a1f ;de=yx
        dw 0x0515 ;bc=hgt,wid
        db 3 ;next line
        db "Quit Nedovigator?",0
        db 0 ;end of window

windel
	dw 0x0919 ;de=yx
        dw 0x051f ;bc=hgt,wid
        db 3 ;next line
	db "Delete ",0 
        db 1 ;nfiles
	db " file(s)?",0
        db 0 ;end of window

wincopy
	dw 0x0919 ;de=yx
        dw 0x051f ;bc=hgt,wid
        db 3 ;next line
	db "Copy ",0 
        db 1 ;nfiles
	db " file(s)?",0
        db 0 ;end of window
        
        
tdotdot
	dw "..",0


        STRUCT PANEL
;sorterjp	BYTE ;TODO remove
;sorter		WORD ;TODO remove
xy		WORD
;pg		BYTE ;TODO remove
pgadd		BYTE ;0/DIRPAGES
catbuf		WORD ;TODO remove
poipg		BYTE
pointers	WORD ;TODO remove
totalsize	DWORD
files		WORD ;visible files
filesdirs       WORD ;files+dirs (no ".", "..")
markedfiles	WORD
markedsize	DWORD
dirpos		WORD
dirscroll	WORD
dirviewmode	BYTE
dirsortproc	WORD
dirsortmode	BYTE
dir		BLOCK MAXPATH_sz
	ENDS
;PANEL_sz=13+MAXPATH_sz

leftpanel PANEL
rightpanel PANEL

oldtimer
        dw 0
        
;<0x4000 for hobeta
fcb
        ds FCB_sz
fcb_filename=fcb+FCB_FNAME        

fcbmask
        db 0
        db "???????????"
        ds FCB_sz-11-1
fcbmask_filename=fcbmask+FCB_FNAME        

fcb2
        ds FCB_sz
fcb2_filename=fcb2+FCB_FNAME        

cmd_filename
        db "cmd     com"
ext_filename
        db "nv      ext"
texted_filename
        db "texted  com"

filenametext ;for change dir, rename
        db "prince  .   ",0 ;ds 64

ext
        ds 3 ;TODO объединить с filenametext
        
copybuf=0x4000 ;нельзя 0xc000 - поверх какой-нибудь директории (а она используется при копировании) ;0x8000 можно только после выставления страницы там
        ;ds 4096;128
copybuf_sz=0x4000;$-copybuf

        align 256
file_buf
        ds 128
file_buf_end=$-1

washobetarunner
;pgsys=pagexor-10
;pgfatfs=pagexor-9
;pgtrdosfs=pagexor-8
;pgkillable=pagexor-4 ;в 128K памяти, т.к. можно портить
	disp hobetarunner ;in pgkillable
;$c loaded in pages 4,1,0
;only ATM2 ports here!
	di
	ld a,#7f-5
        ld bc,#bff7
	out (c),a
	ld a,#7f-4
        ld bc,#fff7
	out (c),a
        ld hl,#c000
        ld de,#8000
        ld bc,#4000
        ldir ;pg4 -> pg5
	ld a,#7f-8;pgtrdosfs
        ld bc,#fff7
	out (c),a
        ld hl,#1c00+#c000
        ld de,#1c00+#8000
        ld bc,#400
        ldir ;restore sysvars
	ld a,#7f-2
        ld bc,#bff7
	out (c),a
	ld a,#7f-1
        ld bc,#fff7
	out (c),a
        ld hl,#c000
        ld de,#8000
        ld bc,#4000
        ldir ;pg1 -> pg2
	ld a,#7f-0+#80
	ld bc,#fff7
	out (c),a
	ld a,#00
	ld bc,#7ffd
	out (c),a
	ld a,#81 ;128 basic (with 7ffd)
	ld bc,#3ff7
	out (c),a
	ld a,#7f-5
	ld bc,#7ff7
	out (c),a
;128: pages DOS,5,2,0(7ffd)
	ld a,#10
	ld bc,#7ffd
	out (c),a
;48: pages 2,4,4,4
	ld a,#7f-5
	ld bc,#7ff7
	out (c),a
	ld a,#7f-2
        ld bc,#bff7
	out (c),a
	ld a,#7f-0+#80
        ld bc,#fff7
	out (c),a
	ld a,#83 ;48 basic switchable to DOS
	ld bc,#3ff7
	out (c),a
;48: pages DOS,5,2,0(7ffd)
        
        LD A,%10101011 ;6912
	ld bc,#ff77 ;shadow ports off, palette off
        out (c),a
	ld sp,#6000
	ei
hobetarunner_jp=$+1
	jp #6000
        ent
hobetarunner_sz=$-washobetarunner

wordfiles
        db " files",0
wordbytes
        db " bytes",0

;HS_elpg ;2 pages
;        ds 2
        align 256
HS_strpg
        ds DIRPAGES*2+2 ; по 1 байту на маркеры "0"
        
        include "nvsort.asm"
        include "heapsort.asm"

        include "nvjptbl.asm"
        include "nvunit.asm"
        include "nveditln.asm"
        include "nvview.asm"
        include "nvhexed.asm"

        include "../_sdk/prdword.asm"
        include "../_sdk/loadpage.asm"
        include "../_sdk/cmdpr.asm"
        
cmd_end

	display "nv size ",/d,cmd_end-cmd_begin," bytes"

	savebin "nv.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "..\us\user.l"
