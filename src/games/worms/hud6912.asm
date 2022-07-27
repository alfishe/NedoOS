;процедуры для рисования оформления, нижнего уровня (зависят от типа экрана)

DrawPieHL
        LD A,PGLMN
        CALL OUTME;OUTNO
        LD DE,#482D
        LD BC,#28FF
PRGUG0  LD A,E
        DUP 6
        LDI 
        EDUP 
        LD E,A
        CALL DDE
        DJNZ PRGUG0
        ret

DrawPanel
;hl=panel
        ld de,0x50a0
DrawPanel_chrs
        push de
        ld b,8
DrawPanel0
        ld a,(hl)
        ld (de),a
        inc hl
        inc d
        djnz DrawPanel0
        ld d,0x5a
        ld a,(hl)
        ld (de),a
        inc hl
        pop de
        inc e
        jr nz,DrawPanel_chrs
        ret

;печать игрового сообщения
DrawTitle
        CALL UnDrawOldTitle;MTCL
        LD A,15
        LD (STCNTa),A
        LD C,(HL) ;len
        INC L
        LD A,32
        SUB C
       ;RET C
        SCF 
        RRA 
        LD E,A ;x+128
MT0     LD A,(HL)
        INC L
        sub 32;CP 32
        JR Z,MTSPC
        LD D,0x50;80
        PUSH HL
        LD H,FONT88/2/256
        RLCA
        rlca
        LD L,A
        add hl,hl
        LD B,8
MT1     LD A,(HL)
        LD (DE),A
        INC D
        INC L
        DJNZ MT1
        LD D,0x5a;90
        LD A,TITLCOL
        LD (DE),A
        POP HL
MTSPC   INC E
        DEC C
        JR NZ,MT0
        LD (curdrawingtitle),HL
        RET 

UnDrawOldTitle;MTCL
        LD E,#80
        LD C,32
        XOR A
MTCL0   LD D,0x50
        LD B,8
         LD (DE),A
         INC D
        DJNZ $-2
        INC E
        DEC C
        JR NZ,MTCL0
        PUSH HL
        CALL DrawGrenadeTop
        POP HL
        RET 

;печать торчащей части гранаты у нижней панельки
DrawGrenadeTop
        LD L,#88
        LD H,87
        LD (HL),#E0
        LD H,90
        LD (HL),2
        DEC L
        DEC L
        LD DE,BT
        CALL PRBTP
PRBTP   DEC L
        LD H,84
        LD B,4
PRBT0   LD A,(DE)
        INC DE
        LD (HL),A
        INC H
        DJNZ PRBT0
        LD H,90
        LD (HL),4
        RET 

BT      DB #E0,#F8,#FE,#FF,3,7,7,7

windRA=0x55B9
windRAbit=4
windLA=0x55b0;#55B6
windLAbit=8;32
windEA=0x50F0
windEAbit=4
windLAwid=47
windEAwid=119

nrgPLOT
;CY=pix, e=mask, hl=scraddr
        SBC A,A
        XOR (HL)
        AND E
        XOR (HL)
        LD (HL),A
        INC H
        XOR (HL)
        AND E
        XOR (HL)
        LD (HL),A
        INC H
        XOR (HL)
        AND E
        XOR (HL)
        LD (HL),A
        DEC H
        DEC H
        ;RET 
;nrgGORIGHT
        RRC E
        ret nc;JR NC,$+3
        INC HL
        ret

DrawAttrField
        LD HL,#5860
        LD DE,COLOUR
        LD C,17
PASC0L  LD (HL),D
        LD B,31
        INC L
        LD (HL),E
        DJNZ $-2
        LD (HL),D
        INC HL
        DEC C
        JR NZ,PASC0L
        RET 

Hud_UnDrawTime
        LD HL,(#5A62)
        call Hud_ResetTimeAttrHL
        ld de,0x3d00 ;space
        ld b,d
        ld c,e
        jr DrawTime_Go
DrawTime
       ld bc,(curtime)
       bit 0,c
       ret nz
        ;LD D,61 ;ROM font FIXME
       ld hl,numfont
       ld a,b
       ld b,0
       add hl,bc
       ex de,hl
       ld bc,numfont
       add a,c
       ld c,a
       jr nc,$+3
       inc b
        ;LD E,B
        ;SET 7,E
        ;LD B,D
        ;SET 7,C
DrawTime_Go
        LD HL,#5060
TIMPR0  LD A,(bc);(DE)
        LD (HL),A
        INC L
        LD A,(de);(BC)
        ;INC C
        LD (HL),A
        ;INC H
        ;LD (HL),A
        DEC L
        ;LD A,(DE)
        ;INC E
        ;LD (HL),A
       inc bc
       inc de
        INC H
        BIT 3,H
        JR Z,TIMPR0
        LD H,80
        LD A,L
        SUB -32
        LD L,A
        CP #A0
        JR C,TIMPR0
        RET 

Hud_ResetTime
        LD HL,#4747
Hud_ResetTimeAttrHL
        LD (#5A60),HL
        LD (#5A80),HL
        RET 

cls
;не чистит панельку
       ld hl,0x4000
        ld b,192-32
cls0
        push bc
        push hl
        ld d,h
        ld e,l
        inc e
        ld (hl),0
        ld bc,31
        ldir
        pop hl
        call DHL
        pop bc
        djnz cls0
       
       ld hl,0x5800
       ld de,0x5801
       ld bc,0x0100
       ld (hl),l;0
       ldir
       ld bc,0x019f
       ld (hl),COLOUR
       ldir
        ret

DHL
        INC H
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

PR64
        PUSH BC
        PUSH DE
        PUSH HL
        SUB 32
        ADD A,A
        LD L,A
        LD H,FONT/4/256
        ADD HL,HL
        ADD HL,HL
        LD B,7
        DEC C
        JR Z,PR641
        DEC C
        JR Z,PR64R
PR640   LD A,(HL)
        RLCA 
        RLCA 
        RLCA 
        RLCA 
        LD (DE),A
        INC L
        INC D
        DJNZ PR640
        LD D,#58
        LD A,71
        LD (DE),A
        POP HL
        POP DE
        POP BC
        INC C
        RET 
PR641   LD A,(DE)
        OR (HL)
        LD (DE),A
        INC L
        INC D
        DJNZ PR641
        POP HL
        POP DE
        INC E
        POP BC
        DEC C
        RET 
PR64R
        LD A,(HL)
        LD (DE),A
        INC L
        INC D
        DJNZ PR64R
        LD D,#58
        LD A,71
        LD (DE),A
        POP HL
        POP DE
        INC E
        POP BC
        LD C,0
        RET 

ClearEnergyPanel
        LD HL,#4000
        LD DE,#4001
        LD BC,#7FF
        LD (HL),L
        LDIR 
        LD A,6
        LD HL,#5800
        LD (HL),A
        INC L
        LD DE,#5802
        LD C,#5D
        LD (HL),67
        LDIR 
        LD (DE),A
        LD H,A
        LD L,A
        LD (#581F),HL
        LD (#583F),HL
        LD HL,#4747
        LD (#580F),HL
        LD (#582F),HL
        LD (#584F),HL
        ret

PRSTAR
        LD DE,SPRSTAR
        LD B,9
        BIT 4,L
        JR NZ,PRSTAR1
PRSTAR0 LD A,(DE)
        LD (HL),A
        INC DE
        INC A
        JR NZ,$+6
        INC L
        SET 7,(HL)
        DEC L
        CALL DHL
        DJNZ PRSTAR0
        RET 
PRSTAR1 LD A,(DE)
        RLCA 
        LD (HL),A
        INC DE
        JR NC,$+6
        DEC L
        SET 0,(HL)
        INC L
        CALL DHL
        DJNZ PRSTAR1
        RET 
SPRSTAR
        DB 8,12,#1C,-1,127,62,62,#66,66
ENRAMKA
;hl=scr
        LD BC,+(RAMKAWID-1)*256+0xff
        LD D,H
        LD E,L
        LD (HL),0x7f
        INC L
        LD (HL),C ;0xff
        DJNZ $-2
        DEC (HL) ;0xfe
        LD B,RAMKAHGT-1;15
ENRAMK0 CALL DHL
        SET 1,(HL)
        EX DE,HL
        CALL DHL
        SET 6,(HL)
        EX DE,HL
        DJNZ ENRAMK0
        LD B,RAMKAWID-1;13
        LD (HL),0xfe
        DEC L
        LD (HL),C ;0xff
        DJNZ $-2
        LD (HL),0x7f
        RET 
ENFAKE
;рисуем полную энергию у команды
;hl=scr
        LD E,5
ENFAKE0 PUSH HL
        LD (HL),0x5F ;0x40 от рамки слева
        LD B,RAMKAWID-1;13
        INC L
        LD (HL),C
        DJNZ $-2
        LD (HL),0xfa ;0x02 от рамки справа
        POP HL
        CALL DHL
        DEC E
        JR NZ,ENFAKE0
        RET 
