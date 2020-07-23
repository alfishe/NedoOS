        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

atm=1

TEXBMP=1
NTEXPGS=5
NSPRPGS=1

tempintstack=0x4000 ;2 bytes
SPOIL6BSTACK=0x3ffe;-2
STACK=SPOIL6BSTACK-6
INTSTACK=0x3e80
;scrbase=0x8000

addhlbc=1 ;можно scrhgt=200 и в одной странице
customscales=0;1

IMPOSSIBLECOLOR=0x01 ;(Ч+Б)

muz=0x8000

        org PROGSTART
begin
        ld sp,STACK

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
		
		ld de,res_path
		OS_CHDIR

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,l
        LD (pgscalersnum),A
        ld a,h
        ;push af;LD (pg8000),A
        ld (pgmuznum),a

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,l
        ;ld (setpgs_scr_low),a
	;xor e
        ;ld (setpgs_scr_xor),a
        ;ld a,d
	;xor e
        ;ld (setpgs_scr_high_xor_low),a

        ;OS_NEWPAGE
        ;ld a,e
        ;ld (pgmuznum),a
        ;SETPG32KLOW
        ld hl,wasmuz
        ld de,muz
        ld bc,wasmuz_sz
        ldir
        call muz
        
        ;pop af ;LD a,(pg8000)
        ;SETPG32KLOW

        OS_NEWPAGE
        ld a,e
        ld (pgmapnum),a

        if TEXBMP
        ld de,texfilename
        call openfile_skipbmpheader
;b=handle
        ld hl,ttexpgs+NTEXPGS-1
        ld c,NTEXPGS
gettexpgs0
        push bc
        push hl
        call ldpgrecodebmp
        
        push de
        
;2. проходим по hl правый верхний треугольник текстуры, а по de - левый нижний, меняем их местами
        ld hl,0x4000
gettexpgsrot0
        push hl    
        ld b,64
gettexpgsrot1
        push bc
        push hl
        ld d,h
        ld e,l
gettexpgsrot2
        ld c,(hl)
        ld a,(de)
        ld (hl),a
        ld a,c
        ld (de),a
        inc l
        inc d
        djnz gettexpgsrot2
        pop hl
        inc l
        inc h
        pop bc
        djnz gettexpgsrot1
        pop hl
        ld a,l
        add a,64
        ld l,a
        jr nz,gettexpgsrot0
        
        pop de
        pop hl
        ld (hl),e
        dec hl
        pop bc
        dec c
        jr nz,gettexpgs0

        OS_CLOSEHANDLE

        ld de,sprfilename
        call openfile_skipbmpheader
;b=handle
        ld hl,ttexpgs+NTEXPGS+NSPRPGS-1
        ld c,NSPRPGS
getsprpgs0
        push bc
        push hl
        call ldpgrecodebmp        
        pop hl
        ld (hl),e
        dec hl
        pop bc
        dec c
        jr nz,getsprpgs0

        OS_CLOSEHANDLE

        else
        
        ld hl,ttexpgs
        ld b,5
getttexpgs0
        push bc
        push hl
        OS_NEWPAGE
        
        push de
        ld a,e
        SETPG16K
        ld de,texfilename
        OS_OPENHANDLE
        push bc
        ld de,0x4000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
        
        ld hl,texfilenamenum
        inc (hl)
        pop de
        
        pop hl
        ld (hl),e
        inc hl
        pop bc
        djnz getttexpgs0

        endif


        LD HL,tID
REtID0  LD A,(HL)
        add a,ttexpgs&0xff
        ld e,a
        adc a,ttexpgs/256
        sub e
        ld d,a
        ld a,(de)
;basepggfx=$+1
;        ADD A,0
        LD (HL),A
        INC L
        INC L
        jr NZ,REtID0

        ld ix,tscales
        ld hl,tscales_rev
        ld b,64
revscale0
        push bc
        push hl
        ld c,(ix)
        inc ix
        ld b,(ix)
        inc ix
        ld de,256
;деление
;DE=+-7.8;BC=+7.8
;DE=DE/BC=+-8.7/2
    ;BC сохраняется!!!
        call MONDIV
        pop hl
        sla e
        rl d
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        pop bc
        djnz revscale0

        ;YIELD ;иначе не установится видеорежим и палитра?

        if 1==0 ;нельзя при интерполяции
        ld hl,tlogd2sca
retlogd2sca0
        sla (hl)
        sla (hl)
        inc l
        jr nz,retlogd2sca0
        endif

        call genscalers

        call swapimer

        call TEXCODEGO
        
        call swapimer
        
        call shutay        
        QUIT

        if 1==0
setpgsscr40008000_current
        call getuser_scr_low_cur
        SETPG16K
        call getuser_scr_high_cur
        SETPG32KLOW
        ret

setpgsscr40008000
        call getuser_scr_low
        SETPG16K
        call getuser_scr_high
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
        endif

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
         ;add a,a
         ;add a,a
         ;add a,a
         ;ld (imer_curscreen_value),a
        ret
        
changescrpg
        ;jr $
        call changescrpg_current
        ;ld (curscrnum_physical),a
	ld e,a
	OS_SETSCREEN
        ret

openfile_skipbmpheader
        OS_OPENHANDLE
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,14+2;0x0076 ;size
        OS_READHANDLE ;b=handle
        pop bc
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,(bmpbuf+14)
        dec hl
        dec hl
        OS_READHANDLE ;b=handle
        pop bc
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,4*16;0x0076 ;size
        OS_READHANDLE ;b=handle
        pop bc
        ret

ldpgrecodebmp
        push bc
        OS_NEWPAGE
        ld a,e
        SETPG16K
        pop bc ;b=handle
        push de
        
        ld de,0x4000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE

        ld hl,0x4000
        ld d,trecolor/256
gettexpgsrecode0
        ld e,(hl)
        ld a,(de)
        ld (hl),a
        inc hl
        bit 7,h
        jr z,gettexpgsrecode0

;повернуть текстуры на 90 градусов (для стен, а для спрайтов просто перевернуть?)
;1. переворот текстур
        ld hl,0x4000
        ld de,0x4000+0x3f00
        ld b,32
gettexpgsturn0
gettexpgsturn1
        ld c,(hl)
        ld a,(de)
        ld (hl),a
        ld a,c
        ld (de),a
        inc l
        inc e
        jr nz,gettexpgsturn1
        inc h
        dec d
        djnz gettexpgsturn0
        
        pop de ;e=pg
        ret

shutay
	ld de,0xe00
shutay0
	dec d
	ld bc,0xfffd
	out (c),d
	ld b,0xbf
	out (c),e
	jr nz,shutay0
	ret
	
texfilename
        if TEXBMP
        db "wolftex.bmp",0
        else
        db "wolftex.0",0
texfilenamenum=$-2
        endif
sprfilename
        db "wolfspr.bmp",0

        align 256
ttexpgs
        ds NTEXPGS+NSPRPGS

setpgmap4000
pgmapnum=$+1
        ld a,0
        SETPG16K
        ret

swapimer
	di
         ld hl,(0x0038+3) ;адрес intjp
         ld (intjpaddr),hl        
         ld hl,(0x0026) ;ok
         ld (on_int_0026),hl
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038

on_int
;restore stack with de
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	pop hl
	ld (on_int_sp2),sp
        ld (on_int_jp),hl
;intjpaddr=$+1
;	ld (0),hl ;(on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
;imer_curscreen_value=$+1
;         ld a,0
;         ld bc,0x7ffd
;         out (c),a

	ex de,hl;ld hl,0
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек

on_int_0026=$+1
        ld hl,0
        ld (0x0026),hl ;восстановили запоротый стек 0x0028 (=40)

        ld hl,on_int_q
intjpaddr=$+1
	ld (0),hl
        
        push ix
        push iy
        ex af,af'
        exx
        push af
        push bc
        push de
        push hl
        ld a,(curscrnum)
        ld e,a
        OS_SETSCREEN ;вызываем здесь, а не в рандомном месте, иначе даже с одной задачей можем получить непредсказуемую задержку, которую не фиксирует наш таймер? с несколькими задачами надо учитывать и системный - TODO
        
        if atm
        
curpalette=$+1
        ld de,wolfpal
        OS_SETPAL
        
        ld a,(CURPG32KLOW) ;ok
        push af
pgmuznum=$+1
        ld a,0
        SETPG32KLOW
        call muz+6
        ;TODO music + sound effects in OS_SETMUSIC
        pop af
        SETPG32KLOW
        
        GET_KEY
        or a
        jr z,$+5
        ld (curkey),a
        
        else
curpg=$+1
        ld a,0
        setpgafast
        endif
        
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af'
        pop iy
        pop ix
        
	ld hl,(timer)
	inc hl
	ld (timer),hl

	pop de
	pop bc
	pop af
	
on_int_hl=$+1
	ld hl,0
;on_int_sp2=$+1
;	ld sp,0
;        ei
;on_int_jp=$+1
;	jp 0

        ld sp,tempintstack
        push de
        ex de,hl
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        jp 0x0038+5

;вход в стандартный обработчик:
        ;ex de,hl ;de="hl", hl="de"
        ;ex (sp),hl ;hl=адрес выхода, de="hl", в стеке "de"
        ;ld (intjp),hl ;TODO писать не прямо в intjp, а в промежуточную локацию (иначе хвост обработчика нельзя с ei - он сам не может сменить режим обработки прерывания после jp)
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        ;ld l,a
;user_fdvalue6=$+1
        ;ld a,fd_system
        ;out (0xfd),a ;10 b

on_int_q
;на выходе из стандартного обработчика в стеке "de"
;восстановим как надо
on_int_sp2=$+1
	ld sp,0
on_int_jp=$+1
	jp 0

wolfpal
        dw 0xffff,0x0c0c,0x3f3f,0xdede,0xfefe,0xdfdf,0x4c4c,0xaeae
        dw 0xbdbd,0xfdfd,0xbfbf,0xeded,0x8d8d,0x7d7d,0xecec,0x1f1f

        include "WATM2.asm"

scale2ytop
;bc=scale
;out: de=Y, lx=y
        XOR A
        LD L,A
        ld H,A
        SBC HL,BC ;-scale = -0x40..-0x410
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL ;*32 = -0x800..-0x8200
        EXD 
        LD LX,E
        LD a,D
        LD D,-1
        ADD A,Ycenter ;0x64
        LD E,A
        ret nc ;jr NC,$+3
        INC D
        ret

YtoADDR
       PUSH HL
        LD H,D
        ld L,E
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE ;*5
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL ;*40
        LD DE,scrbase
        ADD HL,DE
;genX=$+1
;        LD DE,0
;        ADD HL,DE
        EXD 
       POP HL
        RET 
        ;align 256;DS .(-$)
tscales
       IF customscales == 0
        INCBIN "scalesw3" ;сначала мелкие
       ELSE 
        DS 8,5,0
        DS 7,6,0
        DS 6,7,0
        DS 5,8,0
        DS 4,9,0
        DS 3,10,0
        DS 2,11,0
        DS 1,12,0
        DS 1,13,0
        DS 1,14,0
        DS 1,15,0
        DS 1,16,0
        DS 1,17,0
        DS 1,18,0
        DS 1,19,0
        DS 1,20,0
        DS 1,21,0
        DS 1,22,0
        DS 1,23,0
        DS 1,24,0
        DS 1,25,0
        DS 1,26,0
        DS 1,27,0
        DS 1,28,0
        DS 1,29,0
        DS 1,30,0
        DS 1,31,0
        DS 1,32,0
        DS 1,33,0
        DS 1,34,0
        DS 1,35,0
        DS 1,36,0
        DS 1,38,0
        DS 1,40,0
        DS 1,42,0
        DS 1,44,0
        DISPLAY $-tscales,"=#80"
       ENDIF 
tscales_rev
        ds 128

tsprites
;pg,xmid,xleft-1,xright-1
        macro TSPRITES pg,xleft,wid
xright=xleft+wid
xmid=(xleft+xright)/2
        db NTEXPGS+pg
        db xmid/2
        db xleft/2
        db xright/2
        endm
;TODO надо правильно центровать
        ;TSPRITES 0,0,0 ;ID 0 not used
        TSPRITES 0,0,44 ;ID 1
        TSPRITES 0,44,42
        TSPRITES 0,86,36
        TSPRITES 0,122,56
        TSPRITES 0,178,40
        TSPRITES 0,218,48
        TSPRITES 0,266,36
        TSPRITES 0,302,56
        TSPRITES 0,358,38
        TSPRITES 0,396,50 ;10
        TSPRITES 0,448,24
        TSPRITES 0,472,26

MONSTAB
;ZOMBIEMAN stay
        db 1
        db 2
        db 1
        db 2
        db 1
        db 2
        db 0,0
;ZOMBIEMAN go1
        db 3
        db 4
        db 5
        db 6
        db 3
        db 4
        db 0,0
;ZOMBIEMAN go2
        db 7
        db 8
        db 9
        db 10
        db 7
        db 8
        db 0,0
;AMMO
        db 12 ;G
        db 12 ;R
        db 12 ;MEGAHEALTH
        db 12 ;RL
        db 12 ;AMMO
        db 12
        db 0,0
;STOLB
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11
        db 11

        if 1==0
        DS ((-$)&7)&0xff
MONSTRS
;Xx,Yy,TYPEphase,TIMEenergy
        DW #0F80,#AF80,#000,-1;ENEMY
        DW #2680,#A080,#000,64
        DW #0380,#BA80,#000,64
        DW #0780,#B780,#000,64

        DW #0F80,#B080,#002,64
        DW #1380,#A080,#000,64
        DW #1380,#AA80,#000,64
        DW #1380,#B280,#000,64
        DW #1380,#B380,#000,64
        DW #1280,#B580,#002,64
        DW #1480,#AB80,#000,64
        DW #1480,#AE80,#002,64

        DW #1480,#B080,#002,64
        DW #1480,#B380,#000,64
        DW #1580,#A180,#002,80
        DW #1680,#AD80,#002,90
        DW #1680,#B180,#002,100
        DW #2180,#AD80,#002,10
        DW #2380,#A080,#000,50
        DW #2380,#A580,#002,50

        DW #2680,#A480,#003,50
        DW #2680,#B280,#004,50
        DW #2780,#A880,#005,50
        DW #2780,#B180,#003,64

        DW #2780,#A380,#100,150
        DW #2080,#A580,#101,100
        DW #2280,#A580,#102,100
        DW #2580,#A080,#103,20
        DW #2080,#A080,#104,40

        DW #1380,#A2C0,#200,0
        DW #1380,#A440,#200,0
        DW #1280,#A2C0,#200,0
        DW #1280,#A440,#200,0
        DW #1180,#A2C0,#200,0
        DW #1180,#A440,#200,0
        DW #1080,#A2C0,#200,0
        DW #1080,#A440,#200,0
        DW #0F80,#A2C0,#200,0
        DW #0F80,#A440,#200,0
        DW #0E80,#A2C0,#200,0
        DW #0E80,#A440,#200,0
        DW #0D80,#A2C0,#200,0
        DW #0D80,#A440,#200,0
        DW -1
eNDMONS
        endif

level
        DB "W"
gfxnr   DB "0"
muznr   DB "A"
pol     DB #E7
potolok DB #F3
color   DB 7
levname DS 23
        DB 0
monstrs DB 0
prizes  DW 0 ;$$$/10
EXITx   DB 23
EXITy   DB 15+0xA0
yx      DW 0x8080
YX      DW 0xBA08
angle   DW 64
endlev

        DS ((-$)&7)&0xff
MONSTRS
;Xx,Yy,TYPEphase,TIMEenergy
        ;DW -1

;сейчас TYPE кодируется так (что видно в редакторе: что в TYPE):
;31: вход
;29: выход
;32..63: goods (58..63: gold 5,10,20,50,100,200)
;1..28: monsters

;        ds 64
;INTSTACK

        align 256
trecolor
;%00003210 => %.3...210
        dup 256
_3=$&8
_210=$&7
_3L=($>>4)&8
_210L=($>>4)&7
        db (_3L*0x08) + (_210L*0x01) + (_3*0x10) + (_210*0x08)
        edup

bmpbuf

        display "free before stack=",0x3e00-$

        ds 0x8000-$

       IF atm
        ;ORG #C000;,pgscalers
        ;ds 0xc000-$
        ;INCBIN "scalers"
wasmuz
        incbin "DOOM-MUS" ;TODO load
wasmuz_sz=$-wasmuz

        include "genscale.asm"

        display "WASMAP=",$
WASMAP
        INCBIN "mapatm.E" ;TODO load
szMAP=$-WASMAP

res_path
	defb "wolf3d",0
      

       else ;~atm
WASMAP
        INCBIN "map48.E"
szMAP=$-WASMAP
        ;ORG #C000,pgscale
        ds 0xc000-$
      IF 1
        INCBIN "48kblock" ;with 48K textures
      ELSE 
       IF scale64
       IF scale64 == 3
        INCBIN "tscale3"
       ELSE 
        INCBIN "tscale2"
       ENDIF 
       ELSE 
        INCBIN "tscale"
       ENDIF 
      ENDIF 
       ENDIF 
end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "wolf3d.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
