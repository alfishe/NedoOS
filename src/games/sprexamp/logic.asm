objectslogic
        ld a,(pgmetatilemap)
        SETPG32KHIGH

        ld ix,objects
objectslogic0
        ld a,(ix+obj.y16+1)
        cp DELETEDYHIGH
        jp z,objectslogic0_skip

        ld l,(ix+obj.animaddr16+0)
        ld h,(ix+obj.animaddr16+1)
        ld e,(hl)
        inc hl
        ld d,(hl) ;de = phase
        inc hl
        dec (ix+obj.animtime)
        jr nz,logic_nonextphase
        ld a,(hl) ;new animtime
        inc hl
        ld (ix+obj.animtime),a
        ld e,(hl)
        inc hl
        ld d,(hl) ;de = phase
        ld a,d
        cp 0xc0
        jr nc,logic_nocycleanim
        ex de,hl 
        ;ld e,(hl)
        inc hl
        ;ld d,(hl) ;de = phase (>=0xc000) or new animaddr (<0xc000)
logic_nocycleanim
        dec hl
        ld (ix+obj.animaddr16+0),l
        ld (ix+obj.animaddr16+1),h
logic_nonextphase

        ld l,(ix+obj.xspeed16+0)
        ld h,(ix+obj.xspeed16+1)
        ld e,(ix+obj.x16+0)
        ld d,(ix+obj.x16+1)
        add hl,de
        ld (ix+obj.x16+0),l
        ld (ix+obj.x16+1),h
        ld l,(ix+obj.yspeed16+0)
        ld h,(ix+obj.yspeed16+1)
        inc hl
        inc hl
        inc hl
        inc hl ;gravity
         ld a,h
         rla
         jr c,gravityok
         ld de,8*YSUBPIX8
         or a
         sbc hl,de
         add hl,de
         jr c,gravityok
         ex de,hl
gravityok
        ld (ix+obj.yspeed16+0),l
        ld (ix+obj.yspeed16+1),h
        ex de,hl ;de=yspeed
        
        ld l,(ix+obj.y16+0) ;*YSUBPIX8
        ld h,(ix+obj.y16+1)
        bit 7,(ix+obj.flags)
        jr nz,logic_nocheckfloor
;check floor
        push de ;yspeed
        push hl ;y
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,32*YSUBPIX8
         add hl,de ;координата прямо под ногами
        call gettile_bycoords
        pop hl ;yspeed
        pop bc ;y
          ;ld c,(ix+obj.y16+0)
          ;ld b,(ix+obj.y16+1)
          add hl,bc
        cp FIRSTSOLIDTILE;32
         res 0,(ix+obj.flags) ;not on floor
        jr c,nofloor
         cp FIRSTOBJTILE
        jr nc,nofloor
         set 0,(ix+obj.flags) ;not on floor
;выравнивание по y на 16(пикс)*YSUBPIX8
        ld a,l
        and 16*YSUBPIX8;128
        ld l,a
        ld (ix+obj.yspeed16+0),0
        ld (ix+obj.yspeed16+1),0
        jr floorok
nofloor
        push hl ;y16

        ld l,(ix+obj.y16+0) ;*YSUBPIX8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ;ld de,0
         ;add hl,de ;координата прямо в голове
        call gettile_bycoords
        cp FIRSTBETONTILE;64
        pop hl ;y16
        jr c,noceiling
;выравнивание по y на 16(пикс)*8 вверх
        ld a,l
        or 16*YSUBPIX8-1;127
        ld l,a
        inc hl
        ld (ix+obj.yspeed16+0),0
        ld (ix+obj.yspeed16+1),0        
noceiling
floorok
        jr logic_checkfloorq
logic_nocheckfloor
;hl=y
;de=yspeed
        add hl,de
        ld a,h
        cp METATILEMAPHGT*16*YSUBPIX8/256
        jr c,logic_nofalltohell
        ld h,DELETEDYHIGH
logic_nofalltohell
logic_checkfloorq
        ld (ix+obj.y16+0),l
        ld (ix+obj.y16+1),h
objectslogic0_skip
        ld bc,OBJSIZE
        add ix,bc
        bit 7,(ix+obj.y16+1) ;yhigh
        jp z,objectslogic0
        ret

bulletslogic
        ld a,(pgmetatilemap)
        SETPG32KHIGH

        ld ix,bullets
bulletslogic0
        bit 7,(ix+obj.y16+1) ;yhigh
        ret nz
        ;jr $
;если health=1, то это мёртвая пуля, этот слот можно использовать
        dec (ix+obj.health)
        jr nz,bulletslogic_noremove
        ld (ix+obj.y16+1),DELETEDYHIGH;0x7f ;yhigh
        inc (ix+obj.health)
        jp bulletslogic_skip        
bulletslogic_noremove
        ld l,(ix+obj.xspeed16+0)
        ld h,(ix+obj.xspeed16+1)
        ld e,(ix+obj.x16+0)
        ld d,(ix+obj.x16+1)
        add hl,de
        ld (ix+obj.x16+0),l
        ld (ix+obj.x16+1),h

;TODO каждый второй фрейм
ENEMYHGT=32*YSUBPIX8
ENEMYWID=16*XSUBPIX8 ;(in double pixels)
BULLETWID=8*XSUBPIX8 ;(in double pixels)
;TODO учесть размер врага
;попали, если enemyy<=bullety<=enemyy+ENEMYHGT и enemyx-BULLETWID<=bulletx<=enemyx+ENEMYWID
         ;<--->
;   |------|

;check enemy
        ld e,(ix+obj.y16+0) ;*YSUBPIX8
        ld d,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
        ld a,d
        cp DELETEDYHIGH
        jp z,bulletslogic_checkenemy0q
;de=bullety
;bc=bulletx
        exx
        ld bc,OBJSIZE
        exx
        ld iy,objects+obj.sz
bulletslogic_checkenemy0
        bit 7,(iy+obj.y16+1) ;yhigh
        jr nz,bulletslogic_checkenemy0q
;enemyx-BULLETWID<=bulletx<=enemyx+ENEMYWID
;-BULLETWID<=bulletx-enemyx<=ENEMYWID
;-(ENEMYWID+BULLETWID)<=enemyx-bulletx-BULLETWID<=0
        ld l,(iy+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld h,(iy+obj.x16+1) ;enemyx
        ;ld a,l
        ;sub BULLETWID
        ;ld l,a
        ;jr nc,$+3
        ;dec h
        or a
        sbc hl,bc ;bc=bulletx
        jr nc,bulletslogic_checkenemy_skip
        ld a,l
        add a,ENEMYWID;+BULLETWID
        ld l,a
        jr nc,bulletslogic_checkenemy_skip
        inc h
        jr nz,bulletslogic_checkenemy_skip
bulletslogic_checkenemy_xok
;enemyy<=bullety<=enemyy+ENEMYHGT?
;0<=bullety-enemyy<=ENEMYHGT?
;-ENEMYHGT<=enemyy-bullety<=0?
        ld l,(iy+obj.y16+0) ;*YSUBPIX8
        ld h,(iy+obj.y16+1) ;enemyy
        or a
        sbc hl,de ;de=bullety
        jr nc,bulletslogic_checkenemy_skip
        ld a,l
        add a,ENEMYHGT-1
        ld l,a
        jr nc,bulletslogic_checkenemy_skip
        inc h
        jr nz,bulletslogic_checkenemy_skip
bulletslogic_checkenemy_yok
;попали!!!
        ld (ix+obj.y16+1),DELETEDYHIGH ;уничтожаем пулю
;отнимаем энергию
        ld a,(iy+obj.health)
        sub 10
        ld (iy+obj.health),a
         ld a,9
        jr nc,bulletslogic_enemyfound_notdead
        set 7,(iy+obj.flags) ;dead
        ld (iy+obj.yspeed16+0),-8*YSUBPIX8
        ld (iy+obj.yspeed16+1),-1
        ld (iy+obj.xspeed16+0),2*XSUBPIX8
        ld (iy+obj.xspeed16+1),0
         ld a,10 ;3 перезвяк, 5 диньк, 7 тормоз, 9 миниприз, 10 приз, 11 бум
bulletslogic_enemyfound_notdead
        push bc
        push de
         call sfxplay
        pop de
        pop bc
bulletslogic_checkenemy_skip
        exx
        add iy,bc
        exx
        jr bulletslogic_checkenemy0
bulletslogic_checkenemy0q
;~check enemy
        
;check wall
        ld l,(ix+obj.y16+0) ;*YSUBPIX8
        ld h,(ix+obj.y16+1)
          ld c,(ix+obj.yspeed16+0)
          ld b,(ix+obj.yspeed16+1)
          add hl,bc
        push hl
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld a,c
         ;add a,2*XSUBPIX8
         sub 6*XSUBPIX8
         ld c,a
         ;adc a,b
         ;sub c
         ld a,b
         sbc a,0
         ld b,a
        call gettile_bycoords
        ;inc l
        ;ld a,(hl)
        pop hl
        sub FIRSTBETONTILE;32
        cp FIRSTOBJTILE-FIRSTBETONTILE
        jr nc,bulletslogic_nocrash
        ld h,DELETEDYHIGH ;удалить
        ld (ix+obj.xspeed16+0),0
        ld (ix+obj.xspeed16+1),0
        ld (ix+obj.yspeed16+0),0
        ld (ix+obj.yspeed16+1),0
bulletslogic_nocrash
        ld (ix+obj.y16+0),l
        ld (ix+obj.y16+1),h
bulletslogic_skip
        ld bc,OBJSIZE
        add ix,bc
        jp bulletslogic0

fire
genbullet
;сначала найдём пустые места в списке пуль (т.е. где yhigh==0x7f)
;если таких нет, то добавляем в конец
        ld iy,bullets
genbullet_findempty0
        bit 7,(iy+obj.y16+1) ;yhigh
        jr nz,genbullet_findempty0q
        ld a,(iy+obj.y16+1) ;yhigh
        cp DELETEDYHIGH
        jr z,genbullet_struct
        ld bc,OBJSIZE
        add iy,bc
        jr genbullet_findempty0
genbullet_findempty0q
        ;jr $
curbulletlistend=$+2
        ld iy,bullets
        push iy
        ld de,-bulletlistend
        add iy,de
        pop iy
        ret c ;no room

        call genbullet_struct
        ld bc,OBJSIZE
        add iy,bc
genbullet_terminate
        ld (curbulletlistend),iy
        ld (iy+obj.y16+1),-1
        ret

BULLETSPEED=MAXSPEED ;(in double pixels)
genbullet_struct
         ld a,1 ;3 перезвяк, 5 диньк, 7 тормоз, 9 миниприз, 10 приз, 11 бум
         call sfxplay
         
         ld a,(lastdir) ;0=right
         or a
         ld de,BULLETSPEED;4
         jr z,$+5
         ld de,-BULLETSPEED;4
         ld (iy+obj.xspeed16),e
         ld (iy+obj.xspeed16+1),d

         ld de,bulletanim_right
         jr z,$+5
         ld de,bulletanim_left
        ld (iy+obj.animaddr16),e
        ld (iy+obj.animaddr16+1),d
        ld (iy+obj.animtime),1
        ld (iy+obj.health),100
        ld a,(ix+obj.x16)
        add a,4*XSUBPIX8
        ld (iy+obj.x16),a
        ld a,(ix+obj.x16+1)
        adc a,0
        ld (iy+obj.x16+1),a
        ld a,(ix+obj.y16)
        add a,16*YSUBPIX8
        ld (iy+obj.y16),a
        ld a,(ix+obj.y16+1)
        adc a,0
        ld (iy+obj.y16+1),a
        xor a
        ld (iy+obj.yspeed16),a
        ld (iy+obj.yspeed16+1),a
        ld (iy+obj.flags),a
        ret
        

logic
        call objectslogic
        call bulletslogic
        call herocontrol
        ret
        
;hero control 
herocontrol
joystate=$+1
oldjoystate=$+2
        ld bc,0
        ld a,c
        ld (oldjoystate),a
        xor b
        ld b,a
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
        bit 6,c
        push bc
        call nz,kick
        pop bc
        bit 5,c
        jr z,nofire
        bit 5,b
        jr z,nofire
        push bc
        ld ix,objects
        call fire
        pop bc
nofire

        ld ix,objects
        ld l,(ix+obj.xspeed16+0)
        ld h,(ix+obj.xspeed16+1)
        bit 1,c
        jr z,noleft
        ld a,h
        or a
        jp m,nostartrunleft
        ld a,1
        ld (lastdir),a
         ld de,heroanim_runleft
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
nostartrunleft
        ld de,-1
        add hl,de
        ld de,-MAXSPEED
        or a
        sbc hl,de
        ld a,h
        add hl,de
        or a
        jr z,leftq
        ex de,hl
        jr leftq
noleft
        bit 0,c
        jr z,noright
        ld a,h
        or a
        jp m,startrunright
        or l
        jr nz,nostartrunright
startrunright
        xor a
        ld (lastdir),a
         ld de,heroanim_runright
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
nostartrunright
        ld de,1
        add hl,de
        ld de,MAXSPEED
        or a
        sbc hl,de
        ld a,h
        add hl,de
        or a
        jr nz,leftq
        ex de,hl
        jr leftq
noright
         bit 0,(ix+obj.flags) ;on floor?
         jr z,leftq ;не тормозим на лету
        ld a,h
        or l
        ld e,a
         bit 7,h
         jr z,$+3
         inc hl
         sra h
         rr l
         ld a,h
         or l
         jr nz,leftq
         ld a,e
         or a
         jr z,leftq ;уже стояли
lastdir=$+1
         ld a,0 ;/1
         or a
         ld de,heroanim_standright
         jr z,$+5
         ld de,heroanim_standleft
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
leftq
        ld (ix+obj.xspeed16+0),l
        ld (ix+obj.xspeed16+1),h
;проверить, что не въехали в стену в текущем направлении и отскочить
       push bc
        bit 7,h
        jp nz,checkleftwall
        ld l,(ix+obj.y16+0) ;*YSUBPIX8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,16*YSUBPIX8
         add hl,de ;координата на уровне пояса
        call gettile_bycoords
        dec l
        ld a,(hl) ;правее центра
        cp FIRSTBETONTILE;64
        jp c,checkleftwallq ;not beton
         cp FIRSTOBJTILE
         jr nc,checkwall_obj
;врезались справа, выравниваем x = (x&0xf0) - 1
         ld de,heroanim_standright
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
         ld (ix+obj.xspeed16+0),0
         ld (ix+obj.xspeed16+1),0
        ld l,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld h,(ix+obj.x16+1)
        ld a,l
        and -8*XSUBPIX8
        ld l,a
        dec hl
        ld (ix+obj.x16+0),l ;*XSUBPIX8 (in double pixels)
        ld (ix+obj.x16+1),h        
        jp checkleftwallq
checkwall_obj
        ld (hl),0
        ex de,hl
        push de
         ld a,3 ;3 перезвяк, 5 диньк, 7 тормоз, 9 миниприз, 10 приз, 11 бум
         call sfxplay
        pop de
        
        ;call uvscroll_filltilemap
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
;de=тайл, который мы только что изменили
;мы должны пропустить по y ровно столько строчек, чтобы hl пересёк тот тайл, который мы только что изменили

        ld a,d
        sub h ;a=y
        cp TILEMAPHGT/2
        jr nc,getobjnofill
        
        ;ld a,3 ;y по умолчанию
        
        ;push af
        ;add a,h
        ;ld h,a ;hl=metatilemap+
        ;pop af
        ld h,d
        push af ;y
        
        ex de,hl
        ld hl,TILEMAP
        ld bc,TILEMAPWID*2
        or a
        jr z,getobjfill0q
getobjfill0
        add hl,bc
        dec a
        jr nz,getobjfill0
getobjfill0q
        ex de,hl
        call uvscroll_filltilemap_line
        
        ;call uvscroll_showtilemap
        call uvscroll_showtilemap_counthlde
        pop af ;y
        or a
        jr z,getobjshow0q
        ld b,a
getobjshow0
        push bc
        ld bc,16*(UVSCROLL_WID/512)
        add hl,bc ;y*(UVSCROLL_WID/512) ;allscroll+...
        ex de,hl
        ld bc,TILEMAPWID*2
        add hl,bc ;tilemap+...
        ex de,hl
        pop bc
        djnz getobjshow0
getobjshow0q
        ld b,1
        call uvscroll_showtilemap_b
getobjnofill
        jr checkleftwallq
checkleftwall
        ld l,(ix+obj.y16+0) ;*YSUBPIX8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,16*YSUBPIX8
         add hl,de ;координата на уровне пояса
        call gettile_bycoords
        inc l
        ld a,(hl) ;левее центра
        cp FIRSTBETONTILE;64
        jr c,checkleftwallq ;not beton
         cp FIRSTOBJTILE
         jr nc,checkwall_obj
;врезались слева, выравниваем x = (x+15)&0xf0
         ld de,heroanim_standleft
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
         ld (ix+obj.xspeed16+0),0
         ld (ix+obj.xspeed16+1),0
        ld l,(ix+obj.x16+0) ;*XSUBPIX8 (in double pixels)
        ld h,(ix+obj.x16+1)
        ld bc,8*XSUBPIX8-1
        add hl,bc
        ld a,l
        and -8*XSUBPIX8
        ld l,a
        ld (ix+obj.x16+0),l ;*XSUBPIX8 (in double pixels)
        ld (ix+obj.x16+1),h

checkleftwallq
       pop bc

        ld l,(ix+obj.yspeed16+0)
        ld h,(ix+obj.yspeed16+1)
        bit 7,c
        jr z,nojump
        bit 7,b
        jr z,nojump ;не изменилась кнопка
        
;check floor
        bit 0,(ix+obj.flags) ;on floor
        jr z,nojump

        ld hl,-60
        ld (ix+obj.yspeed16+0),l
        ld (ix+obj.yspeed16+1),h
        ld e,(ix+obj.y16+0)
        ld d,(ix+obj.y16+1)
        add hl,de
        ld (ix+obj.y16+0),l
        ld (ix+obj.y16+1),h
        
        
nojump

        ret

KICKDIST_X=8*XSUBPIX8
KICKDIST_Y=32*YSUBPIX8
kick
;герой толкает ближайшего врага
        ld ix,objects
        ld l,(ix+obj.x16+0)
        ld h,(ix+obj.x16+1)
        ld e,(ix+obj.y16+0)
        ld d,(ix+obj.y16+1)
        
        ld ix,objects+OBJSIZE
kick0
        bit 7,(ix+obj.y16+1) ;yhigh
        ret nz
        push de
        push hl
        ld c,(ix+obj.x16+0)
        ld b,(ix+obj.x16+1)
        or a
        sbc hl,bc
        ld bc,KICKDIST_X
        add hl,bc
        ld bc,KICKDIST_X*2
        or a
        sbc hl,bc
        jr nc,kick_xskip
        ex de,hl
        ld c,(ix+obj.y16+0)
        ld b,(ix+obj.y16+1)
        or a
        sbc hl,bc
        ld bc,KICKDIST_Y
        add hl,bc
        ld bc,KICKDIST_Y*2
        or a
        sbc hl,bc
        jr nc,kick_xskip
         ld a,11 ;3 перезвяк, 5 диньк, 7 тормоз, 9 миниприз, 10 приз, 11 бум
         call sfxplay
        pop hl
        pop de
        ld (ix+obj.yspeed16+0),-80
        ld (ix+obj.yspeed16+1),-1
        ld (ix+obj.xspeed16+0),8
        ld (ix+obj.xspeed16+1),0
        ret
kick_xskip
        pop hl
        pop de

        ld bc,OBJSIZE
        add ix,bc
        jp kick0

gettile_bycoords
        dup 3
        srl h
        rr l
        edup
        dup 4
        add hl,hl
        edup
        dup 3
        srl b
        rr c
        edup
        dup 3
        srl b
        rr c
        edup
        ld a,c
         sub 3
        cpl
        ld l,a
        ld a,h
         sub 3 ;проверять будем тайл в ногах, а не в голове
        cpl
        ld h,a
        ld a,(hl) ;tile в ногах
        ret
