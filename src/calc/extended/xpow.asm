 ifndef included_xpow
 define included_xpow
 include "../common/pushpop.asm"
 include "xmul.asm"
 include "xlg.asm"
 include "xpow2.asm"

xpow:
;;Computes x^y
;;HL points to y
;;DE points to x
;;BC points to output
  call pushpop
  push bc
  push de
  ld bc,xOP1
  call xlg
  pop de
  ld h,b
  ld l,c
  call xmul
  pop bc
  jp xpow2
 endif
