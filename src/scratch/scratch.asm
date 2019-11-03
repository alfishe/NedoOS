        DEVICE ZXSPECTRUM128
        ;device pentagon1024

        include "../_sdk/sys_h.asm"

MAXCMDSZ=COMMANDLINE_sz-1 ;не считая терминатора

scrwid=320
scrwid8=scrwid/8
scrhgt=200

scrbase=0x8000
scrbase16k=0x4000

tempc000=0x4000 ;круглое!
tempe000=0x6000

editpal_c0=0x80
editpal_e0=editpal_c0+0x20
tabclippal=0xc000

titlehgt=8

workzonex8=4
workzoney=8
workzonewid8=scrwid/8-workzonex8-4
workzonehgt=scrhgt-workzoney

rightpanelx8=workzonex8+workzonewid8

colorx8=0
colory=scrhgt-16
colorhgt=16

palettey=workzoney
palettex8=rightpanelx8

navigatorx=rightpanelx8*8
navigatory=palettey+(8*4)
navigatorhgt=31 ;лучше не увеличивать, чтобы не было переполнения при умножении на bitmapwid (max 2048)
navigatorwid=31

coordsx=navigatorx
coordsy=navigatory+navigatorhgt+1
coordswindowx=coordsx
coordswindowy=coordsy+16
coordswindowwid=32
coordswindowhgt=32

ZONE_NO=0
ZONE_TOP=1
ZONE_LEFT=2
ZONE_RIGHT=3
ZONE_WORK=4
ZONE_PAL=5
ZONE_NAVIGATOR=6

TOOL_WINDOW=0
TOOL_PENCIL=1
TOOL_BRUSH=2
TOOL_LINE=3
TOOL_FILL=4
TOOL_TEXT=5
NTOOLS=6

backcolor=0x3f;%00111111

bmpmaxpages=251
maxbitmaps=4
        
        macro SHAPESPROC name
;_=$
        ;org _curorg
name
        ;call setpgshapes
        ;jp _
;_curorg=$
        ;org _
        endm

        macro SETPGBITMAPLOW
        ld ($+4),a
        ld a,(tbitmappages)
        SETPG32KLOW
        endm
        
        ;macro SETPGBITMAPHIGH
        ;ld ($+4),a
        ;ld a,(tbitmappages)
        ;SETPG32KHIGH
        ;endm

        org PROGSTART
gfxeditor_begin
main_go
        jp main_go2
        ds 256
main_go2
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ld e,0 ;EGA
        OS_SETGFX
        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
        ld a,d
        ld (setpgs_scr_high),a
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (curpgshapes),a
        ld a,h
        ld (curpgpal),a
        ld a,l
        ld (curpgtemp),a

        call setpgs_scr
        call setpgshapes
        xor a
        call shapes_cls
        
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = "scratch <file to load>"
        push hl
        call findlastslash. ;de=after last slash or beginning of path
        pop hl
        push de
        dec de
        ld a,(de)
        cp '/'
        jr nz,$+4
        xor a
        ld (de),a ;отрезать имя файла
        inc de
        ex de,hl;ld de,wordbuf ;ASCIIZ string for parsing (в 0xc000...)
        ;push de
        jr nz,autoload_nopath
        OS_CHDIR
autoload_nopath
        ;pop hl
        ;call findlastslash.
        pop de ;de=after last slash
        
        ld hl,fcb_filename ;Pointer to 11 byte buffer
        OS_PARSEFNAME
        ld de,fcb
        OS_FOPEN
        or a
        jr nz,noautoload;error
        call readbmp ;nz=ошибка (тогда не менять имя файла)
        jr nz,autoloaderror
        
        ld hl,fcb_filename ;Pointer to 11 byte buffer
        ld de,curpicname
        call cpmname_to_dotname

autoloaderror
        ld de,fcb
        OS_FCLOSE
        jr autoloadq
noautoload
        ld bc,320 ;wid
        ld de,200 ;hgt
        xor a ;color
        call newbitmap
autoloadq
        
        ld de,pathbuf_forBDOS ;de=pointer to 64 byte (MAXPATH_sz!) buf
        OS_GETPATH
        ld a,(de)
        sub '0'
        ld (curdrive),a
        
        ;call initcontrol

        call showworkscreen
        
mainloop
;1. всё выводим
;2. ждём событие
;3. всё стираем
;4. обрабатываем событие
        call ahl_coords
        call invarrzone ;инвертируем пункт под стрелкой
        call ahl_coords
        call showline ;рисуем новую линию
        call ahl_coords
        call showwindow ;рисуем новое окно
        call ahl_coords
        call showcopywindow ;рисуем новое окно копирования
        call ahl_coords
        call checkfirezone
        ld (prarr_zone),a
        
        call setpgshapes

        call ahl_coords
        call showbitmapcoords
        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr ;рисуем стрелку
        
        call waitsomething ;в это время стрелка видна
;что-то изменилось - стираем стрелку и старое окно, двигаем стрелку, рисуем новое окно и стрелку

        call setpgshapes
        
        call ahl_oldcoords
        call shapes_rearr ;стираем стрелку
        call ahl_oldcoords
        call showcopywindow ;стираем старое окно копирования
        call ahl_oldcoords
        call showwindow ;стираем старое окно
        call ahl_oldcoords
        call showline ;стираем старую линию
        call ahl_oldcoords
        call invarrzone ;восстанавливаем (инвертируем) пункт под стрелкой
        
        call control_mousebuttons
        call control_keys

        jp mainloop
	
ahl_coords
        ld a,(arry)
        ld hl,(arrx)
        ret
ahl_oldcoords
        ld a,(oldarry)
        ld hl,(oldarrx)
        ret

showline
;hl=x на экране
;a=y на экране
curlinestate=$+1
        ld c,0
        dec c
        ret nz
        call checkfirezone
        cp ZONE_WORK
        ret nz
;out: bc=x cur, de=y cur в битмэпе (с клипированием по workzone)          
        ;push bc
        ;push de
        ld (curlinex2),bc
        ld (curliney2),de
        
curlinex=$+1
        ld bc,-1 ;по умолчанию линия через shift недоступна
curliney=$+1
        ld de,0
;bc=x в bitmap
;de=y в bitmap
        call calccoords_frombitmapcoords_noclip ;hl=x, de=y

        push hl ;x
        push de ;y
        
curlinex2=$+1
        ld bc,0
curliney2=$+1
        ld de,0
        call calccoords_frombitmapcoords_noclip ;hl=x2, de=y2
        ex de,hl ;hl=y2
        push de
        pop ix ;iy=x2

        pop de ;y
        pop bc ;x
        
        call setpgshapes
;bc=x (в плоскости экрана, но может быть отрицательным)
;de=y (в плоскости экрана, но может быть отрицательным)
;ix=x2
;hl=y2
        jp shapes_line
        
invarrzone
;инвертировать пункт под стрелкой
;hl=x на экране
;a=y на экране
        push af ;y
        call checkfirezone
        pop bc ;b=y
        cp ZONE_LEFT
        ret nz
        ld a,b;(arry)
        call calccurtool
        ret nc ;нет такой тулзы
        add a,a
        add a,a
        add a,a
        add a,a
        add a,workzoney
        ld b,a ;y
        ld c,0 ;x/8
        ld de,0x1004 ;d=hgt ;e=wid
        call setpgshapes
        jp shapes_invbox
        
control_mousebuttons
        ld a,(mousebuttons)
        cpl
        and 7
        cp 3
        jr nc,mmb ;LMB+RMB или MMB
        rra
        jp c,fire
        rra
        jr c,rmb
        ret ;никогда

isitclick
	ld a,(oldmousebuttons)
	cpl
	and 7
        ret ;nz=кнопку уже держали

mmb
        call ahl_coords
        call checkfirezone ;out: a=код зоны
        cp ZONE_WORK
        jr z,mmb_work
        cp ZONE_PAL
        ret nz ;не палитра
        call ahl_coords
        sub palettey
        cp 4*8
        ret nc ;не палитра
        rra
        and 0x0c
        ld c,a
        ld a,l
        srl h
        rra
        srl h
        rra
        srl h
        rra
        sub palettex8
        ret c ;не палитра
        ;a=x8-palettex8
        add a,c
        add a,a
        ld l,a
        ld h,0
        ld bc,workpal
        add hl,bc ;hl=указатель на текущий цвет в палитре
        ld (mmb_setpal_coloraddr),hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        call editpal
mmb_setpal_coloraddr=$+1
        ld (0),hl
        jp showworkscreen        
mmb_work
;рисование сеткой
;bc=x в bitmap, de=y в bitmap
        ld a,(curcolor1)
        ld (curcolorA),a
        ld a,(curcolor2)
        ld (curcolorB),a
        ld a,(curtool1)
        ld (curtool),a
        xor a
        ld (curmousebutton),a
        jr fire_or_rmb_action_

rmb
        ld a,(curcolor2)
        ld (curcolorA),a
        ld (curcolorB),a
        ld a,(curtool2)
        ld (curtool),a
        ld a,1
        ld (curmousebutton),a
        
fire_or_rmb_action_
        call ahl_coords
        call checkfirezone ;out: a=код зоны
        cp ZONE_LEFT
        jp z,setcurtool
        cp ZONE_PAL
        jp z,setcurcolor
        cp ZONE_NAVIGATOR
        jp z,fire_or_rmb_navigator
        cp ZONE_TOP
        jp z,filemenu
        cp ZONE_WORK
        ret nz
        xor a
        ld (windowcopymode),a ;меняем картинку - выключаем режим копирования
;bc=x в bitmap, de=y в bitmap
        ld a,(curtool)
        cp TOOL_PENCIL
        jp z,fire_or_rmb_pencil
        cp TOOL_LINE
        jp z,fire_or_rmb_line
        cp TOOL_FILL
        jp z,fire_or_rmb_fill
        cp TOOL_WINDOW
        jp z,fire_or_rmb_window
        cp TOOL_BRUSH
        jp z,fire_or_rmb_brush
        ret

fire_or_rmb_fill
        ld a,(curcolorA)
        ex af,af'
        ld a,(curcolorB)
        call fillbitmap
        call setpgs_scr
        jp showbitmap
        
fire
        ld a,(curcolor1)
        ld (curcolorA),a
        ld (curcolorB),a
        ld a,(curtool1)
        ld (curtool),a
        xor a
        ld (curmousebutton),a
        jr fire_or_rmb_action_

fire_or_rmb_line
;bc=x в bitmap, de=y в bitmap
        call isitclick
	ret nz ;кнопку уже держали
        ld hl,(curlinestate)
        dec l
        jr z,fire_or_rmb_line_finish
        ld a,1
        ld (curlinestate),a
        ld (curlinex),bc
        ld (curliney),de
        ret
fire_or_rmb_line_finish
        ld hl,(curliney)
        ld ix,(curlinex)
        ld a,(curcolorA)
        ex af,af'
        ld a,(curcolorB)
        call prlinebitmap
        xor a
        ld (curlinestate),a
        jp showbitmap

fire_or_rmb_brush
;bc=x в bitmap, de=y в bitmap
        ld (minx),bc
        ld (maxx),bc
        ld (miny),de
        ld (maxy),de
        
        ;call ahl_oldcoords
        ;call checkfirezone ;out: a=код зоны
        ;cp ZONE_WORK
        ;jr nz,firebrushpixel ;старое положение было вне рабочей зоны - линию нельзя (TODO клипировать линию)

        call ahl_oldcoords
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
        push bc ;x2
        push de ;y2
        call ahl_coords
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
        ld (curlinex),bc
        ld (curliney),de
        pop hl ;y2
        or a
        sbc hl,de
        ld (brushlinedy),hl
        pop hl ;x2
        or a
        sbc hl,bc
        ld (brushlinedx),hl
       
;firebrushpixel
        ;call ahl_coords
        ;call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
;bc=x в bitmap, de=y в bitmap
        call firepixelpp
        dec bc
        call firepixelpp
        dec de
        call firepixelpp
        inc bc
        call firepixelpp
        inc bc
        call firepixelpp
        inc de
        call firepixelpp
        inc de
        call firepixelpp
        dec bc
        call firepixelpp
        dec bc
        call firepixelpp
        
        jp fire_scrupdate
        
firepixelpp
        call checkminmaxxy
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
        ;jr $
        push bc
        push de
brushlinedx=$+2
        ld ix,0
        add ix,bc
brushlinedy=$+1
        ld hl,0
        add hl,de
        
        push bc
        push de
        push ix
        pop bc
        ex de,hl
        call checkminmaxxy ;портит hl
        ex de,hl
        pop de
        pop bc

        ld a,(curcolorA)
        ex af,af'
        ld a,(curcolorB)
        ;call setpixel_fast_coloraa
        call prlinebitmap

        pop de
        pop bc
        ret

fire_or_rmb_pencil        
;bc=x в bitmap, de=y в bitmap (всегда положительные, т.к. мы в workzone - TODO при удержании режима рисования учесть отрицательные)
        ld (minx),bc
        ld (maxx),bc
        ld (miny),de
        ld (maxy),de
        
        ;call ahl_oldcoords
        ;call checkfirezone ;out: a=код зоны
        ;cp ZONE_WORK
        ;jr nz,firepixel ;старое положение было вне рабочей зоны - линию нельзя
fireline
        ;ld a,0xfe
        ;in a,(0xfe)
         ld a,(cur_cs_halfrow)
        rra ;Caps Shift
        jr c,fireline_noshift
        ld bc,(curlinex)
        ld a,b
        inc a
        ret z ;0xffxx - нет предыдущей точки
        ld de,(curliney)
        jr fireline_noshiftq
fireline_noshift
        call ahl_oldcoords
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
fireline_noshiftq
        call checkminmaxxy
        push bc ;x2
        push de ;y2
        call ahl_coords
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
        ld (curlinex),bc
        ld (curliney),de
        call checkminmaxxy
        pop hl ;y2
        pop ix ;x2
        ld a,(curcolorA)
        ex af,af'
        ld a,(curcolorB)
        call prlinebitmap
        
        if 1==0
        
        jr fire_scrupdate
        
firepixel
        call ahl_coords
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
        call checkminmaxxy
;bc=x в bitmap (не портится)
;de=y в bitmap (не портится)
        ld a,(curcolorA)
        ex af,af'
        ld a,(curcolorB)
        call setpixel_fast_coloraa
        
        endif
        
fire_scrupdate
;обновить часть экрана
;bc=minx
;de=miny
;hl=maxx, maxy
        call setpgs_scr
minx=$+1
        ld bc,0
miny=$+1
        ld de,0
        call calccoords_frombitmapcoords ;hl=x,a=y(min)
        dup 3
        srl h
        rr l
        edup
        push af
        push hl ;x/8(min)
maxx=$+1
        ld bc,0
maxy=$+1
        ld de,0
;отсекаем координаты сверху, чтобы не делать это каждый раз в checkminmaxxy
        ld hl,(curbitmapwid_edit)
        dec hl
        call minhl_bc_tobc
        ld hl,(curbitmaphgt)
        dec hl
        or a
        sbc hl,de
        add hl,de
        jr nc,$+3 ;de<=hl
        ex de,hl
        call calccoords_frombitmapcoords ;hl=x,a=y(max)
        dup 3
        srl h
        rr l
        edup
        inc hl ;hl=x/8(max) с округлением в большую сторону
        pop de ;x/8(min)
        pop bc ;y(min)
        inc a ;y(max) с округлением в большую сторону
        sub b ;y(max)-y(min)
         ;jr z,$ ;ret z
        ld hy,a ;hy=hgt
        ld a,l ;x/8(max) с округлением в большую сторону
        sub e ;x/8(min)
         ;jr z,$ ;ret z
        ld lx,a ;lx=wid(chr)
        ld l,e
        ld h,b
        push hl ;h=y на экране, l=x на экране
        ex de,hl
        add hl,hl
        add hl,hl
        add hl,hl ;hl=x(min)
        ld a,b ;a=y(min)
        call calcbitmapcoords
        ld h,b
        ld l,c ;hl=x в bitmap ;de=y в bitmap
        pop bc ;b=y на экране, c=x на экране
        jp prbitmapbox

setcurcolor
        call isitclick
	ret nz ;кнопку уже держали
        ld a,(curmousebutton)
        or a
        ld de,curcolor1
        jr z,$+5
        ld de,curcolor2
        call ahl_coords
        sub palettey
        rra
        and 0x0c
        ld bc,-palettex8*8
        add hl,bc
        srl l
        srl l
        srl l
        add a,l
        ld (de),a
        jp showcurcolor
        
checkfirecoords
;hl=x на экране, a=y на экране
;out: CY=вне битмэпа
;bc=x в bitmap, de=y в bitmap
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap
        ld hl,(curbitmapwid_edit)
        scf
        sbc hl,bc
        ret c ;x>(bitmapwid-1) => x>=bitmapwid
        ld hl,(curbitmaphgt)
        scf
        sbc hl,de
        ret ;CY: y>(bitmaphgt-1) => y>=bitmaphgt

checkminmaxxy
;bc=x, de=y (могут быть отрицательные) (не портятся)
        bit 7,b
        jr nz,checkminmaxxy_nox
        ld hl,(maxx)
        or a
        sbc hl,bc
        jr nc,$+6
        ld (maxx),bc
        ld hl,(minx)
        or a
        sbc hl,bc
        jr c,$+6
        ld (minx),bc
        jr checkminmaxxy_xq
checkminmaxxy_nox
        ld hl,0
        ld (minx),hl
checkminmaxxy_xq
        bit 7,d
        jr nz,checkminmaxxy_noy
        ld hl,(maxy)
        or a
        sbc hl,de
        jr nc,$+6
        ld (maxy),de
        ld hl,(miny)
        or a
        sbc hl,de
        ret c
        ld (miny),de
        ret
checkminmaxxy_noy
        ld hl,0
        ld (miny),hl
        ret
        
control_keys
key=$+1
        ld a,0
        cp key_left
        jp z,control_keys_left
        cp key_down
        jp z,control_keys_down
        cp key_up
        jp z,control_keys_up
        cp key_right
        jp z,control_keys_right
        cp '+'
        jp z,control_keys_plus
        cp '-'
        jp z,control_keys_minus
        cp 'c'
        jp z,control_keys_clear
        cp 'w'
        jp z,window_allpicture
        cp 'v'
        jp z,window_copy
        cp 'V'
        jp z,window_copy
        cp 'z'
        jp z,control_keys_swapcolors
        cp 'x'
        jp z,window_mirrhor
        cp 'y'
        jp z,window_mirrver
        cp key_redraw
        jp z,showworkscreen
        sub '1'
        cp 4
        jr c,control_keys_selectbmp
        
        ret
        
control_keys_swapcolors
        ld hl,(curcolor1) ;1, 2
        ld a,l
        ld l,h
        ld h,a
        ld (curcolor1),hl
        jp showworkscreen
        
control_keys_selectbmp
        call selectbmp
        call kill_unfinished_shapes
        jp showworkscreen ;control_scale_checksize

kill_unfinished_shapes
        xor a
        ld (curlinestate),a ;убиваем недоопределённую линию
        dec a
        ld (curlinex+1),a ;отменяем начальную точку линии через shift
         ld a,(curwindowstate)
         dec a
         call z,clearwindowstate ;убиваем недоопределённое окно
        ret

findcurbitmap
;a=номер
        ld c,a
        ld b,0
        ld de,bitmapstruct_sz
        call mulbcde_ahl
        ld bc,bitmaps
        add hl,bc
        ret
        
control_keys_right
        call control_getscrollvalue ;de=scrollvalue
        ld hl,(curbitmapxscroll)
        add hl,de
control_keys_setxscroll
        ld (curbitmapxscroll),hl
control_scroll_checksize
        call control_scroll_checksizepp
        call shownavigator
        call showtitle
        jp showbitmap
control_scroll_checksizepp
        ld hl,+(workzonex8+workzonewid8)*8 ;hl=x
        ld a,workzoney+workzonehgt ;a=y        
        call calcbitmapcoords ;out: bc=x в bitmap, de=y в bitmap

        ld hl,(curbitmaphgt)
        or a
        sbc hl,de
        jr nc,control_scroll_nocorrecty ;hgt>=y
;hl<0 (сколько лишних пикселей bitmap по y)
;посчитать bitmaphgt-(workzonehgt/scale) = bitmaphgt+hl
        ld de,workzonehgt
        call scalescrcoords
        ld hl,(curbitmaphgt)
        call subhldecheck0
        ld (curbitmapyscroll),hl
control_scroll_nocorrecty
        ld hl,(curbitmapwid_edit)
        or a
        sbc hl,bc
        ret nc ;wid>=x
;hl<0 (сколько лишних пикселей bitmap по x)
;посчитать bitmapwid-(workzonewid/scale) = bitmapwid+hl
        ld de,workzonewid8*8
        call scalescrcoords
        ld hl,(curbitmapwid_edit)
        call subhldecheck0
        ld (curbitmapxscroll),hl
        ret
        
control_keys_left
        call control_getscrollvalue ;de=scrollvalue
        ld hl,(curbitmapxscroll)
        ;or a
        ;sbc hl,de
        ;jr nc,$+5
        ;ld hl,0
        call subhldecheck0
        jr control_keys_setxscroll
        ;ld (curbitmapxscroll),hl
        ;jr control_scroll_checksize
        
control_keys_down
        call control_getscrollvalue ;de=scrollvalue
        ld hl,(curbitmapyscroll)
        add hl,de
control_keys_setyscroll
        ld (curbitmapyscroll),hl
        jr control_scroll_checksize

control_keys_up
        call control_getscrollvalue ;de=scrollvalue
        ld hl,(curbitmapyscroll)
        ;or a
        ;sbc hl,de
        ;jr nc,$+5
        ;ld hl,0
        call subhldecheck0
        jr control_keys_setyscroll
        ;ld (curbitmapyscroll),hl
        ;jp control_scroll_checksize

control_getscrollvalue
        ld de,64
        jp scalescrcoords
        
control_scale_checksize
        call control_scroll_checksizepp

        call setpgshapes

        ld bc,workzoney*256 + workzonex8 ;b=y ;c=x/8
        ld de,workzonehgt*256 + workzonewid8 ;d=hgt ;e=wid8
        ld a,0x3f;%00111111 ;a=%33210210
        call shapes_fillbox
        jp control_scroll_checksize;showworkscreen
control_keys_plus
        ld a,(curbitmapscale)
        inc a
        cp 5+1
        jr c,$+3
        dec a
        ld (curbitmapscale),a
        jp control_scroll_checksize ;не нужно перепечатывать пустое место
control_keys_minus
        ld a,(curbitmapscale)
        dec a
        jr nz,$+3
        inc a
        ld (curbitmapscale),a
        jp control_scale_checksize

control_keys_clear
        ld a,(curwindowstate)
        cp 2
        ret nz
        ld bc,(curwindowx) ;bc=x в bitmap
        ld de,(curwindowy) ;de=y в bitmap
        ld hl,(curwindowwid) ;hl=wid
        ld ix,(curwindowhgt) ;ix=hgt
        ld a,(curcolor2)
        ex af,af'
        ld a,(curcolor2)
;a=color1
;a'=color2
        call bitmap_fillbox
        jp showbitmap

checkfirezone
;hl=x
;a=y
;out: a=код зоны и для ZONE_WORK: bc=x в bitmap, de=y в bitmap
        ld c,a
        cp workzoney
        ld a,ZONE_TOP
        ret c ;top
        ld a,ZONE_LEFT
        ld de,workzonex8*8
        ;or a
        sbc hl,de
        add hl,de
        ret c ;left
        ld de,+(workzonex8+workzonewid8)*8
        ;or a
        sbc hl,de
        add hl,de
        ld a,c
        jr nc,checkfirezone_right ;right
        call checkfirecoords ;CY=вне битмэпа
        ld a,ZONE_NO
        ret c ;bc=x в bitmap, de=y в bitmap
        ld a,ZONE_WORK
        ret
checkfirezone_right
        cp navigatory
        ld a,ZONE_PAL
        ret c ;pal
        cp navigatory+navigatorhgt
        ld a,ZONE_NAVIGATOR
        ret c ;navigator
        ld a,ZONE_RIGHT
        ret ;right

showworkscreen
        call setpgs_scr
        call setpgshapes
        ld a,backcolor
        call shapes_cls

        call showtitle
        call showbitmap
        call showtools
        call showcurcolor
        call showpalette

        jp shownavigator 
        
showcurcolor
        call setpgshapes

        ld de,256*colorhgt+2
        push de ;y
        ld bc,256*colory+colorx8
        ld a,(curcolor1)
        call shapes_colortocolormask
        call shapes_prbox
        ;ld de,256*colorhgt+2
        pop de ;y
        ld bc,256*colory+colorx8+2
        ld a,(curcolor2)
        call shapes_colortocolormask
        jp shapes_prbox

calccurtool
;a=y
;определяет номер тулзы по координатам стрелки
;out: a=tool, NC: a>=NTOOLS
        sub 8
        rra
        rra
        rra
        rra
        and 0x0f
        cp NTOOLS
        ret

setcurtool
        call isitclick
	ret nz ;кнопку уже держали
        xor a
        ld (curlinestate),a ;отменить недоопределённую линию
curmousebutton=$+1 ;0=LMB
        or 0
        ld hl,curtool1
        jr z,$+5
        ld hl,curtool2
        ld a,(arry)
        call calccurtool
        ret nc ;>=NTOOLS
        ld (hl),a
        cp TOOL_WINDOW
        jr nz,showcurtool
        ld a,1
        ld (windowcopymode),a
        ;jp showcurtool
showcurtool
        call setpgshapes

        ld bc,256*(colory-10)+colorx8+1
        call calcscr_from_xchr_y        
        ld de,text_ntool
        ld a,(curtool1)
        add a,'0' 
        ld (de),a
        inc de
        inc de
        ld a,(curtool2)
        add a,'0' 
        ld (de),a
        dec de
        dec de
        ld lx,backcolor
        jp shapes_prtext48ega_oncolor

text_ntool
        db "0 0",0
        
showtools
        call setpgshapes

        ld de,ttools
        ld bc,256*workzoney+0
showtools0
        push bc
        push de
        ld de,0x1004
        ld a,backcolor
        call shapes_prbox
        pop de
        pop bc
        push bc
        ld a,b
        add a,4
        ld b,a
        call calcscr_from_xchr_y
        set 5,h ;на 4 пикселя правее
        call shapes_prtext48ega_black
        pop bc
        ld a,b
        add a,0x10
        ld b,a
        inc de
        ld a,(de)
        inc a
        jr nz,showtools0
        ret

showpalette
        call setpgshapes

        xor a
        ld b,workzoney ;b
        ld e,4
prpal0
        ld c,palettex8
        ld d,4
prpal1
        push af
        push de
        ld de,0x0801 ;hgt, wid(chr)
        push bc
        call shapes_colortocolormask
        call shapes_prbox
        pop bc
        pop de
        pop af
        inc c
        inc a
        dec d
        jr nz,prpal1
        push af
        ld a,b
        add a,8
        ld b,a ;y
        pop af
        dec e
        jr nz,prpal0
        ret

showtitle
        call setpgshapes

        ld bc,0 ;b=y ;c=x/8
        ld de,titlehgt*256 + scrwid8 ;d=hgt ;e=wid8
        xor a ;a=%33210210
        call shapes_fillbox
        ld hl,prchar48ega_white
        ld (prchar48ega_colorproc),hl
        ld hl,scrbase ;scr
        ld a,(curbmp)
        add a,'1'
        call shapes_prchar48ega
        ld a,':'
        call shapes_prchar48ega
        ld de,curpicname
        call shapes_prtext48ega
        ld a,' '
        call shapes_prchar48ega
        ld lx,0 ;фоновый цвет
        ex de,hl
        ld hl,(curbitmapwid_edit)
        call shapes_prnum
        ex de,hl
        ld a,'x'
        call shapes_prchar48ega
        ex de,hl
        ld hl,(curbitmaphgt)
        call shapes_prnum
        ex de,hl
        ld a,' '
        call shapes_prchar48ega
        ex de,hl
        ld a,(curbitmapscale)
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        ld bc,tscalesnames-4
        add hl,bc
        ex de,hl
        call shapes_prtext48ega
        
        ld a,'%'
        jp shapes_prchar48ega
        
        
tscalesnames
        db " 25",0
        db " 50",0
        db "100",0
        db "200",0
        db "400",0
        
showbitmap
        ld hl,workpal
        call copytemp_setpal
        call setpgs_scr
        ld hl,(curbitmapwid_edit)
        ld de,(curbitmaphgt)
        ld a,d
        or e
        ret z ;пустой битмэп
        call scalebitmapcoords ;hl=wid, de=hgt
        inc hl
        srl h
        rr l
        inc hl
        srl h
        rr l
        inc hl
        srl h
        rr l ;wid(chr)
        ld bc,workzonewid8
        or a
        sbc hl,bc
        add hl,bc
        jr nc,$+3 ;wid>=workzonewid => берём ширину рабочей зоны
        ld c,l ;wid<workzonewid => берём wid битмэпа
        ld lx,c;workzonewid8 ;lx=wid(chr)
        ex de,hl
        ld bc,workzonehgt
        or a
        sbc hl,bc
        add hl,bc
        jr nc,$+3 ;hgt>=workzonehgt => берём ширину рабочей зоны
        ld c,l ;hgt<workzonehgt => берём hgt битмэпа
        ld hy,c;workzonehgt ;hy=hgt
        
        ld hl,(curbitmapxscroll) ;hl=x в bitmap
        ld de,(curbitmapyscroll) ;de=y в bitmap
        ld bc,workzoney*256+workzonex8 ;c=x/8 на экране, b=y на экране
        jp prbitmapbox

calcscr_from_xchr_y
;b=y
;c=x/8
;out: hl=scraddr
;не портит de
         ld a,c
calcscr_from_xchr_ya
        ld l,b
        ld h,0
         ld b,scrbase/256/8
         ld c,l
        add hl,hl
        add hl,hl
        add hl,bc;de ;y*5
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
         add a,l
         ld l,a
         ret nc
         inc h
        ret

cls
        call setpgs_scr
        call setpgshapes
        xor a
        jp shapes_cls

	align 256
tmirror
_=0
	dup 256
_0=_&1
_1=_>>1&1
_2=_>>2&1
_3=_>>3&1
_4=_>>4&1
_5=_>>5&1
_6=_>>6&1
_7=_>>7&1
	db (_0<<7)+(_1<<6)+(_2<<5)+(_3<<4)+(_4<<3)+(_5<<2)+(_6<<1)+(_7)
_=_+1
	edup

ttools
        db "Window",0
        db "Pencil",0
        db "Brush",0
        db "Line",0
        db "Fill",0
        db "Text",0
        db -1
        
curtool
        db 0
curtool1
        db 1
curtool2
        db 0
curcolorA
        db 0
curcolorB
        db 0
curcolor1
        db 15
curcolor2
        db 0
    
prarr_zone
        db 0

setpgs_scr
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret

setpgshapes
        push bc
curpgshapes=$+1
        ld a,0;pgshapes
        SETPG16K
        pop bc
        ret

setpgpal
        push bc
curpgpal=$+1
        ld a,0;pgshapes
        SETPG32KLOW
        pop bc
        ret

setpgtemp
        push bc
curpgtemp=$+1
        ld a,0;pgshapes
        SETPG32KHIGH
        pop bc
        ret

        include "window.asm"
        include "navigator.asm"
        
        include "pal.asm"
        
        include "bitmap.asm"

        include "prbitmap.asm"
        
        include "control.asm"
        include "math.asm"
        
        include "files.asm"

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

;hl = poi to filename in string
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
nfopenfnslashq.
;de = after last slash or beginning of path
	ret

wordbuf
        ds MAXCMDSZ+1
        
pathbuf_forBDOS
        ds MAXPATH_sz ;сейчас используется только при инициализации (прочитать текущий драйв)

        ;display "$ before align=",/h,$
        
        .align 256
;;;;;;;;;;;;;;;;;;; таблицы для prbitmap
tpixelrecode
;%00003210 => %33210210
        dup 256
_3=$&8
_210=$&7
        db (_3*0x18) + (_210*0x09)
        edup
        
tpixelrecodeLEFT
;%00003210 => %.3...210
        dup 256
_3=$&8
_210=$&7
        db (_3*0x08) + (_210*0x01)
        edup
        
tpixelrecodeRIGHT
;%00003210 => %3.210...
        dup 256
_3=$&8
_210=$&7
        db (_3*0x10) + (_210*0x08)
        edup
        
;;;;;;;;;;;;;;;;;;; таблицы для палитры
tsin
        incbin "tsin200"
tarcsin
        incbin "tarcsin"
tsqr
;аргумент +-0..127 (соответствует -1..+1)
;результат 0..127 (соответствует -1..+1)
_=0
        dup 128
        db (_*_)/128
_=_+1
        edup
_=128
        dup 128
        db (_*_)/128
_=_-1
        edup
tsqrt
;аргумент 0..255 (соответствует 0..2)
;результат 0..127 (соответствует 0..1) и выше
        incbin "sqrtmax2"
tbitmappages
        ;display "tbitmappages=",tbitmappages
        ds bmpmaxpages,0x7f
        
activeend
        ;display "activeend=",activeend
        ds 0x4000-$
SHAPES_begin
        include "prshapes.asm"
        include "prarrow.asm"
        include "prtext.asm"
        .align 256
font48
        incbin "64qua.fnt"
SHAPES_sz=$-SHAPES_begin
	;display "Shapes size ",/d,SHAPES_sz," bytes"
        
gfxeditor_end

	display "Size ",/d,gfxeditor_end-gfxeditor_begin," bytes"
	;display "Free (incl. stack) ",/d,0x4000-activeend," bytes"

	savebin "scratch.com",gfxeditor_begin,gfxeditor_end-gfxeditor_begin
	
	;LABELSLIST "..\us\user.l"
