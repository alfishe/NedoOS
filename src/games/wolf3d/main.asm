        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

STACK=0x4000
scrbase=0x8000

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
        push af;LD (pg8000),A

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
        ld (pgmuznum),a
        SETPG32KLOW
        ld hl,wasmuz
        ld de,muz
        ld bc,wasmuz_sz
        ldir
        call muz
        
        pop af ;LD a,(pg8000)
        SETPG32KLOW

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
        
        call shutay        
        QUIT
res_path
		defb "wolf3d",0

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
         ld hl,(0x0038+3) ;адрес intjp
         ld (intjpaddr),hl        
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
intjpaddr=$+1
	ld (0),hl ;(on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
imer_curscreen_value=$+1
         ld a,0
         ld bc,0x7ffd
         out (c),a

	ex de,hl;ld hl,0
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек
        
        push ix
        push iy
        ex af,af'
        exx
        push af
        push bc
        push de
        push hl
        ld a,(curscreen)
        ld e,a
        OS_SETSCREEN ;вызываем здесь, а не в рандомном месте, иначе даже с одной задачей можем получить непредсказуемую задержку, которую не фиксирует наш таймер? с несколькими задачами надо учитывать и системный - TODO
curpalette=$+1
        ld de,wolfpal
        OS_SETPAL
        
        ld a,(CURPG32KLOW)
        push af
pgmuznum=$+1
        ld a,0
        SETPG32KLOW
        call muz+6
;pg8000=$+1
;        ld a,0
        pop af
        SETPG32KLOW
        
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
on_int_sp2=$+1
	ld sp,0
;        ei
;on_int_jp=$+1
;	jp 0

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

        include "WATM2.asm"

        include "genscale.asm"

        ;ds 64
INTSTACK


       IF atm
        ;ORG #C000;,pgscalers
        ;ds 0xc000-$
        ;INCBIN "scalers"
wasmuz
        incbin "DOOM-MUS"
wasmuz_sz=$-wasmuz
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

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "wolf3d.com",begin,end-begin
	
	;LABELSLIST "..\us\user.l"
