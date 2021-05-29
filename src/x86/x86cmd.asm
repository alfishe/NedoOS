PANIC
	jr $

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

CLCer
	ex af,af'
	scf
	ccf
	ex af,af'
       _Loop_

STCer
	ex af,af'
	scf
	ex af,af'
       _Loop_

CMCer
	ex af,af'
	ccf
	ex af,af'
       _Loop_

PUSHi8
	get
	next
	ld c,a
	ld b,0
        putmemspBC
       _LoopC
PUSHi16
	getBC
        putmemspBC
       _LoopC
PUSHax
        EXX
       push hl ;ax
        EXX
       pop bc
        putmemspBC
       _LoopC
PUSHcx
       ld bc,(_CX)
        putmemspBC
       _LoopC
PUSHdx
       ld bc,(_DX)
        putmemspBC
       _LoopC
PUSHbx
       ld bc,(_BX)
        putmemspBC
       _LoopC
PUSHsp
       ld bc,(_SP)
       decodeSP
        putmemspBC
       _LoopC
PUSHbp
       ld bc,(_BP)
        putmemspBC
       _LoopC
PUSHsi
       ld bc,(_SI)
        putmemspBC
       _LoopC
PUSHdi
       ld bc,(_DI)
        putmemspBC
       _LoopC
PUSHes
       ld bc,(_ES)
        putmemspBC
       _LoopC
PUSHcs
       ld bc,(_CS)
        putmemspBC
       _LoopC
PUSHss
       ld bc,(_SS)
        putmemspBC
       _LoopC
PUSHds
       ld bc,(_DS)
        putmemspBC
       _LoopC

POPax
        getmemspBC
        PUSH BC
        EXX
       POP HL ;ax
        EXX
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
	push hl
	exx
	pop hl ;ax
	exx
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
	getBC
	encodeSP
       _Loop_
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
	exx
	ld l,a ;al
	exx
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
	exx
	ld h,a ;ah
	exx
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

;mov byte [di],n
MOVmDIBYTE
	get
	next
	ld hl,(_DI)
	putmemDS
       _LoopC

;mov ax,[bx]
MOVAXmBX
	ld hl,(_BX)
	inc hl
	getmemDS
	push af ;a=ah
	ld hl,(_BX)
	getmemDS
	exx
	pop hl ;h=ah
	ld l,a ;al
	exx
       _LoopC

;mov [addr],ax
MOVmemax
	getHL
	push hl
	exx
	ld a,l ;al
	exx
	putmemDS
	pop hl
	inc hl
	exx
	ld a,h ;ah
	exx
	putmemDS
       _LoopC
;mov [addr],al
MOVmemal
	getHL
	exx
	ld a,l ;al
	exx
	putmemDS
       _LoopC
;mov ax,[addr]
MOVaxmem
	getHL
	push hl
	getmemDS
	exx
	ld l,a ;al
	exx
	pop hl
	inc hl
	getmemDS
	exx
	ld h,a ;ah
	exx
       _LoopC
;mov al,[addr]
MOValmem
	getHL
	getmemDS
	exx
	ld l,a ;al
	exx
       _LoopC


INCax
	exx
	ex af,af'
	ld bc,1
	jr c,2f
	adc hl,bc ;ZF,SF
	ld a,h
	rra
	ld e,a ;OF
	scf
	ccf ;NC
	jp 8f
2
	or a
	adc hl,bc ;ZF,SF
	ld a,h
	rra
	ld e,a ;OF
	scf ;C
8
	ex af,af'
	ld a,h
	xor l
	ld d,a ;PF
	exx
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
        ld bc,(_SP)
        decodeSP
        ld h,b
        ld l,c
	inchlwithflags
        ld b,h
        ld c,l
	encodeSP
       _Loop_
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
	exx
	ex af,af'
	ld bc,1
	jr c,2f
	sbc hl,bc ;ZF,SF
	ld a,h
	rra
	ld e,a ;OF
	scf
	ccf ;NC
	jp 8f
2
	or a
	sbc hl,bc ;ZF,SF
	ld a,h
	rra
	ld e,a ;OF
	scf ;C
8
	ex af,af'
	ld a,h
	xor l
	ld d,a ;PF
	exx
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
        ld bc,(_SP)
        decodeSP
        ld h,b
        ld l,c
	dechlwithflags
        ld b,h
        ld c,l
	encodeSP
       _Loop_
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
        EXD ;new PC
        LD B,H
        ld C,L ;=old PC
        putmemspBC
       _LoopC_JP 

RETer
        getmemspBC
        LD D,B
        ld E,C ;new PC
       _LoopC_JP

JLEer ;jump if not greater (zero or less)
	ex af,af'
	jr z,JRYer
	ex af,af'
JLer ;jump if less (SF xor OF = 1)
	ex af,af'
	jp m,exaJNOer
exaJOer
	ex af,af'
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
	ex af,af'
	jr z,exaNOJP
	ex af,af'
JNLer ;jump if not less (SF xor OF = 0)
	ex af,af'
	jp m,exaJOer
exaJNOer
	ex af,af'
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
	ex af,af'
	JR NZ,JRYer
	ex af,af'
        next
       _Loop_ 
JEer
	ex af,af'
	JR Z,JRYer
	ex af,af'
        next
       _Loop_ 
JNCer
	ex af,af'
	JR NC,JRYer
	ex af,af'
        next
       _Loop_ 
JCer
	ex af,af'
	JR C,JRYer
	ex af,af'
        next
       _Loop_ 
JBEer ;jump if CF or ZF = 1
	ex af,af'
	JR C,JRYer
	JR Z,JRYer
	ex af,af'
        next
       _Loop_ 
JAer ;jump if (CF or ZF) = 0, i.e. CF=ZF=0
	ex af,af'
	JR C,$+4
	JR Z,JRYer
	ex af,af'
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
	ex af,af'
	jp m,JRYer
	ex af,af'
        next
       _Loop_ 
JNSer ;jump if no sign
	ex af,af'
	jp p,JRYer
	ex af,af'
        next
       _Loop_ 

exaNOJP
	ex af,af' ;'
        next
       _Loop_

LOOPNZer
	ex af,af' ;'
	jr z,exaNOJP
	jr exaLOOPer
LOOPZer
	ex af,af'
	jr nz,exaNOJP
exaLOOPer
	ex af,af'
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

;jmp word [di]
JMPWORDmDI
	ld hl,(_DI)
	getmemDS
	ld e,a
	ld hl,(_DI)
	inc hl
	getmemDS
	ld d,a ;new PC
       _LoopC_JP

;mov al,[di]
MOVALmDI
	ld hl,(_DI)
	getmemDS
	exx
	ld l,a ;al
	exx
       _LoopC

;mov ah,[di]
MOVAHmDI
	ld hl,(_DI)
	getmemDS
	exx
	ld h,a ;ah
	exx
       _LoopC

	macro XCHGAXRP rp
	exx
	ld bc,(rp)
	ld (rp),hl
	ld h,b
	ld l,c
	exx
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
	decodeSP
	push bc
	exx
	ex (sp),hl
	exx
	pop bc
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

SCASBer
	ld hl,(_SI)
	getmemDS
	ex af,af'
	exx
	ld a,l ;al
	exx
	cmphl
	ex af,af'
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
REPSCASBer
	ld hl,(_SI)
	getmemDS
	ex af,af'
	exx
	ld a,l ;al
	exx
	cmphl
	ex af,af'
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
	ex af,af'
	jp z,exaLoopC
	ex af,af'
	ld a,h
	or l
	jr nz,REPSCASBer_repeat
       _LoopC
REPSCASBer_repeat
       decodePC
        dec de
        dec de ;new PC 
       _LoopC_JP

CMPSBer
	ld hl,(_SI)
	getmemDS
	push af
	ld hl,(_DI)
	getmemDS
	ex af,af'
	pop af
	cmphl
	ex af,af'
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
REPCMPSBer
	ld hl,(_SI)
	getmemDS
	push af
	ld hl,(_DI)
	getmemDS
	ex af,af'
	pop af
	cmphl
	ex af,af'
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
	ex af,af'
	jr nz,exaLoopC
	ex af,af'
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

LODSBer
	ld hl,(_SI)
	getmemDS
	exx
	ld l,a ;al
	exx
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

LODSWer
	ld hl,(_SI)
	getmemDS
	exx
	ld l,a ;al
	exx
	ld hl,(_SI)
	inc hl
	getmemDS
	exx
	ld h,a ;ah
	exx
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

STOSBer
	exx
	ld a,l ;al
	exx
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

STOSWer
	exx
	ld a,l ;al
	exx
	ld hl,(_DI)
        putmemDS
	exx
	ld a,h ;ah
	exx
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

;in al,0x40          ; Read timer counter 0 
INali8
	exx
	ld a,(timer)
	ld l,a
	exx
       _Loop_
	
;int 0x20 ;system
;int 0x16 ;ah=0: input key -> al
;int 0x10 ;ah=0x0e: print al (зачем bx=7?)
INTi8
	get
	next
	cp 0x10
	jr z,INT_printal
	cp 0x16
	jr z,INT_inputal
       _Loop_

INT_printal
        push de
        exx
        ex af,af' ;'
        push af
        push hl
        push iy
	ld a,l
	PRCHAR
        pop iy
        pop hl
        pop af
        ex af,af' ;'
        exx
        pop de
       _Loop_

INT_inputal
        push de
        exx
        push hl
        push iy
        YIELDGETKEYLOOP;OS_GETKEY
;        A - код символа(кнопки). Допустимые коды смотри в 'sysdefs.asm' секция 'Usable key codes'
;        C - код символа(кнопки) без учета текущего языкового модификатора. Как правило, используется для обработки "горячих кнопок"
;        DE - позиция мыши (y,x) (возвращает 0 при отсутствии фокуса)
;        L - кнопки мыши (bits 0(LMB),1(RMB),2(MMB): 0=pressed; bits 7..4=положение колёсика)
;        LX - Kempston joystick (0bP2JFUDLR): 1=pressed, - при отсутствии джойстика 0 (а не 0xff)
;        Флаг Z - если 0(NZ), то отсутствует фокус.  
        pop iy
        pop hl
	ld l,a
        exx
        pop de
       _Loop_
