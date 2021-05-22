        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

STACK=0x4000
IMVEC=#4100

        include "macro.asm"

;*Z80
;*O	
;*P4
        page 4
	ORG #C000	
;*B XCOM.B00
        incbin "ufo2/ufo24.dat"
;*P3
        page 3
	ORG #C000
;*B XCOM.B01
        incbin "ufo2/ufo23.dat"
;*P1	
        page 1
	ORG #C000
;*B XCOM.B02
        incbin "ufo2/ufo21.dat"
;*P7
        page 7
	ORG #C000
;*B XCOM.B03
        incbin "ufo2/ufo27.dat"
;*P0
        page 0

	ORG #C000
begin0
BLK2
;*B XCOM.LP2
        incbin "blk2.bin.mlz"
BLK3
;*B XCOM.LP3
        incbin "blk3.bin.mlz"
BLK4
;*B XCOM.LP4
        incbin "blk4.bin.mlz"
BLK1
;*B XCOM.LP1
        incbin "blk1.bin.mlz"
	;DEFR #FFF0-$
        ds #FFF0-$
	db "Моя работа!"
end0

        org PROGSTART
begin
        include "loader.asm"

	ORG #4000
	DEFW BLK1;+2
	DEFW BLK2;+2
	DEFW BLK3;+2
	DEFW BLK4;+2	
	DEFS #4000+16-$,1
JP_ST
	;ENT $ ;--------вход 
;*B XCOM.B04
        incbin "ufo2/ufo2main.dat"
end

	savebin "ufo2/ufo20.dat",begin0,end0-begin0
	savebin "ufo2.com",begin,end-begin
