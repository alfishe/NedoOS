;dehl = m
;dehl' = n
;out: dehl = m/n
uintdiv32
	ld a,h
	cpl
	ld h,a
	ld a,l
	cpl
	ld l,a
	ld (.dividendlo),hl
	ld a,d
	cpl
	ld h,a
	ld a,e
	cpl
	ld l,a
	ld (.dividendhi),hl
	ld a,1
	ld bc,0
	ld de,1
	ld hl,0
	ld iy,0
	ld (.templo),hl
	ld (.temphi),hl
	exx
	ld bc,de
	ex de,hl
	bit 7,b
	jr nz,.rshiftloop
.lshiftloop
	sla de
	rl bc
	exx
	sla de
	rl bc
	exx
	inc a
	bit 7,b
	jr z,.lshiftloop
.rshiftloop
.templo=$+2
	ld ix,0
.temphi=$+1
	ld hl,0
	add ix,de
	adc hl,bc
	jr c,.nextbit
	push ix
	push hl
	push de
.dividendlo=$+1
	ld de,0
	add ix,de
.dividendhi=$+1
	ld de,0
	adc hl,de
	pop de
	pop hl
	pop ix
	jr c,.nextbit
	ld (.templo),ix
	ld (.temphi),hl
	exx
	add iy,de
	add hl,bc
	exx
.nextbit
	srl bc
	rr de
	exx
	srl bc
	rr de
	exx
	dec a
	jr nz,.rshiftloop
	exx
	ld de,iy
	ex de,hl
	ret

;bc = m
;de = n
;out: dehl = m*n
uintmul16:
	ld a,c
	ld c,b
	ld hl,0
	ld b,16
.loop	add hl,hl
	rla
	rl c
	jr nc,.skip
	add hl,de
	adc a,0
	jr nc,.skip
	inc c
.skip	djnz .loop
	ld d,c
	ld e,a
	ret


;bc = m
;de = n
;out: dehl = m*n
intmul16:
  xor a
  ld h,a
  ld l,a

  bit 7,d
  jr z,muldpos
  sbc hl,bc
muldpos:

  or b
  jp p,mulbpos
  sbc hl,de
mulbpos:

  ld a,16
mulloop:
  add hl,hl
  rl e
  rl d
  jr nc,mul0bit
  add hl,bc
  jr nc,mul0bit
  inc de
mul0bit:
  dec a
  jr nz,mulloop
  ret  

;===============
;The following routine divides ac by de and places the quotient in ac and the remainder in hl

div_ac_de:
   ld	hl, 0
   ld	b, 16

._loop:
   sll	c
   rla
   adc	hl, hl
   sbc	hl, de
   jr	nc, $+4
   add	hl, de
   dec	c
   
   djnz	._loop
    ret


;=====================
;The following routine multiplies h by e and places the result in hl

mult_h_e

   ld	d, 0	; Combining the overhead and
   sla	h	; optimised first iteration
   sbc	a, a
   and	e
   ld	l, a
   
   ld	b, 7
.loop:
   add	hl, hl          
   jr	nc, $+3
   add	hl, de
   
   djnz	.loop
   
   ret


;============
;The following routine divides hl by c and places the quotient in hl and the remainder in a

div_hl_c:
   xor	a
   ld	b, 16

.loop:
   add	hl, hl
   rla
   jr	c, $+5
   cp	c
   jr	c, $+4

   sub	c
   inc	l
   
   djnz	.loop
   
   ret
 


DEHL_Div_C:
;Inputs:
;     DEHL is a 32 bit value where DE is the upper 16 bits
;     C is the value to divide DEHL by
;Outputs:
;    A is the remainder
;    B is 0
;    C is not changed
;    DEHL is the result of the division
;
  ;   ld b,32

     xor a
     dup 32   
       add hl,hl
       rl e : rl d
       rla
       cp c
       jr c,$+4
         inc l
         sub c
  ;     djnz $-11
     edup   
     ret



BCDE_Times_A:
;Inputs: BC:DE,A
;Outputs: A:HL:IX is the 40-bit product, BC,DE unaffected
;503cc~831cc
;667cc average
;29 bytes
    ld ix,0
    ld hl,0
    call .a1
.a1:
    call .a2
.a2:
    call .a3
.a3:
    add ix,ix : adc hl,hl : rla : ret nc
    add ix,de : adc hl,bc : adc a,0
    ret

mult_de_a:
;Input: A = Multiplier, DE = Multiplicand, HL = 0, C = 0
;Output: A:HL = Product

	add	a,a		; optimised 1st iteration
	jr	nc,$+4
	ld	h,d
	ld	l,e
        
        dup 7
	add	hl,hl		; unroll 7 times
	rla			; ...
	jr	nc,$+4		; ...
	add	hl,de		; ...
	adc	a,c		; ...
        edup
        ret

