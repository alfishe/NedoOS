	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

HEADER_DATA_OFFSET = 0x8034
HEADER_CLOCK_YM2203 = 0x8044
HEADER_CLOCK_YM3812 = 0x8050
HEADER_CLOCK_YMF262 = 0x805c
HEADER_CLOCK_YMF278B = 0x8060

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
	ld a,'v'
	cp c
	ret nz
	ld hl,'gm'
	sub hl,de
	ret nz
;prepare local variables
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

playerinit
;hl = shared pages
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld hl,initokstr
	xor a
	ret

	macro a_or_dw addr
	ld hl,(addr)
	or h
	or l
	ld hl,(addr+2)
	or h
	or l
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
	ex de,hl
	ld b,MEMORYBUFFERMAXPAGES
	call memorybufferloadfile
	ret nz

	call memorybufferstart
	ld a,(memorybufferpagecount)
	call setprogressdelta

	set_timer waittimer50hz,882
	ld hl,0
	ld (waitcounter),hl

	ld a,(memorybufferpages)
	SETPG8000
;check if this file uses TFM
	xor a
	a_or_dw HEADER_CLOCK_YM2203
	ld (useYM2203),a
	call nz,initYM2203
;check if this file uses Moonsound
	xor a
	a_or_dw HEADER_CLOCK_YM3812
	a_or_dw HEADER_CLOCK_YMF262
	a_or_dw HEADER_CLOCK_YMF278B
	ld (useYMF278B),a
	call nz,initYMF278B
;skip to the data
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

initYM2203
	call opninit
	set_timer opnwaittimer60hz,735
	jp opninittimer60hz

initYMF278B
	call opl4init
	set_timer opl4waittimer60hz,735
	jp opl4inittimer60hz

musicunload
	ld a,(useYM2203)
	or a
	call nz,opnmute
	ld a,(useYMF278B)
	or a
	call nz,opl4mute
	jp memorybufferfree

playerdeinit
	ret

	include "../_sdk/file.asm"
	include "moonsound.asm"
	include "memorybuffer.asm"
	include "vgm/opl4.asm"
	include "vgm/opn.asm"
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
	memory_buffer_read_1 a
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
	ld hl,(memorybuffercurrentpage)
	ld de,memorybufferpages
	sub hl,de
	ld a,l
	call updateprogress
;continue playing
	or 1
	ret

wait1	ld hl,(waitcounter)
	inc hl
	ld (waitcounter),hl
	ret

waitn	memory_buffer_read_2 e,d
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
	jp memorybufferskip
	endm

skip1	ret
skip2	skip_n 1
skip3	skip_n 2
skip4	skip_n 3
skip5	skip_n 4
skip6	skip_n 5
skip11	skip_n 10
skip12	skip_n 11

cmdunsupported equ endofsounddata

endofsounddata
;stop playing
	pop af
	xor a
	ret

cmdYM2203
	memory_buffer_read_2 e,d
	jp opnwritemusiconlyfm1

cmdYM2203dp
	memory_buffer_read_2 e,d
	jp opnwritemusiconlyfm2

cmdYMF262p0
	memory_buffer_read_2 e,d
	jp opl4writemusiconlyfm1

cmdYMF262p1
	memory_buffer_read_2 e,d
	jp opl4writemusiconlyfm2

cmdYMF278B
	memory_buffer_read_3 c,e,d
	dec c
	jp z,opl4writemusiconlyfm2
	jp p,opl4writewave
	jp opl4writemusiconlyfm1

cmdYM3812
	memory_buffer_read_2 e,d
	jp opl4writemusiconlyfm1

cmdYM3812dp
	memory_buffer_read_2 e,d
	jp opl4writemusiconlyfm2

cmdYMF262dp0 equ memorybufferread2
cmdYMF262dp1 equ memorybufferread2

processdatablock
	memory_buffer_read_2 a,e ;a = 0x66 guard, e = type
	cp 0x66
	jp nz,cmdunsupported
	call memorybufferread4 ;adbc = data size
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
	call memorybufferskip
	dec de
	ld a,e
	or d
	jr nz,.loop
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
	db cmdunsupported  %256 ; A0
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
	db cmdunsupported  /256 ; A0
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

initokstr
	db "OK\r\n",0
playernamestr
	db "VGM Player",0
end

useYM2203 ds 1
useYMF278B ds 1

	savebin "vgm.bin",begin,end-begin
