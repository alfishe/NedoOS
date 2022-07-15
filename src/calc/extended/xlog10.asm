 ifndef included_xlog10
 define included_xlog10
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xln.asm"

xlog10:
;lg(x) = ln(x)/ln(2)
  call pushpop
  call xln
  ld h,b
  ld l,c
  ld de,xconst_log10_e
  jp xmul
 endif
