        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

STACK=0x4000

TCRC=0x4000 ;size 0x400, divisible by 0x100

LISTBUF		equ	0x4400
LISTBUFsz	equ	0x200

DISKBUF=0xc000
DISKBUFsz=0x4000

CHKSYMLEN	equ	8 ;length of checksum in hex: 8 for CRC32

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
AST_FILES	equ	1
AST_CHK		equ	2

process_arg:	;args parsing routine, has state
		;in: HL=asciiz of current argument

		ld	a,[argp_state]
		or	a
		jr	nz,.no_dflt

;DFLT - wait for switches

		; check for -h or --help
		ld	hl,[curr_arg]
		push	hl
		ld	de,help_arg
		call	strcmp
		jr	z,.arg_help

		pop	hl
		ld	de,chk_arg
		call	strcmp
		jr	z,.arg_chk

		; set FILES mode
		ld	a,AST_FILES
		ld	[argp_state],a
.chksum_arg
		ld	hl,[curr_arg]
		jp	process_file
.no_dflt
		dec	a
		jr	z,.chksum_arg
		; FILES mode -- go to .chksum_arg
.no_files
		dec	a
		jr	nz,.no_check
		;CHECK mode
		call	process_list
.no_check
		jp	error_exit



.arg_help	;print help, exit
		ld	hl,help_msg1
		call	prtext
		ld	hl,[name_ptr]
		call	prtext
		ld	hl,help_msg2
		call	prtext
		jr	successful_exit


.arg_chk	;check mode

		ld	a,AST_CHK
		ld	[argp_state],a
		ret




process_list:	;argument = filename, open it, read crcs and filenames, check

		;open file by name
		;
		ld	de,[curr_arg]
		OS_OPENHANDLE
		;b - handle, a!=0 - error
		or	a
		jp	nz,.error_open
		ld	a,b
		ld	[list_hndl],a

		xor	a
		ld	[lpush],a
		ld	h,a
		ld	l,a
		ld	[lsz],hl



		;main loop: FSM to parse the file with checksums and filenames.
		;format:
		;
		;<BOL>XXXXXXXX<space><space><filename><EOL>
		;
		;<BOL> -- not a real symbol, just an indication that this is the beginning of line
		;XXXXXXXX -- checksum in hex, must be of predefined length (8 for CRC32)
		;<space> -- 0x20
		;<filename> -- file that will be attempted to open.
		;<EOL> -- <crlf> or <cr> or <lf>, last line from file is not obliged to end with these

.new_line
		;check for EOF
		call 	my_getc
		jr	nc,.have_bytes

.full_end	;correct end of the file
		ld	bc,[list_hndl-1]
		OS_CLOSEHANDLE
		ret

.have_bytes	call	my_ungetc

		;parse checksum
		ld	b,CHKSYMLEN
		ld	hl,CHKSUM
.chksum_loop
		call	my_getc
		jp	c,.line_unexp_end
		call	is_hex
		jp	c,.line_format_error

		ld	[hl],a
		inc	hl
		djnz	.chksum_loop
		ld	[hl],0

		;parse two spaces
		ld	b,2
.chkspc_loop
		call	my_getc
		jr	c,.line_unexp_end
		cp	' '
		jr	nz,.line_format_error
		djnz	.chkspc_loop

		;parse filepath/name
		ld	b,MAXPATH_sz&255 ;now it is 256
		ld	hl,FNAME
.chkfname_loop
		call	my_getc
		jr	c,.line_last_end
		cp	' '	;space -- end of path/fname
		jr	z,.end_fname
		cp	13	;13 or 10 -- end of path/fname
		jr	z,.end_fname
		cp	10
		jr	z,.end_fname
		
		ld	[hl],a
		inc	hl
		djnz	.chkfname_loop
		ld	[hl],0

		;check whether there's more in input stream
		call	my_getc
		jr	c,.line_last_end
		cp	' '
		jr	z,.end_fname
		cp	13
		jr	z,.end_fname
		cp	10
		jr	z,.end_fname

.fname_error	;if path/filename seems to be greater than MAXPATH_sz or zero-sized
		jr	$	;STUB

.line_last_end	;here if EOF condition while parsing '-c filename'
		ld	[hl],0

		;check for zero-length path/filename
		exd	
		ld	hl,FNAME
		or	a
		sbc	hl,de
		exd
		jr	z,.fname_error
		jr	.no_errs

.end_fname
		call	my_ungetc	;return space/13/10 to the input stream;
					;will be used later as to look for a new line
		
		;check for zero-length path/filename
		exd
		ld	hl,FNAME
		or	a
		sbc	hl,de
		exd
		jr	z,.fname_error

		;no errors here
.no_errs	;hl=FNAME
		ld	[hl],0
		ld	hl,FNAME
		call	process_file

.skip_line	;scan till end of filename/whatever, skip extra spaces/etc., skip line end
		call	my_getc
		jp	c,.full_end
		cp	13
		jr	z,.eol_13
		cp	10
		jr	nz,.skip_line
.eol_10
		jr	.new_line2
.eol_13
		call	my_getc
		cp	10
		jr	z,.new_line2
		call	my_ungetc
.new_line2
		jp	.new_line



.line_format_error
.line_unexp_end
		ld	hl,[name_ptr]
		call	prtext
		ld	hl,name_to_file
		call	prtext
		ld	hl,[curr_arg]
		call	prtext
		ld	hl,format_error
		jr	.prtext2



.error_open
		ld	hl,[name_ptr]
		call	prtext
		ld	hl,name_to_file
		call	prtext
		ld	hl,[curr_arg]
		call	prtext
		ld	hl,file_error
.prtext2
		jp	prtext





my_getc:	;get a symbol from list_hdnl:lptr:lsz:etc. construction
		;
		;out: A - symbol
		;     cy=1 - no more symbols or error

		ld	a,[lpush]
		or	a
		jr	z,.no_ununget
		;
		xor	a
		ld	[lpush],a
		ld	a,[lpbyte]
		ret
.no_ununget
		push	hl
		ld	hl,[lsz]
		ld	a,h
		or	l
		jr	z,.buf_empty
.no_ununget2
		dec	hl
		ld	[lsz],hl
		ld	hl,[lptr]
		ld	a,[hl]
		inc	hl
		ld	[lptr],hl
		pop	hl
		ret
.buf_empty
		push	ix
		push	iy
		push	bc
		push	de
		
		ld	a,[list_hndl]
		ld	b,a
		ld	de,LISTBUF
		ld	[lptr],de
		ld	hl,LISTBUFsz
		OS_READHANDLE
		ld	a,h
		or	l
		ld	[lsz],hl
		
		pop	de
		pop	bc
		pop	iy
		pop	ix
		
		jr	nz,.no_ununget2
.nothing_more
		pop	hl
		scf
		ret



my_ungetc:	;unget a symbol (there can be only a single ungot symbol!)
		;in: A - symbol

		push	af
		ld	a,[lpush]
		or	a
		jr	nz,$
		inc	a
		ld	[lpush],a
		pop	af
		ld	[lpbyte],a
		ret



is_hex:		;check that A is hex, i.e. [0-9][A-F][a-f]
		;in: A
		;out: cy=1: *NOT* hex. A is saved

		cp	'0'
		ret	c
		cp	'9'+1
		ccf
		ret	nc

		cp	'A'
		ret	c
		cp	'F'+1
		ccf
		ret	nc
		
		cp	'a'
		ret	c
		cp	'f'+1
		ccf
		ret


process_file:
		;hl = asciiz filename
		ld	[file_name],hl

	ld	de,[file_name]
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
	        
	        ld	hl,txtdblspc
        	call	prtext

		ld	hl,[curr_arg]
		call	prtext

		ld	hl,txtcrlf
		jr	.prtext

.file_error
		ld	hl,[file_name]
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
		db	"  -c   read CRCs from the FILEs and check them.",13,10
		db	"       file format: ^<CRC><space><space><filename><EOL>",13,10
		db	"  -h   display this help and exit",13,10
		db	13,10
		db	0


help_arg:	db	"-h",0
chk_arg:	db	"-c",0

txtdblspc:	db	"  ",0
txtcrlf:        db	13,10,0

file_error:	db	": Error opening or reading file",13,10,0
format_error:	db	": File format error",13,10,0

name_to_file:	db	": ",0



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
file_name:	dw	0
argp_state:	db	0

list_hndl:	db	0

lpush:		db	0
lpbyte:		db	0
lptr:		dw	0
lsz:		dw	0




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



CHKSUM	ds	CHKSYMLEN+1	;checksum to check, taken from '-c filename' file
FNAME	ds	MAXPATH_sz+1	;file/path to check, taken from '-c filename' file



cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "crc.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
