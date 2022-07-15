 ifndef included_xmul2
 define included_xmul2
 include "../../common/pushpop.asm"
 include "../../common/mov.asm"
xmul2:
  call pushpop
  ld d,b
  ld e,c
  call mov8
  ld c,(hl)
  inc hl
  ld b,(hl)
  inc c
  jr nz,xmul2ok;+_
  ld a,b
  inc b
  xor b
  jp m,xmul2ok;+_
  xor b
  sla b
  rla
  rr b
  ;ld a,$80  ;If this overflow occurs, then A must currently be %1111111x :D
  dec de
  ld (de),a
  inc de
xmul2ok;_:
  ex de,hl
  ld (hl),c
  inc hl
  ld (hl),b
  ret
 endif
