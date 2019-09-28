; Чёрный Ворон (С) Медноногов В.С, 1996,97
        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"
;*L+
;*D-
SCR     EQU #C000
ATR     EQU #D800
;-----------------------
STACK=0x4000
INTSTACK=0x3f00
;scrbase=0x8000
timer=0x3f00 ;???

;D$      MAC ;debug
;        DI
;        HALT
;        EI
;        ENDM

;M$      MAC
;        LD      A,=0
;        CALL    MEM
;        ENDM


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
        jp begingo
        jp _128
        jp swapimer
_128
        push bc
        ;LD	BC,#7FFD
	LD	(R128),A
	;OUT	(C),A
        and 7
        ld ($+3+1),a
        ld a,(ttexpgs)
        SETPG32KHIGH
        pop bc
	RET
R128
        db 0

swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038

on_int
;restore stack with de
        EX DE,HL
	EX (SP),HL
	LD (on_int_jp),HL
	EX DE,HL
	POP DE
	LD (on_int_sp2),SP
	LD SP,DBL_SP
	CALL INAR0
on_int_sp2=$+1
	ld sp,0
	EI
on_int_jp=$+1
	jp 0

        align 256 ;0x200
ttexpgs
        ds 8

        include "w_intv.asm"

begingo
        ld sp,STACK

        ld e,3
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ;ld a,l
        ;LD (pgscalersnum),A

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,l
        ;ld (setpgs_scr_low),a
	;xor e
        ;ld (setpgs_scr_xor),a
        ;ld a,d
	;xor e
        ;ld (setpgs_scr_high_xor_low),a
        ld a,h
        ld (getttexpgs_bagepg7),a
;не будем брать физические страницы, кроме 7, т.к. pg4 используется для запарывания осью

        ;OS_NEWPAGE
        ;ld a,e
        ;ld (pgmapnum),a

        ld hl,texfilename
        ld b,6
getttexpgs0
        push bc
        ld a,(hl)
        cp 7
getttexpgs_bagepg7=$+1
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
        
        ex de,hl
        OS_OPENHANDLE
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

        ;YIELD ;иначе не установится видеорежим и палитра?

        ;call genscalers

        call swapimer
        jp GO
        ;call GO
        ;call swapimer
        ;QUIT

texfilename
        db 0,"br0.dat",0
        db 1,"br1.dat",0
        db 3,"br3.dat",0
        db 4,"br4.dat",0
        db 6,"br6.dat",0
        db 7,"br7.dat",0

        ds 0x4000-$ ;ORG #4000
;--------/MEM--------
        nop ;IR128   DEFB    0
        nop ;R128    DEFB    %11000
        nop ;CHK#0   DEFB    #EE       ;[**B] чек-сум0 ;#4002 ;???
;--------- i/o переменные ---
DISK_2  DEFB    1 ;номер дисковода для диска 2
DISK_T  DEFB    0 ;номер дисковода для отгрузок
SIDE    DEFB    0 ;сторона
MEM16   DEFW    0 ;?
tDRIVE  DEFB    1 ;текущ дисковод 0/1
fADR    DEFW    0 ;адр загр ф-ла
;-------- текущ файлы ----
MORTE   DEFB 0;86 - супер энергия
        nop ;CHK#1   DEFB    #EE       ;[**B] чек-сум1 ;#400C ;???
;
_sBUTT  DEFB 0; 0-1
_sLAND  DEFB #FE; 1-4
_sMUS   DEFB #FB; 0-7
        nop ;isTST5  DEFB    %11000 ;пров 5 [**] ;???

        ;ENT $ ;>>>>>
GO
        ds 2
JP_ST   DI
        LD A,#41
        LD I,A
        LD SP,#403E
        ;IM 2
        JP wMAIN


        db "Made by Copper Feet 1997 v1.01.B"
        ds #4040-$
        JP INTRP ;in #4040
;--адреса.некот.таблиц--
CHK#2   DEFW    #EEEE   ;[**W] чек-сум2 ;#4043
CHK#3   DEFB    #EE     ;[**B] чек-сум3 ;#4045
        DEFW    BFORCE  ;#4046
        DEFW    hBUT    ;#4048
        DEFW    hMSG    ;#404A
        DEFW    hCLRIC  ;#404C
        DEFW    hWIZRD  ;#404E
;==================================обслуживание клавиатуры
PRSKEY  PUSH    BC
        LD      C,#FE
        CALL    PRSROW
        POP     BC
        AND     C
        RET

PRSROW  IN      A,(C)
        CPL
        AND     #1F
        RET

CONTR   
        PUSHs
        LD      A,(KEYJOY)
        OR      A
        JR      Z,CO1
        LD      C,#1F
        CALL    PRSROW
        XOR     #1F
CO2     LD      (CONTRB),A
        LD      A,(PMOUSE)
        OR      A
        CALL    NZ,MOUSE
        POPs
        LD      A,(CONTRB)
        RET
CO1     LD      HL,(KEYS)
        LD      E,0
        LD      D,5
CO3     LD      C,(HL)
        INC     HL
        LD      B,(HL)
        CALL    PRSKEY
        JR      Z,CO4
        SET     5,E
CO4     RRC     E
        DEC     D
        INC     HL
        JR      NZ,CO3
        LD      A,E
        JR      CO2

DELAY   HALT
        DEC A
        JR NZ,DELAY
        RET Z

KBR     DEFW    #DF01,#DF02,#FD01,#FB01,#7F15
INT2    DEFW    #EF08,#EF10,#EF04,#EF02,#EF01
;;KUR   DEFW    #EF04,#F710,#EF10,#EF08,#EF01 ;;;

RND     PUSH    HL
        LD      HL,(RNA)
        INC     HL
;;;     LD      A,R
;;;     ADD     A,H
        LD      A,H ;;;
        AND     #3F;#1F
        LD      H,A
        LD      A,(RNB)
        RRCA
        XOR     (HL)
        ADD     A,L
        LD      (RNA),HL
        LD      (RNB),A
        POP     HL
        RET

;--------------проверка денег---
chkCRC  PUSH HL ;проверить к/сумму денег
        PUSH AF
        CALL suMdig
        CP (HL)
        JR Z,exiCRC
suMdig  ;вычислить к/с денег
        PUSH BC
        LD HL,MONEY-1
        LD B,6
        LD A,(TASK_M+10)
suM1    INC HL
        RLCA
        RLCA
        RLCA
        XOR (HL)
        SUB L
        DJNZ suM1
        POP BC
        LD HL,MNYcrc
        RET
setC1   SCF
setCRC  PUSH HL ;установить к/с денег
        PUSH AF
        CALL suMdig
        LD (HL),A
exiCRC  POP AF
        POP HL
        RET
;----------------Interupt table
        ds #4100-$
        DEFS 257,#40
;---выровн табл (H-без изменений)------------
inMAP   DEFW 64,65,1,-63,-64,-65,-1,63 ;for MAKE_R
MLtab1  DEFB #FF,#7F,#3F,#1F,#F,#7,#3,#1        ;для hLINE
MLtab2  DEFB #80,#C0,#E0,#F0,#F8,#FC,#FE,#FF
MLtabV  DEFB #80,#40,#20,#10,#8,#4,#2,#1        ;для vLINE
GO_Ntb  ;смещ по напр y,x;y,x;y,x...  для GO_NXT
        DEFB 0,1, 1,1, 1,0, 1,-1, 0,-1, -1,-1, -1,0, -1,1; (8)
;---------------------------------------------
GO_Nt2  ;...продолж для расст =2
        DEFB 2,-1, 2,0, 2,1, -2,1, -2,0, -2,-1
        DEFB 1,2, 0,2, -1,2, -1,-2, 0,-2, 1,-2 ;(20)
        ;=2max
        DEFB -2,2, -2,-2, 2,-2, 2,2 ;(24)
        ;=3
        DEFB 0,-3, 3,0, 0,3, -3,0
        DEFB 1,-3, 3,1, -1,3, -3,-1
        DEFB -1,-3, 3,-1, 1,3, -3,1
        DEFB 2,-3, 3,2, -2,3, -3,-2
        DEFB -2,-3, 3,-2, 2,3, -3,2 ;(44)
        ;=3max
        DEFB -3,3, -3,-3, 3,-3, 3,3 ;(48)
        ;=4
        DEFB 0,-4, 4,0, 0,4, -4,0
        DEFB 1,-4, 4,1, -1,4, -4,-1
        DEFB -1,-4, 4,-1, 1,4, -4,1
        DEFB 2,-4, 4,2, -2,4, -4,-2
        DEFB -2,-4, 4,-2, 2,4, -4,2 ;(68)

;Main procedures
        include "wlid.asm"
        include "w_io.asm"
WFONT
        incbin "data/wfont.fnt"
        include "xdelpz.asm"
        ;include "w_intv.asm"
        include "wlib2.asm"
        ds 157 ;просто так ;???
        include "wlib2x3.asm"
        include "wlie.asm"
        include "wlib1a.asm"
        include "wsound2.asm"
        include "wlik.asm"

M_Mexi  OUT (C),A ;выход
        DI
        LD SP,#FFFF
        JP 0 ;???
;-------- переменные -----
;*L+
        ds #7650-$
        nop ;CHK_4   DEFB #EE ;[**B] чек-сум4 #7650 ;???
G_DATA  EQU  #7700  ;отгрузка идёт с #7700
        include "w~local.asm" ;??? грузит w_demo.asm
        include "w~var.asm"
        ds #79C0-$
        include "w~level.asm"
        ;include "levels/w~115.a80"
        NOP
WBAR
        incbin "data/wbar.dat" ;подгружается сюда
        NOP
end

        page 0 ;*P0 ;--------------------
        ORG #C000
begin0
        include "wlib3.asm"
        include "wlib3vi.asm"
        include "wlif.asm"
        include "wintel.asm"
        include "wlic.asm"
        ds 101 ;просто так ;???
        include "wlig.asm"
        include "wlib4.asm"
        ;include "w_protec.asm" ;???
        include "wstrateg.asm"
        include "wlih.asm"
        include "wwizard.asm"
;;*L+
        ds #F4AE-$
        nop ;CHK_9   DEFB #EE ;[**B] чек-сум5 0:#F4AE
        nop ;CHK_5   DEFB #EE ;[**B] чек-сум5 0:#F4AF
        incbin "data/wscreat2.dat"
        DEFS #FFFF-$+1,#C2
;где creat25 equ #F4C0 ;creat26 equ #FA60
end0

;*P0 ;--------------------


;---------формат данных героя (HUMAN,KUNGE,SLAVE)---
;0      X (1..62,=0-труп)
;1      Y (1..62,=0-пусто)
;2      Hапр (0..7)
;3      Фаза (=0 - целиком в квадрате)
;          или (%1ibttttt, где i-удар b-назад ttttt-задержка)
;          или (%10000xxx, где ххх-ожидание свободного прохода)
;          или (тоже, время нахождения в шахте/на базе)
;4      Тип (0..26)
;5      Здоровье
;6      Мана / Время магич. жизни
;7      Длина шага при перемещении (1..4)
;8      Тип движения:
;               0-стоп
;               #80-free move
;               %0len-обход по часовой
;               %1len-против (где len-длина обхода)
;       На стоянке: #FF/xx - посмотрел/не посмотрел вокруг
;9      Тип действий:
;        (cм.ниже)

;10     Цель X
;11     Цель Y
;12     N врага (если ix+9 == 4) (%txxxxxxx, где t=0/1=герой/дом)
;       Для лесоруба - к_во оставшихся ударов
;13     -
;14     Xwood ;для крестьян - коорд, куда идти за лесом/золотом
;15     Ywood ;
;Формат массива XY
;0-1    Xpos (0..1024) (левая)
;2-3    Ypos (0..1024) (нижняя)
;-------------------------------
;Примеч: Невидимый герой: (IX+1)=%1xxxxxxx, (IY+1)=%1xxxxxxx

;(ix+9) -тип действий
;        0-ничего
;        1-стоять насмерть
;        2-перемещение
;        3-атаковать позицию
;        4-атаковать врага (для крестьян - убегать)
;        5-идти на базу
;        6-идти за лесом
;        7-идти за золотом
;        8-идти на ремонт/строительство
;        9-?

;        10-родить скорпиона
;        11-огненный дождь
;        12-родить стеногрыза
;        13-родить паука
;        14-наслать смерч
;        15-родить демона

;        16-дать здоровье
;        17-дальнее зрение
;        18-огненный пояс
;        19-поднять скелетов
;        20-чёрное зрение
;        21-хрустальная сфера
;        22-находиться на строительстве
;        23-находиться в шахте
;        24-находиться на базе
;        25-рубить лес
;------------------------------------
;---------формат данных трупа ---
;0      Х=0
;1      если 0-труп исчез
;2      -
;3      Время гниения текущ фазы (1..хх)
;4      Вид трупа (0-16)
;(10)   Х коорд. трупа
;(11)   Y
;Формат массива XY - тот же
;-------------------------------


;Формат данных здания
;-------------------------------
;0      X  (0-нет)
;1      Y
;2      тип
;3      жизн сила
;4      тип пр-ва (255-нет,253/254-строится)    ;4 (для шахты)
;5      степень готовности                      ;-деньги/100
;6      начальная жизн сила /2
;7      Для строящегося здания:
;         255-стр_во не начато/N-стр_во ведёт герой N
;-------------------------------
;тип: 0-main,1-креп,2-лесоп,3-церкв,4-кузня,5-конюш,6-башн,7-дворец,8-хата
;кунги:10-18, 255-шахта


;Формат снаряда/взрыва/заклинания (12байт)
;-------------------------------
;0-1    * * -   Xpos \ пиксельные коорд
;2-3    * * -   Ypos /
;4      * * *   тип/фаза (0-нет)
;5      * - *   Xtar \ коорд. цели      Ntar \ номер цели
;6      * - -   Ytar / (для катап)  OR  -    / (стрелы,заклинания)
;7      * - -   автор выстрела
;8      * - -   напр. полёта (0-7)
;9      * * *   time (время полёта/действия/фазы)
;10     * ? ?   dX \смещение при перемещении
;11     * ? ?   dY /
;---------------------------------
; Типы (iy+4):
;1      наши стрелы
;2      стрелы врага
;3      огонь волшебников
;4      взрыв огня волшебников (фаза iy+9)
;5      -
;6      снаряд катапульты
;7      снаряд стеногрыза
;8      снаряд огненного дождя
;9      колдовские звёздочки
;10     взрыв снаряда катапульты (фаза iy+9)
;11     взрыв здания
;12     заклинание "смерч"
;-------------------------------(iy+0,1,2,3 - от объекта N)
;13     заклинание "хрустальная сфера"
;14     заклинание "огненный пояс"
;15     -
;--------------------------------(дым пожарищ)
;16     дым (низ,50%)
;17     дым (низ,25%)
;18     дым (верх)

;*L+
        page 7 ;--------SCR,...-----
        ORG #C000
begin7
        incbin "barkov/w_world.scr"
;	 ORG #DB00
        nop ;CHK_6	 DEFB #EE; [**B] чек-сум6 7:#DB00
WBUTT
        incbin "data/whumbutt.dat" ;0(*)
        ;incbin "data/worcbutt.dat" ;1
WNAMES
        incbin "data/wnames.dat"
        include "wmenu2.asm"
end7

        page 3 ;--------Кунги+эффекты-------
	ORG #C000
begin3
        incbin "data/wsorc.dat"

SOU0	;удар меча
	DEFW 27
	DEFB 12,#FF
	DEFW 25
	DEFB 15,10
	DEFW 15
	DEFB 15,16
	DEFW 15
	DEFB 15,20
	DEFW 14
	DEFB 14,23
	DEFW 14
	DEFB 11,28
	DEFW 14
	DEFB 7,30
	DEFB #FF

SOU1	;удар топора, cкелета, стеногрыза, полоза
	DEFW 1540
	DEFB 13,1
	DEFB #FF

SOU7	;укус паука, скорпиона
	DEFW 1340
	DEFB 14,#FF
	DEFB #FF

SOU5	;колдовство
	DEFW 40
	DEFB 14,#FF
	DEFW 80
	DEFB 14,#FF
	DEFW 50
	DEFB 14,#FF
	DEFW 100
	DEFB 13,#FF
	DEFW 56
	DEFB 14,#FF
	DEFW 110
	DEFB 14,#FF
	DEFW 60
	DEFB 14,#FF
	DEFW 120
	DEFB 13,#FF
	DEFW 70
	DEFB 14,#FF
	DEFW 140
	DEFB 14,#FF
	DEFW 80
	DEFB 14,#FF
	DEFW 150
	DEFB 13,#FF
	DEFW 300
	DEFB 11,#FF
	DEFB #FF

SOU6	;волш/свящ стреляют
	DEFW 540
	DEFB 11,4
	DEFW 354
	DEFB 13,4
	DEFW 568
	DEFB 10,#FF
	DEFB #FF

SOU2	;взрыв
	DEFW 1000
	DEFB 10,27
	DEFW 1200
	DEFB 14,24
	DEFW 1450
	DEFB 15,18
	DEFW 1650
	DEFB 15,15
	DEFW 1700
	DEFB 15,11
	DEFW 1800
	DEFB 15,16
	DEFW 1950
	DEFB 15,20
	DEFW 2050
	DEFB 15,26
	DEFW 2100
	DEFB 15,22
	DEFW 2200
	DEFB 15,21
	DEFW 2250
	DEFB 15,29
	;
	DEFW 2300
	DEFB 15,23
	DEFW 2350
	DEFB 15,22
	DEFW 2400
	DEFB 15,17
	DEFW 2450
	DEFB 15,14
	DEFW 2500
	DEFB 15,10
	DEFW 2550
	DEFB 15,06
	DEFW 2600
	DEFB 15,07
	DEFW 2650
	DEFB 14,12
	DEFW 2700
	DEFB 14,18
	DEFW 2750
	DEFB 14,22
	DEFW 2800
	DEFB 14,27
	;
SOU8	DEFW 2850 ;малый взр
	DEFB 13,31
	DEFW 2900
	DEFB 13,30
	DEFW 2950
	DEFB 13,27
	DEFW 3100
	DEFB 12,26
	DEFW 3200
	DEFB 12,22
	DEFW 3300
	DEFB 12,17
	DEFW 3400
	DEFB 11,12
	DEFW 3500
	DEFB 11,07
	DEFW 3600
	DEFB 10,09
	DEFW 3750
	DEFB 10,16
	DEFW 3900
	DEFB 08,21
	DEFB #FF
end3

        page 4 ;--------Люди-------
	ORG #C000
begin4
        incbin "data/wshum.dat"
;вспомогательн. подпрограмы
        nop;CHK_8	 DEFB #EE; [**B] чек-сум7 4:#FF00
        include "wmisc_4.asm"
end4

        page 6 ;---Магич.создания--
	ORG #C000
begin6
        include "wmap.asm" ;первый!
	DEFS #C400-$ ;c #C300 - invTAB
WSCREA
        incbin "data/wscreat1.dat"
WMISC3	EQU WSCREA+8608   ;доп.спр3Х3
;вспомогательн. подпрограмы
        include "wmisc_6.asm"
end6

        page 1 ;---Cпрайты ландшафта--
	ORG #C000
begin1
WMISC2			;доп.спр2Х2
        incbin "data/wmisc.dat"
WMISC4	EQU WMISC2+1792 ;доп.спр4Х4
WMISC1	EQU WMISC2+3328 ;доп.спр1Х1
        include "wmisc_1.asm" ;доп п/п
;селект-рамки----
fr2x2h	DEFW #FFFF,#80FF,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80FF,#FFFF
	DEFW #FFFF,#01FF,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#01FF,#FFFF
fr3x3h	DEFW #FFFF,#80FF,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80FF,#FFFF
	DEFW #FFFF,#00FF,0,0,0,0,0,0
	DEFW 0,0,0,0,0,0,0,0
	DEFW 0,0,0,0,0,0,#00FF,#FFFF
	DEFW #FFFF,#01FF,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#01FF,#FFFF
	ds #D000-$
LAND			;ландшафт
shadwA	EQU	49*32+LAND
SHADOW	EQU	383*32+LAND
        incbin "data/w2spr.dat" ;1(*)
;*B ..\DATA\w2SPR.DAT ;2
;*B ..\DATA\w3SPR.DAT ;3
;*B ..\DATA\w4SPR.DAT ;4
end1
;*P0 ;-------------------


	display "begin=",begin
	display "end=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
        page 0
	savebin "br.com",begin,end-begin
        page 0
	savebin "br0.dat",begin0,end0-begin0
        page 1
	savebin "br1.dat",begin1,end1-begin1
        page 3
	savebin "br3.dat",begin3,end3-begin3
        page 4
	savebin "br4.dat",begin4,end4-begin4
        page 6
	savebin "br6.dat",begin6,end6-begin6
        page 7
	savebin "br7.dat",begin7,end7-begin7
	
	;LABELSLIST "..\us\user.l"
