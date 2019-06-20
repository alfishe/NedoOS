        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
dns_err_count=25
cmd_begin

;init
	ld sp,0x8000
	ld e,6
	OS_SETGFX ;text mode set
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
	cp 'p'
	call z,ping_setkey_p
	jr ping_checkkeys

ping_keysok
	ld de,arg_hostname
	call strcopy_hltode

	ld a,(arg_hostname)
	or a
	jp z, show_usage ;if no hostname show usage

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
	PRCHAR
	ld a,(icmpdatasize)
	add 8+6 ; header icmp + header ip
	call printbyte_a
	ld a,')'
	PRCHAR
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

	ld de,conparam
	OS_NETCONNECT ; open socket
	ld c,a
	ld a,l
	or a
	ld hl,txt_socketopenerror ; In c error code
	jp m, ping_error_hl

	YIELD 

	ld bc,(icmpcnt) ; num of packets
ping_loop
	push bc
	call ping_buildicmppacket

	ld hl,(icmpdatasize)
	ld de,8 ; header 8 bytes
	add hl,de
	ld a,(soc1)
	ld de,icmppacket ; send icmp packet

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
	ld de,icmppacket; Don't worry after icmppacket - buf 256bytes
	OS_WIZNETREAD
	pop bc
	ld a,h
	or l
	jr nz,ping_loopreceived
	push bc
	YIELD
	pop bc
	djnz ping_loopwait ; if read zero bytes
	ld hl,(icmperr); timeout
	inc hl
	ld (icmperr),hl ; inc packet loss count
	ld hl,txt_timeout
	call print_hl 
	pop bc
	djnz ping_loop
	jr ping_end ; if tries more than icmpcnt

ping_loopreceived

	ld ix,icmppacket
	call icmpchecksum_ixtohl
	inc hl ; checksum of cheksummed packet always 0xFFFF
	ld a,h
	or l
	ld (crc),a
	jr z, ping_nocrc
	ld hl,(icmperr) ; inc packet loss count
	inc hl
	ld (icmperr),hl
ping_nocrc

	call ping_printwork 
	call ping_wait ; wait for some time
	pop bc 
	ld a,b
	dec a
	ld b,a
	or a
	jp nz, ping_loop 

ping_end
	ld a,(soc1)
	ld E,0
	OS_NETSHUTDOWN 

	call ping_printstat

	QUIT


;------------------functions-----------
	include "../_sdk/string.asm"

ping_setkey_p
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
	ld a,(icmpnum)
	call printbyte_a
	ld hl,txt_tail3
	call print_hl
	ld hl,(icmpnum)
	ld de,(icmperr)
	sbc hl,de
	ld a,l
	call printbyte_a
	ld hl,txt_tail4
	call print_hl
;% lost
	ld hl,txt_tail5
	call print_hl
;time
	ld hl,txt_tail6
	call print_hl
;rtt
	call print_nl

	ret

ping_printpacket_ix
;	ld a,(icmpdatasize)
;	add 8 ;header
;	ld b,a
	ld b,16
ping_printpacket_ix0
	push bc
	ld a,(ix)
	ld de,buf
	call bytetohexstr_atode
	ld hl,buf
	call print_hl
	ld a,' ' ;TODO only every 4 bytes
	PRCHAR
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
	PRCHAR
	ld a,'('
	PRCHAR
	ld hl,txtip
	call print_hl
	ld hl,txt_work2
	call print_hl

	ld hl,txt_crc
	ld a,(crc)
	or a
	jr nz,ping_printwork_crc
	ld a,(icmppacket.num); if no crc print packet num
	ld de,buf
	call bytetostr_atode
	ld hl,buf
ping_printwork_crc
	call print_hl
	ld hl,txt_work3
	call print_hl
	YIELD ; update current time in "oldtimer"
	ld de,(icmppacket.data+6)
	ld hl,(oldtimer)
	sbc hl,de
	ex hl,de
	ld hl,(icmptime) ; add to total elapsed time
	add hl,de
	ld (icmptime),hl
	ex hl,de
	
	ld a,l ; only low byte, sorry :(
	sll a
	sll a
	sll a
	add l
	sll a ; moultiple by 20ms
	call printbyte_a
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

ping_error_hl
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

ping_wait
	ld bc,(icmpdelay)
ping_wait0
	push bc
	YIELD
	pop bc
	djnz ping_wait0
	ret

ping_buildicmppacket
	ld ix,icmppacket
	ld (ix + STicmpreq.type),8
	ld (ix + STicmpreq.code),0
	ld (ix + STicmpreq.checksum),0
	ld (ix + STicmpreq.checksum+1),0
	ld hl,(icmpnextid)
	ld (ix + STicmpreq.id),hl
	ld hl,(icmpnum)
	inc hl
	ld (icmpnum),hl
	ld (ix + STicmpreq.num),h
	ld (ix + STicmpreq.num),l
	ld hl, (oldtimer)
	ld (ix + STicmpreq.data+6),hl
	ld (ix + STicmpreq.data+4),hl
	ld (ix + STicmpreq.data+2),hl
	ld (ix + STicmpreq.data),hl
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

show_usage
	ld hl,txt_usage
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
conparam	db 0,0,53,8,8,8,8
icmppacket 	STicmpreq
buf 		ds 255
ip		ds 4
txtip		db 0,0,0,'.',0,0,0,'.',0,0,0,'.',0,0,0,0

icmpdatasize db 56,0
icmpnum db 0,0
icmpcnt db 0,10
icmpnextid db 0x53,0x53
icmperr db 0,0
icmptime db 0,0
icmpshowpacket db 0
icmpdelay db 0,50 ;*20ms
crc db 0

oldtimer ds 2
arg_hostname ds 255

txt_usage db "Use ping [-p] <host_name|ip>",0x0D,0x0A,0
txt_head1 db "PING ",0
txt_head2 db " (",0
txt_head3 db ") ",0
txt_head4 db " bytes of data.",0x0D,0x0A,0
txt_resolveerror db "Can not resolve ",0
txt_socketerror db "IP socket creation error",0
txt_socketopenerror db "IP socket opening error",0
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
txt_tail5 db " packet loss, time ",0
txt_tail6 db " ms",0x0D,0x0A,"rtt min/avg/max = ",0

cmd_end
	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "ping.com",cmd_begin,cmd_end-cmd_begin

