        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
        ld hl,MDLADDR
        jr INIT
        call PLAY
        ret;jp 0x8003 ;sfx
        include "../../_sdk/ptsplay.asm"
MDLADDR
        incbin "UFO_2_Intro.pt3"
	savebin "ufo2/ufomuz3.bin",begin,$-begin
