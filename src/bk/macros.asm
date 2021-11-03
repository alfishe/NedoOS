;PC=0x4000...
;SP=0x8000...
;data=0xC000...

       macro UNTESTED
       if DEBUG
        jr $
       endif
       endm

       macro GOOD
       endm

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

	macro decodePC_to_ae ;de,pc_high -> ae
        ld a,(pc_high)
        xor d
        and 0xc0
        xor d
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
        ld a,0xaa
        ld (oddpc),a ;even, for for jp pc; TODO jp oddaddr?
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
       res 0,l ;for cputest
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
       macro GETDEST_cmdc
        ld a,c
        call getdest_aisc
       endm ;bc=dest, a=cmdLSB

;a=cmdLSB
       macro GETDEST_cmda
        ld c,a
        call getdest_aisc
       endm ;bc=dest, a=cmdLSB

;c=cmdLSB
       macro GETDEST_cmdc_autoinc
        ld a,c
        call getdest_aisc_autoinc
       endm ;bc=dest, a=cmdLSB

;a=cmdLSB
       macro GETDEST_cmda_autoinc
        ld c,a
        call getdest_aisc_autoinc
       endm ;bc=dest, a=cmdLSB

;c=cmdLSB
       macro GETDEST8_cmdc
        ld a,c
        call getdest8_aisc
       endm ;c=dest, a=cmdLSB

;a=cmdLSB
       macro GETDEST8_cmda
        ld c,a
        call getdest8_aisc
       endm ;c=dest, a=cmdLSB

;c=cmdLSB
       macro GETDEST8_cmdc_autoinc
        ld a,c
        call getdest8_aisc_autoinc
       endm ;c=dest, a=cmdLSB

;a=cmdLSB
       macro GETDEST8_cmda_autoinc
        ld c,a
        call getdest8_aisc_autoinc
       endm ;c=dest, a=cmdLSB

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
       res 0,l ;16-bit write always at even addr
        ld a,h
        and 0xc0
       jp m,2f ;ROM/ports
       push bc
        ld c,a
       ;ld lx,a
	ld b,tpgs/256
	set 7,h
        set 6,h
       cp 0x40
       jr z,1f ;screen
      if DEBUGWR
      ld a,h
      cp 0xc1 ;stack
      jr c,$
      endif
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        inc l
        ;call z,inchnextpg
        ld (hl),b
        _LoopC
1 ;screen
	ld a,(bc)
	SETPGC000
       pop bc
        ld (hl),c
        call putscreen_c
        inc l
        ;jr z,3f;screen inchnextpg
;5
        ld (hl),b
        ld c,b
        call putscreen_c
        _LoopC
;3
;        inc h
;        jr nz,5b
;screen nextpg = ROM
;        ;call hlnextpg
;        _LoopC
2 ;ROM/ports
      if 1
       inc h
       jp nz,wrmemrom_LoopC ;no ports
;FFB0=177660 регистр состояния клавиатуры (Разряд 6 - маска прерываний от клавиатуры. разряд доступен по записи и чтению. “0” - разрешено прерывание от клавиатуры; “1” - запрещено прерывание от клавиатуры. Разряд 7 - флаг состояния клавиатуры. Устанавливается в единицу при поступлении в регистр данных клавиатуры нового кода. Сбрасывается в “0” при чтении регистра данных клавиатуры.)
;FFB2=177662 Регистр данных клавиатуры
;177664 предназначен для указания начала экранного ОЗУ и организации рулонного сдвига экрана. При начальной установке экрана в регистре записывается значение 1330 (0x02d8). Изменение этого значения на 1 приводит к сдвигу изображения на экране по вертикали на 1 точечную строку. Сразу же после включения питания разряд 9 устанавливается в "1". При включении режима расширенной памяти разряд сбрасывается в "0". Разряды 8, 10-15 не используются.
        ld a,l
        cp 0xb0
        jr z,9f ;kbd state ;TODO сюда пишет labyrinh, потом ждёт в (0xffce) 0x80a0
        cp 0xb2
        jr z,9f ;kbd data
        cp 0xb4
        jr z,8f ;scroll
        cp 0x76 ;буфер передатчика
        ;jr nz,9f ;no ports
        call z,print_bc_to_log
      endif
9
        _LoopC
8
        ld (bkscroll),bc
        _LoopC
       endm

;hl=addr, c=data
       macro WRMEM8_hl_LoopC
        ld a,h
        and 0xc0
       jp m,2f ;ROM/ports
       push bc
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
       inc h
       jp nz,wrmemrom_LoopC ;no ports
;TODO ports
        _LoopC
       endm

       macro RDMEM_ac_ret ;bc=result, a=hx
        ld h,a
       res 0,c ;16-bit read always at even addr
       cp 0xff
       jp z,rdport_c
      if BASIC == 0
       cp 0xa0
       jp nc,buserror
      endif
        ld l,c
        and 0xc0
	ld c,a
       ;ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        inc l
        ld b,(hl)
        ;ret nz
        ;inc h
        ;call z,hlnextpg
        ;ld b,(hl)
        ret
       endm

       macro RDMEM8_ac_ret ;c=result, a=hx
        ld h,a
       cp 0xff
       jp z,rdport_c
      if BASIC == 0
       cp 0xa0
       jp nc,buserror
      endif
        ld l,c
        and 0xc0
	ld c,a
       ;ld lx,a ;for nextpg
	ld b,tpgs/256
	set 7,h
        set 6,h
	ld a,(bc)
	SETPGC000
       ld a,hx
        ld c,(hl)
        ret
       endm
