;процедуры для рисования оформления, нижнего уровня (зависят от типа экрана)

DrawPieHL

;TODO

        ret

DrawPanel
;hl=panel
        ex de,hl
        call setpgsscr40008000
        call SetPgTextureC000
        ld bc,38*256+160
        ld hl,0x4000+(40*162)
       push bc
       push de
       push hl
        call primgega_onescreen
        call changescrpg
        call setpgsscr40008000
       pop hl
       pop de
       pop bc
        call primgega_onescreen
        ;call changescrpg
        jp setpgsmain40008000

;печать игрового сообщения
DrawTitle
        CALL UnDrawOldTitle
        LD A,15
        LD (STCNTa),A
        push hl
        call DrawTitle_screen
        pop hl
        call DrawTitle_screen
        LD (curdrawingtitle),HL
        jp setpgsmain40008000 
DrawTitle_screen
        call setpgsscr40008000
        LD C,(HL) ;len
        INC L
        LD A,40;32
        SUB C
       ;RET C
        RRA ;x
       SCRADDR 0,TITLEY
       ld de,_
       add a,e
       ld e,a
       jr nc,$+3
       inc d
MT0     LD A,(HL)
        INC L
        sub 32;CP 32
        ;JR Z,MTSPC        
        PUSH HL
        LD H,FONT88/256
        add a,a
        add a,a
        add a,a
        LD L,A
        jr nc,$+3
        inc h
        LD B,8
       push de
MT1
;TODO 16c font
_left=1;0xb8
_right=8;0x47
        xor a
        rlc (hl)
        jr nc,$+4
        or _left
        rlc (hl)
        jr nc,$+4
        or _right        
        ld (de),a
        ld a,d
        add a,0x40
        ld d,a
        xor a
        rlc (hl)
        jr nc,$+4
        or _left
        rlc (hl)
        jr nc,$+4
        or _right        
        ld (de),a
        ld a,d
        add a,0x20-0x40
        ld d,a
        xor a
        rlc (hl)
        jr nc,$+4
        or _left
        rlc (hl)
        jr nc,$+4
        or _right        
        ld (de),a
        ld a,d
        add a,0x40
        ld d,a
        xor a
        rlc (hl)
        jr nc,$+4
        or _left
        rlc (hl)
        jr nc,$+4
        or _right        
        ld (de),a
        ld a,e
        add a,40
        ld e,a
        ld a,d
        adc a,-0x60
        ld d,a
        inc l
        DJNZ MT1
       pop de

        POP HL
MTSPC   INC de ;scraddr
        DEC C
        JR NZ,MT0
        push hl
        call changescrpg
        pop hl
        ret

UnDrawOldTitle
        push hl
        call UnDrawOldTitle_screen
        pop hl
        call UnDrawOldTitle_screen
        jp setpgsmain40008000 
UnDrawOldTitle_screen
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
