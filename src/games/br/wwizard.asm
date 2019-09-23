;------------------------------
;--интеллект магов (from ZZ0)--

AI10    ;священник-охранник
        LD A,R
        AND %1111
        JR NZ,_aiWId
        LD A,(IX+6)
        CP MANA/4
        JR C,_aiWId
        JP itHLTH

AI11    ;волшебник-охранник
        LD A,(IX+6)
        CP MANA
        JR C,_aiWId
        LD A,(kmaxW)
        CP 3
        JR C,ai13_1
        JR ai13_3

_aiWId  LD L,(IX+14)
        LD H,(IX+15)
        CALL IXt_HL
        JP IX_93

_aiWIZ  ;если неудача применения магии
        JP AI03_

AI13    ;/священник-атакующий (закл.2->1)
        ;
AI12    ;священник-атакующий (закл.1)
        LD A,(IX+6)
        CP MANA/4
        JR C,_aiWIZ
        ;здоровье/оживл
        CALL itHLTH
        RET NC
        JR _aiWIZ

AI14    ;священник-атакующий (закл.3)
        LD A,(kmaxC)
        CP 3
        JR C,AI12
        ;огн.кольцо/хр.шар
        LD A,(IX+6)
        CP MANA
        JR C,_aiWIZ
        CALL itDFND
        RET NC
        JR _aiWIZ

AI15    ;волшебник-атакующий (закл 1)
        LD A,(IX+6)
        CP MANA/4
        JR C,_aiWIZ
ai13_1  LD A,1
        JR itCREA


AI16    ;волшебник-атакующий (закл 2)
        LD A,(kmaxW)
        CP 2
        JR C,AI15
        LD A,(IX+6)
        CP MANA/2
        JR C,_aiWIZ
        CALL itRAIN
        RET NC
        JR _aiWIZ


AI17    ;волшебник-атакующий (закл 3)
        LD A,(kmaxW)
        CP 3
        JR C,AI16
        LD A,(IX+6)
        CP MANA
        JR C,_aiWIZ
ai13_3  LD A,3
        JR itCREA


;-------применяемые заклинания (NC/C-применили/нет)----

itCREA  ;создания (A=1/3 - насекомые/монстры)
        LD C,A
        LD A,(IX+4)
        CP 6
        LD A,9
        JR Z,it111
        LD A,12
it111   ADD A,C
        LD (IX+9),A
        RET ;nc

itHLTH  ;здоровье/оживл трупов
        CALL HL_IX0
        LD A,(IX+4)
        CP 5
        JR NZ,itTROO
        EXX
        PUSH IX
        CALL loopKb ;w/o B
        LD C,#30
it102   LD A,(IX+0)
        OR A
        JR Z,it103
        LD A,(IX+4)
        LD HL,HEALTH
        CALL WT
        LD A,L
        CP (IX+5) ;требуется лечение?
        JR Z,it103
        EXX
        CALL DIST
        EXX
        CP 16; дистанция
        JR NC,it103
        LD A,(HER_N)
        CP C ;сам на ся?
        JR Z,it103
        CALL HL_IX0
	POP IX
	LD A,16
        JR itACT ;нашли больного
it103   ADD IX,DE
        INC C
        LD A,C
        CP #60
        JR C,it102
        JR itexC
        ;
itTROO  ;оживл трупов
        PUSH IX
        CALL loopHb
        LD C,0
it107   LD A,(IX+0)
        OR A
        JR NZ,it106
        LD A,(IX+1) ;труп?
        OR A
        JR Z,it106
        LD A,(IX+4) ;обычный труп?
        CP 8
        JR NC,it106
        CALL DIST
        CP 20 ;дистанция
        JR NC,it106
        CALL HL_IXt ;коорд трупа
        POP IX ;иди оживляй
        LD A,19
        JR itACT
it106   ADD IX,DE
        INC B
        LD A,B
        CP #60
        JR C,it107
itexC   POP IX
        SCF
        RET ;c-закл не выполн

itACT   ;действуй, маг! A-закл, HL-поз, {C-Nцели}
        LD (IX+9),A
        LD (IX+12),C
        LD (IX+8),#80
        XOR A;nc
        JP IXt_HL

itDFND  ;защитное кольцо/шар
        PUSH IX
        CALL loopKb
        LD C,#30
it402   LD A,(IX+0)
        OR A
        JR Z,it403
        LD A,(IX+9)
        CP 4
        JR NZ,it403
        CALL HL_IX0
        POP IX
        LD A,(IX+4)
        CP 5
        LD A,18
        JR Z,itACT
        LD A,21
        JR itACT ;нашли атакующего
it403   ADD IX,DE
        INC C
        LD A,C
        CP #60
        JR C,it402
        JR itexC

itRAIN  ;огн.дождь/смерч
        PUSH IX
        LD A,(TIC) ;man/blt
        RRCA
        JR C,itRAh
        LD A,R
        AND #1F
        ADD A,8
        CALL B_IX
        CALL HL_IX0
        POP IX
        JR itRA1
itRAh   LD A,R
        AND #3F
        CP 48
        JP NC,itRAh
        CALL N_IX
        CALL HL_IX0
        LD A,(IX+9)
        CP 1
        POP IX
        RET C ;цель не стои'т
itRA1   LD A,L
        CP 1
        RET C ;не нашёл цель
        LD A,(IX+4)
        CP 6
        LD A,11
        JR Z,itACT
        LD A,14
        JP itACT

