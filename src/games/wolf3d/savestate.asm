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

health
        db 20
bullets
        db 10
grenades
        db 2
leveltime
        dw 0
gametime
        dw 0
firedelaycounter
        db 0
downtimer_time
        db 1

        DS ((-$)&7)&0xff
MONSTRS
;Xx,Yy,TYPEphase_dir,TIMEenergy ;TYPEphase=TYPE*8+phase (было PHASE_type)
        ;DW -1
	DW #0F80,#AF80,#100,-1;ENEMY
	DW #2680,#A080,#100,64
	DW #0380,#BA80,#100,64
	DW #0780,#B780,#100,64

	DW #0F80,#B080,#102,64
	DW #1380,#A080,#100,64
	DW #1380,#AA80,#100,64
	DW #1380,#B280,#100,64
	DW #1380,#B380,#100,64
	DW #1280,#B580,#102,64
	DW #1480,#AB80,#100,64
	DW #1480,#AE80,#102,64

	DW #1480,#B080,#102,64
	DW #1480,#B380,#100,64
	DW #1580,#A180,#102,80
	DW #1680,#AD80,#102,90
	DW #1680,#B180,#102,100
	DW #2180,#AD80,#102,10
	DW #2380,#A080,#100,50
	DW #2380,#A580,#102,50

	DW #2680,#A480,#103,50
	DW #2680,#B280,#104,50
	DW #2780,#A880,#105,50
	DW #2780,#B180,#103,64

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

;сейчас TYPE кодируется так (что видно в редакторе: что в TYPE):
;31: вход
;29: выход
;32..63: goods (58..63: gold 5,10,20,50,100,200)
;1..28: monsters
