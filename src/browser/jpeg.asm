preview=1 ;CAPS=thumbnail 

ONEPAGEYUV=0;1 ;TODO YUV в одном потоке на несколько страниц с чередованием составляющих? (чтобы картинку можно было шире 1024), но будет проблема с масштабированием SAMPLE на границе страниц

JPGPAGESTART=0xc000 ;в одной страничке до 16 строк до 0x400 пикселей каждая
;TODO 0x8000 с двойными страницами под составляющую (чтобы картинку можно было шириной 2048)
;TODO составляющие хранить вертикально и рендерить прямо в них, без переброски с масштабированием

;таблицы умножения в pg0 ;TODO в 0x4000+
;заполняются в GENMTAB
_D0=0xd0 ;два набора, второй в +0x18
_D2=_D0+0x02
_D4=_D0+0x04
_D6=_D0+0x06
_D8=_D0+0x08
_DA=_D0+0x0a
_DC=_D0+0x0c
_DE=_D0+0x0e
_E0=_D0+0x10
_E2=_D0+0x12
_E4=_D0+0x14
_E6=_D0+0x16

;FREE=0x8000 ;динамическая память, размер=0x13be для girl.jpg, izba1024.jpg, =0x12be для карлсон.jpg

;LINE1=0x3300;0x9400 ;буфер строки 0x400*3?
  
JPEGCLEARADDR=FREE;0xa000
JPEGCLEARSZ=0xc000-JPEGCLEARADDR

G716C=0xa000 ;CR tab (add to Y->R)G7174=G716C+0x200 ;CR tab (add to Y->G)G7178=G7174+0x200 ;CB tab (add to Y->B)G7170=G7178+0x200 ;CB tab (add to Y->G)

_thuffs=0xad00 ;размер=0x214 (girl.jpg, izba1024.jpg, карлсон.jpg) - временный буфер, после maketree не нужен

SAMPLE=0xac00 ;DS #80 ;блок 8x8 (по 2 байта), потом оттуда читаем через стек (подряд, один раз) ;перед ним немного места под стекSAMTAB=SAMPLE+0x80 ;DS #80
;таблица обрубания переполненияPLTAB=0xad00 ;DS #300PTAB=PLTAB+0x100
VAR=0xaa00 ;было в #4200
VARS=VAR ;???
VARSsz=0x123
 ;+#48 = ??? [2] в jpgreadsizes, должно быть =8
 ;+#4e = ??? только запись ;+#50-51 = ??? только запись ;+#52-53 = ??? только запись ;+#56-#57 = ??? результат выделения динамической памяти в jpgreadsizes;+#5A-#69=табл pQTB;+#6A-#79=табл pLHTB;+#7A-#89=табл pHHTB;+#C2=период вызова M18E7A (чанк M141FE);+#120=здесь он считается;+#110-#11F=табл.накопленных DC, 4? записи по 2 байта (+E0*2 байт???)
;+#120=какой-то счётчик?
;+#122=что-то write only???
;DISKBUF=0xb000
        
       MACRO rdbytecheckFFSCF        rdbyte        CP -1        CALL NC,RDFF       ENDM  

RDFF        CALL RDBYTE        INC A        JR Z,RDFF ;может быть много #FF        SUB 2 ;#FF кодировано как #FF,#00        RET 
GENMTAB        LD E,0        CALL SETPG       LD HL,_D0<<8s=2k=1<<sf=#E8-#D0        LD DE,#1151*2/k        CALL GEN        LD DE,#187E*2/k ;D2        CALL GEN        LD DE,#3B21*2/k ;D4        CALL GEN        LD DE,#25A1*2/k ;D6        CALL GEN        LD DE,#0C7C*2/k ;D8        CALL GEN        LD DE,#1CCD*2/k ;DA        CALL GEN        LD DE,#300B*2/k ;DC        CALL GEN        LD DE,#3EC5*2/k ;DE        CALL GEN        LD DE,#5203*2/k ;E0        CALL GEN        LD DE,#6254*2/k ;E2        CALL GEN        LD DE,#41B3*2/k ;E4        CALL GEN        LD DE,#098E*2/k ;E6        CALL GENs2=5k=1<<s2        LD DE,#1151*2/k ;E8        CALL GENA        LD DE,#187E*2/k ;EA        CALL GENA        LD DE,#3B21*2/k ;EC        CALL GENA        LD DE,#25A1*2/k ;EE        CALL GENA        LD DE,#0C7C*2/k ;F0        CALL GENA        LD DE,#1CCD*2/k ;F2        CALL GENA        LD DE,#300B*2/k ;F4        CALL GENA        LD DE,#3EC5*2/k ;F6        CALL GENA        LD DE,#5203*2/k ;F8        CALL GENA        LD DE,#6254*2/k ;FA        CALL GENA        LD DE,#41B3*2/k ;FC        CALL GENA        LD DE,#098E*2/k ;FEGENA        LD IX,0        LD C,0GM0A    LD B,128GM1A    LD A,HX        LD (HL),A        INC H        LD (HL),C        DEC H        ADD IX,DE        JR NC,$+3        INC C        INC L        DJNZ GM1A        XOR A        SUB LX        LD LX,A        LD A,B;0        SBC A,HX        LD HX,A        SBC A,A        SUB C        LD C,A        INC L        DEC L        JR NZ,GM0A       INC H
       inc H        RET GEN        LD IX,0        LD BC,0GM1     LD (HL),C        INC H        LD (HL),B        DEC H        ADD IX,DE        JR NC,$+3        INC BC        INC L        JR NZ,GM1       INC H
       inc H        RET M18E7A       ;IFN rdcyc       ; LD A,(RDCYC)       ; OR A       ; JR NZ,rDCOK       ;ENDIF FMR1    rdbyte        INC A        JR NZ,FMR1FMR2    rdbyte        INC A        JR Z,FMR2        DEC A        JR Z,FMR1rDCOK        LD A,(VAR+#E0)        ADD A,A        LD B,A ;не больше #10? (см. ниже VAR+#120)        LD HL,VAR+#110        XOR AcLHT    LD (HL),A        INC HL        DJNZ cLHT       ;IFN rdcyc       ; LD (RDCYC),A       ;ENDIF        LD A,128       LD (BITER),A        LD A,(VAR+#C2)        LD (VAR+#120),A        RET 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RDSAMP
        IF preview       ;LD A,(cOLPOI) ;0=B/W       ;OR A       ;SCF        ;JR NZ,RDSAnGR       ;LD A,(pSMPPG_1) ;1/2/5       ;CP 2 ;1/2/5 (2/5=CB/CR=SKIP);RDSAnGR       ;IFN fCS       CALL getCS       ;ELSE        ;CALL C,8026       ;ENDIF          LD A,prevdj
         ld BC,#202        JR NC,$+7        LD A,YBITdj
        ld BC,#FCFA       LD (YBITjr),A       LD A,C
       ld (HORdjnz),A       LD A,B
       ld (VERdjnz),A        ENDIF        ;DI        LD (pSPS1_1),SP        LD SP,SAMPLE+#80        LD HL,0       DUP #40        PUSH HL       EDUP pSPS1_1=$+1
        LD SP,0pLHTB_2=$+2
        LD IX,0        CALL dehuf        OR A       LD H,A
       ld L,A       CALL NZ,RDBITS        EX DE,HLpHCNT   LD HL,(VAR+#110)        ADD HL,DEpHCNT2  LD (VAR+#110),HL        EX DE,HLpQTBDC_1=$+1
        LD A,(0) ;ok        CALL MULDE_AQ        LD (SAMPLE),HLPRMODE=$+1    LD A,0    CP #C2    JR Z,BRKLP       LD A,#02;63 коэффициента ACSCNLP1        ex af,af'
pHHTB_2=$+2
        LD IX,0        CALL dehuf        LD L,A       LD H,R4A0F/256       LD H,(HL)        AND #0F        JR NZ,YBITYBITjr=$-1        LD A,H        CP #20 ;L=#F0?        JR NZ,BRKLP        ex af,af'
       ADD A,32       JP P,SCNLP1       JR BRKLPprevYBITprevdj=$-YBITjr-1        LD B,A        LD DE,BITER        LD A,(DE)skBLP   ADD A,A        JR Z,skNEW        DJNZ skBLP        LD (DE),A        ex af,af'
        ADD A,H       JP P,SCNLP1       JR BRKLPskNEW        rdbytecheckFFSCF        RLA         DJNZ skBLP        LD (DE),A        ex af,af'
        ADD A,H       JP P,SCNLP1       JR BRKLPYBITYBITdj=$-YBITjr-1        ex af,af'
        ADD A,H       LD E,A
       ld D,Qorder/256        ex af,af'
       CALL RDBITS        EX DE,HL       LD A,(HL)       LD (Qadr),ApQTB    LD BC,0        ADD HL,BC        LD A,(HL)        CALL MULDE_AQQadr=$+1       LD (SAMPLE),HL        ex af,af'
       JP P,SCNLP1BRKLP        LD E,0        CALL SETPG;---------------------------       ;DI ;из-за iy?       PUSH IY        LD IX,SAMPLE        LD B,8HORLP        PUSH BC       PUSH IX       POP HL        INC L        XOR A        LD B,7        INC L        OR (HL)        INC L        OR (HL)        DJNZ $-4HORdjnz=$-1        JR NZ,NOEMPH        LD A,(IX)
        ld D,(IX+1)       DUP 2+s        SRA D        RRA        EDUP        PUSH IX       POP HL        LD B,8        LD (HL),A        INC L
        inc L        DJNZ $-3        JP HORZOKNOEMPH       LD C,(IX+4)
       ld B,(IX+5)       LD L,(IX+#C)
       ld H,(IX+#D)       PUSH HL       ADC HL,BC       LD D,_D0       CALL NZ,MULLONG       LD H,B        LD B,L       LD L,C       LD D,_D2       LD A,H       OR L       CALL NZ,MULLONG        LD A,L        ADD A,B        LD C,A       POP HL       LD D,_D4       LD A,H       OR L       CALL NZ,MULLONG        LD A,B        SUB L        LD B,A       LD L,(IX)
       ld H,(IX+1)       LD E,(IX+8)
       ld D,(IX+9)       PUSH HL       ADD HL,DE       LD A,L       DUP 2+s       SRA H       RRA        EDUP         ADD A,C      LD LY,A        SUB C,C       POP HL       SBC HL,DE      LD E,A       LD A,L       DUP 2+s       SRA H       RRA        EDUP         ADD A,B      LD C,A        SUB B
        sub B      LD B,A      EXX        LD L,(IX+#A)
       ld H,(IX+#B)       LD E,(IX+6)
       ld D,(IX+7)      PUSH DE      PUSH HL       ADD HL,DE       EX DE,HL       LD C,(IX+#E)
       ld B,(IX+#F)       ADD HL,BC      PUSH DE      PUSH BC      PUSH HL      PUSH BC       EX DE,HL       ADD HL,BC       LD C,(IX+2)
       ld B,(IX+3)       ADC HL,BC       LD D,_D6       CALL NZ,MULLONG      LD A,L      ex af,af'
       LD L,(IX+#A)
       ld H,(IX+#B)       ADC HL,BC       LD D,_D8       CALL NZ,MULLONG      ex af,af'
        SUB L      LD HY,A      ADD A,L      ex af,af'
      POP HL       ADC HL,BC       LD D,_DA       CALL NZ,MULLONG       LD H,B        LD B,L       LD L,C       LD D,_DC       LD A,H       OR L       CALL NZ,MULLONG      LD A,HY        SUB B        ADD A,L        LD L,A      ADD A,LY        LD (IX),A        SUB L
        sub L        LD (IX+#E),A      POP HL       LD D,_DE       LD A,H       OR L       CALL NZ,MULLONG      ex af,af'
        SUB L        LD C,A      POP HL       LD D,_E6       LD A,H       OR L       CALL NZ,MULLONG        LD A,C        SUB B        ADD A,L        LD L,A      EXX       ADD A,E      EXX         LD (IX+6),A        SUB L
        sub L        LD (IX+8),A      POP HL       LD D,_E0       LD A,H       OR L       CALL NZ,MULLONG        LD B,L      POP HL       LD D,_E4       LD A,H       OR L       CALL NZ,MULLONG      LD A,HY        ADD A,L        SUB B        LD L,A      EXX       ADD A,B      EXX         LD (IX+4),A        SUB L
        sub L        LD (IX+#A),A      POP HL       LD D,_E2       LD A,H       OR L       CALL NZ,MULLONG        LD A,L        SUB B        ADD A,C        LD L,A      EXX       ADD A,C      EXX         LD (IX+2),A        SUB L
        sub L        LD (IX+#C),AHORZOK        LD DE,16        ADD IX,DE        POP BC        DEC B        JP NZ,HORLP;---------------------------        LD IX,SAMPLE        LD B,8VERULP        PUSH BC        PUSH IX        POP HL        XOR A        LD DE,16        LD B,7        ADD HL,DE        OR (HL)        DJNZ $-2VERdjnz=$-1        JR NZ,NOEMPV        LD A,(IX)       ADD A,A       LD L,A       SBC A,A       LD H,A        PUSH IX        LD B,8fLULP   LD (IX),L
        ld (IX+1),H        ADD IX,DE        DJNZ fLULP        POP IX        JP VERTUOKNOEMPV        LD A,(IX+#60)        LD E,(IX+#20)        ADD A,E        LD L,A       LD H,_D0+f       LD C,(HL)       INC H       LD B,(HL)        LD L,E       INC H       LD A,(HL)       INC H       LD H,(HL)
       ld L,A        ADD HL,BC       EX DE,HL         LD A,(IX)         ADD A,(IX+#40)       ADD A,A       LD L,A       SBC A,A       LD H,A        SBC HL,DE      PUSH HL       ;LD (vLC6_1),HL        ADD HL,DE
        add HL,DE        LD (nPD0H_1),HL        LD L,(IX+#60)       LD H,_D4+f       LD E,(HL)       INC H       LD D,(HL)      LD H,B
      ld L,C        SBC HL,DE        EX DE,HL         LD A,(IX)         SUB (IX+#40)       ADD A,A       LD L,A       SBC A,A       LD H,A        SBC HL,DE      PUSH HL       ;LD (vLC2_1),HL        ADD HL,DE
        add HL,DE        LD (vLC0E_1),HL        LD A,(IX+#50)        LD (vLC20_1),A        LD E,A        LD A,(IX+#30)        LD (vLC1C_1),A        LD C,A        ADD A,E        LD (vLC24_1),A        LD A,(IX+#70)        LD (vLC14_1),A       LD B,A        ADD A,C        LD (vLC28_1),A        ADD A,E       LD C,(IX+#10)       ADD A,C        LD L,A       LD H,_D6+f       LD A,(HL)       INC H       LD H,(HL)
       ld L,A      PUSH HL       LD A,E       ADD A,C        LD L,A       LD H,_D8+f       LD E,(HL)       INC H       LD D,(HL)      POP HL      PUSH HL       SBC HL,DE        LD (nPD3H_1),HL        EX DE,HL       LD A,B       ADD A,C       LD L,A        LD A,C       LD H,_DA+f       LD C,(HL)       INC H       LD B,(HL)        LD L,A       INC H       LD A,(HL)       INC H       LD H,(HL)
       ld L,A        SBC HL,BC        ADD HL,DE       EX DE,HLnPD0H_1=$+1
        LD HL,0        SBC HL,DE        LD (IX+#70),L
        ld (IX+#71),H        ADD HL,DE
        add HL,DE        LD (IX),L
        ld (IX+1),HvLC28_1=$+1
       LD HL,+(_DE+f)<<8       LD E,(HL)       INC H       LD D,(HL)      POP HL       SBC HL,DE      LD D,H
      ld E,L      SBC HL,BC      PUSH HLvLC24_1=$+1
       LD HL,+(_E0+f)<<8       LD C,(HL)       INC H       LD B,(HL)vLC1C_1=$+1
       LD HL,+(_E2+f)<<8       LD A,(HL)       INC H       LD H,(HL)
       ld L,A        SBC HL,BC        ADD HL,DE       EX DE,HLvLC0E_1=$+1
        LD HL,0        SBC HL,DE        LD (IX+#60),L
        ld (IX+#61),H        ADD HL,DE
        add HL,DE        LD (IX+#10),L
        ld (IX+#11),HvLC14_1=$+1
       LD HL,+(_E6+f)<<8       LD E,(HL)       INC H       LD D,(HL)      POP HL        ADD HL,DE       EX DE,HLvLC20_1=$+1
       LD HL,+(_E4+f)<<8       LD A,(HL)       INC H       LD H,(HL)
       ld L,A        SBC HL,BCnPD3H_1=$+1
        LD BC,0        ADD HL,BC       LD B,H
       ld C,L      POP HL        SBC HL,BC        LD (IX+#50),L
        ld (IX+#51),H        ADD HL,BC
        add HL,BC        LD (IX+#20),L
        ld (IX+#21),H      POP HL        SBC HL,DE        LD (IX+#40),L
        ld (IX+#41),H        ADD HL,DE
        add HL,DE        LD (IX+#30),L
        ld (IX+#31),HVERTUOK        INC LX
        inc LX        POP BC        DEC B        JP NZ,VERULP       POP IY       ;EI         RET ;twice;/21331 CALLS;150t=1sMULDE_AQ       LD HL,0       RLA       JP NC,$+6      LD H,D
      ld L,E      ADD HL,HL        DUP 6       RLA        JR NC,$+3       ADD HL,DE       ADD HL,HL        EDUP        RLA        RET NC       ADD HL,DE       RET ;/65537 CALLS;50t=1sRD1BBITER=$+1        LD A,128        ADD A,A        JR Z,rD1NOLD        LD (BITER),A        RET rD1NOLD        rdbytecheckFFSCF        RLA rD1OLD  LD (BITER),A        RET ;2RDBITS        LD B,A       CALL RD1B       DEC B       JR NC,RDBITSm        LD HL,1       RET ZrDBLP   ADD A,A        JR Z,rDNEWrDNEWQ        ADC HL,HL        DJNZ rDBLP        LD (BITER),A        RET RDBITSm        LD HL,-2       JR Z,rDBITsmQrDBLPm  ADD A,A        JR Z,rDNEWmrDNEWQm        ADC HL,HL        DJNZ rDBLPm        LD (BITER),ArDBITsmQ       INC HL        RET rDNEW        rdbytecheckFFSCF        RLA         JP rDNEWQrDNEWm        rdbytecheckFFSCF        RLA         JP rDNEWQm
;хаффман;/25364 CALLS;150t=1sdehuf
;ix в районе FREE        LD A,(BITER)        ADD A,A        CALL Z,rD1NOLD       LD DE,0       RL E        JP fNDHLPhD1NOLD        rdbytecheckFFSCF        RLA         JP $+6rDNXT        ADD A,A        JR Z,hD1NOLD       RL E
       rl D        INC IX
        inc IXfNDHLP        LD L,(IX+1)
        ld H,(IX)       INC HL       SCF         SBC HL,DE        JP C,rDNXT        LD (BITER),A        LD H,(IX+#482-#43C)
        ld L,(IX+#483-#43C)        ADD HL,DE        LD A,(HL)        RET MSHTAB        LD A,H        OR AMSHTABA
           ;JR mSH3216
        JR NZ,mSH3216 ;HL>=256: полноценное умножение        LD H,D        LD E,(HL)        INC H        LD D,(HL)        EX DE,HL        RET mSH3216        EX DE,HL       LD L,64;16        LD A,(HL)        LD H,0        RRA         JR NC,$+7        ADD HL,DE        RR H
        rr L       DUP 5;3        RRA         JR NC,$+3        ADD HL,DE        RR H
        rr L       EDUP         RET 

;hl=nnnn
;d=multable/256 (512 bytes)
;out: hlMULLONG        BIT 7,H        JP Z,MSHTAB        XOR A        SUB L        LD L,A        SBC A,A        SUB H        LD H,A        CALL MSHTABA        XOR A        SUB L        LD L,A        SBC A,A        SUB H        LD H,A        RET M1696A
;перекодируем 2-байтные данные из SAMPLE (-#180..+#180) в однобайтные в строке блоков
;hl=адрес блока в строке блоков LSZX*8        ;DI        LD (pSPS3_1),SP         ;LD DE,(LSZXM8)         ;INC DE
LSZXm7=$+1
         ld de,0        LD SP,SAMPLE        EXX         LD DE,PTAB+#80 ;таблица обрубания переполнения        LD B,8cOPLOOP  DUP 7         POP HL         ADD HL,DE         LD A,(HL)         EXX          LD (HL),A         INC HL         EXX          EDUP          POP HL         ADD HL,DE         LD A,(HL)         EXX          LD (HL),A        ADD HL,DE ;de=LSZX-7        EXX         DJNZ cOPLOOPpSPS3_1=$+1
        LD SP,0        ;EI         RET ;HL=(pLNADR+1)M166AA;перекодируем 2-байтные данные из SAMPLE в однобайтные в строке блоков, с увеличением в 2 раза
;hl=адрес блока в строке блоков LSZX*8        ;DI        LD (pSPS6_1),SPpLSMH2_1=$+1
        LD BC,0        LD SP,SAMPLE        LD (pLSS_1),BC        EXX         LD DE,PTAB+#80 ;таблица обрубания переполнения        LD B,8pXSCL_1=$+1
        JR IN3IN2        POP HL        ADD HL,DE        LD A,(HL)        EXX        LD (pLLIN_1),HL       DUP 7        LD (HL),A        INC HL        LD (HL),A        INC HL        EXX         POP HL        ADD HL,DE        LD A,(HL)        EXX        EDUP         LD (HL),A        INC HL        LD (HL),A        INC HLpYSCL_1=$+1
        LD A,0C2LP        ADD HL,BC       EX DE,HLpLLIN_1=$+1
        LD HL,0
        dup 16
        ldi
        edup       EX DE,HLpLSS_1=$+1
        LD BC,0        DEC A        JR NZ,C2LP        ADD HL,BC        EXX         DJNZ IN2        JP pSPS6IN3        POP HL        ADD HL,DE        LD A,(HL)        EXX        LD (pLLIN1_1),HL       DUP 7        LD (HL),A        INC HL        LD (HL),A        INC HL        LD (HL),A        INC HL        EXX         POP HL        ADD HL,DE        LD A,(HL)        EXX        EDUP         LD (HL),A        INC HL        LD (HL),A        INC HL        LD (HL),A        INC HL        LD A,(pYSCL_1)C3LP        ADD HL,BC       EX DE,HLpLLIN1_1=$+1
        LD HL,0
        dup 24
        ldi
        edup       EX DE,HL        LD BC,(pLSS_1)        DEC A        JR NZ,C3LP        ADD HL,BC        EXX         DEC B        JP NZ,IN3
pSPS6pSPS6_1=$+1
        LD SP,0        ;EI         RET M1675A;перекодируем 2-байтные данные из SAMPLE в однобайтные в строке блоков, с увеличением в 2 раза по X?
;hl=адрес блока в строке блоков LSZX*8        ;DI        LD (pSPS5_1),SPpLSMH_1=$+1
        LD DE,0        LD SP,SAMPLE        EXX         LD DE,PTAB+#80 ;таблица обрубания переполнения        LD C,8Co3LOOP       DUP 7        POP HL        ADD HL,DE        LD A,(HL)        EXX         LD (HL),A        INC HL        LD (HL),A        INC HL        EXX        EDUP         POP HL        ADD HL,DE        LD A,(HL)        EXX         LD (HL),A        INC HL        LD (HL),A        INC HL        ADD HL,DE        EXX         DEC C        JR NZ,Co3LOOPpSPS5_1=$+1
        LD SP,0        ;EI         RET 
;pg1 = Y -> G?
;pg2 = Cb -> R
;pg5 = Cr -> B
;по одним и тем же адресам, начиная с JPGPAGESTART(0xc000) -> BGR
        
;TODO с учётом масштабирования пропускать строкиjpgconvRGB
;HL=JPGPAGESTART;A=(MAXV8) ;высота полноценного блокаjpgconvRGBlines0jpglinecount=$+1
        ld de,0
        dec de
        bit 7,d
        ret nz ;строки сверх высоты картинки не выводить
        ld (jpglinecount),de
        push af
         ;bit 0,e
         ;jp z,jpgconvRGBlineskip ;TODO с учётом зума
         call islinevisible
         jp nz,jpgconvRGBlineskip
        push hl
        ;1.читать в LINE каждую составляющую отдельно, 2.перекодировать каждую составляющую отдельно, 3. записывать сразу в bmp (BGR)
        ld e,1
        call SETPG
        ld de,LINE1
        ld bc,(curpicwid)
jpgcnvcopylineY0
        ldi
        inc de
        inc de
        jp pe,jpgcnvcopylineY0
        pop hl
        push hl
        ld e,2
        call SETPG
        ld de,LINE1+1
        ld bc,(curpicwid)
jpgcnvcopylineCB0
        ldi
        inc de
        inc de
        jp pe,jpgcnvcopylineCB0
        pop hl
        push hl
        ld e,5
        call SETPG
        ld de,LINE1+2
        ld bc,(curpicwid)
jpgcnvcopylineCR0
        ldi
        inc de
        inc de
        jp pe,jpgcnvcopylineCR0
;этот фрагмент=55481
        
        ld hl,LINE1
        ld bc,(curpicwid)
jpgconvRGBpixels0
        LD A,(HL) ;Y
        inc hl        LD (pY8_),A        LD A,(HL) ;CB
        inc hl        LD (pCB8_),A
        LD A,(HL) ;CR
        EXX        LD L,A ;CR       LD H,G716C/256 ;CR tab (add to Y->R) ;k>=0?        LD E,(HL)        INC H        LD D,(HL)       INC H ;G7174/256 ;CR tab (add to Y->G) ;k<0?        LD C,(HL)        INC H        LD B,(HL)pY8_=$+1
        LD HL,PTAB ;таблица обрубания переполнения + Y       EX DE,HL        ADD HL,DE ;de=таблица обрубания переполнения + Y        LD A,(HL) ;R без контраста
        exx
        ld (hl),a ;R без контраста
        exxpCB8_=$+1
        LD HL,G7170 ;CB tab (add to Y->G)       DEC H       LD A,(HL)       DEC H ;G7178/256 ;CB tab (add to Y->B) ;k<0?       LD L,(HL)       LD H,A        ADD HL,BC        ADD HL,DE ;de=таблица обрубания переполнения + Y        LD A,(HL) ;G без контраста
        ex af,af'       LD HL,(pCB8_) ;G7170+ ;CB tab (add to Y->G) ;k>=0?        LD C,(HL)        INC H        LD B,(HL)       EX DE,HL ;hl=таблица обрубания переполнения + Y        ADD HL,BC         ld a,(hl) ;B без контраста        EXX         dec hl
        dec hl
        LD (HL),A ;B без контраста
        inc hl
         ex af,af'
         ld (hl),a ;G без контраста        inc hl
        cpi        jp pe,jpgconvRGBpixels0 ;один проход цикла = 358
;цикл=171870

        ld hl,LINE1
        ld bc,(curpicwidx3)
;hl=откуда копируем строку
;bc=сколько байт копируем
        ;push hl
        ;call putline ;30644
        ;pop hl
        call drawscreenline_frombuf ;конвертируем LINEGIF в LINEPIXELS и выводим её на экран ;меняет, потом восстанавливает 0x4000, 0x8000
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS

        pop hl
jpgconvRGBlineskip
         call inccury
        LD DE,(LSZX) ;ширина строки, округлённая вверх до полноценного блока        ADD HL,DE ;следующая строка блока        pop af        dec a        JP NZ,jpgconvRGBlines0 ;на всю высоту полноценного блока ;одна строка = 258150        RET ;4 130 590
jpgconvBW
;HL=JPGPAGESTART;A=(MAXV8) ;высота полноценного блока        ;ld e,1
        ;call SETPG
jpgconvBWlines0        ld de,(jpglinecount)
        dec de
        bit 7,d
        ret nz ;строки сверх высоты картинки не выводить
        ld (jpglinecount),de
        push af         ;bit 0,e
         ;jp z,jpgconvBWlineskip ;TODO с учётом зума
         call islinevisible
         jp nz,jpgconvBWlineskip
        push hl
         ld e,1
         call SETPG
         
;1.читать в LINE составляющую Y во все три составляющих RGB, 2. записывать сразу в bmp (BGR)
        ld de,LINE1
        ld bc,(curpicwid)
jpgconvBWcopylineY0
        ld a,(hl)
        ld (de),a
        inc de
        ld (de),a
        inc de
        ldi
        jp pe,jpgconvBWcopylineY0
        
        ld hl,LINE1
        ld bc,(curpicwidx3)
;hl=откуда копируем строку
;bc=сколько байт копируем
        ;push hl
        ;call putline ;30644
        ;pop hl
        call drawscreenline_frombuf ;конвертируем LINEGIF в LINEPIXELS и выводим её на экран ;меняет, потом восстанавливает 0x4000, 0x8000
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS

        pop hl
jpgconvBWlineskip
         call inccury
        LD DE,(LSZX) ;ширина строки, округлённая вверх до полноценного блока        ADD HL,DE ;следующая строка блока        pop af        dec a        JP NZ,jpgconvBWlines0 ;на всю высоту полноценного блока        ret
        

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JPEG_CLPG=0
        if JPEG_CLPG
clpg
        ld hl,0xc000
        ld de,0xc001
        ld bc,0x3fff
        ld (hl),l ;0
        ldir
        ret
        endif

readjpeg
        if JPEG_CLPG
        ld e,0
        call SETPG
        call clpg
        ld e,1
        call SETPG
        call clpg
        ld e,2
        call SETPG
        call clpg
        ld e,5
        call SETPG
        call clpg
        endif

        ld hl,JPEGCLEARADDR
        ld de,JPEGCLEARADDR+1
        ld bc,JPEGCLEARSZ-1
        ld (hl),0
        ldir

        ld hl,LINE1
        ld de,LINE1+1
        ld (hl),BACKGROUNDCOLORLEVEL
        ld bc,LINE1_sz-1
        ldir ;чтобы справа в остатке знакоместа была чернота (потом можно убрать, когда readchr будет это делать)
        
        ;ld hl,VARS
        ;ld de,VARS+1
        ;ld bc,VARSsz-1
        ;ld (hl),0
        ;ldir ;какие-то переменные ожидаются в 0 - TODO найти какие
        
        ;LD HL,jpgputline        ;LD (pPROC+1),HL        LD HL,FREE        LD (MEMDN),HL       ;LD HL,JPGPAGESTART        ;LD (pSCR2+1),HL       ;IFN buf9000       ;LD A,DISKBUF/256+(DISKBUFsz/256)       ;LD (RDBYHend),A       ;LD IY,DISKBUF+DISKBUFsz-1       ;ELSE        ; LD H,L       ; LD (BFLEN),HL       ;ENDIF        ;LD A,(SCRPRC)       ;LD (WASCRPRC),A ;настройка наложения на старый экран?        ;CALL iNITJPG         ld hl,SAMTAB
         ld (pPST_1),hl

        CALL FBMARK        CALL LBMARK        ;CALL pSCAL ;установка масштабов        ;CALL SETPG7       ;CALL PRSIZES;onceGMAXC        LD A,(CNUM)        LD B,A        LD IX,(VAR+#56)        PUSH IX
        push BC        LD HL,#101       LD DE,18gMAXS   LD A,(IX+2)        CP H        JR C,$+3        LD H,A        LD A,(IX+3)        CP L        JR C,$+3        LD L,A        ADD IX,DE        DJNZ gMAXS       ;LD A,H       ;LD (MAXH),A       ;LD A,L        LD (MAXV),HL;A        POP BC
        pop IXrESCLP  PUSH BC        LD DE,(curpicwid)        LD A,(IX+2)        CALL MULDE_A        LD DE,(MAXH)        ADD HL,DE        DEC HL        CALL DIVHL_DE       LD (IX+7),C       LD (IX+8),B        LD DE,(curpichgt)        LD A,(IX+3)        CALL MULDE_A        LD DE,(MAXV)        ADD HL,DE        DEC HL        CALL DIVHL_DE       LD (IX+9),C       LD (IX+#0A),B       LD DE,18       ADD IX,DE        POP BC        DJNZ rESCLP;SELECT OUTPUT        ;CALL 8026        ;LD A,(PIXPOI)        ;JR C,$+4        ;LD A,3        ;LD (pIXPOI),A        ;LD BC,0        ;JR NC,bC_JR        ;LD A,(BRIGP)        ;LD HL,CONTP        ;OR (HL)        ;LD B,A        ;INC B        ;DEC C;bC_JR       ;IFN fCS       ;LD A,C,(rdCS+1),A       CALL rdCSU ;первоначальное чтение CS       ;ENDIF 
       
        LD A,(CNUM)        ;LD (VAR+#C8),A        ;LD (VAR+#CA),A        DEC A
         ld hl,jpgconvBW
        JR Z,YEGRSC ;greyscale image        CP 2        CALL NZ,ERROR ;not YUV        LD HL,jpgconvRGB
        ;JR sTCFYEGRSC        ;LD HL,CNVTOGR        ;DJNZ $+5        ;LD HL,EMPTYsTCF      ;LD (cOLPOI),A        LD (jpgconv_patch),HL ;процедура конверсии YUV -> RGB        ;DEC A        ;ADD A,A        ;LD HL,CLADR        ;CALL HLA   ;HL+=A        ;CALL DEGRB ;DE=(HL)        ;EX DE,HL        ;LD (pCLRS+1),HL         

        ;push iy
        ;call reserve_bmp_pages
        ;pop iy
        
;всё до render=203762
render
        ld hl,(curpichgt)
        ld (jpglinecount),hl
                CALL YCCTAB ;103518        CALL GENMTAB ;430734       ;CALL MAKCTB
      PUSH IY       CALL setsamplescalers ;1253       CALL maketrees;M18E08 ;110466      POP IY        
;заполняем после maketrees, поверх её буфера        LD l,0cNTBLP  LD H,PLTAB/256 ;таблица отсечения переполнения        ld (hl),0
        inc h        LD (HL),L
        inc h        LD (HL),-1        INC L        JR NZ,cNTBLP        LD A,(MAXV)        ADD A,A        ADD A,A        ADD A,A        LD (MAXV8),A        LD A,(MAXH)        ADD A,A        ADD A,A        ADD A,A        LD (MAXH8),A        LD HL,(curpicwid)        CALL ROUND ;HL=k*A (>=HL)        LD (LSZX),HL        LD DE,7       OR A        SBC HL,DE        LD (LSZXm7),HL        ADD HL,DE        LD DE,(MAXH8)       OR A        SBC HL,DE        LD (pLSMH_1),HL        LD (pLSMH2_1),HL        ADD HL,DE        ADD HL,HL        ADD HL,HL        ADD HL,HL        LD (BLSZ),HL       CALL MAKTS
;этот блок=27612
       
;рендер        LD A,(pichgt_inblocks) ;высота картинки в полноценных блоках        LD B,A ;0x16YLOOP   PUSH BC
;рендерим строку из полноценных блоков        LD HL,JPGPAGESTART        LD (LPNT),HL        LD A,(picwid_inblocks) ;ширина картинки в полноценных блоках        LD B,A ;0x1eXLOP    PUSH BC        CALL rENDLIN ;147235 один вызов        LD HL,(LPNT)        LD DE,(MAXH8)        ADD HL,DE        LD (LPNT),HL        POP BC        DJNZ XLOP
;6 007 979 цикл по горизонтали
                LD HL,JPGPAGESTART        LD A,(MAXV8) ;высота полноценного блокаjpgconv_patch=$+1
        CALL jpgconvRGB ;перекодируем в bmp ;4 130 590 один вызов
;следующая строка из полноценных блоков        POP BC        DJNZ YLOOP
        pNFX   LD DE,0 ;какая получилась высота с округлением вверх на полноценный блок ;0x160       LD HL,(curpichgt) ;0x15c       OR A       SBC HL,DE       RET Z       RET C ;в girl.jpg выход по CY
;высота с округлением вверх получилась меньше реальной??? это как??? TODO
       
;что происходит после рендера??? TODO
              LD HL,JPGPAGESTART        LD (LPNT),HL
rENDLIN
        LD HL,VAR+#110        LD (pHCNT+1),HL        LD (pHCNT2+1),HL        LD A,(VAR+#C2)       OR A        JR Z,gOREAD        LD A,(VAR+#120)       OR A       CALL Z,M18E7A        LD HL,VAR+#120        DEC (HL)gOREAD  LD HL,JF44 ;адрес таблицы из 4 функций        LD (pSFUNC+1),HL
                LD IX,SPGTB ;таблица из 3 страниц 1/2/5 ;TODO убрать        LD HL,SAMTABNXRS    LD A,(IX)        INC IX        LD (pSMPPG+1),A ;страничка 1/2/5 ;TODO убрать
                LD A,(HL) ;число слоёв?        INC HL        OR A       RET Z        PUSH IX        LD B,A
;перебираем все слои?NXRS1   PUSH BC        LD E,(HL)        INC HL        LD D,(HL)        INC HL       PUSH HL       LD HL,(LPNT)       ADD HL,DE       LD (pLNADR+1),HL       POP HL        LD E,(HL)        INC HL        LD D,(HL)        INC HL       INC DE       LD (pQTBDC_1),DE      DEC DE
      dec DE       LD A,D       SUB Qorder/256       LD D,A       LD (pQTB+1),DE        LD E,(HL)        INC HL        LD D,(HL)        INC HL        LD C,(HL)        INC HL        LD B,(HL)        INC HL       PUSH HL       LD HL,#43C;16       ADD HL,DE       LD (pLHTB_2),HL       SBC HL,DE       ADD HL,BC       LD (pHHTB_2),HL       POP HL        LD A,(HL)       ADD A,-1       SBC A,A       AND IN3-IN2        LD (pXSCL_1),A ;jr disp        INC HL        LD A,(HL)        LD (pYSCL_1),A        INC HL        PUSH HL        CALL RDSAMP
        if !ONEPAGEYUVpSMPPG  LD E,0 ;1/2/5 номер слоя
        CALL SETPG
        endifpLNADR  LD HL,0
        if ONEPAGEYUV        LD E,1
        CALL SETPG ;TODO убрать
pSMPPG  LD A,0 ;1/2/5 номер слоя
        ;пересчёт HL в зависимости от номера слоя
        cp 2
        jr nz,$+6
         set 3,h
         jr $+6
        jr c,$+4
        set 4,h
        endif pSFUNC  CALL 0 ;текущий адрес в таблице 4 функций ;по идее должно быть M1696A, M166AA, M1675A или EMPTY? перекладывает SAMPLE в нужный слой с нужным масштабированием        POP HL        POP BC        DJNZ NXRS1 ;следующий слой?
                EX DE,HL        LD HL,(pHCNT+1)        INC HL
        inc HL        LD (pHCNT+1),HL        ;LD HL,(pHCNT2+1) ;зачем? TODO        ;INC HL
        ;inc HL        LD (pHCNT2+1),HL        LD HL,(pSFUNC+1)       INC HL
       inc HL
       inc HL        LD (pSFUNC+1),HL        EX DE,HL        POP IX       JP NXRS
ROUNDm8        ADD A,A        ADD A,A        ADD A,A;3 timesROUND        LD E,A        LD D,0       ADD HL,DE       DEC HL       PUSH HL       CALL QUAHL_DE ;DE=HLmodDE       POP HL       OR A       SBC HL,DE ;HL=k*A (>=HL)        RET ;onceMAKTS        LD HL,(curpicwid)        LD A,(MAXH8)       LD E,A       LD D,0       ADD HL,DE ;       DEC HL    ;для округления вверх       CALL DIVHL_DE       LD (picwid_inblocks),BC        LD HL,(curpichgt)        LD A,(MAXV8)       LD E,A       LD D,0       ADD HL,DE ;       DEC HL    ;для округления вверх       CALL DIVHL_DE       LD D,B
       ld E,C        LD (pichgt_inblocks),DE        LD A,(MAXV8)        CALL MULDE_A        LD (pNFX+1),HL ;какая получилась высота с округлением на полноценный блок        LD HL,VAR+#E2        LD A,(CNUM)        LD B,ARCLP1   PUSH BC
        push HL        CALL GETIXHL       LD B,(IX+2)
       ld C,(IX+3)       LD (IX+#B),B
       ld (IX+#C),C       LD L,(IX+7)
       ld H,(IX+8)        LD A,B        CALL ROUNDm8 ;HL=k*A*8 (>=HL)        XOR A        ADD A,C        DJNZ $-1        LD (IX+#0D),A       LD (IX+#E),L
       ld (IX+#F),H       LD L,(IX+9)
       ld H,(IX+#A)        LD A,C        CALL ROUNDm8 ;HL=k*A*8 (>=HL)       LD (IX+#10),L
       ld (IX+#11),HpPST_1=$+1
        LD HL,SAMTAB        LD A,(IX+#D)        LD (HL),A        INC HL        LD DE,0        LD C,(IX+3)YMTLP   PUSH DE        LD B,(IX+2)XMTLP   PUSH BC        PUSH DE        LD (HL),E        INC HL        LD (HL),D        INC HL       EX DE,HL       LD HL,VAR+#5A        LD A,(IX+4)       ADD A,A       ADD A,L       LD L,A        LDI         LDI         LD A,(IX+5)       ADD A,A       ADD A,0xff&(VAR+#6A)       LD L,A        LDI         LDI         LD A,(IX+6)       ADD A,A       ADD A,0xff&(VAR+#7A)       LD L,A        LDI         LDI         LD A,(MAXH)        LD B,(IX+2)        CALL DIV8       SUB 2        LD (DE),A        INC DE        LD A,(MAXV)        LD B,(IX+3)        CALL DIV8        DEC A        LD (DE),A        INC DE       POP HL        LD BC,8        ADD HL,BC       EX DE,HL       POP BC        DJNZ XMTLP       POP DE       PUSH HL        LD HL,(BLSZ)        ADD HL,DE       EX DE,HL       POP HL        DEC C        JR NZ,YMTLP        LD (pPST_1),HL       EX DE,HL        POP HL        INC HL
        inc HL        POP BC       DEC B       JP NZ,RCLP1       EX DE,HL       LD (HL),B        RET ;         Y CB CRSPGTB        DB 1,2,5;oncesetsamplescalers        LD A,(VAR+#BE)        OR A        CALL NZ,ERROR        LD A,(VAR+#E0)        LD B,A        LD HL,VAR+#E2        LD IY,JF44+1 ;адрес таблицы из 4 функцийuPFLP        PUSH HL        CALL GETIXHL       LD HL,(MAXH)       LD A,(MAXV)       LD E,A       LD H,(IX+2)       LD D,(IX+3)        LD A,H        CP L        JR NZ,uPF1        LD A,D        CP E       JR NZ,uPF1       LD HL,M1696A ;без увеличения       JR uPFOKuPF1    LD A,H        ADD A,A        CP L        JR NZ,uPF2        LD A,D        CP E       JR NZ,uPF2       LD HL,M1675A ;с увеличением в 2 раза по X?       JR uPFOKuPF2    LD A,H        CP L        JR NZ,uPF3        LD A,D        ADD A,A        CP E       JR NZ,uPF3       LD HL,ERROR ;M16810       JR uPFOKuPF3    LD A,L       SUB H       CALL C,ERROR       JR NZ,$-4        LD A,E       SUB D       CALL C,ERROR       JR NZ,$-4        LD HL,M166AA ;с увеличением в 2 раза       ;LD A,(cOLPOI) ;0=B/W режим показа       ;OR A       ;JR NZ,$+5       ;LD HL,EMPTYuPFOK   LD (IY),L        LD (IY+1),H ;кладём адрес функции в таблицу из 4 функций        LD DE,3        ADD IY,DE        POP HL        INC HL
        inc HL        DJNZ uPFLP        RET ;oncemaketrees;M18E08       LD A,128       LD (BITER),A       LD A,(VAR+#E0)       LD B,A        LD HL,VAR+#E2        LD DE,VAR+#110hUFLP   PUSH BC
        push HL
        push DE        CALL GETIXHL        LD A,(IX+5)        LD HL,VAR+#6A       CALL maketree;m18950       LD A,(PRMODE)       CP #C2        LD A,(IX+6)        LD HL,VAR+#7A       CALL NZ,maketree;m18950        POP DE        XOR A        LD (DE),A        INC DE        POP HL        INC HL
        inc HL        POP BC        DJNZ hUFLP        ;LD (VAR+#122),A ;TODO зачем?        LD A,(VAR+#C2)        LD (VAR+#120),A        RET 
;построение дерева;twicemaketree;m18950
;_thuffs - временный буфер, после этой процедуры не нужен
;дерево создаётся в районе FREE по указателю в [[hl+a*2]]
       ADD A,A       LD E,A       LD D,0       ADD HL,DE       LD E,(HL)       INC HL       LD D,(HL)       LD A,D       OR E       CALL Z,ERROR        PUSH IX        EX DE,HL        LD (pHFT),HL        LD DE,_thuffs+#0207
         push de        LD A,1l3      LD B,(HL)        INC HL        INC B        LD (DE),A        INC DE        DJNZ $-2        DEC DE        INC A        CP 17        JR NZ,l3       XOR A       LD (DE),A
         ;jr $         pop ix ;LD IX,_thuffs+#0207       LD HL,_thuffs+#0004       LD D,A
       ld E,A ;de=0        LD C,(IX);что-то хитроеl5      LD A,(IX)        CP C        JR NZ,l4        INC IX        LD (HL),D        INC HL        LD (HL),E        INC HL        INC DE        JR l5l4      SLA E        RL D        INC C        LD A,(IX)        OR A        JR NZ,l5pHFT=$+2        LD IY,0        PUSH IY        LD DE,#43C        ADD IY,DE       LD H,A
       ld L,A       LD DE,2+#480        EXX         POP HL        EXX         LD B,16L8      PUSH BC        EXX         LD A,(HL)       INC HL        EXX        OR A        JR Z,L7        LD IX,(pHFT)       ;LD BC,#480       ;ADD IX,BC        ADD IX,DE        LD (IX),H        LD (IX+1),L       PUSH HL        LD IX,(pHFT)        ADD IX,DE        ADD HL,HL        LD BC,_thuffs+#0004        ADD HL,BC        LD B,(HL)        INC HL        LD C,(HL)       LD (IX+#416-#480),B       LD (IX+#417-#480),C       POP HL        LD C,A        LD B,0        ADD HL,BC       PUSH HL        ADD HL,HL        LD BC,_thuffs+#0002        ADD HL,BC        LD B,(HL)        INC HL        LD C,(HL)       POP HL        JR $+5L7      LD BC,-1        LD (IY),B        LD (IY+1),C        INC IY
        inc IY        INC DE
        inc DE        POP BC        DJNZ L8        LD HL,(pHFT)        LD DE,#47C        ADD HL,DE       LD (HL),B        INC HL        LD (HL),#0F        INC HL       DEC B       LD (HL),B        INC HL       LD (HL),B;(+482)=(+482)-(+418)+A+16       LD HL,(pHFT)       LD BC,16       ADD HL,BC       EX DE,HL       LD IX,#482-16       ADD IX,DE       LD A,CREHUF0       LD H,(IX)       LD L,(IX+1)       LD B,(IX+#418-#482)       LD C,(IX+#419-#482)       OR A       SBC HL,BC       ADD HL,DE       LD (IX),H       LD (IX+1),L       INC IX
       inc IX       DEC A       JR NZ,REHUF0        POP IX        RET          

FBMARK        ;CALL RDBYTE ;уже прочитали в browser        ;INC A        ;CALL NZ,ERROR2        CALL RDBYTE        CP #D8        CALL NZ,ERROR2        LD IX,VARS+#8A        LD B,#10       LD HL,1ARTLP  LD (IX),H       LD (IX+#10),L        LD (IX+#20),5        INC IX        DJNZ ARTLP        LD (VARS+#50),HL        LD (VARS+#52),HL        DEC L        LD (VARS+#C2),HL       LD A,H        LD (VARS+#4E),A        LD (VARS+#BE),A        CALL PRCMARK1       LD (PRMODE),A ;значения #c2, #c3, какие ещё?       CP #C3        CALL NC,ERROR4        CALL jpgreadsizesMRKP3        LD A,(CNUM)       CP 1        JR Z,MRKPOK       CP 3        JR NZ,mRKPC4        LD A,(VARS+#4A)        OR A        RET NZ        LD IX,(VARS+#56)        LD A,1        CP (IX)        CALL NZ,ERROR        INC A        CP (IX+#12)       JR NZ,mRKP4        INC A        CP (IX+#24)        JR Z,MRKPOKmRKP4   LD A,4        CP (IX+#12)        CALL NZ,ERROR        INC A        CP (IX+#24)        CALL NZ,ERROR        DEC A        JR MRKPOKmRKPC4  CP 4        CALL NZ,ERROR        INC AMRKPOK  LD (VARS+#4A),A        RET ;twicePRCMARK1        CALL PRCMARKpMRK_1=$+1
        LD A,0        RET MPHT    CALL P_HTABPRCMARK
        ;jr $       CALL RDBYTE       INC A       JR NZ,$-4       CALL RDBYTE        LD (pMRK_1),A        SUB #C0       JP C,ERROR4        RET Z        SUB 4       RET C        JR Z,MPHT        SUB 8       RET C        JP Z,ERROR ;MPAT        SUB 3       RET C        RET Z        SUB 9        JP C,ERROR4        SUB 3       RET C        JR Z,MPQT        SUB 2        JR Z,M141FE        SUB 3        JR Z,MPAPP        LD A,(pMRK_1)        CALL RDWORDHSBLSBtohl        DEC HL
        dec HLSKPM    CALL RDBYTE        DEC HL        LD A,H        OR L        JR NZ,SKPM        JR PRCMARKMPQT    CALL P_QTAB        JR PRCMARKM141FE        CALL RDWORDHSBLSBtohl       LD A,L       SUB 4       OR H        CALL NZ,ERROR        CALL RDWORDHSBLSBtohl        LD (VAR+#C2),HL        JR PRCMARKMPAPP   CALL P_APP0        JR PRCMARK;onceP_APP0        CALL RDWORDHSBLSBtohl       LD DE,-16       ADD HL,DE        LD (pAPPR_1),HL        CALL RDBYTE        CP "J"       JR NZ,ERR2_        CALL RDBYTE        CP "F"       JR NZ,ERR2_        CALL RDBYTE        CP "I"       JR NZ,ERR2_        CALL RDBYTE        CP "F"ERR2_  JP NZ,ERROR2

        CALL RDBYTE        OR A        CALL NZ,ERROR        CALL RDWORDHSBLSBtohl        CALL RDBYTE        LD (VARS+#4E),A        CALL RDWORDHSBLSBtohl        LD (VARS+#50),HL        CALL RDWORDHSBLSBtohl        LD (VARS+#52),HL        CALL RDWORDHSBLSBtohlpAPPR_1=$+1
        LD BC,0APPSL   LD A,B        OR C        RET Z        CALL RDBYTE        DEC BC        JR APPSL 
        
;onceP_QTAB        CALL RDWORDHSBLSBtohl        DEC HL
        dec HL ;lenNQTB   PUSH HL        rdbyte        LD B,A        RRCA         RRCA         RRCA         RRCA         AND #0F       LD DE,#41       JR Z,$+4       LD E,#81       PUSH DE       LD C,A        LD A,B        AND #0F        CP 4        CALL NC,ERROR       ADD A,A       LD HL,VARS+#5B       ADD A,L       LD L,A        LD D,(HL)        DEC HL        LD E,(HL)        LD A,D        OR E        JR NZ,QTP       PUSH HL        LD DE,#80        CALL ALLDNP ;не портит bc! hl=указатель на выделенную память       EX DE,HL       POP HL       LD (HL),E       INC HL       LD (HL),DQTP     EX DE,HL        LD B,#40pQPRC   LD A,C       OR A       CALL NZ,RDBYTE        LD (HL),A        INC HL        rdbyte        LD (HL),A        INC HL        DJNZ pQPRC       POP DE       POP HL       OR A       SBC HL,DE       RET Z       RET C        JR NQTB 
        
;выделение динамической памяти
;de=размер (реально очищается на 1 байт больше)
;out: hl=указатель на выделенную память
ALLDNP  
        if 1==0 ;не чистим
        CALL ALLDN        LD E,0        CALL SETPG        PUSH HL
        push DE
        push BC        LD E,L
        ld D,H        INC DEpCLR_=$+1        LD BC,0        LD (HL),0        LDIR         POP BC
        pop DE
        pop HL        RET 
ALLDN        LD (pCLR_),DE
        endif
               LD HL,(MEMDN)       EX DE,HL        ADD HL,DE        LD (MEMDN),HL       EX DE,HL        RET  

;oncejpgreadsizes        CALL RDWORDHSBLSBtohl       PUSH HL ;pFSML        CALL RDBYTE        CP 8        CALL NZ,ERROR        LD (VARS+#48),A        CALL RDWORDHSBLSBtohl        call setpichgt        CALL RDWORDHSBLSBtohl
        call setpicwid
        call reservefirstframeaddr
        call initframe ;один раз на картинку после setpicwid, setpichgt ;заказывает память под конверченный кадр

        CALL RDBYTE        LD (CNUM),A        LD B,A        ADD A,A        ADD A,B        ADD A,8       POP HL        CP L        CALL NZ,ERROR        LD HL,(CNUM) ;16bit!!!        ADD HL,HL        LD E,L
        ld D,H        ADD HL,HL        ADD HL,HL        ADD HL,HL        ADD HL,DE        EX DE,HL        CALL ALLDNP ;hl=указатель на выделенную память        LD (VARS+#56),HL       PUSH HL       POP IX       LD D,0        LD A,(CNUM)        LD B,AsFLP    LD (IX+1),D        CALL RDBYTE        LD (IX),A        CALL RDBYTE       LD C,A       RRCA        RRCA        RRCA        RRCA        AND #0F       LD (IX+2),A       LD A,C       AND #0F       LD (IX+3),A        CALL RDBYTE        LD (IX+4),A        INC D       PUSH BC       LD BC,18       ADD IX,BC       POP BC        DJNZ sFLP        RET ;onceLBMARK        CALL PRCMARK1       SUB #D9       ;OR A       RET Z       DEC A        CALL NZ,ERROR        CALL STSCAN        SCF         RET 
;onceSTSCAN        LD IX,VARS+#E2        CALL RDWORDHSBLSBtohl        CALL RDBYTE        LD (VARS+#E0),A        LD B,A       ADD A,A       ADD A,3       LD E,A       XOR A       LD D,A       SBC HL,DE       PUSH HL; pSKPSCNsCCLP   PUSH BC        LD HL,(VAR+#56)        LD A,(CNUM)        LD B,A        CALL RDBYTE        LD DE,18sCCLP1  CP (HL)        JR Z,sCCF1        DEC B        CALL Z,ERROR        ADD HL,DE        JR sCCLP1sCCF1  LD (IX),L       LD (IX+1),H       LD E,5        ADD HL,DE        CALL RDBYTE       LD B,A       RRCA        RRCA        RRCA        RRCA        AND #0F       LD (HL),A       LD A,B       INC HL       AND #0F       LD (HL),A        INC IX
        inc IX        POP BC        DJNZ sCCLP       POP BCrdmany LD A,B       OR C       RET Z       DEC BC       rdbyte       JR rdmany ;APPSL 
       
;onceP_HTAB        CALL RDWORDHSBLSBtohl        DEC HL
        dec HLrDHNT  PUSH HL ;pHML        LD DE,#4A2 ;под дерево?        CALL ALLDNP ;hl=указатель на выделенную память        rdbyte        LD IX,VARS+#6A       CP #10       JR C,$+6        LD IX,VARS+#7A       AND #0F       ADD A,A       LD E,A       LD D,0       ADD IX,DE       LD (IX),L       LD (IX+1),H       PUSH HL       POP IX       LD H,D
       ld L,D        LD B,#10rDHHD   rdbyte        LD (IX),A        INC IX       LD E,A       ADD HL,DE        DJNZ rDHHD       LD A,H       OR A        CALL NZ,ERROR       LD B,LrDHTB   rdbyte        LD (IX),A        INC IX       DJNZ rDHTB       LD DE,17       ADD HL,DE       EX DE,HL       POP HL       ;OR A       SBC HL,DE        RET Z        CALL M,ERROR        JR rDHNT 

;5 times;/8 CALLSDIVHL_DE        LD BC,-1        OR AdIV11   SBC HL,DE        INC BC        JR NC,dIV11        RET ;once;/7 CALLSQUAHL_DE
;de = hl mod de        OR A        SBC HL,DE        JR NC,$-2        ADD HL,DE        EX DE,HL        RET          
GETIXHL       LD A,(HL)       LD LX,A       INC HL       LD A,(HL)       LD HX,A        RET 
;twice;/12 CALLSDIV8        LD C,-1       INC C       SUB B       JR NC,$-2        LD A,C
EMPTY        RET  
        
SETPG
;e=0/1 задают вручную, 1/2/5 по таблице (цветовые составляющие)
;сохраняет af,bc,de,hl
        push af
        push bc
        push hl
        ld a,e

        ;cp 0
        ;jr z,setpgok
        ;cp 1
        ;jr z,setpgok
        ;cp 2
        ;jr z,setpgok
        ;cp 5
        ;jr z,setpgok
        ;jr $
;setpgok
        
        ld hl,tpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        SETPG32KHIGH
        
        pop hl
        pop bc
        pop af
        ret
        
tpgs
        ds 6
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;onceYCCTAB        ;LD A,0xce;100;(SATURP)        ;ADD A,100        ;LD DE,327        ;CALL MULDE_A;HL=0..FFFF      LD HL,#3fde;#8000        LD (YCCHL),HL;CR tab (add to Y->R)       LD IX,G716C+128       LD HL,-#B3       LD DE,1        EXX         LD DE,#66EA       CALL XtBLP;CB tab (add to Y->G)       LD IX,G7170+128       LD HL,-#E2      LD DE,1        EXX         LD DE,#C5A2       CALL XtBLP;CR tab (add to Y->G)       LD IX,G7174+128       LD HL,#5B       LD DE,-1        EXX         LD DE,0xffff&(-#B6D2)       CALL XtBLP;CB tab (add to Y->B)       LD IX,G7178+128       LD HL,#2C      LD DE,-1        EXX         LD DE,-#581AXtBLP;HL'<HL>=a[0];DE'DE=da=(a[255]-a[0])/255;*(SATURP+100)       EXX        LD A,E       EXX         LD E,D
        ld D,AYCCHL=$+1        LD BC,0       PUSH HL        CALL MUL16LONG ;DE*BC      ADD HL,HL       EX (SP),HL        PUSH BC        EXX         POP BC        EX DE,HL        CALL MUL16LONG ;DE*BC      ADD HL,HL        EXX        POP BC        LD A,B
        ld D,C       EXX        LD E,A        RLA         SBC A,A        LD D,A       EXX XtBLp        EXX         LD B,0tBLP4  LD (IX-128),L       INC IX       LD (IX+127),H        EXX         ADD HL,DE        EXX         ADC HL,DE        DJNZ tBLP4        RET  

MUL16LONG;BC>0        BIT 7,D        JP Z,MUL1616        XOR A        SUB E        LD E,A        SBC A,A        SUB D        LD D,A        CALL MUL1616        XOR A        SUB L        LD L,A        SBC A,A        SUB H        LD H,A        RET         
MUL1616        LD HL,0;DE>0;FFFF=*2        LD A,C       DUP 8        RRA         JR NC,$+3        ADD HL,DE        RR H
        rr L       EDUP         LD A,B       DUP 7        RRA         JR NC,$+3        ADD HL,DE        RR H
        rr L       EDUP         RRA         RET NC        ADD HL,DE        RET 

;3 times;/7 CALLSMULDE_A        LD HL,0mUL11   ADD HL,DE        DEC A        JR NZ,mUL11        RET  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MEMDN   DW FREE ;указатель на динамическую память
        ;display "MEMDN=",MEMDN 
JF44    
        JP 0;JF48    
        JP 0;JF4C    
        JP 0;JF50    
        JP 0 

CNUM    DW 0 ;число слоёв? HSB=0!!!

picwid_inblocks   DW 0 ;ширина картинки в полноценных блокахpichgt_inblocks   DW 0 ;высота картинки в полноценных блокахMAXV    DB 0MAXH    DB 0BLSZ    DW 0MAXH8   DW 0 ;ширина полноценного блока картинки ;по идее 8 или 16MAXV8   DW 0 ;высота полноценного блока картинки ;по идее 8 или 16LPNT    DW 0 ;указатель на графику полноценного блока (растёт от JPGPAGESTART(0xc000) в строке блоков LSZX*MAXV8, по окончании строки блоков опять начинается с JPGPAGESTART)LSZX    DW 0 ;ширина картинки с округлением вверх до полноценного блока

        align 256
R4A0F        DS 16,2        DS 16,4        DS 16,6        DS 16,8        DS 16,10        DS 16,12        DS 16,14        DS 16,16        DS 16,18        DS 16,20        DS 16,22        DS 16,24        DS 16,26        DS 16,28        DS 16,30        DS 16,32       DW 2
       Qorder        DW 2*#00,2*#01,2*#08,2*#10,2*#09,2*#02,2*#03,2*#0A        DW 2*#11,2*#18,2*#20,2*#19,2*#12,2*#0B,2*#04,2*#05        DW 2*#0C,2*#13,2*#1A,2*#21,2*#28,2*#30,2*#29,2*#22        DW 2*#1B,2*#14,2*#0D,2*#06,2*#07,2*#0E,2*#15,2*#1C        DW 2*#23,2*#2A,2*#31,2*#38,2*#39,2*#32,2*#2B,2*#24        DW 2*#1D,2*#16,2*#0F,2*#17,2*#1E,2*#25,2*#2C,2*#33        DW 2*#3A,2*#3B,2*#34,2*#2D,2*#26,2*#1F,2*#27,2*#2E        DW 2*#35,2*#3C,2*#3D,2*#36,2*#2F,2*#37,2*#3E,2*#3F 


