;PC=0x4000...
;SP=0x8000...
;data=0xC000...
       macro ALIGNrm
        align 2
       endm

       macro _PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg
        ld b,tscreenpgs/256
        ld a,(bc)
        cp b
        call nz,PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg_do
       endm

       macro _PUTscreen_logpgc_zxaddrhl_datamhl
        ld b,tscreenpgs/256
        ld a,(bc)
        cp b
        call nz,PUTscreen_logpgc_zxaddrhl_datamhl_do
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

;если резко сменился PC (полный DE в той же странице)
        MACRO _LoopC_JPoldpg
       set 6,d
       res 7,d ;4000+
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
;теперь вычитаем пересчитанный сегмент, т.к. при encodePC он прибавляется
	ld bc,(cs_LSW)
        ex de,hl
        ;or a
        sbc hl,bc
        ex de,hl
	endm

	macro encodePC
        ex de,hl
        _memCS
        ex de,hl
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

	macro countSS ;bc=(_SS)
        call countXS_bc_to_ahl
	ld (ss_LSW),hl
	ld (ss_HSB),a
	endm

	macro countCS ;bc=(_CS)
        call countXS_bc_to_ahl
	ld (cs_LSW),hl
	ld (cs_HSB),a
	endm

	macro countDS ;bc=(_DS)
        call countXS_bc_to_ahl
	ld (ds_LSW),hl
	ld (ds_HSB),a
	endm

	macro countES ;bc=(_ES)
        call countXS_bc_to_ahl
	ld (es_LSW),hl
	ld (es_HSB),a
	endm

        macro ADDSEGMENT_hl_abc_to_ahl
	add hl,bc
	adc a,0
	xor h
	and 0x3f
	xor h ;a = номер страницы (%01..5432)
        endm

	macro _memCS
        ;ld a,h
        ;ld (pc_high),a
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
       ld a,h
       ld (pc_high),a
	res 7,h
        set 6,h
	ld a,(bc)
	SETPG4000
	endm

	macro memSS
	ld bc,(ss_LSW)
	ld a,(ss_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
	set 7,h
        res 6,h
	ld a,(bc)
	SETPG8000
	endm

       if 1 ;TODO подмена сегмента!!!
	macro memDS
	ld bc,(ds_LSW)
	ld a,(ds_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
	ld a,h
	or 0xc0
	ld h,a
	ld a,(bc)
	SETPGC000
	endm

	macro getmemDS
	memDS
	ld a,(hl)
	endm
       endif

	macro memES_nosetpg
	ld bc,(es_LSW)
	ld a,(es_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
	ld a,h
	or 0xc0
	ld h,a
	ld a,(bc)
	endm

	macro putmemES
	push af
	memES_nosetpg
        push bc
	SETPGC000
        pop bc
	pop af
	ld (hl),a
        _PUTscreen_logpgc_zxaddrhl_datamhl
	endm

	macro getmemES
	memES_nosetpg
	SETPGC000
	ld a,(hl)
	endm

;TODO перехват записи в экран (call...jr/ld...ret? (+27t быстрая ветка) или ld a,hx:rla:call cc (+22t быстрая ветка), а там на выходе пропуск всего этого блока? или вообще and hx:call z? (+18t, на входе a!=0))
	macro putmemspBC
        ld hl,(_SP)
        ld a,l
        sub 2
        call c,putmemspBC_pp ;должна на выходе сама пропускать быструю ветку (skipsize байт ниже)
_putmemspBC_base=$
        ld l,a
        ld (_SP),a
        res 6,h
        set 7,h ;0x8000+
        ld (hl),c
        inc l
        ld (hl),b
_putmemspBC_skipsize=$-_putmemspBC_base
        endm

	macro getmemspBC
        LD HL,(_SP)
        ld a,l
        add a,2
        call c,getmemspBC_pp ;должна на выходе сама пропускать быструю ветку (skipsize байт ниже)
_getmemspBC_base=$
        ld (_SP),a
        res 6,h
        set 7,h ;0x8000+
	ld c,(hl)
        inc l
	ld b,(hl)
_getmemspBC_skipsize=$-_getmemspBC_base
	endm

	macro encodeSP
	;ld hl,(_SP)
        memSS
	endm

	macro KEEPHFCFPARITYOVERFLOW_FROMA ;для математики OF надо брать из P/O!
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        jp po,$+5
        ld e,0x40
        exx
	ex af,af' ;'
	endm

	macro KEEPCFPARITYOVERFLOW_FROMA ;для сдвигов
        exx
	ld d,a ;parity data
	 rra
	 ld e,a ;overflow data
	 rla ;restore CF
        exx
	ex af,af' ;'
	endm

	macro KEEPLOGICCFPARITYOVERFLOW_FROMA ;для логики
        exx
	ld d,a ;parity data
	ld e,0 ;OF=0
	exx
	ex af,af' ;'
	endm

       if FASTADC16WITHFLAGS;AFFLAG_16BIT ;NS
        macro SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL ;для математики OF надо брать из P/O!
	jr c,4f;sbc_with_carry	;7/12 ;[10]
;sbc_without_carry
;half carry part
	ld a,l			;4
	sbc a,c			;4	;теряет carry !!
	push af			;11	
;востанавливаем carry = 0
	and a				;4
	sbc hl,bc			;15
;half carry part
	pop bc			;10
;save x86 flags
	push af                 	;11 59
;parity
	ld a,l			;4	A = new L
	exx             	;4
	ld d,a 			;4 12	parity data = new L
;overflow
	ld e,0x00 	;7	overflow data
	jp po,2f  	;10
	ld e,0x40 	;7
2	exx			;4 
;half carry part
	bit 4,c			;8 36
	jr nz,1f			;7 / 12
	pop af				;10
	rla                     	;4
	rra 				;4	;Z80 HF(AF) = 0		xxx0 xxxx
	;ex af,af' ;'			;4 22
        jp 3f
;1	pop af				;10
;	cpl	;если не нужен A	;4	;Z80 HF(AF) = 1		xxx1 xxxx
;	;ex af,af' ;'			;4 18
;	jp 3f	
4;sbc_with_carry
;half carry part
	ld a,l			;4
	sbc a,c			;4		;теряет carry !!
	push af			;11
;востанавливаем carry = 1
	scf
	sbc hl,bc			;15
;half carry part
	pop bc			;10
;save x86 flags
	push af                 	;11
;parity
	ld a,l			;4	A = new L
	exx             	;4
	ld d,a 			;4	parity data = new L
;overflow
	ld e,0x00 	;7	overflow data
	jp po,2f  	;10
	ld e,0x40 	;7
2	exx			;4
;half carry part
	bit 4,c			;8
	jr nz,1f			;7 / 12
	pop af				;10
	rla                     	;4
	rra 				;4	;Z80 HF(AF) = 0		xxx0 xxxx
	;ex af,af' ;'			;4
        jp 3f
1
	pop af				;10
	cpl	;если не нужен A	;4	;Z80 HF(AF) = 1		xxx1 xxxx
3
	ex af,af' ;'			;4 18
        endm
       
       else
        macro SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL ;для математики OF надо брать из P/O!
       if AFFLAG_16BIT
       sbc a,a
       ld hx,a ;todo ()
       ld a,l
       endif
        sbc hl,bc
       if AFFLAG_16BIT
       rla
       rra ;reset HF(AF)
       push af
       ld b,a
       endif
        ld a,l
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        jp po,$+5
        ld e,0x40
        exx
       if AFFLAG_16BIT
        ld a,c
        and 0x0f
        sub hx ;hx=oldCF=0/-1
        ld c,a
        ld a,b ;oldl
        and 0x0f
        sub c
        jr nc,1f
       pop af
       cpl ;set HF(AF)
       jp 2f
1
       pop af
2
       endif
	ex af,af' ;'
        endm
       endif

       if FASTADC16WITHFLAGS;AFFLAG_16BIT ;NS
        macro ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL ;для математики OF надо брать из P/O!
	jr c,4f;adc_with_carry	;7/12 ;[10]
;adc_without_carry
;half carry part
	ld a,l			;4
	adc a,c			;4	;теряет carry !!
	push af			;11	
;востанавливаем carry = 0
	and a				;4
	adc hl,bc			;15
;half carry part
	pop bc			;10
;save x86 flags
	push af                 	;11 59
;parity
	ld a,l			;4	A = new L
	exx             	;4
	ld d,a 			;4 12	parity data = new L
;overflow
	ld e,0x00 	;7	overflow data
	jp po,2f  	;10
	ld e,0x40 	;7
2	exx			;4 
;half carry part
	bit 4,c			;8 36
	jr nz,1f			;7 / 12
	pop af				;10
	rla                     	;4
	rra 				;4	;Z80 HF(AF) = 0		xxx0 xxxx
	;ex af,af' ;'			;4 22
        jp 3f
;1	pop af				;10
;	cpl	;если не нужен A	;4	;Z80 HF(AF) = 1		xxx1 xxxx
;	;ex af,af' ;'			;4 18
;	jp 3f	
4;adc_with_carry
;half carry part
	ld a,l			;4
	adc a,c			;4		;теряет carry !!
	push af			;11
;востанавливаем carry = 1
	scf
	adc hl,bc			;15
;half carry part
	pop bc			;10
;save x86 flags
	push af                 	;11
;parity
	ld a,l			;4	A = new L
	exx             	;4
	ld d,a 			;4	parity data = new L
;overflow
	ld e,0x00 	;7	overflow data
	jp po,2f  	;10
	ld e,0x40 	;7
2	exx			;4
;half carry part
	bit 4,c			;8
	jr nz,1f			;7 / 12
	pop af				;10
	rla                     	;4
	rra 				;4	;Z80 HF(AF) = 0		xxx0 xxxx
	;ex af,af' ;'			;4
        jp 3f
1
	pop af				;10
	cpl	;если не нужен A	;4	;Z80 HF(AF) = 1		xxx1 xxxx
3
	ex af,af' ;'			;4 18
        endm
       
       else
        macro ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL ;для математики OF надо брать из P/O!
       if AFFLAG_16BIT
       sbc a,a
       ld hx,a ;todo ()
       ld a,l
       endif
        adc hl,bc
       if AFFLAG_16BIT
       rla
       rra ;reset HF(AF)
       push af
       ld b,a
       endif
        ld a,l
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        jp po,$+5
        ld e,0x40
        exx
       if AFFLAG_16BIT
        ld a,c
        and 0x0f
        sub hx ;hx=oldCF=0/-1
        ld c,a
        ld a,b ;oldl
        or 0xf0
        add a,c
        jr nc,1f
       pop af
       cpl ;set HF(AF)
       jp 2f
1
       pop af
2
       endif
	ex af,af' ;'
        endm
       endif

        macro KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
	or l ;CF=0 ;ZF=(hl==0) ;TODO sign
	ex af,af' ;'
        ld a,l
	exx
	ld d,a ;parity data
        ld e,0 ;OF=0
	exx
        endm

        macro KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
	or c ;CF=0 ;ZF=(bc==0) ;TODO sign
	ex af,af' ;'
        ld a,c
	exx
	ld d,a ;parity data
        ld e,0 ;OF=0
	exx
        endm

       if 1;AFFLAG_16BIT
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

       else ;no AF

;inc - Adds 1 to the destination operand, while preserving the state of the CF flag. 
;The OF, SF, ZF, AF, and PF flags are set according to the result. 
	macro incwithflags ;keep CY
	ex af,af' ;'
       sbc a,a ;keep CF
        or a
	adc hl,bc ;ZF,SF
       rra ;old CF
	ld a,l
        exx
	ld e,0 ;overflow data
        jp po,$+5
        ld e,0x40
	ld d,a ;PF
        exx
	ex af,af' ;'
	endm

	macro inchlwithflags ;keep CY
	ld bc,1
        incwithflags
	endm ;81.5t

	macro incbcwithflags ;keep CY
	ld hl,1
        incwithflags
        ld b,h
        ld c,l
	endm ;89.5t

	macro dechlwithflags ;keep CY
	ld bc,1
	ex af,af' ;'
       sbc a,a ;keep CF
        or a
	sbc hl,bc ;ZF,SF
       rra ;old CF
	ld a,l
        exx
	ld e,0 ;overflow data
        jp po,$+5
        ld e,0x40
	ld d,a ;PF
        exx
	ex af,af' ;'
	endm ;81.5t < 84t with call

	macro decbcwithflags ;keep CY
        ld h,b
        ld l,c
        dechlwithflags
        ld b,h
        ld c,l
	endm ;97.5t

       endif
