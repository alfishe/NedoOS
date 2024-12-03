       if atm
        include "../../_sdk/sys_h.asm"
       endif
;atm=1
;doublescr=1
showfps=1-atm
EDITOR=0

crosshair=1;0

	if atm
ID_DOOR=0+(22*2);127
	else
ID_DOOR=0x40+((22-16)*2);127
	endif

;ZX data:
music=doublescr

debug=0
demorec=0
demoplay=0;1

;control:
doublespeed=1
doublerotate=1
autostrafe=1
kempston=0;1
mouse=1
mindist=64;111 ;max=111 ;118 stuck in door

colour=7
ceilingcolour=0
floorcolour=colour*9
ceilingcolourbyte=0b00000000;%11111111 ;atm
floorcolourbyte=0b00010010;%11110110 ;atm

sprites=1
CURSPRITES_RECSZ=5;4 ;ID, distL, distH, xscr, [monsterindex]
FATMONSTERS=0
viewrange=6
woundrange=2
MONSTERviewrange=3
MONSTERBACKviewrange=2

scale64=3;1 ;0 не поддерживается

;render:
        if atm
scrwid=32 ;chr$
scrtopx=(32-scrwid)/2
scrhgt=200;128 ;pixels
scrhgtpix=scrhgt
Ycenter=100
Ytop=Ycenter-(scrhgt/2)
Ybottom=Ycenter+(scrhgt/2)
scrbase=0x4000+4
scrtop=Ytop*40+scrbase
        else
scrwid=24;32 ;chr$
scrtopx=(32-scrwid)/2
scrhgt=20;24 ;chr$ (10,12,...,24)
scrhgtpix=scrhgt*8
scrtop=(24-scrhgt)*16+#4000+scrtopx
attrtop=((scrtop/8)&0x300)+(0xff&scrtop)+0x5800
;для ускорения EOR-fill (частично замазывание атрибутами) размеры всегда активной части столбца:
lowscrtop=#4800+scrtopx
lowattrtop=((lowscrtop/8)&0x300)+(0xff&lowscrtop)+0x5800
lowscrhgt=8 ;chr$
lowscrhgtpix=lowscrhgt*8
        endif

        IF scale64
maxscale=63
 IF scale64 == 3 ;sc=(s+sh)^p/div, Ys=(Y/32-1)*sc, где s=0..63, Y=1..62, p=5, k=16^(-1/p), sh=(63*k)/(1-k), div = (63+sh)^p/1024*8
lowmaxscale=27;28 ;fit in low screen
 ELSE 
lowmaxscale=19 ;fit in low screen
 ENDIF 
        ELSE 
maxscale=127
lowmaxscale=25 ;fit in low screen
        ENDIF 
mapdifbit=5;7
        IF atm == 0
lores=0
optres=1&(1-lores) ;+22t на мелких, выигрыш на крупных
        ELSE 
lores=1
optres=0
        ENDIF 
optfast=1;0 ;в движении рисуем грубо
loresspr=0|lores
optresspr=1&(1-loresspr) ;выигрыш на крупных
loresspr_hires=loresspr&(1-lores)
pixperchr=8>>lores
corr_coord=1
 if atm
interpolate=4
 else
interpolate=16
 endif
antizalom=1

        if lores
SCRWIDPIX=scrwid*4
        else
SCRWIDPIX=scrwid*8
        endif

        if atm
scrbuf=#6040
        else
scrbuf=#A040
lowscrbuf=(scrhgtpix-lowscrhgtpix)/2+scrbuf
        endif
scrbufflag=(scrbuf&#FF00)+32
dropline=scrhgt*8+(0xff&scrbuf) ;Y=192
map=scrbuf-#3F;#A001 ;+0 занят dropline, +32 занят флагом высоких
mapend=map+#2000
invmap=1

        if atm == 0
tscale=#C000 ;128x64, множители 0 и 63 выдают константы 0 и 3
             ;64x64 при scale64=1
        endif

RENDERSPEEDLIMIT=2 ;1=50 fps, 2=25 fps, 3=17 fps
LOGICSPEED=2       ;1=50 fps, 2=25 fps, 3=17 fps

TIME_WOUNDED=30/LOGICSPEED
TIME_WANTATTACK=40/LOGICSPEED
TIME_ATTACK=25/LOGICSPEED
TIME_STEP=10/LOGICSPEED
TIME_SHOT=10/LOGICSPEED
TIME_WOUNDED=10/LOGICSPEED
TIME_EXPLODE=10/LOGICSPEED
