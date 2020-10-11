        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

OLDDRAWSPR=0;1

DEBUGPRINT=0

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=192-16;200
clswid=40 ;*8
clshgt=200

STACK=0x3ff0 ;место для вылетания за экран
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00;0x3b80 ;чтобы не запороть стек загрузки bmp в bgpush (теперь он в 0x4000+)

XSUBPIX8=8
YSUBPIX8=8

MAXSPEED=4*XSUBPIX8
CAMERATRACKINGSPEED_X=16 ;double pixels
CAMERATRACKINGSPEED_Y=16
CAMERASHIFTSPEED_X=4 ;double pixels
CAMERASHIFTSPEED_Y=4

FIRSTSOLIDTILE=32
FIRSTBETONTILE=64
FIRSTOBJTILE=111

;PENT=0


uvscroll_scrbase=0x4000
uvscroll_pushbase=0x8000
uvscroll_callbase=0xc000


UVSCROLL_WID=1024
UVSCROLL_HGT=256;512
TILEMAPWID=42 ;целые метатайлы
TILEMAPHGT=24 ;целые метатайлы
UVSCROLL_SCRWID=320 ;8*(TILEMAPWID-2)
UVSCROLL_SCRHGT=192-16 ;(делится на 16!!!) ;8*(TILEMAPHGT-2) ;чтобы выводить всегда 12 метатайлов (3 блока по 8) по высоте
UVSCROLL_NPUSHES=UVSCROLL_WID/2/4/2 
UVSCROLL_SCRNPUSHES=UVSCROLL_SCRWID/2/4/2 

UVSCROLL_SCRSTART=uvscroll_scrbase+((UVSCROLL_SCRHGT-1)*40)
UVSCROLL_LINESTEP=-40

UVSCROLL_NCALLPGS=4

UVSCROLL_TEMPSP=tempsp

METATILEMAPWID=256;64
METATILEMAPHGT=64
TILEGFX=0xc000

DELETEDYHIGH=0x7f

pushbase=0x8000;c000
        macro SETPGPUSHBASE
         ;ld (curpgc000),a
         ;SETPG32KHIGH
        ;ld (curpg8000),a
        SETPG32KLOW
        endm

        macro RECODEBYTE
        ld a,(de)
        ld ($+4),a
        ld a,(trecodebyteright)
        ld c,a
        dec de
        ld a,(de)
        dec de
        ld ($+4),a
        ld a,(trecodebyteleft)
        or c
        endm        

        org PROGSTART
begin
        jp GO ;/prsprqwid (спрайты в файле подготовлены так, что выходят сюда)
        
mainloop_uv0

        ld a,(curscrnum)
        or a
        ld hl,(allscroll)
        ld a,(allscroll_lsb)
        jr z,mainloop_uv_getcurscroll0
allscroll_scr1=$+1
        ld de,-1
        ld (allscroll_scr1),hl
allscroll_lsb_scr1=$+1
        ld c,-1
        ld (allscroll_lsb_scr1),a
        jr mainloop_uv_getcurscrollok
mainloop_uv_getcurscroll0
allscroll_scr0=$+1
        ld de,-1
        ld (allscroll_scr0),hl
allscroll_lsb_scr0=$+1
        ld c,-1
        ld (allscroll_lsb_scr0),a
mainloop_uv_getcurscrollok

skipfastredraws=$+1
        ld b,1
        dec b
        jr nz,mainloop_uv_dodrawbg
        cp c
        jr nz,mainloop_uv_dodrawbg
        or a
        sbc hl,de
        ;jr nz,mainloop_uv_dodrawbg
        jr z,mainloop_uv_nodrawbg
mainloop_uv_dodrawbg
         ld a,b
         ld (skipfastredraws),a
        call uvscroll_draw ;367574/391621
        jr mainloop_uv_drawbgq
mainloop_uv_nodrawbg
;copy scr behind sprites
        ;ld hl,spritesA+5;/B/C
        ld a,(curspritesN)
        inc a
        cp 3
        jr nz,$+3
        xor a ;берём спрайты на 2 отрисовки раньше (т.е. буфер следующий из 3)
        call getspritesN_a_tode
        ex de,hl
         ld l,0
         ld l,(hl)        
        inc l
        dec l
        jr z,undrawsprites0q
undrawsprites0
        ld a,(hl)
        dec hl
        SETPG32KHIGH
        ld a,(hl)
       ;sub 0x80
        ld hy,a
        dec hl
        ld a,(hl)
        ld ly,a
        dec hl
        ld c,(hl) ;y
        dec hl
        ld e,(hl) ;x
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        push hl
        ;jr $
        call copyboxscrtoscr
        pop hl
        dec l
        jp nz,undrawsprites0
undrawsprites0q
        call setpgsmain40008000
        
mainloop_uv_drawbgq

       if OLDDRAWSPR==1
        ld ix,objects
        call drawsprites
        ld ix,bullets
        call drawsprites
       else
curspritesN=$+1
        ld a,0
        call getspritesN_a_tode
        ld ix,objects
        call preparedrawsprites ;1720
        ld ix,bullets
        call preparedrawsprites ;1110
        dec de
        ld (drawsprites_data),de
         ld a,e
         ld e,0
         ld (de),a
        call drawsprites ;24040 (только герой)
        ld a,(curspritesN)
        inc a
        cp 3
        jr nz,$+3
        xor a
        ld (curspritesN),a
       endif

        call usetrackcamera
;d=camera dy
;e=camera dx
;l=mousekey
        ld a,l ;hl=(sysmousebuttons)
        rra
         ;jr nc,mainloop_uvq ;LMB
        call uvscroll_scroll
        call uvscroll_scrolltiles ;23099(21121 ldir)/46220
        
       ld a,(timer)
       push af
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
mainloop_uvwaittimer0
        ld a,(timer)
uvoldtimer=$+1
        ld b,0
        ld (uvoldtimer),a
        sub b
        ld b,a
        jr z,mainloop_uvwaittimer0
mainloop_uvlogic0
        push bc
        call logic
        pop bc
        djnz mainloop_uvlogic0

;можем начать новую отрисовку, только если с момента changescrpg прошло хотя бы одно прерывание (возможно, внутри logic)
       pop bc ;b=timer на момент changescrpg
waitchangescr0
        ld a,(timer)
        cp b
        jr z,waitchangescr0

        ld a,(curkey)
        cp key_esc
        jp nz,mainloop_uv0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mainloop_uvq

        if 1==1

;vertical scroll
        ld de,bgfilename
        call bgpush_prepare

        call cls
        ld de,pal;SUMMERPAL
        OS_SETPAL

mainloop
        ld bc,-1
        call bgpush_inccurscroll

        call bgpush_draw ;359975t

        ld de,spritesA+1
        call preparedrawsprites
        dec de
        ld (drawsprites_data),de
        call drawsprites
        
       ld a,(timer)
       push af
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
        
mainloopwaittimer0
        ld a,(timer)
oldtimer=$+1
        ld b,0
        ld (oldtimer),a
        sub b
        ld b,a
        jr z,mainloopwaittimer0
mainlooplogic0
        push bc
        call logic
        pop bc
        djnz mainlooplogic0
        
;можем начать новую отрисовку, только если с момента changescrpg прошло хотя бы одно прерывание (возможно, внутри logic)
       pop bc ;b=timer на момент changescrpg
waitchangescr1
        ld a,(timer)
        cp b
        jr z,waitchangescr1
        
;waitkey
        ;halt ;в играх не юзаем YIELD, иначе может сработать чужой обработчик прерываний
        ld a,(curkey)
        cp key_esc
        jp nz,mainloop;waitkey

        endif

        call swapimer
pgmusic=$+1
        ld a,0
        SETPG16K
        ld hl,0x4008+3 ;stop
        OS_SETMUSIC
        halt
        QUIT

curkey
        db 0

getspritesN_a_tode
        or a
        ld de,spritesA+1
        ret z
        dec a
        ld de,spritesB+1
        ret z
        ld de,spritesC+1
        ret

        if OLDDRAWSPR==1
drawsprites
pg1=$+1
        ld a,0
        call setpgc000
drawsprites0       
        bit 7,(ix+obj.y16+1) ;yhigh
        jp nz,setpgsmain40008000

        ld l,(ix+obj.animaddr16+0)
        ld h,(ix+obj.animaddr16+1)
        ld e,(hl)
        inc hl
        ld d,(hl) ;de = phase

        ;ld l,(ix+obj.spraddr16+0)
        ;ld h,(ix+obj.spraddr16+1)
        
        ex de,hl
        
         ;ld a,2
         ;add a,0
         ;ld ($-1),a
         ;and 2*3
         ;add a,l
         ;ld l,a
        ld (drawsprites0_sprdescr),hl
        call setpgsscr40008000 ;предыдущий спрайт мог выключить, если был левее экрана и вообще не попал на экран? ;TODO если спрайт в границах экрана
drawsprites0_sprdescr=$+2
        ld iy,(0xc000);testspr

;храним x*XSUBPIX8 (in double pixels),y*YSUBPIX8
        ld a,(ix+obj.x16+0)
        ld d,(ix+obj.x16+1)
        srl d
        rra
        srl d
        rra
        srl d
        rra
        ld e,a
        
cameraxm=$+1
        ld hl,0;+160;-2048+160
        add hl,de
         ;jr $
        ld a,h
        or a
        jr nz,drawspr_skip
        ld a,l
        cp 159+sprmaxwid
        jr nc,drawspr_skip
        ;sub sprmaxwid-1
        ld e,a
        
        ld a,(ix+obj.y16+0)
        ld b,(ix+obj.y16+1)
        srl b
        rra
        srl b
        rra
        srl b
        rra
        ld c,a
cameraym=$+1
        ld hl,0;+160;-1024+160
        add hl,bc
        ld a,h
        or a
        jr nz,drawspr_skip
        ld a,l
        cp 199+sprmaxhgt
        jr nc,drawspr_skip
        sub sprmaxhgt-1
        ld c,a

;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)

        push ix
        ;call prsprega ;(с включением экранных страниц и проверкой попадания спрайта в экран) один спрайт 16x16 = 6875t
        call prspr ;(без включения экранных страниц и без проверки попадания спрайта в экран) один спрайт 16x16 = 6408t (из них 4224t само мясо)
        pop ix
drawspr_skip

        ld bc,OBJSIZE
        add ix,bc
        jp drawsprites0
;817000(prsprega)/793000(prspr)t на всё
        endif

        if OLDDRAWSPR==0
preparedrawsprites
;pg1=$+1
        ld a,(pg1) ;страница описателей спрайтов
        call setpgc000
preparedrawsprites0
        bit 7,(ix+obj.y16+1) ;yhigh
        ret nz ;jp nz,preparedrawspritesq ;setpgsmain40008000

;храним x*XSUBPIX8 (in double pixels),y*YSUBPIX8
        ld a,(ix+obj.x16+0)
        ld b,(ix+obj.x16+1)
        srl b
        rra
        srl b
        rra
        srl b
        rra
        ld c,a
cameraxm=$+1
        ld hl,0;+160;-2048+160
        add hl,bc
        ld a,h
        or a
        jr nz,preparedrawspr_skip
        ld a,l
        cp 159+sprmaxwid
        jr nc,preparedrawspr_skip
        ;ld e,a
         ld (de),a ;x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        
        ld a,(ix+obj.y16+0)
        ld b,(ix+obj.y16+1)
        srl b
        rra
        srl b
        rra
        srl b
        rra
        ld c,a
cameraym=$+1
        ld hl,0;+160;-1024+160
        add hl,bc
        ld a,h
        or a
        jr nz,preparedrawspr_skip
        ld a,l
        cp 199+sprmaxhgt
        jr nc,preparedrawspr_skip
        sub sprmaxhgt-1
        ;ld c,a
         inc de
         ld (de),a ;y = -(sprmaxhgt-1)..199 (кодируется как есть)
         inc de
        ld l,(ix+obj.animaddr16+0)
        ld h,(ix+obj.animaddr16+1)
        ld a,(hl) ;phase LSB
        inc hl
        ld h,(hl) ;phase HSB
        ld l,a
         ldi
         ldi

        ld a,(ix+obj.animaddr16+0) ;TODO
pg1=$+1
        ld a,0
         ld (de),a ;pg
         inc de
preparedrawspr_skip
        ld bc,OBJSIZE
        add ix,bc
        jp preparedrawsprites0
;817000(prsprega)/793000(prspr)t на всё
;preparedrawspritesq
;        dec de
;        ld (drawsprites_data),de
;        ret ;jp setpgsmain40008000

        ;ld iy,(0xc000);testspr
        ;ld e,110+(sprmaxwid-1) ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        ;ld c,120 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        ;call prsprega

        align 256
spritesA
        ds 1+5*51
        align 256
spritesB
        ds 1+5*51
        align 256
spritesC
        ds 1+5*51

drawsprites
;y,x,addr,pg - читаем с конца
drawsprites_data=$+1
        ld hl,0;sprlistA/B/C + ...
        ;jr $
        inc l
        dec l
        ret z ;no sprites
drawsprites0
        call setpgsscr40008000 ;предыдущий спрайт мог выключить, если был левее экрана и вообще не попал на экран? ;TODO если спрайт в границах экрана
        ld a,(hl)
        dec hl
        call setpgc000
        ld a,(hl)
        ld hy,a
        dec hl
        ld a,(hl)
        ld ly,a
        dec hl
        ld c,(hl) ;y
        dec hl
        ld e,(hl) ;x
        push hl
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        call prspr ;(без включения экранных страниц и без проверки попадания спрайта в экран) один спрайт 16x16 = 6408t (из них 4224t само мясо)
        pop hl
        dec l
        jp nz,drawsprites0
        jp setpgsmain40008000

        endif

getmousedelta
        GET_KEY ;OS_GETKEYNOLANG
        ld a,c ;keynolang
        ;ld (key),a
         jr nz,control_nofocus
control_imer_oldmousecoords=$+1
        ld bc,0
        ld (control_imer_oldmousecoords),de
        ld a,d;b
        sub b;d
        ld d,a
        ld a,c;e
        sub e;c
        ld e,a
control_nofocus
        ;ld (control_imer_mousecoordsdelta),de
        ret

loadpage
;заказывает страничку и грузит туда файл (имя файла в hl)
;out: hl=после имени файла, a=pg
        push hl
        OS_NEWPAGE
        pop hl
        ld a,e
        push af ;pg
        call setpgc000;SETPG32KHIGH
        push hl
        ex de,hl
        OS_OPENHANDLE
        push bc
        ld de,0xc000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE                
        pop hl
        ld b,1
        xor a
        cpir ;after 0
        pop af ;pg
        ret

        include "pal.ast"
;SUMMERPAL
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        ;dw 0xffff,0xfefe,0x1d1d,0x3c3c,0xcdcd,0x4c4c,0x2c2c,0xecec
        ;dw 0xfdfd,0x2d2d,0xeeee,0x3f3f,0xafaf,0x5d5d,0x4e4e,0x0c0c
;RSTPAL
;        STANDARDPAL


primgega
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        push bc
        call setpgsscr40008000
        pop bc
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
        jp setpgsmain40008000
        
prsprega
;iy=spr (+4)
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        push bc
        call setpgsscr40008000
        pop bc       
        ld a,e
        cp scrwid+(sprmaxwid-1)
        jr nc,noprspr
        ld a,c
        add a,sprmaxhgt-1
        cp scrhgt+(sprmaxhgt-1)
        call c,prspr
noprspr
        jp setpgsmain40008000

sfxplay
        push af
pgsfx=$+1
        ld a,0
        SETPG32KLOW
        pop af
        jp 0x8000 ;SFXPLAY

        include "int.asm"
        include "cls.asm"
        include "prspr.asm"
        include "bgpush.asm"
        include "bgpushxy.asm"
        include "mem.asm"
        include "bmp.asm"
        include "logic.asm"
        include "camera.asm"

        include "sprdata.asm"
        
        include "../../_sdk/file.asm"

        if DEBUGPRINT
prcoords
        call setpgsscr40008000
        ld hl,(cameraxshift)
        ld de,0x4000 + (192*40)
        call prnum
        ld hl,(objects+obj.xspeed16)
        ld de,0x4008 + (192*40)
        call prnum
        ret

prnum
        ld bc,10000
        call prdig
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;push hl
        ;call prchar
        ;pop hl
        ;ret
prchar
;a=code
;de=screen
        push de
        push hl
        call prcharin
        pop hl
        pop de
        inc e
        ret
        
calcscraddr
;bc=yx
;можно портить bc
        ex de,hl
        ld a,c ;x
        ld l,b ;y
        ld h,0
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
         add hl,hl
         add hl,hl
         add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        ex de,hl
        ret

prcharxy
;a=code
;bc=yx
        push de
        push hl
        push bc
        push af
        call calcscraddr
        pop af
        call prcharin
        pop bc
        pop hl
        pop de
        ret
        
prcharin
        sub 32
        ld l,a
        ld h,0
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
        ;ld bc,font-(32*32)
        ;add hl,bc
        ld a,h
        add a,font/256
        ld h,a
prcharin_go
        ex de,hl
        
        ld bc,40
        push hl
        push hl
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        ;set 6,h
         ld a,h
         add a,0x40
         ld h,a
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 5,h
        push hl
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        ;set 6,h
         ld a,h
         add a,0x40
         ld h,a
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup        
        ret
        endif

genpush_newpage
;заказывает страницу, заносит в tpushpgs, a=pg
        push bc
        push de
        push hl
        push ix
        OS_NEWPAGE
        pop ix
        ld a,e
        ld (ix),a
        ld de,4
        add ix,de
        pop hl
        pop de
        pop bc
        ret

        if DEBUGPRINT
        align 256
font
        incbin "fontgfx"
        endif
        
res_path
        db "sprexamp",0 ;в этом относительном пути будут лежать все загружаемые данные игры
bgfilename
        db "bg6-16c.bmp",0
bgxyfilename
        db "bg8-16d.bmp",0

tilefilename
        db "tiles.bin",0
tilebmpfilename
        db "tiles1.bmp",0
tilemapfilename
        db "map1.map",0
enemymapfilename
        db "map1.enm",0


TILEMAP
        ds TILEMAPWID*TILEMAPHGT ;снизу вверх, справа налево

tpushpgs
        ds 128 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...

        align 256
trecodebyteleft
        dup 256
;%00003210 => %.3...210
_3=$&8
_210=$&7
        db (_3*0x08) + (_210*0x01)
        edup
        
trecodebyteright
        dup 256
;%00003210 => %3.210...
_3=$&8
_210=$&7
        db (_3*0x10) + (_210*0x08)
        edup

bgpush_bmpbuf=0x4000 ;ds 1024;320 ;заголовок bmp или одна строка
bgpush_loadbmplinestack=bgpush_bmpbuf+1024 ;ds pushhgt*2+32

        include "init.asm"

end        

	display "begin=",begin
	display "end=",end
	display "Size ",/d,end-begin," bytes"
	
	savebin "sprexamp.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l"
