        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
dns_err_count=25

TN_CMD_SE		EQU 0xF0 ;suboption end
TN_CMD_NOP		EQU 0xF1
TN_CMD_DATAMARK		EQU 0xF2 
TN_CMD_BREAK		EQU 0xF3
TN_CMD_INTERRUPTPROCESS	EQU 0xF4
TN_CMD_ABORTOUTPUT	EQU 0xF5
TN_CMD_AREYOUTHERE	EQU 0xF6
TN_CMD_ERASECHAR	EQU 0xF7
TN_CMD_ERASELINE	EQU 0xF8
TN_CMD_GOAHEAD		EQU 0xF9
TN_CMD_SB		EQU 0xFA ;suboption begin
TN_CMD_WILL		EQU 0xFB
TN_CMD_WONT		EQU 0xFC
TN_CMD_DO		EQU 0xFD
TN_CMD_DONT		EQU 0xFE
TN_CMD_IAC		EQU 0xFF

TN_OP_BINARY		EQU 0x00
TN_OP_ECHO		EQU 0x01
TN_OP_NICREPEAT		EQU 0x02
TN_OP_SGA		EQU 0x03 ;suppress go ahead
TN_OP_NICSIZEDIALOG	EQU 0x04
TN_OP_STATUS		EQU 0x05
TN_OP_TIMINGMARK	EQU 0x06
TN_OP_RCTE		EQU 0x07
TN_OP_NICLENGTH		EQU 0x08
TN_OP_NICOUTPAGESIZE	EQU 0x09
TN_OP_NAOCRD		EQU 0x0A ;Telnet Output Carriage-Return Disposition Option
TN_OP_NAOHTS		EQU 0x0B ;TELNET OUTPUT HORIZONTAL TABSTOPS OPTION
TN_OP_NAOHTD		EQU 0x0C ;TELNET OUTPUT HORIZONTAL TAB DISPOSITION OPTION
TN_OP_NAOFFD		EQU 0x0D ;TELNET OUTPUT FORMFEED DISPOSITION OPTION
TN_OP_NAOVTS		EQU 0x0E ;TELNET OUTPUT VERTICAL TABSTOPS OPTION
TN_OP_NAOVTD		EQU 0x0F ;TELNET OUTPUT VERTICAL TAB DISPOSITION OPTION
TN_OP_NAOLFD		EQU 0x10 ;TELNET OUTPUT LINEFEED DISPOSITION
TN_OP_EXTENDASCII	EQU 0x11 ;TELNET EXTENDED ASCII OPTION
TN_OP_LOGOUT		EQU 0x12
TN_OP_BM		EQU 0x13 ;TELNET Byte Macro Option
TN_OP_DET		EQU 0x14 ;Telnet Data Entry Terminal Option
TN_OP_SUBDUP		EQU 0x15
TN_OP_SUBDUPOUTPUT	EQU 0x16
TN_OP_SENDLOCATION	EQU 0x17
TN_OP_TERMINALTYPE	EQU 0x18
TN_OP_ENDOFRECORD	EQU 0x19
TN_OP_TUID		EQU 0x1A ;TACACS User Identification Telnet Option
TN_OP_OUTMRK		EQU 0x1B
TN_OP_TTYLOC		EQU 0x1C
TN_OP_REGIME		EQU 0x1D
TN_OP_X3PAD		EQU 0x1E
TN_OP_NAWS		EQU 0x1F ;Telnet Window Size Option
TN_OP_TERMINALSPEED	EQU 0x20
TN_OP_TOGGLEFLOWCONTROL	EQU 0x21
TN_OP_LINEMODE		EQU 0x22
TN_OP_XDISPLOC		EQU 0x23
TN_OP_ENVIRON		EQU 0x24
TN_OP_AUTHENTICATION	EQU 0x25
TN_OP_ENCRYPT		EQU 0x26
TN_OP_NEWENVIRON	EQU 0x27
TN_OP_TN3270E		EQU 0x28
TN_OP_XAUTH		EQU 0x29
TN_OP_CHARSET		EQU 0x2A
TN_OP_RSP		EQU 0x2B
TN_OP_COMPORT		EQU 0x2C
TN_OP_SUPPRESSLOCALECHO	EQU 0x2D
TN_OP_STARTTLS		EQU 0x2E
TN_OP_KERMIT		EQU 0x2F
TN_OP_SENDURL		EQU 0x30
TN_OP_FORWARDX		EQU 0x31
TN_OP_EXTENDLIST	EQU 0xFF

TN_ECHO 		EQU 0b00000001
TN_SGA 			EQU 0b00000010
TN_DEBUG		EQU 0b10000000

TN_ST_TEXT		EQU 0
TN_ST_ESC		EQU 1
TN_ST_ANSI		EQU 2

ERR_EAGAIN		EQU 35		;/* Try again */

AF_INET EQU 2

cmd_begin
;init
	ld sp,0x4000
	
	ld e,0x86
	OS_SETGFX ;text mode set
	OS_HIDEFROMPARENT

	OS_GETMAINPAGES ;dehl
	push de
	push hl
	ld e,l
	OS_DELPAGE
	pop hl
	ld e,h
	OS_DELPAGE
	pop de
	OS_DELPAGE


;main
;check cmdline
	ld e,0
	OS_CLS
	call print_nl
	ld hl,COMMANDLINE

telnet_checkkeys ;Check cmdline keys
	call skipword_hl ;skip arg0
	call skipspaces_hl
	ld a,(hl)
	cp '-'
	jr nz,telnet_keysok
	inc hl
	ld a,(hl)
	cp 'd'
	call z,telnet_setkey_d
	cp 'h'
	jp z,telnet_showhelp
	cp 'V'
	jp z,telnet_showversion
	jr telnet_checkkeys

telnet_keysok
	ld de,arg_hostname
	call strcopy_hltode

	ld a,(arg_hostname)
	or a
	jp z, telnet_showusage ;if no hostname show usage

        ld hl,23*256 ;BIG ENDIAN 23
        ld (curport),hl

	display "hostname ", $
        ld hl,arg_hostname
openstream_http_findslash0
         ld a,(hl)
         cp ':'
         jr z,openstream_http_setport
         ;cp '/'
         ;jr z,openstream_http_slash
         or a
         jr z,openstream_http_slash
         inc hl
         jr openstream_http_findslash0
openstream_http_setport
        ld (hl),0 ;end of httphostname
;decode port
        ld de,0 ;oldport
openstream_http_decodeport0
        inc hl
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,openstream_http_decodeportq
        push hl
        ld h,d
        ld l,e
        add hl,hl
        add hl,hl
        add hl,de
        add hl,hl ;hl=oldport*10
        add a,l
        ld e,a
        adc a,h
        sub e
        ld d,a ;de=port
        pop hl
        jr openstream_http_decodeport0
openstream_http_decodeportq
;de=port
        ld a,d
        ld d,e
        ld e,a
        ld (curport),de ;BIG ENDIAN
openstream_http_slash

	ld hl,arg_hostname-1 ;��� �������� � �����
	ld de,ip

telnet_nextdig
	inc hl         ;check for ip-address in arg
	call strtobyte_hltode 
	ld a,(hl)
	cp '.'
	jr z,telnet_nextdig
	ld a,(hl)
	or a
	jr nz,telnet_resolve
	ex hl,de
	ld de,ip
	sbc hl,de
	ld de,4 
	sbc hl,de
	ld a,h
	or l
	jp z,telnet_noresolve ; We have ip in arg

telnet_resolve

	ld de,arg_hostname
	call dns_resolver ; resolving ip
	ld a,h
	or l   ;in HL ip address or zero
	jp z,telnet_resolveerror
	ld de,ip; copy ip
	ld bc,4
	ldir

telnet_noresolve 
curport=$+1
        ld hl,0
        ld (conparam_port),hl


	ld hl,ip
	ld de,txtip ; convert to text
	call telnet_iptostr_hltode

	ld hl,txt_head1 ; showing message connect to blablabla
	call print_hl
	ld hl,arg_hostname
	call print_hl
	ld hl,txt_head2
	call print_hl
	ld hl,txtip
	call print_hl
	ld hl,txt_head3
	call print_hl

;curport=$+1
;	ld bc,23 ; Preparing connect params
	ld hl,ip
        ;ex de,hl
	;ld hl,conparam+1;2
        ;ld (hl),b
        ;inc hl
	;ld (hl),c ; port 23 
        ;ex de,hl
	;inc de
	display "connect ", $
        ld de,conparam_ip
	ld bc,4
	ldir ; copy ip address
	ld de,0x0201 ; AF_INET,SOCK_TCP
	OS_NETSOCKET
	ld a,l 
	   ld c,l ;???
	ld (soc1),a ; save socket to soc1
	or a
	ld hl,txt_socketerror
	jp m, telnet_error_hl

	ld de,conparam
	OS_NETCONNECT ; open socket
	   ld c,a ;???
	ld a,l
	or a
	ld hl,txt_socketopenerror
	jp m, telnet_error_hl

	ld hl,txt_work1 ; connected to
	call print_hl
	ld hl,arg_hostname
	call print_hl
	ld hl,txt_head2
	call print_hl
	ld hl,txtip
	call print_hl
	ld hl,txt_head3
	call print_hl

	ld de,ansi_pal
	OS_SETPAL
	display "main loop ", $
telnet_loop
	call telnet_set_cursor
	YIELDGETKEY
	push af
	call telnet_res_cursor
	pop af
	;ld a,c 
	cp extD ;key_esc ;Sayman
	jp z,telnet_end
	cp NOKEY
	jr z,telnet_purge
	cp key_backspace
	call z,telnet_backspace
	cp key_left
	jp z,telnet_sendleft
	cp key_right
	jp z,telnet_sendright
	cp key_up
	jp z,telnet_sendup
	cp key_down
	jp z,telnet_senddown
	push af
	call telnet_putbyte_a
	pop af

telnet_loop0
	ld bc,(options) ;echo
	bit 0,c
	jr z,telnet_purge
	cp 0x0D
	jr z,telnet_prchar
	cp 0x0A
	jr z,telnet_prchar
	cp 0x20
	jr c,telnet_purge
	cp 0x7F
	jr nc,telnet_purge
telnet_prchar
	PRCHAR
telnet_purge
	call telnet_purge_writebuf
	jr telnet_read

telnet_read_resetstate
	xor a
	ld (read_state),a
telnet_read
	ld a,(read_state)
	cp TN_ST_ESC
	jr z,telnet_esc
	cp TN_ST_ANSI
	jr z,telnet_ansi0
	call telnet_getbyte
	jr nz,telnet_loop
	ld a,(hl)
	cp 0x0D
	jr z,telnet_read_prchar
	cp 0x0A
	jr z,telnet_read_prchar
	cp 0x08
	jr z,telnet_prbackspace
	cp 0x1B ;ESC
	jr z,telnet_esc
	cp 0x20
	jp c,telnet_read
	cp 242;223;128 ;TODO 240?
	jp nc,telnet_noprintable
telnet_read_prchar
	PRCHAR
	jr telnet_read

telnet_prbackspace
	OS_GETXY
	ld a,e
	dec a
	jr c,telnet_read
	ld e,a
	push de
	OS_SETXY
	ld a,' '
	PRCHAR
	pop de
	OS_SETXY
	jr telnet_read


telnet_esc
	ld a,TN_ST_ESC
	ld (read_state),a
	call telnet_getbyte
	jp nz,telnet_loop
	ld a,(hl)
	cp '[' ;CSI
	jr z,telnet_ansi
	jr telnet_read_resetstate

telnet_ansi
	ld a,TN_ST_ANSI
	ld (read_state),a
	ld hl,0
	ld (ansi_cmd),hl
	ld (ansi_anum),hl
	ld (ansi_args),hl
	ld (ansi_args+2),hl
telnet_ansi0
	call telnet_getbyte
	jp nz,telnet_loop
	ld a,(hl)
	call strisdigit_a
	jr z,telnetansi_readargs
	ld a,(hl)
	cp ';'
	jr z,telnetansi_nextarg
	cp '?'
	jr z,telnet_ansi0 ;TODO
	ld a,(hl)
	call strischar_a
	jr z,telnetansi_readcmd
	jp telnet_read_resetstate

telnetansi_nextarg
	ld de,(ansi_anum)
	inc de
	ld (ansi_anum),de
	jp telnet_ansi0

telnetansi_readcmd
	ld a,(hl)
	ld de,ansi_cmd
	ld (de),a
	jr telnetansi_docmd

telnetansi_readargs
	ld a,(hl)
	sub 0x30
	ld hl,ansi_args
	ld de,(ansi_anum)
	add hl,de
	ld d,a ;new digit
	ld a,(hl)
	ld e,a ;old digit
	sla a
	sla a
	add e
	sla a ;multiply by 10
	add d 
	ld (hl),a
	jr telnet_ansi0

telnetansi_docmd
	ld hl,ansi_cmd
	ld a,(ansi_cmd)
	cp 'm'
	jp z,telnetansi_docmd_m ;SGR
	cp 'A'
	jp z,telnetansi_docmd_A ;cursor up
	cp 'B'
	jp z,telnetansi_docmd_B ;cursor down
	cp 'C'
	jp z,telnetansi_docmd_C ;cursor light
	cp 'D'
	jp z,telnetansi_docmd_D ;cursor left
	cp 'E'
	jp z,telnetansi_docmd_E ;cursor x=1 y=y+n
	cp 'F'
	jp z,telnetansi_docmd_F ;cursor x=1 y=y-1
	cp 'G'
	jp z,telnetansi_docmd_G ;cursor x=n
	cp 'H'
	jp z,telnetansi_docmd_H ;cursor x=m y=n
	cp 'J'
	jp z,telnetansi_docmd_J ;n=0 clear screen after x n=1 clear screen before x n=2 clear all
	cp 'K'
	jp z,telnetansi_docmd_K ;n=0 clear line after x n=1 clear line before x n=2 clear whole line
	cp 'S'
	jp z,telnetansi_docmd_S ;scroll up n
	cp 'T'
	jp z,telnetansi_docmd_T ;scroll down n
	cp 'f'
	jp z,telnetansi_docmd_H ;cursor x y
	jp telnet_read_resetstate

telnetansi_docmd_J
	OS_GETXY
	ld a,(ansi_args)
	cp 2
	jr z,telnetansi_docmd_J2
	cp 1
	jr z,telnetansi_docmd_J1
	or a
	jp nz,telnet_read_resetstate
;J0
	ld a,(max_y)
	sub d
	jp z,telnetansi_docmd_K0
	ld b,a
	push de
	ld e,0
	inc d
	OS_SETXY
telnetansi_docmd_J0
	push bc
	ld b,80
	call telnet_print_spaces_b
	pop bc
	djnz telnetansi_docmd_J0
	pop de
	jr telnetansi_docmd_K0

telnetansi_docmd_J1
	ld a,d
	or a
	jp z,telnetansi_docmd_K1
	ld b,d
	push de
	ld de,0
	OS_SETXY
telnetansi_docmd_J10
	push bc
	ld b,80
	call telnet_print_spaces_b
	pop bc
	djnz telnetansi_docmd_J10
	pop de
	jr telnetansi_docmd_K1
telnetansi_docmd_J2
        ld e,0 ;color byte
	OS_CLS
	jp telnet_read_resetstate

;KK
telnetansi_docmd_K
	OS_GETXY
	ld a,(ansi_args)
	cp 2
	jr z,telnetansi_docmd_K2
	cp 1
	jr z,telnetansi_docmd_K1
	or a
	jp nz,telnet_read_resetstate
;J0
telnetansi_docmd_K0
	ld a,(max_x)
	sub e
	ld b,a
	ld a,(max_y)
	sub d
	jp z,telnet_read_resetstate
	inc b
telnetansi_docmd_K0_noscroll
	push de
	call telnet_print_spaces_b
	pop de
	OS_SETXY
	jp telnet_read_resetstate
telnetansi_docmd_K1
	ld a,e
	or a
	jp z,telnet_read_resetstate
	push de
	ld e,0
	OS_SETXY
	pop de
	ld b,e
	dec b
	call telnet_print_spaces_b
	jp telnet_read_resetstate
telnetansi_docmd_K2
	push de
	ld e,0
	OS_SETXY
	ld b,80
	call telnet_print_spaces_b
	pop de
	OS_SETXY
	jp telnet_read_resetstate


telnet_print_spaces_b
	push bc
	ld a,' '
	PRCHAR
	pop bc
	djnz telnet_print_spaces_b
	ret


telnetansi_docmd_S
;CMD_SCROLLUP=0xe7 ;de=topyx, hl=hgt,wid ;x, wid even
	ld de,0
	ld a,(max_y)
	inc a
	ld h,a
	ld a,(max_x)
	inc a
	ld l,a
	ld a,(ansi_args)
	ld b,a
	or a
	jr nz,telnetansi_docmd_S0
	inc b
telnetansi_docmd_S0
	push de
	push hl
	push bc
	OS_SCROLLUP
	pop bc
	pop hl
	pop de
	djnz telnetansi_docmd_S0
	jp telnet_read_resetstate

telnetansi_docmd_T
;CMD_SCROLLDOWN=0xe7 ;de=topyx, hl=hgt,wid ;x, wid even
	ld de,0
	ld a,(max_y)
	inc a
	ld h,a
	ld a,(max_x)
	inc a
	ld l,a
	ld a,(ansi_args)
	ld b,a
	or a
	jr nz,telnetansi_docmd_T0
	inc b
telnetansi_docmd_T0
	push de
	push hl
	push bc
	OS_SCROLLDOWN
	pop bc
	pop hl
	pop de
	djnz telnetansi_docmd_T0
	jp telnet_read_resetstate

telnetansi_docmd_F;;cursor x=1 y up
	OS_GETXY
	ld e,0
	jr telnetansi_docmd_A1
telnetansi_docmd_A ;cursor up
	OS_GETXY
telnetansi_docmd_A1
	ld a,(ansi_args)
	or a
	jr nz,telnetansi_docmd_A0
	ld a,1
telnetansi_docmd_A0
	ld hl,(max_y)
	sub d
	neg
	ld d,a
	cp l
	jr c,telnetansi_docmd_A_ret
	ld d,0
telnetansi_docmd_A_ret
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_E ;cursor x=1 y down
	OS_GETXY
	ld e,1
	jr telnetansi_docmd_B1
telnetansi_docmd_B ;cursor down
	OS_GETXY
telnetansi_docmd_B1
	ld a,(ansi_args)
	or a
	jr nz,telnetansi_docmd_B0
	ld a,1
telnetansi_docmd_B0
	ld hl,(max_y)
	add d
	ld d,a
	cp l
	jr c,telnetansi_docmd_B_ret
	ld d,h
telnetansi_docmd_B_ret
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_C ;cursor right
	OS_GETXY
	ld a,(ansi_args)
	or a
	jr nz,telnetansi_docmd_C0
	ld a,1
telnetansi_docmd_C0
	ld hl,(max_x)
	add e
	ld e,a
	cp l
	jr c,telnetansi_docmd_C_ret
	ld e,h
telnetansi_docmd_C_ret
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_D ;cursor left
	OS_GETXY
	ld a,(ansi_args)
	or a
	jr nz,telnetansi_docmd_D0
	ld a,1
telnetansi_docmd_D0
	ld hl,(max_x)
	sub e
	neg
	ld e,a
	cp l
	jr c,telnetansi_docmd_D_ret
	ld e,0
telnetansi_docmd_D_ret
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_G ;cursor x
	OS_GETXY
	ld a,(ansi_args)
	dec a
	ld hl,(max_x)
	inc hl
	cp l
	jp nc,telnet_read_resetstate
	ld e,a
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_H ;cursor x,y
	ld a,(ansi_args+1)
	or a
	jr z,telnetansi_docmd_H0
	dec a
telnetansi_docmd_H0
	ld hl,(max_x)
	inc hl
	cp l
	jp nc,telnet_read_resetstate ;x
	ld e,a
	ld a,(ansi_args)
	or a
	jr z,telnetansi_docmd_H1
	dec a
telnetansi_docmd_H1
	ld hl,(max_y)
	inc hl
	cp l
	jp nc,telnet_read_resetstate ;y
	ld d,a
	OS_SETXY
	jp telnet_read_resetstate

telnetansi_docmd_m ;SGR
	ld a,(ansi_args)
	or a ;0
	jp z,telnetansi_docmd_mreset
	cp 1
	jr z,telnetansi_docmd_m1
	cp 22
	jr z,telnetansi_docmd_m22
	cp 39
	jr z,telnetansi_docmd_m39
	cp 49
	jr z,telnetansi_docmd_m49
	sub 30
	jp c,telnet_read_resetstate
	sub 8
	jr c,telnetansi_docmd_m30
	sub 2 ;40
	jp c,telnet_read_resetstate
	sub 8
	jr c,telnetansi_docmd_m40
	call printbyte_a
	sub 42 ;90
	jp c,telnet_read_resetstate
	sub 8
	jr c,telnetansi_docmd_m90

	jp telnet_end
telnetansi_docmd_m1
	ld a,(color)
	set 6,a
	jr telnetansi_docmd_m0
telnetansi_docmd_m22
	ld a,(color)
	res 6,a
	jr telnetansi_docmd_m0
telnetansi_docmd_m39
	ld a,(color)
	and 0b10111000
	or  0b00000111 ;default text color
	jr telnetansi_docmd_m0
telnetansi_docmd_m49
	ld a,(color)
	and 0b01000111
	jr telnetansi_docmd_m0
telnetansi_docmd_m90
	add 64-8 ;intensity
telnetansi_docmd_m30
	add 8
	ld d,a
	ld a,(color)
	and 0b11111000
	add d
	jr telnetansi_docmd_m0
telnetansi_docmd_m40
	add 8
	sla a
	sla a
	sla a
	ld d,a
	ld a,(color)
	and 0b11000111
	add d
	jr telnetansi_docmd_m0
telnetansi_docmd_mreset
	ld a,7
telnetansi_docmd_m0
	ld e,a
	ld (color),a
	OS_SETCOLOR
	jp telnet_read_resetstate

telnet_noprintable
	cp TN_CMD_IAC
	jp nz,telnet_read
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	cp TN_CMD_DO
	jr z,telnet_cmd_do
	cp TN_CMD_DONT
	jr z,telnet_cmd_dont
	cp TN_CMD_WILL
	jr z,telnet_cmd_will
	cp TN_CMD_SB
	jp z,telnet_cmd_SB
	jp telnet_read

telnet_cmd_do
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	push af
	cp TN_OP_TERMINALTYPE
	jr z,telnet_cmd_do_will
	cp TN_OP_ECHO
	jr z,telnet_cmd_do_echo
	cp TN_OP_NAWS
	jr z,telnet_cmd_do_naws
	call telnet_sendwont_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_do_naws
	call telnet_sendwill_a
	call telnet_sendnaws
	pop af
	jp telnet_read

telnet_cmd_dont
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	push af
	cp TN_OP_ECHO
	jr z,telnet_cmd_dont_echo
	call telnet_sendwont_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_will
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	push af
	cp TN_OP_ECHO
	jr z,telnet_cmd_dont_echo
;	call telnet_senddont_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_will_do
	call telnet_senddo_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_do_echo
	push af
	ld a,(options)
	or TN_ECHO
	ld (options),a
	pop af
	jr telnet_cmd_do_will

telnet_cmd_do_will
	call telnet_sendwill_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_dont_echo
	push af
	ld a,(options)
	and 255-TN_ECHO
	ld (options),a
	pop af
	jr telnet_cmd_do_dont

telnet_cmd_do_dont
	call telnet_sendwont_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_SB
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	push af
	cp TN_OP_TERMINALTYPE
	jp nz,telnet_cmd_SB_unknown
	pop af
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	cp 1 ; SEND
	push af
	jp nz,telnet_cmd_SB_unknown
	call telnet_sendterminaltype

telnet_cmd_SB_unknown
	pop af
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_read
	ld a,(hl)
	cp TN_CMD_SE
	jp z,telnet_read
	push af
	jr telnet_cmd_SB_unknown

telnet_end
	ld a,(soc1)
	ld E,0 ;close immediately
	OS_NETSHUTDOWN 
	call print_nl
	QUIT

;------------------functions-----------
	include "../_sdk/string.asm"
old_curs_pos
	defw 0
	
telnet_set_cursor
	OS_GETXY
	ld (old_curs_pos),de
	OS_GETATTR
	cpl
	ld e,a
	OS_PRATTR
	ret
	
telnet_res_cursor
	OS_GETXY
	push de
	ld de,(old_curs_pos)
	OS_SETXY
	OS_GETATTR
	cpl
	ld e,a
	OS_PRATTR
	pop de
	OS_SETXY
	ret

telnet_error_hl
	call print_hl
	jp waitquit

telnet_sendleft
	ld hl,ansi_left
	call telnet_sendtext_hl
	jp telnet_loop0

telnet_sendright
	ld hl,ansi_right
	call telnet_sendtext_hl
	jp telnet_loop0

telnet_sendup
	ld hl,ansi_up
	call telnet_sendtext_hl
	jp telnet_loop0

telnet_senddown
	ld hl,ansi_down
	call telnet_sendtext_hl
	jp telnet_loop0


telnet_sendtext_hl ;TODO SLOW  (make direct, not thru putbyte)
	ld a,(hl)
	or a
	ret z
	push hl
	call telnet_putbyte_a
	pop hl
	inc hl
	jr telnet_sendtext_hl

telnet_backspace 
	push af
;	ld a,(options) ;echo off?
;	bit 0,a
;	jr z,telnet_backspace_remote
;	pop af
;	ret
telnet_backspace_remote
	ld a,TN_CMD_ERASECHAR
	call telnet_senddo_a
	pop af
	ret

telnet_sendterminaltype
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_SB
	call telnet_putbyte_a
	ld a,TN_OP_TERMINALTYPE
	call telnet_putbyte_a
	ld a,0 ;IS
	call telnet_putbyte_a
	ld a,'i'
	call telnet_putbyte_a
	ld a,'b'
	call telnet_putbyte_a
	ld a,'m'
	call telnet_putbyte_a
	ld a,'p'
	call telnet_putbyte_a
	ld a,'c'
	call telnet_putbyte_a
	ld a,'3'
	call telnet_putbyte_a
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_SE
	call telnet_putbyte_a
	ret

telnet_sendwillnaws
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_WILL
	call telnet_putbyte_a
	ld a,TN_OP_NAWS
	call telnet_putbyte_a
	ret

telnet_sendnaws
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_SB
	call telnet_putbyte_a
	ld a,TN_OP_NAWS
	call telnet_putbyte_a
	xor a
	call telnet_putbyte_a
	ld a,80
	call telnet_putbyte_a
	xor a
	call telnet_putbyte_a
	ld a,25
	call telnet_putbyte_a
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_SE
	call telnet_putbyte_a
	ret

telnet_senddont_a
	push af
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_DONT
	call telnet_putbyte_a
	pop af
	call telnet_putbyte_a
	ret

telnet_sendwont_a
	push af
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_WONT
	call telnet_putbyte_a
	pop af
	call telnet_putbyte_a
	ret

telnet_senddo_a
	push af
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_DO
	call telnet_putbyte_a
	pop af
	call telnet_putbyte_a
	ret

telnet_sendwill_a
	push af
	ld a,TN_CMD_IAC
	call telnet_putbyte_a
	ld a,TN_CMD_WILL
	call telnet_putbyte_a
	pop af
	call telnet_putbyte_a
	ret

telnet_send_hl ;hl=buf
	ld d,h
	ld e,l
	call telnet_sizeof_hl
	ld h,0
	ld l,a
	ld a,(soc1)
	OS_WIZNETWRITE
	ret

telnet_getbyte;*HL=byte a=FF error
	ld a,(bufindex)
	ld e,a
	ld a,(bufmax)
	cp e
	jr c, telnet_getbyte_read;buffer empty
	ld hl,buf
	ld d,0
	add hl,de
	ld a,e
	inc a
	ld (bufindex),a
	xor a
	or a
	ret
telnet_getbyte_read
	ld hl,255
	ld de,buf
	ld a,(soc1)
	OS_WIZNETREAD
	bit 7,h
	jp z,telnet_getbyte_readed ;no error read
	cp ERR_EAGAIN
	jr z,telnet_getbyte_empty
	jp telnet_end ;error read
telnet_getbyte_readed
	dec hl
	ld a,l
	ld (bufmax),a ;max index
	xor a
	ld (bufindex),a
	jr telnet_getbyte
telnet_getbyte_empty
	ld a,0xFF
	or a
	ret

telnet_putbyte_a;*HL=byte a=FF error
	push af
	ld a,(wrbufindex)
	cp 255
	jr z, telnet_putbyte_full;buffer full
	ld hl,wrbuf
	ld d,0
	ld e,a
	add hl,de
	inc a
	ld (wrbufindex),a
	pop af
	ld (hl),a
	xor a
	or a
	ret
telnet_putbyte_full
	pop af
	ld a,0xFF
	or a
	ret

telnet_purge_writebuf
	ld a,(wrbufindex)
	or a
	ret z
	ld h,0
	ld l,a
	ld a,(soc1)
	ld de,wrbuf
	OS_WIZNETWRITE
	ld a,h
	or a
	ret m
	xor a
	ld (wrbufindex),a
	ret

telnet_sizeof_hl
	ld b,0
telnet_sizeof_hl0
	ld a,(hl)
	or a
	jr z,telnet_sizeof_hl_end
	inc b
	inc hl
	jr telnet_sizeof_hl0
telnet_sizeof_hl_end
	ld a,b
	ret

telnet_setkey_d
	ld a,(options)
	or TN_DEBUG
	ld (options),a
	ret

telnet_resolveerror
	ld e,0
	OS_CLS
	ld hl,txt_resolveerror
	call print_hl
	ld hl,arg_hostname
	call print_hl
	jp waitquit

telnet_iptostr_hltode
	call bytetostr_hltode
	ld a, '.'
	ld (de), a
	inc de
	call bytetostr_hltode
	ld a, '.'
	ld (de), a
	inc de
	call bytetostr_hltode
	ld a, '.'
	ld (de), a
	inc de
	call bytetostr_hltode
	ret

telnet_showusage
	ld e,0
	OS_CLS
	ld hl,txt_usage
	call print_hl
	jp waitquit

telnet_showhelp
	ld e,0
	OS_CLS
	ld hl,txt_version
	call print_hl
	ld hl,txt_usage
	call print_hl
	ld hl,txt_help
	call print_hl
	jp waitquit

telnet_showversion
	ld e,0
	OS_CLS
	ld hl,txt_version
	call print_hl
waitquit
	call waitkey
	QUIT



telnet_debug_a
	push af
	ld a,(options)
	bit 7,a
	jr z,telnet_debug_a_no
	pop af
	call printhex_a
	ret
telnet_debug_a_no
	pop af
	ret

dns_resolver		;DE-domain name
dns_err_loop
	push de
	ld hl,dns_head
	ld de,buf
	ld bc,6
	ldir
	ex de,hl
	ld de,buf+7
	ld (hl),b
	ld  c,256-7
	ldir
	ld de,buf+12
	ld h,d
	ld l,e
	pop bc
name_loop
	inc hl
	ld a,(bc)
	ld (hl),a
	inc bc
	cp '.'
	jr z,is_dot
	or a
	jr nz,name_loop
is_dot
	sbc hl,de
	ex de,hl
	dec e
	ld (hl),e
	inc e
	add hl,de
	ld d,h
	ld e,l
	or a
	jr nz,name_loop
	inc a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	push hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a, (conparam_ip)
	cp 0
	jp nz, skipgetdns
	ld de, conparam_ip;DE= ptr to DNS buffer(4 bytes)
	OS_GETDNS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
skipgetdns:	
	ld de,0x0203
	OS_NETSOCKET
	ld a,l
	ld (soc1),a
	or a
	jp m,dns_exiterr
	;LD DE,conparam
	;OS_NETCONNECT
	;ld a,l
	;or a
	;jp m,dns_exiterr
	
	pop hl
	push hl
	ld de,0xffff&(-buf)
	add hl,de
	LD a,(soc1)
	LD IX,buf
	LD DE,conparam
	OS_WIZNETWRITE
	bit 7,h
	jr nz,dns_exitcode
dns_err_count=$+1
	ld b,25
	jr recv_wait1
recv_wait
	push bc
	YIELD
	pop bc
recv_wait1
	push bc
	ld hl,256
	LD a,(soc1)
	LD ix,buf
	ld de,sa_recv
	OS_WIZNETREAD
	pop bc
	;ld a,h
	;or l
	bit 7,h
	jr z,recv_wait_end
	djnz recv_wait
	jr dns_exiterr
recv_wait_end
	bit 7,h
	jr nz,dns_exitcode
	ld a,(buf+3)
	and 0x0f
	jr nz,dns_exiterr
dns_exitcode
	LD a,(soc1)
	LD E,0
	OS_NETSHUTDOWN
	pop hl
reqpars_l
	inc hl ; Skip compressed
	inc hl ; name
	inc hl ; Type
	ld a,(hl) ; of message
	ld de,7 ; Skip 
	add hl,de ; Class , TTL
	ld b,(hl) ; RDLENGTH
	inc hl
	ld c,(hl)
	inc hl
	dec a
	ret z   ; If TYPE was 0x1 (IP) exit
	cp 4
	jr nz,exiterr1 ; If TYPE was not 0x5 (CNAME) error
	add hl,bc ; to next message
	jr reqpars_l
dns_exiterr
	pop af
	LD a,(soc1)
	LD E,0
	OS_NETSHUTDOWN
	ld a,(dns_err_count)
	add a,a
	ld (dns_err_count),a
	jp nc,dns_err_loop
exiterr1
	ld hl,0
	ret

waitkey
	push bc
	push de
	push hl
keyloop
    GET_KEY
    cp 0
	jp z, keyloop
	pop hl
	pop de
	pop bc
	ret

soc1		db 0
dns_head 	db 0x11,0x22,0x01,0x00,0x00,0x01
conparam	db 0;AF_INET
PORT=53;DNS;14321
conparam_port
                db PORT/256,PORT&255;53 ;port (HSB,LSB)
conparam_ip
                db 0,0,0,0 ;ip
                ds 8 ;reserve
;conparam1
sa_recv
	db 0,0,0,0,0,0,0
        ds 8 ;reserve
buf 		ds 255
bufindex	db 1
bufmax		db 0
wrbuf 		ds 255
wrbufindex	db 0
ip		ds 4
txtip		db 0,0,0,'.',0,0,0,'.',0,0,0,'.',0,0,0,0
options		db 0
ansi_args	db 0,0,0,0,0,0,0
ansi_anum	db 0,0
ansi_cmd	db 0,0
max_x		db 79,0
max_y		db 24,0
color		db 7
ansi_up		db 27,'[','A',0
ansi_down	db 27,'[','B',0
ansi_right	db 27,'[','C',0
ansi_left	db 27,'[','D',0
ansi_pal	dw 0xF3F3,0xF1F1,0xE3E3,0xE1E1,0xF2F2,0xF0F0,0xE2E2,0xE0E0
		dw 0x1313,0xB1B1,0x6363,0x2121,0xD2D2,0x9090,0x4242,0x0000
read_state      db 0 ;0 - text, 1- esc, 2-ansi

;oldtimer ds 2
arg_hostname ds 255

txt_usage db "Use telnet [-d] [-h] [-V] <host_name|ip>",0x0D,0x0A,0
txt_help  db "            -d : Print incoming IAC commands",0x0D,0x0A
          db "            -h : Show this help and exit",0x0D,0x0A
          db "            -V : Show version info and exit",0x0D,0x0A,0
txt_version db "Telnet v0.1 NedoPC group 2019",0x0D,0x0A,0x0d,0x0a,0
txt_resolveerror db "Can not resolve ",0
txt_socketerror db "IP socket creation error",0x0d,0x0a,0
txt_socketopenerror db "IP socket opening error",0x0d,0x0a,0
txt_writeerror db "Something wrong with write",0x0D,0x0A,0
txt_head1 db "Telnet connecting to ",0
txt_head2 db " (",0
txt_head3 db ")...",0x0D,0x0A,0
txt_work1 db "Connected to ",0

cmd_end
	display "Size ",/d,cmd_end-cmd_begin," bytes"
	;display "telnet_loop: ",telnet_loop
	;display "telnet_read: ",telnet_read
	;display "telnet_purge_writebuf: ",telnet_purge_writebuf
	;display "telnet_ansi0: ",telnet_ansi0
	;display "telnet_noresolve: ",telnet_noresolve
	savebin "telnet.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "..\..\us\user.l"
