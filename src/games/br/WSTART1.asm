        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

        macro PUSHs
        PUSH    HL
        PUSH    DE
        PUSH    BC
        ENDM
        macro POPs
        POP     BC
        POP     DE
        POP     HL
        ENDM

        slot 0
        page 8

        slot 3
        page 0

        org PROGSTART
begin
ORGX
        jp START

; Чёрный Ворон
; Стартовый менеджер загрузки заставки
; а затем - фильм, инструкция или игра

DSCR    EQU #4000
SCR     EQU #C000

        ;DEFB #D1,#BB ;метка диска 1
        ;JP F_CUT
        db "  Black Raven StartUp Manager  "
;Декомпрессор

DLPCB   db "v101b"
        include "xdelpz.asm"

DELPZF  LD DE,#FFFE
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

MEM0    XOR A;Cтандартная страница-0
        JR      MEM

MEM7    LD      A,7
MEM     
        if 1==1
_128
        push bc
        ;LD	BC,#7FFD
	;LD	(R128),A
	;OUT	(C),A
        ;and 7
        ld ($+3+1),a
        ld a,(ttexpgs)
	;LD	(R128),A
        SETPG32KHIGH
        pop bc
	RET
        else
        OR      %10000
        PUSH BC
        LD      BC,#7FFD
        OUT     (C),A
        POP BC
        RET
        endif

OFFD    XOR     A
OFFD__  LD      DE,DSCR+#1AFE
        LD      HL,DSCR+#1AFF
        LD      BC,768
        LD      (HL),A
        LDDR
        RET

OFFS    CALL    MEM7
OFFS_   LD      DE,SCR+#1AFE
        LD      HL,SCR+#1AFF
        LD      BC,768
        LD      (HL),0
        LDDR
        RET

SW5     ;LD A,%10000 ;норм экр
        ld e,0
        JR SW_
SW7     ;LD A,%11000
        ld e,1
SW_     ;LD (MEM+1),A ;доп экр
        OS_SETSCREEN
        RET

        ds 256+ORGX-$,#F6

        DEFW    S,S,S,S,S,S,S,S,S,S,S,S,S,S

        align 256
ttexpgs
        ds 256

;TR00    DI
;        LD      IX,#2F5F
;        CALL    DOS
;        LD      IX,#2F65
;        JP      DOS

F_DAT

;*F w&DISK1
        if 1==0
;sec,trk,size
  DEFB	 #C0,0,16 	; none (0)
  DEFB	#C0,2,9 	; file (1) name (..\W01\W&START1.B04)
  DEFB	#C4,3,10 	; file (2) name (..\W01\W&START1.lp2)
  DEFB	#C4,5,8 	; file (3) name (..\W01\W&START1.lp3)
  DEFB	#C2,7,40 	; file (4) name (..\W01\W&START1.B01)
  DEFB	 #C1,15,16 	; none (5)
  DEFB	#C2,15,12 	; file (6) name (..\game.lpz\w.lp0)
  DEFB	#C4,17,11 	; file (7) name (..\game.lpz\w.lp1)
  DEFB	#C0,20,12 	; file (8) name (..\game.lpz\w.lp5)
  DEFB	#C2,22,9 	; file (9) name (..\game.lpz\w.lp7)
  DEFB	#C1,24,8 	; file (10) name (..\game.lpz\w.lp3)
  DEFB	#C4,25,8 	; file (11) name (..\game.lpz\w.lp4)
  DEFB	#C2,27,1 	; file (12) name (..\game.lpz\w0_s1.lpz)
  DEFB	#C3,27,9 	; file (13) name (..\game.lpz\w.lp6)
  DEFB	 #C2,42,16 	; none (14)
  DEFB	#C2,29,16 	; file (15) name (..\W01\W&FINAL.BIN)
  DEFB	#C3,32,5 	; file (16) name (..\intro\flick.lpz\waniB_0.lpz) ;используем файлы, начиная с этого №16
  DEFB	#C3,33,5 	; file (17) name (..\intro\flick.lpz\waniB_1.lpz)
  DEFB	#C3,34,10 	; file (18) name (..\intro\flick.lpz\waniD_0.lpz)
  DEFB	#C3,36,9 	; file (19) name (..\intro\flick.lpz\waniD_1.lpz)
  DEFB	#C2,38,5 	; file (20) name (..\intro\flick.lpz\wani8_0.lpz)
  DEFB	#C2,39,4 	; file (21) name (..\intro\flick.lpz\wani8_1.lpz)
  DEFB	#C1,40,10 	; file (22) name (..\intro\flick.lpz\waniJ_0.lpz)
  DEFB	#C1,42,11 	; file (23) name (..\intro\flick.lpz\waniJ_1.lpz)
  DEFB	#C2,44,11 	; file (24) name (..\intro\flick.lpz\waniA_0.lpz)
  DEFB	#C3,46,11 	; file (25) name (..\intro\flick.lpz\waniA_1.lpz)
  DEFB	#C4,48,11 	; file (26) name (..\intro\flick.lpz\waniC_0.lpz)
  DEFB	#C0,51,12 	; file (27) name (..\intro\flick.lpz\waniC_1.lpz)
  DEFB	#C2,53,13 	; file (28) name (..\intro\flick.lpz\waniG_0.lpz)
  DEFB	#C0,56,12 	; file (29) name (..\intro\flick.lpz\waniG_1.lpz)
  DEFB	#C2,58,10 	; file (30) name (..\intro\flick.lpz\waniI_0.lpz)
  DEFB	#C2,60,9 	; file (31) name (..\intro\flick.lpz\waniI_1.lpz)
  DEFB	#C1,62,11 	; file (32) name (..\intro\flick.lpz\wani7_0.lpz)
  DEFB	#C2,64,9 	; file (33) name (..\intro\flick.lpz\wani7_1.lpz)
  DEFB	#C1,66,10 	; file (34) name (..\intro\flick.lpz\waniE_0.lpz)
  DEFB	#C1,68,11 	; file (35) name (..\intro\flick.lpz\waniE_1.lpz)
  DEFB	#C2,70,13 	; file (36) name (..\intro\flick.lpz\waniF_0.lpz)
  DEFB	#C0,73,12 	; file (37) name (..\intro\flick.lpz\waniF_1.lpz)
  DEFB	#C2,75,11 	; file (38) name (..\intro\flick.lpz\wani9_0.lpz)
  DEFB	#C3,77,12 	; file (39) name (..\intro\flick.lpz\wani9_1.lpz)
  DEFB	#C0,80,12 	; file (40) name (..\intro\flick.lpz\wani2_0.lpz)
  DEFB	#C2,82,11 	; file (41) name (..\intro\flick.lpz\wani2_1.lpz)
  DEFB	#C3,84,11 	; file (42) name (..\intro\flick.lpz\wani6_0.lpz)
  DEFB	#C4,86,12 	; file (43) name (..\intro\flick.lpz\wani6_1.lpz)
  DEFB	#C1,89,9 	; file (44) name (..\intro\flick.lpz\waniH_0.lpz)
  DEFB	#C0,91,6 	; file (45) name (..\intro\flick.lpz\waniH_1.lpz)
  DEFB	#C1,92,8 	; file (46) name (..\intro\flick.lpz\wani3_0.lpz)
  DEFB	#C4,93,8 	; file (47) name (..\intro\flick.lpz\wani3_1.lpz)
  DEFB	#C2,95,10 	; file (48) name (..\intro\flick.lpz\wani4_0.lpz)
  DEFB	#C2,97,10 	; file (49) name (..\intro\flick.lpz\wani4_1.lpz)
  DEFB	#C2,99,10 	; file (50) name (..\intro\flick.lpz\wani5_0.lpz)
  DEFB	#C2,101,10 	; file (51) name (..\intro\flick.lpz\wani5_1.lpz)
  DEFB	#C2,103,11 	; file (52) name (..\intro\flick.lpz\waniU_0.lpz)
  DEFB	#C3,105,12 	; file (53) name (..\intro\flick.lpz\waniU_1.lpz)
  DEFB	#C0,108,8 	; file (54) name (..\intro\flick.lpz\waniV_0.lpz)
  DEFB	#C3,109,9 	; file (55) name (..\intro\flick.lpz\waniV_1.lpz)
  DEFB	#C2,111,10 	; file (56) name (..\intro\flick.lpz\waniW_0.lpz)
  DEFB	#C2,113,9 	; file (57) name (..\intro\flick.lpz\waniW_1.lpz)
  DEFB	#C1,115,10 	; file (58) name (..\intro\flick.lpz\waniX_0.lpz)
  DEFB	#C1,117,11 	; file (59) name (..\intro\flick.lpz\waniX_1.lpz)
  DEFB	#C2,119,11 	; file (60) name (..\intro\flick.lpz\waniY_0.lpz)
  DEFB	#C3,121,11 	; file (61) name (..\intro\flick.lpz\waniY_1.lpz)
  DEFB	#C4,123,10 	; file (62) name (..\intro\flick.lpz\waniZ_0.lpz)
  DEFB	#C4,125,10 	; file (63) name (..\intro\flick.lpz\waniZ_1.lpz)
        endif
        
        db "B"
        db "D"
        db "8"
        db "J"
        db "A"
        db "C"
        db "G"
        db "I"
        db "7"
        db "E"
        db "F"
        db "9"
        db "2"
        db "6"
        db "H"
        db "3"
        db "4"
        db "5"
        db "U"
        db "V"
        db "W"
        db "X"
        db "Y"
        db "Z"
        
curfilename
curfilename_letter=$+4
curfilename_number=$+6
        db "waniZ_1.lpz",0
        

R128
        db 0

br_path
		defb "br",0

texfilename
        ;db 0,"bri0.dat",0 ;его нет, чисто для заказа страницы
        db 3,"bri3.dat",0
        db 4,"bri4.dat",0
        db 7,"bri7.dat",0
ntexfilenames=3

loadpic
        ld e,3
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        ld b,25
waitcls0
        push bc
        YIELD
        pop bc
        djnz waitcls0 ;чтобы nv не затёр pg7
        
		ld de,br_path
		OS_CHDIR

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,l
        ;LD (ttexpgs+0),A
        ld hl,ttexpgs
        ld (hl),a
        ld b,7
filltexpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        inc l
        ld (hl),e
        pop bc
        djnz filltexpgs0

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,h
         ld (ttexpgs+31),a ;ld (IR128),a ;на всякой случай, для прерывания
         ld (getttexpgs_basepg7),a
         
        ld a,d
        SETPG16K
        
;не будем брать физические страницы, кроме 7, т.к. pg4 используется для запарывания осью

        ld hl,texfilename
        ld b,ntexfilenames
getttexpgs0
        push bc
        ld a,(hl)
        cp 7
getttexpgs_basepg7=$+1
        ld a,0
        jr z,getttexpgs7
        push de
        push hl
        OS_NEWPAGE
        ld a,e
        pop hl
        pop de
getttexpgs7
        ld c,(hl)
        ld b,ttexpgs/256
        ld (bc),a
        inc hl
        push hl
        SETPG32KHIGH

        ld a,(hl)
        cp ' '
        jr nc,gettexpgs_noskipdata
         ;jr $
        inc hl
gettexpgs_noskipdata
        ex de,hl
        push af
        OS_OPENHANDLE
        pop af ;CY=skip data, a=number of 8Ks to skip
        jr nc,gettexpgs_noskipdata2
        push bc
        ld de,0
        ld hl,0
        rra
        rr h
        rra
        rr h
        rra
        rr h
        OS_SEEKHANDLE ;dehl=offset
        pop bc
gettexpgs_noskipdata2
        push bc
        ld de,0xc000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
                
        pop hl
        ld b,1
        xor a
        cpir ;after 0
        pop bc
        djnz getttexpgs0
        ret

        ;ENT $
S
START   ;начало начал
        ;DI
        ;IM 1
        LD SP,0x4000;#61FE
        
        call loadpic
        di
;               JP bFLAG
;               JP bINSTR
;               JP bFLICK
        ;Теневик off
        ;CALL ON256
        ;CALL MEM0
        ;LD HL,#C000
        ;LD DE,#C001
        ;LD BC,#5000
        ;LD (HL),#A4 ;байт-заполнитель
        ;LDIR ;;++
        ;CALL OFF256
        ;drive num
        ;LD A,(23798)
        ;LD (DRIVE),A
        ;Заставка
        LD A,%1001
        OUT (254),A
        CALL OFFD__
        CALL MEM7
        LD A,1
        ;CALL LOADF
        LD DE,SCR
        LD HL,CROW+2
        CALL DELPZ
        CALL SW7
        ;если ЕНТЕР нажат, сразу грузи игру
        ;LD BC,#BFFE
        ;IN A,(C)
        ;RRA
        ;JR NC,bGAME
        ;
        LD A,3
        CALL MEM
        LD A,2
        ;CALL LOADG
        LD A,4
        CALL MEM
        LD A,3
        ;CALL LOADG
        CALL MEM0
        LD A,4
        ;CALL LOADF
        CALL bFLAG ;-->
        ;
LOADG   ;CALL LOADF
        LD HL,#C000
        JP DELPZF

       ;-------------
        if 1==0
bGAME   ;загрузка игры ; страницы 0(F6),1,*2,7,3,4,*5,6(F13)

        DI
        CALL SW7
        XOR A
        CALL MEM
        LD A,6
        CALL LOADF
        ;
        LD A,1
        CALL MEM
        LD A,7
        CALL LOADF
        ;
        LD A,2
        CALL MEM
        LD A,8
        CALL LOADF
        ;
        CALL OFFD
        CALL SW5
        XOR A
        OUT (254),A
        CALL MEM7
        LD A,9
        CALL LOADG
        CALL SW7
        ;
        LD A,3
        CALL MEM
        LD A,10
        CALL LOADF
        ;
        LD A,4
        CALL MEM
        LD A,11
        CALL LOADF
        ;
        LD A,5
        CALL MEM
        LD A,12 ;4k!
        CALL LOADF
        ;
        LD A,6
        CALL MEM
        LD A,13
        CALL LOADF
        ;
        DI
        LD B,7 ;раскрыть страницы
bGloo   PUSH BC
        LD A,B
        DEC A
        CALL MEM
        LD HL,#C000
        CALL DELPZF
        POP BC
        DJNZ bGloo
        ;
        LD A,6
        CALL MEM
        CALL #FE00 ;-->перейти к старту игры в странице 6

        endif

ST_ADR  DEFB #70,#DB,#C0,#C0,#62,#C0 ;интро
        DEFB #C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0,#80 ;нач. игры
        ;#C0-все флики

firstT  EQU #C0 ;перв сектор
lastT   EQU #C4 ;последн сектор

READ    DI ;E-sec,D-trk,B-sec.num,HL-mem.adr
        CALL    POS
        LD      A,(#5CD6)
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
        DI ;обязательно
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
        JP      Z,ERR_RW
        EX      AF,AF'
        JR      NXT_SC
GOOD    POP     BC
        POP     HL
        EX      AF,AF'
GOOD1   INC     E
        LD      A,E
        CP      lastT+1
        JR      C,OLD_TR
        LD      E,firstT
        INC     D
        CALL    POS
OLD_TR  INC     H
        INC     H
        INC     H
        INC     H
        DJNZ    NXT_S
        DI
        XOR     A
        RET

DRIVE   DEFB 0 ;текущий дисковод

POS     LD      A,(DRIVE)
        ADD     A,#3C
        BIT     0,D
        JR      Z,DW_SID
        RES     4,A
DW_SID  LD      C,#FF
        CALL    RG_DOS
        LD      A,D
        SRL     A
        LD      C,#7F
        CALL    RG_DOS
        LD      A,#18
        LD      C,#1F
        CALL    RG_DOS
        CALL    COM_EX
        DI ;обязательно
        RET

RD_SCT  LD      BC,RD_SCT
        PUSH    BC
        LD      BC,#17F
        LD      IX,#2090
        JR      DOS

RG_DOS  LD      IX,#2A53
        JR      DOS

COM_EX  LD      IX,#3EF5
DOS     PUSH    IX
        JP      #3D2F

ERR_RW  SCF
        RET


WA      RLCA
BA      ADD     A,L
        LD      L,A
        JR      NC,B1
        INC     H
B1      LD      A,(HL)
        RET

LOADF   ;A-N ф-ла (0..NN)
        PUSH    AF
         sub 16
         rra
        ;LD D,A
        ;ADD A,A
        ;ADD A,D
        LD HL,F_DAT
        CALL BA ;add hl,a:ld a,(hl)
        ;LD E,(HL)
        ;INC HL
        ;LD D,(HL)
        ;INC HL
        ;LD B,(HL)
         ld (curfilename_letter),a
        POP AF
         and 1
         add a,'0'
         ld (curfilename_number),a
        ;LD H,#C0 ;флики
        ;CP 16
        ;JR NC,L16
        ;LD HL,ST_ADR ;остальные файлы
        ;CALL BA
        ;LD H,A
;L16     XOR A
        ;LD L,A
;RETRY1  ;CALL    READ
        ;RET     NC
        ;DI
        ;CALL    TR00
        ;CALL    TR00
        ;CALL    TR00
        ;JR      RETRY1
        ld de,curfilename
        OS_OPENHANDLE
        push bc
        ld de,0xc000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
        ret

;===============================

        ;ORG #6200 ;.B01
        include "WINTRO.asm"
;*L+
        ds 0x4000-$
        include "WINSTR.asm"
WFTXT
        incbin "data/WFLICTXT.LPZ"
MUS     EQU 60000
        ds MUS-$,#10
        incbin "intro/FORGIVME.MUS"

;*L+
        db "End of code"
end

;*P3;======3        .B02
        ;slot 3
        page 3
        ORG #C000
begin3
        incbin "intro/XLAG_BL0.DAT"
PIKE
        incbin "intro/WXLAG.LPZ"
end3
;*P4;======4        .B03
        ;slot 3
        page 4
        ORG #C000
begin4
        incbin "intro/XLAG_BL1.DAT"
end4
;*P7;======7        .B04
        ;slot 3
        page 7
        ORG #DB00
begin7=0xc000 ;лоадер иначе не умеет
CROW
        incbin "barkov/CROW1.LPZ"
J45LPZ
        incbin "intro/JAMMY45.LPZ"
end7
;*P0;======0
        ;slot 3
        page 0

;*P0;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI3_0.LPZ
;*P1;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI3_1.LPZ
;*P3;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI4_0.LPZ
;*P4;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI4_1.LPZ
;*P6;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI5_0.LPZ
;*P7;
;       ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANI5_1.LPZ
;*P0 ;==

	display "begin=",begin
	display "end=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
        page 0
	savebin "brintro.com",begin,end-begin
        page 3
	savebin "br/bri3.dat",begin3,end3-begin3
        page 4
	savebin "br/bri4.dat",begin4,end4-begin4
        page 7
	savebin "br/bri7.dat",begin7,end7-begin7
	
	;LABELSLIST "..\us\user.l"
 