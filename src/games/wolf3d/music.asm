        DEVICE ZXSPECTRUM1024
        org 0x4000
begin
        include "ptsplay.asm"
module
        incbin "testmusi.pt3"
end
	savebin "wolf3d/music.bin",begin,end-begin
