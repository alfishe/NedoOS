;*L+
;*** IO FOR ЧЁРНЫЙ ВОРОН: A-N(1..) HL-START DE-LENTGTH / CY=0 - ERROR

;;SIDE    DEFB    0 ;сторона
;;tDRIVE  DEFB    1 ;текущ дисковод 0/1
;;MEM16   DEFW    0 ;?
;;fADR    DEFW    0 ;адр загр ф-ла

;-------запись

D_WRITE DI   ;запись 256 бт секторов
        CALL    POS
LOPWR1  PUSH    HL
        PUSH    BC
        LD      C,#5F
        LD      A,E
        CALL    RG_DOS
        CALL    WR_SC
        POP     BC
        POP     HL
        INC     E
        INC     H
        DJNZ    LOPWR1
        RET

WR_SC   LD      A,#A0
        LD      C,#1F
        CALL    RG_DOS
        LD      C,#7F
        LD      IX,#3FCA; IN A,(FF): AND C0: JR Z,3FCA: RET M: OUTI: JR 3FCA
        JR      DOS

;----общие

RG_DOS  LD      IX,#2A53 ;выв в рег TRDOS (out (C),A:ret)
        JR      DOS

DOS     PUSH    IX
        JP      #3D2E

POS     ;позиционир трек
        LD C,#3C
        LD A,(SIDE)
        OR A
        JR      Z,DW_SID
        RES     4,C
DW_SID  LD A,(tDRIVE)
        OR C
        LD      C,#FF
        CALL    RG_DOS
        LD      A,D
        LD      C,#7F
        CALL    RG_DOS
        LD      A,#18
        LD      IX,#2F57 ;вып ком TRDOS
        JP DOS

RD_SCT  LD      BC,RD_SCT ;по этому адресу = 1
        PUSH    BC
        LD      BC,#17F
        LD      IX,#2090  ;чтение сектора из п/п форматирования(портит#5cd6)
        JR      DOS

TR000   CALL TR00 ;иниц дисковода + задержка
        CALL TR00
        CALL TR00
TR00    DI
        LD      D,0
        CALL    POS
        LD      IX,#2F65 ;ld a,8:jr 2f57
        JR      DOS

D_READ  DI ;E-sec,D-trk,B-sec.num,HL-mem.adr
        CALL    POS
d_rea_  LD      A,(#5CD6)
        EX      AF,AF'
NXT_S   DEFB    #DD
        LD      L,#3 ;retry.num
NXT_SC  PUSH    HL
        PUSH    BC
NXC_C1  PUSH    IX
        LD      C,#5F
        LD      A,E
        CALL    RG_DOS
        CALL    RD_SCT
        DI;обязательно
        LD      HL,#5CD6
        EX      AF,AF'
        CP      (HL)
        POP     IX
        JR      Z,GOOD
        LD      (HL),A
        DEFB    #DD
        DEC     L
        POP     BC
        POP     HL
        JR      Z,ERR_RW
        EX      AF,AF'
        JR      NXT_SC
GOOD    POP     BC
        POP     HL
        EX      AF,AF'
GOOD1   INC     E
        LD      A,E
        CP      #F9
        JR      C,OLD_TR
        LD      E,#F4
        INC     D
        CALL    POS
OLD_TR  INC     H
        INC     H
        INC     H
        INC     H
        DJNZ    NXT_S
        XOR     A
        RET

ERR_RW  SCF
        RET

;-------логич чтение

READ1   CALL    D_READ ;чтение сектора с проверкой
        RET     NC
        LD      A,(SIDE)
        XOR #FF
        LD      (SIDE),A
;;;     LD A,0 ;разница треков сверху/снизу==0
;;;     JR NZ,RTR1
;;;     NEG
;;;RTR1 ADD A,D
;;;     LD D,A
        PUSH DE
        CALL    TR000
        POP DE
        JR      READ1

READ    ;A-No.файла, HL - adr
        LD (fADR),HL
        LD HL,WX_LEN
        LD D,0
        CP (HL) ;N файла, где к_во секторов >256
        JR C,REA0
        INC D
REA0    INC HL ;табл_hl - Ncект;смещ в секторе/4
        CALL WA
        PUSH AF
        PUSH HL
        LD E,A
        LD L,5
        CALL DIVB2
        LD A,D
        LD D,E
        ADD A,#F4 ;f4..f8
        LD E,A
        LD A,D ;+14 треков
        ADD A,14
        LD D,A
        LD B,1
        LD HL,(fADR)
        PUSH HL
        XOR A
        LD (SIDE),A
        CALL READ1
        LD (MEM16),DE
        POP DE
        POP HL
        INC HL
        PUSH HL
        LD L,(HL)
        LD H,0
        ADD HL,HL
        ADD HL,HL
        PUSH HL
        ADD HL,DE
        LD BC,1024
        PUSH BC
        LDIR
        POP HL
        POP BC
        OR A
        SBC HL,BC
        LD BC,(fADR)
        ADD HL,BC
        POP DE
        INC DE
        LD A,(DE)
        POP BC
        SUB B
        RET Z
        LD B,A
        LD DE,(MEM16)
        JR READ1

;--------Работа с файлами

numFL   EQU 129 ;длина т.ф-лов (111+8+8)

;1-5    -ландшафты
;6      -панель
;7-8    -кнопки
;9-17   -музыки
;18-49  -уровни


READ_F  PUSH HL  ;загр и декомпр
        CALL READ
        POP HL
DELPZF  LD DE,#FFFF
;Декомпрессор
;HL - ОТКУДА И КУДА, DE - ВЕРХНЯЯ ГРАНИЦА ОБЛАСТИ
DELPZX  PUSH HL
        LD C,(HL)
        INC HL
        LD B,(HL)
        ADD     HL,BC
        LDDR
        EX      DE,HL
        INC     HL
        POP     DE
        JP      DELPZ

selSAV  LD A,(SAVDSK)
        JR selD_
selD_2  LD A,(DISK_2)
selD_   LD (tDRIVE),A
        RET

muzfilename
muzfilename_number=$+5 ;0..7
        db "brmuz0.dat",0
barfilename
        db "brbar.dat",0
butfilename
butfilename_number=$+5 ;0..1
        db "brbut0.dat",0
sprfilename
sprfilename_number=$+5 ;1..4
        db "brspr1.dat",0

LOADOSpp
        push hl
        OS_OPENHANDLE
        pop de
       push de
        ld hl,0x4000 ;size
        push bc
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
       POP HL
        ret

LOADms  ;загр. офрмл. уровня

        ;jr $

        ;пров защиты
        EX AF,AF'
        CALL MEM0
        if 1==0        
        CALL PROTeC ;AF'=NC/C-нов ур/подгр ;???
        else
        EX AF,AF'
	JR C,LOADms_nonewlevel ;подгр
        CALL SEEonn	;0 нов ур
	CALL setC1	;0
	CALL setMAP	;0
LOADms_nonewlevel
        endif

        if 1==1
        call swapimer ;делает ei
        im 1
        ;загр ландш A=1..4
        CALL MEM1
        LD A,(fsLAND)
        LD HL,_sLAND
        CP (HL)
        JR Z,lad2 ;загружено
        LD (HL),A
        add a,"0"
        ld (sprfilename_number),a
        ld de,sprfilename
        ld hl,LAND ;addr
        call LOADOSpp
        LD DE,#FFFF
         di
        CALL DELPZX
lad2
        ;--загр панели
        ld de,barfilename
        ld hl,DSCR ;addr
        call LOADOSpp
        
        ;--загр кнопок A=0..1
        CALL MEM7
        LD A,(MASTER)
        LD HL,_sBUTT
        CP (HL)
        JR Z,lad3 ;загружено
        LD (HL),A
        add a,"0"
        ld (butfilename_number),a
        ld de,butfilename
        ld hl,WBUTT ;addr
        call LOADOSpp
        LD DE,WNAMES
         di
        CALL DELPZX
lad3
        ;--загр муз A=0..7
        CALL MEM6
        LD A,(fsMUS)
        LD HL,_sMUS
        CP (HL)
        JR Z,lad1 ;загружено
        LD (HL),A
        add a,"0"
        ld (muzfilename_number),a
        ld de,muzfilename
        ld hl,WMUSIC ;addr
        call LOADOSpp
        LD DE,#FFFF
         di
        CALL DELPZX
lad1
        call swapimer ;делает ei
        im 2
        
        else

        ;загр ландш A=1..4
        CALL MEM1
        LD A,(fsLAND)
        LD HL,_sLAND
        CP (HL)
        JR Z,lad2 ;загружено
        LD (HL),A
        LD HL,LAND
        CALL READ_F
lad2    ;--загр панели
        LD A,6
        LD HL,DSCR
        CALL READ
        ;--загр кнопок A=0..1
        CALL MEM7
        LD A,(MASTER)
        LD HL,_sBUTT
        CP (HL)
        JR Z,lad3 ;загружено
        LD (HL),A
        ADD A,7
        LD HL,WBUTT
        PUSH HL
        CALL READ
        POP HL
        LD DE,WNAMES
        CALL DELPZX
lad3    ;--загр муз A=0..7
        CALL MEM6
        LD A,(fsMUS)
        LD HL,_sMUS
        CP (HL)
        JR Z,lad1 ;загружено
        LD (HL),A
        ADD A,9
        LD HL,WMUSIC
        CALL READ_F
lad1    
        endif

        if 1==1
        JP MEM0
        else
        LD HL,(WX_BAD+1) ;[--8]
        LD A,H
        SUB L
        LD HL,WX_BAD+8
        CP (HL)
        JP Z,MEM0
        endif

;----------сохр игры--

pasw    EQU #0C5E ;к/с отгрузки
ENCODE  DI
        LD DE,pasw
        LD HL,G_DATA
        LD BC,DSCR-G_DATA
        CALL enc1
        LD HL,HUMAN
        LD BC,#BFFA-HUMAN
        CALL enc1
        LD (HL),E
        INC HL
        LD (HL),D
        RET
        ;
enc1    LD A,(HL)
        ADD A,E
        LD E,A
        JR NC,enc2
        INC D
enc2    RRC (HL)
        INC HL
        DEC BC
        LD A,C
        OR B
        JR NZ,enc1
        RET

DECODE  DI
        LD DE,pasw
        LD HL,G_DATA
        LD BC,DSCR-G_DATA
        CALL dnc1
        LD HL,HUMAN
        LD BC,#BFFA-HUMAN
        CALL dnc1
        LD A,(HL)
        CP E
        RET NZ
        INC HL
        LD A,(HL)
        CP D
        RET ;NZ/Z- err/ok
        ;
dnc1    RLC (HL)
        LD A,(HL)
        ADD A,E
        LD E,A
        JR NC,dnc2
        INC D
dnc2    INC HL
        DEC BC
        LD A,C
        OR B
        JR NZ,dnc1
        RET

SAVgam  ;сохр A=0-7
        ADD A,A
        ADD A,A
        ADD A,A
        ADD A,4
        LD D,A ;c 4-ого трека
        PUSH DE
        CALL selSAV
        CALL MEM6
        CALL WMUSIC
        CALL MEM7
        CALL ENCODE ;-di
Srtry   POP DE
        PUSH DE
        XOR A
        LD (SIDE),A
        CALL TR000
        ;---запись данных
        POP DE
        PUSH DE
        LD HL,G_DATA
        LD A,5
svv0    PUSH AF
        CP 1
        LD B,16
        JR NZ,svv1
        LD B,9
svv1    LD E,1
        CALL D_WRITE
        INC D
        POP AF
        DEC A
        JR NZ,svv0
        ;----пров  перв сект
        POP DE
        PUSH DE
        LD HL,DSCR
        PUSH HL
        LD B,1
        LD E,B
        CALL D_READ
        POP HL
        LD DE,G_DATA
        LD B,255
svvCP0  LD A,(DE)
        CP (HL)
        JR NZ,Srtry ;--err
        INC HL
        INC DE
        DJNZ svvCP0
        POP DE
        JP DECODE

levfilename
levfilename_master=$+2
levfilename_number=$+3
        ;db "br101.dat",0
        db "br215.dat",0

;-------- i/o
LODlev  ;загр нов уровня

        if 1==1
;TODO ei и восстановить патч музыки???
        ;jr $
        call swapimer ;делает ei
        im 1
        ;jr $
        LD A,(MASTER)
        add a,"1"
        ld (levfilename_master),a
        LD A,(LEVEL)
        inc a
        cp 10
        ld hl,levfilename_number
        ld (hl),"0"
        jr c,$+5 ;1..9
         sub 10 ;10..17
         inc (hl)
        add a,"0"
        inc hl
        ld (hl),a
        ld de,levfilename
        OS_OPENHANDLE
        ld de,LEVDAT ;addr
       push de
        ld hl,0x4000 ;size
        push bc
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
       pop hl
        LD DE,#BFFE
         di
        CALL DELPZX
        
        call swapimer
        im 2
        
        else

        CALL selD_2
        LD A,(MASTER)
        OR A
        LD C,18 ;1й ур л
        JR Z,LLV0
        LD C,36 ;1й ур к
LLV0    LD A,(LEVEL)
        ADD A,C ;# file
        LD HL,LEVDAT
        PUSH HL
        CALL READ
        POP HL

        LD DE,#BFFE
        CALL DELPZX
        
        endif
        
         ;jr $
        CALL MEM0
        CALL isRUNL ;для заключ уровней - набор данных
        CALL OFFS
        LD HL,datSCR
        LD DE,SCR
        LD BC,6912
        LDIR
        XOR A
        OUT (254),A
        RET

        if 1==0
;----диск 2

TXds21  DEFB 14,65,66,48,50,74,66,53,10, 52,56,65,58,10, 02,127 ;insert d2
TXds22  DEFB 50,10, 52,56,65,58,62,50,62,52,10, 44,43, 127 ;в д-д Х:
TXdsEn  DEFB 56,10, 61,48,54,60,56,66,53,10, 17,81,30,17,82, 127 ;& Enter

CHNGd2  CALL MEM7
        LD DE,#403  ;смени диск2
        LD BC,#1307
        CALL MU_BOX
        ATRs #403,#0713,#69
        LD DE,#605
        LD HL,TXds21
        CALL PRINTS
        LD DE,#706
        LD HL,TXds22
        CALL PRINTS
        DEC DE
        DEC DE
        LD A,(DISK_2)
        ADD A,12
        CALL PRINT
        LD DE,#805
        LD HL,TXdsEn
        CALL PRINTS
isENTR  LD BC,#BFFE
        IN A,(C)
        RRA
        RET NC
        JR C,isENTR

        endif
