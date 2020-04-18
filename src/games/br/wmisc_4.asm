;******** вспом п/п PAGE 4 ***** 256bt

;----ВЫБОР ГЕРОЕВ--------
outBOX	
        if 1==0
        CALL _TST#8
        endif
	LD A,(begBOX)
	OR A
	RET Z
	LD HL,(MX)
	LD A,L
	CP 190
	JR C,oB1
	LD L,190
oB1	LD DE,(BOXX)
	XOR A
	PUSH HL
	SBC HL,DE
	POP HL
	RET Z
outboxpp
;de=top left
;hl=bottom right
       if EGA==0
	CALL STD ;выбор теневого экрана
       endif
       if EGA
        ;push de
        ;push hl
        call setpgsscr40008000
        ;pop hl
        ;pop de
        ld bc,setpgsmain40008000
        push bc
       endif
        ;jr $
	PUSH DE
	LD E,L
       if EGA
       push hl
       endif
	CALL vLINE
       if EGA
       pop hl
       endif
	POP DE
	PUSH DE
	LD D,H
       if EGA
       push hl
       endif
	CALL hLINE
       if EGA
       pop hl
       endif
	POP DE
       if EGA
       push de
       push hl
       endif
	CALL vLINE
       if EGA
       pop hl
       pop de
       endif
	CALL hLINE
	LD HL,LMask
	RRC (HL)
	RET

        if EGA
outBOXsolid
;de=top left
;hl=bottom right
;a'=mask
        ld a,(LMask)
        push af
        ex af,af'
        ld (LMask),a
        call outboxpp
        pop af
        ld (LMask),a
        ret
        endif

hLINE	;гориз уч DE->L;
	LD A,(LMask)
	LD (LMask_),A
         if EGA ;для выделения домиков
         ld a,d
         cp 192
         ret nc
         ld a,e
         cp 192
         jr c,hlinenoclipleft
         ld e,0
hlinenoclipleft
         ld a,l
         cp -16
         ret nc
         cp 191
         jr c,hlinenoclipright
         ld l,191
hlinenoclipright
         endif
	LD A,L
	CP E
	RET Z
	PUSH HL
	PUSH DE
	JR NC,hL1
	LD L,E
	LD E,A
hL1	PUSH HL
	PUSH DE
	LD A,E
       if EGA
	AND 0xfe
       else
	AND #F8
       endif
	LD E,A
	LD A,L
       if EGA
	AND 0xfe
       else
	AND #F8
       endif
	SUB E
       if EGA
	CP #2
       else
	CP #8
       endif
	JR C,hLA
	JR NZ,hLC
	LD B,0
	JR hLB
hLC	
       if EGA
        RRCA
       else
        RRCA
	RRCA
	RRCA
       endif
	LD B,A
	DEC B
hLB	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
       if EGA
        ld a,0xff ;L+R
        bit 0,e
        jr z,$+4
        ld a,0xb8 ;R only
       else
	LD A,E
	AND 7
	LD DE,MLtab1 ;#FF,#7F,#3F,#1F,#F,#7,#3,#1
	ADD A,E
	LD E,A
	LD A,(DE)
       endif
	CALL pMASK ;A-маска;HL-коорд
	LD A,B
	OR A
	JR Z,hLC1
hLC0	LD A,#FF
	CALL pMASK
	DJNZ hLC0
hLC1	POP DE
       if EGA
        ld a,0x47 ;L
        bit 0,e
        jr z,$+4
        ld a,0xff ;L+R
       else
	LD A,E
	AND 7
	LD DE,MLtab2 ;#80,#C0,#E0,#F0,#F8,#FC,#FE,#FF
	ADD A,E
	LD E,A
	LD A,(DE)
       endif
	JR hLA1
hLA	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
       if EGA
        ld a,0xff ;L+R
        bit 0,e
        jr z,$+4
        ld a,0xb8 ;R only
        pop de
        bit 0,e
        jr nz,$+4
        and 0x47 ;keep L
       else
	LD A,E
	AND 7
	LD DE,MLtab1 ;#FF,#7F,#3F,#1F,#F,#7,#3,#1
	ADD A,E
	LD E,A
	LD A,(DE)
	LD C,A
	POP DE
	LD A,E
	AND 7
	LD DE,MLtab2 ;#80,#C0,#E0,#F0,#F8,#FC,#FE,#FF
	ADD A,E
	LD E,A
	LD A,(DE)
	AND C
       endif
hLA1	CALL pMASK
	POP DE
	POP HL
	RET

pMASK	;выв байта LMask по маске А в (HL)
       if EGA
	LD C,A
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	RLCA
	RLCA
	LD (LMask_),A
        jr nc,pMASKq
	ld a,c
	XOR (HL)
	LD (HL),A
pMASKq
        ld de,0x4000
        ld a,0x9f;0xa0
        cp h
        adc hl,de ;de = 0x4000 - ((sprhgt-1)*40)
        ret pe
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
        ret
       else
	LD C,A
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	AND C
	XOR (HL)
	LD (HL),A
	INC L
	RET
       endif ;~EGA

pvMASK
       if EGA
	LD A,C
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	RLCA
	LD (LMask_),A
        jr nc,pvMASKq
	ld a,c
	XOR (HL)
	LD (HL),A
pvMASKq
        ld de,40
        add hl,de
        ret
       else
	LD A,C
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	RLCA
	LD (LMask_),A
	AND C
	XOR (HL)
	LD (HL),A
	INC H
	LD A,H
	AND 7
	RET NZ
	LD A,L
	ADD A,32
	LD L,A
	RET C
	LD A,H
	SUB 8
	LD H,A
	RET
       endif ;~EGA

vLINE	;верт.линияDE->H
	LD A,(LMask)
	LD (LMask_),A
         if EGA ;для выделения домиков
         ld a,e
         cp 192
         ret nc
         ld a,d
         cp 192
         jr c,vlinenocliptop
         ld d,0
vlinenocliptop
         ld a,h
         cp -16
         ret nc
         cp 192;191
         jr c,vlinenoclipbottom
         ld h,192;191
vlinenoclipbottom
         endif
	LD A,D
	CP H
	RET Z
	PUSH HL
	PUSH DE
	JR C,vG1
	LD D,H
	LD H,A
vG1	PUSH DE
	LD A,H
	SUB D
	LD B,A
	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
       if EGA
        ld c,0x47 ;L
        bit 0,e
        jr z,$+4
        ld c,0xb8 ;R
       else
	LD A,E
	AND 7
	LD DE,MLtabV
	ADD A,E
	LD E,A
	LD A,(DE)
	LD C,A ;один бит
       endif
vG2	CALL pvMASK
	DJNZ vG2
	POP DE
	POP HL
	RET
