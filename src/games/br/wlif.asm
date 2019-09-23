;---ОБРАБОТКА НАЖАТИЯ FIRE

ACTION  ;реакция на управл ***********
        CALL FIRBUT
        CALL capSEL
        CALL SELECT
        LD A,(T_FIRE)
        DEC A
        RET NZ
ACT_F   LD A,(BX)
        CP 24
        RET NC
        LD A,(SEL_T)
        OR A
        RET Z
        CP 7
        RET Z
        JP NC,acHOM
        LD A,(fixTAR) ;цель зафиксирована?
        OR A
        JR Z,acNfx
        LD HL,G_MAP1
        LD A,(TIC)
        RRA
        JR C,acFx
        LD HL,G_FIX1
acFx    LD (G_IMG),HL
        RET
acNfx   LD HL,G_MAP1 ;сменить курсор
        LD (G_IMG),HL
        LD A,(ext_M)
        CP 1
        LD A,(F_FUNC)
        JP NC,acPEON
        ;для людей/группы
        CP #FF
        RET NC
        OR A
        JR NZ,acM1
        ;кнопка 0-я
acMOV   LD C,2; move
act00   CALL PXcorr
        EX DE,HL
act0    LD HL,SEL_T
        LD B,(HL)
        INC HL
act1    LD A,(HL)
        INC HL
        PUSH HL
        CALL N_IX
        LD (IX+10),E
        LD (IX+11),D
        LD (IX+9),C
        LD (IX+8),#80
        POP HL
        DJNZ act1
        RET
acM1    LD HL,(PX) ;кнопка 1я
        DEC A
        JP NZ,acM2
        ;кнопка 1-я
        LD A,(BUT_N+1)
        CP 18
        JR Z,acM1_1
        ;атака
        CALL HLcorr
        PUSH HL
        CALL GMAP2
        POP DE
        LD A,(HL)
        SUB #38
act03   LD C,3 ;на позицию
        JR C,act00
        RES 4,H
        BIT 7,(HL)
        SET 4,H
        JR NZ,act00 ;на тёмное поле ->вых
        CP #48
        JR NC,act12
        SET 7,A ;атака на здание
        JR act10
act12   SUB #48 ;атака на человека
        CP #30
        JR C,act03 ;не атакуй своего
act10   LD C,A
        LD HL,SEL_T
        LD B,(HL)
        INC HL
act11   LD A,(HL)
        INC HL
        CP C ;сам себя?
        JR Z,act17
        PUSH HL
        CALL N_IX
        LD (IX+10),E
        LD (IX+11),D
        LD (IX+12),C
        LD (IX+9),4 ;атаковать цель
        LD (IX+8),#80
        POP HL
act17   DJNZ act11
        LD L,C
        LD H,6 ;время мигания кв. цели
        LD (sel_en),HL
        LD A,H
        LD (fixTAR),A ;цель зафиксрована
        RET

acM1_1  ;идти в лес/шахту
        CALL HLcorr
        CALL GMAP
        LD A,(HL)
        AND #7F
        CP 78
        LD C,6
        JR C,acM1_a
        INC C ;7
acM1_a  CALL act00
        LD (IX+14),E
        LD (IX+15),D
        RET

acM2    DEC A
        JR NZ,acM3
        ;кнопка 2-я
        LD A,(BUT_N+2)
        CP 19
        JP Z,acREM
acM3    LD A,(BUT_N+3)
        CP 71
        JR NZ,acM3_
        ;свободный выcтрел из катапульты
        LD C,27
        PUSH HL
        CALL GMAP
        POP DE
        LD A,(HL)
        OR A
        RET Z ;нельзя целить на бордюр
        AND #80
        RET NZ ;нельзя целить в тёмное поле
        JP act0
        ;колдовство
acM3_   LD A,(BUT_H)
        CP 66
        JR C,acM301
        ;у кунгов
        LD C,14
        JP NZ,acMANA
        LD A,(F_FUNC)
        ADD A,17
        LD C,A
        CP 21
        JP NZ,act00
        JR act30
acM301  ;у людей
        CP 57
        LD C,11
        JP Z,acMANA
        LD A,(F_FUNC)
        ADD A,14
        LD C,A
        CP 17
        JP Z,act00
        JR act30
        ;
acMANA  ;пров mana
        LD A,(SEL_N)
        CALL N_IX
        LD A,(IX+6)
        CP MANA/2
        JP NC,act00
        JP C,pb07

act30   ;заклинание(С) на цель
        LD A,(SEL_T+1)
        LD B,A
        CALL N_IX
        LD HL,(PX)
        CALL IXt_HL
        CALL IX_98
        CALL GMAP2
        LD A,(HL)
        SUB #80 ;не человек?
        RET C
        CP B ;сам себя?
        RET Z;
        LD (IX+12),A
        LD (IX+9),C ;атаковать цель
        LD (IX+8),#80
        LD L,A
        LD H,1 ;время мигания кв. цели
        LD (sel_en),HL
        RET

acREM   ;ремонт/стр-во (C=8)
        CALL HLcorr
        CALL GMAP2
        LD A,(HL)
        SUB #38
        JP C,acMOV
        CP 72
        JP NC,acMOV
        LD C,8
        JP act00


nMN_WD  ;дать сообщ, если нехв mn/wd
        ADD A,44
        JP dirTX

acHOM   LD A,(F_FUNC)
        CP #FF
        RET NC
        CALL mayBLT
        RET NZ
        LD A,(F_FUNC)
        CALL GETmw
        CALL dMN_WD
        JR C,nMN_WD
        LD HL,(PX)
        CALL GMAP
        LD A,(F_FUNC)
        OR A
        JR NZ,acH1
        ;дорожка
        LD A,(MASTER)
        ADD A,7
        LD (HL),A
        RET
        ;
acH1    ;заборчик
        LD (HL),66
        CALL putWAL
        DEC L
        CALL putWAL
        INC L
        INC L
        CALL putWAL
        LD DE,-65
        ADD HL,DE
        CALL putWAL
        LD DE,128
        ADD HL,DE
putWAL  ;поставить стенку, учтя вокруг
        LD A,(HL)
        AND #7F
        CP 64
        RET C
        CP 78
        RET NC
        CP 71
        LD (HL),64
        JR C,pUW1
        LD (HL),71
pUW1    LD C,0
        PUSH HL
        DEC L
        CALL pUWsub
        INC L
        INC L
        CALL pUWsub
        LD DE,-65
        ADD HL,DE
        CALL pUWsub
        LD DE,128
        ADD HL,DE
        CALL pUWsub
        LD HL,pUWtab
        LD A,C
        CALL BA
        LD C,A
        POP HL
        PUSH HL
        ADD A,(HL)
        LD (HL),A
        SET 4,H
        LD (HL),2
        RES 4,H
        LD E,64
        ADD HL,DE
        LD A,(HL)
        AND #7F
        CP 51
        JR NZ,pUW3
        LD A,C
        CP 4
        JR Z,pUW2
        LD (HL),1
        JR pUW2
pUW3    CP 64
        JR C,pUW5
        CP 78
        JR C,pUW2
pUW5    LD A,C
        CP 4
        JR NZ,pUW2
        ;SET 4,H
        LD A,(HL)
        OR A
        JR Z,pUW11
        CP 7
        JR C,pUW4
        CP 17
        JR C,pUW11
        CP 26
        JR C,pUW4
pUW11   POP HL
        INC (HL)
        RET
pUW4    LD (HL),0
        RES 4,H
        LD (HL),51
pUW2    POP HL
        RET
pUWtab  DEFB 2,4,4,4,2,0,5,0,2,3,6,3,2,1,2,1
pUWsub  SLA C
        LD A,(HL)
        AND #7F
        CP 64
        RET C
        CP 78
        RET NC
        INC C
        RET


acPEON  ;строительство для крестьян
        JR NZ,acPex2
        ;меню 1
        CP #FF
        RET NC
        CALL mayBLT
        RET NZ
        LD A,(F_FUNC)
        OR A
        JR NZ,acP2
        LD A,8
        JR acP2
acPex2  CP #FF
        RET NC
        CALL mayBLT
        RET NZ
        LD A,(F_FUNC)
        ADD A,3
acP2    LD C,A
        PUSH BC
        LD A,(F_FUNC)
        CALL GETmw
        CALL dMN_WD
        POP BC
        JP C,nMN_WD
        LD A,(MASTER)
        OR A
        JR Z,acP3
        LD A,10
acP3    ADD A,C
        LD C,A
        LD HL,(PX)
        INC L
        INC H
        PUSH HL
        XOR A
        CALL BLTNEW
        CALL onsee2
        POP DE
        LD C,8
        CALL act0
        EX DE,HL
        CALL EVENTr
        CALL oneSE_
        RET ;!

PXcorr  ;коррекция PX,если указывает на край здания (вых: HL)
        LD HL,(PX)
HLcorr  ;то же для HL
        PUSH HL
        CALL GMAP
        LD A,(HL)
        AND #7F
        SUB 120
        POP HL
        RET C
        PUSH HL
        LD HL,PXcrT
        CALL WT
        POP DE
        LD A,L
        ADD A,E
        LD L,A
        LD A,H
        ADD A,D
        LD H,A
        RET

PXcrT   DEFB 1,0, 1,1, 0,1, -1,1, -1,0
        DEFB -1,-1, 0,-1, 1,-1