;доступ к файловой системе только через буфер в #c000
;там подключена pgtemp, там лежит директория (а во время чтения/записи там file_buf, она же подключена с #4000, там буфер текущей строки картинки - TODO грузить туда)
;во время переброски строки в #4000 подключена pgtemp (там буфер текущей строки картинки), а в #8000,#c000 подключен bitmap
filelist_maxfiles=25

filelistx8=0
filelisty=0
filelistwid8=20
filelisthgt=filelist_maxfiles*8

savex8=23
savey=0
savewid8=4
savehgt=8

quitx8=36-3
quity=100
quitwid8=4+3
quithgt=8

exitx8=36
exity=192
exitwid8=4
exithgt=8

filenamex8=34
filenamey=0
filenamewid8=6 ;12 символов
filenamehgt=8

catbuf=#c000
scrbuf=#c000 ;for .scr
file_buf=#ff00
file_buf_end=file_buf+127

; I    1    0      2    Признак ВМР-файла - символы 'BM'       (+)
;      2    2      4    Размер ВМР-файла (байт)                (НАДО СФОРМИРОВАТЬ, ЧИТАТЬ НЕ НУЖНО)
;      3    6      4    Резерв (=0)                            (НАМ НЕ НУЖНО)
;      4   10      4    Смещение в байтах от начала файла до   
;                       начала описания растрового изображения (НАМ НЕ НУЖНО, у нас 118)
                                                              
; II   5   14      4    Размер Описания Изображения (=40 WINDOWS) (НАМ НЕ НУЖНО, всегда 40)
;      6   18      4    Ширина изображения (в пикселах)        (+)
;      7   22      4    Высота изображения (в пикселах)        (+)
;      8   26      2    Количество цветовых плоскостей (=1)    (НАМ НЕ НУЖНО, всегда 1)
;      9   28      2    Количество бит на пиксел               (+ 4, 8, 24 БИТ, ПОТОМ МОЖНО 1БИТ)
;     10   30      4    Вид сжатия информации (0,1 или 2)      (ПОКА ЧТО БЕЗ СЖАТИЯ)
;     11   34      4    Размер образа растрового изображения   (НАДО СФОРМИРОВАТЬ, ЧИТАТЬ НЕ НУЖНО)
;     12   38      4    Рекомендуемое горизон-ое разрешение    (НАМ НЕ НУЖНО)
;     13   42      4    Рекомендуемое вертикальное разрешение  (НАМ НЕ НУЖНО)
;     14   46      4    Количество цветов в палитре            (+)
;     15   50      4    Количество важных цветов в палитре     (НАМ НЕ НУЖНО)

;дальше идёт палитра (B, G, R, 0)

;дальше идёт картинка (длины строк в байтах кратны 4)

        macro READBYTE_A
        inc ly
        call m,readbyte_readbuf
        ld a,(iy)
        endm
        macro READBYTE_E
        inc ly
        call m,readbyte_readbuf
        ld e,(iy)
        endm
        macro READBYTE_D
        inc ly
        call m,readbyte_readbuf
        ld d,(iy)
        endm

        macro WRITEBYTE_A
        ld (iy),a
        inc ly
        call m,writebyte_writebuf
        endm

isfilename_act
        ld a,(fcb_filename+8)
        or #20
        cp 'a'
        ret

readfile_scr
;#c000=pgtemp
        ld de,scrbuf
        OS_SETDTA ;set disk transfer address = de
        ld b,#1b00/128
readfile_scr0
        push bc
        ld de,fcb
        OS_FREAD
        pop bc
        djnz readfile_scr0
        
        call delbitmap ;удалить текущую картинку и освободить странички
        ld hl,256
        ld (curbitmapwid_edit),hl
        ld hl,192
        ld (curbitmaphgt),hl
        call reserve_bmp_pages ;там genmuldewid_ahl
        ld hl,RSTPAL
        ld de,workpal
        ld bc,32
        ldir
        
        ld de,0 ;y
        ld hx,192
readfile_scrlines0
        ld lx,32
readfile_scrline0
        ld a,32
        sub lx
        ld c,a ;x(chr)
        ld a,e
        rla
        rla
        and %11100000
        add a,c ;x(chr)
        ld l,a
        ld a,e
        rra
        rra
        rra
        xor e
        and %00011000
        xor e
        and %00011111
        add a,scrbuf/256
        ld b,a ;bl=pixel addr
        rra
        rra
        rra
        and 3
        add a,scrbuf/256+#18
        ld h,a ;hl=attr addr
        ld a,(hl) ;attr
        and 7
        bit 6,(hl) ;bright
        jr z,$+4
        or 8
        ld (readfile_scr_ink),a
        ld a,(hl) ;attr
        rra
        rra
        rra
        and 15
        ld (readfile_scr_paper),a
        ld h,b ;hl=pixels attr
;e  = %TTYYYyyy
;hl = %110TTyyy YYYxxxxx
        ld a,c
        add a,a
        add a,a
        add a,a
        ld c,a
        ld b,0 ;bc=x
        ld a,(hl) ;pixels
        push af
        call calcbitmap_from_xy ;a=pg, hl=addr
        ;push bc
        SETPGBITMAPLOW
        ;pop bc
        pop af
        scf
        adc a,a
readfile_scrchr00
readfile_scr_paper=$+1
        ld (hl),0
        jr nc,$+4
readfile_scr_ink=$+1
        ld (hl),0
        add a,a
        ;inc bc
        inc hl ;строка имеет круглую длину 256, так что всё в одной страничке
        jr nz,readfile_scrchr00
        dec lx
        jr nz,readfile_scrline0
        inc de
        dec hx
        jr nz,readfile_scrlines0
        ret

readfile_rgbtopal
        call calcRGBtopal_pp
        ld (ix+1),a
        call calcRGBtopal_pp
        ld (ix),a
        inc ix
        inc ix
        ret

readfile_pal
        ld ix,workpal
        ld c,16
readfile_pal0
        call readbyte
        ld l,a ;r
        call readbyte
        ld d,a ;g
        call readbyte
        ld e,a ;e=B, d=G, l=R
        call readfile_rgbtopal
        dec c
        jr nz,readfile_pal0
        ret ;z

readbmp
;out: nz=ошибка
        call setpgtemp
        ld iy,file_buf_end

        call isfilename_act
        jr z,readfile_pal
        cp 's'
        jp z,readfile_scr

        call readbyte
        cp 'B'
        ret nz
        call readbyte
        cp 'M'
        ret nz
        push iy
        call delbitmap ;удалить текущую картинку и освободить странички
        pop iy
        
        call readlong ;размер ВМР-файла (байт) ;hlde
        call readlong ;резерв
        call readlong ;смещение в байтах от начала файла до начала описания растрового изображения
        call readlong ;размер описания изображения (обычно 40 в Windows)
        call readlong ;ширина
        ld (curbitmapwid_edit),de
        ;ld a,d;(curbitmapwid_view+1)
        ;ld (readbmp_checkendline_HSB),a
        ;ld a,e;(curbitmapwid_view)
        ;ld (readbmp_checkendline_LSB),a
        call readlong ;высота
        ld a,#3e ;ld a,N
        ld h,d
        ld l,e
        dec hl ;starty
        bit 7,d
        jr z,readbmp_noneghgt
        ld hl,0 ;starty
        call negde
        ld a,#18 ;jr
readbmp_noneghgt
        ld (readbmp_nextlinejrneghgt),a
        ld (curbitmaphgt),de
        ld (readbmp_starty),hl
        call readword ;количество цветовых плоскостей
        call readword ;количество бит на пиксел
        ld a,l
        ld (readbmp_bpp),a

        push iy
        call reserve_bmp_pages ;там genmuldewid_ahl
        pop iy
        call readlong ;вид сжатия информации
        call readlong ;размер образа
        call readlong ;Рекомендуемое горизон-ое разрешение (нет в ACDSee)
        call readlong ;Рекомендуемое вертикальное разрешение (нет в ACDSee)
        call readlong ;количество цветов в палитре (для 4бит не задаётся)
        ld a,d
        dec a
        or e
        jr z,readbmp_pal_256c
        ld a,e
        or a
        jr nz,$+4 ;число цветов не задано - будет 16
        ld a,16
readbmp_pal_256c
        push af
        call readlong ;количество важных цветов в палитре
;дальше идёт палитра?
        ld ix,workpal
        pop bc ;b=число цветов

        ld a,(readbmp_bpp)
        cp 24
        jr z,readbmp24

        ld c,0
readbmp_pal0
        call readlong ;e=B, d=G, l=R, h=0
        ld a,c
        cp 16
        call c,readfile_rgbtopal
        inc c
        ld a,c
        cp b
        jr nz,readbmp_pal0
;дальше идёт картинка?
        ;ld de,(curbitmaphgt)
        ;dec de ;y
readbmp_bpp=$+1
        ld a,0
        cp 4
        jr z,readbmp4
        jr c,readbmp1
readbmp8
        call readbmp_start
readbmp8_pic0
        call readbmp_linestart
;bc=x в bitmap
;de=y в bitmap
;hl=addr
readbmp8_pic00
        READBYTE_A
        and #0f
        call readbmp_putbyte_checkendline
        jr z,readbmp8_pic00
        call readbmp_nextline
        jr nz,readbmp8_pic0
        ret

readbmp24
        call readbmp_start
readbmp24_pic0
        call readbmp_linestart
;bc=x counter
;de=y в bitmap
;hl=addr
readbmp24_pic00
        push de
        READBYTE_E ;b
        READBYTE_D ;g
        READBYTE_A ;r
        rl d ;g
        ld d,a ;r
        ld a,%1
        rla ;g
        rl d 
        rla ;r
        rl e
        rla ;b ;a=%1grb
        pop de
        call readbmp_putbyte_checkendline
        jr z,readbmp24_pic00
        call readbmp_nextline
        jr nz,readbmp24_pic0
        ld hl,RSTPAL
        ld de,workpal
        ld bc,32
        ldir
        ret

;нельзя читать картинку прямо в bitmap, иначе байты округления в конце строки затрут другую строку
;читаем строку в pgtemp:tempc000, потом перебрасываем в bitmap
readbmp4
        call readbmp_start
readbmp4_pic0
        call readbmp_linestart
;bc=x counter
;de=y в bitmap
;hl=addr
readbmp4_pic00
        READBYTE_A
        ld (hl),a
         xor a
         rrd ;(hl)=%0000llll, a=%0000rrrr
        inc hl
        dec bc ;x counter
        call readbmp_putbyte_checkendline
        jr z,readbmp4_pic00
        call readbmp_nextline
        jr nz,readbmp4_pic0
        ret

readbmp1
        call readbmp_start
readbmp1_pic0
        call readbmp_linestart
;bc=x counter
;de=y в bitmap
;hl=addr
readbmp1_pic00
        READBYTE_A
        scf
        rla
readbmp1_pic000
        ld (hl),0
        rl (hl)
        inc hl
        dec bc ;x counter
        add a,a
        jr nz,readbmp1_pic000
        bit 7,b
        jr z,readbmp1_pic00
        call readbmp_nextline
        jr nz,readbmp1_pic0
        ret

readbmp_start
readbmp_starty=$+1
        ld de,0
        ld a,ly
        ld lx,a
        ret

readbmp_linestart
        ld a,(curpgtemp)
        SETPG16K ;для буфера текущей строки
        ;call setpgtemp ;для file_buf (должен быть выше #c000) ;уже подключен
        ld bc,(curbitmapwid_edit)
        dec bc
        ld hl,tempc000
;hl=addr
        ret

readbmp_putbyte_checkendline
;out: nz=endline
        ld (hl),a
        inc hl
        dec bc ;x counter
        bit 7,b
        ret

readbmp_nextline
;out: z=конец картинки
        ld bc,0
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
        push de
        call calcbitmap_setpg32k ;hl=addr
        ex de,hl
        ld hl,tempc000
        ld bc,(curbitmapwid_edit)
        ldir
        pop de
        call setpgtemp ;для file_buf (должен быть выше #c000), иначе readbyte обломится
        xor a ;z
readbmp_wait4bytes0
        call nz,readbyte
        ld a,ly
        xor lx
        and 3
        jr nz,readbmp_wait4bytes0
readbmp_nextlinejrneghgt=$
        jr readbmp_nextline_neghgt
        ld a,d
        or e
        dec de
        ret ;out: z=конец картинки
readbmp_nextline_neghgt
        inc de
        ld a,(curbitmaphgt)
        cp e
        ret nz
        ld a,(curbitmaphgt+1)
        cp d
        ret ;out: z=конец картинки

savebmp_inch
;readbmp_inch
        inc h
        bit 6,h
        ret z
        push af
        call calcbitmap_from_xy ;a=pg, hl=addr
        push bc
        SETPGBITMAPLOW
        pop bc
        pop af
        ret

readlong
;e,d,l,h
        call readword
        ex de,hl
readword
;l,h
        call readbyte
        ld l,a
        call readbyte
        ld h,a
        ret

readbyte
        READBYTE_A
        ret

readbyte_readbuf
        push bc
        push de
        push hl
        push ix
        ld de,file_buf
        push de
        OS_SETDTA ;set disk transfer address = de
        ld de,fcb
        OS_FREAD
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        ret

writelongzero
        ld hl,0
        ld d,h
        ld e,l
writelong
;e,d,l,h
        ex de,hl
        call writeword
        ex de,hl
writeword
;l,h
        ld a,l
        call writebyte
        ld a,h
        ;jp writebyte
writebyte
        WRITEBYTE_A
        ret
        
writebyte_writebuf
        push bc
        push de
        push hl
        push ix
        ld de,file_buf
        push de
        OS_SETDTA ;set disk transfer address = de
        ld de,fcb
        OS_FWRITE
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        ret
        
filemenu
        call isitclick
	ret nz ;кнопку уже держали

        ld hl,curpicname
        ld de,savepicname
        ld bc,12+1
        ldir
        
        ld (filemenu_exitsp),sp
        ld hl,RSTPAL
        call copytemp_setpal
filemenu_restart
        call prfilemenu
        ld a,ZONE_NO
        ld (prarr_zone),a;от этого зависит форма стрелочки
        
filemenuloop
;1. всё выводим
;2. ждём событие
;3. всё стираем
;4. обрабатываем событие
        call setpgshapes

        call ahl_coords
        call filemenu_invarrzone
        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr
        
        call waitsomething ;в это время стрелка видна
;что-то изменилось

        call setpgshapes

        call ahl_oldcoords
        call shapes_rearr
        call ahl_oldcoords
        call filemenu_invarrzone ;инвертировать пункт под стрелкой
        
        ld a,(mousebuttons)
        cpl
        and 7
        call nz,filemenu_fire
        call file_control_keys
        jr filemenuloop
filemenu_exit
filemenu_exitsp=$+1
        ld sp,0
        ;ld hl,workpalend
        ;call setpalhl
        jp showworkscreen
        
filemenu_quit
;TODO проверить, сохранены ли картинки
        QUIT
        
file_control_keys
        ld a,(key)
        cp cs6
        jr z,file_control_keys_down
        cp cs7
        jr z,file_control_keys_up
        cp key_redraw
        jp z,prfilemenu
        cp '1'
        jr z,file_control_keys_drive1
        cp '2'
        jr z,file_control_keys_drive2
        cp '3'
        jr z,file_control_keys_drive3
        cp '4'
        jr z,file_control_keys_drive4 ;TODO more drives
        sub '5'
        jr z,file_control_keys_drive0 ;a=0
        ret
        
file_control_keys_drive1
file_control_keys_drive2
file_control_keys_drive3
file_control_keys_drive4
        sub '0'
file_control_keys_drive0
file_control_keys_drive_fail0
        ld e,a
        push de
        OS_SETDRV
        pop de
        or a
        jr nz,file_control_keys_drive_fail
        ld a,e
        ld (curdrive),a
         pop af ;снимаем адрес возврата
        jp filemenu_restart
file_control_keys_drive_fail
curdrive=$+1
        ld a,0
        jr file_control_keys_drive_fail0
        
file_control_keys_down
        ld bc,(filelist_firstfilevisible)
        ld hl,filelist_maxfiles
        add hl,bc ;номер файла, который сейчас должен появиться ;CY=0
filelist_nfiles=$+1
        ld de,0
        sbc hl,de
        ret nc ;номер файла больше, чем число файлов
        inc bc
        ld (filelist_firstfilevisible),bc

        call setpgshapes

        ld hl,+(filelisty+8)*40 + filelistx8 + scrbase
        ld de,filelisty*40 + filelistx8 + scrbase
        ld bc,+(filelisthgt-8)*256 + filelistwid8
        call shapes_copybox
        
        ld de,+(filelisty + filelisthgt-8)*40 + filelistx8 + scrbase ;de=scr (начало строки)
        ld b,filelist_maxfiles-1 ;b=номер видимого файла
        jp prdirfile

file_control_keys_up
        ld hl,(filelist_firstfilevisible)
        ld a,h
        or l
        ret z
        dec hl
        ld (filelist_firstfilevisible),hl

        call setpgshapes

        ld de,+(filelisty+8)*40 + filelistx8 + scrbase
        ld hl,filelisty*40 + filelistx8 + scrbase
        ld bc,+(filelisthgt-8)*256 + filelistwid8
        call shapes_copybox
        
        ld de,+(filelisty)*40 + filelistx8 + scrbase ;de=scr (начало строки)
        ld b,0 ;b=номер видимого файла
        jp prdirfile
        
filemenu_fire
        call isitclick
        ret nz ;кнопка уже была нажата
        call ahl_coords
        call filemenu_isitsave
        jp c,savefile
        call filemenu_isitquit
        jp c,filemenu_quit
        call filemenu_isitexit
        jp c,filemenu_exit
        call filemenu_isitfilename
        jp c,editfilename
        call filemenu_findvisiblefilenumber
        ret nc;jp nc,filemenu_exit ;не попали в список файлов
        ;a = номер видимого файла
        call file_findvisiblefile_a
        call setpgtemp
        ld de,fcb
        push de ;FCB
        ld bc,32;FCB_sz
        ldir
        pop de ;FCB
	ld a,(fcb+FCB_FATTRIB)
	cp FATTRIB_DIR;0x10
	jr nz,filemenu_fire_not_dir
	pop af ;снимаем адрес возврата
        ld hl,fcb_filename
        ld de,temppicname
        push de
        call cpmname_to_dotname
        pop de ;DE = Pointer to ASCIIZ string
	OS_CHDIR
	jp filemenu_restart
filemenu_fire_not_dir
        OS_FOPEN
        or a
        jr nz,filemenu_fire_finish;error

        call readbmp ;nz=ошибка (тогда не менять имя файла)

        push af

        call setpgtemp ;т.к. после чтения bmp может быть любая страница там
        ld de,fcb
        push de
        OS_FCLOSE
        pop hl ;fcb
        inc hl ;имя в формате CP/M

        pop af
        jr nz,filemenu_fire_finish;error
        
        call isfilename_act
        jr z,filemenu_fire_finish ;если загрузили файл палитры, то не меняем имя текущей картинки

        ld de,curpicname
        call cpmname_to_dotname
filemenu_fire_finish
        ;call clearwindowstate ;a=0
        call kill_unfinished_shapes
        xor a
        ld h,a
        ld l,a
        ld (curbitmapxscroll),hl
        ld (curbitmapyscroll),hl
        jp filemenu_exit
        
cpmname_to_dotname
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

filemenu_invarrzone
;инвертировать пункт под стрелкой
;hl=x на экране
;a=y на экране
        call filemenu_isitsave
        ;ld bc,savey*256 + savex8 ;y, x/8
        ;ld de,savehgt*256 + savewid8 ;d=hgt ;e=wid
        jr c,filemenu_invarrzone_invert
        
        call filemenu_isitquit
        ;ld bc,quity*256 + quitx8 ;y, x/8
        ;ld de,quithgt*256 + quitwid8 ;d=hgt ;e=wid
        jr c,filemenu_invarrzone_invert
                
        call filemenu_isitexit
        ;ld bc,exity*256 + exitx8 ;y, x/8
        ;ld de,exithgt*256 + exitwid8 ;d=hgt ;e=wid
        jr c,filemenu_invarrzone_invert
                
        call filemenu_isitfilename
        ;ld bc,filenamey*256 + filenamex8 ;y, x/8
        ;ld de,filenamehgt*256 + filenamewid8 ;d=hgt ;e=wid
        jr c,filemenu_invarrzone_invert
        call filemenu_findvisiblefilenumber
        ret nc ;не попали в список файлов
        ;a = номер видимого файла
        add a,a
        add a,a
        add a,a
        add a,filelisty
        ld b,a ;y
        ld c,filelistx8 ;x/8
        ld de,8*256 + filelistwid8 ;d=hgt ;e=wid
filemenu_invarrzone_invert
        call setpgshapes
        jp shapes_invbox
        
filemenu_isitfilename
;hl=x на экране (не портится)
;a=y на экране (не портится)
;out: CY=1 - попали в редактируемое имя файла, bcde=размеры для invarrzone
        if 1==1
        ld bc,filenamey*256 + filenamex8 ;y, x/8
        ld de,filenamehgt*256 + filenamewid8 ;d=hgt ;e=wid
        jr filemenu_isitbox
        else
        cp filenamey
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        cp filenamey+filenamehgt
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        ld bc,filenamex8*8
        or a
        sbc hl,bc
        add hl,bc
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        ld bc,+(filenamex8*8)+(filenamewid8*8)
        or a
        sbc hl,bc
        add hl,bc
        ret ;nc=мимо
        endif

filemenu_isitsave
;hl=x на экране (не портится)
;a=y на экране (не портится)
;out: CY=1 - попали в Save, bcde=размеры для invarrzone
        if 1==1
        ld bc,savey*256 + savex8 ;y, x/8
        ld de,savehgt*256 + savewid8 ;d=hgt ;e=wid
        jr filemenu_isitbox
        else
        cp savey
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        cp savey+savehgt
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        ld bc,savex8*8
        or a
        sbc hl,bc
        add hl,bc
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        ld bc,+(savex8*8)+(savewid8*8)
        or a
        sbc hl,bc
        add hl,bc
        ret ;nc=мимо
        endif

filemenu_isitquit
;hl=x на экране (не портится)
;a=y на экране (не портится)
;out: CY=1 - попали в Quit, bcde=размеры для invarrzone
        ld bc,quity*256 + quitx8 ;y, x/8
        ld de,quithgt*256 + quitwid8 ;d=hgt ;e=wid
        jr filemenu_isitbox
        
filemenu_isitexit
;hl=x на экране (не портится)
;a=y на экране (не портится)
;out: CY=1 - попали в Exit, bcde=размеры для invarrzone
        ld bc,exity*256 + exitx8 ;y, x/8
        ld de,exithgt*256 + exitwid8 ;d=hgt ;e=wid
        ;jr filemenu_isitbox
filemenu_isitbox
;hl=x на экране (не портится)
;a=y на экране (не портится)
;b=y ;c=x/8 (не портятся)
;d=hgt ;e=wid/8 (не портятся)
;out: CY=1 - попали в бокс
        cp b ;y
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        sub b ;y
        cp d ;hgt
        jr nc,filemenu_isitbox_addbret ;nc=мимо
        add a,b
        push bc
        ;ld bc,x8*8
         ld b,0
         sla c
         rl b
         sla c
         rl b
         sla c
         rl b
        or a
        sbc hl,bc
        add hl,bc
        pop bc
        ccf
        ret nc ;jr nc,filemenu_invarrzone_nofilename ;nc=мимо
        push bc
        ;ld bc,+(x8*8)+(wid8*8)
         push af
         ld a,c ;x8
         add a,e ;wid8
         ld b,0
         add a,a
         rl b
         add a,a
         rl b
         add a,a
         rl b
         ld c,a
         pop af
        or a
        sbc hl,bc
        add hl,bc
        pop bc
        ret ;nc=мимо
filemenu_isitbox_addbret
        add a,b
        ret
        
filemenu_findvisiblefilenumber
;hl=x на экране
;a=y на экране
;out: nc = не попали в список файлов, a = номер видимого файла
        sub filelisty
        rra
        rra
        rra
        and 31
filelist_filesvisible=$+1        
        cp 0
        ret nc ;не попали по y в список файлов
        ld bc,filelistx8*8
        or a
        sbc hl,bc
        ld bc,filelistwid8*8
        or a
        sbc hl,bc
        ret ;nc = не попали по x в список файлов

prfilemenu
;FILINFO_sz=32
        call cls
        ld lx,0 ;фоновый цвет
        call prfilename
        ld de,tsave
        ld hl,savey*40 + savex8 + scrbase
        call shapes_prtext48ega_oncolor
        ld de,tquit
        ld hl,quity*40 + quitx8 + scrbase
        call shapes_prtext48ega_oncolor
        ld de,texit
        ld hl,exity*40 + exitx8 + scrbase
        call shapes_prtext48ega_oncolor

        call setpgtemp

        ld de,fcb
        OS_SETDTA ;set disk transfer address = de
        call makeemptymask
        ld de,fcbmask
        OS_FSEARCHFIRST
        or a
        
        ld de,catbuf
        ld bc,0 ;nfiles
        ;ld a,' '
        ;ld (de),a
        jr nz,loaddir_error
loaddir0
        ;ld a,(fcb+FCB_FNAME)
        ;cp ' ' 
        ;jr z,loaddirq
        push bc
        ld hl,fcb
        ld bc,32;FCB_sz
        ldir
        pop bc
        inc bc ;nfiles
         ;inc bc
        bit 1,b ;страничка pgtemp закончилась? max 512 файлов по 32 байта
         ;dec bc
        jr nz,loaddirq
        push bc
        push de ;catbuf
        ld de,fcb
        OS_SETDTA ;set disk transfer address = de
         ;call makeemptymask ;в CP/M не нужно, но отсутствие вредит многозадачности
         ld de,fcbmask ;в CP/M не нужно, но отсутствие вредит многозадачности
        OS_FSEARCHNEXT
        pop de ;catbuf
        pop bc ;nfiles
        or a
        jr z,loaddir0
loaddir_error
loaddirq
;bc=nfiles
        push bc
        call setpgs_scr
        pop bc
        
        ld (filelist_nfiles),bc
        ld hl,0
        ld (filelist_firstfilevisible),hl
        ld a,b
        or a
        jr nz,loaddir_max
        ld a,c
        cp filelist_maxfiles
        jr c,loaddir_maxq
loaddir_max
        ld c,filelist_maxfiles
loaddir_maxq
        ld a,c
        ld (filelist_filesvisible),a
        or a
        ret z ;нет файлов

        ld b,0 ;номер видимого файла
        ld de,filelisty*40 + filelistx8 + scrbase ;scr
prdir0
        push bc ;c=nfiles, b=номер видимого файла
        push de ;scr (начало строки)
        call prdirfile
        pop de ;scr (начало строки)
        ld hl,40*8
        add hl,de ;CY=0
        ex de,hl
        pop bc ;c=nfiles, b=номер видимого файла
        inc b
        dec c
        jr nz,prdir0
        ret

makeemptymask
        ld hl,fcbmask_filename
        ld d,h
        ld e,l
        inc de
        ld bc,11-1
        ld (hl),'?'
        ldir
        ret
        
prdirfile
;de=scr (начало строки)
;b=номер видимого файла
        push de ;scr (начало строки)
        ld a,b
        call file_findvisiblefile_a ;получили hl
        call setpgtemp
        ;ld de,filinfo
        ;ld bc,FILINFO_sz
        ld de,fcb_print
        ld bc,FCB_FATTRIB
        ldir
	ld a,(hl)
        and FATTRIB_DIR
	ld (prdirfile_dot_or_dir),a
        ld  c,32-FCB_FATTRIB ;FCB_sz-FCB_FATTRIB
        ldir
        ld lx,0
        call setpgshapes
        call setpgs_scr
        ;ld de,filinfo+FILINFO.FNAME
        ld de,fcb_print+FCB_FNAME
        ;ex de,hl
        ;push hl ;text
        ;xor a
        ;ld bc,15
        ;cpir ;hl будет указывать после нуля, bc=число оставшихся байт
        ;ld b,c
        ;dec hl
        ;ld (hl),' '
        ;inc hl
        ;djnz $-3
        ;ld (hl),b ;0
        ;pop de ;de=text
        pop hl ;hl=scr (начало строки)
        ;call shapes_prtext48ega_oncolor
        ld a,8
        call shapes_prNchars
        ld a,'.'
prdirfile_dot_or_dir=$+1
	xor 0
        call shapes_prchar48ega
        ld a,3
        call shapes_prNchars
        
        ex hl,de
        exx
        ;ld hl,(filinfo+FILINFO.FSIZE+2)
        ld hl,(fcb_print+FCB_FSIZE+2)
        exx
        ;ld hl,(filinfo+FILINFO.FSIZE)
        ld hl,(fcb_print+FCB_FSIZE)
        call shapes_prnumdword
        
;       shapes_prchar48ega
;a=char
;hl=scr
;       shapes_prnum
;de=scr
;hl=num       
;ld hl,(fcb_print+FCB_FTIME)
;       shapes_prNchars
;hl=scr
;de=text
;a=Nchars
        ld a,' '
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        
        ld hl,(fcb_print+FCB_FDATE)
        push hl
        ld a,h
        srl a
        sub 20
        jr nc,$+4
        add a,100 ;XX century
        call shapes_prNN ;year
        ld a,'-'
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and #0f
        call shapes_prNN ;month
        ld a,'-'
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        pop af
        and #1f
        call shapes_prNN ;day
        
        ld a,' '
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        
        ld hl,(fcb_print+FCB_FTIME)
        push hl
        ld a,h
        rra
        rra
        rra
        and #1f
        call shapes_prNN ;hour
        ld a,':'
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and #3f
        call shapes_prNN ;minute
        ld a,':'
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        pop af
        add a,a
        and #3f
        jp shapes_prNN ;second
        
file_findvisiblefile_a
;a = номер видимого файла
        ld l,a
        ld h,catbuf/(32*256)
filelist_firstfilevisible=$+1
        ld bc,0
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;(a+firstfilevisible)*FILINFO_sz = a*32
        ret

editfilename
editfilename0
        ld bc,filenamey*256 + filenamex8 ;y, x/8
        ld de,filenamehgt*256 + filenamewid8 ;d=hgt ;e=wid
        xor a
        call shapes_fillbox
editfilename_nokey
        call prfilename
        ;halt
        ;GET_KEY
        ;cp NOKEY
        ;jr z,editfilename_nokey
        YIELDGETKEYLOOP
        ld hl,savepicname
        cp key_enter
        ret z
        cp key_backspace
        jr z,editfilename_backspace
        cp 0x20
        jr c,editfilename_nokey ;прочие системные кнопки не нужны
        ld e,a
        ld bc,12
        xor a
        cpir
        dec hl ;hl=на терминаторе
        jr nz,editfilename0 ;не нашли терминатор = максимальная длина строки, нельзя вводить
        ld (hl),e
        inc hl
        ld (hl),a;0
        jr editfilename0
editfilename_backspace
        ld a,(savepicname)
        or a
        jr z,editfilename0 ;удалять нечего
        ld bc,12+1 ;чтобы точно найти терминатор
        xor a
        cpir
        dec hl ;hl=на терминаторе
        dec hl
        ld (hl),a;0
        jr editfilename0

prfilename
        call setpgshapes
        ld lx,0
        ld de,savepicname
        ld hl,filenamey*40 + filenamex8 + scrbase
        jp shapes_prtext48ega_oncolor

savefile
        call setpgtemp
        ld hl,savepicname
        ld de,catbuf
        ld bc,16
        push de
        ldir
        pop de ;ASCIIZ string for parsing (в #c000...)
        ld hl,fcb_filename ;Pointer to 11 byte buffer
        OS_PARSEFNAME
        ld de,fcb
        OS_FCREATE

        ld iy,file_buf

        call isfilename_act
        jp z,savefile_pal
        
;если bmp
        ld hl,savepicname
        ld de,curpicname
        ld bc,12+1
        ldir

        ld a,'B'
        call writebyte
        ld a,'M'
        call writebyte
        
        ld bc,(curbitmapwid_edit)
        dec bc
        ld a,c
        or 8-1
        ld c,a
        inc bc ;округлённая вверх до 4 байт (8 пикселей)
        ld a,c
        ld (savebmp4_pic00_widLSB),a
        ld a,b
        ld (savebmp4_pic00_widHSB),a
        srl b
        rr c
        ld de,(curbitmaphgt)
        call mulbcde_ahl
        ex de,hl
        ld bc,118
        ld l,a
        ld h,b;0
        push hl
        push de
        ex de,hl
        add hl,bc
        ex de,hl
        ld c,b ;0
        adc hl,bc
        
;hlde = hgt*wid_view/2 + 118
        call writelong ;размер ВМР-файла (байт)
        call writelongzero ;резерв
        ld  e,118
        call writelong ;смещение в байтах от начала файла до начала описания растрового изображения
        ld  e,40
        call writelong ;размер описания изображения (обычно 40 в Windows)
        ld de,(curbitmapwid_edit)
        call writelong ;ширина
        ld de,(curbitmaphgt)
        call writelong ;высота
        ld  l,1
        call writeword ;количество цветовых плоскостей
        ld  l,4
        call writeword ;количество бит на пиксел
        ld  e,0
        ld l,e;0
        call writelong ;вид сжатия информации

        pop de
        pop hl
;hlde = hgt*wid_view/2
        call writelong ;размер образа

        call writelongzero ;Рекомендуемое горизон-ое разрешение (нет в ACDSee)
        call writelong ;Рекомендуемое вертикальное разрешение (нет в ACDSee)
        ld  e,16
        call writelong ;количество цветов в палитре (для 16 можно не задавать)
        call writelong ;количество важных цветов в палитре
;дальше идёт палитра
        ld ix,workpal
        ld c,16
savebmp_pal0
        ld l,(ix)
        inc ix
        ld h,(ix)
        inc ix
;hl=color (DDp palette)
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        call calchexcolor
;b=#BB
;d=#RR
;e=#GG
        ld l,d
        ld h,0
        ld d,e
        ld e,b
        call writelong ;e=B, d=G, l=R, h=0
        dec c
        jr nz,savebmp_pal0
;дальше идёт картинка
        ld de,(curbitmaphgt)
        dec de ;y
savebmp4
savebmp4_pic0
        ld bc,0
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
        call calcbitmap_from_xy ;a=pg, hl=addr
        push bc
        SETPGBITMAPLOW
        pop bc
savebmp4_pic00
        ld a,(hl)
        inc bc ;x
        inc l
        call z,savebmp_inch
        rlca
        rlca
        rlca
        rlca
        or (hl)
        inc bc
        inc l
        call z,savebmp_inch
        WRITEBYTE_A
savebmp4_pic00_widLSB=$+1
        ld a,0
        cp c
        jr nz,savebmp4_pic00
savebmp4_pic00_widHSB=$+1
        ld a,0
        cp b
        jr nz,savebmp4_pic00
        dec de
        bit 7,d
        jr z,savebmp4_pic0
savefile_close_quit
        call writebyte_writebuf
        ld de,fcb
        OS_FCLOSE
        ; pop af ;снимаем адрес возврата (т.к. вызывали call filemenu_fire)
        ;jp filemenu
        jp filemenu_exit

savefile_pal
        ld ix,workpal
        ld c,16
savefile_pal0
        ld l,(ix)
        inc ix
        ld h,(ix)
        inc ix
;hl=color (DDp palette)
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        call calchexcolor
;b=#BB
;d=#RR
;e=#GG
        ld a,d ;r
        call writebyte
        ld a,e ;g
        call writebyte
        ld a,b ;b
        call writebyte
        dec c
        jr nz,savefile_pal0
        jr savefile_close_quit

fcb;=(-FCB_sz)&0xffff     ;ds FCB_sz
        ds FCB_sz
fcb_filename=fcb+FCB_FNAME        

fcb_print
fcbmask
        ds FCB_sz
fcbmask_filename=fcbmask+FCB_FNAME        

texit
        db "  Back",0
tquit
        db "  Quit to OS",0
tsave
        db "  Save",0

temppicname=#fe00 ;выше #c000
savepicname
        db "12345678.123",0
