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

cmd_begin

;init
	ld sp,0x4000
	ld e,6
	OS_SETGFX ;text mode set
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
	call z,ping_setkey_d
/*	cp 's'
	call z,ping_setkey_s
	cp 'i'
	call z,ping_setkey_i
	cp 'c'
	call z,ping_setkey_c*/
	jr telnet_checkkeys

telnet_keysok
	ld de,arg_hostname
	call strcopy_hltode

	ld a,(arg_hostname)
	or a
	jp z, telnet_showusage ;if no hostname show usage

	ld hl,arg_hostname-1 ;для удобства в цикле
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

	ld a,23 ; Preparing connect params
	ld hl,ip
	ld de,conparam+2
	ld (de),a ; port 23 
	inc de
	ld bc,4
	ldir ; copy ip address

	ld de,0x0201 ; AF_INET,SOCK_TCP
	OS_NETSOCKET
	ld a,l 
	ld c,l
	ld (soc1),a ; save socket to soc1
	or a
	ld hl,txt_socketerror ; In c error code
	jp m, telnet_error_hl

	ld de,conparam
	OS_NETCONNECT ; open socket
	ld c,a
	ld a,l
	or a
	ld hl,txt_socketopenerror ; In c error code
	jp m, telnet_error_hl

	ld hl,txt_work1 ; showing message connect to blablabla
	call print_hl
	ld hl,arg_hostname
	call print_hl
	ld hl,txt_head2
	call print_hl
	ld hl,txtip
	call print_hl
	ld hl,txt_head3
	call print_hl

telnet_loop
	YIELDGETKEY
	ld a,c
	push af
	cp key_esc
	jp z,telnet_end
	cp NOKEY
	jr z,telnet_purge
	cp key_backspace
	call z,telnet_backspace

	call telnet_putbyte_a

	ld a,(options) ;echo
	bit 1,a
	jr z,telnet_purge
	pop af
	PRCHAR

telnet_purge
	pop af
	call telnet_purge_writebuf

telnet_read
	call telnet_getbyte
	jr nz,telnet_loop
	ld a,(hl)
	cp 128
	jr nc,telnet_noprintable
	cp 0x1B ;ESC
	jr z,telnet_esc
	PRCHAR
	jr telnet_read

telnet_esc
	call telnet_getbyte
	jr nz,telnet_loop
	ld a,(hl)
	cp '[' ;CSI
	jr z,telnet_ansi
	jr telnet_read

telnet_ansi
	ld b,0
	xor a
	ld hl,ansi_cmd
	ld (hl),a
	ld hl,ansi_anum
	ld (hl),a
telnet_ansi0
	push bc
	call telnet_getbyte
	jr nz,telnet_loop
	ld a,(hl)
	call strisdigit_a
	jr z,telnetansi_readargs
	ld a,(hl)
	call strischar_a
	jr z,telnetansi_readcmd

telnetansi_readcmd
	ld a,(hl)
	ld de,ansi_cmd
	ld (de),a
	jr telnetansi_docmd

telnetansi_readargs
	pop bc
	ld a,(hl)
	ld hl,ansi_args
	ld d,0
	ld e,b
	add hl,de
	ld (hl),a
	inc b
	ld a,b
	ld (ansi_anum),a
	jr telnet_ansi0

telnetansi_docmd
	ld hl,ansi_cmd
	ld a,(ansi_cmd)
	cp 'm'
	jr z,telnetansi_docmd_m
	jp telnet_loop

telnetansi_docmd_m
	ld hl,ansi_anum
	ld e,0x07
	ld a,(hl)
	or a
	jr z,telnetansi_docmd_m0;no args - do sgr reset/normal
	ld hl,ansi_args
	ld a,(hl)
	sub 30
	jp c,telnet_loop
	sub 8
	jp nc,telnet_loop
	add 8
	ld e,a
telnetansi_docmd_m0
	OS_SETCOLOR
	jp telnet_loop

telnet_noprintable
	cp TN_CMD_IAC
	jp nz,telnet_read
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_loop
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
	jp nz,telnet_loop
	ld a,(hl)
	push af
	cp TN_OP_TERMINALTYPE
	jr z,telnet_cmd_do_will
	cp TN_OP_ECHO
	jr z,telnet_cmd_do_echo
	cp TN_OP_NAWS
	jr z,telnet_cmd_do_will
	call telnet_sendwont_a
	pop af
	call telnet_debug_a
	jp telnet_read

telnet_cmd_dont
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_loop
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
	jp nz,telnet_loop
	ld a,(hl)
	push af
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
	jp nz,telnet_loop
	ld a,(hl)
	push af
	cp TN_OP_TERMINALTYPE
	jp nz,telnet_cmd_SB_unknown
	pop af
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_loop
	ld a,(hl)
	cp 1 ; SEND
	push af
	jp nz,telnet_cmd_SB_unknown
	call telnet_sendterminaltype

telnet_cmd_SB_unknown
	pop af
	call telnet_debug_a
	call telnet_getbyte
	jp nz,telnet_loop
	ld a,(hl)
	cp TN_CMD_SE
	jp z,telnet_read
	push af
	jr telnet_cmd_SB_unknown

telnet_end
	ld a,(soc1)
	ld E,0
	OS_NETSHUTDOWN 
	call print_nl
	QUIT

no20 db 0xFF,0xFB,0x18,0xFF,0xFB,0x20,0xFF,0xFB,0x23,0xFF,0xFB,0x27,0
 
;------------------functions-----------
	include "../_sdk/string.asm"

telnet_backspace 
	push af
	ld a,(options) ;echo
	bit 1,a
	jr z,telnet_backspace_remote

	pop af
	ret
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
	ld b,a
	ld a,(bufmax)
	cp b
	jr c, telnet_getbyte_read;buffer empty
	ld hl,buf
	ld d,0
	ld e,b
	add hl,de
	ld a,(bufindex)
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
	ld a,h
	cp 0xFF
	jp z,telnet_end ;error read
	or l
	jr z,telnet_getbyte_empty
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
/*
ping_setkey_c
	inc hl
	call skipspaces_hl
	call strtoushort_hltode
	or a
	ret nz
	ld (icmpcnt),de
	ret

ping_setkey_i
	inc hl
	call skipspaces_hl
	call strtoushort_hltode
	or a
	ret nz
	;check
	push hl
	ex hl,de
;	call printushort_hl
;	call print_nl
	ld de,20
	sbc hl,de ;<20
	jp c,ping_showusage
	add hl,de
	ld (icmpdelay),hl
	pop hl
	ret

ping_setkey_s
	inc hl
	call skipspaces_hl
	ld de,buf
	call strtobyte_hltode
	or a
	ret nz
	ld de,buf
	ld a,(de)
	ld d,a
	;check
	sub 56 ;<56
	jp c,ping_showusage
	add 70 ;>241
	jp c,ping_showusage
	ld a,d
	ld (icmpdatasize),a
	ret
*/
ping_setkey_d
	ld a,(options)
	or TN_DEBUG
	ld (options),a
	ret


ping_printpacket_ix
	ld b,16 ; only first 16 bytes
ping_printpacket_ix0
	push bc
	ld a,(ix)
	ld de,buf
	call bytetohexstr_atode
	ld hl,buf
	call print_hl
	ld a,' '
	PRCHAR
	inc ix
	pop bc
	djnz ping_printpacket_ix0
	call print_nl
	ret


telnet_resolveerror
	ld hl,txt_resolveerror
	call print_hl
	ld hl,arg_hostname


telnet_error_hl
	call print_hl
	ld a,c
	ld de,buf
	call bytetostr_atode
	ld a,':'
	PRCHAR
	ld hl,buf
	call print_hl
	call print_nl
	QUIT

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
	ld hl,txt_usage
	call print_hl
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
	
	ld de,0x0203
	OS_NETSOCKET
	ld a,l
	ld (soc1),a
	or a
	jp m,dns_exiterr
	LD DE,conparam
	OS_NETCONNECT
	ld a,l
	or a
	jp m,dns_exiterr
	
	pop hl
	push hl
	ld de,0xffff&(-buf)
	add hl,de
	LD a,(soc1)
	LD DE,buf
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
	LD DE,buf
	OS_WIZNETREAD
	pop bc
	ld a,h
	or l
	jr nz,recv_wait_end
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



soc1		db 0
dns_head 	db 0x11,0x22,0x01,0x00,0x00,0x01
conparam	db 0,0,53,8,8,8,8
buf 		ds 255
bufindex	db 1
bufmax		db 0
wrbuf 		ds 255
wrbufindex	db 0
ip		ds 4
txtip		db 0,0,0,'.',0,0,0,'.',0,0,0,'.',0,0,0,0
options		db 0
ansi_args	db 0,0,0,0
ansi_anum	db 0
ansi_cmd	db 0

oldtimer ds 2
arg_hostname ds 255

txt_usage db "Use telnet [-d] <host_name|ip>",0x0D,0x0A,0
txt_resolveerror db "Can not resolve ",0
txt_socketerror db "IP socket creation error",0
txt_socketopenerror db "IP socket opening error",0
txt_writeerror db "Something wrong with write",0x0D,0x0A,0
txt_head1 db "Telnet connecting to ",0
txt_head2 db " (",0
txt_head3 db ")...",0x0D,0x0A,0
txt_work1 db "Connected to ",0

cmd_end
	display "Size ",/d,cmd_end-cmd_begin," bytes"
	display "telnet_loop: ",telnet_loop
	display "telnet_read: ",telnet_read
	display "telnet_purge_writebyf: ",telnet_purge_writebuf
	display "telnet_ansi: ",telnet_ansi
	savebin "telnet.com",cmd_begin,cmd_end-cmd_begin

