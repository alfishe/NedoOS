scrbase=0x4000+4
iconsscraddr=scrbase+25+(32*40)
faceiconsscraddr=scrbase+(17*8*40)+1
sprmaxwid=48;32
sprmaxhgt=32
scrwid=128+8;160 ;double pixels
scrhgt=192;200
INTSTACK=0x3f00
tempsp=0x3f06 ;6 bytes for prspr

        ld sp,STACK
        OS_HIDEFROMPARENT
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

	ld de,file_path
	OS_CHDIR

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000
        ld a,e
        ld (pgmain4000),a
        ld a,h
        ld (pgmain8000),a
        ld a,l
        ld (tpgs+0),a

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,(user_scr1_high) ;ok
       if 0;EGA
         ;ld (scrpg7),a
       else
         ld (getttexpgs_basepg7),a
       endif

        OS_NEWPAGE
        ld a,e
        ld (tpgs+6),a

        ld hl,texfilename
        ;ld b,ntexfilenames
getttexpgs0
        ;push bc
        ld a,(hl)
        or a
        ld a,(tpgs+0) ;не перезахватываем 0-ю страницу
        jr z,getttexpgs7
        ld a,(hl)
       if 1;EGA==0
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
        ld b,tpgs/256
        ld (bc),a
        inc hl
        push hl
        SETPGC000

        ld a,(hl)
        cp ' '
        jr nc,gettexpgs_noskipdata
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
        ;pop bc
        ld a,(hl)
        inc a
        jr nz,getttexpgs0
        
       if 0
        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        call setpgsscr40008000 ;включили страницы экрана
        ld a,8
        call setpg

	ld iy,0xc004;human_0
	ld e,50 ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
	ld c,50 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
	call prspr

        call setpgsmain40008000 ;включили страницы программы в 4000,8000, как было
        call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали
        jr $
       endif
        jp JP_ST

        align 256
tpgs
        ds 64

quit
        ld hl,0 ;result
        QUIT

PT128	LD	A,6;Cтандартная страница
	JR	MEM

MEM7	LD	A,7
MEM	OR	%11011000
_128	;LD	BC,#7FFD
	;OUT	(C),A
        and 7
setpg
        ld b,tpgs/256
        ld c,a
        ld a,(bc)
        SETPGC000
	RET

LODmlz	LD HL,#4000 ;c компр
	;CALL WT
;WT
        RLCA
	ADD	A,L
	LD	L,A
	JR	NC,wWT_
	INC	H
wWT_	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	;RET
	XOR A
	CALL MEM
	;JP DELPC

;DEC40
        include "unmegalz.asm"

SEED	DEFW 1 ;счётчик

prtile
        ;ret
;de=gfx
        ld h,tmask/256
;h=tmask/256
;bc=scr
;hx=hgt
;4000,8000,6000,a000
        push bc
        call prtilepp
        pop bc
        push bc
        ld a,b
        add a,0x40
        ld b,a
        call prtilepp
        pop bc
        push bc
        set 5,b
        call prtilepp
        pop bc
        ld a,b
        add a,0x60
        ld b,a
prtilepp
       push ix
prtile0
        LD A,(de)
        INC e
        LD L,A
        LD A,(bc)
        AND (HL)
        OR L
        LD (bc),A
        ld a,c
        add a,40
        ld c,a
        jr nc,$+3
        inc b
        dec hx
        jr nz,prtile0
       pop ix
        ret

        align 256
temptilebuf
        ds 256
        align 256
tmask
        incbin "tmask"

        include "xlib.asm"

        include "prspr.asm"
        include "mem.asm"
        
;curscrnum_int
;        db 0

file_path
        db "ufo2",0

texfilename
       if EGA
        db 0,"ufo20ega.dat",0
       else
        db 0,"ufo20.dat",0
       endif
        db 1,"ufo21.dat",0
        db 3,"ufo23.dat",0
        db 4,"ufo24.dat",0
        ;db 6,"br6.dat",0
        db 7,"ufo27.dat",0
        db 8,"ufospr1.dat",0
        db 9,"ufospr2.dat",0
        db 10,"ufospr3.dat",0
        db 11,"ufospr4.dat",0
        db 12,"ufospr5.dat",0
        db 13,"ufoxm11a.dat",0
        db 14,"ufoxm11b.dat",0
        ;if EGA==0
;ntexfilenames=5
        ;else
        ;endif
        db -1

        include "int.asm"

findsprfilename
;a=#=1..74
        ld hl,sprfilenames
findsprfilename0
        dec a
        ret z
        push af
        xor a
        ld b,a
        ld c,a
        cpir ;hl=после 0
        pop af
        jr findsprfilename0

sprfilenames
	DEFB "xm2.dat",0;	0,0 ;#1 (m2)
	DEFB "xm3.dat",0;	1,150 ;#2 (m3)
	DEFB "xm4.dat",0;	3,49 ;#3 (m4)
	DEFB "xm5.dat",0;	7,5 ;#4 (m5)
	DEFB "xm10.dat",0;	10,247 ;#5 (m10)
	DEFB "xm7.dat",0;	14,152 ;#6 (m7)
	DEFB "xm8.dat",0;	19,133 ;#7 (m8)
	DEFB "xm9.dat",0;	22,169 ;#8 (m9)
	DEFB "xm6.dat",0;	26,94 ;#9 (m6)
	DEFB "xm11.dat",0;	29,173 ;#10 (m11)
	DEFB "xm12.dat",0;	33,58 ;#11 (m12)
	DEFB "xm13.dat",0;	37,213 ;#12 (m13)
	DEFB "xm14.dat",0;	42,77 ;#13 (m14)
	DEFB "xm15.dat",0;	44,11 ;#14 (m15)
	DEFB "xm16.dat",0;	45,217 ;#15 (m16)
	DEFB "xm17.dat",0;	47,209 ;#16 (m17)
	DEFB "xm18.dat",0;	49,120 ;#17 (m18)
	DEFB "xm19.dat",0;	51,58 ;#18 (m19)
	DEFB "xm20.dat",0;	53,29 ;#19 (m20)
	DEFB "XL2.LND",0;	54,198 ;#20 (l2)
	DEFB "end.bin",0;	56,127 ;#21 (end)
	DEFB "XL3.LND",0;	62,199 ;#22 (l3)
	DEFB "XL4.LND",0;		64,84 ;#23 (l4)
	DEFB "XL5A.LND",0;		66,26 ;#24 (l5a)
	DEFB "XL5B.LND",0;		67,244 ;#25 (l5b)
	DEFB "XL5C.LND",0;		69,154 ;#26 (l5c)
	DEFB "XL5D.LND",0;		71,94 ;#27 (l5d)
	DEFB "XL6A.LND",0;		72,247 ;#28 (l6a)
	DEFB "XL6B.LND",0;		75,7 ;#29 (l6b)
	DEFB "XL6C.LND",0;		77,43 ;#30 (l6c)
	DEFB "XL6D.LND",0;		79,58 ;#31 (l6d)
	DEFB "x2.bin",0;		81,67 ;#32 (X2) ;???
	DEFB "XL7.LND",0;	81,71 ;#33 (l7)
	DEFB "XL8A.LND",0;	83,32 ;#34 (l8a)
	DEFB "XL8B.LND",0;	84,248 ;#35 (l8b)
	DEFB "XL8C.LND",0;	86,214 ;#36 (l8c)
	DEFB "XL8D.LND",0;	88,174 ;#37 (l8d)
	DEFB "XL9.LND",0;	90,128 ;#38 (l9)
	DEFB "x3.bin",0;	92,99 ;#39 (X3)
	DEFB "XL10A.LND",0;	92,103 ;#40 (l10a)
	DEFB "XL10B.LND",0;	93,141 ;#41 (l10b)
	DEFB "XL10C.LND",0;	94,179 ;#42 (l10c)
	DEFB "XL10D.LND",0;	95,225 ;#43 (l10d)
	DEFB "XL11.LND",0;	97,14 ;#44 (l11)
	DEFB "XL12.LND",0;	98,210 ;#45 (l12)
	DEFB "XL13.LND",0;	100,74 ;#46 (l13)
	DEFB "XL14.LND",0;	102,38 ;#47 (l14)
	DEFB "XL15.LND",0;	103,88 ;#48 (l15)
	DEFB "XL19.LND",0;	105,16 ;#49 (l19)
	DEFB "XL17.LND",0;	105,217 ;#50 (l17)
	DEFB "XL18.LND",0;	107,46 ;#51 (l18)
	DEFB "XL16.LND",0;	108,109 ;#52 (l16)
	DEFB "XL20.LND",0;	109,188 ;#53 (l20)
	DEFB "up1.bin",0;	111,18 ;#54 (up1) ;???
	DEFB "up2.bin",0;	116,94 ;#55 (up2)
	DEFB "up3.bin",0;	121,183 ;#56 (up3)
	DEFB "up4.bin",0;	127,21 ;#57 (up4)
	DEFB "up5.bin",0;	131,62 ;#58 (up5)
	DEFB "up6.bin",0;	138,99 ;#59 (up6)
	DEFB "up7.bin",0;	150,43 ;#60 (up7)
	DEFB "up8.bin",0;	161,37 ;#61 (up8)
	DEFB "up9.bin",0;	172,200 ;#62 (up9)
	DEFB "up10.bin",0;	184,174 ;#63 (up10)
	DEFB "up11.bin",0;	191,192 ;#64 (up11)
	DEFB "up12.bin",0;	202,114 ;#65 (up12)
	DEFB "up13.bin",0;	206,254 ;#66 (up13)
	DEFB "up14.bin",0;	211,239 ;#67 (up14)
	DEFB "up15.bin",0;	217,97 ;#68 (up15)
	DEFB "up16.bin",0;	225,4 ;#69 (up16)
	DEFB "up17.bin",0;	231,142 ;#70 (up17)
	DEFB "up18.bin",0;	238,185 ;#71 (up18)
	DEFB "up19.bin",0;	249,150 ;#72 (up19)
	DEFB "up20.bin",0;	3,246 ;#73 (up20)
	DEFB "theend.bin",0;	15,13 ;the end

