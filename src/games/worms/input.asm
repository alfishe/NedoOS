;при проверке наличия мыши требует память 0xb8b9..0xbb00
INIMOUS
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
        RET 

;onint
MOUSE
nokeytimer=$+1
        ld a,-1 ;счётчик фреймов, где не использовалось управление
        inc a
        jr nz,$+3
        dec a
        ex af,af' ;'
        CALL INKEY
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
        JR NZ,MANTORM
        AND 15
        JR NZ,MANNOT
MANTORM LD A,128
        CP D
        JR NC,$+3
        INC D
        SRA D
        CP E
        JR NC,$+3
        INC E
        SRA E
MANNOT  RRA 
        JR C,$+3
        INC D
        RRA 
        JR C,$+3
        DEC D
        RRA 
        JR C,$+3
        DEC E
        RRA 
        JR C,$+3
        INC E
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
        LD (MOUSEx),HL
        LD (ARVEL),DE
       ex af,af' ;'
       ld (nokeytimer),a ;счётчик фреймов, где не использовалось управление
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
        LD A,239
        IN A,(-2)
        RRCA 
        RLA 
        RLA 
        OR #C2
        LD C,A
        LD A,#DF
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 4,C
        RRA 
        JR C,$+4
        RES 5,C
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
        LD A,-2
        IN A,(-2)
        RRA 
        JR C,$+4
        RES 0,C
        LD A,#7F
        IN A,(-2)
        CPL 
        AND 31
        RET Z
        RES 1,C
        RET 
