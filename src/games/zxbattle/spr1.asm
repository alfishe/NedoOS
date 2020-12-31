        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;+0
        dup 16
         dw drop0
        edup
;+32
        dw megaship;drop01 ;???
        dw drop0
        dw megatank0;drop01
        dw megatank1;drop01
        dw gameover0;drop01
        dw gameover1;drop01
        dw cloud0 ;!!!
        dw cloud1 ;!!!
         dw megaboom0 ;drop0 ;???
         dw megaboom2 ;drop0 ;???
        dw bulletr0
        dw bulletu0
        dw boom0
        dw boom1
        dw boom2
         dw tree;drop0 ;???
;+64
        dup 16
         dw drop0
        edup
;+96
        dw bonus0
        dw bonus1
        dw bonus2
        dw bonus3
        dw bonus4
        dw bonus5
        dw bonus6
        dw bonus7
        dup 4
         dw drop01
        edup
        dw star0;boom0 ;???
        dw star1;boom1 ;???
        dw star2;boom2 ;???
         dw star3;drop0 ;???
;+128
        dup 16
         dw drop0
        edup
;+160
         dw drop0
        dw drop0
        dw megatank0
        dw megatank1
        dw gameover0
        dw gameover1
        dw cloud0
        dw cloud1
        dw tile9 ;dw star0
        dw tile10 ;dw star1
        dw tile11 ;dw star2
        dw tile12 ;dw star3
        dw tile13 ;dw drop0;megaboom00
        dw tile14 ;drop0;megaboom01
        dw tile0 ;drop0;megaboom10
        dw drop0;megaboom11
;+192
        dup 16
         dw drop0
        edup
        dw bonus8;drop0
         dw drop0
        dw megatank2
        dw megatank3
        dw pause0
        dw pause1
        dw pause2
        dw score10
        dw score20
        dw score30
        dw score40
        dw score50
        dw drop0;megaboom02
        dw drop0;megaboom03
        dw drop0;megaboom12
        dw drop0;megaboom13
;+256
;mirror hrz
        dup 16
         dw drop0
        edup
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
        dw bulletl0
        dw bulletu0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
;
        dup 16
         dw drop0
        edup
        dup 16
         dw drop0
        edup
        dup 64
         dw drop0
        edup
;+512
;mirror vert
        dup 16
         dw drop0
        edup
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
        dw bulletr0
        dw bulletd0
       if 1==0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
;
        dup 16
         dw drop0
        edup
        dup 16
         dw drop0
        edup
        dup 64
         dw drop0
        edup
;+768
;mirror hrz+vert (unneeded?)
        dup 16
         dw drop0
        edup
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
        dw bulletl0
        dw bulletd0
         dw drop0
         dw drop0
         dw drop0
         dw drop0
        endif

        include "spr1.ast"
drop01=boom0;drop0
end
	savebin "zxbattle/spr1.dat",begin,end-begin
