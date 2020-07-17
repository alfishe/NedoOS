window_start
        ld (curwindow),iy
        ld (curwindowcolors),ix
         ld hl,0
         ld (pressed_iy),hl
        ld l,(iy);1 ;x/2
        ld h,(iy+1);10 ;y
        ld c,(iy+2);159 ;wid/2
        ld b,(iy+3);100 ;hgt
        ld (curwindow_xy),hl
        ld (curwindow_wh),bc
        ld e,h
;l=x/2
;e=y
;hx=brush color byte 0bRLrrrlll
;lx=background fill color byte 0bRLrrrlll
;b=hgt
;c=wid/2
        call shapes_drawwindow
        ;jr $
        ld bc,WINDESCRIPTORSIZE
        add iy,bc
drawwindow_elements0
        ld l,(iy+WINELEMENT_NEXT)
        ld h,(iy+WINELEMENT_NEXT+1)
        push hl
        bit WINELEMENT_FLAG_HIDDEN,(iy+WINELEMENT_FLAGS) ;hidden
        jr nz,drawwindow_elements0_skip
curwindow_xy=$+1
        ld de,0
        ld l,(iy+WINELEMENT_X) ;x/2
        ld h,(iy+WINELEMENT_Y) ;y
        add hl,de
        ld c,(iy+WINELEMENT_WID) ;wid/2
        ld b,(iy+WINELEMENT_HGT) ;hgt
        ld a,(iy+WINELEMENT_TYPE) ;type
        ld e,h
        cp T_BUTTON
        jr nz,drawwindow_elements0_nbutton
        push hl
        call shapes_drawbutton
        pop hl
        ld de,0x0404 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nbutton
        cp T_FLAG
        jr nz,drawwindow_elements0_nflag
        push hl
        call window_drawflag
        pop hl
        ld de,0x0004 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nflag
        cp T_RADIO
        jr nz,drawwindow_elements0_nradio
        push hl
        call window_drawradio
        pop hl
        ld de,0x0004 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nradio
        cp T_LABEL
        jr nz,drawwindow_elements0_nlabel
        ld de,0x0000 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nlabel
        cp T_EDIT
        jr nz,drawwindow_elements0_nedit
        ld de,0x0000 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nedit
        
drawwindow_elements0_skip
        pop iy
        ld a,hy
        or ly
        jr nz,drawwindow_elements0
        ret

window_drawflag
        ld e,h
;l=x/2
;e=y
        call xytoscraddr        
        ld de,spr_flag_on
        bit WINELEMENT_FLAG_CHECKED,(iy+WINELEMENT_FLAGS)
        jr nz,$+5
        ld de,spr_flag_off
        jp prspr88ega

window_drawradio
        ld e,h
;l=x/2
;e=y
        call xytoscraddr        
        ld de,spr_radio_on
        bit WINELEMENT_FLAG_CHECKED,(iy+WINELEMENT_FLAGS)
        jr nz,$+5
        ld de,spr_radio_off
        jp prspr88ega

spr_flag_on
        db 0b00000000
        db 0b00000000
        db 0b10000000
        db 0b10000000
        db 0b01000000
        db 0b01000000
        db 0b01000000
        db 0b00000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000
        db 0b10000000
        db 0b00000000
        db 0b00000000

        db 0b01000000
        db 0b10000000
        db 0b10000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000

spr_flag_off
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b00000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b10000000
        db 0b01000000
        db 0b10000000
        db 0b00000000
        db 0b00000000

        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000
        db 0b00000000
        db 0b10000000
        db 0b01000000
        db 0b00000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000

spr_radio_off
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000
        db 0b10000000
        db 0b10000000
        db 0b01000000
        db 0b00000000

        db 0b00000000
        db 0b11000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b11000000

        db 0b00000000
        db 0b10000000
        db 0b01000000
        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b10000000
        db 0b10000000
        db 0b10000000
        db 0b00000000
        db 0b00000000

spr_radio_on
        db 0b00000000
        db 0b00000000
        db 0b01000000
        db 0b10000000
        db 0b10000000
        db 0b10000000
        db 0b01000000
        db 0b00000000

        db 0b00000000
        db 0b11000000
        db 0b00000000
        db 0b11000000
        db 0b11000000
        db 0b11000000
        db 0b00000000
        db 0b11000000

        db 0b00000000
        db 0b10000000
        db 0b01000000
        db 0b10000000
        db 0b10000000
        db 0b10000000
        db 0b01000000
        db 0b10000000

        db 0b00000000
        db 0b00000000
        db 0b00000000
        db 0b10000000
        db 0b10000000
        db 0b10000000
        db 0b00000000
        db 0b00000000

windowelement_drawtext
;iy=element
;hl=yx/2
;de=dydx/2
        add hl,de
        ld e,h
;l=x/2
;e=y
        call xytoscraddr
        push iy
        pop de
        ex de,hl
        ld bc,WINELEMENTSTRUCTSIZE
        add hl,bc ;hl=text
        ex de,hl
;hl=scr
;de=text
        jp shapes_prtext48ega
        
window_mainloop
        ld a,ZONE_NO
        ld (prarr_zone),a

        call setpgs_scr
;1. всё выводим
;2. ждём событие
;3. всё стираем
;4. обрабатываем событие
        call ahl_coords
        ld ix,(curwindowcolors)
        call window_invarrzone ;инвертируем пункт под стрелкой
        
        call setpgshapes

        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr ;рисуем стрелку
        
         ;ld a,0x07
         ;ld (0xc000),a
         ;out (0xfe),a
         ;ld e,a
         ;OS_SETBORDER
        call waitsomething ;в это время стрелка видна
;что-то изменилось - стираем стрелку и старое окно, двигаем стрелку, рисуем новое окно и стрелку
         ;ld a,0x02
         ;ld (0xc000),a
         ;out (0xfe),a
         ;ld e,a
         ;OS_SETBORDER
         ;ld a,r
         ;ld (0x8000),a

        call setpgshapes
        
        call ahl_oldcoords
        call shapes_rearr ;стираем стрелку
        
curwindowcolors=$+2
        ld ix,0
        call ahl_oldcoords
        call window_invarrzone ;восстанавливаем (инвертируем) пункт под стрелкой
        call window_mousebuttons
        call window_keys

curwindow_wh=$+1
        ld bc,0 ;на случай, кгда клик вне окна закрывает окно

        jp window_mainloop

window_mousebuttons
        call isfirechanged
;a=старые кнопки XOR новые
;nz=что-то изменилось
        ret z
        ;ld a,(mousebuttons)
        cpl
        and 7
        cp 3
        ;jr nc,win_mmb ;LMB+RMB или MMB
        rra
        jp c,window_fire
        rra
        jr c,window_rmb
        ret ;никогда

window_fire
window_rmb
        ld a,(mousebuttons)
        rra
        jr nc,window_nunclick ;ветвление click (NC)/unclick (C)
pressed_iy=$+2
        ld iy,0
        ld de,(curwindow_xy)
        ld l,(iy+WINELEMENT_X) ;x/2
        ld h,(iy+WINELEMENT_Y) ;y
        add hl,de
        ld c,(iy+WINELEMENT_WID) ;wid/2
        ld b,(iy+WINELEMENT_HGT) ;hgt
        ld e,h
        ld a,(iy+WINELEMENT_TYPE)
        cp T_BUTTON
        jr nz,window_nunclick
         ld a,hy
         or a
        call nz,shapes_drawbutton
window_nunclick
        
curwindow=$+2
        ld iy,0
        ld bc,WINDESCRIPTORSIZE
        add iy,bc
window_fire_elements0
         ld a,(iy+WINELEMENT_TYPE)
         cp T_RADIO
         jr nz,window_fire_elements_nradio
        ld a,(window_firstradio+1) ;HSB
        or a
        jr nz,window_fire_elements_radiook
        ld (window_firstradio),iy
         jr window_fire_elements_radiook
window_fire_elements_nradio
        ld hl,0
        ld (window_firstradio),hl
window_fire_elements_radiook
        ld l,(iy+WINELEMENT_NEXT)
        ld h,(iy+WINELEMENT_NEXT+1)
        push hl
        bit WINELEMENT_FLAG_DISABLED,(iy+WINELEMENT_FLAGS)
        jr nz,window_fire_elements0_skip
        ld de,(curwindow_xy)
        ld l,(iy+WINELEMENT_X) ;x/2
        ld h,(iy+WINELEMENT_Y) ;y
        add hl,de
        ld a,(iy+WINELEMENT_WID) ;wid/2
        add a,l
        ld c,a
        ld a,(iy+WINELEMENT_HGT) ;hgt
        add a,h
        ld b,a
       ex de,hl
        call ahl_coords
;de=element_yx/2
;hl=x
;a=y
;touched if:
;element_y(d) <= y(a) < element_y+hgt(b)
        cp d
        jr c,window_fire_elements0_skip
        cp b
        jr nc,window_fire_elements0_skip
;and element_x/2(e) <= x/2(L) < element_x/2+wid/2(c)
        srl h
        ld a,l
        rra
        cp e
        jr c,window_fire_elements0_skip
        cp c
        jr nc,window_fire_elements0_skip
         pop af ;skip next element
       ex de,hl
        ld c,(iy+WINELEMENT_WID) ;wid/2
        ld b,(iy+WINELEMENT_HGT) ;hgt
        ld a,(mousebuttons)
        rra
        jr c,window_fire_unclick ;unclick
        ld e,h
         ld (pressed_iy),iy
        ld a,(iy+WINELEMENT_TYPE)
        cp T_BUTTON
        jr z,window_fire_clickbutton
        cp T_EDIT
        jr z,window_fire_clickedit
        cp T_FLAG
        jr z,window_fire_clickflag
        cp T_RADIO
        jr z,window_fire_clickradio
        ;TODO
        jr window_fire_click
window_fire_elements0_skip
        pop iy
        ld a,hy
        or ly
        jp nz,window_fire_elements0
        ret
window_fire_clickradio
        push iy
window_firstradio=$+2
        ld iy,0
window_fire_clickradio0
         ld a,(iy+WINELEMENT_TYPE)
         cp T_RADIO
         jr nz,window_fire_clickradiook
        res WINELEMENT_FLAG_CHECKED,(iy+WINELEMENT_FLAGS)
        call windowelement_getxy ;hl=yx/2
        call window_drawradio
        ld l,(iy+WINELEMENT_NEXT)
        ld h,(iy+WINELEMENT_NEXT+1)
        push hl
        pop iy
        ld a,h
        or l
        jr nz,window_fire_clickradio0
window_fire_clickradiook
        pop iy
        set WINELEMENT_FLAG_CHECKED,(iy+WINELEMENT_FLAGS)
        call windowelement_getxy ;hl=yx/2
        jp window_drawradio
window_fire_clickflag
        ld a,(iy+WINELEMENT_FLAGS)
        xor 1<<WINELEMENT_FLAG_CHECKED
        ld (iy+WINELEMENT_FLAGS),a
        call windowelement_getxy ;hl=yx/2
        jp window_drawflag
window_fire_clickedit       
        call window_fire_click
        jp window_edit
window_fire_clickbutton
        call shapes_drawbutton_pressed
window_fire_click
         ld l,(iy+WINELEMENT_CLICK)
         ld h,(iy+WINELEMENT_CLICK+1)
         jp (hl)
window_fire_unclick
        ld bc,(pressed_iy)
        ld a,ly
        sub c
        ld c,a
        ld a,hy
        sbc a,b
        or c
        ret nz
         ld l,(iy+WINELEMENT_UNCLICK)
         ld h,(iy+WINELEMENT_UNCLICK+1)
         jp (hl)

window_close
         pop af ;skip window_mainloop return addr
        ret

window_keys
        ld a,(key)
;TODO пройтись по всем элементам окна и проверить горячую клавишу
        ret

window_invarrzone
;пройтись по всем элементам окна ;только те, у которых invertible
        ld (window_invarrzone_a),a
        ld (window_invarrzone_hl),hl
        ld iy,(curwindow)
        ld bc,WINDESCRIPTORSIZE
        add iy,bc
window_invarrzone0
        ld l,(iy+WINELEMENT_NEXT)
        ld h,(iy+WINELEMENT_NEXT+1)
        push hl
        bit WINELEMENT_FLAG_DISABLED,(iy+WINELEMENT_FLAGS)
        jr nz,window_invarrzone0_skip
        bit WINELEMENT_FLAG_INVERTIBLE,(iy+WINELEMENT_FLAGS)
        jr z,window_invarrzone0_skip
        call windowelement_getxy ;hl=yx/2
        ld a,(iy+WINELEMENT_WID) ;wid/2
        add a,l
        ld c,a
        ld a,(iy+WINELEMENT_HGT) ;hgt
        add a,h
        ld b,a        
       ex de,hl
        ;call ahl_coords
window_invarrzone_a=$+1
        ld a,0
window_invarrzone_hl=$+1
        ld hl,0
;de=element_yx/2
;hl=x
;a=y
;touched if:
;element_y(d) <= y(a) < element_y+hgt(b)
        cp d
        jr c,window_invarrzone0_skip
        cp b
        jr nc,window_invarrzone0_skip
;and element_x/2(e) <= x/2(L) < element_x/2+wid/2(c)
        srl h
        ld a,l
        rra
        cp e
        jr c,window_invarrzone0_skip
        cp c
        jr nc,window_invarrzone0_skip
         pop af ;skip next element
       ex de,hl
        ld e,(iy+WINELEMENT_WID) ;wid/2
        ld d,(iy+WINELEMENT_HGT) ;hgt
        srl e
        srl e ;wid/8
        ld b,h ;y
        ld c,l
        srl c
        srl c ;x/8
        jp shapes_invbox
window_invarrzone0_skip
        pop iy
        ld a,hy
        or ly
        jp nz,window_invarrzone0
        ret

windowelement_getxy
        ld de,(curwindow_xy)
        ld l,(iy+WINELEMENT_X) ;x/2
        ld h,(iy+WINELEMENT_Y) ;y
        add hl,de
        ret

strtoint
;hl=str
;out: hl=int
        ld de,0
strtoint0
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,strtointq
        inc hl
        ex de,hl
        push de
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
        add hl,hl ;*10
        ld e,a
        ld d,0
        add hl,de
        pop de
        ex de,hl
        jr strtoint0
strtointq
        ex de,hl
        ret

window_edit
        ;ld ix,(curwindowcolors)
        ;ld hl,3
;TODO hl=strlen (когда будет ввод в середину строки)
        ;ld (window_edit_strlen),hl
        push iy
        pop hl
        ld de,WINELEMENTSTRUCTSIZE
        add hl,de
        ld (window_edit_str),hl
;находим длину строки
        call strlen_wo_trailing_spaces
        ld (window_edit_curx),hl

window_edit0
        ;ld bc,filenamey*256 + filenamex8 ;y, x/8
        ;ld de,filenamehgt*256 + filenamewid8 ;d=hgt ;e=wid
        ;xor a
        ;call shapes_fillbox
window_edit_nokey
        call windowelement_getxy ;hl=yx/2
        ;ld hl,filenamey*256 + filenamex8*4 ;y, x/8
        ld de,0
;iy=element
;hl=yx/2
;de=dydx/2
        call windowelement_drawtext
        ;halt
        ;GET_KEY
        ;cp NOKEY
        ;jr z,editfilename_nokey
        push ix
        push iy
        YIELDGETKEYLOOP
        pop iy
        pop ix
window_edit_str=$+1
        ld hl,0
        cp key_enter
        ret z
window_edit_curx=$+1
        ld bc,0
        add hl,bc
        cp key_backspace
        jr z,window_edit_backspace
        cp 0x20
        jr c,window_edit_nokey ;прочие системные кнопки не нужны
        ld e,a
        ld a,(hl)
        or a
        jr z,window_edit0 ;максимальная длина строки, нельзя вводить
        ld (hl),e
        inc bc
        ld (window_edit_curx),bc
        jr window_edit0
window_edit_backspace
        ld a,b
        or c
        jr z,window_edit0 ;удалять нечего
        dec hl
        ld (hl),' '
        dec bc
        ld (window_edit_curx),bc
        jr window_edit0

strlen_wo_trailing_spaces
;hl=str
;out: hl=length
        xor a
        push hl
        call strlen_pp
        ex (sp),hl
        ld a,' '
        call strlen_pp
        pop bc
        call minhl_bc_tobc
        ld h,b
        ld l,c
        ret
strlen_pp 
        ld bc,0 ;чтобы точно найти терминатор
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret
