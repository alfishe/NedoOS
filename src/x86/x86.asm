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

       if 0
	macro putmemspBC_slow
        LD HL,(_SP)
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
	endm

	macro getmemspBC_slow
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
       endif

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

	macro KEEPCFPARITYOVERFLOW_FROMA_keepa
        exx
	ld d,a ;parity data
	rra
	ld e,a ;overflow data
	rla ;restore CF
	ex af,af' ;'
        ld a,d
        exx
	endm

	macro KEEPLOGICCFPARITYOVERFLOW_FROMA
        exx
	ld d,a ;parity data
	ld e,0 ;OF=0
	exx
	ex af,af' ;'
	endm

	macro KEEPLOGICCFPARITYOVERFLOW_FROMA_keepa
        exx
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
        ld a,d
	exx
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
        jp init
initq
Reset       
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

        LD DE,STARTPC ;=IP(PC)
        LD IY,EMUCHECKQ
        EI 
       _LoopC_JP
       
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
       if 0 ;debug
oldpc
        dw 0       endif
EMUCHECKQ
       if 0 ;debug
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

trom0
       if BASIC
        db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h, 16h, 20h(system)
       else
        ;db "test.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        db "paporot.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "gfxcom.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "para512.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "railways.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        ;db "lander.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 21h(allocate, vectors)
        ;db "pixeltwn.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system), Pentium 3
        ;db "ladybug.img",0 ;Его надо запускать в 0:0100h, требует функции bios int 10h, 20h(system)
        db "megapole.img",0 ;Его надо запускать в 0:0100h, требует bios int 10h, 21h#9 (print)
       endif
        ;DB "pc102782.bin",0

pgprog
        db 0 ;TODO там можно хранить дополнительный код (напр., отладчик)

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
        ld c,(hl) ;colour
     inc b ;ld b,trecolour/256
;a=1..4
        ;rrca
        ;rrca
        ;and 0xc0
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
	dw 0xffff,0xfdfd,0xefef,0xeded,0xfefe,0xfcfc,0xeeee,0xecec
	dw 0x1f1f,0x1d1d,0x0f0f,0x0d0d,0x1e1e,0x1c1c,0x0e0e,0x0c0c

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

        display "killable=",$

;killable
init
        ld sp,STACK
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

        ld de,ansipal
        OS_SETPAL ;TODO в Reset, с копированием во временную палитру

        ld de,path
        OS_CHDIR

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
     cp 4 ;чистим первые 4 страницы ;para512 ожидает чистую память после себя
     jr nc,filltpgs0_noclear
       push de
       push hl
       ld a,e
       call clpga
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
        ld h,tscreenpgs/256
        ld e,40
        ld bc,0x440
filltscreenpgs0
       ld l,e
       rrc l
       rrc l
        ld (hl),c
            ;dec l     ;
            ;ld (hl),c ;test backbuffer
        ld a,c
        add a,0x40
        ld c,a
        inc e
        djnz filltscreenpgs0

        call swapimer ;сначала прерывания ничего не делают (iff0==0)

        jp initq
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
path
        db "x86",0

;diskname
;        db "SYS.TRD",0       

end
        display "end=",$

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
