window_start
        ld (curwindow),iy
        ld (curwindowcolors),ix
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
        ld l,(iy)
        ld h,(iy+1)
        push hl
        ld a,(iy+8) ;hidden
        or a
        jr nz,drawwindow_elements0_skip
curwindow_xy=$+1
        ld de,0
        ld l,(iy+2) ;x/2
        ld h,(iy+3) ;y
        add hl,de
        ld c,(iy+4) ;wid/2
        ld b,(iy+5) ;hgt
        ld a,(iy+6) ;type
        ld d,(iy+7) ;checked
        ld e,h
        cp T_BUTTON
        jr nz,drawwindow_elements0_nbutton
        call shapes_drawbutton
        jr drawwindow_elements0_skip
drawwindow_elements0_nbutton
        cp T_RADIO
        jr nz,drawwindow_elements0_nradio
        call shapes_drawbutton_pressed
        jr drawwindow_elements0_skip
drawwindow_elements0_nradio
        
drawwindow_elements0_skip
        pop iy
        ld a,hy
        or ly
        jr nz,drawwindow_elements0
        ret
        
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
        call window_invarrzone ;инвертируем пункт под стрелкой ;только T_MENUITEM
        
        call setpgshapes

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
        
curwindowcolors=$+2
        ld ix,0
        call window_invarrzone ;восстанавливаем (инвертируем) пункт под стрелкой
        call window_mousebuttons
        call window_keys

;TODO dispatch window messages
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
        ;ld a,(mousebuttons)
        ;rra
        ;ветвление click (NC)/unclick (C)
curwindow=$+2
        ld iy,0
        ld bc,WINDESCRIPTORSIZE
        add iy,bc
        ;display "window_fire_elements0=",$
window_fire_elements0
        ld l,(iy)
        ld h,(iy+1)
        push hl
        ;ld a,(iy+8) ;hidden
        ;or a
        ;jr nz,window_fire_elements0_skip
        ld de,(curwindow_xy)
        ld l,(iy+2) ;x/2
        ld h,(iy+3) ;y
        add hl,de
        ld a,(iy+4) ;wid/2
        add a,l
        ld c,a
        ld a,(iy+5) ;hgt
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
        ld c,(iy+4) ;wid/2
        ld b,(iy+5) ;hgt
        ;ld a,(iy+6) ;type
        ;ld d,(iy+7) ;checked
        ld e,h
        ;cp T_BUTTON
        ;jr nz,window_fire_elements0_nbutton
        ld a,(mousebuttons)
        rra
        jr c,window_fire_unclick ;unclick
        call shapes_drawbutton_pressed
         ld l,(iy+11)
         ld h,(iy+12)
         jp (hl)
window_fire_unclick
        call shapes_drawbutton
         ld l,(iy+13)
         ld h,(iy+14)
         jp (hl)
window_fire_elements0_skip
        pop iy
        ld a,hy
        or ly
        jr nz,window_fire_elements0
        ret

window_close
         pop af ;skip window_mainloop return addr
        ret

window_keys
        ld a,(key)
;TODO пройтись по всем элементам окна и проверить горячую клавишу
        ret

window_invarrzone
;TODO пройтись по всем элементам окна ;только T_MENUITEM
        ret
