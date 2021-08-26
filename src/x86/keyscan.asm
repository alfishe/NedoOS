keybfsz=4

ssSpc=1;32
csEnt=2;13
ssEnt=3;13
;CS+3=4
;CS+4=5
;CS+2=6
;CS+1=7
;CS+5=8
;CS+8=9
;CS+6=10
;CS+7=11
;CS+0=12
;Ent=13
;SS+CS=14
;CS+9=15
csSpc=16;32
;Ext+key=CS+key

KEYB
;для autosav и моргания ovr
       ;LD HL,(23672)
       ;INC HL
       ;LD (23672),HL
KBoff
        NOP ;/ret
;сканировать клавиатуру
        LD HL,OLDSCAN
        LD BC,#FEFE
KEYBSC  LD D,(HL)
        IN A,(C)
        LD (HL),A
        INC HL
        LD (HL),D ;старый скан
        INC HL
        RLC B
        jr C,KEYBSC

;время CS и SS
tss=$+1
tcs=$+2
        LD BC,0
;если нажат CS+SS, то OK (у CS код 14)
;если нажат только CS, то снимаем его из матрицы
;SS снимаем с матрицы всегда
        XOR A
         LD HL,OLDSCAN+14
        BIT 1,(HL) ;ss
        SET 1,(HL) ;снимаем ss
        jr NZ,freess ;ss отжат
        INC C
        jr NZ,okss ;max=255
        DEC C
        JR okss
freess  LD C,A ;=0
okss
         LD HL,OLDSCAN
        BIT 0,(HL) ;cs
        jr NZ,freecs ;cs отжат
       INC C
       DEC C
       jr NZ,$+3 ;ss нажат => EXT
        INC (HL) ;снимаем cs, когда нет ss
        INC B
        jr NZ,okcs ;max=255
        DJNZ okcs ;DEC B:JR всегда
freecs  LD B,A ;=0
okcs
        LD (tss),BC

;ВСЕ события пишем в буфер (чтобы не терять одновременные)
        LD DE,#00D8
        LD C,32
KEYBX   LD HL,OLDSCAN+15
        RRC C
        LD B,8
KEYBX1  LD A,(HL) ;было отжато=1
       ;CPL                   ;0
        DEC HL
       ;OR (HL) ;нажато=0
       XOR (HL)
        AND C
       ;JNZ KEYBX1N
       jr Z,KEYBX1N
        LD A,(HL)
        AND C ;Z=нажатие
       PUSH BC
       PUSH HL
       LD BC,(tss)
;E=#D8..#FF
;пребразовать скан-код E в код клавиши D
        LD D,0
       jr Z,KBpress ;Z=нажатие
        LD HL,TCURKEYS-#D8
        ADD HL,DE
        LD D,(HL) ;под каким кодом была нажата эта клавиша
        SET 7,D ;признак отжатия в коде клавиши
        XOR A
        LD (KBcode),A ;выкл. автоповтор
        JR KBpressQ
KBpress
        LD HL,TPLAINKEYS-#D8
        XOR A
        CP C
        jr Z,$+5
        LD HL,TSSKEYS-#D8
        CP B
        jr Z,$+5
        LD HL,TCSKEYS-#D8 ;ex#=cs#
        ADD HL,DE
        LD A,(HL) ;код клавиши
        LD HL,TCURKEYS-#D8
        ADD HL,DE
        LD (HL),A ;для отжатия - под каким кодом нажата клавиша
        LD D,A
        LD (KBcode),A
        LD (KBbc),BC
        LD A,15
        LD (KBtime),A
KBpressQ
        CALL PUTKEY
KBpressQQ
       POP HL
       POP BC
KEYBX1N
        INC E
        DEC HL
        DJNZ KEYBX1
        jr NZ,KEYBX

       ;INC D
       ;DEC D
       ;RET NZ ;что-то изменилось - нет автоповтора

         LD HL,OLDSCAN
        LD A,-1
        LD B,8
        AND (HL) ;"что-то нажато" (SS снят с матрицы, "CS"=EXT)
        INC HL,HL
        DJNZ $-3
        CPL 
        AND 31
        RET Z ;ничего не нажато
;нажата старая(?) кнопка
KBtime=$+1
        LD A,15
        DEC A
        jr Z,YEpKEYauto ;автоповтор (старые D,B,C)
      ;автоповтору не время
        LD (KBtime),A ;постепенно убавляем до 1
                      ;и после 1 больше не попадем на убавление
                      ;а сразу на повтор
        RET 
YEpKEYauto
KBbc=$+1
        LD BC,0
KBcode=$+1
        LD D,0
PUTKEY
GKEYADR=$+1
        LD HL,KEYBUFF ;адрес конца списка
        LD A,D
       OR A
       RET Z ;нет события
        CP 32
        jr NC,YEpNUPR
;не складировать автоповтор cs3, cs4, cs9, cs0!
;вообще управляющие клавиши
        DEC HL,HL,HL
        CP (HL)
        RET Z ;еще старую копию не забрали!
        INC HL,HL,HL
YEpNUPR
;есть ли место в буфере?
        LD A,L
        CP KEYBUFFEND&0xff
        RET Z ;нет места!
        LD (HL),D
        INC HL
        LD (HL),C
        INC HL
        LD (HL),B
        INC HL
        LD (HL),0 ;маркер конца списка
        LD (GKEYADR),HL
       ;IFN sobyt
       ; LD HL,(SOBYTS)
       ; INC HL
       ; LD (SOBYTS),HL
       ;ENDIF 
       ;SET 5,(IY+1)
      ;ld a,1
      ;ld (keyreceived),a
        RET 

keyscan_getkey
;возвращает A,B<->C,ничего не портит
;Z=no keys
        PUSH HL
        LD HL,KBoff
        LD (HL),201 ;запрет опроса клавы
     ;если запрет на изменение буфера, то можно потерять событие ;TODO циклическую очередь
        LD HL,KEYBUFF
        LD A,(HL)
       OR A
       jr Z,GETKpop ;no keys in buff
        LD A,(HL)
        PUSH DE
        LD D,H
        ld E,L
        INC HL
        LD B,(HL);в обр.порядке для совместимости
        INC HL
        LD C,(HL)
        INC HL
        PUSH BC
        LD BC,+(keybfsz-1)*3
        LDIR 
        ex de,hl 
       LD (HL),B
        LD HL,(GKEYADR)
        DEC HL,HL,HL
        LD (GKEYADR),HL
       ; PUSH AF
       ;LD A,L
       ;CP KEYBUFF
       ;jr Z,$+6
       ;SET 5,(IY+1)
       ; POP AF
      ;CALL RECAP
       INC B ;NZ
        POP BC
        POP DE
GETKpop
        LD HL,KBoff
        LD (HL),0
        POP HL
       ;LD (23560),A
        RET 

TCURKEYS
;таблица для отжатия - кем является каждая клетка матрицы
                      ;т.е. под каким кодом она нажата
        DS 40

TPLAINKEYS
;a-la #205
;#205: "BHY6..." (39 байт, SS=#E)
        db 0x30,0x23,0x15,7,6,0x14,0x22,0x2f ;DB "BHY65TGV"
        db 0x31,0x24,0x16,8,5,0x13,0x21,0x2e ;DB "NJU74RFC"
        db 0x32,0x25,0x17,9,4,0x12,0x20,0x2d ;DB "MKI83EDX"
        db 0x00,0x26,0x18,10,2,0x11,0x1f,0x2c ;DB 0,"LO91WSZ"
        db 0x39,0x1c,0x19,0x0b,2,0x10,0x1e ;DB 32,13,"P01QA",0
TCSKEYS
;a-la #205
        DB "bhy",0x50,0x4b,"tgv"
        DB "nju",0x48,5,"rfc"
        DB "mki",0x4d,4,"edx"
        DB 0,"lo",15,6,"wsz"
        DB csSpc,csEnt,"p",12,7,"qa",14
TSSKEYS
;a-la #205
        DB "*^[&%>}/"
        DB ",-]'$<{?"
        DB ".+",ssI,"(#",ssE,'\\',"`"
        DB 0,"=;)@",ssW,"|:"
        DB ssSpc,ssEnt,34,"_!",ssQ,"~"
       ;CS+SS ищется в TCSKEYS

;за 3 байта до KEYBUFF должен быть симв>=32
KEYBUFF
        DS 3*keybfsz ;key,tss,tcs
KEYBUFFEND
        DB 0 ;конец самого буфера (после кнопки кладут 0)
OLDSCAN
        DS 16,-1;от CS.. до Spc..
               ;новая,старая,новая,... 

