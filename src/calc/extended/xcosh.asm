 ifndef included_xcosh
 define included_xcosh
 include "../common/pushpop.asm"
 include "xexp.asm"
 include "xinv.asm"
 include "xamean.asm"

hyper_0=xOP1+72
hyper_1=xOP1+82
xcosh:
  call pushpop
  push bc
  ld bc,hyper_0
  call xexp
  ld h,b
  ld l,c
  ld bc,hyper_1
  call xinv
  ld d,b
  ld e,c
  pop bc
  jp xamean

;#undefine hyper_0
;#undefine hyper_1
 endif
