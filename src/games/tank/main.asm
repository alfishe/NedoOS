        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

scrbuf=#e000 ;делится на #800
tilemap=#dd00 ;#300
collisionmap=#da00 ;#300 (перед ней ~20 байт затирается)
validmap=#fc00 ;#300 (перед ней ~20 байт затирается)
VALID0=#fb ;валидная, не надо обновлять
VALID1=#80 ;невалидная, надо обновлять, там можно более длинные процедуры
VALID00=VALID0+256*VALID0
VALID01=VALID0+256*VALID1
VALID10=VALID1+256*VALID0
VALID11=VALID1+256*VALID1
validmaplinesize=32
validmapwid=validmaplinesize-2 ;в конце строки лежит validmapnext

emptyattr=7

fieldwid=10
fieldhgt=8
fieldx=0
fieldy=0

coordsfactor=4

leftwallx=0
topwally=0
rightwallx=fieldwid*24*coordsfactor
bottomwally=fieldhgt*24*coordsfactor

dir_r=#09
dir_l=#08
dir_u=#0b
dir_d=#0a

collisionmaplinesize=32
collisionmapwid=fieldwid*3
collisionmaphgt=fieldhgt*3
collisionmapsize=collisionmaplinesize*collisionmaphgt
tilemaplinesize=collisionmaplinesize
tilemapwid=collisionmapwid
tilemaphgt=collisionmaphgt
tilemapsize=collisionmapsize

maxemptytile=9

maxobjects=20
maxbullets=100
TERMINATOR=#80

tanksize=16
tankdamagesize=11 ;грязный хак
tankaimsize=8
tankspeed=4 ;2^n!
bulletspeed=6
bulletenergy=20

startlives=5
maxlives=10

;timer=23672
        
        include "macro.asm"
        
        org PROGSTART
begin
        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,d
        SETPG16K
        
        ld hl,valid00
        ld de,VALID00
        ld bc,valid00_size
        ldir
        ld hl,valid01
        ld de,VALID01
        ld c,valid01_size
        ldir
        ld hl,valid10
        ld de,VALID10
        ld c,valid10_size
        ldir
        ld hl,valid11
        ld de,VALID11
        ld c,valid11_size
        ldir

        call cls
        call clscrbuf
        
        ld a,startlives
        ld (lives),a
        call prlives

        call initlevel

        call clearvalid
        call restoreobjects_clear
        call restorebullets_clear

        call prmap
        call fillcollisionmap
        
        OS_GETTIMER ;hlde=timer
        ex de,hl
        ;ld hl,(timer)
        ld (oldtimer),hl
        
loop
        call restoreobjects
        call restorebullets
        ;ld a,2
        ;out (#fe),a
        call probjlist
        ;ld a,4
        ;out (#fe),a
        call prbulletlist
        ;ld a,0
        ;out (#fe),a
        
loopdelay
        OS_GETTIMER ;hlde=timer
        ex de,hl
        ;ld hl,(timer)
oldtimer=$+1
        ld bc,0
        ld (oldtimer),hl
        ld a,l
        sub c
        jr z,loopdelay
        ld b,a
        ;ld a,5
        ;out (#fe),a
logicloop0
        push bc
        call control
        call animate
        call logic
        call bulletlogic
        ;ld a,1
        ;out (#fe),a
        call fillcollisionmap
        ;ld a,5
        ;out (#fe),a
        call bulletcollision
        pop bc
        djnz logicloop0
        ;ld a,6
        ;out (#fe),a
        call prvalid
        ;call displaycollisionmap
        jp loop

initlevel
        call genmap

        ld ix,objlist
        call genobj_terminate
        ld ix,bulletlist
        call genbullet_terminate
        
        ld de,#0010 ;x
        ld hl,#02b0 ;y
        ld bc,params_tank
        ld a,1 ;a=dir
        call genobj
        
        ld de,#0010 ;x
        ld hl,#0010 ;y
        ld bc,params_tanke
        ld a,2 ;a=dir
        call genobj

        ld de,#0370 ;x
        ld hl,#0010 ;y
        ld bc,params_tanke
        ld a,2 ;a=dir
        call genobj
reter        
        ret

attrbox  
;bc=yx
;a=фон
;d=y координата левого верхнего угла
;е=х координата левого верхнего угла
;#5800+xcoordredbox+(32*ycoordredbox)
        ld l,d  ;y
        ld h,0        
        add hl,hl     
        add hl,hl     
        add hl,hl     
        add hl,hl     
        add hl,hl
        ld d,#58
        add hl,de ;x
attrbox_lines
        ld e,l
        ld d,h   
        push bc
attrbox_pixels 
        ld (de),a
        inc e
        dec c        
        jr nz,attrbox_pixels
        pop bc
        ld de,32
        add hl,de    
        djnz attrbox_lines
        ret

genmap
        ld hl,tilemap
        ld de,tilemap+1
        ld bc,tilemapsize-1
        ld (hl),0
        ldir
        
        ld hl,tilemap+(3*tilemaplinesize)
        ld b,fieldhgt-2
genmaplines
        push bc
        push hl
        ld b,fieldwid
genmapline
        push bc
        push hl
        push hl
        ld a,b ;1..fieldwid
        sub 2 ;n
        cp fieldwid-2 ;nc=левый или правый край
        adc a,nblocks+1 ;n + cy + (nblocks+1)
        sub b ;n + cy + nblocks - (n+2)
        ld c,a ;nblocks или nblocks-1
        call rnd
        ld c,a
        ld b,0
        ld de,9
        call mulbcde
        ld bc,blocks
        add hl,bc
        ex de,hl
        pop hl
        ld bc,tilemaplinesize-2
        dup 3
        ld a,(de)
        ld (hl),a
        inc de
        inc hl
        ld a,(de)
        ld (hl),a
        inc de
        inc hl
        ld a,(de)
        ld (hl),a
        inc de
        add hl,bc
        edup
        pop hl
        inc hl
        inc hl
        inc hl
        pop bc
        djnz genmapline
        pop hl
        ld bc,tilemaplinesize*3
        add hl,bc
        pop bc
        djnz genmaplines
        ret

control
        GET_KEY
        cp csSpace
        jp z,quit
        call getkey ;c=%???lrduf (0=нажато)
        ld a,c
        rra ;f
        jr nc,control_noreleasefire
        ld a,1
        ld (control_firehasbeenreleased),a
control_noreleasefire

;кнопки должны срабатывать, когда мы стоим посредине клетки ((x&(8*coordsfactor-1)) == 4*coordsfactor, (y&(8*coordsfactor-1)) == 4*coordsfactor)
        ld ix,objlist ;первый объект - наш
        call checkevencoords ;nz=не посредине клетки
        ret nz

        ld a,c
        rra ;f
        jr c,control_nofire
        ;проверим, что до этого был момент, когда огонь не нажимали
control_firehasbeenreleased=$+1
        ld a,0
        or a
        jr z,control_nofire ;не было момента, когда огонь не нажимали
        xor a
        ld (control_firehasbeenreleased),a
        ;ld ix,objlist ;первый объект - наш
        push bc
        call shoot
        pop bc
control_nofire

        ld ix,objlist ;первый объект - наш
        ;если не нажата кнопка движения и мы едем, то остановиться
        rr c
        ld a,c
        cpl
        and #0f
        jr nz,control_nokeysreleased
        ld a,(ix+obj_anim)
        cp ANIM_GO
        jr nz,control_nokeysreleased
        SETANIM ANIM_STOP
control_nokeysreleased

        ld a,c
        rra ;u
        jr c,control_nou
        call goifpossible
        ld (ix+obj_dir),0
control_nou
        rra ;d
        jr c,control_nod
        call goifpossible
        ld (ix+obj_dir),2
control_nod
        rra ;r
        jr c,control_nor
        call goifpossible
        ld (ix+obj_dir),1
control_nor
        rra ;l
        jr c,control_nol
        call goifpossible
        ld (ix+obj_dir),3
control_nol
        
        ret
       
goifpossible
        ld c,a
        ld a,(ix+obj_anim)
        cp ANIM_APPEAR
        jr nz,$+4
        ld a,ANIM_STOP
        cp ANIM_STOP
        ld a,c
        ret nz ;не стоим, так что не можем поехать
        SETANIM ANIM_GO
        ret
        
checkevencoords
;out: nz=не посредине клетки
        ld a,(ix+obj_x)
        and 8*coordsfactor-1
        cp 4*coordsfactor
        ret nz
        ld a,(ix+obj_y)
        and 8*coordsfactor-1
        cp 4*coordsfactor
        ret

shoot
        SETANIM ANIM_SHOOT
        ld c,(ix+obj_dir)
        ld b,0
        ld hl,tankbulletcoords
        add hl,bc
        add hl,bc
        ld a,(hl) ;dx
        ld c,a ;%sxxxxxxx
        rla    ;%xxxxxxx?, CY=s
        sbc a,a;%ssssssss
        ld b,a ;dx
        inc hl
        ld a,(hl) ;dy
        GETXDE_YHL
        ex de,hl ;hl=x
        add hl,bc ;x+dx
        push hl ;x+dx
        push de ;y
        ld e,a
        rla
        sbc a,a
        ld d,a ;dy
        pop hl ;y
        add hl,de ;hl = y+dy
        pop de ;de = x+dx
        ld a,(ix+obj_dir) ;a=dir
        ld bc,params_bullet
curbulletlistend=$+2
        ld ix,bulletlist
        call genobjorbullet
genbullet_terminate
        ld bc,objterminator
        ld (ix+obj_objaddr),c
        ld (ix+(obj_objaddr+1)),b
        ld (ix+(obj_x+1)),TERMINATOR
        ld (curbulletlistend),ix
        ret

genobjorbullet
;de=x
;hl=y
;bc=params (obj(16),energy(8),speed(8))
;a=dir
        ld (ix+obj_dir),a
        PUTXDE_YHL
        SETANIM ANIM_APPEAR
        ld (ix+obj_delaycounter),1
        ld (ix+obj_gundelaycounter),0
        ld a,(bc)
        ld (ix+obj_objaddr),a
        inc bc
        ld a,(bc)
        ld (ix+(obj_objaddr+1)),a
        inc bc
        ld a,(bc)
        ld (ix+obj_energy),a
        inc bc
        ld a,(bc)
        ld (ix+obj_speed),a
        ld bc,objsize
        add ix,bc
        ret

genobj
;de=x
;hl=y
;bc=params (obj(16),energy(8),speed(8))
;a=dir
curobjlistend=$+2
        ld ix,objlist
        call genobjorbullet
genobj_terminate
        ld bc,objterminator
        ld (ix+obj_objaddr),c
        ld (ix+(obj_objaddr+1)),b
        ld (ix+(obj_x+1)),TERMINATOR
        ld (curobjlistend),ix
        ret

animate
        ld ix,objlist-objsize
animate0_prepareregs
        ld a,TERMINATOR
        ld bc,objsize
animate0
        add ix,bc
animate0_afterdel
        cp (ix+(obj_x+1))
        ret z
        dec (ix+obj_animcounter)
        jp nz,animate0
        ;текущая фаза анимации кончилась, ищем следующую
        ld l,(ix+obj_objaddr)
        ld h,(ix+(obj_objaddr+1)) ;hl=адрес описателя объекта (в начале лежит указатель на список анимаций)
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl=указатель на список анимаций
        ld e,(ix+obj_anim) ;номер анимации
        ld d,0
        add hl,de
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;hl=указатель на анимацию
        ld e,(ix+obj_animphase) ;номер фазы анимации
        inc e ;следующая фаза анимации
        ld (animate_pointer),hl
        add hl,de
        add hl,de
        add hl,de
        ld a,(hl) ;время фазы
        or a ;если 0, то это конец анимации
        jr nz,animate_noend
        inc hl
        ld a,(hl) ;режим зацикливания (0=переход на нулевую анимацию, 1=зацикливаемся тут, 2=удалить)
        cp 2
        jr z,animate_delete
        or a
        jr nz,animate_no0
        ld (ix+obj_anim),a ;0-я анимация
animate_no0
        ld e,0
animate_pointer=$+1
        ld hl,0
        add hl,de
        add hl,de
        add hl,de
        ld a,(hl) ;время фазы
animate_noend
        ld (ix+obj_animcounter),a
        ld (ix+obj_animphase),e ;следующая фаза анимации
        jp animate0_prepareregs
        
animate_delete
        push ix
        pop hl
        ld de,objlist
        or a
        sbc hl,de
        jr z,animate_delete_player
        ld hl,curobjlistend
        call delobj ;копируем из ix+objsize в ix
        ld a,TERMINATOR
        ld bc,objsize
        jp animate0_afterdel
animate_delete_player
        call decreaselives
        call rndbottomcoords ;bc=x, de=y
        SETANIM ANIM_APPEAR
        ld (ix+obj_dir),1 ;a=dir
        jp animate0_prepareregs
        
bulletlogic
        ld ix,bulletlist-objsize
        jr logic0
logic
        ld ix,objlist-objsize
logic0
        ld bc,objsize
        add ix,bc
logic0_afterdel
        ld l,(ix+obj_objaddr)
        ld h,(ix+(obj_objaddr+1)) ;hl=адрес описателя объекта (в начале лежит указатель на список анимаций)
        inc hl
        inc hl
        jp (hl) ;hl=адрес обработчика объекта
        
rndbottomcoords
;out: bc=x, de=y
rndbottomcoords_retry
        ld c,fieldwid
        call rnd
        ld c,a
        ld b,0
        ld de,8*coordsfactor*3
        call mulbcde
        ld bc,4*coordsfactor
        add hl,bc ;x
        ex de,hl
        ld hl,#02b0 ;y
        PUTXDE_YHL
        call checkobstacles_tank ;nc=препятствие
        jr nc,rndbottomcoords_retry
        ret

delobj
;hl=адрес указателя на конец списка (на терминатор)
;копируем из ix+objsize в ix
        ld (delobj_curlistend1),hl
        ld (delobj_curlistend2),hl
        ld c,(hl)
        inc hl
        ld b,(hl) ;указатель на конец списка (на терминатор)
        ld hl,objsize
        add hl,bc
        ld b,h
        ld c,l ;указатель на конец списка (после объекта-терминатора)
        ld d,hx
        ld e,lx ;de=ix
        ld a,e
        add a,objsize
        ld l,a
        adc a,d
        sub l
        ld h,a ;hl=ix+objsize
        ld a,c
        sub l
        ld c,a
        ld a,b
        sbc a,h
        ld b,a ;bc=objlistend-hl
        ld a,b
        or c
        ret z ;почему удаляем терминатор после встречи двух пуль??? TODO
        ldir ;копируем все следующие объекты, включая терминатор
delobj_curlistend1=$+1
        ld hl,(curobjlistend)
        ld bc,-objsize
        add hl,bc
delobj_curlistend2=$+1
        ld (curobjlistend),hl
        push ix
        call fillcollisionmap
        pop ix
        ret
        
movetank
        ld a,(ix+obj_anim)
        cp ANIM_GO
        ret nz
moveobj
        GETXDE_YHL
        ld b,(ix+obj_speed)
        ld c,(ix+obj_dir)
        inc c
        dec c
        call z,moveobj_u
        dec c
        call z,moveobj_r
        dec c
        call z,moveobj_d
        dec c
        call z,moveobj_l
        PUTXDE_YHL
        ret
moveobj_u
        dec hl
        djnz $-1
        ret
moveobj_r
        inc de
        djnz $-1
        ret
moveobj_d
        inc hl
        djnz $-1
        ret
moveobj_l
        dec de
        djnz $-1
        ret

objtank
        dw anims_tank
objtank_move
        GETXDE_YHL
        push de
        push hl
        call movetank
        call checkobstacles_tank ;nc=коллизия
        jr nc,objtank_collided
        ld c,tanksize ;размер
        call checkwalls ;nc=стена
        ;TODO как-то воткнуть checkwalls в moveobj, но не в ущерб пулям
objtank_collided
        pop hl
        pop de
        jp c,logic0 ;не стена
        PUTXDE_YHL ;стена - восстановим старые координаты
        jp logic0

objtanke
        dw anims_tanke
        dec (ix+obj_gundelaycounter)
        jr nz,objtanke_nogundelaystop
        inc (ix+obj_gundelaycounter)
        ld a,(ix+obj_anim)
        cp ANIM_PREPARESHOOT
        jr nz,objtanke_noshoot
        push ix
        call shoot
        pop ix
        ld (ix+obj_gundelaycounter),50
        jr objtanke_stop
objtanke_noshoot
objtanke_nogundelaystop
        ld a,(ix+obj_anim)
        cp ANIM_DIE
        jp z,objtanke_nologic
;логика должна срабатывать, когда мы стоим посредине клетки ((x&(8*coordsfactor-1)) == 4*coordsfactor, (y&(8*coordsfactor-1)) == 4*coordsfactor)
        call checkevencoords ;nz=не посредине клетки
        jp nz,objtanke_nologic
;едем энное растояние, потом случайно меняем направление или встаём
        dec (ix+obj_delaycounter)
        jr nz,objtanke_nonewmove
        ld (ix+obj_delaycounter),20
        ld c,5
        call rnd
        cp 4
        jr z,objtanke_stop
        ld (ix+obj_dir),a
        SETANIM ANIM_GO
        jr objtanke_nonewmove
objtanke_stop
        SETANIM ANIM_STOP
objtanke_nonewmove
;если одна из координат близка к нашей (x-(tanksize/2*coordsfactor) > xe >= x+(tanksize/2*coordsfactor)), то встать, задержать и стрелять
        GETXDE_YHL
        push hl ;y
        ld hl,(objlist+obj_x) ;наша координата
        ld bc,-(tankaimsize/2*coordsfactor)
        add hl,bc
        or a
        sbc hl,de ;надо -tanksize*coordsfactor..-1
        ld bc,tankaimsize*coordsfactor
        add hl,bc ;cy=координата близка к нашей
        pop hl ;y
        ex de,hl ;de=y, hl=x
        jr z,$+4
        jr nc,objtanke_noprepareshootx
        ld hl,(objlist+obj_y) ;наша координата
        or a
        sbc hl,de ;y >= ye? тогда d, иначе u
        ld a,2 ;d
        jr nc,$+4 ;y >= xe
        ld a,0 ;u
        ld (ix+obj_dir),a
        jr objtanke_prepareshoot
objtanke_noprepareshootx
        push hl ;x
        ld hl,(objlist+obj_y) ;наша координата
        ld bc,-(tankaimsize/2*coordsfactor)
        add hl,bc
        or a
        sbc hl,de ;надо -tanksize*coordsfactor..-1
        ld bc,tankaimsize*coordsfactor
        add hl,bc ;cy=координата близка к нашей
        pop de ;x
        jr z,$+4
        jr nc,objtanke_noprepareshoot
        ld hl,(objlist+obj_x) ;наша координата
        or a
        sbc hl,de ;x >= xe? тогда r, иначе l
        ld a,1 ;r
        jr nc,$+4 ;x >= xe
        ld a,3 ;l
        ld (ix+obj_dir),a
objtanke_prepareshoot
        SETANIM ANIM_PREPARESHOOT
        ;ld (ix+obj_delaycounter),1
objtanke_noprepareshoot
objtanke_nologic
        jp objtank_move

objbullet
        dw 0
        call moveobj
        ld c,0 ;размер
        call checkwalls ;nc=стена
        jp c,logic0 ;не стена
        ld hl,curbulletlistend
        call delobj ;копируем из ix+objsize в ix
        ld bc,-objsize
        add ix,bc
        jp logic0
        
bulletcollision
        ld ix,bulletlist-objsize
        ld ly,-(128-1)
bulletcollision0
        dec ly
        ld bc,objsize
        add ix,bc
bulletcollision0_afterdel
        ld a,(ix+(obj_x+1))
        cp TERMINATOR
        ret z
        GETXDE_YHL
        call calctilemapaddr_de_hl
        ld a,(hl)
        cp maxemptytile+1
        jr nc,bulletcollision_collided
        call calccollisionmapaddr
        ld a,(hl)
        add a,ly ;номер текущей пули ;CY=1 при совпадении
        call nz,checkbulletcollision
        jp c,bulletcollision0 ;не коллизия
bulletcollision_delete
        ld hl,curbulletlistend
        call delobj ;копируем из ix+objsize в ix
        jp bulletcollision0_afterdel
bulletcollision_collided
        ;ld c,l
        GETXDE_YHL
        push hl
        ex de,hl
        ld a,(ix+obj_dir)
        rra ;nc=vertical direction
        ccf
        call divmul3 ;hl=x клетки карты
        ex (sp),hl ;сохранили x клетки карты ;hl=y
        ld a,(ix+obj_dir)
        rra ;nc=vertical direction
        call divmul3 ;hl=y клетки карты
        pop bc ;x клетки карты
        ld b,l ;y клетки карты
        ld a,c
        call calctilemapaddr_a_l
        ld a,(ix+obj_dir)
        dec a
        jr z,objbullet_collided_ver ;r
        dec a
        jr z,objbullet_collided_hor ;d
        dec a
        jr z,objbullet_collided_ver ;l
                                    ;u
objbullet_collided_hor
        call degradetile
        inc c
        inc hl
        call degradetile
        inc c
        inc hl
        call degradetile
        jp bulletcollision_delete
objbullet_collided_ver
        ld de,tilemaplinesize
        call degradetile
        inc b
        add hl,de
        call degradetile
        inc b
        add hl,de
        call degradetile
        jp bulletcollision_delete
        
divmul3
;если CY=1, то делим до знакомест и округляем до 3
;иначе просто делим до знакомест
        ld de,8*coordsfactor
        jp nc,divhlde ;hl=x(y) клетки карты (без округления)
        ld de,8*coordsfactor*3
        call divhlde ;hl=x(y) клетки поля
        ld c,l
        ld b,h
        add hl,hl
        add hl,bc
        ret ;hl=x(y) клетки карты

degradetile
;bc=yx клетки карты
;hl=tilemap+
        ;push bc
        push de
        ;push hl
        call degradetile_changetile
        call calcscrbufaddr ;de=scrbuf+
        call restoretile
        ;pop hl
        pop de
        ;pop bc
        ret
degradetile_changetile
        ld a,(hl)
        cp tilem
        ret z
        cp tileb
        ld (hl),tile0
        ret z
        cp tilec
        ld (hl),tileb
        ret z
        ld (hl),tile0
        ret
        
objterminator
        dw 0
        ret

decreaselives
lives=$+1
        ld a,0
        dec a
        ld (lives),a
        push af
        call prlives
        pop af
        ret nz
        
gameover     
fieldEx=32
fieldEy=24
centr=(fieldEx/2)-(10/2)+(256*fieldEy/2)
;bc=yx
;a=фон
;d=y координата левого верхнего угла
;е=х координата левого верхнего угла
;#5800+xcoordredbox+(32*ycoordredbox)
        ld c,12
        ld b,3
        ld de,centr-#0101
        ld a,#57        
        ld (curattr),a
        call attrbox
        ld hl,endtext
        ld bc,centr
        call prtext
gameoverloop
        YIELD
        GET_KEY
        cp csSpace
        jr nz,gameoverloop
quit
        QUIT

endtext
        db "Game over!",0

font
        incbin "zx.fnt"
        
        include "collision.asm"
        include "tankgfx.asm"
        include "tankdata.asm"
        include "math.asm"
        include "input.asm"
end

reobjlist
        ds 2*(maxobjects+1)
rebulletlist
        ds 2*(maxbullets+1)

objlist
        ds objsize*(maxobjects+1)
objlistend
        
bulletlist
        ds objsize*(maxbullets+1)
bulletlistend


	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "tank.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
