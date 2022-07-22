;процедуры для рисования оформления, нижнего уровня (зависят от типа экрана)

DrawPieHL

;TODO

        ret

DrawPanel
;hl=panel

;TODO

        ret

;печать игрового сообщения
DrawTitle
        CALL UnDrawOldTitle
        LD A,15
        LD (STCNTa),A
        LD C,(HL) ;len
        INC L
        LD A,32
        SUB C
       ;RET C
        RRA ;x
       SCRADDR 0,128
       ld de,_
       add a,e
       ld e,a
       jr nc,$+3
       inc d
MT0     LD A,(HL)
        INC L
        sub 32;CP 32
        JR Z,MTSPC        
        PUSH HL
        
        LD H,FONT88/2/256
        RLCA
        rlca
        LD L,A
        add hl,hl
        LD B,8
MT1

;TODO

        DJNZ MT1

        POP HL
MTSPC   INC E
        DEC C
        JR NZ,MT0
        LD (curdrawingtitle),HL
        RET 

UnDrawOldTitle

;TODO

        ret


windRA=#55B9
windRAbit=4
windLA=#55B6
windLAbit=32
windEA=#50F0
windEAbit=4

nrgPLOT

;TODO

        RET 

nrgGOLEFT

;TODO

        RET 

nrgGORIGHT

;TODO

        RET 

DrawAttrField
        RET 

Hud_UnDrawTime
        ;LD HL,(#5A62)
        ;call Hud_ResetTimeAttrHL
        ;ld de,0x3d00 ;space
        ;ld b,d
        ;ld c,e

;TODO

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

;TODO

        RET 

Hud_ResetTime
Hud_ResetTimeAttrHL
        RET 

cls

;TODO

        ret

PR64

;TODO

        RET 

ClearEnergyPanel

;TODO

        RET 

PRSTAR

;TODO

        RET 

ENRAMKA

;TODO

        RET 

ENFAKE ;рисуем полную энергию у команды

;TODO

        RET 
