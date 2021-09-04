        ALIGNrm ;на всякий случай, вдруг там есть r/m
EXTer
       UNTESTED
;0f 31 = rdtsc eax edx
;0f b6 d0 = movzx dx,al (move with zero-extend)
;0f b6 c2 = movzx ax,dl (move with zero-extend)
;0f b6 06 87 0c = movzx ax,byte ptr [0c87] for pitman
;0f b6 9f 8e 0c = movzx bx,byte ptr [bx+0c8e] for pitman
;0f a8 .. TODO for 25frame
;0F DA  r P3+     PMINUB mm mm/m64   sse1      Minimum of Packed Unsigned Byte Integers (for pixeltwn)
;0F 82 (xx xx) JC rel16/32 Jump near if below/not above or equal/carry (CF=1) ;(for pixeltwn)
;0F 83 (A4 00) JNC rel16/32 Jump near if not below/above or equal/not carry (CF=0) ;(for pixeltwn)
;0F 85 (6B FF) jnz rel16 (for megapole)
;0F AF C3 imul ax,bx (for megapole)
;0F 45 C1 CMOVNZ ax,cx (for megapole) Conditional Move - not zero/not equal (ZF=0)
;JNAE rel16/32    
;JC rel16/32 

;TODO прочие адресации
        get
        next
       cp 0x31
       jp z,RDTSCer
       cp 0x45
       jr z,CMOVNZer
       cp 0x82
       jp z,JCrel16
       cp 0x83
       jp z,JNCrel16
       cp 0x84
       jp z,JZrel16
       cp 0x85
       jp z,JNZrel16
      cp 0x88
      jp z,JSrel16 ;pitman
       cp 0xaf
       jr z,IMULr1r2
       cp 0xda
       jr z,PMINUBer
       cp 0xb6
       jr nz,$
;movzx r16,rm8
        get
        next
        cp 0b11000000
        jr c,MOVZXmem
        ;jr $
      if 1
       ;ld h,a
       sub 64
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;rm addr
       ;ld a,h
        ;ld h,_AX/256
        ld c,(hl)
        ld b,0 ;rm
        rra
        rra
        and 7*2
        ld l,a
       _PUTr16Loop_
        ;ld l,a
        ;ld h,_AX/256
        ;ld l,(hl) ;reg8 addr
        ;ld c,(hl)
        ;ld b,0 ;reg16
       ;and 7
       ;add a,a
        ;ld l,a ;rm addr
       ;_PUTr16Loop_
      else
       cp 0xc2
       jr z,MOVZXaxdl
       cp 0xd0
       jr nz,$
        ld hl,(_AL)
        ld h,0
        ld (_DX),hl
       _Loop_
MOVZXaxdl
        ld hl,(_DL)
        ld h,0
        ld (_AX),hl
       _Loop_
      endif
MOVZXmem
       ADDRm16_GETm8c_for_PUTm8
        ld b,0 ;rm
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       _PUTr16Loop_AisL
       
CMOVNZer
;CMOVNZ ax,cx - Conditional Move - not zero/not equal (ZF=0)
        ex af,af' ;'
        jr z,CMOVnzer_no
        ld hl,(_CX)
        ld (_AX),hl
CMOVnzer_no
        ex af,af' ;'
       _Loop_

IMULr1r2
        get
        next
       push de
        ld bc,(_BX) ;TODO other regs
	ld de,(_AX);ex de,hl ;de=ax ;TODO other regs
        call IMUL_bc_de_to_hlde
	;ld (_DX),hl ;HSW
        ld (_AX),de ;LSW
       pop de
       _Loop_

PMINUBer
;не уверен, что такое поведение - TODO
        ld hl,(_AX)
        ld a,l
        cp h
        jr c,$+3
        ld l,h
        ld h,0
        ld (_AX),hl
       _Loop_

RDTSCer
;костыль для para512
        ld a,r
        ld l,a
        ld h,a
        ld (_AX),hl
       _Loop_

JSrel16
	ex af,af' ;'
	jp m,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JCrel16
	ex af,af' ;'
	jr c,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JNCrel16
	ex af,af' ;'
	jr nc,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JZrel16
	ex af,af' ;'
	jr z,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JNZrel16
	ex af,af' ;'
	jr nz,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JRrel16y
	ex af,af' ;'
	get
        next
        ld l,a
	get
        next
        LD H,A
       decodePC ;a=d
        ADD HL,DE
       ;;ld a,d
       ;xor h
       ;and 0xc0
        ex de,hl ;new PC 
       ;jp z,JRer_qslow
       _LoopC_JP;oldpg
