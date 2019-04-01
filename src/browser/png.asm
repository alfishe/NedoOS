LINEPNG=0x8008
LINEPNGTEMP=0x9000 ;дл€ конвертации 16bit->8bit (TODO в конце LINEPNGPRIOR)
LINEPNGPRIOR=0xa008

        align 256
PNGPAL
        ds 768 ;TODO убрать в страничку

readpng
        ld b,7
        call read_b_bytes ;TODO test header
        ;jr $

readpng_chunk
        call RDWORDHSBLSBtohl
        ex de,hl
        call RDWORDHSBLSBtohl ;dehl=chunk size
        exx
        call GETDWORD_slow ;e,d,l,h
        ;jr $
        ld a,e
        cp 'I'
        jr z,readpng_chunk_IHDR_IDAT
        cp 'P'
        jr z,readpng_chunk_PLTE
        jr readpng_skiprestofchunk
        
readpng_chunk_IHDR_IDAT
        ld a,d
        cp 'D'
        jp z,readpng_chunk_IDAT
        cp 'E'
        ret z ;IEND
readpng_chunk_IHDR
        call RDWORDHSBLSBtohl
        call RDWORDHSBLSBtohl ;hl=width
        call setpicwid
        call RDWORDHSBLSBtohl
        call RDWORDHSBLSBtohl ;hl=hgt
        call setpichgt
        call RDBYTE ;bit depth (глубина цвета 1, 2, 4, 8, 16) ;TODO 16bit
         ld (readpng_bitdepth),a
        add a,7 ;8,9,11,15,23
        rra
        rra
        rra
        and 3 ;1,1,1,1,2
        ld e,a
        call RDBYTE ;color type (тип цвета: 1 (индексированный цвет - с палитрой) + 2 (цветное изображение, т.е. не Grayscale) + 4 (используетс€ альфа-канал))
         ld (readpng_palflag_bit0),a
         rra
         ld d,1
         jr c,readpng_countbppok
         rra
         jr nc,$+4
         ld d,3
         rra
         jr nc,$+3
         inc d
readpng_countbppok
         ld a,d
         dec e
         jr z,$+3
         add a,a
        ld (png_bytesperpix),a
         ;jr $
        call RDBYTE ;compression method (0 = deflate)
        call RDBYTE ;filter method (=0)
        call RDBYTE ;interlace method (0 (нет чередовани€) / 1 (Adam7 interlace)) ;TODO

        call initframe ;один раз на кадр после setpicwid, setpichgt и после установки gifframetime ;заказывает пам€ть под конверченный кадр

        call GETDWORD_slow ;e,d,l,h
        jr readpng_chunk

readpng_chunk_PLTE
        ;jr $
        exx
        ;hl=chunk size
        dec hl
        ld e,0
readpng_chunk_PLTE0
        ld d,PNGPAL/256
        call RDBYTE
        ld (de),a
        inc d
        call RDBYTE
        ld (de),a
        inc d
        call RDBYTE
        ld (de),a
        inc e
        ld bc,3
        or a
        sbc hl,bc
        jp p,readpng_chunk_PLTE0

        call GETDWORD_slow ;e,d,l,h
        jp readpng_chunk

readpng_skiprestofchunk
;after chunk name: skip chunk size + 4 bytes (CRC)
        exx
;dehl=chunk size
readpng_skiprestofchunk0
        ld c,l ;1..0
        xor a
        ld b,a;0
        dec c ;0..255
        inc bc ;1..256
        ;or a
        sbc hl,bc
        jr nc,$+3
         dec de
        ld b,c
        call read_b_bytes
        ld a,d
        or e
        or h
        or l
        jr nz,readpng_skiprestofchunk0
        call GETDWORD_slow ;e,d,l,h
        jp readpng_chunk

readpng_chunk_IDAT
;заказать пам€ть под блок данных hgt*(wid*bytesperpix+1):
; if bpp=1
; then RawLen:=IHDRData.Width div bp+1 {bp:=8 div BitDepth} {реально надо округление вверх??? TODO проверить - сделал вверх}
; else RawLen:=IHDRData.Width*bpp+1;
;теоретически сейчас в DISKBUF может быть больше, чем размер текущего IDAT (хот€ реально разрезают IDAT по 8K)        
;TODO переставить указатель файла на текущий байт и прочитать на размер текущего IDAT (если это меньше DUSKBUFsz)
;а пока без перестановки указател€ - узнаем, какую часть IDAT мы уже прочитали, и вычитаем еЄ из chunk size
;chunksize -= DISKBUF+DISKBUFsz-(iy+1) ;может быть 0
;[chunksize += iy + (1 - (DISKBUF+DISKBUFsz)) ;может быть 0]
        exx
;dehl=chunk size
        ;jr $
        push iy
        pop bc
        push hl
        ld hl,DISKBUF+DISKBUFsz-1
        or a
        sbc hl,bc
        ld b,h
        ld c,l ;iy + (1 - (DISKBUF+DISKBUFsz))
        pop hl
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        ld (pngIDATremained),hl
        ld (pngIDATremainedHSW),de
        
        ;jr $

        ld hl,(freemem_hl)
        ld a,(freemem_a)
        ld (pngdepktoaddr),hl
        ld (pngdepktoaddrHSB),a
        ld (pngdecodefromaddr),hl
        ld (pngdecodefromaddrHSB),a

        ld de,(curpicwid)
png_bytesperpix=$+1
        ld bc,0
        call MULWORD ;hlbc=de*bc

        ld a,(readpng_bitdepth)
        cp 8
        jr nc,readpng_chunk_IDATlinesizeok ;нельз€ генерить палитру, т.к. бывает YA?
        cp 4
         ld e,17
        jr z,readpng_chunk_IDATlinesizediv2
        cp 2
         ld e,85
        jr z,readpng_chunk_IDATlinesizediv4
         ld e,255
        inc bc
        srl b
        rr c
readpng_chunk_IDATlinesizediv4
        inc bc
        srl b
        rr c
readpng_chunk_IDATlinesizediv2
        inc bc
        srl b
        rr c
;сгенерировать нужную серую палитру:
         ld a,(readpng_palflag_bit0)
         rra
         jr c,readpng_chunk_IDATlinesizeok ;насто€щую палитру уже прочитали

        push hl
        xor a
        ld l,a
;4bits: step=17
;2bits: step=85
;1bit: step=255
readpng_getgreypal0
        ld h,PNGPAL/256
        ld (hl),a
        inc h
        ld (hl),a
        inc h
        ld (hl),a
        add a,e;step
        inc l
        jr nz,readpng_getgreypal0
        pop hl

         ld a,1
         ld (readpng_palflag_bit0),a
readpng_chunk_IDATlinesizeok
         ld (png_bytesperline),bc
        inc bc ;every line starts with subfilter byte
         ;bc=physical line data size
        ld de,(curpichgt)
        call MULWORD ;hlbc=de*bc = размер блока данных
        ld d,b
        ld e,c
;hlde=size
        call reserve_mem ;портит номер банка в 0xc000
         call gifsetpgLZW

;zlib/gzip header:
        call RDBYTE ;0xW8, W=max window
        call RDBYTE ;7..6=compression level, 5=DICT (TODO read 4 bytes - и что с ними делать?), 4..0=for multiple of 31
;
        
        call INFLATING

;render:
        ld hl,LINEPNGPRIOR
        ld de,LINEPNGPRIOR+1
        ld bc,(png_bytesperline)
        dec bc
        ld (hl),BACKGROUNDCOLORLEVEL
        ldir
        ld hl,0
        ld (LINEPNG-2),hl
        ld (LINEPNG-4),hl ;чтобы не провер€ть k>=bpp
        ld (LINEPNG-6),hl
        ld (LINEPNG-8),hl ;чтобы не провер€ть k>=bpp
        ld (LINEPNGPRIOR-2),hl
        ld (LINEPNGPRIOR-4),hl ;чтобы не провер€ть k>=bpp
        ld (LINEPNGPRIOR-6),hl
        ld (LINEPNGPRIOR-8),hl ;чтобы не провер€ть k>=bpp

pngdecodefromaddr=$+1
        ld hl,0
pngdecodefromaddrHSB=$+1
        ld a,0

        ld bc,(curpichgt)
renderpng_lines0
        push bc
        call readbyte ;subfilter byte
         ld lx,c
         ;ld b,a
         ;ld a,c
         ;cp 5
         ;ld a,b
         ;jr nc,$

        ld de,LINEPNG
png_bytesperline=$+1
        ld bc,0
        push bc
        push af
        push hl
        call getfrommem
        pop hl
        pop af
        pop bc
        add hl,bc
        adc a,0
        push af
        push hl
        
        ld bc,(png_bytesperpix)
        ld de,LINEPNG
        ld hl,LINEPNGPRIOR
        push hl
        push de
        ;or a
        sbc hl,bc
        ex de,hl
        ;or a
        sbc hl,bc
        exx
        pop hl ;LINEPNG
        pop de ;LINEPNGPRIOR
        ld bc,(png_bytesperline)
        ld a,lx
        or a
        jr z,pngfilterq
        dec a
        jr z,png_sub
        dec a
        jr z,png_up
        dec a
        jr z,png_average
         ;dec a
         ;jr nz,$
png_paeth
;      if k>=bpp
;      then inc(ImageData[i],PaethPredictor(Raw[k-bpp],Prior[k],Prior[k-bpp]))
;      else inc(ImageData[i],PaethPredictor(0,Prior[k],0));
        exx
        ex de,hl
        exx
renderpng_paeth0
        ld a,(de)
        exx
        call paethpredictor ;(de),a,(hl)
        inc hl
        inc de
        exx
        add a,(hl)
        ld (hl),a
        inc de
        cpi
        jp pe,renderpng_paeth0
        jr pngfilterq
png_sub
;      if k>=bpp
;      then inc(ImageData[i],Raw[k-Bpp]);
        exx
        push hl ;raw-
        exx
        pop de
png_up
;      inc(ImageData[i],Prior[k]);
renderpng_up0
        ld a,(de) ;prior
        add a,(hl)
        ld (hl),a
        inc de
        cpi
        jp pe,renderpng_up0
        jr pngfilterq
png_average
;      if k>=bpp
;      then inc(ImageData[i],(Raw[k-bpp]+Prior[k])div 2)
;      else inc(ImageData[i],Prior[k]div 2);
renderpng_average0
        ld a,(de)
        exx
        add a,(hl)
        inc hl
        exx
        rra
        add a,(hl)
        ld (hl),a
        inc de
        cpi
        jp pe,renderpng_average0
        
pngfilterq
        
        call islinevisible
        jp nz,renderpng_lineinvisible
        
;конвертировать составл€ющие из 16bit в 8bit:
        ld hl,LINEPNG
        ld de,LINEPNGPRIOR ;result of recolor
        ld a,(readpng_bitdepth)
        cp 16
        ld a,(png_bytesperpix)
        jr nz,pngrecolor16q
        rra
        push de
        ld de,LINEPNGTEMP ;TODO в конце PRIOR
        push de
        ;jr $
        ld bc,(png_bytesperline)
        srl b
        rr c
pngrecolor160
        inc hl
        ldi
        jp pe,pngrecolor160
        pop hl
        pop de ;будем перекодировать TEMP->PRIOR
pngrecolor16q
;конвертировать из bpp в 24bit:
;hl=from
;de=to
;a=число цветовых составл€ющих(1..4)
         ;jr $
        ld bc,(curpicwid)
        dec a
        jr z,pngrecolor1
        dec a
        jp z,pngrecolor2
        dec a
        jp z,pngrecolor3
;32bpp: RGBA -> BGR
pngrecolorRGBA0
        ld a,(hl)
        inc hl
        ex af,af' ;R
        ld a,(hl) ;G
        inc hl
        ldi ;B
        ld (de),a ;G
        inc de
        ex af,af'
        ld (de),a ;R
        inc de
        ex af,af'
        inc hl ;skip A
        jp pe,pngrecolorRGBA0
        jp pngrecolorq
pngrecolor1
        ;jr $
;8bpp: Y -> BGR
readpng_palflag_bit0=$+1
        ld a,0
        rra
        jp nc,pngrecolorY0
readpng_bitdepth=$+1
        ld a,0
        cp 8
        jr z,pngrecolorPAL80
        cp 4
        jr z,pngrecolorPAL4
        cp 2
        jr z,pngrecolorPAL2
pngrecolorPAL1
;bc = (bc+7)/8 = (bc-1)/8 + 1
        dec bc
        ld a,c
        srl b
        rra
        srl b
        rra
        srl b
        rra
        ld c,a
        inc bc
pngrecolorPAL10
        push hl
        ld a,(hl)
        scf
        rla
pngrecolorPAL100
        ld l,0
        rl l
        call pngrepal
        inc bc ;ldi compensation
        add a,a
        jr nz,pngrecolorPAL100
        pop hl
        cpi
        jp pe,pngrecolorPAL10
        jp pngrecolorq
pngrecolorPAL4
;round least bit up
        inc bc
        res 0,c
pngrecolorPAL40
        push hl
        ld a,(hl)
        push af
        rra
        rra
        rra
        rra
        and 0x0f
        ld l,a
        call pngrepal
        pop af
        and 0x0f
        ld l,a
        call pngrepal
        pop hl
        inc hl
        jp pe,pngrecolorPAL40
        jr pngrecolorq       
pngrecolorPAL2        
;round 2 least bits up
        inc bc
        inc bc
        inc bc
        res 1,c
        res 0,c
pngrecolorPAL20
        push hl
        ld a,(hl)
        call pngrepal2bits
        call pngrepal2bits
        call pngrepal2bits
        call pngrepal2bits
        pop hl
        inc hl
        jp pe,pngrecolorPAL20
        jr pngrecolorq
pngrecolorPAL80
        push hl
        ld l,(hl)
        call pngrepal
        pop hl
        inc hl
        jp pe,pngrecolorPAL80
        jr pngrecolorq
pngrecolorY0
        ld a,(hl)
        ldi ;B
        ld (de),a ;G
        inc de
        ld (de),a ;R
        inc de
        jp pe,pngrecolorY0
        jr pngrecolorq
pngrecolor2
;16bpp: YA -> BGR
pngrecolorYA0
        ld a,(hl)
        ldi ;B
        ld (de),a ;G
        inc de
        ld (de),a ;R
        inc de
        inc hl ;skip A
        jp pe,pngrecolorYA0
        jr pngrecolorq
pngrecolor3
;24bpp: RGB -> BGR
pngrecolorRGB0
        ld a,(hl)
        inc hl
        ex af,af' ;R
        ld a,(hl) ;G
        inc hl
        ldi ;B
        ld (de),a ;G
        inc de
        ex af,af'
        ld (de),a ;R
        inc de
        ex af,af'        
        jp pe,pngrecolorRGB0
        jr pngrecolorq
pngrecolorq
        ld h,d
        ld l,e
        ld (hl),b;0
        inc de
        ld bc,7*3-1
        ldir ;чтобы справа в остатке знакоместа была чернота (потом можно убрать, когда readchr будет это делать)

        ld hl,LINEPNGPRIOR ;recolored line
        call drawscreenline_frombuf ;конвертируем LINEGIF в LINEPIXELS и выводим еЄ на экран
        call keepconvertedline ;запоминаем сконверченную строку из LINEPIXELS
        call nextoldconvertedframeaddr ;смещаем адрес, откуда брать сконверченную строку из предыдущего кадра (gifoldconvertedframeaddr)
renderpng_lineinvisible
        call inccury

        ld hl,LINEPNG
        ld de,LINEPNGPRIOR
        ld bc,(png_bytesperline)
        ldir ;TODO мен€ть местами указатели
        
        pop hl
        pop af
        
        pop bc
        dec hl
        cpi
        jp pe,renderpng_lines0

        ret ;остальное нас не интересует (курсор файла после unzip в случайном положении?)

;function TPNG.PaethPredictor(a,b,c:BYTE):byte;
; var
;   pa,pb,pc:integer;
; begin {PaethPredictor}
;   pc:=a+b-c;
;   pa:=abs(pc-a); pb:=abs(pc-b); pc:=abs(pc-c);
;   if(pa<=pb)and(pa<=pc)
;   then Result:=a
;   else
;    if pb>pc
;    then Result:=c
;    else Result:=b;
; end; {PaethPredictor}
paethpredictor
;?a=(de),?b=a,?c=(hl)
;out: a
        ld hx,a;?b
        sub (hl);?c
        jr nc,$+4
        neg
         ld ly,a;?pa,a ;pa=abs(b-c)
         
        ld a,(de);?a
        sub (hl);?c
        jr nc,$+4
        neg
         ld hy,a;?pb,a ;pb=abs(a-c)
         
        ld a,(de);?a
        add a,hx;?b
        rra
        jr c,paeth1
        sub (hl);?c ;a=(a+b-2c)/2
        jr nc,$+4
        neg
        add a,a
        jp paethpredok
paeth1
        sub (hl);?c ;a=(a+b-2c)/2 - 1/2 ;1 вместо 1.5, -1 вместо -0.5
        jr nc,$+3
        cpl ;-1 (означает -0.5) => 0 (означает 0.5)
        scf
        rla
paethpredok
        jr nc,$+3
        sbc a,a
         ld lx,a;?pc,a ;pc=abs(a+b-2c) ;если >255, то 255
         
        ld a,hy;?pb
        cp ly;?pa
        jr c,paethpredictor_resultnoa ;pa>pb
        ld a,lx;?pc
        cp ly;?pa
        jr nc,paethpredictor_resulta ;(pa<=pb)and(pa<=pc)
paethpredictor_resultnoa
        ld a,lx;?pc
        cp hy;?pb
        jr c,paethpredictor_resultc ;pb>pc
        ld a,hx;?b
        ret
paethpredictor_resultc
        ld a,(hl);?c
        ret
paethpredictor_resulta
        ld a,(de);?a
        ret

pngrepal2bits
        ld l,0
        rla
        rl l
        rla
        rl l
pngrepal
;l=color index
;write 3 bytes from pal to (de)
;keeps a
;decrements bc with P/V flag
        ld h,PNGPAL/256+2
        ex af,af'
        ld a,(hl) ;B
        ld (de),a
        inc de
        dec h
        ld a,(hl) ;G
        ld (de),a
        ex af,af'
        inc de
        dec h
        ldi ;R
        ret

