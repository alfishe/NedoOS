 ifndef included_xasinh
 define included_xasinh
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xadd.asm"
 include "xsqrt.asm"
 include "xbg.asm"

;x/BG(sqrt(1-x^2),1)
var_x=xOP1+152 ;FIXME
xasinh:
  call pushpop
  push bc
  push hl
  ld d,h
  ld e,l
  ld bc,xOP1
  call xmul
  ld h,b
  ld l,c
  ld de,xconst_1
  call xadd
  call xsqrt
  call xbg
  pop de
  pop bc
  jp xmul
 endif
