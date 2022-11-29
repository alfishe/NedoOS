        DEVICE ZXSPECTRUM1024
        org 0x4000
begin
        ld hl,MDLADDR
        jr INIT
        call PLAY
        jp 0x8003
        include "../../_sdk/ptsplay.asm"
MDLADDR
        incbin "everlast.pt3"
end
	savebin "sprexamp/music.bin",begin,end-begin
