LINEGIF=0x8000 ;адрес для сборки строк
ROL_TAB=0xa000 ;,0x1000 ;L0>>n (16 bit)
PAL_GLOB=0x9a00 ;,0x300 ;глобальная таблица цветов
PAL_LOCAL=0x9d00 ;,0x300 ;локальная таблица цветов

;процедуры чтения на входе хотят NC, иначе могут насквозь вернуть C даже без ошибки
        macro GIFINITCY
        ;or a
        endm

        macro GIFRETIFDISKERR
        ;ret c
        endm

        macro GIFJRIFDISKERR addr
        ;jr c,addr
        endm

        macro GIFGETBYTE
        rdbyte
        GIFRETIFDISKERR
        endm

        macro GIFGETBYTE_noret
        rdbyte
        endm

        macro GIFGETWORD
        call GIF_GETWORD
        GIFRETIFDISKERR
        endm

;Производит поиск элемента с кодом в HL по таблице цепочек
;  1,x-начальный (корневоЙ) элемент таблицы (при LZW_SIZE=8 всего их будет 256)
;  0,0-элемента не существует
;  0,1-код очистки
;  0,2-код завершения данных EOI
;  остальные величины означают адрес, по которому сидит предыдущий элемент цепочки +256
;и третий байт - собственно сам символ
;out: HL=адрес элемента. Если элемент равен CC,EOI или отсутствует, то Z=1, А=0-нет элемента,1-CC,2-EOI
;==========================================
        macro GIFRECODE ;out: HL=адрес элемента. Если элемент равен CC,EOI или отсутствует, то Z=1, А=0-нет элемента,1-CC,2-EOI
        LD C,L
        ;LD a,H
         or 0xc0
         ld b,a
        ADD HL,HL
        ADD HL,BC
        LD A,(HL)
         or a
        endm

        macro GIFGETCHAR
        ex af,af'
        dec a
        call z,GETCHRnewblock
        ex af,af'
        GIFGETBYTE_noret
        GIFRETIFDISKERR
        endm        

        macro GIFGETCODE
        call GETCODE_
        GIFRETIFDISKERR
        endm

readgif
        CALL ROL_INSTALL
        CALL GIFSEARCH
        RET C
        CALL GIF_LOGSCR ;Обработка дескриптора лог.Экрана
        RET C           ;вместе с палитрой (PAL_GLOB)
;""""""""""""""""""""""P
GIF_LP0
         call initframe
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
        GIFRETIFDISKERR
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
        ld hl,PUTCHAR
        ld (PUTCHARaddr),hl
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
        ld lx,a;LD (GETCOD0+1),A ;количество бит в наличии
        LD (GIF_IMG_ENDcode),A

        ld a,1
        ex af,af'
        GIFINITCY
        GIFGETBYTE
        LD (LZW_SIZE),A
         push hl
;"""""""""""""""""""""""
GIF_IMGclearLZW ;очистка LZW
         pop hl
        CALL LZW_INSTALL
        GIFGETCODE
        GIFRECODE ;out: HL=адрес элемента. Если элемент равен CC,EOI или отсутствует, то Z=1, А=0-нет элемента,1-CC,2-EOI
        push hl
        JR nz,GIF_IMGputstring
         inc hl
         ld a,(hl)
        dec a;CP 1
        JR Z,GIF_IMGclearLZW ;код очистки
        dec a;CP 2
        jr Z,GIF_IMG_END ;код конца данных...
;элемент отсутствует - ошибка
         pop hl
        SCF 
        RET 
GIF_IMGputstring
        ;push hl;LD (LZW_OLD),HL ;(Адрес) было после
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
        ;RET C
        jr GIF_IMGunpackloop
;""""""""""""""""""""""""
GIF_IMGputstring_newcode
        ;nop ;4t = 0.04 s
        ;push hl;LD (GIF_IMG3+1),HL
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
        ;RET C
GIF_IMGnewcode_unpackloop
;добавить в таблицу цепочек элемент, состоящий из ссылки на OLD и символа А
NEW_COD0 LD HL,0
        LD DE,(LZW_OLD)
         inc d
        LD (HL),d;E
        INC HL
        LD (HL),e;D
        INC HL
        LD (HL),A
        INC HL
        LD (NEW_COD0+1),HL
NEW_COD1 LD HL,0        
        INC HL
        LD (NEW_COD1+1),HL
;проверка, нужно ли увеличивать LZW_SIZW
NEW_CODmask=$+1
        LD DE,0 ;маска+1
        OR A
        SBC HL,DE
        call z,gif_inccodemask ;сначала одни 111, затем 000... - тогда увеличивать
GIF_IMGunpackloop
;главный цикл распаковки
        ;LD HL,0
        pop hl
        LD (LZW_OLD),HL
        GIFGETCODE
        GIFRECODE ;out: HL=адрес элемента. Если элемент равен CC,EOI или отсутствует, то Z=1, А=0-нет элемента,1-CC,2-EOI
        push hl
        jp nz,GIF_IMGputstring_newcode
         inc hl
         ld a,(hl)
        dec a;CP 1
        JR Z,GIF_IMGclearLZW ;код очистки
        dec a;CP 2
        jr Z,GIF_IMG_END;конец блока
;элемент отсутствует
        ;nop ;4t < 0.02 s
        ;push hl;LD (GIF_IMG3+1),HL ;Запоминаем адрес элемента для того, чтобы после NEW_CODE присвоить его значение OLD-у
LZW_OLD=$+1
        LD HL,0
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
        ;RET C
         ;push af
        CALL PUTCHAR
         ;pop af
         ld a,(de) ;первый символ цепочки
        jp GIF_IMGnewcode_unpackloop

GIF_IMG_END
         pop hl
GIF_IMG_END0
;найден код конца LZW-данных
;необходимо считать след. блок, и если его длина=0, то конец кадра
        GIFINITCY
        ;GIFGETCHAR
        call GETCHAR_ ;чтобы была правильная глубина стека при нахождении блока с длиной 0 (он пропускает чтение следующего байта через снятие адреса со стека)
;установит переменную GIF_IMG_ENDcode, если пойдёт блок с длиной 0, а пока дочитываем текущий блок
        GIFRETIFDISKERR
GIF_IMG_ENDcode=$+1
        LD A,0 ;/0xff, если встретился блок с длиной 0
        OR A
        JR z,GIF_IMG_END0 ;т.е. ещё не конец блока.
;встретился блок с длиной 0
        if 1==0
GIF_IMG_END0 ;так не работает, потому что надо дочитать текущий блок до конца (почему он кончается не сразу?)
GIF_IMG_ENDcode=$+1
        ld a,0
        GIFGETBYTE
        or a
        ;ret nz ;не блок с длиной 0 - ошибка
        jr nz,GIF_IMG_END0 ;ждём конца данных - блока с длиной 0 (почему он приходит не сразу?)        
        endif

        ;CALL CONVERT
        ;CALL VIEW
        
        JP GIF_LP0 ;следующий кадр

;====================================================
LZW_SIZE DEFB 0 ;Минимальный размер кода LZW для инициализации.
X_IMG   DEFW 0  ;Размеры отдельного изображения:
Y_IMG   DEFW 0  ;Начальная позиция в экране
DX_IMG  DEFW 0  ;и размер этого изображения.
DY_IMG  DEFW 0
;===========================
;затычка для неиспользуемых строк (вызывается только в двух местах, затычку достаточно в PUTSTRING)
PUTCHAR_DUMMY
        exx
        cpi;ldi
        exx
        ret pe
        jp PUTCHARendline

PUTCHARtransparent
        inc de
        inc de
        inc de
        cpi
        exx
        ret pe
        jp PUTCHARendline

PUTCHAR
;Вывод символа в поток (строку)...
;портит a
;de'=linebufpointer, bc'=counter
        exx
giftransparentcolor=$+1
         cp 0
         jr z,PUTCHARtransparent
         ;nop ;4t = 0.1 s
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
        exx
        ret pe ;строка не кончилась
PUTCHARendline
;end of line
        push bc
        push de
        push hl
         ld hl,PUTCHAR
         ld (PUTCHARaddr),hl
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
         ld hl,PUTCHAR_DUMMY
         ld (PUTCHARaddr),hl ;TODO с учётом зума
        
PUTCHARskipline
        pop hl
        pop de
        pop bc
        exx
;TODO для анимированных: если не первый кадр, прочитать строку из памяти в LINEGIF (чтобы рисовать поверх неё)

        ld bc,(DX_IMG) ;локальная ширина
linebufstart_local=$+1
        ld de,0 ;локальное начало строки
        exx
        ret
;__________________________________
PUTSTRING
;выводит цепочку с нач. адресом в HL в поток символов.
;Возвращает в А первый символ этой цепочки.  [Либо CF=1 в случае ошибки]
;портит bc,de,hl
;использует буфер по адресу -1..-4096
        ld bc,0
        ;xor a
        ;ld b,a
        ;ld c,a
PUTSTR0 ;
        dec bc
        ld d,(hl);e
        inc hl
        ld e,(hl);d
        inc hl
        ld a,(hl)
        ld (bc),a
        ex de,hl
         ;BIT 4,B
         ;JR Z,PUTSTR_fail ;ошибка (длина 4096 элементов, больше нет места) ;но реально такого не может быть в составленной нами таблице
         ;nop ;4t = 0.1 s
         dec h
        JP NZ,PUTSTR0 ;пока не перейдём к корневой цепочке
;[CY=0]
PUTSTR2 LD A,(bc)
PUTCHARaddr=$+1
        CALL PUTCHAR
        ;JR C,PUTSTRpopfail
        INC bc
        BIT 7,b
        JP NZ,PUTSTR2
         ld a,(de) ;первый символ цепочки
        RET 

;________________________________________________
LZW_INSTALL
;Инсталляция таблицы цепочек в #c000
;Структура таблицы: трехбайтные элементы,
;  1,x-начальный (корневоЙ) элемент таблицы (при LZW_SIZE=8 всего их будет 256)
;  0,0-элемента не существует
;  0,1-код очистки
;  0,2-код завершения данных EOI
;  остальные величины означают адрес, по которому сидит предыдущий элемент цепочки +256
;и третий байт - собственно сам символ
        LD HL,#C000
        LD DE,#C001
        LD BC,#3FFF
        LD (HL),L;C
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
        LD (HL),1;0
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
        ;XOR A
        LD (HL),a;=0;#FF
        INC HL
        LD (HL),1
        INC HL
        LD (HL),A;0
        INC HL
        LD (HL),a;=0;#FF
        INC HL
        LD (HL),2
        INC HL
        LD (HL),A;0
        INC HL
        LD (NEW_COD0+1),HL ;Адрес первого свободного Элемента в таблице цепоЧек.
        LD A,(LZW_SIZE)
        INC A
gif_setcodemask
;a=codesize=1..12
;out: CY=0
        LD (LZW_SIZW),A ;1..12
        ld b,a
        ld hl,0
        add hl,hl
        inc hl
        djnz $-2
        ld a,l
        ld (GETCODmasklow),a
        ld a,h
        ld (GETCODmaskhigh),a
         inc hl
        ld (NEW_CODmask),hl ;маска+1
        ret
gif_inccodemask
        LD A,(LZW_SIZW)
        CP #0C
        JR NC,$+3
         INC A
;a=codesize=1..12
        jp gif_setcodemask ;out: CY=0
;__________________________
GETCHAR_
;для GIF_IMG_END
        GIFGETCHAR ;может вывалиться с C (ошибка) или NC (найден блок с длиной 0)
        ret
        
GETCHRnewblock
;текущий блок закончился
        GIFGETBYTE_noret
        GIFJRIFDISKERR GETCHRnewblock_fail
        or a
        ret nz ;установить длину блока и читать байт
;блок нулевой длины - определить конец данных
;нужно только в GIF_IMG_END
         ex af,af'
         pop af ;выход на уровень выше, чтобы не читать данное (ret будет эквивалентно ret nc из GIFGETCHAR)
        LD A,#FF
        LD (GIF_IMG_ENDcode),A
        GIFINITCY
        RET 
GETCHRnewblock_fail
         ex af,af'
        pop af ;выход на уровень выше (ret будет эквивалентно ret c в GIFGETCHAR)
        scf
        ret

;__________________________
        if 1==0
GETCODgetbyte
        GIFGETCHAR
        ;CALL GETCHAR
        ;ret c ;JR C,GETCOD_fail
        LD L,A
        LD (GETCOD00+1),A
        LD A,8
        ret
        endif

GETCODE_ ;ВозвраЩает код в HL с колиЧеством бит,равным LZW_SIZW
GETCOD00 LD L,0 ;оставШиеся данные.
;GETCOD0 LD A,0  ;количество бит в наличии
        ;OR A
        ;call z,GETCODgetbyte

        ld a,lx;LD C,A ;количество бит в наличии
        ADD A,A
        if 1==1
        JP NZ,GETCOD1
        GIFGETCHAR
        LD L,A
        LD (GETCOD00+1),A
        LD A,8
         ld lx,a;c,a
         add a,a
GETCOD1
        endif
        ADD A,ROL_TAB/256-2
        LD H,A
        ;LD E,(HL) ;LSB (L>>n)

       LD A,lx;C ;количество бит в наличии
       SUB 0
LZW_SIZW=$-1 ;Т%куЩий размер ко$а LZW (Уже модифицированный на +1)
        JR NC,GETCODneed0bytes ;имеем достаточно бит в наличии
        ADD A,8
        ;JR C,GETCODneed1byte ;надо взять дополнительно 1 байт
        jr nc,GETCODneed2bytes ;надо взять дополнительно 2 байта
GETCODneed1byte
;надо взять дополнительно 1 байт (самый частый случай)
         ;call z,GETCODgetbyte
        LD lx,a;(GETCOD0+1),A ;количество бит в наличии
        LD E,(HL) ;LSB (L>>n)
        GIFINITCY
        GIFGETCHAR
        LD (GETCOD00+1),A
        LD L,A
        LD D,(HL) ;LSB (L>>n)
        inc h
        LD A,(HL) ;HSB (L>>n)
        OR E
        ;JP GETCOD2
GETCOD2
GETCODmasklow=$+1
        and 0
        LD L,A
GETCODmaskhigh=$+1
        LD A,0
        AND d
        LD H,A
        ;OR A    ;нормальный выход, HL=код
        RET 
GETCODneed2bytes
;надо взять дополнительно 2 байта
        ADD A,8
         ;call z,GETCODgetbyte
        LD lx,a;(GETCOD0+1),A ;количество бит в наличии
        LD E,(HL) ;LSB (L>>n)
        GIFINITCY
        GIFGETCHAR
        LD L,A
        LD D,(HL) ;LSB (L>>n)
        inc h
        LD A,(HL) ;HSB (L>>n)
        OR E
        LD E,A
        GIFGETCHAR
        LD (GETCOD00+1),A
        LD L,A
        LD A,(HL) ;HSB (L>>n)
        OR D
        LD D,A
        ld a,e
        JP GETCOD2
GETCODneed0bytes
;имеем достаточно бит в наличии
         ;call z,GETCODgetbyte
        LD lx,a;(GETCOD0+1),A ;количество бит в наличии
        LD D,0
        ld a,(hl)
        JP GETCOD2
;________________________________________
GIF_LOGSCR      ;Обработка дескриптора логиЧеского Экрана.
         ld a,PAL_GLOB/256
         ld (putchar_palH),a
        GIFINITCY
        GIFGETWORD
        call setpicwid
        GIFGETWORD
        LD (curpichgt),HL
        
        call reserve_bmp_pages
        
        GIFINITCY
        GIFGETBYTE
        LD C,A
        GIFGETBYTE
        LD (giftransparentcolor),A
        GIFGETBYTE
        ;LD (X_Y_GIF),A
        LD A,C
        LD HL,PAL_GLOB
        ;JP GIF_PAL
;_______________________________
GIF_PAL
;Обработка палитры
;HL=адрес, куда совать таблицу (768б), А=флаг
        OR A
        ;BIT 7,A
        ret p ;значит нету палитры
        AND 7
        INC A
        LD B,A ;число битов палитры 1..8
        ld a,h
        ld (putchar_palH),a
        LD a,1
        add a,a
        djnz $-1
        ld b,a ;B=длина палитры в триплетах RGB (min=2, max=256)
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
;Поиск GIF'a в потоке данных.
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
        ;JR NZ,GIFSEARCH_fail
        scf
        ret nz
GIFSEARCH1
        INC HL
        INC DE
        DJNZ GIFSEARCH0
        XOR A
        RET 
;GIFSEARCH_fail
;        scf
;        ret
;_______
gifsetpgLZW
curpgLZW=$+1
        ld a,0
        SETPG32KHIGH
        ret

;=============================
ROL_INSTALL
;Инсталятор таблички для ускорения процедуры GETCODE
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
