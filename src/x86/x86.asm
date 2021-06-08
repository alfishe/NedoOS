        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

STACK=0x4000

BASIC=0
       if BASIC
STARTPC=0x7c00
       else
STARTPC=0x0100
       endif

;PC=0x4000...
;SP=0x8000...
;data=0xC000...

       macro ALIGNrm
        align 2
       endm

       macro _PUTscreen_logpgc_zxaddrhl_datamhl_keepabchlpg
        push af
        push bc
        ld b,tscreenpgs/256
        ld a,(bc)
        or a
        call nz,PUTscreen_logpgc_zxaddrhl_datamhl_keepabchlpg_do
        pop bc
        pop af
       endm

       macro _PUTscreen_logpgc_zxaddrhl_datamhl
        ld b,tscreenpgs/256
        ld a,(bc)
        or a
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
	ld (ss_LSW),hl
	ld (ss_HSB),a
	endm

	macro countCS ;bc=(_CS)
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
	ld (cs_LSW),hl
	ld (cs_HSB),a
	endm

	macro countDS ;bc=(_DS)
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
	ld (ds_LSW),hl
	ld (ds_HSB),a
	endm

	macro countES ;bc=(_ES)
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

	macro putmemDS
	push af
	memDS
	pop af
	ld (hl),a
;TODO перехват записи в экран
        
	endm

	macro getmemDS
	memDS
	ld a,(hl)
	endm
       endif

	macro putmemspBC
        LD HL,(_SP)
	inc l
	dec l
	call z,recountsp_dec
	dec l
       push hl
       res 6,h
       set 7,h
	ld (hl),b
;TODO перехват записи в экран

       pop hl
	call z,recountsp_dec
	dec l
        LD (_SP),HL	
       res 6,h
       set 7,h
	ld (hl),c
;TODO перехват записи в экран

	endm

	macro getmemspBC
        LD HL,(_SP)
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
	endm

	macro encodeSP
	;ld hl,(_SP)
        memSS
	endm

	macro KEEPCFPARITYOVERFLOW_FROMA
        exx
	ld d,a ;parity data
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
	endm

	macro KEEPLOGICCFPARITYOVERFLOW_FROMA
        exx
	ld d,a ;parity data
	ld e,0 ;OF=0
	exx
	ex af,af' ;'
	endm

        macro KEEPCFPARITYOVERFLOW_FROMHL
	ld a,h
	rra
	exx
	ld e,a ;overflow data
	exx
	rla ;restore CF
	ex af,af' ;'
        ld a,h
        xor l
	exx
	ld d,a ;parity data
	exx
        endm

        macro KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
	or l ;CF=0 ;ZF=(hl==0) ;TODO sign
	ex af,af' ;'
	ld a,h
	xor l
	exx
	ld d,a ;parity data
        ld e,0 ;OF=0
	exx
        endm

        macro KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
	or c ;CF=0 ;ZF=(bc==0) ;TODO sign
	ex af,af' ;'
	ld a,b
	xor c
	exx
	ld d,a ;parity data
        ld e,0 ;OF=0
	exx
        endm

        macro KEEPLOGICCFPARITYOVERFLOW_FROMHL
	ld a,h
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
        endm

        macro KEEPLOGICCFPARITYOVERFLOW_FROMBC
	ld a,b
        KEEPLOGICCFPARITYOVERFLOW_FROMBC
        endm

;inc - Adds 1 to the destination operand, while preserving the state of the CF flag. 
;The OF, SF, ZF, AF, and PF flags are set according to the result. 
	macro inchlwithflags ;keep CY
	ex af,af' ;'
	ld bc,1
       ld a,b
       rla ;keep CF
	adc hl,bc ;ZF,SF
       ld b,a
	ld a,h
	rra
        exx
	ld e,a ;OF
        exx
       ld a,b
       rra ;old CF
	ex af,af' ;'
	ld a,h
	xor l
        exx
	ld d,a ;PF
        exx
	endm

	macro incbcwithflags ;keep CY
	ex af,af' ;'
	ld hl,1
       ld a,h
       rla ;keep CF
	adc hl,bc ;ZF,SF
       ld b,a
	ld a,h
	rra
        exx
	ld e,a ;OF
        exx
       ld a,b
       rra ;old CF
	ex af,af' ;'
	ld a,h
	xor l
        exx
	ld d,a ;PF
        exx
        ld b,h
        ld c,l
	endm

	macro dechlwithflags ;keep CY
	ex af,af' ;'
	ld bc,1
       ld a,b
       rla ;keep CF
	sbc hl,bc ;ZF,SF
       ld b,a
	ld a,h
	rra
        exx
	ld e,a ;OF
        exx
       ld a,b
       rra ;old CF
	ex af,af' ;'
	ld a,h
	xor l
        exx
	ld d,a ;PF
        exx
	endm

	macro decbcwithflags ;keep CY
        ld h,b
        ld l,c
        dechlwithflags
        ld b,h
        ld c,l
	endm

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,6+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld de,path
        OS_CHDIR

        ld de,diskname
        OS_OPENHANDLE
        ld a,b
        ;ld (diskhandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgprog),a

        ld hl,tpgs
        ld b,64
filltpgs0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        pop bc
       ld a,l
       rrc l
       rrc l
        ld (hl),e
       ld l,a
        inc l
        djnz filltpgs0
       
;0xa0000 (pg 40): 4 pages for screen
        ld hl,tscreenpgs+40
        ld bc,0x401
filltscreenpgs0
       ld a,l
       rrc l
       rrc l
        ld (hl),c
        inc c
       ld l,a
        inc l
        djnz filltscreenpgs0
       
        ld bc,0
        ld (_SS),bc
        countSS
        ld hl,0xff00
        ld (_SP),hl
        encodeSP
       
        ld bc,0
        ld (_CS),bc
        countCS
        ld de,STARTPC
        encodePC;memCS ;out: a=physpg, de=zxaddr
        ex de,hl
        ld de,trom0
;de=имя файла
;hl=куда грузим
        call loadfile_in_hl



        call swapimer

        LD DE,STARTPC ;=IP(PC)
        LD IY,EMUCHECKQ
        EI 
       _LoopC_JP
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
       if 1 ;debug
oldpc
        dw 0       endif
EMUCHECKQ
       if 1 ;debug
       ld a,d
       sub 0x40+((STARTPC/256)&0x3f);0x7c
       cp 2
       jr nc,$
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

;de=имя файла
;hl=куда грузим
loadfile_in_hl
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret

path
        db "x86",0

diskname
        db "SYS.TRD",0
        
trom0
       if BASIC
        db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
       else
        db "gfxcom.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
       endif
        ;DB "pc102782.bin",0

pgprog
        db 0 ;TODO там можно хранить дополнительный код (напр., отладчик)

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

PUTscreen_logpgc_zxaddrhl_datamhl_keepabchlpg_do
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
        ld b,(hl) ;colour
;a=1..4
        rrca
        rrca
        and 0xc0
        add a,h
        ld h,a
;hl=addr in screen=0..65535
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
        SETPGC000
        sra h
        rr l
        jr c,$+4
        res 5,h
;TODO корректировать левую точку цветом b
     ld a,(hl)
     or 0b01000111
     ld (hl),a    
        ret
PUTscreen_rightpixel
        sra h
        rr l
        ld a,(user_scr0_low) ;ok
        jr nc,$+5
        ld a,(user_scr0_high) ;ok
        SETPGC000
        sra h
        rr l
        jr c,$+4
        res 5,h
;TODO корректировать правую точку цветом b
     ld a,(hl)
     or 0b10111000
     ld (hl),a    
        ret

       display "--",$
	include "rmbyte.asm"
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
        ds 256 ;%10765432 ;номер страницы в экране или 0, если не экранная

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
;4 sregs
_ES     DW 0
_CS     DW 0
_SS     DW 0
_DS     DW 0

pc_high     db 0

_DIRECTION
	db 0
iff1	db 0
iff2	db 0 ;TODO unneeded?

timer
	dw 0
        
        ds _ES+0x20-$
;0x30
es_LSW	dw 0
cs_LSW	dw 0
ss_LSW	dw 0
ds_LSW	dw 0
;0x38
es_HSB	db 0
        nop
cs_HSB	db 0
        nop
ss_HSB	db 0
        nop
ds_HSB	db 0

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
;decode r8
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

end

        display $

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
