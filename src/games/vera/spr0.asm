        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;+0
        dw hero_r0
        dw hero_r1
        dw hero_r2
        dw hero_l0
        dw hero_l1 ;8
        dw hero_l2 ;a
        dw hero_u0 ;c
        dw hero_u1 ;e
        dw hero_u2
        dw hero_d0
        dw hero_d1
        dw hero_d2
        dw herour0
        dw herour1
        dw herour2
        dw herodr0
        dw herodr1
        dw herodr2
        dw heroul0
        dw heroul1
        dw heroul2
        dw herodl0
        dw herodl1
        dw herodl2
        include "sprites0.ast"
end
	savebin "vera/sprites0.bin",begin,end-begin
