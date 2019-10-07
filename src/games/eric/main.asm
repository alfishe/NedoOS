        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

        org PROGSTART
begin

        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        OS_GETSCREENPAGES

        ld a,d
        SETPG16K

		include "eric1.asm"

oldtimer
        dw 0
quiter
	QUIT ;rasmer

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "eric.com",begin,end-begin