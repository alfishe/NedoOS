        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

STACK=0x4000
MAXVERTICES=256
MAXEDGES=512;256
scrbase=0x8000

scrwid=320
scrhgt=200

COLORS_UNCROSSED=%11001001
COLORS_CROSSED=%11010010

nofocuskey=0xff

        org PROGSTART
begin
        ld sp,STACK

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        call cls

        ld de,pal
        OS_SETPAL

        ld a,r
        ld (rndseed1),a
        OS_GETTIMER ;hlde=timer
        ld (rndseed2),de
         ld (oldupdtimer),de

	ld de,filename
	OS_OPENHANDLE
	;jr $
	;ld a,-1
	or a
	jr nz,noloadini
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	jr loadiniq
noloadini
        ;ld a,8
	xor a
        ld (level),a
        call countverticesneeded
        ;jr $
        call genmesh
loadiniq
         call cls
        call redraw
        
        jr mouseloop_go
mouseloop
;1. всё выводим
;2. ждём событие
;[3. всё стираем]
;4. обрабатываем событие (без перерисовки)
;5. всё стираем

        ld a,(clickstate)
        or a
        jr z,mouseloop_nomove
        call   drawcurvertex
        ;call   drawconnectedvertices
        call   drawcuredges

        ;call ahl_coords
        call movecurvertex

        call drawcuredges
        ;call drawconnectedvertices
        call drawcurvertex
        
        call ahl_coords
        cp 8
        jr nc,$+2+2+3
         ld a,1
         ld (invalidatetime),a
        
mouseloop_nomove

         call clsifneeded ;TODO убрать?
         call redrawifneeded ;TODO убрать?
         
        ld a,(key)
        cp nofocuskey
        call nz,prlevelifneeded

mouseloop_go
;сейчас всё выведено, кроме стрелки
        ld a,(key)
        cp nofocuskey
        jr z,mouseloop_noprarr
        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr8c
mouseloop_noprarr
        ;call waitsomething ;в это время стрелка видна
mainloop_nothing0
        call updatetime
;в это время стрелка видна
        YIELD ;halt
        call control
        jr nz,mainloop_something
         ld a,(invalidatetime)
         or a
        jr z,mainloop_nothing0
mainloop_something
;что-то изменилось
        
        ld a,(key)
        cp nofocuskey
        jr z,mouseloop_norearr
        ld a,(oldarry)
        ld hl,(oldarrx)
        call shapes_rearr
mouseloop_norearr
;сейчас всё выведено, кроме стрелки

key=$+1
        ld a,0
        cp key_esc
        call z,quitifnoclickstate
        cp key_redraw
        push af
        call z,cls
        pop af
        call z,redraw

        ;call control_keys
clickstate=$+1
        ld a,0
        or a
        jr nz,mouseloop_wasclicked
        ld a,(mousebuttons)
        cpl
        and 7
        call nz,mouse_fire
        jp mouseloop
mouseloop_wasclicked
        ld a,(mousebuttons)
        cpl
        and 7
        call z,mouse_unfire
        jp mouseloop


mouse_unfire
        ld a,1
        ld (doredraw),a
        xor a
        ld (clickstate),a

;обновить счётчик crossededges конкретно по рёбрам, которые пересекались в начале и в конце движения
;для этого для старой позиции вершины для каждого из связанных рёбер декрементируем все пересечения (у него и у пересечённого)
;а для новой позиции вершины для каждого из связанных рёбер инкрементируем все пересечения (у него и у пересечённого)

;для новой позиции вершины для каждого из связанных рёбер инкрементируем все пересечения (у него и у пересечённого)
        ld hl,inccrossedandself
        call inccrossededges
;или просто посчитаем каждый с каждым
        ;call countcrossededges
        
;после победы уже не проверяем победу
        ld a,(nextlevelon)
        or a
        ret nz

;check if untangled
        ;ld hl,(ncrossededges)
        ld hl,edges
        ld de,0 ;count*2
        ld bc,(nedges)
sumcrossededges0
        inc hl
        inc hl
        ld a,(hl) ;crossed
        inc hl
        add a,e
        ld e,a
        adc a,d
        sub e
        ld d,a
        dec bc
        ld a,b
        or c
        jr nz,sumcrossededges0
;de=2*ncrossededges
        ld a,d
        or e
        jr z,levelcomplete
        
        ret

levelcomplete
        ld a,' '
        ld (nextlevelon),a
        ;ld a,1
        ld (invalidatetime),a
        ret
        
mouse_fire_nextlevel
        call ahl_coords
        cp 8
        jr nc,mouse_fire_nonextlevel
        ld bc,-(8*(nextlevelon+1-tlevel))
        ;or a
        ;sbc hl,bc
        add hl,bc
        ld bc,8*10 ;"NEXT LEVEL"
        or a
        sbc hl,bc
        jr nc,mouse_fire_nonextlevel
;levelcomplete_go
        xor a
        ld (nextlevelon),a
        inc a;ld a,1
        ld (invalidatetime),a
        ;ld a,1
        ld (docls),a
        ld (doredraw),a
        ld hl,level
        inc (hl)
        call countverticesneeded
        jp genmesh

mouse_fire
        ld a,(nextlevelon)
        or a
        jr nz,mouse_fire_nextlevel
mouse_fire_nonextlevel
        call ahl_coords
        call findvertex
        ret c ;not found
        ld (curvertex),a
        ld a,1
        ld (clickstate),a
;для старой позиции вершины для каждого из связанных рёбер декрементируем все пересечения (у него и у пересечённого)
        ld hl,deccrossedandself
        call inccrossededges
;стираем текущую вершину, текущие рёбра и перерисовываем их инверсией
        call undrawcurvertex
        call undrawconnectedvertices
        call undrawcuredges
        ;call cls
        call drawunconnectededges
        call drawunconnectedvertices

        call prlevel
        
        call drawcuredges
        call drawconnectedvertices
        ;jp drawcurvertex
drawcurvertex
        ;ld a,(clickstate)
        ;or a
        ;ret z ;unclicked
        call getcurvertexxy_ahl
        jp shapes_prarr_ring8c
drawringon
        bit 0,l
        ld de,sprringon_l+1
        jr nz,$+5+2
         ld de,sprringon_r+1
         dec hl
         dec hl
        jp prarr_cross8c_go


movecurvertex
        ld a,(clickstate)
        or a
        ret z ;unclicked
        call getcurvertexaddr
        push hl
        call ahl_coords
	 cp 7
	 jr nc,$+4
	 ld a,7 ;max dy = 192 (for fast mul)
        ex de,hl
        pop hl
        ld (hl),e
        inc hl
        ld (hl),d ;x
        inc hl
        ld (hl),a ;y
        inc hl
        ld (hl),0
        ret

undrawcurvertex
        ;ld a,(clickstate)
        ;or a
        ;ret z ;unclicked
        call getcurvertexxy_ahl
        ;jp shapes_prarr_ring8c
drawringoff
        bit 0,l
        ld de,sprringoff_l+1
        jr nz,$+5+2
         ld de,sprringoff_r+1
         dec hl
         dec hl
        jp prarr_cross8c_go

getcurvertexxy_ahl
        call getcurvertexaddr
        ld c,(hl)
        inc hl
        ld b,(hl) ;x
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;y
        ld a,e ;y
        ld h,b
        ld l,c ;x
        ret

getcurvertexaddr
curvertex=$+1
        ld hl,0
        ld de,vertices
        add hl,hl
        add hl,hl
        add hl,de
        ret

undrawcuredges
        call setlinenormalmask
        ;ld a,0x47 ;keep left pixel ;иначе надо cls перед redraw
        ;ld (lineverR_and_r),a
        ;ld (lineverL_and_r),a
        ;cpl
        ;ld (lineverR_and_l),a
        ;ld (lineverL_and_l),a
        ;ld hl,delpixel
        xor a
        jr drawcuredges_go
drawcuredges
        ld a,0xff
        ld (lineverR_and_l),a
        ld (lineverL_and_l),a
        ld (lineverR_and_r),a
        ld (lineverL_and_r),a
        ld (linehorR_and_r),a
        ld (linehorL_and_r),a
        ld (linehorR_and_l),a
        ld (linehorL_and_l),a
        ;ld hl,invpixel
        ;ld a,0xff
drawcuredges_go
        ;ld (pixelprocver),hl
        ;ld (pixelprochor),hl
        ld (drawcuredges_colormask),a
        ld a,(clickstate)
        or a
        ret z ;unclicked
;find all edges with current vertex (1st or 2nd), draw them
;vertex1,vertex2,crossed
        ld hl,edges
        ld bc,(nedges)
drawcuredges0
        push bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(curvertex)
        cp d
        jr z,$+3
        cp e
        jr nz,drawcuredgesno
        ld a,(hl)
        push hl
;e=vertex1
;d=vertex2
;a=crossed
        or a
        ld a,COLORS_UNCROSSED;%11001001
        jr z,$+4
        ld a,COLORS_CROSSED;%11010010
drawcuredges_colormask=$+1
        and 0
        call drawedge
        pop hl
drawcuredgesno
        pop bc
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,drawcuredges0
        cpi
        jp pe,drawcuredges0
        ;ld hl,prpixel
        ;ld (pixelprocver),hl
        ;ld (pixelprochor),hl
setlinenormalmask
        ld a,0x47 ;keep left pixel ;иначе надо cls перед redraw
        ld (lineverR_and_r),a
        ld (lineverL_and_r),a
        ld (linehorR_and_r),a
        ld (linehorL_and_r),a
        cpl
        ld (lineverR_and_l),a
        ld (lineverL_and_l),a
        ld (linehorR_and_l),a
        ld (linehorL_and_l),a
        ret

drawconnectedvertices
        ld hl,shapes_prarr_ring8c;drawringon
        jr drawconnectedvertices_go
undrawconnectedvertices
        ld hl,drawringoff
drawconnectedvertices_go
        ld (drawconnectedvertices_drawproc),hl
        ld hl,edges
        ld bc,(nedges)
drawconnectedvertices0
        push bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
;e=vertex1
;d=vertex2
        ld a,(curvertex)
        cp d
        jr z,drawconnectedvertices_e
        cp e
        jr nz,drawconnectedverticesno
        ld e,d
drawconnectedvertices_e
        push hl
        ld d,0 ;e=connected vertex
        ld hl,vertices
        add hl,de
        add hl,de
        add hl,de
        add hl,de
        ld c,(hl)
        inc hl
        ld b,(hl) ;x
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;y
        ld a,e ;y
        ld h,b
        ld l,c ;x
drawconnectedvertices_drawproc=$+1
        call drawringon
        pop hl
drawconnectedverticesno
        pop bc
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,drawconnectedvertices0
        cpi
        jp pe,drawconnectedvertices0
        ret

drawunconnectededges
;рисуем все рёбра, кроме связанных с текущей вершиной
;find all edges with current vertex (1st or 2nd), draw others
;vertex1,vertex2,crossed
        ld hl,edges
        ld bc,(nedges)
drawunconnectededges0
        push bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(curvertex)
        cp d
        jr z,$+3
        cp e
        jr  z,drawunconnectededgesno
        ld a,(hl)
        push hl
;e=vertex1
;d=vertex2
;a=crossed
        or a
        ld a,COLORS_UNCROSSED;%11001001
        jr z,$+4
        ld a,COLORS_CROSSED;%11010010
        call drawedge
        pop hl
drawunconnectededgesno
        pop bc
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,drawunconnectededges0
        cpi
        jp pe,drawunconnectededges0
        ret
        
drawunconnectedvertices
;рисуем все вершины, кроме текущей и связанных с ней
;для этого:
;чистим таблицу связанных вершин
        ld hl,vertlinkflags
        ld de,vertlinkflags+1
        ld bc,MAXVERTICES-1
        ld (hl),0
        ldir
;помечаем там текущую вершину
        ld de,vertlinkflags
        ld hl,(curvertex)
        ld h,b;0
        add hl,de
        inc (hl)
;перебираем все рёбра, ищем там связанные вершины и помечаем в таблице связанных вершин
        ld hl,edges
        ld bc,(nedges)
drawunconnectedvertices0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
;e=vertex1
;d=vertex2
        ld a,(curvertex)
        cp d
        jr z,drawunconnectedvertices_e
        cp e
        jr nz,drawunconnectedverticesno
        ld e,d
drawunconnectedvertices_e
        push hl
        ld d,0 ;e=connected vertex
        ld hl,vertlinkflags
        add hl,de
        inc (hl)
        pop hl
drawunconnectedverticesno
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,drawunconnectedvertices0
;перебираем все вершины, выводим только не попавшие в таблицу
        ld hl,vertlinkflags
        ld a,(nvertices)
        ld b,a
drawunconnectedvertices1
        push bc
        push hl
        ld a,(nvertices)
        sub b
        ld e,a
         ld a,(hl) ;linkflag
        ld d,0 ;e=connected vertex
        ld hl,vertices
        add hl,de
        add hl,de
        add hl,de
        add hl,de
        ld c,(hl)
        inc hl
        ld b,(hl) ;x
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;y
         or a
        ld a,e ;y
        ld h,b
        ld l,c ;x
        call z,drawringon
        pop hl
        inc hl
        pop bc
        djnz drawunconnectedvertices1
        ret
        
countverticesneeded
        ld a,6
        ld (verticesneeded),a
        ld a,(level)
        or a
        ret z
        ld b,a
countverticesneeded0
        ld a,b
        add a,3 ;a=4..
        ld hl,verticesneeded
        add a,(hl)
        jr nc,$+3
        sbc a,a
        ld (hl),a
        djnz countverticesneeded0
        ret

ahl_coords
        ld a,(arry)
        ld hl,(arrx)
        ret


quitifnoclickstate
	ld a,(clickstate)
	or a
	ret nz
quit
	ld de,filename
	OS_CREATEHANDLE
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_WRITEHANDLE
	pop bc
	OS_CLOSEHANDLE
        QUIT
	
filename
	db "untangle.ini",0

redrawifneeded
        xor a
doredraw=$+1
        cp 0
        ret z
redraw
        xor a
        ld (doredraw),a
        call setscrpgs
        call drawedges
        call drawvertices
        jr prlevel

prlevelifneeded
        xor a
invalidatetime=$+1
        cp 0
        ret z
prlevel
        ld a,(level)
        inc a
        ld hl,tleveldig1
        call dectotxt12
        ;ld (tleveldig2),a
        ;ld a,b
        ;ld (tleveldig1),a
        ld a,(cur_h)
        ld hl,ttimeh1
        call dectotxt12
        ld a,(cur_m)
        ld hl,ttimem1
        call dectotxt12
        ld a,(cur_s)
        ld hl,ttimes1
        call dectotxt12
        
         xor a
         ld (invalidatetime),a
        ld b,a
        ld c,a ;ld bc,0
        ld hl,tlevel
        jp prtext

dectotxt12
        ld b,'0'-1
        inc b
        sub 10
        jr nc,$-3
        add a,'0'+10
         ld (hl),b
         inc hl
         ld (hl),a
        ret

updatetime
        OS_GETTIMER ;hlde=timer
        ld hl,(oldupdtimer)
        ex de,hl
        ld (oldupdtimer),hl
        or a
        sbc hl,de ;hl=frames
        ret z
        ld b,h
        ld c,l
updatetime0
        call inctime
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,updatetime0
        cpi
        jp pe,updatetime0
        ret
inctime
        ld hl,cur_f
        inc (hl)
        ld a,(hl)
        sub 50
        ret c
        ld (hl),a
         ld a,1
         ld (invalidatetime),a
        ld hl,cur_s
        inc (hl)
        ld a,(hl)
        sub 60
        ret c
        ld (hl),a
        ld hl,cur_m
        inc (hl)
        ld a,(hl)
        sub 60
        ret c
        ld (hl),a
        ld hl,cur_h
        inc (hl)
        ret

        if 1==0
genvertices
;x,X,y,Y
        ld hl,vertices
        ld a,(nvertices)
        ld b,a
genvertices0
        push bc
        ld c,160
        call rnd
        add a,a
        ld (hl),a
        inc hl
        ld (hl),0
        rl (hl)
        inc hl
        ld c,200
        call rnd
        ld (hl),a
        inc hl
        ld (hl),0
        inc hl
        pop bc
        djnz genvertices0
        ret
        endif

        if 1==0
genedges
;vertex1,vertex2,crossed
        ld hl,edges
        ld bc,(nedges)
genedges0
        push bc
        ld a,(nvertices)
        ld c,a
        call rnd
        ld (hl),a
        inc hl
        ld a,(nvertices)
        ld c,a
        call rnd
        ld (hl),a
        inc hl
        ld (hl),0 ;uncrossed
        inc hl
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,genedges0
        ret
        endif

drawedges
;vertex1,vertex2,crossed
        ld hl,edges
        ld bc,(nedges)
drawedges0
        push bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(hl)
        push hl
;e=vertex1
;d=vertex2
;a=crossed
        or a
        ld a,COLORS_UNCROSSED;%11001001
        jr z,$+4
        ld a,COLORS_CROSSED;%11010010
        call drawedge
        pop hl
        pop bc
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,drawedges0
        cpi
        jp pe,drawedges0
        ret

drawvertices
;x,X,y,Y
        ld hl,vertices
        ld a,(nvertices)
        ld b,a
drawvertices0
        push bc
        ld c,(hl)
        inc hl
        ld b,(hl) ;x
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl) ;y
        inc hl
        push hl
        ld a,e ;y
        ld h,b
        ld l,c ;x
        call drawringon;shapes_prarr_ring8c
        pop hl
        pop bc
        djnz drawvertices0
        ret

findvertex
;in: hl=arrx, a=arry
;out: CY=not found, or else a=vertex #
        ex de,hl
        ld c,a
;x,X,y,Y
        ld hl,vertices
        ld a,(nvertices)
        ld b,a
findvertex0
        ld a,(hl)
        inc hl
        push hl
        ld h,(hl)
        ld l,a ;x
        or a
        sbc hl,de ;x-arrx
        inc hl
        inc hl
        push de
        ld de,5
        or a
        sbc hl,de ;CY = -2..+2
        pop de
        pop hl
        inc hl
        jr nc,findvertexno
        push hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a ;y
        push bc
        xor a
        ld b,a
        sbc hl,bc ;y=arry
        inc hl
        inc hl
        ld bc,5
        or a
        sbc hl,bc ;CY = -2..+2
        pop bc
        pop hl
        jr c,findvertexok
findvertexno
        inc hl
        inc hl
        djnz findvertex0
        scf
        ret
findvertexok
        ld a,(nvertices)
        sub b
        or a
        ret

rnd
;0..c-1
        ;ld a,r
        push de
        push hl
        call func_rnd
        pop hl
        pop de
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

func_rnd
;Patrik Rak
rndseed1=$+1
        ld  hl,0xA280   ; xz -> yw
rndseed2=$+1
        ld  de,0xC0DE   ; yw -> zt
        ld  (rndseed1),de  ; x = y, z = w
        ld  a,e         ; w = w ^ ( w << 3 )
        add a,a
        add a,a
        add a,a
        xor e
        ld  e,a
        ld  a,h         ; t = x ^ (x << 1)
        add a,a
        xor h
        ld  d,a
        rra             ; t = t ^ (t >> 1) ^ w
        xor d
        xor e
        ld  h,l         ; y = z
        ld  l,a         ; w = t
        ld  (rndseed2),hl
        ;ex de,hl
        ;ld hl,0
        ;res 7,c ;int
        ret


div4signedup
        or a
        jp m,$+5
        add a,3
        sra a
        sra a
        ret

clsifneeded
        xor a
docls=$+1
        cp 0
        ret z
        ld (docls),a ;0
cls
        ld e,0
        OS_CLS
        ret

prtext
;bc=координаты
;hl=text
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext

prnum
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
        adc a,0x80
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
        set 6,h
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
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup        
        ret

        if 1==0

invpixel
;bc=x (не портится)
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        push bc
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ;ld d,ty/256
        ;ld h,tx/256
        ld a,(de) ;(y*40)
        jr c,invpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
invpixel_color_l=$+1
        xor 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
invpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
invpixel_color_r=$+1
        xor 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret

prpixel
;bc=x (не портится)
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        push bc
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ;ld d,ty/256
        ;ld h,tx/256
        ld a,(de) ;(y*40)
        jr c,prpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
prpixel_color_l=$+1
        or 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
prpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
prpixel_color_r=$+1
        or 0;lx
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
        
delpixel
;bc=x (не портится)
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        push bc
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ;ld d,ty/256
        ;ld h,tx/256
        ld a,(de) ;(y*40)
        jr c,delpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0xb8 ;keep right pixel 
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
delpixel_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld b,a
        ld a,(bc)
        and 0x47 ;keep left pixel 
        ld (bc),a
        dec h
        dec d
        pop bc
        ret
        
        endif

drawedge
;e=vertex1
;d=vertex2
;a=color = %33210210
        ;ld (prpixel_color_l),a
        ;ld (prpixel_color_r),a
        ld l,a
        and 0x47;%01000111 ;keep left pixel 
        ;ld (invpixel_color_l),a
         ;ld (prpixel_color_l),a
         ld (lineverR_color_l),a
         ld (lineverL_color_l),a
         ld (linehorR_color_l),a
         ld (linehorL_color_l),a
        xor l ;keep right pixel 
        ;ld (invpixel_color_r),a
         ;ld (prpixel_color_r),a
         ld (lineverR_color_r),a
         ld (lineverL_color_r),a
         ld (linehorR_color_r),a
         ld (linehorL_color_r),a
        ld h,0
        ld l,e ;vertex1
        ld bc,vertices
        add hl,hl
        add hl,hl
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl) ;x
        inc hl
        ld a,(hl) ;y

        ld h,0
        ld l,d ;vertex2
        ld de,vertices
        add hl,hl
        add hl,hl
        add hl,de ;NC
        ld e,(hl)
        inc hl
        ld d,(hl) ;x2
        inc hl
;bc=x (в плоскости экрана, но может быть отрицательным)
;a=y
;de=x2
;(hl)=y2
        ;or a
        ;sbc hl,de
        ;add hl,de
        ;jp p,shapes_line_noswap
         sub (hl)
        jr c,shapes_line_noswap
        push af ;dy
        ld a,d
        ld d,b
        ld b,a
        ld a,e
        ld e,c
        ld c,a ;x <-> x2
        ex de,hl
        sbc hl,bc
        push hl ;dx
        ex de,hl
         ld e,(hl) ;y
         jp shapes_line_noswapq
shapes_line_noswap
        neg
        push af ;dy
        neg
        add a,(hl)
        ex de,hl
        or a
        sbc hl,bc
        push hl ;dx
         ld e,a ;y
shapes_line_noswapq
        exx
        pop bc ;dx
        ld a,0x03 ;inc bc
        jp p,shapes_line_nodec
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;dx >= 0
        ld a,0x0b ;dec bc
shapes_line_nodec
        pop hl ;dy
         ld l,h
         ld h,0
;a=код inc/dec bc
;bc'=x (в плоскости экрана, но может быть отрицательным)
;e'=y
        or a
        sbc hl,bc
        add hl,bc
;bc=dx
;hl=dy
        jp nc,shapes_linever ;dy>=dx
        ex de,hl
        ld hy,b
        ld ly,c ;counter=dx
	
;0x0000 -> 0x0101
;0x0001 -> 0x0102
;0x00ff -> 0x0100
;0x0100 -> 0x0201
	inc ly
	inc hy
	
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,b
        ld l,c
        sra h
        rr l ;ym=dx div 2 ;TODO а если dx<0?
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mym=256-(dx div 2)
        exx
        ld h,tx/256
        ld d,ty/256
         cp 0x03 ;inc bc
         jr nz,shapes_linehorL
         ;jr z,shapes_linehorR
        if 1==0
        ld (shapes_lineincx),a
;bc=x
;e=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linehor0
pixelprochor=$+1
        call prpixel
shapes_lineincx=$
        inc bc ;x+1        
        exx
        ;add hl,de ;mym+dy
        or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehor1
        inc  e ;y+1
        exx
        ;or a
        ;sbc hl,bc ;mym-dx
        add hl,bc ;ym+dx
        exx
shapes_linehor1
        dec ly
        jp nz,shapes_linehor0
        dec hy
        jp nz,shapes_linehor0
        ret
        endif

        if 1==1
shapes_linehorR
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ld b,ly
        ld a,(de) ;(y*40)
        jr c,shapes_linehorR_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_linehorR0_l
        ld a,(hl)
linehorR_and_l=$+1
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
linehorR_color_l=$+1
        xor 0;lx
        ld (hl),a
        exx
        ;or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehorR0_ldjnz
        add hl,de ;y+1
        exx
        add hl,bc ;ym+dx
        exx
shapes_linehorR0_ldjnz
        djnz shapes_linehorR0_r
        dec hy
        jp nz,shapes_linehorR0_r
        ret
shapes_linehorR_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_linehorR0_r
        ld a,(hl)
linehorR_and_r=$+1
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
linehorR_color_r=$+1
        xor 0;lx
        ld (hl),a        
	bit 6,h
	set 6,h
	jr z,shapes_linehorR_incxok
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,shapes_linehorR_incxok
	inc hl
shapes_linehorR_incxok
        exx
        ;or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehorR0_rdjnz
        add hl,de ;y+1
        exx
        add hl,bc ;ym+dx
        exx
shapes_linehorR0_rdjnz
        djnz shapes_linehorR0_l
        dec hy
        jp nz,shapes_linehorR0_l
        ret

shapes_linehorL
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ld b,ly
        ld a,(de) ;(y*40)
        jr c,shapes_linehorL_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_linehorL0_l
        ld a,(hl)
linehorL_and_l=$+1
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
linehorL_color_l=$+1
        xor 0;lx
        ld (hl),a
	bit 6,h
	res 6,h
	jr nz,shapes_linehorL_decxok
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr z,shapes_linehorL_decxok
	dec hl
shapes_linehorL_decxok
        exx
        ;or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehorL0_ldjnz
        add hl,de ;y+1
        exx
        add hl,bc ;ym+dx
        exx
shapes_linehorL0_ldjnz
        djnz shapes_linehorL0_r
        dec hy
        jp nz,shapes_linehorL0_r
        ret
shapes_linehorL_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_linehorL0_r
        ld a,(hl)
linehorL_and_r=$+1
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
linehorL_color_r=$+1
        xor 0;lx
        ld (hl),a        
        exx
        ;or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehorL0_rdjnz
        add hl,de ;y+1
        exx
        add hl,bc ;ym+dx
        exx
shapes_linehorL0_rdjnz
        djnz shapes_linehorL0_l
        dec hy
        jp nz,shapes_linehorL0_l
        ret

        endif
        
shapes_linever
        ld d,h
        ld e,l
        ld hy,d
        ld ly,e ;counter=dy
	
;0x0000 -> 0x0101
;0x0001 -> 0x0102
;0x00ff -> 0x0100
;0x0100 -> 0x0201
	inc ly
	inc hy
	
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ;ld h,d
        ;ld l,e
        sra h
        rr l
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mxm=256-(dy div 2)
        exx
        ld h,tx/256
        ld d,ty/256
         cp 0x03 ;inc bc
         jr nz,shapes_lineverL
         ;jr z,shapes_lineverR
        if 1==0
        ld (shapes_lineincx2),a
;bc=x
;e=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linever0
pixelprocver=$+1
        call prpixel
        inc  e ;y+1
        exx
        ;add hl,bc ;mxm+dx
        or a
        sbc hl,bc ;xm-dx
        exx
        jr nc,shapes_linever1
shapes_lineincx2=$
        inc bc ;x+1
        exx
        ;or a
        ;sbc hl,de ;mxm-dy
        add hl,de ;xm+dy
        exx
shapes_linever1
        dec ly
        jp nz,shapes_linever0
        dec hy
        jp nz,shapes_linever0
        ret
        endif

        if 1==1
;bc=x
;e=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_lineverR
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ld b,ly
        ld a,(de) ;(y*40)
        jr c,shapes_lineverR_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_lineverR0_l
        ld a,(hl)
lineverR_and_l=$+1
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
lineverR_color_l=$+1
        xor 0;lx
        ld (hl),a
        add hl,de ;y+1 ;NC
        exx
        ;or a
        sbc hl,bc ;xm-dx
        jr c,shapes_lineverRincx_r
        ;add hl,de ;xm+dy
        exx
shapes_lineverR0_ldjnz
        djnz shapes_lineverR0_l
        dec hy
        jp nz,shapes_lineverR0_l
        ret
shapes_lineverR_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
shapes_lineverR0_r
        ld a,(hl)
lineverR_and_r=$+1
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
lineverR_color_r=$+1
        xor 0;lx
        ld (hl),a
        add hl,de ;y+1 ;NC
        exx
        ;or a
        sbc hl,bc ;xm-dx
        jr c,shapes_lineverRincx_l
        exx
        djnz shapes_lineverR0_r
        dec hy
        jp nz,shapes_lineverR0_r
        ret
shapes_lineverRincx_r
        add hl,de ;xm+dy
        exx
        djnz shapes_lineverR0_r
        dec hy
        jp nz,shapes_lineverR0_r
        ret
shapes_lineverRincx_l
        add hl,de ;xm+dy
        exx
	bit 6,h
	set 6,h
	jr z,shapes_lineverR0_ldjnz
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,shapes_lineverR0_ldjnz
	inc hl
        jp shapes_lineverR0_ldjnz

shapes_lineverL
        ld a,b
        rra
        ld a,c
        rra
        ld l,a
        ld b,ly
        ld a,(de) ;(y*40)
        jr c,shapes_lineverL_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
;hl=scr
;de=40
;b=pixels
shapes_lineverL0_l
        ld a,(hl)
lineverL_and_l=$+1
        and 0xb8 ;keep right pixel ;иначе надо cls перед redraw
lineverL_color_l=$+1
        xor 0;lx
        ld (hl),a
        add hl,de ;y+1 ;NC
        exx
        ;or a
        sbc hl,bc ;xm-dx
        jr c,shapes_lineverLdecx_r
        ;add hl,de ;xm+dy
        exx
        djnz shapes_lineverL0_l
        dec hy
        jp nz,shapes_lineverL0_l
        ret
shapes_lineverL_r
        add a,(hl) ;x div 4
        ld c,a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
        ld l,c
        ld de,40
shapes_lineverL0_r
        ld a,(hl)
lineverL_and_r=$+1
        and 0x47 ;keep left pixel ;иначе надо cls перед redraw
lineverL_color_r=$+1
        xor 0;lx
        ld (hl),a
        add hl,de ;y+1 ;NC
        exx
        ;or a
        sbc hl,bc ;xm-dx
        jr c,shapes_lineverLdecx_l
        exx
shapes_lineverL0_rdjnz
        djnz shapes_lineverL0_r
        dec hy
        jp nz,shapes_lineverL0_r
        ret
shapes_lineverLdecx_r
        add hl,de ;xm+dy
        exx
	bit 6,h
	res 6,h
	jr nz,shapes_lineverL0_rdjnz
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr z,shapes_lineverL0_rdjnz
	dec hl
        jp shapes_lineverL0_rdjnz
shapes_lineverLdecx_l
        add hl,de ;xm+dy
        exx
        djnz shapes_lineverL0_l
        dec hy
        jp nz,shapes_lineverL0_l
        ret

        endif

oldupdtimer
        dw 0

        align 256
tx
        dup 256
        db ($&0xff)/4
        edup
        dup 64
        db 0x80
        db 0xc0
        db 0xa0
        db 0xe0
        edup
ty
        dup 200
        db 0xff&(($&0xff)*40)
        edup
        ds 56,0xff&8000
        dup 200
        db (($&0xff)*40)/256
        edup
        ds 56,8000/256
font
        incbin "fontgfx"

genmesh
        xor a
        ld (nvertices),a
        ld (nvertices2),a
        ld (curmeshvertex),a
        ld h,a
        ld l,a ;ld hl,0
        ld (nedges),hl
        ;ld (ncrossededges),hl
        ld (genmeshedge_old),hl ;невозможное ребро
;создать ряд из 2 точек (или лучше из sqrt(verticesneeded)) с рёбрами между ними:
        ld (genmeshx),hl
        ld (genmeshy),hl
        call genmeshvertex ;in verlist2
        ld a,(verticesneeded)
        ;ld h,0
;sqrt
;in: a [hl]
;out: d
        or a
        ld de,64
        ;ld a,l
        ld l,d;h
        ld h,d
        ld b,8
sqrt0
        sbc hl,de
        jr nc,$+3
        add hl,de
        ccf
        rl d
        add a,a
        adc hl,hl
        add a,a
        adc hl,hl
        djnz sqrt0

        ld b,d ;будет одна лишняя сверх sqrt
genmeshfirstrow0
        push bc
        call newedgeinlist2 ;цепляем новое ребро в vertlist2
        pop bc
        djnz genmeshfirstrow0

        call copyvertlist2to1
        
genmeshrows0
;начинаем следующий ряд
        ld hl,(genmeshy)
        ld bc,25
        add hl,bc
        ld (genmeshy),hl
        xor a
        ld (curopenvertinlist1),a
        ld (nvertices2),a
        ld h,a
        ld l,a ;ld hl,0
        ld (genmeshx),hl
;сначала цепляем к первой открытой точке ребро
;.    .    .    .
;|    ^текущая открытая точка
;* текущая цепляемая точка
        ld a,(nvertices)
        push af
        call genmeshvertex ;in verlist2
        pop af ;новая точка
        ld (curmeshvertex),a
        call linktoopenvertex
        
genmeshrow00
        call func_rnd
        cp 128
;если rnd>0.?, то создаём ребро и циклимся здесь, иначе цепляем последнее ребро за следующую открытую точку
;TODO вероятность поставить в соответствие с числом nvertices2 - если сильно меньше, чем надо, то надо генерить рёбра
;.   .    .    .
;|_\/

;.    .    .    .
;|_\__|

;.    .    .    .
;|_\_.__\
;        * текущая цепляемая точка
;и так пока не кончатся открытые точки
        jr c,genmesh_nextopenvert
        call newedgeinlist2 ;цепляем новое ребро в vertlist2        
        ld a,(nvertices)
        ld hl,verticesneeded
        cp (hl)
        jr nc,genmesh_finishlastvertex;jp nc,linktoopenvertex ;сгенерили точек столько, сколько просили
;с некоторой вероятностью цепляем к текущей открытой точке
        call func_rnd
        cp 128
        call c,linktoopenvertex
        jr genmeshrow00
genmesh_finishlastvertex
;цепляем ребро к текущей открытой точке (даже ко всем открытым до конца! иначе при 2 рядах может остаться хвост в верхнем ряду) и выходим
genmesh_finishlastvertex0
        call linktoopenvertex ;цепляем ребро к текущей открытой точке
        ld de,curopenvertinlist1
        ld a,(de)
        inc a
        ld hl,nvertices1
        cp (hl)
        ret nc ;больше нет открытых точек - заканчиваем
        ld (de),a
        jr genmesh_finishlastvertex0

genmesh_nextopenvert
;переходим к следующей открытой точке, если она есть, и цепляем к ней ребро
        ld de,curopenvertinlist1
        ld a,(de)
        inc a
        ld hl,nvertices1
        cp (hl)
        jr nc,genmesh_rowend ;больше нет открытых точек - заканчиваем ряд
        ld (de),a
        call linktoopenvertex ;цепляем ребро к текущей открытой точке
        jr genmeshrow00
genmesh_rowend
        call linktoopenvertex ;цепляем ребро к текущей (последней) открытой точке
;ряд открытых точек заменить новым
        call copyvertlist2to1
        jr genmeshrows0

newedgeinlist2
;цепляем новое ребро в vertlist2
        ld a,(nvertices)
        push af
        call genmeshvertex ;in verlist2
        ld a,(curmeshvertex)
        ld e,a ;текущая цепляемая точка
        pop af ;новая точка
        ld (curmeshvertex),a
        ld d,a
        jp genmeshedge

linktoopenvertex
curmeshvertex=$+1
        ld d,0 ;номер точки, которую надо прицепить
curopenvertinlist1=$+1
        ld a,0
        ld hl,vertlist1
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld e,(hl) ;текущая открытая точка
        jp genmeshedge

genmeshvertex
;in verlist2
genmeshx=$+1
        ld bc,0
genmeshy=$+1
        ld de,0
        
        ld c,160
        call rnd
        add a,a
        ld c,a
        ld b,0
        rl b
        push bc
        ld c,200-8
        call rnd
        add a,8
        ld e,a
        ;ld d,0
        pop bc
;bc=x
;e=y
        ld a,(nvertices2)
        ld hl,vertlist2
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(nvertices)
        ld (hl),a
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        push bc
        ld bc,vertices
        add hl,bc
        pop bc
        ld (hl),c
        inc hl
        ld (hl),b ;x
        inc hl
        ld (hl),e
        inc hl
        ld (hl),0;d ;y
        ld hl,nvertices
        inc (hl)
        ld hl,nvertices2
        inc (hl)
        ld hl,(genmeshx)
        ld bc,24
        add hl,bc
        ld (genmeshx),hl
        ret
        
copyvertlist2to1
        ld hl,vertlist2
        ld de,vertlist1
        ld bc,MAXVERTICES
        ldir
        ld a,(nvertices2)
        ld (nvertices1),a
        ret
        
genmeshedge
;d=vertex1
;e=vertex2
;проверим, что мы уже не прицепили это ребро
genmeshedge_old=$+1
        ld hl,0
        or a
        sbc hl,de
        ld (genmeshedge_old),de
        ret z
        ld bc,(nedges)
        ld hl,edges
        add hl,bc
        add hl,bc
        add hl,bc
        ld (hl),d
        inc hl
        ld (hl),e
        dec hl
;check if this edge crossed with something, mark crossing here and there
        ld bc,(nedges)
        call checkcrossedwith_oldedges
        ld hl,(nedges)
        inc hl
        ld (nedges),hl
        ret

        if 1==0
countcrossededges
;проверяем пересечение всех со всеми
        ;ld hl,0
        ;ld (ncrossededges),hl
        ld hl,edges
        ld bc,(nedges)
initcrossededges0
        inc hl
        inc hl
        ld (hl),0 ;uncrossed
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,initcrossededges0
        
        ld hl,edges
        ld bc,(nedges)
        ld de,0 ;counter (+1)
countcrossededges0
        push bc
        push de
        push hl
        ld b,d
        ld c,e
        call checkcrossedwith_oldedges
        pop hl
        inc hl
        inc hl
        inc hl
        pop de
        pop bc
        inc de
        dec bc
        ld a,b
        or c
        jr nz,countcrossededges0
        ret
        endif

inccrossededges
        ld (inccrossededges_proc),hl
;для каждого из связанных рёбер инкрементируем/декрементируем все пересечения (у него и у пересечённого)
        ld hl,edges
        ld bc,(nedges)
inccrossededges0
;ищем связанные рёбра
        ld e,(hl)
        inc hl
        ld d,(hl)
        dec hl
;e=vertex1
;d=vertex2
        ld a,(curvertex)
        cp d
        jr z,inccrossededgesok
        cp e
        jr nz,inccrossededgesno
inccrossededgesok
;нашли связанное ребро, ищем все его пересечения (по всем рёбрам, кроме самого себя) и их инкрементируем (и у себя тоже)
        push bc
        push hl
        ld (inccrossededges_selfaddr),hl
        ld hl,edges
        ld bc,(nedges)
inccrossededges00
inccrossededges_selfaddr=$+1
        ld de,0
        or a
        sbc hl,de
        add hl,de
        jr z,inccrossededges00_skipself
        push bc
;hl=edge1addr
;de=edge2addr
        push hl
        call checkcrossed_edge ;out: CY=crossed
        pop hl
inccrossededges_proc=$+1
        call c,inccrossedandself
        pop bc
inccrossededges00_skipself
        inc hl
        inc hl
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,inccrossededges00
        cpi
        jp pe,inccrossededges00
;конец обработки связанного ребра
        pop hl
        pop bc
inccrossededgesno
        inc hl
        inc hl
        ;inc hl
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,inccrossededges0
        cpi
        jp pe,inccrossededges0
        ret
inccrossedandself
        push hl
        inc hl
        inc hl
        inc (hl)
        ld hl,(inccrossededges_selfaddr)
        inc hl
        inc hl
        inc (hl)
        pop hl
        ret
deccrossedandself
        push hl
        inc hl
        inc hl
        dec (hl)
        ld hl,(inccrossededges_selfaddr)
        inc hl
        inc hl
        dec (hl)
        pop hl
        ret

checkcrossedwith_oldedges
;hl=edge to check
;bc=nedges before current edge
        ;inc hl
        ;inc hl
        ;ld (hl),0
        ;dec hl
        ;dec hl
        ld de,edges
        ld a,b
        or c
        ret z;jr z,genmeshedge_nocheckcrossed
;bc=was nedges
genmeshedge_checkcrossed0
        push bc
        push de
        push hl
        call checkcrossed_edge
        pop hl
        pop de
        pop bc
        inc de
        inc de
        jr nc,genmeshedge_nocrossed
        ld a,(de)
        inc a
        ld (de),a
        inc hl
        inc hl
        inc (hl)
        dec hl
        dec hl
genmeshedge_nocrossed
        inc de
        dec bc
        ld a,b
        or c
        jr nz,genmeshedge_checkcrossed0
;genmeshedge_nocheckcrossed
        ret

checkcrossedcoord
;ix<=bc: AB
;hl<=de: CD
;out: CY=crossed

; all possible configurations:
;
; 1.
;  A===B
;        C===D
;
; 2.
;  C===D 
;        A===B
;
; 3.
; A======B
;   C==D 
;
; 4.
; C======D
;   A==B
;
; 5.
; A===B
;   C===D
;
; 6.
; C===D
;   A===B

; hence NON-crossed case is:
;
; if B(bc)<C(hl), otherwise if D(de)<A(ix)

	or	a
	sbc	hl,bc ; C(hl)-B(bc): Z if B==C, cy if B>C, nc if B<C and not Z
	jr	z,checkcrossedcoord_crossed
	ret	nc

	push	ix
	pop	hl
	or	a
	sbc	hl,de	;A(hl, was ix)-D(de)
	ret	nz
checkcrossedcoord_crossed:
	scf
	ret



 if 1==0
;crossed case1: C(hl)<=B(bc), D(de)>=B(bc)
        or a
        sbc hl,bc
        add hl,bc
        jr z,checkcrossedcoord_maybecrossed1
        ;jr c,checkcrossedcoord_maybecrossed1
        jr nc,checkcrossedcoord_cross1q
checkcrossedcoord_maybecrossed1
        ex de,hl
        ;or a
        sbc hl,bc
        add hl,bc
        ;ex de,hl
        jr nc,checkcrossedcoord_crossed
checkcrossedcoord_cross1q
;crossed case2: A(ix)<=C(hl), B(bc)>=C(hl)
        push ix
        pop de
        or a
        sbc hl,de
        add hl,de
        jr c,checkcrossedcoord_notcrossed
        ;or a
        sbc hl,bc
        add hl,bc
        jr z,checkcrossedcoord_crossed
        jr c,checkcrossedcoord_crossed
checkcrossedcoord_notcrossed
        or a
        ret
checkcrossedcoord_crossed
        scf
        ret
 endif




checkcrossed_edge
;hl=edge1addr
;de=edge2addr
;out: CY=crossed
;для надёжности сделаем hl>=de всегда (похоже, тест некоммутативный в редких случаях)
        or a
        sbc hl,de
        add hl,de
        jr nc,$+3
        ex de,hl

;если A=C или A=D или B=C или B=D, то непересечение (примыкание) - надо проверять не координаты, а номера вершин!!!
	ld a,(de)
	cp (hl)
	ret z ;примыкание
	inc hl
	cp (hl)
	ret z ;примыкание
	inc de
	ld a,(de)
	cp (hl)
	ret z ;примыкание
	dec hl
	cp (hl)
	ret z ;примыкание

        ld c,(hl) ;edge1vertex1
        inc hl
        ld a,(hl) ;edge1vertex2
        ld b,0
        ld hl,vertices
        add hl,bc
        add hl,bc
        add hl,bc
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkxA),bc
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkyA),bc
        ld l,a ;edge1vertex2
        ld h,0
        ld bc,vertices
        add hl,hl
        add hl,hl
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkxB),bc
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkyB),bc
        
        ex de,hl

        ld a,(hl) ;edge2vertex2
	dec hl
        ld c,(hl) ;edge2vertex1
        ld b,0
        ld hl,vertices
        add hl,bc
        add hl,bc
        add hl,bc
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkxC),bc
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkyC),bc
        ld l,a ;edge2vertex2
        ld h,0
        ld bc,vertices
        add hl,hl
        add hl,hl
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkxD),bc
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (checkyD),bc

        if 1==1
;test xA..xB doesn't cross xC..xD: if cross, check y...
        ld hl,(checkxA)
        ld de,(checkxB)
        call maxhl_de_tode ;de>=hl
        push hl
        pop ix
        ld b,d
        ld c,e ;bc>=ix
        ld hl,(checkxC)
        ld de,(checkxD)
        call maxhl_de_tode ;de>=hl
        call checkcrossedcoord ;out: CY=crossed
        ret nc
;test yA..yB doesn't cross yC..yD
        ld hl,(checkyA)
        ld de,(checkyB)
        call maxhl_de_tode ;de>=hl
        push hl
        pop ix
        ld b,d
        ld c,e ;bc>=ix
        ld hl,(checkyC)
        ld de,(checkyD)
        call maxhl_de_tode ;de>=hl
        call checkcrossedcoord ;out: CY=crossed
        ret nc
        endif
        
;проверка пересечения AB и CD
;проверить одинаковую левость (знак векторного произведения двух сторон) треугольников ABC и BCD. Если одинаковая, то пересечение.
;Ложное срабатывание! Поэтому если левость одинаковая, надо проверить ещё левость DBA - если такая же, то пересечение.
;ложное срабатывание при палке B,A над CD ;проверяем DCA
;Как при этом гарантировать [0..1]?
;Если (A=C и B=D) или (B=C и A=D), то пересечение (чтобы не выигрывали методом наложения отрезков)
        if 1==1
        ld hl,(checkxA)
        ld de,(checkxC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noAC
        ld hl,(checkyA)
        ld de,(checkyC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noAC
        ld hl,(checkxB)
        ld de,(checkxD)
        or a
        sbc hl,de
        jr nz,checkcrossed_noAC
        ld hl,(checkyB)
        ld de,(checkyD)
        or a
        sbc hl,de
        scf
        ret z ;пересечение
checkcrossed_noAC
        ld hl,(checkxB)
        ld de,(checkxC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noBC
        ld hl,(checkyB)
        ld de,(checkyC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noBC
        ld hl,(checkxA)
        ld de,(checkxD)
        or a
        sbc hl,de
        jr nz,checkcrossed_noBC
        ld hl,(checkyA)
        ld de,(checkyD)
        or a
        sbc hl,de
        scf
        ret z ;пересечение
checkcrossed_noBC
        endif
        
;если A=C или A=D или B=C или B=D, то непересечение (примыкание) - надо проверять не координаты, а номера вершин!!! поэтому убрано тут, см. выше
        if 1==0
        ld hl,(checkxA)
        ld de,(checkxC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noACcommon
        ld hl,(checkyA)
        ld de,(checkyC)
        or a
        sbc hl,de
        ret z ;примыкание
checkcrossed_noACcommon
        ld hl,(checkxA)
        ld de,(checkxD)
        or a
        sbc hl,de
        jr nz,checkcrossed_noADcommon
        ld hl,(checkyA)
        ld de,(checkyD)
        or a
        sbc hl,de
        ret z ;примыкание
checkcrossed_noADcommon
        ld hl,(checkxB)
        ld de,(checkxC)
        or a
        sbc hl,de
        jr nz,checkcrossed_noBCcommon
        ld hl,(checkyB)
        ld de,(checkyC)
        or a
        sbc hl,de
        ret z ;примыкание
checkcrossed_noBCcommon
        ld hl,(checkxB)
        ld de,(checkxD)
        or a
        sbc hl,de
        jr nz,checkcrossed_noBDcommon
        ld hl,(checkyB)
        ld de,(checkyD)
        or a
        sbc hl,de
        ret z ;примыкание
checkcrossed_noBDcommon
        endif
        ;or a
        ;ret
        
;иначе считаем математику
        ld hl,(checkxA)
        ld (trix1),hl
        ld hl,(checkxB)
        ld (trix2),hl
        ld hl,(checkxC)
        ld (trix3),hl
        ld hl,(checkyA)
        ld (triy1),hl
        ld hl,(checkyB)
        ld (triy2),hl
        ld hl,(checkyC)
        ld (triy3),hl
        call checktriangle ;ABC
	
	if 1==1
	sbc a,a
        push hl
	push af
        ld hl,(checkxD)
        ld (trix1),hl
        ld hl,(checkyD)
        ld (triy1),hl
        call checktriangle ;DBC
	sbc a,a
	pop bc
        pop de
        xor b
        ret nz ;разная левость - нет пересечения
        ld a,h
        or l
        or d
        or e
        jr z,checkcrossed_collinear ;все 4 на одной линии - отдельная проверка
        push bc
        ld hl,(checkxA)
        ld (trix3),hl
        ld hl,(checkyA)
        ld (triy3),hl
        call checktriangle ;DBA
	sbc a,a
        pop bc
        xor b
        ret nz ;разная левость - нет пересечения
;ложное срабатывание при палке B,A над CD
;проверяем DCA
        push bc
        ld hl,(checkxC)
        ld (trix2),hl
        ld hl,(checkyC)
        ld (triy2),hl
        call checktriangle ;DCA
	sbc a,a
        pop bc
        xor b
	rla
        ccf
        ret ;одинаковая левость - есть пересечение

	else
	
        push hl
        ld hl,(checkxD)
        ld (trix1),hl
        ld hl,(checkyD)
        ld (triy1),hl
        call checktriangle ;DBC
        pop de
        ld a,h
        xor d
        rla
        ccf
        ret nc ;разная левость - нет пересечения
        push hl
        ld hl,(checkxA)
        ld (trix3),hl
        ld hl,(checkyA)
        ld (triy3),hl
        call checktriangle ;DBA
        pop bc
        ld a,h
        xor b
        rla
        ccf
        ret nc ;разная левость - нет пересечения
        ld a,h
        or l
        or d
        or e
        jr z,checkcrossed_collinear ;площадь DBC = 0 - отдельная проверка
;ложное срабатывание при палке B,A над CD
;проверяем DCA
        push hl
        ld hl,(checkxC)
        ld (trix2),hl
        ld hl,(checkyC)
        ld (triy2),hl
        call checktriangle ;DCA
        pop de
        ld a,h
        xor d
        rla
        ccf
        ret ;одинаковая левость - есть пересечение
	endif
	
checkcrossed_collinear
;отрезки на одной прямой
;отдельно проверить, что отрезки лежат друг на друге (раньше площади 0 считались как непересечение)
;найти самую большую ось (max-min)
        ld hl,(checkxA)
        ld bc,(checkxB)
        call minhl_bc_tobc
        ld (checkxminAB),bc
        push bc
        ld hl,(checkxC)
        ld bc,(checkxD)
        call minhl_bc_tobc
        ld (checkxminCD),bc
        pop hl
        call minhl_bc_tobc
;bc=minx
        ld hl,(checkxA)
        ld de,(checkxB)
        call maxhl_de_tode
        ld (checkxmaxAB),de
        push de
        ld hl,(checkxC)
        ld de,(checkxD)
        call maxhl_de_tode
        ld (checkxmaxCD),de
        pop hl
        call maxhl_de_tode
;de=maxx
        ex de,hl
        or a
        sbc hl,bc
        push hl ;maxx-minx

        ld hl,(checkyA)
        ld bc,(checkyB)
        call minhl_bc_tobc
        ld (checkyminAB),bc
        push bc
        ld hl,(checkyC)
        ld bc,(checkyD)
        call minhl_bc_tobc
        ld (checkyminCD),bc
        pop hl
        call minhl_bc_tobc
;bc=miny
        ld hl,(checkyA)
        ld de,(checkyB)
        call maxhl_de_tode
        ld (checkymaxAB),de
        push de
        ld hl,(checkyC)
        ld de,(checkyD)
        call maxhl_de_tode
        ld (checkymaxCD),de
        pop hl
        call maxhl_de_tode
;de=maxy
        ex de,hl
        or a
        sbc hl,bc ;maxy-miny
        
        pop de ;maxx-minx
        
;если нет пересечения, то должно быть max(A,B)<min(C,D) или max(C,D)<min(A,B)
        or a
        sbc hl,de ;NC: разброс по y >= разброс по x, берём y
        jr nc,checkcrossed_collinear_y
;разброс по y < разброс по x, берём x
checkxmaxAB=$+1
        ld hl,0
checkxminCD=$+1
        ld de,0
        or a
        sbc hl,de
        ccf
        ret nc ;нет пересечения
checkxmaxCD=$+1
        ld hl,0
checkxminAB=$+1
        ld de,0
        or a
        sbc hl,de
        ccf
        ret
checkcrossed_collinear_y
;разброс по y >= разброс по x, берём y
checkymaxAB=$+1
        ld hl,0
checkyminCD=$+1
        ld de,0
        or a
        sbc hl,de
        ccf
        ret nc ;нет пересечения
checkymaxCD=$+1
        ld hl,0
checkyminAB=$+1
        ld de,0
        or a
        sbc hl,de
        ccf
        ret

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

maxhl_de_tode ;de>=hl
        or a
        sbc hl,de
        add hl,de
        ret c ;de>hl
        ex de,hl
        ret ;de>=hl

checkxA
        dw 0
checkyA
        dw 0
checkxB
        dw 0
checkyB
        dw 0
checkxC
        dw 0
checkyC
        dw 0
checkxD
        dw 0
checkyD
        dw 0

checktriangle
;out: CY=левость, hl==0 вырожденность
;    x21:=vert[poly[i].v2].xscr-vert[poly[i].v1].xscr;
;    x31:=vert[poly[i].v3].xscr-vert[poly[i].v1].xscr;
;    y21:=vert[poly[i].v2].yscr-vert[poly[i].v1].yscr;
;    y31:=vert[poly[i].v3].yscr-vert[poly[i].v1].yscr;
	ld bc,tsqr/2
triy2=$+1
        ld hl,0
triy1=$+1
        ld de,0
        or a
        sbc hl,de
        ld (y21),hl
triy3=$+1
        ld hl,0
        or a
        sbc hl,de
        ld (y31),hl
trix2=$+1
        ld hl,0
trix1=$+1
        ld de,0
        or a
        sbc hl,de
	add hl,bc
        ld (x21),hl
trix3=$+1
        ld hl,0
        or a
        sbc hl,de
	add hl,bc
        ;ld (x31),hl
;    poly[i].visible := ((x21*y31 - x31*y21) > 0);
;x31=$+1
        ;ld hl,0
        ld bc,0
y21=$-2
        call mul9 ;out: CYhl ;_MULLONG. ;out: hl(high), de(low)
	 sbc a,a
	ld lx,a ;hsb
	ex de,hl
x21=$+1
        ld hl,0
        ld bc,0
y31=$-2
        call mul9 ;out: CYhl ;_MULLONG. ;out: hl(high), de(low)
	 sbc a,a
        or a
        sbc hl,de ;lsw
	sbc a,lx ;hsb
	rla ;CY=результат сравнения знаковых (LVD)
        ret

mul9
;9*9 -> 18
;можно использовать для +-319*+-192, тогда результат со знаком в CY
;hl=A+(tsqr/2) (A=+-319)
;bc=B = +-192
;A*B = ((A+B)^2)/4 - ((A-B)^2)/4 ;младшие 2 бита перед делением одинаковые слева и справа, определяются чётностью
	push hl
	add hl,bc
;hl=A+B
	add hl,hl
;CY=0
	ld (mulpatchadd),hl
	pop hl
	sbc hl,bc
;hl=A-B
	add hl,hl
;CY=0
	ld (mulpatchsub),hl
mulpatchadd=$+1
	ld hl,(0)
mulpatchsub=$+2
	ld bc,(0)
	sbc hl,bc
;HL = %rrrrrrrr rrrrrrrr
	ret

	align 2
tsqrsize=(320+200)
_=tsqrsize
	dup tsqrsize
_=_-1
	dw ((_*_)/4)&0xffff
	edup
tsqr
_=0
	dup tsqrsize
	dw ((_*_)/4)&0xffff
_=_+1
	edup


        if 1==0
;hl * de (signed = unsigned)
;out: hl
_MUL.
	ld a,h
	ld c,l
	ld hl,0
	ld b,16
_MUL0.
	add hl,hl
	rl c
	rla
	jr nc,$+3
	add hl,de
	djnz _MUL0.
	ret
        endif

	if 1==0
;hl, de * bc, ix
;out: hl(high), de(low)
_MULLONG.
	;EXPORT _MULLONG.
;signed mul is equal to unsigned mul
;hlde*bcix = hlde*b000 + hlde*c00 + hlde*i0 + hlde*x
	ld a,lx
	push af ;lx
	push ix ;hx
	ld a,c
	push af ;c
	ld a,b
;bcde <= hlde:
	ld b,h
	ld c,l
;hlix <= 0
	ld hl,0
	;ld ix,0
	push hl
	pop ix
	call _MULLONGP. ;hlix = (hlix<<8) + "b*hlde"
	pop af ;c
	call _MULLONGP. ;hlix = (hlix<<8) + "c*hlde"
	pop af ;hx
	call _MULLONGP. ;hlix = (hlix<<8) + "hx*hlde"
	pop af ;lx
	call _MULLONGP. ;hlix = (hlix<<8) + "lx*hlde"
	push ix
	pop de
	ret
;hlix = (hlix<<8) + a*bcde
_MULLONGP.
	exx
	ld b,8
_MULLONG0.
	exx
	add ix,ix
	adc hl,hl
	rla
	jr nc,$+2+2+2
	add ix,de
	adc hl,bc
	exx
	djnz _MULLONG0. ;можно по a==0 (первый вход с scf:rla, далее add a,a) ;или раскрыть цикл
	exx
	ret
	endif

setscrpgs
        ld a,(user_scr0_low)
        SETPG32KLOW
        ld a,(user_scr0_high)
        SETPG32KHIGH
        ret

        display $
SAVEDATA
level
        db 0
verticesneeded
        db 10
nvertices
        db 0

nvertices1
        db 0
nvertices2
        db 0
        
vertlinkflags
vertlist1
        ds MAXVERTICES
vertlist2
        ds MAXVERTICES

vertices
;x,X,y,Y
        ds MAXVERTICES*4
edges
;vertex1,vertex2,crossed
        ds MAXEDGES*3
nedges
        dw 0
;ncrossededges
;        dw 0
cur_h
        db 0
cur_m
        db 0
cur_s
        db 0
cur_f
        db 0

tlevel
        db "LEVEL 00"
tleveldig1=$-2
tleveldig2=$-1
        db " TIME 00:00:00"
ttimeh1=$-8
ttimeh2=$-7
ttimem1=$-5
ttimem2=$-4
ttimes1=$-2
ttimes2=$-1
nextlevelon=$ ;этот флаг надо сохранять
        db 0
        db "NEXT LEVEL"
        db 0

SAVEDATAsz=$-SAVEDATA

pal ;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
        dw 0xffff,0x6f6f,0xbdbd,0x6f6f,0x6f6f,0x4e4e,0x2d2d,0x0c0c

        macro SHAPESPROC name
name
        endm

        include "prarrow.asm"

        include "control.asm"

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "untangle.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
