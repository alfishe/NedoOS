        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;+0
        dw tankyu0
        dw tankyu1
        dw tankyr0
        dw tankyr1
        dw tankgu0 ;8
        dw tankgu1 ;a
        dw tankgr0 ;c
        dw tankgr1 ;e
        dw tankYu0
        dw tankYu1
        dw tankYr0
        dw tankYr1
        dw tankGu0
        dw tankGu1
        dw tankGr0
        dw tankGr1
        dup 16
        dw tankyu0
        edup
;+64
        dw tankwu0
        dw tankwu1
        dw tankwr0
        dw tankwr1
        dw tankru0
        dw tankru1
        dw tankrr0
        dw tankrr1
         dw tile1 ;dw bonus0
         dw tile2 ;dw bonus1
         dw tile3 ;dw bonus2
         dw tile4 ;dw bonus3
         dw tile5 ;dw bonus4
         dw tile6 ;dw bonus5
         dw tile7 ;dw bonus6
         dw tile8 ;dw bonus7
        dup 16+64
        dw tankyu0
        edup
;+256
;mirror hrz
        dw tankyu0
        dw tankyu1
        dw tankyl0
        dw tankyl1
        dw tankgu0
        dw tankgu1
        dw tankgl0
        dw tankgl1
        dw tankYu0
        dw tankYu1
        dw tankYl0
        dw tankYl1
        dw tankGu0
        dw tankGu1
        dw tankGl0
        dw tankGl1
        dup 16
        dw tankyu0
        edup
        dw tankwu0
        dw tankwu1
        dw tankwl0
        dw tankwl1
        dw tankru0
        dw tankru1
        dw tankrl0
        dw tankrl1
        dup 24+64
        dw tankyu0
        edup
;+512
;mirror vert
        dw tankyd0
        dw tankyd1
        dw tankyr0
        dw tankyr1
        dw tankgd0
        dw tankgd1
        dw tankgr0
        dw tankgr1
        dw tankYd0
        dw tankYd1
        dw tankYr0
        dw tankYr1
        dw tankGd0
        dw tankGd1
        dw tankGr0
        dw tankGr1
        dup 16
        dw tankyu0
        edup
        dw tankwd0
        dw tankwd1
        dw tankwr0
        dw tankwr1
        dw tankrd0
        dw tankrd1
        dw tankrr0
        dw tankrr1
       if 1==0
        dup 24+64
        dw tankyu0
        edup
;+768
;mirror hrz+vert (unneeded?)
        dw tankyd0
        dw tankyd1
        dw tankyl0
        dw tankyl1
        dw tankgd0
        dw tankgd1
        dw tankgl0
        dw tankgl1
        dw tankYd0
        dw tankYd1
        dw tankYl0
        dw tankYl1
        dw tankGd0
        dw tankGd1
        dw tankGl0
        dw tankGl1
        dup 16
        dw tankyu0
        edup
        dw tankwd0
        dw tankwd1
        dw tankwl0
        dw tankwl1
        dw tankrd0
        dw tankrd1
        dw tankrl0
        dw tankrl1
        dup 24+64
        ;dw tankyu0
        edup
       endif
        include "sprites.ast"
end
	savebin "zxbattle/spr0.dat",begin,end-begin
