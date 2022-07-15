 ifndef included_xmul17
 define included_xmul17
 include "../../common/pushpop.asm"
 include "../../common/mov.asm"
 include "../routines/srl64_x4.asm"
 include "../routines/add64.asm"
 include "../routines/rr64.asm"
 include "xmul3.asm"

xmul17:
  call pushpop
  push bc
  call xmul17pp;+_
  pop de
  ld hl,xOP1
  jp mov10
xmul17pp;_:
  ld de,xOP1
  call mov10
  ld hl,(xOP1+8)
  ld a,h
  or l
  ret z
  ld hl,xOP1
  call mov8

  call srlxOP2_4
  ld hl,xOP2
  ld de,xOP1
  call adc64
  ex de,hl
  push af
  call c,rr64
  ld hl,xOP1+8
  pop af
  ld a,(hl)
  adc a,4
  ld (hl),a
  ret nc
  inc hl
  ld a,(hl)
  inc (hl)
  xor (hl)
  jp m,constmul_overflow
  ret
 endif
