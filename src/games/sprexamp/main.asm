        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=192-16;200
clswid=40 ;*8
clshgt=200

STACK=0x3ff0 ;место для вылетания за экран
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3b80;0x3f00 ;чтобы не запороть стек загрузки bmp в bgpush

MAXSPEED=8*8-4
CAMERATRACKINGSPEED_X=16 ;double pixels
CAMERATRACKINGSPEED_Y=16
CAMERASHIFTSPEED_X=4 ;double pixels
CAMERASHIFTSPEED_Y=4

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
        jp $+3 ;/prsprqwid (спрайты в файле подготовлены так, что выходят сюда)
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
        call loadpage
        ld (pg0),a
        call loadpage
        ld (pg1),a
        call loadpage
        ld (pgmusic),a
        SETPG16K
        push af
        call 0x4000 ;init
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
        ld de,pal
        OS_SETPAL
mainloop_uv0
        ;halt
        call uvscroll_draw

        call drawsprites

        call prcoords

        call getmousedelta ;de=delta (d>0: go up) (e>0: go left), l=mousekey
        
        push hl

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
        pop hl ;l=mousekey
        
        ld a,l ;hl=(sysmousebuttons)
        rra
         jr nc,mainloop_uvq ;LMB
        call uvscroll_scroll
        call uvscroll_scrolltiles
        
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

        jp mainloop_uv0
mainloop_uvq
;vertical scroll
        ld de,bgfilename
        call bgpush_prepare

        call cls
        ld de,pal;SUMMERPAL
        OS_SETPAL

pg0=$+1
        ld a,0
        call setpgc000;SETPG32KHIGH
        ld hl,0x4000 ;scr
        ld de,0xc000 ;gfx
        ld bc,0xc020 ;hgt,wid
        call primgega

mainloop
        ld bc,-1
        call bgpush_inccurscroll

        call bgpush_draw ;359975t

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
curkey=$+1
        ld a,0
        cp key_esc
        jp nz,mainloop;waitkey
        
        call swapimer
pgmusic=$+1
        ld a,0
        SETPG16K
        ld hl,0x4008 ;stop
        OS_SETMUSIC
        halt
        QUIT

logic
        ld ix,objects
logic0
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

        ld a,(pgmetatilemap)
        SETPG32KHIGH

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
         ld de,8*8
         or a
         sbc hl,de
         add hl,de
         jr c,gravityok
         ex de,hl
gravityok
        ld (ix+obj.yspeed16+0),l
        ld (ix+obj.yspeed16+1),h
        
;check floor
        push hl
        ld l,(ix+obj.y16+0) ;*8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,32*8
         add hl,de ;координата прямо под ногами
        call gettile_bycoords
        pop hl
        ld c,(ix+obj.y16+0)
        ld b,(ix+obj.y16+1)
        add hl,bc
        cp 32
         res 0,(ix+obj.flags) ;not on floor
        jr c,nofloor
         set 0,(ix+obj.flags) ;not on floor
;выравнивание по y на 16(пикс)*8
        ld a,l
        and 128
        ld l,a
        ;dec hl
        push hl   
        ld hl,0
        ld (ix+obj.yspeed16+0),l
        ld (ix+obj.yspeed16+1),h
        pop hl
nofloor
        ld (ix+obj.y16+0),l
        ld (ix+obj.y16+1),h

        ld bc,OBJSIZE
        add ix,bc
        bit 7,(ix+obj.y16+1) ;yhigh
        jp z,logic0

;hero control 
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
        ld ix,objects
        ld l,(ix+obj.xspeed16+0)
        ld h,(ix+obj.xspeed16+1)
        bit 1,c
        jr z,noleft
        ld a,h
        or a
        jp m,nostartrunleft
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
         ld de,heroanim_stand
        ld (ix+obj.animaddr16+0),e
        ld (ix+obj.animaddr16+1),d
leftq
        ld (ix+obj.xspeed16+0),l
        ld (ix+obj.xspeed16+1),h
;проверить, что не въехали в стену в текущем направлении и отскочить
       push bc
        bit 7,h
        jr nz,checkleftwall
        ld l,(ix+obj.y16+0) ;*8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,16*8
         add hl,de ;координата на уровне пояса
        call gettile_bycoords
        dec l
        ld a,(hl) ;правее центра
        cp 64 ;beton
        jr c,checkleftwallq ;not beton
;врезались справа, выравниваем x = (x&0xf0) - 1
        ld l,(ix+obj.x16+0) ;*8 (in double pixels)
        ld h,(ix+obj.x16+1)
        ld a,l
        and -8*8
        ld l,a
        dec hl
        ld (ix+obj.x16+0),l ;*8 (in double pixels)
        ld (ix+obj.x16+1),h        
        jr checkleftwallq
checkleftwall
        ld l,(ix+obj.y16+0) ;*8
        ld h,(ix+obj.y16+1)
        ld c,(ix+obj.x16+0) ;*8 (in double pixels)
        ld b,(ix+obj.x16+1)
         ld de,16*8
         add hl,de ;координата на уровне пояса
        call gettile_bycoords
        inc l
        ld a,(hl) ;левее центра
        cp 64 ;beton
        jr c,checkleftwallq ;not beton
;врезались слева, выравниваем x = (x+15)&0xf0
        ld l,(ix+obj.x16+0) ;*8 (in double pixels)
        ld h,(ix+obj.x16+1)
        ld bc,8*8-1
        add hl,bc
        ld a,l
        and -8*8
        ld l,a
        ld (ix+obj.x16+0),l ;*8 (in double pixels)
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

drawsprites
pg1=$+1
        ld a,0
        call setpgc000
        
        ld ix,objects
drawsprites0       

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

;храним x*8 (in double pixels),y*8
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
        bit 7,(ix+obj.y16+1) ;yhigh
        jr z,drawsprites0
;817000(prsprega)/793000(prspr)t на всё

        ;ld iy,(0xc000);testspr
        ;ld e,110+(sprmaxwid-1) ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        ;ld c,120 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        ;call prsprega

        jp setpgsmain40008000


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
        db "WBAR.bin",0
        db "WHUM1.bin",0
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

testspr=$+4
_hgt=16
_wid=8 ;width/2
        db _wid
        db _hgt
_=_wid
        dup _wid
        dup _hgt*2
        db (0xaa+$)&0xff
        edup
_=_-1
        if _ != 0
        dw 0x4000 - ((_hgt-1)*40)
        else
        dw 0xffff
        endif
        edup
        dw prsprqwid



HERO0=0xc000+(24*2)
HERO1=0xc000+(25*2)
HERORUNRIGHT0=0xc000+(26*2)
HERORUNRIGHT1=0xc000+(27*2)
HERORUNRIGHT2=0xc000+(28*2)
HERORUNLEFT0=0xc000+(29*2)
HERORUNLEFT1=0xc000+(30*2)
HERORUNLEFT2=0xc000+(31*2)

heroanim_stand
        dw HERO0
        db 25
        dw HERO1
        db 25
        dw heroanim_stand
heroanim_runright
        dw HERORUNRIGHT0
        db 4
        dw HERORUNRIGHT1
        db 4
        dw HERORUNRIGHT2
        db 4
        dw heroanim_runright
heroanim_runleft
        dw HERORUNLEFT0
        db 4
        dw HERORUNLEFT1
        db 4
        dw HERORUNLEFT2
        db 4
        dw heroanim_runleft

        STRUCT obj
y16     WORD
x16     WORD
;sprite16 WORD
animtime BYTE
animaddr16 WORD
xspeed16 WORD
yspeed16 WORD
health  BYTE
flags   BYTE ;b0=on ground, b1=jump not released, b2=blinking, b4=провалиться
sz
        ENDS

OBJSIZE=obj.sz
objects
;y16 (*8)
;x16 (*8) (in double pixels)
;animtime
;animaddr16
;xspeed16
;yspeed16
;health
_=0
_x=10
        dup 1
_y=100
        dup 1;  3
        
        dw 8*_y ;y
        dw 8*(_x+(sprmaxwid-1)) ;x
        ;dw HERO0
        db 1
        dw heroanim_stand
        dw 1
        dw 0
        db 100
        db 0 ;flags
_=_+1
_y=_y+40
        edup
_x=_x+20
        edup
        dw -1

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

        align 256
font
        incbin "fontgfx"
        
res_path
        db "sprexamp",0 ;в этом относительном пути будут лежать все загружаемые данные игры
bgfilename
        db "bg6-16c.bmp",0
bgxyfilename
        db "bg8-16d.bmp",0

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

bgpush_bmpbuf
        ds 1024;320 ;заголовок bmp или одна строка
end        

	display "begin=",begin
	display "end=",end
	display "Size ",/d,end-begin," bytes"
	
	savebin "sprexamp.com",begin,end-begin
	
	LABELSLIST "../../../us\user.l"
