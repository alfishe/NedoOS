        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

HEAPSORT_LH=1 ;byte order in poiters: LSB,HSB

MAXCMDSZ=COMMANDLINE_sz-1-4 ;not counting terminator (-4 for "cmd ")

_COLOR=0x0007;0x07
_PANELCOLOR=0x040f;0x4f
_PANELDIRCOLOR=0x040f;0x4f
_PANELEXECOLOR=0x040a;0x4c
_PANELFILECOLOR=0x0407;0b00001111;0xf
_PANELSELECTCOLOR=0x040b;0x4e
_CURSORCOLOR=0x0600;0x28
_FILECURSORCOLOR=0x0600;0x28
_COLOR_RED=0x0107;0x17
_COLOR_DIALOG=0x0300;0700 не видно курсор;0x38
_HINTCOLOR1=0x0007;7
_HINTCOLOR0=0x0600;5*8

;8192fcbs*32bytes*2panels = 32 pages
DIRPAGES=16
FIRSTDIRPAGEFORRIGHTPANEL=128

catbuf_left=0xc000
catbuf_right=0xc000
FILES_POINTERS_left=0xc000;0x3700
FILES_POINTERS_right=0xc000;0x3b00

txtscrhgt=25
txtscrwid=80
CMDLINEY=23;24
CONST_HGT_TABLE=21
PANELDIRCHARS37=37
left_panel_xy=0x0000
right_panel_xy=0x0028
firstfiley=left_panel_xy/256 + 1
PROGRESBARWINXY=0x0f16 ;0x0919 + 051f ;de=yx
PROGRESBARWINHGTWID=0x0324 ;0x051f ;bc=hgt,wid

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
        call initstdio

        ;ld e,6 ;textmode
        ;OS_SETGFX
        
	;call nv_copyscreen0to1
        ;GET_KEY ;съедаем key_redraw

        CLS_ ;print 25 lines of spaces except one
        
;        ld de,nvpal
;        OS_SETPAL
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000(copybuf),8000,c000*(dirbuf)
        push hl
        ld e,h
        OS_DELPAGE
        pop hl
        ld e,l
        OS_DELPAGE

	OS_NEWPAGE ; for dircopy batch
	ld hl,dirpg
	ld (hl),e

	OS_NEWPAGE ;выделяем по одной страничке для каталогов
        ld hl,HS_strpg
        ld (hl),e
	inc hl
	ld (hl),0 ;маркер конца списка страниц
	OS_NEWPAGE ;выделяем по одной страничке для длинных имён
        ld hl,HS_strpg+DIRPAGES+1
        ld (hl),e
	inc hl
	ld (hl),0 ;маркер конца списка страниц        

	OS_NEWPAGE
	ld hl,HS_strpg+FIRSTDIRPAGEFORRIGHTPANEL;DIRPAGES+1
        ld (hl),e
	inc hl
	ld (hl),0 ;маркер конца списка страниц
	OS_NEWPAGE ;выделяем по одной страничке для длинных имён
        ld hl,HS_strpg+FIRSTDIRPAGEFORRIGHTPANEL+DIRPAGES+1
        ld (hl),e
	inc hl
	ld (hl),0 ;маркер конца списка страниц        
        
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
	ld a,FIRSTDIRPAGEFORRIGHTPANEL;DIRPAGES+1
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

	call readpanels_reprint

mainloop
        call editcmd_readprompt_setendcmdx
        call controlloop
        jp mainloop

strdelpages ;удаляем str страницы. IX - панель. первую страничку не удаляем
	ld hl, HS_strpg
	ld e, (ix+PANEL.pgadd)
	ld d,0; (ix+PANEL.pgadd+1)
	add hl,de
        ld (ix+PANEL.curpgfcbpoi),l
        ld (ix+PANEL.curpgfcbpoi+1),h
        call strdelpages_next
strdelpages_lname
	ld hl, HS_strpg+DIRPAGES+1 ;HS_lnamepg
	ld e, (ix+PANEL.pgadd)
	ld d,0; (ix+PANEL.pgadd+1)
	add hl,de
        ld (ix+PANEL.curpglnamepoi),l
        ld (ix+PANEL.curpglnamepoi+1),h
        ;jp strdelpages_next

strdelpages_next
        inc hl
        ld a, (hl)
        or a
        ret z
        ld e, a
        push hl
        push ix
	OS_DELPAGE
        pop ix
	pop hl
        xor a
        ld (hl), a
        jr strdelpages_next

lnamenewpage ;выделяем новую страничку IX - панель, [E номер странички в HS_strpg]
	push hl
	push de
        push ix
	OS_NEWPAGE
        pop ix
        ld l,(ix+PANEL.curpglnamepoi)
        ld h,(ix+PANEL.curpglnamepoi+1)
	ld (hl),e
	inc hl
	ld (hl),0 ; маркер конца списка
        ld (ix+PANEL.curpglnamepoi),l
        ld (ix+PANEL.curpglnamepoi+1),h
	pop de
	pop hl
	ret
        
strnewpage ;выделяем новую страничку IX - панель, [E номер странички в HS_strpg]
	push hl
	push de
        push ix
	OS_NEWPAGE
        pop ix
        ld l,(ix+PANEL.curpgfcbpoi)
        ld h,(ix+PANEL.curpgfcbpoi+1)
	ld (hl),e
	inc hl
	ld (hl),0 ; маркер конца списка
        ld (ix+PANEL.curpgfcbpoi),l
        ld (ix+PANEL.curpgfcbpoi+1),h
	pop de
	pop hl
	ret

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
        PRCHAR_
        pop hl
        jr prhint0
prhint_color0
        ld de,_HINTCOLOR1;7
        jr prhint_color
prhint_color1
        ld de,_HINTCOLOR0;5*8
prhint_color
        call nv_setcolor
        jr prhint0
thint
        db "{1}Drive { 2}Find  { 3}View  { 4}Edit  { 5}Copy  { 6}Rename{ 7}MkDir { 8}Delete{ 9}InsNam{ 0}Quit  ",0

readpanels_reprint
        call printhint
	ld ix,leftpanel
	call readsortdrawpanel
	ld ix,rightpanel
readsortdrawpanel
	call readdir
	call sortfiles
	jp drawpanel_with_files

readpanels_reprint_keepcursor
        call printhint
	ld ix,leftpanel
	call readsortdrawpanel_keepcursor
	ld ix,rightpanel
readsortdrawpanel_keepcursor
	call readdir_keepcursor
	call sortfiles
	jp drawpanel_with_files

drawpanel_head ;ix=panel
        call nv_getpanelxy_de
        inc e
	inc e
        call nv_setxy
	push ix
	or a
	ld de,(curpanel)
	pop hl
	push hl
	sbc hl,de
	pop hl
	jr nz,drawpanel_dir
	ld de,_FILECURSORCOLOR
	jr drawpanel_dir0
drawpanel_dir
	ld de,_PANELCOLOR
drawpanel_dir0
	call nv_setcolor
	ld de,PANEL.dir
	add hl,de
        push hl
        ld c,0
        call panelprtext
	call setpanelcolor
        pop hl
        call strlen ;hl=len
        ex de,hl
        ld hl,PANELDIRCHARS37
        or a
        sbc hl,de
        ret c
        ret z
        ld de,tdoublehoriz
        jp sendchars

drawpanel_with_files
;ix=panel
	call setpanelcolor
        call nv_getpanelxy_de
        bit 0,(ix+PANEL.drawtableunneeded)
        set 0,(ix+PANEL.drawtableunneeded)
	call z,prtable ;keeps ix

	call setpaneldir_makeprompt ;keeps ix
        ld de,_COLOR
        call nv_setcolor

	call drawpanel_head
        call drawpanelfilesandsize

drawpanel_files
;ix=panel
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
        call gotofilepointer_numberde ;hl=file pointer
        call nv_getpanelxy_de
	inc d 
	inc e
	ld b,c ;files to show
        ld a,b
        or a
        jr z,premptyfiles
prNfiles0
	push bc
	push de
        call nv_setxy ;keeps de,hl
	;ld e,(hl)
	;inc hl
	;ld d,(hl)
	;inc hl
        call getfilepointer_de_fromhl ;uses ix
	push hl
	ex de,hl
        push ix
	call prdirfile
        pop ix
	pop hl
	pop de
	pop bc
	inc d
	djnz prNfiles0
premptyfiles
;c=files to show
        ld a,CONST_HGT_TABLE
        sub c
        ret z
        push ix
        ld b,a
premptyfiles0
	push bc
	push de
        call nv_setxy ;keeps de,hl
	;ld e,(hl)
	;inc hl
	;ld d,(hl)
	;inc hl
        ;call getfilepointer_de_fromhl
	;push hl
	;ex de,hl
        ;push ix
        ld de,emptyfilelinebuf
        ld hl,emptyfilelinebuf_sz
        call sendchars
        ;pop ix
	;pop hl
	pop de
	pop bc
	inc d
	djnz premptyfiles0
        pop ix
	ret

fileiscom ;fcb ;output: z=com
	ld a,(fcb+9);(ix+9)
         or 0x20
	 cp 'c'
	jr nz,fileiscom_ix_nocom_a
	ld a,(fcb+10);(ix+10)
         or 0x20
	 cp 'o'
	jr nz,fileiscom_ix_nocom
	ld a,(fcb+11);(ix+11)
         or 0x20
	 cp 'm'
        ret z
fileiscom_ix_nocom
	ld a,(fcb+9);(ix+9)
fileiscom_ix_nocom_a
	cp '$'
	ret nz ;jr nz,fileiscom_ix_nohobeta
	ld a,(fcb+10);(ix+10)
         or 0x20
	 cp 'c'
	ret

colorfile
;ix=fcb
;out: de=color
	ld a,(fcb);(ix) ;mark
	rra
        ld de,_PANELSELECTCOLOR
        ret c
        ld a,(fcb+FCB_FATTRIB);(ix+FCB_FATTRIB)
        and FATTRIB_DIR
	ld de,_PANELDIRCOLOR
	ret nz
	call fileiscom
	ld de,_PANELEXECOLOR
        ret z
	ld de,_PANELFILECOLOR
        ret

prdirfile
;hl=fcb
        call getfcbfromhl
        call colorfile ;de=color
prdirfile_ix_decolor
        call nv_setcolor
        ld a,(fcb+FCB_EXTENTNUMBERLO)
        SETPG32KHIGH
        ld hl,(fcb+FCB_EXTENTNUMBERHI)
        ld de,filelinebuf
        ld b,25
prdirfile_fn0
        ld a,(hl)
        or a
        jr z,prdirfile_fn0q
        ld (de),a
        inc hl
        inc de
        djnz prdirfile_fn0
        jr prdirfile_fn0qq
prdirfile_fn0q
        ld a,' '
prdirfile_fn1
        ld (de),a
        inc de
        djnz prdirfile_fn1         
prdirfile_fn0qq
        ld de,filelinebuf+15
        exx
        ld hl,(fcb+FCB_FSIZE+2)
	exx
        ld hl,(fcb+FCB_FSIZE)
        ld a,(fcb+FCB_FATTRIB)
        and FATTRIB_DIR
        call z,prdword_de
         ld de,filelinebuf+28 ;skip "cursor right" over | (which has different color)
        ld hl,(fcb+FCB_FDATE)
        push hl
        ld a,l
        and 0x1f
        call prNNcmd ;day
        pop hl 
        push hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 0x0f
        add a,a
        ld l,a
        ld h,0
        ld bc,tmonth-2
        add hl,bc
        ldi
        ldi
        pop hl
        ld a,h
        srl a
        sub 20
        jr nc,$+4
        add a,100 ;XX century
        call prNNcmd ;year        
         inc de
        ld hl,(fcb+FCB_FTIME)
        push hl
        ld a,h
        rra
        rra
        rra
        and 0x1f
        call prNNcmd ;hour
         inc de ;skip ':'
        pop hl
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 0x3f
        call prNNcmd ;minute
        ld de,filelinebuf
        ld hl,filelinebuf_sz
        jp sendchars
prNNcmd
;a=NN
;de=buf
        ld bc,10+(256*('0'-1))
        sub c
        inc b
        jr nc,$-2
         ex de,hl
         ld (hl),b
         ex de,hl
         inc de
        add a,'0'+10
         ld (de),a
         inc de
        ret

filelinebuf
        db "filename.ext   1234567890",0x1b,"[CDDmmYY hh:mm"
filelinebuf_sz=$-filelinebuf
emptyfilelinebuf
        db "                         ",0x1b,"[C            "
emptyfilelinebuf_sz=$-emptyfilelinebuf
        
tmonth
        ;db "jan"
        ;db "feb"
        ;db "mar"
        ;db "apr"
        ;db "may"
        ;db "jun"
        ;db "jul"
        ;db "aug"
        ;db "sep"
        ;db "oct"
        ;db "nov"
        ;db "dec"
        db "ja","fe","mr","ap","my","jn","jl","au","se","oc","no","de"
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readdir
;ix=panel
        call readdir_keepcursor
nv_setcursor_zero
        ld bc,0
        call nv_setdirscroll_bc
        jp nv_setdirpos_zero

nv_setcursor_hl
        call nv_setdirpos_hl
	ld bc,CONST_HGT_TABLE*2/3;CONST_HGT_TABLE-1
        xor a
        sbc hl,bc
        jr nc,$+4
         ld h,a
         ld l,a
        ld b,h
        ld c,l
        jp nv_setdirscroll_bc

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
	;call setpaneldir
	call strdelpages
	;ld de,fcb
        ;OS_SETDTA ;set disk transfer address = de
        ;call makeemptymask
        ;ld de,fcbmask
        ;OS_FSEARCHFIRST
	pop hl ;get IX
	push hl
	ld de,PANEL.dir
	add hl,de
	ex de,hl ;de=path
	OS_CHDIR
	ld de,emptypath
	OS_OPENDIR
	pop ix
        or a

        ld hl,0xc000
        ld (loaddir_curlnameaddr),hl

	ld e,(ix+PANEL.catbuf)     ;00
	ld d,(ix+PANEL.catbuf+1)   ;c0
	ld l,(ix+PANEL.pointers)   ;00  номер страницы
	ld h,(ix+PANEL.pointers+1) ;c0  номер файла
        ld bc,0 ;nfiles
        jp nz,loaddir_error
		;ld a,(fcb+1)
		;cp '.'
		;jp z,loaddir_onedot
loaddir0
        call loaddir_filinfo
        jp c,loaddirq
        jr z,loaddir0
        
        push bc

	push de
	push hl
        
        ;ld l,(ix+PANEL.curpgfcbpoi)
        ;ld h,(ix+PANEL.curpgfcbpoi+1)
        ;ld a,(hl)
        ;SETPG32KHIGH
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
        ;ld hl,fcb+1
        ;ld bc,31;FCB_sz 
        ;ldir ; копируем fcb в catbuf
        ld hl,filinfo+FILINFO_FNAME
        ;ld bc,8
        ;ldir
        ;inc hl
        ;ld c,3
        ;ldir
        ex de,hl
        push hl
        call dotname_to_cpmname ;de -> hl
        pop hl
        ld bc,11
        add hl,bc
        ex de,hl
        ld (loaddir_fcb_lnamepgpoi),de
        inc de ;extent number - NU
        ld hl,filinfo+FILINFO_FATTRIB
        ldi
        ld (loaddir_fcb_lnameaddrpoi),de
        inc de ;record count - NU
        inc de ;extent number hi - NU
        ld hl,filinfo+FILINFO_FSIZE
        ;TODO через процедуру
	push hl
        push ix
        ld a,(hl)
        add a,(ix+PANEL.totalsize)
        ld (ix+PANEL.totalsize),a
        inc hl
        ld a,(hl)
        adc a,(ix+PANEL.totalsize+1)
        ld (ix+PANEL.totalsize+1),a
        inc hl
        ld a,(hl)
        adc a,(ix+PANEL.totalsize+2)
        ld (ix+PANEL.totalsize+2),a
        inc hl
        ld a,(hl)
        adc a,(ix+PANEL.totalsize+3)
        ld (ix+PANEL.totalsize+3),a
        pop ix
	pop hl
        ld bc,4
        ldir
        ld hl,filinfo+FILINFO_FTIME
        ld c,2
        ldir
        ex de,hl
        ld c,8
        add hl,bc
        ex de,hl
        ld hl,filinfo+FILINFO_FDATE
        ld c,2
        ldir

loaddir_curlnameaddr=$+1
        ld de,0
;если нету места под длинное имя в текущей странице, заказать новую и сдвинуть указатель
        ld a,d
        inc a
        jr nz,loaddirlname_nonewpg
        ld a,e
        cp -DIRMAXFILENAME64
        jr c,loaddirlname_nonewpg
	call lnamenewpage
        ld de,0xc000        
loaddirlname_nonewpg
;записать текущий указатель на длинное имя в fcb
;записать длинное имя по указателю
        ld l,(ix+PANEL.curpglnamepoi)
        ld h,(ix+PANEL.curpglnamepoi+1)
        ld a,(hl)
loaddir_fcb_lnamepgpoi=$+1
        ld (0),a
loaddir_fcb_lnameaddrpoi=$+2
        ld (0),de
        SETPG32KHIGH
        ld hl,filinfo+FILINFO_LNAME
        ld a,(hl)
        or a
        jr nz,$+5
        ld hl,filinfo+FILINFO_FNAME
        call strcopy ;out: hl,de after terminator
        ld (loaddir_curlnameaddr),de
        
	pop hl
	pop de
        call putfilepointer_de_tohl ; возвращает в верхнее окно страницу poipg и в pointers заносит de
	ex de,hl
	ld bc,32
	add hl,bc
	ex hl,de ; увеличили на 32 catbuf
	jr nc,nonewpg ; всё ещё умещаемся в страницу
	inc de ;next page de
	call strnewpage
        set 7,d
        set 6,d
nonewpg:
        
        pop bc
        inc bc ;nfiles
        bit 5,b;1,b ;страничка pgtemp закончилась? max 512 файлов по 32 байта
        jp z,loaddir0
loaddir_error
loaddirq
;bc=nfiles
	ld (ix+PANEL.files),c
	ld (ix+PANEL.files+1),b

        call countfiles
        ld (ix+PANEL.filesdirs),l
        ld (ix+PANEL.filesdirs+1),h
        
        ex de,hl
        call nv_getdirpos_hl
        or a
        sbc hl,de ;dirpos<files?
        ret c ;OK
	jp nv_setcursor_zero

loaddir_filinfo
        push bc
	push de
	push hl        
        ld de,filinfo
        OS_READDIR
        pop hl
        pop de
        pop bc
        or a
         scf
        ret nz ;CY
        ld a,(filinfo+FILINFO_FNAME)
        or a
         scf
        ret z ;CY
	ld a,(filinfo+FILINFO_FNAME+1)
	or a
	ret nz ;not one dot ;NC
	ld a,(filinfo+FILINFO_FNAME)
	cp '.'
	ret z ;Z,NC ;one dot
        or a ;NZ,NC
        ret

controlloop
        call fixscroll_prcmd
controlloop_noprline
        ld hl,controlloop
        push hl
        ld ix,(curpanel)
        ld a,(ix+PANEL.files)
        or (ix+PANEL.files+1)
        call z,nv_setdirpos_zero ;can't move cursor if 0 files
        ;ld e,CURSORCOLOR;#38
        ;OS_PRATTR ;draw cursor
	ld hl,_FILECURSORCOLOR
	call prfilecursor_reprintfile
        call cmdcalccurxy
        call nv_setxy
        ;SETX_ ;force reprint cursor
controlloop_nokey
        call yieldgetkeyloop ;YIELDGETKEYLOOP
         or a
         jr z,controlloop_nokey ;TODO handle mouse events
        push af
        ld ix,(curpanel)
        call getfcbaddrundercursor
        push hl
        pop ix
        call colorfile
        ex de,hl ;hl=color
	call prfilecursor_reprintfile ;remove file cursor
        ;call cmdcalccurxy
        ;call nv_setxy
        ;ld e,COLOR;7
        ;OS_PRATTR ;remove cursor
         ld de,_COLOR
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
editcmd_del
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        ret z ;нечего удалять вправо
        inc hl
        jp strdelch

;hl = poi to filename in string
;out: de = after last slash
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
        
editcmddirback
editcmddirback_go
	call setpaneldir
	ld de,tdotdot
	OS_CHDIR
;взять имя директории из последнего элемента paneldir
        ld hl,(curpanel)
        push hl
	ld de,PANEL.dir
	add hl,de
        call findlastslash. ;out: de = after last slash
        ex de,hl
        ld de,filenametext
        call strcopy
        pop hl ;ld hl,(curpanel)
        push hl
        call editcmd_setpaneldirfromcurdir_panelhl
	pop ix ;ld ix,(curpanel)
	call readdir
	call sortfiles
;найти имя директории
        ;ld ix,(curpanel)
        call getfiles
        ld b,h
        ld c,l
        ld hl,0
editcmddirbackfind0
        push bc
        push hl
        call getfcbaddrunderhl
        ld de,FCB_EXTENTNUMBERLO
        add hl,de
        ld a,(hl)
        inc hl
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        SETPG32KHIGH
        ld hl,filenametext
        call strcp
        pop hl
        pop bc
        jr z,editcmddirback_ok
        cpi
        jp pe,editcmddirbackfind0
        ld h,b
        ld l,c ;error!!! not found!!!
editcmddirback_ok
;hl=номер элемента директории
        call nv_setcursor_hl ;установить на него курсор
        
	call drawpanel_with_files
        jp editcmd_readprompt_setendcmdx

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
        ret z ;некуда вправо, стоим на терминаторе
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
editcmd_clearkbddrawpanel
	call drawpanel_files
        jp clear_keyboardbuffer ;TODO почему не работает?

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
	jr editcmd_clearkbddrawpanel ;jp drawpanel_files      
editcmd_pageDown_nofirstvisible
        call nv_getdirscroll_bc
        ld h,b
        ld l,c
        call nv_setdirpos_hl
	jr editcmd_clearkbddrawpanel ;jp drawpanel_files      

editcmd_End
        ld hl,-1 ;>=files
        jp editcmd_pageDown_end_q

editcmd_Home
        xor a
        ld h,a
        ld l,a;0
        call nv_setdirpos_hl
        jr editcmd_pageUpq

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
        call scrolldown ;OS_SCROLLDOWN
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
        call scrollup ;OS_SCROLLUP
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
	push ix
        call getanotherpanel_ix
	ld (curpanel),ix
	call drawpanel_head
	pop ix
	call drawpanel_head ;inactive panel
        jp editcmd_readprompt_setendcmdx

editcmd_enter
	ld a,(cmdbuf)
	or a
        jr nz,editcmd_enter_runcmd
        call getfcbundercursor ;->fcb
	ld a,(fcb+FCB_FATTRIB)
	and FATTRIB_DIR;#10
	jp z,editcmd_enter_run
         ld hl,fcb+FCB_FNAME
         ld a,(hl)
         cp '.'
         jr nz,editcmd_enter_nodotdot
         inc hl
         ld a,(hl)
         cp '.'
         jp z,editcmddirback_go
editcmd_enter_nodotdot
        call changedir_fromfcb
;editcmd_setpaneldirfromcurdir
        ld hl,editcmd_reprintcurpanel
        push hl
	ld hl,(curpanel)
editcmd_setpaneldirfromcurdir_panelhl
	ld de,PANEL.dir
	add hl,de
        ex de,hl ;de=pointer to 64 byte (MAXPATH_sz!) buf
        OS_GETPATH
         jp clear_keyboardbuffer
        ;ret

editcmd_enter_runcmd
;run "cmd <command to run>"
        OS_SETSYSDRV ;TODO каталог cmd
        ld hl,cmd_filename
        call copy_to_fcb_filename
        
        ld hl,cmdbuf
loadandrun_waitpid
;hl=cmdbuf или cmdprompt (для loadandrun_restcmd)
        push hl
        call setdrawtablesneeded
        ld de,0
        SETXY_
        ld de,_COLOR
        SETCOLOR_
        CLS_
        ld de,0
        SETXY_
        pop hl ;hl=cmdbuf или cmdprompt
	 ;call setcurpaneldir
        call loadandrun ;nz=error, e=id
        jp nz,execcmd_error
;команда scratch - реально cmd scratch в текущем терминале
        WAITPID
        CLS_ ;scroll what was printed
execcmd_error
        ld hl,cmdbuf
        ld (hl),0
        jp editcmd_reprintall_keepcursor

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
        or 0x20
        cp 'c'
        jr nz,editcmd_enter_runfile_nocom
        ld a,c
        or 0x20
        cp 'o'
        jr nz,editcmd_enter_runfile_nocom
        ld a,b
        or 0x20
        cp 'm'
        jr nz,editcmd_enter_runfile_nocom
editcmd_enter_runfile_com
        ld hl,cmdbuf
        ld (hl),0
;hl=rest of command line
        jp loadandrun_waitpid

	;display "editcmd_enter_runfile_nocom",editcmd_enter_runfile_nocom
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
        jp loadandrun_waitpid

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
        jp cpmname_to_dotname ;prompt = "d:/path/filename"
        
runfile_findhandler
;find fcb_filename ext (spoiled) in "nv.ext"
;out: nz=error, cmdbuf=handler
        ld hl,fcb_filename+8
        ld de,ext
        ld b,3
runfile_nocom_recodeext0
        ld a,(hl)
        or 0x20
        ld (de),a
        inc hl
        inc de
        djnz runfile_nocom_recodeext0
        OS_SETSYSDRV ;TODO директория nv
        ld hl,ext_filename
        ld de,filenametext
        push de
	call cpmname_to_dotname
        pop de
        OS_OPENHANDLE
	or a
        ret nz ;error
        ld a,b
        ld (curhandle),a
        ;call copy_to_fcb_filename
        ;call nv_openfcb ;autopush nv_closefcb
        ;ret nz ;error
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
        call nv_closehandle
        xor a
        dec a
        ret ;nz
runfile_nocom_extok
        call skiptocolon ;пройти к ':'
        ld hl,cmdbuf
        call loadtoendline
        call nv_closehandle
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
        cp 0x0a
        jr z,checkoneext0 ;skip LF
        or 0x20
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
        cp 0x0d
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
        cp 0x0d
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
        ;OS_SETDTA ;set disk transfer address = de
        ;ld de,fcb
        ;OS_FREAD
        ;cp 128 ;128=no bytes read
        ld hl,128
        call readcurhandle
        ld a,h
        or l ;z=no bytes read
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        ret

editcmd_enter_runfile_hobeta
hobetarunner=0x4100
        ld e,6 ;textmode
        OS_SETGFX
        ld a,(user_scr0_low) ;ok
	sub 4-1 ;ld a,#ff-4 ;pgkillable
	SETPG16K

        ld hl,washobetarunner
        ld de,hobetarunner
        ld bc,hobetarunner_sz
        ldir
        
;cmdpgscreen0_0=$+1
;	ld a,#ff-1
        ld a,(user_scr0_low) ;ok
	SETPG32KLOW
        inc a ;ld a,#ff-0
	SETPG32KHIGH
;0x4000 : pg4
;0x8000 : pg1
;0xc000 : pg0

        call loadhobeta
        ret nz ;error
        ld hl,0x6000
        ld bc,(0x6000-17+11) ;len
        add hl,bc
        dec hl ;hl=load end
        ex de,hl
        ld hl,(0x6000-17+9) ;start
        ld (hobetarunner_jp),hl
        add hl,bc
        dec hl
        ex de,hl ;de=destination end
        lddr
	jp hobetarunner

loadhobeta        
        ;call nv_openfcb ;autopush nv_closefcb
        ;ret nz ;error
	ld hl,fcb_filename
        ld de,filenametext
        push de
	call cpmname_to_dotname
        pop de
        OS_OPENHANDLE
	or a
        ret nz ;error
        ld a,b
        ld (curhandle),a
        ld de,0x6000-17
        ld hl,-(0x6000-17)
        OS_READHANDLE
        ;OS_SETDTA
;editcmd_enter_runfile_hobeta_fcb0      
        ;ld de,fcb
        ;OS_FREAD
        ;or a
        ;jr z,editcmd_enter_runfile_hobeta_fcb0
;editcmd_enter_runfile_hobeta_fcbq
        call nv_closehandle
        xor a ;no error
        ret ;call nv_closefcb

loadandrun
;hl=rest of command line
;out: nz=error, e=id
;load file in fcb from system current dir with parameters in tcmd, then set curpaneldir and run
        ld (loadandrun_restcmd),hl
        ;call nv_openfcb ;autopush nv_closefcb
        ;ret nz ;error
	ld hl,fcb_filename
        ld de,filenametext
        push de
	call cpmname_to_dotname
        pop de
        OS_OPENHANDLE
	or a
        ret nz ;error
        ld a,b
        ld (curhandle),a
        ld hl,nv_closehandle
        push hl
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
        ld de,0xc000+COMMANDLINE
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
        ldir ;copy command line ;можем залезть за 0x0100!
        xor a
        ld (0xc000+COMMANDLINE+COMMANDLINE_sz-1),a
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
editcmd_F1
        ld ix,(curpanel)
	ld a,(ix+PANEL.xy)
        add a,10
        ld (windrv),a ;x
	add a,5
	ld (windrverr),a
        ld hl,editcmd_reprintcurpanel;editcmd_reprintall_onlyreadcurdir
        push hl

seldrv_redraw_mainloop
        ld hl,windrv
;hl=window
	ld de,_COLOR_DIALOG
	call nv_setcolor

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
        ld hl,_CURSORCOLOR
        ld b,22
        call drawfilecursor_sizeb_colorhl ;draw cursor
seldrv_mainloop_nokey
        call yieldgetkeyloop ;YIELDGETKEYLOOP
         or a
         jr z,seldrv_mainloop_nokey ;TODO handle mouse events
	ld a,c
        pop de
        push af
        ld hl,_COLOR_DIALOG
        ld b,22
        call drawfilecursor_sizeb_colorhl ;remove cursor
        pop af
        cp key_redraw
        jr z,seldrv_redraw_mainloop
        ld hl,seldrv_cury
        cp key_enter
        jr z,seldrv_selcursor
        cp key_esc
        ret z
	cp 'a'
	jr c,seldrv_cursor
	cp 'p'
	;jr nc,seldrv_cursor
	jr c,seldrv_selletter
seldrv_cursor
        ld bc,seldrv_mainloop
        push bc
        cp key_down
        jr z,seldrv_down
        cp key_up
        jr z,seldrv_up
        ret
seldrv_selletter
        sub 'a'
	jr seldrv_ok
seldrv_selcursor
	ld a,(hl)
seldrv_ok
	ld e,a
	push de
	OS_SETDRV
	pop de
	or a
        jr z,seldrv_ok0
	ld de,_COLOR_RED
	call nv_setcolor
	ld hl,windrverr
	call prwindow_waitkey
	ld de,_COLOR
	call nv_setcolor
	jp seldrv_redraw_mainloop
seldrv_ok0
	ld a,e
        add 'a'
        ld ix,(curpanel)
        ld (ix+PANEL.dir),a
        ld (ix+PANEL.dir+1),':'
        ld (ix+PANEL.dir+2),'/'
        ld (ix+PANEL.dir+3),0
;	ld hl,ix
;	ld de,PANEL.dir
;	add hl,de
;	ex hl,de
;	OS_CHDIR
;	or a
;        ret z
;	ld de,_COLOR_RED
;	call nv_setcolor
;	ld hl,windrverr
;	call prwindow_waitkey
;	ld de,_COLOR
;	call nv_setcolor
;	jp seldrv_redraw_mainloop
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
editcmd_F4
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
        jp loadandrun_waitpid
        
editcmd_9
        call ifcmdnonempty_typedigit
	;ld e,1
	;OS_SETSCREEN
	;YIELDGETKEYLOOP
	;ld e,0
	;OS_SETSCREEN
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
	;ld e,COLOR
	;OS_CLS
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
editcmd_F6
        ld hl,editcmd_reprintall_keepcursor;editcmd_reprintall
        push hl
	call setpaneldir
        call getfcbundercursor

        if 1==1
        ld a,(fcb+FCB_EXTENTNUMBERLO)
        SETPG32KHIGH
        ld hl,(fcb+FCB_EXTENTNUMBERHI)
        ld de,filenametext
        push hl
        call strcopy
        pop hl
        ld de,tnewfilename
        call strcopy
        ;ld bc,64 ;max filename size+terminator
        ;ldir
        else
        ld hl,fcb_filename
        ld de,tnewfilename
        push de
        call cpmname_to_dotname
        pop hl
        ld de,filenametext
        ld bc,12
        ldir
        endif

	ld de,_COLOR_DIALOG
	call nv_setcolor

        ld hl,winrename
	ld de,tnewfilename
	ld c,63;13 ;max filename size
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
editcmd_F7
        ld hl,editcmd_reprintall_keepcursor;editcmd_reprintall
        push hl
	call setpaneldir

	ld de,_COLOR_DIALOG
	call nv_setcolor
	xor a
        ld hl,winmkdir
	ld de,tnewfilename
	ld (de),a
	ld c,63;13 ;max filename size
        call prwindow_edit ;CY=OK, de=filename
        ret nc ;cancel
        OS_MKDIR
        ;TODO error
        ret

editcmd_8 ;del
        call ifcmdnonempty_typedigit
editcmd_F8
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
        ld de,_COLOR_RED
        call nv_setcolor
        ld hl,windel
        call prwindow_waitkey ;CY=OK
        jp nc,editcmd_reprintall_noreaddir
	ld hl,editcmd_reprintall_keepcursor;editcmd_reprintall
        push hl
	ld hl,windel2
	call prwindow_text
	ld hl,proc_del_file
	ld ix,(curpanel)
	jp processfiles
        
proc_del_file
	bit 0,(hl) ;marked?
	ret z
	call getfcbfromhl

	ld ix,(curpanel)
	ld de,PANEL.dir
	add ix,de
	push ix
	pop hl
	ld de,dir_buf
	call strcopy;nv_strcopy_hltode

	ld hl,proc_del_file_batch
	ld (nv_batch_proc),hl

proc_del_file_batch
	ld de,dir_buf
	OS_CHDIR

	ld hl,fcb_filename
        ld de,filenametext ;needed for batch
	call cpmname_to_dotname

	ld de,windel2_file ;dest
	ld bc,filenametext ;add
	ld hl,dir_buf ;src
	call nv_makefilepath_hltode ;result :  de=hl'/'bc
	ld hl,windel2_file
	call nv_fillpathspaces_hl ;fill to 64bytes spaces
	ld hl,windel2
	call upwindow_text ;update window

        ld de,filenametext
        OS_DELETE
	or a
	ret z ;if success return

        ld a,(fcb_attrib)
        and FATTRIB_DIR
	push af
	call nz,nv_copydir_add
	pop af
	jp nz,nv_copydir_add ;twice to remove empty dirs

        ret

editcmd_5 ;copy
        call ifcmdnonempty_typedigit
editcmd_F5
        ;ld ix,(curpanel)
        call getmarkedfiles ;countmarkedfiles
        ld a,h
        or l
        jr nz,editcmd_5_0       
        call getfcbaddrundercursor ;hl=fcb
        call isthisdotdir_hl
        ret z ;"." or ".."
        call changemark_hl ;ld (hl),1
editcmd_5_0

	call getanotherpanel_ix
	ld de,PANEL.dir
	add ix,de
	push ix
	pop hl
	ld de,dir2_buf
	call strcopy;nv_strcopy_hltode

	ld ix,(curpanel)
	ld de,PANEL.dir
	add ix,de
	push ix
	pop hl
	ld de,dir_buf
	call strcopy;nv_strcopy_hltode

	ld de,_COLOR_DIALOG
	call nv_setcolor
	ld ix,(curpanel)

        ld hl,wincopy
	ld de,dir2_buf
	ld c,60
        call prwindow_edit ;CY=OK
        jp nc,editcmd_reprintall_noreaddir

        ld hl,editcmd_reprintall
        push hl ;don't change!

        ld hl,0
        ld (filescopied),hl
        
;        ld de,PROGRESBARWINXY
;        ld bc,PROGRESBARWINHGTWID
;        call prwin
	ld hl,wincopy2
	call prwindow_text
        ld hl,proceditcmd_copy
        ld ix,(curpanel)
	jp processfiles

        if 1==0
nv_addslashtopath_hl ; out=terminator
	push hl
	call skipword_hl
	dec hl
	ld a,(hl)
	cp '/'
	jr z,nv_addslashtopath_hl0
	inc hl
	ld a,'/'
	ld (hl),a
nv_addslashtopath_hl0
	inc hl
	xor a
	ld (hl),a
	pop hl
	ret

nv_adddirtopath_detohl ; hl=path de=dirname; out - last component of path
	push hl
	call skipword_hl
	ex hl,de
	push hl
	call strlen
	ld b,h
	ld c,l
	pop hl
	ldir
	xor a
	ld (de),a
	pop hl
	ret
        endif

        if 1==0
nv_strcopy_hltode
;out: hl,de at terminator
	ld a,(hl)
	ld (de),a
	or a
	ret z
	inc hl 
	inc de
	jr nv_strcopy_hltode
        endif
strcopy
;hl->de
;out: hl,de after terminator
        xor a
strcopy0
        cp (hl)
        ldi
        jp nz,strcopy0
        ret

nv_makefilepath_hltode ;DE=dest HL=src BC=filename
        push bc
	call strcopy;nv_strcopy_hltode
        pop bc
;assumed that DE is after terminator
	dec de
	dec de
	ld a,(de)
	cp '/'
	jr z,nv_addslash0
	inc de
	ld a,'/'
	ld (de),a
nv_addslash0
	inc de
	xor a
	ld (de),a
	ld h,b
	ld l,c
	jp strcopy;nv_strcopy_hltode

nv_fillpathspaces_hl
	ld b,0
nv_fillpathspaces_hl0
	ld a,(hl)
	inc b
	inc hl
	or a
	jr nz,nv_fillpathspaces_hl0
	dec hl
	dec b
	ld c,' '
	ld a,b
nv_fillpathspaces_hl1
	ld (hl),c
	inc hl
	inc a
	cp 64
	jr c,nv_fillpathspaces_hl1
	ret

nv_batch_pushrecord
	OS_GETMAINPAGES
	ld a,h
	ld (savepg),a
	ld a,(dirpg)
	SETPG32KLOW

	ld hl,0x8000
	ld bc,(dir_batch_pointer)
	ld de,256
nv_batch_pushsrecord
	ld a,b
	or c
	jr z,nv_batch_pushsrecordend
	add hl,de
	dec bc
	jr nv_batch_pushsrecord
nv_batch_pushsrecordend
	push hl
;dir 1
	ld de,dir_buf
	ex hl,de
	ld bc,filenametext
	call nv_makefilepath_hltode
	pop hl
	ld de,128
	add hl,de
;dir2
	ld de,dir2_buf
	ex hl,de
	ld bc,filenametext
	call nv_makefilepath_hltode

	ld bc,(dir_batch_pointer)
	inc bc
	ld (dir_batch_pointer),bc
	ld a,(savepg)
	SETPG32KLOW
	ret

nv_batch_poprecord ;z=empty
	OS_GETMAINPAGES
	ld a,h
	ld (savepg),a
	ld a,(dirpg)
	SETPG32KLOW

	ld hl,0x8000
	ld bc,(dir_batch_pointer)
	ld a,b
	or c
	jr z,nv_batch_popsrecordq ;empty :(
	dec bc
	ld de,256
nv_batch_popsrecord
	ld a,b
	or c
	jr z,nv_batch_popsrecordend
	add hl,de
	dec bc
	jr nv_batch_popsrecord
nv_batch_popsrecordend
	ld de,dir_buf
	ld bc,128
	ldir
	ld de,dir2_buf
	ld  c,128
	ldir
	ld bc,(dir_batch_pointer)
	dec bc
	ld (dir_batch_pointer),bc
	ld a,1
	or a ;NZ
nv_batch_popsrecordq
	ld a,(savepg)
	SETPG32KLOW
	ret

nv_copydir_add
	jp nv_batch_pushrecord

nv_batch
	call nv_batch_poprecord
	ret z;empty
nv_label
	or a
	ld hl,(processfiles_proc) 
	ld de,proceditcmd_copy
	sbc hl,de
	jr nz,nv_batch_nocopydir ;if it's not copy

	ld de,dir2_buf
	OS_MKDIR
	ld de,dir2_buf
	OS_CHDIR ;de
	or a
	jr nz,nv_batch ;can't open dest dir
nv_batch_nocopydir
	ld de,dir_buf
	OS_CHDIR ;;
	or a
	jr nz,nv_batch ;can't open src dir

	ld de,fcb
	OS_SETDTA
	ld de,fcbmask
	OS_FSEARCHFIRST
	or a
	jr nz,nv_batch
	ld de,fcb
	OS_SETDTA
	ld de,fcbmask
	OS_FSEARCHNEXT
	or a
	jr nz,nv_batch ;skip . and ..
nv_batch1
	ld de,fcb
	OS_SETDTA
	ld de,fcbmask
	OS_FSEARCHNEXT
	or a
	jr nz,nv_batch_nofiles
nv_batch_proc=$+1
	call 0
	jr nv_batch1
nv_batch_nofiles
	or a
	ld hl,(processfiles_proc)
	ld de,proc_del_file
	sbc hl,de
	jr nz,nv_batch ;if not del
	ld a,'/'
	ld (dir2_buf),a
	xor a
	ld (dir2_buf+1),a
	ld de,dir2_buf
	OS_CHDIR
	ld de,dir_buf
	OS_DELETE
	jp nv_batch

skipword_hl
	ld a,(hl)
	or a
	ret z
	cp ' '
	ret z
	inc hl
	jr skipword_hl

proceditcmd_copy
        bit 0,(hl)
	ret z
        call getfcbfromhl

	ld hl,proceditcmd_copy_fcb
	ld (nv_batch_proc),hl

proceditcmd_copy_fcb
        ld hl,proceditcmd_copy_q
        push hl
	ld de,dir_buf
	OS_CHDIR

        ld de,filenametext ;wordbuf ;de=drive/path/file
	ld hl,fcb_filename
	call cpmname_to_dotname

	ld a,(fcb_attrib)
	and FATTRIB_DIR
	jp nz,nv_copydir_add

	ld de,wincopy_src ;update copy window
	ld bc,filenametext
	ld hl,dir_buf
	call nv_makefilepath_hltode
	ld hl,wincopy_src
	call nv_fillpathspaces_hl
	ld de,wincopy_dest
	ld bc,filenametext
	ld hl,dir2_buf
	call nv_makefilepath_hltode
	ld hl,wincopy_dest
	call nv_fillpathspaces_hl
	ld hl,wincopy2
	call upwindow_text

	ld de,filenametext
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

	ld de,dir2_buf
	OS_CHDIR

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

proceditcmd_copy_q
filescopied=$+1
        ld hl,0
         if 1==0
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
        SETXY_
        ;ld e,#ff
        ;OS_PRATTR
        ld a,'*'
        PRCHAR_
        pop bc
        pop de
        inc e
        djnz proceditcmd_copy_q_progress0
         endif
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
        call ifcmdnonempty_typedigit
editcmd_quit
        ld de,_COLOR_RED
        call nv_setcolor
        ld hl,winquit
        call prwindow_waitkey ;CY=OK
        jp nc,editcmd_reprintall_keepcursor;editcmd_reprintall
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

editcmd_typeword
        call getfcbundercursor
        ld hl,fcb_filename
        ld de,tnewfilename
        call cpmname_to_dotname ;de указывает на терминатор
        ld hl,cmdbuf
        call strlen ;hl=length
        ld bc,MAXCMDSZ-11
        or a
        sbc hl,bc
        ret nc ;некуда вводить
        add hl,bc
        ld bc,cmdbuf
        add hl,bc
        ex de,hl ;de=end of cmdbuf
        ld a,(cmdbuf)
        or a
        ld hl,tnewfilename
        jr z,editcmd_typeword_empty
        dec hl ;с пробелом
editcmd_typeword_empty
        call strcopy;nv_strcopy_hltode ;out: hl,de at terminator
        ld hl,cmdbuf
        call strlen ;hl=length
        ld a,l
        ld (curcmdx),a
        ret

windrv
        dw 0x0003 ;de=yx
        dw 256*(3+15)+28 ;0x0809 ;bc=hgt,wid
        db "Drive",0
        db 3 ;next line
        db "  A: - 1st Floppy",0,3
        db "  B: - 2nd Floppy",0,3
        db "  C: - 3rd Floppy",0,3
        db "  D: - 4th Floppy",0,3
        db "  E: - IDE Master p.1",0,3
        db "  F: - IDE Master p.2",0,3
        db "  G: - IDE Master p.3",0,3
        db "  H: - IDE Master p.4",0,3
        db "  I: - IDE Slave p.1",0,3
        db "  J: - IDE Slave p.2",0,3
        db "  K: - IDE Slave p.3",0,3
        db "  L: - IDE Slave p.4",0,3
        db "  M: - SD Z-controller",0,3
        db "  N: - SD NeoGS",0,3
        db "  O: - USB flash zx-net",0,3
        db 0 ;end of window

winmkdir
        dw 0x0a07 ;de=yx
        dw 0x0544 ;bc=hgt,wid
        db "Create new directory:",0
        db 3 ;next line
        db 2 ;print outer text
        dw tnewfilename
        db 0 ;end of window

winrename
        dw 0x0a07 ;de=yx
        dw 0x0544 ;bc=hgt,wid
        db "Rename file:",0
        db 3 ;next line
        db 2 ;print outer text
        dw tnewfilename
        db 0 ;end of window

wincopy
        dw 0x0a07 ;de=yx
        dw 0x0544 ;bc=hgt,wid
        db "Copy ",0
	db 1
	db " file(s)/dir(s) to:",0
        db 3 ;next line
        db 2 ;print outer text
        dw dir2_buf
        db 0 ;end of window

        db ' ' ;для typeword - перед tnewfilename
tnewfilename
        ds 64 ;max filename size+terminator
;        ds 12
;        db 0
;tnewfilename_sz=12

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

wincopy2
	dw 0x0706 ;de=yx
        db 68,8 ;wid,hgt
        db 3 ;next line
	db " Copying",0,3
wincopy_src
	db "                                                                ",0,3
	db " to",0,3
wincopy_dest
	db "                                                                ",0
        db 0 ;end of window

windel2
	dw 0x0706 ;de=yx
        db 68,6 ;bc=wid,hgt
	db " Deleting",0,3
        db 3 ;next line
windel2_file
	db "                                                                ",0
        db 0 ;end of window

windrverr
	dw 0x040f ;de=yx
        dw 0x0510 ;bc=hgt,wid
        db 3 ;next line
	db "Drive error!",0 
        db 0 ;end of window

tdotdot
	dw "..",0

        STRUCT PANEL
xy		WORD
catbuf		WORD ;TODO remove
poipg		BYTE
pointers	WORD ;TODO remove
pgadd		BYTE ;0/DIRPAGES
curpgfcbpoi     WORD
curpglnamepoi   WORD
drawtableunneeded BYTE
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

;<0x4000 for hobeta
fcb
        ds FCB_sz
fcb_filename=fcb+FCB_FNAME        
fcb_attrib=fcb+FCB_FATTRIB

;TODO kill (used in batch)
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
        ds 64 ;max filename size+terminator

ext
        ds 3 ;TODO объединить с filenametext

copybuf=0x4000 ;нельзя 0xc000 - поверх какой-нибудь директории (а она используется при копировании) ;0x8000 можно только после выставления страницы там
copybuf_sz=0x4000 ;$-copybuf

dir_batch_pointer db 0,0
savepg db 0,0
dirpg db 0,0

washobetarunner
;pgsys=pagexor-10
;pgfatfs=pagexor-9
;pgtrdosfs=pagexor-8
;pgkillable=pagexor-4 ;в 128K памяти, т.к. можно портить
	disp hobetarunner ;in pgkillable
;$c loaded in pages 4,1,0
;only ATM2 ports here!
	di
	ld a,0x7f-5
        ld bc,0xbff7
	out (c),a ;4,5,0
	ld a,0x7f-4
        ld bc,0xfff7
	out (c),a ;4,5,4
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir ;pg4 -> pg5
	ld a,0x7f-8;pgtrdosfs ;нельзя TOPDOWNMEM!!!
        ld bc,0xfff7
	out (c),a ;4,5,8
        ld hl,0x1c00+0xc000
        ld de,0x1c00+0x8000
        ld bc,0x400
        ldir ;restore sysvars
	ld a,0x7f-2
        ld bc,0xbff7
	out (c),a
	ld a,0x7f-1
        ld bc,0xfff7
	out (c),a
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x4000
        ldir ;pg1 -> pg2
	ld a,0x7f-0+0x80
	ld bc,0xfff7
	out (c),a
	ld a,0x00
	ld bc,0x7ffd
	out (c),a
	ld a,0x81 ;128 basic (with 7ffd)
	ld bc,0x3ff7
	out (c),a
	ld a,0x7f-5
	ld bc,0x7ff7
	out (c),a
;128: pages DOS,5,2,0(7ffd)
	ld a,0x10
	ld bc,0x7ffd
	out (c),a
;48: pages 2,4,4,4
	ld a,0x7f-5
	ld bc,0x7ff7
	out (c),a
	ld a,0x7f-2
        ld bc,0xbff7
	out (c),a
	ld a,0x7f-0+0x80
        ld bc,0xfff7
	out (c),a
	ld a,0x83 ;48 basic switchable to DOS
	ld bc,0x3ff7
	out (c),a
;48: pages DOS,5,2,0(7ffd)
        
        LD A,0b10101011 ;6912
	ld bc,0xff77 ;shadow ports off, palette off
        out (c),a
	ld sp,0x6000
	ei
hobetarunner_jp=$+1
	jp 0x6000
        ent
hobetarunner_sz=$-washobetarunner

wordfiles
        db "1234567890 files ";,0
wordbytes
        db "1234567890 bytes ",0
emptypath=$-1
        ;db 0

filinfo
        ds FILINFO_sz
        
        include "nvsort.asm"
        include "heapsort.asm"

        include "nvjptbl.asm"
        include "nvunit.asm"
        include "nveditln.asm"
        include "nvview.asm"
        include "nvhexed.asm"
        include "nvfind.asm"

        include "prdword.asm"
        include "cmdpr.asm"
        include "../_sdk/stdio.asm"

        align 256
searchbuf
SEARCHBUF_SZ=128 ;2 таких
file_buf
dir_buf
        ds 128
file_buf_end=$-1
dir2_buf
        ds 128        

        align 256
HS_strpg
        ds 256;DIRPAGES*2+2 ;по 1 байту на маркеры "0"
        align 256
textpages
        ds 256
twinto866
        incbin "../_sdk/codepage/winto866"
cmd_end

	display "nv size ",/d,cmd_end-cmd_begin," bytes"

	savebin "nv.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "../../us/user.l"
