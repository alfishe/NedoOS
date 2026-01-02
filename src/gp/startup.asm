; One-time initialization code, not retained after startup is complete.

	include "common/opl4.asm"
	include "common/opn.asm"
	include "common/opm.asm"
	include "common/opna.asm"

startup
	OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
	ld (gpsettings.sharedpages),hl
	ld a,e
	ld (gpsettings.sharedpages+2),a
	ld d,b
	call quitifanotherinstanceisrunning
	call turnturboon
	ld e,7
	OS_CLS
	ld de,COLOR_DEFAULT
	OS_SETCOLOR
	ld de,currentfolder
	OS_GETPATH
	ld hl,(currentfolder+2)
	ld a,l
	xor '/'
	or h
	jr nz,$+5
	ld (currentfolder+2),a
	OS_SETSYSDRV
	call loadandparsesettings
	call checkinifile
	call runsetup
	call detectcpuspeed
	call detectmoonsound
	call detecttfm
	call detectopm
	jp detectopna

runsetup
	ld a,(runplayersetup)
	or a
	ret z
;player setup
	ld hl,(gpsettings.mididevice)
	ld de,midioptions
	ld b,midioptioncount
	ld a,(hl)
	and 15
	call updateradiobuttons
	ld hl,(gpsettings.moddevice)
	ld de,modoptions
	ld b,modoptioncount
	ld a,(hl)
	and 15
	call updateradiobuttons
	ld hl,(bomgemoonsettings)
	ld de,bomgemoonoption
	ld a,(hl)
	and 1
	call updatecheckbox
	ld hl,(gpsettings.slowtfm)
	ld de,slowtfmoption
	ld a,(hl)
	and 1
	call updatecheckbox
	call redrawplayersetupui
	ld hl,playersetupmsgtable
	ld (currentmsgtable),hl
	call playloop
	ld de,COLOR_DEFAULT
	OS_SETCOLOR
	ld e,7
	OS_CLS
	ret

checkinifile
	ld hl,(inifileversionsettings)
	ld a,l
	or h
	jr z,.isoutdated
	ld a,(hl)
	cp '2'
	ret z
.isoutdated
	ld hl,builtininifile
	ld de,inifilebuffer
	ld bc,builtininifilesize
	ld (inifilesize),bc
	ldir
	xor a
	ld (de),a
	call parsesettings
	ld a,1
	ld (runplayersetup),a
	ret

playersetupmsgtable
	db (playersetupmsghandlers_end-playersetupmsghandlers_start)/3
playersetupmsghandlers_start
	db 0             : dw setupidle
	db key_redraw    : dw redrawplayersetupui
	db key_esc       : dw exitplayersetup
	db key_up        : dw goprevoption
	db key_down      : dw gonextoption
	db key_enter     : dw setoption
	db ' '	         : dw setoption
	db key_tab       : dw gonextfast
playersetupmsghandlers_end

setupidle
	YIELD
	ret

playersetupoptions
midioptions
	dw midioption1str : dw midioptionhandler : dw defaultdevicedescstr
	dw midioption2str : dw midioptionhandler : dw moonsounddescstr
	dw midioption3str : dw midioptionhandler : dw midioption3descstr
	dw midioption4str : dw midioptionhandler : dw midioption4descstr
	dw midioption5str : dw midioptionhandler : dw midioption5descstr
	dw midioption6str : dw midioptionhandler : dw midioption6descstr
midioptioncount=($-midioptions)/6
modoptions
	dw modoption1str : dw modoptionhandler : dw defaultdevicedescstr
	dw modoption2str : dw modoptionhandler : dw moonsounddescstr
	dw modoption3str : dw modoptionhandler : dw modoption3descstr
modoptioncount=($-modoptions)/6
bomgemoonoption
	dw bomgemoonoptionstr : dw bomgemoonhandler : dw bomgemoonoptiondescstr
slowtfmoption
	dw slowtfmoptionstr : dw slowtfmhandler : dw slowtfmoptiondescstr
playersetupoptioncount=($-playersetupoptions)/6

MIDI_DEVICE_WINDOW_X = 4
MIDI_DEVICE_WINDOW_Y = 3
MOD_DEVICE_WINDOW_X = 46
MOD_DEVICE_WINDOW_Y = 4
MISC_OPTION_WINDOW_X = 20
MISC_OPTION_WINDOW_Y = 13

playersetupui
	CUSTOMUISETCOLOR ,COLOR_DEFAULT
	CUSTOMUIPRINTTEXT ,30,0,settingsheaderstr
	CUSTOMUIPRINTTEXT ,15,24,setuphotkeysstr
	CUSTOMUISETCOLOR ,COLOR_PANEL
	CUSTOMUIDRAWWINDOW ,MIDI_DEVICE_WINDOW_X,MIDI_DEVICE_WINDOW_Y,30,6
	CUSTOMUIPRINTTEXT ,MIDI_DEVICE_WINDOW_X+2,MIDI_DEVICE_WINDOW_Y,mididevicestr
	CUSTOMUIDRAWWINDOW ,MOD_DEVICE_WINDOW_X,MOD_DEVICE_WINDOW_Y,24,3
	CUSTOMUIPRINTTEXT ,MOD_DEVICE_WINDOW_X+2,MOD_DEVICE_WINDOW_Y,moddevicestr
	CUSTOMUIDRAWWINDOW ,MOD_DEVICE_WINDOW_X,MOD_DEVICE_WINDOW_Y,24,3
	CUSTOMUIPRINTTEXT ,MOD_DEVICE_WINDOW_X+2,MOD_DEVICE_WINDOW_Y,moddevicestr
	CUSTOMUIDRAWWINDOW ,MISC_OPTION_WINDOW_X,MISC_OPTION_WINDOW_Y,34,2
	CUSTOMUIPRINTTEXT ,MISC_OPTION_WINDOW_X+2,MISC_OPTION_WINDOW_Y,miscoptionstr
	CUSTOMUIDRAWEND

midioption1str db MIDI_DEVICE_WINDOW_Y+1,MIDI_DEVICE_WINDOW_X+1,"[X] Auto Select Device        ",0
midioption2str db MIDI_DEVICE_WINDOW_Y+2,MIDI_DEVICE_WINDOW_X+1,"[ ] MoonSound (OPL4)          ",0
midioption3str db MIDI_DEVICE_WINDOW_Y+3,MIDI_DEVICE_WINDOW_X+1,"[ ] NeoGS (VS10x3 Synth)      ",0
midioption4str db MIDI_DEVICE_WINDOW_Y+4,MIDI_DEVICE_WINDOW_X+1,"[ ] UART AY1 (Multisound Old) ",0
midioption5str db MIDI_DEVICE_WINDOW_Y+5,MIDI_DEVICE_WINDOW_X+1,"[ ] UART AY2 (Multisound New) ",0
midioption6str db MIDI_DEVICE_WINDOW_Y+6,MIDI_DEVICE_WINDOW_X+1,"[ ] UART YM2608               ",0
modoption1str db MOD_DEVICE_WINDOW_Y+1,MOD_DEVICE_WINDOW_X+1,"[X] Auto Select Device  ",0
modoption2str db MOD_DEVICE_WINDOW_Y+2,MOD_DEVICE_WINDOW_X+1,"[ ] MoonSound (OPL4)    ",0
modoption3str db MOD_DEVICE_WINDOW_Y+3,MOD_DEVICE_WINDOW_X+1,"[ ] GeneralSound        ",0
bomgemoonoptionstr db MISC_OPTION_WINDOW_Y+1,MISC_OPTION_WINDOW_X+1,"[ ] OPL3-only Device (BomgeMoon)  ",0
slowtfmoptionstr   db MISC_OPTION_WINDOW_Y+2,MISC_OPTION_WINDOW_X+1,"[ ] Slow TurboSound-FM            ",0

settingsheaderstr db "GP v0.9.0 Settings",0
setuphotkeysstr db "ESC=Save&Continue  Space=Select  Up/Down=Nagivate",0
mididevicestr db "MIDI Device...",0
moddevicestr db "MOD Device...",0
miscoptionstr db "Misc...",0

moonsounddescstr db "Проигрывать через MoonSound.",0
defaultdevicedescstr db "Разрешает плееру использовать любое доступное устройство.",0
midioption3descstr db "Используйте если у вас обновлённая версия NeoGS c декодером VLSI VS10x3.",0
midioption4descstr db "Используйте если у вас MultiSound с прошивкой первой версии.",0
midioption5descstr db "Используйте если у вас MultiSound с последней ревизией прошивки.",0
midioption6descstr db "MIDI UART подключен через IOA YM2608.",0
modoption3descstr db "Проигрывать через прошивку GeneralSound/NeoGS.",0
bomgemoonoptiondescstr db "Включите, если у вас нет MoonSound, но есть карта с OPL3 чипом.",0
slowtfmoptiondescstr db "Включите, если ваш TurboSound-FM работает плохо или не работает.",0

activeoption db 0
inifileversionsettings dw 0
inifilesize dw 0

exitplayersetup
	pop hl
	ld de,settingsfilename
	call openstream_file
	or a
	jr z,.openedfile
	ld de,settingsfilename
	OS_CREATEHANDLE
	or a
	ret nz
	ld a,b
	ld (filehandle),a
.openedfile
	ld a,(filehandle)
	ld b,a
	ld de,inifilebuffer
	ld hl,(inifilesize)
	OS_WRITEHANDLE
	jp closestream_file

updatecheckbox
;hl = ini address
;de = option struct
;a = 0-1 value
	dec a
	ld c,a
	ld b,1
	ld a,'X'
	ld (updateradiobuttons.selectionsymbol),a
	ld a,'1'
	jr updateradiobuttons.updateoptions

updateradiobuttons
;hl = ini address
;de = option structs
;b = option count
;a = active option
	ld c,a
	ld a,254
	ld (.selectionsymbol),a
	ld a,'0'
.updateoptions
	ld (.basedigit),a
	ld a,h
	or l
	ret z
	ld a,c
.basedigit=$+1
	add a,'0'
	ld (hl),a
	ex de,hl
	inc c
.loop	ld e,(hl)
	inc hl
	ld d,(hl)
	inc de
	inc de
	inc de
	dec c
.selectionsymbol=$+1
	ld a,254
	jr z,$+4
	ld a,' '
	ld (de),a
	ld de,5
	add hl,de
	djnz .loop
	ret

midioptionhandler
	ld hl,(gpsettings.mididevice)
	ld de,midioptions
	ld b,midioptioncount
	ld a,(activeoption)
	sub (midioptions - playersetupoptions)/6
	call updateradiobuttons
	jp drawsetupoptions

modoptionhandler
	ld hl,(gpsettings.moddevice)
	ld de,modoptions
	ld b,modoptioncount
	ld a,(activeoption)
	sub (modoptions - playersetupoptions)/6
	call updateradiobuttons
	jp drawsetupoptions

bomgemoonhandler
	ld hl,(bomgemoonsettings)
	ld de,bomgemoonoption
	ld a,(hl)
	cpl
	and 1
	call updatecheckbox
	jp drawsetupoptions

slowtfmhandler
	ld hl,(gpsettings.slowtfm)
	ld de,slowtfmoption
	ld a,(hl)
	cpl
	and 1
	call updatecheckbox
	jp drawsetupoptions

getactiveoptionaddr
;hl=base addr
;output: hl=active option addr
	ld a,(activeoption)
	add a,a
	ld e,a
	add a,a
	add a,e
	ld e,a
	ld d,0
	add hl,de
	ret

setoption
	ld hl,playersetupoptions+2
	call getactiveoptionaddr
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jp (hl)

goprevoption
	ld a,(activeoption)
	dec a
	jp p,$+5
	ld a,playersetupoptioncount-1
	ld (activeoption),a
	jp drawsetupoptions

gonextoption
	ld a,(activeoption)
	inc a
	cp playersetupoptioncount
	jr c,$+3
	xor a
	ld (activeoption),a
	jp drawsetupoptions

gonextfast
	ld a,(activeoption)
	add a,3
	cp playersetupoptioncount
	jr c,$+3
	xor a
	ld (activeoption),a
	jp drawsetupoptions

optiondescbuffer equ playlistpanel

redrawplayersetupui
	ld e,7
	OS_CLS
	ld ix,playersetupui
	call drawcustomui
drawsetupoptions
	ld hl,playersetupoptions
	ld b,playersetupoptioncount
	ld c,0
.optionsloop
	push bc
	ld a,(activeoption)
	cp c
	ld de,COLOR_CURSOR
	jr z,$+5
	ld de,COLOR_PANEL_FILE
	push hl
	OS_SETCOLOR
	pop hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	push hl
	ex de,hl
	ld d,(hl)
	inc hl
	ld e,(hl)
	inc hl
	push hl
	OS_SETXY
	pop hl
	call print_hl
	pop hl
	ld de,5
	add hl,de
	pop bc
	inc c
	djnz .optionsloop
;print desc
	ld de,COLOR_DEFAULT
	OS_SETCOLOR
	ld de,0x1600
	OS_SETXY
	ld hl,playersetupoptions+4
	call getactiveoptionaddr
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
	ex de,hl
	ld c,0
	call findlastchar
	ld a,l
	sub e
	dec a
	ld c,a
	ld a,80
	sub c
	rra
	ld b,a
	ld de,optiondescbuffer
	ld a,' '
.fillloop1
	ld (de),a
	inc de
	djnz .fillloop1
	pop hl
	ldir
	ld a,(optiondescbuffer+80)%256
	sub e
	ld b,a
	ld a,' '
.fillloop2
	ld (de),a
	inc de
	djnz .fillloop2
	xor a
	ld (de),a
	ld hl,optiondescbuffer
	jp print_hl

loadandparsesettings
	ld de,settingsfilename
	call openstream_file
	or a
	ret nz
	ld de,inifilebuffer
	ld hl,0x4000
	call readstream_file
	ld (inifilesize),hl
	ld de,inifilebuffer
	add hl,de
	ld (hl),0
	call closestream_file
parsesettings
	ld de,inifilebuffer
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

settingsfilename
	db "gp/gp.ini",0

settingsvars
	db 0x19 : dw gpsettings.usemp3
	db 0x14 : dw gpsettings.usemwm
	db 0x74 : dw gpsettings.usept3
	db 0x1F : dw gpsettings.usevgm
	db 0x26 : dw gpsettings.usemoonmod
	db 0x7F : dw gpsettings.moonmoddefaultpanning
	db 0x7A : dw gpsettings.midiuartdelayoverride
	db 0x61 : dw bomgemoonsettings
	db 0x20 : dw gpsettings.usemoonmid
	db 0x11 : dw gpsettings.mididevice
	db 0x7E : dw gpsettings.moddevice
	db 0x32 : dw inifileversionsettings
	db 0x78 : dw gpsettings.slowtfm
settingsvarcount=($-settingsvars)/3

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

detectcpuspeed
	ld hl,detectingcpustr
	call print_hl
	call swapinterrupthandler ;avoid OS while benchmarking
	halt
	ld hl,0
	ld e,0
	xor a
	ld (.spincount),a
	ld a,33
	halt
;--> 42 t-states loop start
.loop	inc e
	jp nz,$+4
	inc hl
	nop
.spincount=$+1
	ld bc,0
	cp c
	jp nc,.loop
;<-- loop end
	push de
	push hl
	call swapinterrupthandler ;restore OS handler
	pop hl
	pop de
;hl = hle / 32
	sla e : adc hl,hl
	sla e : adc hl,hl
	sla e : adc hl,hl
	ld (gpsettings.framelength),hl
	ex de,hl
	ld hl,-MIN_FRAME_LENGTH_FPGA
	add hl,de
	ld hl,cpufpgastr
	jp c,print_hl
	ld hl,-MIN_FRAME_LENGTH_ZXEVO
	add hl,de
	ld hl,cpuevostr
	jp c,print_hl
	ld hl,cpuatmstr
	jp print_hl

swapinterrupthandler
	di
	ld hl,.store
	ld de,0x38
	ld b,3
.loop	ld a,(de)
	ld c,(hl)
	ld (hl),a
	ld a,c
	ld (de),a
	inc hl
	inc de
	djnz .loop
	ei
	ret
.store	jp lightweightinterrupthandler

lightweightinterrupthandler
	push af
	ld a,(detectcpuspeed.spincount)
	inc a
	ld (detectcpuspeed.spincount),a
	pop af
	ei
	ret

isbomgemoon
;output: zf=0 is BomgeMoon flag is set
	ld hl,(bomgemoonsettings)
	ld a,l
	or h
	ret z
	ld a,(hl)
	cp '0'
	ret

detectmoonsound
	ld hl,detectingmoonsoundstr
	call print_hl
	call ismoonsoundpresent
	ld hl,notfoundstr
	jp nz,print_hl
	call opl4init
	call isbomgemoon
	jr z,.detectwaveports
	ld hl,devicebomgemoon
	ld (devicelist.moonsoundstraddr),hl
	ld a,1
	ld (gpsettings.moonsoundstatus),a
	ld hl,bomgemoonstr
	jp print_hl
.detectwaveports
	ld bc,9
	ld d,0
	ld hl,0x1200
	ld ix,playlistpanel
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

detecttfm
	ld hl,detectingtfmstr
	call print_hl
	call turnturbooff
	call istfmpresent_notimer
	push af
	call turnturboon
	pop af
	ld hl,notfoundstr
	jp nz,print_hl
	ld a,1
	ld (gpsettings.tfmstatus),a
	ld hl,foundstr
	jp print_hl

trywritingopm
	dec a
	jr nz,$-1
	ld bc,OPM0_REG
	out (c),e
	ld bc,OPM1_REG
	out (c),e
	dec a
	jr nz,$-1
	ld bc,OPM0_DAT
	out (c),d
	ld bc,OPM1_DAT
	out (c),d
	ret

detectopm
	ld hl,detectingopmstr
	call print_hl
;check for non-zero as an early exit condition
	ld bc,OPM0_DAT
	in a,(c)
	or a
	ld hl,notfoundstr
	jp nz,print_hl
;start timer
	ld de,0xff12
	call trywritingopm
	ld de,0x2a14
	call trywritingopm
;wait for the timer to finish
	YIELD
	YIELD
;check the timer flags
	ld bc,OPM0_DAT
	in a,(c)
	cp 2
	ld hl,notfoundstr
	jp nz,print_hl
	ld bc,OPM1_DAT
	in a,(c)
	cp 2
	ld hl,founddualchipstr
	jr z,.hasdualopm
	call opmdisablechip1
	ld hl,foundstr
	ld a,1
.hasdualopm
	ld (gpsettings.opmstatus),a
	call print_hl
	jp opmstoptimers

trywritingopna1
	dec a
	jr nz,$-1
	ld bc,OPNA1_REG
	out (c),e
	dec a
	jr nz,$-1
	ld bc,OPNA1_DAT
	out (c),d
	ret

detectopna
	ld hl,detectingopnastr
	call print_hl
;check for non-zero as an early exit condition
	ld bc,OPNA1_REG
	in a,(c)
	or a
	ld hl,notfoundstr
	jp nz,print_hl
	ld de,0xff26
	call trywritingopna1
	ld de,0x2a27
	call trywritingopna1
;wait for the timer to finish
	YIELD
	YIELD
;check the timer flags
	ld bc,OPNA1_REG
	in a,(c)
	cp 2
	ld hl,notfoundstr
	jp nz,print_hl 
	ld a,1
	ld (gpsettings.opnastatus),a
	ld de,0x3027
	call trywritingopna1
	ld de,0x0027
	call trywritingopna1
	ld hl,foundstr
	jp print_hl

trywritingmoonsoundfm1
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
	ld de,0xff03
	call trywritingmoonsoundfm1
	ld de,0x4204
	call trywritingmoonsoundfm1
	ld d,0x80
	call trywritingmoonsoundfm1
;wait for the timer to finish
	YIELD
	YIELD
;check the timer flags
	in a,(MOON_STAT)
	cp 0xa0
	ret nz
;there must be MoonSound in this system
	call opl4stoptimers
	xor a
	ret

trywritingtfm1
	dec a
	jr nz,$-1
	ld bc,OPN_REG
	out (c),e
	dec a
	jr nz,$-1
	ld bc,OPN_DAT
	out (c),d
	ret

istfmpresent_notimer
	ld bc,OPN_REG
	ld a,%11111100
	out (c),a
	ld de,0xff00
	call trywritingtfm1
	YIELD
	YIELD
	ld bc,OPN_REG
	in a,(c)
	and 128
	ret

quitifanotherinstanceisrunning
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
	ld de,fullpathbuffer
	ld bc,COMMANDLINE_sz
	ldir
	ld hl,fullpathbuffer
	call skipword_hl
	ld (hl),0
	ld hl,fullpathbuffer
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
	ld hl,COMMANDLINE
	ld de,0xc000+COMMANDLINE
	ld bc,COMMANDLINE_sz
	ldir
	QUIT

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

detectingmoonsoundstr
	db "Detecting MoonSound...",0
detectingtfmstr
	db "Detecting TurboSound FM...",0
detectingopmstr
	db "Detecting YM2151...",0
detectingopnastr
	db "Detecting YM2608...",0
notfoundstr
	db "no device!\r\n",0
foundstr
	db "found!\r\n",0
bomgemoonstr
	db "OPL3\r\n",0
founddualchipstr
	db "dual!\r\n",0
detectingcpustr
	db "Running on...",0
cpufpgastr
	db "FPGA\r\n",0
cpuevostr
	db "ZX Evolution\r\n",0
cpuatmstr
	db "ATM\r\n",0
rom001200
	db "Copyright"
firmwareerrorstr
	db "firmware problem!\r\nPlease update ZXM-MoonSound firmware to revision 1.01\r\n"
	db "https://www.dropbox.com/s/1e0b2197emrhzos/zxm_moonsound01_frm0101.zip\r\n"
	db "Or enable the BomgeMoon option in the player's settings to skip OPL4 port detection.",0

builtininifile
	incbin "gp.ini"
builtininifilesize=$-builtininifile
