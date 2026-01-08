	DEVICE ZXSPECTRUM128
	include "gsports.asm"
	include "gscodedefs.asm"
	include "vs10xx.asm"

XTALI_FREQ = 14000000 ;14mhz on NGS
CLOCKF_VS1011 = 0x8000|((XTALI_FREQ+1000)/2000) ;28mhz
CLOCKF_VS1033 = ((XTALI_FREQ-8000000+2000)/4000)|SC_MULT_03_35X|SC_ADD_03_00X ;49mhz
CLOCKF_VS1053 = ((XTALI_FREQ-8000000+2000)/4000)|SC_MULT_53_40X|SC_ADD_53_00X ;56mhz

	MACRO WDC
;	in a,(SSTAT)
;	and M_MCRDY
;	jr z,$-4
;TODO: why MCRDY polling works fine on real hardware, but not in UnrealSpeccy?
;Neo Player Light does this
	call noper
	ENDM

	MACRO WDD
	in a,(SSTAT)
	rrca
	jr nc,$-3
	ENDM

	MACRO ATOZX
	out (ZXDATWR),a
	in a,(ZXSTAT)
	rlca
	jr c,$-3
	ENDM

	MACRO CALCFREEBUFFERSPACE
	ld a,h
	sub d
	and 0x7f
	ENDM

	MACRO LOAD256 IENABLED
.loadloop
	in a,(ZXSTAT)                         ;check if data or command is pending
	and M_CBIT|M_DBIT
	jr z,.loadloop
	rlca
	jr c,.loaddata
;got command
	IF IENABLED
	di
	ENDIF
	call processcommand
	IF IENABLED
	ei
	ENDIF
	jr .loadloop
.loaddata
	in a,(ZXDATRD)
	ld (de),a
	inc e
	jr nz,.loadloop
	inc d
	ENDM

	org GSPROGSTART
begin   di
	ld sp,GSSTACKADDR
	call checkifngs
;uploading is done via interrupt handler
	ld hl,interrupthandler
	ld (GSINTERRUPTTABLEENTRYADDR),hl
	ld a,GSINTERRUPTTABLEENTRYADDR>>8
	ld i,a
	im 2
	call mutemod
	ld a,%10011100
	out (SCTRL),a
;set ngs to 10mhz
	ld d,C_10MHZ
	call ngssetfreq
;hw decoder reset
	ld a,M_MPXRS
	out (SCTRL),a
	WDC
;clear reset signal
	ld a,M_MPXRS|M_SETNCLR
	out (SCTRL),a
;go to 12mhz
	ld d,C_12MHZ
	call ngssetfreq
;write to a register after reset
	ld l,SCI_VOL
	ld de,SV_SILENCE
	call vswriteregister
;read chip id
	ld l,SCI_STATUS
	call vsreadregister
	ld a,e
	and SS_VER_MASK
	ld (vsversion),a
;set an arbitrary writable page for the ring buffer in 0x8000...0xffff
	ld a,2
	out (MPAG),a
startnewstream
	call vssoftreset                      ;reset decoder setting SDI to compatibility mode
;start preloading
	ld a,255
	ld (streaminfobyte),a
	ld h,0x70
	ld de,0x8000                          ;de is ring buffer write pointer
preloadloop
	LOAD256 0
	ld a,d
	cp 0xdf
	jr c,preloadloop
;start uploading
	ld hl,0x8000                          ;hl is ring buffer read pointer
	ei
mainloop
	in a,(ZXSTAT)                         ;check if a command is pending
	rrca
	jr nc,.checkifcandownload
;handle command
	di
	call processcommand
	ei
	jr mainloop
.checkifcandownload
	CALCFREEBUFFERSPACE
	cp 3
	jr c,mainloop                         ;keep read and write addresses of the ring buffer at least 256 bytes apart
	LOAD256 1
	set 7,d
	jr mainloop

interrupthandler
	push af
	push bc
	ld a,d
	sub h
	and 0x7f
	cp 3
	jr c,.skipupload                      ;keep read and write addresses of the ring buffer at least 256 bytes apart
	in a,(SSTAT)
	rrca 
	jr nc,.skipupload                     ;update stream info if data is not requested
	ld b,32                               ;upload 32 bytes
.uploadloop
	ld a,(hl)
	out (MD_SEND),a
	inc hl
	djnz .uploadloop
	bit 7,h                               ;check if the address wrapped to 0x0000
	call z,updatestreaminfo
;blink LED
;	ld a,h
;	rlca
;	rlca
;	out (LEDCTR),a
.skipupload
	pop bc
	pop af
	ei
	ret

updatestreaminfo
	push hl
	push de
	ld l,SCI_HDAT1
	call vsreadregister
	push de
	ld l,SCI_HDAT0
	call vsreadregister
	pop bc
	ld a,b
	cp 255
	jr nz,.notmpeg
	ld a,d
	rrca
	rrca
	rrca
	rrca
	and %00001111
	ld b,a
	ld a,c
	rlca
	rlca
	rlca
	and %11110000
	or b
	add mp3bitratestringlookup%256
	ld l,a
	adc mp3bitratestringlookup/256
	sub l
	ld h,a
	ld a,e
	rrca
	and %01100000
	or (hl)
.setstreaminfo
	ld (streaminfobyte),a
	pop de
	pop hl
	set 7,h                               ;wrap the address to 0x8000
	ret
.notmpeg
	cp 'A'
	jr nz,.notaac
	ld a,c
	cp 'T'
	jr z,$+6
	cp 'D'
	jr nz,.unsupportedstream
	xor a
.getbitratestringindex
	ld hl,0x0380
	add hl,de
	rr h
	srl h
	ld l,h
	ld h,0
	ld de,bitratestringlookup
	add hl,de
	or (hl)
	jr .setstreaminfo
.notaac
	cp 'O'
	jr nz,.unsupportedstream
	ld a,c
	cp 'g'
	ld a,%01000000
	jr z,.getbitratestringindex
.unsupportedstream
	ld a,255
	jr .setstreaminfo

mp3bitratestringlookup
;lookup_index = (id<<6) | (layer<<4) | bitrate_index
	db 152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,131,133,134,135,136,137,138,139,140,141,142,143,144,145,152
	db 152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,131,133,134,135,136,137,138,139,140,141,142,143,144,145,152
	db 152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,128,129,130,131,132,133,134,135,136,137,138,139,140,141,152
	db 152,131,133,134,135,136,137,138,139,140,141,142,143,144,145,152
	db 152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152
	db 152,131,132,133,134,135,136,137,138,139,141,143,144,145,147,152
	db 152,131,133,134,135,136,137,138,139,141,143,144,145,147,149,152
	db 152,131,135,137,139,141,143,144,145,146,147,148,149,150,151,152

bitratestringlookup
;lookup_index = (HDAT0*8/1024 + 7)/8
	db 0,0,1,2,3,4,5,6
	db 7,8,8,9,9,10,10,11
	db 11,12,12,13,13,14,14,15
	db 15,16,16,16,16,17,17,17
	db 17,18,18,18,18,19,19,19
	db 19,20,20,20,20,21,21,21
	db 21,22,22,22,22,23,23,23
	db 23,23,23,23,23,23,23,23
	db 23

vssoftreset
	ld l,SCI_VOL
	ld de,SV_SILENCE
	call vswriteregister                  ;set volume to minimum
	ld l,SCI_MODE
	call vsreadregister
	ld a,e
	xor SM_RESET
	ld e,a
	ld a,d
	and ~(SM_SDINEW>>8)                   ;NGS implements compatibility mode only
	ld d,a
	call vswriteregister                  ;reset
	ld a,e
	xor SM_RESET
	ld e,a
	call vswriteregister                  ;clear reset
volumevalue=$+1
	ld de,0
	ld l,SCI_VOL
	call vswriteregister                  ;restore volume
	call vsclockvalue
	ld l,SCI_CLOCKF
	call vswriteregister                  ;set internal clock
vsversion=$+1
	ld a,255
	cp SS_VER_VS1001
	ret nz
	ld l,0x02                             ;Force the clock-doubler on by writing 0x8008 to SCI_INT_FCTLH.
	ld de,0x8008                          ;The datasheet states that you should never write to this register.
	jr vswriteregister                    ;This is, however, an exception.

;l = register
;de = value
vswriteregister
	WDD
	WDC
	ld a,M_MCNCS
	out (SCTRL),a                         ;SCI start
	WDC
	ld bc,MC_SEND
	ld a,2
	out (c),a                             ;write op
	WDC
	out (c),l                             ;which register
	WDC
	out (c),d                             ;high byte
	WDC
	out (c),e                             ;low byte
	WDC
	ld a,M_MCNCS|M_SETNCLR
	out (SCTRL),a                         ;SCI end
	WDC
	ret

;l = register
;out: de = value
vsreadregister
	WDD
	WDC
	ld a,M_MCNCS
	out (SCTRL),a                         ;SCI start
	WDC
	ld bc,MC_SEND
	ld a,3
	out (c),a                             ;read op
	WDC
	out (c),l                             ;which register
	WDC
	ld a,0xff
	out (c),a
	WDC
	ld bc,MC_READ
	in d,(c)                              ;high byte
	WDC
	ld a,0xff
	out (MC_SEND),a
	WDC
	in e,(c)                              ;low byte
	WDC
	ld a,M_MCNCS|M_SETNCLR
	out (SCTRL),a                         ;SCI end
	WDC
	ret

vsclockvalue
;out: de = CLOCKF value
	ld a,(vsversion)
	ld de,CLOCKF_VS1011
	cp SS_VER_VS1001
	ret z
	cp SS_VER_VS1002
	ret z
	cp SS_VER_VS1011
	ret z
	ld de,CLOCKF_VS1033
	cp SS_VER_VS1003
	ret z
	cp SS_VER_VS1033
	ret z
	ld de,CLOCKF_VS1053
	ret

ngssetfreq
;d = frequency constant
	in a,(GSCFG0)
	and %11001111
	or d
	out (GSCFG0),a
	ret

checkifngs
	in a,(GSCFG0)
	cp 255
	ret nz
.msgloop
	in a,(ZXSTAT)
	rrca
	call c,processcommand
	jr .msgloop

mutemod
	xor a
	out (VOL1),a
	out (VOL2),a
	out (VOL3),a
	out (VOL4),a
	out (VOL5),a
	out (VOL6),a
	out (VOL7),a
	out (VOL8),a
	ret

processcommand
	in a,(ZXCMD)
	cp CMDCOUNT
	jr nc,.cmdreset                       ;received an invalid command, so the player crashed?
	add a,a
	ld (.commandtable),a
	out (CLRCBIT),a
.commandtable=$+1
	jr $
	jr .cmdreset
	jr .cmdgetfreebufferspace
	jr .cmdgetchipid
	jr .cmdrestartstream
	jr .cmdvolumeup
	jr .cmdvolumedown
	jr .cmdgetstreaminfo
.cmdreset
	ld a,(vsversion)
	inc a
	jp z,0
	call vssoftreset
	ld d,C_20MHZ
	call ngssetfreq
	jp 0
.cmdgetfreebufferspace
	CALCFREEBUFFERSPACE
	ATOZX
	ret
.cmdgetchipid
	ld a,(vsversion)
	ATOZX
	ret
.cmdrestartstream
	ld sp,GSSTACKADDR
	jp startnewstream
.cmdvolumeup
	ld a,(volumevalue)
	or a
	ret z
	dec a
.setvolume
	push hl
	push de
	push bc
	ld e,a
	ld d,a
	ld (volumevalue),de
	ld l,SCI_VOL
	call vswriteregister
	pop bc
	pop de
	pop hl
	ret
.cmdvolumedown
	ld a,(volumevalue)
	cp SV_SILENCE>>8
	ret nc
	inc a
	jr .setvolume
.cmdgetstreaminfo
streaminfobyte=$+1
	ld a,255
	ATOZX
	ret

noper
	ds 18,0
	ret
end
	savebin "gscode.bin",begin,end-begin
