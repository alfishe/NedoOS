        ;ORG #C000,pg6&7
        align 256
TDHL
wassin
s=32768
c=777
        DUP 128
        ;display "s=",s,",c=",c
        DB (s>>7)&0xff
a=s
s=(s+c)&0xffff
c=(c-((a-32768)/1610))&0xffff
        EDUP 
INPAGE
        LD E,B
sad0    LD L,E
        RES 7,L
        LD D,SIN/256+15
        LD BC,#1010
        XOR A
sad1    ex de,hl 
        LD (HL),C
        SLA (HL)
        ex de,hl 
        BIT 7,E
        jr Z,sader
        SUB (HL)
        jr NC,$+3
         DEC C
        JR sadq
sader   ADD A,(HL)
        jr NC,$+3
         INC C
sadq    DEC D
        DJNZ sad1
        INC E
        jr NZ,sad0
        ;CALL cs_8026
        ;jr C,$+7
        ; LD A,201
        ; ld (IMnOFF),A
        LD DE,#4020
        LD HL,TDHL
        LD B,E
MKDHL   LD (HL),E
        INC L
        LD (HL),D
        INC L
        CALL DDE
        DJNZ MKDHL
        RET 
GETAYER
        jr Z,IMnOFF
       ;LD (ITEMFLG),A
        LD HL,(ARXY)
        ld A,L
        SUB 8
        CP 32
        jr NC,IMnOFF
        LD A,H
        LD HL,CLST3
        ld DE,PLoffC
        CP #D4
        jr NC,IMabc
        LD L,CLST2&0xff ;TODO fix
        ld DE,PLoffB
        CP #AC
        jr NC,IMabc
        LD L,CLST1&0xff ;TODO fix
        ld DE,PLoffA
        CP #88
        jr C,IMnOFF
       LD A,(WBUFTOP+1)
       INC A ;edsmp
       jr Z,IMnOFF
IMabc   LD A,(DE)
        ld (HL),A
       ;INC HL
       ;LD (HL),A
        CPL 
        LD (DE),A
IMnOFF
       LD A,(WBUFTOP+1)
       INC A  ;edsmp
        LD A,#11
        ld HL,8
        LD DE,rgbufA
       CALL NZ,GETRG
        LD A,#16
        ld HL,#209
        LD DE,rgbufB
        CALL GETRG
        LD A,#1B
        ld HL,#40A
        LD DE,rgbufC
GETRG
        LD (ZZC),A
        LD BC,-3
        OUT (C),L
        IN A,(C)
        OUT (C),H
        IN L,(C)
        INC H
        OUT (C),H
        CPL 
        AND #F
        ADD A,SIN/256
        LD H,A
        IN A,(C)
        BIT 3,A
        CPL 
        jr Z,$+3
         XOR A
        AND 7
        LD C,A
        ex de,hl 
       IF skipABC
        LD B,1
        CP (HL)
        LD (HL),A
        JR Z,$+3
         INC B
        INC HL
        LD A,E
        CP (HL)
        LD (HL),A
        JR Z,$+3
         INC B
        INC HL
        LD A,D
        CP (HL)
        LD (HL),A
        JR Z,$+3
         INC B
        INC HL
        LD A,(HL)
        INC HL
        CP (HL)
        LD (HL),A
        JR NZ,$+4
         DEC B
         RET Z
       ELSE 
        LD A,(HL)
       ENDIF 
       PUSH BC
       push DE
        INC HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD B,A
        ld C,A
        ex de,hl 
        LD (CLSTSP+1),SP
        JP (HL)
CLSTSP  LD SP,0
       POP DE
       pop BC
ZZC=$+1
        LD B,0
        EXX 
        LD B,4
zz0     EXX 
b=7
       DUP 4
        ex de,hl 
        LD A,L
        ADD A,C ;channel volume?
        LD L,A
        ld E,(HL)
        ex de,hl 
        ADD A,C
        LD E,A
        ld H,TDHL/256
        ld A,(HL)
        OR B
        INC L
        LD H,(HL)
        ld L,A
        SET b,(HL)
        LD A,(DE)
        ld L,A
        ld H,TDHL/256
        ld A,(HL)
        OR B
        INC L
        LD H,(HL)
        ld L,A
        SET b-1,(HL)
b=b-2
       EDUP 
        INC B
        EXX 
        DJNZ zz0
        RET 

CLSTAN3
s=#403F
       DUP 3
       DUP 4
       DUP 8
        LD SP,s
        PUSH BC
        push BC
s=s+256
       EDUP 
s=s-#7E0
       EDUP 
        JP CLSTSP
s=s-#85
       EDUP 
CLSTlen=($-CLSTAN3)/3
CLSTAN2=CLSTAN3+CLSTlen
CLSTAN1=CLSTAN2+CLSTlen

rgbufA
       IF skipABC
        DS 3,#AA
       ENDIF 
CLST1   NOP 
       IF skipABC
        NOP 
       ENDIF 
        DW CLSTAN1
rgbufB
       IF skipABC
        DS 3,#AA
       ENDIF 
CLST2   NOP 
       IF skipABC
        NOP 
       ENDIF 
        DW CLSTAN2
rgbufC
       IF skipABC
        DS 3,#AA
       ENDIF 
CLST3   NOP 
       IF skipABC
        NOP 
       ENDIF 
        DW CLSTAN3

       IF 0==frqrosh
tab2frq INCBIN "kozasm.bin"
        DW #CDA
tab0frq INCBIN "kozpt.bin"
tab1frq INCBIN "kozst.bin"
       ELSE 
NT_DATA
        DB T_NEW_0-T_
       ADC A,D
        DB TCNEW_0-T_

        DB T_NEW_1-T_
        OR A
        DB TCNEW_1-T_

        DB T_NEW_2-T_
       ADC A,D
        DB TCNEW_2-T_

        DB T_NEW_3-T_
       ADC A,D
        DB TCNEW_3-T_
T_
TCNEW_1
TCOLD_1 DB #5C+1,0
TCNEW_3 DB #56+1
TCOLD_3 DB #1E+1,#22+1,#24+1,#28+1,#2C+1,#2E+1,#32+1,#BE+1,0
TCNEW_0 DB #1C+1,#20+1,#22+1,#26+1,#2A+1,#2C+1,#30+1,#54+1
        DB #BC+1,#BE+1,0
TCNEW_2 DB #1A+1,#20+1,#24+1,#28+1,#2A+1,#3A+1,#4C+1,#5E+1
        DB #BA+1,#BC+1,#BE+1,0

;first 12 values of tone tables

T_NEW_1
T_OLD_1 DW #0EF8*2,#0E10*2,#0D60*2,#0C80*2,#0BD8*2,#0B28*2
        DW #0A88*2,#09F0*2,#0960*2,#08E0*2,#0858*2,#07E0*2
T_NEW_3
T_OLD_3 DW #0CDA*2,#0C22*2,#0B73*2,#0ACF*2,#0A33*2,#09A1*2
        DW #0917*2,#0894*2,#0819*2,#07A4*2,#0737*2,#06CF*2
T_OLD_0=T_OLD_3+2
T_NEW_0=T_OLD_3+2
        DW #066D*2
T_NEW_2 DW #0D10*2,#0C55*2,#0BA4*2,#0AFC*2,#0A5F*2,#09CA*2
        DW #093D*2,#08B8*2,#083B*2,#07C5*2,#0755*2,#06EC*2
       ENDIF 
MEMOBUF;(320=#140)
SIN=(($+#23F)/256)<<8
        DISPLAY "SKIP BEFORE SIN=",SIN-MEMOBUF-#140
;        ds $-SIN
;        ds 0x1000
        DISPLAY "SINEND=",SIN+#1000
PRFONSCR
       IF mkvol
        LD HL,#11
        LD D,H
        ld E,H
        LD IX,TVOL+16
        LD B,#10
INITV2  PUSH HL
        ADD HL,DE
        ex de,hl 
        SBC HL,HL
INITV1  LD A,L
        RLA 
        LD A,H
        ADC A,0
        LD (IX),A
        INC IX
        ADD HL,DE
        INC B
        LD A,B
        AND 15
        jr NZ,INITV1
        POP HL
        LD A,E
        CP #77
        JR NZ,$+3
         INC E
        INC B
        DJNZ INITV2
       ENDIF 
        LD HL,0x48a1;#48E1
        ld BC,0x5810;#4810
        CALL VlN
        LD L,0xa5;#E5
        CALL VlN
        LD L,0xa7;#E7
        CALL VlN
        LD L,0xaf;#EF
        CALL VlN
        LD L,0xb7;#F7
        CALL VlN
        LD L,0xbf;#FF
        CALL VlN
        LD HL,#4715
        ld BC,#2281
        CALL VlN
        LD L,#1A
        CALL VlN
        LD L,#1F
        DEC C
        CALL VlN
        LD L,#10
        ld C,1
        CALL VlN
        INC L
PRFONSCRL
       DUP 3
        LD BC,#4FF
        LD (HL),C
        INC L
        DJNZ $-2
        INC L
       EDUP 
        BIT 0,H
        LD HL,#40B1
        jr NZ,PRFONSCRL
        LD HL,0x4f80;#4FC0
        ld B,31
         LD (HL),C
         INC L
        DJNZ $-2
        LD (HL),#F0
        LD DE,0x1a06;0x1806;#1A06
        CALL pRSprRR
        call pRSprRR
        LD de,0x1a09;e,10
        CALL pRSprRR
        LD DE,#700
        ld C,8;10
PRFONSCR0
        CALL pRSprPM
        DEC C
        jr NZ,PRFONSCR0
        LD DE,0x1806;0x1606;#1806
        CALL pRSprPM2
        ;INC E
         ;inc d
         ;inc d
        CALL pRSprPM2
        call pRSprPM2
        LD DE,0x1009;#1D0D
        CALL pRSprPM
        LD de,0x1d06;0x1b06;E,6
        CALL pRSprPM2
        ;INC E
         ;inc d
         ;inc d
        CALL pRSprPM
pRSprPM2
        CALL pRSprPM
pRSprPM
        LD HL,SprPM
        ld B,8
pRSprU
        PUSH DE
        push HL
        CALL DE2SCR
        POP DE
pRSpr0  LD A,(DE)
        ld (HL),A
        INC HL
        inc DE
        LD A,(DE)
        ld (HL),A
        INC DE
        DEC HL
        INC H
        DJNZ pRSpr0
        POP DE
        INC E
        RET 
pRSprRR
        LD HL,SprRRR
        ld B,6
        JR pRSprU

VlN
       PUSH BC
       push HL
VlN0    LD (HL),C
        CALL DHL
        DJNZ VlN0
       POP HL
       pop BC
        RET 
SprPM
        db 0x01,0x01,0x10,0x00,0x11,0x01,0x7C,0x7C,0x11,0x01,0x10,0x00,0x01,0x01,0xAA,0xAA
SprRRR
        db 0x00,0x00,0x22,0x20,0x33,0x30,0x3B,0xB8,0x33,0x30,0x22,0x20
Tfonscr
 DB        "Tempo       04      Disk Options       Octave 04   Step 00"
 DB 6,0, 1,"Position    00         Clears"
 DB 6,0, 2,"Pattern     00        Compiler"
 DB 6,0, 3,"Length      01         Set_up"
 DB 6,0, 4,"Loop to     00      Play  Melody"
 DB 6,0, 5,"Volume      0F      Play Pattern"
 DB 6,0, 6,"Edit patt.  00        About Me         Sample 01        01"
 DB 6,0, 7,"Patt length 64      Edit  Melody       Ornam. 01        01"
 DB 6,0, 8,"Edit data OFF ----     Chip 01        Pattern 00        00"
 DB 6,0, 9,"Auto env. OFF  1:1  Vol Tone +00      Channel 01        01"
 DB 6,0,10,"Music:",6,38,10,"Begin   00    Home00"
 DB 6,0,11,"   by:",6,38,11,"End     63      Exchange"
 DB 6,0,12,"      ---- ---- ----            ----            ----"
 db #A0
FONATRS
        ;INCBIN "fonatrs.bin"
        ds 16,0x45 ;0
       ds 16,0x07
        ds 16,0x44 ;1
       db 0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07
        ds 16,0x45 ;2
       db 0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07
        ds 16,0x44 ;3
       db 0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07
        ds 9,0x45  ;4
       ds 7,0x47
       db 0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07,0x47,0x47,0x47,0x47,0x07
        ds 16,0x44 ;5
       ds 16,0x07
        ds 31,0x45 ;6
       db 0x07
        ds 31,0x44 ;7
       db 0x07
        ds 9,0x45  ;8
       ds 10,0x07
       ds 12,0x45
       db 0x07
        ds 31,0x44 ;9
       db 0x07
        ds 3,0x45  ;10
       ds 16,0x47
       ds 7,0x45
       ds 2,0x07
       ds 3,0x45
       db 0x07
        ds 3,0x44  ;11
       ds 16,0x47
       ds 12,0x44
       db 0x07
        ds 32,0x07 ;12
        
        ds 32*6,0x07
        db 0x4f,0x4d,0x4f,0x4f,0x4f,0x4f,0x4e,0x4f,0x4f,0x4f,0x4f,0x4f,0x4f,0x4e,0x4e,0x4d
        db 0x4f,0x4f,0x4f,0x4f,0x4f,0x4e,0x4e,0x4d,0x4f,0x4f,0x4f,0x4f,0x4f,0x4e,0x4e,0x4d
        ds 32*4,0x07
;end
