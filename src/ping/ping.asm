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

ping_checkkeys
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
	jp z, show_usage ;if empty arg1 show usage

label1

	ld hl,arg_hostname-1
	ld de,ip

ping_nextdig
	inc hl
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
	jp z,ping_noresolve

ping_resolve

;	ld hl,txt_resolve
;	call print_hl
;	QUIT
	ld de,arg_hostname
	call dns_resolver ; resolving ip
	ld a,h
	or l
	jp z,resolveerror
	ld de,ip; save ip
	ld bc,4
	ldir

ping_noresolve
;	ld hl,txt_notresolve
;	call print_hl
;	QUIT

	ld hl,ip
	ld de,txtip ; convert to text
	call iptostr_hltode

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
	ld hl,icmpdatasize
	ld de,buf
	call bytetostr_hltode
	ld hl,buf
	call print_hl
	ld a,'('
	PRCHAR
	ld a,(icmpdatasize)
	add 8+6
	ld de,buf
	call bytetostr_atode
	ld hl,buf
	call print_hl
	ld a,')'
	PRCHAR
	ld hl,txt_head4
	call print_hl

label2
	xor a
	ld hl,ip
	ld de,conparam+2
	ld (de),a ; порт обнуляем
	inc de
	ld bc,4
	ldir ; запихиваем ип адрес

label3
	ld de,0x0202
	OS_NETSOCKET
	ld a,l
	ld c,l
	ld (soc1),a
	or a
	ld hl,txt_socketerror
	jp m, ping_error_hl

	LD de,conparam
	OS_NETCONNECT
	ld c,a
	ld a,l
	or a
	ld hl,txt_socketopenerror
	jp m, ping_error_hl

	YIELD

	ld bc,(icmpcnt)
ping_loop
	push bc
	call buildicmppacket
	ld hl,16
	LD a,(soc1)
	LD de,icmpreq1
	OS_WIZNETWRITE
	ld a,h
	jp p,ping_nowriteerr
	ld hl,txt_writeerror
	call print_hl

ping_nowriteerr
	ld b,250
ping_loopwait
	push bc
	ld hl,256
	ld a,(soc1)
	ld de,icmprep1
	OS_WIZNETREAD
	pop bc
	ld a,h
	or l
	jr nz,ping_loopreceived
	push bc
	YIELD
	pop bc
	djnz ping_loopwait
	ld hl,(icmperr); timeout
	inc hl
	ld (icmperr),hl
	ld hl,txt_timeout
	call print_hl
	pop bc
	djnz ping_loop
	jr ping_end

ping_loopreceived

	ld ix,icmprep1
	call icmpchecksum_ixtohl
	inc hl
	ld a,h
	or l
	ld (crc),a
	jr z, ping_nocrc
	ld hl,(icmperr)
	inc hl
	ld (icmperr),hl
ping_nocrc

	call ping_printwork
	call ping_wait
	pop bc
	ld a,b
	dec a
	ld b,a
	or a
	jp nz, ping_loop

ping_end
;	bit 7,h
	LD a,(soc1)
	LD E,0
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
	call print_a
	ld hl,txt_tail3
	call print_hl
	ld hl,(icmpnum)
	ld de,(icmperr)
	sbc hl,de
	ld a,l
	call print_a
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
	ld a,(icmpdatasize)
	add 8
	ld b,a
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
	ld a,(icmprep1.num)
	ld de,buf
	call bytetostr_atode
	ld hl,buf
ping_printwork_crc
	call print_hl
	ld hl,txt_work3
	call print_hl
	YIELD
	ld de,(icmpreq1.data+6)
	ld hl,(oldtimer)
	sbc hl,de
	ex hl,de
	ld hl,(icmptime)
	add hl,de
	ld (icmptime),hl
	ex hl,de
	
	ld a,l
	sll a
	sll a
	sll a
	add l
	sll a ; умножили на 20
	ld de,buf
	call bytetostr_atode
	ld hl,buf
	call print_hl
	ld hl,txt_work4
	call print_hl
	ld a,(icmpshowpacket)
	or a
	ret z
	ld ix,icmprep1
	call ping_printpacket_ix
	ret


resolveerror
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

ping_textsum_hltobuf
	ld (buf),hl
	ld de,buf+2
	ld hl,buf
	call bytetostr_hltode
	call bytetostr_hltode
	ret

ping_wait
	ld b,50
ping_wait0
	push bc
	YIELD
	pop bc
	djnz ping_wait0
	ret

buildicmppacket
	ld ix,icmpreq1
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
	ld (ix + STicmpreq.data+5),0
	ld (ix + STicmpreq.data+4),0
	ld (ix + STicmpreq.data+3),0
	ld (ix + STicmpreq.data+2),0
	ld (ix + STicmpreq.data+1),0
	ld (ix + STicmpreq.data),0
	call icmpchecksum_ixtohl
	ld (icmpnextid),hl
	ld (ix + STicmpreq.checksum),h
	ld (ix + STicmpreq.checksum+1),l
	ret

icmpchecksum_ixtohl
	push ix
	ld hl,0
	ld b,8
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

iptostr_hltode
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
	ld (hl),b;0
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

	STRUCT STicmpreq
type		BYTE
code		BYTE
checksum	WORD
id		WORD
num		WORD
data		ds 8
	ENDS

dns_head 	db 0x11,0x22,0x01,0x00,0x00,0x01
conparam	db 0,0,53,8,8,8,8
icmpreq1 STicmpreq
icmprep1 STicmpreq
buf 		ds 255
soc1		db 0
ip		ds 4
txtip		db 0,0,0,'.',0,0,0,'.',0,0,0,'.',0,0,0,0

icmpdatasize db 8
icmpnum db 0,0
icmpcnt db 0,10
icmpnextid db 0x53,0x53
icmperr db 0,0
icmptime db 0,0
icmpshowpacket db 0
crc db 0

oldtimer ds 2

txt_usage db "Use ping <host_name|ip>",0x0D,0x0A,0
txt_head1 db "PING ",0
txt_head2 db " (",0
txt_head3 db ") ",0
txt_head4 db " bytes of data.",0x0D,0x0A,0
txt_resolveerror db "Can not resolve ",0
txt_socketerror db "IP socket creation error",0
txt_socketopenerror db "IP socket opening error",0
txt_writeerror db "Something wrong with write",0x0D,0x0A,0
txt_sumerror db " checksum wrong",0x0D,0x0A,0
txt_sumok db " checksum ok",0x0D,0x0A,0
txt_timeout db " timeout",0x0D,0x0A,0
txt_work1 db "Echo from ",0
txt_work2 db "): icmp_seq=",0
txt_work3 db " time=",0
txt_work4 db " ms",0x0D,0x0A,0
txt_crc db "CRC error",0
txt_tail1 db "--- ",0
txt_tail2 db " ping statistics ---",0x0D,0x0A,0
txt_tail3 db " packets transmitted, ",0
txt_tail4 db " received, ",0
txt_tail5 db " packet loss, time ",0
txt_tail6 db " ms",0x0D,0x0A,"rtt min/avg/max = ",0
txt_resolve db "Resolve",0x0D,0x0A,0
txt_notresolve db "Not resolve",0x0D,0x0A,0


arg_hostname ds 255

cmd_end
	display "printhl: ", print_hl
	display "begin: ", cmd_begin
	display "buf: ", buf
	display "label1: ", label1
	display "label2: ", label2
	display "label3: ", label3
	display "txtip: ", txtip
	display "dns_exiterr: ", dns_exiterr
	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "ping.com",cmd_begin,cmd_end-cmd_begin

