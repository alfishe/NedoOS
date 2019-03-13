	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

FREE=0x8000 ;динамическая память jpeg, буфер строки gif
LINE1=0x9400 ;буфер строки 0x400*3? jpeg

DISKBUF=0xb000
DISKBUFsz=0x1000

COLOR=7
STATUSCOLOR=0x38

GIF_PIXELSIZE=0

HTMLTOPY=0
HTMLHGT=24

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
        
;curfulllink нужен для сохранения в истории и использования пути для относительных ссылок
;linkbuf содержит ссылку (может быть относительная)
        if 1==0
        call setpgs_scr
        call setpgcode4000
        ld de,0xc000;0x0801
        call setxymc
        ld de,curfulllink;COMMANDLINE
        call prtextmc ;TODO сформировать и напечатать полный путь с протоколом
        call setpgtemp8000
        ;jr $
        endif

        ;call keepcurlink

	jr browser_go_curfulllink
        
browser_godownload
	ld a,1
	ld (downloadflag),a
browser_go
;curfulllink содержит текущую ссылку (из неё брать путь), слеш в конце http://ser.ver уже есть
;в linkbuf лежит ссылка (может быть локальная)
;TODO перекодировать русские буквы в ссылке в %

        call keepcurlink

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
;слеш в конце http://ser.ver уже есть
        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
        call findlastslash. ;out: de = after last slash
        ld hl,linkbuf
browser_go_chdir
        ld a,'.'
        cp (hl)
        jr nz,browser_go_chdirq
        inc hl ;skip dot
         ld a,(hl)
         cp '/'
         jr z,browser_go_dotslash
        inc hl ;skip another dot supposed
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
browser_go_dotslash
;"./Timex"
browser_go_rootlink
;"/Timex"
;hl=linkbuf+... at slash
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
	inc a
	jr nz,keeptohist_nooverflow
	ld hl,0xc100
	ld de,0xc000
	ld bc,0x3f00
	ldir ;forget oldest link
keeptohist_nooverflow
	ld hl,curfulllink;linkbuf
	ld bc,254
	ldir
        ld hl,html_curtopy
        ldi
        ldi
	ld (histaddr),de
        ld hl,0
        ld (html_curtopy),hl
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
;вспомнить старый путь с протоколом и именем, положить его в COMMANDLINE
;сейчас histaddr указывает на последний элемент истории. идём назад и запомним новый указатель
	ld hl,(histaddr)
	ld a,h
	cp 0xc0
	jr z,browser_reload;jp z,getkeyquit ;jr z,$+3 ;no history
	dec h
	ld (histaddr),hl
	call setpghist
         ;jr $
        ld de,curfulllink;linkbuf
        ;call strcopy
	ld bc,254
	ldir
        ld de,html_curtopy
        ldi
        ldi

browser_backspaceq
;curfulllink содержит полный url, собранный из старого curfullink и ссылки linkbuf        
        ld sp,#4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        
        call unreservepages
        xor a
        ld h,a
        ld l,a
        ld (freemem_hl),hl
        ld (freemem_a),a

        call setpgs_scr
        call setpgcode4000
        ld hl,0xc000+(40*192)
        ld a,STATUSCOLOR
        call cleanlinemc
        ;ld a,STATUSCOLOR
        call initprcharmc
        ld de,0xc000;0x0801
        call setxymc
        ld de,curfulllink;linkbuf
        call prtextmc ;TODO сформировать и напечатать полный путь с протоколом
        call setpgtemp8000

         OS_GETTIMER ;hlde=timer
         ld (timebegin),de

        ld hl,curfulllink
        call isprotocolpresent
;a=protocol (0=file, 1=http), hl=after "//"
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
	
       LD IY,DISKBUF+DISKBUFsz-1

        call RDBYTE
        ;cp '<'
        ;jp z,loadhtml
         ;cp 0x0a ;speccy.info
         ;jp z,loadhtml
        cp 'G'
        jp z,loadgif
        cp 0xff
        jp z,loadjpeg
        cp 'B'
        jp nz,loadhtml;loadbmp_fail
        call RDBYTE
        cp 'M'
        jp nz,loadhtml;loadbmp_fail

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
;DE = Buffer address, HL = Number of bytes to read
         push hl
        call readstream
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l
         pop hl
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
        
downloadfile
        call reservepage
        ret nz ;no memory
	
	ld de,downloadfilename ;TODO сгенерировать из урла + запросить редактирование
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
	inc (hl)

	jp closequit

	
loadjpeg
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        ld (bmpstart),hl
        ld (bmpstartHSB),a

        ;jr $
        call readjpeg

         jp closequit
        
loadgif
        ld hl,(putchar_hl)
        ld a,(putchar_a)
        ld (bmpstart),hl
        ld (bmpstartHSB),a
        
        call readgif

showgif
        ;jr $
nframes=$+1
        ld bc,0
        ld a,c
        dec a
        or b
        jp z,closequit;showgifq
firstframeaddr=$+1
        ld hl,0
firstframeaddrHSB=$+1
        ld a,0
        
showgif_frames0
        push bc
        
	push hl
	push af
        OS_GETTIMER ;hlde=timer
	pop af
	ex de,hl
	ex (sp),hl
	
        call showframe
	
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

showframedelay0
        call yieldgetkeynolang ;nz=nokey
        jp nz,closequit ;TODO restore stack
        OS_GETTIMER ;hlde=timer
showframemaxtimer=$+1
	ld bc,0 ;max timer for this frame
	ex de,hl
	or a
	sbc hl,bc
	jp m,showframedelay0 ;timer<maxtimer
        
	pop hl
	pop af
	
        pop bc
        dec hl
        cpi
        jp pe,showgif_frames0
        
         jp showgif;closequit
        
;TODO быстрый вывод (см. два варианта в gfxideas.txt)

showframe
;ahl=addr
        call readword ;de
        push de ;ld (showframe_nextaddr),de
        call readbyte ;c
        ld b,c
        push bc ;ld (showframe_nextaddrHSB),bc
        call readword
	ld (showframetime),de
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a        

        call setpgtemp4000

        ld hl,0xc000
        ld bc,(curpichgt)
        inc bc
        srl b
        rr c ;TODO с учётом зума
showframelines0
        push bc
        push hl

         push hl
        ld hl,(keepframe_linesize)
        add hl,hl
        ld b,h
        ld c,l ;size
        push bc
        ld de,KEEPFRAMELINE
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        call getfrommem
        pop bc ;size
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        add hl,bc
        adc a,0
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a
         pop hl
        
        call setpgs_scr
        ld de,KEEPFRAMELINE
;pixels?
        push hl
        xor a
        call copylinetoscr
        set 5,h
        ld a,1
        call copylinetoscr
        pop hl
;attr?
        res 6,h
        xor a
        call copylinetoscr
        set 5,h
        ld a,1
        call copylinetoscr
        
        pop hl
        ld bc,40
        add hl,bc
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,showframelines0
        
        pop af
        pop hl ;next
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        ret
        
        
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
        call closestream
        
showtimequit
         call setpgcode4000
        ld a,STATUSCOLOR
        call initprcharmc

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
        ld de,0xc040;0x0801
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
        cp cs0
        jp z,browser_backspace
        cp '5'
        jp z,browser_reload
	cp 's'
	jp z,browser_downloadthis
        cp csSpace
        jr nz,getkeyquit0
browser_quit
        QUIT

yieldgetkeynolang
	YIELDGETKEY
        ld a,c
        ret

closestream
closestream_patch=$+1
        jp closestream_file
        
tconnerr
        db "conn.err",0
tloaderr
        db "load err",0
        
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
        ret ;nz=protocol absent (hl=start)

nextscreenline
drawscreenline_frombuf_scr=$+1
        ld de,0xc000
        ld hl,40
        add hl,de ;next line on screen
        bit 5,h
        ret nz ;jr nz,drawscreenline_frombufq ;end of screen, current line doesn't fit
        ld (drawscreenline_frombuf_scr),hl
        ret
       
drawscreenline_frombuf
;hl=from
;bc=size (*3?)
        exx
        call nextscreenline
        exx
        ret nz ;end of screen, current line doesn't fit

         call setpgdiv4000
        ;call setpgs_scr ;177t
        call setpgscrc000
        
        push ix
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
        
         call setpgcode4000
        ;ld hl,(drawscreenline_frombuf_scr)
        ;ld bc,40
        ;add hl,bc ;next line on screen
        ;bit 5,h
        ;jr nz,$+5
        ;ld (drawscreenline_frombuf_scr),hl

        pop iy
        pop ix
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
        res 3,l
        ld a,(de);(hl) ;R
        DOROUNDDOWN
        ld b,a
        set 4,l
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

        xor a
        ld h,a
        ld l,a
        ld (putchar_a),a
        ld (putchar_hl),hl
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
        ld a,(putchar_a)
        ld hl,(putchar_hl)
curpicwidx3=$+1
        ld bc,0
        add hl,bc
        adc a,0
        ld (putchar_hl),hl
        ld (putchar_a),a
        ret

getline
;de=куда достаём строку
;bc=сколько байт достаём
gifdisposalmethod=$+1
        ld a,0 ;bit0 = transparent color present, bit4..2 = disposal method (0=not specified(?), 1=do not dispose(?), 2=overwrite with bg color, 3=overwrite with prev frame(?))
        and 0x1c
        cp 8
        jr z,getline_fill
        ld hl,(nframes)
        ld a,h
        or l
        jr nz,getline_frommem
getline_fill
;фон первой строки - заливка
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
        ;ld h,d
        ;ld l,e
        ;cpi
        ;ret po ;bc=0
        ;ex de,hl
        ;ld (hl),a;0
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


downloadfilename
	db "download.fil",0

tfileprotocol
        db "file://",0
thttpprotocol
        db "http://",0

linkbuf
        ds 256
        
curfulllink
        ds 256

        include "htmlview.asm"
        include "html.asm"
        include "prvirt.asm"
	include "mempgs.asm"
        include "dynmem.asm"
        include "file.asm"
        include "http.asm"
        include "gif.asm"
        
oldtimer
        dw 0
        
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
        incbin "winto866"
        
endcode=$
        
        ds 0x4000-$-256 ;for stack
        display "free for code=",$-endcode

        ds 0x4000-$ ;stack
	include "prmc.asm"
        include "jpeg.asm"

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
        ld (tpgs+0),a ;mul
        OS_NEWPAGE
        ld a,e
        ld (tpgs+1),a ;y
        OS_NEWPAGE
        ld a,e
        ld (tpgs+2),a ;cb?
        OS_NEWPAGE
        ld a,e
        ld (tpgs+5),a ;cr?

        OS_NEWPAGE
        ld a,e
        ld (temppg8000),a ;depack data, diskbuf

        OS_NEWPAGE
        ld a,e
        ld (histpg),a
        
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
         ld hl,defaultfilename
        ld de,linkbuf
        call strcopy

;recode url in linkbuf to full path:
        ld hl,linkbuf
        ld de,curfulllink
        push de
        call strcopy
        pop hl ;curfulllink
        call isprotocolpresent
        jr z,browser_recodefull_protocolpresent
;protocol absent
;1:/file... => file://1:/file...
;ser.ver... => http://ser.ver...
        ld a,(linkbuf+1)
        cp ':'
        ld a,1
        jr nz,$+3
        xor a
        call adddefaultprotocol
browser_recodefull_protocolpresent
;curfulllink OK
;hl=after "//"
;a=protocol
        call addslashafterserver ;add / after http://ser.ver

        ret

defaultfilename
        ;db "0:/hippiman.bmp",0
        db "http://zxevo.ru/nos/",0

zxpal
        incbin "zxpal"

        ds 0x8000-$
        
        incbin "tdiv"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "browser.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
