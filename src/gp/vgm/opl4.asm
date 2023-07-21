MOONSOUNDROMSIZE = 0x200000
WAVETABLESIZE = 128 ;RAM samples only
WAVEHEADERSIZE = 12
WAVEHEADERBUFFERSIZE = WAVETABLESIZE*WAVEHEADERSIZE

opl4writemusiconlyfm1
;skips writes to control registers
;e = register
;d = value
	ld a,e
	cp 0x20
	jr nc,opl4writefm1
	cp 0x08
	ret nz
opl4writefm1
;e = register
;d = value
	opl4_wait
	ld a,e
	out (MOON_REG1),a
	opl4_wait
	ld a,d
	out (MOON_DAT1),a
	ret

opl4writemusiconlyfm2
;skips writes to control registers
;e = register
;d = value
	ld a,e
	cp 0x05
	jr nz,opl4writefm2
;TODO: skipping write to reg5 leads to a hang on some init sequences, but setting any 
;value to reg5 resets timer state. Is it possible to do something better here?
	ld d,3
	call opl4writefm2
	jp opl4inittimer60hz

opl4writefm2
;e = register
;d = value
	opl4_wait
	ld a,e
	out (MOON_REG2),a
	opl4_wait
	ld a,d
	out (MOON_DAT2),a
	ret

opl4writewavemusiconly
;skips writes to control registers and handles ROM dumps
;e = register
;d = value
	ld a,e
	cp 0x38
	jr nc,opl4writewave
	cp 0x08
	ret c
	cp 0x20
	jr c,writewavetableindexlo
;force wave table index into 384--511 range if ROM data is loaded
isromloaded=$+1
	ld a,0
	or d
	ld d,a
	jr opl4writewave
writewavetableindexlo
	ld a,(isromloaded)
	rrca
	or d
	ld d,a
	call opl4writewave
;wait for the header to load
	in a,(MOON_STAT)
	and 3
	jr nz,$-4
	ret

opl4writewave
;e = register
;d = value
	opl4_wait
	ld a,e
	out (MOON_WREG),a
	opl4_wait
	ld a,d
	out (MOON_WDAT),a
	ret

opl4readwave
;e = register
	opl4_wait
	ld a,e
	out (MOON_WREG),a
	opl4_wait
	in a,(MOON_WDAT)
	ret

	macro opl4_write_fm_regs
;e = base register
;d = value
;l = count
.loop
	call opl4writefm1
	call opl4writefm2
	inc e
	dec l
	jr nz,.loop
	endm

	macro opl4_write_wave_regs
;e = base register
;d = value
;l = count
.loop
	call opl4writewave
	inc e
	dec l
	jr nz,.loop
	endm

opl4init
	xor a
	ld (isromloaded),a
	ld hl,MOONSOUNDROMSIZE%65536
	ld (opl4loadramdatablockheader.romsize0),hl
	ld a,MOONSOUNDROMSIZE/65536
	ld (opl4loadramdatablockheader.romsize2),a
	ld de,0x0305
	call opl4writefm2
	ld l,0xda
	ld de,0x0020
	opl4_write_wave_regs
	ld de,0x1bf8
	call opl4writewave
	ld de,0x1002
	call opl4writewave
	ld l,0xd6
	ld de,0x0020
	opl4_write_fm_regs
	ld de,0x0001
	call opl4writefm1
	ld de,0x0008
	call opl4writefm1
	ld de,0x0004
	call opl4writefm2
	ld de,0x0005
	jp opl4writefm2

opl4mute
	ld de,0x00bd
	call opl4writefm1 ;rhythm off
	ld l,0x16
	ld de,0x0f80
	opl4_write_fm_regs ;max release rate
	ld l,0x16
	ld de,0x3f40
	opl4_write_fm_regs ;min total level
	ld l,0x09
	ld de,0x00a0
	opl4_write_fm_regs ;frequency 0
	ld l,0x09
	ld de,0x00b0
	opl4_write_fm_regs ;key off
	ld l,0x18
	ld de,0x4068
	opl4_write_wave_regs ;key off, damp
	ld de,0x0005
	jp opl4writefm2

opl4setmemoryaddress
;dhl = memory address
	ld e,0x03
	call opl4writewave
	ld d,h
	inc e
	call opl4writewave
	inc e
	ld d,l
	jp opl4writewave

opl4readmemory
;bc = byte count
;dhl = memory address
;ix = buffer
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
.readloop
	opl4_wait
	in a,(MOON_WDAT)
	ld (de),a
	inc de
	djnz .readloop
	dec c
	jr nz,.readloop
	ld de,0x1002
	jp opl4writewave

opl4writememory
;bc = number of bytes
;dhl = memory address
;ix = buffer
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
.writeloop
	opl4_wait
	ld a,(de)
	out (MOON_WDAT),a
	inc de
	djnz .writeloop
	dec c
	jr nz,.writeloop
	ld de,0x1002
	jp opl4writewave

sub24x16
;dhl = minuend
;bc = subtrahend
;out: cf=1 if negative result, zf=1 if zero
	sub hl,bc
	jr c,.carry
	ret nz
	ld a,d
	or a
	ret
.carry
	ld a,d
	sbc a,0
	ld d,a
	ret nz
	ld a,l
	or h
	ret

opl4loadromdatablockheader
;dhl = header+data size
;out: zf=1 if no data to load, dhl = data block size, dhl' = start address
	exx
	call memorybufferread4 ;adbc = total rom size
	ld (opl4loadramdatablockheader.romsize0),bc
	ld a,d
	add 0x20 ;place in RAM
	ld (opl4loadramdatablockheader.romsize2),a
	call memorybufferread4 ;adbc = start address
	ld hl,bc
	set 5,d ;place in RAM
	exx
	ld bc,8
	jr sub24x16

opl4loadramdatablockheader
;dhl = header+data size
;out: zf=1 if no data to load, dhl = data block size, dhl' = start address
	exx
	call memorybufferread4 ;adbc = total ram size
	call memorybufferread4 ;adbc = start address
.romsize0=$+1
	ld hl,0
	add hl,bc
.romsize2=$+1
	ld a,0
	adc a,d
	and 0x3f
	ld d,a
	exx
	ld bc,8
	jr sub24x16

setup24bitscounterloop
;dhl = counter
;out: b = inner loop counter, de = outer loop counter
	ld e,l
	ld bc,1
	sub hl,bc
	jr nc,$+3
	dec d
	ld b,e
	ld e,h
	inc de
	ret

opl4loadsample
;dhl = sample start address
;dhl' = sample size
	ld b,d
	ld de,0x0305
	call opl4writefm2
	ld d,b
	call opl4setmemoryaddress
	ld de,0x1102
	call opl4writewave
	opl4_wait
	ld a,6
	out (MOON_WREG),a
	exx
	call setup24bitscounterloop
	ld hl,(memorybuffercurrentaddr)
.loop
	memory_buffer_read_byte c
	opl4_wait
	ld a,c
	out (MOON_WDAT),a
	djnz .loop
	dec de
	ld a,e
	or d
	jr nz,.loop
	ld (memorybuffercurrentaddr),hl
	ld de,0x1002
	jp opl4writewave

opl4loadramdatablock
;dhl = data+header size
	call opl4loadramdatablockheader
	ret z
	exx
	jr opl4loadsample

opl4loadromdatablock
;dhl = data+header size
	call opl4loadromdatablockheader
	ret z
	exx
	push de
	call opl4loadsample
	pop af
;check if the address is within the first 64K of RAM
	cp 0x21
	ret nc
;patch all 128 headers that LSI can read from RAM
	ld a,1
	ld (isromloaded),a
	ld hl,MOONSOUNDROMSIZE%65536
	ld d,MOONSOUNDROMSIZE/65536
	ld bc,WAVEHEADERBUFFERSIZE
	ld ix,waveheaderbuffer
	call opl4readmemory
	ld hl,waveheaderbuffer
	ld de,WAVEHEADERSIZE
	ld b,WAVETABLESIZE
.loop
	set 5,(hl) ;set base address in RAM area
	add hl,de
	djnz .loop
	ld hl,MOONSOUNDROMSIZE%65536
	ld d,MOONSOUNDROMSIZE/65536
	ld bc,WAVEHEADERBUFFERSIZE
	ld ix,waveheaderbuffer
	jp opl4writememory

opl4inittimer60hz
	ld de,0x2f02
	call opl4writefm1
	ld de,0x2104
	jp opl4writefm1

opl4waittimer60hz
	in a,(MOON_STAT)
	rla
	jr nc,opl4waittimer60hz
	ld de,0x8104
	jp opl4writefm1
