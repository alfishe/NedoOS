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
        
        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,openerror
        ;jr nz,$+5
        ; ld hl,defaultfilename
        ld (curfilenameaddr),hl
        ex de,hl
        call openstream_file
        or	a
        jr	nz,openerror
readloop0
        ld de,DISKBUF
        ld hl,DISKBUFsz
;de=buf
;hl=size
        call readstream_file
        ld a,h
        or l
        jr z,closequit
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

        jr readloop0
closequit
        call closestream_file
curfilenameaddr equ $+1
        ld hl,txtcrc
        call prtext
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
        call prtext
        
openerror
error
quit
        QUIT

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
        
txtdblspc
	db	"  ",0
txtcrc
        db "CRC32=",0
txtcrlf
        db 13,10,0





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
