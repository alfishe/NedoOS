
;FREE=0x8000 ;адрес дл€ сборки строк
ROL_TAB=0xa000 ;,0x1000 ;L0>>n (16 bit)
PAL_GLOB=0x9a00 ;,0x300 ;глобальна€ таблица цветов
PAL_LOCAL=0x9d00 ;,0x300 ;локальна€ таблица цветов

        macro GIFINITCY
        ;or a
        endm

        macro GIFGETBYTE
        rdbyte
        ;ret c
        endm

        macro GIFGETBYTE_noret
        rdbyte
        endm

        macro GIFGETWORD
        call GIF_GETWORD
        ;ret c
        endm

readgif
        ;jr $
        CALL ROL_INSTALL
        CALL GIFSEARCH
        RET C
        CALL GIF_LOGSCR ;ќбработка дескриптора лог.Ёкрана
        RET C           ;вместе с палитрой (PAL_GLOB)
;""""""""""""""""""""""P
GIF_LP0
;Ќачало цикла обработки кадра? GIF-изображени€
        GIFINITCY
        GIFGETBYTE
        CP #2C
        JP Z,GIF_IMG
        CP #21
        ;JR Z,GIF_SPEC
        ;CP #3B ;???
        ;ret z
        ret nz ;неопознанный блок, выход по ошибке

;"""""""""""""""""""""""
GIF_SPEC;—пециальный фрейм.
        GIFINITCY
        GIFGETBYTE
;       CP #FF
;       JR NZ,GIF_fail ;Ќеопознаное приложение
GIF_HELP
        GIFGETBYTE
        OR A
        JP Z,GIF_LP0
        LD B,A
GIF_HP0 
        GIFGETBYTE    ;ѕропустить HELP...
        DJNZ GIF_HP0
        JR GIF_HELP

;"""""""""""""""""""""""
GIF_IMG ;ќбработка блока изображени€.
        GIFINITCY
        GIFGETWORD
        LD (X_IMG),HL
        GIFGETWORD
        LD (Y_IMG),HL
         ;LD (Y_WORK),HL
        GIFGETWORD
        LD (DX_IMG),HL ;локальна€ ширина
         LD (pixelcounter_back),HL
         ret c
         ld b,h
         ld c,l
         add hl,hl
         add hl,bc
         ld (DX_IMGx3),hl
        GIFGETWORD
        LD (DY_IMG),HL ;локальна€ высота
        GIFGETBYTE

        LD HL,FREE
        ld de,(X_IMG) ;локальное начало строки
        add hl,de
        add hl,de
        add hl,de
        ld (linebufstart_local),hl
        LD (linebufpointer),HL

        BIT 6,A ;необходимо проверить бит 6 на предмет наличи€ чередовани€ строк
        JR Z,GIF_IMG_NORM
;здесь - „ередование строк -> не подходит. TODO поддержать чередование строк
         LD A,7
         OUT (#FE),A
         SCF 
         RET 

GIF_IMG_NORM

;for PUTCHAR:
linebufpointer=$+1
        ld de,0 ;јдрес дл€ вывода байта в FREE
pixelcounter_back=$+1
        ld bc,0
        exx

        LD HL,PAL_LOCAL
        CALL GIF_PAL
        RET C

;========================
;Ќа„ало разборки отдельного блока графики.
        CALL gifsetpgLZW
        XOR A
        LD (GETCOD0+1),A ;количество бит в наличии
        LD (GETCHR0+1),A
        LD (GIF_IMG_ENDcode),A
        ;___________
        GIFGETBYTE
        LD (LZW_SIZE),A
;"""""""""""""""""""""""
GIF_IMG0 CALL LZW_INSTALL
        CALL GETCODE
        RET C
        CALL RE_CODE
        JR NC,GIF_IMG1
        CP 1
        JR Z,GIF_IMG0
        CP 2
        JP Z,GIF_IMG_END ;код конца данных...
        SCF 
        RET 
GIF_IMG1
         LD (LZW_OLD),HL ;(јдрес) было после
        CALL PUTSTRING  ;вывод цепо„ки из таблицы цепо„ек.
        RET C
;""""""""""""""""""""""""
GIF_IMG2
;√лавный цикл распаковки.
        CALL GETCODE
        RET C
        CALL RE_CODE
        JR NC,GIF_IMG4 ;putstring без putchar
        CP 1
        JR Z,GIF_IMG0   ; од очистки
        CP 2
        JP Z,GIF_IMG_END;конец блока
;ј=#FF,код отсутствует... ўа сделаем ;)
        LD (GIF_IMG3+1),HL;«апоминаем code дл€ того,„тобы
        ;потом присвоить его зна„ение OLD-у.
        LD HL,(LZW_OLD)
        CALL PUTSTRING
        RET C
         push af
        CALL PUTCHAR
         pop af
        CALL NEW_CODE
GIF_IMG3 LD HL,0
        LD (LZW_OLD),HL
        JP GIF_IMG2
;""""""""""""""""""""""
GIF_IMG4
        LD (GIF_IMG3+1),HL
        CALL PUTSTRING
        RET C
        CALL NEW_CODE
        JR GIF_IMG3
;<><<><><><><><>>>><><><><>><>><><><><><><>
GIF_IMG_END     ;Ќайден код конца LZW-данных,
                ;необходимо с„итать след.блок,
                ;и если он=0,то все ок!.
GIF_IMG_ENDcode=$+1
        LD A,0 ;/0xff
        OR A
        ;“о Ўо надо!.
        JP NZ,GIF_LPR
        CALL GETCHAR
        RET C
        JR GIF_IMG_END ;т.е. еўе не конец блока.

GIF_LPR
        ;CALL CONVERT
        ;CALL VIEW
        JP GIF_LP0 ;следующий кадр?
;====================================================
LZW_OLD DEFW 0  ;ѕредыдуўий адрес цепо„ки символов :)
LZW_SIZE DEFB 0 ;ћинимальный размер кода LZW дл€ инициализации.
;X2_SIZE DEFW 0  ;размер в байтах по X конвертированного Ёкрана.
X_IMG   DEFW 0  ;–азмеры отдельного изображени€:
Y_IMG   DEFW 0  ;Ќачальна€ позици€ в экране
DX_IMG  DEFW 0  ;и размер этого изображени€.
DY_IMG  DEFW 0
;__________________________________________
X_Y_GIF DEFB 0  ;—оотноЎение X/Y из заголовка GIF.
;FON_COLOR DEFB 0;÷вет фона (TODO прозрачность)
;===========================
PUTCHAR
;¬ывод символа в поток (строку)...
;портит a,bc,de,hl
        exx
;linebufpointer=$+1
;        ld de,0 ;јдрес дл€ вывода байта в FREE
putchar_palH=$+1
        LD H,PAL_GLOB/256
        LD L,A
        LD A,(HL)
        LD (de),A
        INC de
        inc h
        LD A,(HL)
        LD (de),A
        INC de
        inc h
        ldi
        ;ld (linebufpointer),de
        exx
        ret pe

DX_IMGx3=$+1
        ld bc,0 ;локальна€ ширина*3
        ld hl,(linebufstart_local) ;локальное начало строки

;hl=откуда копируем строку
;bc=сколько байт копируем
        call putline
        
        CALL gifsetpgLZW

        exx
        ld bc,(DX_IMG) ;локальна€ ширина
        ;ld (pixelcounter_back),bc
linebufstart_local=$+1
        ld de,0 ;локальное начало строки
        ;ld (linebufpointer),de
        exx
        ret

;__________________________________________
NEW_CODE;добавить в таблицу цепо„ек Ёлемент, состо€ўий
        ;из ссылки на OLD, и символа из ј.
        PUSH HL
        PUSH DE
        PUSH BC
NEW_COD0 LD HL,0
        LD DE,(LZW_OLD)
        LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        LD (HL),A
        INC HL
        LD (NEW_COD0+1),HL
NEW_COD1 LD HL,0        ;ѕроверка,нужно ли увели„ивать LZW_SIZW
        INC HL
        LD (NEW_COD1+1),HL
        DEC HL

NEW_COD2
        LD DE,0 ;
        OR A
        SBC HL,DE
        LD A,H
        OR L
        JR NZ,NEW_COD5  ;—на„ала одни 111,затем 000...

        LD A,(LZW_SIZW) ;и тогда увели„ивать!
        CP #0C
        JR NC,$+6
        INC A
        LD (LZW_SIZW),A
        DEC A
        ADD A,A
        ADD A,NEW_COD3&0xff
        LD L,A
        ADC A,NEW_COD3/256
        SUB L
        LD H,A
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD (NEW_COD2+1),DE
        LD A,E
        LD (GETCOD20+1),A
        LD A,D
        LD (GETCOD21+1),A
NEW_COD5
        OR A
        POP BC
        POP DE
        POP HL
        RET 
NEW_COD3
        DEFW #0001,#0003,#0007,#000F
        DEFW #001F,#003F,#007F,#00FF
        DEFW #01FF,#03FF,#07FF,#0FFF
;__________________________________
PUTSTRING;выводит цепо„ку с на„. адресом в HL, в поток
        ;символов. ¬озвраўает в ј первый символ
        ;Ётой цепо„ки.  Ћибо CF=1 в слу„ае оЎибки в
        ;PUTCHAR.
;портит bc,de,hl
        ld bc,0
PUTSTR0 ;
        dec bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(hl)
        ld (bc),a
        ex de,hl
         BIT 4,B
         JR Z,PUTSTR_fail ;ошибка (???)
        LD A,H
        OR L
        JP NZ,PUTSTR0
;CY=0
        LD A,(bc)
        ex af,af' ;LD (PUTSTR3+1),A ;ѕервый символ цепо„ки.
PUTSTR2 LD A,(bc)
         push bc
        CALL PUTCHAR
         pop bc
        ;JR C,PUTSTR4
        INC bc
        BIT 7,b
        JP NZ,PUTSTR2
        ex af,af'
PUTSTR4
        RET 

;ошибка!!!
PUTSTR_fail
       SCF 
       RET 


;________________________________
RE_CODE ;ѕроизводит поиск Ёлемента с кодом в HL
        ;по таблице цепо„ек.
        ;¬озвраўает HL=адрес Ёлемента.
        ;если Ёлемент равен CC,EOI или отсутствует,
        ;то устанавливаетс€ CF=1, и ј:
        ;FF-нет Ёлемента,1-CC,2-EOI.
        ;==========================================
        PUSH BC
        LD C,L
        LD B,H
        ADD HL,HL
        ADD HL,BC
        POP BC
        LD A,#C0
        OR H
        LD H,A
        LD A,(HL)
        CP #FF
        JR Z,RE_COD0
        OR A
        RET     ;нормальный выход.
RE_COD0 INC HL
        LD A,(HL)
        DEC HL
        CP #FF
        JR Z,RE_COD1
        CP 3
        JR C,RE_COD1
        OR A
        RET 
RE_COD1 SCF 
        RET 
;________________________________________________
LZW_INSTALL
        ;»нсталл€ци€ таблицы цепо„ек в странице #10
        ;—труктура таблицы: трехбайтные Ёлементы,
        ;первые два байта=
        ;  0-на„альный (корнево…) Ёлемент таблицы
        ;    (при LZW_SIZE=8 всего их будет 256)
        ;  #FFFF-Ёлемента не суўествует...
        ;  #01FF-код о„истки...
        ;  #02FF-код заверЎени€ данных EOI.
        ;  остальные вели„ины озна„аёт адрес, по которому
        ;  сидит предыдуўий Ёлемент цепо„ки.
        ;и третий ба…т-собственно сам символ (Ёлемент).
        ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        LD HL,#C000
        LD DE,#C001
        LD BC,#3FFF
        LD (HL),C
        LDIR 
        LD A,(LZW_SIZE)
        LD B,A
        LD HL,1
LZW_INS0
        ADD HL,HL
        DJNZ LZW_INS0
        LD C,L
        LD B,H
        INC HL
        INC HL
        LD (NEW_COD1+1),HL
        LD HL,#C000
        LD E,0
LZW_INS1
        LD (HL),0
        INC HL
        LD (HL),0
        INC HL
        LD (HL),E
        INC HL
        INC E
        DEC BC
        LD A,B
        OR C
        JR NZ,LZW_INS1
        XOR A
        LD (HL),#FF
        INC HL
        LD (HL),1
        INC HL
        LD (HL),A
        INC HL
        LD (HL),#FF
        INC HL
        LD (HL),2
        INC HL
        LD (HL),A
        INC HL
        LD (NEW_COD0+1),HL ;јдрес первого свободного Ёлемента
                           ;в таблице цепо„ек.
        LD A,(LZW_SIZE)
        INC A
        LD (LZW_SIZW),A

        DEC A
        ADD A,A
        ADD A,NEW_COD3&0xff
        LD L,A
        ADC A,NEW_COD3/256
        SUB L
        LD H,A
        LD E,(HL)
        INC HL
        LD D,(HL)
        LD (NEW_COD2+1),DE
        LD A,E
        LD (GETCOD20+1),A
        LD A,D
        LD (GETCOD21+1),A

        RET 
;__________________________
GETCHAR ;выбрать символ из потока данных дл€ GETCODE
        ;с у„етом подблоков,их длин и подблока 0-й длины
        ;≈сли оЎибка-то возврат CF=1,ZF=0 (NZ)
        ;≈сли подблок нулевой длины то возврат CF=1,ZF=1
        ;ина„е возврат ј=данное,CF=0
GETCHR0 LD A,0  ; оли„ество байт,оставЎеес€ в текуўем блоке.
        OR A
        JR Z,GETCHR5
GETCHR2 DEC A
        LD (GETCHR0+1),A
        GIFGETBYTE_noret
        ret nc ;нормальный выход, ј=данное
GETCHR_fail
        PUSH HL
        LD L,0
        INC L   ;”становка флага ZF=0
        POP HL
        SCF     ;ќЎибка „тени€ байта...
        RET 
GETCHR5
        GIFGETBYTE_noret
        JR C,GETCHR_fail
GETCHR1 OR A
        JP NZ,GETCHR2
                ;Ѕлок нулевой длины-определить конец данных...
GETCHR4 LD A,#FF
        LD (GIF_IMG_ENDcode),A
        INC A
        OR A
        RET 

;__________________________
GETCODE ;¬озвраўает код в HL с коли„еством бит,равным LZW_SIZW
        PUSH AF
        PUSH DE
        PUSH BC
GETCOD00 LD L,0 ;оставЎиес€ данные.
GETCOD0 LD A,0  ;количество бит в наличии
        OR A
        JP NZ,GETCOD1
        CALL GETCHAR
        JR C,GETCOD_fail
        LD L,A
        LD (GETCOD00+1),A
        LD A,8
GETCOD1
        LD C,A ;количество бит в наличии
        ADD A,A
        ADD A,ROL_TAB/256-2
        LD H,A  ;'HL=адрес таблицы.

        LD E,(HL) ;LSB (L>>n)

       LD A,C ;количество бит в наличии
       SUB 0
LZW_SIZW EQU $-1;“%куўий размер ко$а LZW (”же модифицированный
;^^^^^^^^^^^^^  ;на +1)

        JR NC,GETCOD11
        INC H

        ADD A,8
        JR C,GETCOD10
        ADD A,8
        LD (GETCOD0+1),A ;количество бит в наличии

        CALL GETCHAR
        JR C,GETCOD_fail
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR E
        LD E,A
        DEC H
        LD D,(HL) ;LSB (L>>n)
        INC H
        CALL GETCHAR
        JR C,GETCOD_fail
        LD (GETCOD00+1),A
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR D
        LD D,A
        JP GETCOD2
;===========================
GETCOD10
        LD (GETCOD0+1),A ;количество бит в наличии
        CALL GETCHAR
        JR C,GETCOD_fail
        LD (GETCOD00+1),A
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR E
        LD E,A
        DEC H
        LD D,(HL) ;LSB (L>>n)
        JP GETCOD2
;===============================
GETCOD11
        LD (GETCOD0+1),A ;количество бит в наличии
        LD D,0

GETCOD2
        EX DE,HL
GETCOD20
        LD A,0
        AND L
        LD L,A
GETCOD21
        LD A,0
        AND H
        LD H,A
        POP BC
        POP DE
        POP AF
        OR A    ;нормальны… выход,HL=код.
        RET 

GETCOD_fail ;ќЎибка в выборке байтов.
        POP BC
        POP DE
        POP HL
        SCF     ;A=код оЎибки...
        RET 
;________________________________________
GIF_LOGSCR      ;ќбработка дескриптора логи„еского Ёкрана.
         ld a,PAL_GLOB/256
         ld (putchar_palH),a
        GIFINITCY
        GIFGETWORD
        LD (curpicwid),HL
        ld b,h
        ld c,l
        add hl,hl
        add hl,bc
        ld (curpicwidx3),hl
        GIFGETWORD
        LD (curpichgt),HL
        
        call reserve_bmp_pages
        
        GIFINITCY
        GIFGETBYTE
        LD C,A
        GIFGETBYTE
        ;LD (FON_COLOR),A ;TODO прозрачность???
        GIFGETBYTE
        LD (X_Y_GIF),A
        LD A,C
        LD HL,PAL_GLOB
        ;JP GIF_PAL
;_______________________________
GIF_PAL;ќбработка палитры.¬ HL=адрес,куда совать B&W
        ;таблицу (768б), ј=флаг.
        OR A
        BIT 7,A
        RET Z   ;«на„ит нету палитры.
        AND 7
        INC A
        LD B,A ;число битов палитры 1..8

        ld a,h
        ld (putchar_palH),a

        LD a,1
GIF_PAL0
        add a,a
        DJNZ GIF_PAL0
        ld b,a
        ;B=длина палитры в триплетах RGB (min=2, max=256)
        GIFINITCY
GIF_PAL1
        inc h
        inc h
        GIFGETBYTE
        ld (hl),a
        dec h
        GIFGETBYTE
        ld (hl),a
        dec h
        GIFGETBYTE
        ld (hl),a
        inc l
        djnz GIF_PAL1
        XOR A
        RET 

GIF_GETWORD
        GIFINITCY
        GIFGETBYTE
        LD L,A
        GIFGETBYTE_noret
        LD H,A
        RET 
;_______ _______________________
GIF_HEAD0 DEFB "IF87a"
GIF_HEAD1 DEFB "IF89a"

GIFSEARCH
;ѕоиск GIF-a в потоке данных.
        GIFINITCY
        LD HL,GIF_HEAD0
        LD DE,GIF_HEAD1
        LD B,6-1
GIFSEARCH0
        GIFGETBYTE
        CP (HL)
        JR Z,GIFSEARCH1
        EX DE,HL
        CP (HL)
        EX DE,HL
        JR NZ,GIFSEARCH_fail
GIFSEARCH1
        INC HL
        INC DE
        DJNZ GIFSEARCH0
        XOR A
        RET 
GIFSEARCH_fail
        scf
        ret
;_______
gifsetpgLZW
        push af
        push bc
curpgLZW=$+1
        ld a,0
        SETPG32KHIGH
        pop bc
        pop af
        ret
       

;=============================
ROL_INSTALL ;»нстал€тор табли„ки дл€ ускорени€
            ;процедуры GETCODE
;L0>>n (16 bit)
        LD HL,ROL_TAB+#0E00
        ld de,0x08FF
ROL_I00
ROL_I01
        ld b,d
        ld a,l
        rlca
        djnz $-1
        ld c,a
        and e
        LD (HL),A ;LSB
        INC H
        xor c
        LD (HL),A ;HSB
        DEC H
        INC L
        jr nz,ROL_I01
        DEC H
        DEC H
        srl e ;0xff >> n
        dec d
        jr nz,ROL_I00
        ret
