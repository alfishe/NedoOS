 ifndef included_strtox
 define included_strtox
 include "../common/mov.asm"
 include "../common/pushpop.asm"
 include "routines/sla64.asm"
 ;include "routines/ascii_to_uint8.asm"
 include "../common/ascii_to_uint8.asm"
 include "tables.asm"
 include "constantsx.asm"
 include "xmul.asm"

 ifndef char_TI_TOK
char_NEG='-';$1A
char_ENG='e';$1B
char_DEC='.'
 else
;otherwise, char_TI_CHR
char_NEG=$B0
char_ENG=$3B
char_DEC=$3A
 endif

;#ifndef strtox_ptr
strtox_ptr=xOP1+25 ;FIXME
;#endif
strtox:
;;#Routines/Extended Precision
;;Inputs:
;;  HL points to the string
;;  BC points to where the float is output
;;Output:
;;  xOP1+25 is the pointer to the end of the string
;;Destroys:
;;  25 bytes at xOP1 ?
  call pushpop
  push bc

;Check if there is a negative sign.
;   Save for later
;   Advance ptr
  ld a,(hl)
  sub char_NEG
  sub 1
  push af
  jr nc,$+3;+_
  inc hl
;_:
  call strtox_sub0
TItox_stepin:
;bc=exp-1
;Gotta multiply the number at (xOP1) by 2^64

;Save the location of the ending byte of the string
  ld (strtox_ptr),hl
  ld d,100
  call xOP1_xtimes_256
  ld (xOP1+17),a
  call xOP1_xtimes_256
  ld (xOP1+16),a
  call xOP1_xtimes_256
  ld (xOP1+15),a
  call xOP1_xtimes_256
  ld (xOP1+14),a
  call xOP1_xtimes_256
  ld (xOP1+13),a
  call xOP1_xtimes_256
  ld (xOP1+12),a
  call xOP1_xtimes_256
  ld (xOP1+11),a
  call xOP1_xtimes_256
  ld (xOP1+10),a
  call xOP1_xtimes_256
  ld (xOP1+9),a

;Now xOP1+9 is a 9-byte mantissa that needs to be normalized
;
  ld hl,(xOP1+10)
  or h
  or l
  ld hl,(xOP1+12)
  or l
  or h
  ld hl,(xOP1+14)
  or h
  or l
  ld hl,(xOP1+16)
  or l
  or h
  jp z,strtox_zero-1
  pop af
  push bc
  ld bc,$7FFF
  rr b
  ld a,h
  or a
  jp m,strtox_normed
  ;Will need to iterate at most three times
strtox_norm0;_:
  dec bc
  ld hl,xOP1+9
  call sla64
  adc a,a
  jp p,strtox_norm0;-_
strtox_normed:
;Move the number to xOP1
  ld hl,(xOP1+10)
  ld (xOP1),hl
  ld hl,(xOP1+12)
  ld (xOP1+2),hl
  ld hl,(xOP1+14)
  ld (xOP1+4),hl
  ld hl,(xOP1+16)
  ld h,a
  ld (xOP1+6),hl
  ld (xOP1+8),bc
  pop bc
;now (xOP1) is our number, need to multiply by power of 10!
;Power of 10 is stored in BC, need to put in A first
  xor a
  or b;sub b ;Alone Coder
  ld de,pow10table+120
  jp p,strtox_powp;+_
  xor a : sub c : ld c,a
  sbc a,a : sub b : ld b,a
  ld de,pown10table+120
strtox_powp;_:
  ld hl,xOP1
strtox_muls0;_:
  srl b
  rr c
  call strtox_mul;+_
  ld a,b
  or c
  jr nz,strtox_muls0;-_
  pop de
  jp mov10
strtox_mul;_:
  push bc
  ld b,h
  ld c,l
  call c,xmul
  pop bc
  ld a,e
  sub 10
  ld e,a
  ret nc
  dec d
  ret

strtox_sub00;_:
  inc hl
strtox_sub0:
;Skip all leading zeroes
  ld a,(hl)
  cp '0'
  jr z,strtox_sub00;-_

;Set exponent to 0
  ld bc,0
;Check if the next char is char_DEC
  sub char_DEC
  or a
  jr nz,strtox_skipzeroesq;+_
  inc c
;Get rid of zeroes
  ld a,'0'
  cpi
  jr z,$-2
  scf
strtox_skipzeroesq;_:
;Now we read in the next 20 digits
  ld de,xOP1+9
  push bc
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  call ascii_to_uint8
  ld a,b
  pop bc
  push af
  add a,c
  ld c,a
  jr nc,$+3
  inc b
  pop af
;Now `xOP1` holds the 10-digit base-100 number.
;BC is the exponent
;if carry flag is set, just need to get rid of remaining digits
;Otherwise, need to get rid of remaining digits, while incrementing the exponent
  call skipdigits
;Now check for engineering `E` to modify the exponent
  cp char_ENG-'0'
  ret nz
str_xeng_exp:
  ld de,0
  inc hl
  ld a,(hl)
  cp char_NEG    ;negative exponent?
  push af
  jr nz,$+3
  inc hl
str_xeng_exp0;_:
  ld a,(hl)
  sub 3Ah
  add a,10
  jr nc,str_xeng_expq;+_
  inc hl
  push hl
  ld h,d
  ld l,e
  add hl,hl
  add hl,hl
  add hl,de
  add hl,hl
  add a,l
  ld l,a
  ex de,hl
  pop hl
  jr str_xeng_exp0;-_
str_xeng_expq;_:
  ld a,d
  cp 20
  jp nc,xeng_overflow
  pop af
  ld a,c
  jr nz,str_xeng_add;+_
  sub e
  ld c,a
  ld a,b
  sbc a,d
  ld b,a
  ret
str_xeng_add;_:
  add a,e
  ld c,a
  ld a,d
  adc a,b
  ld b,a
  ret

xOP1_xtimes_256:
  push bc
  ld e,8
xOP1_xtimes_2560;_:
  or a
  ld hl,xOP1
  call xOP1_xtimes_256pp;+_
  call xOP1_xtimes_256pp;+_ ;итого 10 раз xOP1_xtimes_sub
  rl c
  dec e
  jr nz,xOP1_xtimes_2560;-_
  ld a,c
  pop bc
  ret
xOP1_xtimes_256pp;_:
  call xOP1_xtimes_sub
  call xOP1_xtimes_sub
  call xOP1_xtimes_sub
  call xOP1_xtimes_sub
xOP1_xtimes_sub:
  ld a,(hl)
  rla
  cp d
  jr c,$+2+1;+_
  sub d
;_:
  ld (hl),a
  inc hl
  ccf
  ret
xeng_overflow:
  pop af
  jr nz,strtox_inf
  pop af
strtox_zero:
  ld hl,xconst_0
  pop de
  jp mov10
strtox_inf:
;return inf
  pop af
  ld hl,xconst_INF
  jr nc,$+2+3;+_
  ld hl,xconst_nINF
;_:
  pop de
  jp mov10


skipdigits:
  jr nc,skipdigits_nodec
  db $FE     ; start of `cp *` to skip the `inc hl`
skipdigits0;_:
  inc hl
  ld a,(hl)
  sub '0'
  cp 10
  jr c,skipdigits0;-_
  ret

skipdigits_nodec0;_:
  inc hl
  inc bc
skipdigits_nodec:
  ld a,(hl)
  sub '0'
  cp 10
  jr c,skipdigits_nodec0;-_
  ret
 endif
