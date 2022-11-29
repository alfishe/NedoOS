        macro MASKBYTE
        ld a,(hl)
        and e
        or d
        ld (hl),a
        endm
        macro DOWNBYTE
        add hl,bc
        endm

prspr
;в 4000,8000 уже включен экран (setpgsscr40008000)
;iy=sprite data+2 = spraddr+4
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)=sprhgt
;(iy-4)=sprwid
;по x,y, ширине, высоте найти адрес на экране, куда выводим видимую часть спрайта
;спрайт полной высоты и ширины должен работать максимально быстро!
        ld a,scrwid+(sprmaxwid-1)
        sub e ;x ;a=расстояние до правой границы экрана
        ld hx,a
        ;ld lx,0 ;по умолчанию нет фальшивого экрана, выход по правой границе экрана будет сразу ;для полной ширины не надо - выход будет по окончанию спрайта
         ;ld lx,0 ;для спрайта полной высоты, клипированного справа - выход сразу на границе
        ld a,e ;x
        sub sprmaxwid-1
        jr nc,prsprnocropleft
;[найти адрес начала видимой части спрайта:]
;[сначала столбец (прибавить hgt*2*число скрытых столбцов) можно в цикле, т.к. пропуск столбцов бывает редко]
;или включить фальшивый экран в 0x4000,0x8000 и заменить адреса выхода на переключалку страниц, так можно работать со спрайтами процедурой
;a=-число отрезанных слева столбцов
;посчитать hx для правильного выхода из фальшивого экрана
;посчитать lx для правильного выхода из спрайта в y-клипированной выводилке
        ld l,a
        add a,(iy-4)
        ld lx,a ;sprwid-число отрезанных слева столбцов
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
        xor a
        sub l
        ld hx,a ;число отрезанных слева столбцов
        push bc
        ld a,(pgfake)
        ;ld (curpg4000),a
        SETPG4000
        ;ld (curpg8000),a
        SETPG8000
;hl будет вычислен с ошибкой +64
        pop bc
        ld a,l
        or a
prsprnocropleft
        ld (prsprqsp),sp
;NC
        ld b,0
        ld l,c ;y
        rra ;x bit 0
        ;ld h,0x40/32/2
        ;jr nc,$+4 ;x bit 0
        ; ld h,0x80/32/2
         ld h,b;0
         rl h
         inc h ;0x40/32/2 или 0x80/32/2
        srl a ;x bit 1
         rl h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40+scrbase
         if scrbase&0xff
         add a,scrbase&0xff
         endif
;a=x/4
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl=scr ;не может быть переполнения при отрицательных x? maxhl = 199*40 + 127 = 8087
        ld a,c ;y
        ;add a,sprmaxhgt-1
        ;sub sprmaxhgt-1
        ;jp c,prsprcroptop
         cp scrhgt
         jp nc,prsprcroptop
        add a,(iy-3) ;sprhgt
        cp scrhgt+1 ;200=OK, >200=crop
        jp nc,prsprcropbottom        
;hx=расстояние до правой границы экрана (columns)
;x=156: hx=4
;x=157: hx=3
;x=158: hx=2
;x=159: hx=1
;если нет клипирования справа, то при нечётном x и чётном sprwid надо сделать строго hx>sprwid/2!
;lx важен только при клипировании слева
         ld a,hx
         inc a
         srl a
         ld hx,a ;lx не пересчитываем, он завышен в 2 раза, но тут в полном спрайте есть выход по ширине раньше
;hx=расстояние до правой границы экрана (double columns)
;x=156: hx=2
;x=157: hx=2
;x=158: hx=1
;x=159: hx=1
        ld c,40 ;b=0
;iy=sprite data+2
        ld e,(iy-2)
        ld d,(iy-1)
        ld sp,iy
;выбрать ветку в зависимости от sprhgt
        ld a,(iy-3) ;sprhgt
        cp 16
        jr z,prspr16
        jr nc,prspr24
prspr8
        ld a,prspr8column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr8column+1
prspr16
        ld a,prspr16column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr16column+1
prspr24
        cp 32
        jr z,prspr32
        ld a,prspr24column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr24column+1
prspr32
        ld a,prspr32column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr32column+1
        align 256
;отдельная процедура для спрайта полной высоты, т.к. там не надо на каждом столбце переставлять sp
prspr32column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr24column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr16column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr8column
        display prspr32column," HSB equal to ",$
        dup 7
        pop de
        MASKBYTE
        DOWNBYTE
        edup
        pop de
        MASKBYTE
;найти адрес следующего столбца на экране или выйти        
;4000,8000,[c000]6000,a000,[e001]4001... ;единственное расположение для такой логики (из-за константы 0xa0) (другой вариант - константа 0x60? тогда надо экран в 0000!!!)
;нельзя использовать строки, где h=0xa0, т.е. верхние 7 строк (остаётся 193 строки), иначе надо ld a,0x9f...inc a (+2t)
        pop de ;годится только для спрайтов полной высоты (не прокатит даже если делать pop всех данных столбца, т.к. сдвиг hl разный - разве что и hl сдвигать при клипировании)
        ld a,0x9f;0xa0
        cp h
        adc hl,de ;de = 0x4000 - ((sprhgt-1)*40)
         ret c ;выход по ширине спрайта, там надо восстановить sp и константу в стеке
prsprcolumnpatch=$+1
        jp pe,prspr16column ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
         dec hx
goprsprcolumn
         jp nz,prspr16column
prsprcolumnpatch2=$-2
         ;выход по границе экрана
;10+11+15+14 = 40t (+5+9)
;это может быть граница фальшивого экрана! надо иметь возможность продолжить (с hl-64 из-за ошибки адреса при отрицательных x?)
;        ld a,(pgfake)
;curpg4000=$+1
        ld a,(curpg16k) ;ok
pgfake2=$+1
        cp 0
        jp nz,prsprqright ;действительно выход по правой границе
;был фальшивый экран для клипирования по левой границе, продолжаем на настоящем экране
        ld hx,lx
        ld bc,-64
        add hl,bc ;из-за ошибки адреса при отрицательных x
         dec c ;NZ!!!
;как не запороть стек? даже если инлайнить вызов, там внутри всё равно rst
        ld (prsprmaybeqrightsp),sp
        ld sp,tempsp
        call setpgsscr40008000 ;выключаем фальшивый экран, включаем настоящий
prsprmaybeqrightsp=$+1
        ld sp,0
        ld bc,40
        ;ld lx,b;0 ;второй раз будет действительно выход
        jp goprsprcolumn ;NZ!!!
;можно то же самое сделать при спрайте кодом (патчи не нужны, de присваивать только если меняется, 13-1 байт (36.5t) лишних на столбец, выход по dec hx:ret z и просто ret в конце)
;а как делать вход в середину, если спрайты кодом, а de присваивается только при изменении? сначала рисовать в фальшивый экран и переключать по call z?
;но клипирование по y уже надо делать с данными спрайта, а не с кодом (т.е. нужна копия спрайта в виде данных)

;выход по ширине спрайта
prsprqwid
;у нас de взят с прошлого раза, и обработчик прерываний может запороть стек
        ld hl,$
        push hl ;если теперь произойдёт прерывание, то de не запорет стек
prsprqright
prsprqsp=$+1
        ld sp,0
        ret

        
;для вывода спрайта неполной высоты:

;клипирование снизу
prsprcropbottom
;a=sprbottom
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
;hl=scr
        sub scrhgt;200
        ;sub (iy-3) ;sprhgt
         ld d,(iy-3) ;sprhgt
         sub d
        ld c,a ;-sprvisiblehgt = sprbottom-200-sprhgt
;если клипировано слева, то сейчас lx = sprwid-число отрезанных слева столбцов
;иначе lx не задано
        
        ld a,(iy-4) ;sprwid
        cp hx ;расстояние до правого края экрана
        ;jr nc,$
        jr nc,prsprcropygo;_cropx ;берём меньшее из sprwid и расстояния до правой границы экрана
        ld hx,a
        jp prsprcropygo

prsprcroptop
;a=sprtop
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
;hl=scr неверный (выше экрана)
        
        neg ;a=number of lines to crop
         ld d,(iy-3) ;sprhgt
         sub d
;a = -sprvisiblehgt = -(sprtop+sprhgt) = linestocrop-sprhgt
;если sprvisiblehgt<=0, то спрайта нет на экране!!! выходим!!!
         ret p
        ld c,a ;-sprvisiblehgt = -(sprtop+sprhgt) = linestocrop-sprhgt

;если клипировано слева, то сейчас lx = sprwid-число отрезанных слева столбцов
;иначе lx не задано
        
        ld a,(iy-4) ;sprwid
        cp hx ;расстояние до правого края экрана
        jr nc,prsprcropygo_cropx ;берём меньшее из sprwid и расстояния до правой границы экрана
        ld hx,a
prsprcropygo_cropx

         ld a,c
         add a,d ;a=number of lines to crop
        add a,a
;прибавить 2*число скрытых строк к адресу
        add a,ly
        ld ly,a
        jr nc,$+4
        inc hy
        
        ld a,e ;x
        sub sprmaxwid-1 ;NC для положительных x
        srl a
        ld h,0x40
        jr nc,$+4 ;x bit 0
         ld h,0x80
        srl a
        jr nc,$+4 ;x bit 1
         set 5,h
       if scrbase&0xff
       add a,scrbase&0xff
       endif
        ld l,a
        
prsprcropygo
;d=(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
        ld a,d ;sprhgt
        ;add a,c ;-sprvisiblehgt
        ; add a,3 ;inc a
        ;add a,a
        ;ld (prsprNspraddpatch),a ;2*(sprhgt-sprvisiblehgt)+2 +4
         inc a
         add a,a
        ld (prsprNspraddpatch),a ;2*sprhgt+2

        ld a,c ;-sprvisiblehgt
        add a,a
        add a,c
        add a,a
        ld (prsprNpatch),a ;PRSPR24 и т.п. (по 6 байт)        

        ex de,hl
         ;ld b,-1 ;убрать за счёт перемещения ld h
         ;ld h,0x40/32-1
         inc c
        ld l,c ;-sprvisiblehgt
        add hl,hl
        add hl,hl
         ld h,0x40/8-1 -1
         jr nz,$+4
         ld h,0x40/8 ;для sprvisiblehgt-1 == 0
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl
        ld (prsprNscraddpatch),hl ;0x4000 - ((sprvisiblehgt-1)*40)
        ex de,hl

;hl=scr
        ;ld c,40
        jp prsprN

;выравнивание на нужный младший байт адреса:
_lowaddr=256-(sprmaxhgt*6)
        ds (_lowaddr-$)&0xff
;младший байт адреса равен 256-(sprvisiblehgt*6)
PRSPR32
        dup 8
        MASKBYTE
        DOWNBYTE
        pop de
        edup
PRSPR24
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR23
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR22
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR21
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR20
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR19
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR18
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR17
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR16
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR15
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR14
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR13
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR12
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR11
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR10
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR9
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR8
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR7
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR6
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR5
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR4
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR3
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR2
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR1
        display PRSPR32," HSB equal to ",$
        MASKBYTE
        
;найти адрес следующего столбца на экране или выйти        
;4000,8000,[c000]6000,a000,[e001]4001...
;восстановить начальный hl
prsprNscraddpatch=$+1
        ld bc,0 ;bc = 0x4000 - ((sprvisiblehgt-1)*40)
        ld a,0x9f;0xa0
        cp h
        adc hl,bc
        jp pe,prsprNcolumnq ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
prsprNcolumnq
        dec hx
        jp z,prsprNmaybeqright ;это может быть граница фальшивого экрана! надо иметь возможность продолжить (с hl-64 из-за ошибки адреса при отрицательных x?)
prsprNcolumnqq
;найти адрес данных следующего столбца спрайта
;можно просто сделать много пустых pop de, т.к. пропуск строк бывает редко
prsprNspraddpatch=$+1
        ld bc,0 ;bc = 2*(sprhgt-sprvisiblehgt)+2
        add iy,bc
prsprN
;iy=sprite data
        ld c,40
        ld sp,tempsp ;чтобы не намусорить новым de в старых данных
        ld e,(iy-2)
        ld d,(iy-1)
        ld sp,iy
prsprNpatch=$+1
        jp PRSPR24
        
prsprNmaybeqright
;curpg8000=$+1
;        ld a,0
        ld a,(curpg32klow) ;ok
pgfake=$+1
        cp 0
        jp nz,prsprqright ;действительно выход
        ld hx,lx
        ld bc,-64
        add hl,bc ;из-за ошибки адреса при отрицательных x
        ld sp,tempsp
        call setpgsscr40008000 ;выключаем фальшивый экран, включаем настоящий
        ;ld bc,40
        ;ld lx,b;0 ;второй раз будет действительно выход
        jp prsprNcolumnqq

copyboxscrtoscr
;iy=sprite data+2 = spraddr+4
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)=sprhgt
;(iy-4)=sprwid
       ;ld e,1+(sprmaxwid-1)
       ;ld c,0
        
        ld l,(iy-4) ;sprwid
        ld a,e ;x
        sub sprmaxwid-1
        ld e,a
        jr nc,copyboxscrtoscr_nocropleft
        add a,l
        ld l,a ;new sprwid
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
        xor a
        ld e,a ;new x        
copyboxscrtoscr_nocropleft
        add a,l
        sub scrwid
        jr c,copyboxscrtoscr_nocropright
;a=число столбцов, откушенных справа
        neg
        add a,l
        ld l,a ;new sprwid
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
copyboxscrtoscr_nocropright
        ld h,(iy-3) ;sprhgt
        ld a,c ;y
        cp -(sprmaxhgt-1)
        jr c,copyboxscrtoscr_nocroptop
        add a,h
        ld h,a ;new sprhgt
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
        xor a
        ld c,a ;new y
copyboxscrtoscr_nocroptop
        add a,h
        sub scrhgt
        jr c,copyboxscrtoscr_nocropbottom
;a=число столбцов, откушенных справа
        neg
        add a,h
        ld h,a ;new sprhgt
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
copyboxscrtoscr_nocropbottom
;h=hgt,l=wid (/2) != 0
         ;ld l,32
        ld a,c
        add a,h
        dec a
        ld c,a
;c=y, e=xleft (/2)
        ld lx,c ;lx=y
       push hl ;h=hgt,l=wid (/2) != 0
        ld a,e ;xleft (/2)
        add a,l ;wid (/2)
        dec a
        ld e,a ;xright (/2)
        ld b,0
        ld l,c ;y
        ;srl a ;CY=x bit 0
        ;srl a ;CY=x bit 1
         ld h,0xc0/32
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40+scrbase
        ; if scrbase&0xff
        ; add a,scrbase&0xff
        ; endif
        ;add a,l
        ;ld l,a
        ;adc a,h
        ;sub l
        ;ld h,a ;hl=scr
       pop bc ;b=hgt,c=wid (/2) != 0
;c=wid (/2)
;b=hgt
;e=xright (/2)
;lx=y
        push bc
        push de
        push hl
        call copyboxscrtoscr_page ;rightmost layer
        pop hl
        pop de
        pop bc
        dec e ;xright (/2)
        dec c ;wid (/2)
       ret z
        push bc
        push de
        push hl
        call copyboxscrtoscr_page ;next layer
        pop hl
        pop de
        pop bc
        dec e ;xright (/2)
        dec c ;wid (/2)
       ret z
        push bc
        push de
        push hl
        call copyboxscrtoscr_page ;next layer
        pop hl
        pop de
        pop bc
        dec e ;xright (/2)
        dec c ;wid (/2)
       ret z
copyboxscrtoscr_page
;lx=y
;e=xright (/2)
;c=wid (/2)
;b=hgt
;hl=scrright = 0xc000+
        push bc
        ld a,e ;xright (/2)
        rra
        call nc,getuser_scr_low
        call c,getuser_scr_high
        SETPGC000 ;kills bc
        ld a,e ;xright (/2)
        rra
        rra
        jr nc,$+4
         set 5,h
        and 0x3f
         if scrbase&0xff
         add a,scrbase&0xff
         endif
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl=scr
        pop bc
;widbytes = 1 + (xright)/4 - (xright-wid+1+(3-layer))/4 (layer = xright&3)
        ld a,e ;xright
        cpl
        and 3 ;3-layer
        add a,e ;xright
        sub c ;wid
        inc a
        srl a
        srl a
        ld c,e
        srl c
        srl c
        sub c
        dec a ;a=-widbytes
       ret z
        neg
        ld c,a
;c=wid (bytes in this page)
;b=hgt

       push bc
       push hl

        ;ld a,e ;xright
        ;cpl
        ld a,+(UVSCROLL_SCRWID/2)-1
        sub e
;[a=layer 0..3]
         ;add a,+(UVSCROLL_SCRNPUSHES-1)*8
        ld hl,allscroll_lsb
        add a,(hl)
;hlc = allscroll = yscroll*512+x2scroll
        ld c,a
          ld hl,(allscroll)
          jr nc,$+3
          inc hl ;hlc = allscroll = yscroll*512+x2scroll
        ld a,UVSCROLL_SCRHGT-1
        sub lx ;y
        ld e,a
        ld d,0
        add hl,de
        add hl,de
        ld a,c
         ld e,l ;yscroll*2
        add hl,hl
        if 1==1
         rr e ;yscroll (corrected для зацикливания)
         rra
         ;or 3 ;a=0xff-(((x2scroll+layer[+4])/2)&0xfc)
         set 0,a
          bit 1,a
         res 1,a
         jr nz,$+3
         inc a
        else 
         rr e ;yscroll (corrected для зацикливания)
         rra
          ;ld b,a
         and 0xfc ;a=0xfc-(((x2scroll+layer[+4]+((UVSCROLL_SCRNPUSHES-1)*8))/2)&0xfc)
        endif
         ld (copyboxscrtoscr_page_e),a
         ld a,h
         rla
         rla ;a=(x2scroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
          xor 3

        ld hl,tpushpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl) ;gfx pages
        SETPG4000
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        SETPG8000

        ld a,e ;yscroll (corrected для зацикливания)
        and 63
        add a,0x40
        ld d,a
copyboxscrtoscr_page_e=$+1
        ld e,0
         ;ld de,0x4001 ;de=ldpush = 0x4000+
         
       pop hl
       pop bc
;рисуем справа налево!
copyboxscrtoscr0
        push bc ;b = hgt
        ld hx,b
        push de
        push hl
;hl=scr = 0xc000+
;de=ldpush = 0x4000+
;11 LL RR pp 11 LL RR pp
        ld bc,-40
copyboxscrtoscrcolumn0
        ld a,(de)
        inc d
        ld (hl),a
        add hl,bc
        dec hx
        jp nz,copyboxscrtoscrcolumn0
        pop hl
        dec hl
        pop de
        bit 1,e
        dec de
        jr nz,$+2+3+3
         ld bc,6
         ex de,hl
         add hl,bc
         ex de,hl
        pop bc
        dec c
        jr nz,copyboxscrtoscr0
        ret
