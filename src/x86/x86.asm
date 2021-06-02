        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

STACK=0x4000

;PC=0x4000...
;SP=0x8000...
;data=0xC000...


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
        call z,recountpc_inc
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

	macro memCS
        ld a,h
        ld (pc_high),a
	ld bc,(cs_LSW)
	add hl,bc
	ld a,(cs_HSB)
	adc a,0
	xor h
	and 0x3f
	xor h ;a = номер страницы (%01..5432)
	ld c,a
	ld b,tpgs/256
	res 7,h
        set 6,h
	ld a,(bc)
	SETPG4000
	endm

	macro memSS
        ld a,h
        ld (sp_high),a
	ld bc,(ss_LSW)
	add hl,bc
	ld a,(ss_HSB)
	adc a,0
	xor h
	and 0x3f
	xor h ;a = номер страницы (%01..5432)
	ld c,a
	ld b,tpgs/256
	set 7,h
        res 6,h
	ld a,(bc)
	SETPG8000
	endm

	macro memDS
	ld bc,(ds_LSW)
	add hl,bc
	ld a,(ds_HSB)
	adc a,0
	xor h
	and 0x3f
	xor h ;a = номер страницы (%01..5432)
	ld c,a
	ld b,tpgs/256
	ld a,h
	or 0xc0
	ld h,a
	ld a,(bc)
	SETPGC000
	endm

	macro memES
	ld bc,(es_LSW)
	add hl,bc
	ld a,(es_HSB)
	adc a,0
	xor h
	and 0x3f
	xor h ;a = номер страницы (%01..5432)
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
	endm

	macro putmemES
	push af
	memES
	pop af
	ld (hl),a
	endm

	macro getmemDS
	memDS
	ld a,(hl)
	endm

	macro getmemES
	memES
	ld a,(hl)
	endm

	macro putmemspBC
        LD HL,(_SP_encoded)
       res 6,h
       set 7,h
	inc l
	dec l
	call z,recountsp_dec
	dec l
	ld (hl),b
	call z,recountsp_dec
	dec l
	ld (hl),c
       LD HL,(_SP_encoded)
       dec hl
       dec hl
        LD (_SP_encoded),HL	
	endm

	macro getmemspBC
        LD HL,(_SP_encoded)
       res 6,h
       set 7,h
	ld c,(hl)
        inc l
	call z,recountsp_inc
	ld b,(hl)
        inc l
	call z,recountsp_inc
       LD HL,(_SP_encoded)
       inc hl
       inc hl
        LD (_SP_encoded),HL
	endm

	macro encodeSP
        ld h,b
        ld l,c
        ;res 6,b
        ;set 7,b ;0x8000+
	ld (_SP_encoded),hl;bc
        memSS
	endm

	macro decodeSP_fromBC
        ;ld a,(sp_high)
        ;xor b
        ;and 0xc0
        ;xor b
        ;ld b,a
	endm
	macro decodeSP
        ld bc,(_SP_encoded)
        decodeSP_fromBC
        endm

	macro KEEPPARITYOVERFLOW
	ld d,a ;parity data
	rra
	ld e,a ;overflow data
	rla ;restore CF
	endm

;inc - Adds 1 to the destination operand, while preserving the state of the CF flag. 
;The OF, SF, ZF, AF, and PF flags are set according to the result. 
	macro inchlwithflags ;keep CY
	ex af,af' ;'
	ld bc,1
	jr c,2f
	adc hl,bc ;ZF,SF
	ld a,h
        exx
	rra
	ld e,a ;OF
	scf
	ccf ;NC
	jp 8f
2
	or a
	adc hl,bc ;ZF,SF
	ld a,h
        exx
	rra
	ld e,a ;OF
	scf ;C
8
	ex af,af' ;'
        exx
	ld a,h
	xor l
        exx
	ld d,a ;PF
        exx
	endm

	macro dechlwithflags ;keep CY
	ex af,af' ;'
	ld bc,1
	jr c,2f
	sbc hl,bc ;ZF,SF
	ld a,h
        exx
	rra
	ld e,a ;OF
	scf
	ccf ;NC
	jp 8f
2
	or a
	sbc hl,bc ;ZF,SF
	ld a,h
        exx
	rra
	ld e,a ;OF
	scf ;C
8
	ex af,af' ;'
        exx
	ld a,h
	xor l
        exx
	ld d,a ;PF
        exx
	endm

	macro cmphl
	sub (hl)
	exx
	KEEPPARITYOVERFLOW
	exx
	endm

	macro cmpc
	sub c
	exx
	KEEPPARITYOVERFLOW
	exx
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
       
        ld bc,0
        ld (_CS),bc
        countCS
        ld de,0x7c00
        encodePC;memCS
       
        ld bc,0
        ld (_SS),bc
        countSS
        ld bc,0xff00
        encodeSP;memSS
       
        ;OS_NEWPAGE
        ;ld a,e
        ;LD (pgrom0),a
        ld de,trom0
        ld hl,0x7c00;0xc000
;de=имя файла
;hl=куда грузим (0xc000)
;a=в какой странице
        call loadfile_in_ahl



        call swapimer

        LD DE,0x7C00 ;=PC
        LD IY,EMUCHECKQ
        EI 
       _LoopC_JP
jpiyer
        ld hl,jpiyer
        push hl
        jp (iy)
oldpc
        dw 0EMUCHECKQ
       ld a,d
       sub 0x7c
       cp 2
       jr nc,$
       ld (oldpc),de
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD C,(HL)
        INC H
        LD H,(HL)
        ld L,C
        JP (HL) 

;de=имя файла;hl=куда грузим (0xc000)
;a=в какой странице
loadfile_in_ahl
        SETPGC000 ;включили страницу A в 0xc000
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret;jp setpgmainc000 ;включили страницу программы в c000, как было 

path
        db "x86",0

diskname
        db "SYS.TRD",0
        
trom0
        db "basic.img",0 ;Его надо запускать в 0:7C00h, требует функции bios int 10h/16h
        ;DB "pc102782.bin",0

        align 256
tpgs
        ds 256 ;%10765432

pgrom0
        db 0 ;TODO убрать?
pgprog
        db 0 ;TODO убрать?

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
_SP_encoded     DW 0 ;not encoded
_BP     DW 0
_SI     DW 0
_DI     DW 0

sp_high     db 0
pc_high     db 0
_ES     DW 0
_CS     DW 0
_SS     DW 0
_DS     DW 0
cs_LSW	dw 0
cs_HSB	db 0
ss_LSW	dw 0
ss_HSB	db 0
ds_LSW	dw 0
ds_HSB	db 0
es_LSW	dw 0
es_HSB	db 0
_DIRECTION
	db 0
iff1	db 0
iff2	db 0 ;TODO unneeded?

timer
	dw 0

recountpc_inc
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
        bit 6,h
        ret z ;<0xc000
        push bc
        dec hl
        ld b,h
        ld c,l
        decodeSP_fromBC ;bc->bc
        ld h,b
        ld l,c
        inc hl
        memSS
        pop bc
        ld hl,0x8000
	ret

recountsp_dec
;вызывается до dec l!
	dec h
        ret m ;>=0x8000
        push bc
        inc h
        ld b,h
        ld c,l
        decodeSP_fromBC ;bc->bc
        ld h,b
        ld l,c
        memSS
        pop bc
        ld hl,0xbf00
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
        LD HL,#38 ;new PC
        ;LD HL,(_I-1)
        ;LD L,#FF ;состояние пассивной ШД
        ;getmemBC
        ;ld h,b
        ;ld l,c
        ;JR IMERIM 
IMERIM
;hl=new PC
        EI
       decodePC ;de=old PC
        ex de,hl ;DE=new PC
        LD B,H
        ld C,L ;BC=old PC
        putmemspBC ;TODO а CS куда?
       _LoopC_JP 

	include "x86cmd.asm"
	include "x86math.asm"
	include "x86logic.asm"
        align 256
	include "x86table.asm"

end

        align 256 ;for setmem00004000forwrite
secbuf
        ds 256
        display secbuf+256

	savebin "x86.com",begin,end-begin

	LABELSLIST "../../us/user.l"
