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
	call detectcpuspeed
	call detectmoonsound
	call detecttfm
	call detectopm
	jp detectopna

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
	db 0x4C : dw gpsettings.forcemididevice
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
	in f,(c)
	ret m
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

closingplayerstr
	db "Closing old player instance...\r\n",0
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
	db "2x\r\n",0
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
	db "Or set BomgeMoon=1 in bin\\gp\\gp.ini to skip OPL4 ports detection.",0
