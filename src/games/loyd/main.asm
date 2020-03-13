        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

emptyattr=7
FIGBUF_sz=100
        
        org PROGSTART
begin

        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,d
        SETPG16K

        call cls
        
        ld a,r
        add a,3
        jr nc,$-2
        LD HL,FIG9
        jr z,gameinit_hl
        dec a
        LD HL,FIG10
        jr z,gameinit_hl
        LD HL,FIG11
gameinit_hl
        ld a,(hl)
        inc hl
        ld (cur_nfigures),a
        ld a,(hl)
        inc hl
        ld (curtopmargin),a
        ld a,(hl)
        inc hl
        ld (curbottommargin),a
        ld a,(hl)
        inc hl
        ld (curleftmargin),a
        ld a,(hl)
        inc hl
        ld (currightmargin),a
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        CALL COPBUF
        
gameloop
        
        ;call prscore

        YIELD ;call delay

        GET_KEY
         cp key_esc
         jr z,quit
        cp 'a'
        jr c,$+4
        sub 0x20
        LD (STARTA_boxname),A
        CP 'A'
        JR C,$+4
        SUB 'A'-':'
        SUB '1'
        JR C,gameloop
cur_nfigures=$+1
        CP 10
        JR NC,gameloop
        PUSH AF
        CALL MOVFIG
        POP AF
        PUSH AF
        CALL MOVFIG
        POP AF
        PUSH AF
        CALL MOVFIG
        POP AF
        CALL MOVFIG
        jr gameloop
quit
        QUIT

MOVFIG  LD HL,FIGBUF-4
        push af
        push hl
        YIELD
        pop hl
        pop af
FNDFIG  INC HL
        INC HL
        INC HL
        INC HL
        SUB 1
        JR NC,FNDFIG
        LD B,(HL)
        INC HL
        LD C,(HL)
        INC HL
        LD D,(HL)
        INC HL
        LD E,(HL)
        DEC HL
        DEC HL
        XOR A
        DEC B
        CALL MAYIGO
        JR NZ,NOUP
        CALL TOLIETO
        JR NZ,ICANGO
        INC A
NOUP    INC B
        INC B
        CALL MAYIGO
        JR NZ,NODN
        CALL TOLIETO
        JR NZ,ICANGO
        OR 2
NODN    DEC B
        DEC C
        CALL MAYIGO
        JR NZ,NOLT
        CALL TOLIETO
        JR NZ,ICANGO
        OR 4
NOLT    INC C
        INC C
        CALL MAYIGO
        JR NZ,NORT
ICANGO  PUSH BC
        PUSH DE
        PUSH HL
        LD HL,FIGBUF
        LD DE,FIGBUF2
        LD BC,FIGBUF_sz;100
        LDIR 
        POP HL
        POP DE
        POP BC
        PUSH DE
        PUSH BC
        LD A,(HL)
        LD (HL),C
        DEC HL
        LD C,(HL)
        LD (HL),B
        LD B,C
        LD C,A
        EX DE,HL
        CALL CLW
        POP BC
        POP HL
STARTA_boxname=$+1
        LD A,"A"
        CALL BOX
        RET 
NORT    LD C,(HL)
        DEC HL
        LD B,(HL)
        INC HL
        DEC B
        RRA 
        JR C,ICANGO
        INC B
        INC B
        RRA 
        JR C,ICANGO
        DEC B
        DEC C
        RRA 
        JR C,ICANGO
        RET 

TOLIETO PUSH BC
        LD (TOLIETO_A),A
        PUSH DE
        DEC HL
        LD A,(HL)
        LD (HL),B
        INC HL
        LD B,(HL)
        LD (HL),C
        INC HL
        LD C,A
        LD A,(HL)
        LD (HL),D
        INC HL
        LD D,(HL)
        LD (HL),E
        LD E,A
        PUSH BC
        PUSH DE
        PUSH HL
        LD HL,FIGBUF
        LD DE,FIGBUF2
        LD B,FIGBUF_sz;100
TOLI0   LD A,(DE)
        INC DE
        CP (HL)
        INC HL
        JR NZ,$+4
        DJNZ TOLI0
        POP HL
        POP DE
        POP BC
        LD (HL),D
        DEC HL
        LD (HL),E
        DEC HL
        LD (HL),B
        DEC HL
        LD (HL),C
        INC HL
        POP DE
TOLIETO_A=$+1
        LD A,0
        POP BC
        RET 

COPBUF  LD A,(HL)
        ADD A,A
        INC A
        ADD A,A
        INC HL
        PUSH BC
        PUSH HL
        LD L,(HL)
        ADD HL,HL
        INC L
        ADD HL,HL
        LD H,A
        XOR A
        CALL BOX
        POP HL
        POP BC
        INC HL
        LD DE,FIGBUF
        LD A,"1"
COPBUF0 EX AF,AF'
        BIT 7,(HL)
        LD A,(HL)
        ;JR Z,$+4
         LD (DE),A
        ; RET 
         ret nz
        PUSH BC
        INC HL
        ADD A,A
        ADD A,A
        ADD A,B
        INC A
        LD (DE),A
        INC DE
        LD B,A
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        ADD A,C
        INC A
        LD (DE),A
        INC DE
        LD C,A
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        LD (DE),A
        INC DE
        PUSH DE
        LD D,A
        LD A,(HL)
        INC HL
        ADD A,A
        ADD A,A
        LD E,A
        PUSH AF
        PUSH HL
        EX DE,HL
        EX AF,AF'
        CALL BOX
        EX AF,AF'
        POP HL
        POP AF
        POP DE
        LD (DE),A
        INC DE
        POP BC
        EX AF,AF'
        INC A
        CP ":"
        JR NZ,$+4
        LD A,"A"
        JR COPBUF0

EXBCHL  LD A,B
        AND 24
        ADD A,64
        LD E,H
        LD H,A
        LD A,B
        RRCA 
        RRCA 
        RRCA 
        LD B,A
        AND #E0
        OR C
        LD C,L
        LD L,A
        LD A,E
        ADD A,A
        ADD A,A
        ADD A,A
        LD B,A
        RET 

BOX     PUSH AF
        CALL EXBCHL
        LD A,C
        PUSH HL
BOX0    LD (HL),255
        INC HL
        DEC A
        JR NZ,BOX0
        POP HL
        PUSH HL
        DEC B
BOX1    CALL DOWNHL
        PUSH HL
        SET 7,(HL)
        LD A,L
        ADD A,C
        DEC A
        LD L,A
        SET 0,(HL)
        POP HL
        DJNZ BOX1
        LD B,C
BOX2    LD (HL),255
        INC HL
        DJNZ BOX2
        POP DE
        POP AF
        OR A
        RET Z
        LD L,A
        EX AF,AF'
        ;ADD HL,HL
        ;LD H,15
        ;ADD HL,HL
        ;ADD HL,HL
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;#3c00
        add hl,bc
        LD B,8
BOX3    LD A,(DE)
        XOR (HL)
        LD (DE),A
        INC D
        INC hl
        DJNZ BOX3
        EX AF,AF'
        RET 

CLW     CALL EXBCHL
CLW0    PUSH HL
        LD A,C
CLW1    LD (HL),0
        INC HL
        DEC A
        JR NZ,CLW1
        POP HL
        CALL DOWNHL
        DJNZ CLW0
        RET 

MAYIGO  PUSH BC
        PUSH DE
        PUSH HL
        LD (MAYGO_A),A
        LD A,B
curtopmargin=$+1
        CP 4
        JR C,MAYGON
        ADD A,D
curbottommargin=$+1
        CP 21
        JR NC,MAYGON
        LD A,C
curleftmargin=$+1
        CP 6
        JR C,MAYGON
        ADD A,E
currightmargin=$+1
        CP 27 ;31 for 11
        JR NC,MAYGON
        DEC HL
        PUSH HL
        POP IX
        LD HL,FIGBUF
MAYGO0  BIT 7,(HL)
        JR NZ,MAYGOQ
        LD A,H
        CP HX
        LD A,LX
        JR NZ,$+5
        CP L
        JR Z,MAYGOK
        LD A,(HL)
        INC HL
        INC HL
        SUB B
        JR C,MAYGOX
        CP D
        JR NC,MAYGOK+2
        JR MAYGOXQ
MAYGOX  DEC A
        ADD A,(HL)
        JR NC,MAYGOK+2
MAYGOXQ DEC HL
        LD A,(HL)
        INC HL
        INC HL
        SUB C
        JR C,MAYGOY
        CP E
        JR NC,MAYGOK+3
        JR MAYGON
MAYGOY  DEC A
        ADD A,(HL)
        JR NC,MAYGOK+3
        JR MAYGON
MAYGOK  INC HL
        INC HL
        INC HL
        INC HL
        JR MAYGO0
MAYGOQ  XOR A
        JR $+3
MAYGON  OR H
        POP HL
        POP DE
MAYGO_A=$+1
        LD A,0
        POP BC
        RET 

DOWNHL  INC H
        LD A,H
        AND 7
        RET NZ
        LD A,L
        ADD A,32
        LD L,A
        RET C
        LD A,H
        ADD A,-8
        LD H,A
        RET 

FIG9
        db 9
        db 4,21,6,27 ;top,bottom,left,right margin
        dw 0x0305
        DEFW #504,2,#202,0,#102,#100,#102
        DEFW #200,#101,#201,#101,#300,#102,#400
        DEFW #102,#302,#201,#303,#201
        dw 255
FIG10
        db 10
        db 4,21,6,27 ;top,bottom,left,right margin
        dw 0x0305
        DEFW #504,1,#202,0,#201,#200,#201,3
        DEFW #201,#203,#201,#400,#101,#301,#101
        DEFW #302,#101,#403,#101,#201,#102
        dw 255
FIG11
        db 11
        db 4,21,6,31 ;top,bottom,left,right margin
        dw 0x0305
        DEFW #604,2,#202,0,#102,#100,#102
        DEFW #200,#101,#300,#101,#400,#102,#500
        DEFW #102,#402,#201,#403,#201,#302,#102
        DEFW #202,#102
        dw 255
FIGBUF
        DEFS FIGBUF_sz;100
FIGBUF2
        DEFS FIGBUF_sz;100

cls
	ld hl,#4000
	ld de,#4001
        ld bc,#17ff
        ld (hl),0;#ff
        ldir
	ld hl,#5800
	ld de,#5801
	ld (hl),emptyattr
	ld bc,767
	ldir
        ret
        
      
prtext
;bc=координаты
;hl=text
        ld a,emptyattr
        ld (curattr),a
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext

prscore
        ld hl,(curscore)
        ld de,#4000
prnum
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;push hl
        ;call prchar
        ;pop hl
        ;ret
        
prchar
;a=code
;de=screen
        push de
        push hl
        call prcharin
        pop hl
        pop de
        inc e
        ret
        
calcscraddr
;de=#4000 + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,#40
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        ret
        
calcattraddr
        call calcscraddr
        ;call calcattraddr_fromscr
calcattraddr_fromscr
;de=#5800 + (y&#18)/8+((y*32)&#ff+x)
        ld a,d
        ;sub #40
        rra
        rra
        rra
        and 3
        add a,#58
        ld d,a ;de=attraddr
        ret

prcharxy
;a=code
;bc=yx
        push bc
        push de
        push hl
        push af
        call calcscraddr
        pop af
        push de
        call prcharin
        pop de
        call calcattraddr_fromscr
curattr=$+1
        ld a,0
        ld (de),a
        pop hl
        pop de
        pop bc
        ret
        
prcharin
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;#3c00
        add hl,bc
        ld b,8
prchar0
        ld a,(hl) ;font
        ld (de),a ;scr
        inc hl
        inc d ;+256
        djnz prchar0
        ret

;text
;        db "Hello world!",0
endtext
        db "Game over!",0
curxy 
        dw 0
oldcurxy 
        dw 0
    
curscore
        dw 0
font
        incbin "zx.fnt"

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "loyd.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
