control
        ld hl,(arrx)
        ld (oldarrx),hl
        ld a,(arry)
        ld (oldarry),a
mousebuttons=$+1
        ld a,0
        ld (oldmousebuttons),a

        GET_KEY ;OS_GETKEYNOLANG
        ld a,nofocuskey
        ld (key),a
         jr nz,control_nofocus
        ld a,c ;keynolang
        ld (key),a
control_imer_oldmousecoords=$+1
        ld bc,0
        ld (control_imer_oldmousecoords),de
        ld a,b
        sub d
        ld d,a
        ld a,e
        sub c
        ld e,a
control_nofocus
        ld (control_imer_mousecoordsdelta),de
        ld a,l ;hl=(sysmousebuttons)
        push af ;ld (control_imer_buttons),a

        OS_GETKEYMATRIX ;out: bcdehlix = полуряды cs...space
        ;ld a,b ;
        ;ld (cur_cs_halfrow),a
        
        ;ld a,0xef
        ;in a,(0xfe)
         ld a,h;l
        rrca
        rla
        rla
        rrca
        rla
        rla
        or 0x86;%10000110

        ;ld a,0xfd
        ;in a,(0xfe)
         bit 0,c;d ;A
        ld c,a
        jr nz,$+4
        res 4,c ;down

;c=%1lrdu11L
        ;ld a,0xdf
        ;in a,(0xfe)
         ld a,l;hx
        rra ;P
        jr c,$+4
        res 5,c ;right
        rra ;O
        jr c,$+4
        res 6,c ;left

        ;ld a,0xfb
        ;in a,(0xfe)
         ld a,d;e
        rra ;Q
        jr c,$+4
        res 3,c ;up
        
        ;ld a,0x7f
        ;in a,(0xfe)
         ld a,lx;b
        rra ;Space
        jr c,control_nospace
        res 0,c ;Space = LMB
        rra ;SS
        jr c,$+4
        res 2,c ;SS+Space = MMB
        rla ;SS
control_nospace
        rra ;SS
        rra ;M
        jr c,$+4
        res 1,c ;M = RMB
        
;control_imer_buttons=$+1
	;ld a,0
        pop af ;mouse buttons
        or 0xf8;%11111000
        and c
;a=%1lrduMRL
        ld (mousebuttons),a

control_curspeed=$+1
        ld de,0
control_curspeedtime=$+1
        ld c,0
        
        call isfirechanged
        ;and 7;%00000111 ;кнопки огня
        ld a,(mousebuttons)
        cpl
        rra
        rra
        rra
        jr nz,control_slower ;клик или анклик тормозит стрелку
        and 0x0f;%00001111 ;кнопки движения
        jr nz,control_noslower ;движемся, не тормозим
        ld d,a ;0
        ld e,a ;0
        ld c,a ;0 ;speedtime
control_slower
        push af
        ld a,128
        cp d
        jr nc,$+3
        inc d
        sra d ;dy
        cp e
        jr nc,$+3
        inc e
        sra e ;dx
        pop af
control_noslower
        rra
        jr nc,$+3
        dec d ;dy
        rra
        jr nc,$+3
        inc d ;dy
        rra
        jr nc,$+3
        inc e ;dx
        rra
        jr nc,$+3
        dec e ;dx
        
        ld (control_curspeed),de
        ld a,d
        call div4signedup
        ld d,a
        ld a,e
        call div4signedup
        ld e,a

        or d
        jr z,$+3 ;скорость равна нулю, сбрасываем speedtime
         ld a,c ;speedtime
        inc a
        jr nz,$+3
        dec a
        ld (control_curspeedtime),a
;1=скорость равна нулю
;2=только что нажали клавишу движения
        dec a
        jr z,control_keymoveq
        cp 3 ;игнорируем третий фрейм удержания клавиши для точного позиционирования одиночным нажатием клавиши
        jr nz,control_keymoveok
control_keymoveq
control_imer_mousecoordsdelta=$+1
        ld de,0
;e=dx
;d=dy        
control_keymoveok
         ld a,d ;dy
         or a
arry=$+1
        ld l,100
        jp p,control_yadd
        add a,l
        jr c,control_yaddq
        xor a ;min
        jr control_yaddq
control_yadd
        add a,256-scrhgt
        add a,l
        jr nc,$+3
        sbc a,a ;max
        sub 256-scrhgt
control_yaddq        
        ld (arry),a
;e=dx
        
        ld a,e
        rla
        sbc a,a
        ld d,a ;de=dx
arrx=$+1
        ld hl,160
        add hl,de
        ld de,scrwidpix
        xor a
        sbc hl,de
        add hl,de
        jr c,control_xaddq
        ;bit 7,h
        ld h,a
        ld l,a
        ;jr nz,control_xaddq
        jp m,control_xaddq
        ld hl,scrwidpix-1
control_xaddq
        ld (arrx),hl

        call isfirechanged
        ret nz
        ld a,(arry)
oldarry=$+1
        cp 0
        ret nz
oldarrx=$+1
        ld de,0
        ;or a
        sbc hl,de
        ret nz
        ld a,(key)
        cp NOKEY
        ret
;nz=что-то изменилось

isfirechanged
        ld a,(mousebuttons)
oldmousebuttons=$+1
        xor 0
        ret
;a=старые кнопки XOR новые
;nz=что-то изменилось

;keymatrix
        ;ds 8
;cur_cs_halfrow
;        db 0

;oldtimer
;        dw 0

        if 1==0
waitsomething
mainloop_nothing
;в это время стрелка видна
        YIELD ;halt
        call control
        jr z,mainloop_nothing
        ret
        endif