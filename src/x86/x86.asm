        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

STACK=0x4000

       if 0
BASIC=0
       if BASIC
STARTPC=0x7c00
       else
STARTPC=0x0100
       endif
       endif

SHIFTCOUNTMASK=1 ;and 31
AFFLAG_16BIT=1 ;only for add_test
FASTADC16WITHFLAGS=0 ;NS

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
	endm

	macro encodePC
        ld h,d
        ld l,e
        memCS
        res 7,d
        set 6,d ;0x4000+
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

	macro memCS
        ld a,h
        ld (pc_high),a
	ld bc,(cs_LSW)
	ld a,(cs_HSB)
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld b,tpgs/256
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

        org PROGSTART
begin
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = "x86 <file to load>"
       ld (filenameaddr),hl
       ld hl,0x100
       ld (loadaddr),hl
       jr autoloadq
noautoload
        ld de,path
        OS_CHDIR
autoloadq
        jp init
initq
Reset       
        ld de,ansipal
        OS_SETPAL ;TODO с копированием во временную палитру

        ld bc,0
        ld (_SS),bc
        countSS
        ld hl,0x7f00
        ld (_SP),hl
        encodeSP
        
        ld bc,0xf000
        ld (_CS),bc
        countCS      
        ld de,0xe000
        encodePC;memCS ;out: a=physpg, de=zxaddr
        ex de,hl
        ld de,trom0
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl

        ld de,0xfff0

       if 1
        ld bc,0
        ld (_CS),bc
        countCS
loadaddr=$+1
        ld de,0x7c00;STARTPC
       push de
        encodePC;memCS ;out: a=physpg, de=zxaddr
        ex de,hl
filenameaddr=$+1
        ld de,tprog
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl
       pop de ;LD DE,STARTPC ;=IP(PC)
       endif
       
       
        LD IY,EMUCHECKQ
        ;EI 
       _LoopC_JP

quiter
        call swapimer ;сначала прерывания ничего не делают (iff0==0)
        QUIT
       
       if 0
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
       endif
       if 1 ;debug
oldpc
        dw 0       endif
EMUCHECKQ
       if 1 ;debug
       ;ld a,d
       ;sub 0x40+((STARTPC/256)&0x3f);0x7c
       ;cp 0x3f
       ;jr nc,$
       ;ld a,(_SP)
       ;rra
       ;jr c,$
       ld (oldpc),de
       endif
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD b,(HL)
        INC H
        LD H,(HL)
        ld L,b ;чётный для всех rm-команд
        JP (HL) 

clpga
        SETPGC000
        ld hl,0xc000
        ld d,h
        ld e,l
        inc e
        ld bc,0x3fff
        ld (hl),l;0
        ldir
        ret     

;de=имя файла
;hl=куда грузим
loadfile_in_hl
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld h,0x7f ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

trom0
        db "compaq.bin",0 ;грузить в F000:E000, запускать с FFF0?
tprog
        db "atomchess.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        ;db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
        ;db "lander.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 21h(allocate, vectors)
        ;db "ladybug.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "megapole.img",0 ;Его надо запускать в 0:0100h, требует bios int 10h, 21h#9 (print)
        ;DB "pc102782.bin",0

pgprog
        db 0 ;TODO там можно хранить дополнительный код (напр., отладчик)

;keep here for quit
swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int
        jp 0x0038+3

on_int
        PUSH AF,HL
        push bc,de
        exx
        push bc
        push de
        push hl
        push ix
        push iy
        ex af,af' ;'
        push af 
        call oldimer
	ld hl,(timer)
	inc hl
	ld (timer),hl
       ld a,0xf7
       in a,(0xfe)
       and 0b10101
       jp z,quiter ;1+2+3 = quit
        ;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop af
        ex af,af' ;'
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        exx
        pop de,bc
       LD A,(iff1)
       OR A
       jr NZ,IMEREI
        POP HL,AF
        EI
       RET
IMEREI
        XOR A
        LD (iff1),A
        LD (iff2),A ;для NMI надо только iff1!
;перед эмуляцией INT завершаем тек.команду (перехват на EMULOOP)
        LD (keepemuchecker),IY
        LD IY,IMINT
        POP HL,AF
        RET  ;di!
IMINT
keepemuchecker=$+2
        LD IY,0
       ;LD (retfromim),DE ;для индикации времени обработки прерыв
        LD HL,#38 ;new IP(PC) ;TODO из вектора
        ;LD HL,(_I-1)
        ;LD L,#FF ;состояние пассивной ШД
        ;getmemBC
        ;ld h,b
        ;ld l,c
        ;JR IMERIM 
IMERIM
;hl=new IP(PC)
        EI
       decodePC ;de=old IP(PC)
        ex de,hl ;DE=new IP(PC)
        LD B,H
        ld C,L ;BC=old IP(PC)
        putmemspBC ;TODO а CS куда? push cs; push ip?
       _LoopC_JP 

       if 1;AFFLAG_16BIT
;как сформировать ZF,SF, не трогая AF?
;для этого надо сформировать число с нужными свойствами и сделать inc
         ;ZF SF AF OF
;ff даёт  1  0  1  0 ;имитирует флаги после inc ffff
;7f даёт  0  1  1  1 ;имитирует флаги после inc 7fff
;80 даёт  0  1  0  0 ;имитирует флаги после inc 8000
;8f даёт  0  1  1  0 ;имитирует флаги после inc 800f
;т.е. ff, 7f надо формировать только для 7fff, ffff
;а в остальных случаях надо брать (h&0x80) + (l&0x08)
;если l!=ff, l!=7f, то можно просто сделать inc l
;если l=ff, то нельзя просто сделать inc h - запортится AF!
inchlwithflags_l00 ;inc h needed
        inc h
        ret z ;set ZF=1(ok), AF=1(ok), OF=0(ok)
        jp pe,inchlwithflags_overflow
inchlwithflags_a0_setAF ;set ZF=0(ok), SF=h7(ok), AF=1, keep CY
;a=0
        jp m,$+5
        ld a,0x80 ;after dec: a7=h7
        dec a ;set ZF=0, SF=h7, AF=1, keep CY
        ret
incbcwithflags_c00 ;inc b needed
        inc b
        ret z ;set ZF=1(ok), AF=1(ok), OF=0(ok)
        jp po,inchlwithflags_a0_setAF
inchlwithflags_overflow
        exx
        ld e,0x80 ;overflow (e7!=e6)
        exx
        ret

inchlwithflags_l80 ;fix SF, keep AF=1, ZF=0
;a=0x80
        bit 7,h
        jr z,inchlwithflags_l80_p
inchlwithflags_l80_m
        ld a,0 ;keep CY!
        dec a ;00->ff ;set ZF=0, SF=h7, AF=1, keep CY
        ret
incbcwithflags_c80 ;fix SF, keep AF=1, ZF=0
;a=0x80
        bit 7,b
        jr nz,inchlwithflags_l80_m
inchlwithflags_l80_p
        dec a ;80->7f ;set ZF=0, SF=h7, AF=1, keep CY
        ret

dechlwithflags_fixflags
	ex af,af' ;'
        dec l
        ld a,l
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        jr z,dechlwithflags_l00 ;maybe zero
        inc a
        jp pe,inchlwithflags_l80;dechlwithflags_l7f ;fix SF, keep AF=1, ZF=0
        ret nz
        dec h
        jp pe,inchlwithflags_overflow
        jr nz,inchlwithflags_a0_setAF ;set ZF=0, SF=h7, AF=1, keep CY
;a=0, hl=0x00ff
        inc a ;set ZF=0, SF=0, AF=0, keep CY
        ret
dechlwithflags_l00 ;maybe zero
;a=0
        inc h
        dec h
        ret z ;set ZF=1, SF=0, AF=0
        ld a,h
        res 0,a ;for ZF=0, AF=0
        inc a ;set ZF=0, SF=h7, AF=0, keep CY
        ret

decbcwithflags_fixflags
	ex af,af' ;'
        dec c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,0 ;overflow data
        exx
        jr z,decbcwithflags_c00 ;maybe zero
        inc a
        jp pe,inchlwithflags_l80;dechlwithflags_l7f ;fix SF, keep AF=1, ZF=0
        ret nz
        dec b
        jp pe,inchlwithflags_overflow
        jr nz,inchlwithflags_a0_setAF ;set ZF=0, SF=h7, AF=1, keep CY
;a=0, bc=0x00ff
        inc a ;set ZF=0, SF=0, AF=0, keep CY
        ret
decbcwithflags_c00 ;maybe zero
;a=0
        inc b
        dec b
        ret z ;set ZF=1, SF=0, AF=0
        ld a,b
        res 0,a ;for ZF=0, AF=0
        inc a ;set ZF=0, SF=h7, AF=0, keep CY
        ret

       endif

countXS_bc_to_ahl
	ld h,b
	ld l,c
	xor a
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
        ret

putmemspBC_pp
        ;LD HL,(_SP)
	inc l
	dec l
	call z,recountsp_dec
	dec l
       push hl
       res 6,h
       set 7,h
	ld (hl),b
       pop hl
	call z,recountsp_dec
	dec l
        LD (_SP),HL	
       res 6,h
       set 7,h
	ld (hl),c
       pop hl
        ld bc,_putmemspBC_skipsize
        add hl,bc
        jp (hl)

getmemspBC_pp
        ;LD HL,(_SP)
       push hl
       res 6,h
       set 7,h
	ld c,(hl)
       pop hl
        inc l
	call z,recountsp_inc
       push hl
       res 6,h
       set 7,h
	ld b,(hl)
       pop hl
        inc l
	call z,recountsp_inc
        LD (_SP),HL
       pop hl
       push bc
        ld bc,_getmemspBC_skipsize
        add hl,bc
       pop bc
        jp (hl)

recountsp_inc
	inc h
        push bc
        push hl
        memSS
        pop hl
        pop bc
	ret

recountsp_dec
;вызывается до dec l!
        dec h
        push bc
        push hl
        memSS
        pop hl
        pop bc
	ret

recountpc_inc ;keep CY!
	inc d
        ret p ;<0x8000
        push af
        push bc
        ex de,hl
        dec hl
        ld b,h
        ld c,l
        decodePC ;bc->bc
        ld h,b
        ld l,c
        inc hl
        memCS
        ex de,hl
        pop bc
        pop af
        ld de,0x4000
	ret

PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg_do
       push hl
       push bc
       call PUTscreen_logpgc_zxaddrhl_datamhl_do
       pop bc
        ld b,tpgs/256
        ld a,(bc)
        SETPGC000 ;как было
       pop hl
        ret

PUTscreen_logpgc_zxaddrhl_datamhl_do
_PUTscreen_do_patch=$
_PUTscreen_do_patch_vgadata=0x044e ;ld c,(hl):inc b
        jr PUTscreen_textmode ;/ld c,(hl):inc b (b=trecolour/256)
;a=1..4*0x40
        add a,h
        ld h,a
;экран VGA = 320 байт на строку
;экран ZXEGA = 40 байт на строку *4 слоя
        scf
        rr h
        rr l ;CY=left/right
        jr c,PUTscreen_rightpixel
        sra h
        rr l
        ld a,(user_scr0_low) ;ok
        jr nc,$+5
        ld a,(user_scr0_high) ;ok
       push bc
        SETPGC000
       pop bc
        sra h
        rr l
        jr c,$+4
        res 5,h
     ld a,(bc)
     xor (hl)
     and 0b01000111
     xor (hl)
     ld (hl),a    
        ret
PUTscreen_rightpixel
        sra h
        rr l
        ld a,(user_scr0_low) ;ok
        jr nc,$+5
        ld a,(user_scr0_high) ;ok
       push bc
        SETPGC000
       pop bc
        sra h
        rr l
        jr c,$+4
        res 5,h
     ld a,(bc)
     xor (hl)
     and 0b10111000
     xor (hl)
     ld (hl),a    
        ret

PUTscreen_textmode
        ld c,(hl) ;colour
     ;inc b ;ld b,trecolour/256
;a=1..4*0x40
        ;add a,h
       ;cp 4096/256
       ;ret nc
        ;ld h,a
;hl=addr in screen=0..65535
;The VGA text buffer is located at physical memory address 0xB8000.
;25 строк по 80 слов: символ, атрибут (%FpppIiii - пересчитать в PIpppiii)
;как пересчитать строки по 160 байт (80 символов) в строки по 64 байта (128 виртуальных символов)? всего 2000 знакомест = 125 групп по 16 символов, можно по таблице получить адрес (2 байта) или номер виртуальной группы (их всего 200, т.е. 1 байт)
       push bc
;получаем номер группы по 16 символов:
;hl=0000GGGG gggXXXxA
        ;xor l
        ;and 0xe0
        ;xor h
           ;rlca
           ;rlca
           ;rlca
        ld a,l  ;gggXXXxA
        srl a
        xor h 
        and 0xf0
        xor h    ;0gggGGGG
;пересчитываем в номер группы на АТМ textmode:
        ld b,ttextaddr/256
        ld c,a
        ld a,(bc) ;gggGGGgg
        ld h,a
        xor l
        and 0xe0
        xor l
        ld l,a
        ld a,h
        and 0x1f
;пересчитываем в адрес группы на ATM textmode:
;hl=000GGGgg gggXXXxA ;+0x01c0 уже прибавлено к номеру группы как +56
         scf
         rra
        rr l
        jr c,PUTscreen_attr
         scf
         rra
        rr l
        jr nc,$+4
         or 0x20;set 5,h
        ld h,a
;RAM page #05 (#07):
;#21C0...#27FF - character codes of odd (1,3,...) characters (25 lines, every line is 64 bytes, of which only first 40 are significant).
;#01C0...#07FF - character codes of even (0,2,...) characters (ditto).
        ld a,(user_scr0_high) ;ok
        SETPGC000
       pop bc
       ld b,t866toatm/256
       ld a,(bc)
        ld (hl),a
        ret
PUTscreen_attr
         rra
        rr l
        inc l
        jr c,$+5
         or 0x20
         dec l
        ld h,a
;RAM page #01 (#03):
;#21C0...#27FF - attributes of even(!) characters (ditto).
;#01C1...#07FF - attributes of odd(!) characters (ditto).
        ld a,(user_scr0_low) ;ok
        SETPGC000
       pop bc ;c=%ppppiiii
        ld a,c
        rra
        xor c
        and 0b00111000
        xor c
        and 0b10111111
        bit 3,c
        jr z,$+4
        or 0b01000000
        ld (hl),a ;%pipppiii
        ret

       display "--",$
	include "rmbyte.asm"
       display "--",$
	include "rmbytcmd.asm"
       display "--",$
	include "x86cmd.asm"
       display "--",$
	include "x86math.asm"
       display "--",$
	include "x86logic.asm"
       display "--",$
	include "ports.asm"
       display "--",$

        align 256
tpgs
        ds 256 ;%10765432
tscreenpgs
        ds 256,tscreenpgs/256 ;%10765432 ;номер страницы в экране или tscreenpgs/256, если не экранная

;trecolour = tscreenpgs+256
       macro dbcol _0
        db ((_0)&7)*9 + (((_0)&8)*0x18)
       endm
        
       macro dbcol8 _0,_1,_2,_3,_4,_5,_6,_7
        dbcol _0
        dbcol _1
        dbcol _2
        dbcol _3
        dbcol _4
        dbcol _5
        dbcol _6
        dbcol _7
       endm
        
       macro dbcol8i _0,_1,_2,_3,_4,_5,_6,_7
        dbcol8 _0|0x08,_1|0x08,_2|0x08,_3|0x08,_4|0x08,_5|0x08,_6|0x08,_7|0x08
       endm
        
        align 256
trecolour ;TODO generate for given palette
        dup 16
        dbcol $&0xff
        edup
;0x10
        dbcol8 0,0,0,0,8,8,8,8
        dbcol8 7,7,7,7,15,15,15,15
;0x20
        dbcol8 1,1,1,5,5,5,4,4
        dbcol8 4,4,4,6,6,6,2,2
        dbcol8 2,2,2,3,3,3,1,1
;0x38
        dbcol8i 1,1,1,5,5,5,4,4
        dbcol8i 4,4,4,6,6,6,2,2
        dbcol8i 2,2,2,3,3,3,1,1
;0x50
        dbcol8i 7,7,7,7,7,7,7,7
        dbcol8i 7,7,7,7,7,7,7,7
        dbcol8i 7,7,7,7,7,7,7,7
;0x68
        dbcol8 1,1,1,5,5,5,4,4
        dbcol8 4,4,4,6,6,6,2,2
        dbcol8 2,2,2,3,3,3,1,1
;0x80
       dup 6
        dbcol8 8,8,8,8,8,8,8,8
       edup
;0xb0
        ds 72,0x00
;0xf8
        ds 8,0

        align 256
;8 r16s
_AX
_AL     DB 0
_AH     DB 0
_CX
_CL     DB 0
_CH     DB 0
_DX
_DL     DB 0
_DH     DB 0
_BX
_BL     DB 0
_BH     DB 0
_SP     DW 0 ;use encodeSP (with hl=(_SP)) after write!
_BP     DW 0
_SI     DW 0
_DI     DW 0
;0x10
;4 sregs + 2
_ES     DW 0
_CS     DW 0
_SS     DW 0
_DS     DW 0
_FS     DW 0
_GS     DW 0

        ds _ES+0x10-$
;0x20
es_HSB	db 0
        nop
cs_HSB	db 0
        nop
ss_HSB	db 0
        nop
ds_HSB	db 0
        nop
fs_HSB	db 0
        nop
gs_HSB	db 0

        ds _ES+0x20-$
;0x30
es_LSW	dw 0
cs_LSW	dw 0
ss_LSW	dw 0
ds_LSW	dw 0
fs_LSW	dw 0
gs_LSW	dw 0

ansipal
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
;по сравнению с цветами терминала переставлено:
;1-4
;3-6
	dw 0xffff,0xfefe,0xefef,0xeeee,0xfdfd,0xfcfc,0xeded,0xecec
	dw 0x1f1f,0x1e1e,0x0f0f,0x0e0e,0x1d1d,0x1c1c,0x0d0d,0x0c0c

pc_high     db 0

_DIRECTION
	db 0
iff1	db 0
iff2	db 0 ;TODO unneeded?

timer
	dw 0
        
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ds _AX+128-$
;decode rm
        dup 8
        db _AL&0xff
        db _CL&0xff
        db _DL&0xff
        db _BL&0xff
        db _AH&0xff
        db _CH&0xff
        db _DH&0xff
        db _BH&0xff
        edup
       ds _AX+192-$
;decode r8 (TODO поменять местами с decode rm, т.к. rm нужно чаще)
        ds 8,_AL&0xff
        ds 8,_CL&0xff
        ds 8,_DL&0xff
        ds 8,_BL&0xff
        ds 8,_AH&0xff
        ds 8,_CH&0xff
        ds 8,_DH&0xff
        ds 8,_BH&0xff
        align 256
	include "x86table.asm"

        align 256
t866toatm
        incbin "../kernel/866toatm"

        align 256
       macro dbrrc3 data
        db (data>>3)+((data<<5)&0xe0)
       endm
ttextaddr
        dup 128
_=$&0xff
;0gggGGGG -> 0GGGGggg:
_=((_&0x0f)<<3)+((_&0x70)>>4)
       if _<125
_=_/5*8+(_-(_/5*5))+56
        dbrrc3 _
       else
        dbrrc3 255
       endif
        edup

        display "killable=",$

;killable
init
        OS_HIDEFROMPARENT
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;ld e,0
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS
        ;ld e,1
        ;OS_SETSCREEN
        ;ld e,0
        ;OS_CLS

        ld sp,STACK
        ;ld de,diskname
        ;OS_OPENHANDLE
        ;ld a,b
        ;ld (diskhandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgprog),a

        ld a,(user_scr0_high) ;ok
        call clpga
        ld a,(user_scr0_low) ;ok
        call clpga

        ld hl,tpgs
        ld b,64
filltpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
     ld a,l
     add a,-40
     cp 4-40 ;чистим первые 4 страницы и экран с остатком памяти ;para512 ожидает чистую память после себя, pillman ожидает чистый экран
     ;jr nc,filltpgs0_noclear
       push de
       push hl
       ld a,e
       call c,clpga
       pop hl
       pop de
filltpgs0_noclear
        pop bc
       ld a,l
       rrc l
       rrc l
        ld (hl),e
       ld l,a
        inc l
        djnz filltpgs0
       
;0xa0000 (pg 40): 4 pages for screen
;0xb8000 (pg 46): 1 page for textmode
        ld h,tscreenpgs/256
        ld bc,4*256+40
        xor a
filltscreenpgs0
        add a,0x40
       ld l,c
       rrc l
       rrc l
        ld (hl),a
            ;dec l     ;
            ;ld (hl),a ;test backbuffer
        inc c
        djnz filltscreenpgs0
       ld (tscreenpgs+0x8b),a ;for textmode

        call swapimer ;сначала прерывания ничего не делают (iff0==0)

        jp initq
path
        db "x86",0
skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

end
        display "end=",$

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
