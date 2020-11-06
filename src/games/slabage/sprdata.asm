        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
        dw dragon0
        dw dragon1
        dw dragon2
        dw dragon3
        dw dragon4
        dw dragon5
        dw dragon6
        dw dragon7
        dw dragon8
        dw dragon9
        dw dragon10
        dw dragon11
        dw cursor0
        dw cursor1
        dw cursor2
        include "sprites.ast"
end
	savebin "slabage/sprdata.bin",begin,end-begin
