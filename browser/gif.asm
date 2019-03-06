LINEGIF=0x8000 ;адрес для сборки строк
ROL_TAB=0xa000 ;,0x1000 ;L0>>n (16 bit)
PAL_GLOB=0x9a00 ;,0x300 ;глобальная таблица цветов
PAL_LOCAL=0x9d00 ;,0x300 ;локальная таблица цветов

;процедуры чтения на входе хотят NC, иначе могут насквозь вернуть C даже без ошибки
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

newgifgetchar=1;0
        
        if newgifgetchar
        
        macro GIFGETCHAR
        ex af,af'
        dec a
        call z,GETCHRnewblock
        ex af,af'
        GIFGETBYTE_noret
         ret c
        endm
        
        else
        
        macro GIFGETCHAR
        call GETCHAR_
        ret c
        endm
        
        endif
        

        macro GIFGETCODE
        push bc
        push de
        ;push af
        call GETCODE_
        ;pop bc
        ;ld a,b ;???
        pop de
        pop bc
        ret c
        endm

readgif
        ;jr $
        CALL ROL_INSTALL
        CALL GIFSEARCH
        RET C
        CALL GIF_LOGSCR ;Обработка дескриптора лог.Экрана
        RET C           ;вместе с палитрой (PAL_GLOB)
;""""""""""""""""""""""P
GIF_LP0
         call initframe
         jp GIF_PARSEFRAME
         
GIF_IMG_END 
        ;jr $
;найден код конца LZW-данных
        if 1==1

;необходимо считать след. блок, и если его длина=0, то конец кадра
         or a
        ;GIFGETCHAR ;установит следующую переменную, если пойдёт блок с длиной 0, а пока дочитываем текущий блок
        call GETCHAR_ ;чтобы была правильная глубина стека при нахождении блока с длиной 0 (он пропускает чтение следующего байта через снятие адреса со стека)
        ret c
        
GIF_IMG_ENDcode=$+1
        LD A,0 ;/0xff, если встретился блок с длиной 0
        OR A
        jp nz,GIF_LPR ;встретился блок с длиной 0
        ;GIFGETCHAR
        ;CALL GETCHAR
        ;RET C
        JR GIF_IMG_END ;т.е. еЩе не конец блока.
        else
;так не работает, потому что надо дочитать текущий блок до конца (почему он кончается не сразу?)
GIF_IMG_ENDcode=$+1
        ld a,0
        GIFGETBYTE
        or a
        ;ret nz ;не блок с длиной 0 - ошибка
        jr nz,GIF_IMG_END ;ждём конца данных - блока с длиной 0 (почему он приходит не сразу?)
        
        endif
        
GIF_LPR
        ;CALL CONVERT
        ;CALL VIEW
        
        JP GIF_LP0 ;следующий кадр?

GIF_PARSEFRAME
;Начало цикла обработки кадра? GIF-изображения
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
GIF_SPEC;Специальный фрейм.
        GIFINITCY
        GIFGETBYTE
;       CP #FF
;       JR NZ,GIF_fail ;Неопознаное приложение
GIF_HELP
        GIFGETBYTE
        OR A
        JP Z,GIF_LP0
        LD B,A
GIF_HP0 
        GIFGETBYTE    ;Пропустить HELP...
        DJNZ GIF_HP0
        JR GIF_HELP

;"""""""""""""""""""""""
GIF_IMG ;Обработка блока изображения.
        GIFINITCY
        GIFGETWORD
        LD (X_IMG),HL
        GIFGETWORD
        LD (Y_IMG),HL
         ;LD (Y_WORK),HL
        GIFGETWORD
        LD (DX_IMG),HL ;локальная ширина
         LD (pixelcounter_back),HL
         ret c
         ld b,h
         ld c,l
         add hl,hl
         add hl,bc
         ld (DX_IMGx3),hl
        GIFGETWORD
        LD (DY_IMG),HL ;локальная высота
        GIFGETBYTE

        LD HL,LINEGIF;FREE
        ld de,(X_IMG) ;локальное начало строки
        add hl,de
        add hl,de
        add hl,de
        ld (linebufstart_local),hl
        LD (linebufpointer),HL

        if 1==0
        BIT 6,A ;необходимо проверить бит 6 на предмет наличия чередования строк
        JR Z,GIF_IMG_NORM
;здесь - Чередование строк -> не подходит. TODO поддержать чередование строк (0,2,1,3?)
         LD A,7
         OUT (#FE),A
         SCF 
         RET 

GIF_IMG_NORM
        endif

;for PUTCHAR:
;TODO для анимированных: если не первый кадр, прочитать строку из памяти в LINEGIF (чтобы рисовать поверх неё)
linebufpointer=$+1
        ld de,0 ;Адрес для вывода байта в LINEGIF
pixelcounter_back=$+1
        ld bc,0
        exx

        LD HL,PAL_LOCAL
        CALL GIF_PAL
        RET C

;========================
;НаЧало разборки отдельного блока графики.
        CALL gifsetpgLZW
        XOR A
        LD (GETCOD0+1),A ;количество бит в наличии
        LD (GIF_IMG_ENDcode),A

        ld a,1;0 ;TODO 1
        if newgifgetchar
        ex af,af'
         or a ;т.к. далее GIFGETBYTE
        else
        LD (GETCHRblocksizecount),A
        endif

        ;___________
        GIFGETBYTE
        LD (LZW_SIZE),A
;"""""""""""""""""""""""
GIF_IMG0 CALL LZW_INSTALL
        GIFGETCODE
        ;CALL GETCODE
        ;RET C
        CALL RE_CODE
        JR NC,GIF_IMG1
        CP 1
        JR Z,GIF_IMG0
        CP 2
        JP Z,GIF_IMG_END ;код конца данных...
        SCF 
        RET 
GIF_IMG1
         LD (LZW_OLD),HL ;(Адрес) было после
        CALL PUTSTRING  ;вывод цепоЧки из таблицы цепоЧек.
        RET C
;""""""""""""""""""""""""
GIF_IMG2
;Главный цикл распаковки.
        GIFGETCODE
        ;CALL GETCODE
        ;RET C
        CALL RE_CODE
        JR NC,GIF_IMG4 ;putstring без putchar
        CP 1
        JR Z,GIF_IMG0   ;Код очистки
        CP 2
        JP Z,GIF_IMG_END;конец блока
;А=#FF,код отсутствует... Ща сделаем ;)
        LD (GIF_IMG3+1),HL;Запоминаем code для того,Чтобы
        ;потом присвоить его знаЧение OLD-у.
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

;====================================================
LZW_OLD DEFW 0  ;ПредыдуЩий адрес цепоЧки символов :)
LZW_SIZE DEFB 0 ;Минимальный размер кода LZW для инициализации.
;X2_SIZE DEFW 0  ;размер в байтах по X конвертированного Экрана.
X_IMG   DEFW 0  ;Размеры отдельного изображения:
Y_IMG   DEFW 0  ;Начальная позиция в экране
DX_IMG  DEFW 0  ;и размер этого изображения.
DY_IMG  DEFW 0
;__________________________________________
;X_Y_GIF DEFB 0  ;СоотноШение X/Y из заголовка GIF.
;FON_COLOR DEFB 0;Цвет фона (TODO прозрачность)
;===========================
PUTCHAR
;Вывод символа в поток (строку)...
;портит a,bc,de,hl
        exx
;linebufpointer=$+1
;        ld de,0 ;Адрес для вывода байта в LINEGIF
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

cury=$+1 ;инициализируется в initframe
        ld de,0
        inc de
        ld (cury),de
        bit 0,e
        jr nz,PUTCHARskipline
        
DX_IMGx3=$+1
        ld bc,0 ;локальная ширина*3
        ld hl,(linebufstart_local) ;локальное начало строки

;hl=откуда копируем строку
;bc=сколько байт копируем
        ;push hl
        ;call putline ;TODO для анимированных
        ;pop hl
        call drawscreenline_frombuf
        
        CALL gifsetpgLZW
PUTCHARskipline
        exx
;TODO для анимированных: если не первый кадр, прочитать строку из памяти в LINEGIF (чтобы рисовать поверх неё)

        ld bc,(DX_IMG) ;локальная ширина
        ;ld (pixelcounter_back),bc
linebufstart_local=$+1
        ld de,0 ;локальное начало строки
        ;ld (linebufpointer),de
        exx
        ret

;__________________________________________
NEW_CODE;добавить в таблицу цепоЧек Элемент, состояЩий
        ;из ссылки на OLD, и символа из А.
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
NEW_COD1 LD HL,0        ;Проверка,нужно ли увелиЧивать LZW_SIZW
        INC HL
        LD (NEW_COD1+1),HL
        DEC HL

NEW_COD2
        LD DE,0 ;patch
        OR A
        SBC HL,DE
        ;LD A,H
        ;OR L
        JR NZ,NEW_CODq  ;СнаЧала одни 111,затем 000...

        LD A,(LZW_SIZW) ;и тогда увелиЧивать!
        CP #0C
        JR NC,$+3
         INC A
;a=codesize=1..12
        call gif_setcodemask
NEW_CODq
        OR A
        POP BC
        POP DE
        POP HL
        RET 

;NEW_COD3
;        DEFW #0001,#0003,#0007,#000F
;        DEFW #001F,#003F,#007F,#00FF
;        DEFW #01FF,#03FF,#07FF,#0FFF
;__________________________________
PUTSTRING;выводит цепоЧку с наЧ. адресом в HL, в поток
        ;символов. ВозвраЩает в А первый символ
        ;Этой цепоЧки.  Либо CF=1 в слуЧае оШибки в
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
        push af ;ex af,af' ;LD (PUTSTR3+1),A ;Первый символ цепоЧки.
PUTSTR2 LD A,(bc)
         push bc
        CALL PUTCHAR
         pop bc
        ;JR C,PUTSTR4
        INC bc
        BIT 7,b
        JP NZ,PUTSTR2
        pop af ;ex af,af'
;PUTSTR4
        RET 

;ошибка!!!
PUTSTR_fail
       SCF 
       RET 


;________________________________
RE_CODE ;Производит поиск Элемента с кодом в HL
        ;по таблице цепоЧек.
        ;ВозвраЩает HL=адрес Элемента.
        ;если Элемент равен CC,EOI или отсутствует,
        ;то устанавливается CF=1, и А:
        ;FF-нет Элемента,1-CC,2-EOI.
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
        inc a ;CP #FF
        JR Z,RE_COD0
        dec a ;OR A
        RET     ;нормальный выход.
RE_COD0 INC HL
        LD A,(HL)
        DEC HL
        CP #FF
        JR Z,RE_COD1
        CP 3
        ;ret c ;JR C,RE_COD1
        ;OR A
        RET 
RE_COD1 SCF 
        RET 
;________________________________________________
LZW_INSTALL
        ;Инсталляция таблицы цепоЧек в странице #10
        ;Структура таблицы: трехбайтные Элементы,
        ;первые два байта=
        ;  0-наЧальный (корневоЙ) Элемент таблицы
        ;    (при LZW_SIZE=8 всего их будет 256)
        ;  #FFFF-Элемента не суЩествует...
        ;  #01FF-код оЧистки...
        ;  #02FF-код заверШения данных EOI.
        ;  остальные велиЧины ознаЧаЮт адрес, по которому
        ;  сидит предыдуЩий Элемент цепоЧки.
        ;и третий баЙт-собственно сам символ (Элемент).
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
        LD (NEW_COD0+1),HL ;Адрес первого свободного Элемента
                           ;в таблице цепоЧек.
        LD A,(LZW_SIZE)
        INC A

        ;LD (LZW_SIZW),A ;1..12
        ;DEC A
        ;ADD A,A
        ;ADD A,NEW_COD3&0xff
        ;LD L,A
        ;ADC A,NEW_COD3/256
        ;SUB L
        ;LD H,A
        ;LD E,(HL)
        ;INC HL
        ;LD D,(HL)
        ;LD (NEW_COD2+1),DE
        ;LD A,E
        ;LD (GETCOD20+1),A
        ;LD A,D
        ;LD (GETCOD21+1),A
        ;RET 
        ;jp gif_setcodemask
gif_setcodemask
;a=codesize=1..12
        LD (LZW_SIZW),A ;1..12
        ld b,a
        ld hl,0
        add hl,hl
        inc hl
        djnz $-2
        ;DEC A
        ;ADD A,A
        ;ADD A,NEW_COD3&0xff
        ;LD L,A
        ;ADC A,NEW_COD3/256
        ;SUB L
        ;LD H,A
        ;LD E,(HL)
        ;INC HL
        ;LD D,(HL)
        ;LD (NEW_COD2+1),DE ;маска
        ;LD A,E
        ;LD (GETCOD20+1),A
        ;LD A,D
        ;LD (GETCOD21+1),A
        ld (NEW_COD2+1),hl ;маска
        ld a,l
        ld (GETCOD20+1),a
        ld a,h
        ld (GETCOD21+1),a
        ret
;__________________________
        if newgifgetchar
GETCHAR_
;для GIF_IMG_END
        GIFGETCHAR ;может вывалиться с C (ошибка) или NC (найден блок с длиной 0)
        ret
        
        else
        
GETCHAR_
;выбрать символ из потока данных для GETCODE
        ;с уЧетом подблоков,их длин и подблока 0-й длины
        ;Если оШибка-то возврат CF=1,[ZF=0 (NZ)]
        ;Если подблок нулевой длины то возврат CF=0,[ZF=1] [не CF=1,ZF=1]
        ;инаЧе возврат А=данное,CF=0
        ;jr $
GETCHRblocksizecount=$+1
        LD A,1;0  ;КолиЧество байт,оставШееся в текуЩем блоке.
        ;OR A
         dec a
        call Z,GETCHRnewblock ;текущий блок закончился
;GETCHR2
        ;DEC A
        LD (GETCHRblocksizecount),A
        GIFGETBYTE_noret
        ret ;c/nc
        
        endif
        
        if 1==0
        ret nc ;нормальный выход, А=данное
GETCHR_fail
        ;PUSH HL
        ;LD L,0
        ;INC L   ;Установка флага ZF=0
        ; dec l
        ;POP HL
        SCF     ;ОШибка Чтения байта...
        RET 
        endif
        
GETCHRnewblock
;текущий блок закончился
        GIFGETBYTE_noret
        JR C,GETCHRnewblock_fail;GETCHR_fail
        or a
        ;jr z,GETCHRendofdata
        ret nz ;JP NZ,GETCHR2 ;установить длину блока и читать байт
                ;Блок нулевой длины-определить конец данных...
;GETCHRendofdata
;нужно только в GIF_IMG_END - может, там просто читать байт из файла? TODO
         ex af,af'
         pop af ;выход на уровень выше, чтобы не читать данное (ret будет эквивалентно ret nc из GIFGETCHAR)
        LD A,#FF
        LD (GIF_IMG_ENDcode),A
        ;INC A
        OR A
        RET 
GETCHRnewblock_fail
         ex af,af'
        pop af ;выход на уровень выше (ret будет эквивалентно ret c в GIFGETCHAR)
        ;jr GETCHR_fail
        scf
        ret


;__________________________
GETCODE_ ;ВозвраЩает код в HL с колиЧеством бит,равным LZW_SIZW
        ;PUSH AF
        ;PUSH DE
        ;PUSH BC
GETCOD00 LD L,0 ;оставШиеся данные.
GETCOD0 LD A,0  ;количество бит в наличии
        OR A
        JP NZ,GETCOD1
        GIFGETCHAR
        ;CALL GETCHAR
        ;ret c ;JR C,GETCOD_fail
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
LZW_SIZW EQU $-1;Т%куЩий размер ко$а LZW (Уже модифицированный
;^^^^^^^^^^^^^  ;на +1)

        JR NC,GETCOD11
        INC H

        ADD A,8
        JR C,GETCOD10
        ADD A,8
        LD (GETCOD0+1),A ;количество бит в наличии

         or a
        GIFGETCHAR
        ;CALL GETCHAR
        ;ret c ;JR C,GETCOD_fail
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR E
        LD E,A
        DEC H
        LD D,(HL) ;LSB (L>>n)
        INC H
        GIFGETCHAR
        ;CALL GETCHAR
        ;ret c ;JR C,GETCOD_fail
        LD (GETCOD00+1),A
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR D
        LD D,A
        JP GETCOD2
;===========================
GETCOD10
        LD (GETCOD0+1),A ;количество бит в наличии
         or a
        GIFGETCHAR
        ;CALL GETCHAR
        ;ret c ;JR C,GETCOD_fail
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
        ;EX DE,HL
GETCOD20
        LD A,0
        AND e;L
        LD L,A
GETCOD21
        LD A,0
        AND d;H
        LD H,A
        ;POP BC
        ;POP DE
        ;POP AF
        ;OR A    ;нормальныЙ выход,HL=код.
        RET 

GETCOD_fail ;ОШибка в выборке байтов.
        ;POP BC
        ;POP DE
        ;POP HL
        SCF     ;A=код оШибки...
        RET 
;________________________________________
GIF_LOGSCR      ;Обработка дескриптора логиЧеского Экрана.
         ld a,PAL_GLOB/256
         ld (putchar_palH),a
        GIFINITCY
        GIFGETWORD
        ;LD (curpicwid),HL
        ;ld b,h
        ;ld c,l
        ;add hl,hl
        ;add hl,bc
        ;ld (curpicwidx3),hl
        call setpicwid
        GIFGETWORD
        LD (curpichgt),HL
        
        call reserve_bmp_pages
        
        GIFINITCY
        GIFGETBYTE
        LD C,A
        GIFGETBYTE
        ;LD (FON_COLOR),A ;TODO прозрачность???
        GIFGETBYTE
        ;LD (X_Y_GIF),A
        LD A,C
        LD HL,PAL_GLOB
        ;JP GIF_PAL
;_______________________________
GIF_PAL;Обработка палитры.В HL=адрес,куда совать B&W
        ;таблицу (768б), А=флаг.
        OR A
        BIT 7,A
        RET Z   ;ЗнаЧит нету палитры.
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
;Поиск GIF-a в потоке данных.
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
ROL_INSTALL ;Инсталятор таблиЧки для ускорения
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
