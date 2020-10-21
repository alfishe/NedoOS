        DEVICE ZXSPECTRUM1024
        org 0x8000
begin
        include "ayfxplay.asm"
sfx
        incbin "sfx.afb"
end
	savebin "wolf3d/sfx.bin",begin,end-begin
