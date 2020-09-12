        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

OLDDRAWSPR=0;1

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
GO
        ld sp,STACK
        OS_HIDEFROMPARENT

;        ld b,25
;waitcls0
;        push bc
;        YIELD
;        pop bc
;        djnz waitcls0 ;чтобы nv не перехватил фокус при вызове через комстроку

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        LD (pgmain4000),A
        ld a,h
        LD (pgmain8000),A
        call setpgsmain40008000 ;записать в curpg...

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,l
        ;ld (setpgs_scr_low),a
	;xor e
        ;ld (setpgs_scr_scrxor),a
        ;ld a,h
         ;ld (ttexpgs+31),a ;ld (IR128),a ;на всякой случай, для прерывания
        ;xor l
        ;ld (setpgs_scr_pgxor),a

        OS_NEWPAGE
        ld a,e
        ld (pgfake),a ;эту страницу можно будет запарывать при отрисовке спрайтов с клипированием
        ld (pgfake2),a
        
	ld de,res_path
	OS_CHDIR

        call getmousedelta ;prepare mouse

        ld hl,texfilename
        ;call loadpage
        ;ld (pg0),a
        call loadpage
        ld (pg1),a
        call loadpage
        ld (pgsfx),a
        call loadpage
        ld (pgmusic),a
        SETPG16K
        push af
        call 0x4000 ;init
        
        ld a,(pgsfx)
        SETPG32KLOW
        pop af
        ld hl,0x4005 ;play
        OS_SETMUSIC
        call setpgsmain40008000
        
        ld hl,prsprqwid
        ld (0x0101),hl ;спрайты в файле подготовлены так, что выходят в 0x0100
      
        call swapimer

;UV scroll
        call uvscroll_prepare
        ;ld de,bgxyfilename
        ;call uvscroll_preparebmp
         call uvscroll_preparetiles
;TODO обновить allscroll
;allscroll=yscroll*(UVSCROLL_WID/512)+xscroll
        ;jr $
        ;ld hl,1;+(511*2)+(1023/256)
        ;ld a,1023&0xff
        ;ld (allscroll),hl
        ;ld (allscroll_lsb),a
        ld hl,-160 ;top left
        if 1==0
        ld hl,+80
        ld bc,(objects+obj.y16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        endif
        ld (cameraym),hl
        ld (cameraymideal),hl
        ld (cameraymold),hl
        ld de,1024-160 ;top left
        add hl,de
        ld (yscroll),hl
        
        ld hl,-160 ;top left
        if 1==0
        ld hl,+80
        ld bc,(objects+obj.x16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        endif
        ld (cameraxm),hl
        ld (cameraxmideal),hl
        ld (cameraxmold),hl
        ld de,2048-160 ;top left
        add hl,de
        ld (x2scroll),hl

         call uvscroll_preparetilemap

        call importcoords
        ld iy,bullets
        call genbullet_terminate

        ld de,pal
        OS_SETPAL
mainloop_uv0
        ;halt
        call uvscroll_draw ;367574/391621
        
        if OLDDRAWSPR==1
        ld ix,objects
        call drawsprites
        ld ix,bullets
        call drawsprites
        
        else
        ld de,spritesA+1
        ld ix,objects
        call preparedrawsprites ;1720
        ld ix,bullets
        call preparedrawsprites ;1110
        dec de
        ld (drawsprites_data),de
        call drawsprites ;24040 (только герой)
        endif

        ;call prcoords

        call getmousedelta ;de=delta (d>0: go up) (e>0: go left), l=mousekey
        push hl
trackcamera_addr=$+1
        ;call mousetrackcamera ;de=delta (d>0: go up) (e>0: go left) ;out: d=camera dy, e=camera dx         
        call trackcamera ;de=delta (d>0: go up) (e>0: go left) ;out: d=camera dy, e=camera dx         
        pop hl ;l=mousekey
        
        ld a,l
        bit 1,a
        jr nz,nocamoff
        ld bc,notrackcamera
        ld (trackcamera_addr),bc
nocamoff
        
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
mainloop_uvq

        if 1==1

;vertical scroll
        ld de,bgfilename
        call bgpush_prepare

        call cls
        ld de,pal;SUMMERPAL
        OS_SETPAL

        if 1==0
pg0=$+1
        ld a,0
        call setpgc000;SETPG32KHIGH
        ld hl,0x4000 ;scr
        ld de,0xc000 ;gfx
        ld bc,0xc020 ;hgt,wid
        call primgega
        endif

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

mousetrackcamera
;de=delta (d>0: go up) (e>0: go left)
;out: d=camera dy, e=camera dx
        ld hl,(cameraxm)
        ld c,e
        ld a,c
        rla
        sbc a,a
        ld b,a
        add hl,bc
        ld (cameraxm),hl
        ld hl,(cameraym)
        ld c,d
        ld a,c
        rla
        sbc a,a
        ld b,a
        add hl,bc
        ld (cameraym),hl
        ret

notrackcamera
;out: d=camera dy, e=camera dx
        ld de,0
        ret

trackcamera
;de=delta (d>0: go up) (e>0: go left)
;out: d=camera dy, e=camera dx
;двигаем смещение камеры к идеалу (xspeed16;yspeed16), но не быстрее, чем на +-CAMERASHIFTSPEED
;и находим camerax/ymideal
cameraxshift=$+1
        ld hl,0
        ld de,(objects+obj.xspeed16)
        xor a
        sbc hl,de
        or h
        jp m,xshifttoideal_neg
;hl=xshift-xshiftideal >=0
        ld bc,CAMERASHIFTSPEED_X
        sbc hl,bc
        jr c,xshifttoideal_get ;не быстрее, чем на +CAMERASHIFTSPEED_X
        jr xshifttoideal_limit
xshifttoideal_neg
;hl=xshift-xshiftideal <0
        ld bc,-CAMERASHIFTSPEED_X
        sbc hl,bc
        jr nc,xshifttoideal_get ;не быстрее, чем на -CAMERASHIFTSPEED_X
xshifttoideal_limit
        ld hl,(cameraxshift)
        or a
        sbc hl,bc
        ex de,hl
xshifttoideal_get
        ex de,hl
xshifttoideal_negq        
        ld (cameraxshift),hl
        ex de,hl

        ld hl,+80+24
        ld bc,(objects+obj.x16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        ;ld de,(objects+obj.xspeed16)
        or a
        sbc hl,de
        ld (cameraxmideal),hl

camerayshift=$+1
        ld hl,0
        ld de,(objects+obj.yspeed16)
        xor a
        sbc hl,de
        or h
        jp m,yshifttoideal_neg
;hl=yshift-yshiftideal >=0
        ld bc,CAMERASHIFTSPEED_Y
        sbc hl,bc
        jr c,yshifttoideal_get ;не быстрее, чем на +CAMERASHIFTSPEED_Y
        jr yshifttoideal_limit
yshifttoideal_neg
;hl=yshift-yshiftideal <0
        ld bc,-CAMERASHIFTSPEED_Y
        sbc hl,bc
        jr nc,yshifttoideal_get ;не быстрее, чем на -CAMERASHIFTSPEED_Y
yshifttoideal_limit
        ld hl,(camerayshift)
        or a
        sbc hl,bc
        ex de,hl
yshifttoideal_get
        ex de,hl
yshifttoideal_negq        
        ld (camerayshift),hl
        ex de,hl

        ld hl,+80+48
        ld bc,(objects+obj.y16)
         dup 3
         srl b
         rr c
         edup
        or a
        sbc hl,bc
        ;ld de,(objects+obj.yspeed16)
        or a
        sbc hl,de
        ld (cameraymideal),hl
        
;двигаем камеру к идеалу, но не быстрее, чем на +-CAMERATRACKINGSPEED
        ld hl,(cameraxm)
cameraxmideal=$+1
        ld de,0;(cameraxmideal)
        xor a
        sbc hl,de
        or h
        jp m,xmtoideal_neg
;hl=xm-xmideal >=0
        ld bc,CAMERATRACKINGSPEED_X
        sbc hl,bc
        jr c,xmtoideal_get ;не быстрее, чем на +CAMERATRACKINGSPEED_X
        jr xmtoideal_limit
xmtoideal_neg
;hl=xm-xmideal <0
        ld bc,-CAMERATRACKINGSPEED_X
        sbc hl,bc
        jr nc,xmtoideal_get ;не быстрее, чем на -CAMERATRACKINGSPEED_X
xmtoideal_limit
        ld hl,(cameraxm)
        or a
        sbc hl,bc
        ex de,hl
xmtoideal_get
        ex de,hl
xmtoideal_negq        
        ld (cameraxm),hl
cameraxmold=$+1
        ld de,0
        ld (cameraxmold),hl
        or a
        sbc hl,de ;camera dx
       push hl

        ld hl,(cameraym)
cameraymideal=$+1
        ld de,0;(cameraymideal)
        xor a
        sbc hl,de
        or h
        jp m,ymtoideal_neg
;hl=ym-ymideal >=0
        ld bc,CAMERATRACKINGSPEED_Y
        sbc hl,bc
        jr c,ymtoideal_get ;не быстрее, чем на +CAMERATRACKINGSPEED_Y
        jr ymtoideal_limit
ymtoideal_neg
;hl=ym-ymideal <0
        ld bc,-CAMERATRACKINGSPEED_Y
        sbc hl,bc
        jr nc,ymtoideal_get ;не быстрее, чем на -CAMERATRACKINGSPEED_Y
ymtoideal_limit
        ld hl,(cameraym)
        or a
        sbc hl,bc
        ex de,hl
ymtoideal_get
        ex de,hl
ymtoideal_negq        
        ld (cameraym),hl
cameraymold=$+1
        ld de,0
        ld (cameraymold),hl
        or a
        sbc hl,de ;camera dy
        
       pop bc ;camera dx
         ld d,l
         ld e,c
        ret

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
        ld hl,0;sprlistA/B/C
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


texfilename
        ;db "WBAR.bin",0
        db "WHUM1.bin",0
        db "sfx.bin",0
        db "music.bin",0

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
        ;jp setpgsmain40008000

setpgsmain40008000
pgmain4000=$+1
        ld a,0
        ;ld (curpg4000),a
        SETPG16K
pgmain8000=$+1
        ld a,0
        ;ld (curpg8000),a
        SETPG32KLOW
        ret

setpgsscr40008000_current
        call getuser_scr_low_cur
        ;ld (curpg4000),a ;TODO kill
        SETPG16K
        call getuser_scr_high_cur
        ;ld (curpg8000),a ;TODO kill
        SETPG32KLOW
        ret

setpgsscr40008000
        call getuser_scr_low
        ;ld (curpg4000),a ;TODO kill
        SETPG16K
        call getuser_scr_high
        ;ld (curpg8000),a ;TODO kill
        SETPG32KLOW
        ret

setpgscrlow4000
        call getuser_scr_low
        SETPG16K
        ret

setpgscrhigh4000
        call getuser_scr_high
        SETPG16K
        ret

getuser_scr_low
getuser_scr_low_patch=$+1
getuser_scr_low_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr1_low) ;ok
        ret

getuser_scr_high
getuser_scr_high_patch=$+1
getuser_scr_high_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr1_high) ;ok
        ret

getuser_scr_low_cur
getuser_scr_low_cur_patch=$+1
getuser_scr_low_cur_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr0_low) ;ok
        ret

getuser_scr_high_cur
getuser_scr_high_cur_patch=$+1
getuser_scr_high_cur_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr0_high) ;ok
        ret

changescrpg_current
;        ld a,(setpgs_scr_low)
;setpgs_scr_scrxor=$+1
;        xor 0
;        ld (setpgs_scr_low),a
        ld hl,getuser_scr_low_patch
        ld a,(hl)
        xor getuser_scr_low_patchN
        ld (hl),a
        ld hl,getuser_scr_high_patch
        ld a,(hl)
        xor getuser_scr_high_patchN
        ld (hl),a
        ld hl,getuser_scr_low_cur_patch
        ld a,(hl)
        xor getuser_scr_low_cur_patchN
        ld (hl),a
        ld hl,getuser_scr_high_cur_patch
        ld a,(hl)
        xor getuser_scr_high_cur_patchN
        ld (hl),a

        ld a,1
curscrnum=$+1
        xor 0
        ld ($-1),a
        ret
        
changescrpg
        ;jr $
        call changescrpg_current
        ld (curscrnum_int),a
	;ld e,a
	;OS_SETSCREEN
        ret
        
setpgc000
        ;ld (curpgc000),a
        SETPG32KHIGH
        ret

        include "sprdata.asm"

sfxplay
        push af
pgsfx=$+1
        ld a,0
        SETPG32KLOW
        pop af
        jp 0x8000 ;SFXPLAY

importcoords
        ld de,enemymapfilename
        OS_OPENHANDLE
        ld de,objects
        ld hl,MAXOBJECTS*3
        push bc
        OS_READHANDLE
        pop bc
        push hl ;size
        OS_CLOSEHANDLE
        pop bc
;bc=size
        ld hl,objects-1
        add hl,bc
        ld de,endobjects-1
        push bc
        lddr
        pop bc
        inc de
        ex de,hl ;hl=начало данных: type, x, y
        ld ix,objects+OBJSIZE ;героя перебросим отдельно
importcoords0        
        ld a,(hl) ;type
        cp TYPE_HERO
        jr nz,importcoords_nhero
        push ix
        ld ix,objects
        ld de,heroanim_standright
        ld (ix+obj.animaddr16),e
        ld (ix+obj.animaddr16+1),d
        ld (ix+obj.animtime),1
        ld (ix+obj.health),100
        call fillobjxy
        pop ix
        jr importcoords_nheroq
importcoords_nhero
        ;TODO anim from type
        ld de,heroanim_runright
        ld (ix+obj.animaddr16),e
        ld (ix+obj.animaddr16+1),d
        ld (ix+obj.animtime),1
        ;TODO health from type
        ld (ix+obj.health),19
        call fillobjxy
        ld de,OBJSIZE
        add ix,de
importcoords_nheroq
        inc hl
        dec bc
        dec bc
        dec bc
        ld a,b
        or c
        jr nz,importcoords0
        ld (ix),0xff
        ld (ix+1),0xff
        ret

fillobjxy
;hl=указатель на type, x, y
;ix=obj
        inc hl
        ld a,(hl)
        add a,3
        ld d,0
        dup 3+3
        add a,a
        rl d
        edup
        ld e,a
        ld (ix+obj.x16),e
        ld (ix+obj.x16+1),d
        inc hl
        ld a,(hl)
        ld d,0
        dup 4+3
        add a,a
        rl d
        edup
        ld e,a
        ld (ix+obj.y16),e
        ld (ix+obj.y16+1),d
        xor a
        ld (ix+obj.xspeed16),a
        ld (ix+obj.xspeed16+1),a
        ld (ix+obj.yspeed16),a
        ld (ix+obj.yspeed16+1),a
        ld (ix+obj.flags),a
        ret

        include "int.asm"
        include "cls.asm"
        include "prspr.asm"
        include "bgpush.asm"
        include "bgpushxy.asm"
        
        include "../../_sdk/file.asm"

readbmphead_pal
        ld de,bgpush_bmpbuf
        ld hl,14+2;54+(4*16)
;de=buf
;hl=size
        call readstream_file
        ld de,bgpush_bmpbuf
        ld hl,(bgpush_bmpbuf+14)
        dec hl
        dec hl
;de=buf
;hl=size
        call readstream_file
        ld de,bgpush_bmpbuf
        ld hl,+(4*16)
;de=buf
;hl=size
        call readstream_file

        ld hl,bgpush_bmpbuf;+54
        ld ix,pal
        ld b,16
recodepal0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld l,(hl) ;e=B, d=G, l=R
        call readfile_rgbtopal
        pop hl
        inc hl
        inc hl
        djnz recodepal0
        ret

readfile_rgbtopal
;e=B, d=G, l=R
        call calcRGBtopal_pp
        ld (ix+1),a
        call calcRGBtopal_pp
        ld (ix),a
        inc ix
        inc ix
        ret

calcRGBtopal_pp
;e=B, d=G, l=R
;DDp palette: %grbG11RB(low),%grbG11RB(high), ??oN????N
        xor a
        rl e  ;B
        rra
        rl l  ;R
        rra
        rrca
        rrca
        rl d  ;G
        rra
        rl e  ;b
        rra
        rl l  ;r
        rra
        rl d  ;g
        rra
        cpl
        ret 

bgpush_ldbmp_line
;hl=начало строки ld-push
;a=pushwid/2
        push bc
        ;push de

         push af
        ;push de
        push hl
        push ix
        ld de,bgpush_bmpbuf
        ld h,0
        ld l,a
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        ;ld hl,320
;de=buf
;hl=size
        push hl
        push de
        call readstream_file
        pop de
        pop hl
        add hl,de
        ex de,hl ;de=gfx end addr
        pop ix
        pop hl
        ;pop de
         pop bc
        ;pop af
        ;ld b,a
        dec de ;gfx addr
        ld a,(ix+3)
        call bgpush_ldbmp_layerline
        dec de
        dec de
        ld a,(ix+2);(ix+1)
        call bgpush_ldbmp_layerline
        dec de
        dec de
        ld a,(ix+1);(ix+2)
        call bgpush_ldbmp_layerline        
        dec de
        dec de
        ld a,(ix+0)
        call bgpush_ldbmp_layerline        
        ;pop de
        pop bc
        ret

bgpush_ldbmp_layerline
;пишем каждый четвёртый байт с конца в ld-push
;de=gfx
;hl=начало строки ld-push
;a=pg
;b=pushwid/2
        ;ld b,pushwid/2
        push bc
        SETPG32KLOW;SETPGPUSHBASE
        pop bc
        push bc
        push de
        push hl
        ;inc hl
        ;inc hl ;мы на втором байте первого слова данных в ld bc
bgpush_ldbmp_bytes0
        inc hl
        inc hl
        RECODEBYTE
        ld (hl),a
        dec hl
         dec de
         dec de
         dec de
         dec de
         dec de
         dec de
        RECODEBYTE
        ld (hl),a
        inc hl
         dec de
         dec de
         dec de
         dec de
         dec de
         dec de
        inc hl
        inc hl
        djnz bgpush_ldbmp_bytes0
        pop hl
        pop de
        pop bc
        ret

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

        align 256
font
        incbin "fontgfx"
        
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
        
end        

	display "begin=",begin
	display "end=",end
	display "Size ",/d,end-begin," bytes"
	
	savebin "sprexamp.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l"
