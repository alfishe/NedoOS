 ifndef included_xlog
 define included_xlog
 include "../common/pushpop.asm"
 include "xdiv.asm"
 include "xln.asm"

var_y=xOP1+162 ;FIXME
var_y0=xOP1+172 ;FIXME
xlog:
  call pushpop
  push bc
  ld bc,var_y0
  call xln
  ld bc,var_y
  ex de,hl
  call xln
  ld d,b
  ld e,c
  pop bc
  ld hl,var_y0
  jp xdiv
;#undefine var_y
 endif
