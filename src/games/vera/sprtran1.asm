        DEVICE ZXSPECTRUM1024
        org 0xc000
begin
prsprqwid=0x0100 ;TODO прямо по какому-то адресу код, а не jp
;+0
        dw hero2_r0
        dw hero2_r1
        dw hero2_r2
        dw hero2_l0
        dw hero2_l1 ;8
        dw hero2_l2 ;a
        dw hero2_u0 ;c
        dw hero2_u1 ;e
        dw hero2_u2
        dw hero2_d0
        dw hero2_d1
        dw hero2_d2
        dw hero2ur0
        dw hero2ur1
        dw hero2ur2
        dw hero2dr0
        dw hero2dr1
        dw hero2dr2
        dw hero2ul0
        dw hero2ul1
        dw hero2ul2
        dw hero2dl0
        dw hero2dl1
        dw hero2dl2
        include "sprtran1.ast"
end
	savebin "vera/sprtran1.bin",begin,end-begin
