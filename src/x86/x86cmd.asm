PANIC
	jr $

incdec2si_hl
incdec2di_hl
        inc hl
incdecsi_hl
incdecdi_hl
        inc hl
        ret

EXTer
;0f 31 = rdtsc eax edx
;0f b6 d0 = movzx dx,al (move with zero-extend)
;0f b6 c2 = movzx ax,dl (move with zero-extend)
;0F DA  r P3+     PMINUB mm mm/m64   sse1      Minimum of Packed Unsigned Byte Integers (for pixeltwn)
;0F 82   03+     JB rel16/32     .......c     Jump near if below/not above or equal/carry (CF=1) ;TODO (for pixeltwn)
;0F AF C3 imul ax,bx (for megapole)
;0F 85 (6B FF) jnz rel16 (for megapole)
;0F 45 C1 CMOVNZ ax,cx (for megapole) Conditional Move - not zero/not equal (ZF=0)
;JNAE rel16/32    
;JC rel16/32 

;TODO прочие адресации
        get
        next
       cp 0x31
       jr z,RDTSCer
       cp 0x45
       jr z,CMOVNZer
       cp 0x85
       jp z,JNZrel16
       cp 0xaf
       jr z,IMULr1r2
       cp 0xda
       jr z,PMINUBer
       cp 0xb6
       jr nz,$
        get
        next
       cp 0xc2
       jr z,MOVZXaxdl
       cp 0xd0
       jr nz,$
        ld hl,(_AL)
        ld h,0
        ld (_DX),hl
       _Loop_
       
CMOVNZer
;CMOVNZ ax,cx - Conditional Move - not zero/not equal (ZF=0)
        ex af,af' ;'
        jr z,CMOVnzer_no
        ld hl,(_CX)
        ld (_AX),hl
CMOVnzer_no
        ex af,af' ;'
       _Loop_

IMULr1r2
        get
        next
       push de
        ld bc,(_BX) ;TODO other regs
	ld de,(_AX);ex de,hl ;de=ax ;TODO other regs
        call IMUL_bc_de_to_hlde
	;ld (_DX),hl ;HSW
        ld (_AX),de ;LSW
       pop de
       _Loop_
       
MOVZXaxdl
        ld hl,(_DL)
        ld h,0
        ld (_AX),hl
       _Loop_
       
PMINUBer
;не уверен, что такое поведение - TODO
        ld hl,(_AX)
        ld a,l
        cp h
        jr c,$+3
        ld l,h
        ld h,0
        ld (_AX),hl
       _Loop_

RDTSCer
;костыль для para512
        ld a,r
        ld l,a
        ld h,a
        ld (_AX),hl
       _Loop_

JNZrel16
	ex af,af' ;'
	jr nz,JRrel16y
	ex af,af' ;'
        next
        next
       _Loop_ 
JRrel16y
	ex af,af' ;'
	get
        next
        ld l,a
	get
        next
        LD H,A
       decodePC ;a=d
        ADD HL,DE
       ;ld a,d
       xor h
       and 0xc0
        ex de,hl ;new PC 
       jr z,JRrel16_qslow
       _LoopC_JPoldpg
JRrel16_qslow
       _LoopC_JP

;на входе в команду:
;без сегментного префикса: b=l(адрес обработчика)
;с сегментным префиксом: b=?s_LSW+1(нечётный)
;все обработчики rm-команд (и вообще команд с подменой сегмента) по чётному адресу
DSer
        ld b,1+(ds_LSW&0xff)
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
        ld b,1+(cs_LSW&0xff)
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
        ld b,1+(es_LSW&0xff)
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
        ld b,1+(ss_LSW&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 
FSer
        ld b,1+(fs_LSW&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 
GSer
        ld b,1+(gs_LSW&0xff)
        get
        next
	LD L,A
        ld H,MAINCOMS/256
        LD a,(HL)
        INC H
        LD H,(HL)
        ld L,a
        JP (HL) 

getflags_bc
        ex af,af' ;'
        push af
        ex af,af' ;'
        pop bc 
;b=%SZ?H???C
        res 5,b
        res 3,b
        set 1,b
        exx
        ld a,d ;parity data
        exx
        or a
        res 2,b
        jp pe,$+5 ;или инверсно?
        set 2,b
;b=%SZ0A0P1C
;b=%SF:ZF:0:AF:0:PF:1:CF
        ret

makeflags_frombc
;b=%SF:ZF:0:AF:0:PF:1:CF
        push bc
        ex af,af' ;'
        pop af
        ex af,af' ;'
        ld a,b
        and 2
        exx
        ld d,a ;parity data ;или инверсно?
        exx
        ret

SAHFer
;store AH into flags
        ld bc,(_AX)
        call makeflags_frombc
       _Loop_

LAHFer
;Load Status Flags into AH Register
        call getflags_bc
        ld a,b
        ld (_AH),a
       _Loop_

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
        ld a,0x23 ;"inc hl"
        ld (incdec2si_hl),a
        ld (incdecsi_hl),a
NOPer
       _Loop_

STDer
	ld a,-1
	ld (_DIRECTION),a
        ld a,0x2b ;"dec hl"
        ld (incdec2si_hl),a
        ld (incdecsi_hl),a
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

PUSHAer
        ld hl,_AX
        ld b,12
_PUSHAer0
        push bc
        ld c,(hl)
        inc l
        ld b,(hl)
        inc l
        push hl
        putmemspBC
        pop hl
        pop bc
        djnz _PUSHAer0
;TODO flags
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
PUSHFer
       call getflags_bc
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

POPAer
        ld hl,_AX+(12*2)
        ld b,12
_POPAer0
        push bc
        push hl
        getmemspBC
        pop hl
        dec l
        ld (hl),b
        dec l
        ld (hl),c
        pop bc
        djnz _POPAer0
;TODO recode segments
;TODO flags
       _Loop_

POPFer
        getmemspBC
        call makeflags_frombc
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
       ld lx,c;push bc
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld a,(_AL)
	ld (hl),a
       ld c,lx;pop bc
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC

;mov [addr],ax
        ALIGNrm
MOVmemax
	getHL
        call ADDRm16_pp_ds_nodisp ;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
       ld lx,c;push bc
         ld b,tpgs/256
         ld a,(bc)
	SETPGC000
        ld bc,(_AX)
       _PUTm16LoopC_oldpg

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
       ld lx,c
       ;push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       ;pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment_pglx
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
        pop de
RETFq
        ld (_CS),bc
        countCS
       _LoopJP

RETer
        getmemspBC
        LD D,B
        ld E,C ;new PC
       _LoopC_JP

RETFer
        getmemspBC
       push bc
        getmemspBC
        LD D,B
        ld E,C ;new PC
       pop bc
        jp RETFq

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
	JR nz,JRYer
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
       decodePC ;a=d
        ADD HL,DE
       ;ld a,d
       xor h
       and 0xc0
        ex de,hl ;new PC 
       jr z,JRer_qslow
       _LoopC_JPoldpg
JRer_qslow
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
JCXZer ;jump if CX != 0
	ld hl,(_CX)
	ld a,h
	or l
	JR nz,JRer
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

       macro INCDECSIbyDIRECTION
	ld hl,(_SI)
        call incdecsi_hl
	ld (_SI),hl
       endm
       macro INCDECDIbyDIRECTION
	ld hl,(_DI)
        call incdecdi_hl
	ld (_DI),hl
       endm
       macro INCDECSI_DIbyDIRECTION
	ld hl,(_SI)
        call incdecsi_hl
	ld (_SI),hl
	ld hl,(_DI)
        call incdecdi_hl
	ld (_DI),hl
       endm
       macro INCDEC2SIbyDIRECTION
	ld hl,(_SI)
        call incdec2si_hl
	ld (_SI),hl
       endm
       macro INCDEC2DIbyDIRECTION
	ld hl,(_DI)
        call incdec2di_hl
	ld (_DI),hl
       endm
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
	cp 0xaa
	jp z,REPSTOSBer
	;cp 0xab
	;jp z,REPSTOSWer
	cp 0xae
	jp z,REPSCASBer
	;cp 0xaf
	;jp z,REPSCASWer
	jp PANIC

MOVSBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld hl,(_DI)
	putmemES
        INCDECSI_DIbyDIRECTION
       _LoopC

;rep movsb
REPMOVSBer
;костыль: если cx=0, то сразу выходим (а не 65536 повторов)
       ;ld hl,(_CX)
       ;ld a,h
       ;or l
       ;jr z,REPMOVSBerq
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld hl,(_DI)
	putmemES
        INCDECSI_DIbyDIRECTION
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ld a,h
	or l
	jr nz,REP_repeat
REPMOVSBerq
       _LoopC

REPSTOSBer
;костыль: если cx=0, то сразу выходим (а не 65536 повторов)
       ld hl,(_CX)
       ld a,h
       or l
       jr z,REPSTOSBerq
	ld a,(_AL) ;al
	ld hl,(_DI)
        putmemES
        INCDECDIbyDIRECTION
;flags not affected
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ld a,h
	or l
	jr nz,REP_repeat
REPSTOSBerq
       _LoopC

REP_repeat ;TODO speedup!!!
       decodePC
        dec de
        dec de ;new PC 
       _LoopC_JP
;repz cmpsb
REPCMPSBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ex af,af' ;'
	ld hl,(_DI)
	getmemES
	ex af,af' ;'
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
        INCDECSI_DIbyDIRECTION
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ex af,af' ;'
	jr nz,exaLoopC
	ex af,af' ;'
	ld a,h
	or l
	jp nz,REP_repeat
       _LoopC
;repnz scasb
REPSCASBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld a,(_AL) ;al
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
        INCDECSIbyDIRECTION
	ld hl,(_CX)
	dec hl
	ld (_CX),hl
	ex af,af' ;'
	jr z,exaLoopC
	ex af,af' ;'
	ld a,h
	or l
	jp nz,REP_repeat
       _LoopC
exaLoopC
	ex af,af' ;'
       _LoopC

SCASBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld a,(_AL) ;al
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
        INCDECSIbyDIRECTION
       _LoopC

CMPSBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ex af,af' ;'
	ld hl,(_DI)
	getmemES
	ex af,af' ;'
	sub (hl)
        KEEPCFPARITYOVERFLOW_FROMA
        INCDECSI_DIbyDIRECTION
       _LoopC

LODSBer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld (_AL),a ;al
        INCDECSIbyDIRECTION
;flags not affected
;dec cx не надо!
       _LoopC

LODSWer
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld (_AL),a ;al
	ld hl,(_SI)
	inc hl
	getmemDS ;TODO подмена сегмента
	ld (_AH),a ;ah
LODSWerincq
        INCDEC2SIbyDIRECTION
;flags not affected
;dec cx не надо!
       _LoopC

OPSIZEr
;костыль для para512
        get
        next
;for lodsd
	ld hl,(_SI)
	getmemDS ;TODO подмена сегмента
	ld (_AL),a ;al
	ld hl,(_SI)
	inc hl
	getmemDS ;TODO подмена сегмента
	ld (_AH),a ;ah
       jr LODSWerincq

STOSBer
	ld a,(_AL) ;al
	ld hl,(_DI)
        putmemES
        INCDECDIbyDIRECTION
;flags not affected
;dec cx не надо!
       _LoopC

STOSWer
	ld a,(_AL) ;al
	ld hl,(_DI)
        putmemES
	ld a,(_AH) ;ah
	ld hl,(_DI)
	inc hl
        putmemES ;TODO speedup
        INCDEC2DIbyDIRECTION
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
	cp 0x1a
	jr z,INT_gettimer
        cp 0x21
        jr z,INT21
        cp 0x80
        jr nc,intlooper ;костыль для megapole
       jr $
intlooper
       _Loop_

INT_gettimer
;int 1Ah ;AL= 24 hours overflow flag, CX:DX = 32bit timer
_microtimer=$+1
        ld hl,0
        inc hl
        ld (_microtimer),hl
        ld (_DX),a
       _Loop_

INT10
        ld a,(_AH)
        or a
        jr z,INT_setgfx
        cp 0x0e
        jr z,INT_printal
       jr $

INT21
        ld a,(_AH)
        cp 0x09
        jr z,INT_printstringdx

;        mov     ax,ds                   ;deallocate all but 128k mem
;        mov     es,ax
;        mov     ah,4Ah
;        mov     bx,2000h ;size 128k
;        int     21h

;        mov     ah,35h                  ;get and save old int 09h vector
;        mov     al,09h
;        int     21h
;        mov     word ptr old_int9[0],bx
;        mov     word ptr old_int9[2],es

;set new int 09h vector
;        push    cs
;        pop     ds
;        mov     dx,offset key_int
;        mov     ah,25h
;        mov     al,09h
;        int     21h

;        mov     ah,48h                  ;allocate       starbuf
;        mov     bx,1000h                ;64k
;        int     21h
;        mov     es,ax

;        mov     ah,0                    ;init random seed
;        int     1Ah                     ; to timer
;        mov     word ptr r3[0],dx       ;
;        mov     word ptr r3[2],cx       ;


;        mov     ah,2                    ;scoreboard
;        mov     bh,0
;        mov     dh,24
;        mov     dl,0
;        int     10h ;???
;        mov     dx,offset fuelS
;        mov     ah,9
;        int     21h

       jr $
INT_printstringdx
;TODO
       _Loop_

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
