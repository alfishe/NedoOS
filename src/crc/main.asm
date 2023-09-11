        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

STACK=0x4000
TCRC=0x6800 ;size 0x400, divisible by 0x400
DISKBUF=0xc000
DISKBUFsz=0x4000

        org PROGSTART
cmd_begin
        ld sp,STACK
        call initstdio

	; precalculate CRC table
        xor a
        LD L,A
MKTCRC0 EXX 
        LD HL,0
        ld D,H
        ld E,A
        LD B,8
MKTCRC1 SRL H
        RR L
        rr D
        rr E
        JR NC,MKTCRCe
        ex af,af' ;'
        LD A,E
        XOR 0x20
        LD E,A
        ld A,D
        XOR 0x83
        LD D,A
        ld A,L
        XOR 0xB8
        LD L,A
        ld A,H
        XOR 0xED
        LD H,A
        ex af,af' ;'
MKTCRCe DJNZ MKTCRC1
        PUSH HL
        PUSH DE
        EXX 
       LD H,TCRC/256
        POP DE
        LD (HL),E
        INC H
        LD (HL),D
        INC H
        POP DE
        LD (HL),E
        INC H
        LD (HL),D
        INC L
        INC A
        JR NZ,MKTCRC0 


		;get name of the prog as it was called from shell
		ld	hl,COMMANDLINE
	
		call	skipspaces
		or	a
		jp	z,fatal_err	;can't find first non-' ' char -- fatal error

		ld	[name_ptr],hl	;program name

		call	skipword
		or	a
		jp	z,got_no_args
		ld	[hl],0		;zero-terminate program name
		inc	hl
		call	skipspaces
		or	a
		jp	z,got_no_args

		;now HL points to first real arg, start arg parsing loop
parse_args:
		ld	[curr_arg],hl
		;find end of arg and zero-terminate
		call	skipword
		or	a
		push	af
		push	hl
		ld	[hl],0

		call	process_arg

		pop	hl
		pop	af
		jr	z,successful_exit
		inc	hl
		call	skipspaces
		or	a
		jr	nz,parse_args
successful_exit:
		ld	hl,0
		QUIT


AST_DFLT	equ	0

process_arg:	;args parsing routine, has state
		;in: HL=asciiz of current argument

		ld	a,[argp_state]
		or	a
		jr	nz,.no_dflt

;DFLT - wait for switches

		; check for -h or --help
		ld	hl,[curr_arg]
		push	hl
		ld	de,help_arg1
		call	strcmp
		jr	z,.arg_help
		pop	hl
		ld	de,help_arg2
		call	strcmp
		jr	z,.arg_help

		;if not -h or --help -- file to CRC
		;(preliminary, until -c mode is implemented)

		ld	hl,[curr_arg]
		call	process_file
		

		ret


.no_dflt
		jp	error_exit



.arg_help	;print help, exit
		ld	hl,help_msg1
		call	prtext
		ld	hl,[name_ptr]
		call	prtext
		ld	hl,help_msg2
		call	prtext
		jr	successful_exit







process_file:

	ld	de,[curr_arg]
        call openstream_file
        or	a
        jr	nz,.file_error

		ld	hl,0xFFFF
		ld	[CRCArea+0],hl
		ld	[CRCArea+2],hl

.readloop0
        ld de,DISKBUF
        ld hl,DISKBUFsz
;de=buf
;hl=size
        call readstream_file
        ld a,h
        or l
        jr z,.closequit
        ld b,h
        ld c,l
	
	;BC -- size
        ld	hl,DISKBUF
        exx
        LD	DE,(CRCArea+2)
        LD	BC,(CRCArea)
        exx
        call	crc_loop
        exx
        LD	(CRCArea),BC
        LD	(CRCArea+2),DE 

        jr	.readloop0
.closequit
        call closestream_file

		ld	hl,[curr_arg]
		call	prtext

	        ld	hl,txtdblspc
        	call	prtext

        ld hl,CRCArea
        ld a,(hl)
        cpl
        ld (hl),a
        inc hl
        ld a,(hl)
        cpl
        ld (hl),a
        inc hl
        ld a,(hl)
        cpl
        ld (hl),a
        inc hl
        ld a,(hl)
        cpl
        ld (hl),a
        call prhexbyte
        call prhexbyte
        call prhexbyte
        call prhexbyte        
        ld hl,txtcrlf
;;;;;;;;call prtext
		jr	.prtext

.file_error
		ld	hl,[curr_arg]
		call	prtext
		ld	hl,file_error
.prtext
		jp	prtext



fatal_err:		; fatal error so that we can't print even error message
		ld	hl,2
        	QUIT



got_no_args:	; no args given, print short help
	
		ld	hl,[name_ptr]
		push	hl
		call	prtext
		ld	hl,noargs_msg1
		call	prtext
		pop	hl
		call	prtext
		ld	hl,noargs_msg2
		call	prtext
error_exit:
		ld	hl,1
		QUIT


noargs_msg1:	db	": no args given",13,10
		db	"Try '",0
noargs_msg2:	db	" -h' for more information",13,10,0

help_msg1:	db	"Usage: ",0
help_msg2:	db	" [OPTION] [FILE]...",13,10
		db	"Print CRC-32 (0xEDB88320) checksums.",13,10,13,10
;		db	"With no FILE or when file is -, read standard input.",13,10,13,10
;		db	"  -c, --check     read CRCs from the FILEs and check them",13,10
		db	"  -h, --help      display this help and exit",13,10
		db	13,10
		db	0


help_arg1:	db	"-h",0
help_arg2:	db	"--help",0

txtdblspc:	db	"  ",0
txtcrlf:        db	13,10,0

file_error:	db	": Error opening or reading file",13,10,0


strcmp:		;compare strings pointed by HL and DE, case-sensitive.
		;in: hl, de -- ptr to asciiz,
		;out: Z,NC if equal, NZ,NC if str(DE)>str(HL), NZ,C if str(DE)<str(HL)
		;kills: af,de,hl
		;
		ld	a,[hl]
		or	a
		ld	a,[de]
		jr	z,.lastcmp
		or	a
		jr	z,.lastcmp
		
		cp	[hl]
		inc	hl
		inc	de
		jr	z,strcmp
		ret
.lastcmp
		cp	[hl]
		ret




skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

prhexbyte
        ld a,(hl)
        rrca
        rrca
        rrca
        rrca
        call prhexdigit
        ld a,(hl)
        dec hl
prhexdigit
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
        push hl
        PRCHAR_
        pop hl
        ret

prtext
        ld a,(hl)
        or a
        ret z
        push hl
        push iy
        PRCHAR_
        pop iy
        pop hl
        inc hl
        jr prtext
        


name_ptr:	dw	0
curr_arg:	dw	0
argp_state:	db	0


	;bc - size
	;hl - ptr
	;c'b'e'd' - crc
crc_loop
	ld	a,[hl]		;7
	exx			;4

	xor	c		;4
	ld	l,a		;4

	ld	h,TCRC/256	;7
	ld	a,[hl]		;7
	xor	b		;4
	ld	c,a		;4

	inc	h		;4
	ld	a,[hl]		;7
	xor	e		;4
	ld	b,a		;4

	inc	h		;4
	ld	a,[hl]		;7
	xor	d		;4
	ld	e,a		;4

	inc	h		;4
	ld	d,[hl]		;7

	exx			;4
	cpi			;16
	jp	pe,crc_loop	;10
				; == 120 tc/byte
	ret	;10




        include "../_sdk/file.asm"
        include "../_sdk/stdio.asm"

CRCArea
        ds 4,0xff

cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "crc.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
