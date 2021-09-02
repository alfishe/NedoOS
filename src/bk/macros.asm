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

;c=cmdLSB
       macro GETDEST
        call getdest
       endm ;bc=dest, a=cmdLSB

;bc=data, a=cmdLSB
       macro PUTDEST_Loop
        jp putdest_Loop
       endm

;c=data, a=cmdLSB
       macro PUTDEST8_Loop
        jp putdest8_Loop
       endm

;hl=addr, bc=data
       macro WRMEM_hl_LoopC
       push bc
        ld a,h
        and 0xc0
       jp m,2f ;ROM/ports
        ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
       cp 0x40
       jr z,1f ;screen
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        inc l
        call z,inchnextpg
        ld (hl),b
        _LoopC
1 ;screen
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        call putscreen_c
        inc l
        jr z,3f;screen inchnextpg
5
        ld (hl),b
        ld c,b
        call putscreen_c
        _LoopC
3
        inc h
        jr nz,5b
;screen nextpg = ROM
        ;call hlnextpg
        _LoopC
2 ;ROM/ports
;TODO ports
        _LoopC
       endm

;hl=addr, c=data
       macro WRMEM8_hl_LoopC
       push bc
        ld a,h
        and 0xc0
       jp m,2f ;ROM/ports
        ld c,a
       ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
       cp 0x40
       jr z,1f ;screen
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        _LoopC
1 ;screen
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        call putscreen_c
        _LoopC
2 ;ROM/ports
;TODO ports
        _LoopC
       endm

       macro RDMEM_ac_ret ;bc=result, a=hx
        ld l,c
        ld h,a
        and 0xc0
	ld c,a
       ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ret nz
        inc h
        call z,hlnextpg
        ld b,(hl)
        ret
       endm
