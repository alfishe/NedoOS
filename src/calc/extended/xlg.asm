 ifndef included_xlg
 define included_xlg
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xln.asm"

xlg:
;lg(x) = ln(x)/ln(2)
  call pushpop
  call xln
  ld h,b
  ld l,c
  ld de,xconst_lg_e
  jp xmul
 endif
