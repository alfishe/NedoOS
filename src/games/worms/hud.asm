;процедуры для рисования оформления, верхнего уровня (не зависят от типа экрана)

;печать панельки энергии и ветра + названия команд
DrawEnergyPanel
        call ClearEnergyPanel
       SCRADDR 1,4
        LD HL,_;#4401
        CALL ENRAMKA
       SCRADDR 17,4
        LD HL,_;#4411
        CALL ENRAMKA
       SCRADDR 1,6
        LD HL,_;#4601
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR 1,6+7
        LD HL,_
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR 17,6
        LD HL,_;#4611
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR 17,6+7
        LD HL,_
        CALL ENFAKE ;рисуем полную энергию у команды
        LD HL,CUTEAMS
       SCRADDR 2,1
        LD DE,_;#4102
        CALL PRTEAM
       SCRADDR 2,16
        LD DE,_;#4042
        CALL PRTEAM
       SCRADDR 30,1
        LD DE,_;#411E
        CALL PRTEAM
       SCRADDR 30,16
        LD DE,_;#405E
        CALL PRTEAM

       SCRADDR 0,0
        LD HL,_;#4000
        CALL PRSTAR
       SCRADDR 31,0
        LD HL,_;#401F
        CALL PRSTAR
       SCRADDR 0,15
        LD HL,_;#4720
        CALL PRSTAR
       SCRADDR 31,15
        LD HL,_;#473F
        jp PRSTAR
        
PRTEAM
        PUSH HL
        LD BC,TEAMLEN
        ADD HL,BC
        PUSH HL
        LD A,32
        LD B,C
PRTEAMF DEC HL
        CP (HL)
        JR NZ,PRTEAME
        DJNZ PRTEAMF
        INC B
PRTEAME POP HL
        EX (SP),HL
        PUSH DE
        LD C,0
        BIT 4,E
        JR Z,PRTEAM0
        LD A,E
        ADD A,A
        SUB B
        RRA 
        LD E,A
        RL C
        SLA C
PRTEAM0 LD A,(HL)
        INC HL
        CALL PR64
        DJNZ PRTEAM0

        POP DE
        POP HL
        RET 

;печать полосок энергии и ветра
DrawEnergy
        ld a,(wind) ;-46..46
        add a,47
        ld c,a ;1..46 left, 47 no, 48..93 right
        LD HL,windLA
        LD b,#2F
        LD E,windLAbit;32
PRnrg0
        LD A,B
        DEC A
        CP C
        ccf
        CALL nrgPLOT
        CALL nrgGOLEFT
        DJNZ PRnrg0
windP
        LD HL,windRA
        LD B,#2F
        LD E,windRAbit;4
PRnrg1
        LD A,B
        ADD A,C
        CP 95
        ccf
        CALL nrgPLOT
        CALL nrgGORIGHT
        DJNZ PRnrg1
PRnrgE
        ld a,(powr) ;0..118
        cpl
        add a,119
        ld c,a
        LD HL,windEA
        LD B,#76
        LD E,windEAbit;4
PRnrg2
        LD A,c
        CP b
        CALL nrgPLOT
        CALL nrgGORIGHT
        DJNZ PRnrg2
        RET 

MTIDEAD
;hl=name+12
        LD bc,13
        LD A,' ';32
FNDLF   DEC HL
        DEC C
        CP (HL)
        JR Z,FNDLF
;hl=before the last space, c=length
        LD A,C
        LD DE,MESDIE+11
        LDDR 
        EX DE,HL
        ADD A,14
        LD (HL),A
MTITLE
;hl=title to add
titlecuraddr=$+1
        LD DE,TITBUF
        
;if too many unprinted titles, overwrite the last one
       ld a,(curdrawingtitle)
       sub e
       neg ;titlecuraddr - drawingtitle
       cp 192
       jr c,MTITLE_nooverwrite
MTITLE_overwrite0
        dec e
        ld a,(de)
        cp 32
        jr nc,MTITLE_overwrite0 ;find len of pre-last message
        ;inc e
MTITLE_nooverwrite
        LD B,(HL) ;len
        INC B
MTITLEC LD A,(HL)
        LD (DE),A
        INC HL
        INC e ;!!!
        DJNZ MTITLEC
        EX DE,HL
        LD (HL),B ;0
        LD (titlecuraddr),HL
        RET 

DrawPie
DrawPieaddr=$+1
        LD HL,0
        call DrawPieHL
        LD (DrawPieaddr),HL
        ret;jp PRGA ;set old page
