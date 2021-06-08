PANIC
	jr $

;на входе в команду:
;без сегментного префикса: b=l(адрес обработчика)
;с сегментным префиксом: b=?s_LSW+1(нечётный)
;все обработчики rm-команд (и вообще команд с подменой сегмента) по чётному адресу
DSer
        ld b,1+(ds_HSB&0xff)
        get
        next
        LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 
CSer
        ld b,1+(cs_HSB&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 
ESer
        ld b,1+(es_HSB&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 
SSer
        ld b,1+(ss_HSB&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 

CLIer
        xor a
        ld (iff1),a
       _Loop_

STIer
        ld a,-1
        ld (iff1),a
       _Loop_

CLDer
	xor a
	ld (_DIRECTION),a
NOPer
       _Loop_

STDer
	ld a,-1
	ld (_DIRECTION),a
       _Loop_

STCer
	ex af,af' ;'
	scf
	ex af,af' ;'
       _Loop_

CLCer
	ex af,af' ;'
	scf
	ex af,af' ;'
CMCer
	ex af,af' ;'
	ccf
	ex af,af' ;'
       _Loop_

PUSHi8
	get
	next
	ld c,a
        rla
        sbc a,a
        ld b,a
       jr _PUSHq
PUSHi16
	getBC
       jr _PUSHq
PUSHax
       ld bc,(_AX)
       jr _PUSHq
PUSHcx
       ld bc,(_CX)
       jr _PUSHq
PUSHdx
       ld bc,(_DX)
       jr _PUSHq
PUSHbx
       ld bc,(_BX)
       jr _PUSHq
PUSHsp
       ld bc,(_SP)
       jr _PUSHq
PUSHbp
       ld bc,(_BP)
       jr _PUSHq
PUSHsi
       ld bc,(_SI)
       jr _PUSHq
PUSHdi
       ld bc,(_DI)
       jr _PUSHq
PUSHes
       ld bc,(_ES)
       jr _PUSHq
PUSHcs
       ld bc,(_CS)
       jr _PUSHq
PUSHss
       ld bc,(_SS)
       jr _PUSHq
PUSHds
       ld bc,(_DS)
_PUSHq
        putmemspBC
       _LoopC

POPax
        getmemspBC
        ld (_AX),bc
       _LoopC
POPcx
        getmemspBC
	ld (_CX),bc
       _LoopC
POPdx
        getmemspBC
	ld (_DX),bc
       _LoopC
POPbx
        getmemspBC
	ld (_BX),bc
       _LoopC
POPsp
        getmemspBC
        ld h,b
        ld l,c
	ld (_SP),hl
	encodeSP
       _LoopC
POPbp
        getmemspBC
	ld (_BP),bc
       _LoopC
POPsi
        getmemspBC
	ld (_SI),bc
       _LoopC
POPdi
        getmemspBC
	ld (_DI),bc
       _LoopC
POPes
        getmemspBC
	ld (_ES),bc
	countES
       _LoopC
POPcs
        getmemspBC
	ld (_CS),bc
	countCS
       _LoopC
POPss
        getmemspBC
	ld (_SS),bc
	countSS
       _LoopC
POPds
        getmemspBC
	ld (_DS),bc
	countDS
       _LoopC

MOVaxi16
	getHL
	ld (_AX),hl
       _Loop_
MOVcxi16
	getHL
	ld (_CX),hl
       _Loop_
MOVdxi16
	getHL
	ld (_DX),hl
       _Loop_
MOVbxi16
	getHL
	ld (_BX),hl
       _Loop_
MOVspi16
	getHL
	ld (_SP),hl
	encodeSP
       _LoopC
MOVbpi16
	getHL
	ld (_BP),hl
       _Loop_
MOVsii16
	getHL
	ld (_SI),hl
       _Loop_
MOVdii16
	getHL
	ld (_DI),hl
       _Loop_

MOVali8
	get
	next
	ld (_AL),a
       _Loop_
MOVcli8
	get
	next
	ld (_CL),a
       _Loop_
MOVdli8
	get
	next
	ld (_DL),a
       _Loop_
MOVbli8
	get
	next
	ld (_BL),a
       _Loop_
MOVahi8
	get
	next
	ld (_AH),a
       _Loop_
MOVchi8
	get
	next
	ld (_CH),a
       _Loop_
MOVdhi8
	get
	next
	ld (_DH),a
       _Loop_
MOVbhi8
	get
	next
	ld (_BH),a
       _Loop_

;mov [addr],al
        ALIGNrm
MOVmemal
	getHL
        call ADDRm16_pp_ds_nodisp ;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
       push bc
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld a,(_AL)
	ld (hl),a
       pop bc
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC

;mov [addr],ax
        ALIGNrm
MOVmemax
	getHL
        call ADDRm16_pp_ds_nodisp ;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
       push bc
        ld bc,(_AX) ;TODO спецверсию PUTm16
       _PUTm16LoopC

;mov al,[addr]
        ALIGNrm
MOValmem
	getHL
        call ADDRm16_pp_ds_nodisp ;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
	ld a,(hl)
	ld (_AL),a
       _LoopC

;mov ax,[addr]
        ALIGNrm
MOVaxmem
	getHL
        call ADDRm16_pp_ds_nodisp ;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld b,(hl)
        ld c,a
	ld (_AX),bc
       _LoopC

INCax
	ld hl,(_AX)
	inchlwithflags
	ld (_AX),hl
       _Loop_
INCcx
	ld hl,(_CX)
	inchlwithflags
	ld (_CX),hl
       _Loop_
INCdx
	ld hl,(_DX)
	inchlwithflags
	ld (_DX),hl
       _Loop_
INCbx
	ld hl,(_BX)
	inchlwithflags
	ld (_BX),hl
       _Loop_
INCsp
	ld hl,(_SP)
	inchlwithflags
	ld (_SP),hl
       encodeSP
       _LoopC
INCbp
	ld hl,(_BP)
	inchlwithflags
	ld (_BP),hl
       _Loop_
INCsi
	ld hl,(_SI)
	inchlwithflags
	ld (_SI),hl
       _Loop_
INCdi
	ld hl,(_DI)
	inchlwithflags
	ld (_DI),hl
       _Loop_

DECax
	ld hl,(_AX)
	dechlwithflags
	ld (_AX),hl
       _Loop_
DECcx
	ld hl,(_CX)
	dechlwithflags
	ld (_CX),hl
       _Loop_
DECdx
	ld hl,(_DX)
	dechlwithflags
	ld (_DX),hl
       _Loop_
DECbx
	ld hl,(_BX)
	dechlwithflags
	ld (_BX),hl
       _Loop_
DECsp
	ld hl,(_SP)
	dechlwithflags
	ld (_SP),hl
       encodeSP
       _LoopC
DECbp
	ld hl,(_BP)
	dechlwithflags
	ld (_BP),hl
       _Loop_
DECsi
	ld hl,(_SI)
	dechlwithflags
	ld (_SI),hl
       _Loop_
DECdi
	ld hl,(_DI)
	dechlwithflags
	ld (_DI),hl
       _Loop_

CALLer
        getHL
       decodePC
        add hl,de
        ex de,hl ;new IP(PC)
        ld b,h
        ld c,l ;=old IP(PC)
        putmemspBC
       _LoopJP

CALLptr1616
;push cs; push ip (адрес после команды)
       ld bc,(_CS)
        putmemspBC ;old CS
;абсолютный адрес ip, cs
        getBC ;ip
       push bc
        getBC ;cs
        ld (_CS),bc ;new CS
        countCS
        LD b,d
        ld c,e ;=old PC
       pop de ;new PC
        putmemspBC
       _LoopJP

JMPptr1616
;абсолютный адрес ip, cs
        getBC ;ip
        push bc
        getBC ;cs
        ld (_CS),bc
        countCS
        pop de
       _LoopJP

RETer
        getmemspBC
        LD D,B
        ld E,C ;new PC
       _LoopC_JP

JLEer ;jump if not greater (zero or less)
	ex af,af' ;'
	jp z,JRYer
	ex af,af' ;'
JLer ;jump if less (SF xor OF = 1)
	ex af,af' ;'
	jp m,exaJNOer
exaJOer
	ex af,af' ;'
JOer ;jump if overflow
	exx
	ld a,e ;overflow data
	and 0x40
	rla
	xor e
	exx
	JP M,JRer
        next
       _Loop_
JGer ;jump if greater (not zero and not less)
	ex af,af' ;'
	jp z,exaNOJP
	ex af,af' ;'
JNLer ;jump if not less (SF xor OF = 0)
	ex af,af' ;'
	jp m,exaJOer
exaJNOer
	ex af,af' ;'
JNOer ;jump if no overflow
	exx
	ld a,e ;overflow data
	and 0x40
	rla
	xor e
	exx
	JP P,JRer
        next
       _Loop_ 
JPer ;jump if parity even
	exx
	ld a,d ;parity data
	exx
	or a
	JP PE,JRer
        next
       _Loop_ 
JNPer ;jump if parity odd
	exx
	ld a,d ;parity data
	exx
	or a
	JP PO,JRer
        next
       _Loop_ 
JNEer
	ex af,af' ;'
	JR NZ,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JEer
	ex af,af' ;'
	JR Z,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JNCer
	ex af,af' ;'
	JR NC,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JCer
	ex af,af' ;'
	JR C,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JBEer ;jump if CF or ZF = 1
	ex af,af' ;'
	JR C,JRYer
	JR Z,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JAer ;jump if (CF or ZF) = 0, i.e. CF=ZF=0
	ex af,af' ;'
	JR C,$+4
	JR Z,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JRYer
	ex af,af' ;'
JRer
	get
        next
        ld l,a
        RLA
        SBC A,A
        LD H,A
       decodePC
        ADD HL,DE
        ex de,hl ;new PC 
       _LoopC_JP
JSer ;jump if sign
	ex af,af' ;'
	jp m,JRYer
	ex af,af' ;'
        next
       _Loop_ 
JNSer ;jump if no sign
	ex af,af' ;'
	jp p,JRYer
exaNOJP
	ex af,af' ;'
        next
       _Loop_
LOOPNZer
	ex af,af' ;'
	jr z,exaNOJP
	jr exaLOOPer
LOOPZer
	ex af,af' ;'
	jr nz,exaNOJP
exaLOOPer
	ex af,af' ;'
LOOPer
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
JCXZer ;jump if CX = 0
	ld hl,(_CX)
	ld a,h
	or l
	JR Z,JRer
        next
       _Loop_ 

JMPer
        getHL
       decodePC
        ADD HL,DE
        ex de,hl ;new PC
       _LoopC_JP

	macro XCHGAXRP rp
	ld bc,(rp)
        ld hl,(_AX)
	ld (rp),hl
	ld (_AX),bc
       _Loop_
	endm
XCHGaxcx
	XCHGAXRP _CX
XCHGaxdx
	XCHGAXRP _DX
XCHGaxbx
	XCHGAXRP _BX
XCHGaxsp
	ld bc,(_SP)
        ld hl,(_AX)
	ld (_AX),bc
	ld (_SP),hl
       encodeSP
       _Loop_
XCHGaxbp
	XCHGAXRP _BP
XCHGaxsi
	XCHGAXRP _SI
XCHGaxdi
	XCHGAXRP _DI

REPZer
REPNZer
;костыль! FIXME
	get
	next
	cp 0xa4
	jp z,REPMOVSBer
	cp 0xa6
	jp z,REPCMPSBer
	;cp 0xa5
	;jp z,REPMOVSWer
	;cp 0xaa
	;jp z,REPSTOSBer
	;cp 0xab
	;jp z,REPSTOSWer
	cp 0xae
	jp z,REPSCASBer
	;cp 0xaf
	;jp z,REPSCASWer
	jp PANIC

;TODO подмена сегмента
MOVSBer
	ld hl,(_SI)
	getmemDS
	ld hl,(_DI)
	putmemDS
	ld hl,(_SI)
	ld bc,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc bc
	jr z,$+6
	dec hl
	dec hl
	dec bc
	dec bc
	ld (_SI),hl
	ld (_DI),bc
       _LoopC

;rep cmpsb
;TODO подмена сегмента
REPMOVSBer
	ld hl,(_SI)
	getmemDS
	ld hl,(_DI)
	putmemDS
	ld hl,(_SI)
	ld bc,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc bc
	jr z,$+6
	dec hl
	dec hl
	dec bc
	dec bc
	ld (_SI),hl
	ld (_DI),bc
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ld a,h
	or l
	jr nz,REPMOVSBer_repeat
       _LoopC
REPMOVSBer_repeat
       decodePC
        dec de
        dec de ;new PC 
       _LoopC_JP

;TODO подмена сегмента
SCASBer
	ld hl,(_SI)
	getmemDS
	ld a,(_AL) ;al
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
	ld hl,(_SI)
	ld a,(_DIRECTION)
	or a
	inc hl
	jr z,$+4
	dec hl
	dec hl
	ld (_SI),hl
       _LoopC

;repnz scasb
;TODO подмена сегмента
REPSCASBer
	ld hl,(_SI)
	getmemDS
	ld a,(_AL) ;al
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
	ld hl,(_SI)
	ld a,(_DIRECTION)
	or a
	inc hl
	jr z,$+4
	dec hl
	dec hl
	ld (_SI),hl
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ex af,af' ;'
	jp z,exaLoopC
	ex af,af' ;'
	ld a,h
	or l
	jr nz,REPSCASBer_repeat
       _LoopC
REPSCASBer_repeat
       decodePC
        dec de
        dec de ;new PC 
       _LoopC_JP

;TODO подмена сегмента
CMPSBer
	ld hl,(_SI)
	getmemDS
	ex af,af' ;'
	ld hl,(_DI)
	getmemDS
	ex af,af' ;'
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
	ld hl,(_SI)
	ld bc,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc bc
	jr z,$+6
	dec hl
	dec hl
	dec bc
	dec bc
	ld (_SI),hl
	ld (_DI),bc
       _LoopC

;repz cmpsb
;TODO подмена сегмента
REPCMPSBer
	ld hl,(_SI)
	getmemDS
	ex af,af' ;'
	ld hl,(_DI)
	getmemDS
	ex af,af' ;'
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
	ld hl,(_SI)
	ld bc,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc bc
	jr z,$+6
	dec hl
	dec hl
	dec bc
	dec bc
	ld (_SI),hl
	ld (_DI),bc
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ex af,af' ;'
	jr nz,exaLoopC
	ex af,af' ;'
	ld a,h
	or l
	jr nz,REPCMPSBer_repeat
       _LoopC
exaLoopC
	ex af,af' ;'
       _LoopC
REPCMPSBer_repeat
       decodePC
        dec de
        dec de ;new PC 
       _LoopC_JP

;TODO подмена сегмента
LODSBer
	ld hl,(_SI)
	getmemDS
	ld (_AL),a ;al
	ld hl,(_SI)
	ld a,(_DIRECTION)
	or a
	inc hl
	jr z,$+4
	dec hl
	dec hl
	ld (_SI),hl
;flags not affected
;dec cx не надо!
       _LoopC

;TODO подмена сегмента
LODSWer
	ld hl,(_SI)
	getmemDS
	ld (_AL),a ;al
	ld hl,(_SI)
	inc hl
	getmemDS
	ld (_AH),a ;ah
	ld hl,(_SI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc hl
	jr z,$+6
	dec hl
	dec hl
	dec hl
	dec hl
	ld (_SI),hl
;flags not affected
;dec cx не надо!
       _LoopC

;TODO подмена сегмента
STOSBer
	ld a,(_AL) ;al
	ld hl,(_DI)
        putmemDS
	ld hl,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	jr z,$+4
	dec hl
	dec hl
	ld (_DI),hl
;flags not affected
;dec cx не надо!
       _LoopC

;TODO подмена сегмента
STOSWer
	ld a,(_AL) ;al
	ld hl,(_DI)
        putmemDS
	ld a,(_AH) ;ah
	ld hl,(_DI)
	inc hl
        putmemDS
	ld hl,(_DI)
	ld a,(_DIRECTION)
	or a
	inc hl
	inc hl
	jr z,$+6
	dec hl
	dec hl
	dec hl
	dec hl
	ld (_DI),hl
;flags not affected
;dec cx не надо!
       _LoopC

;int 0x20 ;system
;int 0x16 ;ah=0: input key -> al
;int 0x10 ;ah=0x0e: print al (зачем bx=7?)
;int 0x10 ;ah=0x00: set gfx mode = al (0x13)
INTi8
	get
	next
	cp 0x10
	jr z,INT10
	cp 0x16
	jr z,INT_inputal
       jr $
       ;_Loop_

INT10
        ld a,(_AH)
        or a
        jr z,INT_setgfx
        cp 0x0e
        jr z,INT_printal
       jr $

INT_setgfx
        push de
        push iy
        ld e,0+0x80 ;keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        pop iy
        pop de
       _Loop_

INT_printal
        push de
        ex af,af' ;'
        push af
        push iy
	ld a,(_AL)
	PRCHAR
        pop iy
        pop af
        ex af,af' ;'
        pop de
       _Loop_

INT_inputal
        push de
        push iy
        YIELDGETKEYLOOP;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop iy
	ld (_AL),a
        pop de
       _Loop_
