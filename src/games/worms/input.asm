INIMOUS
;TODO для ATM читать начальные координаты мыши
       if !ATM
;при проверке наличия мыши требует память 0xb8b9..0xbb00
        EI 
        HALT 
        LD HL,#BA00
        PUSH HL
        POP DE
        INC E
        LD B,E
        ld C,L
        LD (HL),#B9
        LD A,H
        LDIR 
        DEC (HL)
        LD HL,#C9AF
        LD (#B9B8),HL
        LD (#B8B9),HL
        LD I,A
        IM 2
        EI 
        HALT ;test databus == 0xff
        IM 1
        LD A,#80
        OUT (127),A
        JR NZ,NOMOUSE ;databus != 0xff
       LD A,-1
        LD BC,0xfadf
        IN C,(C)
        LD A,0xfb
        IN A,(#DF)
        LD B,A
        LD (OLDXmouse),A
        LD A,0xff
        IN A,(#DF)
        LD (OLDYmouse),A
        CP B
        RET NZ
        CP C
        RET NZ
;all 3 mouse ports equal => no mouse
NOMOUSE
        ld hl,0x003e
        ld (mouseXportreadpatch),hl
        ld (mouseYportreadpatch),hl
        ;LD A,62
        ;LD (OLDX-2),A
        ;LD (OLDY-2),A
        ;XOR A
        ;LD (OLDX-1),A
        ;LD (OLDY-1),A
       endif
        RET 

;onint
MOUSE
nokeytimer=$+1
        ld a,0;-1 ;счётчик фреймов, где не использовалось управление
        inc a
        jr nz,$+3
        dec a
        ex af,af' ;'
        CALL INKEY
       ld a,b
       ld (cursorkeys),a
        LD A,C
MOUSEx=$+1
        LD HL,maxXwin/2
MOUSEy=$+1
        LD B,waterYwin+4
ARVEL=$+1
        LD DE,0
KEY=$+1
        CP 0
        LD (KEY),A
        call nz,resetnokeytimer
    ;корректируем скорости
        RRA 
        RRA 
        CPL 
        ;JR NZ,MANTORM
        AND 15
        JR NZ,MANnTORMOZ
        LD A,128 ;(a&15) == 0
        CP D
        JR NC,$+3
        INC D
        SRA D
        call nz,resetnokeytimer
        CP E
        JR NC,$+3
        INC E
        SRA E
        call nz,resetnokeytimer
MANnTORMOZ
        RRA 
        JR nc,$+3
        dec D
        RRA 
        JR nc,$+3
        inc D
        RRA 
        JR nc,$+3
        inc E
        RRA 
        JR nc,$+3
        dec E
    ;корректируем X
        LD A,0xfb
mouseXportreadpatch=$
        IN A,(#DF)
OLDXmouse=$+1
        LD C,0
        LD (OLDXmouse),A
        SUB C
        call nz,resetnokeytimer
        ADD A,E
        LD E,A
        JP Z,MXQQ
        JP P,MXP
;dx<0
      ; SRA A
       PUSH BC
       LD C,A
       LD B,-1
       ADD HL,BC
       POP BC
       ;ADD A,L
        jr C,MXQ
       CALL MXZRO
       LD HL,0
       ;CALL NC,MXZRO
        JR MXQ
MXP   ; DEC A
      ; SRL A
       ;SUB -8
       PUSH BC
       LD C,A
       LD B,0
       ADD HL,BC
       LD BC,maxXwin
       SBC HL,BC
       ADD HL,BC
       POP BC
       jr C,MXQ ;x<maxXwin
       CALL MXZRO
       LD HL,maxXwin
       ;ADD A,L
       ;CALL C,MXZRO
       ;SUB 8
MXQ    ;LD L,A
MXQQ
    ;корректируем Y
        LD A,0xff
mouseYportreadpatch=$
        IN A,(#DF)
OLDYmouse=$+1
        LD C,0
        LD (OLDYmouse),A
        SUB C
        call nz,resetnokeytimer
        SUB D
        JR Z,MYQQ
        CPL 
        JP M,MYP
      ; SRA A
        ADD A,B
        JR C,MYQ
        XOR A
        LD D,A
        JR MYQ
MYP   ; INC A
      ; SRA A
        ADD A,B
        CP maxYwin;/2;64
        JR C,MYQ
        XOR A
        LD D,A
        LD A,maxYwin;/2;64
MYQ     LD B,A
MYQQ    LD A,B
        LD (MOUSEy),A
        LD (ARVEL),DE

       ex af,af' ;' ;a=счётчик фреймов, где не использовалось управление
       ld (nokeytimer),a ;счётчик фреймов, где не использовалось управление

       if STICKMOUSEXTOGRID
;TODO отключать во время полёта снаряда, не получится через манипуляцию nokeytimer
        or a
        jr z,Mouse_stickskip ;управление использовалось
        ld a,l
        and 7
        jr z,Mouse_stickskip;Mouse_stickdomoveq ;уже прилипли к сетке
mouse_oldmdx=$+1
        ld a,0 ;последний -dx, не равный 0
        rla
        inc hl
        jr c,Mouse_stickdomoveq ;old dx>=0
        dec hl
        dec hl
Mouse_stickskip ;управление использовалось
        ld a,(MOUSEx)
        sub l
        jr z,Mouse_stickdomoveq
        ld (mouse_oldmdx),a
Mouse_stickdomoveq
       endif

        LD (MOUSEx),HL
        RET 

resetnokeytimer
       ex af,af' ;'
        xor a ;счётчик фреймов, где не использовалось управление
       ex af,af' ;'
        ret

MXZRO
        XOR A
        SUB E
        JP P,$+4
        INC A
        SRA A
        LD E,A
       ;XOR A
        RET 

INKEY
        ld bc,0xffff
        LD A,0xbf
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 1,b ;enter
        LD A,0x7f
        IN A,(-2)
        CPL 
        AND 31
        jr z,$+4
        RES 0,b ;space
        ld a,0xdf
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 4,C ;P
        RRA 
        JR C,$+4
        RES 5,C ;O
        LD A,-5
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 2,C
        LD A,-3
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 3,C
        ld a,0xfe
        in a,(0xfe)
        rra
        jr nc,INKEY_cursor
        ld a,0xef
        IN A,(0xfe)
        RRCA 
        RLA 
        RLA 
        OR #C3
        and c
        LD C,A ;11LRDU11
        ret
INKEY_cursor
        ld a,0xf7
        in a,(0xfe)
        bit 4,a ;5=L
        jr nz,$+4
        res 5,b
        ld a,0xef
        IN A,(0xfe) ;DUR??
        bit 2,a
        jr nz,$+4
        res 4,b
        rra
        or 0xf3
        and b
        ld b,a ;11LRDUef cursor
        ret
