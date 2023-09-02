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
        LD HL,(CRCArea+2)
        LD DE,(CRCArea) 
        ld iy,DISKBUF
        ;ld bc,DISKBUFsz
        call UPCRC
        LD (CRCArea),DE
        LD (CRCArea+2),HL 
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

;iy=buf
;bc=size
;edlh=crc
UPCRC
        PUSH BC
        LD B,H
        ld C,L
        LD A,E
        XOR (iy);(IX)
        LD L,A
        LD H,TCRC/256
        LD A,(HL)
        XOR D
        LD E,A
        INC H
        LD A,(HL)
        XOR C
        LD D,A
        INC H
        LD A,(HL)
        XOR B
        INC H
        LD H,(HL)
        ld L,A
        POP BC
        INC iy;IX
        DEC BC
        LD A,B
        OR C
        JR NZ,UPCRC
        RET  

        include "../_sdk/file.asm"
        include "../_sdk/stdio.asm"

CRCArea
        ds 4,0xff

cmd_end

        display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "crc.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
