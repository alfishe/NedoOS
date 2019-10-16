        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

COLOR=7
        
        macro STRPUSH
;hl=string addr
        xor a
        push af
         ld a,(hl)
         inc hl
         or a
         push af
        jr nz,$-4
        pop af
;в стеке лежит \0, текст (без терминатора)
        endm
        
        macro STRPOP
;hl=string addr
        ld d,h
        ld e,l
         pop af
         ld (hl),a
         inc hl
         or a
        jr nz,$-4
        ex de,hl ;hl=string addr, de не важен
        call strmirror
        endm
        
        org PROGSTART
cmd_begin
        ld sp,0xc000;0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ld e,6 ;textmode
        OS_SETGFX
        
        ;ld e,COLOR
        ;OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jp z,noautoload
;проверяем, это *.tar или файл/директория? если файл/директория, то её надо паковать
        push hl
        call findlastdot ;out: de = after last dot or start
        pop hl
        or a
        sbc hl,de
        add hl,de
        jr z,notar
        ld a,(de)
        or 0x20
        cp 't'
        jr nz,notar
        inc de
        ld a,(de)
        or 0x20
        cp 'a'
        jr nz,notar
        inc de
        ld a,(de)
        or 0x20
        cp 'r'
        jr nz,notar
        jp untar
notar
;это не *.tar
        ld de,filename
        call strcopy
;формируем имя архива (отрезаем расширение, если есть, и приписываем справа .tar)
;надо взять только после слеша (чтобы архив был в текущей директории):
        ld hl,filename
        call findlastslash. ;de=after last slash or start
        ex de,hl
        ld de,tarname
        call strcopy
        dec de
       push de ;de=at terminator        
        ld hl,tarname
        push hl
        call findlastdot
        pop hl
        or a
        sbc hl,de
        add hl,de
        jr z,tarname_nolastdot
;проверяем, что эта точка относится к расширению, т.е. после неё нет слэшей
        ld h,d
        ld l,e ;de=after last dot
tarname_checkext0
        ld a,(hl)
        inc hl
        cp '/'
        jr z,tarname_nolastdot
        or a
        jr nz,tarname_checkext0
        dec de ;de=at last dot
       pop af
       push de
tarname_nolastdot
       pop de ;de=at terminator or last dot        
        ld hl,ttar
        call strcopy

;создаём архив
        ld de,tarname
        call SAVECREATE
        or a
        jp nz,openerror

;filename=имя файла с путём
;пусть мы находимся в той же директории, что пакуемый файл (в данном случае пакуемая директория), в filename уже нет пути:
        ld hl,filename
        call findlastslash. ;out: de = after last slash or start
        ld hl,filename
        or a
        sbc hl,de
        jr z,nopathinfilename
        push de
        dec de
        xor a
        ld (de),a ;instead of slash
        ld hl,filename
        ld de,cmdprompt
        call strcopy
        ld de,cmdprompt
        OS_CHDIR
        pop hl
        ld de,filename
        call strcopy
nopathinfilename
        xor a
        ld (cmdprompt),a
;filename=имя файла без пути, выбрана директория файла, cmdprompt пустой
        ld hl,filename
        ld de,filenametoopen
        call strcopy
        call taraddfile
       ld hl,tallok
       call prtext
        jr tarclosearchive
openfileerror
       ld hl,terroropeningfile
       call prtext
tarclosearchive
        call SAVECLOSE

        jp quit
        
tallok
        db "All OK",0x0d,0x0a,0
terroropeningfile
        db "Error opening file",0x0d,0x0a,0

taraddfile   
        ld hl,filename
        call prtext
        call prcrlf
;filenametoopen=имя файла, который надо открыть в текущей директории
;filename=имя файла, которое надо положить в архив
;делаем заголовок файла
        ld hl,tarfileheader
        ld bc,100*256
        ld (hl),c
        inc hl
        djnz $-2
        ld hl,filename
        ld de,tarfileheader
        ld b,100
tarmkfilename0
        ld a,(hl)
        or a
        jr z,tarmkfilenameq
        ld (de),a
        inc hl
        inc de
        djnz tarmkfilename0
tarmkfilenameq

;открываем файл
;время можно прочитать и из директории, а открыть её как файл нельзя
        ld de,filenametoopen
        OS_GETFILETIME ;out: ix=date, hl=time
        or a
        jp nz,openfileerror

        call dos2unixtime ;out: dehl=UNIX time
        ld bc,tarfiletimeoctal_end
        ld a,11
        call wroctaldehl_adigits
        
        ld de,filenametoopen
        call openstream_file
        or a
        ld a,(filehandle)
        ld b,a
       push bc
        jp nz,tardir;openfileerror ;4=no file, 5=no path, 13=no drive, 20=it's a directory (было тоже 4)

	OS_GETFILESIZE ;dehl=filesize
        
;dehl=filesize
        ld a,'0'
        ld (tarfileordir),a
        call tarwrsizeheader
;tarwritefile
;пакуем файл
;dehl=size
writefile0
        ld a,d
        or e
        ld bc,0x4000
        call z,minhl_bc_tobc
;bc=save size
        ld a,b
        or c
        jr z,writefileq
        push de
        push hl
        push bc
         ;push bc ;save size
;0x200 -> 0x200
;0x201 -> 0x400
        dec bc
        ld a,b
        add a,2
        and 0xfe
        ld h,a ;0..1->2, 2..3->4
        ld de,0xc000
        ld l,e;0
;DE = Buffer address, HL = Number of bytes to read
         push hl
        push de
        call readstream_file
;hl=actual size
        pop de
         pop hl ;save size
        call SAVE
        pop bc
        pop hl
        pop de
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        jr writefile0
writefileq
        ;jr $
       pop bc ;b=file handle
        OS_CLOSEHANDLE
        ret
        
        
tardir
        ld a,'5'
        ld (tarfileordir),a
        ld hl,0
        ld d,h
        ld e,l ;size=0
;dehl=filesize
        call tarwrsizeheader ;записали директорию в архив
;допустим, что мы находимся в той же директории, что пакуемый файл (в данном случае пакуемая директория), в filename уже нет пути, cmdprompt пустой
;рекурсивно пакуем содержимое директории:
;- strpush cmdprompt
        ;jr $
        ld hl,cmdprompt
        STRPUSH
;- cmdprompt = cmdprompt+filenametoopen
        ;ld de,cmdprompt ;de=pointer to 64 byte (MAXPATH_sz!) buf
        ;OS_GETPATH
        ld hl,cmdprompt
;если непустой и в конце нет слеша, то добавим:
        ;ld bc,0 ;чтобы точно найти терминатор
        xor a
       cp (hl)
       jr z,tardirnoaddslash
        ld b,a
        ld c,a;0
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        dec hl ;на терминаторе
        dec hl ;перед терминатором
        ld a,'/'
        cp (hl)
        jr z,$+2+5
         inc hl
         ld (hl),a
         inc hl
         ld (hl),0
tardirnoaddslash
        ex de,hl
        ld hl,filenametoopen
        call strcopy ;TODO проверять переполнение буфера cmdprompt
;- chdir filenametoopen
        ld de,filenametoopen
        OS_CHDIR
;- читаем в цикле cpmname, из него формируем filenametoopen (dotname(cpmname)), filename (cmdprompt+dotname(cpmname)) - путь относительно корня директории!) и вызываем taraddfile
;        ld de,fcb
;        OS_SETDTA ;set disk transfer address = de
;        ;call makeemptymask
;        ld de,fcbmask
;        OS_FSEARCHFIRST
;        or a
;        jr nz,tardir0q
       ld bc,0 ;номер файла в директории
tardir0
        ;jr $
        push bc
        call getdirfcb_bc
        pop bc
        jr nz,tardir0q
       push bc ;номер файла в директории
        ld hl,fcb_filename
       ld a,(hl)
       cp '.'
       jr z,tardir0skip
        ld de,filenametoopen
        call cpmname_to_dotname
        ld hl,cmdprompt
        ld de,filename
        call strcopy
        ex de,hl
        dec hl ;hl=terminator addr
;если в конце нет слеша, то добавим:
        dec hl
        ld a,'/'
        cp (hl)
        inc hl
        jr z,$+4
         ld (hl),a;'/'
         inc hl
        ex de,hl
        ld hl,filenametoopen
        call strcopy ;TODO проверять переполнение буфера filename
        call taraddfile ;filenametoopen (dotname(cpmname)), filename (cmdprompt+dotname(cpmname))
tardir0skip
       ; ld de,fcb
       ; OS_SETDTA ;set disk transfer address = de
       ;  ;call makeemptymask ;в CP/M не нужно, но отсутствие вредит многозадачности
       ;  ld de,fcbmask ;в CP/M не нужно, но отсутствие вредит многозадачности
       ; OS_FSEARCHNEXT
       pop bc
       inc bc
       ; or a
       ; jr z,tardir0
        jr tardir0
tardir0q
;- strpop cmdprompt
        ld hl,cmdprompt
        STRPOP
;- chdir ..;cmdprompt
        ld de,tdotdot;cmdprompt
        OS_CHDIR
       ld hl,tdirclosed
       call prtext
        jp writefileq
        
tdirclosed
        db "Directory closed",0x0d,0x0a,0

tdotdot
        db "..",0
        
getdirfcb_bc
;bc=file number in current dir to read to fcb
;nz=error
        push bc
        ld de,fcb
        OS_SETDTA
        ld de,fcbmask
        OS_FSEARCHFIRST ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
        pop bc
        or a
        ret nz
       
getdirfcb_bc0
        ld a,b
        or c
        ret z
        dec bc
        push bc
        ld de,fcb
        OS_SETDTA
        ld de,fcbmask
        OS_FSEARCHNEXT ;(NOT CP/M!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
        pop bc
        or a
        jr z,getdirfcb_bc0
        ret
        
tarwrsizeheader
        push de
        push hl
        
        ld bc,tarfilesizeoctal_end
        ld a,11
        call wroctaldehl_adigits

        call wrheaderchecksum
        ld de,tarfileheader
        ld hl,0x200
        call SAVE
        
        pop hl
        pop de
        ret

MULWORD
;out: HLBC=DE*BC
        LD HL,0
        LD A,17
MULWOR0 RR B
        RR C
        DEC A
        RET Z
        JR NC,$+3
        ADD HL,DE
        RR H
        RR L
        JR MULWOR0

countdays_month
;d=year since 1970 (0 for 1970)
;e=month (1..12)
;out: a=days
        ld a,e
        cp 2
        jr z,countdays_feb
        push de
        push hl
        ld d,0
        ld hl,tdays_month-1
        add hl,de
        ld a,(hl)
        pop hl
        pop de
        ret
countdays_feb
        ld a,d
        sub 2
        and 3
        ld a,28
        ret nz
        inc a
        ret
        
tdays_month        
        db 31
        db 28
        db 31
        db 30
        db 31
        db 30
        db 31
        db 31
        db 30
        db 31
        db 30
        db 31

dos2unixtime
;ix=date, hl=time
;out: dehl=UNIX time
;DOS date, time to UNIX time (seconds since beginning of 1970)
        ;jr $
        push hl ;time
        ld a,lx
        push af
        ld hl,0 ;число дней
        ld a,hx
        srl a
        add a,10
        ld d,a ;d=year since 1970 (0 for 1970)
;в цикле по годам прибавлять число дней, соответствующее годам
        ;jr z,dos2unixtime_noyear
        push de
        ld b,d
        ld d,0 ;year 1970
dos2unixtime_years0
        ld a,d
        sub 2
        and 3
        ld a,365&0xff
        jr nz,$+3
        inc a
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        inc h
        inc d ;year 1971 etc... don't add current year
        djnz dos2unixtime_years0
        pop de
;dos2unixtime_noyear
;в цикле по месяцам прибавлять число дней, соответствующее месяцам
        add ix,ix
        add ix,ix
        add ix,ix
        ld a,hx
        and 0x0f
        ld b,a ;e=month (1..12)
        dec b
        jr z,dos2unixtime_nomonth
        ld e,1
dos2unixtime_months0
;e=month (1..12)
        call countdays_month ;out: a=days
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        inc e
        djnz dos2unixtime_months0
dos2unixtime_nomonth
        pop af
        and 0x1f ;day (1..31)
        dec a
;потом прибавить (day-1) (т.к. дни у нас с единицы)
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl=число дней с начала 1970
;потом умножить на 86400 (0x15180) / 2
        ex de,hl
        ld bc,86400/2
        call MULWORD ;out: HLBC=DE*BC
        ld d,b
        ld e,c
        ex de,hl ;dehl = days*86400/2
        pop bc ;time
;потом прибавить (3600/2*hour) + (60/2*minute) + (second/2) = 30*(60*hour + minute) + (second/2)
        push de
        push hl ;dehl = days*86400/2

        ld a,b
        rra
        rra
        rra
        and 0x1f ;hour
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        ld d,h
        ld e,l ;hour*4
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;hour*64
        sbc hl,de ;hl = hour*60
        
        ld a,c
        rla
        rl b
        rla
        rl b
        rla
        rl b
        ld a,b
        and 0x3f ;minute
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl = (60*hour + minute)

        add hl,hl
        ld d,h
        ld e,l ;*2
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;*32
        sbc hl,de ;*30
;hl = 30*(60*hour + minute)

        ld a,c
        and 0x1f ;second/2
        ld c,a
        ld b,0
        add hl,bc
        
        pop bc
        pop de ;debc = days*86400/2

        add hl,bc
        jr nc,$+3
        inc de
        
;потом умножить на 2
        add hl,hl
        rl e
        rl d ;dehl=UNIX time
        ret

unix2dostime
;dehl=UNIX time
;out: ix=date, hl=time
;UNIX time (seconds since beginning of 1970) to DOS date, time
        ;jr $
;поделить на 2 (т.к. в DOS только двойные секунды)
        srl d
        rr e
        rr h
        rr l
;поделить на 86400/2 - в остатке время
        push de
        ld de,86400/2
        exx
        pop hl
        ld de,0
        exx
        call ldiv ; hl'hl = hl'hl / de'de ; de'de = hl'hl % de'de
;hl=дни
        push de ;de=двойные секунды

;в цикле по годам вычитать число дней, соответствующее годам
        ld d,-1 ;year 1970-1
unix2dostime_years0
        inc d ;d=0 = year 1970 etc
        ld a,d
        sub 2
        and 3
        ld bc,365
        jr nz,$+3
        inc bc
        or a
        sbc hl,bc
        jr nc,unix2dostime_years0
        add hl,bc
;d=year
;hl=days

;в цикле по месяцам вычитать число дней, соответствующее месяцам
        ld e,0
unix2dostime_months0
        inc e ;e=month (1..12)
        call countdays_month ;out: a=days
        ld c,a
        ld b,0
        or a
        sbc hl,bc
        jr nc,unix2dostime_months0
        add hl,bc
;d=year since 1970
;e=month=1..12
;hl=days
        ld a,d
        sub 10
        jr nc,$+3
        xor a ;year < 1980
        ld d,a
        inc l ;day (1..31)
        ld a,e ;month
        add a,a
        add a,a
        add a,a
        add a,a
        add a,a
        rl d
        ld hx,d
        or l
        ld lx,a
;ix = DOS date: %YYYYYYYM MMMDDDDD
        
        pop hl ;hl=двойные секунды

;в цикле по часам вычитать число 3600/2
        ld bc,3600/2
        xor a ;NC
unix2dostime_hours0
        inc a
        sbc hl,bc
        jr nc,unix2dostime_hours0
        add hl,bc
        dec a ;a=hours = 0..23
        add a,a
        add a,a
        add a,a
        ld d,a ;d=hours<<3
        
;в цикле по минутам вычитать число 60/2
        ld bc,60/2
        xor a ;NC
unix2dostime_minutes0
        inc a
        sbc hl,bc
        jr nc,unix2dostime_minutes0
        add hl,bc ;l=seconds/2
        dec a ;a=minutes = 0..59
        ld e,a
        xor a
        rr e
        rra
        rr e
        rra
        rr e
        rra
        or l
        ld l,a
        ld a,d ;d=hours<<3
        or e
        ld h,a
;hl = DOS time: %hhhhhmmm mmmsssss
        ret

; версия от 2006-12-18T15:11:28+0300
; Беззнаковое 32-разрядное деление
; функция состоит из двух частей:
; 1. 32-разрядное делимое и 16-разрядный
;    делитель.
; 2. 32-раздядное делимое и 32-разрядный
;    делитель.
; hl'hl = hl'hl / de'de
; de'de = hl'hl % de'de
ldiv
        push hl 
        xor a 
        ld l, a
        ld h, a 
        sub e 
        ld e, a
 ld a, h
        sbc a, d
        ld d, a
        exx 
        pop bc 
        ld a, 0
        sbc a, e
        ld e, a
        sbc a, d  ; de'de=0-divisor
        sub e
        ld d, a 
        and e
        inc a     ; Z=short divisor
        push hl 
        ld hl, 0  ; hl'hl=reminder
        exx 
        pop bc 
        ld a, b   ; a,c,bc'=divident

        jr nz, ldiv_long


    ; divisor = -00de
        ld b, 8
        rla 
ldivs0
        rl l 
        add hl, de 
        jr c, ldivs1
        sbc hl, de 
ldivs1  rla 
        djnz ldivs0

           ld b, c
           ld c, a
           ld a, b 
           ld b, 8
        rla
ldivs2
        adc hl, hl
        add hl, de
        jr c, ldivs3
        sbc hl, de
ldivs3  rla
        djnz ldivs2
        jr ldiv_long1


   ; divisor=-de'de
ldiv_long
        call ldiv_8
           ld b, c
           ld c, a
           ld a, b
        call ldiv_8
ldiv_long1
           exx 
           exa 
           ld a, b
           exa
           ld b, a
           exa
           exx 
        call ldiv_8
           exx
           exa
           ld a, c
           exa
           ld c, a
           exa
           exx 
        call ldiv_8

  ; result=c,bc',a -> hl'hl 
  ; reminder=hl'hl -> de'de 

        ex de, hl 
        ld l, a 
        ld a, c 
        exx
        ex de, hl 
        ld h, a
        ld l, b
        ld a, c 
        exx 
        ld h, a
        ret 


; hl'hl=reminder
; de'de=divisor
; a=divident
ldiv_8
        ld b, 8
        rla 
ldiv_8_0
        adc hl, hl
        exx
        adc hl, hl 
        exx
        add hl, de 
        exx 
        adc hl, de 
        exx 
        jr c, ldiv_8_1
        sbc hl, de 
        exx
        sbc hl, de
        exx 
ldiv_8_1
        rla 
        djnz ldiv_8_0
        ret 
         
        
untar
        ;ld (filenameaddr),hl
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        call openstream_file
        or a
        jp nz,openerror

readtar0
        ld de,header
         xor a
         ld (de),a
        ld hl,0x200
        call readstream_file
        ld hl,header
        ld a,(hl)
        or a
        jp z,untarend
         xor a
         ld (header+100),a ;на всякий случай, если длина имени = 100
        ld de,filename
        call copyname83
        
        ld a,(header+0x09c) ;type (0=file, 5=dir)
        cp '5'
        jr nz,readtar_nodir
;убираем слеш в конце
        ld hl,filename
        push hl
        xor a
        ld b,-1
        cpir
        ld a,'/'
        dec hl ;на терминаторе
        dec hl ;перед терминатором
        sub (hl)
        jr nz,$+3
        ld (hl),a ;0
        pop de ;ld de,filename
        OS_MKDIR
        jr readtar0
readtar_nodir

        ld bc,header+0x07c ;size in octal (TODO size in bytes - найти пример)
        call readoctal_dehl
        
;dehl=size
        push de
        push hl
        ld de,filename
        call SAVECREATE
        pop hl
        pop de
readfile0
        ld a,d
        or e
        ld bc,0x4000
        call z,minhl_bc_tobc
;bc=save size
        ld a,b
        or c
        jr z,readfileq
        push de
        push hl
        push bc
         push bc ;save size
;0x200 -> 0x200
;0x201 -> 0x400
        dec bc
        ld a,b
        add a,2
        and 0xfe
        ld h,a ;0..1->2, 2..3->4
        ld de,0xc000
        ld l,e;0
;DE = Buffer address, HL = Number of bytes to read
        push de
        call readstream_file
;hl=actual size
        pop de
         pop hl ;save size
        call SAVE
        pop bc
        pop hl
        pop de
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        jr readfile0
readfileq
        call SAVECLOSE

        ld bc,header+0x088 ;time in octal
        call readoctal_dehl
        call unix2dostime
        ld de,filename
        OS_SETFILETIME

        jp readtar0
untarend
        call closestream_file
noautoload
openerror
quit
        QUIT

readoctal_dehl
        ld hl,0
        ld d,h
        ld e,l
readtar_getsize0
        ld a,(bc)
        inc bc
        sub '0'
        ret c ;jr c,readtar_getsizeq
        add hl,hl
        rl e
        rl d
        add hl,hl
        rl e
        rl d
        add hl,hl
        rl e
        rl d
        adc a,l
        ld l,a
        ld a,h
        adc a,0
        ld h,a
        jr nc,$+3
        inc de
        jr readtar_getsize0
;readtar_getsizeq
        ret

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret
        
skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

prtext
;out: hl=after terminator
prtext0
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        jp prtext0

prcrlf
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        ret
        
;hl = size to write
;de = addr
SAVE
        ld a,(savefilehandle)
        ld b,a
        push iy
        OS_WRITEHANDLE
        pop iy
        ret

SAVECREATE
        push iy
        OS_CREATEHANDLE
;b=new file handle
        push af
        ld a,b
        ld (savefilehandle),a
        pop af
        pop iy
        ret

SAVECLOSE
        push iy
savefilehandle=$+1
        ld b,0
        OS_CLOSEHANDLE
        pop iy
        ret

;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot

;hl = poi to filename in string
;out: de = after last slash or start
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash or start
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.

copyname83
;hl->de
copyname83_element
        ld b,8
copyname83_0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_ext
        ld (de),a
        inc de
        djnz copyname83_0
;8 chars of name copied, wait for dot or slash or terminator
copyname83_skipname0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr nz,copyname83_skipname0
copyname83_ext
        ld (de),a ;'.'
        inc de
        ld b,3
copyname83_ext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_skipext0
        ld (de),a
        inc de
        djnz copyname83_ext0
copyname83_skipext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr nz,copyname83_skipext0
copyname83_endelement
        ld (de),a ;'/'
        inc de
        jr copyname83_element
copyname83_q
        ld (de),a ;0
        ret
        
strcopy
;hl->de
;out: hl,de after terminator
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

;oldtimer
;        dw 0

ttar
        db ".tar",0

wrheaderchecksum
        ld hl,tarfileheaderchecksumoctal
        ld bc,0x820
        ld (hl),c
        inc hl
        djnz $-2 ;fill with spaces
        ld hl,tarfileheader
        ld de,0
        ld bc,0x200
countheaderchecksum0
        ld a,(hl)
        add a,e
        ld e,a
        adc a,d
        sub e
        ld d,a
        cpi
        jp pe,countheaderchecksum0
;de=checksum
        ex de,hl
        ld de,0 ;dehl=checksum
        ld bc,tarfileheaderchecksumoctal_end
        xor a
        ld (bc),a
        dec bc
        ld a,' '
        ld (bc),a
        ld a,6
        jp wroctaldehl_adigits
        
wroctaldehl_adigits
;bc=text end (after last digit)
;a=number of digits
wroctaldehl_adigits0
        push af
        call wroctaldehl_dig
        pop af
        dec a
        jr nz,wroctaldehl_adigits0
        ret

wroctaldehl_dig
;bc=text end (after last digit)
        srl d
        rr e
        rr h
        rr l
        rra
        srl d
        rr e
        rr h
        rr l
        rra
        srl d
        rr e
        rr h
        rr l
        rra
        rlca
        rlca
        rlca
        and 7
        add a,'0'
        dec bc
        ld (bc),a
        ret
        
strmirror
;hl=string addr
        ld d,h
        ld e,l
        call strlen
        ld b,h
        ld c,l
         ld a,b
         or c
         ret z
;de=начало, bc=hl=длина
        ;ld h,b
        ;ld l,c
        add hl,de ;hl=конец+1
        srl b
        rr c ;bc=wid/2
mirrorbytes0
        dec hl
        ld a,(de)
        ldi
        dec hl
        ld (hl),a
        jp pe,mirrorbytes0
        ret
        
cpmname_to_dotname
;hl -> de
        push hl
        ld b,8
cpmname_to_dotname0
        ld a,(hl)
        cp ' '
        jr z,cpmname_to_dotname0q
        ld (de),a
        inc hl
        inc de
        djnz cpmname_to_dotname0
cpmname_to_dotname0q
        pop hl
        ld bc,8
        add hl,bc ;hl=pointer to ext
        ld a,(hl)
        cp ' '
        jr z,cpmname_to_dotnameq
        ld a,'.'
        ld (de),a
        inc de
        ld  c,3
        ldir
cpmname_to_dotnameq
        xor a
        ld (de),a
        ret

strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret
        
tarfileheader
        ds 100 ;filename
        db "0000777",0
        db "0000000",0
        db "0000000",0
;tarfilesizeoctal=$
        db "00000000000",0 ;11 цифр = 33 бита
tarfilesizeoctal_end=$-1
;tarfiletimeoctal=$
        db "00000000000",0 ;11 цифр = 33 бита
tarfiletimeoctal_end=$-1
tarfileheaderchecksumoctal=$
        db "007147 ",0
tarfileheaderchecksumoctal_end=$-1
tarfileordir=$
        db "0" ;0=file, 5=dir
        ds tarfileheader+0x101-$
        db "ustar"
        ds tarfileheader+0x200-$

        db 0 ;для затирания, если нет пути
filename
        db "depkfile.fil"
        ds filename+256-$ ;для длинных имён

filenametoopen
        ds 256
        
fcb
        ds FCB_sz
fcb_filename=fcb+FCB_FNAME        

fcbmask
        db 0
        db "???????????"
        ds FCB_sz-11-1
fcbmask_filename=fcbmask+FCB_FNAME

cmdprompt
        ds 256

tarname
        ds 256
        
        include "../_sdk/file.asm"
        
cmd_end
header
        ;ds 512

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "tar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
