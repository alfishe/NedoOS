 ifndef included_xabs
 define included_xabs
 include "../common/pushpop.asm"
 include "../common/mov.asm"

xabs:
  call pushpop
  ld d,b
  ld e,c
  call mov9
  ld a,(hl)
  and $7F
  ld (de),a
  ret
 endif
