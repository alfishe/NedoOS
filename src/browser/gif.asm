LINEGIF=0x8000 ;адрес для сборки строк
LINEGIF_sz=0x1800 ;макс. ширина = 2048
;KEEPFRAMELINE=LINEGIF-0x4000
PAL_GLOB=0x9a00 ;,0x300 ;глобальная таблица цветов
PAL_LOCAL=0x9d00 ;,0x300 ;локальная таблица цветов
ROL_TAB=0xa000 ;,0x1000 ;L0>>n (16 bit)

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
        ld hl,LINEGIF
        ld de,LINEGIF+1
        ld (hl),BACKGROUNDCOLORLEVEL
        ld bc,LINEGIF_sz-1
        ldir ;чтобы справа в остатке знакоместа была чернота (потом можно убрать, когда readchr будет это делать)
        
        xor a
        ld (gifdisposalmethod),a
        
        ld a,GIFTRANSP_off
        ld (giftransparencyflag),a
        CALL ROL_INSTALL
        CALL GIFSEARCH
        RET C
        CALL GIF_LOGSCR ;обработка дескриптора картинки вместе с палитрой (PAL_GLOB) ;заказывает память под bmp
        RET C
GIF_newframe
GIF_parsechunk
        GIFINITCY
        GIFGETBYTE
        CP #2C
        jr Z,GIF_IMG
        CP #21
        ;JR Z,GIF_SPEC
        ;CP #3B ;???
        ;ret z
        ret nz ;неопознанный блок, выход по ошибке
;GIF_SPEC ;специальный блок
        GIFINITCY
        GIFGETBYTE
        cp #f9 ;graphic control extension
        jr z,GIF_GFXCTRLEXT
;       CP #FF
;       JR NZ,GIF_fail
GIF_HELP
        GIFGETBYTE
        OR A
        jr z,GIF_parsechunk;newframe
        LD B,A
GIF_HP0 
        GIFGETBYTE    ;Пропустить HELP...
        DJNZ GIF_HP0
        JR GIF_HELP

;graphic control extension
GIF_GFXCTRLEXT
        GIFGETBYTE ;=4
gifdisposalmethod=$+1
         ld a,0
         ld (gifwasdisposalmethod),a
        GIFGETBYTE ;bit0 = transparent color present, bit4..2 = disposal method (0=not specified(?), 1=do not dispose(?), 2=overwrite with bg color, 3=overwrite with prev frame(?))
;6908fast.gif, 6914fast.gif, 6911sled.gif: a=5 (transparent color present, do not dispose), 5, 5...
;6906wrbg.gif: a=5, 5, 5, 9 (то есть указанный dispose надо делать после картинки?)
;5scroll.gif: a=4...
;sprites.gif: a=1 (transparent color present, disposal not specified)
;animatie.gif: a=9 (transparent color present, overwrite with bg color), 9, 9...
;zajchik.gif: a=5...
;voloki.gif: a=0
;ris4.gif: a=0
;optic_14.gif: a=0
;optic_15.gif: a=0
;multipal.gif, melnchud.gif, melnchil.gif (все из Photoshop) - нет graphic control extension - TODO не заказывать память под bmp и не делать putline?
        ld (gifdisposalmethod),a
         ;cp 9 
         ;ret z
        ;jr $
         rra;bit 0,a
         ld a,GIFTRANSP_on
         jr c,$+4;nz
         ld a,GIFTRANSP_off
         ld (giftransparencyflag),a
        GIFGETBYTE ;delayLSB
	ld l,a
        GIFGETBYTE ;delayHSB
	ld h,a
         or l
         jr nz,$+4
         ld l,10 ;0 s => 0.1 s
	ld (gifframetime),hl
        GIFGETBYTE ;transparent color index
         ld (giftransparentcolor),a
        GIFGETBYTE ;=0
        jp GIF_parsechunk

;"""""""""""""""""""""""
GIF_IMG ;Обработка блока изображения.
        call initframe ;один раз на кадр после setpicwid, setpichgt и после установки gifframetime ;заказывает память под конверченный кадр
         ld (gifconvertedframeaddr),hl
         ld (gifconvertedframeaddrHSB),a

        GIFINITCY
        GIFGETWORD
        ex de,hl;ld (localx),hl ;локальное начало строки        
        GIFGETWORD
        ;ld (starty),hl ;локальная первая строка
        ld b,h
        ld c,l
        GIFGETWORD
        LD (DX_IMG),HL ;локальная ширина
         LD (pixelcounter_back),HL
        GIFRETIFDISKERR
        GIFGETWORD
        LD (DY_IMG),HL ;локальная высота
        ld h,d
        ld l,e ;локальное начало строки
        add hl,hl
        add hl,de
        ex de,hl ;de=localx*3
        ld hl,LINEGIF
        add hl,de
        ld (linebufstart_local),hl
        ld (linebufpointer),hl

gifrasteraddr=$+1
        ld hl,0;(putchar_hl)
gifrasteraddrHSB=$+1
        ld a,0;(putchar_a)
        call setputlineaddr

;пропустить строки до starty (скопировать из предыдущего кадра) TODO что если это первый кадр, а строк нет? так не бывает?
;starty=$+1
;        ld bc,0
;bc=локальная первая строка
        call gifpreparepic_skiplines

        if 1==0
;ищем, в какое место bmp класть начальную строчку кадра:
        ld bc,(cury);(Y_IMG)
         srl b
         rr c ;TODO с учётом зума
        inc bc
        jr gifrasterstart0loop
gifrasterstart0
        call nextscreenline
        call nextputlineaddr
gifrasterstart0loop
        cpi
        jp pe,gifrasterstart0
        endif
        
        GIFINITCY
        GIFGETBYTE
        if 1==0
        BIT 6,A ;необходимо проверить бит 6 на предмет наличия чередования строк
        JR Z,GIF_IMG_NORM
;чередование строк. TODO поддержать чередование строк (0,2,1,3? - разницу будет видно только с зумом)
         SCF 
         RET 

GIF_IMG_NORM
        endif
        push af

;for PUTCHAR:
        call PUTCHARgetline_ifvisible ;устанавливает PUTCHARaddr, PUTCHARputaddr
        CALL gifsetpgLZW
linebufpointer=$+1
        ld de,0 ;Адрес для вывода байта в LINEGIF
pixelcounter_back=$+1
        ld bc,0
        exx

        pop af ;A bit 7: признак наличия палитры, 2..0: число цветов
        LD HL,PAL_LOCAL
        CALL GIF_PAL
        RET C

;начало разборки отдельного блока графики
        XOR A
        ld lx,a;LD (GETCOD0+1),A ;количество бит в наличии
        LD (GIF_IMG_ENDcode),A

        inc a ;ld a,1
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
        push hl ;запоминаем адрес элемента, чтобы после NEW_CODE присвоить его значение LZW_OLD'у
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
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
        jr GIF_IMGunpackloop

GIF_IMGputstring_newcode
        ;nop ;4t = 0.04 s
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
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
NEW_CODmask=$+1
        LD DE,0 ;маска+1
        OR A
        SBC HL,DE
        call z,gif_inccodemask ;сначала одни 111, затем 000... - увеличить LZW_SIZW
GIF_IMGunpackloop
;главный цикл распаковки
        pop hl
        LD (LZW_OLD),HL
        GIFGETCODE
        GIFRECODE ;out: HL=адрес элемента. Если элемент равен CC,EOI или отсутствует, то Z=1, А=0:нет элемента,1:CC,2:EOI
        push hl ;запоминаем адрес элемента, чтобы после NEW_CODE присвоить его значение LZW_OLD'у
        jp nz,GIF_IMGputstring_newcode
         inc hl
         ld a,(hl)
        dec a;CP 1
        JR Z,GIF_IMGclearLZW ;код очистки
        dec a;CP 2
        jr Z,GIF_IMG_END;конец блока
;элемент отсутствует
        ;nop ;4t < 0.02 s
LZW_OLD=$+1
        LD HL,0
        CALL PUTSTRING ;вывод цепочки из таблицы цепочек
PUTCHARaddr2=$+1
        CALL PUTCHAR ;если не патчить на невидимых строках, видно следы ;keeps de
         ld a,(de) ;первый символ цепочки
        jp GIF_IMGnewcode_unpackloop

GIF_IMG_END
         pop hl
GIF_IMG_END0
;найден код конца LZW-данных
;необходимо считать след. блок, и если его длина=0, то конец кадра
        GIFINITCY
        call GETCHAR_ ;чтобы была правильная глубина стека при нахождении блока с длиной 0 (он пропускает чтение следующего байта через снятие адреса со стека)
;установит переменную GIF_IMG_ENDcode, если пойдёт блок с длиной 0, а пока дочитываем текущий блок
        GIFRETIFDISKERR
GIF_IMG_ENDcode=$+1
        LD A,0 ;/0xff, если встретился блок с длиной 0
        OR A
        jr z,GIF_IMG_END0 ;т.е. ещё не конец блока.
;встретился блок с длиной 0 - конец изображения

        ld bc,(curpichgt)
        ;jr $
        call gifpreparepic_skiplines
        
        ld hl,(nframes)
        inc hl
        ld (nframes),hl

gifconvertedframeaddr=$+1
        ld hl,0
gifconvertedframeaddrHSB=$+1
        ld a,0
        ld (gifoldconvertedframeaddr),hl
        ld (gifoldconvertedframeaddrHSB),a
         ;ld a,(nframes)
         ;cp 2
         ;ret z
        JP GIF_newframe ;следующий кадр
        
;bc=номер строки выхода
gifpreparepic_skiplines0
;TODO копировать прямо из памяти (окна 1,2) в память (окно 3)
         push bc
        call islinevisible ;nz=invisible
        jr nz,gifpreparepic_skiplines_invisible
        ld hl,(gifoldconvertedframeaddr)
        ld a,(gifoldconvertedframeaddrHSB)
        ld de,LINEPIXELS
        ld bc,(keepframe_linesize_bytes)
        call getfrommem ;берём сконверченную строку из предыдущего кадра
        call nextoldconvertedframeaddr ;смещаем адрес, откуда брать сконверченную строку из предыдущего кадра (gifoldconvertedframeaddr)
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS, смещаем адрес, куда класть (keepframeaddr)
         call nextscreenline
         call nextputlineaddr
gifpreparepic_skiplines_invisible
        call inccury
         pop bc
gifpreparepic_skiplines
;вход тут
        ld hl,(cury)
        or a
        sbc hl,bc
        jr nz,gifpreparepic_skiplines0
        ;call gifsetpgLZW
        ret

nextoldconvertedframeaddr
gifoldconvertedframeaddr=$+1
        ld bc,0
gifoldconvertedframeaddrHSB=$+1
        ld a,0
        ld hl,(keepframe_linesize_bytes)
        add hl,bc
        adc a,0
        ld (gifoldconvertedframeaddr),hl
        ld (gifoldconvertedframeaddrHSB),a
        ret

DX_IMG  DEFW 0  ;размер отдельного изображения
DY_IMG  DEFW 0
;===========================
;затычка для неиспользуемых строк (вызывается только в двух местах)
PUTCHAR_DUMMY
        exx
        cpi
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
giftransparencyflag=$
         jr z,PUTCHARtransparent ;/ld l,
GIFTRANSP_on=0x28 ;"jr z"
GIFTRANSP_off=0x2e ;"ld l"
         ;nop ;4t = 0.1 s
putchar_palH=$+1
        ld h,PAL_GLOB/256
        ld l,a
        ld a,(hl)
        ld (de),a
        inc de
        inc h
        ld a,(hl)
        ld (de),a
        inc de
        inc h
        ldi
        exx
        ret pe ;строка не кончилась
PUTCHARendline
;end of line
        push bc
        push de
        push hl
        call inccury
PUTCHARputaddr=$+1
        jp 0 ;jr nz,PUTCHARskipline
PUTCHARputline
        ld bc,(curpicwidx3)
        ld hl,LINEGIF
;hl=откуда копируем строку
;bc=сколько байт копируем
        push hl
        call putline ;TODO для анимированных ;кладёт в bmp
        pop hl
        call drawscreenline_frombuf ;конвертируем LINEGIF в LINEPIXELS и выводим её на экран
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS
         ;call setpgtemp8000 ;drawscreenline_frombuf сама восстанавливает
         ;call setpgcode4000 ;drawscreenline_frombuf сама восстанавливает
        call nextoldconvertedframeaddr ;смещаем адрес, откуда брать сконверченную строку из предыдущего кадра (gifoldconvertedframeaddr)
PUTCHARskipline
        call PUTCHARgetline_ifvisible ;берём строку из bmp, если она видимая и если надо рисовать поверх ;устанавливает PUTCHARaddr
        call gifsetpgLZW
        pop hl
        pop de
        pop bc
        exx
        ld bc,(DX_IMG) ;локальная ширина
linebufstart_local=$+1
        ld de,0 ;локальное начало строки
        exx
        ret

PUTCHARgetline_ifvisible
;устанавливает PUTCHARaddr, PUTCHARputaddr
         ld hl,PUTCHAR_DUMMY
         ld de,PUTCHARskipline
        call islinevisible ;nz=invisible
        jr nz,PUTCHARgetline_ifvisibleq
;getline, если DX_IMG!=curpicwid или если есть прозрачность ;TODO делать эту проверку один раз за кадр
         ld hl,(DX_IMG)
         ld de,(curpicwid)
         or a
         sbc hl,de
        ld bc,(curpicwidx3)
        ld de,LINEGIF
        jr nz,PUTCHARgetline
;de=куда достаём строку
;bc=сколько байт достаём
        ld a,(giftransparencyflag)
        cp GIFTRANSP_off
PUTCHARgetline
        call nz,getline ;TODO для анимированных: если не первый кадр, прочитать строку из памяти в LINEGIF (чтобы рисовать поверх неё)
         ld hl,PUTCHAR
         ld de,PUTCHARputline
PUTCHARgetline_ifvisibleq
         ld (PUTCHARaddr),hl
         ld (PUTCHARaddr2),hl
         ld (PUTCHARputaddr),de
        ret

;__________________________________
PUTSTRING
;выводит цепочку с нач. адресом в HL в поток символов
;out: А=первый символ этой цепочки
;портит bc,de,hl
;использует буфер по адресу -1..-4096
        ld bc,0
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
        jp nz,PUTSTR0 ;пока не перейдём к корневой цепочке
PUTSTR2 ld a,(bc)
PUTCHARaddr=$+1
        call PUTCHAR
        inc c
        jp nz,PUTSTR2
        inc b
        jp nz,PUTSTR2
         ld a,(de) ;первый символ цепочки
        ret

;________________________________________________
LZW_INSTALL
;Инсталляция таблицы цепочек в 0xc000
;Структура таблицы - трёхбайтные элементы:
;  1,x-начальный (корневоЙ) элемент таблицы (при LZW_SIZE=8 всего их будет 256)
;  0,0-элемента не существует
;  0,1-код очистки
;  0,2-код завершения данных EOI
;  остальные величины означают адрес, по которому сидит предыдущий элемент цепочки +256
;и третий байт - собственно сам символ
        ld hl,0xc000
        push hl
        ld de,0xc001
        ld bc,0x3fff
        ld (hl),l;=0
        ldir
LZW_SIZE=$+1
        ld b,0 ;начальный размер кода LZW (расширяться будет не здесь, а в LZW_SIZW)
        ld hl,1
        add hl,hl
        djnz $-1
        LD C,L
        LD B,H
        INC HL
        INC HL
        LD (NEW_COD1+1),HL
        pop hl ;0xc000
        xor a
        ld e,a;0
LZW_INS1
        LD (HL),1;0
        INC HL
        LD (HL),a;0
        INC HL
        LD (HL),E
        INC E
        cpi
        jp pe,LZW_INS1
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
        ld b,a
         add a,a
         add a,ROL_TAB/256-2
        LD (LZW_SIZW),A ;1..12 *2 +(ROL_TAB/256-2)
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
        ld a,(LZW_SIZW) ;1..12 *2 +(ROL_TAB/256-2)
         sub ROL_TAB/256-2
         rrca
        cp 12
        adc a,0
        ;JR NC,$+3
        ; INC A
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
GETCODE_ ;читает код в HL с заданным количеством бит (см. LZW_SIZW)
GETCOD00 LD L,0 ;оставшиеся данные.
        ld a,lx ;количество бит в наличии *2
        or a;ADD A,A
        JP NZ,GETCOD1
        GIFGETCHAR
        LD L,A
        LD (GETCOD00+1),A
        LD A,16;8
         ld lx,a
         ;add a,a
GETCOD1
        ADD A,ROL_TAB/256-2
        LD H,A

       ;LD A,lx ;количество бит в наличии *2
       SUB 0
LZW_SIZW=$-1 ;текущий размер кода LZW *2 +1 +(ROL_TAB/256-2)
        JR NC,GETCODneed0bytes ;имеем достаточно бит в наличии
        ADD A,16;8
        jr nc,GETCODneed2bytes ;надо взять дополнительно 2 байта
;GETCODneed1byte
;надо взять дополнительно 1 байт (самый частый случай)
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
        ;JP GETCODq
GETCODq
GETCODmasklow=$+1
        and 0
        LD L,A
GETCODmaskhigh=$+1
        LD A,0
        AND d
        LD H,A
        RET ;NC=OK, HL=код
GETCODneed2bytes
;надо взять дополнительно 2 байта
        ADD A,16;8
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
        JP GETCODq
GETCODneed0bytes
;имеем достаточно бит в наличии
        LD lx,a;(GETCOD0+1),A ;количество бит в наличии
        LD D,0
        ld a,(hl)
        JP GETCODq
;________________________________________
GIF_LOGSCR
;обработка дескриптора картинки
         ld a,PAL_GLOB/256
         ld (putchar_palH),a
        GIFINITCY
        GIFGETWORD
        call setpicwid
        GIFGETWORD
        call setpichgt
        
        ld hl,(freemem_hl)
        ld (gifrasteraddr),hl
        ld a,(freemem_a)
        ld (gifrasteraddrHSB),a
        call reserve_bmp_pages ;TODO для анимированных
        call reservefirstframeaddr
        
        GIFINITCY
        GIFGETBYTE ;d7=palette on, d6..d4=bits of color resolution(add 1), d3=0, d2..d0=bits/pixel in image(add 1)
        LD C,A
        GIFGETBYTE
        LD (gifbgcolor),A
        GIFGETBYTE ;aspect ratio? (0 in GIF87)
        LD A,C
        LD HL,PAL_GLOB
        ;JP GIF_PAL
;_______________________________
GIF_PAL
;чтение палитры
;HL=адрес, куда класть палитру (768 b), А=флаг палитры (7) и число цветов (2..0)
        OR A
        ret p ;нет палитры
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
;zajchik.gif - в локальных палитрах последний цвет чёрный
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
GIF_HEAD0 db "IF87a"
GIF_HEAD1 db "IF89a"

GIFSEARCH
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
        scf
        ret nz ;CY=fail
GIFSEARCH1
        INC HL
        INC DE
        DJNZ GIFSEARCH0
        XOR A ;OK
        RET 

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
