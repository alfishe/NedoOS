        DEVICE ZXSPECTRUM1024
        org 0x4000
begin
        ld hl,MDLADDR
        jr INIT
        call PLAY
        jp 0x8003
        include "../../_sdk/ptsplay.asm"
MDLADDR
        incbin "testmusi.pt3"
end
	savebin "wolf3d/music.bin",begin,end-begin
