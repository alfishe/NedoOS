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
        ;call changescrpg
        call setpgsscr40008000_current
       pop hl
       pop de
       pop bc
        call primgega_onescreen
        ;call changescrpg
        jp setpgsmain40008000

;печать игрового сообщения
DrawTitle
;hl=msg (len,text)
        push hl
        CALL UnDrawOldTitle
        pop hl
        LD A,15
        LD (STCNTa),A
        push hl
        call setpgsscr40008000
        call DrawTitle_screen
        call setpgsscr40008000_current
        pop hl
        call DrawTitle_screen
        LD (curdrawingtitle),HL
        jp setpgsmain40008000 
DrawTitle_screen
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
        JR Z,MTSPC
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
_left=1
_right=8
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
        ret

UnDrawOldTitle
        push hl
        call setpgsscr40008000
        call UnDrawOldTitle_screen
        call setpgsscr40008000_current
        pop hl
        call UnDrawOldTitle_screen
        jp setpgsmain40008000 
UnDrawOldTitle_screen
       SCRADDR 8,TITLEY
        ld hl,_
        ld e,0 ;e=gfx byte
        ld bc,8*256+24*4 ;b=hgt,c=wid (/2)
        jp climgega_onescreen ;TODO надрисовать панельку (её верхушки) с энергией

       if 0
climgega_xy
;h=y, l=x/2
;b=hgt,c=wid (/2)
;e=gfx byte
       push bc
        ld a,l
        ld c,h
;a=x
;c=y
        ld b,0
        ld l,c ;y
        srl a ;x bit 0
         ld h,b;0
         rl h
         ;inc h
        srl a ;x bit 1
         rl h ;0x00/32/2 или 0x40/32/2
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40+scrbase
         if scrbase&0xff
         add a,scrbase&0xff
         endif
;a=x/4
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
       pop bc
       endif
climgega_onescreen
;b=hgt,c=wid (/2)
;e=gfx byte
;hl=scr
climgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
climgegacolumn0
        ld (hl),e
        add hl,bc
        dec hx
        jr nz,climgegacolumn0
        pop hl
;0x4000,0x8000,0x6000,0xa000,0x4001
        ld a,0x9f;0xa0, если не используем верхние 8 линий
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,climgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a ;если используем верхние 8 линий
        xor h
        ld h,a
climgegacolumn0q
        pop bc
        dec c
        jr nz,climgega0
        ret

primgega_onescreen
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
       push ix
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
       pop ix
        ret

windLA=0x4000+(176*40)+(165/8)+0x2000;#55B9 ;ширина 58
windLAbit=0xb8;16 ;1=left;8=right
windRA=0x4000+(176*40)+(255/8)+0x6000;#55B6 ;ширина 58
windRAbit=0xb8;0x47;2 ;1=left;8=right
windEA=0x4000+(187*40)+(165/8)+0x2000;#50F0 ;ширина 148
windEAbit=0xb8;16 ;1=left;8=right
windLAwid=58;47
windEAwid=148;119

nrgPLOT
        push bc
        push af
        call setpgsscr40008000
        pop af
        push af
        call nrgPLOT_screen
        call setpgsscr40008000_current
        pop af
        call nrgPLOT_screen
        call setpgsmain40008000
        pop bc
        ;jr $
        ;ret
;nrgGORIGHT
        ld a,e
        cpl;xor 2^16 ;1=left;8=right
        ld e,a
        rla;cp 8
        ret c;nc
        ld a,h
        xor 0x40^0x80
        ld h,a
        ret m ;>=0x80
         ;bit 5,h
         ;set 5,h
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        ret nz
         ;res 5,h
        inc hl
        ret
nrgPLOT_screen
;CY=pix, e=mask, hl=scraddr
        sbc a,a
       ;and -(2*9);and 2*9
       ;add a,4*9 ;color2 (dark grey)="0", color4 (light grey)="1"
       and 2*9
       add a,2*9 ;color2 (dark grey)="0", color4 (light grey)="1"
        push hl
        ld bc,40
        ld d,6
nrgPLOT_screen0
        xor (hl)
        and e
        xor (hl)
        ld (hl),a
        add hl,bc
        dec d
        jr nz,nrgPLOT_screen0
        pop hl
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
