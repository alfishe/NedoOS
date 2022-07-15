 ifndef included_xmul5
 define included_xmul5
 include "../../common/pushpop.asm"
 include "../../common/mov.asm"
 include "../routines/srl64.asm"
 include "../routines/rr64.asm"
 include "../routines/add64.asm"
 include "xmul3.asm"

xmul5:
  call pushpop
  push bc
  call xmul5pp;+_
  pop de
  ld hl,xOP1
  jp mov10
xmul5pp;_:
  ld de,xOP1
  call mov10
  ld hl,(xOP1+8)
  ld a,h
  or l
  ret z
  ld hl,xOP1
  call mov8
  call srlxOP1_mantissa
  call srlxOP1_mantissa
  ld hl,xOP2
  ld de,xOP1
  call adc64
  ex de,hl
  push af
  call c,rr64
  ld hl,xOP1+8
  pop af
  ld a,(hl)
  adc a,2
  ld (hl),a
  ret nc
  inc hl
  ld a,(hl)
  inc (hl)
  xor (hl)
  jp m,constmul_overflow
  ret
 endif
