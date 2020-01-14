        
;взять b=R/G/Bmin, hl установить на начало буфера R/G/B:
        ;pop bc ;ld bc,(maxdistaxis) ;b=maxaxis
        ;ld l,0xff&chrbuf
        ;ld a,(Rminmax) ;Rmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+8)
        ;ld a,(Gminmax) ;Gmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+16)
        ;ld a,(Bminmax) ;Bmin
        ;ld b,a ;b=R/G/Bmin
        ;ld a,c ;c=maxdist
        ;rra
        ;rra
        ; and 0x3f
        ; add a,tmaxdistdiv/256
        ;ld d,a ;d=maxdistdiv

;потом выбираем лучшую ось:
        ;ld de,(Bminmax)
        ld a,d ;Bmax
        sub e ;Bmin
        ld c,a ;maxdist
        ld b,2 ;maxaxis
        pop de ;ld de,(Gminmax)
        ld a,d ;Gmax
        sub e ;Gmin
        cp c ;>=maxdist?
        ld hl,(Bminmaxcolor)
        jr c,$+2+1+1
         ld c,a ;maxdist
         ;dec b ;maxaxis=1
         ld hl,(Gminmaxcolor)
        pop de ;ld de,(Rminmax)
        ld a,d ;Rmax
        sub e ;Rmin
        cp c ;>=maxdist?
        jr c,$+2+4;2
         ;ld b,0 ;maxaxis
         ld hl,(Rminmaxcolor)
        ex de,hl

;потом берём положение рекордных цветов:
        ;pop de ;ld de,(Rminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Gminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Bminmaxcolor)


        if 1==0;0:03CNVTOGR        LD HL,#C000        LD BC,#7FFD        LD E,1        CALL SETPG       LD D,GRF/256 ;таблица brightness/contract/dithering level        LD A,(MAXV8)        LD B,AYSGOOP        PUSH BC        LD BC,(LSZX) ;<256?      ;LD A,C      ;DEC BC      ;INC B      ;LD C,B ;1..256 => 1, 257..512 => 2      ;LD B,AXSGOOP        LD E,(HL)        LD A,(DE)        LD (HL),A      ;INC HL      ;DJNZ XSGOOP      ;DEC C      ;JNZ XSGOOP       CPI        JP PE,XSGOOP        POP BC       ;hgt<256        DJNZ YSGOOP        RET 
        endif
        if 1==0;0:26CNVTORGB        LD HL,#C000        LD BC,#7FFD        LD DE,#7FDF        EXX         LD E,1        CALL SETPG        LD A,(MAXV8)        LD B,AYSLOOP        PUSH BC        LD BC,(LSZX)XSLOOP        PUSH BC;once+ini;/168900 CALLS;20t=1s!!!;SCONV        EXX         LD A,#1B        OUT (C),A        LD A,(HL)        LD (pCB+1),A        LD A,#1C        OUT (C),A        LD A,(HL)       EXA         LD A,#19        OUT (C),A        LD A,(HL)        LD (pY+1),A       EXA         EXX        LD L,A       LD H,'G716C        LD E,(HL)        INC H        LD D,(HL)       INC H        LD C,(HL)        INC H        LD B,(HL)pY      LD HL,PTAB       EX DE,HL        ADD HL,DE        LD A,(HL)       LD (RC+1),ApCB    LD HL,G7170       DEC H       LD A,(HL)       DEC H       LD L,(HL)       LD H,A        ADD HL,BC        ADD HL,DE        LD A,(HL)       LD (GC+1),A       LD HL,(pCB+1)        LD C,(HL)        INC H        LD B,(HL)       EX DE,HL        ADD HL,BC        LD C,(HL)       LD B,'GRF       LD A,(BC)       LD (BCL+1),A       LD A,(RC+1)       LD C,A       LD A,(BC)       LD (RC+1),A       LD A,(GC+1)       LD C,A       LD A,(BC)       LD (GC+1),A;считали все, а берем одну....pCLRS   LD A,(0)        EXX         LD (HL),A        INC HL        EXX         POP BC        DEC BC        LD A,B        OR C        JP NZ,XSLOOP        POP BC        DEC B ;hgt<256        JP NZ,YSLOOP        RET 
        endif

RC      OR 0GC      OR 0BCL     OR 0

curbold=$+1
        ld a,0
curlink=$+1
        or 0
        ld hl,tfontweight
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        ld (prcharmc_attr),a
curitalic=$+1
        ld a,0
        ld (prcharmc_italic1),a
        ld (prcharmc_italic2),a
        ld (prcharmc_italic3),a
        ld (prcharmc_italic4),a
curstroke=$+1
        ld a,0
        ld (prcharmc_stroke),a
curunderline=$+1
        ld a,0
        ld (prcharmc_underline),a

        
        

        if 1==0
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
        endif

        ;ld hl,curfulllink;linkbuf
        ;ld de,COMMANDLINE
        ;push de
        ;call strcopy ;TODO убрать (сейчас только для отладки)
        ;pop hl        
;command line = "<file to load>"

        if 1==0

         xor a
         ld (washttpword),a
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
        jr z,browser_go_changeprotocolhttp
        pop hl
        jr browser_go_nochangeprotocol
browser_go_changeprotocolhttp
         ld a,1
         ld (washttpword),a        
browser_go_changeprotocol
        ld (browserprotocol),a
        ;pop af ;skip old hl
        ex (sp),hl ;push hl
        
        endif
        

        if 1==0
;сменить текущий каталог (или http-каталог) в соответствии с каталогом в ссылке
        push hl ;hl=начало path без протокола
browser_go_findslash
	 push hl
        call findlastslash.
	 pop hl
;de=after last slash or start
	 or a
	 sbc hl,de
	 add hl,de ;hl=начало path без протокола
	 jr nz,browser_go_slashfound
	 ;no slash in end
browserprotocol=$+1
        ld a,0 ;0=file, 1=http
washttpword=$+1
        ld a,0 ;1=was "http://"
	or a
	jr z,browser_go_slashfound
	 ;http => add slash after (as in http://nedopc.com)
	 push hl
	 xor a
	 ld b,-1
	 cpir
	 dec hl ;at terminator
	 ld (hl),'/'
	 inc hl
	 ld (hl),0
	 pop hl
	 jr browser_go_findslash
browser_go_slashfound
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
         
        endif
         
        if 1==0
getpath_http
;de=buffer to get path
        ld hl,httpcurdir ;server/path (without / in the end)
        jp strcopy

rootdir_http
        xor a
        ld (httpcurdir),a ;server/path (without / in the end)
        ret
        
chdir_http_dot
        inc de ;skip dot
        inc de ;skip another dot supposed
        ld a,(de)
        or a
        jr z,$+3
        inc de ;skip / supposed
;hl=end of curdir (slash or terminator)
;remove last element of curdir = move hl to previous slash or =httpcurdir:
        ld a,'/'
        dec hl
        ld b,-1
        cpdr
        inc hl ;at slash (might be httpcurdir-1)
        ld bc,httpcurdir
        or a
        sbc hl,bc
        ;add hl,bc
        ;jr nc,$+3 ;< httpcurdir?
        ;inc hl ;if so, hl=httpcurdir
         adc hl,bc ;if (hl<httpcurdir) hl=httpcurdir
        ;jr chdir_http

chdir_http
;de=server/path (without / in the end)
        ld hl,httpcurdir
        xor a
        ld b,-1
        cpir
        dec hl
;hl=end of curdir
        ld a,(de)
        cp '.'
        jr z,chdir_http_dot
        ld (hl),'/'
        inc hl
        ex de,hl
        call strcopy ;TODO check overflow
        ret
        endif

;httphostname=server name (filename before slash, not including slash)
;top of stack=filename (after ser.ver/)
        ;jr $
        
        if 1==0
         push de ;filename
;httphostname=server name (httpcurdir before slash), curdir=httpcurdir after slash:
        ld hl,httpcurdir+1 ;server/path (without / in the end)
        ld de,httphostname
        push de
	 push hl
        call strcopy
	 pop bc
	 or a
	 sbc hl,bc
	 ld b,h
	 ld c,l
        pop hl ;httphostname
        ld a,'/'
        ;ld bc,128
        cpir ;TODO ser.ver:port
	 jr z,openstream_http_slashfound
;if no slash
	 ld hl,httphostname
	 xor a
	 cpir
	 dec hl ;at terminator
	 dec a ;NZ
openstream_http_slashfound
        ld (openstream_http_curdir),hl
	jr nz,$+2+1+2
        dec hl
        ld (hl),0 ;end of httphostname
        endif
        
        if 1==0
openstream_http_curdir=$+1
        ld hl,0 ;httpcurdir+N
;if empty path, don't add second slash
	 ld a,(hl)
	 or a
	 jr z,openstream_http_emptypath
        call strcopy
        dec de
        ld a,'/'
        ld (de),a
        inc de
openstream_http_emptypath
        endif

;         ld b,50 ;10 OK for nedopc.com
;httpconnectwait0
;        push bc
;        YIELD
;        pop bc
;        djnz httpconnectwait0
        

        
;store converted frame with timings:
;+0 (3) pnext
;+3 (2) time
;+5 converted frame

        if 1==0
;берём с экрана
        ;call setpgtemp4000
        ld hl,0xc000
        ld bc,(curpichgt_visible)
keepframelines0
        push bc
        push hl

        call setpgs_scr
        ld de,LINEPIXELS;KEEPFRAMELINE
        
;pixels
        push hl
        push de
        xor a
        call copylinefromscr
        inc de
        set 5,h
        ld a,1
        call copylinefromscr
        pop de
        ld hl,(keepframe_linesize)
        add hl,de
        ex de,hl
        pop hl
;attr
        res 6,h
        xor a
        call copylinefromscr
        inc de
        set 5,h
        ld a,1
        call copylinefromscr
 
        ld bc,(keepframe_linesize_bytes) ;size (pixels+attr)
        push bc
        ld de,LINEPIXELS;KEEPFRAMELINE
keepframeaddr=$+1
        ld hl,0
keepframeaddrHSB=$+1
        ld a,0
        ;ld hl,(keepframeaddr)
        ;ld a,(keepframeaddrHSB)
        call puttomem
        pop bc ;size
        ld hl,(keepframeaddr)
        ld a,(keepframeaddrHSB)
        add hl,bc
        adc a,0
        ld (keepframeaddr),hl
        ld (keepframeaddrHSB),a
        
        pop hl
        ld bc,40
        add hl,bc
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,keepframelines0
        call setpgtemp8000
        endif

        ld de,KEEPFRAMELINE
;pixels
        push hl
        push de
        xor a
        call copylinetoscr
        inc de
        set 5,h
        ld a,1
        call copylinetoscr
        pop de
        ld hl,(keepframe_linesize)
        add hl,de
        ex de,hl
        pop hl
;attr
        res 6,h
        xor a
        call copylinetoscr
        inc de
        set 5,h
        ld a,1
        call copylinetoscr

        if 1==0
copylinetoscr
;hl=line (kept)
;de=buf
;a=нечётность (0=чётные, 1=нечётные столбцы)
        push de
        push hl
        ex de,hl
        call copyline_countsize
        call copyline_countsize_ldirtoscr
        ex de,hl
        pop hl
        pop de
        ret

copylinefromscr
;hl=line (kept)
;de=buf
;a=нечётность (0=чётные, 1=нечётные столбцы)
        push de
        push hl
        call copyline_countsize
        call copyline_countsize_ldir
        pop hl
        pop de
        ret

copyline_countsize
keepframe_linesize=$+1
        ld bc,0
        or a
        jr nz,$+3 ;нечётных столбцов меньше
        inc bc
        srl b
        rr c
        ret
copyline_countsize_ldir
        ld a,b
        or c
        ret z;jr z,$+4 ;for width=1
copyline_countsize_ldir0
        ldi
        inc de
        jp pe,copyline_countsize_ldir0
        ret
copyline_countsize_ldirtoscr
        ld a,b
        or c
        ret z;jr z,$+4 ;for width=1
copyline_countsize_ldirtoscr0
        ldi
        inc hl
        jp pe,copyline_countsize_ldirtoscr0
        ret
        endif
        
        if 1==0
        
        push iy
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
        pop iy
        ret
        
        endif

        if 1==0
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
        endif

        if 1==0
        push bc
        push de
        push hl
        ld hl,chrbuf
        ld de,chrbuf+8
        ld bc,16
        ldir
        pop hl
        pop de
        pop bc
        endif

renderpng_pixels0
        push bc
        call readbyte
        ex de,hl
        ld (hl),c
        inc hl
        ex de,hl
        call readbyte
        ex de,hl
        ld (hl),c
        inc hl
        ex de,hl
        call readbyte
        ex de,hl
        ld (hl),c
        inc hl
        ex de,hl
        call readbyte ;alpha
        pop bc
        dec hl
        cpi
        jp pe,renderpng_pixels0

        
        ld a,(hl) ;R
        inc hl
        inc hl ;skip G
        ldi ;B
        inc de
        ld (de),a ;R
        inc de ;skip G
