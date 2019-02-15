	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

DISKBUF=0xb000
DISKBUFsz=0x1000

COLOR=7

GIF_PIXELSIZE=0

;b=R/G/Bmin
;de на начале буфера R/G/B
;h=maxdistdiv
;в диферинге ходим только по одной составляющей, остальные не читаем:
        macro DITHERMC1B ch0,ch1,ch2,ch3
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch0 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch1 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch2 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch3 ;chunklevel[x%4][y%4]
        rl c ;bits

        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch0 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch1 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch2 ;chunklevel[x%4][y%4]
        rl c ;bits
        ld a,(de) ;R(pixel)
        inc e
        sub b ;Rmin
         rra ;maybe<0
        ld l,a ;h=maxdistdiv
        ld a,(hl) ;inklevel
        cp ch3 ;chunklevel[x%4][y%4]
        ld a,c
        rla ;bits
        exx
        ld (de),a ;записать bits
        exx
        endm
        
        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        ld e,2 ;MC hires mode
        OS_SETGFX
        
        ;YIELD ;чтобы cmd мог доделать свои дела на экране

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
        ld a,d
        ld (setpgs_scr_high),a
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ;ld (curpg4000),a
        ld a,h
        ;ld (curpgpal),a
        ld a,l
        ld (curpgLZW),a
        ;ld (curpgtemp),a

;for JPEG:
        OS_NEWPAGE
        ld a,e
        ld (tpgs+0),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+1),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+2),a
        ;OS_NEWPAGE
        ;ld a,e
        ;ld (tpgs+3),a
        ;OS_NEWPAGE
        ;ld a,e
        ;ld (tpgs+4),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+5),a

        
        ld e,0;COLOR
        OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
        ld hl,filename
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle
        ld a,b
        ld (filehandle),a

        ;ld hl,0
        ;ld de,0

        call GETBYTE_slow
        cp 'G'
        jp z,loadgif
        cp 0xff
        jp z,loadjpeg
        cp 'B'
        jp nz,loadbmp_fail
        call GETBYTE_slow
        cp 'M'
        jp nz,loadbmp_fail

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


        
        ld b,18-2
loadbmp_skipheader0
        call GETBYTE_slow
        djnz loadbmp_skipheader0
        call GETDWORD_slow
        ld (curpicwid),de
        ld h,d
        ld l,e
        add hl,hl
        add hl,de
        ld (curpicwidx3),hl
        call GETDWORD_slow
        ld (curpichgt),de
        
        ld b,54-26
loadbmp_skipheader1
        call GETBYTE_slow
        djnz loadbmp_skipheader1
        
nvview_load0
        ;push bc
        push de
        push hl
        call reservepage
        pop hl
        pop de
        ;pop bc
        ret nz ;no memory

        ;push bc
        
        push de
        push hl
        ld de,0xc000
        ld hl,0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        ld a,(filehandle)
        ld b,a
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l
        ld hl,0x4000
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        pop hl
        pop de

        push af ;NZ = bytes to read != bytes actually read
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
        pop af ;NZ = bytes to read != bytes actually read

        ;pop bc

        ;or a
        jr z,nvview_load0
        
        ld hl,0x8000+(40*199)
        ld (scrstartaddr),hl
        ld hl,-40
        ld (scrlinestep),hl
        
        jr loadq
        
loadjpeg
        call readjpeg

        ld hl,0x8000
        ld (scrstartaddr),hl
        ld hl,40
        ld (scrlinestep),hl
        jr loadq
        
loadgif
;hlde=0
        call readgif

        ld hl,0x8000
        ld (scrstartaddr),hl
        ld hl,40
        ld (scrlinestep),hl
        
;hlde=true file size (for TRDOSFS)
loadq
        
;hlde=true file size (for TRDOSFS)
        ;ld (fcb+FCB.FSIZE),de
        ;ld (fcb+FCB.FSIZE+2),hl
        
        ;ld a,(filehandle)
        ;ld b,a
        ;OS_CLOSEHANDLE
        call closefile
        
noautoload

        ld de,zxpal
        ld c,CMD_SETPAL
        CALLBDOS


        ld hl,(curpicwid)
        dec hl ;для округления вверх
        ld a,l
        srl h
        rra
        srl h
        rra
        srl h
        rra
        inc a ;округление вверх
        cp 80
        jr c,$+4
        ld a,80
        ld (fillwid8),a
        
        ld a,0
        ld hl,0;+(640*3)
        exx

        ld hl,(curpichgt)
        inc hl
        srl h
        rr l
        ld bc,200
        call minhl_bc_tobc
        ld b,c
        ;ld b,200
       
scrstartaddr=$+1
        ld hl,0x8000
fill0
        ;ld hy,b
;ahl' = readaddr
;hl = attraddr
        push bc
        push hl
        
        exx
        push af
        push hl
        exx
        
        push af
        push hl
        ;ld a,b
         ld a,200
         sub b
        and 3
        add a,a
        ld l,a
        ld h,0
        ld bc,tdithermcpatch
        add hl,bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld (dithermc1b_patch),de
        pop hl
        pop af

fillwid8=$+1        
        ld b,80 ;TODO patch, TODO x not multiple of 8
fill1
;цикл = 3130t/8pix
        ld d,h
        ld e,l
        set 6,d
        push bc
        exx
        call readchr ;859t
        ex af,af' ;push af
        push hl
        call setpgs_scr ;177t
        call convertchr ;1990t
        pop hl
        exx
        ld a,h
        xor 0x20
        cp h
        ld h,a
        jr nc,$+3
        inc hl
        ex af,af' ;pop af
        pop bc
        djnz fill1
        
        exx
        pop hl
        pop af ;логический адрес начала строки
        call skipline
        call skipline
        exx
        pop hl
scrlinestep=$+1
        ld bc,40
        add hl,bc ;next line on screen
        pop bc
        djnz fill0

quit
        YIELDGETKEYLOOP
        QUIT
        
ERROR ;for jpeg
        jr $
ERROR2
        jr $
ERROR4
        jr $
        QUIT
        
loadbmp_fail
        call closefile
        jr quit

closefile
        ld a,(filehandle)
        ld b,a
        OS_CLOSEHANDLE
        ret
        
skipline
        if GIF_PIXELSIZE
        ld bc,(curpicwid)
        else
        ld bc,(curpicwidx3)
        endif
        add hl,bc
        ret nc
        inc a
        ret

;TODO читать быстро, а потом откатывать IY
GETDWORD_slow
;hlde
        call GETBYTE_slow
        ld e,a
        call GETBYTE_slow
        ld d,a
        call GETBYTE_slow
        ld l,a
        call GETBYTE_slow
        ld h,a
        ret
        
GETBYTE_slow
        push bc
        push de
        push hl
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        ld de,GETBYTE_slow_buf
        ld hl,1
        ld a,(filehandle)
        ld b,a
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
GETBYTE_slow_buf=$+1
        ld a,0
        pop hl
        pop de
        pop bc
        ret

readchr
;b,g,r
;TODO с масштабированием и с учётом правого края картинки, не делящегося на 8
        ;push bc
        push af
        push hl
        ;call ahl_to_pgaddr ;set pages in 32K
        rl h
        rla
        rl h
        rla
        srl h
        scf
        rr h
;a=page number in table (0..)
        ld e,a
        ld d,textpages/256
        ld a,(de)
        SETPG32KLOW
        inc e
        ld a,(de)
        SETPG32KHIGH
        ld d,chrbuf/256
_=0
        if GIF_PIXELSIZE
        dup 8
        ld a,(hl)
        inc hl
        ld (chrbuf+16+_),a
        ld (chrbuf+8+_),a
        ld (chrbuf+0+_),a
_=_+1
        edup
        else
        dup 8
        ld e,0xff&(chrbuf+16+_)
        ldi ;b
        ld e,0xff&(chrbuf+8+_)
        ldi ;g
        ld e,0xff&(chrbuf+0+_)
        ldi ;r
_=_+1
        edup
        
         ;ld hl,chrbuf
         ;ld de,chrbuf+8
         ;ld bc,16
         ;ldir
        
        endif
        pop hl
        pop af
        if GIF_PIXELSIZE
        ld bc,8
        else
        ld bc,24
        endif
        add hl,bc
        ;pop bc
        ret nc
        inc a
        ret
        
convertchr

chrbufG=64+8
;поиск 2 цветов (запоминаем положения рекордных цветов, чтобы потом их прочитать):
        ld hl,chrbuf
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Rmin
        ld b,c ;Rmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;R(pixel)
        cp c ;Rmin
        jr nc,$+2+1+2
         ld c,a ;Rmin
         ld e,_ ;Rmincolor = положение текущего цвета
        cp b ;Rmax
        jr c,$+2+1+2
         ld b,a ;Rmax
         ld d,_ ;Rmaxcolor = положение текущего цвета
_=_+1
        edup
        push de ;ld (Rminmaxcolor),de
        ld a,b
        sub c
        push af ;Rmax-Rmin

        inc l ;ld hl,chrbuf+8
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Gmin
        ld b,c ;Gmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;G(pixel)
        cp c ;Gmin
        jr nc,$+2+1+2
         ld c,a ;Gmin
         ld e,_ ;Gmincolor = положение текущего цвета
        cp b ;Gmax
        jr c,$+2+1+2
         ld b,a ;Gmax
         ld d,_ ;Gmaxcolor = положение текущего цвета
_=_+1
        edup
        push de ;ld (Gminmaxcolor),de
        ld a,b
        sub c
        push af ;Gmax-Gmin

        inc l ;ld hl,chrbuf+16
_=chrbufG
        ld de,_*257
        ld c,(hl) ;Bmin
        ld b,c ;Bmax
_=_+1
        dup 7
        inc l
        ld a,(hl) ;B(pixel)
        cp c ;Bmin
        jr nc,$+2+1+2
         ld c,a ;Bmin
         ld e,_ ;Bmincolor = положение текущего цвета
        cp b ;Bmax
        jr c,$+2+1+2
         ld b,a ;Bmax
         ld d,_ ;Bmaxcolor = положение текущего цвета
_=_+1
        edup
        ;ld (Bminmaxcolor),de
        ld a,b
        sub c ;Bmax-Bmin

;выбираем лучшую ось и её minmaxcolor:
        ld c,a ;maxdist
        pop af ;Gmax-Gmin
        pop hl ;Gminmaxcolor
        cp c ;>=maxdist?
        jr c,$+2+1+1
         ld c,a ;maxdist
         ex de,hl
        pop af ;Rmax-Rmin
        pop hl ;Rminmaxcolor
        cp c ;>=maxdist?
        jr c,$+2+1
         ex de,hl

;d=maxcolor
;e=mincolor
;берём рекордные цвета (в виде color16):
;чтобы получить color16, надо сначала color64(=BBGGRR), потом по таблице из него
        ld h,chrbuf/256
        ld l,d ;maxcolor
;округлять вверх! +32 (найдено подбором)
        ld a,(hl) ;G
ROUNDUP=32
         add a,ROUNDUP
         jr nc,$+3
         sbc a,a
        ld c,a
        res 3,l
        ld a,(hl) ;R
         add a,8;16;ROUNDUP;16 ;подгонка на лицах, но тогда greyscale становится розовым
         jr nc,$+3
         sbc a,a
        ld b,a
        set 4,l
        ld a,(hl) ;B
         add a,ROUNDUP
         jr nc,$+3
         sbc a,a
        rlca
        rlca
        rl c
        rla
        rl c ;g
        rla
        rl b
        rla
        rl b ;r
        rla ;BBGGRR
        or 0xc0
        ld l,a
        ;ld h,t64to16paper/256
        ld d,(hl) ;d=maxcolor16=paper
        ld l,e ;mincolor
        ;ld h,chrbuf/256
;округлять вниз! -32 (найдено подбором)
        if 1==0
        ld c,(hl) ;G
        res 3,l
        ld b,(hl) ;R
        set 4,l
        ld a,(hl) ;B
        else
        ld a,(hl) ;G
ROUNDDOWN=32
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        ld c,a
        res 3,l
        ld a,(hl) ;R
         sub 8;0;ROUNDDOWN;16 ;подгонка на лицах, но тогда greyscale становится розовым
         jr nc,$+3
         xor a
        ld b,a
        set 4,l
        ld a,(hl) ;B
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        endif
        rlca
        rlca
        rl c
        rla
        rl c ;g
        rla
        rl b
        rla
        rl b ;r
        rla ;BBGGRR
        and 0x3f
        ld l,a
        ;ld h,t64to16ink/256
        ld a,(hl) ;a=mincolor16=ink
        or d
;a=attr
        ;cp %11110110 ;p=0e,i=0e
        ;cp %01111110 ;p=07,i=0e
        ;dec hy
        ;dec hy
        ;jr nz,$+2+2+2
        ;cp #f1
        ;jr z,$
        ;inc hy
        ;inc hy
         ;ld a,0x38 ;%00111000
        exx
        ld (hl),a ;записать attr
        exx
        
;по реальным атрибутам заново пересчитать maxaxis, min, maxdist! (проверено, что без этого получается пятнистость):
        ld d,h
        dec h ;ld h,tmaxaxis/256+2
        ld l,a
        ld e,(hl) ;maxaxis*8
        dec h
        ld b,(hl) ;min
        dec h
        ld h,(hl) ;maxdistdiv
        
;b=R/G/Bmin
;de на начале буфера R/G/B
;h=maxdistdiv
;в диферинге ходим только по одной составляющей, остальные не читаем:
dithermc1b_patch=$+1
        jp dithermcy0


 ;0 бессмысленно (всегда NC), поэтому все значения увеличены на 1:
dithermcy3
        DITHERMC1B 0x1, 0xd, 0x3, 0xf
        ;DITHERMC1B 0x0, 0xc, 0x2, 0xe
        ret
dithermcy2
        DITHERMC1B 0x9, 0x5, 0xb, 0x7
        ;DITHERMC1B 0x8, 0x4, 0xa, 0x6
        ret
dithermcy1
        DITHERMC1B 0x4, 0x10, 0x2, 0xe
        ;DITHERMC1B 0x3, 0x0f, 0x1, 0xd
        ret
dithermcy0
        DITHERMC1B 0xc, 0x8, 0xa, 0x6
        ;DITHERMC1B 0xb, 0x7, 0x9, 0x5
        ret

tdithermcpatch
        dw dithermcy0
        dw dithermcy1
        dw dithermcy2
        dw dithermcy3
        
        
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

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

reservepage
;new page, set page in textpages, npages++, set page in #c000
;nz=error
        OS_NEWPAGE
        or a
        ret nz
npages=$+1
        ld hl,textpages
        ld (hl),e
        inc l
        ld (npages),hl
        ld a,e
        SETPG32KHIGH
        xor a
        ret ;z

unreservepages
unreservepages0
        call unreservepage
        jr z,unreservepages0
        ret
        
unreservepage
;del page, npages--
;nz=error
        ld hl,(npages)
        ld a,l
        or a
        jr z,unreservepage_fail
        dec l
        ld (npages),hl
        ld e,(hl)
        OS_DELPAGE
        xor a
        ret ;z
unreservepage_fail
        xor a
        dec a
        ret ;nz
        
reserve_bmp_pages
        ld de,(curpichgt)
        ld bc,(curpicwidx3)
        CALL MULWORD
        ld d,b
        ld e,c
        ;hlde=bmp size
;ищем адрес последнего байта картинки
        ex de,hl
        ld bc,0
        scf
        sbc hl,bc
        ex de,hl
        sbc hl,bc
;ищем номер страницы последнего байта картинки
        ld a,l
        rl d
        rla
        rl d
        rla ;a=lastpg
        inc a ;a=npages
        ld b,a
reserve_bmp_pages0
        push bc
        push hl
reserve_bmp_pages_fail        
        call reservepage
        or a
        jr nz,reserve_bmp_pages_fail ;repeat until success
        pop hl
        pop bc
        djnz reserve_bmp_pages0
        ret

readbyte
;out: c
        push af
        push hl
        call ahl_to_pgaddr
        ld c,(hl)
        pop hl
        pop af
skipbyte
        inc l
        ret nz
        inc h
        ret nz
        inc a
        ret
        
ahl_to_pgaddr
;keeps bc,de
;counts physical hl
        rl h
        rla
        rl h
        rla
        srl h
        scf
        rr h
        push bc
        call setpg32k
        pop bc
        ret

setpg32k
;a=page number in table (0..)
        push hl
        ld l,a
        ld h,textpages/256
        ld a,(hl)
        SETPG32KLOW
        inc l
        ld a,(hl)
        SETPG32KHIGH
        pop hl
        ret

setpgs_scr
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret

readdiskbuf
        exx
        push bc
        push de
        push hl
        ld de,DISKBUF
        ld hl,DISKBUFsz
filehandle=$+1
        ld b,0
        OS_READHANDLE
        pop hl
        pop de
        pop bc
        exx
        ret

putline
;hl=откуда копируем строку
;bc=сколько байт копируем
        ld (putchar_ldir_hl),hl
        push bc
        
putchar_hl=$+1
        ld hl,0
putchar_a=$+1
        ld a,0
        rl h
        rla
        rl h
        rla
        scf
        rr h
        scf
        rr h
;a=page number in table (0..)
        ld c,a
        ld b,textpages/256
        ld a,(bc)
        inc c
         ld (purchar_nextpgtabaddr),bc
        SETPG32KHIGH
        ex de,hl

        pop bc ;сколько байт копируем
        
;если строка не помещается в страничке, то копируем сколько помещается, включаем следующую страницу и копируем остаток
        ld hl,0
        or a
        sbc hl,de ;hl=сколько места осталось в страничке
        or a
        sbc hl,bc ;hl>=0: места хватает
        jr nc,putchar_ldir
;места не хватает -hl байт
         push hl ;-остаток ширины
        add hl,bc ;hl=сколько места осталось в страничке
        ld b,h
        ld c,l
        ld hl,(putchar_ldir_hl) ;локальное начало строки
        ldir
purchar_nextpgtabaddr=$+1
        ld a,(0)
        SETPG32KHIGH
        ld de,0xc000
;hl=остаток строки
         pop bc ;-остаток ширины
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;bc=остаток ширины
        ldir
        jr putchar_ldirq
putchar_ldir
putchar_ldir_hl=$+1
        ld hl,0 ;локальное начало строки
        ldir
putchar_ldirq
        
        ld a,(putchar_a)
        ld hl,(putchar_hl)
        ld bc,(curpicwidx3)
        add hl,bc
        adc a,0
        ld (putchar_hl),hl
        ld (putchar_a),a

        ret

curpicwid
        dw 0
curpicwidx3
        dw 0
curpichgt
        dw 0

zxpal
        incbin "zxpal"
        
        
        align 256
textpages
        ds 256

oldtimer
        dw 0

filename
        ;db "0:/hippiman.bmp",0
        ;db "0:/melnchud.bmp",0
        ;db "0:/melnchud.gif",0
        db "0:/girl.jpg",0

        include "gif.asm"
        include "jpeg.asm"
        
        align 256
tmaxaxis ;maxdistdiv_fromattr[256], min_fromattr[256], maxaxis_fromattr[256]
        incbin "tmaxaxis"
        ;align 256 ;непосредственно после tmaxaxis
t64to16ink
        incbin "t64to16i"
chrbuf
        ds 8 ;R
chrbufG=$&0xff
        ds 8 ;G
        ds 8 ;B
        ds 256-64-24-64
t64to16paper
        incbin "t64to16p"

endcode=$
        
        ds 0x4000-$-256 ;for stack
        display "free for code=",$-endcode
;DISKBUF
;        ds DISKBUFsz
;ROL_TAB
        ;ds 0x1000

        ds 0x4000-$ ;stack
        
        incbin "tdiv"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "browser.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
