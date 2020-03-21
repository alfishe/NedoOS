;SVG FILES CONVERTER (MAX LEN 255 SECTORS) done by elfh
;SCALABLE VECTOR GRAPHICS, STORED IN TXT FORM
;EXTRACTS ONLY line,polygon,path (not full)

;SOURCE DRAWING MUST BE ALIGNED TO THE TOP LEFT CORNER OF PAGE
;DIMENSIONS 256x192 mm MAXIMUM
;LINES SHOULD NOT BE COMBINED
;LOOK house.svg AS AN EXAMPLE


;...WAITING FOR FUTURE DEVELOPMENTS
;+0 - LINES DATA START OFFSET
;+2 - QUANTITY OF LINES
;+4 - POLYLINES DATA START OFFSET
;+6 - QUANTITY OF POLYLINES
;+8 - POLYGONS DATA START OFFSET
;+10 - QUANTITY OF POLYGONS

; OUTPUT: HL - ADR OF DATA
;         BC - LENGTH OF DATA

SCRADR=#4000
HLJUMP=#7000 ;[512] LINE JUMPS
HLTMP=HLJUMP+#200     ;[512] SCR ADRS
HLBASE=HLTMP+#200     ;[#C22]
COLM1=5
;READBUF EQU 0x6000;#9000
FINDAT=0x6000;READBUF
LINES=0xd000;#C000 ;
POLYLINES=0xe000;#D000
POLYGONS=0xf000;#E000
STR_BUF=0x6300;#9300 ;не перекроет FINDAT?

;TUNING PARAMETERS

SCALE=#108
MINLINE=#4      ;MINIMAL LENGTH OF LINE
ADDX=4          ;SCREN OFFSET
ADDY=4
CPLX=0  ;X MIRRORING

readsvg
        CALL INITS
        CALL CONVERT
        ;CALL PRNREAL
        CALL COMPACT
        ;PUSH HL
        ;push BC
        CALL DRAW
        ;LD A,#10
        ;CALL PAG_128
        ;LD HL,#4000
        ;LD DE,#C000
        ;LD BC,#1800
        ;LDIR 
        ;POP BC
        ;pop HL

        RET 


CRDINI
        LD HL,(FINDAT)
        LD BC,FINDAT
        ADD HL,BC
        LD (LS+1),HL
        LD HL,FINDAT+2
        LD (LQ+2),HL
        LD HL,(FINDAT+4)
        ADD HL,BC
        LD (PLS+1),HL
;       LD (PLS1+1),HL
        LD HL,FINDAT+6
        LD (PLQ+2),HL
        LD HL,(FINDAT+8)
        ADD HL,BC
        LD (PLGS+1),HL
;       LD (PLGS1+1),HL
        LD HL,FINDAT+10
        LD (PLGQ+2),HL
        RET 

POLYGONDRAW
PLGQ    LD BC,(POLYGONS)
        LD A,B
        OR C
        RET Z
PLGS    LD HL,POLYGONS+2

POLYGDR2
        PUSH BC
        LD B,(HL)
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        DEC B
        PUSH DE
POLYGDR1
        PUSH BC
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL

        PUSH BC
        PUSH HL
LC1     CALL LINE
        POP HL
        POP DE
        POP BC
        DJNZ POLYGDR1
        POP BC
        PUSH HL
LC2     CALL LINE
        POP HL
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,POLYGDR2
        RET 

POLYLINEDRAW
PLQ     LD BC,(POLYLINES)
        LD A,B
        OR C
        RET Z
PLS     LD HL,POLYLINES+2
POLYLDR2
        PUSH BC
        LD B,(HL)
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        DEC B
POLYLDR1
        PUSH BC
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH BC
        PUSH HL
LC3     CALL LINE
        POP HL
        POP DE
        POP BC
        DJNZ POLYLDR1
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,POLYLDR2
        RET 



LINEDRAW
LQ      LD BC,(0)
        LD A,B
        OR C
        RET Z
        LD (LINEDR4+1),BC
LINEDR3
LINEDR4 LD BC,0
LS      LD HL,LINES+2
LINEDR1
        PUSH BC
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH HL
LC4     CALL LINE
        POP HL
        POP BC

        DEC BC
        LD A,B
        OR C
        JR NZ,LINEDR1
        RET 



COMPACT
        ;LD A,#10
        ;CALL PAG_128
        LD IX,FINDAT
        LD DE,FINDAT+12
        LD A,D
        SUB FINDAT/256
        LD (IX),E       ;LINES START
        LD (IX+1),A
        LD HL,LINES
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD (IX+2),C     ;LINES QUANTITY
        LD (IX+3),B
        LD A,B
        OR C
        JR Z,COMPACT1
        PUSH HL
        LD HL,(LINES1+1)
        LD BC,LINES+2
        AND A
        SBC HL,BC
        LD B,H
        LD C,L
        POP HL
        LDIR 

COMPACT1
        LD A,D
        SUB FINDAT/256

        LD (IX+4),E     ;POLYLINES START
        LD (IX+5),A

        LD HL,POLYLINES
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD (IX+6),C     ;POLYLINES QUANTITY
        LD (IX+7),B
        LD A,B
        OR C
        JR Z,COMPACT2

        PUSH HL
        LD HL,(PATHS1+1)
        LD BC,POLYLINES+2
        AND A
        SBC HL,BC
        LD B,H
        LD C,L
        POP HL
        LDIR 
COMPACT2
        LD A,D
        SUB FINDAT/256

        LD (IX+8),E     ;POLYGONS START
        LD (IX+9),A

        LD HL,POLYGONS
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        LD (IX+10),C    ;POLYGONS QUANTITY
        LD (IX+11),B
        LD A,B
        OR C
        JR Z,COMPACT3
        PUSH HL
        LD HL,(POLYGS+1)
        LD BC,POLYGONS+2
        AND A
        SBC HL,BC
        LD B,H
        LD C,L
        POP HL
        LDIR 
COMPACT3
        LD HL,FINDAT
        PUSH HL
        EX DE,HL
        AND A
        SBC HL,DE
        LD B,H
        LD C,L
        POP HL
        RET 

DRAW
        ;LD A,#10
        ;CALL PAG_128
        CALL CRDINI
        CALL LINEDRAW
        CALL POLYGONDRAW
        CALL POLYLINEDRAW
        RET 


CONVERT
        ;LD A,#10
        ;CALL PAG_128
        ;LD HL,LINETXT
        ;LD DE,#4000
        ;CALL PRNLINE
        ;LD HL,POLYLINETXT
        ;LD DE,#4020
        ;CALL PRNLINE
        ;LD HL,POLYGONTXT
        ;LD DE,#4040
        ;CALL PRNLINE

        LD HL,0
        LD (LINES),HL
        LD (POLYGONS),HL
        LD (POLYLINES),HL

        if 1==0
        
        LD A,9
        LD (23814),A
        LD HL,FILENAME
        LD DE,23773
        LD BC,9
        LDIR 
        LD C,#0A        ;SEARCH
        CALL #3D13
        BIT 7,C
        JR Z,FILEFOUND
NO_FILE
        LD A,2
        OUT (#FE),A
        RET 
FILEFOUND
        LD A,C
        LD C,#08        ;FILEDATUM
        CALL #3D13
        LD HL,(23773+14)
        LD (#5CF4),HL
        LD A,(23773+13)
;       LD IY,VTX_BUF+2
        LD LX,A
READ1
        PUSH IY
        push IX
READADR LD HL,READBUF
        LD DE,(#5CF4)
        LD BC,#0105
        PUSH HL
        LD IY,#5C3A
        CALL #3D13      ;READSECTOR
        POP HL
        POP IX
        pop IY
        XOR A
        INC H
CLEANBUF
        LD (HL),A
        INC L
        JR NZ,CLEANBUF
        endif
        
SEARCH
        ;LD A,#7F
        ;IN A,(#FE)
        ;RRCA 
        ;RET NC
        
SEARCH1 ;LD HL,READBUF
        LD DE,STR_BUF
SEARCH4
        ;LD A,(HL)
        ;INC HL
        rdbyte
        LD (DE),A
        INC DE
        AND A
        ret z ;JR Z,SEARCH3
        CP #0D
        ;JR Z,SEARCH2
        JR nz,SEARCH4
SEARCH2
        ;LD (SEARCH1+1),HL
        XOR A
        LD (DE),A

        if 1==0
        JR SEARCH5
        
SEARCH3
        DEC HL
        LD DE,(SEARCH1+1)
        AND A
        SBC HL,DE
        LD B,H
        LD C,L
        EX DE,HL
        LD DE,READBUF
        LD (SEARCH1+1),DE
        LD A,B
        OR C
        JR Z,$+2+2
        LDIR 
        LD (READADR+1),DE
        ;CALL PRNREAL
        DEC LX
        JP NZ,READ1
        RET 
        endif

SEARCH5
        LD DE,POLYLINETXT
        LD HL,STR_BUF
        CALL FINDSEQ
        JP NC,POLYLSUB
        LD DE,LINETXT
        LD HL,STR_BUF
        CALL FINDSEQ
        JP NC,LINESUB
        LD DE,POLYGONTXT
        LD HL,STR_BUF
        CALL FINDSEQ
        JP NC,POLYGSUB
        LD DE,PATHTXT
        LD HL,STR_BUF
        CALL FINDSEQ
        JP NC,PATHSUB
        JR C,SEARCH

POLYLSUB
        LD DE,POINTSTXT
        CALL FINDSEQ
        ;LD D,H
        ;ld E,L
        LD HL,(PATHS1+1)
        PUSH HL
        INC HL
        ;LD LY,#0
        xor a
        ld (POLYLSUB_LY),a
POLYLS1
        PUSH HL
        ;LD H,D
        ;ld L,E
        CALL TAKEVALUE
        POP HL
        ADD A,ADDX
        IF CPLX
        CPL 
        ENDIF 
        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD C,","
        CALL FINDCHAR
        CALL TAKEVALUE
        POP HL
        ADD A,ADDY
        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD C," "
        CALL FINDCHAR
        ;INC LY
POLYLSUB_LY=$+1
        ld a,0
        inc a
        ld (POLYLSUB_LY),a
        CALL CHEKEND
        ;LD D,H
        ;LD E,L
        POP HL
        JR NC,POLYLS1
        LD A,(POLYLSUB_LY);LY
        CP 2
        JR NZ,POLYLS3
        POP HL
        INC HL
        PUSH DE
        LD DE,(LINES1+1)
        LDI 
        LDI 
        LDI 
        LDI 
        LD (LINES1+1),DE
        POP DE
        JP INCLINES
POLYLS3
        LD (PATHS1+1),HL
        POP HL
        LD (HL),A
        LD HL,(POLYLINES)
        INC HL
        LD (POLYLINES),HL
        ;LD H,D
        ;LD L,E
        JP SEARCH


PATHSUB
        EXX 
PATHS1  LD HL,POLYLINES+2
        PUSH HL
        INC HL
        EXX 
        LD DE,DTXT
        CALL FINDSEQ
        LD C,"M"
        CALL FINDCHAR
        CALL TAKEVALUE
        EXX 
        LD C,A
        EXX 
        LD C," "
        LD H,D
        ld L,E
        CALL FINDCHAR
        CALL TAKEVALUE
        EXX 
        LD B,A
        LD A,C
        ADD A,ADDX
        IF CPLX
        CPL 
        ENDIF 

        LD (HL),A
        INC HL
        LD A,B
        ADD A,ADDY
        LD (HL),A
        INC HL
        EXX 
        ;LD LY,1
        ld a,1
        ld (PATHS_LY),a

        LD C,"l"
        ;LD H,D
        ;ld L,E
        INC HL
        CALL FINDCHAR
PATHS2
        CALL TAKEVALUE
        EXX 
        ADD A,C
        LD C,A
        EXX 
        LD C," "
        ;LD H,D
        ;ld L,E
        INC HL
        CALL FINDCHAR
        CALL TAKEVALUE
        EXX 
        ADD A,B
        CP #F0
        JR C,$+2+1
         XOR A
        LD B,A
        LD A,C
        ADD A,ADDX
        IF CPLX
        CPL 
        ENDIF 
        LD (HL),A
        INC HL
        LD A,B
        ADD A,ADDY
        LD (HL),A
        INC HL
        EXX 
        ;INC LY
PATHS_LY=$+1
        ld a,0
        inc a
        ld (PATHS_LY),a
        ;LD H,D
        ;ld L,E
        INC HL
        CALL CHEKPATH
        JR Z,PATHS2
  ;CONTINUOUS PATHS ARE NOT IMPLEMENTED
  ;"z,m,l" AND OTHER CASES SHOULD BE CHECKED HERE
        EXX 
        PUSH HL
        EXX 
        POP HL
        LD A,(PATHS_LY);LY
        CP 2
        JR NZ,PATHS3
        POP HL
        INC HL
        PUSH DE
        LD DE,(LINES1+1)
        LDI 
        LDI 
        LDI 
        LDI 
        LD (LINES1+1),DE
        POP DE
        JP INCLINES
PATHS3
        LD (PATHS1+1),HL
        POP HL
        LD (HL),A
        LD BC,(POLYLINES)
        INC BC
        LD (POLYLINES),BC

        PUSH DE
        LD B,(HL)
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC HL
        DEC B
POLYLD11
        PUSH BC
        LD C,(HL)
        INC HL
        LD B,(HL)
        INC HL
        PUSH BC
        PUSH HL
        CALL LINE
        POP HL
        POP DE
        POP BC
        DJNZ POLYLD11
        POP DE
        ;LD H,D
        ;LD L,E
        JP SEARCH


CHEKPATH
        ;LD A,(HL)
        ;INC HL
        rdbyte
        CP " "
        RET Z
        CP "9"+1
        JR C,CHEKPATH
        AND A
        RET 

FINDCHAR
        ;LD A,(HL)
        ;INC HL
        rdbyte
        CP C
        JR NZ,FINDCHAR
        RET 

POLYGSUB
        LD DE,POINTSTXT
        CALL FINDSEQ
        ;LD D,H
        ;ld E,L
POLYGS  LD HL,POLYGONS+2
        PUSH HL
        INC HL
        ;LD LY,#0
        xor a
        ld (POLYGSUB_LY),a
POLYGS1
        PUSH HL
        ;LD H,D
        ;ld L,E
        CALL TAKEVALUE
        POP HL
        ADD A,ADDX
        IF CPLX
        CPL 
        ENDIF 

        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD C,","
        CALL FINDCHAR
        CALL TAKEVALUE
        POP HL
        ADD A,ADDY
        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD C," "
        CALL FINDCHAR
        ;INC LY
POLYGSUB_LY=$+1
        ld a,0
        inc a
        ld (POLYGSUB_LY),a
        CALL CHEKEND
        ;LD D,H
        ;LD E,L
        POP HL
        JR NC,POLYGS1
        LD A,(POLYGSUB_LY);LY
        CP 2
        JR NZ,POLYGS3
        POP HL
        INC HL
        PUSH DE
        LD DE,(LINES1+1)
        LDI 
        LDI 
        LDI 
        LDI 
        LD (LINES1+1),DE
        POP DE
        JP INCLINES
POLYGS3
        LD (POLYGS+1),HL
        POP HL
        LD (HL),A
        LD HL,(POLYGONS)
        INC HL
        LD (POLYGONS),HL
        ;LD H,D
        ;LD L,E
        JP SEARCH


CHEKEND
        ;PUSH HL
CHEKEND1
        ;LD A,(HL)
        ;INC HL
        rdbyte
        CP '0'-1
        JR NC,CHEKEND1
        CP '.'
        JR Z,CHEKEND2
        CP 34;'"'
        ;JR Z,CHEKEND3
        JR nz,CHEKEND1
CHEKEND3
        SCF 
        ;POP HL
        RET 
CHEKEND2
        AND A
        ;POP HL
        RET 


LINESUB
        LD DE,X1
        CALL FINDSEQ
        CALL TAKEVALUE
LINES1  LD HL,LINES+2
        ADD A,ADDX

        IF CPLX
        CPL 
        ENDIF 

        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD DE,Y1
        CALL FINDSEQ
        CALL TAKEVALUE
        CP #BF
        JR C,$+2+2
        LD A,#BF
        POP HL
        ADD A,ADDY
        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD DE,X2
        CALL FINDSEQ
        CALL TAKEVALUE
        POP HL
        ADD A,ADDX
        IF CPLX
        CPL 
        ENDIF 

        LD (HL),A
        INC HL
        PUSH HL
        ;LD H,D
        ;LD L,E
        LD DE,Y2
        CALL FINDSEQ
        CALL TAKEVALUE
        CP #BF
        JR C,$+2+2
        LD A,#BF
        POP HL
        ADD A,ADDY
        LD (HL),A
        INC HL
        LD (LINES1+1),HL

INCLINES
        ;LD H,D
        ;LD L,E
        PUSH HL
        LD HL,(LINES1+1)
        DEC HL
        LD D,(HL)
        DEC HL
        LD E,(HL)
        DEC HL
        LD B,(HL)
        DEC HL
        LD C,(HL)
        LD A,B
        CP D
        JR NC,MINL1
        LD A,D
        SUB B
        JR $+2+1
MINL1
        SUB D
        LD H,A

        LD A,C
        CP E
        JR NC,MINL2
        LD A,E
        SUB C
        JR $+2+1
MINL2
        SUB E
;       LD L,A
        CP H
        JR NC,$+2+1
        LD A,H

        CP MINLINE
        JR C,MINL3
        CALL LINE
        LD HL,(LINES)
        INC HL
        LD (LINES),HL

MINL3
        POP HL
        JP SEARCH

TAKEVALUE
;a=first char?
;may be sign TODO
        ld de,0 ;val
        jr TAKEVALUE_go ;TODO test
TAKEVALUE0
        ;LD A,(HL)
        rdbyte
TAKEVALUE_go
        CP "0"-1
        JR C,TAKEVAL6
        CP "9"+1
        JR C,TAKEVAL5
TAKEVAL6
        ;INC HL
        sub '0'
;val=val*10+A
        push hl
        ld h,d
        ld l,e
        add hl,hl
        add hl,hl
        add hl,de
        add hl,hl
        add a,l
        ld e,a
        adc a,h
        sub e
        ld d,a
        pop hl
        JR TAKEVALUE0
TAKEVAL5
;non-numeric char
        ;LD D,H
        ;LD E,L
        LD H,0 ;???
;TAKEVAL2
        ;INC DE
        ;LD A,(DE)
        ;rdbyte
        ;CP "9"+1
        ;JR NC,TAKEVAL7
        ;CP "0"-1
        ;JR NC,TAKEVAL2
        CP "."
        JR Z,TAKEVAL1 ;fraction
TAKEVAL7 ;no fraction
        ;DEC DE
        ;LD L,0 ;no rounding up
        JR TAKEVAL4

TAKEVAL1
;fraction
        ;INC DE
        ;LD A,(DE)
        rdbyte
        CP "5" ;rounding up or down?
        ;LD L,0
        JR C,TAKEVAL3
        inc de;LD L,1
TAKEVAL3
        ;DEC DE
        ;DEC DE
TAKEVAL4
        if 1==0
        ;LD A,(DE)
        ;rdbyte
        ;SUB "0"
        ;ADD A,L
        ;LD L,A
        ;DEC DE
        ;LD A,(DE)
        ;rdbyte
        CP "0"-1
        JR C,SIGNCHECK
        CP "9"+1
        JR NC,SIGNCHECK
        SUB "0"
        AND A
        RLA 
        LD C,A
        RLA             ;x10
        RLA 
        ADD A,C
        ADD A,L
        LD L,A

        DEC DE
        LD A,(DE)
        CP "0"-1
        JR C,SIGNCHECK
        CP "9"+1
        JR NC,SIGNCHECK

        SUB "0"         ;x100
        AND A
        RLA 
        RLA 
        LD C,A          ;4
        RLA 
        RLA 
        RLA 
        LD B,A          ;32
        RLA             ;64
        ADD A,B
        ADD A,C
        ADD A,L
        JR NC,$+2+2
        LD A,#FF
        LD L,A
        DEC DE
        LD A,(DE)
SIGNCHECK
        endif

        PUSH AF ;TODO push '-' at the beginning
        ;PUSH DE
        LD H,e;L
        LD L,0
        LD DE,SCALE
        CALL DIV
        ;POP DE
        POP AF
        CP "-"
        LD A,L
        JR NZ,SIGNCH1
        NEG 
SIGNCH1
;       AND A
;       RR L
;       LD A,L
;       CP #74
;       RET NZ
        RET 


FINDSEQ
        LD A,(DE)
        LD C,A
        rdbyte ;LD A,(HL)
        AND A
        JR Z,FINDS4
        CP C
        CALL Z,FINDS2
        JR Z,FINDS7
        ;INC HL
        JR FINDSEQ
FINDS7
        SCF 
        CCF 
        RET 

FINDS2
        PUSH DE
         inc de ;first char is already checked
FINDS6
        LD A,(DE)
        AND A
        JR Z,FINDS5
        ;CP (HL)
        ex de,hl
        rdbyte
        cp (hl)
        ex de,hl
        JR NZ,FINDS3
        ;INC HL
        INC DE
        JR FINDS6
FINDS5
        POP DE
        RET 

FINDS3
        POP DE
FINDS4
        SCF 
        RET 

        if 1==0
;---PRINT HEX NUMBER
PRNREAL
        ;LD A,#10
        ;CALL PAG_128
        LD HL,(LINES)
        PUSH HL
        LD A,H
        LD DE,#4010
        CALL HEX_BYT
        POP HL
        LD A,L
        CALL HEX_BYT

        LD HL,(POLYLINES)
        PUSH HL
        LD A,H
        LD DE,#4020+#10
        CALL HEX_BYT
        POP HL
        LD A,L
        CALL HEX_BYT

        LD HL,(POLYGONS)
        PUSH HL
        LD A,H
        LD DE,#4040+#10
        CALL HEX_BYT
        POP HL
        LD A,L
        CALL HEX_BYT



        ;LD A,#10
        ;CALL PAG_128
        RET 
        endif


INITS
        ;XOR A
        ;OUT (#FE),A
        CALL DCRHORN
        ;LD A,#15
        ;CALL PAG_128
        ;LD A,COLM1
        ;CALL SCR_FIL
        ;LD A,#17
        ;CALL PAG_128
        ;LD A,COLM1
        ;CALL SCR_FIL
        RET 

;[512] LINE JUMP TABLE ON ROW X COL Y
;EA=PROC#*64+X*8+Y
;LOW BYTE=(EA) HIGH BYTE=(EA+256)
;PROC#:
; 0-DY>DX RIGHT
; 1-DY>DX LEFT
; 2-DX>DY RIGHT
; 3-DX>DY LEFT

;- HORN LINE DECRUNCHING

DCRHORN CALL DHLTAB
        CALL DHLSEQ
        CALL DHLRMAP

;LINE SCREEN ADR TABLE

HLSCAD  LD HL,HLTMP
        LD DE,SCRADR
        LD B,192
HLSC    LD (HL),E
        INC H
        LD (HL),D
        DEC H
        INC L
        INC D
        LD A,D
        AND 7
        JR NZ,HLSC1
        LD A,E
        ADD A,#20
        LD E,A
        JR C,HLSC1
        LD A,D
        SUB 8
        LD D,A
HLSC1   DJNZ HLSC
        RET 

DHLSEQ  LD IX,DHLSEQD
        LD HL,HLBASE
DLSQ    LD A,(IX)
        INC IX
        OR A
        RET Z
        LD DE,DLSQ
        PUSH DE
        LD B,A
        AND #C0
        LD E,A
        LD A,B
        AND 7
        LD C,A
        BIT 5,B
        JR NZ,DLSQ1
        BIT 6,B
        JR NZ,DLSQ1
        LD A,7
        SUB C
DLSQ1   INC A
        AND 7
        RLCA 
        RLCA 
        RLCA 
        ADD A,E
        LD E,A
        LD D,HLJUMP/256
        LD C,B
        BIT 5,B
        JP NZ,DHLX
DHLY
;IN:C,B &7=BIT# B4/B3 FLAGS
;   DE-JUMP PTR
;   HL-OUTPUT CODE PTR
;OUT:HL-OUTPUT CODE NEW PTR
        LD A,C
        AND 7
        RLCA 
        RLCA 
        RLCA 
        OR #C6
        LD C,A
        PUSH DE
        LD DE,#023E
        BIT 4,B
        JR Z,$+4
        INC E
        DEC D
        PUSH BC
        LD B,7
DHLY1   LD (HL),#CB
        INC HL
        LD (HL),C
        INC HL
        LD (HL),#24
        INC HL
        LD (HL),#93
        INC HL
        LD (HL),#38
        INC HL
        LD (HL),E
        INC HL
        LD A,E
        SUB D
        LD E,A
        DJNZ DHLY1
        LD (HL),#CB
        INC HL
        LD (HL),C
        INC HL
        EX DE,HL
        LD HL,DHLDAT
        LD BC,DHLDAT1-DHLDAT
        LDIR 
        EX DE,HL
        POP BC
        LD C,#80
        BIT 4,B
        JR Z,DHLY1A
        LD C,#2C
        BIT 3,B
        JR Z,$+3
        INC C
DHLY1A  LD B,8
        POP DE
DHLY2   LD (HL),#82
        INC HL
        BIT 7,C
        JR NZ,$+4
        LD (HL),C
        INC HL
        LD (HL),#C3
        INC HL
        LD A,(DE)
        INC D
        LD (HL),A
        INC HL
        LD A,(DE)
        DEC D
        INC E
        LD (HL),A
        INC HL
        DJNZ DHLY2
        RET 

DHLX    PUSH DE
        LD A,C
        AND 7
        LD DE,#002D
        CP 7
        JR NZ,$+5
        LD DE,#0C3A
        PUSH BC
        LD B,8
DHLX1   LD (HL),#CB
        INC HL
        LD A,B
        DEC A
        BIT 6,C
        JR Z,$+5
        LD A,8
        SUB B
        RLCA 
        RLCA 
        RLCA 
        OR #C6
        LD (HL),A
        INC HL
        LD (HL),#93
        INC HL
        LD A,C
        AND 7
        CP 7
        JR Z,DHLX1A
DHLX1C  LD (HL),#38
        INC HL
        LD (HL),E
        INC HL
        LD A,E
        ADD A,D
        LD E,A
        JR DHLX1B
DHLX1A  LD A,B
        CP 2
        JR NZ,DHLX1C
        PUSH DE
        push HL
        LD DE,#84
        ADD HL,DE
        EX DE,HL
        POP HL
        LD (HL),#DA
        INC HL
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        POP DE
DHLX1B  DJNZ DHLX1
        DEC HL
        DEC HL
        DEC HL
        LD A,#2C
        BIT 3,C
        JR Z,$+3
        INC A
        LD (HL),A
        INC HL
        EX DE,HL
        LD HL,DHLDAT1
        LD BC,DHLDAT2-DHLDAT1
        LDIR 
        EX DE,HL
        POP BC
        pop DE
        LD A,C
        AND 7
        CP 7
        LD A,#D3
        JR NZ,$+3
        DEC A
        LD (HL),A
        INC HL
        LD B,8
DHLX2   LD (HL),#82
        INC HL
        LD (HL),#24
        INC HL
        LD A,C
        AND 7
        CP 7
        JR NZ,DHLX3
        PUSH DE
        push BC
        EX DE,HL
        LD HL,DHLDAT3
        LD BC,DHLDAT4-DHLDAT3
        LDIR 
        EX DE,HL
        POP BC
        pop DE
DHLX3   LD (HL),#C3
        INC HL
        LD A,(DE)
        INC D
        LD (HL),A
        INC HL
        LD A,(DE)
        DEC D
        INC E
        LD (HL),A
        INC HL
        DJNZ DHLX2
        RET 

;CREATE HL JUMP TABLES
DHLTAB  LD IX,HLJUMP
        LD HL,HLBASE
        LD A,2
DHLT0   EXA 
        LD C,8
DHLT1   LD B,8
        ld DE,6
        CALL DHLT
        LD E,48
        ADD HL,DE
        DEC C
        JR NZ,DHLT1
        LD E,8
        ADD HL,DE
        EXA 
        DEC A
        JR NZ,DHLT0
        LD A,2
DHLT2   EXA 
        LD C,7
DHLT3   LD B,8
        ld E,5
        CALL DHLT
        LD E,45
        ADD HL,DE
        DEC C
        JR NZ,DHLT3
        LD B,7
        ld E,5
        CALL DHLT
        INC HL
        LD B,1
        LD E,146
        CALL DHLT
        EXA 
        DEC A
        JR NZ,DHLT2
        RET 

DHLT    LD (IX+0),L
        INC HX
        LD (IX+0),H
        DEC HX
        INC LX
        ADD HL,DE
        DJNZ DHLT
        RET 

DHLRMAP ;HL TABLES REMAP
        LD HL,HLJUMP
        LD DE,HLTMP
        PUSH HL
        push DE
        LD BC,512
        LDIR 
        POP HL
        pop DE
        LD E,#40
        LD C,8
DHRM    LD A,C
        ADD A,A
        ADD A,A
        ADD A,A
        ADD A,#38
        LD L,A
        LD B,8
DHRM0   LD A,(HL)
        INC H
        LD (DE),A
        INC D
        LD A,(HL)
        DEC H
        INC L
        LD (DE),A
        DEC D
        INC E
        DJNZ DHRM0
        DEC C
        JR NZ,DHRM
        LD HX,D
        LD LX,#C0
        LD C,0
DHRM1   LD B,8
DHRM2   LD A,8
        SUB B
        ADD A,A
        ADD A,A
        ADD A,A
        ld (DHRM_HY),a ;LD HY,A
        ADD A,#80
        add A,C
        LD L,A
        LD A,(HL)
        INC H
        LD (DE),A
        INC D
        LD A,(HL)
        DEC H
        LD (DE),A
        DEC D
        INC E
        LD A,7
        SUB C
        ;ADD A,HY
DHRM_HY=$+1
         add a,0
        add A,#C0
        LD L,A
        LD A,(HL)
        INC H
        LD (IX),A
        INC HX
        LD A,(HL)
        DEC H
        LD (IX),A
        DEC HX
        INC LX
        DJNZ DHRM2
        INC C
        LD A,C
        CP 8
        JR NZ,DHRM1
        RET 


DHLSEQD ;HORNLINE DCR SEQUENCE DATA
;#00-END
;+0 B76-PROC#
;   B5-AXIS DY>DX=0 DX>DY=1
;   B4-ADD INC/DEC
;   B3-INC L/DEC L #2C/#2D
;   B2-0 BIT# (0-7)

        DB #07,#06,#05,#04
        DB #03,#02,#01,#10
        DB #40,#41,#42,#43
        DB #44,#45,#46,#5F
        DB #B0,#B1,#B2,#B3
        DB #B4,#B5,#B6,#B7
        DB #F8,#F9,#FA,#FB
        DB #FC,#FD,#FE,#FF
        DB 0

DHLDAT  DEC B
        CALL Z,HLTRAP
        INC H
DHLDAT3 EXA 
        LD A,L
        ADD A,#20
        LD L,A
        JR C,$+6
        LD A,H
        SUB 8
        LD H,A
        EXA 
DHLDAT4 SUB E
        DB #30,-#40;JR NC,START OF ROW
DHLDAT1 DEC B
        CALL Z,HLTRAP
        SUB E
        DB #30; ,#D3-JR/#D2-JP
DHLDAT2


;HORN LINE 1    Idea&Coding Dark/X-Trade
;FIRST VERSION OF MATRIX 8X8 ALGHORITHM
;--------------------------------------
;DRAW LINE BETWEEN POINTS
;(X1,Y1)-(X2,Y2) (C,B)-(E,D)

LINE    LD A,D
        SUB B
        LD H,A; DY
        JR NC,LINE_1
        NEG 
        LD H,A
        LD A,D
        ld D,B
        ld B,A; SWAP 1,2
        LD A,C
        ld C,E
        ld E,A
LINE_1  LD A,E
        SUB C
        LD L,A
        LD A,0
        JR NC,LINE1A
        SUB L
        LD L,A; DX
        LD A,#08
LINE1A  EXA 
        LD A,H
        CP L
        JR NC,LINE2
        LD H,L
        ld L,A;SWAP DX,DY
        EXA 
        OR #10
        EXA ;SET MARK DY<DX
        LD A,H
LINE2   OR L
        RET Z
        PUSH HL
        EXA 
        LD H,A
        XOR E
        AND #18
        XOR E
        RLCA 
        RLCA 
        RLCA 
        XOR D
        AND #F8
        XOR D
        LD (HLTRAP0),A
        RLA 
        JR C,LINE3
        EXA 
        LD A,B
        AND #F8
        LD L,A
        LD A,D
        AND #F8
        SUB L
        CALL Z,HLTRAP
        JR LINE4
LINE3   LD A,E
        AND #F8
        LD L,A
        LD A,C
        AND #F8
        SUB L
        CALL Z,HLTRAP
        JR NC,LINE4
        NEG 
LINE4   RRCA 
        RRCA 
        RRCA 
        LD E,A
;E=size in chrs
        LD A,H
        XOR C
        AND #18
        XOR C
        RLCA 
        RLCA 
        RLCA 
        XOR B
        AND #F8
        XOR B
        LD H,HLJUMP/256
        LD L,A
        LD A,(HL)
        INC H
        LD H,(HL)
        LD L,A
        LD (LINEJP+1),HL
        LD H,HLTMP/256
        LD L,B
        LD A,(HL)
        INC H
        LD H,(HL)
        LD L,A
        LD A,C
        AND 31<<3
        RRCA 
        RRCA 
        RRCA 
        ADD A,L
        LD L,A
        LD B,E
        POP DE
        LD A,D
        SRL A
LINEJP  CALL 0
        LD HL,0
LINETA  EQU $-2
        LD (HL),0
LINETD  EQU $-1
        RET 

;HORN LINE TRAP CODE
; PUT RET AFTER SET X,(HL)

HLTRAP  EXA 
        EXX 
        LD HL,HLJUMP
HLTRAP0 EQU $-2
        LD A,(HL)
        INC H
        LD H,(HL)
        LD L,A
        INC HL,HL
        LD (LINETA),HL
        LD A,(HL)
        LD (LINETD),A
        LD (HL),#C9
        EXA 
        EXX 
        RET 
        
        if 1==0
SCR_FIL
        LD      HL,#C000
        LD      DE,#C001
        LD      BC,#1800
        LD      (HL),L
        LDIR 
        LD      (HL),A
        LD      BC,#2FF
        LDIR 
        RET 
        endif

;+-----------------------+
;|      HL = HL/DE       |
;+-----------------------+
;OUTPUT: HL = HL/DE
;spoils DE,HL,A

DIV     LD      A,D
        OR      E
        RET     Z
        PUSH    DE
        PUSH    BC
        LD      A,1
DIV_0   PUSH    HL
        SBC     HL,DE
        JP      C,HL0
        SBC     HL,DE
        JP      C,DIV_1
DIV_01  INC     A
        SLA     E
        RL      D
        POP     HL
        JP      DIV_0
DIV_1   POP     HL
        LD      BC,0
DIV_2   AND     A
        JP      NZ,DIV_3
        LD      H,B
        LD      L,C
        POP     BC
        POP     DE
        RET 
DIV_3   SBC     HL,DE
        JP      NC,DIV_4
        ADD     HL,DE
DIV_4   CCF 
        RL      C
        RL      B
        SRL     D
        RR      E
        DEC     A
        JP      DIV_2
HL0     CP      1
        JP      NZ,DIV_01
        POP     HL
        POP     BC
        POP     DE
        LD      HL,0
        RET 

PRNLINE
PRNLINE1
        LD A,(HL)
        AND A
        RET Z
        INC HL
        PUSH HL
        CALL PRNSYMBOL
        POP HL
        JR PRNLINE1

PRNSYMBOL
        LD L,A
        LD H,0
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        LD BC,#3C00
        ADD HL,BC
        PUSH DE
        DUP 3
        LD A,(HL)
        LD (DE),A
        INC L
        INC D
        LD A,(HL)
        LD (DE),A
        INC L
        INC D
        EDUP 
        LD A,(HL)
        LD (DE),A
        INC L
        INC D
        LD A,(HL)
        LD (DE),A
        POP DE
        INC E
        RET 

HEX_BYT
        PUSH AF
        RRA 
        RRA 
        RRA 
        RRA 
        CALL OUT_H
        POP AF
OUT_H
        AND #F
        CP #A
        JR C,O_H1
        ADD A,7
O_H1
        ADD A,48
        CALL PRNSYMBOL
        RET 


POLYLINETXT
        DB "polyline",0
LINETXT
        DB "line",0
POLYGONTXT
        DB "polygon",0
POINTSTXT
        DB "points=",0
PATHTXT
        DB "path",0
DTXT
        DB " d=",0

X1
        DB "x1=",0
X2
        DB "x2=",0
Y1
        DB "y1=",0
Y2
        DB "y2=",0

        if 1==0
PAG_128
        LD      BC,#7FFD
PAG1281 OR      0
        OUT     (C),A
        RET 
        endif

            ;123456789AB
FILENAME DB "house   svg"
