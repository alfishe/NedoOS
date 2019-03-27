fire_or_rmb_navigator
        call isitclick
	ret nz ;кнопку уже держали
        ld hl,(arrx)
        ld bc,-navigatorx
        add hl,bc
        ex de,hl
        ld bc,(curbitmapwid_edit)
        ;ld a,b
        ;or c
        ;ret z ;пустой битмэп
        call mulbcde_ahl ;hl=bitmapwid * (x-navigatorx)
        push hl ;hl=bitmapwid * (x-navigatorx)
        call calcnavigatorsize ;hl=navigatorwid, b=navigatorhgt
        ex de,hl ;de=navigatorwid
        pop hl ;hl=bitmapwid * (x-navigatorx)
        push bc ;navigatorhgt
        call divhlde ;hl=hl/de = (bitmapwid * (x-navigatorx))/navigatorwid
;вычесть workzonewid/scale/2 с учётом переполнения
        push hl
        ld hl,workzonewid8*8/2
        call scalescrcoords
        ex de,hl
        pop hl
        ;or a
        ;sbc hl,de
        ;jr nc,$+5
        ;ld hl,0
        call subhldecheck0
       ld (curbitmapxscroll),hl ;ставим в центр
        ld a,(arry)
        sub navigatory
        ld e,a
        ld d,0
        ld bc,(curbitmaphgt)
        call mulbcde_ahl ;hl=bitmaphgt * (y-navigatory)
        pop bc ;b=navigatorhgt
        ld d,0
        ld e,b
        call divhlde ;hl=hl/de = (bitmaphgt * (y-navigatory))/navigatorhgt
;вычесть workzonehgt/scale/2 с учётом переполнения
        push hl
        ld hl,workzonehgt/2
        call scalescrcoords
        ex de,hl
        pop hl
        ;or a
        ;sbc hl,de
        ;jr nc,$+5
        ;ld hl,0
        call subhldecheck0
       ld (curbitmapyscroll),hl ;ставим в центр
        jp control_scroll_checksize

calcnavigatorsize
;out: hl=wid, b=hgt
        ld hl,(curbitmapwid_edit)
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;при wid>=2048 будет переполнение!
        jr nc,$+5
        ld hl,#ffff ;wid==2048
        ld de,(curbitmaphgt)
        call divhlde ;hl=hl/de
        ld bc,navigatorwid*32/navigatorhgt
        or a
        sbc hl,bc
        jr c,shownavigator_high
;shownavigator_wide
        ld bc,(curbitmaphgt) ;<2048
        ld de,navigatorwid
        call mulbcde_ahl
        ld de,(curbitmapwid_edit)
        call divhlde ;hl=hl/de
        ld b,l ;b=hgt = (navigatorwid*bitmaphgt)/bitmapwid
        ld hl,navigatorwid ;hl=wid
        ret;jr shownavigator_high_or_wide_q
shownavigator_high
        ld bc,(curbitmapwid_edit) ;<2048
        ld de,navigatorhgt
        call mulbcde_ahl
        ld de,(curbitmaphgt)
        call divhlde ;hl=hl/de
        ;hl=wid = (navigatorhgt*bitmapwid)/bitmaphgt
        ld b,navigatorhgt ;b=hgt
;shownavigator_high_or_wide_q
        ret

shownavigator
        ld hl,(curbitmaphgt)
        ld a,h
        or l
        ret z ;пустой битмэп
;картинка высокая или широкая?
;если bitmapwid/bitmaphgt >= navigatorwid/navigatorhgt, то картинка широкая, иначе высокая
        call setpgshapes

        call calcnavigatorsize ;hl=wid, b=hgt
        
        ld c,navigatory ;c=y
        ld de,navigatorx ;de=x
        ld a,l
        ld (shownavigator_wid),a
        ld a,b
        ld (shownavigator_hgt),a
        push bc
        push de
        push hl
        ld lx,backcolor ;lx=color
        call shapes_prpixelbox
        pop hl
        pop de
        pop bc
        ld lx,0 ;lx=color
        call shapes_prpixelframe

;shapes_prpixelframe(navigatorx+xleft, navigatory+ytop, xright-xleft, ybottom-ytop)

;расчёт k=navigatorwid*256/bitmapwid:
        ;ld hl,navigatorwid*256
        ld hl,(shownavigator_wid-1) ;h=wid
        ld l,0
        ld de,(curbitmapwid_edit)
        call divhlde ;hl=k
        ex de,hl ;de=k
;xleft=k*bitmapxscroll
        ld bc,(curbitmapxscroll)
        call mulbcde_ahl
        ld b,a
        ld c,h
;bc=xleft
;при xleft==0, но bitmapxscroll!=0, сделать xleft++
        ld a,b
        or c
        jr nz,shownavigator_nocorrectxleft
        ld hl,(curbitmapxscroll)
        ld a,h
        or l
        jr z,shownavigator_nocorrectxleft ;bitmapxscroll==0
        inc bc ;xleft++ ;TODO test
shownavigator_nocorrectxleft
        ld hl,navigatorx
        add hl,bc
        ld (shownavigator_xleft),hl
;xright=min[k*(bitmapxscroll+workzonewid/scale),navigatorwid]
        push de ;k
        ld hl,workzonewid8*8
        call scalescrcoords
        ld bc,(curbitmapxscroll)
        add hl,bc
        ld b,h
        ld c,l
        pop de ;k
        call mulbcde_ahl
        ld l,h
        ld h,a
shownavigator_wid=$+1
        ld bc,navigatorwid
        call minhl_bc_tobc ;bc = наименьшее из k*(bitmapxscroll+workzonewid/scale) и navigatorwid
;bc=xright
;если не существует пиксель (workzonex+workzonewid,workzoney), то xright=navigatorwid
;при xright==navigatorwid, но существует пиксель (workzonex+workzonewid,workzoney), сделать xright--
        push de ;k
        push bc
        ld a,workzoney
        ld hl,workzonex8*8+(workzonewid8*8)
        call checkfirecoords ;out: CY=вне битмэпа ;bc=x в bitmap, de=y в bitmap
        pop bc
        ld hl,(shownavigator_wid)
        jr nc,shownavigator_nogluexright
        ld b,h
        ld c,l
        jr shownavigator_nocorrectxright
shownavigator_nogluexright
        or a
        sbc hl,bc
        jr nz,shownavigator_nocorrectxright ;xright!=navigatorwid
        dec bc ;xleft-- ;TODO test
shownavigator_nocorrectxright
        pop de ;k
        ld hl,navigatorx
        add hl,bc
        ld (shownavigator_xright),hl

;y аналогично

;yleft=k*bitmapyscroll
        ld bc,(curbitmapyscroll)
        call mulbcde_ahl
;h=ytop
;при ytop==0, но bitmapyscroll!=0, сделать ytop++
        ld a,h
        or a
        jr nz,shownavigator_nocorrectytop
        ld bc,(curbitmapyscroll)
        ld a,b
        or c
        jr z,shownavigator_nocorrectytop ;bitmaptscroll==0
        inc h ;ytop++ ;TODO test
shownavigator_nocorrectytop
        ld a,h
        add a,navigatory
        ld (shownavigator_ytop),a
;yright=k*(min[bitmapyscroll+workzonehgt/scale,bitmaphgt])
        push de
        ld hl,workzonehgt
        call scalescrcoords
        ld bc,(curbitmapyscroll)
        add hl,bc
        ld bc,(curbitmaphgt)
        call minhl_bc_tobc ;bc = наименьшее из bitmapyscroll+workzonehgt/scale и bitmaphgt
        pop de
        call mulbcde_ahl
;h=ybottom
;если не существует пиксель (workzonex,workzoney+workzonehgt), то ybottom=navigatorhgt
;при ybottom==navigatorhgt, но существует пиксель (workzonex,workzoney+workzonehgt), сделать ybottom--
        push de ;k
        push hl
        ld a,workzoney+workzonehgt
        ld hl,workzonex8*8
        call checkfirecoords ;out: CY=вне битмэпа ;bc=x в bitmap, de=y в bitmap
        pop hl
shownavigator_hgt=$+1
        ld a,0
        jr nc,shownavigator_noglueybottom
        ld h,a;navigatorhgt
        jr shownavigator_nocorrectybottom
shownavigator_noglueybottom
        cp h
        jr nz,shownavigator_nocorrectybottom ;ybottom!=navigatorhgt
        dec h ;ybottom-- ;TODO test
shownavigator_nocorrectybottom
        pop de ;k
        ld a,h
        add a,navigatory
        ld (shownavigator_ybottom),a

shownavigator_xleft=$+1
        ld de,0
shownavigator_xright=$+1
        ld hl,0
        or a
        sbc hl,de ;xright-xleft
shownavigator_ytop=$+1
        ld c,0 ;c=y
shownavigator_ybottom=$+1
        ld a,0
        sub c ;ybottom-ytop
        ld b,a ;b=hgt
        
        ;ld c,navigatory ;c=y
        ;ld de,navigatorx8*8 ;de=x
        ;ld b,navigatorhgt-1 ;b=hgt
        ;ld hl,navigatorwid-1 ;hl=wid
        ld lx,%11100100 ;lx=color
        jp shapes_prpixelframe

showbitmapcoords
;hl=x
;a=y
        call checkfirezone ;out: a=код зоны
        cp ZONE_WORK
        ret nz ;вне рабочей зоны
;bc=x в bitmap, de=y в bitmap
        call setpgshapes
        ld lx,%00111111 ;фоновый цвет

        push de ;y
        ;push bc ;x

        ld hl,coordsy*40 + (coordsx/8) + scrbase
        ld de,tnavigator_x
        ;pop bc ;x
        call shapes_prtext_num
        pop bc ;y
        jp shapes_prtext_num

showwindowcoords
;bc=x
;de=y
        call setpgshapes
        ld lx,%00111111 ;фоновый цвет

        push de ;y
        ;push bc ;x

        ld hl,coordswindowy*40 + (coordsx/8) + scrbase
        ld de,tnavigator_wx
        ;pop bc
        call shapes_prtext_num
        pop bc ;y
        call shapes_prtext_num
        ld bc,(curwindowwid)
        call shapes_prtext_num
        ld bc,(curwindowhgt)
        jp shapes_prtext_num

tnavigator_x
        db "x ",0
tnavigator_y
        db "y ",0
tnavigator_wx
        db "wx ",0
tnavigator_wy
        db "wy ",0
tnavigator_wid
        db "wid ",0
tnavigator_hgt
        db "hgt ",0
