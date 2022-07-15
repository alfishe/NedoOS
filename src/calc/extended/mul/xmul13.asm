 ifndef included_xmul13
 define included_xmul13
 include "../../common/pushpop.asm"
 include "../../common/mov.asm"
 include "../routines/srl64.asm"
 include "../routines/addmantissa0102.asm"
 include "xmul3.asm"

xmul13:
  call pushpop
  push bc
  call xmul13pp;+_
  pop de
  ld hl,xOP1
  jp mov10
xmul13pp;_:
  ld de,xOP1
  call mov10
  ld hl,(xOP1+8)
  ld a,h
  or l
  ret z
  ld hl,xOP1
  call mov8
  call srlxOP2
  call addmantissa0102
  call srlxOP2
  call srlxOP2
  call addmantissa0102
  ld hl,xOP1+8
  ld a,(hl)
  add a,3
  ld (hl),a
  ret nc
  inc hl
  ld a,(hl)
  inc (hl)
  xor (hl)
  jp m,constmul_overflow
  ret
 endif
