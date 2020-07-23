
ldirinpages;Z6542
;hl=откуда (логический адрес в буфере сохранения)
;bc=сколько
;TODO ускорить
        LD A,C
        OR B
        RET Z ;TODO надо ли?
         ;DI 
         ;CALL 8020
        ;JP C,_Z6545
        ; LD A,4
        ; CALL ON_BANK
        ; JP START_1

Z6546=$+1 ;сколько байт сохранить (это же текущий адрес в буфере, т.е. куда копировать)
        LD DE,0

        if depkbuf
        push bc
        ld bc,depkbuf
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
        pop bc
ldirinpages0
        ld a,(hl)
        CALL CRC32_
        ldi
        jp pe,ldirinpages0
        ld hl,-depkbuf
        add hl,de
        ld (Z6546),hl
        ret
        ;bit 7,h
        ;ret z
        ;jp saveblock ;save whole buffer
        
        else

        PUSH HL,DE
        LD A,D
        LD (SAVED+1),A
        LD A,H
        LD (SAVEH+1),A
        
        if depkbuf
        add a,depkbuf/256
        LD H,A
        else
        RLCA 
        RLCA 
        AND 3
        LD (BANKH+1),A
        CALL ON_BANK
        LD A,H
        OR #C0
        LD H,A
        endif
        
        LD (ADRH+1),HL
        LD A,(HL)
        EXA 
        LD A,D

        if depkbuf
        add a,depkbuf/256
        LD D,A
        else
        RLCA 
        RLCA 
        AND 3
        LD (BANKD+1),A
        CALL ON_BANK
        LD A,D
        OR #C0
        LD D,A
        endif
        
        LD (ADRD+1),DE
        EXA 
        LD (DE),A
        CALL CRC32_
        POP DE,HL
        INC DE
        LD A,D
        INC A
        JR Z,SV1
WOZW1   CPI 
        JP PO,AFN5
ADRH    LD HL,0
ADRD    LD DE,0
AFN2    INC L
        JR Z,SAVEH
AFN1    INC E
        JR Z,SAVED
AFN3    LD A,B
        OR C
        JR Z,AFN4

        if depkbuf==0
BANKH   LD A,0
        CALL ON_BANK
        endif

        LD A,(HL)

        if depkbuf==0
        EXA 
BANKD   LD A,0
        CALL ON_BANK
        EXA 
        endif

        LD (DE),A
        CALL CRC32_
        DEC BC
        JP AFN2

SAVEH   LD A,0
       INC A,A
       JR Z,$+3
       DEC A
        LD H,A
        LD (SAVEH+1),A

        if depkbuf==0
        RLCA 
        RLCA 
        AND 3
        LD (BANKH+1),A
        LD A,H
        OR #C0
        LD H,A
        endif
        JR AFN1

SAVED   LD A,0
        INC A
        LD D,A
        if buf64k
        INC A
        else
        cp 0x80
        endif
        JR Z,SV2 ;save whole buffer
WOZWR2  LD A,D
        LD (SAVED+1),A

        if depkbuf==0
        RLCA 
        RLCA 
        AND 3
        LD (BANKD+1),A
        LD A,D
        OR #C0
        LD D,A
        endif
        LD (ADRD+2),A
        JR AFN3

AFN4    LD A,(SAVED+1)
        LD D,A
AFN5    LD (Z6546),DE ;сколько байт сохранить
        ret
        ;LD A,4
        ;CALL ON_BANK
        ;CALL COUNT ;процентомер?
        ;LD A,5
        ;JP ON_BANK

SV1     CALL SV0
        LD A,D
        DEC A
        LD (SAVED+1),A

        if depkbuf==0
        RLCA 
        RLCA 
        AND 3
        LD (BANKD+1),A
        LD A,D
        OR #C0
        LD D,A
        endif
        LD (ADRD+2),A
        LD E,-1 ;на случай выхода в AFN5
        JP WOZW1

SV2     CALL SV0
        JR WOZWR2

SV0     LD (Z6546),DE ;сколько байт сохранить
        ;LD A,5
        ;CALL ON_BANK
        CALL saveblock ;save whole buffer
        LD DE,(Z6546) ;сколько байт сохранить (=0?)
        RET 

        endif
 
;запись одного байта в память + обновление CRC32 + при необходимости сохранение
SBYTE
;a=byte
        PUSH HL
        LD HL,(Z6546) ;сколько байт сохранить (он же текущий адрес, куда писать)
        PUSH HL

        if depkbuf
        exa
        ld a,h
        add a,depkbuf/256
        ld h,a
        exa
        else
        EXA 
        LD A,H
        RLCA 
        RLCA 
        AND 3
        CALL ON_BANK
        LD A,H
        OR #C0
        LD H,A
        EXA 
        endif
        LD (HL),A
        CALL CRC32_
        POP HL
        INC HL
        ;LD A,H
        ;AND A
        ;JR NZ,CON2
        ;LD A,L
        ;CP #11
        ;CALL Z,HOBETA1
;CON2    
        LD (Z6546),HL ;сколько байт сохранить
        ;LD A,5
        ;CALL ON_BANK
        LD A,H
        if buf64k
        INC A
        else
        cp 0x80
        endif
        POP HL
        RET NZ

        jp saveblock



;ИНИЦИАЛИЗАЦИЯ ДЕПAKEPA
initdepk=initCRC;Z6629

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

;метод store
ZD102
        LD A,B
        CP 8
        CALL NZ,read_a_bits
        EX DE,HL ;??? (hl=0x802b) длина блока
        CALL readbyte_d
        LD E,D
        CALL readbyte_d ;??? (de=0x7fd4)
        LD A,D
        XOR H
        LD D,A
        LD A,E
        XOR L
        AND D
        INC A
        call NZ,depkqerror ;save whole buffer и выйти
           ;CALL readbyte_d
           EX DE,HL

;ZD11F=$+1
        ;LD HL,0

        ;DEC HL
_ZD122   
        ;LD A,(HL)
        ;INC HL
         ;push hl
         ;LD HL,(Z6546)
         ;bit 7,h
         ;jr nz,$
         ;pop hl
        ziprdbyte
        CALL SBYTE ;запись одного байта в память + обновление CRC32 + при необходимости сохранение
        ;PUSH HL
        ;LD BC,#4001
        ;ADD HL,BC
        ;POP HL
       ;JR NC,ZD135
       ;CALL LBLOKZIP
       ;LD HL,BUFER
;ZD135   
        DEC DE
        LD A,D
        OR E
        JR NZ,_ZD122
        ;LD (ZD11F),HL
        POP DE ;снимаем адрес возврата
        JR _ZD14D ;читаем следующий блок

;ZD140
INFLATING
;init read buffer, inflate file
        XOR A
        LD (_ZD159),A ;не последний блок
        ;CALL LBLOKZIP
       ;LD HL,0
       ; LD (U6546),HL ;сколько байт сохранить = текущий адрес в буфере
_ZD14D 
        ;LD HL,(ZD11F)
        ;LD E,(HL)
        ;INC HL
        ;LD (ZD11F),HL
        ziprdbyte
        ld e,a
        CALL readbyte_d ;установит b=8

_ZD158 ;сюда попадаем по коду 256 (end of block)
        ;push hl
        ;ld hl,(Z6546)
        ;jr $
        ;pop hl
_ZD159=$+1
        LD A,0 ;1 = был последний блок
        OR A
        jp NZ,savelastblock ;save (U6546) bytes, выход
        CALL readbit_de ;1 = last block, 0 = not last block
        LD HL,_ZD159 ;см. выше
        RR (HL)
        CALL readtrees;ZD2E4
_ZD168  
         ;push de
         ;push hl
          ;LD HL,(Z6546)
          ;bit 7,h
          ;jr nz,$ ;почему-то не попадаем сюда
         ;ld hl,(Z6546)
         ;ld de,0x53c7;0x546f
         ;or a
         ;sbc hl,de
         ;jr nc,$
         ;pop hl
         ;pop de
        CALL readcodetree1 ;out: hl=code
        ;jr $
         LD A,H
         OR A
         JR NZ,_ZD175 ;если код - не байт
        LD A,L ;байт
        CALL SBYTE ;запись одного байта в память + обновление CRC32 + при необходимости сохранение
        JR _ZD168
_ZD175  DEC A
        OR L
;256: end of block - stop processing if last block, otherwise start processing next block.
;257-285: combined with extra-bits, a match length of 3-258 bytes.
;286, 287: not used, reserved and illegal but still part of the tree.
         ;jr z,$ ;не доходим сюда на adv 1,2, а в adv3 его нет в первом блоке
         ;push hl
         ;LD HL,(Z6546)
         ;pop hl
        JR Z,_ZD158 ;если 256 (end of block), то назад на чтение заголовка блока и деревьев
        ;jr $
        
        DEC H
        INC HL,HL
        PUSH HL ;2+(код-256) = сколько
        CALL readcodetree2 ;distance
        INC HL
        POP AF
        PUSH BC,DE,AF
        POP BC ;2+(код-256) = сколько
        EX DE,HL ;de=код по tree2 (расстояние?)
        LD HL,(U6546) ;сколько байт сохранить = текущий адрес в буфере
       OR A
        SBC HL,DE
        JR NC,_ZD1B5 ;расстояние умещается внутри несохранённого блока?
        EX DE,HL ;de = -сколько байт не хватает?
       LD HL,0
       OR A
        SBC HL,DE ;сколько байт не хватает?
        PUSH HL
        LD HL,#2121
TD198=$-2 ;сколько байт сохраняли в прошлый раз
        ADD HL,DE ;hl = сколько байт сохраняли - сколько байт не хватает? (получается адрес в прошлом буфере?)
        POP DE
        EX DE,HL ;de=адрес в прошлом буфере?, hl=сколько байт не хватает?
        PUSH HL ;сколько байт не хватает?
       CP A
        SBC HL,BC ;NC=блок не пересекает границу старого и нового буферов (сколько байт не хватает >= сколько)
        POP HL ;сколько байт не хватает?
        EX DE,HL
        JR NC,_ZD1B5 ;если блок не пересекает границу старого и нового буферов, то откуда = адрес в прошлом буфере?
        EX DE,HL
        PUSH BC
        EX (SP),HL
        POP BC ;hl=сколько, bc=сколько байт не хватает?
       AND A
        SBC HL,BC
        PUSH HL ;сколько-сколько байт не хватает
        EX DE,HL ;hl=адрес в прошлом буфере, bc=сколько байт не хватает?
        CALL ldirinpages ;скопировали первый кусок в текущий адрес в буфере ;TODO разрезать на 2 части при пересечении 32К
        LD HL,0 ;продолжение будем копировать из начала нового буфера
        POP BC ;длина продолжения (сколько-сколько байт не хватает)
;TODO сделать настоящее скользящее окно 32К, т.к. Relative back-references can be made across any number of blocks, as long as the distance appears within the last 32 KiB of uncompressed data decoded (termed the sliding window)
_ZD1B5  
;hl = откуда (логический адрес в буфере)
;bc = сколько
        CALL ldirinpages ;копируем в текущий адрес в буфере ;TODO разрезать на 2 части при пересечении 32К
        LD A,(Z6546+1) ;(Z6546) = сколько байт сохранить = текущий адрес в буфере
        if buf64k
        CP -1
        else
        CP 0x80
        endif
        CALL NC,saveblock ;save whole buffer ;буфер на [64K]32K, надо сохранить и создать новый буфер ;TODO зациклить окно
        POP DE
        POP BC
        JR _ZD168 ;читаем следующий код

;?
       ;DS 10
;какие-то стандартные длины кодов
;256: end of block - stop processing if last block, otherwise start processing next block.
;257-285: combined with extra-bits, a match length of 3-258 bytes.
;286, 287: not used, reserved and illegal but still part of the tree.
;TODO почему тут всего 19 стандартных длин, а не 28?
TD1EE   db #10,#11
        db #12,0
        db 8,7
        db 9,6
        db #A,5
        db #B,4
        db #C,3
        db #D,2
        db #E,1
        db #F ;,1 ;#F заходил на следующий сегмент, а 1 был частью TD201 ;читается максимум 19 байт, т.е. до #F включительно (в gunzip нет 1)
        
        align 256
         db 0 ;чтобы на 1 байт позже
TD201   DB 1,3,7,#F,#1F,#3F,#7F,-1 ;маски
;?
TD209  DS 34;70 ;туда пишется 32 байта (2-байтные счётчики, сколько раз встретилась каждая длина кода 0..15)
TD22B  ds 70-34 ;с #xx2d лежат 2-байтные начальные коды для каждой длины кода (1..15)

get_a_bits_tohl;ZD24F
        CP 9
        JR C,_ZD262
        SUB 8
        LD H,A
        LD A,8
        CALL get_a_bits
        LD L,A
        LD A,H
        CALL get_a_bits
        LD H,A
        RET 
_ZD262  CALL get_a_bits
        LD H,0
        LD L,A
        RET 

get_a_bits;ZD269
;a=число бит, b=число бит d в наличии, de=данные в наличии
;out: a=число из e (младшие биты по маске количества бит)
        LD (_ZD26E),A
        EXA 
_ZD26E=$+1
        LD A,(TD201) ;a=маска 0x01,0x03,0x07...0xff (для 1,2,3...8)
        AND E
        PUSH AF
        EXA 
        CALL read_a_bits
        POP AF
        RET 

readbit_de;ZD278
;"читать бит" (текущие биты в de, b=число верных битов d)
;out: CY=вылетевший младший бит de
        SRL D
        RR E
        DEC B
        RET NZ
readbyte_d;ZD27E
;читать байт в d, установить b=8
;TODO макрос и без push af
        PUSH AF
        ;push HL
        ;push BC
        ;LD HL,(ZD11F)
        ;LD BC,#4001
        ;ADD HL,BC
        ;POP BC
        ;CALL C,LBLOKZIP
        ;LD HL,(ZD11F)
        ;LD D,(HL)
        ;INC HL
        ;LD (ZD11F),HL
        ziprdbyte
        ld d,a
        LD B,8
        ;POP HL
        pop AF
        RET 

;a=число бит (бывает 8)
;b=число бит d в наличии
;de=имеющиеся данные (e - самые старые)
read_a_bits;ZD299
        CP B ;сколько бит в d
        JR C,_ZD2A6 ;в d достаточно бит
_ZD29C   SRL D
        RR E
        DEC A
        DJNZ _ZD29C
        CALL readbyte_d
        ;теперь в d имеется 8 бит, b=8, a уменьшено на сколько имелось бит
_ZD2A6  OR A
       RET Z ;выходим, когда прочитали нужное количество бит
        SRL D
       RR E
        DEC A
        DJNZ _ZD2A6
;сюда можно попасть только при a >= 8+сколько имелось бит
;строим деревья по умолчанию (коды 0..127 по 8 бит, 128..255 по 9 бит и т.д.)
;b=0
;a=сколько бит не хватило (может быть 0)
_ZD2AF   PUSH BC,DE
        LD HL,ziptrees ;длины кодов первого дерева?
        LD BC,#9008
_ZD2B7  LD (HL),C
        INC HL
        DJNZ _ZD2B7
        LD BC,#7009 ;...продолжение
_ZD2BE  LD (HL),C
        INC HL
        DJNZ _ZD2BE
        LD BC,#1807
_ZD2C5  LD (HL),C
        INC HL
        DJNZ _ZD2C5
        LD BC,#808
_ZD2CC  LD (HL),C
        INC HL
        DJNZ _ZD2CC
        LD HL,ziptrees+#140 ;длины кодов второго дерева?
        LD BC,#2005
        LD A,B ;32
_ZD2D7  LD (HL),C
        INC HL
        DJNZ _ZD2D7
        LD (ZD3C8),A ;число кодов второго дерева?
        LD (ZD3B8),A ;число кодов первого дерева (-256)?
        JP gentrees;ZD3B7 ;построить 2 дерева?

readtrees;ZD2E4
        LD A,2
        CALL get_a_bits ;читаем метод
        DEC A
        JP M,ZD102 ;00 = stored/raw/literal section, between 0 and 65,535 bytes in length
        JR Z,_ZD2AF ;01 = static Huffman compressed block, using a pre-agreed Huffman tree
        DEC A
        call NZ,depkqerror ;11 = ошибка, save whole buffer и выйти
;10 = compressed block complete with the Huffman table supplied
        LD A,5
        CALL get_a_bits
        INC A
        LD (ZD3B8),A ;число кодов первого дерева (-256)
        LD A,5
        CALL get_a_bits
        INC A
        LD (ZD3C8),A ;число кодов второго дерева
        LD HL,ziptrees+#560 ;почему сюда кладутся длины кодов??? TODO
        LD A,#13
_ZD30A  LD (HL),0
        INC HL
        DEC A
        JR NZ,_ZD30A
        LD A,4
        CALL get_a_bits
        ADD A,4 ;4..19 кодов
        LD C,A
        LD HL,TD1EE
_ZD31B  LD A,3
        CALL get_a_bits
        PUSH DE
        LD E,(HL)
        LD D,0
        PUSH HL
        LD HL,ziptrees+#560 ;почему сюда кладутся длины кодов??? TODO
        ADD HL,DE
        LD (HL),A
        POP HL,DE
        INC HL
        DEC C
        JR NZ,_ZD31B
        PUSH BC
        push DE
        LD HL,ziptrees+#160 ;там будет лежать первое дерево
        LD DE,ziptrees+#560 ;почему отсюда берутся длины кодов??? TODO
        LD BC,#13
        CALL gentree
        LD HL,(ZD3B8) ;число кодов первого дерева
        LD DE,(ZD3C8) ;число кодов второго дерева
        ADD HL,DE
        DEC HL
        POP DE
        pop BC
        LD IX,ziptrees ;длины кодов первого дерева (реально прочитаем оба (там место с запасом), потом перебросим остаток длин)
ZD34D   PUSH HL,DE
       LD D,0
        LD HL,ziptrees+#160 ;первое дерево
       ADD HL,DE
       ADD HL,DE
       LD E,(HL)
        LD HL,ziptrees+#560 ;длины кодов???
       ADD HL,DE
        LD A,(HL)
       LD C,E
        POP DE
        CALL read_a_bits
        LD A,C
        POP HL
        CP #10
        JR NC,ZD36C
;< #10: это будет длина кода, пишем её
        LD C,A ;длина кода?
        LD A,1 ;число повторов
        JR _ZD390

ZD36C   JR NZ,ZD37A
;= #10: пишем 3..6 предыдущих длин
        LD A,2
        CALL get_a_bits
        ADD A,3 ;число повторов
        LD C,(IX-1) ;длина кода?
        JR _ZD390

ZD37A   CP #11
        JR NZ,_ZD387
;= #11: пишем 3..10 длин 0
        LD A,3
        CALL get_a_bits
        ADD A,3
        JR _ZD38E

_ZD387
;> #11: пишем 11..138 длин 0
        LD A,7
        CALL get_a_bits
        ADD A,#B ;число повторов
_ZD38E  LD C,0
_ZD390  LD (IX),C ;длина кода
        INC IX
        DEC A
        DEC HL
        JR Z,ZD3A0
        BIT 7,H
        call NZ,depkqerror ;save whole buffer и выйти
        JR _ZD390

ZD3A0   BIT 7,H
        JR Z,ZD34D
        PUSH BC
        push DE
        LD HL,ziptrees ;длины кодов первого дерева
        LD DE,(ZD3B8) ;число кодов первого дерева
        ADD HL,DE
        LD DE,ziptrees+#140 ;длины кодов второго дерева
        LD BC,(ZD3C8) ;число кодов второго дерева
        LDIR ;TODO lddr и убрать запас после ziptrees, или предавать указатель на длины кодов второго дерева в gentrees

gentrees;ZD3B7
;на стеке de,bc
ZD3B8=$+1 ;пишется 1 байт
        LD BC,#100 ;число кодов первого дерева
        LD DE,ziptrees ;длины кодов первого дерева
        LD HL,ziptrees+#160 ;там будет лежать первое дерево
        LD IX,ziptrees+#560
        CALL gentree
ZD3C8=$+1
        LD BC,0 ;число кодов второго дерева ;обычно 32
        LD DE,ziptrees+#140 ;длины кодов второго дерева
        LD HL,ziptrees+#360 ;там будет лежать второе дерево
        LD IX,ziptrees+#9E0
        CALL gentree
        POP DE
        pop BC
        RET 

;построение дерева
;de=длины кодов
;hl=адрес, где будет лежать дерево
;ix=? (записывается в (ZD523) - что-то для кодов длиннее 8)
;bc=число кодов = #100+(ZD3B8) для первого дерева, (ZD3C8) для второго (обычно 32)
gentree;ZD3DA
        LD A,B
        OR C
        RET Z
        LD (ZD443),BC ;число кодов
        LD (ZD4A9),HL

;очищаем, сколько раз встретились коды каждой длины (0..15)
        LD HL,TD209
        PUSH HL
        push BC
        LD BC,#2000
_ZD3EC  LD (HL),C;0
        INC HL
        DJNZ _ZD3EC
        POP BC
        pop HL

        PUSH DE ;длины кодов

;считаем, сколько раз встретились коды каждой длины (0..15)
_ZD3F3  LD A,(DE)
        INC DE
        ADD A,A
         ADD A,9 ;TD209
         LD L,A
        INC (HL)
        JR NZ,_ZD3FE
        INC HL
        INC (HL)
_ZD3FE  DEC BC
        LD A,B
        OR C
        JR NZ,_ZD3F3
;теперь в TD209 лежат 2-байтные значения, сколько раз встретились коды каждой длины (0..15)

       LD L,#2D ;TD22B+2
       LD (HL),C;0
       INC HL
       LD (HL),C;0 ;начальный код для длины 1 ;TODO ld (TD22B+2),bc
        
         PUSH BC;0 ;текущий код?
         
        LD BC,#F02 ;перебираем длины кодов 1..15
_ZD40C  LD A,C ;длина кода*2
         ADD A,9 ;TD209
         LD L,A
        LD E,(HL)
        INC HL
        LD D,(HL) ;de=сколько раз встретилась эта длина кода
         EX (SP),HL
        ADD HL,DE
        ADD HL,HL
        LD E,L
        LD D,H ;какой-то магией формируем текущий код из предыдущего
         EX (SP),HL
        INC C
        INC C
        LD A,C
         ADD A,#2B ;TD22B
         LD L,A
        LD (HL),E
        INC HL
        LD (HL),D ;начальный код для заданной длины кода
        DJNZ _ZD40C
        
         POP DE ;текущий код?
         
        LD A,D
        OR E
        JR Z,ZD440 ;последний начальный код должен получиться 0 (т.е. все варианты в бинарном дереве использованы)
;ошибочное дерево?
       LD D,B
       LD E,B;de=0
        LD A,#F
         LD L,#B ;TD209+2
_ZD42F  LD C,(HL)
        INC HL
        LD B,(HL) ;сколько раз встретился код этой длины
        INC HL
        EX DE,HL
        ADD HL,BC
        EX DE,HL
        DEC A
        JR NZ,_ZD42F
;de=количество ненулевых длин кодов -2
       LD HL,-2
       ADD HL,DE
        call C,depkqerror ;если кодов более 1, save whole buffer и выйти (ошибочное дерево? в архиве с адвентюрерами - на каждом большом файле)
;всего 1 код используется - считаем, что не ошибка, что не получилось построить дерево из 1 кода?
ZD440   
        POP DE ;длины кодов
        PUSH DE ;длины кодов

ZD443=$+1
        LD BC,0 ;число кодов

        LD HL,ziptrees+#A60 ;сюда положим все коды по 2 байта на код
_ZD448  LD A,(DE) ;длина кода
        INC DE
        PUSH DE
        ADD A,A
        LD E,A
        LD D,A
        JR Z,__ZD45F ;длина кода=de=0
;берём код номер "длина кода" в de (и инкрементируем его там, где он лежал)
        PUSH HL
       LD H,TD209/256;UD2
       ADD A,#2B ;TD22B
        LD L,A
        LD E,(HL)
        INC HL
        LD D,(HL)
        INC DE
        LD (HL),D
        DEC HL
        LD (HL),E
        DEC DE
        POP HL
__ZD45F LD (HL),E
        INC HL
        LD (HL),D
        INC HL
        POP DE
        DEC BC
        LD A,C
        OR B
        JR NZ,_ZD448
        
        POP DE ;длины кодов
        PUSH DE ;длины кодов

        LD HL,ziptrees+#A60 ;все коды по 2 байта на код
        LD BC,(ZD443) ;число кодов
_ZD472  LD A,(DE)
        INC DE
        DEC A
        JP M,_ZD4A1 ;код длиной 0 (неиспользуемый) - пропускаем
        JR Z,_ZD4A1 ;код длиной 1 - пропускаем
        PUSH DE
        LD E,(HL)
        INC HL
        LD D,(HL) ;берём код
        PUSH HL
        LD HL,0
;начинаем переворачивать код, сначала длинакода-1 битиков:
_ZD482  SRL D
        RR E
        ADC HL,HL
       EXA 
        LD A,D
        OR E
        JR Z,_ZD493 ;код кончился
       EXA 
        DEC A
        JR NZ,_ZD482
        INC A ;a=1: сдвинем потом ещё на 1 битик
       EXA 
_ZD493 EXA 
;сдвинем на несколько оставшихся битиков:
        RR E
_ZD496  ADC HL,HL
        DEC A
        JR NZ,_ZD496
        EX DE,HL
        POP HL
        LD (HL),D
        DEC HL
        LD (HL),E ;записали перевёрнутый код
        POP DE
_ZD4A1  INC HL
        INC HL
        DEC BC
        LD A,C
        OR B
        JR NZ,_ZD472

ZD4A9=$+1
        LD HL,0 ;адрес дерева
        LD E,L
        LD D,H
        INC DE
        LD BC,#1FF
        LD (HL),A;0
        LDIR ;очистили 512 байт (TODO почему не больше? литералов может быть больше 256!)
        
        POP HL ;длины кодов
        
        LD BC,(ZD443) ;число кодов
        DEC BC
        ADD HL,BC
        EX DE,HL ;de=указатель на длину последнего кода

        LD (ZD523),IX ;какой-то адрес для кодов длиннее 8

        LD HL,ziptrees+#A60+1 ;все коды по 2 байта на код (уже перевёрнутые)
        ADD HL,BC
        ADD HL,BC ;указатель на последний байт последнего кода
;генерируем дерево:
_ZD4C5   
;bc=литерал
        LD A,(DE)
        DEC DE
        OR A
        JR Z,_ZD503 ;код длиной 0 (неиспользуемый) - пропускаем
        CP 9
        PUSH DE
        LD D,(HL)
        DEC HL
        LD E,(HL) ;de=код
         INC HL
        PUSH HL ;TODO выше
        JR NC,_ZD50B ;код не умещается в 1 байт - используем буфер ix+...
;код умещается в 1 байт
        LD HL,1
        INC A ;1..9
_ZD4D8  ADD HL,HL
        DEC A
        JR NZ,_ZD4D8
        EX DE,HL ;de=1<<(1..9)
        ADD HL,HL ;код*2
        LD A,(ZD4A9) ;адрес дерева
        ADD A,L
        LD L,A
        LD (__ZD4FE),A ;это и...
        LD A,(ZD4A9+1)
        ADC A,H
        LD H,A
       INC A,A
        LD (__ZD4F7),A ;...это задаёт адрес выхода (адрес дерева + код*2 + 512)
        DEC DE
;кладём литерал в дерево
_ZD4F1  LD (HL),C
        INC HL
        LD (HL),B ;кладём литерал
        ADD HL,DE ;какой-то магией находим следующий адрес (адрес литерала + код*2)
         LD A,H
__ZD4F7=$+1
         CP 0
         JR C,_ZD4F1
         JR NZ,_ZD501
         LD A,L
__ZD4FE=$+1
         CP 0
        JR C,_ZD4F1 ;пока не дошли до адреса выхода, кладём этот литерал (TODO зачем много раз???)
_ZD501
        POP HL,DE
_ZD503
        DEC HL
        DEC HL ;предыдущий код
        DEC BC ;предыдущий литерал
        BIT 7,B
        JR Z,_ZD4C5
        RET 

_ZD50B
;код не умещается в 1 байт - используем буфер ix+...
;a=длина кода
;de=код
        SUB 8
        PUSH BC ;литерал
        LD B,A ;длина кода-8
        LD A,D
        LD D,0
        LD HL,(ZD4A9) ;адрес дерева
        ADD HL,DE
        ADD HL,DE
        LD C,1 ;некий бит для проверки старшего байта кода
        EXA 
_ZD51A  LD E,(HL)
        INC HL
        LD D,(HL) ;берём литерал из дерева по смещению 2*(код-256) (или адрес ix+... после прохода - см. ниже)
        DEC HL
        LD A,D
        OR E
        JR NZ,_ZD535 ;литерал уже заполнен!
;нулевой литерал (ещё не заполненный)
ZD523=$+1
        LD DE,0 ;сначала туда клали ix
        LD (HL),E
        INC HL
        LD (HL),D ;кладём этот адрес в дерево на место ещё не заполненного литерала
       LD H,D
       LD L,E
       LD (HL),A;0
       INC HL
       LD (HL),A;0
       INC HL
       LD (HL),A;0
       INC HL
       LD (HL),A;0 ;и кладём 4 нуля по этому адресу (на следующем проходе можем использовать первые два или последние два нуля, чтобы положить туда адрес литерала или литерал)
       INC HL
       LD (ZD523),HL ;обновляем бывший ix
_ZD535
        EX DE,HL ;hl=адрес = ix+... (или уже заполненный литерал)
        EXA 
        LD E,A ;старший байт кода
        AND C ;проверяем некий бит
        LD A,E ;старший байт кода
        JR Z,_ZD53E
        INC HL,HL ;если установлен, то адрес+2 (TODO а если это был литерал???)
_ZD53E  EXA 
        SLA C ;сдвигаем некий бит
        DJNZ _ZD51A ;попробуем следующий адрес или ещё раз этот же (TODO а что если это был литерал, а не ix+..., а битик не совпал - повторим с тем же адресом???)
        POP BC
        LD (HL),C
        INC HL
        LD (HL),B ;кладём литерал
        JR _ZD501 ;конец текущего кода

readcodetree1;ZD549
;de=имеющиеся данные
;out: hl=code
        PUSH DE
        XOR A
        LD D,A
        LD HL,ziptrees+#160+1 ;тут лежит первое дерево
        ADD HL,DE
        ADD HL,DE ;hl=адрес второго байта кода номер e в дереве
        OR (HL)
        DEC HL
        LD L,(HL)
        LD H,A
         if ziptrees>=0x8000
         else
         add a,a
         endif
        JP M,_ZD58C ;h bit 6 значит дерево, иначе hl=литерал
         PUSH HL
         LD DE,ziptrees ;длины кодов первого дерева???
         ADD HL,DE
         LD A,(HL) ;длина добавки кода для имеющегося hl???
         POP HL
         pop DE
_ZD560
;256: end of block - stop processing if last block, otherwise start processing next block.
;257-285: combined with extra-bits, a match length of 3-258 bytes.
;286, 287: not used, reserved and illegal but still part of the tree.
        CALL read_a_bits
        LD A,H
        OR A
        RET Z
        LD A,L
        CP 9
        RET C
        CP #1D
        LD HL,#200
        RET Z
        DEC A
        LD C,A
        SRL C
        SRL C
        DEC C
        AND 3
        ADD A,4
        LD H,L
        LD L,A
        LD A,C
_ZD57E   ADD HL,HL
        DEC C
        JR NZ,_ZD57E
        INC H
        CALL get_a_bits
        INC A
        ADD A,L
        LD L,A
        RET NC
        INC H
        RET 

_ZD58C  POP DE
        CALL ZD5CB ;читать 8 бит и пройти по ним дерево hl
        JR _ZD560

readcodetree2;ZD592
;de=имеющиеся данные
;out: hl=code
;The distance tree contains space for 32 symbols:
;0-3: distances 1-4
;4-5: distances 5-8, 1 extra bit
;6-7: distances 9-16, 2 extra bits
;8-9: distances 17-32, 3 extra bits
;...
;26-27: distances 8,193-16,384, 12 extra bits
;28-29: distances 16,385-32,768, 13 extra bits
;30-31: not used, reserved and illegal but still part of the tree.
;Note that for the match distance symbols 2-29, the number of extra bits can be calculated as [n/2]-1.
        PUSH DE
        XOR A
        LD D,A
        LD HL,ziptrees+#360+1
        ADD HL,DE
        ADD HL,DE
        OR (HL)
        DEC HL
        LD L,(HL)
        LD H,A ;h bit 6 значит дерево, иначе hl=литерал
         if ziptrees>=0x8000
         else
         add a,a
         endif
        JP M,_ZD5C5 ;читать 8 бит и пройти по ним дерево hl
         PUSH HL
         LD DE,ziptrees+#140 ;длины кодов второго дерева???
         ADD HL,DE
         LD A,(HL) ;длина добавки кода для имеющегося hl???
         POP HL,DE
_ZD5A9  CALL read_a_bits ;дочитываем столько бит, сколько прошагали?
        LD A,L ;литерал
        CP 4
        RET C
        RRA 
        DEC A
        LD C,A
        LD L,H
        RL L
        INC L,L
ZD5B8   ADD HL,HL
        DEC C
        JR NZ,ZD5B8
        PUSH HL
        CALL get_a_bits_tohl
        EX DE,HL
        EX (SP),HL
        ADD HL,DE
        POP DE
        RET 

_ZD5C5   POP DE
        CALL ZD5CB ;читать 8 бит и пройти по ним дерево hl
        JR _ZD5A9

ZD5CB
;читать 8 бит и пройти по ним дерево hl
;out: a=сколько бит реально прошагали, l=литерал?
        LD A,8
        CALL read_a_bits
        LD C,E ;эквивалентно ld a,8:call get_a_bits:ld c,a ?
;ходим по дереву hl, имея код C (младшие биты сначала)
        XOR A
ZD5D2   INC A
        RR C
        JR NC,ZD5D9
        INC HL
        inc HL
ZD5D9   LD (ZD5DD),HL
ZD5DD=$+1
        LD HL,(0) ;ok
         if ziptrees>=0x8000
         BIT 7,H
         else
         BIT 6,H ;h bit 6 значит дерево, иначе l=литерал
         endif
        JR NZ,ZD5D2
        RET 

;       ENT 

;END_DEP=$ 

U6546=Z6546 ;сколько байт сохранить = текущий адрес в буфере


