        DEVICE ZXSPECTRUM1024
        org 0x8000
begin
        include "ayfxplay.asm"
sfx
        incbin "sfx.afb"
end
	savebin "sprexamp/sfx.bin",begin,end-begin
