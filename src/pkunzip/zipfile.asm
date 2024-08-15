
depack        
;       JR NOSTART_
;START_
;YESAUTOEX=$+1
;       LD A,0
;       CP "U
;       JP Z,QUIT_
;NOSTART_
        LD (exit_sp),SP
START_1
        ;LD SP,#5FE6
        if 1==0
        LD HL,ANYKEY_P
        LD (MOD1+1),HL
        LD A,#C3
        LD HL,START_
        LD (MOD2),A
        LD (MOD2+1),HL
        LD HL,SPISOK+1
        LD (UKAZ1),HL
        ;XOR A
        ;LD (NO_HOB),A
        ;LD (HOB),A
        LD HL,T_KEY
        LD (MODECAT+1),HL
        CALL PRCAT

        LD A,#4F
        LD (TEKATR+1),A
        LD HL,0
        LD DE,#440
        CALL RAMKA
        LD HL,T6935
        CALL PRINTS_
        LD HL,T6935_
        CALL PRINTS_
        endif
        
;MANYF   LD HL,0
;        LD (ML_FLEN),HL
;        LD (ML_FLEN+1),HL
        ;CALL CLS_LINE
       if READZIPDIR
        ;jr $
        CALL PROWERKA ;ищем central directory, достаём таблицу файлов в CAT, заполняем переменные про файл
        
        if 1==0
        LD A,(SKIPING)
        OR A
        JR Z,NOSKIP1
        LD HL,T_KEY1
        LD (MODECAT+1),HL
        CALL VIEWCAT
        LD A,#4F
        LD (TEKATR+1),A
        LD HL,0
        LD DE,#440
        CALL RAMKA
        LD HL,T6935
        CALL PRINTS_
        LD HL,T6935_
        CALL PRINTS_
        LD HL,#400
        LD DE,#C40
        CALL RAMKA
NOSKIP1
        endif
        
        ;LD A,1
        ;LD (D_INST),A ;это было для инициализации TR-DOS после смены диска

        LD DE,0
LEN_KOM=$-2
        LD A,D
        OR E
        JR Z,PR700
        LD HL,#4000
        OR A
        SBC HL,DE
        JR C,PR700 ;комментарий > 0x4000?
        EX DE,HL
        LD DE,0 ;size of central directory
SM1=$-2
       if SEEK32BIT
        LD HL,(SME_ML) ;start of central directory
        ADD HL,DE
       push hl
        LD bc,0
SM2w=$-2
        LD hl,(SME_STw)
        ADC hl,bc
        ld b,h
        ld c,l
       pop hl
        LD DE,#16
        ADD HL,DE
        jr nc,$+3
        inc bc
;bchl=position in file
       else
        LD C,0
SM2=$-1
        LD HL,(SME_ML) ;start of central directory
        LD A,(SME_ST)
        ADD HL,DE
        ADC A,C
        LD DE,#16
       LD C,0
        ADD HL,DE
        ADC A,C
;ahl=position in file
       endif
        LD IX,BUFER
        LD DE,(LEN_KOM) ;комментарий может быть до 0x4000 (реально формат позволяет больше)
        CALL READ

        ;LD HL,TEXT20
        ;CALL PRINTS_
       endif

        if 1==0
        LD A,0
MEN=$-1
        OR A
        JR Z,NM1
        CALL INS_DEST

NM1     LD A,(DESTIN)
        CP "*"
        JR NZ,$+5
        LD A,(SOURCE)
        SUB #41
        LD C,1
        CALL TRDOS
        LD C,#18
        CALL TRDOS
        LD HL,FNAME1
        LD DE,23773
        LD BC,9
        LDIR 
        LD HL,BUFER
        LD DE,(LEN_KOM)
        LD C,#B
        CALL TRDOS
        LD A,(MEN)
        OR A
       JR Z,PR700
       CALL INS_SOURC
        endif
PR700   
        ;LD HL,TEXT21
        ;CALL PRINTS_
        
        LD HL,0
KOL_F=$-2
        ;XOR A
        ;LD IX,T_BUF
        ;CALL DS100
        ;LD HL,T_KOL_F
        ;CALL PRINTS_

nextfile
           ;LD A,5
           ;call ON_BANK 
        
        LD HL,0 ;start of central directory (сделал, чтобы он обновлялся с каждым новым файлом)
SME_ML=$-2
       if SEEK32BIT
        LD bc,0
SME_STw=$-2
;bchl=position in file
       else
        LD A,0
SME_ST=$-1
;ahl=position in file
       endif
        ;EXA 

        if 1==0
        LD BC,(KOL_F)
        LD A,C
        LD (F_KOL),A
Z6013   PUSH BC
        LD A,0
F_KOL=$-1
        SUB C

        INC A
        LD (NUM_F),A ;номер файла
        endif
        
        if 1==0
        PUSH HL
        LD HL,#71A ;координаты
        LD (COR),HL
        LD B,13
CLS1    PUSH BC
        LD A,#20
        CALL PR
        POP BC
        DJNZ CLS1
        POP HL
        endif

       if SEEK32BIT
;bchl=position in file
       else
        ;EXA 
        LD B,A ;SME_ST
;ahl=position in file
       endif

;куда сейчас указывает указатель в архиве?
;с READZIPDIR на начало директории
;без READZIPDIR на 0
        ;jr $
        LD IX,BUFER
        LD DE,#2E
        ;LD C,41 ;???
        CALL READ ;читаем описатель одного файла

        if 1==0
        EXX 
        LD A,(BUFER+#24)
        LD HL,CODE
       BIT 0,A
       JR Z,LL20
        LD HL,TEXT
LL20    LD DE,T_TYPE
        LD BC,4
        LDIR 
        EXX 
        endif

       if SEEK32BIT
        ADD HL,DE
        jr nc,$+3
        inc bc
;bchl=position in file
       else
        LD A,B ;SME_ST на начало описателя
        ADD HL,DE ;de=0x002e
        ADC A,D;=0 ;перемещаем указатель на имя
;ahl=position in file
        LD B,A
       endif

        LD DE,(Z6638) ;file name length
        LD IX,Z664A
        CALL READ ;читаем имя файла
;Z664A=ИMЯ TEKУЩEГO ФAЙЛА B APXИBE
        ADD IX,DE
        LD (IX),0 ;кладём 0 в конец имени (получится ASCIIZ)

       if SEEK32BIT
        ADD HL,DE
        jr nc,$+3
        inc bc
;bchl=position in file
       else
        LD A,B
        ADD HL,DE
        ADC A,0 ;перемещаем указатель после имени
;ahl=position in file
       endif

       if 0 ;???
        LD B,E
       DEC D
       INC D
        JR Z,Z604D ;длина имени <256
       LD B,0 ;длина имени >=256, считаем, что 256
Z604D
       endif
        LD DE,(Z663A) ;extra field length
        ADD HL,DE ;пропускаем extra field
       if SEEK32BIT
        jr nc,$+3
        inc bc
;bchl=position in file
       else
       ADC A,0
;ahl=position in file
       endif
        LD DE,(Z663C) ;file comment length
        ADD HL,DE ;пропускаем file comment length
       if SEEK32BIT
        jr nc,$+3
        inc bc
;bchl=position in file
       else
       ADC A,0
;ahl=position in file
       endif

       ld (SME_ML),hl
       if SEEK32BIT
       ld (SME_STw),bc
       else
       ld (SME_ST),a
       endif
        
;сформировать filename 8.3 (во всех элементах):
        ld hl,Z664A
        ld de,filename
        ;call strcopy
        call copyname83
; если это директория, то create directory (например, "md scr/1" без слеша в конце):
; это только для пустых директорий! nedoos-1.zip не содержит записи о директориях с файлами (в отличие от .tar)

        ;LD A,(T6624) ;flags
        ;and 8 ;TODO где этот флаг?
        ;jr nz,readzip_nodir
;убираем слеш в конце
        ld hl,filename
        push hl
        pop de ;ld de,filename
        xor a
        ld b,-1
        cpir
        ld a,'/'
        dec hl ;на терминаторе
        dec hl ;перед терминатором
        sub (hl)
        jr nz,readzip_nodir;$+3
        ld (hl),a ;0
        OS_MKDIR
        jp SKIP_noclose
readzip_nodir
        ld hl,Z664A;filename
        call prtext
        call prcrlf
        
        if 1==0
        
        LD HL,#5CE5
        LD DE,T_PKT
        LD B,3
        CALL PROVERK
        JR C,NX600
        LD A,"C"
        LD (#5CE5),A
        LD A,(#5CDD)
        CP "0"
        JR C,$+6
        CP ":"
        JR NC,NX600
        AND 7
        OR #30
        LD (#5CDD),A
NX600
        endif
        
        if 1==0
        LD A,(SKIPING)
       OR A
        JR Z,NOSKIP
       LD A,(NUM_F)
       LD L,A
        LD H,MARKBUF/256
       LD A,(HL)
       AND A
        JP Z,SKIP_noclose
NOSKIP  
        endif
        if 1==0
        LD IX,T_TEK
        LD HL,0
NUM_F=$-2
        CALL DS100
        LD HL,T_FILE
        CALL PRINTS_
        endif

        ;LD HL,#71A ;координаты
        ;LD (COR),HL
        ;LD HL,T61F7
        ;CALL PRINTS
        ;LD A,#4F
        ;LD (TEKATR+1),A
        
        ;XOR A

        LD HL,-1
        LD (ML_CRC32),HL
        LD (ST_CRC32),HL

        LD HL,(Z6634) ;внутри BUFER
        ;OR H
        ;OR L
        LD (ML_LEN_ISH),HL

;HL= МЛАДШИE БAЙTЫ ДЛИHЫ ИCXOДHOГO ФAЙЛA
        LD HL,(Z6636) ;внутри BUFER
        ;OR H
        ;OR L
        LD (ST_LEN_ISH),HL

;HL= CTAPШИE БAЙТЫ ДЛИНЫ ИCXOДHOГO ФAЙЛA
        ;JP Z,SKIP_noclose; HУЛЕВАЯ ДЛИHA (теперь проверяется ниже, чтобы создать файл)

        ;LD A,L
        ;LD HL,(ML_LEN_ISH)
        ;LD IX,T_ORIG
        ;CALL DES_

        LD HL,T6628 ;file last modification time ;внутри BUFER
        LD DE,T6221
        LD BC,8
        LDIR ;??? TODO установить дату после распаковки

        LD A,(T6624) ;flags ;внутри BUFER
        RRA 
        JR NC,Z60E3

;ФAЙЛ 3AKOДИPOBAH
        LD A,3
        LD (FLAGS),A ;CRYPTED

Z60E3   LD HL,(T6626) ;внутри BUFER

;T6626=METOД CЖATИЯ: 0:STORED, 8:DEFLATE, others unknown
        LD A,H
        OR A
        JR NZ,Z60F1
        OR L
        JR Z,Z60FC
        CP 8
        JR Z,Z60FC

Z60F1   ;LD HL,UNKNOWN
        ;LD DE,T_METOD
        ;LD BC,7
        ;LDIR 
        LD A,2
        LD (FLAGS),A ;UNKNOWN (число в A не должно совпадать с 0 или 8!)
        ;JR UNK_

Z60FC   
        if 1==0
        BIT 3,A
        LD HL,STORED
        JR Z,ST_
        LD HL,DEFLATE
ST_     LD DE,T_METOD
        LD BC,7
        LDIR 
        endif

UNK_    PUSH AF ;0:STORED, 8:DEFLATE, others unknown ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;LD HL,(Z6630)
        ;LD A,(Z6632)

;A,HL= ДЛИHA CЖATOГO ФAЙЛА
        ;LD (ML_PAC_LEN),HL
        ;LD (ST_PAC_LEN),A
        
        if 1==0
        LD IX,T_PACK
        CALL DES_
        LD B,4
        LD HL,CRC_ISH+3
        LD DE,T_CRC
L100    LD A,(HL)
        CALL HEX
        DEC HL
        DJNZ L100

        CALL T_IND ;инициализация процентомера?

        LD HL,0 ;текущий размер файла для процентомера
        LD (B1),HL
        LD (B2),HL
        endif

        ;CALL DATA_COR ;печать даты?

        ;LD HL,T_PACK_L
        ;CALL PRINTS_

FLAGS=$+1
        LD A,0;(FLAGS) ;2:UNKNOWN, 3:CRYPTED, other=OK (формируется выше)
        ;LD HL,T_UNK
        CP 2
        JR Z,SK__

        ;LD HL,T_CRYPT
        CP 3;:JR Z,SK__

;LD A,(SKIPING):OR A;JR Z,PROD10
        JR NZ,PROD10
SK__    ;CALL PRINTS_
        ;CALL KEY10_
        POP AF ;TODO убрать
        JP SKIP_noclose

PROD10  
        if 1==0
        LD HL,#5CE5
        LD DE,T_TRD
        LD B,3
        CALL PROVERK

        JR C,NXSCL
        LD HL,TRDOBR
        CALL PRINTS_

KEY11   XOR A
       LD (#5C08),A
        EI 
        HALT 
       LD A,(#5C08)
       OR A
        JR Z,KEY11
        CP "Y"
        JR Z,nX601_
        CP 13
       JR NZ,NX601
nX601_
        XOR A
        LD (MEN),A
        LD A,(DESTIN)
        CP "*"
        JR Z,MEN100
       LD A,(DESTIN)
       LD L,A
        LD A,(SOURCE)
       CP L
        JR NZ,MEN100
       LD A,1
        LD (MEN),A
MEN100
        LD A,#C3
        LD (SAVE),A
        LD HL,SAVETRD
        LD (SAVE+1),HL
        LD HL,0
        LD (TRK_SECT),HL

        JR NX602
NXSCL
        LD HL,#5CE5
        LD DE,T_SCL
        LD B,3
        CALL PROVERK

        JR C,NX601
;EXTRACTING FROM SCL

       IF 1==1
        LD HL,SCLOBR
        CALL PRINTS_

KEY11S  XOR A
       LD (#5C08),A
        EI 
        HALT 
       LD A,(#5C08)
       OR A
        JR Z,KEY11S
        CP "Y"
        JR Z,nX601_S
        CP 13
       JR NZ,NX601
nX601_S
        LD A,"S"
        LD (YESSCL),A
       ELSE 
       LD A,#C3
       LD (SAVE),A
       LD HL,SAVESCL
       LD (SAVE+1),HL
       LD HL,0
       LD (TRK_SECT),HL
       JR NX602
       ENDIF 
       
;NORMAL FILE (NOT TRD OR SCL)
NX601   LD A,#3E
        LD (SAVE),A
        LD HL,#CD04
        LD (SAVE+1),HL

       endif
        
        if 1==0
        LD A,(ST_LEN_ISH)
        OR A
        JR NZ,NX602
        LD HL,(ML_LEN_ISH)
       LD DE,#FF12
       OR A
       SBC HL,DE
        JR NC,NX602
        LD A,(#5CE5)
        CP "$"
        JR NZ,NX602
        LD (HOB),A
NX602   
        endif

        LD HL,(Z6646) ;Relative offset of local file header. This is the number of bytes between the start of the first disk on which the file occurs, and the start of the local file header. This allows software reading the central directory to locate the position of the file inside the ZIP file.
       if SEEK32BIT
        LD bc,(Z6648)
;bchl=position in file
       else
        LD A,(Z6648)
;ahl=position in file
       endif
        ;jr $

;position in file = CMEЩEHИE ДO ЛOKAЛЬНOГO 3AГОЛОBKA
        LD IX,BUFER
        LD DE,#1E
       if SEEK32BIT
       else
        ;LD C,#29 ;???
        LD B,A
       endif
        CALL READ

       if SEEK32BIT
        ADD HL,DE
        jr nc,$+3
        inc bc
       else
        XOR A
        ADD HL,DE
        ADC A,B
       endif
        LD DE,(Z6636)
;DE= ДЛИНA ИMEHИ ФAЙЛA
        ADD HL,DE
       if SEEK32BIT
        jr nc,$+3
        inc bc
       else
        ADC A,0
       endif
        LD DE,(Z6638)
;DE= ДOПOЛHИTEЛЬНOE ПOЛE ДЛИНЫ
        ADD HL,DE
       if SEEK32BIT
        jr nc,$+3
        inc bc
       else
        ADC A,0
       endif
        ;LD (Z634C),HL ;текущая позиция чтения в файле
        ;LD (Z634F),A;bc

;теперь физически установим указатель файла туда
       if SEEK32BIT
        ld d,b
        ld e,c
       else
        ld d,0
        ld e,a
       endif
        ;dehl=shift
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
        
        call SAVECREATE

        LD hl,(ML_LEN_ISH)
        ld a,h
        or l
        LD hl,(ST_LEN_ISH)
        or h
        or l
        jr z,SKIP ;файл нулевой длины
        
       LD IY,DISKBUF+DISKBUFsz-1
        
        ;LD HL,0
        ;LD (T622D),HL
        ;LD (T622E),HL
        
;DEPACK
       LD HL,0
       LD (U6546),HL ;сколько байт сохранить = текущий адрес в буфере
       
        POP BC ;0:STORED, 8:DEFLATE, others unknown ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        BIT 3,B
        ;LD (inflateq_sp),SP ;??? TODO
        CALL Z635E ;nz=INFLATING
       ;LD A,(YESSCL)
       ;CP "S
       ;CALL Z,DESCLPP
       ; XOR A
       ;LD (YESSCL),A
        ;LD (NO_HOB),A
        ;LD (HOB),A
        LD A,(CRC32_)
        CP #C9
        JR Z,SKIP
        LD HL,ML_CRC32
        LD DE,CRC_ISH
        LD B,4
Z6159   LD A,(DE)
        XOR (HL)
        INC HL
        inc DE
        inc A
C1      JR NZ,crcerror;Z6164
        DJNZ Z6159
        JR SKIP

crcerror;Z6164
;CRC ERROR
        ;CALL E_CRC ;!!!!!!!!!!
        ld hl,tcrcerror
        call prtext

SKIP
readerror
        call SAVECLOSE
SKIP_noclose
        ld bc,(KOL_F)
        cpi
        ld (KOL_F),bc
        ld sp,(exit_sp)
        jp pe,nextfile

E_ZIP
EXIT
exit_sp=$+1
        LD SP,#3131
         ret

BUFCAT
        dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       if READZIPDIR
PROWERKA
        if 1==0
        LD A,#4F
        LD (TEKATR+1),A
        LD HL,#400
        LD DE,#C40
        CALL RAMKA

        LD HL,FNAME
        LD DE,T6927
        LD BC,8
        LDIR 
        LD A,"."
        LD (DE),A
        INC DE
        LDI 
        LD A,(HL)
        CP #20
        JR C,NOEXN
        INC HL
        LD A,(HL)
        DEC HL
        CP #20
        JR C,NOEXN
        LDI 
        LDI 
        JR NOEXN+5
NOEXN   LD A,#20
        LD (DE),A
        INC DE
        LD (DE),A

        LD HL,FNAME
        LD DE,N_ARC
        LD BC,8
        LDIR 
       LD A,"."
       LD (DE),A
       INC DE
       LDI 
       LD A,(HL)
       CP #20
       JR C,NOEHN
       INC HL
       LD A,(HL)
       DEC HL
       CP #20
       JR C,NOEHN
       LDI 
       LDI 
       JR NOEHN+5
NOEHN  LD A,#20
       LD (DE),A
       INC DE
       LD (DE),A

        LD HL,T6918
        CALL PRINTS_
        
        endif
        
        ;CALL F_OPEN
        LD HL,CAT
        LD DE,CAT+1
        LD BC,#63F
        LD (HL),0
        LDIR ;TODO убрать
        LD HL,CAT
        LD (BUFCAT),HL

;ПPOBEPKA APXИBA

;каталог лежит в конце файла, как до него добраться?

;Z66FA
;a=??? после F_OPEN (!=0 разрешает искать назад -0x800 даже в маленьком файле любого размера) TODO
       if SEEK32BIT
        LD bc,(ST_FLENw)
       else
        LD A,(ST_FLEN)
       endif
        LD HL,(ML_FLEN) ;ahl(bchl)=длина файла
        LD DE,#800
       if SEEK32BIT
         ld a,b
         or c
       else
         OR A
       endif
         JR NZ,Z6727 ;длина файла >=0x10000
        LD A,H
        CP 8
       if SEEK32BIT
       else
        LD A,E;0
       endif
        JR NC,Z6727 ;длина файла >=0x800, так что начнём поиск с длина файла-0x800
       if SEEK32BIT
        xor a
       endif
        OR H
        JR NZ,Z6714
;длина файла < 0x100
        LD A,L
        CP #64
        jp C,Z6780 ;длина файла < 0x64 - нет ни одного файла, ошибка
Z6714   PUSH HL
        XOR A
        LD HL,BUFER
        LD DE,BUFER+1
        LD (HL),A
        LD BC,#7FF
        LDIR ;очистили буфер, чтобы случайно не найти end of central directory не там
        POP DE
Z6723 ;ищем в начале файла
        LD L,A
        LD H,A
       if SEEK32BIT
        ld c,a
        ld b,a
       endif
        JR _Z672A

Z6727   SBC HL,DE
       if SEEK32BIT
        jr nc,$+3
        dec bc
       else
        SBC A,E ;=0
       endif

_Z672A
       if SEEK32BIT
       else
        LD B,A
       endif       
        LD IX,BUFER
        ;de=0x800
        CALL LOAD_B ;поиск блока end of central directory
       if SEEK32BIT
        JR Z,Z6747 ;end of central directory
        ld a,b
        or c
        OR L
        OR H
        JR Z,Z6780 ;дошли до начала файла, а end of central directory не нашли
        push bc ;de занято
        LD BC,#7EA ;смещаем указатель файла назад почти на 0x800
        SBC HL,BC
        pop bc
        jr nc,_Z672A ;ищем назад
        ld a,c
        sbc a,0
        ld c,a
        ld a,b
        sbc a,0
        ld b,a
        JR NC,_Z672A ;ищем назад
        XOR A
        JR Z6723 ;ищем в начале файла
       else
        LD A,B
        JR Z,Z6747 ;end of central directory
        OR L
        OR H
        JR Z,Z6780 ;дошли до начала файла, а end of central directory не нашли
        LD A,B
        LD BC,#7EA ;смещаем указатель файла назад почти на 0x800
        SBC HL,BC
        SBC A,0
        JR NC,_Z672A ;ищем назад
        XOR A
        JR Z6723 ;ищем в начале файла
       endif       

Z6747
;нашли end of central directory (ix = адрес этого блока в BUFER+)
       if SEEK32BIT
        push ix
        pop de
        ADD HL,de
        jr nc,$+3
        inc bc
        or a
        LD de,BUFER
        SBC HL,de
        jr nc,$+3
        dec bc
       else
        PUSH IX
        POP BC
        ADD HL,BC
       ADC A,0
        LD BC,BUFER
        SBC HL,BC
       SBC A,0 ;ahl=смещение end of central directory в файле
       endif
        LD (Z6896),HL ;текущее смещение в файле?
       if SEEK32BIT
        LD (Z6894w),bc
       else
        LD (Z6894),A
        EX DE,HL ;de=текущее смещение в файле?
       endif
        LD H,(IX+#11)
        LD L,(IX+#10) ;offset of start of central directory

;МЛАДШИЕ БAЙTЫ CMEЩEHИЯ HAЧAЛА ЦEHTPAЛЬHOГO KATAЛOГA
        LD (SME_ML),HL
       if SEEK32BIT
       else
        LD (IX+2),A ;???
       endif

;CTAPШИЙ БAЙT CMEЩЕНИЯ
       if SEEK32BIT
        LD c,(IX+#12) ;offset of start of central directory HSB
        LD b,(IX+#13)
        LD (SME_STw),bc
       else
        LD A,(IX+#12) ;offset of start of central directory HSB
        LD (SME_ST),A
       endif
       if SEEK32BIT
        LD d,(IX+#D)
        LD e,(IX+#C)
        LD (SM1),de ;size of central directory
;de=ДЛИНA ЦEHTPAЛЬHOЙ ДИPEKTOPИИ, МЛАДШИЕ БAЙТЫ
        add hl,de
        ld a,c
        adc a,(ix+#e)
        ld c,a
        ld a,b
        adc a,(ix+#f)
        ld b,a
        ld de,(Z6896) ;de=текущее смещение в файле?
        sbc hl,de
        JR NZ,Z6780 ;конец central directory не соответствует смещению блока end of central directory - ошибка
        ld hl,(Z6894w) ;текущее смещение в файле HSW?
        sbc hl,bc
        JR Z,Z6783 ;конец central directory соответствует смещению блока end of central directory
Z6780  JP ERR_Z1 ;дошли до начала файла, а end of central directory не нашли
       else
        LD B,(IX+#D)
        LD C,(IX+#C)
        LD (SM1),BC ;size of central directory
;BC=ДЛИНA ЦEHTPAЛЬHOЙ ДИPEKTOPИИ, МЛАДШИЕ БAЙТЫ
        ADD HL,BC
        ADC A,(IX+#E) ;size of central directory HSB
        XOR (IX+2) ;???
        JR NZ,Z6780 ;конец central directory не соответствует смещению блока end of central directory - ошибка
        SBC HL,DE ;de=текущее смещение в файле?
        JR Z,Z6783 ;конец central directory соответствует смещению блока end of central directory
Z6780  JP ERR_Z1 ;дошли до начала файла, а end of central directory не нашли
       endif

Z6783   LD L,(IX+#14)
        LD H,(IX+#15)
        LD (LEN_KOM),HL

       if SEEK32BIT
        LD c,(IX+#E)
        LD b,(IX+#F)
        LD (SM2w),bc ;size of central directory HSW
       else
        LD A,(IX+#E)
        LD (SM2),A ;size of central directory HSB
       endif

        LD e,(IX+#A)
        LD d,(IX+#B)
        LD H,(IX+9)
        LD L,(IX+8)
;cy=0
;de=ОБЩEE ЧИСЛO ФAЙЛОB B APXИBE
;HL=ЧИСЛО 3AПИCEЙ B KATAЛOГE HA ЭTOM ДИCKE
        LD (KOL_F),HL
        SBC HL,de
        JP NZ,ERR_Z2
        LD HL,(SME_ML) ;start of central directory
       if SEEK32BIT
        LD bc,(SME_STw)
       else
        LD A,(SME_ST)
        EXA
       endif
Z679E   PUSH de ;ОБЩEE ЧИСЛO ФAЙЛОB B APXИBE
       if SEEK32BIT
       else
        EXA 
        LD B,A
       endif
        LD A,1 ;тип сигнатуры
        LD DE,#2E
        LD IX,BUFER
        CALL Z6886 ;читаем блок и проверяем сигнатуру (выход по ошибке - ERR_Z1)

        LD A,(IX+#1D) ;A= старШИЙ БAЙT ДЛИНЫ ИMEHИ ФAЙЛА
        CP 2
        JP NC,ERR_Z3
        LD D,A
        LD E,(IX+#1C) ;DE=ДЛИНА ИMEHИ ФAЙЛА
        CALL Z68D9 ;сдвинуть указатель в файле bhl(bchl) на de байт и проверить, что не вышли за границу файла?
        LD D,(IX+#1F)
        LD E,(IX+#1E) ;DE=ДOПOЛНИTEЛЬHOE ПОЛE ДЛИHЫ
        CALL Z68D9 ;сдвинуть указатель в файле bhl(bchl) на de байт и проверить, что не вышли за границу файла?
        LD D,(IX+#21)
        LD E,(IX+#20) ;DE=ДЛИHA KOMEHTAPИЯ K ФAЙЛУ
        CALL Z68D9 ;сдвинуть указатель в файле bhl(bchl) на de байт и проверить, что не вышли за границу файла?
       PUSH BC
       push HL
       if SEEK32BIT
        LD c,(IX+#2c)
        LD b,(IX+#2d)
       else
        LD B,(IX+#2C)
       endif
        LD L,(IX+#2A)
        LD H,(IX+#2B)
;bhl(bchl)=CMEЩEHИE OT HAЧAЛA ПEPBOГO ДИCKA C ЭTИM ФAЙЛOM
;     ДO ЛОКАЛЬHOГO 3AГOЛOBKA.
        INC IX
        inc IX
        inc HX
        LD A,3 ;тип сигнатуры
        LD DE,#30
        CALL Z68B1 ;сдвигаем указатель bhl(bchl) на de байт, читаем и проверяем сигнатуру?
        PUSH IX
        POP HL
        LD DE,#1E
        ADD HL,DE
        LD (NAMEF3+1),HL
        LD E,(IX+#1A)
        LD D,(IX+#1B)
        ADD HL,DE
        LD DE,(BUFCAT)
         PUSH DE
         push DE
        LD A," "
        LD B,11
        LD (DE),A
        INC DE
        DJNZ $-2
NAMEF3  LD DE,0
NAMEF4  DEC HL
        PUSH HL
        AND A
        SBC HL,DE
        POP HL
       JR NC,NAMEF5
       EX DE,HL
       DEC HL
       JR NAMEF6

NAMEF5  LD A,(HL)
        CP "/"
        JR NZ,NAMEF4
NAMEF6   POP DE
        INC HL
        LD B,8
NAMEF2  LD A,(HL)
        INC HL
        CP "."
        JR Z,NAMEF1
        LD (DE),A
        INC DE
        DJNZ NAMEF2
        LD A,(HL)
        INC HL
        CP "."
        JR NZ,$-4
NAMEF1   POP DE
        LD B,8
        INC DE
        DJNZ $-1
       LD BC,3
        LDIR 
        LD A,(IX+#16) ;uncompressed size
        LD (DE),A
        INC DE
        LD A,(IX+#17)
        LD (DE),A
        INC DE
        LD A,(IX+#18) ;FIXME для 32bit длины файла
        LD (DE),A
        INC DE
        inc DE
        inc DE
        EX DE,HL
        ;LD (BUFCAT),HL
        LD HL,#1E
        LD A,(IX+#1B) ;A=СТАРШИЙ БAЙT ДЛИHЫ имени ФAЙЛА
        CP 2
        JP NC,ERR_Z3
        LD D,A
        LD E,(IX+#1A) ;DE=ДЛИHA имени ФAЙЛА
        CALL Z68ED ;сдвинуть указатель в файле bhl(bchl) на de байт и проверить, что не вышли за границу файла?
        LD D,(IX+#1D)
        LD E,(IX+#1C) ;DE=extra field len
        CALL Z68ED ;сдвинуть указатель в файле bhl(bchl) на de байт и проверить, что не вышли за границу файла?
        LD D,(IX+#13)
        LD E,(IX+#12)
       if SEEK32BIT
        LD A,(IX+#15)
        ld (Z68EEhswb),a
       endif
        LD A,(IX+#14) ;<Z68EEhswb>A,DE=ДЛИHA CЖATOГO ФAЙЛA
        CALL Z68EE ;сдвинуть указатель в файле bhl(bchl) на <Z68EEhswb>ade байт и проверить, что не вышли за границу файла?
        LD A,(IX+#16)
        OR (IX+#17)
        OR (IX+#18)
        OR (IX+#19) ;ИCXOДHAЯ ДЛИHA ФAЙЛA
        EXA  ;файл длиной 0?
        PUSH IX
        POP HL
        LD BC,7
        ADD HL,BC
        RES 7,(IX+7)

;METOД CЖATИЯ, CTAPШИЙ БAЙT
        LD B,#18-3
Z6825   LD A,(HL)
        DEC H
        SUB (HL) ;TODO что с чем сравниваем?
        JR NZ,ERR_Z1 ;глобальная ошибка zip-файла
        INC H
        inc HL
        DJNZ Z6825
       POP HL
       pop BC
       if SEEK32BIT
       else
        LD A,B
       endif
        POP de ;общее число файлов в архиве
        EXA  ;файл длиной 0?
        JR Z,Z6838 ;файл длиной 0?
        LD (Z683F),A ;файл длиной не 0?
Z6838   DEC de
        LD A,d
        OR e
        JP NZ,Z679E

        LD A,0
Z683F=$-1
        OR A
        RET NZ ;хоть один файл длиной не 0?
;TODO файл длиной 0
ERR_Z1
ERR_Z2
ERR_Z3
        JP E_ZIP

;поиск блока end of central directory
LOAD_B
;bhl(bchl)=смещение в файле
;ix=буфер
;de=len
;out: z=end of central directory, bhl=kept
        CALL READ
        PUSH BC
        LD BC,#7EA ;???
        ADD IX,BC
;поиск заголовка блока
Z6861   LD A,#50 ;'P'
        CP (IX)
        JR NZ,Z687C
        LD A,#4B ;'K'
        CP (IX+1)
        JR NZ,Z687C
        LD A,5
        CP (IX+2)
        JR NZ,Z687C
        INC A
        CP (IX+3)
        JR Z,Z6884 ;05, 06 = end of central directory
Z687C   DEC BC
        DEC IX
        LD A,B
        OR C
        JR NZ,Z6861 ;поиск заголовка блока дальше
        DEC A ;-1, NZ
Z6884   POP BC
        RET 

Z6886
       PUSH HL ;keep old position in file
       if SEEK32BIT
       push bc ;keep old position in file HSW
       endif
       push DE ;keep size
        LD (signaturetype),A
        ADD HL,DE
       if SEEK32BIT
       jr nc,$+3
       inc bc
       else
       LD A,B
       ADC A,0
        JR C,ERR_Z1 ;глобальная ошибка zip-файла
       endif

        EX DE,HL

       if SEEK32BIT
;bcde=next position in file
Z6896=$+1
        LD HL,0
        or a
        SBC HL,DE ;это просто сравнение, результат не используется
Z6894w=$+1
        LD hl,0
        sbc hl,bc ;bcde=next position in file
        JR C,ERR_Z1 ;глобальная ошибка zip-файла
       else
        LD C,A
;cde=next position in file
Z6894=$+1
        LD A,0
Z6896=$+1
        LD HL,0
        SBC HL,DE ;это просто сравнение, результат не используется
        SBC A,C
        JR C,ERR_Z1 ;глобальная ошибка zip-файла
       endif

        EX DE,HL

       if SEEK32BIT
;bchl=next position in file
        ld (Z6886bc),bc
       POP DE ;size
       pop bc
       EX (SP),HL ;keep next position in file, get old position in file
        CALL READ
       POP HL
Z6886bc=$+1
       ld bc,0 ;bchl=next position in file
       else
;chl=next position in file
       POP DE ;size
       EX (SP),HL ;keep next position in file, get old position in file
        LD A,B
       LD B,C
        CALL READ
       POP HL ;bhl=next position in file
       endif
        JR Z68AB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Z68AB   CALL checksignature;Z6901
        RET Z
Z68AF   JR ERR_Z1 ;глобальная ошибка zip-файла

Z68B1
;сдвигаем указатель bhl(bchl) на de байт, читаем и проверяем сигнатуру?
       PUSH HL ;keep old position in file
       if SEEK32BIT
       push bc ;keep old position in file HSW
       endif
       push DE ;keep size
        LD (signaturetype),A
       ADD HL,DE
       if SEEK32BIT
        jr nc,$+3
        inc bc
       else
       LD A,B
       ADC A,0
        JR C,ERR_Z1 ;глобальная ошибка zip-файла
       endif

        EX DE,HL

       if SEEK32BIT
;bcde=next position in file
        LD HL,(SME_ML) ;start of central directory
        or a
        SBC HL,DE ;это просто сравнение, результат не используется
        LD hl,(SME_STw)
        SBC hl,bc
        JR C,Z68AF ;глобальная ошибка zip-файла
       else
        LD C,A
;cde=next position in file
        LD A,(SME_ST)
        LD HL,(SME_ML) ;start of central directory
        SBC HL,DE ;это просто сравнение, результат не используется
        SBC A,C
        JR C,Z68AF ;глобальная ошибка zip-файла
       endif

        EX DE,HL

       if SEEK32BIT
;bchl=next position in file
        ld (Z68B1bc),bc
       POP DE ;size
       pop bc
       EX (SP),HL ;keep next position in file, get old position in file
        CALL READ
       POP HL
Z68B1bc=$+1
       ld bc,0 ;bchl=next position in file
       else
;chl=next position in file
       POP DE ;size
       EX (SP),HL ;keep next position in file, get old position in file
        LD A,B
       LD B,C
        CALL READ
        POP HL ;bhl=next position in file
       endif
        JR Z68AB ;check signature

Z68D9
;сдвинуть указатель в файле (bhl)bchl на de байт и проверить, что не вышли за границу файла?
        XOR A
        ADD HL,DE
       if SEEK32BIT
        ADC A,c
        ld c,a
        ld a,b
        adc a,0
        LD B,A
        JR C,Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла
       else
        ADC A,B
        JR C,Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла
        LD B,A
       endif
        EX DE,HL
       if SEEK32BIT
        LD HL,(Z6896) ;текущее смещение в файле?
        SBC HL,DE ;это просто сравнение, результат не используется
        LD hl,(Z6894w)
        SBC hl,bc
       else
        LD A,(Z6894)
        LD HL,(Z6896) ;текущее смещение в файле?
        SBC HL,DE ;это просто сравнение, результат не используется
        SBC A,B
       endif
        EX DE,HL
        RET NC
       JR Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла

Z68ED
;сдвинуть указатель в файле (bhl)bchl на de байт и проверить, что не вышли за границу файла?
        XOR A
       if SEEK32BIT
        ld (Z68EEhswb),a
       endif
Z68EE
;сдвинуть указатель в файле (bhl)bchl на <Z68EEhswb>ade байт и проверить, что не вышли за границу файла?
        ADD HL,DE
       if SEEK32BIT
        ADC A,c
        ld c,a
        ld a,b
Z68EEhswb=$+1
        adc a,0
        LD B,A
        JR C,Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла
       else
        ADC A,B
        JR C,Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла
        LD B,A
       endif
        EX DE,HL
       if SEEK32BIT
        LD HL,(SME_ML) ;start of central directory
        SBC HL,DE ;это просто сравнение, результат не используется
        LD hl,(SME_STw)
        SBC hl,bc
       else
        LD A,(SME_ST)
        LD HL,(SME_ML) ;start of central directory
        SBC HL,DE ;это просто сравнение, результат не используется
        SBC A,B
       endif
        EX DE,HL
        RET NC
       JR Z68AF ;ERR_Z1 ;глобальная ошибка zip-файла

checksignature;Z6901
        LD A,#50
        CP (IX)
        RET NZ
        LD A,#4B
        CP (IX+1)
        RET NZ
signaturetype=$+1;Z690E
        LD A,0 ;тип сигнатуры: 03: local file header, 01: central directory file header, 07: optional data descriptor, 05: end of central directory
        CP (IX+2)
        RET NZ
        INC A
        CP (IX+3)
        RET  
        
      endif ;READZIPDIR

        if 1==0
Z631F  PUSH BC
       POP DE
        PUSH HL
        POP IX
        LD A,0
ST_PAC_LEN=$-1
        LD HL,0
ML_PAC_LEN=$-2
        OR A
        JR NZ,Z633D
        PUSH HL
        SBC HL,DE
        POP HL
        JR NC,Z633D
        LD E,L
        LD D,H
Z633D   OR A
        SBC HL,DE
        SBC A,0
        LD (ST_PAC_LEN),A ;FIXME for SEEK32BIT
        LD (ML_PAC_LEN),HL
        LD A,D
        OR E
        RET Z
        LD HL,0
Z634C=$-2
        LD A,0 ;FIXME for SEEK32BIT
Z634F=$-1
        LD B,A
        CALL READ
        XOR A
        ADD HL,DE
        ADC A,B
        LD (Z634C),HL
        LD (Z634F),A ;FIXME for SEEK32BIT
       ;CALL STOP_DRV
       RET 
        else
;Z634C
;        dw 0
;Z634F
;        db 0
        endif
       
Z635E
        jp NZ,INFLATING
;stored
         ld hl,tstored
         call prtext
        ;LD HL,PROCES
        ;CALL PRINTS_
           ;LD A,5
           ;call ON_BANK 
        ld hl,(ML_LEN_ISH)
        ld a,(ST_LEN_ISH) ;FIXME
        ;ld c,a
        ;or h
        ;or l
        ;ld a,c
        ;jr z,storedq
        jr stored0go
stored0
        push af
        ;push hl
        ziprdbyte
        CALL SBYTE
        ;pop hl
        pop af
stored0go
        ld bc,1
        or a
        sbc hl,bc
        sbc a,b;0
        jr nc,stored0
           ;LD A,5
           ;call ON_BANK 
;storedq
        ;jp savelastblock;_ZD1C4 ;save whole buffer (end of file)
        
savelastblock;_ZD1C4
        ;jr $
;save whole buffer
;сюда попадаем в конце файла
;       ld hl,tsavelast
;       call prtext
        LD HL,(U6546)
        ;ld a,h
        ;cp 0x50
        ;jr z,$
savehlbytes;ZD1C7
        LD DE,0
        JP SAVE

saveblock;Z65B8
;save whole buffer
;сюда не попадаем на коротких файлах
        PUSH HL,DE,BC,AF
         ;push ix
         ;exx
         ;exa
         ;push af
         ;push bc
         ;push de
         ;push hl
         call progressbar
        ;LD A,5
        ;CALL ON_BANK
        LD HL,(Z6546) ;сколько байт сохранить
        LD (TD198),HL ;сколько байт сохраняли
        CALL savehlbytes;ZD1C7 ;SAVE hl bytes
;hl=0
        LD (Z6546),HL ;сколько байт сохранить (=0)
        if 1==0 ;обновление размера для процентомера
        EX DE,HL
        LD HL,(TD198) ;сколько байт сохраняли
       AND A
        SBC HL,DE
        JR C,CON1 ;???
        LD DE,(B2)
        ADD HL,DE
        LD (B2),HL
       LD A,(B1)
       ADC A,0
       LD (B1),A
CON1
        endif
         ;pop hl
         ;pop de
         ;pop bc
         ;pop af
         ;exa
         ;exx
         ;pop ix
        POP AF,BC,DE,HL
        RET 

tsaveblock
        db "  save block #",0
tsavelast
        db 13,10,"save last block",13,10,0


tstored
        db "stored",13,10,0

ST_LEN  DW 0

progressbar
        ld hl,tsaveblock
        call prtext
        ld hl,(blockCounter)
        inc hl
        ld (blockCounter),hl
        call toDecimal
        ld hl,decimalS
        call prtext
        call prcrlf
        ret
toDecimal		;конвертирует 2 байта в 5 десятичных цифр
				;на входе в HL число
	ld de,10000 ;десятки тысяч
	ld a,255
toDecimal10k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal10k
	add hl,de
	add a,48
	ld (decimalS),a
	ld de,1000 ;тысячи
	ld a,255
toDecimal1k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal1k
	add hl,de
	add a,48
	ld (decimalS+1),a
	ld de,100 ;сотни
	ld a,255
toDecimal01k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal01k
	add hl,de
	add a,48
	ld (decimalS+2),a
	ld de,10 ;десятки
	ld a,255
toDecimal001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal001k
	add hl,de
	add a,48
	ld (decimalS+3),a
	ld de,1 ;единицы
	ld a,255
toDecimal0001k			
	and a
	sbc hl,de
	inc a
	jr nc,toDecimal0001k
	add hl,de
	add a,48
	ld (decimalS+4),a		
	ret
decimalS
	ds 5 ;десятичные цифры
        db 0
blockCounter
        dw 0000 


        if 1==0
INFLATING
        ;ld (inflateq_sp),sp
        ;LD HL,PROCES
        ;CALL PRINTS_
        ;LD A,5
        ;CALL ON_BANK
        CALL ZD140 ;init read buffer, inflate file
        ;LD A,4
        ;JP ON_BANK
        ret
        endif

depkqerror;B_TABL
;ошибка в файле
        ;jr $
         ld hl,terror
         call prtext
;save whole buffer (Z6546) байт и выйти
;Z63B4
;inflateq_sp=$+1;Z63B5=$+1
;        LD SP,0
        ;LD HL,(Z6546) ;сколько байт сохранить = текущий адрес в буфере
        ;LD DE,0
        ;CALL SAVE
        call savelastblock
        ;LD A,4
        ;CALL ON_BANK
        ;CALL E_TABL
        JP SKIP ;восстанавливает sp
terror
        db "error",13,10,0

;PAСЧET CRC-32
;тут может быть патч RET (TODO)
;a=byte
CRC32_  EXX 
        LD DE,(ST_CRC32)
        LD HL,(ML_CRC32)
CRCPR_  XOR L
        LD B,H
        LD L,A
         LD H,TCRC/1024 ;#18
        ADD HL,HL
        ADD HL,HL
        LD A,B
        XOR (HL)
        LD C,A
        INC L
        LD A,E
        XOR (HL)
        LD B,A
        INC L
        LD A,D
        XOR (HL)
        LD E,A
        INC L
        LD D,(HL)
        LD (ST_CRC32),DE
        LD (ML_CRC32),BC
        EXX 
        RET 
;ГEHEPAЦИЯ TAБЛИЦЫ ДЛЯ PAСЧETA CRC-32
initCRC
        LD IX,TCRC+#3FC
        LD C,0
Z669B   LD B,8
        LD DE,0
        LD H,D
        LD L,C
        DEC L
Z66A3   SRL D
        RR E
        RR H
        RR L
        JR NC,Z66BD
        LD A,#ED
        XOR D
        LD D,A
        LD A,#B8
        XOR E
        LD E,A
        LD A,#83
        XOR H
        LD H,A
        LD A,#20
        XOR L
        LD L,A
Z66BD   DJNZ Z66A3
        LD (IX),L
        LD (IX+1),H
        LD (IX+2),E
        LD (IX+3),D
        LD DE,-4
        ADD IX,DE
        DEC C
        JR NZ,Z669B
        ;LD A,4
        ;JP ON_BANK
        ret
