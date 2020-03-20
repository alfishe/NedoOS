        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=200
clswid=40 ;*8
clshgt=200

STACK=0x4000
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00

        org PROGSTART
begin
        jp $+3 ;/prsprqwid (спрайты в файле подготовлены так, что выходят сюда)
        ld sp,STACK

        ld b,25
waitcls0
        push bc
        YIELD
        pop bc
        djnz waitcls0 ;чтобы nv не перехватил фокус при вызове через комстроку

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

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,l
        ld (setpgs_scr_low),a
	xor e
        ld (setpgs_scr_scrxor),a
        ld a,h
         ;ld (ttexpgs+31),a ;ld (IR128),a ;на всякой случай, для прерывания
        xor l
        ld (setpgs_scr_pgxor),a
        
        OS_NEWPAGE
        ld a,e
        ld (pgfake),a ;эту страницу можно будет запарывать при отрисовке спрайтов с клипированием
        
        call bgpush_prepare

	ld de,res_path
	OS_CHDIR

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

        call cls
        ld de,pal;SUMMERPAL
        OS_SETPAL

pg0=$+1
        ld a,0
        SETPG32KHIGH
        ld hl,0x4000 ;scr
        ld de,0xc000 ;gfx
        ld bc,0xc020 ;hgt,wid
        call primgega

mainloop
        ld hl,callpush_curscroll
        ld a,(hl)
        sub 1
        jr nc,$+4
        add a,pushhgt
        ld (hl),a

        call bgpush_draw

pg1=$+1
        ld a,0
        SETPG32KHIGH
        ld iy,(0xc000);testspr
        ld e,100+(sprmaxwid-1) ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        ld c,100 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        call prsprega
        ld iy,(0xc000);testspr
        ld e,110+(sprmaxwid-1) ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        ld c,120 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        call prsprega
        
        call changescrpg ;с этого момента можем видеть, что нарисовали
        
;waitkey
        halt ;в играх не юзаем YIELD, иначе может сработать чужой обработчик прерываний
curkey=$+1
        ld a,0
        cp key_esc
        jr nz,mainloop;waitkey
        
        call swapimer
pgmusic=$+1
        ld a,0
        SETPG16K
        ld hl,0x4008 ;stop
        OS_SETMUSIC
        halt
        QUIT

loadpage
;заказывает страничку и грузит туда файл (имя файла в hl)
;out: hl=после имени файла, a=pg
        push hl
        OS_NEWPAGE
        pop hl
        ld a,e
        push af ;pg
        SETPG32KHIGH
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
        ld (curpg4000),a
        SETPG16K
pgmain8000=$+1
        ld a,0
        ld (curpg8000),a
        SETPG32KLOW
        ret

setpgsscr40008000_current
        ld a,(setpgs_scr_scrxor)
        jr setpgsscr40008000_go
setpgsscr40008000
        xor a
setpgsscr40008000_go
setpgs_scr_low=$+1
        xor 0
        ld (curpg4000),a
        SETPG16K
setpgs_scr_pgxor=$+1
        xor 0
        ld (curpg8000),a
        SETPG32KLOW
        ret
        
setpgscrlow4000
        ld a,(setpgs_scr_low)
        ld (curpg4000),a
        SETPG16K
        ret
setpgscrhigh4000
        ld a,(setpgs_scr_low)
        ld hl,setpgs_scr_pgxor
        xor (hl)
        ld (curpg4000),a
        SETPG16K
        ret

changescrpg_current
        ld a,(setpgs_scr_low)
setpgs_scr_scrxor=$+1
        xor 0
        ld (setpgs_scr_low),a
        ld a,1
curscrnum=$+1
        xor 0
        ld ($-1),a
        ret
        
changescrpg
        call changescrpg_current
	ld e,a
	OS_SETSCREEN
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

        include "int.asm"
        include "cls.asm"
        include "prspr.asm"
        include "bgpush.asm"
        
res_path
        db "sprexamp",0 ;в этом относительном пути будут лежать все загружаемые данные игры
end        

	display "begin=",begin
	display "end=",end
	display "Size ",/d,end-begin," bytes"
	
	savebin "sprexamp.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
