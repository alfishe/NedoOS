;PC=0x4000...
;SP=0x8000...
;data=0xC000...

     macro DISABLE_IFF0_KEEP_IY ;иначе pop iy запорет iy от обработчика прерывания
        call disable_iff0_keep_iy
     endm
     macro ENABLE_IFF0_REMEMBER_IY ;иначе pop iy запорет iy от обработчика прерывания
        call enable_iff0_remember_iy
     endm


        MACRO _Loop_
        JP (IY) ;EMULOOP (нужный marg или нужный обработчик b/p)
        ENDM 

;если вместо стр.команд включили др.стр.
        MACRO _LoopC
        ;OUTcom
        JP (IY)
        ENDM 

;если резко сменился PC (полный DE)
        MACRO _LoopJP
        encodePC;CALCiypgcom
        JP (IY)
        ENDM 

;если выключили др.стр. и резко сменился PC (полный DE)
        MACRO _LoopC_JP
        encodePC;CALCiypgcom
        JP (IY)
        ENDM 

;если IN/OUT (могла измениться конфигурация памяти)
        MACRO _LoopSWI
        ;CALCpgcom
        JP (IY)
        ENDM 

	macro decodePC ;de,pc_high -> de
        ld a,(pc_high)
        xor d
        and 0xc0
        xor d
        ld d,a
	endm

	macro encodePC_AisD
       ld (pc_high),a
       and 0xc0
	ld c,a
	ld b,tpgs/256
	res 7,d
        set 6,d
	ld a,(bc)
	SETPG4000
	endm

	macro encodePC
       ld a,d
       encodePC_AisD
	endm

	macro get
	ld a,(de)
	endm

	macro next
	inc e
        call z,recountpc_inc ;keep CY!
	endm

	macro getHL
	get
	next
	ld l,a
	get
	next
	ld h,a
	endm

	macro getBC
	get
	next
	ld c,a
	get
	next
	ld b,a
	endm

        macro putmemspBC
       push bc
        ld hl,(_SP)
        dec hl
        dec hl
        ld (_SP),hl
        ld a,h
        and 0xc0
        ld c,a
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        inc l
        call z,recountsp_inc
        ld (hl),b
        endm

        macro getmemspBC
        call getmemspBCpp
        endm

;a=cmdLSB
        macro GETDEST
        call getdest
        endm ;bc=dest, a=cmdLSB

;bc=dest, a=cmdLSB
        macro PUTDEST
        call putdest
        endm

;inc - Adds 1 to the destination operand, while preserving the state of the CF flag. 
;The OF, SF, ZF, AF, and PF flags are set according to the result. 
	macro inchlwithflags ;keep CY
	ex af,af' ;'
        inc l
        ld a,l
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        call pe,inchlwithflags_l80 ;fix SF
        call z,inchlwithflags_l00 ;inc h needed
	ex af,af' ;'
        endm ;57t in most cases
        
	macro incbcwithflags ;keep CY
	ex af,af' ;'
        inc c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        call pe,incbcwithflags_c80 ;fix SF
        call z,incbcwithflags_c00 ;inc b needed
	ex af,af' ;'
        endm ;57t in most cases
        
	macro dechlwithflags ;keep CY
        call dechlwithflags_fixflags ;z/nz - separate branches
	ex af,af' ;'
        endm ;21+63 = 84t in most cases
        
	macro decbcwithflags ;keep CY
        call decbcwithflags_fixflags ;z/nz - separate branches
	ex af,af' ;'
        endm ;21+63 = 84t in most cases
