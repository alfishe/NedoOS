 ifndef included_xpow10
 define included_xpow10
 include "../common/pushpop.asm"
 include "constantsx.asm"
 include "xmul.asm"
 include "xpow2.asm"

xexp_x=xOP3+42
xpow10:
  call pushpop
  push bc
  ld de,xconst_lg_10
  ld bc,xexp_x
  call xmul
  ld hl,xexp_x
  pop bc
  jp xpow2
;#undefine xexp_x
 endif
