 ifndef included_div64_32
 define included_div64_32
 include "div32_16.asm"
 include "../../common/mul16.asm"

var_x=xOP2   ;output
var_b=xOP2   ; 4 bytes, result gets copied to bottom anyways
var_n=xOP3

div64_32:
;var_n / var_x
;HLDE is the remainder
;BCIX is the quotient
;440+2{0,96}+2*div32_16+2*mul16
;min: 2408cc
;max: 3908cc
;avg: 3356.274cc
  ld hl,(var_n+6)
  ld de,(var_n+4)
  ld bc,(var_x+6)
  call div32_16
  push de

;Need to adjust the remainder
  push hl
  ld bc,(var_x+4)
  call mul16

  ;DEHL
  ld b,d
  ld c,e
  ex de,hl
  ld hl,(var_n+2)
  or a
  sbc hl,de
  ex de,hl
  pop hl
  sbc hl,bc
  jr nc,div64_32_adjust_done
div64_32_adjust0;_:
  pop bc
  dec bc
  push bc
  ld bc,(var_x+4)
  ex de,hl
  add hl,bc
  ld bc,(var_x+6)
  ex de,hl
  adc hl,bc
  jr nc,div64_32_adjust0;-_
div64_32_adjust_done:
;HLDE is the new remainder
  ld bc,(var_x+6)
  call div32_16
  push de

;Need to adjust the remainder
;(HL:(00-DE*(var_x+4))
  push hl
  ld bc,(var_x+4)
  call mul16

  ;DEHL
  ld b,d
  ld c,e
  ex de,hl
  ld hl,(var_n)
  or a
  sbc hl,de
  ex de,hl
  pop hl
  sbc hl,bc
  jr nc,div64_32_adjustq;+_
  pop bc
  dec bc
  push bc
  ld bc,(var_x+4)
  ex de,hl
  add hl,bc
  ld bc,(var_x+6)
  ex de,hl
  adc hl,bc
div64_32_adjustq;_:
;HLDE is the new remainder
  pop ix
  pop bc
  ret
 endif
