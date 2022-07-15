 ifndef included_xneg
 define included_xneg
 include "../common/pushpop.asm"
 include "../common/mov.asm"
xneg:
  call pushpop
  ld d,b
  ld e,c
  call mov9
  ld a,(hl)
  xor 80h
  ld (de),a
  ret
 endif
