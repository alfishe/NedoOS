; Derived from RoboPlay Amiga MOD player
; Copyright 2023 RoboSoft Inc.
; https://gitlab.com/torihino/roboplay/-/blob/master/players/src/mod.c

MODSAMPLECOUNT = 31
MODWAVEHEADERBUFFERSIZE = MODSAMPLECOUNT*MOONWAVEHEADERSIZE
MODSAMPLEDATASTART = MOONRAMWAVETABLESIZE*MOONWAVEHEADERSIZE+MOONSOUNDROMSIZE
MODPATTERNSTEPCOUNT = 64
MODSTEPDATASIZE = 4
MODMAXPATTERNS = 128
MODMAXCHANNELS = 24
MODMAXVOLUME = 64
MODHEADERADDR = 0xc000

	struct MODSAMPLEINFO
samplename ds 22
samplelength ds 2
finetune ds 1
volume ds 1
samplerepeatpoint ds 2
samplerepeatlength ds 2
	ends

	struct MODHEADER
songname ds 20
samples ds MODSAMPLEINFO*31
songlength ds 1
dummy ds 1
patterntable ds 128
moduletype ds 4
	ends

	struct MODSTEPDATA
samplenumber ds 1
period ds 2
effectcommand ds 1
effectdata ds 1
extendedcommand ds 1
	ends

	struct MODCHANNEL
index ds 1
samplenumber ds 1
oldsamplenumber ds 1
notenumberperiod ds 2
period ds 2
volume ds 1
tempcommand ds 2
pitchbendspeed ds 1
vibratocommand ds 1
vibratotableposition ds 1
tremolocommand ds 1
tremolotableposition ds 1
wavecontrol ds 1
patternloopstart ds 1
patternloopcount ds 1
pankeyon ds 1
	ends

	struct MODINFO
patternaddrs ds MODMAXPATTERNS*4
channelcount ds 1
patterncount ds 1
songlength ds 1
samplefinetunes ds MODSAMPLECOUNT
samplevolumes ds MODSAMPLECOUNT
	ends

	struct MODPLAYER
patterntableindex ds 1
patternstepindex ds 1
arpeggio ds 1
commandE5 ds 1
commandEE ds 1
bpm ds 1
speed ds 1
speedstep ds 1
channels ds MODCHANNEL*MODMAXCHANNELS
stepdatabuffer ds MODSTEPDATA*MODMAXCHANNELS
	ends

	macro get_array_value dest,array
	add a,(array)%256
	ld l,a
	adc a,(array)/256
	sub l
	ld h,a
	ld dest,(hl)
	endm

modload
;de = input file name
;out: zf=1 if the file is ready for playing, zf=0 otherwise
	call memorystreamloadfile
	ret nz
;map header to MODHEADERADDR
	ld a,(memorystreampages)
	SETPGC000
	call modparsetype
	jp nz,memorystreamfree ;sets zf=0
	ld (modinfo.channelcount),a
	ld a,(modheader.songlength)
	ld (modinfo.songlength),a
	call opl4init
	call modloadpatterns
	call modloadsamples
;init player state
	ld hl,modplayer
	ld de,modplayer+1
	ld bc,MODPLAYER-1
	ld (hl),0
	ldir
;init channels
	ld iy,modplayer.channels
	ld bc,MODMAXCHANNELS*256
.initchloop
	ld (iy+MODCHANNEL.index),c
	ld hl,508
	ld (iy+MODCHANNEL.period),hl
	ld (iy+MODCHANNEL.notenumberperiod),hl
	ld a,c
	and 3
	get_array_value a,moddefaultpanning
	call modsetpanning
	ld de,MODCHANNEL
	add iy,de
	inc c
	djnz .initchloop
;init globals
	ld a,125
	call modsetbpm
	xor a
	call modsetnextstep
	ld a,6
	ld (modplayer.speed),a
	ld a,1
	ld (modplayer.speedstep),a
	xor a
	ret

modparsetype
;output: a = channel count
	ld hl,modtypetable
	ld b,modtypecount
.loop   ld a,(modheader.moduletype+0)
	xor (hl)
	inc hl
	ld c,a
	ld a,(modheader.moduletype+1)
	xor (hl)
	inc hl
	or c
	ld c,a
	ld a,(modheader.moduletype+2)
	xor (hl)
	inc hl
	or c
	ld c,a
	ld a,(modheader.moduletype+3)
	xor (hl)
	inc hl
	or c
	ld a,(hl)
	inc hl
	ret z
	djnz .loop
	ret

modunload
	call opl4mute
	jp memorystreamfree

modplay
	call modwaittimer
	ld a,(modplayer.speedstep)
	dec a
	jp nz,.tn
	ld a,(modplayer.speed)
	ld (modplayer.speedstep),a
	ld a,(modplayer.commandEE)
	or a
	jr z,.noEE
	dec a
	ld (modplayer.commandEE),a
	ret
.noEE	call modreadstepdata
	ld ix,modplayer.stepdatabuffer
	ld iy,modplayer.channels
	ld a,(modinfo.channelcount)
.t0loop
	push af
	xor a
	ld (modplayer.commandE5),a
	call modsetsample
	call modhandlecommandT0
	ld d,(ix+MODSTEPDATA.effectcommand)
	ld e,(ix+MODSTEPDATA.extendedcommand)
	ld hl,0x0e0d
	sub hl,de
	jr z,.finalizenote
	call modnewnote
	ld a,(ix+MODSTEPDATA.effectcommand)
	cp 0x0e
	jr nz,.finalizenote
	ld a,(ix+MODSTEPDATA.extendedcommand)
	dec a
	call z,modportaup
	ld a,(ix+MODSTEPDATA.extendedcommand)
	cp 2
	call z,modportadown
.finalizenote
	ld a,(iy+MODCHANNEL.volume)
	call modsetvolume
	set 7,(iy+MODCHANNEL.pankeyon)
	call modflushpankeyon
	ld de,MODSTEPDATA
	add ix,de
	ld e,MODCHANNEL
	add iy,de
	pop af
	dec a
	jp nz,.t0loop
	ret
.tn	ld (modplayer.speedstep),a
	ld a,(modplayer.arpeggio)
	inc a
	cp 3
	jr c,$+3
	xor a
	ld (modplayer.arpeggio),a
	ld ix,modplayer.stepdatabuffer
	ld iy,modplayer.channels
	ld a,(modinfo.channelcount)
	ld b,a
.tnloop
	push bc
	call modhandlecommandTN
	ld de,MODSTEPDATA
	add ix,de
	ld e,MODCHANNEL
	add iy,de
	pop bc
	djnz .tnloop
	ret

modloadsamples
;input: memory stream at samples data
	ld hl,MODSAMPLEDATASTART%65536
	ld a,MODSAMPLEDATASTART/65536
	ld (.sampleaddresslo),hl
	ld (.sampleaddresshi),a
	ld ix,modheader.samples
	ld iy,modwaveheaderbuffer
	ld hl,modinfo.samplefinetunes
	ld de,modinfo.samplevolumes
	ld b,MODSAMPLECOUNT
.mainloop
	ld a,(ix+MODSAMPLEINFO.finetune)
	ld (hl),a
	inc hl
	ld a,(ix+MODSAMPLEINFO.volume)
	ld (de),a
	inc de
	push bc
	push de
	push hl
	ld h,(ix+MODSAMPLEINFO.samplelength+0)
	ld l,(ix+MODSAMPLEINFO.samplelength+1)
	ld de,0
	add hl,hl
	jr nc,.canfullyload
	ex de,hl
	inc de
	ld hl,0xffff
.canfullyload
	ld (.sampletail),de
	ld (.samplelength),hl
	ld h,(ix+MODSAMPLEINFO.samplerepeatpoint+0)
	ld l,(ix+MODSAMPLEINFO.samplerepeatpoint+1)
	add hl,hl
	ld bc,hl
	ld h,(ix+MODSAMPLEINFO.samplerepeatlength+0)
	ld l,(ix+MODSAMPLEINFO.samplerepeatlength+1)
	add hl,hl
	ex de,hl
	ld hl,-5
	add hl,de
	sbc a,a
	ex de,hl
	add hl,bc
	dec hl
	ex de,hl
	or b
	or c
	jr nz,.hasvalidloop
	ld de,(.samplelength)
	dec de
	ld bc,de
.hasvalidloop
	ld hl,0xffff
	sub hl,de
	ld (iy+ 3),b ;loop hi
	ld (iy+ 4),c ;loop lo
	ld (iy+ 5),h ;end hi
	ld (iy+ 6),l ;end lo
	ld (iy+ 7),0x00 ;LFO, VIB
	ld (iy+ 8),0xf0 ;AR, D1R
	ld (iy+ 9),0xff ;DL, D2R
	ld (iy+10),0x0f ;rate correction, RR
	ld (iy+11),0x00 ;AM
.sampleaddresslo=$+1
	ld hl,0
.sampleaddresshi=$+1
	ld d,0
	ld (iy+0),d ;8 bits sample, addr hi
	ld (iy+1),h ;addr mi
	ld (iy+2),l ;addr lo
.samplelength=$+1
	ld bc,0
	ld a,b
	or c
	jr z,.nextsample
;write sample
	push bc
	push de
	push hl
	call opl4setmemoryaddress
	ld de,0x1102
	call opl4writewave
	opl4_wait
	ld a,6
	out (MOON_WREG),a
	ld de,ix
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld hl,(memorystreamcurrentaddr)
.writeloop
	memory_stream_read_byte d
	opl4_wait
	ld a,d
	out (MOON_WDAT),a
	djnz .writeloop
	dec c
	jr nz,.writeloop
	ld (memorystreamcurrentaddr),hl
.sampletail=$+1
	ld bc,0
	ld a,b
	or c
	jr z,.fullyloaded
	call memorystreamgetpos
	add hl,bc
	jr nc,$+3
	inc de
	call memorystreamseek
.fullyloaded
	ld de,0x1002
	call opl4writewave
	pop hl
	pop de
	pop bc
;set next write address
	xor a
	add hl,bc
	ld (.sampleaddresslo),hl
	adc a,d
	ld (.sampleaddresshi),a
.nextsample
	ld de,MODSAMPLEINFO
	add ix,de
	ld e,MOONWAVEHEADERSIZE
	add iy,de
	pop hl
	pop de
	pop bc
	dec b
	jp nz,.mainloop
;write headers
	ld ix,modwaveheaderbuffer
	ld hl,MOONSOUNDROMSIZE%65536
	ld d,MOONSOUNDROMSIZE/65536
	ld bc,MODWAVEHEADERBUFFERSIZE
	jp opl4writememory

modloadpatterns
;output: pattern offsets, memory stream is positioned past patterns data
	ld hl,modheader.patterntable
	ld b,128
	xor a
.maxpatternloop
	cp (hl)
	jr nc,$+3
	ld a,(hl)
	inc hl
	djnz .maxpatternloop
	inc a
	ld (modinfo.patterncount),a
	ld de,MODSTEPDATASIZE*MODPATTERNSTEPCOUNT
	ld hl,0
	ld a,(modinfo.channelcount)
	ld b,a
.patsizeloop
	add hl,de
	djnz .patsizeloop
	ld bc,hl
	ld de,0
	ld hl,MODHEADER
	ld ix,modinfo.patternaddrs
	ld a,(modinfo.patterncount)
.patdataloop
	ld (ix+0),l
	ld (ix+1),h
	ld (ix+2),e
	ld (ix+3),d
	add hl,bc
	jr nc,$+3
	inc de
	inc ix
	inc ix
	inc ix
	inc ix
	dec a
	jr nz,.patdataloop
	jp memorystreamseek

modgetnextpatternindex
;output: a = pattern index
	ld a,(modplayer.patterntableindex)
	inc a
	ld hl,modheader.songlength
	cp (hl)
	jr c,$+3
	xor a
	ld (modplayer.patterntableindex),a
	ret

modgetpatternpos
;a = pattern index
;out: dehl = file stream position
	ld e,a
	ld d,0
	ld hl,modheader.patterntable
	add hl,de
	ld e,(hl)
	ld hl,modinfo.patternaddrs
	add hl,de
	add hl,de
	add hl,de
	add hl,de
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl,bc
	ret

modsetnextstep
;a = step index
;output: memory stream at patterntableindex/patternstepindex
	dec a ;save decremented patternstepindex to cancel out its increment in T0
	ld (modplayer.patternstepindex),a
	ld a,(modplayer.patterntableindex)
	call modgetpatternpos
	ld a,(modplayer.patternstepindex)
	inc a
	ld b,0
	add a,a
	rl b
	add a,a
	rl b
	ld c,a
	ld a,(modinfo.channelcount)
.loop	add hl,bc
	jr nc,$+3
	inc de
	dec a
	jr nz,.loop
	jp memorystreamseek

modreadstepdata
;input: memory stream
;output: filled stepdatabuffer, memory stream at next pattern step
	ld a,(modplayer.patternstepindex)
	inc a
	cp MODPATTERNSTEPCOUNT
	jr c,.nextpatternstep
	call modgetnextpatternindex
	call modgetpatternpos
	call memorystreamseek
	xor a
.nextpatternstep
	ld (modplayer.patternstepindex),a
;read step data
	ld ix,modplayer.stepdatabuffer
	ld hl,(memorystreamcurrentaddr)
	ld a,(modinfo.channelcount)
	ld b,a
.loop	memory_stream_read_byte c
	memory_stream_read_byte d
	memory_stream_read_byte e
	ld a,c
	and 15
	ld (ix+MODSTEPDATA.period+0),d
	ld (ix+MODSTEPDATA.period+1),a
	ld a,e
	rrca
	rrca
	rrca
	rrca
	xor c
	and 15
	xor c
	ld (ix+MODSTEPDATA.samplenumber),a
	memory_stream_read_byte c
	ld a,e
	and 15
	ld (ix+MODSTEPDATA.effectcommand),a
	cp 14
	ld a,c
	jr nz,.notextended
	srl c
	srl c
	srl c
	srl c
	ld (ix+MODSTEPDATA.extendedcommand),c
	and 15
.notextended
	ld (ix+MODSTEPDATA.effectdata),a
	ld de,MODSTEPDATA
	add ix,de
	djnz .loop
	ld (memorystreamcurrentaddr),hl
	ret

	macro clamp_volume_in_a
	cp MODMAXVOLUME+1
	jr c,$+4
	ld a,MODMAXVOLUME
	endm

modhandlecommandT0
;ix = step data
;iy = channel data
	ld a,(ix+MODSTEPDATA.effectcommand)
	ld b,a
	add a,a
	add a,b
	ld (.effectcommandtable),a
.effectcommandtable=$+1
	jr $
	jp .doeffect0 ; 0 [Arpeggio]
	ret : ds 2    ; 1 [Porta Up]
	ret : ds 2    ; 2 [Porta Down]
	ret : ds 2    ; 3 [Porta To Note]
	jp .doeffect4 ; 4 [Vibrato]
	ret : ds 2    ; 5 [Porta + Volume Slide]
	ret : ds 2    ; 6 [Vibrato + Volume Slide]
	jp .doeffect7 ; 7 [Tremolo]
	jp .doeffect8 ; 8 [Pan]
	ret : ds 2    ; 9 [Sample Offset]
	ret : ds 2    ; A [Volume Slide]
	ret : ds 2    ; B [Jump To Pattern]
	jp .doeffectC ; C [Set Volume]
	ret : ds 2    ; D [Pattern Break]
	jp .doeffectE ; E [Effect]
	;;;;;;;;;;;;;;; F [Set Speed]
	ld a,(ix+MODSTEPDATA.effectdata)
	cp 32
	jp nc,modsetbpm
	ld (modplayer.speed),a
	ld (modplayer.speedstep),a
	ret
.doeffect0
	xor a
	ld (modplayer.arpeggio),a
	ld hl,(iy+MODCHANNEL.period)
	jp modsetfrequency
.doeffect4
	ld bc,(iy+MODCHANNEL.period)
	ld (iy+MODCHANNEL.tempcommand),bc
	ld b,(ix+MODSTEPDATA.effectdata)
	ld c,(iy+MODCHANNEL.vibratocommand)
	ld a,b
	and 0xf0
	jr z,.skipvibratohi
	xor c
	and 0xf0
	xor c
	ld c,a
.skipvibratohi
	ld a,b
	and 15
	jr z,.skipvibratolo
	xor c
	and 15
	xor c
	ld c,a
.skipvibratolo
	ld (iy+MODCHANNEL.vibratocommand),c
	ret
.doeffect7
	ld b,(ix+MODSTEPDATA.effectdata)
	ld c,(iy+MODCHANNEL.tremolocommand)
	ld a,b
	and 0xf0
	jr z,.skiptremolohi
	xor c
	and 0xf0
	xor c
	ld c,a
.skiptremolohi
	ld a,b
	and 15
	jr z,.skiptremololo
	xor c
	and 15
	xor c
	ld c,a
.skiptremololo
	ld (iy+MODCHANNEL.tremolocommand),c
	ret
.doeffect8
	ld a,(ix+MODSTEPDATA.effectdata)
	rrca
	rrca
	rrca
	rrca
	and 15
	call modsetpanning
	jp modflushpankeyon
.doeffectC
	ld a,(ix+MODSTEPDATA.effectdata)
	clamp_volume_in_a
	ld (iy+MODCHANNEL.volume),a
	jp modsetvolume
.doeffectE
	ld a,(ix+MODSTEPDATA.extendedcommand)
	ld b,a
	add a,a
	add a,b
	ld (.exteffcommandtable),a
.exteffcommandtable=$+1
	jr $
	ret : ds 2    ; 0 [Set Filter]
	ret : ds 2    ; 1 [Fine Portamento Up]
	ret : ds 2    ; 2 [Fine Portamento Down]
	ret : ds 2    ; 3 [Glissando Control]
	jp .doexteff4 ; 4 [Set Vibrato Waveform]
	jp .doexteff5 ; 5 [Set Finetune]
	ret : ds 2    ; 6 [Pattern Loop]
	jp .doexteff7 ; 7 [Set Tremolo WaveForm]
	jp .doexteff8 ; 8 [16 position panning]
	jp .doexteff9 ; 9 [Retrig Note]
	jp .doexteffA ; A [Fine Volume Slide Up]
	jp .doexteffB ; B [Fine Volume Slide Down]
	jp .doexteffC ; C [Cut Note]
	jp .doexteffD ; D [Delay Note]
	jp .doexteffE ; E [Pattern Delay]
	ret           ; F
.doexteff4
	ld a,(iy+MODCHANNEL.wavecontrol)
	ld b,(ix+MODSTEPDATA.effectdata)
	and 0xfc
	or b
	ld (iy+MODCHANNEL.wavecontrol),a
	ld (iy+MODCHANNEL.vibratotableposition),0
	ret
.doexteff5
	ld a,(ix+MODSTEPDATA.effectdata)
	ld (modplayer.commandE5),a
	ret
.doexteff7
	ld a,(iy+MODCHANNEL.wavecontrol)
	ld b,(ix+MODSTEPDATA.effectdata)
	sla b
	sla b
	and 0xf3
	or b
	ld (iy+MODCHANNEL.wavecontrol),a
	ld (iy+MODCHANNEL.tremolotableposition),0
	ret
.doexteff8
	ld a,(ix+MODSTEPDATA.effectdata)
	call modsetpanning
	jp modflushpankeyon
.doexteff9
	ld a,(ix+MODSTEPDATA.effectdata)
	ld (iy+MODCHANNEL.tempcommand),a
	ret
.doexteffA
	ld a,(iy+MODCHANNEL.volume)
	add a,(ix+MODSTEPDATA.effectdata)
	clamp_volume_in_a
	add (iy+MODCHANNEL.volume),a
	jp modsetvolume
.doexteffB
	ld a,(iy+MODCHANNEL.volume)
	sub (ix+MODSTEPDATA.effectdata)
	jr nc,$+3
	xor a
	add (iy+MODCHANNEL.volume),a
	jp modsetvolume
.doexteffC
	ld a,(ix+MODSTEPDATA.effectdata)
	or a
	jr z,.channeloff
	ld (iy+MODCHANNEL.tempcommand),a
	ret
.channeloff
	ld (iy+MODCHANNEL.volume),a
	jp modsetvolume
.doexteffD
	ld a,(ix+MODSTEPDATA.effectdata)
	or a
	ret z
	ld (iy+MODCHANNEL.tempcommand),a
	ret
.doexteffE
	ld a,(ix+MODSTEPDATA.effectdata)
	ld (modplayer.commandEE),a
	ret

modhandlecommandTN
; ix = step data
; iy = channel data
	ld a,(ix+MODSTEPDATA.effectcommand)
	ld b,a
	add a,a
	add a,b
	ld (.effectcommandtable),a
.effectcommandtable=$+1
	jr $
	jp .doeffect0   ; 0 [Arpeggio]
	jp modportaup   ; 1 [Porta Up]
	jp modportadown ; 2 [Porta Down]
	jp modtoneporta ; 3 [Porta To Note]
	jp modvibrato   ; 4 [Vibrato]
	jp .doeffect5   ; 5 [Porta + Volume Slide]
	jp .doeffect6   ; 6 [Vibrato + Volume Slide]
	jp modtremolo   ; 7 [Tremolo]
	ret : ds 2      ; 8 [Pan]
	ret : ds 2      ; 9 [Sample Offset]
	jp modvolumeslide ; A [Volume Slide]
	jp .doeffectB   ; B [Jump To Pattern]
	ret : ds 2      ; C [Set Volume]
	jp .doeffectD   ; D [Pattern Break]
	jp .doeffectE   ; E [Effect]
	ret             ; F [Set Speed]
.doeffect0
	ld a,(ix+MODSTEPDATA.effectdata)
	or a
	ret z
	ld hl,(modplayer.arpeggio)
	dec l
	jr z,.datahi
	inc l
	jr nz,.datalo
	ld hl,(iy+MODCHANNEL.period)
	jp modsetfrequency
.datahi	rrca
	rrca
	rrca
	rrca
.datalo	and 15
	push af
	ld hl,(iy+MODCHANNEL.notenumberperiod)
	call modfindnotenumber
	pop bc
	add a,b
	cp periodstablesize
	jr c,$+4
	ld a,periodstablesize-1
	ld e,a
	ld d,0
	ld hl,ft2periods
	add hl,de
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	call modtuneperiod
	jp modsetfrequency
.doeffect5
	call modtoneporta
	jp modvolumeslide
.doeffect6
	call modvibrato
	jp modvolumeslide
.doeffectB
	ld a,(modplayer.speedstep)
	dec a
	ret nz
	ld a,(ix+MODSTEPDATA.effectdata)
	ld (modplayer.patterntableindex),a
	xor a
	jp modsetnextstep
.doeffectD
	ld a,(modplayer.speedstep)
	dec a
	ret nz
	call modgetnextpatternindex
	ld a,(ix+MODSTEPDATA.effectdata)
	ld b,a
	and 0xf0
	xor b
	ld c,a
	xor b
	rrca
	rrca
	rrca
	rrca
	add a,a
	ld b,a
	add a,a
	add a,a
	add a,b
	add a,c
	jp modsetnextstep
.doeffectE
	ld a,(ix+MODSTEPDATA.extendedcommand)
	ld b,a
	add a,a
	add a,b
	ld (.exteffcommandtable),a
.exteffcommandtable=$+1
	jr $
	ret : ds 2    ; 0 [Set Filter]
	ret : ds 2    ; 1 [Fine Portamento Up]
	ret : ds 2    ; 2 [Fine Portamento Down]
	ret : ds 2    ; 3 [Glissando Control]
	ret : ds 2    ; 4 [Set Vibrato Waveform]
	ret : ds 2    ; 5 [Set Finetune]
	jp .doexteff6 ; 6 [Pattern Loop]
	ret : ds 2    ; 7 [Set Tremolo WaveForm]
	ret : ds 2    ; 8 [16 position panning]
	jp modnewnote ; 9 [Retrig Note]
	ret : ds 2    ; A [Fine Volume Slide Up]
	ret : ds 2    ; B [Fine Volume Slide Down]
	jp .doexteffC ; C [Cut Note]
	jp .doexteffD ; D [Delay Note]
	ret : ds 2    ; E [Pattern Delay]
	ret           ; F
.doexteff6
	ld a,(modplayer.speedstep)
	dec a
	ret nz
	ld a,(ix+MODSTEPDATA.effectdata)
	or a
	jr nz,.checkloopcount
	ld a,(modplayer.patternstepindex)
	ld (iy+MODCHANNEL.patternloopstart),a
	ret
.checkloopcount
	ld b,(iy+MODCHANNEL.patternloopcount)
	inc b
	cp b
	jr c,.restartloop
	ld (iy+MODCHANNEL.patternloopcount),b
	ld a,(iy+MODCHANNEL.patternloopstart)
	jp modsetnextstep
.restartloop
	ld (iy+MODCHANNEL.patternloopcount),0
	ret
.doexteffC
	ld a,(iy+MODCHANNEL.tempcommand)
	or a
	ret z
	dec a
	ld (iy+MODCHANNEL.tempcommand),a
	ret nz
	ld (iy+MODCHANNEL.volume),a
	jp modsetvolume
.doexteffD
	ld a,(iy+MODCHANNEL.tempcommand)
	or a
	ret z
	dec a
	ld (iy+MODCHANNEL.tempcommand),a
	ret nz
	jp modnewnote

modsetsample
;ix = step data
;iy = channel data
	ld a,(ix+MODSTEPDATA.samplenumber)
	or a
	ret z
	ld (iy+MODCHANNEL.samplenumber),a
	get_array_value a,modinfo.samplevolumes-1
	ld (iy+MODCHANNEL.volume),a
	ld (iy+MODCHANNEL.vibratotableposition),0
	ret

modnewnote
;ix = step data
;iy = channel data
	ld a,(iy+MODCHANNEL.samplenumber)
	or a
	ret z
	ld a,(ix+MODSTEPDATA.effectcommand)
	cp 0x03
	jr z,.effect3
	cp 0x05
	jr z,.effect5
	ld a,(ix+MODSTEPDATA.period)
	or (ix+MODSTEPDATA.period+1)
	ret z
	xor a
	call modsetvolume
	res 7,(iy+MODCHANNEL.pankeyon)
	call modflushpankeyon
	ld hl,(ix+MODSTEPDATA.period)
	ld (iy+MODCHANNEL.notenumberperiod),hl
	call modtuneperiod
	ld (iy+MODCHANNEL.period),hl
	call modsetfrequency
	ld a,(iy+MODCHANNEL.samplenumber)
	cp (iy+MODCHANNEL.oldsamplenumber)
	ret z
	ld (iy+MODCHANNEL.oldsamplenumber),a
	jp modsetsamplenumber
.effect3
	ld a,(ix+MODSTEPDATA.effectdata)
	or a
	jr z,.effect5
	ld (iy+MODCHANNEL.pitchbendspeed),a
.effect5
	ld hl,(ix+MODSTEPDATA.period)
	ld a,h
	or l
	ret z
	ld (iy+MODCHANNEL.notenumberperiod),hl
	call modtuneperiod
	ld (iy+MODCHANNEL.tempcommand),hl
	ret

modtuneperiod
;iy = channel data
;hl = period
;out: hl = period
	ex de,hl
	ld a,(modplayer.commandE5)
	or a
	jr nz,.computefinetune
	ld a,(iy+MODCHANNEL.samplenumber)
	get_array_value a,modinfo.samplefinetunes-1
	and 15
	jr nz,.computefinetune
	ex de,hl
	ret
.computefinetune
	add a,a
	get_array_value c,finetunefactors
	inc hl
	ld b,(hl)
	call uintmul16
	add hl,hl
	ex de,hl
	adc hl,hl
	ret

modportaup
;ix = step data
;iy = channel data
	ld hl,(iy+MODCHANNEL.period)
	ld e,(ix+MODSTEPDATA.effectdata)
	ld d,0
	sub hl,de
	jr c,.clamp
	ex de,hl
	ld hl,-1
	add hl,de
	ex de,hl
	jr c,$+5
.clamp	ld hl,1
	ld (iy+MODCHANNEL.period),hl
	jp modsetfrequency

modportadown
;ix = step data
;iy = channel data
	ld hl,(iy+MODCHANNEL.period)
	ld e,(ix+MODSTEPDATA.effectdata)
	ld d,0
	add hl,de
	ex de,hl
	ld hl,-7000
	add hl,de
	ex de,hl
	jr nc,$+5
	ld hl,6999
	ld (iy+MODCHANNEL.period),hl
	jp modsetfrequency

modtoneporta
;iy = channel data
	ld hl,(iy+MODCHANNEL.period)
	ld bc,(iy+MODCHANNEL.tempcommand)
	ld de,hl
	sub hl,bc
	ex de,hl
	jp z,modsetfrequency ;period == tempcommand
	ld e,(iy+MODCHANNEL.pitchbendspeed)
	ld d,0
	jr c,.pospitchbend ;period < tempcommand
	sub hl,de
	jr nc,$+5
	ld hl,0
	ld de,hl
	sub hl,bc
	ex de,hl
	jr nc,.finalize ;period >= tempcommand
	ld hl,bc
	jr .finalize
.pospitchbend
	add hl,de
	ld de,hl
	sub hl,bc
	ex de,hl
	jr c,$+4 ;period < tempcommand
	ld hl,bc
.finalize
	ld (iy+MODCHANNEL.period),hl
	jp modsetfrequency

mul8x8
;a,e = factors
;hl = 0
;out: hl = a*e
	ld d,h
	ld b,a
	add hl,de
	djnz $-1
	ret

modvibrato
;iy = channel data
	ld a,(iy+MODCHANNEL.vibratotableposition)
	rrca
	rrca
	and 0x1f
	get_array_value e,modvibratotable
	ld hl,0
	ld a,(iy+MODCHANNEL.vibratocommand)
	and 15
	call nz,mul8x8
	sla l
	rl h
	ld e,h
	ld d,0
	ld hl,(iy+MODCHANNEL.period)
	bit 7,(iy+MODCHANNEL.vibratotableposition)
	jr z,.periodup
	sub hl,de
	jr .finalize
.periodup
	add hl,de
.finalize
	ld (iy+MODCHANNEL.tempcommand),hl
	call modsetfrequency
	ld a,(iy+MODCHANNEL.vibratocommand)
	rrca
	rrca
	and 0x3c
	add a,(iy+MODCHANNEL.vibratotableposition)
	ld (iy+MODCHANNEL.vibratotableposition),a
	ret

modtremolo
;iy = channel data
	ld a,(iy+MODCHANNEL.tremolotableposition)
	rrca
	rrca
	and 0x1f
	get_array_value e,modvibratotable
	ld hl,0
	ld a,(iy+MODCHANNEL.tremolocommand)
	and 15
	call nz,mul8x8
	ld a,h
	sla l
	rla
	sla l
	rla
	bit 7,(iy+MODCHANNEL.tremolotableposition)
	jr z,.volumeup
	ld b,a
	ld a,(iy+MODCHANNEL.volume)
	sub b
	jr nc,.finalize
	xor a
	jr .finalize
.volumeup
	add a,(iy+MODCHANNEL.volume)
	clamp_volume_in_a
.finalize
	call modsetvolume
	ld a,(iy+MODCHANNEL.tremolocommand)
	rrca
	rrca
	and 0x3c
	add a,(iy+MODCHANNEL.tremolotableposition)
	ld (iy+MODCHANNEL.tremolotableposition),a
	ret

modvolumeslide
;ix = step data
;iy = channel data
	ld a,(ix+MODSTEPDATA.effectdata)
	cp 0x10
	jr nc,.volumeup
	ld b,a
	ld a,(iy+MODCHANNEL.volume)
	sub b
	jr nc,.finalize
	xor a
	jr .finalize
.volumeup
	rrca
	rrca
	rrca
	rrca
	and 15
	add a,(iy+MODCHANNEL.volume)
	clamp_volume_in_a
.finalize
	ld (iy+MODCHANNEL.volume),a
	jp modsetvolume

modsetsamplenumber
;iy = channel data
;a = sample number
	add a,0x7f
	ld d,a
	ld a,(iy+MODCHANNEL.index)
	add 0x08
	ld e,a
	call opl4writewave
;wait for the header to load
	in a,(MOON_STAT)
	and 3
	jr nz,$-4
	ret

modsetfrequency
;iy = channel data
;hl = period
	ld a,(modperiodlookuppage)
	SETPGC000
	add hl,hl
	ld de,0xc000-2
	add hl,de
	ld d,(hl)
	inc hl
	ld l,(hl)
	ld a,(memorystreampages)
	SETPGC000
	ld a,(iy+MODCHANNEL.index)
	add 0x38
	ld e,a
	call opl4writewave
	ld d,l
	ld a,e
	sub 0x18
	ld e,a
	jp opl4writewave

modsetvolume
;iy = channel data
;a = volume
	get_array_value d,modvolumetable
	sll d
	ld a,(iy+MODCHANNEL.index)
	add a,0x50
	ld e,a
	jp opl4writewave

modsetpanning
;iy = channel data
;a = panning
	get_array_value l,modpantable
	ld a,(iy+MODCHANNEL.pankeyon)
	and 0x80
	or l
	ld (iy+MODCHANNEL.pankeyon),a
	ret

modflushpankeyon
;iy = channel data
	ld d,(iy+MODCHANNEL.pankeyon)
	ld a,(iy+MODCHANNEL.index)
	add a,0x68
	ld e,a
	jp opl4writewave

modsetbpm
;a = bpm
	ld (modplayer.bpm),a
	get_array_value d,modtimertable
	ld e,0x03
	call opl4writefm1
	ld de,0x4204
	jp opl4writefm1

modwaittimer
	in a,(MOON_STAT)
	rla
	jr nc,modwaittimer
	ld de,0x8204
	jp opl4writefm1

modvolumetable
	db 0x7F,0x5C,0x52,0x4A,0x44,0x3F,0x3B,0x37,0x34,0x31
	db 0x2F,0x2D,0x2A,0x28,0x27,0x25,0x23,0x22,0x20,0x1F
	db 0x1E,0x1C,0x1B,0x1A,0x19,0x18,0x17,0x16,0x15,0x14
	db 0x13,0x12,0x12,0x11,0x10,0x0F,0x0F,0x0E,0x0D,0x0C
	db 0x0C,0x0B,0x0B,0x0A,0x09,0x09,0x08,0x08,0x07,0x06
	db 0x06,0x05,0x05,0x04,0x04,0x03,0x03,0x03,0x02,0x02
	db 0x01,0x01,0x00,0x00,0x00

moddefaultpanning
	db 5,10,10,5

modpantable
	db 9,10,11,12,13,14,15,0,0,1,2,3,4,5,6,7

; 2^( -FineTune / 12 / 8 ) as 1.15 fixed point
finetunefactors
	dw 0x8000,0x7f14,0x7e2a,0x7d41,0x7c5b,0x7b76
	dw 0x7a92,0x79b0,0x879c,0x86a2,0x85aa,0x84b4
	dw 0x83c0,0x82cd,0x81dc,0x80ed

modvibratotable
	db   0, 24, 49, 74, 97,120,141,161
	db 180,197,212,224,235,244,250,253
	db 255,253,250,244,235,224,212,197
	db 180,161,141,120, 97, 74, 49, 24

modtimertable
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0x05,0x0d,0x14,0x1b,0x22,0x28,0x2e,0x33,0x39,0x3e,0x42,0x47,0x4b,0x4f,0x53,0x57,0x5a,0x5e
	db 0x61,0x64,0x67,0x6a,0x6d,0x70,0x72,0x75,0x77,0x7a,0x7c,0x7e,0x80,0x82,0x84,0x86,0x88,0x8a
	db 0x8b,0x8d,0x8f,0x90,0x92,0x94,0x95,0x96,0x98,0x99,0x9a,0x9c,0x9d,0x9e,0x9f,0xa1,0xa2,0xa3
	db 0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xae,0xaf,0xb0,0xb1,0xb2,0xb2,0xb3
	db 0xb4,0xb5,0xb5,0xb6,0xb7,0xb7,0xb8,0xb9,0xb9,0xba,0xbb,0xbb,0xbc,0xbc,0xbd,0xbd,0xbe,0xbf
	db 0xbf,0xc0,0xc0,0xc1,0xc1,0xc2,0xc2,0xc3,0xc3,0xc3,0xc4,0xc4,0xc5,0xc5,0xc6,0xc6,0xc7,0xc7
	db 0xc7,0xc8,0xc8,0xc8,0xc9,0xc9,0xca,0xca,0xca,0xcb,0xcb,0xcb,0xcc,0xcc,0xcc,0xcd,0xcd,0xcd
	db 0xce,0xce,0xce,0xcf,0xcf,0xcf,0xd0,0xd0,0xd0,0xd0,0xd1,0xd1,0xd1,0xd1,0xd2,0xd2,0xd2,0xd3
	db 0xd3,0xd3,0xd3,0xd4,0xd4,0xd4,0xd4,0xd4,0xd5,0xd5,0xd5,0xd5,0xd6,0xd6,0xd6,0xd6,0xd6,0xd7
	db 0xd7,0xd7,0xd7,0xd8,0xd8,0xd8,0xd8,0xd8,0xd8,0xd9,0xd9,0xd9,0xd9,0xd9,0xda,0xda,0xda,0xda
	db 0xda,0xda,0xdb,0xdb,0xdb,0xdb,0xdb,0xdb,0xdc,0xdc,0xdc,0xdc,0xdc,0xdc,0xdd,0xdd,0xdd,0xdd
	db 0xdd,0xdd,0xdd,0xde,0xde,0xde,0xde,0xde,0xde,0xde,0xdf,0xdf,0xdf,0xdf,0xdf,0xdf,0xdf,0xe0
	db 0xe0,0xe0,0xe0,0xe0,0xe0,0xe0,0xe0,0xe1,0xe1

modtypetable
	db "M.K.",4
	db "M!K!",4
	db "FLT4",4
	db "OCTA",8
	db "2CHN",2
	db "4CHN",4
	db "6CHN",6
	db "8CHN",8
	db "10CH",10
	db "12CH",12
	db "14CH",14
	db "16CH",16
	db "18CH",18
	db "20CH",20
	db "22CH",22
	db "24CH",24
modtypecount = ($-modtypetable)/5

modinitperiodlookup
	ld hl,1
	ld de,0xc000
.loop	push hl
	push de
	call opl4period
	pop de
	add hl,hl
	ld a,b
	add a,a
	add a,a
	add a,a
	add a,a
	or h
	ld (de),a
	inc de
	ld a,l
	or 1
	ld (de),a
	inc de
	pop hl
	inc hl
	bit 5,h
	jr z,.loop
	ret

opl4period
;hl = period
;out: hl = f-number, b = octave
	ld de,0
	exx
	ld de,0x0144
	ld hl,0xace0
	call uintdiv32
	push de
	push hl
	ld b,-7
	exx
	pop hl
	pop de
	srl de : rr h
	srl de : rr h
	srl de : rr h
	ld a,d
	or e
	or h
	jr z,.skip
.loop	exx
	inc b
	srl de : rr hl
	exx
	srl de : rr h
	ld a,d
	or e
	or h
	jr nz,.loop
.skip	exx
	ld a,h
	and 0x3
	ld h,a
	ret

modfindnotenumber
;hl = period
;out: a = note number
;bc = -hl - 1
	ld a,h
	cpl
	ld b,a
	ld a,l
	cpl
	ld c,a
	ld hl,ft2periods
	xor a
.loop	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	add hl,bc
	ret nc
	ex de,hl
	inc hl
	inc a
	cp periodstablesize
	jr nz,.loop
	dec a
	ret

ft2periods
	;    C     C#    D     D#    E     F     F#    G     G#    A     A#    B
	dw 6848, 6464, 6096, 5760, 5424, 5120, 4832, 4560, 4304, 4064, 3840, 3624 ;0
	dw 3424, 3232, 3048, 2880, 2712, 2560, 2416, 2280, 2152, 2032, 1920, 1812 ;1
	dw 1712, 1616, 1524, 1440, 1356, 1280, 1208, 1140, 1076, 1016,  960,  906 ;2
	dw  856,  808,  762,  720,  678,  640,  604,  570,  538,  508,  480,  453 ;3
	dw  428,  404,  381,  360,  339,  320,  302,  285,  269,  254,  240,  226 ;4
	dw  214,  202,  190,  180,  170,  160,  151,  143,  135,  127,  120,  113 ;5
	dw  107,  101,   95,   90,   85,   80,   75,   71,   67,   63,   60,   56 ;6
	dw   53,   50,   47,   45,   42,   40,   37,   35,   33,   31,   30,   28 ;7
periodstablesize=($-ft2periods)/2
