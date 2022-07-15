 ifndef included_xtan
 define included_xtan
 include "../common/pushpop.asm"
 include "xdiv.asm"
 include "xcos.asm"
 include "xsin.asm"

tan_x=xOP1+90
tan_y=xOP1+80
xtan:
  call pushpop
  push bc
  ld bc,tan_x
  call xcos
  ld d,b
  ld e,c
  ld bc,tan_y
  call xsin
  ld h,b
  ld l,c
  pop bc
  jp xdiv
;#undefine tan_x
;#undefine tan_y
 endif
