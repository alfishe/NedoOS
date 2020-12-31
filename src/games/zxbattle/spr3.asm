        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;enemy 3 (+0),4 (+64),5 (+128)
;+0
        dw tankw3u0
        dw tankw3u1
        dw tankw3r0
        dw tankw3r1
        dw tankr3u0
        dw tankr3u1
        dw tankr3r0
        dw tankr3r1
        dup 8+16
        dw tankw3u0
        edup
;+64
        dw tankw4u0
        dw tankw4u1
        dw tankw4r0
        dw tankw4r1
        dw tankr4u0
        dw tankr4u1
        dw tankr4r0
        dw tankr4r1
        dup 8+16
        dw tankw3u0
        edup
;+128
        dw tankw5u0
        dw tankw5u1
        dw tankw5r0
        dw tankw5r1
        dw tankr5u0
        dw tankr5u1
        dw tankr5r0
        dw tankr5r1
        dup 8+16
        dw tankw3u0
        edup
;+192
         dup 16
         dw tankw3u0
         edup
        dup 16
        dw tankw3u0
        edup
;+256
;mirror hrz
        dw tankw3u0
        dw tankw3u1
        dw tankw3l0
        dw tankw3l1
        dw tankr3u0
        dw tankr3u1
        dw tankr3l0
        dw tankr3l1
        dup 8+16
        dw tankw3u0
        edup
 ;+256+64
        dw tankw4u0
        dw tankw4u1
        dw tankw4l0
        dw tankw4l1
        dw tankr4u0
        dw tankr4u1
        dw tankr4l0
        dw tankr4l1
        dup 8+16
        dw tankw3u0
        edup
 ;+256+128
        dw tankw5u0
        dw tankw5u1
        dw tankw5l0
        dw tankw5l1
        dw tankr5u0
        dw tankr5u1
        dw tankr5l0
        dw tankr5l1
        dup 8+16
        dw tankw3u0
        edup
 ;+256+192
         dup 16
         dw tankw3u0
         edup
        dup 16
        dw tankw3u0
        edup
;+512
;mirror vert
        dw tankw3d0
        dw tankw3d1
        dw tankw3r0
        dw tankw3r1
        dw tankr3d0
        dw tankr3d1
        dw tankr3r0
        dw tankr3r1
        dup 8+16
        dw tankw3u0
        edup
 ;+512+64
        dw tankw4d0
        dw tankw4d1
        dw tankw4r0
        dw tankw4r1
        dw tankr4d0
        dw tankr4d1
        dw tankr4r0
        dw tankr4r1
        dup 8+16
        dw tankw3u0
        edup
 ;+512+128
        dw tankw5d0
        dw tankw5d1
        dw tankw5r0
        dw tankw5r1
        dw tankr5d0
        dw tankr5d1
        dw tankr5r0
        dw tankr5r1
        dup 8+16
        dw tankw3u0
        edup
 ;+512+192
         dup 16
         dw tankw3u0
         edup
        dup 16
        dw tankw3u0
        edup
;+768
;mirror hrz+vert (unneeded?)
        dw tankw3d0
        dw tankw3d1
        dw tankw3l0
        dw tankw3l1
        dw tankr3d0
        dw tankr3d1
        dw tankr3l0
        dw tankr3l1
        dup 8+16
        dw tankw3u0
        edup
 ;+768+64
        dw tankw4d0
        dw tankw4d1
        dw tankw4l0
        dw tankw4l1
        dw tankr4d0
        dw tankr4d1
        dw tankr4l0
        dw tankr4l1
        dup 8+16
        dw tankw3u0
        edup
 ;+512+128
        dw tankw5d0
        dw tankw5d1
        dw tankw5l0
        dw tankw5l1
        dw tankr5d0
        dw tankr5d1
        dw tankr5l0
        dw tankr5l1

        include "spr3.ast"
end
	savebin "zxbattle/spr3.dat",begin,end-begin
