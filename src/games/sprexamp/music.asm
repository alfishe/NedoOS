        DEVICE ZXSPECTRUM1024
        org 0x4000
begin
        include "ptsplay.asm"
module
        incbin "everlast.pt3"
end
	savebin "sprexamp/music.bin",begin,end-begin
