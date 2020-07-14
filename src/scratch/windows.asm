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
        cp T_RADIO
        jr nz,drawwindow_elements0_nradio
        push hl
        call shapes_drawbutton_pressed
        pop hl
        ld de,0x0404 ;dydx
        call windowelement_drawtext
        jr drawwindow_elements0_skip
drawwindow_elements0_nradio
        
drawwindow_elements0_skip
        pop iy
        ld a,hy
        or ly
        jr nz,drawwindow_elements0
        ret

windowelement_drawtext
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
         ld a,hy
         or a
        call nz,shapes_drawbutton
window_nunclick
        
curwindow=$+2
        ld iy,0
        ld bc,WINDESCRIPTORSIZE
        add iy,bc
window_fire_elements0
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
        call shapes_drawbutton_pressed
         ld (pressed_iy),iy
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
window_fire_elements0_skip
        pop iy
        ld a,hy
        or ly
        jp nz,window_fire_elements0
        ret

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
