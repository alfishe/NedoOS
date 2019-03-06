	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

FREE=0x8000 ;динамическая память jpeg, буфер строки gif
LINE1=0x9400 ;буфер строки 0x400*3? jpeg

DISKBUF=0xb000
DISKBUFsz=0x1000

COLOR=7

GIF_PIXELSIZE=0

HTMLTOPY=0
HTMLHGT=25

       MACRO rdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

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
        call init
        
browser_go
;в linkbuf лежит ссылка
;в COMMANDLINE лежит текущее имя файла
;для backspace: запомнить полный путь с протоколом и именем
        ld de,pathbuf
        push de
getpath_patch=$+1
        call getpath_file
        pop de
        ;DE = Filled in with whole path string (DRIVE:/PATH/ !!!)
        ld h,d
        ld l,e
        call strcopy
        dec de ;terminator
browser_oldfilename=$+1
        ld hl,emptyfilename
        call strcopy
        jr browser_backspaceq

browser_backspace
;вспомнить старый путь с протоколом и именем, положить его в COMMANDLINE
        ld de,linkbuf
        ld hl,pathbuf
        call strcopy

browser_backspaceq
        ld sp,#4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        
        call setpgs_scr

        call setpgcode4000

        ld de,0xc000;0x0801
        call setxymc
        ld de,linkbuf;COMMANDLINE
        call prtextmc
        
        ;ld de,0x1002
        ;call setxymc
        ;ld de,COMMANDLINE
        ;call prtextmc

        call setpgtemp8000

         OS_GETTIMER ;hlde=timer
         ld (timebegin),de

        ld hl,linkbuf
        ld de,COMMANDLINE
        push de
        call strcopy
        pop hl        
;command line = "<file to load>"

;если в имени файла стоит file://, то включить работу с файлами, если http://, то включить работу с http
        push hl
        ld de,tfileprotocol
        call strcp_tillde0 ;if found, hl=after "//"
        ld a,0
        jr z,browser_go_changeprotocol
        pop hl
        push hl
        ld de,thttpprotocol
        call strcp_tillde0 ;if found, hl=after "//"
        ld a,1
        jr z,browser_go_changeprotocol
        pop hl
        jr browser_go_nochangeprotocol
browser_go_changeprotocol
        ld (browserprotocol),a
        ;pop af ;skip old hl
        ex (sp),hl ;push hl
;включить колбэки под нужный протокол (или грузить http в файл, а потом открывать файл?)
        ld bc,readstream_file
        ld de,closestream_file
        ld hl,getpath_file
        exx
        ld bc,rootdir_file
        ld de,chdir_file
        ld hl,openstream_file
         or a
         jr z,browser_go_changeprotocol_nohttp
        ld bc,readstream_http
        ld de,closestream_http
        ld hl,getpath_http
        exx
        ld bc,rootdir_http
        ld de,chdir_http
        ld hl,openstream_http
browser_go_changeprotocol_nohttp
        ld (rootdir_patch),bc
        ld (chdir_patch),de
        ld (openstream_patch),hl
        exx
        ld (readstream_patch),bc
        ld (closestream_patch),de
        ld (getpath_patch),hl
;сменить текущий каталог на корневой
rootdir_patch=$+1
        call rootdir_file
        pop hl
browser_go_nochangeprotocol

browserprotocol=$+1
        ld a,0 ;0=file, 1=http

;hl=начало path без протокола

;сменить текущий каталог (или http-каталог) в соответствии с каталогом в ссылке
        push hl ;hl=начало path без протокола
        call findlastslash.
        ex de,hl ;hl=after last slash (filename)
        pop de ;начало path без протокола
        or a
        sbc hl,de
        add hl,de ;hl=filename, de=начало path без протокола, Z=(path len==0)
        jr z,browsernopath
        push hl ;filename
        dec hl
        ld (hl),0
;de=path
chdir_patch=$+1
        call chdir_file
        pop hl ;hl=filename
browsernopath
;hl=filename
         ld (browser_oldfilename),hl
        ex de,hl ;de=filename
openstream_patch=$+1
        call openstream_file

        ;ld hl,0
        ;ld de,0
       LD IY,DISKBUF+DISKBUFsz-1

        call RDBYTE
        cp '<'
        jp z,loadhtml
        cp 'G'
        jp z,loadgif
        cp 0xff
        jp z,loadjpeg
        cp 'B'
        jp nz,loadbmp_fail
        call RDBYTE
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
        call RDBYTE
        djnz loadbmp_skipheader0
        call GETDWORD_slow
        ex de,hl ;hl=wid
        call setpicwid
        call GETDWORD_slow
        ld (curpichgt),de
        
        ld b,54-26
loadbmp_skipheader1
        call RDBYTE
        djnz loadbmp_skipheader1
        
        ;ld de,0
        ;ld hl,0 ;dehl=shift in file
        ;ld a,(filehandle)
        ;ld b,a
        ;OS_SEEKHANDLE
        
        call reservepage
        ret nz ;no memory
        ld hl,DISKBUF
        ld de,0xc000
        ld bc,DISKBUFsz
        ldir ;beginning of file is already read
        ld hl,0x4000-DISKBUFsz
        jr nvview_load0go
        
nvview_load0
        call reservepage
        ret nz ;no memory

        ld de,0xc000
        ld hl,0x4000
nvview_load0go
;B = file handle, DE = Buffer address, HL = Number of bytes to read
         push hl
        ;ld a,(filehandle)
        ;ld b,a
        ;OS_READHANDLE
        call readstream
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l
         pop hl
        ;ld hl,0x4000
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        jr z,nvview_load0
        
        ld hl,0x8000+(40*199)
        ld (scrstartaddr),hl
        ld hl,-40
        ld (scrlinestep),hl
        ld hl,54
        xor a
        ld (bmpstart),hl
        ld (bmpstartHSB),a
        
        jp loadq
        
loadjpeg
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        ld (bmpstart),hl
        ld (bmpstartHSB),a

        call readjpeg

         jp closequit
        
loadgif
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        ld (bmpstart),hl
        ld (bmpstartHSB),a
        
        call readgif

         jp closequit
        
loadq_fromtop
        ld hl,0x8000
        ld (scrstartaddr),hl
        ld hl,40
        ld (scrlinestep),hl
        ld hl,0
        ld (bmpstart),hl
        
loadq

        
        call setpgdiv4000

bmpstartHSB=$+1
        ld a,0
bmpstart=$+1
        ld hl,0;54
        exx

        ld hl,(curpichgt)
        inc hl
        srl h
        rr l
        ld bc,200
        call minhl_bc_tobc
        ld b,c
       
        ld iy,colorlace0 ;1 хуже
        ld ix,dithermcy0
       
scrstartaddr=$+1
        ld hl,0x8000
fill0
;ahl' = readaddr
;hl = attraddr
        push bc
        push hl
        
        exx
        push af
        push hl
        exx
        
        ld e,(iy-2)
        ld d,(iy-1)
        ld hy,d
        ld ly,e
        
        ld e,(ix-2)
        ld d,(ix-1)
        ld hx,d
        ld lx,e

        call drawscreenline
        
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
        
loadbmp_fail
closequit

closestream_patch=$+1
        call closestream_file
        
quit
        ;jr $
         call setpgcode4000

         OS_GETTIMER ;hlde=timer
         ex de,hl
timebegin=$+1
         ld de,0
         or a
         sbc hl,de
         ld de,0xc040
;d=y, e=x8
;hl=time (frames)
         call prnumfrac

        YIELDGETKEYLOOP
        cp cs0
        jp z,browser_backspace
        ;QUIT
CONNECTIONERROR
ERROR ;for jpeg
        ;jr $
ERROR2
        ;jr $
ERROR4
        ;jr $
        QUIT
        
;hl = poi to filename in string
;out: de = after last slash
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z ;jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
;nfopenfnslashq.
;de = after last slash
	;ret

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

        
drawscreenline_frombuf
;hl=from
;bc=size (*3?)
        exx
drawscreenline_frombuf_scr=$+1
        ld de,0xc000
        
        ld hl,40
        add hl,de ;next line on screen
        bit 5,h
        exx
        ret nz ;jr nz,drawscreenline_frombufq ;end of screen, current line doesn't fit
        exx
        ld (drawscreenline_frombuf_scr),hl

        exx

         call setpgdiv4000
        ;call setpgs_scr ;177t
        call setpgscrc000
        
        push iy
        
drawscreenline_frombuf_ixaddr=$+2
        ld ix,(dithermcy0-2)
drawscreenline_frombuf_iyaddr=$+2
        ld iy,(colorlace0-2)
        
        ld a,(fillwid8)
        ld b,a
         ;ld b,80
drawscreenline_frombuf0
        push bc
        
        call readchrlomem
        ;if GIF_PIXELSIZE
        ;ld bc,8
        ;else
        ;ld bc,24
        ;endif
        ;add hl,bc
        push hl
        exx
        ld h,d
        ld l,e
        res 6,h ;de=адрес пикселей ;hl=адрес атрибутов
        exx
        ;jr $
         call setpgscr8000
        call convertchr ;jp=1980t
         call setpgtemp8000
        exx
        ld a,d
        xor 0x20
        cp d
        ld d,a
        jr nc,$+3
        inc de
        exx
        pop hl
        pop bc
        djnz drawscreenline_frombuf0
        
        dec ix
        dec ix
        ld (drawscreenline_frombuf_ixaddr),ix
        dec iy
        dec iy
        ld (drawscreenline_frombuf_iyaddr),iy
        
        ;ld hl,(drawscreenline_frombuf_scr)
        ;ld bc,40
        ;add hl,bc ;next line on screen
        ;bit 5,h
        ;jr nz,$+5
        ;ld (drawscreenline_frombuf_scr),hl

        pop iy
        ret;jp setpgtemp8000
        
drawscreenline
fillwid8=$+1        
        ld b,80
fill1
;цикл = 3130t/8pix
        ld d,h ;hl=адрес атрибутов
        ld e,l
        set 6,d ;de=адрес пикселей
        push bc
        exx
        call readchr ;859t
        ex af,af' ;push af
        push hl
        call setpgs_scr ;177t+
        call convertchr ;jp=1980t
;convertchrq
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

RDBYTE
        INC LY
        LD A,(IY)
        RET NZ
RDBYH
        INC HY
        LD A,HY
;RDBYHend=$+1
        CP DISKBUF/256+(DISKBUFsz/256)
        ;JR Z,rDDSK
        LD A,(IY)
         ccf ;CY=0: OK
        RET nz
;rDDSK
       PUSH HL
       PUSH DE
        PUSH BC
        push IX
       CALL rdCS
       ex af,af'
       PUSH AF
        exx
        push bc
        push de
        push hl
        ld de,DISKBUF
        ld hl,DISKBUFsz
        call readstream
;hl=actual size
;fill the rest of buffer with zeros
        ld de,DISKBUF
        add hl,de
        ex de,hl ;de=start of zeros
        ld hl,DISKBUF+DISKBUFsz
        xor a
        sbc hl,de
        ld b,h
        ld c,l ;bc=length of zeros (Z=no zeros)
        jr z,readdiskbuf_nozeros
        ld h,d
        ld l,e ;start of zeros
        ld (hl),a;0
        inc de
        dec bc
        ld a,b
        or c
        jr z,readdiskbuf_nozeros
        ldir
readdiskbuf_nozeros
        pop hl
        pop de
        pop bc
        exx
       POP AF
       ex af,af'
        POP IX
        pop BC
       POP DE
         pop hl
       ld iy,DISKBUF
       LD A,(IY)
       or a ;CY=0: OK
        RET 

readstream
readstream_patch=$+1
        jp readstream_file

;читать быстро, а потом откатывать указатель файла
GETDWORD_slow
;hlde
        call RDBYTE
        ld e,a
        call RDBYTE
        ld d,a
        call RDBYTE
        ld l,a
        call RDBYTE
        ld h,a
        ret
        
RDWORDHSBLSBtohl
        CALL RDBYTE
        LD H,A
        CALL RDBYTE
        LD L,A
        RET  

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
         call readchrlomem
        
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

readchrlomem
;hl=from (BRG)
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
         ;ldir ;BW from R
        
        endif
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
;colorlace_patch=$+1
        jp (iy) ;colorlace0 ;/1

ROUNDUP=32
ROUNDDOWN=32

        dw colorlace1
colorlace0
;d=maxcolor
;e=mincolor
;берём рекордные цвета (в виде color16):
;чтобы получить color16, надо сначала color64(=BBGGRR), потом по таблице из него
        ld h,chrbuf/256
        ld l,d ;maxcolor
        ld c,(hl) ;G
        res 3,l
        ld b,(hl) ;R
        set 4,l
        ld a,(hl) ;B
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
       ; ld d,(hl) ;d=maxcolor16=paper
       ; ld l,e ;mincolor
       ld d,h
        ;ld h,chrbuf/256
         ;ld e,ROUNDDOWN
        ld a,(de);(hl) ;G
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        ld c,a
        res 3,l
        ld a,(de);(hl) ;R
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        ld b,a
        set 4,l
        ld a,(de);(hl) ;B
         sub ROUNDDOWN
         jr nc,$+3
         xor a
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
        ld e,a;l,a
        ;ld h,t64to16ink/256
        ;ld a,(hl) ;a=mincolor16=ink
        ;or d
       ld a,(de)
       or (hl)       
;a=attr
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
        jp (ix) ;dithermcy0/1/2/3

        dw colorlace0
colorlace1
;d=maxcolor
;e=mincolor
;берём рекордные цвета (в виде color16):
;чтобы получить color16, надо сначала color64(=BBGGRR), потом по таблице из него
        ld h,chrbuf/256
        ld l,d ;maxcolor
         ld d,ROUNDUP
        ld a,(hl) ;G
         add a,d;ROUNDUP
         jr nc,$+3
         sbc a,a
        ld c,a
        res 3,l
        ld a,(hl) ;R
         add a,d;ROUNDUP
         jr nc,$+3
         sbc a,a
        ld b,a
        set 4,l
        ld a,(hl) ;B
         add a,d;ROUNDUP
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

        ld c,(hl) ;G
        res 3,l
        ld b,(hl) ;R
        set 4,l
        ld a,(hl) ;B
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
        jp (ix) ;dithermcy0/1/2/3
        
 ;0 бессмысленно (всегда NC), поэтому все значения увеличены на 1:
        dw dithermcy2
dithermcy3
        DITHERMC1B 0x1, 0xd, 0x3, 0xf
        ret;jp convertchrq
        
        dw dithermcy1
dithermcy2
        DITHERMC1B 0x9, 0x5, 0xb, 0x7
        ret;jp convertchrq
        
        dw dithermcy0
dithermcy1
        DITHERMC1B 0x4, 0x10, 0x2, 0xe
        ret;jp convertchrq
        
        dw dithermcy3
dithermcy0
        DITHERMC1B 0xc, 0x8, 0xa, 0x6
        ret;jp convertchrq
        
initframe
        ld hl,dithermcy0-2
        ld (drawscreenline_frombuf_ixaddr),hl
        ld hl,colorlace0-2
        ld (drawscreenline_frombuf_iyaddr),hl
        ld hl,0xc000
        ld (drawscreenline_frombuf_scr),hl
        ld hl,0
        ld (cury),hl
        ret
        
        
setpicwid
        LD (curpicwid),HL ;XRES
         ld b,h
         ld c,l
         add hl,hl
         add hl,bc
         ld (curpicwidx3),hl
        dec bc ;для округления вверх
        ld a,c
        srl b
        rra
        srl b
        rra
        srl b
        rra
        inc a ;округление вверх
        cp 80
        jr c,$+4
        ld a,80
        ld (fillwid8),a
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

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
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

setpgdiv4000
codepg8000=$+1
        ld a,0 ;tdiv
        SETPG16K ;0x4000
        ret
        
setpgcode4000
codepg4000=$+1
        ld a,0
        SETPG16K
        ret

setpgtemp8000
temppg8000=$+1
        ld a,0
        SETPG32KLOW
        ret

setpgs_scr
        call setpgscr8000
setpgscrc000
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret
setpgscr8000
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
        ret

putline
;hl=откуда копируем строку
;bc=сколько байт копируем
;на выходе сдвигает указатель, куда копируем (putchar_hl, putchar_a)
        
putchar_hl=$+1
        ld hl,0
putchar_a=$+1
        ld a,0
;de=from       
;ahl=to
;bc=size
        call puttomem
        
        ld a,(putchar_a)
        ld hl,(putchar_hl)
curpicwidx3=$+1
        ld bc,0
        add hl,bc
        adc a,0
        ld (putchar_hl),hl
        ld (putchar_a),a
        ret

curpicwid
        dw 0
curpichgt
        dw 0

zxpal
        incbin "zxpal"
        

filename
        ;db "0:/hippiman.bmp",0
        ;db "0:/melnchud.bmp",0
        ;db "0:/melnchud.gif",0
        ;db "0:/girl.jpg",0
        db "index.htm",0
emptyfilename=$-1
        ;db 0
tfileprotocol
        db "file://",0
thttpprotocol
        db "http://",0

linkbuf
        ds 128
pathbuf
        ds 128
        
        include "gif.asm"
        include "jpeg.asm"
        include "html.asm"
        include "dynmem.asm"
        include "file.asm"
        include "http.asm"
        
oldtimer
        dw 0
        
        align 256
textpages
        ds 256

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
        
twinto866
        incbin "winto866"
        
;LINE1
;        ds 0x400*3 ;TODO перенести в страницу и копировать в putline/drawscreenline_frombuf
endcode=$
        
        ds 0x4000-$-256 ;for stack
        display "free for code=",$-endcode
;DISKBUF
;        ds DISKBUFsz
;ROL_TAB
        ;ds 0x1000

        ds 0x4000-$ ;stack

fnt
        incbin "1125vert.fnt"

prnumfrac
;d=y, e=x8
;hl=time (frames)
         call setpgs_scr
         push hl
         call setxymc
         pop de
         ld bc,5000
         call prdigmc
         ld bc,500
         call prdigmc
         ld bc,50
         call prdigmc
         push de
         ld a,'.'
         call prcharmc
         pop de
         ld bc,5
         call prdigmc
         sla e
         ld bc,1
         ;call prdigmc
prdigmc
;hl=scraddr
;de=number
;bc=divisor
        ex de,hl
        ld a,'0'-1
        or a
prdigmc0
        inc a
        sbc hl,bc
        jr nc,prdigmc0
        add hl,bc
        ex de,hl
        push de
        call prcharmc
        pop de
        ret
        
prtextmc
prtextmc0
        ld a,(de)
        or a
        ret z
        push de
        call prcharmc
        pop de
        inc de
        jp prtextmc0
        
prcharmc
;a=code
;hl=scraddr
        ld e,a
        ld d,fnt/256
        ld bc,40
        ;push hl
        dup 4
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
prcharmc_italic1=$
        nop ;/add a,a
prcharmc_stroke=$+1
        or 0
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic2=$
        nop ;/add a,a
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic3=$
        nop ;/add a,a
        ld (hl),a
        inc d
        add hl,bc
        ld a,(de)
prcharmc_italic4=$
        nop ;/add a,a
prcharmc_underline=$
        nop ;/cpl
        ld (hl),a
        
        res 6,h
prcharmc_attr=$+1
        ld a,7
        ld bc,-40
        dup 7
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        
        ;set 6,h
        ;pop hl
        ld a,h
        xor 0x60
        cp 0xe0;h
        ld h,a
        ret nc
        inc l
        ret

prcharvirtual_tab_stateful
        ld a,(prcharvirtual_stateful_x)
        and 7 ;0..7
        cpl ;-1..-8
        add a,9
        ld b,a ;8..1
prcharvirtual_tab_stateful0
        push bc
        ld a,' '
        call prcharvirtual_stateful
        pop bc
        djnz prcharvirtual_tab_stateful0
        ret
        
prcharvirtual_stateful
;a=code
        push af
        ld h,twinto866/256
        ld l,a
        ld a,(hl)
        call printtostringbuf1
        pop af
        cp 32
        ret c
prcharvirtual_stateful_x=$+1
        ld a,0
        inc a
        ld (prcharvirtual_stateful_x),a
        cp 80
        ret c
prcharvirtual_crlf_stateful
        call savestringbuf1
        xor a
        ld (prcharvirtual_stateful_x),a
        ld (laststringx),a
        ld hl,(curprintvirtualy)
        inc hl
        ld (laststringy),hl
        ld (curprintvirtualy),hl
        ret
        
prcharmc_tab_stateful
        ld de,(prcharmc_stateful_xy)
        ld a,e
        add a,8
        and 0xf8
        ld e,a
        call setxymc_stateful
        jr prcharmc_tab_statefulq
        
prcharmc_stateful_setattr
        ld hl,prcharmc_stateful_setattr_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setattr_handler
        dec a
        ld hl,tfontweight
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        ld (prcharmc_attr),a
        jr prcharmc_stateful_resethandler
        
prcharmc_stateful_setitalic
        ld hl,prcharmc_stateful_setitalic_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setitalic_handler
        dec a
        rra
        sbc a,a
        and 0x87;add a,a
        ld (prcharmc_italic1),a
        ld (prcharmc_italic2),a
        ld (prcharmc_italic3),a
        ld (prcharmc_italic4),a
        jr prcharmc_stateful_resethandler
        
prcharmc_stateful_setstroke
        ld hl,prcharmc_stateful_setstroke_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setstroke_handler
        dec a
        rra
        sbc a,a
        ld (prcharmc_stroke),a
        jr prcharmc_stateful_resethandler
        
prcharmc_stateful_setunderline
        ld hl,prcharmc_stateful_setunderline_handler
        ld (prcharmc_stateful_patch),hl
        ret
prcharmc_stateful_setunderline_handler
        dec a
        rra
        sbc a,a
        and 0x2f;cpl
        ld (prcharmc_underline),a
prcharmc_stateful_resethandler
        ld hl,prcharmc_stateful_normal
        ld (prcharmc_stateful_patch),hl
        ret

        
prcharmc_stateful
;a=code
prcharmc_stateful_patch=$+1
        jp prcharmc_stateful_normal
prcharmc_stateful_normal
        cp 1
        jr z,prcharmc_stateful_setattr
        cp 2
        jr z,prcharmc_stateful_setitalic
        cp 3
        jr z,prcharmc_stateful_setstroke
        cp 4
        jr z,prcharmc_stateful_setunderline

        ;halt
        push af
        call setpgs_scr
        pop af
prcharmc_stateful_scr=$+1
        ld hl,0
        call prcharmc
        ld (prcharmc_stateful_scr),hl
        call setpgtemp8000
prcharmc_stateful_xy=$+1
prcharmc_stateful_x=prcharmc_stateful_xy
        ld de,0
        inc e
        ld a,e
prcharmc_tab_statefulq
        ld (prcharmc_stateful_xy),de
        cp 80
        ret ;c
        
prcharmc_crlf_stateful
        ;ld hl,(curprintvirtualy)
        ;inc hl
        ;ld (curprintvirtualy),hl
        ld de,(prcharmc_stateful_xy)
        ld e,0
        ld a,d
        add a,8
        ld d,a
        cp 8*(HTMLTOPY+HTMLHGT)
        jr c,setxymc_stateful
        sub 8
        ld d,a
        push de
        call scrollmcup
        pop de
setxymc_stateful
;de=yx
        ld (prcharmc_stateful_xy),de
        call setxymc
        ld (prcharmc_stateful_scr),hl
        ret
        
curprintvirtualy
        dw 0
        
scrollmcdown
        call setpgs_scr
        
        ld hl,0x8000+(40*8*(HTMLTOPY+HTMLHGT-1))
        ld b,HTMLHGT-1
scrollmcdown_rows0
        push bc
        ld d,h
        ld e,l
        ld bc,-40*8
        add hl,bc
        push hl
        call scrollmc_row
        pop hl
        pop bc
        djnz scrollmcdown_rows0
        ld hl,0xc000+(40*8*(HTMLTOPY))
        jr scrollmc_clearq
        
scrollmcup
         ;jp closequit
        call setpgs_scr
        
        ld hl,0x8000+(40*8*(HTMLTOPY))
        ld b,HTMLHGT-1
scrollmcup_rows0
        push bc
        ld d,h
        ld e,l
        ld bc,40*8
        add hl,bc
        push hl
        call scrollmc_row
        pop hl
        pop bc
        djnz scrollmcup_rows0
        ld hl,0xc000+(40*8*(HTMLTOPY+HTMLHGT-1))
scrollmc_clearq
        call cleanlinemc
        jp setpgtemp8000

cleanlinemc
;hl=0xc000+
        call scrollmcup_clblock
        set 5,h;ld hl,0xe000+(40*200)-(40*8)
        call scrollmcup_clblock
        res 6,h;ld hl,0xa000+(40*200)-(40*8)
        call scrollmcup_clblock
        res 5,h;ld hl,0x8000+(40*200)-(40*8)
        ;call scrollmcup_clblock
        ;ret        
scrollmcup_clblock
        push hl
        ld d,h
        ld e,l
        inc de
        ld bc,40*8-1
        ld (hl),0
        ldir
        pop hl
        ret

scrollmc_row
        ld b,8
scrollmc_row0        
        push bc
        push hl
        push de
        call scrollmc_line
        pop hl
        ld bc,40
        add hl,bc
        ex de,hl
        pop hl
        add hl,bc
        pop bc
        djnz scrollmc_row0
        ret
        
scrollmc_line
        ld bc,39
        ldir
        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        ld c,39
        lddr
        ld a,(hl)
        ld (de),a
        set 6,h
        set 6,d
        ld c,39
        ldir
        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d
        ld c,40
        lddr
        ret

setxymc
;de=yx (kept)
;out: hl=0xc000+
        ld b,0
        ld c,d
        ld h,b
        ld l,c
        add hl,hl
        add hl,hl
        add hl,bc ;*5
        add hl,hl
        add hl,hl
        add hl,hl ;*40
        ld c,e
         srl c
        ld b,0xc0
         jr nc,$+4
         ld b,0xe0
        add hl,bc
        ret

init
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
        ld (codepg4000),a
        ld a,h
        ld (codepg8000),a
        ld a,l
        ld (curpgLZW),a

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
        OS_NEWPAGE
        ld a,e
        ld (tpgs+5),a

        OS_NEWPAGE
        ld a,e
        ld (temppg8000),a

        
        ld e,0;COLOR
        OS_CLS

        ld de,zxpal
        ld c,CMD_SETPAL
        CALLBDOS

        ;call setpgcode4000
        ;call setpgtemp8000
        
;command line = "browser <file to load>"
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
        ld hl,filename
        ld de,linkbuf
        call strcopy
        ret

        ds 0x8000-$
        
        incbin "tdiv"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "browser.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
