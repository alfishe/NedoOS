;0 - пусто
;1..127 - объект
;128..254 - пуля
;[255 - препятствие]
fillcollisionmap
        ;ld hl,collisionmap
        ;ld de,collisionmap+1
        ;ld bc,collisionmapsize-1
        ;ld (hl),0
        ;ldir
        ld (fillcollisionmapsp),sp
        ld sp,collisionmap+collisionmapsize
        ld de,0
        ld b,collisionmaphgt
fillcollisionmap_clear0
        dup collisionmaplinesize/2
        push de
        edup
        djnz fillcollisionmap_clear0
fillcollisionmapsp=$+1
        ld sp,0
;помечаем пули
        ld ix,bulletlist
        ld c,128
fillcollisionmap_bullet0
        ld a,(ix+(obj_x+1))
        cp TERMINATOR
        jr z,fillcollisionmap_bulletq
        call calccollisionmapaddr
        ld (hl),c
        ld de,objsize
        add ix,de
        inc c
        jp fillcollisionmap_bullet0
fillcollisionmap_bulletq
;помечаем объекты
        ld ix,objlist
        ld c,1
fillcollisionmap_obj0
        ld a,(ix+(obj_x+1))
        cp TERMINATOR
        ret z
        call calccollisionmapaddr
        ld de,collisionmaplinesize-2
        ld (hl),c
        inc hl
        ld (hl),c
        inc hl
        ld (hl),c
        add hl,de
        ld (hl),c
        inc hl
        ld (hl),c
        inc hl
        ld (hl),c
        add hl,de
        ld (hl),c
        inc hl
        ld (hl),c
        inc hl
        ld (hl),c
        ld de,objsize
        add ix,de
        inc c
        jp fillcollisionmap_obj0
        
calccollisionmapaddr
;bc,e не портим
        GETXDE_YHL
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        ld a,l
        rr h
        rra
        rr h
        rra
        rra
        rra
        rra
        and 0x1f
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;fillcollisionmaplinesize=32
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        ld a,e
        rr d
        rra
        rr d
        rra
        rra
        rra
        rra
        and 0x1f
        add a,l
        ld l,a
        ld a,collisionmap/256
        add a,h
        ld h,a
        ret

calctilemapaddr_de_hl
;de=x
;hl=y
;bc,e не портим
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        ld a,l
        rr h
        rra
        rr h
        rra
        rra
        rra
        rra
        and 0x1f
        ld l,a
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        ld a,e
        rr d
        rra
        rr d
        rra
        rra
        rra
        rra
        and 0x1f
calctilemapaddr_a_l
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;fillcollisionmaplinesize=32
        add a,l
        ld l,a
        ld a,tilemap/256
        add a,h
        ld h,a
        ret

checkbulletcollision
;hl=collisionmapaddr
;out: nc=коллизия
        ld a,(hl)
        or a ;пусто
        ;scf
        ;jr z,$;ret z ;CY=1
        jp m,checkbulletcollision_bullet
;1..127 = объект
        ld c,a
        ld b,0
        ld de,objsize
        call mulbcde
        
        if 1==1
        ld bc,objlist-objsize+obj_energy
        add hl,bc
        
        else ;проверка попадания в яблочко
        ;надо проверить x > xbullet > x+tanksize
        ld bc,objlist-objsize+obj_x
        add hl,bc
        ld a,(ix+obj_x) ;xbullet
        sub (hl) ;x
        ld c,a
        inc hl
        ld a,(ix+(obj_x+1)) ;xbullet(HSB)
        sbc a,(hl) ;x(HSB)
        ld b,a ;bc = xbullet-x
        scf
        ret nz ;bc >= 256 (точно мимо)
        ld a,c
        or a
        scf
        ret z
        cp tankdamagesize*coordsfactor
        ccf
        ret c ;bc >= tanksize
        inc hl
        ld a,(ix+obj_y) ;ybullet
        sub (hl) ;y
        ld c,a
        inc hl
        ld a,(ix+(obj_y+1)) ;ybullet(HSB)
        sbc a,(hl) ;y(HSB)
        ld b,a ;bc = ybullet-y
        scf
        ret nz ;bc >= 256 (точно мимо)
        ld a,c
        or a
        scf
        ret z
        cp tankdamagesize*coordsfactor
        ccf
        ret c ;bc >= tanksize
        ld bc,obj_energy-(obj_y+1)
        add hl,bc
        endif ;проверка попадания в яблочко
        
        ld a,(hl)
        sub (ix+obj_energy) ;энергия пули
        ld (hl),a
        ret nc ;у объекта ещё осталась энергия
        push ix
        ex de,hl
        ld ix,-obj_energy
        add ix,de
        SETANIM ANIM_DIE
        pop ix
        or a
        ret ;nc
checkbulletcollision_bullet
;128..255 = пуля (в collisionmap всегда видна более поздняя пуля, т.е. её можно смело удалять)
        sub 128
        ;push af ;номер найденной пули
        ;push ix
        ;pop hl
        ;ld bc,-bulletlist&0xffff
        ;add hl,bc
        ;ld de,objsize
        ;call divhlde ;hl=номер нашей пули
        ;pop af ;номер найденной пули
        ;cp l ;номер нашей пули
        ;scf
        ;ret z ;CY=1 ;пуля увидела сама себя
        ld c,a
        ld b,0
        ld de,objsize
        call mulbcde
        ex de,hl
        push ix
        ld ix,bulletlist
        add ix,de
        ld hl,curbulletlistend
        call delobj ;копируем из ix+objsize в ix
        pop ix
        or a
        ret ;nc
        
checkwalls
;bc=размер
;out: nc=стена
_=4 ;половина клеточки
        ld h,(ix+(obj_y+1))
        ld a,(ix+obj_y) ;y
        srl h
        rra
        srl h
        rra
        cp _&0xff
        ccf
        ret nc ;верхняя стена
;вычесть (bottomwally/coordsfactor-4)-размер, смотрим <=
        add a,c ;размер
_=(bottomwally/coordsfactor-4)+1
        cp _&0xff
        ret nc ;нижняя стена
_=4 ;половина клеточки
        ld d,(ix+(obj_x+1))
        ld a,(ix+obj_x) ;x
        srl d
        rra
        srl d
        rra
        cp _&0xff
        ccf
        ret nc ;левая стена
;вычесть (rightwallx/coordsfactor-4)-размер, смотрим <=
        add a,c ;размер
_=(rightwallx/coordsfactor-4)+1
        cp _&0xff
        ret ;nc=правая стена
        
checkobstacles_tank
;nc=препятствие
        GETXDE_YHL
        ld bc,-4*coordsfactor
        ex de,hl
        add hl,bc
        ex de,hl
        add hl,bc
        ld a,l
        and 8*coordsfactor-1
        ld b,3 ;число проверяемых строк
        jr z,$+3
        inc b ;число проверяемых строк (стоим неровно по y)
        call calctilemapaddr_de_hl ;bc,e не портим
        ld a,e
        and 8*coordsfactor-1
        jr nz,checkobstacles_tank_lines4 ;стоим неровно по x
        ld de,tilemaplinesize-2
checkobstacles_tank_lines30
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        inc hl
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        inc hl
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        add hl,de
        djnz checkobstacles_tank_lines30
        scf
        ret ;CY=1 (нет препятствия)
checkobstacles_tank_lines4
        ld de,tilemaplinesize-3
checkobstacles_tank_lines40
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        inc hl
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        inc hl
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        inc hl
        ld a,(hl)
        cp maxemptytile+1
        ret nc
        add hl,de
        djnz checkobstacles_tank_lines40
        scf
        ret ;CY=1 (нет препятствия)
