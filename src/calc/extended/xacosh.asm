 ifndef included_xacosh
 define included_xacosh
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xsub.asm"
 include "xsqrt.asm"
 include "xbg.asm"

;sqrt(x^2-1)/BG(x,1)
var_x=xOP1+152 ;FIXME
xacosh:
;log(x+sqrt(x^2-1))
  call pushpop
  push bc
  ld de,var_x-10
  call mov10
  ld hl,var_x-10
  ld d,h
  ld e,l
  ld bc,var_x-20
  call xmul
  ld h,b
  ld l,c
  ld de,xconst_1
  call xsub
  call xsqrt
  ld de,var_x-10
  call xadd
  pop bc
  jp xln




  ; push bc
  ; push hl
  ; ld d,h
  ; ld e,l
  ; ld bc,xOP1
  ; call xmul
  ; ld de,xconst_1
  ; ld h,b
  ; ld l,c
  ; ld bc,var_x
  ; call xsub
  ; ld h,b
  ; ld l,c
  ; call xsqrt
  ; pop hl
  ; ld bc,xOP1
  ; call xbg
  ; ld h,b
  ; ld l,c
  ; ld de,var_x
  ; pop bc
  ; jp xmul
 endif
