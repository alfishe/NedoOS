 ifndef included_xatanh
 define included_xatanh
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xrsub.asm"
 include "xsqrt.asm"
 include "xbg.asm"

 include "xrsub.asm"
 include "xdiv.asm"
 include "xdiv2.asm"
 include "xln.asm"

;x/BG(1,sqrt(1-x^2))
var_x=xOP1+152 ;FIXME
xatanh:
;log((1+x)/(1-x))/2
  call pushpop
  push bc

  ld bc,xOP4
  ld de,xconst_1
  call xadd
  ld bc,xOP5
  ld de,xconst_1
  call xrsub
  ld d,b
  ld e,c
  ld hl,xOP4
  call xdiv
  ld h,b
  ld l,c
  call xln
  pop bc
  jp xdiv2
 endif
