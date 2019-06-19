        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

COLOR=7
        
        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускатьс€ ниже #3b00! иначе возможна порча OS
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
;провер€ем, это *.tar или файл/директори€? если файл/директори€, то еЄ надо паковать
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
;TODO директори€
        ;jr $
;формируем им€ архива (отрезаем расширение, если есть, и приписываем справа .tar)
        ld hl,filename
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
;провер€ем, что эта точка относитс€ к расширению, т.е. после неЄ нет слэшей
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

;создаЄм архив
        ld de,tarname
        call SAVECREATE
        or a
        jp nz,openerror
        
;открываем файл
        ld de,filename
        call openstream_file
        or a
        jp nz,openfileerror

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
        ld a,(filehandle)
        ld b,a
	OS_GETFILESIZE ;dehl=filesize
	;ld (filesize),hl
	;ld (filesizeHSW),de
        push de
        push hl
        
        ld bc,tarfilesizeoctal_end
        ld a,11
        call wroctaldehl_adigits
        
        ld de,filename
        OS_GETFILETIME ;out: ix=date, hl=time

        call dos2unixtime ;out: dehl=UNIX time
        ld bc,tarfiletimeoctal_end
        ld a,11
        call wroctaldehl_adigits

        call wrheaderchecksum
        ld de,tarfileheader
        ld hl,0x200
        call SAVE
        
        pop hl
        pop de
        
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
        
openfileerror

        call SAVECLOSE

        jp quit
        
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
        push hl
        ld hl,tdays_month-1
        add hl,de
        ld a,(hl)
        pop hl
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
        push hl ;time
        ld a,lx
        push af
        ld hl,0 ;число дней
        ld a,hx
        srl a
        add a,10
        ld d,a ;d=year since 1970 (0 for 1970)
;в цикле по годам прибавл€ть число дней, соответствующее годам
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
;в цикле по мес€цам прибавл€ть число дней, соответствующее мес€цам
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
        
        pop hl
        pop de ;dehl = days*86400/2

        add hl,bc
        jr nc,$+3
        inc de
        
;потом умножить на 2
        add hl,hl
        rl e
        rl d ;dehl=UNIX time
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
        jp z,tarend
         xor a
         ld (header+100),a ;на вс€кий случай, если длина имени = 100
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

        ld hl,0
        ld d,h
        ld e,l
        ld bc,header+0x07c ;size in octal (TODO size in bytes - найти пример)
readtar_getsize0
        ld a,(bc)
        inc bc
        sub '0'
        jr c,readtar_getsizeq
        dup 3
        add hl,hl
        rl e
        rl d
        edup
        adc a,l
        ld l,a
        ld a,h
        adc a,0
        ld h,a
        jr nc,$+3
        inc de
        jr readtar_getsize0
readtar_getsizeq
        
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
        jp readtar0
tarend
        call closestream_file
noautoload
openerror
quit
        QUIT

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
        ld a,b
        ld (savefilehandle),a
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

oldtimer
        dw 0

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
        dup 3
        srl d
        rr e
        rr h
        rr l
        rra
        edup
        rlca
        rlca
        rlca
        and 7
        add a,'0'
        dec bc
        ld (bc),a
        ret
        
        
tarfileheader
        ds 100 ;filename
        db "0000777",0
        db "0000000",0
        db "0000000",0
;tarfilesizeoctal=$
        db "00000000000",0
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
        
filename
        db "depkfile.fil"
        ds filename+256-$ ;дл€ длинных имЄн
        
tarname
        ds 256
        
        include "../_sdk/file.asm"
        
cmd_end
header
        ;ds 512

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "tar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
