;процедуры для рисования оформления, верхнего уровня (не зависят от типа экрана)

;печать панельки энергии и ветра + названия команд
DrawEnergyPanel
        call ClearEnergyPanel
       SCRADDR RAMKAX,4
        LD HL,_;#4401
        CALL ENRAMKA
       SCRADDR RAMKAX+16,4
        LD HL,_;#4411
        CALL ENRAMKA
       SCRADDR RAMKAX,6
        LD HL,_;#4601
        ld c,9*3      ;color3 (red)
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR RAMKAX,6+7
        LD HL,_
        ld c,9*1+0xc0 ;color9 (yellow)
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR RAMKAX+16,6
        LD HL,_;#4611
        ld c,9*2+0xc0 ;color10 (green)
        CALL ENFAKE ;рисуем полную энергию у команды
       SCRADDR RAMKAX+16,6+7
        LD HL,_
        ld c,9*6+0xc0 ;color14 (cyan)
        CALL ENFAKE ;рисуем полную энергию у команды
        LD HL,CUTEAMS
       SCRADDR RAMKAX+1,1
        LD DE,_;#4102
        CALL PRTEAM
       SCRADDR RAMKAX+1,16
        LD DE,_;#4042
        CALL PRTEAM
       SCRADDR RAMKAX+29-6,1
        LD DE,_;#411E
        CALL PRTEAMRIGHT
       SCRADDR RAMKAX+29-6,16
        LD DE,_;#405E
        CALL PRTEAMRIGHT

       SCRADDR RAMKAX-1,0
        LD HL,_;#4000
        CALL PRSTAR
       SCRADDR RAMKAX+30,0
        LD HL,_;#401F
        CALL PRSTAR
       SCRADDR RAMKAX-1,15
        LD HL,_;#4720
        CALL PRSTAR
       SCRADDR RAMKAX+30,15
        LD HL,_;#473F
        jp PRSTAR
        
PRTEAM
        PUSH HL
        call PRTEAM_FindLen
        EX (SP),HL ;hl=teamname, (sp)=nextteamname
;b=teamname len
PRTEAM0 LD A,(HL)
        INC HL
        CALL PR64
        DJNZ PRTEAM0
        POP HL
        RET 

PRTEAMRIGHT
        PUSH HL
        call PRTEAM_FindLen
        EX (SP),HL ;hl=teamname, (sp)=nextteamname
        ld a,12
        SUB B ;name len
        RRA
       if !ATM
        RL C
        SLA C ;x phase
       endif
        add a,e
        LD E,A
        jr nc,$+3
        inc d
        jr PRTEAM0

PRTEAM_FindLen
        LD B,TEAMLEN
        ld a,l
        add a,b
        ld l,a
        jr nc,$+3
        inc h
        PUSH HL
        LD A,' '
PRTEAMF DEC HL
        CP (HL)
        JR NZ,PRTEAME
        DJNZ PRTEAMF
        INC B ;1
PRTEAME
        POP HL
;b=teamname len
       if !ATM
        ld c,0
       endif
        ret

;печать полосок энергии и ветра
DrawEnergy
        ld a,(wind) ;-46..46 ;TODO на ATM ширина 58 (пересчитать из 128?)
        add a,windLAwid;47
        ld c,a ;1..46 left, 47 no, 48..93 right
       ;ld c,1;46
        LD HL,windLA
        LD b,windLAwid;47
        LD E,windLAbit;32
PRnrg0
        ;LD A,B
        ;DEC A
        ;CP C
        ;ccf
        ;CALL nrgPLOT
        ;CALL nrgGOLEFT
        LD A,B
        ADD A,C
        CP windLAwid+1
        CALL nrgPLOT
        ;CALL nrgGORIGHT
        DJNZ PRnrg0
windP
        LD HL,windRA
        LD b,windLAwid;47
        LD E,windRAbit;4
PRnrg1
        LD A,B
        ADD A,C
        ;CP windLAwid*2+1;95
        ;ccf
        jr c,$+4
        add a,-(windLAwid*2+1)
        CALL nrgPLOT
        ;CALL nrgGORIGHT
        DJNZ PRnrg1
PRnrgE
        ld a,(powr) ;0..118 ;TODO на АТМ ширина 148 (пересчитать из 256?)
        ;cpl
        ;add a,windEAwid;119
        ld c,a
        LD HL,windEA
        LD B,windEAwid;-1;#76
        LD E,windEAbit;4
PRnrg2
        ;LD A,c
        ;CP b
         ld a,b
         add a,c
         jr c,$+4
         add a,-windEAwid
        CALL nrgPLOT
        ;CALL nrgGORIGHT
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
