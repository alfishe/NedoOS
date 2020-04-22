; Чёрный Ворон (С) Медноногов В.С, 1996,97
        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

scrbase=0x4004;0
sprmaxwid=32;24
sprmaxhgt=32;24
scrwid=96 ;double pixels
scrhgt=192

EGA=1
        
;*L+
;*D-
SCR     EQU #C000
ATR     EQU #D800
;-----------------------
STACK=0x4000
tempsp=0x3f06 ;6 bytes
DBL_SP=0x3f00 ;INTSTACK
;timer=0x3f00 ;???

;D$      MAC ;debug
;        DI
;        HALT
;        EI
;        ENDM

;M$      MAC
;        LD      A,=0
;        CALL    MEM
;        ENDM

        macro ATRs _hl,_bc,_e
	LD	HL,_hl;=0
	LD	BC,_bc;=1
	LD	E,_e;=2
	CALL	ATRBAR
	ENDM

        macro PUSHs
        PUSH    HL
        PUSH    DE
        PUSH    BC
        ENDM
        macro POPs
        POP     BC
        POP     DE
        POP     HL
        ENDM

        slot 0
        page 8

        slot 3
        page 0
        org PROGSTART
begin
        jp begingo ;/prsprqwid
        jp _128
        jp swapimer
_128
        push bc
        ;LD	BC,#7FFD
	LD	(R128),A
	;OUT	(C),A
        ;and 7
        ld ($+3+1),a
        ld a,(ttexpgs)
	;LD	(R128),A
        SETPG32KHIGH
        pop bc
	RET
R128
        db 0

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
        EX DE,HL
	EX (SP),HL
intjpaddr=$+1
	LD (0),hl ;(on_int_jp),HL
	;EX DE,HL
	;POP DE
	LD (on_int_sp2),SP
	LD SP,DBL_SP
	CALL INAR0
on_int_sp2=$+1
	ld sp,0
;	EI
;on_int_jp=$+1
;	jp 0
        ;push de
        ;ex de,hl
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


        align 256 ;0x200
ttexpgs
        ds 32 ;pg31=scr7

        include "w_intv.asm"
        include "wlib1a.asm"
        include "wlid.asm"
        include "wmisc_4.asm"
br_path
		defb "br",0
begingo
        ld sp,STACK

        ld e,3
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        ld b,25
waitcls0
        push bc
        YIELD
        pop bc
        djnz waitcls0 ;чтобы nv не затёр pg7
        
		ld de,br_path
		OS_CHDIR
       if EGA
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        LD (pgmain4000),A
        ld a,h
        LD (pgmain8000),A
       endif

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,l
       if EGA
        ld (setpgs_scr_low),a
       endif
	xor e
       if EGA
        ld (setpgs_scr_scrxor),a
       endif
        ld a,h
         ld (ttexpgs+31),a ;ld (IR128),a ;на всякой случай, для прерывания
       if EGA
         ;ld (scrpg7),a
       else 
         ld (getttexpgs_basepg7),a
       endif
       if EGA
        xor l
        ld (setpgs_scr_pgxor),a
       endif
        
;не будем брать физические страницы, кроме 7, т.к. pg4 используется для запарывания осью

        if EGA
        OS_NEWPAGE
        ld a,e
        ld (pgfake),a
        endif

        if 1==1
        
        ld hl,texfilename
        ld b,ntexfilenames
getttexpgs0
        push bc
        ld a,(hl)
       if EGA==0
        cp 7
getttexpgs_basepg7=$+1
        ld a,0
        jr z,getttexpgs7
       endif
        push de
        push hl
        OS_NEWPAGE
        ld a,e
        pop hl
        pop de
getttexpgs7
        ld c,(hl)
        ld b,ttexpgs/256
        ld (bc),a
        inc hl
        push hl
        SETPG32KHIGH

        ld a,(hl)
        cp ' '
        jr nc,gettexpgs_noskipdata
         ;jr $
        inc hl
gettexpgs_noskipdata
        ex de,hl
        push af
        OS_OPENHANDLE
        pop af ;CY=skip data, a=number of 8Ks to skip
        jr nc,gettexpgs_noskipdata2
        push bc
        ld de,0
        ld hl,0
        rra
        rr h
        rra
        rr h
        rra
        rr h
        OS_SEEKHANDLE ;dehl=offset
        pop bc
gettexpgs_noskipdata2
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
        pop bc
        djnz getttexpgs0

        endif
        
        if EGA
;показываем флажки
        call MEM7
        call setpgsscr40008000 ;scr1
        ld hl,0xc000
        ld de,0x8000
        ld bc,0x1b00
        ldir
        call setpgsmain40008000
        endif
        
        
        if EGA
        ld hl,prsprqwid
        ld (0x0101),hl
        endif
        
        if EGA
        call changescrpg ;на всякий случай, для заполнения переменных
        call setpgsmain40008000 ;на всякой случай, для прерывания
        endif
      
        call swapimer
        jp JP_ST;wMAIN;GO
        ;call GO
        ;call swapimer
        ;QUIT

setpal
        if EGA
        ld de,SUMMERPAL
        else
        ld de,RSTPAL
        endif
        OS_SETPAL
        ret

SUMMERPAL
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b               6f G        ;,,в степи светло-жёлтый, а не ярко-зелёный 4d
           ;ok      ;ok?    ;ok?   ;ok?   ;ok?  ;ok    ;ok   ;ok
        dw 0xffff,0xfefe,0x1d1d,0x3c3c,0xcdcd,0x4c4c,0x2c2c,0xecec
           ;ok?     ;ok     ;ok?   ;ok?   ;ok?  ;ok?   ;ok?  ;ok
        dw 0xfdfd,0x2d2d,0xeeee,0x3f3f,0xafaf,0x5d5d,0x4e4e,0x0c0c
RSTPAL
        STANDARDPAL


texfilename
        db 0,"br0.dat",0
        db 1,"br1.dat",0
        db 3,"br3.dat",0
        db 4,"br4.dat",0
        db 6,"br6.dat",0
        db 7,"br7.dat",0
        
        if EGA==0
ntexfilenames=6
        else
        db 8,"WHUM1.bin",0
        db 9,"WHUM1b.bin",0
        db 10,"WHUM1c.bin",0
        db 11,"WHUMCAT.bin",0
        db 12,"WHUMHOR.bin",0
        db 13,"WORC1.bin",0
        db 14,"WORC1b.bin",0
        db 15,"WORC1c.bin",0
        db 16,"WORCCAT.bin",0
        db 17,"WORCHOR.bin",0
        db 18,"WCREAT1.bin",0
        db 19,"WCREAT1b.bin",0
        db 20,"WCREAT1c.bin",0
        db 21,"WCREAT2.bin",0 ;там же в 0xe800 demobar
        db 22,"WCREAT2b.bin",0
        db 23,"WCREAT2c.bin",0 ;там же трупы
         db 24,"WBAR.bin",0 ;там же надписи
        db 25,"WBULLET.bin",0
;26..28=land
        db 26,"W1LAND.bin",0
        db 27,2,"W1LAND.bin",0
        db 28,4,"W1LAND.bin",0
         db 29,"W0BUT.bin",0
         db 30,1,"W0BUT.bin",0
ntexfilenames=24+5
        endif

        if EGA
MP_OFF	
        if 1==0
        ld e,0
        OS_SETSCREEN
        ld e,0
        OS_CLS
        ld e,1
        OS_SETSCREEN
        ld e,0
        OS_CLS
        ret
        else
_mpoffwid=24
        call setpgsscr40008000
        
        ld ix,scrbase+_mpoffwid
        call MP_OFFlayer
        ld ix,scrbase+0x4000+_mpoffwid
        call MP_OFFlayer
        ld ix,scrbase+0x2000+_mpoffwid
        call MP_OFFlayer
        ld ix,scrbase+0x6000+_mpoffwid
        call MP_OFFlayer
        jp setpgsmain40008000
        endif

        if 1==1
MP_OFFlayer   
	LD (MP_OFFlayerSP),SP
        LD bc,40
        ld d,b
        ld e,b
	LD a,192
MP_OFFlayer0
	LD SP,ix
	dup _mpoffwid/2-1
        push de
        edup
        ld (ix-(_mpoffwid-1)),d
        ld (ix-_mpoffwid),e
        add ix,bc
        dec a
	jr nz,MP_OFFlayer0
MP_OFFlayerSP=$+1
        ld sp,0
        ret
        endif
        
        endif


        if EGA
putBAR
        ld a,24
	LD DE,0xc000;DSCR
putBAR_ade
        push de
        call _128
	LD A,2
	LD (V_FLAG),A ;cursor off
	CALL V_PUT1 ;visible screen
        call setpgsscr40008000_current
        pop de
        push de
        call putBARdoscr
	CALL V_GET1 ;visible screen
	CALL V_MRK1 ;visible screen
	xor a
	LD (V_FLAG),A ;cursor on
	CALL V_PUT2
        call setpgsscr40008000
        pop de
        call putBARdoscr
	CALL V_GET2
	jp V_MRK2
putBARdoscr
        ;call changescrpg_current
	;LD DE,0xc000;DSCR
	LD HL,scrbase+0x0018
	LD BC,#1808
	jr primgega

PUTSYM
;HL - adr in scr; DE-adr spr; BC-size(yx)
        call setpgsscr40008000_current
primgega
        sla c
        sla c
        ld a,b
        add a,a
        add a,a
        add a,a
        ld b,a
primgega_pixsz
;b=hgt,c=wid
;de=gfx
;hl=scr
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
        endif
        
        macro MASKBYTE
        ld a,(hl)
        and e
        or d
        ld (hl),a
        endm
        macro DOWNBYTE
        add hl,bc
        endm

        if EGA
prsprega
        ld a,(Xh)
        add a,a
        add a,a
        ld hl,(SHIFTh)
        srl l
        add a,l
        add a,sprmaxwid-1
        ld e,a
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
        ld a,(Yh)
        ld c,a
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)

        ;di
        push bc
        call setpgsscr40008000
        pop bc
        ;ld c,0
        ;ld e,sprmaxwid-1
        
        ld a,e
        cp scrwid+(sprmaxwid-1)
        jr nc,noprspr
        ld a,c
         add a,sprmaxhgt-1
        cp scrhgt+(sprmaxhgt-1)
        jr nc,noprspr
        ;jr $
        call prspr
noprspr
        
        ;call setpgsmain40008000
        ;ei
        ;ret
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
        ;xor a
        jr setpgsscr40008000_go
setpgsscr40008000
        xor a
        ;ld a,(setpgs_scr_scrxor)
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
        ;jr $
        call changescrpg_current
        ;ld (curscrnum_physical),a
	ld e,a
	OS_SETSCREEN
        ret
        
copyscreen
        display "-",$
        call setpgsscr40008000
        ld a,(setpgs_scr_scrxor)
        ld hl,setpgs_scr_low
        xor (hl)
        push af
        ld (curpg8000),a
        SETPG32KLOW
        ld hl,0x8000
        ld de,0x4000
        ld bc,0x4000
        ldir
        call setpgsscr40008000
        pop bc
        ld a,(setpgs_scr_pgxor)
        xor b
        ld (curpg4000),a
        SETPG16K
        ld hl,0x4000
        ld de,0x8000
        ld bc,0x4000
        ldir
        jp setpgsmain40008000
        
;curscrnum_physical
;        db 0
        endif

        if EGA
IND1	DEFB 127	;тек знач ind1
IND1MX	DEFB 145	;макc знач
IND2	DEFB 10
IND2MX	DEFB 67
IND2TP	DEFB 2		;тип ind2 (0-none,1-magic,2-%)
LMask	DEFB #C3 ;маска линии
LMask_	DEFB 10
timer
        db 0
        endif

SLOWER	;замедлитель
	EI
	XOR A
	OUT (254),A ;sys установки
	LD A,(MAXTRY)
	LD (makTRY),A ;ограничитель числа трассировок
	;
        if EGA
;ждать не менее 3 фреймов с прошлого раза
oldtimer=$+1
        ld c,0
SLOWER0
        ld a,(timer)
        ld (oldtimer),a
        sub c
        cp 3;5
        jr c,SLOWER0
        else
        
	LD A,(SLOW)
	OR A
	RET Z
	LD B,A
ssLW	LD DE,4000 ;x112000тактов
ssL1	DEC DE
	LD A,E
	OR D
	JR NZ,ssL1
	DJNZ ssLW
        endif
        
	RET

;;MATHEMATICAL LIBRARY	MATH-ZX
;MULB2	PUSH	HL	 ;HL*E--DE  (C)
;	JR	MULENT
;MULB	PUSH	HL	 ;L*E--DE
;	LD	H,0
;MULENT LD	A,E
;	LD	E,0
;	LD	D,E
;	JR	MMULB2
;MMULB1 ADD	HL,HL
;	JR	C,ENDMUL
;MMULB2 OR	A
;	JR	Z,ENDMUL
;	RRA
;	JR	NC,MMULB1
;	EX	DE,HL
;	ADD	HL,DE
;	EX	DE,HL
;	JR	MMULB1
;ENDMUL POP	HL
;	RET
;MUL	PUSH	HL ;HL*DE--DE
;	XOR	A
;	OR	D
;	JR	Z,MULENT
;	EX	DE,HL
;	XOR	A
;	OR	D
;	JR	Z,MULENT
;	SCF
;	POP	HL
;	RET
DIVB	LD	D,0 ;E/L--E (MOD in D)
DIVB2	PUSH	HL ;DE/L--E
	PUSH	BC
	LD	B,8
	EX	DE,HL
	LD	D,E
	LD	E,0
DIV1B	OR	A
	RR	D
	RR	E
	SBC	HL,DE
	JR	NC,MDIVB
	ADD	HL,DE
MDIVB	RLA
	DJNZ	DIV1B
	CPL
	LD	D,L
	LD	E,A
	POP	BC
	POP	HL
	RET

        include "wmenu2.asm" ;было в pg7
        include "wlie.asm"
        
        if EGA
prspr
;в 4000,8000 уже включен экран (setpgsscr40008000)
;найти адрес, ширину, высоту спрайта по ID, phase + включить страницу в 0xc000
;...

;iy=sprite data+2
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
;по x,y, ширине, высоте найти адрес на экране, куда выводим видимую часть спрайта
;спрайт полной высоты и ширины должен работать максимально быстро!
        ld a,scrwid+(sprmaxwid-1)
        sub e ;x ;a=расстояние до правой границы экрана
        ld hx,a
        ;ld lx,0 ;по умолчанию нет фальшивого экрана, выход по правой границе экрана будет сразу ;для полной ширины не надо - выход будет по окончанию спрайта
         ;ld lx,0 ;для спрайта полной высоты, клипированного справа - выход сразу на границе
        ld a,e ;x
        sub sprmaxwid-1
        jr nc,prsprnocropleft
;[найти адрес начала видимой части спрайта:]
;[сначала столбец (прибавить hgt*2*число скрытых столбцов) можно в цикле, т.к. пропуск столбцов бывает редко]
;или включить фальшивый экран в 0x4000,0x8000 и заменить адреса выхода на переключалку страниц, так можно работать со спрайтами процедурой
;a=-число отрезанных слева столбцов
;посчитать hx для правильного выхода из фальшивого экрана
;посчитать lx для правильного выхода из спрайта в y-клипированной выводилке
        ld l,a
        add a,(iy-4)
        ld lx,a ;sprwid-число отрезанных слева столбцов
;если <=0, то спрайта нет на экране!!! выходим!!!
         ret m
         ret z
        xor a
        sub l
        ld hx,a ;число отрезанных слева столбцов
        push bc
        ld a,(pgfake)
        ld (curpg4000),a
        SETPG16K
        ld (curpg8000),a
        SETPG32KLOW
;hl будет вычислен с ошибкой +64
        pop bc
        ld a,l
        or a
prsprnocropleft
        ld (prsprqsp),sp
;NC
        ld b,0
        ld l,c ;y
        rra ;x bit 0
        ;ld h,0x40/32/2
        ;jr nc,$+4 ;x bit 0
        ; ld h,0x80/32/2
         ld h,b;0
         rl h
         inc h ;0x40/32/2 или 0x80/32/2
        srl a ;x bit 1
         rl h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40+scrbase
         add a,scrbase&0xff
;a=x/4
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl=scr ;не может быть переполнения при отрицательных x? maxhl = 199*40 + 127 = 8087
        ld a,c ;y
        ;add a,sprmaxhgt-1
        ;sub sprmaxhgt-1
        ;jp c,prsprcroptop
         cp scrhgt
         jp nc,prsprcroptop
        add a,(iy-3) ;sprhgt
        cp scrhgt+1 ;200=OK, >200=crop
        jp nc,prsprcropbottom
;hx=расстояние до правой границы экрана (columns)
;x=156: hx=4
;x=157: hx=3
;x=158: hx=2
;x=159: hx=1
;если нет клипирования справа, то при нечётном x и чётном sprwid надо сделать строго hx>sprwid/2!
;lx важен только при клипировании слева
         ld a,hx
         inc a
         srl a
         ld hx,a ;lx не пересчитываем, он завышен в 2 раза, но тут в полном спрайте есть выход по ширине раньше
;hx=расстояние до правой границы экрана (double columns)
;x=156: hx=2
;x=157: hx=2
;x=158: hx=1
;x=159: hx=1
        ld c,40 ;b=0
;iy=sprite data+2
        ld e,(iy-2)
        ld d,(iy-1)
        ld sp,iy
;выбрать ветку в зависимости от sprhgt
        ld a,(iy-3) ;sprhgt
        cp 16
        jr z,prspr16
        jr nc,prspr24
prspr8
        ld a,prspr8column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr8column+1
prspr16
        ld a,prspr16column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr16column+1
prspr24
        cp 32
        jr z,prspr32
        ld a,prspr24column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr24column+1
prspr32
        ld a,prspr32column&0xff
        ld (prsprcolumnpatch),a
        ld (prsprcolumnpatch2),a
        jp prspr32column+1
        align 256
;отдельная процедура для спрайта полной высоты, т.к. там не надо на каждом столбце переставлять sp
prspr32column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr24column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr16column
        dup 8
        pop de
        MASKBYTE
        DOWNBYTE
        edup
prspr8column
        display prspr32column," HSB equal to ",$
        dup 7
        pop de
        MASKBYTE
        DOWNBYTE
        edup
        pop de
        MASKBYTE
;найти адрес следующего столбца на экране или выйти        
;4000,8000,[c000]6000,a000,[e001]4001... ;единственное расположение для такой логики (из-за константы 0xa0) (другой вариант - константа 0x60? тогда надо экран в 0000!!!)
;нельзя использовать строки, где h=0xa0, т.е. верхние 7 строк (остаётся 193 строки), иначе надо ld a,0x9f...inc a (+2t)
        pop de ;годится только для спрайтов полной высоты (не прокатит даже если делать pop всех данных столбца, т.к. сдвиг hl разный - разве что и hl сдвигать при клипировании)
        ld a,0x9f;0xa0
        cp h
        adc hl,de ;de = 0x4000 - ((sprhgt-1)*40)
         ret c ;выход по ширине спрайта, там надо восстановить sp и константу в стеке
prsprcolumnpatch=$+1
        jp pe,prspr16column ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
         dec hx
goprsprcolumn
         jp nz,prspr16column
prsprcolumnpatch2=$-2
         ;выход по границе экрана
;10+11+15+14 = 40t (+5+9)
;это может быть граница фальшивого экрана! надо иметь возможность продолжить (с hl-64 из-за ошибки адреса при отрицательных x?)
        ld a,(pgfake)
curpg4000=$+1
        cp 0
        jp nz,prsprqright ;действительно выход по правой границе
;был фальшивый экран для клипирования по левой границе, продолжаем на настоящем экране
        ld hx,lx
        ld bc,-64
        add hl,bc ;из-за ошибки адреса при отрицательных x
         dec c ;NZ!!!
;как не запороть стек? даже если инлайнить вызов, там внутри всё равно rst
        ld (prsprmaybeqrightsp),sp
        ld sp,tempsp
        call setpgsscr40008000 ;выключаем фальшивый экран, включаем настоящий
prsprmaybeqrightsp=$+1
        ld sp,0
        ld bc,40
        ;ld lx,b;0 ;второй раз будет действительно выход
        jp goprsprcolumn ;NZ!!!
;можно то же самое сделать при спрайте кодом (патчи не нужны, de присваивать только если меняется, 13-1 байт (36.5t) лишних на столбец, выход по dec hx:ret z и просто ret в конце)
;а как делать вход в середину, если спрайты кодом, а de присваивается только при изменении? сначала рисовать в фальшивый экран и переключать по call z?
;но клипирование по y уже надо делать с данными спрайта, а не с кодом (т.е. нужна копия спрайта в виде данных)

;выход по ширине спрайта
prsprqwid
;у нас de взят с прошлого раза, и обработчик прерываний может запороть стек
        ld hl,$
        push hl ;если теперь произойдёт прерывание, то de не запорет стек
prsprqright
prsprqsp=$+1
        ld sp,0
        ret

        
;для вывода спрайта неполной высоты:

;клипирование снизу
prsprcropbottom
;a=sprbottom
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
;hl=scr
        sub scrhgt;200
        ;sub (iy-3) ;sprhgt
         ld d,(iy-3) ;sprhgt
         sub d
        ld c,a ;-sprvisiblehgt = sprbottom-200-sprhgt
;если клипировано слева, то сейчас lx = sprwid-число отрезанных слева столбцов
;иначе lx не задано
        
        ld a,(iy-4) ;sprwid
        cp hx ;расстояние до правого края экрана
        ;display "---",$
        jr nc,prsprcropygo;_cropx ;берём меньшее из sprwid и расстояния до правой границы экрана
        ld hx,a ;столько столбцов выведем
        jp prsprcropygo

prsprcroptop
;a=sprtop
;e?1=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c?2=y = -(sprmaxhgt-1)..199 (кодируется как есть)
;(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
;hl=scr неверный (выше экрана)
        
        neg ;a=number of lines to crop
         ld d,(iy-3) ;sprhgt
         sub d
;a = -sprvisiblehgt = -(sprtop+sprhgt) = linestocrop-sprhgt
;если sprvisiblehgt<=0, то спрайта нет на экране!!! выходим!!!
         ret p
        ld c,a ;-sprvisiblehgt = -(sprtop+sprhgt) = linestocrop-sprhgt

;если клипировано слева, то сейчас lx = sprwid-число отрезанных слева столбцов
;иначе lx не задано
        
        ld a,(iy-4) ;sprwid
        cp hx ;расстояние до правого края экрана
        jr nc,prsprcropygo_cropx ;берём меньшее из sprwid и расстояния до правой границы экрана
        ld hx,a ;столько столбцов выведем
prsprcropygo_cropx

         ld a,c
         add a,d ;a=number of lines to crop
        add a,a
;прибавить 2*число скрытых строк к адресу
        add a,ly
        ld ly,a
        jr nc,$+4
        inc hy
        
        ld a,e ;x
        sub sprmaxwid-1 ;NC для положительных x
        srl a
        ld h,0x40
        jr nc,$+4 ;x bit 0
         ld h,0x80
        srl a
        jr nc,$+4 ;x bit 1
         set 5,h
       add a,scrbase&0xff
        ld l,a
        
prsprcropygo
;d=(iy-3)?3=sprhgt
;(iy-4)?4=sprwid
        ld a,d ;sprhgt
        ;add a,c ;-sprvisiblehgt
        ; add a,3 ;inc a
        ;add a,a
        ;ld (prsprNspraddpatch),a ;2*(sprhgt-sprvisiblehgt)+2 +4
         inc a
         add a,a
        ld (prsprNspraddpatch),a ;2*sprhgt+2

        ld a,c ;-sprvisiblehgt
        add a,a
        add a,c
        add a,a
        ld (prsprNpatch),a ;PRSPR24 и т.п. (по 6 байт)        

        ex de,hl
         ;ld b,-1 ;убрать за счёт перемещения ld h
         ;ld h,0x40/32-1
         inc c
        ld l,c ;-sprvisiblehgt
        add hl,hl
        add hl,hl
         ld h,0x40/8-1 -1
         jr nz,$+4
         ld h,0x40/8 ;для sprvisiblehgt-1 == 0
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl
        ld (prsprNscraddpatch),hl ;0x4000 - ((sprvisiblehgt-1)*40)
        ex de,hl

;hl=scr
        ;ld c,40
        jp prsprN

;выравнивание на нужный младший байт адреса:
_lowaddr=256-(sprmaxhgt*6)
        ds (_lowaddr-$)&0xff
;младший байт адреса равен 256-(sprvisiblehgt*6)
PRSPR32
        dup 8
        MASKBYTE
        DOWNBYTE
        pop de
        edup
PRSPR24
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR23
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR22
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR21
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR20
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR19
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR18
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR17
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR16
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR15
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR14
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR13
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR12
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR11
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR10
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR9
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR8
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR7
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR6
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR5
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR4
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR3
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR2
        MASKBYTE
        DOWNBYTE
        pop de
PRSPR1
        display PRSPR32," HSB equal to ",$
        MASKBYTE
        
;найти адрес следующего столбца на экране или выйти        
;4000,8000,[c000]6000,a000,[e001]4001...
;восстановить начальный hl
prsprNscraddpatch=$+1
        ld bc,0 ;bc = 0x4000 - ((sprvisiblehgt-1)*40)
        ld a,0x9f;0xa0
        cp h
        adc hl,bc
        jp pe,prsprNcolumnq ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
prsprNcolumnq
        dec hx
        jp z,prsprNmaybeqright ;это может быть граница фальшивого экрана! надо иметь возможность продолжить (с hl-64 из-за ошибки адреса при отрицательных x?)
prsprNcolumnqq
;найти адрес данных следующего столбца спрайта
;можно просто сделать много пустых pop de, т.к. пропуск строк бывает редко
prsprNspraddpatch=$+1
        ld bc,0 ;bc = 2*(sprhgt-sprvisiblehgt)+2
        add iy,bc
prsprN
;iy=sprite data
        ld c,40
        ld sp,tempsp ;чтобы не намусорить новым de в старых данных
        ld e,(iy-2)
        ld d,(iy-1)
        ld sp,iy
prsprNpatch=$+1
        jp PRSPR24
        
prsprNmaybeqright
curpg8000=$+1
        ld a,0
pgfake=$+1
        cp 0
        jp nz,prsprqright ;действительно выход
        ld hx,lx
        ld bc,-64
        add hl,bc ;из-за ошибки адреса при отрицательных x
        ld sp,tempsp
        call setpgsscr40008000 ;выключаем фальшивый экран, включаем настоящий
        ;ld bc,40
        ;ld lx,b;0 ;второй раз будет действительно выход
        jp prsprNcolumnqq
        endif
        
        if EGA
G_MX	DEFB  010
G_MY	DEFB  010

ARRHGT=8

getarr
;hl=x
;a=y
;de=buf
         ;di
        ex de,hl
        ld (hl),e
        inc hl
        ld (hl),a
        inc hl
        ex de,hl
        push de
        call prarr_calccur
        pop hl
getarrcolumn0
        ld bc,40
        ld hy,ly
        ex de,hl
;hl=scr
;de=buf
        push hl
        dup ARRHGT-1
        ld a,(hl) ;scr
        ld (de),a
        inc de
         dec hy
         jr z,getarrcolumnq
        add hl,bc
        edup
        ld a,(hl) ;scr
        ld (de),a
        inc de
getarrcolumnq
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,getarrcolumnqq ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
getarrcolumnqq
        ex de,hl
        dec lx
        jr nz,getarrcolumn0
         ;ei
        ret ;jp setpgsmain40008000

rearr
;hl=buf
        ld e,(hl)
        inc hl
        ld a,(hl)
        inc hl
        ex de,hl
        ld h,0
;hl=x
;a=y
        push de
        call prarr_calccur
        pop hl
rearrcolumn0
        ld bc,40
        ld hy,ly
        ex de,hl
;hl=scr
;de=buf
        push hl
        dup ARRHGT-1
        ld a,(de)
        ld (hl),a ;scr
        inc de
         dec hy
         jr z,rearrcolumnq
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a ;scr
        inc de
rearrcolumnq
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,rearrcolumnqq ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
rearrcolumnqq
        ex de,hl
        dec lx
        jr nz,rearrcolumn0
        ret ;jp setpgsmain40008000


prarr
;hl=x
;a=y
         ;di
        call prarr_calccur
prarrcolumn0
        ld bc,40
        ld hy,ly
        push de
        push hl
        dup ARRHGT-1
        ld a,(de) ;scr
        and (hl) ;mask
        inc hl
        xor (hl) ;pixels
        ld (de),a ;scr
         dec hy
         jr z,prarrcolumnq
        inc hl
        ex de,hl
        add hl,bc
        ex de,hl
        edup
        ld a,(de) ;scr
        and (hl) ;mask
        inc hl
        xor (hl) ;pixels
        ld (de),a ;scr
prarrcolumnq
        pop hl
        ld de,ARRHGT*2
        add hl,de
        pop de
        ex de,hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,prarrcolumnqq ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
prarrcolumnqq
        ex de,hl
        dec lx
        jp nz,prarrcolumn0
         ;ei
        ret ;jp setpgsmain40008000

prarr_calccur
;hl=x
;a=y
;out: hl=scr+, de=gfx, lx=wid
        ld e,a
        push hl ;x
        ld c,l
        rr c
         ;push af ;CY=x0
        ex de,hl ;push de ;e=y
        ;ld a,(prarr_zone)
        ;cp ZONE_WORK
G_IMG=$+1
        ld de,G_IMG1;sprarr_l
        ;ld bc,sprarr_r
        ;pop hl ;l=y
;l=y
;de=spr_l
;bc=spr_r
        ;pop af ;CY=x0
        jr nc,prarr_nor ;de=спрайт для чётного x
        ;ld d,b
        ;ld e,c ;de=спрайт для нечётного x
        ld a,e
        add a,8*ARRHGT+1
        ld e,a
        jr nc,$+3
        inc d
prarr_nor
        pop bc ;x
        ld a,(de)
        ld lx,a
        inc de
;l=y
;bc=x
;de=spr
;lx=wid
        ;ret       
;prarr_calcscr
;l=y
;bc=x
;de=spr
;lx=wid
        push de ;spr
        ld h,0 ;y HSB
        ld a,scrhgt
        sub l ;y
        ld ly,a ;200-y
        ld d,h;0x80/8;scrbase/256/8
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;y*5
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
        pop de ;spr
        srl b ;теперь b=0
        rr c ;c=x/2
        ld a,160;scrwid/2
        sub c ;scrwid/2-(x/2)
        cp lx
        jr nc,$+2+2 ;scrwid/2-(x/2) >= ширина
        ld lx,a ;scrwid/2-(x/2) < ширина
        srl c
        jr nc,$+4
        set 6,h
        srl c
        jr nc,$+4
        set 5,h
         ;ld b,-0x40 ;для scrbase=0x4000
        add hl,bc
         ld bc,scrbase
         add hl,bc
        ex de,hl
;de=scr
;lx=ширина
;ly=200-y
        ret

arbuf0
        ds 2 + (8*ARRHGT)
arbuf1
        ds 2 + (8*ARRHGT)
        
;%rlrrrlll
_xx=0x00ff
_x0=0x0047
_0x=0x00b8
_x1=0xb847
_1x=0x47b8
_10=0x4700
_01=0xb800
_00=0x0000
_11=0xff00

G_IMG1
sprarr_l
;mask,pixels = 0xppmm
;%rlrrrlll
        db 4
        ;dw 0x0000,0xb800,0xb800,0xb800,0xb800,0xb800,0xb800,0xb800,0xb800,0x0047,0x00ff,0x00ff,0x00ff
        ;dw 0x00ff,0x00b8,0x4700,0xff00,0xff00,0xff00,0xff00,0xff00,0x0000,0x0047,0x00ff,0x00ff,0x00ff
        ;dw 0x00ff,0x00ff,0x00ff,0x00b8,0x4700,0xff00,0xff00,0x4700,0x4700,0x4700,0xb800,0xb800,0x0047
        ;dw 0x00ff,0x00ff,0x00ff,0x00ff,0x00ff,0x00b8,0x4700,0x00b8,0x00ff,0x00ff,0x00b8,0x00b8,0x00ff
        dw _11,_10,_10,_10,_10,_11,_x1,_xx
        dw _11,_00,_00,_00,_00,_01,_11,_xx
        dw _11,_01,_00,_01,_00,_00,_10,_11
        dw _xx,_1x,_1x,_1x,_11,_01,_11,_1x
sprarr_r
;mask,pixels = 0xppmm
;%rlrrrlll
        db 5
        ;dw 0x0047,0x0047,0x0047,0x0047,0x0047,0x0047,0x0047,0x0047,0x0047,0x00ff,0x00ff,0x00ff,0x00ff
        ;dw 0x00b8,0x4700,0xff00,0xff00,0xff00,0xff00,0xff00,0xff00,0x4700,0x00b8,0x00ff,0x00ff,0x00ff
        ;dw 0x00ff,0x00ff,0x00b8,0x4700,0xff00,0xff00,0xff00,0xff00,0xb800,0xb800,0x0047,0x0047,0x00ff
        ;dw 0x00ff,0x00ff,0x00ff,0x00ff,0x00b8,0x4700,0xff00,0x0000,0x00b8,0x00b8,0x4700,0x4700,0x00b8
        ;dw 0x00ff,0x00ff,0x00ff,0x00ff,0x00ff,0x00ff,0x00b8,0x00ff,0x00ff,0x00ff,0x00ff,0x00ff,0x00ff
        dw _x1,_x1,_x1,_x1,_x1,_x1,_xx,_xx
        dw _11,_00,_00,_00,_00,_10,_11,_xx
        dw _11,_00,_00,_00,_00,_10,_11,_x1
        dw _1x,_11,_01,_11,_01,_00,_01,_11
        dw _xx,_xx,_xx,_xx,_1x,_1x,_1x,_xx

G_FIX1
sprarrfix_l
        db 4
        dw _00,_01,_01,_01,_01,_00,_x0,_xx
        dw _00,_11,_11,_11,_11,_10,_00,_xx
        dw _00,_10,_11,_10,_11,_11,_01,_00
        dw _xx,_0x,_0x,_0x,_00,_10,_00,_0x
sprarrfix_r
        db 5
        dw _x0,_x0,_x0,_x0,_x0,_x0,_xx,_xx
        dw _00,_11,_11,_11,_11,_01,_00,_xx
        dw _00,_11,_11,_11,_11,_01,_00,_x0
        dw _0x,_00,_10,_00,_10,_11,_10,_00
        dw _xx,_xx,_xx,_xx,_0x,_0x,_0x,_xx

G_MAP1
sprarrmap_l
        db 4
        dw _00,_01,_01,_01,_01,_00,_x0,_xx
        dw _00,_11,_00,_00,_01,_10,_00,_xx
        dw _00,_10,_01,_10,_01,_10,_01,_00
        dw _xx,_0x,_0x,_0x,_00,_10,_00,_0x
sprarrmap_r
        db 5
        dw _x0,_x0,_x0,_x0,_x0,_x0,_xx,_xx
        dw _00,_11,_10,_10,_10,_01,_00,_xx
        dw _00,_11,_00,_01,_10,_01,_00,_x0
        dw _0x,_00,_10,_00,_10,_01,_10,_00
        dw _xx,_xx,_xx,_xx,_0x,_0x,_0x,_xx
        endif ;EGA
        
        if EGA
WFONT
        incbin "data/wfont.fnt"

        macro PRCHARBYTE
        xor a
        sla b
        jr nc,$+4
        or 0x47 ;L
        sla b
        jr nc,$+4
        or 0xb8 ;R
        ld (hl),a
        endm
        
        macro PRCHARINVBYTE
        xor a
        sla b
        jr c,$+4
        or 0x47 ;L
        sla b
        jr c,$+4
        or 0xb8 ;R
        ld (hl),a
        endm
        
        macro PRCHAR4BYTES
        ld a,(de)
        ld b,a
        PRCHARBYTE
        ld a,h
        add a,0x40
        ld h,a
        PRCHARBYTE
        ld a,h
        add a,0x20-0x40
        ld h,a
        PRCHARBYTE
        ld a,h
        add a,0x40
        ld h,a
        PRCHARBYTE
        endm
        
        macro PRCHARINV4BYTES
        ld a,(de)
        ld b,a
        PRCHARINVBYTE
        ld a,h
        add a,0x40
        ld h,a
        PRCHARINVBYTE
        ld a,h
        add a,0x20-0x40
        ld h,a
        PRCHARINVBYTE
        ld a,h
        add a,0x40
        ld h,a
        PRCHARINVBYTE
        endm

prchar
;de=yx
;a=char
	ADD A,A
	LD BC,(FONT)
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
        call setpgsscr40008000_current
        ex de,hl ;de=font+
;hl=yx
        ld a,l
        ld l,h
        ld h,0
        sla l
        sla l
        sla l ;y*8
        ld b,0x40/8
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*8*40
         add a,scrbase&0xff
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        
;hl=scr
        ld c,40
        dup 7
        PRCHAR4BYTES
        ld b,-0x60
        add hl,bc        
        inc de
        edup
        PRCHAR4BYTES

        jp setpgsmain40008000


prcharinv
;de=yx
;a=char
	ADD A,A
	LD BC,(FONT)
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
        call setpgsscr40008000;_current
        ex de,hl ;de=font+
;hl=yx
        ld a,l
        ld l,h
        ld h,0
        sla l
        sla l
        sla l ;y*8
        ld b,0x40/8
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*8*40
         add a,scrbase&0xff
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        
;hl=scr
        ld c,40
        dup 7
        PRCHARINV4BYTES
        ld b,-0x60
        add hl,bc        
        inc de
        edup
        PRCHARINV4BYTES

        jp setpgsmain40008000

        endif ;EGA

       if EGA
        align 256
;---выровн табл (H-без изменений)------------
MLtab1  DEFB #FF,#7F,#3F,#1F,#F,#7,#3,#1        ;для hLINE
MLtab2  DEFB #80,#C0,#E0,#F0,#F8,#FC,#FE,#FF
MLtabV  DEFB #80,#40,#20,#10,#8,#4,#2,#1        ;для vLINE
       endif

        if 1==0
        ds 0x3b00-$
        ;include "WHUM1.ast"
testspr
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
        endif
        
        ds 0x3e00-$
        ds 0x4000-$ ;ORG #4000
;--------/MEM--------
        nop ;IR128   DEFB    0
        nop ;R128    DEFB    %11000
        nop ;CHK#0   DEFB    #EE       ;[**B] чек-сум0 ;#4002 ;???
;--------- i/o переменные ---
DISK_2  DEFB    1 ;номер дисковода для диска 2
DISK_T  DEFB    0 ;номер дисковода для отгрузок
SIDE    DEFB    0 ;сторона
MEM16   DEFW    0 ;?
tDRIVE  DEFB    1 ;текущ дисковод 0/1
fADR    DEFW    0 ;адр загр ф-ла
;-------- текущ файлы ----
MORTE   DEFB 0;86 - супер энергия
        nop ;CHK#1   DEFB    #EE       ;[**B] чек-сум1 ;#400C ;???
;
_sBUTT  DEFB 0; 0-1
_sLAND  DEFB #FE; 1-4
_sMUS   DEFB #FB; 0-7
        nop ;isTST5  DEFB    %11000 ;пров 5 [**] ;???

        
        ;ENT $ ;>>>>>
;GO
        ;ds 2
JP_ST   DI
        ;LD A,#41
        ;LD I,A
        LD SP,STACK;#403E
        JP wMAIN

        db "Made by Copper Feet 1997 v1.01.B"
        
        ds #4040-$
        JP INTRP ;in #4040
;--адреса.некот.таблиц--
CHK#2   DEFW    #EEEE   ;[**W] чек-сум2 ;#4043
CHK#3   DEFB    #EE     ;[**B] чек-сум3 ;#4045
        DEFW    BFORCE  ;#4046
        DEFW    hBUT    ;#4048
        DEFW    hMSG    ;#404A
        DEFW    hCLRIC  ;#404C
        DEFW    hWIZRD  ;#404E
;==================================обслуживание клавиатуры
PRSKEY  PUSH    BC
        LD      C,#FE
        CALL    PRSROW
        POP     BC
        AND     C
        RET

PRSROW  IN      A,(C)
        CPL
        AND     #1F
        RET

CONTR   
        PUSHs
        LD      A,(KEYJOY)
        OR      A
        JR      Z,CO1
        LD      C,#1F
        CALL    PRSROW
        XOR     #1F
CO2     LD      (CONTRB),A
        LD      A,(PMOUSE)
        OR      A
        CALL    NZ,MOUSE
        POPs
        LD      A,(CONTRB)
        RET
CO1     LD      HL,(KEYS)
        LD      E,0
        LD      D,5
CO3     LD      C,(HL)
        INC     HL
        LD      B,(HL)
        CALL    PRSKEY
        JR      Z,CO4
        SET     5,E
CO4     RRC     E
        DEC     D
        INC     HL
        JR      NZ,CO3
        LD      A,E
        JR      CO2

DELAY   HALT
        DEC A
        JR NZ,DELAY
        RET Z

KBR     DEFW    #DF01,#DF02,#FD01,#FB01,#7F15
INT2    DEFW    #EF08,#EF10,#EF04,#EF02,#EF01
;;KUR   DEFW    #EF04,#F710,#EF10,#EF08,#EF01 ;;;

RND     PUSH    HL
        LD      HL,(RNA)
        INC     HL
;;;     LD      A,R
;;;     ADD     A,H
        LD      A,H ;;;
        AND     #3F;#1F
        LD      H,A
        LD      A,(RNB)
        RRCA
        XOR     (HL)
        ADD     A,L
        LD      (RNA),HL
        LD      (RNB),A
        POP     HL
        RET

;--------------проверка денег---
chkCRC  PUSH HL ;проверить к/сумму денег
        PUSH AF
        CALL suMdig
        CP (HL)
        JR Z,exiCRC
suMdig  ;вычислить к/с денег
        PUSH BC
        LD HL,MONEY-1
        LD B,6
        LD A,(TASK_M+10)
suM1    INC HL
        RLCA
        RLCA
        RLCA
        XOR (HL)
        SUB L
        DJNZ suM1
        POP BC
        LD HL,MNYcrc
        RET
setC1   SCF
setCRC  PUSH HL ;установить к/с денег
        PUSH AF
        CALL suMdig
        LD (HL),A
exiCRC  POP AF
        POP HL
        RET
;----------------Interupt table
        ds #4100-$
        DEFS 257,#40
;---выровн табл (H-без изменений)------------
inMAP   DEFW 64,65,1,-63,-64,-65,-1,63 ;for MAKE_R
        if EGA==0
MLtab1  DEFB #FF,#7F,#3F,#1F,#F,#7,#3,#1        ;для hLINE
MLtab2  DEFB #80,#C0,#E0,#F0,#F8,#FC,#FE,#FF
MLtabV  DEFB #80,#40,#20,#10,#8,#4,#2,#1        ;для vLINE
        endif
GO_Ntb  ;смещ по напр y,x;y,x;y,x...  для GO_NXT
        DEFB 0,1, 1,1, 1,0, 1,-1, 0,-1, -1,-1, -1,0, -1,1; (8)
;---------------------------------------------
GO_Nt2  ;...продолж для расст =2
        DEFB 2,-1, 2,0, 2,1, -2,1, -2,0, -2,-1
        DEFB 1,2, 0,2, -1,2, -1,-2, 0,-2, 1,-2 ;(20)
        ;=2max
        DEFB -2,2, -2,-2, 2,-2, 2,2 ;(24)
        ;=3
        DEFB 0,-3, 3,0, 0,3, -3,0
        DEFB 1,-3, 3,1, -1,3, -3,-1
        DEFB -1,-3, 3,-1, 1,3, -3,1
        DEFB 2,-3, 3,2, -2,3, -3,-2
        DEFB -2,-3, 3,-2, 2,3, -3,2 ;(44)
        ;=3max
        DEFB -3,3, -3,-3, 3,-3, 3,3 ;(48)
        ;=4
        DEFB 0,-4, 4,0, 0,4, -4,0
        DEFB 1,-4, 4,1, -1,4, -4,-1
        DEFB -1,-4, 4,-1, 1,4, -4,1
        DEFB 2,-4, 4,2, -2,4, -4,-2
        DEFB -2,-4, 4,-2, 2,4, -4,2 ;(68)

;Main procedures
        ;include "wlid.asm"
        include "w_io.asm"
        if EGA==0
WFONT
        incbin "data/wfont.fnt"
        endif
        include "xdelpz.asm"
        ;include "w_intv.asm"
        include "wlib2.asm"
        if EGA==0
        ds 157 ;просто так ;???
        include "wlib2x3.asm"
        endif
        ;include "wlie.asm"
        ;include "wlib1a.asm"
        include "wsound2.asm"
        include "wlik.asm"

        if 1==0
M_Mexi  OUT (C),A ;выход
        DI
        LD SP,#FFFF
        JP 0 ;???
        endif
;-------- переменные -----
;*L+
        ds #7650-$
        nop ;CHK_4   DEFB #EE ;[**B] чек-сум4 #7650 ;???
G_DATA  EQU  #7700  ;отгрузка идёт с #7700
        include "w~local.asm" ;??? грузит w_demo.asm
        include "w~var.asm"
        ds #79C0-$
        include "w~level.asm"
        ;include "levels/w~115.a80"
        NOP
WBAR
        incbin "data/wbar.dat" ;подгружается сюда
        NOP
end

        page 0 ;*P0 ;--------------------
        ORG #C000
begin0
        include "wlib3.asm"
        include "wlib3vi.asm"
        include "wlif.asm"
        include "wintel.asm"
        include "wlic.asm"
        ds 101 ;просто так ;???
        include "wlig.asm"
        include "wlib4.asm"
        ;include "w_protec.asm" ;???
        include "wstrateg.asm"
        include "wlih.asm"
        include "wwizard.asm"
;;*L+
        ds #F4AE-$
        nop ;CHK_9   DEFB #EE ;[**B] чек-сум5 0:#F4AE
        nop ;CHK_5   DEFB #EE ;[**B] чек-сум5 0:#F4AF
        incbin "data/wscreat2.dat"
        DEFS #FFFF-$+1,#C2
;где creat25 equ #F4C0 ;creat26 equ #FA60
end0

;*P0 ;--------------------


;---------формат данных героя (HUMAN,KUNGE,SLAVE)---
;0      X (1..62,=0-труп)
;1      Y (1..62,=0-пусто)
;2      Hапр (0..7)
;3      Фаза (=0 - целиком в квадрате)
;          или (%1ibttttt, где i-удар b-назад ttttt-задержка)
;          или (%10000xxx, где ххх-ожидание свободного прохода)
;          или (тоже, время нахождения в шахте/на базе)
;4      Тип (0..26)
;5      Здоровье
;6      Мана / Время магич. жизни
;7      Длина шага при перемещении (1..4)
;8      Тип движения:
;               0-стоп
;               #80-free move
;               %0len-обход по часовой
;               %1len-против (где len-длина обхода)
;       На стоянке: #FF/xx - посмотрел/не посмотрел вокруг
;9      Тип действий:
;        (cм.ниже)

;10     Цель X
;11     Цель Y
;12     N врага (если ix+9 == 4) (%txxxxxxx, где t=0/1=герой/дом)
;       Для лесоруба - к_во оставшихся ударов
;13     -
;14     Xwood ;для крестьян - коорд, куда идти за лесом/золотом
;15     Ywood ;
;Формат массива XY - TODO зачем?
;0-1    Xpos (0..1024) (левая)
;2-3    Ypos (0..1024) (нижняя)
;-------------------------------
;Примеч: Невидимый герой: (IX+1)=%1xxxxxxx, (IY+1)=%1xxxxxxx

;(ix+9) -тип действий
;        0-ничего
;        1-стоять насмерть
;        2-перемещение
;        3-атаковать позицию
;        4-атаковать врага (для крестьян - убегать)
;        5-идти на базу
;        6-идти за лесом
;        7-идти за золотом
;        8-идти на ремонт/строительство
;        9-?

;        10-родить скорпиона
;        11-огненный дождь
;        12-родить стеногрыза
;        13-родить паука
;        14-наслать смерч
;        15-родить демона

;        16-дать здоровье
;        17-дальнее зрение
;        18-огненный пояс
;        19-поднять скелетов
;        20-чёрное зрение
;        21-хрустальная сфера
;        22-находиться на строительстве
;        23-находиться в шахте
;        24-находиться на базе
;        25-рубить лес
;------------------------------------
;---------формат данных трупа ---
;0      Х=0
;1      если 0-труп исчез
;2      -
;3      Время гниения текущ фазы (1..хх)
;4      Вид трупа (0-16) >=17 труп катапульты
;(10)   Х коорд. трупа
;(11)   Y
;Формат массива XY - тот же
;-------------------------------


;Формат данных здания
;-------------------------------
;0      X  (0-нет)
;1      Y
;2      тип
;3      жизн сила
;4      тип пр-ва (255-нет,253/254-строится)    ;4 (для шахты)
;5      степень готовности                      ;-деньги/100
;6      начальная жизн сила /2
;7      Для строящегося здания:
;         255-стр_во не начато/N-стр_во ведёт герой N
;-------------------------------
;тип: 0-main,1-креп,2-лесоп,3-церкв,4-кузня,5-конюш,6-башн,7-дворец,8-хата
;кунги:10-18, 255-шахта


;Формат снаряда/взрыва/заклинания (12байт)
;-------------------------------
;0-1    * * -   Xpos \ пиксельные коорд
;2-3    * * -   Ypos /
;4      * * *   тип/фаза (0-нет)
;5      * - *   Xtar \ коорд. цели      Ntar \ номер цели
;6      * - -   Ytar / (для катап)  OR  -    / (стрелы,заклинания)
;7      * - -   автор выстрела
;8      * - -   напр. полёта (0-7)
;9      * * *   time (время полёта/действия/фазы)
;10     * ? ?   dX \смещение при перемещении
;11     * ? ?   dY /
;---------------------------------
; Типы (iy+4):
;1      наши стрелы
;2      стрелы врага
;3      огонь волшебников
;4      взрыв огня волшебников (фаза iy+9)
;5      -
;6      снаряд катапульты
;7      снаряд стеногрыза
;8      снаряд огненного дождя
;9      колдовские звёздочки
;10     взрыв снаряда катапульты (фаза iy+9)
;11     взрыв здания
;12     заклинание "смерч"
;-------------------------------(iy+0,1,2,3 - от объекта N)
;13     заклинание "хрустальная сфера"
;14     заклинание "огненный пояс"
;15     -
;--------------------------------(дым пожарищ)
;16     дым (низ,50%)
;17     дым (низ,25%)
;18     дым (верх)

;*L+
        page 7 ;--------SCR,...-----
        ORG #C000
begin7
        incbin "barkov/w_world.scr"
;	 ORG #DB00
        nop ;CHK_6	 DEFB #EE; [**B] чек-сум6 7:#DB00
WBUTT
        incbin "data/whumbutt.dat" ;0(*)
        ;incbin "data/worcbutt.dat" ;1
WNAMES
        incbin "data/wnames.dat"
        ;include "wmenu2.asm"
end7

        page 3 ;--------Кунги+эффекты-------
	ORG #C000
begin3
        incbin "data/wsorc.dat"

SOU0	;удар меча
	DEFW 27
	DEFB 12,#FF
	DEFW 25
	DEFB 15,10
	DEFW 15
	DEFB 15,16
	DEFW 15
	DEFB 15,20
	DEFW 14
	DEFB 14,23
	DEFW 14
	DEFB 11,28
	DEFW 14
	DEFB 7,30
	DEFB #FF

SOU1	;удар топора, cкелета, стеногрыза, полоза
	DEFW 1540
	DEFB 13,1
	DEFB #FF

SOU7	;укус паука, скорпиона
	DEFW 1340
	DEFB 14,#FF
	DEFB #FF

SOU5	;колдовство
	DEFW 40
	DEFB 14,#FF
	DEFW 80
	DEFB 14,#FF
	DEFW 50
	DEFB 14,#FF
	DEFW 100
	DEFB 13,#FF
	DEFW 56
	DEFB 14,#FF
	DEFW 110
	DEFB 14,#FF
	DEFW 60
	DEFB 14,#FF
	DEFW 120
	DEFB 13,#FF
	DEFW 70
	DEFB 14,#FF
	DEFW 140
	DEFB 14,#FF
	DEFW 80
	DEFB 14,#FF
	DEFW 150
	DEFB 13,#FF
	DEFW 300
	DEFB 11,#FF
	DEFB #FF

SOU6	;волш/свящ стреляют
	DEFW 540
	DEFB 11,4
	DEFW 354
	DEFB 13,4
	DEFW 568
	DEFB 10,#FF
	DEFB #FF

SOU2	;взрыв
	DEFW 1000
	DEFB 10,27
	DEFW 1200
	DEFB 14,24
	DEFW 1450
	DEFB 15,18
	DEFW 1650
	DEFB 15,15
	DEFW 1700
	DEFB 15,11
	DEFW 1800
	DEFB 15,16
	DEFW 1950
	DEFB 15,20
	DEFW 2050
	DEFB 15,26
	DEFW 2100
	DEFB 15,22
	DEFW 2200
	DEFB 15,21
	DEFW 2250
	DEFB 15,29
	;
	DEFW 2300
	DEFB 15,23
	DEFW 2350
	DEFB 15,22
	DEFW 2400
	DEFB 15,17
	DEFW 2450
	DEFB 15,14
	DEFW 2500
	DEFB 15,10
	DEFW 2550
	DEFB 15,06
	DEFW 2600
	DEFB 15,07
	DEFW 2650
	DEFB 14,12
	DEFW 2700
	DEFB 14,18
	DEFW 2750
	DEFB 14,22
	DEFW 2800
	DEFB 14,27
	;
SOU8	DEFW 2850 ;малый взр
	DEFB 13,31
	DEFW 2900
	DEFB 13,30
	DEFW 2950
	DEFB 13,27
	DEFW 3100
	DEFB 12,26
	DEFW 3200
	DEFB 12,22
	DEFW 3300
	DEFB 12,17
	DEFW 3400
	DEFB 11,12
	DEFW 3500
	DEFB 11,07
	DEFW 3600
	DEFB 10,09
	DEFW 3750
	DEFB 10,16
	DEFW 3900
	DEFB 08,21
	DEFB #FF
end3

        page 4 ;--------Люди-------
	ORG #C000
begin4
        incbin "data/wshum.dat"
;вспомогательн. подпрограмы
        nop;CHK_8	 DEFB #EE; [**B] чек-сум7 4:#FF00
        ;include "wmisc_4.asm"
end4

        page 6 ;---Магич.создания--
	ORG #C000
begin6
        include "wmap.asm" ;первый!
	DEFS #C400-$ ;c #C300 - invTAB
WSCREA
        incbin "data/wscreat1.dat"
WMISC3	EQU WSCREA+8608   ;доп.спр3Х3
;вспомогательн. подпрограмы
        include "wmisc_6.asm"
end6

        page 1 ;---Cпрайты ландшафта--
	ORG #C000
begin1
        if EGA==0
WMISC2			;доп.спр2Х2
        incbin "data/wmisc.dat"
WMISC4	EQU WMISC2+1792 ;доп.спр4Х4
WMISC1	EQU WMISC2+3328 ;доп.спр1Х1
        endif
        include "wmisc_1.asm" ;доп п/п
;селект-рамки----
        if EGA
;_=0x1b00
_=0x1200
_l=_&0x4700+0xb8
_r=_&0xb800+0x47
_0=0x00ff
_hgt=16
fr2x2h=$+4
        db 8 ;wid/2
        db _hgt
        dw _,_l,_l,_l,_l,_l,_l,_l, _l,_l,_l,_l,_l,_l,_l,_
        dw 0x4000 - ((_hgt-1)*40)
       dup 8-2
        dw _,0,_0,_0,_0,_0,_0,_0, _0,_0,_0,_0,_0,_0,0,_
        dw 0x4000 - ((_hgt-1)*40)
       edup
        dw _,_r,_r,_r,_r,_r,_r,_r, _r,_r,_r,_r,_r,_r,_r,_
        dw 0xffff
        dw prsprqwid

_hgt=24
fr3x3h=$+4
        db 12 ;wid/2
        db _hgt
        dw _,_l,_l,_l,_l,_l,_l,_l, _l,_l,_l,_l,_l,_l,_l,_l, _l,_l,_l,_l,_l,_l,_l,_
        dw 0x4000 - ((_hgt-1)*40)
       dup 12-2
        dw _,0,_0,_0,_0,_0,_0,_0, _0,_0,_0,_0,_0,_0,_0,_0, _0,_0,_0,_0,_0,_0,0,_
        dw 0x4000 - ((_hgt-1)*40)
       edup
        dw _,_r,_r,_r,_r,_r,_r,_r, _r,_r,_r,_r,_r,_r,_r,_r, _r,_r,_r,_r,_r,_r,_r,_
        dw 0xffff
        dw prsprqwid

        else
;or,xor, стоблцами
fr2x2h	DEFW #FFFF,#80FF,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80FF,#FFFF
	DEFW #FFFF,#01FF,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#01FF,#FFFF
fr3x3h	DEFW #FFFF,#80FF,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80C0
	DEFW #80C0,#80C0,#80C0,#80C0,#80C0,#80C0,#80FF,#FFFF
	DEFW #FFFF,#00FF,0,0,0,0,0,0
	DEFW 0,0,0,0,0,0,0,0
	DEFW 0,0,0,0,0,0,#00FF,#FFFF
	DEFW #FFFF,#01FF,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#0103,#0103
	DEFW #0103,#0103,#0103,#0103,#0103,#0103,#01FF,#FFFF
        endif
	ds #D000-$
LAND			;ландшафт
shadwA	EQU	49*32+LAND
SHADOW	EQU	383*32+LAND
        incbin "data/w2spr.dat" ;1(*)
;*B ..\DATA\w2SPR.DAT ;2
;*B ..\DATA\w3SPR.DAT ;3
;*B ..\DATA\w4SPR.DAT ;4
end1
;*P0 ;-------------------

        if EGA
MONEYPRINT=iPRINT
        else
MONEYPRINT=PRINT
        endif


	display "COORD=",COORD
	display "begin=",begin
	display "end=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
        page 0
	savebin "br.com",begin,end-begin
        page 0
	savebin "br/br0.dat",begin0,end0-begin0
        page 1
	savebin "br/br1.dat",begin1,end1-begin1
        page 3
	savebin "br/br3.dat",begin3,end3-begin3
        page 4
	savebin "br/br4.dat",begin4,end4-begin4
        page 6
	savebin "br/br6.dat",begin6,end6-begin6
        page 7
	savebin "br/br7.dat",begin7,end7-begin7
	
	;LABELSLIST "..\us\user.l"

        display "putBAR=",putBAR
        display "BUT_1=",BUT_1
