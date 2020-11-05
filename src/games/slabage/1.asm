        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"  

STACK=0x4000;0x61a8
GAMESTACK=0x4000;0xFFFF
L_FDFD=0xfdfd
L_FE00=0xfe00

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,3+0x80 ;6912+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

	;ld e,0
	;OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	;ld e,1
	;OS_SETSCREEN
        ;ld e,0 ;color byte
        ;OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ;ld a,e
        ;ld (pgcode4000),a
        ld a,h
        ld (pgcode8000),a
        ;ld a,l
        ;ld (pgcodec000),a 


        ld a,(user_scr0_high)
        SETPG32KLOW
        ld hl,0x6000
        ld de,0x6000+0x4000
        ld bc,0x2000
        ldir
        ;ld a,(user_scr0_high)
        SETPG16K
pgcode8000=$+1
        ld a,0
        SETPG32KLOW
        
        ;ld sp,STACK
        jp GO
        
reter
        ret
        
        ds 0x61a8-$+777
        include "SB.ASM"
end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "slabage.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
