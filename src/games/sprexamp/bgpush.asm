pushscrtop=scrbase+0;10
pushwid=40;20
pushhgt=512;200 ;сколько строк графики разложено в ldpush (не менее scrhgt)
;pushpghgt=192 ;сколько строк графики помещается в одной странице (считается автоматически: строка, попавшая в +0x3fxx, переносится на +0x40xx, так что одна страничка = 0x3f00)

PUSHLINESZ=2+(pushwid*2)+2

bgpush_prepare
;de=filename
        call openstream_file

        ld ix,tpushpgs
        call genpush

        ld ix,tpushpgs+1
        call genpush

        ld ix,tpushpgs+2
        call genpush

        ld ix,tpushpgs+3
        call genpush

        call readbmphead_pal

        ld (bgpush_ldbmp_sp),sp
        ld sp,bgpush_loadbmplinestack+(pushhgt*2)+32
;загрузить графику bmp в ld-push
        ld ix,tpushpgs
        ld hl,pushbase
        ld bc,pushhgt
bgpush_ldbmp0
       push hl ;ix в стек не кладём, иначе будет больше килобайта стека - переполнение ниже 0x3b00
        ld de,PUSHLINESZ
        add hl,de
        ld a,h
        cp pushbase/256+63
        jr nz,bgpush_ldbmp0_nonextpg
        ld h,pushbase/256
        ld de,4
        add ix,de
bgpush_ldbmp0_nonextpg
        dec bc
        ld a,b
        or c
        jr nz,bgpush_ldbmp0
        
        ld bc,pushhgt
bgpush_ldbmp1
        ld a,h ;curln code addr
       pop hl
        cp h ;prevln code addr (<=curln)
        jr nc,bgpush_ldbmp1_noprevpg
        dec ix
        dec ix
        dec ix
        dec ix
bgpush_ldbmp1_noprevpg
        inc hl
        inc hl ;skip ld sp,hl:exx
        ld a,pushwid/2
        call bgpush_ldbmp_line
        dec bc
        ld a,b
        or c
        jr nz,bgpush_ldbmp1
bgpush_ldbmp_sp=$+1
        ld sp,0
        jp closestream_file


;делаем push для одного слоя (в одной страничке помещается pushwid*pushpghgt = 38*200 или 40*192 байт пуша)
;в страничке такой код:
;ld sp,hl ;/jp (ix)
;exx
;ld bc:push bc *N ;de=0!!!
;exx
;add hl,bc ;de=0!!!
;и в самом конце jp pushbase
;задача - правильно пропатчить выход и вызвать (hl=pushscrtop+pushwid+(N*0x2000))

;можно все строчки сгенерировать заранее, но тогда придётся на каждой четверти строчки (или один раз на строчку, если включены обе страницы экрана) вызывать переключение страниц (потому что строчка может быть в рандомной странице)
;можно все строчки сгенерировать заранее и копировать в код (но они будут разной длины!) и копирование 8 или 16 строк за фрейм долго

;чтобы сгенерировать большую картинку 320x512 для скролла:
;- в конце странички переключалку страничек и jp pushbase
;- genpush должен сам заказывать странички
;- расчёт адреса патча/входа должен учитывать страничку
;- патч выхода должен учитывать страничку
;- вход должен учитывать страничку
;- в конце зацикливалка должна включать начальную страничку

;переключалка страниц (на неё патч не должен попадать):
;exx ;нельзя портить bc
;ld a,N
;ld bc,pushbase+
;jp bgpush_setpg

        ds 8
bgpush_setpg_stack
bgpush_setpg
        ld sp,bgpush_setpg_stack
        push bc
        SETPGPUSHBASE ;в будущем кернале это может быть call!!!
        exx
        ret;jp pushbase

bgpush_jppushbase
        ld sp,bgpush_setpg_stack
        exx ;нельзя портить bc
        SETPGPUSHBASE ;в будущем кернале это может быть call!!!
        exx
        jp pushbase

genpush
        call genpush_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        SETPGPUSHBASE
         ld (genpush_firstpage),a
        ld hl,pushbase
        ld bc,pushhgt
genpush0
        push bc
        ld a,h
        cp pushbase/256+63
        call z,genpush_nextpg
        ld (hl),0xf9 ;ld sp,hl
        inc hl
        ld (hl),0xd9 ;exx
        inc hl
        ld b,pushwid/2
genpush1
        ld (hl),1 ;ld bc
        inc hl
        ld a,r
        ld (hl),a
        inc hl
        ld a,r
        ld (hl),a
        inc hl
        ld (hl),0xc5 ;push bc
        inc hl
        djnz genpush1
        ld (hl),0xd9 ;exx
        inc hl
        ld (hl),0x09 ;add hl,bc
        inc hl
        ;ld (hl),0xe9 ;jp (hl)
        ;inc hl
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,genpush0
        ld (hl),0x3e ;ld a,
        inc hl
genpush_firstpage=$+1
        ld (hl),0
        inc hl
        ld (hl),0xc3 ;jp
        inc hl
        ld (hl),bgpush_jppushbase&0xff
        inc hl
        ld (hl),bgpush_jppushbase/256
        ;inc hl
        ret
genpush_nextpg
        ld c,l
        ld b,pushbase/256
        push bc ;pushbase+
        call genpush_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        ld (hl),0xd9 ;exx
        inc hl
        ld (hl),0x3e ;ld a,
        inc hl
        ld (hl),a
        inc hl
        ld (hl),0x01 ;ld bc,
        inc hl
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        ld (hl),0xc3 ;jp
        inc hl
        ld (hl),bgpush_setpg&0xff
        inc hl
        ld (hl),bgpush_setpg/256
        push bc
        SETPGPUSHBASE
        pop bc        
        ;ld hl,pushbase
        pop hl ;pushbase+
        ret

bgpush_inccurscroll
;bc=scroll increment (signed)
        ld hl,(callpush_curscroll)
        add hl,bc
        ld bc,pushhgt
        ld a,h
        or a
        jp m,bgpush_inccurscroll_negative
        sbc hl,bc
        jr nc,$+3
bgpush_inccurscroll_negative
        add hl,bc
        ld (callpush_curscroll),hl
        ret

bgpush_draw
        ;call setpgsscr40008000
        call setpgscrlow4000

;адрес входа = f(curscroll)
;адрес патча-распатча = f((curscroll+scrhgt)mod scrollhgt)

callpush_curscroll=$+1
        ld bc,0 ;0..199 ;изначально 199 = выводим фон с самого начала
;mul PUSHLINESZ:
        ld a,PUSHLINESZ ;<256
        ld hl,0
        rla
        jr nc,$+4
         ld h,b
         ld l,c
        dup 7
        add hl,hl
        rla
        jr nc,$+3
        add hl,bc
        edup
        ld c,-1
        ld a,h
         sub 63
         inc c
        jr nc,$-3
        add a,63
        ld h,a
        ld a,c
        add a,a
        add a,a
        ld (callpush_callpg),a
        ld bc,pushbase+2
        add hl,bc ;hl = curscroll*PUSHLINESZ + pushbase + 2
        ld (callpushjp),hl

        ld hl,(callpush_curscroll) ;0..199
        ld bc,scrhgt
        add hl,bc
        ld bc,pushhgt
        sbc hl,bc
        jr nc,$+3
        add hl,bc
        ld b,h
        ld c,l
;mul PUSHLINESZ:
        ld a,PUSHLINESZ ;<256
        ld hl,0
        rla
        jr nc,$+4
         ld h,b
         ld l,c
        dup 7
        add hl,hl
        rla
        jr nc,$+3
        add hl,bc
        edup
        ld c,-1
        ld a,h
         sub 63
         inc c
        jr nc,$-3
        add a,63
        ld h,a
        ld a,c
        add a,a
        add a,a
        ld (callpush_patchpg),a
        ld bc,pushbase
        add hl,bc ;hl = ((curscroll+scrhgt)mod scrollhgt)*PUSHLINESZ + pushbase
        ld (call_patchaddr),hl
        ld (call_unpatchaddr),hl

        ld ix,callpushq
        
        ld iy,tpushpgs
        ld hl,pushscrtop+pushwid+(0*0x2000)
        exx
        call callpush
        inc iy
         inc iy
        ld hl,pushscrtop+pushwid+(1*0x2000)
        exx
        call callpush
        ;inc iy
         dec iy
        
        call setpgscrhigh4000
        
        ld hl,pushscrtop+pushwid+(0*0x2000)
        exx
        call callpush
        inc iy
         inc iy
        ld hl,pushscrtop+pushwid+(1*0x2000)
        exx
        call callpush
        
        jp setpgsmain40008000

;TODO fill pushlines from tiles


callpush
;hl'=end of top line of screen
;включить ту страницу, которую надо патчить
callpush_patchpg=$+2
        ld a,(iy+0)
        SETPGPUSHBASE
        ld hl,0xe9dd ;jp (ix)
call_patchaddr=$+1
        ld (0),hl
        ld de,0 ;этим числом будем портить левый край при прерывании
        exx
;включить ту страницу, которую надо вызвать
callpush_callpg=$+2
        ld a,(iy+0)
        SETPGPUSHBASE
        ld bc,40
        ld d,b
        ld e,b ;этим числом будем портить левый край при прерывании
        ld (callpushsp),sp
         ld sp,hl
         exx ;вместо запатченного места
callpushjp=$+1
        jp 0
callpushq
;на выходе уже включена та страница, которую надо распатчить
callpushsp=$+1
        ld sp,0        
        ld hl,0xd9f9
call_unpatchaddr=$+1
        ld (0),hl
        ret
