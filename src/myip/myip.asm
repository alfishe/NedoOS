        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
dns_err_count=250
cmd_begin

;init

    call initstdio
	
	ld a,0x01
	ld de,nsserv
	ld hl,sa_dns
	call dns_resolver ; resolving ip
	ld a,h
	or l
	jp z,nsservnotfound;0x0000
	
	ld de,sa_ns + 3
	ld bc,4
	ldir
	
	ld a,0x10
	ld de,hostname
	ld hl,sa_ns
	call dns_resolver ; resolving ip
	ld a,h
	or l
	jp z,myipservnotfound;0x0000
	
	push hl ;тут строка с ip
	add hl,bc
	ld (hl),0
        ld hl,tmyipis
	call print
        pop hl
		inc hl
       ld a,(hl)
       cp 0x0d ;message starts with 0x0d for no known reason
       jr nz,$+3
       inc hl
	call print
        ld hl,tcrlf
	call print
        ld hl,0
        QUIT

print
print0
	ld a,(hl)
	or a
	ret z;jp z,0x0000
	push hl
	PRCHAR_
	pop hl
	inc hl
	jr print0
        
nsservnotfound
        ld hl,nsserv
        call print
        ld hl,tnotfound
	call print
        ld hl,-1
        QUIT
myipservnotfound
        ld hl,hostname
        call print
        ld hl,tnotfound
	call print
        ld hl,-2
        QUIT
	
nsserv
	defb "ns3.google.com",0x00
hostname
	defb "o-o.myaddr.l.google.com",0x00
tmyipis
        db "my ip = ",0
tnotfound
        db " not found",0x0d,0x0a,0
tcrlf
        db 0x0d,0x0a,0
        
dns_resolver		;DE-domain name, HL - sa serv, A - QTYPE
dns_err_loop
	ld (sa_store),hl
	ld (qtype1),a
	ld (qtype2),a
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
	inc hl
	inc hl
	ld (hl),16
qtype1 = $ - 1
	inc hl
	inc hl
	ld (hl),1
	inc hl
	push hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld a, (sa_dns2)
	cp 0
	jp nz, skipgetdns
	ld de, sa_dns2;DE= ptr to DNS buffer(4 bytes)
	OS_GETDNS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
skipgetdns

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
	LD DE,sa_dns
sa_store=$-2
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
	cp 16
qtype2 = $ - 1
	ret z   ; If TYPE was 0x10 (TXT) exit
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
dns_head 	db 0x00,0x02,0x01,0x00,0x00,0x01
sa_dns		db 0,0,53
sa_dns2		db 0,0,0,0
sa_ns		db 0,0,53,216,239,36,10
sa_recv		defs 7
buf 		ds 255
	display "buf ",buf
	include "../_sdk/stdio.asm"
cmd_end
	savebin "myip.com",cmd_begin,cmd_end-cmd_begin
	LABELSLIST "../../us/user.l"
