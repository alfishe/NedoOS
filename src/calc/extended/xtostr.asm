 ifndef included_xtostr
 define included_xtostr
 include "../common/pushpop.asm"
 include "../common/mov.asm"
 include "routines/sla64.asm"
 include "routines/add64.asm"
 include "mul/xOP1mul10.asm"
 include "../common/mul16.asm"
 include "xmul.asm"
 include "tables.asm"
 include "../common/common_str.asm"
;fmtDigits = 97B0h
;#define EXTERNAL_FORMAT_LEN    ;Uses an external reference to get the format length
;#define EXTERNAL_FORMAT_LEN_LOC fmtDigits    ;Use for TI-OS
;#ifndef MAX_FORMAT_LEN
MAX_FORMAT_LEN=19
;#endif
;#ifndef DEFAULT_FORMAT_LEN
DEFAULT_FORMAT_LEN=18
;#endif
;#ifndef TOK_ENG
TOK_ENG='e'
;#endif
;#ifndef TOK_NEG
TOK_NEG='-';$1A
;#endif

pow10exp=xOP3+42
strout=pow10exp+3
xtostr:
  call pushpop
  push bc
  call xtostrpp;+_
  pop de
  xor a
  cp (hl)
  ldi
  jr nz,$-3
  ret
xtostrpp;_:
  ld de,xOP1
  call mov10
  ld de,(xOP1+8)   ;this is the exponent and sign
  ld hl,strout
  bit 7,d
  jr z,xtostr_p;+_
  res 7,d
  ld (xOP1+8),de   ;just making it positive
  ld (hl),TOK_NEG    ;negative sign
  inc hl
xtostr_p;_:
  ld a,d
  or e
  jp z,strcase

;We should write '0' next. When rounding 9.999999... for example, not padding with a 0 will return '.' instead of '1.'
  ld (hl),'0'
  inc hl

;Now we need to perform (DE-0x4000)*19728 (approximation of exponent*log10(2))
  ld bc,19728
  push hl       ;points to where the string is being written
  call mul16    ;when analyzing timing, note that the first iteration is guaranteed to skip
  ld hl,-4932
  add hl,de
  ld (pow10exp),hl
  ld de,pown10table
  jr c,xtostr_expp;+_
;the exponent is negative, need to be multiplying by 10^-exponent
  xor a
  sub l
  ld l,a
  sbc a,a
  sub h
  ld h,a
  ld de,pow10table   ;get the table of 10^-(2^k)
xtostr_expp;_:
  ld bc,xOP1
  add hl,hl
  add hl,hl
  add hl,hl
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
  call xtostr_mul
;now the number is pretty close to a nice value
  jr xtostr_inloop
xtostr_inloop0;_:
  call xOP1mul10
  ld hl,(pow10exp)
  dec hl
  ld (pow10exp),hl
xtostr_inloop:
  ld a,(xOP1+8)
  add a,a
  jr c,xtostr_inloop0;-_

;quick, convert to a fixed-point number !
  rra
  inc a
;  jr z,noadjustxtostr
  ;number of bits to shift
  ld b,a
  xor a
  ld (xOP1+8),a
xtostr_rl0;_:
  call sla64_xOP1
  inc hl
  rl (hl)
  djnz xtostr_rl0;-_
noadjustxtostr:
 ifdef EXTERNAL_FORMAT_LEN
  ld a,(EXTERNAL_FORMAT_LEN_LOC)
; If it is 0 or 1, reset it to the default
  inc a
  jr z,$+5 ;DEFAULT_FORMAT_LEN
  dec a
  jr nz,$+2+2;+_
  ld a,DEFAULT_FORMAT_LEN
;_:
;If it is greater than the maximum length, need to set it to the max
  cp MAX_FORMAT_LEN
  jr c,$+2+2;+_
  ld a,MAX_FORMAT_LEN
;_:
  ld b,a
  inc b
 else
  ld b,DEFAULT_FORMAT_LEN+1
 endif

  ld a,(hl) ;the first digit, might be as large as twenty
  pop hl
  ld c,10
  cp c
  jr c,xtostr_tochar;+_
  ld de,(pow10exp)
  ld (hl),'0'-1
  db $FE   ;start of `cp **` (to avoid the very first "inc de")
  inc de : inc (hl) : sub c : jr nc,$-3
  ld (pow10exp),de
  add a,c
  inc hl
  dec b
 ifdef EXTERNAL_FORMAT_LEN
  jr z,xtostr_round
 endif
xtostr_tochar;_:
  add a,'0'
  ld (hl),a
  dec b
 ifdef EXTERNAL_FORMAT_LEN
  jr z,xtostr_round
 endif
xtostr_tochar0;_:
  inc hl
  push hl
  push bc
  call xtostrmul10
  pop bc
  pop hl
  add a,'0'
  ld (hl),a
  djnz xtostr_tochar0;-_

xtostr_round:
;Now let's round!
  cp '5'
  jr c,xtostr_round0;+_
  ld a,$3A
  ld (hl),'0'
  dec hl
  inc (hl)
  cp (hl)
  jr z,$-5

;Strip trailing zeros
  db $FE   ;start of `cp **` (to avoid the very first "dec hl")
xtostr_round0;_:
  dec hl
  ld a,(hl)
  cp '0'
  jr z,xtostr_round0;-_
;_:
  inc hl

;Strip the leading zero if it exists (rounding may have bumped this to `1`)
  ex de,hl
  ld hl,strout
  ld a,(hl)
  cp TOK_NEG
  jr nz,$+2+1+1;+_
  inc hl
  ld a,(hl)
;_:
  cp '0'
  jr nz,xtostr_no_leading_0
  dec de
  push de
  ex de,hl
  ;Now lets shift the string back 1 byte from DE+1 to DE

 ifdef EXTERNAL_FORMAT_LEN
  ld a,(EXTERNAL_FORMAT_LEN_LOC)
; If it is 0 or 1, reset it to the default
  inc a
  jr z,$+5 ;DEFAULT_FORMAT_LEN
  dec a
  jr nz,$+2+2;+_
  ld a,DEFAULT_FORMAT_LEN
;_:
;If it is greater than the maximum length, need to set it to the max
  cp MAX_FORMAT_LEN
  jr c,$+2+2;+_
  ld a,MAX_FORMAT_LEN
;_:
  ld c,a
  inc c
  ld b,0
 else
  ld bc,DEFAULT_FORMAT_LEN+1
 endif


  ld h,d
  ld l,e
  inc hl
  ldir
  cp a
  db $3E
xtostr_no_leading_0:
  push de

;If z flag is reset, this means that the exponent should be bumped up 1
  ld hl,(pow10exp)
  jr z,$+2+1+3;+_
  inc hl
  ld (pow10exp),hl
;_:

  ;if -4<=HL<=10, then need to insert the decimal place somewhere.
  ld bc,4
  add hl,bc
  ld a,h
  or a
  jr nz,xtostr_decimalafter1st;+_
  ld a,l
  cp 15
  jp c,movdec
xtostr_decimalafter1st;_:
  ;for this, we need to insert the decimal after the first digit
  ;Then, we need to append the exponent string
  ld hl,strout
  ld de,strout-1
  ld a,(hl)
  cp TOK_NEG    ;negative sign
  jr nz,$+2+2;+_
  ldi
;_:
  ldi
  ld a,'.'
  ld (de),a
;now we need to append the exponent to the end of the string
  pop hl
  ld (hl),TOK_ENG
  inc hl
  ld de,(pow10exp)
  bit 7,d
  jr z,xtostr_expok;+_
  ld (hl),TOK_NEG    ;negative sign
  inc hl
  xor a
  sub e
  ld e,a
  sbc a,a
  sub d
  ld d,a
xtostr_expok;_:
  push hl
  ex de,hl
  ld bc,-1000
  ld a,'0'-1
  or a
;_:
  inc a
  add hl,bc
  jr c,$-2;-_
  sbc hl,bc
  cp $30
  jr z,$+2+1+1;+_
  ld (de),a
  inc de
;_:

  ld bc,-100
  ld a,'0'-1
;_:
  inc a
  add hl,bc
  jr c,$-2;-_
  sbc hl,bc
  ld (de),a
  inc de

  ld bc,$2F0A
  ld a,l
;_:
  inc b
  sub c
  jr nc,$-2;-_
  ex de,hl
  ld (hl),b
  inc hl
  add a,$3A
  ld (hl),a
  inc hl
  xor a
  ld (hl),a
  pop de
  ld h,d
  ld l,e
  ld a,'0'
;_:
  cpi
  jr z,$-2;-_
  dec hl
  call mov4
  ld hl,strout-1
  ret
movdec:
  ld hl,(pow10exp)
  bit 7,h
  jr z,posdec
;need to put zeroes before everything
  ld de,strout
  ld a,(de)
  cp TOK_NEG    ;negative sign
  push af
  ld a,'0'
  jr z,$+3
movdec0;_:
  dec de
  ld (de),a
  inc l
  jr nz,movdec0;-_
  inc h
  jr nz,movdec0;-_
;_:
  ld a,'.'
  ld (de),a
  pop af
  ex de,hl
  jr nz,$+2+1+1;+_
  dec hl
  ld (hl),a
;_:
  pop de
  xor a
  ld (de),a
  ret
posdec:
  ld hl,strout
  ld de,strout-1
  ld bc,(pow10exp)
  ld a,b
  or c
  ld a,(hl)
  jr z,$+2+2;+_
  ldir
;_:
  ldi
  cp TOK_NEG    ;negative sign
  jr nz,$+2+2;+_
  ldi
;_:
  pop hl
;HL points to the end of the string
;DE points to where the decimal is printed
;If HL+1 <= DE, then don't write a decimal, and set HL=DE
  ex de,hl
  or a
  dec de
  sbc hl,de
  add hl,de
  inc de
  jr nc,$+2+1+2+1;+_
  ex de,hl
  ld a,'.'
  ld (de),a
;_:
  ld (hl),0
  ld hl,strout-1
  ret
strcase:
  ld de,str_Zero
  ld a,(xOP1+7)
  and $C0
  jr z,xtostr_specstr;+_
  ld de,str_INF
  jp pe,xtostr_specstr;+_
  ld de,str_NaN
xtostr_specstr;_:
  ex de,hl
  call mov4
  ld hl,strout
  ret
xtostr_mul:
  add hl,hl
  push hl
  call c,xtostr_mulpp;+_
  ld hl,10
  add hl,de
  ex de,hl
  pop hl
  ret
xtostr_mulpp;_:
  ld h,b
  ld l,c
  jp xmul
xtostrmul10:
;multiply the 0.64 fixed point number at xOP1 by 10
;overflow in A register
  ld hl,xOP1
  ld de,xOP2
  call mov9
  xor a
  inc hl
  call sla64
  rla
  ld hl,xOP2
  call sla64
  rla
  push af
  ld de,xOP1
  ld hl,xOP2
  call add64
  pop hl
  ld a,h
  adc a,0
  call sla64_xOP1
  rla
  ret
 endif
