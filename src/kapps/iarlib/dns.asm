
	MODULE LIB_DNS_RESOLVER
	PUBLIC DNS_RESOLVER
	EXTERN errno, OS_NETSOCKET, OS_NETSHUTDOWN, YIELD
	EXTERN OS_NETCONNECT, OS_WIZNETREAD_UDP, OS_WIZNETWRITE_UDP
	EXTERN OS_GETDNS
		
	RSEG	CODE
DNS_RESOLVER:		;DE-domain name
	push ix
	push de
    ld de,dns_ia + 3
    call OS_GETDNS
	ld hl,dns_head
	ld de,dnsbuf
	ld bc,6
	ldir
	ex de,hl
	ld de,dnsbuf+7
	ld (hl),0
	ld bc,256-7
	ldir
	ld de,dnsbuf+12
	ld h,d
	ld l,e
	pop bc
name_loop:
	inc hl
	ld a,(bc)
	ld (hl),a
	inc bc
	cp '.'
	jr z,is_dot
	or a
	jr nz,name_loop
is_dot:
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
	call OS_NETSOCKET
	ld a,h
	ld (dnssoc),a
	or a
	jp m,exiterr
	
	pop hl
	push hl
	ld de,0xffff&(-dnsbuf)
	add hl,de
	push hl

//else:	 A=SOCKET, IX=buffer_ptr, HL=sizeof(buffer), de=sockaddr_in ptr
//out: HL=count if HL < 0 then A=error 

	LD	a,(dnssoc)
	LD	ix,dnsbuf
	ld	de,dns_ia
	call OS_WIZNETWRITE_UDP
	pop af
	bit 7,h
	jr nz,exitcode

	ld b,50
	push bc
	jr recv_wait1
recv_wait:
	push bc
	call YIELD
recv_wait1:
	ld hl,256
	push hl
	LD	a,(dnssoc)
	LD	DE,dnsbuf
	LD	ix,dnsbuf
	CALL OS_WIZNETREAD_UDP
	pop af
	pop bc
	bit 7,h
	jr z,recv_wait_end
	djnz recv_wait
	ld a,54	;ERR_CONNRESET
	ld (errno),a
	jr exiterr
recv_wait_end:
	ld a,65		;ERR_HOSTUNREACH
	ld (errno),a
	bit 7,h
	jr nz,exitcode
	ld a,(dnsbuf+3)
	and 0x0f	
	jr nz,exiterr
exitcode:
	LD	a,(dnssoc)
	LD	E,0
	CALL	OS_NETSHUTDOWN
	pop hl
	pop ix
reqpars_l
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	ld de,7
	add hl,de
	ld b,(hl)
	inc hl
	ld c,(hl)
	inc hl
	dec a
	ret z
	cp 4
	jr nz,exiterr1
	add hl,bc
	jr reqpars_l
	
exiterr:
	pop af
	ld a,(errno)
	push af
	LD	BC,(dnssoc)
	LD	E,0
	CALL	OS_NETSHUTDOWN
	pop af
	ld (errno),a
	pop ix
exiterr1:
	ld hl,0
	ret
	
	RSEG	CONST
dns_head
	defb 0x11,0x22,0x01,0x00,0x00,0x01
dns_ia:
	defb 02,00,53,08,08,08,08
	RSEG	NO_INIT
dnssoc:
	DEFS 1	
dnsbuf:
	DEFS 256

	END
		