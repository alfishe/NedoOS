        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=200

STACK=0x3ff0
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00

        org PROGSTART
begin
	jp GO ;patched by prspr
GO
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,0 ;EGA
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode) +8=noturbo, +0x80=keep gfx pages
        ld de,emptypal
        OS_SETPAL ;включаем чёрную палитру, чтобы было незаметно переброску экрана
        ld e,0
        OS_CLS ;очистили текущий экран

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pgmain4000),a
        ld a,h
        ld (pgmain8000),a
        ld a,l
        ld (pgmainc000),a

        OS_NEWPAGE ;заказали новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgvorobey),a ;запомнили её номер
        OS_NEWPAGE ;заказали новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgscrdata0),a ;запомнили её номер
        OS_NEWPAGE ;заказали другую новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgscrdata1),a ;запомнили её номер

        ld de,path
        OS_CHDIR
        
pgvorobey=$+1
        ld a,0
        ld de,filenamevorobey
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили один экранный файл в одну страницу
        
        ld a,(pgscrdata0)
        ld de,filename0 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили один экранный файл в одну страницу
        ld a,(pgscrdata1)
        ld de,filename1 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили другой экранный файл в другую страницу

;сейчас у нас включены страницы программы, как было

	call swapimer

;что-то делаем...
;не важно что...
;...

;теперь надо вывести загруженные данные на экран
        ld a,(pgscrdata0)
        SETPG32KHIGH ;включили страницу с данными в c000
        ld a,(user_scr0_low) ;ok
        SETPG16K ;включили пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        ld hl,0x4000+8000 ;там в картинке палитра (по байту на цвет)
        ld de,pal
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0 ;скопировали палитру в pal (по 2 байта на цвет)
        
        ld a,(pgscrdata1)
        SETPG32KHIGH ;включили страницу с данными в c000
        ld a,(user_scr0_high) ;ok
        SETPG16K ;включили другие пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        call setpgsscr40008000_current ;включили страницы экрана
        ld a,(pgvorobey)
        SETPGC000
        ld hl,scrbase
        ld de,0xc000
        ld bc,128*256+(224/2)
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        call primgega_onescreen
       

        ld de,sprpal;pal
        OS_SETPAL ;включили палитру спрайтов;картинки
        
        call setpgsmain40008000 ;включили страницу программы в 4000, как было
        call setpgmainc000 ;включили страницу программы в c000, как было

	ld de,scrwid/4 + (256*scrhgt) ;d=hgt,e=wid (/8)
	ld hl,0x4000 ;hl=scr
	call copyimgega_curtodefault ;копируем картинку на другой экран
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали

        ld a,(timer)
        ld (uvoldtimer),a
        
;главный цикл
mainloop

;вывод фона или восстановление фона под спрайтами
;... рекомендую взять из sprexamp!


;вывод спрайтов
;...
        call setpgsscr40008000 ;включили страницы экрана

	ld iy,spaceship0
	ld e,50 ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
	ld c,50 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
	call prspr
	ld iy,fly0
	ld e,80 ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
	ld c,60 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
	call prspr
	ld iy,explosion4
	ld e,60 ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
	ld c,60 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
	call prspr

        call setpgsmain40008000 ;включили страницы программы в 4000,8000, как было

;закончили рисовать
       ld a,(timer)
       push af
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали

;логика
;... её вызывать столько раз, сколько прошло прерываний!
mainloop_uvwaittimer0
        ld a,(timer)
uvoldtimer=$+1
        ld b,0
        ld (uvoldtimer),a
        sub b
        ld b,a
        jr z,mainloop_uvwaittimer0 ;если ни одного прерывания не прошло, крутимся тут
;b=сколько прошло прерываний
mainloop_uvlogic0
        push bc
        ;call logic ;<----------------- свою логику пиши сюда
        pop bc
        djnz mainloop_uvlogic0

;ждём физического переключения экрана!
;можем начать новую отрисовку, только если с момента changescrpg прошло хотя бы одно прерывание (возможно, внутри logic)
       pop bc ;b=timer на момент changescrpg
waitchangescr0
        ld a,(timer)
        cp b
        jr z,waitchangescr0

        ld a,(curkey)
        cp key_esc
        jp nz,mainloop ;выход по esc (break)
        
        ;YIELDGETKEYLOOP ;ждём кнопку
	call swapimer
        QUIT

pal
        ds 32 ;тут будет палитра картинки
;sprpal
	include "sprpal.ast" ;палитра спрайтов (надо рисовать картинку этой же палитрой!)
emptypal
        ds 32,0xff ;палитра, где все цвета чёрные

loadfile_in_ahl
;de=имя файла
;hl=куда грузим (0xc000)
;a=в какой странице
        SETPG32KHIGH ;включили страницу A в 0xc000
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	jp setpgmainc000 ;включили страницу программы в c000, как было

primgega_onescreen
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
        ret



copyimgega_curtodefault
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_low
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high
copyimgegaq
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call setpgmainc000
        jp setpgsmain40008000

copyimgega_defaulttocur
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low
        SETPG16K ;set "from" page in 4000
        call getuser_scr_low_cur
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high_cur
        jr copyimgegaq ;set "to" page in c000, copy

copyimgegalayer
        push hl
        ld hx,e ;wid/8
copyimgega0
        push de
        push hl
        ld b,d ;hgt
        ld de,40-0x8000
copyimgegacolumn0
        ld a,(hl)
        set 5,h
        ld c,(hl)
        set 7,h
        ld (hl),c
        res 5,h
        ld (hl),a
        add hl,de
        djnz copyimgegacolumn0
        pop hl
        pop de
        inc hl
        dec hx
        jr nz,copyimgega0
        pop hl
        ret 
        
pgscrdata0
        db 0
pgscrdata1
        db 0

curkey
        db 0
joystate
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
        db 0

path
        db "loadscr",0
filenamevorobey
        db "vorobey.bin",0
filename0
        ;db "solkey.scr",0
        db "0kubik.bmpx",0
filename1
        db "1kubik.bmpx",0

	include "mem.asm"
	include "int.asm"

	include "spr.ast"
	include "prspr.asm"

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "loadscr.com",begin,end-begin
	
	;LABELSLIST "../../../us/user.l"
