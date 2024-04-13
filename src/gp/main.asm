	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

NUM_PLAYERS = 5
SFN_SIZE = 13
FILE_DATA_SIZE = 52 ;keep in sync with getfiledataoffset
FILE_DISPLAY_INFO_OFFSET = 0
FILE_DISPLAY_INFO_SIZE = 38
FILE_NAME_OFFSET = FILE_DISPLAY_INFO_OFFSET+FILE_DISPLAY_INFO_SIZE
FILE_NAME_SIZE = SFN_SIZE
FILE_ATTRIB_OFFSET = FILE_NAME_OFFSET+FILE_NAME_SIZE
FILE_ATTRIB_SIZE = 1
BROWSER_FILE_COUNT=168
PLAYLIST_FILE_COUNT=40
PANELCOLOR = 0x4f
CURSORCOLOR = 0x28
PANELFILECOLOR = 0x0f
PANELDIRCOLOR = 0x4f
PANELDRIVECOLOR = 0x4b
FILE_LINE_COUNT = 22
FILES_WINDOW_X = 0
FILE_ATTRIB_MUSIC = 255
FILE_ATTRIB_PARENT_DIR = 0
FILE_ATTRIB_DRIVE = 1
FILE_ATTRIB_FOLDER = 2
PLAYLIST_VERSION = 1

	org PROGSTART

mainbegin
	ld sp,0x4000
	OS_HIDEFROMPARENT
	ld e,6 ;textmode
	OS_SETGFX
	ld e,7
	OS_CLS

	OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
	ld (gpsettings.sharedpages),hl
	ld a,e
	ld (gpsettings.sharedpages+2),a
	ld d,b
	call closeexistingplayer

	ld de,currentfolder
	OS_GETPATH
	ld hl,(currentfolder+2)
	ld a,l
	xor '/'
	or h
	jr nz,$+5
	ld (currentfolder+2),a

	OS_SETSYSDRV
	call loadsettings
	call detectmoonsound
	call loadplayers
	jp nz,printerrorandexit

	ld ix,browserpanel
	call clearpanel
	ld ix,playlistpanel
	call clearpanel
	or 255 ;set zf=0
	call setcurrentpanel

	ld de,defaultplaylistfilename
	call loadplaylist

	ld hl,COMMANDLINE
	call skipword_hl
	call skipspaces_hl
	ld a,(hl)
	or a
	call nz,setcurrentfolder
	push hl
	call changetocurrentfolder
	pop de
	ld hl,chdirfailedstr
	jp nz,printerrorandexit
	push de
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

playloop
isplaying=$+1
	ld a,0
	or a
	jr z,checkmsgs
	call musicplay
	call z,playnextfile
	call updateprogressbar

checkmsgs
	ld a,(COMMANDLINE)
	or a
	ld a,key_esc
	jr z,closeplayer
	OS_GETKEY
	call tolower
closeplayer
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

mainmsgtable
	db (mainmsghandlers_end-mainmsghandlers_start)/3
mainmsghandlers_start
	db 0             : dw nokey
	db key_redraw    : dw redraw
	db key_up        : dw goprevfile
	db key_down      : dw gonextfile
	db key_enter     : dw startplaying
	db key_esc       : dw exitplayer
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
mainmsghandlers_end

playmsgtable
	db (playmsghandlers_end-playmsghandlers_start)/3
playmsghandlers_start
	db key_redraw    : dw redraw
	db ' '	         : dw playnextfile
	db key_esc       : dw stopplaying
playmsghandlers_end

nokey
	YIELD
	ret

gotop
	ld ix,(currentpaneladdr)
	xor a
	ld (ix+PANEL.currentfileindex),a
	ld (ix+PANEL.firstfiletoshow),a
	jp drawcurrentpanelfilelist

clearplaylist
	ld ix,playlistpanel
	call clearpanel
	jp drawplaylistwindow

playnextfile
	ld ix,(currentpaneladdr)
	call setnextfileindex
	jp c,startplaying
	xor a
	ld (ix+PANEL.currentfileindex),a
	ld (ix+PANEL.firstfiletoshow),a
	ld hl,(currentpaneladdr)
	ld de,PANEL.fileslist+FILE_ATTRIB_OFFSET
	add hl,de
	ld e,FILE_DATA_SIZE
.wraploop
	ld a,(hl)
	cp FILE_ATTRIB_MUSIC
	jp z,startplaying
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
	cp FILE_ATTRIB_MUSIC
	ret nz
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
	pop hl
	call stopplaying
	ld hl,playerpages
	ld a,(playercount)
	ld b,a
playerdeinitloop
	push bc
	push hl
	ld a,(hl)
	SETPG4000
	call playerdeinit
	pop hl
	pop bc
	inc hl
	djnz playerdeinitloop
;save playlist
	ld a,255
	ld (playlistpanel.isinactive),a
	OS_SETSYSDRV
	ld de,defaultplaylistfilename
	call saveplaylist
	QUIT

saveplaylist
;de = filename
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
	jr z,changedrive
	cp FILE_ATTRIB_MUSIC
	ret nz
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
	ret nz
	call drawplayerwindow
.filext1=$+1
	ld bc,0
.filext2=$+1
	ld de,0
.filename=$+1
	ld hl,0
	call musicload
	jp nz,drawui
	ld hl,playmsgtable
	ld (currentmsgtable),hl
	ld a,1
	ld (isplaying),a
	call drawsongtitle
	jp drawprogress
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

getmusicprogress
;out: zf=0 and a=progress if progress is available, zf=1 and a=255 otherwise
	ld hl,(MUSICPROGRESSADDR)
	ld a,l
	or h
	ld a,255
	ret z
	ld a,(hl)
	ret

drawplayerwindow
	ld de,PANELCOLOR
	OS_SETCOLOR
	call getmusicprogress
	push af
	ld (musicprogress),a
	ld de,8*256+6
	ld bc,66*256+4
	ld a,8
	jr nz,$+10
	ld de,8*256+12
	ld bc,54*256+3
	ld a,14
	ld (playerwindowtitlepos),a
	ld (songtitlepos),a
	call drawwindow
	ld de,CURSORCOLOR
	OS_SETCOLOR
playerwindowtitlepos=$+1
	ld de,8*256+0
	OS_SETXY
	ld hl,playingstr
	call print_hl
	call drawsongtitle
	pop af
	ret z
	ld a,(isplaying)
	or a
	jp nz,drawprogress
	ld de,PANELDIRCOLOR
	OS_SETCOLOR
	ld de,11*256+36
	OS_SETXY
	ld hl,loadingstr
	jp print_hl

drawsongtitle
	ld de,PANELDIRCOLOR
	OS_SETCOLOR
songtitlepos=$+1
	ld de,10*256+0
	OS_SETXY
	ld hl,(MUSICTITLEADDR)
	ld a,l
	or h
	jp nz,print_hl
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

drawprogress
	ld a,(musicprogress)
	cp 255
	ret z
	ld de,11*256+8
	OS_SETXY
	ld a,(musicprogress)
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

updateprogressbar
	call getmusicprogress
	ret z
	ld d,a
	ld hl,musicprogress
	ld e,(hl)
	sub e
	ret z
	ld (hl),d
	push af
	ld hl,11*256+8
	ld d,0
	add hl,de
	ex de,hl
	OS_SETXY
	pop bc
.drawloop
	push bc
	ld a,178
	PRCHAR
	pop bc
	djnz .drawloop
	ret

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
	ld de,CURSORCOLOR
	ret z
	ld a,(ix+FILE_ATTRIB_OFFSET-FILE_DISPLAY_INFO_OFFSET)
	cp FILE_ATTRIB_MUSIC
	ld de,PANELFILECOLOR
	ret z
	cp FILE_ATTRIB_DRIVE
	ld de,PANELDRIVECOLOR
	ret z
;FILE_ATTRIB_PARENT_DIR or FILE_ATTRIB_FOLDER
	ld de,PANELDIRCOLOR
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
	ld de,PANELCOLOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X
	ld bc,FILE_DISPLAY_INFO_SIZE*256+FILE_LINE_COUNT
	call drawwindow
	ld de,CURSORCOLOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+2
	OS_SETXY
	ld hl,currentfolder
	call print_hl
	jp drawbrowserfileslist

drawplaylistwindow
	ld de,PANELCOLOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+FILE_DISPLAY_INFO_SIZE+2
	ld bc,FILE_DISPLAY_INFO_SIZE*256+FILE_LINE_COUNT
	call drawwindow
	ld de,CURSORCOLOR
	OS_SETCOLOR
	ld de,FILES_WINDOW_X+FILE_DISPLAY_INFO_SIZE+4
	OS_SETXY
	ld hl,playliststr
	call print_hl
	jr drawplaylistfileslist

redraw
	ld e,7
	OS_CLS
drawui
	call drawbrowserwindow
	call drawplaylistwindow
	ld de,0x7
	OS_SETCOLOR
	ld de,24*256+3
	OS_SETXY
	ld hl,hotkeystr
	call print_hl
	ld a,(isplaying)
	or a
	ret z
	jp drawplayerwindow

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
playersfilename
	db "gp/gp.plr",0
settingsfilename
	db "gp/gp.ini",0
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
chdirfailedstr
	db "Unable to change directory!",0
playliststr
	db "Playlist",0
playingstr
	db "Playing...",0
closingplayerstr
	db "Closing old player instance...\r\n",0
emptystr
	db 0
initializing1str
	db "Initializing ",0
initializing2str
	db "...",0
detectingmoonsoundstr
	db "Detecting MoonSound...",0
notfoundstr
	db "no device!\r\n",0
foundstr
	db "OK\r\n",0
rom001200
	db "Copyright"
loadingstr
	db "LOADING...",0
firmwareerrorstr
	db "firmware problem!\r\nPlease update ZXM-MoonSound firmware to revision 1.01\r\n"
	db "https://www.dropbox.com/s/1e0b2197emrhzos/zxm_moonsound01_frm0101.zip",0
hotkeystr
	db "Arrows=Navigate  Enter=Play  Tab=Panel  Space=Add/Remove  S=Save Playlist",0
drivedata
	db "E: - IDE Master p.1                   E:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "F: - IDE Master p.2                   F:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "M: - SD Z-controller                  M:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
	db "O: - USB ZX-NetUsb                    O:",0,0,0,0,0,0,0,0,0,0,0,FILE_ATTRIB_DRIVE
drivedataend

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
	ld hl,gpsettings
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
	ld de,plrend-plrbegin
	sub hl,de
	ld hl,invalidplayerfilestr
	ret nz
;load players from file
	xor a
	ld (playercount),a
	ld de,modend-modstart : ld hl,(gpsettings.usemoonmod) : call loadplayer
	ld de,mwmend-mwmstart : ld hl,(gpsettings.usemwm) : call loadplayer
	ld de,mp3end-mp3start : ld hl,(gpsettings.usemp3) : call loadplayer
	ld de,pt3end-pt3start : ld hl,(gpsettings.usept3) : call loadplayer
	ld de,vgmend-vgmstart : ld hl,(gpsettings.usevgm) : call loadplayer
	call closestream_file
	ld a,(playercount)
	dec a
	ld hl,noplayersloadedstr
	ret m
	xor a
	ret

detectmoonsound
	ld hl,detectingmoonsoundstr
	call print_hl
	call ismoonsoundpresent
	ld hl,notfoundstr
	jp nz,print_hl
	call opl4init
	ld bc,9
	ld d,0
	ld hl,0x1200
	ld ix,browserpanel
	call opl4readmemory
	ld b,9
	ld de,rom001200
	ld hl,gpsettings.moonsoundstatus
.cmploop
	ld a,(de)
	cp (ix)
	jr nz,.waveportsfailed
	inc de
	inc ix
	djnz .cmploop
	ld (hl),2
	ld hl,foundstr
	jp print_hl
.waveportsfailed
	ld (hl),1
	ld hl,firmwareerrorstr
	call print_hl
	ld hl,pressanykeystr
	call print_hl
	YIELDGETKEYLOOP
	ret

loadsettings
	ld de,settingsfilename
	call openstream_file
	or a
	ret nz
	ld de,browserpanel
	ld hl,0x4000
	call readstream_file
	ld de,browserpanel
	add hl,de
	ld (hl),0
	call closestream_file
	ld de,browserpanel
.parseloop
	ld bc,'='*256
	call findnextchar
	or a
	ret z
	cp b
	jr nz,.parseloop
	ld b,settingsvarcount
	ld hl,settingsvars
.varsearchloop
	ld a,(hl)
	inc hl
	cp c
	jr z,.foundvar
	inc hl
	inc hl
	djnz .varsearchloop
	jr .nextvar
.foundvar
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld (hl),e
	inc hl
	ld (hl),d
.nextvar
	ld b,0
	call findnextchar
	or a
	jr nz,.parseloop
	ret

findnextchar
;de = ptr
;b = character to search
;c = LRC
;output: de = ptr past character, c = updated LRC
	ld a,(de)
	inc de
	or a
	ret z
	cp "\n"
	ret z
	cp b
	ret z
	xor c
	ld c,a
	jr findnextchar

gpsettings GPSETTINGS

settingsvars
	db 0x19 : dw gpsettings.usemp3
	db 0x14 : dw gpsettings.usemwm
	db 0x74 : dw gpsettings.usept3
	db 0x1F : dw gpsettings.usevgm
	db 0x26 : dw gpsettings.usemoonmod
	db 0x7F : dw gpsettings.moonmoddefaultpanning
	db 0x7A : dw gpsettings.midiuartdelayoverride
settingsvarcount=($-settingsvars)/3

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

createfileslist
	ld de,emptystr
	OS_OPENDIR

	ld a,(gpsettings.sharedpages)
	SETPG8000
	ld a,(gpsettings.sharedpages+1)
	SETPGC000

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

	macro jumpindirect addr
	push hl
	ld hl,(addr)
	ex (sp),hl
	ret
	endm

playerinit      jumpindirect PLAYERINITPROCADDR
playerdeinit    jumpindirect PLAYERDEINITPROCADDR
musicload       jumpindirect MUSICLOADPROCADDR
musicunload     jumpindirect MUSICUNLOADPROCADDR
musicplay       jumpindirect MUSICPLAYPROCADDR
isfilesupported jumpindirect ISFILESUPPORTEDPROCADDR

	include "../_sdk/file.asm"
	include "common/radixsort.asm"
	include "common/opl4.asm"

trywritingfm1
	djnz $
	ld a,e
	out (MOON_REG1),a
	djnz $
	ld a,d
	out (MOON_DAT1),a
	ret

ismoonsoundpresent
;out: zf=1 if Moonsound is present, zf=0 if not
	switch_to_pcm_ports_c2_c3
;check for 255 as an early exit condition
	in a,(MOON_STAT)
	add a,1
	sbc a,a
	ret nz
;read the status second time, now expect all bits clear
	in a,(MOON_STAT)
	or a
	ret nz
;start timer
	ld de,0x8003
	call trywritingfm1
	ld de,0x4204
	call trywritingfm1
	ld d,0x80
	call trywritingfm1
;wait for the timer to finish
	YIELD
	YIELD
;check the timer flags
	in a,(MOON_STAT)
	cp 0xa0
	ret nz
;no kidding, there must be MoonSound in this system
	call opl4mute
	xor a
	ret

closeexistingplayer
;d = current pid
	ld e,1
.searchloop
	ld a,e
	cp d
	jr z,.nextprocess
	push de
	OS_GETAPPMAINPAGES ;d,e,h,l=pages in 0000,4000,8000,c000
	or a
	ld a,d
	pop de
	jr nz,.nextprocess
	push de
	SETPGC000
	ld hl,0xc000+COMMANDLINE
	ld de,0x8000
	ld bc,COMMANDLINE_sz
	ldir
	ld hl,0x8000
	call skipword_hl
	ld (hl),0
	ld hl,0x8000
	ld c,'/'
	call findlastchar ;out: de = after last slash or start
	call isplayer
	pop de
	jr z,.foundplayer
.nextprocess
	inc e
	ld a,e
	inc a
	jr nz,.searchloop
	ret
.foundplayer
	xor a
	ld (0xc000+COMMANDLINE),a
	push de
	ld hl,closingplayerstr
	call print_hl
	pop de
.waitloop
	push de
	YIELD
	YIELD
	YIELD
	YIELD
	OS_GETAPPMAINPAGES
	pop de
	or a
	jr z,.waitloop
	ret

isplayer
;de = command line file name
;out: zf=1 if gp, zf=0 otherwise
	ld a,(de)
	call tolower
	cp 'g'
	ret nz
	inc de
	ld a,(de)
	call tolower
	cp 'p'
	ret nz
	inc de
	ld a,(de)
	or a
	ret z
	cp '.'
	ret
mainend

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

playlistdatastart=$
playlistpanelversion ds 2
playlistpanel PANEL
	ds FILE_DATA_SIZE*(PLAYLIST_FILE_COUNT-1)
playlistdatasize=$-playlistdatastart

musicprogress ds 1
playercount ds 1

page0dataend = $

	assert page0dataend <= 0x3e00 ;reserve 512 bytes for stack

	savebin "gp.com",mainbegin,mainend-mainbegin

	org 0x0000

plrbegin
modstart
	incbin "moonmod.bin"
modend
mwmstart
	incbin "mwm.bin"
mwmend
mp3start
	incbin "mp3.bin"
mp3end
pt3start
	incbin "pt3.bin"
pt3end
vgmstart
	incbin "vgm.bin"
vgmend
plrend

	savebin "gp.plr",plrbegin,plrend-plrbegin
