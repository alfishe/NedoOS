        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

STACK=0x4000
scrbase=0x8000

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

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,l
        LD (pgscalersnum),A

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,l
        ld (setpgs_scr_low),a
	xor e
        ld (setpgs_scr_xor),a
        ld a,d
	xor e
        ld (setpgs_scr_high_xor_low),a

        OS_NEWPAGE
        ld a,e
        ld (pgmapnum),a

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
         ;jr $
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

        ;YIELD ;иначе не установится видеорежим и палитра?

        call genscalers

        call swapimer

        call TEXCODEGO
        
        call swapimer
        
        QUIT

texfilename
        db "wolftex.0",0
texfilenamenum=$-2

ttexpgs
        ds 5

setpgmap4000
pgmapnum=$+1
        ld a,0
        SETPG16K
        ret

swapimer
	di
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
;if stack in 0x4000..0x7fff:
;restore stack from pgaddrstackcopy (set in 0x4000 temporarily, then set pgaddrstack)
;else restore stack with de;0
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	;ld (on_int_spcopy),sp
	pop hl
	ld (on_int_sp2),sp
	ld (on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
imer_curscreen_value=$+1
         ld a,0
         ld bc,0x7ffd
         out (c),a

	ex de,hl;ld hl,0
        if 1==0
	ld a,(on_int_sp+1)
	sub 0x40
	cp 0x3f ;запас, чтобы не захватить очистку экрана в 0x8000
	jr nc,on_int_norestoredata
	;jr $
	ld a,(pgaddrstackcopy)
	SETPG16K
on_int_spcopy=$+1
	ld hl,(0)
        ;if RESTOREPG16K==0
	ld a,(pgaddrstack)
	SETPG16K
        ;endif
on_int_norestoredata
        endif
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек
        
	ld hl,(timer)
	inc hl
	ld (timer),hl

	pop de
	pop bc
	pop af
	
on_int_hl=$+1
	ld hl,0
on_int_sp2=$+1
	ld sp,0
        ei
on_int_jp=$+1
	jp 0

        include "WATM2.asm"

        include "genscale.asm"

        ;ds 64
INTSTACK


       IF atm
        ;ORG #C000;,pgscalers
        ;ds 0xc000-$
        ;INCBIN "scalers"
       else
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

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "wolf3d.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
