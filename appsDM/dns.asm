
	MODULE LIB_DNS_RESOLVER
	PUBLIC dns_resolver
	EXTERN errno, OS_NETSOCKET, OS_NETCLOSE, YIELD
	EXTERN OS_NETCONNECT, OS_NETRECV, OS_NETSEND
	
		
	RSEG	CODE
dns_resolver:		;DE-domain name
	push de
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
	ld (dnssoc),a
	or a
	jp m,exiterr
	LD	C,A
	LD	DE,dns_ia
	CALL	OS_NETCONNECT
	or a
	jp m,exiterr
	
	pop hl
	push hl
	ld de,0xffff&(-dnsbuf)
	add hl,de
	PUSH	HL
	LD	bc,(dnssoc)
	LD	DE,dnsbuf
	CALL	OS_NETSEND
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
	PUSH	HL
	LD	bc,(dnssoc)
	LD	DE,dnsbuf
	CALL	OS_NETRECV
	pop af
	pop bc
	ld a,h
	or l
	jr nz,recv_wait_end
	djnz recv_wait
	ld a,54	;ERR_CONNRESET
	ld (errno),a
	jr exiterr
recv_wait_end:
	bit 7,h
	jr nz,exitcode
	ld a,65		;ERR_HOSTUNREACH
	ld (errno),a
	ld a,(dnsbuf+3)
	and 0x0f	
	jr nz,exiterr
exitcode:
	LD	BC,(dnssoc)
	LD	E,0
	CALL	OS_NETCLOSE
	pop hl
	ld de,12
	add hl,de
	ret
exiterr:
	pop af
	ld a,(errno)
	push af
	LD	BC,(dnssoc)
	LD	E,0
	CALL	OS_NETCLOSE
	pop af
	ld (errno),a
	ld hl,0
	ret
	RSEG	CONST
dns_head
	defb 0x11,0x22,0x01,0x00,0x00,0x01
dns_ia:
	defb 0,0,53,8,8,8,8
	RSEG	NO_INIT
dnssoc:
	DEFS 1	
dnsbuf:
	DEFS 256
	
	END
		