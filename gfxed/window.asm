showcopywindow
;hl=x на экране
;a=y на экране
;рисуем окно копирования, если окно существует (в любом битмэпе) и включен режим windowcopymode!=0
        call iscopywindowvisible
        ret nz
        jp showwindow_calcandshow_noshowwindowcoords

iscopywindowvisible
;out: nz=invisible
        ld bc,(curwindowstate)
        dec c
        dec c
        ret nz ;окно нигде не существует
        ld bc,(windowcopymode)
        dec c
        ret nz ;выключен режим windowcopymode
        call checkfirezone
        cp ZONE_WORK
        ret ;nz=invisible

showwindow
;hl=x на экране
;a=y на экране
;рисуем окно, если оно выделено в текущем битмэпе
        ld bc,(curwindowstate)
        dec c
        jr z,showwindow_onecorner
        inc c
        ret z ;окна нет
        ld bc,(curwindowx)
        ld de,(curwindowy)
showwindow_calcandshow
         ld a,(curwindowbmp)
         ld hl,curbmp
         cp (hl)
         ret nz ;окно выделено не в текущем битмэпе
        push bc
        push de
        call showwindowcoords
        pop de
        pop bc
showwindow_calcandshow_noshowwindowcoords
        call calccoords_frombitmapcoords_noclip ;hl=x, de=y
        ld b,h
        ld c,l ;bc=x, de=y без учёта workzone
        push de ;y
        ld hl,(curwindowwid)
        ld de,(curwindowhgt)
        call scalebitmapcoords ;hl=wid, de=hgt (могут оказаться 0)
        dec hl
        bit 7,h
        jr z,$+3
        inc hl
        dec de
        bit 7,d
        jr z,$+3
        inc de
        push de
        pop ix ;hgt
        pop de ;y
        call setpgshapes
        jp shapes_invpixelframe
        
showwindow_onecorner
;hl=x на экране
;a=y на экране
        call checkfirezone
        cp ZONE_WORK
        ret nz
;out: bc=x cur, de=y cur в bitmap (с клипированием по workzone)          
        call window_definecorner2
;bc=x в bitmap
;de=y в bitmap
        jr showwindow_calcandshow

fire_or_rmb_window
;bc=x в bitmap, de=y в bitmap
        call isitclick
	ret nz ;кнопку уже держали
         ld a,(curbmp)
         ld (curwindowbmp),a ;отныне выделяем окно в текущем битмэпе
        ld hl,(curwindowstate)
        dec l 
        jr z,fire_or_rmb_window_onecorner ;задан один угол - задаём второй
        inc l
        ld a,1 ;задан угол
        jr z,fire_or_rmb_window_setcorner ;окна нет - задаём угол
;окно есть - отменяем окно
clearwindowcoords
        ld bc,coordswindowy*256 + (coordswindowx/8) ;b=y ;c=x/8
        ld de,coordswindowhgt*256 + (coordswindowwid/8) ;d=hgt ;e=wid8
        ld a,%00111111 ;a=%33210210
        call shapes_fillbox
clearwindowstate
        xor a
        jr setwindowstate
fire_or_rmb_window_onecorner
;угол уже задан, но не всё окно
        call window_definecorner2
window_settwocorners
;bc=x в bitmap
;de=y в bitmap
        ld a,1
        ld (windowcopymode),a
        inc a ;ld a,2 ;окно задано
fire_or_rmb_window_setcorner
        ld (curwindowx),bc ;переставляем xcorner
        ld (curwindowy),de ;переставляем ycorner
setwindowstate
        ld (curwindowstate),a
        ret

window_allpicture
        ld a,#fb
        in a,(#fe)
        rra ;Q
        ret nc ;было паразитное нажатие W при движении стрелки через OPQA
        ld a,(curwindowstate)
        or a
        jr nz,clearwindowcoords ;окно есть - отменяем окно
        ld hl,(curbitmapwid_edit)
        ld (curwindowwid),hl
        ld hl,(curbitmaphgt)
        ld (curwindowhgt),hl
        ld b,a
        ld c,a ;0
        ld d,a
        ld e,a ;0
        jr window_settwocorners
        
window_definecorner2        
        ld hl,(curwindowx)
        or a
        sbc hl,bc ;|hl|+1 = ширина окна
        jr nc,$+2+4 ;был xcorner >= x; переставляем xcorner
        ld bc,(curwindowx) ;xcorner < x
        call m,neghl
        inc hl
        ld (curwindowwid),hl
        ld hl,(curwindowy)
        or a
        sbc hl,de ;|hl|+1 = высота окна
        jr nc,$+2+4 ;был ycorner >= y; переставляем ycorner
        ld de,(curwindowy) ;xcorner < x
        call m,neghl
        inc hl
        ld (curwindowhgt),hl
        ret

window_mirrhor
        ld a,(curwindowstate)
        cp 2
        ret nz
        ld hl,(curwindowy)
        ld bc,(curwindowhgt)
window_mirrhor0        
        push bc
        push hl ;y1
        ex de,hl
        call window_x_setpg32k ;y1 ;hl=addr
        ex de,hl ;de=addr[x1]
        ld hl,(curwindowwid)
        ld b,h
        ld c,l
        add hl,de ;hl=addr[x2]+1
        srl b
        rr c ;bc=wid/2
window_mirrhor00
        dec hl
        ld a,(de)
        ldi
        dec hl
        ld (hl),a
        jp pe,window_mirrhor00
        pop hl ;y1
        pop bc
        cpi
        jp pe,window_mirrhor0
        jp showbitmap
        
window_mirrver
        ld a,(curwindowstate)
        cp 2
        ret nz
        ld a,(curpgtemp)
        SETPG16K
        ld de,(curwindowy)
        ld hl,(curwindowhgt)
        add hl,de
        dec hl
window_mirrver0
;de=y1
;hl=y2
;CY=0
        ld a,tempc000/256
        call window_mirrver_ldir ;from y1
        ex de,hl
        ;ld a,tempe000/256
        call window_mirrver_ldir ;from y2
        scf
        ;ld a,tempc000/256
        call window_mirrver_ldir ;to y2
        ex de,hl
        scf
        ;ld a,tempe000/256
        call window_mirrver_ldir ;to y1
        inc de ;y1
        dec hl ;y2
        ;or a
        sbc hl,de
        add hl,de
        jr nc,window_mirrver0
        jp showbitmap

window_mirrver_ldir
        push de
        push hl
        push af
        call window_x_setpg32k
        pop af
        jr nc,window_mirrver_ldir_de
        ex de,hl
        ld h,a
        ld l,0
        jr window_mirrver_ldir_go
window_mirrver_ldir_de
        ld d,a
        ld e,0
window_mirrver_ldir_go
        ld bc,(curwindowwid)
        ldir
        pop hl
        pop de
        xor +(tempe000-tempc000)/256
        ret ;CY=0

window_copy
        call ahl_coords
        call iscopywindowvisible
        ret nz
        ld a,(curbmp)
        ld (window_curbmp),a
;out: bc=x cur, de=y cur в bitmap (с клипированием по workzone)
        ld (window_copy_xto),bc
        ex de,hl ;hl=y куда
;сравнение координат и копирование снизу вверх, если надо
        ld a,(curpgtemp)
        SETPG16K
        ld bc,(curwindowhgt)
        ld de,(curwindowy)
        ;hl=y куда
        or a
        sbc hl,de
        add hl,de
        jr nc,window_copyup ;y куда >= y откуда, копируем снизу вверх
;копируем сверху вниз
window_copyline0
        call window_copylinepp
        inc hl
        inc de
        jr nz,window_copyline0
        jp showbitmap
        
window_copyup
;bc=curwindowhgt
;de=curwindowy
;hl=y куда
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
;копируем снизу вверх
window_copylineup0
        dec hl
        dec de
        call window_copylinepp
        jr nz,window_copylineup0
        jp showbitmap

window_copylinepp
        push bc
        push de ;y откуда
        push hl ;y куда
         push hl ;y куда
        push de ;y откуда
        ld a,(curwindowbmp)
        call selectbmp
        pop de ;y откуда
        call window_x_setpg32k ;hl=addr откуда
        ld de,tempc000
        ld bc,(curwindowwid)
        ldir
window_curbmp=$+1
        ld a,0;(curbmp)
        call selectbmp
         pop hl ;y куда
        ld bc,(curbitmaphgt)
        or a
        sbc hl,bc
        add hl,bc
        jr nc,window_copylineppq ;y куда за границей 
         ex de,hl ;de=y куда
window_copy_xto=$+1
        ld bc,0
        call calcbitmap_setpg32k ;hl=addr куда
        ex de,hl ;de=addr куда
        ld hl,(curbitmapwid_edit)
        ld bc,(window_copy_xto)
        or a
        sbc hl,bc ;сколько пикселей доступно справа
        ld bc,(curwindowwid) ;сколько надо пикселей
        jr z,window_copylineppq
        call minhl_bc_tobc ;клипирование по x
        ld hl,tempc000
        ld a,(key)
        cp 'a'
        jr nc,window_copylinepp_ldir ;no Caps Shift
;with Caps Shift - transparent copy
window_copylinepp0
        ld a,(curcolor2)
        cp (hl)
        jr nz,$+4
        ld a,(de)
        ld (hl),a
        ldi
        jp pe,window_copylinepp0
        jr window_copylineppq
window_copylinepp_ldir
        ldir
window_copylineppq
        pop hl ;y куда
        pop de ;y откуда
        pop bc
        dec bc
        ld a,b
        or c
        ret

curwindowbmp
        db 0 ;0..3
windowcopymode
        db 0

curwindowstate
        db 0
curwindowx
        dw 0
curwindowy
        dw 0
curwindowwid
        dw 0
curwindowhgt
        dw 0
