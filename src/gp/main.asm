	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

NUM_PLAYERS = 6
SFN_SIZE = 13
FILE_DATA_SIZE = 52 ;keep in sync with getfiledataoffset
FILE_DISPLAY_INFO_OFFSET = 0
FILE_DISPLAY_INFO_SIZE = 38
FILE_NAME_OFFSET = FILE_DISPLAY_INFO_OFFSET+FILE_DISPLAY_INFO_SIZE
FILE_NAME_SIZE = SFN_SIZE
FILE_ATTRIB_OFFSET = FILE_NAME_OFFSET+FILE_NAME_SIZE
FILE_ATTRIB_SIZE = 1
BROWSER_FILE_COUNT = 160
PLAYLIST_FILE_COUNT = 40
FILE_LINE_COUNT = 22
FILES_WINDOW_X = 0
FILE_ATTRIB_MUSIC = 255
FILE_ATTRIB_PARENT_DIR = 0
FILE_ATTRIB_DRIVE = 1
FILE_ATTRIB_FOLDER = 2
PLAYLIST_VERSION = 1
STARTUP_CODE_ADDR = 0x8000
STACK_ADDR = 0x4000

	org PROGSTART

mainbegin
	ld sp,STACK_ADDR
	OS_HIDEFROMPARENT
	jp startplayer

drawprogress
	ld a,(.pos)
	inc a
	ret z
.color=$+1
	ld de,COLOR_PANEL_DIR
	OS_SETCOLOR
.pos=$+1
	ld de,0x0b08
	OS_SETXY
.counteraddr=$+1
	ld hl,0
	ld a,(hl)
	ld (musicprogress),a
	ld c,a
	or a
	jr z,.drawremaining
	ld b,a
.drawdoneloop
	push bc
	ld a,178
	PRCHAR
	pop bc
	djnz .drawdoneloop
.drawremaining
	ld a,64
	sub c
	ret z
	ld b,a
.drawremainingloop
	push bc
	ld a,176
	PRCHAR
	pop bc
	djnz .drawremainingloop
	ret

drawprogressincremental
;out: a = number of ticks until the next draw
	ld a,(drawprogress.pos)
	inc a
	ret z
	ld hl,(drawprogress.counteraddr)
	ld d,(hl)
	ld hl,musicprogress
	ld e,(hl)
	ld a,d
	sub e
	ret z
	ld (hl),d
	push af
	ld a,e
	ld de,(drawprogress.pos)
	add e
	ld e,a
	OS_SETXY
	ld de,(drawprogress.color)
	OS_SETCOLOR
	pop bc
.drawloop
	push bc
	ld a,178
	PRCHAR
	pop bc
	djnz .drawloop
	ld a,30
	ret

drawprogresscallback
;out: zf=0 if ESC was pressed, zf=1 otherwise
.func=$+1
	call drawprogress
	ld hl,drawprogressincremental
	ld (.func),hl
	OS_GETKEY
	sub key_esc
	cp 1
	sbc a,a
	ret

startplayer
	ld hl,startupcode
	ld de,STARTUP_CODE_ADDR
	ld bc,startupcodesize
	ldir
	call startup
;load players from low memory
	call loadplayers
	jp nz,printerrorandexit
;	YIELDGETKEYLOOP
;init panels	
	ld ix,browserpanel
	call clearpanel
	ld ix,playlistpanel
	call clearpanel
	or 255 ;set zf=0
	call setcurrentpanel
	ld de,defaultplaylistfilename
	call loadplaylist
	ld hl,mainmsgtable
	ld (currentmsgtable),hl
	call processcommandline
playloop
isplaying=$+1
	ld a,0
	or a
	jr z,checkmsgs
	call musicplay
	call z,playnextfile
checkmsgs
	OS_GETKEY
	call tolower
	ld hl,playloop
	push hl
currentmsgtable=$+1
	ld hl,mainmsgtable
	ld de,3
	ld b,(hl)
	inc hl
checkmsgloop
	cp (hl)
	jr z,processmsg
	add hl,de
	djnz checkmsgloop
	ret

processmsg
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jp (hl)

printerrorandexit
	call print_hl
	ld hl,pressanykeystr
	call print_hl
	YIELDGETKEYLOOP
	QUIT

processcommandline
	ld hl,COMMANDLINE
	call skipword_hl
	call skipspaces_hl
	ld a,(hl)
	or a
	call nz,setcurrentfolder
	push hl
	call changetocurrentfolder
	call createfileslist
	pop de
	ld a,(de)
	or a
	call nz,findfile
	ld (browserpanel.currentfileindex),a
	push af
	call drawui
	pop af
	call c,startplaying
	ld hl,COMMANDLINE
	ld (hl),'g'
	inc hl
	ld (hl),'p'
	inc hl
	ld (hl),0
	ret

mainmsgtable
	db (mainmsghandlers_end-mainmsghandlers_start)/3
mainmsghandlers_start
	db 0             : dw mainidle
	db key_redraw    : dw redraw
	db key_up        : dw goprevfile
	db key_down      : dw gonextfile
	db key_enter     : dw startplaying
	db key_esc       : dw confirmplayerexit
	db ' '	         : dw addtoplaylist
	db key_tab       : dw switchpanels
	db key_backspace : dw clearplaylist
	db key_home      : dw gotop
	db key_end       : dw golastfile
	db key_left      : dw gopageup
	db key_right     : dw gopagedown
	db key_pgup      : dw gopageup
	db key_pgdown    : dw gopagedown
	db 's'           : dw onhotkeyS
	db 'o'           : dw onhotkeyO
mainmsghandlers_end

playmsgtable
	db (playmsghandlers_end-playmsghandlers_start)/3
playmsghandlers_start
	db 0             : dw playnokeypressed
	db key_redraw    : dw redraw
	db ' '	         : dw playnextfile
	db key_esc       : dw stopplaying
playmsghandlers_end

mainidle
	YIELD
	YIELD
	YIELD
	YIELD
	ld a,(COMMANDLINE+2)
	or a
	ret z
gotcommandline
	call turnturboon
	or 255 ;set zf=0
	call setcurrentpanel
	jp processcommandline

playnokeypressed
.progressupdatecounter=$+1
	ld a,0
	dec a
	call z,drawprogressincremental
	ld (.progressupdatecounter),a
.playtimeupdatecounter=$+1
	ld a,1
	dec a
	call z,drawplaytimeincremental
	ld (.playtimeupdatecounter),a
	ld a,(COMMANDLINE+2)
	or a
	ret z
	call stopplaying
	jr gotcommandline

gotop	ld ix,(currentpaneladdr)
	xor a
	ld (ix+PANEL.currentfileindex),a
	ld (ix+PANEL.firstfiletoshow),a
	jp drawcurrentpanelfilelist

markplaylistdirty
	ld a,255
	ld (playlistchanged),a
	ret

clearplaylist
	call markplaylistdirty
	ld ix,playlistpanel
	call clearpanel
	jp drawplaylistwindow

setnextfileindexandwrap
	ld ix,(currentpaneladdr)
	call setnextfileindex
	ret c
	ld (ix+PANEL.currentfileindex),0
	ld (ix+PANEL.firstfiletoshow),0
	ret

playnextfile
	call setnextfileindexandwrap
	jp c,startplaying
	ld hl,(currentpaneladdr)
	ld de,PANEL.fileslist+FILE_ATTRIB_OFFSET
	add hl,de
	ld e,FILE_DATA_SIZE
.wraploop
	ld a,(hl)
	or a ;FILE_ATTRIB_MUSIC_
	jp m,startplaying
	add hl,de
	inc (ix+PANEL.currentfileindex)
	jr .wraploop

switchpanels
	ld a,(browserpanel.isinactive)
	or a
setcurrentpanel
	ld a,255
	ld (browserpanel.isinactive),a
	ld (playlistpanel.isinactive),a
	call nz,getbrowserpanelparams
	call z,getplaylistpanelparams
	ld (currentpaneladdr),ix
	ld (currentpanelpos),de
	ld (ix+PANEL.isinactive),0
	call drawbrowserfileslist
	jp drawplaylistfileslist

addtoplaylist
	call markplaylistdirty
	ld a,(browserpanel.isinactive)
	or a
	jr nz,removefromplaylist
	ld hl,currentfolder
	ld de,fullpathbuffer
	call strcopy_hltode
	ld a,'/'
	ld (de),a
	inc de
	push de
	ld a,(browserpanel.currentfileindex)
	call getfiledataoffset
	ld de,browserpanel.fileslist+FILE_ATTRIB_OFFSET
	add hl,de
	ld a,(hl)
	ld de,FILE_NAME_OFFSET-FILE_ATTRIB_OFFSET
	add hl,de
	pop de
	or a ;FILE_ATTRIB_MUSIC_
	ret p
	call strcopy_hltode
	ld hl,fullpathbuffer+FILE_DATA_SIZE-2
	sub hl,de
	ret c
	jr z,skippadding
	ld bc,hl
	ld hl,de
	inc de
	ldir
	dec de
skippadding
	inc de
	ld a,255
	ld (de),a
	ld hl,playlistpanel.filecount
	ld a,(hl)
	cp PLAYLIST_FILE_COUNT
	ret nc
	inc (hl)
	call getfiledataoffset
	ld de,playlistpanel.fileslist
	add hl,de
	ex de,hl
	ld hl,fullpathbuffer
	ld bc,FILE_DATA_SIZE
	ldir
	jp drawplaylistfileslist

removefromplaylist
	ld a,(playlistpanel.filecount)
	or a
	ret z
	dec a
	jp z,clearplaylist
	ld (playlistpanel.filecount),a
	ld b,a
	ld a,(playlistpanel.currentfileindex)
	cp b
	jr nz,.movetail
	dec a
	ld (playlistpanel.currentfileindex),a
	jp drawplaylistwindow
.movetail
	call getfiledataoffset
	ld de,playlistpanel.fileslist
	add hl,de
	ex de,hl
	ld hl,playlistpanel.fileslist+FILE_DATA_SIZE*(PLAYLIST_FILE_COUNT-1)
	sub hl,de
	ld bc,hl
	ld hl,FILE_DATA_SIZE
	add hl,de
	ldir
	jp drawplaylistwindow

exitplayer
	call unloadplayers
	QUIT

confirmplayerexit
	OS_SETSYSDRV
	call savedefaultplaylist
	call changetocurrentfolder
	ld hl,confirmexitmsgtable
	ld (currentmsgtable),hl
	ld hl,confirmexitui
	ld (drawdialog.uiaddr),hl
	jp drawdialog

cancelplayerexit
	ld hl,mainmsgtable
	ld (currentmsgtable),hl
	ld hl,0
	ld (drawdialog.uiaddr),hl
	jp drawui

confirmexitmsgtable
	db (confirmexitmsghandlers_end-confirmexitmsghandlers_start)/3
confirmexitmsghandlers_start
	db 0             : dw mainidle
	db key_redraw    : dw redraw
	db 'y'	         : dw exitplayer
	db 'n'	         : dw cancelplayerexit
	db key_esc       : dw cancelplayerexit
confirmexitmsghandlers_end

CONFIRM_EXIT_WINDOW_X = 17
CONFIRM_EXIT_WINDOW_Y = 8

confirmexittext1str db "Нажмите RSHIFT+ENTER, чтобы свернуть плеер",0
confirmexittext2str db "и вернуться к нему без долгого перезапуска.",0
confirmexittext3str db "Exit the player instead? (Y/N)",0

confirmexitui
	CUSTOMUISETCOLOR ,40
	CUSTOMUIDRAWWINDOW ,CONFIRM_EXIT_WINDOW_X,CONFIRM_EXIT_WINDOW_Y,45,6
	CUSTOMUIPRINTTEXT ,CONFIRM_EXIT_WINDOW_X+2,CONFIRM_EXIT_WINDOW_Y+2,confirmexittext1str
	CUSTOMUIPRINTTEXT ,CONFIRM_EXIT_WINDOW_X+2,CONFIRM_EXIT_WINDOW_Y+3,confirmexittext2str
	CUSTOMUIPRINTTEXT ,CONFIRM_EXIT_WINDOW_X+8,CONFIRM_EXIT_WINDOW_Y+5,confirmexittext3str
	CUSTOMUISETCOLOR
	CUSTOMUISEPARATOR ,CONFIRM_EXIT_WINDOW_X+1,CONFIRM_EXIT_WINDOW_Y+8,45,196,196,196
	CUSTOMUIVERTICALLINE ,CONFIRM_EXIT_WINDOW_X+47,CONFIRM_EXIT_WINDOW_Y+1,7
	CUSTOMUIDRAWEND

hotkeystartstr db 205,205,205,205,205,0
spacing7str db 205,205,205,205,205,205,205,0
hotkeyendstr db 205,205,205,205,188,0
optionshotkey1str db "O" ,0
optionshotkey2str db "ptions",0
playhotkey1str db " Enter ",0
playhotkey2str db "Play",0
addremovehotkey1str db " Space ",0
addremovehotkey2str db "Add/Remove",0
saveplaylisthotkey1str db "S",0
saveplaylisthotkey2str db "ave Playlist",0

hotkeybarui
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,0,24,hotkeystartstr
	CUSTOMUISETCOLOR ,COLOR_CURSOR
	CUSTOMUIPRINTTEXT ,255,255,optionshotkey1str
	CUSTOMUISETCOLOR ,COLOR_PANEL_DIR
	CUSTOMUIPRINTTEXT ,255,255,optionshotkey2str
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,255,255,spacing7str
	CUSTOMUISETCOLOR ,COLOR_CURSOR
	CUSTOMUIPRINTTEXT ,255,255,playhotkey1str
	CUSTOMUISETCOLOR ,COLOR_PANEL_DIR
	CUSTOMUIPRINTTEXT ,255,255,playhotkey2str
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,255,255,spacing7str
	CUSTOMUISETCOLOR ,COLOR_CURSOR
	CUSTOMUIPRINTTEXT ,255,255,addremovehotkey1str
	CUSTOMUISETCOLOR ,COLOR_PANEL_DIR
	CUSTOMUIPRINTTEXT ,255,255,addremovehotkey2str
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,255,255,spacing7str
	CUSTOMUISETCOLOR ,COLOR_CURSOR
	CUSTOMUIPRINTTEXT ,255,255,saveplaylisthotkey1str
	CUSTOMUISETCOLOR ,COLOR_PANEL_DIR
	CUSTOMUIPRINTTEXT ,255,255,saveplaylisthotkey2str
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,255,255,hotkeyendstr
	CUSTOMUIDRAWEND

drawdialog
.uiaddr=$+2
	ld ix,0
	ld a,ixh
	or ixl
	ret z
	jp drawcustomui

unloadplayers
	ld hl,playerpages
	ld a,(playercount)
	ld b,a
playerdeinitloop
	push bc
	push hl
	ld a,(hl)
	ld (.playerpage),a
	SETPG4000
	call playerdeinit
.playerpage=$+1
	ld e,0
	OS_DELPAGE
	pop hl
	pop bc
	inc hl
	djnz playerdeinitloop
	ret

savedefaultplaylist
playlistchanged=$+1
	ld a,0
	or a
	ret z
	xor a
	ld (playlistchanged),a
	ld de,defaultplaylistfilename
saveplaylist
;de = filename
	ld a,255
	ld (playlistpanel.isinactive),a
	push de
	call openstream_file
	pop de
	or a
	jr z,.openedfile
	OS_CREATEHANDLE
	or a
	ret nz
	ld a,b
	ld (filehandle),a
.openedfile
	ld a,(filehandle)
	ld b,a
	ld de,playlistdatastart
	ld hl,playlistdatasize
	OS_WRITEHANDLE
	call closestream_file
	xor a
	ret

onhotkeyS
	ld de,playlistfilename
	call saveplaylist
	ld de,playlistfilename
	jp createfilelistandchangesel

onhotkeyO
	call setsharedpages
	ld hl,runoptionsode
	ld de,STARTUP_CODE_ADDR
	ld bc,runoptionsodesize
	ldir
	jp runoptions

startplaying
	call stopplaying
	ld ix,(currentpaneladdr)
	ld a,(ix+PANEL.filecount)
	or a
	ret z
	ld a,(ix+PANEL.currentfileindex)
	call getfiledataoffset
	ld a,ixl
	add PANEL.fileslist+FILE_ATTRIB_OFFSET
	ld e,a
	adc a,ixh
	sub e
	ld d,a
	add hl,de
	ld a,(hl)
	cp FILE_ATTRIB_PARENT_DIR
	jp z,changetoparentdir
	cp FILE_ATTRIB_FOLDER
	jp z,changetofolder
	cp FILE_ATTRIB_DRIVE
	jp z,changedrive
	or a ;FILE_ATTRIB_MUSIC_
	ret p
	ld a,(browserpanel.isinactive)
	or a
	ld de,FILE_NAME_OFFSET-FILE_ATTRIB_OFFSET
	jr z,$+5
	ld de,FILE_DISPLAY_INFO_OFFSET-FILE_ATTRIB_OFFSET
	add hl,de
	ld (.filename),hl
	call getfileextension
	ld (.filext2),de
	ld (.filext1),bc
	call isfileplaylist
	jp z,.loadplaylist
	call findsupportedplayer
	jp nz,drawerrorwindow
	ld hl,0
	ld (devicemask),hl
	ld (ERRORSTRINGADDR),hl
	call drawplayer
	ld hl,drawprogress
	ld (drawprogresscallback.func),hl
.filext1=$+1
	ld bc,0
.filext2=$+1
	ld de,0
.filename=$+1
	ld hl,0
	call musicload
	jp nz,drawerrorwindow
	ld (devicemask),hl
	ld hl,playmsgtable
	ld (currentmsgtable),hl
;init timer
	OS_GETTIMER
	ld (getplaytimestring.starttime),hl
	ld hl,playtimestr
	ld b,6
	ld (hl),0
	inc hl
	djnz $-3
;skip drawplayerwindow and redraw the rest of player UI
	ld a,1
	ld (isplaying),a
	ld a,0xc9 ;ret opcode
	ld (drawplayerwindow),a
	call drawplayer
	xor a
	ld (drawplayerwindow),a
	ret
.loadplaylist
	ld de,(.filename)
	call loadplaylist
	call drawplaylistwindow
	xor a
	call setcurrentpanel
	jp startplaying

changedrive
	ld de,FILE_NAME_OFFSET-FILE_ATTRIB_OFFSET
	add hl,de
	push hl
	ld de,(currentfolder)
	push de
	ld de,currentfolder
	ldi
	ldi
	call changetocurrentfolder
	pop hl
	pop de
	jp z,createfilelistandchangesel
	ld (currentfolder),hl
	ret

changetoparentdir
	ld hl,currentfolder
	ld c,'/'
	call findlastchar ;out: de = after last slash or start
	push de
	dec de
	xor a
	ld (de),a
	call changetocurrentfolder
	pop de
	jp createfilelistandchangesel

createfilelistandchangesel
;de = selection filename
	push de
	call createfileslist
	pop de
	call findfile
	ld (browserpanel.currentfileindex),a
	sub FILE_LINE_COUNT-1
	jp c,drawbrowserwindow
	ld hl,browserpanel.firstfiletoshow
	cp (hl)
	jp c,drawbrowserwindow
	ld (hl),a
	jp drawbrowserwindow

changetofolder
	ld de,FILE_NAME_OFFSET-FILE_ATTRIB_OFFSET
	add hl,de
	ld de,currentfolder-1
.findzeroloop
	inc de
	ld a,(de)
	or a
	jr nz,.findzeroloop
	ld a,'/'
	ld (de),a
	inc de
	call strcopy_hltode
	call changetocurrentfolder
	call createfileslist
	xor a
	ld (browserpanel.currentfileindex),a
	jp drawbrowserwindow

stopplaying
	ld a,(isplaying)
	or a
	ret z
	call musicunload
	ld hl,mainmsgtable
	ld (currentmsgtable),hl
	xor a
	ld (isplaying),a
	jp drawui

setnextfileindex
;ix = current panel
;out: cf=0 if at the end of file list, c1=1 otherwise
	ld a,(ix+PANEL.currentfileindex)
	inc a
	cp (ix+PANEL.filecount)
	ret nc
	ld (ix+PANEL.currentfileindex),a
	sub FILE_LINE_COUNT-1
	ret c
	cp (ix+PANEL.firstfiletoshow)
	ret c
	ld (ix+PANEL.firstfiletoshow),a
	scf
	ret

golastfile
	ld ix,(currentpaneladdr)
	call setnextfileindex
	jr c,$-3
	jp drawcurrentpanelfilelist

gopagedown	
	ld ix,(currentpaneladdr)
	ld b,FILE_LINE_COUNT
	call setnextfileindex
	djnz $-3
	jp drawcurrentpanelfilelist

gonextfile
	ld ix,(currentpaneladdr)
	call setnextfileindex
	ret nc
	jp drawcurrentpanelfilelist

setprevfileindex
;ix = current panel
	ld a,(ix+PANEL.currentfileindex)
	or a
	ret z
	dec a
	ld (ix+PANEL.currentfileindex),a
	cp (ix+PANEL.firstfiletoshow)
	ret nc
	ld (ix+PANEL.firstfiletoshow),a
	ret

goprevfile
	ld ix,(currentpaneladdr)
	call setprevfileindex
	jp drawcurrentpanelfilelist

gopageup
	ld ix,(currentpaneladdr)
	ld b,FILE_LINE_COUNT
	call setprevfileindex
	djnz $-3
	jp drawcurrentpanelfilelist

loadplaylist
;de = filename
	call markplaylistdirty
	call openstream_file
	or a
	jr nz,initemptyplaylist
	ld de,playlistdatastart
	ld hl,playlistdatasize
	call readstream_file
	call closestream_file
	ld de,PLAYLIST_VERSION
	ld hl,(playlistpanelversion)
	sub hl,de
	ret z
initemptyplaylist
	ld hl,PLAYLIST_VERSION
	ld (playlistpanelversion),hl
	ld ix,playlistpanel
	jr clearpanel

clearpanel
;ix = panel
	xor a
	ld (ix+PANEL.filecount),a
	ld (ix+PANEL.currentfileindex),a
	ld (ix+PANEL.firstfiletoshow),a
	ret

changetocurrentfolder
;out: zf=1 if succeeded, zf=0 otherwise
	ld hl,(currentfolder+2)
	push hl
	ld a,l
	or a
	jr nz,$+8
	ld hl,'/'
	ld (currentfolder+2),hl
	ld de,currentfolder
	OS_CHDIR
	pop hl
	ld (currentfolder+2),hl
	or a
	ret

setcurrentfolder
;out: hl = file name only
	push hl
	ld c,'/'
	call findlastchar ;out: de = after last slash or start
	pop bc
	ld hl,de
	sub hl,bc
	ex hl,de
	ret z
;copy file path
	ld hl,bc
	ld bc,de
	ld de,currentfolder
	ldir
	dec de
	xor a
	ld (de),a
	ret

findfile
;de = file name
;out: a = file index, cf=1 if file was found
	ld a,(browserpanel.filecount)
	or a
	ret z
	ld b,a
	ld c,0
	ld hl,browserpanel.fileslist+FILE_NAME_OFFSET
.searchloop
	push bc
	push de
	push hl
	call stricmp
	pop hl
	ld de,FILE_DATA_SIZE
	add hl,de
	pop de
	pop bc
	scf
	ld a,c
	ret z
	inc c
	djnz .searchloop
	xor a
	ret

stricmp
;hl = string1 addr
;de = string2 addr
;out: zf=1 if equal
	ld a,(hl)
	call tolower
	ld c,a
	ld a,(de)
	call tolower
	ld b,a
	or c
	ret z
	ld a,b
	cp c
	ret nz
	cp 1
	ret c
	inc hl
	inc de
	jr stricmp

drawerrorwindow
;show the error if esc was pressed to avoid infinitely looping through unplayable files
	OS_GETKEY
	cp key_esc
	jr z,.drawwindow
;don't display errors in playlist mode and just skip to the next file silently
	ld a,(browserpanel.isinactive)
	or a
	jr z,.drawwindow
	call setnextfileindexandwrap
	call drawui
	jp startplaying
.drawwindow
	ld de,COLOR_ERROR_WINDOW
	OS_SETCOLOR
	ld hl,(ERRORSTRINGADDR)
	ld a,l
	or h
	jp z,drawui; got no text to print!
	bit 7,h
	jr nz,errorcustomui
	ld b,1
.strlenloop
	ld a,(hl)
	inc hl
	inc b
	or a
	jr nz,.strlenloop
	ld c,3
	ld de,10*256+16
	call drawwindow
	ld de,10*256+18
	OS_SETXY
	ld hl,errorwindowheaderstr
	call print_hl
	ld de,12*256+18
	OS_SETXY
	ld hl,(ERRORSTRINGADDR)
	call print_hl
	YIELDGETKEYLOOP
	jp drawui
errorcustomui
	res 7,h
	push hl
	pop ix
	call drawcustomui
	YIELDGETKEYLOOP
	jp drawui

drawplayerwindow
	nop
	ld a,(.pos)
	inc a
	ret z
	ld de,COLOR_PANEL
	OS_SETCOLOR
.pos=$+1
	ld de,0x0806
.size=$+1
	ld bc,0x4204
	jp drawwindow

getplaytimestring
;de = string buffer
	push de
	OS_GETTIMER
.starttime=$+1
	ld de,0
	sub hl,de
	pop de
	ld bc,-VSYNC_FREQ*60
	call .writefield ;minutes
	ld a,':'
	ld (de),a
	inc de
	ld bc,-VSYNC_FREQ
	call .writefield ;seconds
	xor a
	ld (de),a
	ret
.writefield
	ld a,255
	inc a
	add hl,bc
	jr c,$-2
	sbc hl,bc
	ld bc,0x2ff6 ;b='0'-1, c=-10
	inc b
	add a,c
	jr c,$-2
	ex de,hl
	ld (hl),b
	ex de,hl
	inc de
	add a,'0'+10
	ld (de),a
	inc de
	ret

drawplaytime
	ld a,(.pos)
	inc a
	ret z
	ld de,playtimestr
	call getplaytimestring
.pos=$+1
	ld de,0x0d43
	OS_SETXY
.color=$+1
	ld de,COLOR_CURSOR
	OS_SETCOLOR
	ld hl,playtimestr
	jp print_hl

drawplaytimeincremental
;out: a = number of ticks until the next draw
	ld a,(drawplaytime.pos)
	inc a
	ret z
	ld de,currentplaytimestr
	call getplaytimestring
	ld hl,playtimestr
	ld de,currentplaytimestr
	ld bc,0x0500
.diffsearchloop
	ld a,(de)
	cp (hl)
	jr nz,.difffound
	inc de
	inc hl
	inc c
	djnz .diffsearchloop
	ld a,VSYNC_FREQ/2
	ret
.difffound
	push hl
	ex de,hl
	call strcopy_hltode
	ld de,(drawplaytime.pos)
	ld a,e
	add a,c
	ld e,a
	OS_SETXY
	ld de,(drawplaytime.color)
	OS_SETCOLOR
	pop hl
	call print_hl
	ld a,VSYNC_FREQ/2
	ret

drawsongtitle
	ld a,(.pos)
	inc a
	ret z
	ld de,COLOR_PANEL_DIR
	OS_SETCOLOR
.pos=$+1
	ld de,0x0a08
	OS_SETXY
.straddr=$+1
	ld hl,0
	ld a,l
	or h
	jr z,.usefilename
	ld a,(hl)
	or a
	jp nz,print_hl
.usefilename
	ld ix,(currentpaneladdr)
	ld a,(ix+PANEL.currentfileindex)
	call getfiledataoffset
	ld a,ixl
	add PANEL.fileslist+FILE_DISPLAY_INFO_OFFSET
	ld e,a
	adc a,ixh
	sub e
	ld d,a
	add hl,de
	jp print_hl

drawplayerwindowtitle
	ld a,(.pos)
	inc a
	ret z
	ld de,COLOR_CURSOR
	OS_SETCOLOR
.pos=$+1
	ld de,0x0808
	OS_SETXY
devicemask=$+1
	ld bc,0
	ld a,b
	or c
	ld hl,(PLAYERNAMESTRADDR)
	jp z,print_hl
	ld hl,playingstr
	ld de,filinfo
	call strcopy_hltode
	ld hl,devicelist
	ld ixl,15
.loop	bit 0,c
	jr z,.skip
	bit 7,b
	jr z,.noseparator
	push hl
	ld hl,deviceseparatorstr
	call strcopy_hltode
	pop hl
.noseparator
	push hl
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	call strcopy_hltode
	pop hl
	set 7,b
.skip	inc hl
	inc hl
	sra bc
	dec ixl
	jr nz,.loop
	ld hl,playing1str
	call strcopy_hltode
	ld hl,filinfo
	jp print_hl

drawwindowline
;d = left char
;e = right char
;c = middle char
;b = middle char count
	ld a,d
	push de
	push bc
	PRCHAR
	pop bc
.drawloop
	push bc
	ld a,c
	PRCHAR
	pop bc
	djnz .drawloop
	pop de
	ld a,e
	PRCHAR
	ret

drawwindow
;e = left coord
;d = top coord
;b = client area width
;c = client area height
;top line
	push de
	push bc
	OS_SETXY
	pop bc
	push bc
	ld de,0xc9bb
	ld c,0xcd
	call drawwindowline
	pop bc
	pop de
	inc d
;client area
.drawloop
	push de
	push bc
	OS_SETXY
	pop bc
	push bc
	ld de,0xbaba
	ld c,0x20
	call drawwindowline
	pop bc
	pop de
	inc d
	dec c
	jr nz,.drawloop
;bottom line
	push bc
	OS_SETXY
	pop bc
	ld de,0xc8bc
	ld c,0xcd
	jp drawwindowline

getfiledataoffset
;a = index
;out: hl = index * FILE_DATA_SIZE
	ld l,a
	ld h,0
	ld de,hl
	add hl,hl
	add hl,hl
	ex de,hl
	add hl,de
	ex de,hl
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	ret

getfileinfocolor
;c = file index
;hl = file data address
currentfileindex=$+1
	ld a,0
	cp c
	ld de,COLOR_CURSOR
	ret z
	ld a,(ix+FILE_ATTRIB_OFFSET-FILE_DISPLAY_INFO_OFFSET)
	or a ;FILE_ATTRIB_MUSIC_
	ld de,COLOR_PANEL_FILE
	ret m
	cp FILE_ATTRIB_DRIVE
	ld de,COLOR_PANEL_DRIVE
	ret z
;FILE_ATTRIB_PARENT_DIR or FILE_ATTRIB_FOLDER
	ld de,COLOR_PANEL_DIR
	ret

printfilesinfos
;ix = struct PANEL
;e = left coord
;d = top coord
;b = line count
;c = first file index
	ld a,(ix+PANEL.currentfileindex)
	or (ix+PANEL.isinactive)
	ld (currentfileindex),a
	ld a,(ix+PANEL.filecount)
	ld (.currentfilecount),a
	push de
	ld a,c
	call getfiledataoffset
	ld de,ix
	add hl,de
	ld de,FILE_DISPLAY_INFO_OFFSET+PANEL.fileslist
	add hl,de
	pop de
.filesloop
	ld a,c
.currentfilecount=$+1
	cp 0
	ret nc
	push de
	push hl
	push bc
	OS_SETXY
	pop bc
	pop ix
	push bc
	push ix
	call getfileinfocolor
	OS_SETCOLOR
	pop hl
	pop bc
	push bc
	ld b,FILE_DISPLAY_INFO_SIZE
.printdisplaystringloop
	push bc
	push hl
	ld a,(hl)
	or a
	jr nz,$+4
	ld a,' '
	PRCHAR
	pop hl
	pop bc
	inc hl
	djnz .printdisplaystringloop
	ld de,FILE_DATA_SIZE-FILE_DISPLAY_INFO_SIZE
	add hl,de
	pop bc
	pop de
	inc c
	inc d
	djnz .filesloop
	ret

getbrowserpanelparams
	ld ix,browserpanel
	ld de,256+1+FILES_WINDOW_X
	ret

drawbrowserfileslist
	call getbrowserpanelparams
	ld b,FILE_LINE_COUNT
	ld c,(ix+PANEL.firstfiletoshow)
	jp printfilesinfos

getplaylistpanelparams
	ld ix,playlistpanel
	ld de,256+FILE_DISPLAY_INFO_SIZE+3+FILES_WINDOW_X
	ret

drawplaylistfileslist
	call getplaylistpanelparams
	ld b,FILE_LINE_COUNT
	ld c,(ix+PANEL.firstfiletoshow)
	jp printfilesinfos

drawcurrentpanelfilelist
currentpaneladdr=$+2
	ld ix,0
currentpanelpos=$+1
	ld de,0
	ld b,FILE_LINE_COUNT
	ld c,(ix+PANEL.firstfiletoshow)
	jp printfilesinfos

drawbrowserwindow
	ld de,COLOR_PANEL
	OS_SETCOLOR
	ld de,FILES_WINDOW_X
	ld bc,FILE_DISPLAY_INFO_SIZE*256+FILE_LINE_COUNT
	call drawwindow
	ld de,COLOR_CURSOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+2
	OS_SETXY
	ld hl,currentfolder
	call print_hl
	jp drawbrowserfileslist

drawplaylistwindow
	ld de,COLOR_PANEL
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+FILE_DISPLAY_INFO_SIZE+2
	ld bc,FILE_DISPLAY_INFO_SIZE*256+FILE_LINE_COUNT
	call drawwindow
	ld de,COLOR_CURSOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+FILE_DISPLAY_INFO_SIZE+4
	OS_SETXY
	ld hl,playliststr
	call print_hl
	jr drawplaylistfileslist

redraw	ld e,7
	OS_CLS
drawui	call drawbrowserwindow
	call drawplaylistwindow
	call drawdialog
	ld ix,hotkeybarui
	call drawcustomui
	ld a,(isplaying)
	or a
	ret z
	jp drawplayer

drawplayer
	ld ix,(CUSTOMUIADDR)
	ld a,ixh
	or ixl
	ret z
drawcustomui
;ix = commands
.drawloop
	ld a,(ix)
	cp CUSTOM_UI_CMD_COUNT
	ret nc
	ld (.commandsizeoffset),a
	ld b,a
	add a,a
	add a,b
	ld (.commandtable),a
	push ix
	ld hl,.finalizecmd
	push hl
.commandtable=$+1
	jr $
	jp .drawwindow
	jp .printtext
	jp .setcolor
	jp .playerwindow
	jp .playerwindowtitle
	jp .playtime
	jp .playprogress
	jp .songtitle
	jp .separator
	jp .verticalline
.finalizecmd
	pop ix
.commandsizeoffset=$+1
	ld de,0
	ld hl,.commandsize
	add hl,de
	ld e,(hl)
	add ix,de
	jp .drawloop
.commandsize
	db CUSTOMUIDRAWWINDOW
	db CUSTOMUIPRINTTEXT
	db CUSTOMUISETCOLOR
	db CUSTOMUIPLAYERWINDOW
	db CUSTOMUIPLAYERWINDOWTITLE
	db CUSTOMUIPLAYTIME
	db CUSTOMUIPLAYPROGRESS
	db CUSTOMUISONGTITLE
	db CUSTOMUISEPARATOR
	db CUSTOMUIVERTICALLINE
.drawwindow
	ld e,(ix+CUSTOMUIDRAWWINDOW.topleftx)
	ld d,(ix+CUSTOMUIDRAWWINDOW.toplefty)
	ld b,(ix+CUSTOMUIDRAWWINDOW.clientwidth)
	ld c,(ix+CUSTOMUIDRAWWINDOW.clientheight)
	jp drawwindow
.printtext
	ld e,(ix+CUSTOMUIPRINTTEXT.posx)
	ld d,(ix+CUSTOMUIPRINTTEXT.posy)
	ld hl,1
	add hl,de
	ld hl,(ix+CUSTOMUIPRINTTEXT.straddr)
	jp c,print_hl
	push hl
	OS_SETXY
	pop hl
	jp print_hl
.setcolor
	ld e,(ix+CUSTOMUISETCOLOR.color)
	ld d,0
	OS_SETCOLOR
	ret
.playerwindow
	ld l,(ix+CUSTOMUIPLAYERWINDOW.topleftx)
	ld h,(ix+CUSTOMUIPLAYERWINDOW.toplefty)
	ld (drawplayerwindow.pos),hl
	ld h,(ix+CUSTOMUIPLAYERWINDOW.clientwidth)
	ld l,(ix+CUSTOMUIPLAYERWINDOW.clientheight)
	ld (drawplayerwindow.size),hl
	jp drawplayerwindow
.playerwindowtitle
	ld l,(ix+CUSTOMUIPLAYERWINDOWTITLE.posx)
	ld h,(ix+CUSTOMUIPLAYERWINDOWTITLE.posy)
	ld (drawplayerwindowtitle.pos),hl
	jp drawplayerwindowtitle
.playtime
	ld l,(ix+CUSTOMUIPLAYTIME.posx)
	ld h,(ix+CUSTOMUIPLAYTIME.posy)
	ld (drawplaytime.pos),hl
	ld hl,(ix+CUSTOMUIPLAYTIME.color)
	ld (drawplaytime.color),hl
	ld a,1
	ld (playnokeypressed.playtimeupdatecounter),a
	ld a,(isplaying)
	or a
	ret z
	jp drawplaytime
.playprogress
	ld e,(ix+CUSTOMUIPLAYPROGRESS.posx)
	ld d,(ix+CUSTOMUIPLAYPROGRESS.posy)
	ld (drawprogress.pos),de
	ld hl,(ix+CUSTOMUIPLAYPROGRESS.counteraddr)
	ld (drawprogress.counteraddr),hl
	ld hl,(ix+CUSTOMUIPLAYPROGRESS.color)
	ld (drawprogress.color),hl
	ld a,1
	ld (playnokeypressed.progressupdatecounter),a
	inc e
	ret z
	ld a,(isplaying)
	or a
	jp nz,drawprogress
	ld a,e
	add a,27
	ld e,a
	OS_SETXY
	ld de,COLOR_PANEL_DIR
	OS_SETCOLOR
	ld hl,loadingstr
	jp print_hl
.songtitle
	ld l,(ix+CUSTOMUISONGTITLE.posx)
	ld h,(ix+CUSTOMUISONGTITLE.posy)
	ld (drawsongtitle.pos),hl
	ld hl,(ix+CUSTOMUISONGTITLE.straddr)
	ld (drawsongtitle.straddr),hl
	jp drawsongtitle
.separator
	ld l,(ix+CUSTOMUISEPARATOR.rightchar)
	ld h,(ix+CUSTOMUISEPARATOR.leftchar)
	ld e,(ix+CUSTOMUISEPARATOR.posx)
	ld d,(ix+CUSTOMUISEPARATOR.posy)
	ld b,(ix+CUSTOMUISEPARATOR.middlecharcount)
	ld c,(ix+CUSTOMUISEPARATOR.middlechar)
	push bc
	push hl
	OS_SETXY
	pop de
	pop bc
	jp drawwindowline
.verticalline
	ld e,(ix+CUSTOMUIVERTICALLINE.posx)
	ld d,(ix+CUSTOMUIVERTICALLINE.posy)
	ld b,(ix+CUSTOMUIVERTICALLINE.height)
	ld a,(ix+CUSTOMUIVERTICALLINE.linechar)
.linedrawloop
	push bc
	push de
	OS_SETXY
.linechar=$+1
	ld a,0
	PRCHAR
	pop de
	pop bc
	inc d
	djnz .linedrawloop
	ret

skipword_hl
	ld a,(hl)
	or a
	ret z
	cp ' '
	ret z
	inc hl
	jr skipword_hl

skipspaces_hl
	ld a,(hl)
	cp ' '
	ret nz
	inc hl
	jr skipspaces_hl

print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR
	pop hl
	inc hl
	jp print_hl

strcopy_hltode
	ld a,(hl)
	ld (de),a
	or a
	ret z
	inc hl
	inc de
	jr strcopy_hltode

;c = character
;hl = poi to filename in string
;out: de = after last char or start
findlastchar
	ld d,h
	ld e,l ;de = after last char
findlastchar0
	ld a,(hl)
	inc hl
	or a
	ret z
	cp c
	jr nz,findlastchar0
	jr findlastchar

tolower
	cp 'A'
	ret c
	cp 'Z'+1
	ret nc
	add 32
	ret

pressanykeystr
	db "\r\nPress any key to continue...\r\n",0
mainfilename
	db "gp.com",0
playersfilename
	db "gp/gp.plr",0
defaultplaylistfilename
	db "gp/"
playlistfilename
	db "playlist.gpl",0
invalidplayerfilestr
	db "Corrupted gp/gp.plr file!",0
noplayersloadedstr
	db "Unable to load any players!",0
playersloaderrorstr
	db "Failed to load gp/gp.plr from OS folder!",0
initializing1str
	db "Initializing ",0
initializing2str
	db "...",0
chdirfailedstr
	db "Unable to change directory!",0
playliststr
	db "Playlist",0
playingstr
	db "Playing on ",0
playing1str
	db "...",0
deviceseparatorstr
	db " and ",0
emptystr
	db 0
loadingstr
	db "LOADING...",0
errorwindowheaderstr
	db "Error",0
drivedata
	db "E: - IDE Master p.1                   E:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "F: - IDE Master p.2                   F:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "M: - SD Z-controller                  M:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "O: - USB ZX-NetUsb                    O:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
drivedataend

deviceay
	db "AY8910",0
deviceturbosound
	db "TurboSound",0
devicetfm
	db "TurboSound-FM",0
devicemoonsound
	db "MoonSound",0
devicebomgemoon
	db "BomgeMoon",0
devicegs
	db "GeneralSound",0
deviceneogs
	db "NeoGS",0
devicemidiuart
	db "MIDI UART",0
deviceopm
	db "YM2151",0
devicedualopm
	db "Dual-YM2151",0
deviceopna
	db "YM2608",0
devicelist
	dw deviceay
	dw deviceturbosound
	dw devicetfm
.moonsoundstraddr
	dw devicemoonsound
	dw devicegs
	dw deviceneogs
	dw devicemidiuart
	dw deviceopm
	dw devicedualopm
	dw deviceopna

loadplayer
;de = code size
;hl = settings variable addr
	ld (.codesize),de
	ld a,h
	or l
	ld a,'1' ;default for Use<Player> variable is 1
	jr z,$+3
	ld a,(hl)
	ld (.settingsvalue),a
	OS_NEWPAGE
	or a
	ret nz
	ld a,e
	ld (.playerpage),a
	SETPG4000
	call setsharedpages
	ld de,0x4000
.codesize=$+1
	ld hl,0
	call readstream_file
.settingsvalue=$+1
	ld a,0
	cp '0'
	jr z,.cleanup
	ld hl,initializing1str
	call print_hl
	ld hl,(PLAYERNAMESTRADDR)
	call print_hl
	ld hl,initializing2str
	call print_hl
	ld ix,gpsettings
	ld a,(.playerpage)
	call playerinit
	push af
	call print_hl
	pop af
	jr nz,.cleanup
	ld hl,playercount
	ld e,(hl)
	inc (hl)
	ld d,0
	ld hl,playerpages
	add hl,de
.playerpage=$+1
	ld (hl),0
	ret
.cleanup
	ld a,(.playerpage)
	ld e,a
	OS_DELPAGE
	ret

loadplayers
;output: zf=1 if success, zf=0 and hl=error message if failed
	ld de,playersfilename
	call openstream_file
	or a
	ld hl,playersloaderrorstr
	ret nz
;check if the file matches this build
	ld a,(filehandle)
	ld b,a
	OS_GETFILESIZE
	ld bc,plrfilesize%65536
	sub hl,bc
	ld hl,invalidplayerfilestr
	ret nz
	ld hl,plrfilesize/65536
	sbc hl,de
	ld hl,invalidplayerfilestr
	ret nz
;load players from file
	xor a
	ld (playercount),a
	ld de,modplrsize : ld hl,(gpsettings.usemoonmod) : call loadplayer
	ld de,mwmplrsize : ld hl,(gpsettings.usemwm) : call loadplayer
	ld de,mp3plrsize : ld hl,(gpsettings.usemp3) : call loadplayer	
	ld de,moonmidsize : ld hl,(gpsettings.usemoonmid) : call loadplayer
	ld de,pt3plrsize : ld hl,(gpsettings.usept3) : call loadplayer
	ld de,vgmplrsize : ld hl,(gpsettings.usevgm) : call loadplayer
	call closestream_file
	ld a,(playercount)
	dec a
	ld hl,noplayersloadedstr
	ret m
	xor a
	ret

gpsettings GPSETTINGS drawprogresscallback,drawcustomui
bomgemoonsettings dw 0
runplayersetup db 0

getfileextension
;hl = file name
;out: cde = file extension
	ld c,'.'
	call findlastchar ;out: de = after last dot or start
	ex de,hl
	ld a,(hl)
	call tolower
	ld c,a
	inc hl
	ld a,(hl)
	call tolower
	ld d,a
	inc hl
	ld a,(hl)
	call tolower
	ld e,a
	ret

isfileplaylist
;cde = file extension
;out: zf=1 if playlist, zf=0 otherwise
	ld a,c
	cp 'g'
	ret nz
	ld a,d
	cp 'p'
	ret nz
	ld a,e
	cp 'l'
	ret

findsupportedplayer
;cde = file extension
	ld hl,playerpages
	ld a,(playercount)
	ld b,a
.findplayerloop
	push hl
	push bc
	ld a,(hl)
	SETPG4000
	pop bc
	call isfilesupported
	pop hl
	ret z
	inc hl
	djnz .findplayerloop
	dec b ;set zf=0
	ret

setsharedpages
	ld a,(gpsettings.sharedpages+1)
	SETPG8000
	ld a,(gpsettings.sharedpages)
	SETPGC000
	ret

createfileslist
	ld de,emptystr
	OS_OPENDIR
	call setsharedpages
	xor a
	ld (browserpanel.currentfileindex),a
	ld (browserpanel.firstfiletoshow),a
	ld hl,currentfolder+2
	cp (hl)
	ld hl,0x8000
	jr nz,.startloop
	ex de,hl
	ld hl,drivedata
	ld bc,drivedataend-drivedata
	ldir
	ex de,hl
	ld a,(drivedataend-drivedata)/FILE_DATA_SIZE
.startloop
	ld (browserpanel.filecount),a
.fileenumloop
	ld (.filedataaddr),hl
.skiptonextfile
	ld de,filinfo
	OS_READDIR
	or a
	jp nz,.sortfiles
;skip '.' folder
	ld hl,(filinfo+FILINFO_FNAME)
	ld a,l
	xor '.'
	or h
	jr z,.skiptonextfile
;skip findsupportedplayer for folders
	ld a,(filinfo+FILINFO_FATTRIB)
	and FATTRIB_DIR
	jr nz,.foundfileordir
	ld hl,filinfo+FILINFO_FNAME
	call getfileextension
	call isfileplaylist
	jr z,.foundfileordir
	call findsupportedplayer
	jr nz,.skiptonextfile
;we've got either a playable file or a folder
.foundfileordir
.filedataaddr=$+1
	ld de,0
	ld hl,FILE_NAME_OFFSET
	add hl,de
	ex de,hl
	ld hl,filinfo+FILINFO_FNAME
	ld bc,9*256+SFN_SIZE
.copysfnloop
	ld a,(hl)
	cp '.'
	jr z,.foundsfnext
	or a
	jr z,.sfntailloop
	call tolower
	ld (de),a
	inc hl
	inc de
	dec c
	dec b
	jr .copysfnloop
;this is a folder, pad it to SFN_SIZE with zeros
.sfntailloop
	ld (de),a
	inc de
	dec c
	jr nz,.sfntailloop
	jr .donesfncopy
;format SFN as 8.3 fixed-position array padding with '*' if necessary
;this is needed for sorting
.foundsfnext
	ld a,'*'
.sfntailloop1
	ld (de),a
	inc de
	djnz .sfntailloop1
	dec de
;copy dot, extension, zero terminator
	ld b,5
.sfntailloop2
	ld a,(hl)
	call tolower
	ld (de),a
	inc hl
	inc de
	djnz .sfntailloop2
.donesfncopy
;fill display name
	ld hl,FILE_DISPLAY_INFO_OFFSET-FILE_NAME_OFFSET-SFN_SIZE
	add hl,de
	ex de,hl
	ld hl,filinfo+FILINFO_LNAME
	ld a,(hl)
	or a
	jr nz,$+5
	ld hl,filinfo+FILINFO_FNAME
	ld bc,(FILE_DISPLAY_INFO_SIZE-1)*256+255
.copylfnloop
	ldi
	dec b
	jr z,.lfncopydone
	ld a,(hl)
	or a
	jr nz,.copylfnloop
.filltailloop
	ld (de),a
	inc de
	djnz .filltailloop
.lfncopydone
	xor a
	ld (de),a
;set atrribute data
	call getfileattrib
	ld hl,FILE_ATTRIB_OFFSET-FILE_DISPLAY_INFO_OFFSET-FILE_DISPLAY_INFO_SIZE+1
	add hl,de
	ld (hl),a
	ld de,FILE_DATA_SIZE-FILE_ATTRIB_OFFSET
	add hl,de
;check if we have space for more files
	ld a,(browserpanel.filecount)
	inc a
	ld (browserpanel.filecount),a
	cp BROWSER_FILE_COUNT
	jp c,.fileenumloop
.sortfiles
	ld a,(browserpanel.filecount)
	or a
	ret z
	ld c,a
	ld b,0
	ld a,12
	ld ix,fileextsortkeyoffsets
	ld hl,0x8000
	ld de,FILE_DATA_SIZE
	ld iy,browserpanel.fileslist
	call radixsort
;remove '*' padding restoring SFN to original null-terminated string form
	ld a,(browserpanel.filecount)
	ld b,a
	ld hl,browserpanel.fileslist+FILE_NAME_OFFSET
.removepaddingnextfile
	ld de,hl
	push hl
.removepaddingloop
	ld a,(hl)
	inc hl
	cp '*'
	jr z,.removepaddingloop
	ld (de),a
	inc de
	or a
	jr nz,.removepaddingloop
	pop hl
	ld de,FILE_DATA_SIZE
	add hl,de
	djnz .removepaddingnextfile
	ret

getfileattrib
;out: a = attribute value
	ld a,(filinfo+FILINFO_FATTRIB)
	and FATTRIB_DIR
	ld a,FILE_ATTRIB_MUSIC
	ret z
	ld hl,(filinfo+FILINFO_FNAME)
	ld bc,'..'
	sub hl,bc
	ld a,FILE_ATTRIB_PARENT_DIR
	ret z
	ld a,FILE_ATTRIB_FOLDER
	ret

fileextsortkeyoffsets
	dw FILE_NAME_OFFSET+7, FILE_NAME_OFFSET+6, FILE_NAME_OFFSET+5
	dw FILE_NAME_OFFSET+4, FILE_NAME_OFFSET+3, FILE_NAME_OFFSET+2
	dw FILE_NAME_OFFSET+1, FILE_NAME_OFFSET+0
	dw FILE_NAME_OFFSET+11, FILE_NAME_OFFSET+10, FILE_NAME_OFFSET+9
	dw FILE_ATTRIB_OFFSET

playerinit      = PLAYERINITPROCADDR - 1
playerdeinit    = PLAYERDEINITPROCADDR - 1
musicload       = MUSICLOADPROCADDR - 1
musicunload     = MUSICUNLOADPROCADDR - 1
musicplay       = MUSICPLAYPROCADDR - 1
isfilesupported = ISFILESUPPORTEDPROCADDR - 1

	include "../_sdk/file.asm"
	include "common/radixsort.asm"
	include "common/turbo.asm"

runoptionsode
	disp STARTUP_CODE_ADDR
runoptions
	OS_SETSYSDRV
	ld de,mainfilename
	OS_OPENHANDLE
	or a
	jp nz,changetocurrentfolder
	push bc
	push bc
	call unloadplayers
	call savedefaultplaylist
	ld a,(gpsettings.sharedpages+2)
	SETPG4000
	ld de,currentfolder
	OS_CHDIR
	ld de,mainbegin
	ld hl,mainsize
	pop bc
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	ld a,1
	ld (runplayersetup),a
	ld sp,STACK_ADDR
	jp startplayer
	ent
runoptionsodesize=$-runoptionsode

tempmemorystart = $
startupcode
	disp STARTUP_CODE_ADDR
	include "startup.asm"
	ent
startupcodesize=$-startupcode
mainend
mainsize=mainend-mainbegin

;	display "gpsys = ",/d,startupcodesize," bytes"
	savebin "gp.com",mainbegin,mainsize

	org tempmemorystart
playerpages
	ds NUM_PLAYERS
filinfo
	ds FILINFO_sz
currentfolder
	ds MAXPATH_sz
fullpathbuffer
	ds MAXPATH_sz

	struct PANEL
filecount ds 1
currentfileindex ds 1
firstfiletoshow ds 1
isinactive ds 1
fileslist ds FILE_DATA_SIZE
	ends

browserpanel PANEL
	ds FILE_DATA_SIZE*(BROWSER_FILE_COUNT-1)
inifilebuffer equ browserpanel

playlistdatastart=$
playlistpanelversion ds 2
playlistpanel PANEL
	ds FILE_DATA_SIZE*(PLAYLIST_FILE_COUNT-1)
playlistdatasize=$-playlistdatastart

musicprogress ds 1
playercount ds 1
playtimestr ds 6
currentplaytimestr ds 6

	assert $ <= 0x3e00 ;reserve 512 bytes for stack
	assert startplayer <= SYSTEM_MEMORY_END

	org 0
modstart
	incbin "moonmod.bin"
modplrsize=$-modstart
mwmstart
	incbin "mwm.bin"
mwmplrsize=$-mwmstart
mp3start
	incbin "mp3.bin"
mp3plrsize=$-mp3start
moonmidstart
	incbin "moonmid.bin"
moonmidsize=$-moonmidstart
plrpart1size=$
	savebin "gp1.plr",0,plrpart1size

	org 0
pt3start
	incbin "pt3.bin"
pt3plrsize=$-pt3start
vgmstart
	incbin "vgm.bin"
vgmplrsize=$-vgmstart
plrpart2size=$

	savebin "gp2.plr",0,plrpart2size

plrfilesize=plrpart1size+plrpart2size
