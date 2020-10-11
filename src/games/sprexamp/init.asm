GO
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0|0x80 ;keep screen
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
        
;это относится к загрузке уровня
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
        ld hl,-160 ;top left
        ld (cameraym),hl
        ld (cameraymideal),hl
        ld (cameraymold),hl
        ld de,1024-160 ;top left
        add hl,de
        ld (yscroll),hl
        
        ld hl,-160 ;top left
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
        jp mainloop_uv0

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

texfilename
        ;db "WBAR.bin",0
        db "WHUM1.bin",0
        db "sfx.bin",0
        db "music.bin",0
