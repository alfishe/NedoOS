;play *.tfc

	;module pt3player
;TODO begin&end только в одном каналеstatuschip0=%11111000statuschip1=%11111001        MACRO WaitStatus       ;OUT (C),D ;statuschip0/1
       nop
       nop ;DimkaM        IN F,(C)        JP M,$-4;2 ;DimkaM        ENDM ;tfmplayer;        LD HL,MDLADDR;        JR tfmini;        JP tfm;INIT
tfmini        EXD         LD HL,9        ADD HL,DE        LD A,(HL)        INC HL        CP 50        LD A,201        JR Z,$+4        LD A,62        LD (tfm60hz),A        EXX         LD HL,tfminitab        LD BC,#06FDtfmini0        LD DE,tfminiHL        LDI         LDI         EXX         LD A,(HL)        INC HL        PUSH HL        LD H,(HL)        LD L,A        ADD HL,DEtfminiHL=$+1        LD (0),HL        POP HL        INC HL        EXX         DJNZ tfmini0        XOR A        LD (blkcntA),A        LD (blkcntB),A        LD (blkcntC),A        LD (blkcntD),A        LD (blkcntE),A        LD (blkcntF),A        DEC A        LD (skipA),A        LD (skipB),A        LD (skipC),A        LD (skipD),A        LD (skipE),A        LD (skipF),A;MUTE
tfmshut        ld a,0xa0;%10101000 ;320x200 mode noturbo
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a
        
        LD DE,#FFBF        LD C,#FD        CALL selChip0        CALL tfminiPP        CALL selChip1        CALL tfminiPP
	LD A,0xa8;%10101000 ;320x200 mode
	ld bc,0xbd77	;shadow ports and palette remain on
        out (c),a
        ret
        
tfminiPP        XOR A        EXA         LD A,#0D ;SSGregClrS CALL WRITEREG        DEC A        JP P,regClrS        LD A,#B3regClrZ CP #4F        JR NZ,$+4        LD A,#3F ;skip TL, чтобы не было щелчка        CALL WRITEREG        DEC A        CP #30        JR NC,regClrZ       LD A,#F8 ;чистый тон       EXA        LD A,#07 ;SSG MASK       CALL WRITEREG        LD A,#0F ;max speed        EXA         LD A,#8F ;RRregClrR CALL WRITEREG        DEC A        JP M,regClrR      ; LD A,#F0      ; EXA      ; LD A,#28 ;key      ; CALL WRITEREG ;key on A      ; EXA      ; INC A ;#F1      ; EXA      ; CALL WRITEREG ;key on B      ; EXA      ; INC A ;#F2      ; EXA      ; CALL WRITEREG ;key on C        XOR A        EXA         LD A,#28 ;key        CALL WRITEREG ;key off A        EXA         INC A ;#01        EXA         CALL WRITEREG ;key off B        EXA         INC A ;#02        EXA         CALL WRITEREG ;key off C        DEC A ;#27 ;channel 3 mode        CALL WRITEREG ;normal mode        LD A,#7F ;тишина        EXA         LD A,#4F ;TLregClrT CALL WRITEREG        DEC A        CP #40        JR NC,regClrT       ;LD A,#2F      ;любое       ;EXA        LD A,#2F        CALL WRITEREG ;без этого частота левая       ;LD A,#2D      ;любое       ;EXA        LD A,#2D        ;CALL WRITEREG ;без этого частота левая        
        ;ret
WRITEREG;A=REG;A'=VALUE        LD B,D        WaitStatus        OUT (C),A ;reg        EXA         WaitStatus        LD B,E        OUT (C),A ;value        EXA         RET tfminitab        DW addrA        DW addrB        DW addrC        DW addrD        DW addrE        DW addrFselChip0        LD A,statuschip0        LD B,D        OUT (C),A        RET selChip1        LD A,statuschip1        LD B,D        OUT (C),A        RET 
;PLAYtfm
        LD DE,#FFBF        LD C,#FD        LD B,D        LD A,statuschip0        OUT (C),A        CALL tfmA        CALL tfmB        CALL tfmC        LD B,D        LD A,statuschip1        OUT (C),A        CALL tfmD        CALL tfmE        CALL tfmFtfm60hzcnt60=$+1        LD A,6        DEC A        JR NZ,$+4        LD A,6        LD (cnt60),A        JR Z,tfm        RET         MACRO TestKeyOff chnnum        JP P,.noffX        EXA         LD B,D ;%11111xxx        LD A,#28        WaitStatus        OUT (C),A       IF chnnum==0        XOR A       ELSE         LD A,chnnum       ENDIF         WaitStatus        LD B,E ;#BF        OUT (C),A        EXA .noffX        ENDM         MACRO TestFreq chnnum,chnhigh,chnlow        RRA         JR NC,.nofrqX        EXA         LD B,D ;%11111xxx        LD A,#A4+chnnum        WaitStatus        OUT (C),A       LD A,(HL)       INC HL       LD (chnhigh),A
        WaitStatus        LD B,E ;#BF       OUT (C),A        LD B,D ;%11111xxx        LD A,#A0+chnnum        WaitStatus        OUT (C),A       LD A,(HL)       INC HL       LD (chnlow),A        WaitStatus        LD B,E ;#BF       OUT (C),A        EXA .nofrqX        ENDM         MACRO TestOutRegs        AND #1F        CALL NZ,regsX        ENDM         MACRO KeyOn chnnum        LD B,D ;%11111xxx        LD A,#28        WaitStatus        OUT (C),A        LD A,#F0+chnnum        WaitStatus        LD B,E ;#BF        OUT (C),A        ENDM ;%11111111,-disp8 = данные кадра лежат по смещению -disp8;%111ttttt = skip 32..2 frames;%110ddddd = slide d-16;%11010000,frames,-disp16 = repeat block (skips = 1 frame);%10111111,-disp16 = данные кадра лежат по смещению -disp16;%10NNNNNf = keyoff,[freq,]0..30 regs, keyon;%01111111 = end;%01111110 = begin;%01NNNNNf = keyoff,[freq,]0..31 regs;%00NNNNNf =        [freq,]0..30 regsbb=%01111110be=%01111111
////////////////////////////		
blockA 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntA),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrA),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeA 
OLDfarA 
        LD B,(HL) 
        INC HL 
OLDnearA 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeA 
        POP HL 
        LD (addrA),HL 
        RET  
HLskiperA 
        JR Z,OLDfarA 
        CP %11100000 
        JR C,slideA 
        LD B,A 
        CP #FF 
        JR Z,OLDnearA 
        LD (addrA),HL 
skiperA LD (skipA),A 
        RET  
slideA 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockA 
tfmlowA=$+1 
        ADD A,0 
        LD (tfmlowA),A 
        LD (addrA),HL 
        LD B,D ;%11111xxx 
tfmhighA=$+2 
        LD HL,#A4+0 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+0 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginA 
        LD (loopaddrA),HL 
        JP tfmframeA 
endA 
loopaddrA=$+1 
        LD HL,0 
        JP tfmframeA 
tfmA 
skipA=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperA 
addrA=$+1 
        LD HL,0 
blkcntA=$+1 
        OR 0 
        JR Z,tfmframeA 
        DEC A 
        LD (blkcntA),A 
        JR NZ,tfmframeA 
blkretaddrA=$+1 
        LD HL,0 
tfmframeA 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginA 
        CP be 
        JR Z,endA 
        CP E ;#BF 
        JR NC,HLskiperA 
        TestKeyOff 0 
        OR A 
        PUSH AF 
        TestFreq 0,tfmhighA,tfmlowA
        TestOutRegs 
        LD (addrA),HL 
        POP AF 
        RET P 
        KeyOn 0 
        RET  

////////////////////////////		
blockB 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntB),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrB),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeB 
OLDfarB 
        LD B,(HL) 
        INC HL 
OLDnearB 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeB 
        POP HL 
        LD (addrB),HL 
        RET  
HLskiperB 
        JR Z,OLDfarB 
        CP %11100000 
        JR C,slideB 
        LD B,A 
        CP #FF 
        JR Z,OLDnearB 
        LD (addrB),HL 
skiperB LD (skipB),A 
        RET  
slideB 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockB 
tfmlowB=$+1 
        ADD A,0 
        LD (tfmlowB),A 
        LD (addrB),HL 
        LD B,D ;%11111xxx 
tfmhighB=$+2 
        LD HL,#A4+1 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+1 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginB 
        LD (loopaddrB),HL 
        JP tfmframeB 
endB 
loopaddrB=$+1 
        LD HL,0 
        JP tfmframeB 
tfmB 
skipB=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperB 
addrB=$+1 
        LD HL,0 
blkcntB=$+1 
        OR 0 
        JR Z,tfmframeB 
        DEC A 
        LD (blkcntB),A 
        JR NZ,tfmframeB 
blkretaddrB=$+1 
        LD HL,0 
tfmframeB 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginB 
        CP be 
        JR Z,endB 
        CP E ;#BF 
        JR NC,HLskiperB 
        TestKeyOff 1 
        OR A 
        PUSH AF 
        TestFreq 1,tfmhighB,tfmlowB
        TestOutRegs 
        LD (addrB),HL 
        POP AF 
        RET P 
        KeyOn 1 
        RET  

////////////////////////////		
blockC 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntC),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrC),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeC 
OLDfarC 
        LD B,(HL) 
        INC HL 
OLDnearC 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeC 
        POP HL 
        LD (addrC),HL 
        RET  
HLskiperC 
        JR Z,OLDfarC 
        CP %11100000 
        JR C,slideC 
        LD B,A 
        CP #FF 
        JR Z,OLDnearC 
        LD (addrC),HL 
skiperC LD (skipC),A 
        RET  
slideC 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockC 
tfmlowC=$+1 
        ADD A,0 
        LD (tfmlowC),A 
        LD (addrC),HL 
        LD B,D ;%11111xxx 
tfmhighC=$+2 
        LD HL,#A4+2 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+2 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginC 
        LD (loopaddrC),HL 
        JP tfmframeC 
endC 
loopaddrC=$+1 
        LD HL,0 
        JP tfmframeC 
tfmC 
skipC=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperC 
addrC=$+1 
        LD HL,0 
blkcntC=$+1 
        OR 0 
        JR Z,tfmframeC 
        DEC A 
        LD (blkcntC),A 
        JR NZ,tfmframeC 
blkretaddrC=$+1 
        LD HL,0 
tfmframeC 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginC 
        CP be 
        JR Z,endC 
        CP E ;#BF 
        JR NC,HLskiperC 
        TestKeyOff 2 
        OR A 
        PUSH AF 
        TestFreq 2,tfmhighC,tfmlowC
        TestOutRegs 
        LD (addrC),HL 
        POP AF 
        RET P 
        KeyOn 2 
        RET  

////////////////////////////		
blockD 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntD),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrD),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeD 
OLDfarD 
        LD B,(HL) 
        INC HL 
OLDnearD 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeD 
        POP HL 
        LD (addrD),HL 
        RET  
HLskiperD 
        JR Z,OLDfarD 
        CP %11100000 
        JR C,slideD 
        LD B,A 
        CP #FF 
        JR Z,OLDnearD 
        LD (addrD),HL 
skiperD LD (skipD),A 
        RET  
slideD 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockD 
tfmlowD=$+1 
        ADD A,0 
        LD (tfmlowD),A 
        LD (addrD),HL 
        LD B,D ;%11111xxx 
tfmhighD=$+2 
        LD HL,#A4+0 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+0 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginD 
        LD (loopaddrD),HL 
        JP tfmframeD 
endD 
loopaddrD=$+1 
        LD HL,0 
        JP tfmframeD 
tfmD 
skipD=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperD 
addrD=$+1 
        LD HL,0 
blkcntD=$+1 
        OR 0 
        JR Z,tfmframeD 
        DEC A 
        LD (blkcntD),A 
        JR NZ,tfmframeD 
blkretaddrD=$+1 
        LD HL,0 
tfmframeD 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginD 
        CP be 
        JR Z,endD 
        CP E ;#BF 
        JR NC,HLskiperD 
        TestKeyOff 0 
        OR A 
        PUSH AF 
        TestFreq 0,tfmhighD,tfmlowD
        TestOutRegs 
        LD (addrD),HL 
        POP AF 
        RET P 
        KeyOn 0 
        RET  

////////////////////////////		
blockE 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntE),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrE),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeE 
OLDfarE 
        LD B,(HL) 
        INC HL 
OLDnearE 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeE 
        POP HL 
        LD (addrE),HL 
        RET  
HLskiperE 
        JR Z,OLDfarE 
        CP %11100000 
        JR C,slideE 
        LD B,A 
        CP #FF 
        JR Z,OLDnearE 
        LD (addrE),HL 
skiperE LD (skipE),A 
        RET  
slideE 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockE 
tfmlowE=$+1 
        ADD A,0 
        LD (tfmlowE),A 
        LD (addrE),HL 
        LD B,D ;%11111xxx 
tfmhighE=$+2 
        LD HL,#A4+1 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+1 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginE 
        LD (loopaddrE),HL 
        JP tfmframeE 
endE 
loopaddrE=$+1 
        LD HL,0 
        JP tfmframeE 
tfmE 
skipE=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperE 
addrE=$+1 
        LD HL,0 
blkcntE=$+1 
        OR 0 
        JR Z,tfmframeE 
        DEC A 
        LD (blkcntE),A 
        JR NZ,tfmframeE 
blkretaddrE=$+1 
        LD HL,0 
tfmframeE 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginE 
        CP be 
        JR Z,endE 
        CP E ;#BF 
        JR NC,HLskiperE 
        TestKeyOff 1 
        OR A 
        PUSH AF 
        TestFreq 1,tfmhighE,tfmlowE
        TestOutRegs 
        LD (addrE),HL 
        POP AF 
        RET P 
        KeyOn 1 
        RET  

////////////////////////////		
blockF 
        LD A,(HL) ;N frames 
                  ;1 now, N-1 later 
                  ;skip command is used as 1 frame 
        INC HL 
        LD (blkcntF),A 
        LD B,(HL) 
        INC HL 
        LD C,(HL) ;disp 
        INC HL 
        LD (blkretaddrF),HL 
        ADD HL,BC 
        LD C,#FD 
        JP tfmframeF 
OLDfarF 
        LD B,(HL) 
        INC HL 
OLDnearF 
        LD C,(HL) 
        INC HL 
        PUSH HL 
        ADD HL,BC 
        LD C,#FD 
        CALL tfmframeF 
        POP HL 
        LD (addrF),HL 
        RET  
HLskiperF 
        JR Z,OLDfarF 
        CP %11100000 
        JR C,slideF 
        LD B,A 
        CP #FF 
        JR Z,OLDnearF 
        LD (addrF),HL 
skiperF LD (skipF),A 
        RET  
slideF 
       ;A=-64..-33 
        ADD A,48 
       ;A=-16..15 
        JR Z,blockF 
tfmlowF=$+1 
        ADD A,0 
        LD (tfmlowF),A 
        LD (addrF),HL 
        LD B,D ;%11111xxx 
tfmhighF=$+2 
        LD HL,#A4+2 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),H 
        LD B,D ;%11111xxx 
        LD L,#A0+2 
        WaitStatus 
        OUT (C),L 
        WaitStatus 
        LD B,E ;#BF 
       OUT (C),A 
        RET  
 
beginF 
        LD (loopaddrF),HL 
        JP tfmframeF 
endF 
loopaddrF=$+1 
        LD HL,0 
        JP tfmframeF 
tfmF 
skipF=$+1 
        LD A,-1 
        INC A 
        JR NZ,skiperF 
addrF=$+1 
        LD HL,0 
blkcntF=$+1 
        OR 0 
        JR Z,tfmframeF 
        DEC A 
        LD (blkcntF),A 
        JR NZ,tfmframeF 
blkretaddrF=$+1 
        LD HL,0 
tfmframeF 
        LD A,(HL) 
        INC HL 
        CP bb 
        JR Z,beginF 
        CP be 
        JR Z,endF 
        CP E ;#BF 
        JR NC,HLskiperF 
        TestKeyOff 2 
        OR A 
        PUSH AF 
        TestFreq 2,tfmhighF,tfmlowF
        TestOutRegs 
        LD (addrF),HL 
        POP AF 
        RET P 
        KeyOn 2 
        RET  



regsX        LD B,D ;%11111xxx        WaitStatus        OUTI   ;reg        WaitStatus        LD B,E ;#BF        OUTI   ;value        DEC A        JR NZ,regsX ;в turbo JR=JP        RET ;MDLADDR EQU $
	;endmodule
	