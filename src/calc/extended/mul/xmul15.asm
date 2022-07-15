 ifndef included_xmul15
 define included_xmul15
 include "../../common/pushpop.asm"
 include "../../common/mov.asm"
 include "../routines/srl64_x4.asm"
 include "../routines/sub64.asm"
 include "../routines/normalizexOP1.asm"
 include "xmul3.asm"

xmul15:
  call pushpop
  push bc
  call xmul15pp;+_
  call normalizexOP1
  pop de
  ld hl,xOP1
  jp mov10
xmul15pp;_:
  ld de,xOP1
  call mov10
  ld hl,(xOP1+8)
  ld a,h
  or l
  ret z
  ld hl,xOP1
  call mov8
  call srlxOP2_4
  ld de,xOP1
  call sbc64
  ld hl,xOP1+8
  ld a,(hl)
  add a,4
  ld (hl),a
  ret nc
  inc hl
  ld a,(hl)
  inc (hl)
  xor (hl)
  jp m,constmul_overflow
  ret
 endif
