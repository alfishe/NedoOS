        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;my tank level 2 (+16),3 (+128+16), enemy2 (+0)
;+0
        dw tankw2u0
        dw tankw2u1
        dw tankw2r0
        dw tankw2r1
        dw tankr2u0
        dw tankr2u1
        dw tankr2r0
        dw tankr2r1
        dw tankY2u0
        dw tankY2u1
        dw tankY2r0
        dw tankY2r1
        dw tankG2u0
        dw tankG2u1
        dw tankG2r0
        dw tankG2r1
        dup 16
        dw tankY2u0
        edup
;+64
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
;+128
         dup 8
         dw tankY2u0
         edup
        dw tankY3u0
        dw tankY3u1
        dw tankY3r0
        dw tankY3r1
        dw tankG3u0
        dw tankG3u1
        dw tankG3r0
        dw tankG3r1
        dup 16
        dw tankY2u0
        edup
;+192
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
;+256
;mirror hrz
        dw tankw2u0
        dw tankw2u1
        dw tankw2l0
        dw tankw2l1
        dw tankr2u0
        dw tankr2u1
        dw tankr2l0
        dw tankr2l1
        dw tankY2u0
        dw tankY2u1
        dw tankY2l0
        dw tankY2l1
        dw tankG2u0
        dw tankG2u1
        dw tankG2l0
        dw tankG2l1
        dup 16
        dw tankY2u0
        edup
 ;+256+64
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
 ;+256+128
         dup 8
         dw tankY2u0
         edup
        dw tankY3u0
        dw tankY3u1
        dw tankY3l0
        dw tankY3l1
        dw tankG3u0
        dw tankG3u1
        dw tankG3l0
        dw tankG3l1
        dup 16
        dw tankY2u0
        edup
 ;+256+192
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
;+512
;mirror vert
        dw tankw2d0
        dw tankw2d1
        dw tankw2r0
        dw tankw2r1
        dw tankr2d0
        dw tankr2d1
        dw tankr2r0
        dw tankr2r1
        dw tankY2d0
        dw tankY2d1
        dw tankY2r0
        dw tankY2r1
        dw tankG2d0
        dw tankG2d1
        dw tankG2r0
        dw tankG2r1
        dup 16
        dw tankY2u0
        edup
 ;+512+64
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
 ;+512+128
         dup 8
         dw tankY2u0
         edup
        dw tankY3d0
        dw tankY3d1
        dw tankY3r0
        dw tankY3r1
        dw tankG3d0
        dw tankG3d1
        dw tankG3r0
        dw tankG3r1
 ;+512+192
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
;+768
;mirror hrz+vert (unneeded?)
        dw tankw2d0
        dw tankw2d1
        dw tankw2l0
        dw tankw2l1
        dw tankr2d0
        dw tankr2d1
        dw tankr2l0
        dw tankr2l1
        dw tankY2d0
        dw tankY2d1
        dw tankY2l0
        dw tankY2l1
        dw tankG2d0
        dw tankG2d1
        dw tankG2l0
        dw tankG2l1
        dup 16
        dw tankY2u0
        edup
 ;+768+64
         dup 16
         dw tankY2u0
         edup
        dup 16
        dw tankY2u0
        edup
 ;+512+128
         dup 8
         dw tankY2u0
         edup
        dw tankY3d0
        dw tankY3d1
        dw tankY3l0
        dw tankY3l1
        dw tankG3d0
        dw tankG3d1
        dw tankG3l0
        dw tankG3l1

        include "spr2.ast"
end
	savebin "zxbattle/spr2.dat",begin,end-begin
