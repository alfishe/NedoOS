;работа внутри битмэпа
;и свойства битмэпа

fillbitmap
;bc=x
;de=y
;a=color1
;a'=color2
        ld (setpixel_color),a ;setcolor
        ex af,af'
        ld (setpixel_color2),a
        call getpixel
        ld (curcheckcolor),a ;checkcolor
        ld hl,setpixel_color
        cp (hl)
        jr nz,fillbitmap_noerrorcolor ;цвет заливки != цвет пикселя
         ld a,(setpixel_color2)
         cp (hl)
        ret z ;нельзя кликать на цвет и заливать тем же СПЛОШНЫМ цветом - зациклится
fillbitmap_noerrorcolor
;использует максимум 1K стека
;кладёт в стек только начало пустой последовательности сверху или снизу
        push bc
        push de
        ld lx,2
fillarea0
        dec lx
        ret z ;jp z,setpgs_scr
        pop de
        pop bc
        ld (fillareastartx),bc
        ld (fillareastarty),de
        ld iy,0xffff ;hy: верх был занят (будет новая последовательность), ly: низ был занят (будет новая последовательность)
fillarea00
        call setpixel_fast
;проверяем снизу
        inc de
        ld a,lx ;stack size
        or a
        jr z,fillareanodown_blocked
        ld hl,(curbitmaphgt)
        or a
        sbc hl,de
        jr z,fillareanodown_blocked
        call getpixel
        jr nz,fillareanodown_blocked
        xor a
        cp ly
        jr z,fillareanodown ;старая последовательность
        ld ly,a
         push bc
         push de
         inc lx
        jr fillareanodown
fillareanodown_blocked
        ld ly,0xff
fillareanodown
        dec de
;проверяем сверху
        ld a,d
        or e
         dec de ;y
        jr z,fillareanoup_blocked
        ld a,lx ;stack size
        or a
        jr z,fillareanoup_blocked
        call getpixel
        jr nz,fillareanoup_blocked
        xor a
        cp hy
        jr z,fillareanoup ;старая последовательность
        ld hy,a
         push bc
         push de
         inc lx ;stack size
        jr fillareanoup
fillareanoup_blocked
        ld hy,0xff
fillareanoup
         inc de ;y
;движемся влево (если возможно), иначе вправо
        ld a,b
        or c
        dec bc ;x
        jr z,fillareanoleft_blocked;filrarea0
        call getpixel
        jr z,fillarea00 ;ставит пиксель
fillareanoleft_blocked
        call showbitmap_rarely
fillareastartx=$+1
        ld bc,0
fillareastarty=$+1
        ld de,0
        jr filrarea00
;движемся вправо
filrarea0
        dec lx ;stack size
        ret z ;jp z,setpgs_scr
        pop de
        pop bc
        ld iy,0xffff ;hy: верх был занят (будет новая последовательность), ly: низ был занят (будет новая последовательность)
filrarea00
        call setpixel_fast
;проверяем снизу
        inc de
        ld a,lx ;stack size
        or a
        jr z,filrareanodown_blocked
        ld hl,(curbitmaphgt)
        or a
        sbc hl,de
        jr z,filrareanodown_blocked
        call getpixel
        jr nz,filrareanodown_blocked
        xor a
        cp ly
        jr z,filrareanodown ;старая последовательность
        ld ly,a
         push bc
         push de
         inc lx ;stack size
        jr filrareanodown
filrareanodown_blocked
        ld ly,0xff
filrareanodown
        dec de
;проверяем сверху
        ld a,d
        or e
         dec de ;y
        jr z,filrareanoup_blocked
        ld a,lx ;stack size
        or a
        jr z,filrareanoup_blocked
        call getpixel
        jr nz,filrareanoup_blocked
        xor a
        cp hy
        jr z,filrareanoup ;старая последовательность
        ld hy,a
         push bc
         push de
         inc lx ;stack size
        jr filrareanoup
filrareanoup_blocked
        ld hy,0xff
filrareanoup
         inc de ;y
;движемся вправо
        inc bc ;x
        ld hl,(curbitmapwid_edit)
        or a
        sbc hl,bc
        jp z,fillarea0
        call getpixel
        jr z,filrarea00 ;ставит пиксель
        call showbitmap_rarely
        jp fillarea0 ;берёт из стека

showbitmap_rarely
        ld a,r
        add a,a
        ret nz
        push ix
        push iy
        call showbitmap
        pop iy
        pop ix
        ret
        
prlinebitmap
;bc=x
;de=y ;TODO рисовать без учёта этого пикселя (но 1 пиксель рисовать всегда)
;ix=x2
;hl=y2
;a=color1
;a'=color2
        ld (setpixel_color),a
        ex af,af'
        ld (setpixel_color2),a
        or a
        sbc hl,de
        add hl,de
        jp p,prlinebitmap_noswap
        ex de,hl ;y <-> y2
        push ix
        push bc
        pop ix
        pop bc ;x <-> x2
        ;ld a,lx
        ;ld lx,c
        ;ld c,a
        ;ld a,hx
        ;ld hx,b
        ;ld b,a ;x <-> x2
prlinebitmap_noswap
        or a
        sbc hl,de ;dy >= 0
        push hl ;dy
        ;ld a,lx
        ;sub c
        ;ld l,a
        ;ld a,hx
        ;sbc a,b
        ;ld h,a
        push ix
        pop hl
        sbc hl,bc
        push hl ;dx
        exx
        pop bc ;dx
        ld a,0x03 ;inc bc
        jp p,prlinebitmap_nodec
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;dx >= 0
        ld a,0x0b ;dec bc
prlinebitmap_nodec
        pop de ;dy
;a=код inc/dec bc
;bc'=x
;de'=y
;bc=dx
;de=dy
        ex de,hl
        or a
        sbc hl,bc
        add hl,bc
        ex de,hl
        jr nc,prlinebitmap_ver ;dy>=dx
        ld hy,b
        ld ly,c ;counter=dx
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,b
        ld l,c
        sra h
        rr l ;ym=dx div 2
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mym=256-(dx div 2)
        exx
        ld (prlinebitmap_incx),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
prlinebitmap_hor0
        call setpixel_line
prlinebitmap_incx=$
        inc bc ;x+1        
        exx
        ;add hl,de ;mym+dy
        or a
        sbc hl,de ;ym-dy
        exx
        jr nc,prlinebitmap_hor1
        inc de ;y+1
        exx
        ;or a
        ;sbc hl,bc ;mym-dx
        add hl,bc ;ym+dx
        exx
prlinebitmap_hor1
        dec iy
        ld a,hy
        rla
        jp nc,prlinebitmap_hor0
        ret
prlinebitmap_ver
        ld hy,d
        ld ly,e ;counter=dy
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,d
        ld l,e
        sra h
        rr l ;xm=dy div 2
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mxm=256-(dy div 2)
        exx
        ld (prlinebitmap_incx2),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
prlinebitmap_ver0
        call setpixel_line
        inc de ;y+1
        exx
        ;add hl,bc ;mxm+dx
        or a
        sbc hl,bc ;xm-dx
        exx
        jr nc,prlinebitmap_ver1
prlinebitmap_incx2=$
        inc bc ;x+1
        exx
        ;or a
        ;sbc hl,de ;mxm-dy
        add hl,de ;xm+dy
        exx
prlinebitmap_ver1
        dec iy
        ld a,hy
        rla
        jp nc,prlinebitmap_ver0
        ret
        
bitmap_fillbox
;bc=x в bitmap
;de=y в bitmap
;hl=wid
;ix=hgt
;a=color1
;[a'=color2]
        ;ld (setpixel_color),a ;setcolor
        ;ex af,af'
        ;ld (setpixel_color2),a
        ld (bitmap_fillbox_color),a
bitmap_fillbox0
        push bc
        push hl
         push hl ;wid
         call calcbitmap_setpg32k ;hl=addr
         pop bc ;wid
bitmap_fillbox00
        ;push hl
        ;call setpixel_fast
        ;pop hl
        ;inc bc ;x
        ;dec hl
        ;ld a,h
        ;or l
        ;jr nz,bitmap_fillbox00
bitmap_fillbox_color=$+1
         ld (hl),0
         cpi
        jp pe,bitmap_fillbox00
        pop hl
        pop bc
        inc de ;y
        dec ix
        ld a,hx
        or lx
        jr nz,bitmap_fillbox0
        ret
        
setpixel_fast_coloraa
        ld (setpixel_color),a
        ex af,af'
        ld (setpixel_color2),a
setpixel_line
;bc=x в bitmap (не портится) - может быть вне bitmap
;de=y в bitmap (не портится) - может быть вне bitmap
        ld hl,(curbitmapwid_edit)
        scf
        sbc hl,bc
        ret c
        ld hl,(curbitmaphgt)
        scf
        sbc hl,de
        ret c
setpixel_fast
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
        push bc
        ld a,c
        xor e
        rra
        jr c,setpixel_fast_color2
        call calcbitmap_from_xy ;a=pg, hl=addr
        SETPGBITMAPLOW
setpixel_color=$+1
        ld (hl),0
        pop bc
        ret
setpixel_fast_color2
        call calcbitmap_from_xy ;a=pg, hl=addr
        SETPGBITMAPLOW
setpixel_color2=$+1
        ld (hl),0
        pop bc
        ret

getpixel
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
;out: a=цвет, Z=цвет совпадает с curcheckcolor
        push bc
        call calcbitmap_from_xy ;a=pg, hl=addr
        SETPGBITMAPLOW
        ld a,(hl)
        pop bc
curcheckcolor=$+1
        cp 0
        ret
        
calcbitmap_from_xy
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
;out: a=pg, hl=addr
        call muldewid_ahl
        add hl,bc ;x
        adc a,0
        rl h
        rla
        rl h
        rla
        srl h
        if (scrbase != 0x0000)
        scf
        rr h
        else
        srl h ;ahl = %pppppppp 00aaaaaa aaaaaaaa
        endif
        ret
        
calcbitmapcoords
;hl=x на экране
;a=y на экране
;out: bc=x в bitmap, de=y в bitmap (могут быть отрицательные)
        sub workzoney
        ld e,a
        sbc a,a
        ld d,a ;de=y в workzone
        ld bc,-workzonex8*8
        add hl,bc ;hl=x в workzone
        call scalescrcoords ;hl=x,de=y
        ld bc,(curbitmapxscroll)
        add hl,bc ;hl=y в bitmap
        ld b,h
        ld c,l
        ld hl,(curbitmapyscroll)
        add hl,de ;hl=y в bitmap
        ex de,hl
        ret
        
calccoords_frombitmapcoords
;bc=x в bitmap
;de=y в bitmap
;out: hl=x, a=y (с клипированием по workzone)
        call calccoords_frombitmapcoords_noclip
;TODO убрать из этого модуля
;hl=x, de=y без учёта workzone
        bit 7,h
        jr z,$+5
        ld hl,0
        ld bc,+(8*workzonewid8)
        or a
        sbc hl,bc
        add hl,bc
        jr c,$+5
        ld hl,+(8*workzonewid8)-1
        ld bc,+(8*workzonex8)
        add hl,bc
        ex de,hl
        bit 7,h
        jr z,$+5
        ld hl,0
        ld bc,workzonehgt
        or a
        sbc hl,bc
        add hl,bc
        jr c,$+5
        ld hl,workzonehgt-1
        ex de,hl
        ld a,e
        add a,workzoney
        ret
        
calccoords_frombitmapcoords_noclip
;bc=x в bitmap
;de=y в bitmap
;out: hl=x, de=y (относительно workzone, могут быть отрицательные)
        ld hl,(curbitmapyscroll)
        ex de,hl
        or a
        sbc hl,de
        ex de,hl
        ld hl,(curbitmapxscroll)
        ld a,c
        sub l
        ld l,a
        ld a,b
        sbc a,h
        ld h,a
scalebitmapcoords
;hl=x, de=y (могут быть отрицательные!)
        ld a,(curbitmapscale)
        dec a
        jr nz,calccoords_frombitmapcoords_no25
        call shrhl_de
        inc a
calccoords_frombitmapcoords_no25
        dec a
        jr z,shrhl_de ;50%
        sub 2
        ret c ;100%
        call nz,shlhl_de ;400%
shlhl_de
        add hl,hl
        ex de,hl
        add hl,hl
        ex de,hl
        ret

scalescrcoords
;hl=x,de=y
        ld a,(curbitmapscale)
        dec a
        jr nz,calcbitmapcoords_no25
        call shlhl_de
        inc a
calcbitmapcoords_no25
        dec a
        jr z,shlhl_de ;50%
        sub 2
        ret c ;100%
        call nz,shrhl_de ;400%
shrhl_de
        sra h ;могут быть отрицательные!
        rr l
        sra d ;могут быть отрицательные!
        rr e
        ret

window_x_setpg32k
        ld bc,(curwindowx)
calcbitmap_setpg32k
        call calcbitmap_from_xy ;a=pg, hl=addr
setpg32k
        ;push af
        ;SETPGBITMAPLOW
        ;pop af
        ;inc a
        ;SETPGBITMAPHIGH
        push hl
        ld l,a
        ld h,tbitmappages/256
        ld a,(hl)
        SETPG32KLOW
        inc l
        ld a,(hl)
        SETPG32KHIGH
        pop hl
        ret

calcbitmapsize_pages
        ld bc,(curbitmapwid_view)
        dec bc
        ld de,(curbitmaphgt)
        dec de
        call calcbitmap_from_xy ;a=last page
        inc a ;number of pages
        ret
        
newbitmap
;bc=wid
;de=hgt
;a=color
        push af ;color
        ld (curbitmapwid_edit),bc
        ;dec bc
        ;ld a,c
        ;or 8-1 ;для 4bit
        ;ld c,a
        ;inc bc ;округлили вверх (чтобы строка .bmp была кратна 4 байтам)
        ;ld (curbitmapwid_view),bc
        ld (curbitmaphgt),de
        call reserve_bmp_pages
        ;xor a
        ;ex af,af'
        xor a
        ld b,a
        ld c,a ;bc=x в bitmap
        ld d,a
        ld e,a ;de=y в bitmap
        ld hl,(curbitmapwid_edit) ;hl=wid
        ld ix,(curbitmaphgt) ;ix=hgt
        pop af ;color
        jp bitmap_fillbox
        
reserve_bmp_pages
        call genmuldewid_ahl ;после смены curbitmapwid
        call calcbitmapsize_pages ;a=number of pages, z=no pages
        ld hl,tbitmappages
        ld b,a
reserve_bmp_pages0
        push bc
        push hl
reserve_bmp_pages_fail        
        OS_NEWPAGE
        or a
        jr nz,reserve_bmp_pages_fail ;repeat until success
        pop hl
        pop bc
        ld (hl),e
        inc hl
        djnz reserve_bmp_pages0
        ret

delbitmap
        ld hl,(curbitmaphgt)
        ld a,h
        or l
        ret z ;пустой битмэп
        call calcbitmapsize_pages ;a=number of pages, z=no pages
        ld hl,tbitmappages
        ld b,a
unreserve_bmp_pages0
        push bc
        push hl
        ld e,(hl)
        OS_DELPAGE
        pop hl
        pop bc
        inc hl
        djnz unreserve_bmp_pages0
        ret

selectbmp
;a=выбираемый битмэп
        push af
curbmp=$+1
        ld a,0
        call findcurbitmap ;hl=адрес структуры текущего bmp
        ex de,hl
        ld hl,curbitmapstruct
        ld bc,curbitmapstruct_sz
        ldir
        ld hl,tbitmappages
        ld bc,bmpmaxpages
        ldir
        pop af
        ld (curbmp),a
        call findcurbitmap ;hl=адрес структуры выбранного bmp
        ld de,curbitmapstruct
        ld bc,curbitmapstruct_sz
        ldir
        ld de,tbitmappages
        ld bc,bmpmaxpages
        ldir
        jp genmuldewid_ahl ;после смены curbitmapwid

curbitmapstruct
curbitmapwid_view
        ;dw 0 ;кратно 32 или как удобно bmp'шке при загрузке ;теперь объединено (даже при загрузке bmp не инициализируется)
curbitmapwid_edit
        dw 0
curbitmaphgt
        dw 0
curbitmapxscroll
        dw 0
curbitmapyscroll
        dw 0
curpicname
        db "kartinka.bmp",0
curbitmapscale
        db 3
workpal
        STANDARDPAL
workpalend=$-1
curbitmapstruct_sz=$-curbitmapstruct
bitmapstruct_sz=$-curbitmapstruct+bmpmaxpages

bitmaps
        dup maxbitmaps
        ds curbitmapstruct_sz-32-1 ;нули в описателях bmp
        db 3 ;scale
        STANDARDPAL
        ds bmpmaxpages,0x7f ;имеющая смысл страничка
        edup
