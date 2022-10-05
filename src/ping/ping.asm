        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
dns_err_count=250
cmd_begin

;init
	YIELD
        OS_GETTIMER ;dehl=timer
	ld (icmpstarttime),hl

	ld sp,0x8000
        call initstdio
	;ld e,6
	;OS_SETGFX ;text mode set

	OS_GETMAINPAGES ;hlde
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

ping_checkkeys ;Check cmdline keys
	call skipword_hl ;skip arg0
	call skipspaces_hl
	ld a,(hl)
	cp '-'
	jr nz,ping_keysok
	inc hl
	ld a,(hl)
	cp 'd'
	call z,ping_setkey_d
	cp 's'
	call z,ping_setkey_s
	cp 'i'
	call z,ping_setkey_i
	cp 'c'
	call z,ping_setkey_c
	cp 'h'
	jp z,ping_showhelp
	cp 'V'
	call z,ping_showversion
	jr ping_checkkeys

ping_keysok
	ld de,arg_hostname
	call strcopy_hltode

	ld a,(arg_hostname)
	or a
	jp z, ping_showusage ;if no hostname show usage

	ld hl,arg_hostname-1 ;для удобства в цикле
	ld de,ip

ping_nextdig
	inc hl         ;check for ip-address in arg
	call strtobyte_hltode 
	ld a,(hl)
	cp '.'
	jr z,ping_nextdig
	ld a,(hl)
	or a
	jr nz,ping_resolve
	ex hl,de
	ld de,ip
	sbc hl,de
	ld de,4 
	sbc hl,de
	ld a,h
	or l
	jp z,ping_noresolve ; We have ip in arg

ping_resolve

	ld de,arg_hostname
	call dns_resolver ; resolving ip
	ld a,h
	or l   ;in HL ip address or zero
	jp z,ping_resolveerror
	ld de,ip; copy ip
	ld bc,4
	ldir

ping_noresolve 

	ld hl,ip
	ld de,txtip ; convert to text
	call ping_iptostr_hltode

	ld hl,txt_head1 ; showing message ping to blablabla
	call print_hl
	ld hl,arg_hostname 
	call print_hl
	ld hl,txt_head2
	call print_hl
	ld hl,txtip
	call print_hl
	ld hl,txt_head3
	call print_hl
	ld a,(icmpdatasize)
	call printbyte_a
	ld a,'('
	PRCHAR_
	ld a,(icmpdatasize)
	add 8+6 ; header icmp + header ip
	call printbyte_a
	ld a,')'
	PRCHAR_
	ld hl,txt_head4
	call print_hl
	xor a ; Preparing connect params
	ld hl,ip
	ld de,conparam+2
	ld (de),a ; No port set for ipraw mode
	inc de
	ld bc,4
	ldir ; copy ip address

	ld de,0x0202 ; AF_INET,SOCK_ICMP
	OS_NETSOCKET
	ld a,l 
	ld c,l
	ld (soc1),a ; save socket to soc1
	or a
	ld hl,txt_socketerror ; In c error code
	jp m, ping_error_hl

	;ld de,conparam
	;OS_NETCONNECT ; open socket
	;ld c,a
	;ld a,l
	;or a
	;ld hl,txt_socketopenerror ; In c error code
	;jp m, ping_error_hl

	ld bc,(icmpcnt) ; num of packets
ping_loop
	push bc
	call ping_buildicmppacket

	ld hl,(icmpdatasize)
	ld de,8 ; header 8 bytes
	add hl,de
	ld a,(soc1)
	ld ix,icmppacket ; send icmp packet
	ld de,conparam

	OS_WIZNETWRITE
	ld a,h
	or a
	jp p,ping_nowriteerr
	ld hl,txt_writeerror
	call print_hl

ping_nowriteerr
	ld b,250 ; 250 tries*20ms= about 5s+code execution
ping_loopwait
	push bc
	ld hl,256 ; try to read all buff with trash bytes.
	ld a,(soc1)
	ld ix,icmppacket; Don't worry after icmppacket - buf 256bytes
	ld de,sa_recv
	OS_WIZNETREAD
	pop bc
	;ld a,h
	;or l
	bit 7,h
	jr z,ping_loopreceived
	push bc
	;YIELDGETKEY
        YIELD
        GETKEY_
	ld a,c
	cp key_esc
	jr z,ping_end
	pop bc
	djnz ping_loopwait ; if read zero bytes
	ld hl,(icmperr); timeout
	inc hl
	ld (icmperr),hl ; inc packet loss count
	ld hl,txt_timeout
	call print_hl 
	pop bc
	dec bc
	ld a,b
	or c
	jp nz, ping_loop 
	jr ping_end ; if tries more than icmpcnt

ping_loopreceived

	ld ix,icmppacket
	ld hl,(ix+STicmpreq.id)
	ld de,(icmpoldid)
	or a
	sbc hl,de
	jr nz,ping_loopwait
	call icmpchecksum_ixtohl
	inc hl ; checksum of cheksummed packet always 0xFFFF
	ld a,h
	or l
	ld (crc),a
	jr z, ping_nocrc
	ld hl,(icmperr) ; inc packet loss count
	inc hl
	ld (icmperr),hl
	jr ping_crc
ping_nocrc
	ld hl,(icmprcvd)
	inc hl
	ld (icmprcvd),hl
ping_crc
	call ping_printwork 
	call ping_wait ; wait for some time
	pop bc 
	dec bc
	ld a,b
	or c
	jp nz, ping_loop 

ping_end
	ld a,(soc1)
	ld E,0
	OS_NETSHUTDOWN 

	call ping_printstat

	QUIT


;------------------functions-----------
	include "string.asm"

ping_updateminmaxhl
	push hl
	or a
	ld de,(icmpmin)
	sbc hl,de
	pop hl
	jr nc,ping_updateminmaxhl_next
	ld (icmpmin),hl
ping_updateminmaxhl_next
	push hl
	ld de,(icmpmax)
	sbc hl,de
	pop hl
	ret c
	ld (icmpmax),hl
	ret

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
	jp c,ping_showhelp
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
	jp c,ping_showhelp
	add 70 ;>241
	jp c,ping_showhelp
	ld a,d
	ld (icmpdatasize),a
	ret

ping_setkey_d
	ld a,1
	ld (icmpshowpacket),a
	ret

ping_printstat

	ld hl,txt_tail1
	call print_hl
	ld hl,arg_hostname
	call print_hl
	ld hl,txt_tail2
	call print_hl
	ld hl,(icmpnum)
	call printushort_hl
	ld hl,txt_tail3
	call print_hl
	or a
	ld hl,(icmpnum)
	ld de,(icmprcvd)
	sbc hl,de
	ex hl,de
	push de
	call printushort_hl
	ld hl,txt_tail4
	call print_hl

;print % lost
	pop de
	ld h,d
	ld l,e
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl ; multiply by 100
	ld a,0xFF
	or a
	ld de,(icmpnum)
ping_printstat0
	inc a
	sbc hl,de
	jr nc,ping_printstat0
	call printbyte_a
	ld hl,txt_tail5
	call print_hl

;print overal time
	YIELD 
        OS_GETTIMER ;dehl=timer
	ld de,(icmpstarttime)
	or a
	sbc hl,de
	ld d,h
	ld e,l
	add hl,hl ;multiply by 20ms
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	call printushort_hl

;print rtt
	ld hl,txt_tail6
	call print_hl
;rtt
;min
	ld hl,(icmpmin)
	call printushort_hl
	ld a,'/'
	PRCHAR_
;avg icmppacketstime/(icmpnum-icmperr)
	or a
	ld hl,(icmpnum)
	ld de,(icmperr)
	sbc hl,de
	ex hl,de
	ld hl,(icmppacketstime)
	ld bc,0xFFFF
ping_printstat1
	inc bc
	or a
	sbc hl,de
	jr nc,ping_printstat1
	ld h,b
	ld l,c
	call printushort_hl
	ld a,'/'
	PRCHAR_
;max
	ld hl,(icmpmax)
	call printushort_hl
	ld hl,txt_tail7
	call print_hl
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
        push ix
	ld a,' '
	PRCHAR_
        pop ix
	inc ix
	pop bc
	djnz ping_printpacket_ix0
	call print_nl
	ret

ping_printwork
	ld hl,txt_work1
	call print_hl
	ld hl,arg_hostname
	call print_hl
	ld a,' '
	PRCHAR_
	ld a,'('
	PRCHAR_
	ld hl,txtip
	call print_hl
	ld hl,txt_work2
	call print_hl

	ld hl,txt_crc
	ld a,(crc)
	or a
	jr nz,ping_printwork_crc
	ld a,(icmppacket.num); if no crc print packet num
	ld h,a
	ld a,(icmppacket.num+1)
	ld l,a
	ld de,buf
	call ushorttostr_hltode
	ld hl,buf
ping_printwork_crc
	call print_hl
	ld hl,txt_work3
	call print_hl
	;YIELD ; update current time in "oldtimer"
        OS_GETTIMER ;dehl=timer
	ld a,(icmppacket.data+6)
	ld d,a
	ld a,(icmppacket.data+7)
	ld e,a
	 or a
	sbc hl,de
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl; multiply by 20ms
	ex hl,de
	ld hl,(icmppacketstime) ; add to total packet time
	add hl,de
	ld (icmppacketstime),hl
	ex hl,de
	call ping_updateminmaxhl
	call printushort_hl
	ld hl,txt_work4
	call print_hl
	ld a,(icmpshowpacket) ; want to show packet content?
	or a
	ret z
	ld ix,icmppacket
	call ping_printpacket_ix
	ret


ping_resolveerror
	ld hl,txt_resolveerror
	call print_hl
	ld hl,arg_hostname
	call print_hl
	call print_nl

ping_error_hl
	call print_hl
	QUIT

ping_wait
	ld bc,(icmpdelay)
ping_wait0
	push bc
	;YIELDGETKEY ;out: nz=nokey, a=keylang, c=keynolang
        YIELD
        GETKEY_
	ld a,c
	cp key_esc
	jp z,ping_end
	pop hl
	ld de,19
	or a
	sbc hl,de
	push hl
	pop bc
	jr nc,ping_wait0
	ret

ping_buildicmppacket
	ld ix,icmppacket
	ld (ix + STicmpreq.type),8
	ld (ix + STicmpreq.code),0
	ld (ix + STicmpreq.checksum),0
	ld (ix + STicmpreq.checksum+1),0
	ld hl,(icmpnextid)
	ld (ix + STicmpreq.id),hl
	ld (icmpoldid),hl
	ld hl,(icmpnum)
	inc hl
	ld (icmpnum),hl
	ld (ix + STicmpreq.num),h
	ld (ix + STicmpreq.num+1),l
        OS_GETTIMER ;dehl=timer
	ld (ix + STicmpreq.data),h
	ld (ix + STicmpreq.data+1),l
	ld (ix + STicmpreq.data+2),h
	ld (ix + STicmpreq.data+3),l
	ld (ix + STicmpreq.data+4),h
	ld (ix + STicmpreq.data+5),l
	ld (ix + STicmpreq.data+6),h
	ld (ix + STicmpreq.data+7),l
	call icmpchecksum_ixtohl
	ld (icmpnextid),hl
	ld (ix + STicmpreq.checksum),h
	ld (ix + STicmpreq.checksum+1),l
	ret

icmpchecksum_ixtohl
	push ix
	ld hl,(icmpdatasize)
	ld de,8 ; header
	add hl,de
	srl h
	rr l ; divide by 2
	ld b,l; words
	ld hl,0
	or a
icmpchecksum_loop
	ld d, (ix)
	ld e, (ix+1)
	adc hl,de
	inc ix
	inc ix
	djnz icmpchecksum_loop
	ex hl,de
	ld hl,0
	scf
	sbc hl,de
	pop ix
	ld a,h
	cp l
	ret nz
	ld hl,0xffff
	ret

ping_iptostr_hltode
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

ping_showusage
	ld hl,txt_usage
	call print_hl
	QUIT

ping_showversion
	ld hl,txt_version
	call print_hl
	QUIT

ping_showhelp
	ld hl,txt_usage
	call print_hl
	ld hl,txt_help
	call print_hl
	QUIT

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
	ld a, (dns_ia2)
	cp 0
	jp nz, skipgetdns
	ld de, dns_ia2;DE= ptr to DNS buffer(4 bytes)
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

ping_printcrc
	ld hl,txt_crc
	call print_hl
	call print_nl
	ret


	STRUCT STicmpreq
type		BYTE
code		BYTE
checksum	WORD
id		WORD
num		WORD
data		ds 8
	ENDS

soc1		db 0
dns_head 	db 0x11,0x22,0x01,0x00,0x00,0x01
conparam	db 0,0,53
dns_ia2
			db 0,0,0,0
sa_recv		defs 7
icmppacket 	STicmpreq
buf 		ds 255
ip		ds 4
txtip		db 0,0,0,'.',0,0,0,'.',0,0,0,'.',0,0,0,0

icmpdatasize db 56,0
icmpnum db 0,0
icmpcnt db 0xFF,0xFF
icmpnextid db 0x53,0x53
icmpoldid db 0,0
icmperr db 0,0
icmprcvd db 0,0
icmpstarttime db 0,0
icmppacketstime db 0,0
icmpshowpacket db 0
icmpdelay db 0xE8,0x03 ;1000ms
icmpmin db 0xFF,0xFF
icmpmax db 0,0
crc db 0

;oldtimer ds 2
arg_hostname ds 255

txt_usage db "Use ping [-c count] [-d] [-h] [-i interval] [-s size] [-V] <host_name|ip>",0x0D,0x0A,0
txt_help  
	  db "   -c count : Stop after sending count (1-65535) packets. Default 65535",0x0D,0x0A
	  db "         -d : Print first 16 bytes icmp packet to send",0x0D,0x0A
	  db "         -h : Show this help and exit",0x0D,0x0A
	  db "-i interval : Wait interval between sending each packet. Min 20, max 65535.",0x0d,0x0a
	  db "             Default 1000ms",0x0D,0x0A
	  db "    -s size : Specifies the number of data bytes to send. Min 56 (default), ",0x0d,0x0a
	  db "             max 241",0x0D,0x0A
	  db "         -V : Show version info and exit",0x0D,0x0A,0
txt_version db "Ping v0.1",0x0d,0x0a,"Nedopc group 2019",0x0d,0x0a,0
txt_head1 db "PING ",0
txt_head2 db " (",0
txt_head3 db ") ",0
txt_head4 db " bytes of data.",0x0D,0x0A,0
txt_resolveerror db "Can not resolve ",0
txt_socketerror db "IP socket creation error",0x0D,0x0A,0
txt_socketopenerror db "IP socket opening error",0x0D,0x0A,0
txt_writeerror db "Something wrong with write",0x0D,0x0A,0
txt_crc db "CRC",0
txt_timeout db " timeout",0x0D,0x0A,0
txt_work1 db "Echo from ",0
txt_work2 db "): icmp_seq=",0
txt_work3 db " time=",0
txt_work4 db " ms",0x0D,0x0A,0
txt_tail1 db "--- ",0
txt_tail2 db " ping statistics ---",0x0D,0x0A,0
txt_tail3 db " packets transmitted, ",0
txt_tail4 db " received, ",0
txt_tail5 db "% packet loss, time ",0
txt_tail6 db " ms",0x0D,0x0A,"rtt min/avg/max = ",0
txt_tail7 db " ms",0x0D,0x0A,0

        include "../_sdk/stdio.asm"

cmd_end
	display "Size ",/d,cmd_end-cmd_begin," bytes"
	savebin "ping.com",cmd_begin,cmd_end-cmd_begin

	LABELSLIST "../../us/user.l"
