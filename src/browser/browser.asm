        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

WGETBUF=0x0800
;WGETBUFSZ=0x0400
;WGETBEGINADDR=WGETBUF+WGETBUFSZ
;WGETENDADDR=WGETBEGINADDR+2

end1=0x3500

DISKBUF=0x3500;0xb000
DISKBUFsz=0x800;0x1000

LINEPIXELS=0x3d00 ;,wid8*2 (макс. размер = 512 для wid=2048) ;TODO раньше и поверх LINEGIF (чтобы pixels шли раньше, а attr затирал её в процессе конверсии)

STACK=0x3ffc
SPOIL4B=0x4000 ;микростек на 4 байта, нельзя ниже 0x3b00 ;раньше было в невидимой части страницы экрана, но сейчас мы переключаем экран с этим стеком

end2=0x7e00

depkbuf=0x7e00 ;32K+ for zip (match length of 3-258 bytes)
buf64k=0

FREE=0x8000 ;динамическая память jpeg, буфер строки gif
LINE1=0x9400 ;буфер строки 0x400*3? jpeg
LINE1_sz=0x0c00


COLOR=7
STATUSCOLOR=0x38

GIF_PIXELSIZE=0

HTMLTOPY=0
HTMLHGT=24
SCROLLHGT=HTMLHGT*8;192;200

BACKGROUNDCOLORLEVEL=0 ;при очистке буфера строки (для правильного правого края в остатке знакоместа)

MAXLINKSZ=256+256-1-2 ;запас под терминатор и Yy

EDITLINEY=192
EDITLINEMAXVISIBLEX=72

key_up_scroll=key_ssup ;=F7!
key_down_scroll=key_ssdown ;=F6!

       MACRO rdbyte
        INC LY
        LD A,(IY)
        CALL Z,RDBYH
       ENDM 

       MACRO ziprdbyte
        INC LY
        LD A,(IY)
        CALL Z,ZIPRDBYH
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
        ;exx
        endm
        
        org PROGSTART
cmd_begin
        ld sp,STACK ;не должен опускаться ниже #3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT
        call init        
        
;curfulllink нужен для сохранения в истории и использования пути для относительных ссылок
;linkbuf содержит ссылку (может быть относительная)
        if 1==0
        call setpgs_scr
        call setpgcode4000
        ld de,0xc000;0x0801
        call setxymc
        ld de,curfulllink;COMMANDLINE
        call prtextmc
        call setpgtemp8000
        ;jr $
        endif

        ;call keepcurlink

	jp browser_go_curfulllink
        
browser_godownload
	ld a,1
	ld (downloadflag),a
browser_go
;curfulllink содержит текущую ссылку (из неё брать путь), слеш в конце http://ser.ver уже есть
;в linkbuf лежит ссылка (может быть локальная)
;TODO перекодировать русские буквы в ссылке в %? только в набранной вручную?
        ld hl,linkbuf
        push hl
        push hl
        call strlen
        inc hl
        ;move block to end of buf:
        pop de;ld de,linkbuf
        ld b,h
        ld c,l ;size
        dec de ;linkbuf-1
        add hl,de ;end of data
        ld de,linkbuf+(MAXLINKSZ+1)-1
        lddr
        inc de ;begin of data
        ex de,hl
        pop de;ld de,linkbuf
recodelinkamp0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        or a
        jr z,recodelinkamp0q
        cp '&'
        jr nz,recodelinkamp0
        ld a,(hl)
        cp 'a'
        jr nz,recodelinkamp0
        inc hl
        ld a,(hl)
        cp 'm'
        jr nz,recodelinkamp0dec1
        inc hl
        ld a,(hl)
        cp 'p'
        jr nz,recodelinkamp0dec2
        inc hl
        ld a,(hl)
        cp ';'
        inc hl
        jr z,recodelinkamp0
        dec hl
        dec hl
recodelinkamp0dec2
        dec hl
recodelinkamp0dec1
        dec hl
        jr recodelinkamp0
recodelinkamp0q

        call keepcurlink
        
        call makefulllink
;curfulllink содержит полный url, собранный из старого curfullink и ссылки linkbuf

        if 1==0
        call setpgs_scr
        call setpgcode4000
        ld de,0x0000
        call setxymc
        ld de,curfulllink;COMMANDLINE
        call prtextmc
        call setpgtemp8000
        jr $
        endif
	
browser_go_curfulllink
	
        jr browser_backspaceq
keepcurlink
;для backspace: запомнить полный путь с протоколом и именем
;histaddr указывает на последний элемент истории
	call setpghist
histaddr=$+1
	ld de,0xc000
        ld a,d
	 cp -2 ;inc a
	jr nz,keeptohist_nooverflow
	 ld hl,0xc100+256
	ld de,0xc000
	 ld bc,0x3f00-256
	ldir ;forget oldest link
keeptohist_nooverflow
	ld hl,curfulllink;linkbuf
	 ld bc,254+256
	ldir
        ld hl,html_curtopy
        ld c,2
        ldir
	ld (histaddr),de
        ld (html_curtopy),bc ;0
        ret

remembercurlink
	ld hl,(histaddr)
	ld a,h
	cp 0xc0
	ret z ;jr z,browser_reload ;no history
	dec h
         dec h
	ld (histaddr),hl
	call setpghist
         ;jr $
        ld de,curfulllink;linkbuf
        ;call strcopy
	 ld bc,256+254
	ldir
        ld de,html_curtopy
        ldi
        ldi
        ret

browser_downloadthis
	ld a,1
	ld (downloadflag),a
browser_reload
;histaddr указывает на последний элемент истории
	;ld hl,(histaddr)
	;call setpghist
        ;ld de,curfulllink;linkbuf
        ;call strcopy
	jr browser_backspaceq

browser_backspace
;вспомнить старый путь с протоколом и именем, положить его в curfulllink
;сейчас histaddr указывает на последний элемент истории. идём назад и запомним новый указатель
        call remembercurlink

browser_backspaceq
;curfulllink содержит полный url, собранный из старого curfullink и ссылки linkbuf        
        ld sp,STACK ;не должен опускаться ниже #3b00! иначе возможна порча OS
        
        call unreservepages
        xor a
        ld h,a
        ld l,a
        ld (freemem_hl),hl
        ld (freemem_a),a

        call cleanstatusline
        call browser_editline_print
         ;call setpgcode4000 ;само восстанавливается
        call setpgtemp8000

         OS_GETTIMER ;hlde=timer
         ld (timebegin),de

        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http, 2=gopher, 3=https), hl=after "//"
        ld (curprotocol),a
        push hl ;hl=after "//"

;включить колбэки под нужный протокол
        ld bc,readstream_file
        ld de,closestream_file
        ld hl,openstream_file
         or a
         jr z,browser_go_changeprotocol_nohttp
        ld bc,readstream_http
        ld de,closestream_http
        ld hl,openstream_http
browser_go_changeprotocol_nohttp
        ld (openstream_patch),hl
        ld (readstream_patch),bc
        ld (closestream_patch),de
        
        pop hl

;hl=начало path без протокола
;выкидываем #... (TODO сохранить и использовать для перехода на якорь)
        push hl
        call strlen_tobc_keephl
        jr z,browser_open_skip
        ld a,'#'
        cpir
        jr nz,browser_open_skip
        dec hl
        ld (hl),0
browser_open_skip
        pop hl

        ex de,hl ;de=filename
openstream_patch=$+1
        call openstream_file
	or a
	jp nz,LOADERROR

	xor a
downloadflag=$+1
	cp 0
	ld (downloadflag),a
	jp nz,downloadfile
	
        call initframes_time_scroll
        
       LD IY,DISKBUF+DISKBUFsz-1

        call RDBYTE
         ;jr $
        ;cp '<'
        ;jp z,loadhtml
         ;cp 0x0a ;speccy.info
         ;jp z,loadhtml
        cp 'G'
        jp z,loadgif
        cp 0x89
        jp z,loadpng
        cp 0xff
        jp z,loadjpeg
        cp 'B'
        jr z,loadbmp
         ld a,(DISKBUF+1)
         cp '?' ;<?xml
         ld a,(DISKBUF)
         jp z,loadxml;svg ;надо искать !DOCTYPE HTML или svg
        jp nz,loadhtml;loadbmp_fail
        call RDBYTE
        cp 'M'
        jp nz,loadhtml;loadbmp_fail
loadbmp
; I    1    0      2    Признак ВМР-файла - символы 'BM'       (+)
;      2    2      4    Размер ВМР-файла (байт)                (НАДО СФОРМИРОВАТЬ, ЧИТАТЬ НЕ НУЖНО)
;      3    6      4    Резерв (=0)                            (НАМ НЕ НУЖНО)
;      4   10      4    Смещение в байтах от начала файла до   
;                       начала описания растрового изображения (НАМ НЕ НУЖНО, у нас 118)
                                                              
; II   5   14      4    Размер Описания Изображения (=40 WINDOWS) (НАМ НЕ НУЖНО, всегда 40 - в Linux больше!)
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
        ;jr $

        ld b,18-2 -4+1
;loadbmp_skipheader0
;        call RDBYTE
;        djnz loadbmp_skipheader0
        call read_b_bytes
         call GETDWORD_slow
         push de

        call GETDWORD_slow
        ex de,hl ;hl=wid ;TODO защита
        call setpicwid
        call GETDWORD_slow
        ;ld (curpichgt),de
        ex de,hl ;TODO защита
        call setpichgt
        
         pop hl
         ld a,l
         sub 12
         ld b,a
        ;ld b,54-26
        call read_b_bytes
        
        ;ld de,0
        ;ld hl,0 ;dehl=shift in file
        ;ld a,(filehandle)
        ;ld b,a
        ;OS_SEEKHANDLE

;TODO заказать блок памяти и грузить в него (можно грузить по одному байту, строчки конвертить по одной, тогда буфер bmp не нужен)
        
        call reservepage
        ret nz ;no memory
        ld hl,DISKBUF
        ld de,0xc000
        ld bc,DISKBUFsz
        ldir ;beginning of file is already read
        ld hl,0x4000-DISKBUFsz
        jr nvview_loadbmp0go
        
nvview_loadbmp0
        call reservepage
        ret nz ;no memory

        ld de,0xc000
        ld hl,0x4000
nvview_loadbmp0go
;DE = Buffer address, HL = Number of bytes to read
         push hl
        call readstream
;HL = Number of bytes actually read
        ld b,h
        ld c,l
         pop hl
        xor a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        jr z,nvview_loadbmp0
        
        ld h,a
        ld l,a ;0
        ld a,(npages)
        srl a
        rr h
        srl a
        rr h
        ld (freemem_hl),hl
        ld (freemem_a),a ;костыль (TODO заказывать память под bmp нормально)
        
        call reservefirstframeaddr
        call initframe ;один раз на картинку после setpicwid, setpichgt и после установки gifframetime ;заказывает память под конверченный кадр
;ahl=адрес памяти под конверченный кадр

        ld hl,54 ;TODO относительно начала bmp
        xor a
;перейти на последнюю строчку (чтобы рисовать снизу вверх, нужно менять drawscreenline_frombuf):
        if GIF_PIXELSIZE
        ld de,(curpicwid)
        else
        ld de,(curpicwidx3)
        endif
        dec de
        set 1,e
        set 0,e
        inc de ;округлили размер строки вверх до 4 байт: 0=>0, 1..3=>4, 4=>4...
        ld (bmplinestep),de
        ld bc,(curpichgt)
bmpfindlastline0
        add hl,de
        adc a,0
        dec hl
        cpi
        jp pe,bmpfindlastline0
        ld (putchar_hl),hl
        ld (putchar_a),a

        call setpgtemp8000

        ld bc,(curpichgt)
fill0
        push bc

        ld hl,(putchar_hl)
        ld a,(putchar_a)
bmplinestep=$+1
        ld bc,0
        or a
        sbc hl,bc
        sbc a,0
        ld (putchar_hl),hl
        ld (putchar_a),a        

        call islinevisible ;CY=invisible
        jr c,bmpgetline_ifvisibleq
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        ld bc,(bmplinestep)
        ld de,LINEGIF
        call getfrommem
        ld hl,LINEGIF
        call drawscreenline_frombuf
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS
bmpgetline_ifvisibleq
        call inccury

        pop bc
        cpi
        jp pe,fill0
        jp showgif ;jp closequit
        
downloadfile
        call reservepage
        ret nz ;no memory
	
	ld de,downloadfilename ;TODO сгенерировать из урла или HTTP ответа + запросить редактирование
;de=filename
        OS_CREATEHANDLE
;b=new file handle
        ld a,b
        ld (downloadfilehandle),a
	
downloadfile0
        ld de,0xc000
        ld hl,0x4000
;DE = Buffer address, HL = Number of bytes to read
         push hl
        call readstream
        ;jr $
;HL = Number of bytes actually read, A=error

	push hl
        ld de,0xc000
downloadfilehandle=$+1
	ld b,0
	OS_WRITEHANDLE
	pop hl

        ld b,h
        ld c,l
         pop hl
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        jr z,downloadfile0
	
	ld a,(downloadfilehandle)
	ld b,a
	OS_CLOSEHANDLE
	
	ld hl,downloadfilename
	inc (hl) ;TODO ввод имени

	jp closequit

DOCTYPEsz=9
loadxml;svg
;надо искать !DOCTYPE HTML или svg
;a=first char
         ld e,a
        ld hl,DISKBUF
        ld bc,DISKBUFsz-DOCTYPEsz
        ld a,'!'
        cpir ;костыль!
        ld bc,DOCTYPEsz-1
        add hl,bc
        ld a,(hl)
        or 0x20
        cp 's'
         ld a,e ;ld a,(iy) ;first char
        jp nz,loadhtml
        
        push af
        push iy
        ld e,3 ;6912
        OS_SETGFX
         call setpgscr4000
         call setpgtemp8000
         call setpgsvgc000
        LD      HL,#4000
        LD      DE,#4001
        LD      BC,#1800
        LD      (HL),L
        LDIR 
        LD      (HL),7
        LD      BC,#2FF
        LDIR 
        pop iy
        pop af ;a=(iy)=first char
        call readsvg
        ;jr $
         call setpgcode4000
loadsvgq0
        call yieldgetkeynolang ;z=nokey
        jr z,loadsvgq0
        cp key_enter
        jr nz,loadsvgq0
        ld e,2 ;MC hires mode
        OS_SETGFX
        ld e,0
        OS_CLS
loadsvgq1
        call yieldgetkeynolang
        call globalbuttons
        ;jp browser_backspace
        jr loadsvgq1
        ;jr showgif

loadpng
         call setpgtemp8000
        call readpng
        jr showgif

loadjpeg
        ;call initframes_time_scroll
        call readjpeg
        jr showgif
        
loadgif
        ;call initframes_time_scroll
        call readgif

showgif
        call showtime

showgif_firstframe
        ;jr $
nframes=$+1
        ld bc,0 ;0 или 1 выключают управление
        dec bc
        
        ld hl,(curpichgt_visible)
        ld de,SCROLLHGT+1
        or a
        sbc hl,de
        jr nc,showgif_drawevenifoneframe
        ld hl,(keepframe_linesize)
        ld de,80+1
        or a
        sbc hl,de
        jr nc,showgif_drawevenifoneframe
        dec bc
        bit 7,b
        inc bc
        jp nz,closequit;showgifq ;если 0 или 1 кадр
showgif_drawevenifoneframe

firstframeaddr=$+1
        ld hl,0
firstframeaddrHSB=$+1
        ld a,0
;bc=число кадров-1
showgif_frames0
        push bc
        
	push hl
	push af
        OS_GETTIMER ;hlde=timer
	pop af
	ex de,hl
	ex (sp),hl
        call showframe ;читает showframetime из кадра
	
	pop de ;timer
	
	push af
	push hl
	
showframetime=$+1
	ld hl,0 ;in 1/100 s
	inc hl
	srl h
	rr l
	add hl,de ;max timer for this frame
	ld (showframemaxtimer),hl

showframe_delay0
        call yieldgetkeynolang ;z=nokey
        ;cp key_enter
        ;jp z,closequit ;TODO restore stack
        ;cp 'z'
        ;jr z,showframe_setzoom
        call globalbuttons
        ld hl,(xscroll)
        cp key_left
        jr z,showframe_left
        cp key_right
        jr z,showframe_right
        ld hl,(yscroll)
        cp key_down
        jr z,showframe_down
        cp key_up
        jr z,showframe_up
showframe_nokey
        OS_GETTIMER ;hlde=timer
showframemaxtimer=$+1
	ld bc,0 ;max timer for this frame
	ex de,hl
	or a
	sbc hl,bc
	jp m,showframe_delay0 ;timer<maxtimer

	pop hl
	pop af

        pop bc
        dec bc
        bit 7,b
        jr z,showgif_frames0
        
        jp showgif_firstframe

showframe_setzoom
        ld hl,setzoom_patch
        ld a,(hl)
        xor 0x80
        ld (hl),a
        jp browser_reload

;TODO проблема, если задержка кадра слишком маленькая, успеем только один раз прочитать клавиши

showframe_left
;hl=xscroll
        dec hl
        res 0,l
        bit 7,h
        jr nz,showframe_nokey
        jr showframe_leftrightq

showframe_right
;hl=xscroll
;не двигаем xscroll, если правая граница (=keepframe_linesize-xscroll) получается <80
        inc hl
        inc hl
        ex de,hl
        ld hl,(keepframe_linesize)
        or a
        sbc hl,de
        ld bc,80
        or a
        sbc hl,bc
        ex de,hl
        jr nc,showframe_leftrightq
;предел скролла: xscroll=keepframe_linesize-80 >=0
         ld hl,(keepframe_linesize)
         or a
         sbc hl,bc
        jr c,showframe_nokey
showframe_leftrightq
        ld (xscroll),hl
        jr showframe_nokey

showframe_up
;hl=yscroll
        ld bc,8
        xor a
        sbc hl,bc
        jr nc,showframe_updownq
        ld h,a
        ld l,a
        jr showframe_updownq

showframe_down
;hl=yscroll
;не двигаем yscroll, если нижняя граница (=curpichgt_visible-yscroll) получается <SCROLLHGT(200)
        ld bc,8
        add hl,bc
        ex de,hl
        ld hl,(curpichgt_visible)
        or a
        sbc hl,de
        ld bc,SCROLLHGT;200
        or a
        sbc hl,bc
        ex de,hl
        jr nc,showframe_updownq
;предел скролла: yscroll=curpichgt_visible-SCROLLHGT >=0
         ld hl,(curpichgt_visible)
         or a
         sbc hl,bc
        jr c,showframe_nokey
showframe_updownq
        ld (yscroll),hl
        jr showframe_nokey


        
loadbmp_fail
closequit
        call closestream
         jr getkeyquit

LOADERROR
        call closestream
        ld de,tloaderr
        jr TYPE_ERROR
CONNECTIONERROR
        ld de,tconnerr
TYPE_ERROR
        push de
        call setpgs_scr
        call setpgcode4000
        ld a,STATUSCOLOR
        call initprcharmc
        ld de,0xc048
        call setxymc
        pop de
        call prtextmc

ERROR ;for jpeg
        ;jr $
ERROR2
        ;jr $
ERROR4
        ;jr $
getkeyquit
getkeyquit0
	;YIELD ;halt ;если сделать просто di:rst #38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        ;GET_KEY ;OS_GETKEYNOLANG
        ;ld a,c ;keynolang
        call yieldgetkeynolang
        call globalbuttons
        jr getkeyquit0
        
globalbuttons
        cp key_backspace
        jp z,browser_backspace
        cp '5'
        jp z,browser_reload
        cp 'z'
        jp z,showframe_setzoom
	cp 's'
	jp z,browser_downloadthis
	cp 'e'
	jp z,browser_editline
        cp key_esc
        ret nz
browser_quit
        ld a,(wgetloaded_pid)
        or a
        jr z,browser_quitq

;TODO проверить, что wget жив:
        ld e,a
        OS_WAITPID
        or a
        jr z,browser_quitq

        ld a,(wgetmainpg)
        SETPG32KHIGH
        ld a,0xff
        ld (0xc000+COMMANDLINE+2),a
browser_quitq
        QUIT

oraret
        or a
        ret
yieldgetkeynolang
;out: z=no key, no action
	YIELD ;halt ;если сделать просто di:rst 0x38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        GET_KEY
        ld lx,a ;keylang
        jr nz,oraret ;no focus (a=0, nz) => ret with Z
        ;jr z,yieldgetkeynolang_focus
        ;;ld de,(control_imer_oldmousecoords) ;no focus
        ;xor a
        ;ret
;yieldgetkeynolang_focus
         cp key_redraw ;!=0
         jr z,oraret ;a!=0 => ret with NZ ;эту кнопку нельзя подменять, иначе экран не перерисуется (NZ!)
;hl=(sysmousebuttons)
        ld a,l
        and 0xf0
control_imer_oldmousewheel=$+2
        ld hx,0
        ld (control_imer_oldmousewheel),a
        sub hx
        ld (mouse_scrollvalue),a
        jr z,yieldgetkeynolang_key
        ;jp p,yieldgetkeynolang_scrollup
        ;neg
        ;ld (mouse_scrollvalue),a        
        ld a,key_down_scroll
        ret m ;nz        
;yieldgetkeynolang_scrollup
        ld a,key_up_scroll
        ret ;nz
yieldgetkeynolang_key
        ld a,0
        ld (mouse_scrollvalue),a ;default scrollvalue
        ld a,l
        cpl
        ld l,a
        bit 0,l ;LMB
        ld a,key_enter
        ret nz
        bit 1,l ;RMB
        ld a,key_backspace
        ret nz
        ld a,lx ;keylang
        or a ;cp NOKEY ;keylang==0?
        ret nz ;jr nz,$+3
        cp c ;keynolang==0?
        ret nz
;no action? mouse coords change is also an action
        push bc
control_imer_oldmousecoords=$+1
        ld bc,0
        ld (control_imer_oldmousecoords),de
        ld a,b
        sub d
        ld d,a
        ld a,e
        sub c
        ld e,a
        ld (control_imer_mousecoordsdelta),de
        ld a,d
        or e
        ld a,0
        pop bc
        ret ;z/nz

closestream
closestream_patch=$+1
        jp closestream_file
        
tconnerr
        db "conn.err",0
tloaderr
        db "load err",0
        
showtime
         call setpgcode4000
        ld a,STATUSCOLOR
        call initprcharmc

         OS_GETTIMER ;hlde=timer
         ex de,hl
timebegin=$+1
         ld de,0
         or a
         sbc hl,de
         ld de,0xc04a
;d=y, e=x8
;hl=time (frames)
         jp prnumfrac
         
showmem
        ld a,(npages)
npages_old=$+1
        cp -1
        ret z
        ld (npages_old),a
        ld l,a
        ld h,0
        push hl
         call setpgcode4000
        ld a,STATUSCOLOR
        call initprcharmc
        pop hl
         ld de,0xc046
        jp prnum123
        
cleanstatusline
        call setpgs_scr
        call setpgcode4000
        xor a
        ld (browser_editline_scroll),a
        ld hl,EDITLINEY*256+(40*192)
        ld a,STATUSCOLOR
        call cleanlinemc
        ;ld a,STATUSCOLOR
        jp initprcharmc
         
;hl = poi to filename in string
;out: de = after last slash
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

makefulllink
;curfulllink = curfulllink+linkbuf
        ld hl,linkbuf
;если ссылка начинается со слеша, то надо отрезать весь путь, кроме сервера
        ld a,(hl)
        cp '/'
        jr z,browser_go_rootlink ;"/Timex"
        
        call isprotocolpresent
;nz=protocol absent (hl=link), z=protocol present (a=protocol (0=file, 1=http), hl=after "//")
        jr z,browser_go_protocolpresent ;протокол есть - linkbuf содержит полную ссылку (к ней только добавить / в случае http://ser.ver)
        ld a,(linkbuf+1)
        sub ':'
        jr z,browser_go_defaultprotocolpresent ;1:/file... => file://1:/file...
;нет протокола - взять текущий путь из curfulllink (т.е. отрезать всё после последнего слеша) и приклеить к нему эту ссылку (с учётом ../)
;слеш в конце http://ser.ver уже есть? не всегда! если ввели вручную, то нет
        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
         push hl
        call findlastslash. ;out: de = after last slash or beginning
         pop hl
         or a
         sbc hl,de
         jr nz,browser_go_noaddslashafterserver
         add hl,de
         push hl ;after "//"
         call addslashafterserver
         pop hl
         call findlastslash. ;out: de = after last slash
browser_go_noaddslashafterserver
;de=curfulllink+...=end of curdir (after slash)
        ld hl,linkbuf
browser_go_chdir
        ld a,'.'
        cp (hl)
        jr nz,browser_go_chdirq
        inc hl ;skip dot
         ld a,(hl)
         cp '/'
        inc hl ;if nz,skip another dot supposed
         jr z,browser_go_dotslash
        ld a,(hl)
        or a
        jr z,$+3
        inc hl ;skip / supposed
;hl=linkbuf+... (path/file without ../)
;de=curfulllink+...=end of curdir (after slash)
;remove last element of curdir = move de to previous slash
         ;jr $
        dec de ;at slash
        dec de
        ld a,(de)
        inc de
        inc de ;after slash
        cp '/' ;is it "//"?
        jr z,browser_go_chdir_error
        dec de ;at slash
        ex de,hl ;hl=at slash
        dec hl
        ld a,'/'
        ld b,-1
        cpdr
        inc hl ;at previous slash (might be last slash of "//")
        inc hl ;after slash
        ex de,hl ;de=curfulllink+...=end of curdir (after slash)
         jr browser_go_chdir
browser_go_chdir_error
browser_go_chdirq
;hl=linkbuf+... (path/file without ../)
;de=curfulllink+...=end of curdir (after slash)
        call strcopy
        jr browser_go_protocolpresentq
browser_go_defaultprotocolpresent
;1:/file... => file://1:/file...
;a=0
        call adddefaultprotocol
        jr browser_go_protocolpresentq
browser_go_dotslash=browser_go_chdir ;"./Timex"

browser_go_rootlink
;"/Timex"
;hl=linkbuf+... at slash
;если ссылка начинается с //, то надо отрезать весь путь, кроме протокола
         inc hl
         ld a,(hl)
         cp '/'
         jr z,browser_go_rootprotocol
         dec hl
         push hl
        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
        call findslash
        dec hl ;at slash
        ex de,hl ;de=curfulllink+ after server (at slash)
         pop hl
        jr browser_go_copyto;linkbuf

browser_go_protocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
        call addslashafterserver ;add / after http://ser.ver
        ld de,curfulllink
;browser_go_copytolinkbuf
        ld hl,linkbuf
browser_go_copyto
        call strcopy
browser_go_protocolpresentq
;curfulllink содержит полный url, собранный из старого curfullink и ссылки linkbuf
        ret

browser_go_rootprotocol
        inc hl
;hl=linkbuf+... after "//"
         push hl
        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
        ex de,hl ;de=curfulllink+ after protocol://
         pop hl
        jr browser_go_copyto;linkbuf

adddefaultprotocol
;1:/file... => file://1:/file...
;ser.ver... => http://ser.ver...
;a=protocol (0=file, 1=http)
        push af ;a=protocol (0=file, 1=http)
        or a
        ld hl,tfileprotocol
        jr z,$+5
        ld hl,thttpprotocol        
        ld de,curfulllink
        call strcopy
        dec de
        push de
        ld hl,linkbuf
        call strcopy        
        pop hl
        pop af ;a=protocol (0=file, 1=http)
        ret

addslashafterserver
;add / after http://ser.ver
;hl=after "//"
        call findslash
        ;call strlen_tobc_keephl
        ;ld a,'/'
        ;cpir
        ret z ;слеш уже есть
         ld (hl),c;0
         dec hl
         ld (hl),a ;add / after http://ser.ver
        ret

findslash
        call strlen_tobc_keephl
         ret z
        ld a,'/'
        cpir
        ret

strlen_tobc_keephl
;hl=string
        push hl
        xor a
        ld b,-1
        cpir
        pop de
        sbc hl,de
        ld b,h
        ld c,l ;bc=strlen
        ex de,hl ;hl=string
        ret

isprotocolpresent
;hl=link string
;out: nz=protocol absent (hl=link), z=protocol present (a=protocol (0=file, 1=http), hl=after "//")
        ld de,tfileprotocol
        push hl
        call strcp_tillde0 ;if found, hl=after "//"
        pop de
        ld a,0
        ret z
        ex de,hl
        ld de,thttpprotocol
        push hl
        call strcp_tillde0 ;if found, hl=after "//"
        pop de
        ld a,1
        ret z
        ex de,hl
        ld de,tgopherprotocol
        push hl
        call strcp_tillde0 ;if found, hl=after "//"
        pop de
        ld a,2
        ret z
        ex de,hl
        ld de,thttpsprotocol
        push hl
        call strcp_tillde0 ;if found, hl=after "//"
        pop de
        ld a,3
        ret z
        ex de,hl
        ret ;nz=protocol absent (hl=start)

nextscreenline
;out: de=старая строка, nc=out of screen
drawscreenline_frombuf_scr=$+1
        ld de,0
        ld hl,40
        add hl,de ;next line on screen
         ;push bc
         ld bc,40*(SCROLLHGT+1)+0x4000
         or a
         sbc hl,bc
         add hl,bc
         ;pop bc
         ret nc
        ;bit 5,h
        ;ret nz ;jr nz,drawscreenline_frombufq ;end of screen, current line doesn't fit
        ld (drawscreenline_frombuf_scr),hl
        ret
       
drawscreenline_frombuf
;hl=from
        exx
        call nextscreenline
        ;exx
        ;ret nc ;end of screen, current line doesn't fit

        push ix
        push iy
        
drawscreenline_frombuf_ixaddr=$+2
        ld ix,(dithermcy0-2)
drawscreenline_frombuf_iyaddr=$+2
        ld iy,(colorlace0-2)

        ;exx
        push af ;nc=out of screen
        push de ;screen
        ld de,LINEPIXELS;-0x4000
        ld hl,(keepframe_linesize)
        ld b,h
        ld c,l
        add hl,de
        exx
         call setpgdiv4000
         call setpgtemp8000 ;такой нам дали адрес        
        jr drawscreenline_frombuf0go
drawscreenline_frombuf0
        exx
        pop hl
drawscreenline_frombuf0go
readchr_patch=$+1
        call readchrlomem
        push hl
        call convertchr ;jp=1980t (не делает exx в конце, для удобства)
        inc de
        cpi ;делает inc hl
        jp pe,drawscreenline_frombuf0
        pop af
        
        dec ix
        dec ix
        ld (drawscreenline_frombuf_ixaddr),ix
        dec iy
        dec iy
        ld (drawscreenline_frombuf_iyaddr),iy
        
         ;call setpgs_scr
        exx
        pop bc ;screen
        pop af ;nc=out of screen
        ld hl,LINEPIXELS;-0x4000
;hl=data
;bc=screen=0xc000+
        call c,prlinefast

         call setpgtemp8000
         call setpgcode4000

        pop iy
        pop ix
        ret;jp setpgtemp8000
        
read_b_bytes
read_b_bytes0
        call RDBYTE
        djnz read_b_bytes0
        ret

RDBYTE
        INC LY
        LD A,(IY)
        RET NZ
RDBYH
;TODO проверка конца файла и возврат a=0, флаг CY=1?
        INC HY
        LD A,HY
        CP DISKBUF/256+(DISKBUFsz/256)
        LD A,(IY)
         ccf ;CY=0: OK
        RET nz
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
;hl=actual size (TODO if 0 then exit? сейчас конец последнего блока и пустого блока забивается нулями, нужно для html)
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

ZIPRDBYH
;TODO читать столько, сколько осталось в IDAT (если это не больше DISKBUFsz), потом искать следующий IDAT
        INC HY
        LD A,HY
        CP DISKBUF/256+(DISKBUFsz/256)
        LD A,(IY)
         ccf ;CY=0: OK
        RET nz

       PUSH HL
       PUSH DE
        PUSH BC
        push IX
       ;CALL rdCS
       ex af,af'
       PUSH AF
        exx
        push bc
        push de
        push hl
        
pngIDATremainedHSW=$+1
        ld de,0
pngIDATremained=$+1
        ld hl,0
ZIPRDBYH0read
        ld a,d
        or e
        ld bc,DISKBUFsz
        call z,minhl_bc_tobc ;keeps hl
;bc=size
        ;jr $
        ld a,b
        or c
        jr nz,ZIPRDBYHn0
;прочитать CRC
;прочитать chunksize
;прочитать "IDAT"
        ld de,DISKBUF
        ld hl,12
        call readstream
;вместо remained:
        ld hl,DISKBUF+4
        ld d,(hl)
        inc hl
        ld e,(hl)
        inc hl
        ld a,(hl)
        inc hl
        ld l,(hl)
        ld h,a
;снова посчитать размер текущего блока
        jr ZIPRDBYH0read
ZIPRDBYHn0
;bc=size
        or a
        sbc hl,bc
        ld (pngIDATremained),hl
        jr nc,$+3
        dec de
        ld (pngIDATremainedHSW),de
        ld d,b
        ld e,c
;de=size
        ld hl,DISKBUF+DISKBUFsz
        or a
        sbc hl,de ;size
        ex de,hl ;de=addr = DISKBUF+; hl=size
         push de
        call readstream
         pop de
         push de ;addr
;hl=actual size
         ld a,h
         or l
         jr z,ZIPRDBYHq;readerror
;move block to end of buf:
        ld b,h
        ld c,l
        dec de ;ld de,DISKBUF-1
        add hl,de ;end of data
        ld de,DISKBUF+DISKBUFsz-1
        sbc hl,de
        add hl,de
        jr z,ZIPRDBYHq
         pop af
        lddr
        inc de ;begin of data
         push de
ZIPRDBYHq
         pop iy ;addr = DISKBUF+
        
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
       LD A,(IY)
       or a ;CY=0: OK
        ret
        
        
        
        
readstream
readstream_patch=$+1
        jp readstream_file

rdCS    
        LD A,0
        OR A
        RET Z
rdCSU   
        LD A,0xfe
        IN A,(0xfe)
        LD (getCS+1),A
getCS
        LD A,0xff
        RRA 
        RET        

;читать быстро, а потом откатывать указатель файла
GETDWORD_slow
;hlde
        ;call RDBYTE
        ;ld e,a
        ;call RDBYTE
        ;ld d,a
        call GETWORD_slowhl
        ex de,hl
GETWORD_slowhl
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
        
        endif
        ret

readchrlomemx2
        ld d,chrbuf/256
_=0
        if GIF_PIXELSIZE
        dup 4
        ld a,(hl)
        inc hl
        ld (chrbuf+16+_),a
        ld (chrbuf+8+_),a
        ld (chrbuf+0+_),a
_=_+1
        ld (chrbuf+16+_),a
        ld (chrbuf+8+_),a
        ld (chrbuf+0+_),a
_=_+1
        edup
        else
        dup 4
        ld e,0xff&(chrbuf+16+_)
        ld a,(hl)
        ld (de),a
        inc e
        ldi ;b
        ld e,0xff&(chrbuf+8+_)
        ld a,(hl)
        ld (de),a
        inc e
        ldi ;g
        ld e,0xff&(chrbuf+0+_)
        ld a,(hl)
        ld (de),a
        inc e
        ldi ;r
_=_+2
        edup
        
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
        jp (iy) ;colorlace0 ;/1

ROUNDUP=32
ROUNDDOWN=32
        macro DOROUNDDOWN
         sub ROUNDDOWN
         jr nc,$+3
         xor a
        endm

        macro DOROUNDUP
         add a,d;ROUNDUP;d
         jr nc,$+3
         sbc a,a
        endm

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
       ld d,h ;e=mincolor
        ld a,(de);(hl) ;G
        DOROUNDDOWN
        ld c,a
        res 3,e
        ld a,(de);(hl) ;R
        DOROUNDDOWN
        ld b,a
        set 4,e
        ld a,(de);(hl) ;B
        DOROUNDDOWN
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
       ld a,(de) ;paper(maxcolor)
       or (hl) ;ink(mincolor)     
;a=attr
        exx
        ld (hl),a ;записать attr
        exx
;по реальным атрибутам заново пересчитать maxaxis, min, maxdist! (проверено, что без этого получается пятнистость):
        ld d,h
        dec h ;ld h,tmaxaxis/256+2
        ld l,a ;будем ходить по этой цветовой составляющей
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
        DOROUNDUP
        ld c,a
        res 3,l
        ld a,(hl) ;R
        DOROUNDUP
        ld b,a
        set 4,l
        ld a,(hl) ;B
        DOROUNDUP
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
        ld d,(hl) ;paper(maxcolor)
        ld l,e ;mincolor
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
        ld a,(hl) ;ink(mincolor)
        or d ;paper(maxcolor)
        exx
        ld (hl),a ;записать attr
        exx
;по реальным атрибутам заново пересчитать maxaxis, min, maxdist! (проверено, что без этого получается пятнистость):
        ld d,h
        dec h ;ld h,tmaxaxis/256+2
        ld l,a ;будем ходить по этой цветовой составляющей
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

putline
;hl=откуда копируем строку
;bc=сколько байт копируем
;на выходе сдвигает указатель, куда копируем (putchar_hl, putchar_a)
        ex de,hl
putchar_hl=$+1
        ld hl,0
putchar_a=$+1
        ld a,0
;de=from       
;ahl=to
;bc=size
        call puttomem
nextputlineaddr
;keeps bc
        ld a,(putchar_a)
        ld hl,(putchar_hl)
curpicwidx3=$+1
        ld de,0
        add hl,de
        adc a,0
setputlineaddr
        ld (putchar_hl),hl
        ld (putchar_a),a
        ret

getline
;de=куда достаём строку
;bc=сколько байт достаём
gifwasdisposalmethod=$+1
        ld a,0 ;bit0 = transparent color present, bit4..2 = disposal method (0=not specified(?), 1=do not dispose(?), 2=overwrite with bg color, 3=overwrite with prev frame(?))
        and 0x1c
        cp 8
        jr z,getline_fill
        ld hl,(nframes)
        ld a,h
        or l
        jr nz,getline_frommem
getline_fill
;фон первого кадра - заливка
        push de
gifbgcolor=$+1
         ld hl,PAL_GLOB
         ldi
         dec hl
         inc h
         ldi
         dec hl
         inc h
         ldi ;TODO проверить порядок компонент!
        pop hl
         ret po ;bc=0
        ldir
        ret

getline_frommem
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        jp getfrommem
        
curpicwid
        dw 0
curpichgt
        dw 0
curpichgt_visible
        dw 0


downloadfilename
	db "download.fil",0

tfileprotocol
        db "file://",0
thttpprotocol
        db "http://",0
tgopherprotocol
        db "gopher://",0
thttpsprotocol
        db "https://",0

linkbuf
        ds MAXLINKSZ+1
        
curfulllink
        ds MAXLINKSZ+1

        include "htmlview.asm"
        include "html.asm"
        include "prvirt.asm"
	include "mempgs.asm"
        include "dynmem.asm"
        include "../_sdk/file.asm"
        ;include "http.asm"
        include "gif.asm"
        include "drawmc.asm"
        include "editline.asm"
        
;oldtimer
;        dw 0
        
        align 256
textpages
        ds 256
;TODO ещё отдельно gfxpages (чтобы можно было удалять RGB после конверсии)

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
        incbin "../_sdk/codepage/winto866"
        
endcode=$
        
        ds end1-$
        display "free for code=",$-endcode

        ds 0x4000-$ ;stack
        align 256
fnt
        incbin "1125vert.fnt"
        include "http.asm"
	include "prmc.asm"
        include "jpeg.asm"
        include "png.asm"
depkbeg=$
initCRC
CRC32_
        ret
saveblock
savelastblock
        push af
        push bc
        push de
        push hl
;TODO ускорить
        ld de,depkbuf        
pngdepktoaddr=$+1
        ld hl,0
pngdepktoaddrHSB=$+1
        ld a,0
        ld bc,(Z6546) ;сколько байт сохранить
        ld (TD198),bc ;сколько байт сохраняли 


        inc bc
        jr saveblock0_go
;адрес 0x7e00..0xffff
saveblock0
        push bc
         push af
         call gifsetpgLZW
         pop af
        ex de,hl
        ld c,(hl)
        inc hl
        ex de,hl
        call writebyte
        pop bc
saveblock0_go
        dec hl
        cpi
        jp pe,saveblock0
        ld (pngdepktoaddr),hl
        ld (pngdepktoaddrHSB),a
         call gifsetpgLZW
        
        ld hl,0
        ld (Z6546),hl
        pop hl
        pop de
        pop bc
        pop af
        ret
depkqerror=ERROR        
ziptrees
        ds 0xa60 + 2*288
        include "../pkunzip/depk.asm"
        
        ;display "depk size=",$-depkbeg

wgetfilename
        db "wget.com",0

        include "init.asm"

free2=end2-$;0x8000-$
        display "free for code in 0x4000=",free2
        ds 0x8000-$
        
        incbin "tdiv"
;0xc000
        include "svg.asm"
        display "end=",$
        
cmd_end

	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "browser.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "user.l"
	LABELSLIST "../../us/user.l"
