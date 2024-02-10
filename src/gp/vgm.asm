; Video Game Music player
; Supports AY8910, YM3812, YMF262, YMF278B, YM2203.

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

HEADER_DATA_OFFSET = 0x8034
HEADER_CLOCK_YM2203 = 0x8044
HEADER_CLOCK_YM3812 = 0x8050
HEADER_CLOCK_YMF262 = 0x805c
HEADER_CLOCK_YMF278B = 0x8060
HEADER_CLOCK_AY8910 = 0x8074
HEADER_GD3_OFFSET = 0x8014
HEADER_SAMPLES_COUNT = 0x8018
HEADER_LOOP_OFFSET = 0x801c
HEADER_LOOP_SAMPLES_COUNT = 0x8020
TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	ld a,c
	cp 'v'
	ret nz
	ld a,d
	cp 'g'
	ret nz
	ld a,e
	cp 'm'
	jr z,$+5
	cp 'z'
	ret nz
;prepare local variables
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

playerinit
;hl = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld a,(hl)
	ld (page8000),a
	inc hl
	ld a,(hl)
	ld (pageC000),a
	inc hl
	ld a,(hl)
	ld (filedatapage),a
;hardware detection is done when loading VGM
	ld hl,initokstr
	xor a
	ret

	macro a_or_dw addr
	ld hl,(addr+0)
	or h
	or l
	ld de,(addr+2)
	or d
	or e
	endm

	macro set_timer wait,ticks
	ld hl,wait
	ld (waittimercallback),hl
	ld hl,ticks
	ld (waittimerstep),hl
	endm

musicload
;cde = file extension
;hl = input file name
;out: zf=1 if the file is ready for playing, zf=0 otherwise
	ld a,e
	cp 'z'
	ex de,hl
	jr z,.loadcompressed
	call memorystreamloadfile
	jr z,.doneloading
	ret
.loadcompressed
	call decompressfiletomemorystream
	ret nz
.doneloading
	set_timer waittimer50hz,882
	ld hl,0
	ld (waitcounter),hl
	ld (samplecounterlo),hl
	xor a
	ld (samplecounterhi),a
;map header to 0x8000
	ld a,(memorystreampages)
	SETPG8000
;init progress
	ld hl,(HEADER_SAMPLES_COUNT+2)
	ld bc,(HEADER_LOOP_SAMPLES_COUNT+2)
	add hl,bc
	inc hl ;+1 as if low-word addition sets cf
	ld a,l
	inc h
	dec h
	jr z,$+4
	ld a,255
	call setprogressdelta
;check for GD3
	xor a
	a_or_dw HEADER_GD3_OFFSET
	call nz,parsegd3
;setup loop
	xor a
	a_or_dw HEADER_LOOP_OFFSET
	ld (loopoffsetlo),hl
	ld (loopoffsethi),de
	jr z,$+4
	ld a,1
	inc a
	ld (loopcounter),a
;init AY before TFM in case of weird chip combos
	xor a
	a_or_dw HEADER_CLOCK_AY8910
	ld (useAY8910),a
	call nz,initAY8910
;init TFM
	xor a
	a_or_dw HEADER_CLOCK_YM2203
	ld (useYM2203),a
	call nz,initYM2203
;init Moonsound
	xor a
	a_or_dw HEADER_CLOCK_YM3812
	ld (useYM3812),a
	a_or_dw HEADER_CLOCK_YMF262
	a_or_dw HEADER_CLOCK_YMF278B
	ld (useYMF278B),a
	call nz,initYMF278B
	jp nz,memorystreamfree ;sets zf=0
;skip to the data
	call memorystreamstart
	ld hl,(HEADER_DATA_OFFSET)
	ld a,(HEADER_DATA_OFFSET+2)
	ld d,a
	or l
	or h
	ld bc,0x40
	jr z,$+4
	ld c,0x34
	add hl,bc
	jr nc,$+3
	inc d
	call skipdatablock
	xor a
	ret

initAY8910 equ ssginit

initYM2203
	call opninit
	set_timer opnwaittimer60hz,735
	jp opninittimer60hz

initYMF278B
	call ismoonsoundpresent
	ret nz
	call vgmopl4init
	ld a,(HEADER_CLOCK_YM3812+3)
	and 0x40
	jr nz,notOPL2
useYM3812=$+1
	or 0
	ld de,0x0005
	call nz,opl4writefm2
notOPL2 set_timer opl4waittimer60hz,735
	call opl4inittimer60hz
	xor a
	ret

musicunload
useYMF278B=$+1
	ld a,0
	or a
	call nz,opl4mute
useYM2203=$+1
	ld a,0
	or a
	call nz,opnmute
;mute AY after TFM in case of weird chip combos
useAY8910=$+1
	ld a,0
	or a
	call nz,ssgmute
	jp memorystreamfree

playerdeinit
	ret

	include "../_sdk/file.asm"
	include "common/memorystream.asm"
	include "common/opl4.asm"
	include "vgm/opl4.asm"
	include "vgm/opn.asm"
	include "vgm/ssg.asm"
	include "progress.asm"

waittimer50hz
	YIELD
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
waittimercallback=$+1
	call 0
playloop
waitcounter=$+1
	ld hl,0
waittimerstep=$+1
	ld bc,0
	sub hl,bc
	jr nc,exitplayloop
;read command
	memory_stream_read_1 a
	ld l,a
	ld h,cmdtable/256
	ld e,(hl)
	inc h
	ld d,(hl)
	ld hl,playloop
	push hl
	ex hl,de
	jp (hl)
exitplayloop
	ld (waitcounter),hl
;update progress
samplecounterlo=$+1
	ld hl,0
samplecounterhi=$+1
	ld a,0
	add hl,bc
	adc a,0
	jr nc,$+4
	ld a,255
	ld (samplecounterlo),hl
	ld (samplecounterhi),a
	call updateprogress
;continue playing
	or 1
	ret

wait1	ld hl,(waitcounter)
	inc hl
	ld (waitcounter),hl
	ret

waitn	memory_stream_read_2 e,d
	ld hl,(waitcounter)
	add hl,de
	ld (waitcounter),hl
	ret

	macro wait_n n
	ld hl,(waitcounter)
	ld de,n
	add hl,de
	ld (waitcounter),hl
	ret
	endm

wait2	wait_n 2
wait3	wait_n 3
wait4	wait_n 4
wait5	wait_n 5
wait6	wait_n 6
wait7	wait_n 7
wait8	wait_n 8
wait9	wait_n 9
wait10	wait_n 10
wait11	wait_n 11
wait12	wait_n 12
wait13	wait_n 13
wait14	wait_n 14
wait15	wait_n 15
wait16	wait_n 16
wait735	wait_n 735
wait882	wait_n 882

	macro skip_n n
	ld b,n
	jp memorystreamskip
	endm

skip1	ret
skip2	skip_n 1
skip3	skip_n 2
skip4	skip_n 3
skip5	skip_n 4
skip6	skip_n 5
skip11	skip_n 10
skip12	skip_n 11


endofsounddata
loopcounter=$+1
	ld a,0
	dec a
	ld (loopcounter),a
	jp nz,seektoloop
cmdunsupported
;stop playing
	pop af
	xor a
	ret

cmdYM2203
	memory_stream_read_2 e,d
	jp opnwritemusiconlyfm1

cmdYM2203dp
	memory_stream_read_2 e,d
	jp opnwritemusiconlyfm2

cmdYMF262p0
	memory_stream_read_2 e,d
	jp opl4writemusiconlyfm1

cmdYMF262p1
	memory_stream_read_2 e,d
	jp opl4writemusiconlyfm2

cmdYMF278B
	memory_stream_read_3 c,e,d
	dec c
	jp z,opl4writemusiconlyfm2
	jp p,opl4writewavemusiconly
	jp opl4writemusiconlyfm1

cmdYM3812
	memory_stream_read_2 e,d
	jp opl4writemusiconlyfm1

cmdYM3812dp
	memory_stream_read_2 e,d
	jp opl4writemusiconlyfm2

cmdAY8910
	memory_stream_read_2 e,d
	bit 7,e
	jp z,ssgwritemusiconlychip0
	res 7,e
	jp ssgwritemusiconlychip1

cmdYMF262dp0 equ memorystreamread2
cmdYMF262dp1 equ memorystreamread2

processdatablock
	memory_stream_read_2 a,e ;a = 0x66 guard, e = type
	cp 0x66
	jp nz,cmdunsupported
	call memorystreamread4 ;adbc = data size
	ld a,e
	ld hl,bc
	cp 0x84
	jp z,opl4loadromdatablock
	cp 0x87
	jp z,opl4loadramdatablock
	jr skipdatablock

skipdatablock
;dhl = size
	call setup24bitscounterloop
.loop
	call memorystreamskip
	dec de
	ld a,e
	or d
	jr nz,.loop
	ret

seektoloop
	ld bc,0x1c
loopoffsethi=$+1
	ld de,0
loopoffsetlo=$+1
	ld hl,0
seektopos
;dehl + bc = position
;out: hl = read address
	add hl,bc
	jp nc,memorystreamseek
	inc de
	jp memorystreamseek

parsegd3
;dehl = GD3 offset
	ld bc,32
	call seektopos
	ld b,TITLELENGTH
	ld de,titlestr
	ld a,' '
.fillloop
	ld (de),a
	inc de
	djnz .fillloop
	xor a
	ld (de),a
	ld b,TITLELENGTH
	ld de,titlestr
	call gd3stringcopy   ;track name
	call z,gd3stringskip ;track name in Japanese
	push hl
	ld hl,fromstr
	call z,stringcopy
	pop hl
	call z,gd3stringcopy ;game name
	call z,gd3stringskip ;game name in Japanese
	call z,gd3stringskip ;system name
	call z,gd3stringskip ;system name in Japanese
	push hl
	ld hl,bystr
	call z,stringcopy
	pop hl
	call z,gd3stringcopy ;author
	ld hl,titlestr
	ld (MUSICTITLEADDR),hl
	ld a,(memorystreampages)
	SETPG8000
	ret

gd3stringcopy
;hl = memorystreamcurrentaddr
;de = dest
;b = bytes remaining
;out: zf=1 if encountered zero terminator, zf=0 if out of space
	memory_stream_read_byte a
	memory_stream_read_byte c
	or a
	ret z
	ld (de),a
	inc de
	djnz gd3stringcopy
	ret

gd3stringskip
;hl = memorystreamcurrentaddr
;out: zf=1
	memory_stream_read_byte a
	memory_stream_read_byte c
	or c
	jr nz,gd3stringskip
	ret

stringcopy
;hl = source
;de = dest
;b = bytes remaining
;out: zf=1 if encountered zero terminator, zf=0 if out of space
	ld a,(hl)
	or a
	ret z
	ld (de),a
	inc hl
	inc de
	djnz stringcopy
	ret

	align 256
cmdtable
	db skip1           %256 ; 00
	db skip1           %256 ; 01
	db skip1           %256 ; 02
	db skip1           %256 ; 03
	db skip1           %256 ; 04
	db skip1           %256 ; 05
	db skip1           %256 ; 06
	db skip1           %256 ; 07
	db skip1           %256 ; 08
	db skip1           %256 ; 09
	db skip1           %256 ; 0A
	db skip1           %256 ; 0B
	db skip1           %256 ; 0C
	db skip1           %256 ; 0D
	db skip1           %256 ; 0E
	db skip1           %256 ; 0F
	db skip1           %256 ; 10
	db skip1           %256 ; 11
	db skip1           %256 ; 12
	db skip1           %256 ; 13
	db skip1           %256 ; 14
	db skip1           %256 ; 15
	db skip1           %256 ; 16
	db skip1           %256 ; 17
	db skip1           %256 ; 18
	db skip1           %256 ; 19
	db skip1           %256 ; 1A
	db skip1           %256 ; 1B
	db skip1           %256 ; 1C
	db skip1           %256 ; 1D
	db skip1           %256 ; 1E
	db skip1           %256 ; 1F
	db skip1           %256 ; 20
	db skip1           %256 ; 21
	db skip1           %256 ; 22
	db skip1           %256 ; 23
	db skip1           %256 ; 24
	db skip1           %256 ; 25
	db skip1           %256 ; 26
	db skip1           %256 ; 27
	db skip1           %256 ; 28
	db skip1           %256 ; 29
	db skip1           %256 ; 2A
	db skip1           %256 ; 2B
	db skip1           %256 ; 2C
	db skip1           %256 ; 2D
	db skip1           %256 ; 2E
	db skip1           %256 ; 2F
	db cmdunsupported  %256 ; 30
	db skip2           %256 ; 31
	db skip2           %256 ; 32
	db skip2           %256 ; 33
	db skip2           %256 ; 34
	db skip2           %256 ; 35
	db skip2           %256 ; 36
	db skip2           %256 ; 37
	db skip2           %256 ; 38
	db skip2           %256 ; 39
	db skip2           %256 ; 3A
	db skip2           %256 ; 3B
	db skip2           %256 ; 3C
	db skip2           %256 ; 3D
	db skip2           %256 ; 3E
	db skip2           %256 ; 3F
	db skip3           %256 ; 40
	db skip3           %256 ; 41
	db skip3           %256 ; 42
	db skip3           %256 ; 43
	db skip3           %256 ; 44
	db skip3           %256 ; 45
	db skip3           %256 ; 46
	db skip3           %256 ; 47
	db skip3           %256 ; 48
	db skip3           %256 ; 49
	db skip3           %256 ; 4A
	db skip3           %256 ; 4B
	db skip3           %256 ; 4C
	db skip3           %256 ; 4D
	db skip3           %256 ; 4E
	db skip2           %256 ; 4F
	db cmdunsupported  %256 ; 50
	db cmdunsupported  %256 ; 51
	db cmdunsupported  %256 ; 52
	db cmdunsupported  %256 ; 53
	db cmdunsupported  %256 ; 54
	db cmdYM2203       %256 ; 55
	db cmdunsupported  %256 ; 56
	db cmdunsupported  %256 ; 57
	db cmdunsupported  %256 ; 58
	db cmdunsupported  %256 ; 59
	db cmdYM3812       %256 ; 5A
	db cmdunsupported  %256 ; 5B
	db cmdunsupported  %256 ; 5C
	db skip3           %256 ; 5D
	db cmdYMF262p0     %256 ; 5E
	db cmdYMF262p1     %256 ; 5F
	db cmdunsupported  %256 ; 60
	db waitn           %256 ; 61
	db wait735         %256 ; 62
	db wait882         %256 ; 63
	db cmdunsupported  %256 ; 64
	db cmdunsupported  %256 ; 65
	db endofsounddata  %256 ; 66
	db processdatablock%256 ; 67
	db skip12          %256 ; 68
	db cmdunsupported  %256 ; 69
	db cmdunsupported  %256 ; 6A
	db cmdunsupported  %256 ; 6B
	db cmdunsupported  %256 ; 6C
	db cmdunsupported  %256 ; 6D
	db cmdunsupported  %256 ; 6E
	db cmdunsupported  %256 ; 6F
	db wait1           %256 ; 70
	db wait2           %256 ; 71
	db wait3           %256 ; 72
	db wait4           %256 ; 73
	db wait5           %256 ; 74
	db wait6           %256 ; 75
	db wait7           %256 ; 76
	db wait8           %256 ; 77
	db wait9           %256 ; 78
	db wait10          %256 ; 79
	db wait11          %256 ; 7A
	db wait12          %256 ; 7B
	db wait13          %256 ; 7C
	db wait14          %256 ; 7D
	db wait15          %256 ; 7E
	db wait16          %256 ; 7F
	db skip1           %256 ; 80
	db wait1           %256 ; 81
	db wait2           %256 ; 82
	db wait3           %256 ; 83
	db wait4           %256 ; 84
	db wait5           %256 ; 85
	db wait6           %256 ; 86
	db wait7           %256 ; 87
	db wait8           %256 ; 88
	db wait9           %256 ; 89
	db wait10          %256 ; 8A
	db wait11          %256 ; 8B
	db wait12          %256 ; 8C
	db wait13          %256 ; 8D
	db wait14          %256 ; 8E
	db wait15          %256 ; 8F
	db skip5           %256 ; 90
	db skip5           %256 ; 91
	db skip6           %256 ; 92
	db skip11          %256 ; 93
	db skip2           %256 ; 94
	db skip5           %256 ; 95
	db cmdunsupported  %256 ; 96
	db cmdunsupported  %256 ; 97
	db cmdunsupported  %256 ; 98
	db cmdunsupported  %256 ; 99
	db cmdunsupported  %256 ; 9A
	db cmdunsupported  %256 ; 9B
	db cmdunsupported  %256 ; 9C
	db cmdunsupported  %256 ; 9D
	db cmdunsupported  %256 ; 9E
	db cmdunsupported  %256 ; 9F
	db cmdAY8910       %256 ; A0
	db skip3           %256 ; A1
	db cmdunsupported  %256 ; A2
	db cmdunsupported  %256 ; A3
	db cmdunsupported  %256 ; A4
	db cmdYM2203dp     %256 ; A5
	db skip3           %256 ; A6
	db skip3           %256 ; A7
	db skip3           %256 ; A8
	db skip3           %256 ; A9
	db cmdYM3812dp     %256 ; AA
	db cmdunsupported  %256 ; AB
	db cmdunsupported  %256 ; AC
	db skip3           %256 ; AD
	db cmdYMF262dp0    %256 ; AE
	db cmdYMF262dp0    %256 ; AF
	db skip3           %256 ; B0
	db skip3           %256 ; B1
	db skip3           %256 ; B2
	db skip3           %256 ; B3
	db skip3           %256 ; B4
	db skip3           %256 ; B5
	db skip3           %256 ; B6
	db skip3           %256 ; B7
	db skip3           %256 ; B8
	db skip3           %256 ; B9
	db skip3           %256 ; BA
	db skip3           %256 ; BB
	db skip3           %256 ; BC
	db skip3           %256 ; BD
	db skip3           %256 ; BE
	db skip3           %256 ; BF
	db skip4           %256 ; C0
	db skip4           %256 ; C1
	db skip4           %256 ; C2
	db skip4           %256 ; C3
	db skip4           %256 ; C4
	db skip4           %256 ; C5
	db skip4           %256 ; C6
	db skip4           %256 ; C7
	db skip4           %256 ; C8
	db skip4           %256 ; C9
	db skip4           %256 ; CA
	db skip4           %256 ; CB
	db skip4           %256 ; CC
	db skip4           %256 ; CD
	db skip4           %256 ; CE
	db skip4           %256 ; CF
	db cmdYMF278B      %256 ; D0
	db skip4           %256 ; D1
	db cmdunsupported  %256 ; D2
	db skip4           %256 ; D3
	db skip4           %256 ; D4
	db skip4           %256 ; D5
	db skip4           %256 ; D6
	db skip4           %256 ; D7
	db skip4           %256 ; D8
	db skip4           %256 ; D9
	db skip4           %256 ; DA
	db skip4           %256 ; DB
	db skip4           %256 ; DC
	db skip4           %256 ; DD
	db skip4           %256 ; DE
	db skip4           %256 ; DF
	db cmdunsupported  %256 ; E0
	db skip5           %256 ; E1
	db skip5           %256 ; E2
	db skip5           %256 ; E3
	db skip5           %256 ; E4
	db skip5           %256 ; E5
	db skip5           %256 ; E6
	db skip5           %256 ; E7
	db skip5           %256 ; E8
	db skip5           %256 ; E9
	db skip5           %256 ; EA
	db skip5           %256 ; EB
	db skip5           %256 ; EC
	db skip5           %256 ; ED
	db skip5           %256 ; EE
	db skip5           %256 ; EF
	db skip5           %256 ; F0
	db skip5           %256 ; F1
	db skip5           %256 ; F2
	db skip5           %256 ; F3
	db skip5           %256 ; F4
	db skip5           %256 ; F5
	db skip5           %256 ; F6
	db skip5           %256 ; F7
	db skip5           %256 ; F8
	db skip5           %256 ; F9
	db skip5           %256 ; FA
	db skip5           %256 ; FB
	db skip5           %256 ; FC
	db skip5           %256 ; FD
	db skip5           %256 ; FE
	db skip5           %256 ; FF
	db skip1           /256 ; 00
	db skip1           /256 ; 01
	db skip1           /256 ; 02
	db skip1           /256 ; 03
	db skip1           /256 ; 04
	db skip1           /256 ; 05
	db skip1           /256 ; 06
	db skip1           /256 ; 07
	db skip1           /256 ; 08
	db skip1           /256 ; 09
	db skip1           /256 ; 0A
	db skip1           /256 ; 0B
	db skip1           /256 ; 0C
	db skip1           /256 ; 0D
	db skip1           /256 ; 0E
	db skip1           /256 ; 0F
	db skip1           /256 ; 10
	db skip1           /256 ; 11
	db skip1           /256 ; 12
	db skip1           /256 ; 13
	db skip1           /256 ; 14
	db skip1           /256 ; 15
	db skip1           /256 ; 16
	db skip1           /256 ; 17
	db skip1           /256 ; 18
	db skip1           /256 ; 19
	db skip1           /256 ; 1A
	db skip1           /256 ; 1B
	db skip1           /256 ; 1C
	db skip1           /256 ; 1D
	db skip1           /256 ; 1E
	db skip1           /256 ; 1F
	db skip1           /256 ; 20
	db skip1           /256 ; 21
	db skip1           /256 ; 22
	db skip1           /256 ; 23
	db skip1           /256 ; 24
	db skip1           /256 ; 25
	db skip1           /256 ; 26
	db skip1           /256 ; 27
	db skip1           /256 ; 28
	db skip1           /256 ; 29
	db skip1           /256 ; 2A
	db skip1           /256 ; 2B
	db skip1           /256 ; 2C
	db skip1           /256 ; 2D
	db skip1           /256 ; 2E
	db skip1           /256 ; 2F
	db cmdunsupported  /256 ; 30
	db skip2           /256 ; 31
	db skip2           /256 ; 32
	db skip2           /256 ; 33
	db skip2           /256 ; 34
	db skip2           /256 ; 35
	db skip2           /256 ; 36
	db skip2           /256 ; 37
	db skip2           /256 ; 38
	db skip2           /256 ; 39
	db skip2           /256 ; 3A
	db skip2           /256 ; 3B
	db skip2           /256 ; 3C
	db skip2           /256 ; 3D
	db skip2           /256 ; 3E
	db skip2           /256 ; 3F
	db skip3           /256 ; 40
	db skip3           /256 ; 41
	db skip3           /256 ; 42
	db skip3           /256 ; 43
	db skip3           /256 ; 44
	db skip3           /256 ; 45
	db skip3           /256 ; 46
	db skip3           /256 ; 47
	db skip3           /256 ; 48
	db skip3           /256 ; 49
	db skip3           /256 ; 4A
	db skip3           /256 ; 4B
	db skip3           /256 ; 4C
	db skip3           /256 ; 4D
	db skip3           /256 ; 4E
	db skip2           /256 ; 4F
	db cmdunsupported  /256 ; 50
	db cmdunsupported  /256 ; 51
	db cmdunsupported  /256 ; 52
	db cmdunsupported  /256 ; 53
	db cmdunsupported  /256 ; 54
	db cmdYM2203       /256 ; 55
	db cmdunsupported  /256 ; 56
	db cmdunsupported  /256 ; 57
	db cmdunsupported  /256 ; 58
	db cmdunsupported  /256 ; 59
	db cmdYM3812       /256 ; 5A
	db cmdunsupported  /256 ; 5B
	db cmdunsupported  /256 ; 5C
	db skip3           /256 ; 5D
	db cmdYMF262p0     /256 ; 5E
	db cmdYMF262p1     /256 ; 5F
	db cmdunsupported  /256 ; 60
	db waitn           /256 ; 61
	db wait735         /256 ; 62
	db wait882         /256 ; 63
	db cmdunsupported  /256 ; 64
	db cmdunsupported  /256 ; 65
	db endofsounddata  /256 ; 66
	db processdatablock/256 ; 67
	db skip12          /256 ; 68
	db cmdunsupported  /256 ; 69
	db cmdunsupported  /256 ; 6A
	db cmdunsupported  /256 ; 6B
	db cmdunsupported  /256 ; 6C
	db cmdunsupported  /256 ; 6D
	db cmdunsupported  /256 ; 6E
	db cmdunsupported  /256 ; 6F
	db wait1           /256 ; 70
	db wait2           /256 ; 71
	db wait3           /256 ; 72
	db wait4           /256 ; 73
	db wait5           /256 ; 74
	db wait6           /256 ; 75
	db wait7           /256 ; 76
	db wait8           /256 ; 77
	db wait9           /256 ; 78
	db wait10          /256 ; 79
	db wait11          /256 ; 7A
	db wait12          /256 ; 7B
	db wait13          /256 ; 7C
	db wait14          /256 ; 7D
	db wait15          /256 ; 7E
	db wait16          /256 ; 7F
	db skip1           /256 ; 80
	db wait1           /256 ; 81
	db wait2           /256 ; 82
	db wait3           /256 ; 83
	db wait4           /256 ; 84
	db wait5           /256 ; 85
	db wait6           /256 ; 86
	db wait7           /256 ; 87
	db wait8           /256 ; 88
	db wait9           /256 ; 89
	db wait10          /256 ; 8A
	db wait11          /256 ; 8B
	db wait12          /256 ; 8C
	db wait13          /256 ; 8D
	db wait14          /256 ; 8E
	db wait15          /256 ; 8F
	db skip5           /256 ; 90
	db skip5           /256 ; 91
	db skip6           /256 ; 92
	db skip11          /256 ; 93
	db skip2           /256 ; 94
	db skip5           /256 ; 95
	db cmdunsupported  /256 ; 96
	db cmdunsupported  /256 ; 97
	db cmdunsupported  /256 ; 98
	db cmdunsupported  /256 ; 99
	db cmdunsupported  /256 ; 9A
	db cmdunsupported  /256 ; 9B
	db cmdunsupported  /256 ; 9C
	db cmdunsupported  /256 ; 9D
	db cmdunsupported  /256 ; 9E
	db cmdunsupported  /256 ; 9F
	db cmdAY8910       /256 ; A0
	db skip3           /256 ; A1
	db cmdunsupported  /256 ; A2
	db cmdunsupported  /256 ; A3
	db cmdunsupported  /256 ; A4
	db cmdYM2203dp     /256 ; A5
	db skip3           /256 ; A6
	db skip3           /256 ; A7
	db skip3           /256 ; A8
	db skip3           /256 ; A9
	db cmdYM3812dp     /256 ; AA
	db cmdunsupported  /256 ; AB
	db cmdunsupported  /256 ; AC
	db skip3           /256 ; AD
	db cmdYMF262dp0    /256 ; AE
	db cmdYMF262dp0    /256 ; AF
	db skip3           /256 ; B0
	db skip3           /256 ; B1
	db skip3           /256 ; B2
	db skip3           /256 ; B3
	db skip3           /256 ; B4
	db skip3           /256 ; B5
	db skip3           /256 ; B6
	db skip3           /256 ; B7
	db skip3           /256 ; B8
	db skip3           /256 ; B9
	db skip3           /256 ; BA
	db skip3           /256 ; BB
	db skip3           /256 ; BC
	db skip3           /256 ; BD
	db skip3           /256 ; BE
	db skip3           /256 ; BF
	db skip4           /256 ; C0
	db skip4           /256 ; C1
	db skip4           /256 ; C2
	db skip4           /256 ; C3
	db skip4           /256 ; C4
	db skip4           /256 ; C5
	db skip4           /256 ; C6
	db skip4           /256 ; C7
	db skip4           /256 ; C8
	db skip4           /256 ; C9
	db skip4           /256 ; CA
	db skip4           /256 ; CB
	db skip4           /256 ; CC
	db skip4           /256 ; CD
	db skip4           /256 ; CE
	db skip4           /256 ; CF
	db cmdYMF278B      /256 ; D0
	db skip4           /256 ; D1
	db cmdunsupported  /256 ; D2
	db skip4           /256 ; D3
	db skip4           /256 ; D4
	db skip4           /256 ; D5
	db skip4           /256 ; D6
	db skip4           /256 ; D7
	db skip4           /256 ; D8
	db skip4           /256 ; D9
	db skip4           /256 ; DA
	db skip4           /256 ; DB
	db skip4           /256 ; DC
	db skip4           /256 ; DD
	db skip4           /256 ; DE
	db skip4           /256 ; DF
	db cmdunsupported  /256 ; E0
	db skip5           /256 ; E1
	db skip5           /256 ; E2
	db skip5           /256 ; E3
	db skip5           /256 ; E4
	db skip5           /256 ; E5
	db skip5           /256 ; E6
	db skip5           /256 ; E7
	db skip5           /256 ; E8
	db skip5           /256 ; E9
	db skip5           /256 ; EA
	db skip5           /256 ; EB
	db skip5           /256 ; EC
	db skip5           /256 ; ED
	db skip5           /256 ; EE
	db skip5           /256 ; EF
	db skip5           /256 ; F0
	db skip5           /256 ; F1
	db skip5           /256 ; F2
	db skip5           /256 ; F3
	db skip5           /256 ; F4
	db skip5           /256 ; F5
	db skip5           /256 ; F6
	db skip5           /256 ; F7
	db skip5           /256 ; F8
	db skip5           /256 ; F9
	db skip5           /256 ; FA
	db skip5           /256 ; FB
	db skip5           /256 ; FC
	db skip5           /256 ; FD
	db skip5           /256 ; FE
	db skip5           /256 ; FF

decompressfiletomemorystream
;de = input file name
;out: zf=1 is successful, zf=0 otherwise
	call openstream_file
	or a
	ret nz
;read the last 4 bytes containing decompressed file size
	ld a,(filehandle)
	ld b,a
	OS_GETFILESIZE
	ld bc,4
	sub hl,bc
	jr nc,$+3
	dec de
	ld a,(filehandle)
	ld b,a
	OS_SEEKHANDLE
	ld de,memorystreamsize
	ld hl,4
	call readstream_file
	ld a,(filehandle)
	ld b,a
	ld hl,0
	ld de,hl
	OS_SEEKHANDLE
;allocate memory
	ld hl,(memorystreamsize+0)
	ld de,(memorystreamsize+2)
	call memorystreamallocate
	jr nz,closefilewitherror
	call memorystreamstart
;decompress
	call setsharedpages
	ld hl,0xffff
	ld (filedatasourceaddr),hl
	ld (savedSP),sp
	call GzipExtract
	call closestream_file
	xor a
	ret

GzipThrowException
savedSP=$+1
	ld sp,0
GzipExitWithError
	call memorystreamfree
closefilewitherror
	call closestream_file
	or 1
	ret

setsharedpages
page8000=$+1
	ld a,0
	SETPG8000
pageC000=$+1
	ld a,0
	SETPGC000
	ret

GzipReadInputBuffer
;de = InputBuffer
;hl = InputBufSize
filedatapage=$+1
	ld a,0
	SETPG8000
filedatasourceaddr=$+1
	ld hl,0
	bit 6,h
	call nz,loadfiledata
	ld bc,InputBufSize
	ldir
	ld (filedatasourceaddr),hl
	ld a,(page8000)
	SETPG8000
	ret

loadfiledata
	exx
	ex af,af'
	push af,bc,de,hl,ix,iy
	ld de,0x8000
	ld hl,0x4000
	call readstream_file
	pop iy,ix,hl,de,bc,af
	exx
	ex af,af'
	ld hl,0x8000
	ld de,InputBuffer
	ret

GzipWriteOutputBuffer
;de = OutputBuffer
;hl = size
	ld a,(memorystreamcurrentpage)
	SETPG8000
	ld bc,hl
	add hl,de
	bit 7,h
	jr z,.below8000
	push hl
	ld bc,0x8000-OutputBuffer
	call memorystreamwrite
	pop hl
	res 7,h
	push hl
	ld de,0x4000
	sub hl,de
	ld a,(page8000)
	jr c,.write8000
	jr z,.write8000
	ex (sp),hl
	SETPGC000
	ld de,0xc000
	ld bc,0x4000
	call memorystreamwrite
	ld a,(pageC000)
.write8000
	SETPGC000
	ld de,0xc000
	pop bc
.below8000
	call memorystreamwrite
	jp setsharedpages

	include "common/gunzip.asm"

initokstr
	db "OK\r\n",0
playernamestr
	db "VGM Player",0
fromstr
	db " [",0
bystr
	db "] by ",0
end

GzipBuffersStart = $
waveheaderbuffer = $
waveheaderbufferend = waveheaderbuffer+WAVEHEADERBUFFERSIZE
titlestr = waveheaderbufferend
titlestrend = titlestr+TITLELENGTH

	assert GzipBuffersEnd <= 0x10000
	assert titlestrend <= 0x8000

	savebin "vgm.bin",begin,end-begin
