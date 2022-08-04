FRIY2  ;DS #404;from ldlens
ldlens  DS 298
ddlens  DS 48
rdlens  DS 28 ;#2AA+256
FRIY2ln=$-FRIY2

disp    DS 3

ARCBEG  DS 7 ;FIRST 7 BYTES OF RAR

        align 256
bdlens=$-19
HEXBUF=$-19;24;TOO MUCH
DECBUF ;DB 0
;begin
midBT ;круглый адрес!
;tree added 3,bits sub L(bits=0 оставлено)
      ;L=00   2   4   6   8   A   C   E
     db #00,#03,#00,#04,#00,#05,#00,#06,#00,#07,#00,#08,#00,#09,#00,#0A
        ;10  12  14  16  18  1A  1C  1E
     db #F1,#0B,#EF,#0D,#ED,#0F,#EB,#11,#EA,#13,#E8,#17,#E6,#1B,#E4,#1F
        ;20  22  24  26  28  2A  2C  2E
     db #E3,#23,#E1,#2B,#DF,#33,#DD,#3B,#DC,#43,#DA,#53,#D8,#63,#D6,#73
        ;30  32  34  36
     db #D5,#83,#D3,#A3,#D1,#C3,#CF,#E3

;tree added 1
litBT  db #02,#01,#02,#05,#03,#09,#04,#11,#05,#21,#06,#41,#06,#81,#06,#C1
       DISPLAY litBT,"(don't cross 256)",$
;added 1
bigBT   db #00,#00,#01,#00
        db #00,#00,#02,#00
        db #00,#00,#03,#00
        db #00,#00,#04,#00
        db #00,#01,#05,#00
        db #00,#01,#07,#00
        db #00,#02,#09,#00
        db #00,#02,#0D,#00
        db #00,#03,#11,#00
        db #00,#03,#19,#00
        db #00,#04,#21,#00
        db #00,#04,#31,#00
        db #00,#05,#41,#00
        db #00,#05,#61,#00
        db #00,#06,#81,#00
        db #00,#06,#C1,#00
        db #00,#07,#01,#01
        db #00,#07,#81,#01
        db #00,#08,#01,#02
        db #00,#08,#01,#03
        db #00,#09,#01,#04
        db #00,#09,#01,#06
        db #00,#0A,#01,#08
        db #00,#0A,#01,#0C
        db #00,#0B,#01,#10
        db #00,#0B,#01,#18
        db #00,#0C,#01,#20
        db #00,#0C,#01,#30
        db #00,#0D,#01,#40
        db #00,#0D,#01,#60
        db #00,#0E,#01,#80
        db #00,#0E,#01,#C0
        db #01,#0F,#01,#00
        db #01,#0F,#01,#80
        db #02,#10,#01,#00
        db #03,#10,#01,#00
        db #04,#10,#01,#00
        db #05,#10,#01,#00
        db #06,#10,#01,#00
        db #07,#10,#01,#00
        db #08,#10,#01,#00
        db #09,#10,#01,#00
        db #0A,#10,#01,#00
        db #0B,#10,#01,#00
        db #0C,#10,#01,#00
        db #0D,#10,#01,#00
        db #0E,#10,#01,#00
        db #0F,#10,#01,#00
                      
DEPK
        if 1==0
        LD HL,s8
        LD DE,8
        LD BC,#105
       ;LD HY,B ;это была защита от im 1, чтобы можно было использовать ly (под мл. байт остатка длины файла) TODO
        CALL DOD
        LD HL,(s8+#E1)
       ;LD A,(doSAVEk)
       ;SUB "y"
       ;JR NZ,$+4
       ;LD H,A,L,A ;depack as trd
        LD (stsec),HL ;начиная с какого сектора пишем
        endif
        
        LD A,128
        EXA 
       LD A,(FLAGF)
       AND 16
       JR NZ,DPsol
;;;nosolid
      CALL PRTHEE
        CALL RdTabs
      LD A,-1
      LD (restoreLAST),A
;;;~nosolid
DPsol
        if 1==0
        LD HL,(DEPADR)
         LD (gegAD),HL ;for hobeta
       LD A,(doSAVEk)
       CP "$"
        LD A,(curPG)
         LD (gegPG),A
       JR NZ,nohobski
        LD B,17
        INC L
        CALL Z,Lil
        DJNZ $-4
        LD (stAD),HL
        LD (stPG),A
nohobski
        endif

        LD HL,uNPremn
        LD A,(HL)
       ;LD (SAVElenLS1),A
        XOR A
        SUB (HL)
        LD lx,a;LY,A ;TODO fix, что-то не так с длиной распакованного файла
        INC HL
        LD A,0
        SBC A,(HL)
        LD (HL),A
        LD C,A
        INC HL
        SBC A,A
        SUB (HL)
        LD (HL),A
        LD B,A
       RET Z
      if frmcnt
        ex af,af' ;'
        push af
	 push bc
        push ix
        push iy
        OS_GETTIMER ;dehl=timer
        pop iy
        pop ix
	 pop bc
        pop af
        ex af,af' ;'
        LD (wastimer),hl
      ENDIF 
        XOR A
        LD L,A
        ld H,L
      if frmcnt
      LD (swaps),HL
      ENDIF 
        SBC HL,BC
        ;LD (SAVEsz),HL ;??? TODO
        LD (SAVErmn),HL
        CALL OUTcur
DEPADR=$+1
        LD DE,0;THEEND
         CALL DEPK0
        LD (DEPADR),DE
       ;LD IY,23610
;;;
      if frmcnt
       call RST16
       DB #D,#a,"frames=",0
        OS_GETTIMER ;dehl=timer
wastimer=$+1
        ld de,0
        or a
        sbc hl,de
       LD A,5
       CALL PRDEC
       call RST16
       DB "+swaps=",0
swaps=$+1
       LD HL,0
       LD A,5
       CALL PRDEC
      ENDIF
        jp SAVE

DEPK0i
        LD HL,uNPremn+1
        INC (HL)
       ;jr $
       JR NZ,DEPK0
       JP GPqI

       if retree==0
NEWDEMN
;?/frame
        ;LD A,(IX)
        ;INC LX
        ;CALL Z,LDAsec
        rarrdbyte
        ;SCF 
        RLA 
        JR C,DEMNC
        JP DEMNNC
       endif
yBs
        CALL store
        JP yBse
yBYTE
     EXX 
     LD (DE),A ;page=curPG
     INC E
     JR Z,yBs
yBse   INC lx;LY
       JR Z,DEPK0i
DEPK0
        EXX 
DEPK0X
       if retree
        if 1==0
        exx
        jr $
        ld a,d
        sub 0xc2
        ld d,a
        ld a,e
        sub 0x5e
        or d
        jr z,$
        ld a,d
        add a,0xc2
        ld d,a
        exx
        endif
       
        ex af,af'
        call reld
        ex af,af'
        ld a,c
;1.5t/frame
       djnz yBYTE
       else
        LD HL,ld
        EXA 
DEMN0   ADD A,A
        JR Z,NEWDEMN
        JR NC,$+4 ;ноль
DEMNC   INC L  ;единица
        INC L;HL
DEMNNC  LD C,(HL)
        INC L
        LD H,(HL)
        LD L,C
       IF (ld/256)&#40
        BIT 6,H
       ELSE 
       if (ld/256)&#80
        BIT 7,H
       else
       IF (ld/256)&#20
        BIT 5,h
       ENDIF 
       endif
       ENDIF 
        JP NZ,DEMN0
        EXA 
        LD A,C
;1.5t/frame
       DEC H
       JR NZ,yBYTE
       endif
nBYTE
        SUB 270&0xff
       JP C,m270 ;<270
;270..297
       ADD A,A
      LD H,midBT/256
       LD L,A
    ;LD BC,midBT
    ;ADD HL,BC
       ADD A,(HL)
      INC L
       LD L,(HL)
      if retree
      ld h,b;0
      else
      LD H,0
      endif
       JP NC,na270
        CALL LDA18
        ADD HL,BC
na270
      ex de,hl;PUSH HL;!!!!!!! ;TODO ex de,hl
        LD HL,dd
        CALL DEHUFF
       SLA L
       sla L
      LD BC,bigBT
      ADD HL,BC
       ;LD H,'bigBT
        XOR A
        OR (HL)
        LD (disp+2),A
       JR NZ,diN0
        INC L
        ADD A,(HL)
       JR Z,diNADD
        INC L
        CALL LDA
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        ADD HL,BC
        LD (disp),HL
        JR C,dIIputs
;3t/frame
        LD A,H
      ex de,hl;POP HL ;!!!!!!! ;TODO ex de,hl
        CP #20
       JP C,putsPUT
        INC HL
       JP putsPUT
dIIputs LD A,1
        JP eIIputs
diNADD
        INC L
        LD A,(HL)
        LD (disp),A
        LD HL,0
        LD (disp+1),HL
      ex de,hl;POP HL ;!!!!!!! ;TODO ex de,hl
       JP putsPUT
diN0
;10t/frame
        INC L
       LD A,(HL) ;#F/#10
        INC L
        CALL LDA
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        ADD HL,BC
        LD (disp),HL
        LD A,(disp+2)
        ADC A,0
eIIputs
        LD (disp+2),A
      ex de,hl;POP HL ;!!!!!!! ;TODO ex de,hl
        INC HL
        CP 4
       JP C,putsPUT
        INC HL
       JP putsPUT
y269
       EXX 
       PUSH DE
        CALL RdTabs
       POP DE
       JP DEPK0

m270    INC A
       JR Z,y269 ;269
n256    ADD A,8
       JP C,br261 ;261..268
        ADD A,4
       JP NC,GETPUT;256
;257..260->0..3
       RRCA 
       RRCA 
      LD HL,(ind03)
      ADD A,L
      LD L,A
      ;only +5 frames:
      ;LD B,0
      ;DJNZ $
       LD DE,disp
       LDI 
       LDI 
       LDI 
       ;jr $
        LD HL,rd
        CALL DEHUFF
       SLA L
    ;LD BC,midBT
    ;ADD HL,BC
       LD H,midBT/256
       LD A,L
        ADD A,(HL)
        INC L
        LD L,(HL)
       LD BC,0
       LD H,B
        CALL C,LDA18
        ADD HL,BC
        LD A,(disp+2)
        CP 4
        JR C,$+3
        INC HL
      ;INC HL
        OR A
        JR NZ,I1puts
        LD BC,(disp)
        LD A,B
        CP #20
        JR NC,I1puts
       DEC HL
        DEC BC
        DEC B
       JP M,putsPUT
I1puts  INC HL
       JP putsPUT
;261..268
br261  ADD A,A
       LD HL,litBT
      ADD A,L
       LD L,A
       LD A,(HL)
       INC L
        LD L,(HL)
        CALL LDA18
        LD H,B
        ADD HL,BC
        LD (disp),HL
      XOR A
      LD (disp+2),A
        LD HL,2
putsPUT
       LD (puts),HL
GETPUT
;2t/frame in haets20.rar
ind03=$+1
       LD HL,TAB44
       LD A,L
       SUB 64
       LD L,A
       LD (ind03),A
        LD A,(disp)
        LD (HL),A
        INC L
        LD BC,(disp+1)
        LD (HL),C
        INC L
        LD (HL),B
_2      LD HL,+(1-INITIALMEMPAGES)*64+(THEEND/256)-256 ;INITIALMEMPAGES;6 = число страниц памяти?
        ADD HL,BC
GPaddrpatch=$+1
        JP NC,GPmem ;подменяется на копию p48 (оригинал p48 копируется поверх окончания GPmem, т.к. изначально инициализатор затирался, и p48 тоже, и так быстрее выход из p48)
        ;jr $ ;сюда не попадаем
        
;TODO
        if 1==0
GPdisk
;глючит :(
;FROM=disk
;solid shift
        EXX 
        PUSH DE
        EXX 
        POP HL
       LD BC,(stAD)
       LD B,0
       OR A
       SBC HL,BC
;
       LD B,A
       LD A,L
       SUB B
       PUSH AF
;beg.buf on disk=stsecnw
;sub secs back
       PUSH AF
        LD A,(curPG)
        SLA H
        sla H
      ADC A,0 ;V0.42
        RRA 
        RR H
        RRA 
        RR H
        LD L,H
        ld H,A
       POP AF
        LD BC,(disp+1)
        SBC HL,BC
     ;LD BC,0   ;#80-'THEEND
     ;ADD HL,BC ;???
;HL=secs add
        dup 4
        add hl,hl
        edup
stsecnw=$+1 ;C<<4
       LD BC,0
        ADD HL,BC
;       JR C,notr0
;       LD A,H
;       ADD A,160
;       LD H,A
;notr0
        LD A,L
        RRCA 
        RRCA 
        RRCA 
        RRCA 
        LD L,A
       LD (resec),HL
       EXX 
       CALL restore
        POP AF
        LD L,A
       LD BC,(puts)
        ADD A,C
        LD A,(curPG)
        DEC B
       JR Z,GPftor
       JR C,GPftor
        LD B,D
        INC B
       JP NZ,GPmfst
        DEC B ;B=-1
GPftor  INC B
        CALL OUTME
GPf1    LD A,(HL)
        LD (DE),A
        INC L
        CALL Z,restore ;read known sector from destination file
        INC E
        CALL Z,store
        DEC BC
        LD A,B
        OR C
        JR NZ,GPf1
        endif
GPqSLOW
        LD HL,(puts)
        LD C,lx;LY
        LD A,(uNPremn+1)
        LD B,A
        ADD HL,BC
        LD A,L
        LD lx,a;LY,A
        LD A,H
        LD HL,uNPremn+1
        LD (HL),A
       JP NC,DEPK0
       JP GPqI
       
GPmem
        EXX 
       LD H,D
       ld L,E
       LD BC,(disp)
        LD A,(curPG)
        SLA H
        sla H ;CY=1
      ADC A,-1;V0.42
        RRA 
        RR H ;CY=0
        RRA 
        RR H ;CY=0
;AHL=adrinbuf-hwost
        SBC HL,BC
       EXX 
       SBC A,B
       EXX 
       ;RL H
       ;RLA
       ;RL H
       ;ADC A,A ;CY=1 or M
       ;JP P,$+5
     ;V0.42
        RL H
        RLA 
        RL H
        RLA 
        SCF 
        RR H
        SCF 
        RR H
       CP 128 ;что это? TODO
       JR C,GPendif
        LD C,A ;что это? TODO
        LD A,H
        ADD A,#C0-(THEEND/256)
        JR NC,GPelse
        INC C
        JR Z,GPthen
GPelse  OR 192
        LD H,A
_p1      LD A,INITIALMEMPAGES;6 ;число страниц памяти?
        ADD A,C
        JR C,GPendif
GPthen  RES 6,H
        XOR A
GPendif
GPmemsz=$-GPmem
        LD (frPG),A
puts=$+1
        LD BC,0 ;2..261
        DEC B
       JR Z,GPmtor
        LD B,D
        INC B
       JR Z,GPmt2
        LD B,H
        INC B
       JR Z,GPmt2
curPG=$+1
        CP 0
       JR NZ,GPmt3
GPmfst
        LD B,0
       LD A,C
        LDIR 
GPq
       ADD A,lx;LY
       LD lx,a;LY,A
       JP NC,DEPK0
        LD HL,uNPremn+1
        INC (HL)
       JP NZ,DEPK0
GPqI    INC HL
        INC (HL)
       JP NZ,DEPK0
        RET 

GPm2    LD A,(frPG)
GPmt2   CALL OUTME
        LD B,(HL)
        INC L
        CALL Z,corFROM
        CALL OUTcur
        LD A,B
        LD (DE),A
        INC E
        CALL Z,store
        DEC C
        JP NZ,GPm2
        JR GPe

;t=2f
GPm3    LD A,(frPG)
GPmt3   CALL OUTME
        LD A,(HL)
        PUSH AF
        INC L
        CALL Z,corFROM
        LD B,(HL)
        INC L
        CALL Z,corFROM
curPG2=$+1
        LD A,0
        CALL OUTME
        POP AF
        LD (DE),A
        INC E
        CALL Z,store
        DEC C
        JR Z,GPe
        LD A,B
        LD (DE),A
        INC E
        CALL Z,store
        DEC C
        JP NZ,GPm3
GPe     LD A,(puts)
        JP GPq

GPmtor  INC B
GPm0tor LD A,(frPG)
        CALL OUTME
        LD A,(HL)
       PUSH AF
        INC L          ;
        CALL Z,corFROM ;v0.60!
        CALL OUTcur
       POP AF
        LD (DE),A
        INC E
        CALL Z,store
        DEC BC
        LD A,B
        OR C
        JR NZ,GPm0tor
       JP GPqSLOW
store
        INC D
        RET NZ
        LD A,(curPG)
        INC A
        LD D,#C0
_4      CP INITIALMEMPAGES;6 ;число страниц памяти?
        JR Z,storer
        jp OUTMEcu

storer
;first store - ADDR to ENDMEM,
; ADDR=bufstor+hwostik
;posledujushie - ADDR to ENDMEM
;hwostik ENDMEM -> bufstor, save next time
; iz SAVErmn ne wychitaetsa

;SAVE saves ADDR, (SAVErmn) SECTORS.
       IF border
        LD A,4
        OUT (-2),A
       ENDIF 
        PUSH BC,HL
        push iy;IX
        CALL SAVbeg
;HL=addr,A=page
      PUSH AF
storePG0
        LD A,H
        INC A
        JR NZ,nRAZLOM
        LD DE,bufstor
        PUSH DE
        LD B,A
        SUB L
        LD C,A
       DEC C
       INC BC
        EXA 
        INC A
_5      CP INITIALMEMPAGES;6 ;число страниц памяти?
       JR Z,storQQQ
        LDIR 
        LD H,#C0 ;V0.42
       PUSH AF
        CALL OUTME
       POP AF
        EXA 
        XOR A
        SUB E
        JR Z,$+5
        LD C,A
        LDIR 
       DEC H
        LD A,1
        JR yRAZLOM
nRAZLOM
        PUSH HL
        NEG 
yRAZLOM LD E,A
        ADD A,H
        LD H,A
        EX (SP),HL
       PUSH DE
;e=number of sectors to save
;hl=addr
        if 1==1
        ld d,e
        ld e,0
        call SAVEBLOCK
        else
       
        LD C,6
        LD B,E
stsec=$+1
        LD DE,0
        CALL DOD
        LD HL,(#5CF4)
        LD (stsec),HL
        
        endif
        
       POP DE
SAVErmn=$+1
        LD HL,0
        XOR A
        LD D,A ;de=number of sectors to save (saved)
        SBC HL,DE
        LD (SAVErmn),HL
        POP HL
       JR storePG0
storQQQ
       POP AF ;de
        LD E,L
        PUSH DE
        LDIR 
        POP HL

        if 1==0
;TODO это для возможности чтения уже записанного
;TODO длину сохраняемого файла - SAVErmn*256, сделать SEEK, прочитать, а потом SEEK обратно (будет ли это работать в FATFS? в TRDOSFS не будет)
       PUSH HL
       LD DE,(stsec)
       LD BC,#106
       CALL DOD
        LD HL,(#5CF4)
        LD A,L
        ADD A,A
        add A,A
        add A,A
        add A,A
        LD L,A
        LD (stsecnw),HL
       POP HL
        endif

      POP AF
        EXA 
        XOR A ;!
       IF border
        OUT (-2),A
       ENDIF 
        LD (stPG),A
        LD (stAD),HL
        LD DE,THEEND
        POP iy;IX
        pop HL,BC
        JP OUTMEcu
corFROM
        INC H
        RET NZ
frPG=$+1
        LD A,0
        INC A
        LD (frPG),A
        LD H,#C0
_3      CP INITIALMEMPAGES;6 ;число страниц памяти?
        JP NZ,OUTME
        XOR A
        LD H,THEEND/256
        LD (frPG),A
        JP OUTME

Lil     INC H
        RET NZ
        LD H,#C0
        INC A
L_pg    CP 0
        JR NZ,$+5
        XOR A
        LD H,THEEND/256
        LD C,A
        CALL OUTME
        LD A,C
        RET 
