PANIC
	jr $

PUSHAX
        EXX
       push hl ;ax
        EXX
       pop bc
        putmemspBC
       _LoopC
PUSHCX
       ld bc,(_CX)
        putmemspBC
       _LoopC
PUSHDX
       ld bc,(_DX)
        putmemspBC
       _LoopC
PUSHBX
       ld bc,(_BX)
        putmemspBC
       _LoopC
PUSHSP
       decodeSP ;ld bc,(_SP)
        putmemspBC
       _LoopC
PUSHBP
       ld bc,(_BP)
        putmemspBC
       _LoopC
PUSHSI
       ld bc,(_SI)
        putmemspBC
       _LoopC
PUSHDI
       ld bc,(_DI)
        putmemspBC
       _LoopC
PUSHES
       ld bc,(_ES)
        putmemspBC
       _LoopC
PUSHCS
       ld bc,(_CS)
        putmemspBC
       _LoopC
PUSHSS
       ld bc,(_SS)
        putmemspBC
       _LoopC
PUSHDS
       ld bc,(_DS)
        putmemspBC
       _LoopC

POPAX
        getmemspBC
        PUSH BC
        EXX
       POP HL ;ax
        EXX
       _LoopC
POPCX
        getmemspBC
	ld (_CX),bc
       _LoopC
POPDX
        getmemspBC
	ld (_DX),bc
       _LoopC
POPBX
        getmemspBC
	ld (_BX),bc
       _LoopC
POPSP
        getmemspBC
	encodeSP
       _LoopC
POPBP
        getmemspBC
	ld (_BP),bc
       _LoopC
POPSI
        getmemspBC
	ld (_SI),bc
       _LoopC
POPDI
        getmemspBC
	ld (_DI),bc
       _LoopC
POPES
        getmemspBC
	ld (_ES),bc
	countES
       _LoopC
POPCS
        getmemspBC
	ld (_ES),bc
	countCS
       _LoopC
POPSS
        getmemspBC
	ld (_ES),bc
	countSS
       _LoopC
POPDS
        getmemspBC
	ld (_ES),bc
	countDS
       _LoopC

CLDer
	xor a
	ld (_CLD),a
       _Loop

MOVAX
	getHL
	push hl
	exx
	pop hl ;ax
	exx
       _Loop
MOVCX
	getHL
	ld (_CX),hl
       _Loop
MOVDX
	getHL
	ld (_DX),hl
       _Loop
MOVBX
	getHL
	ld (_BX),hl
       _Loop
MOVSP
	getHL
	encodeSP
       _Loop
MOVBP
	getHL
	ld (_BP),hl
       _Loop
MOVSI
	getHL
	ld (_SI),hl
       _Loop
MOVDI
	getHL
	ld (_DI),hl
       _Loop

MOVAL
	get
	next
	exx
	ld l,a ;al
	exx
       _Loop
MOVCL
	get
	next
	ld (_CL),a
       _Loop
MOVDL
	get
	next
	ld (_DL),a
       _Loop
MOVBL
	get
	next
	ld (_BL),a
       _Loop
MOVAH
	get
	next
	exx
	ld h,a ;ah
	exx
       _Loop
MOVCH
	get
	next
	ld (_CH),a
       _Loop
MOVDH
	get
	next
	ld (_DH),a
       _Loop
MOVBH
	get
	next
	ld (_BH),a
       _Loop

;mov byte [di],n
MOVDIBYTE
	get
	next
	ld hl,(_DI)
	putmemDS
       _LoopC

INCAX
	exx
	inchlwithflags
	exx
       _Loop
INCCX
	ld hl,(_CX)
	inchlwithflags
	ld (_CX),hl
       _Loop
INCDX
	ld hl,(_DX)
	inchlwithflags
	ld (_DX),hl
       _Loop
INCBX
	ld hl,(_BX)
	inchlwithflags
	ld (_BX),hl
       _Loop
INCSI
	ld hl,(_SI)
	inchlwithflags
	ld (_SI),hl
       _Loop
INCDI
	ld hl,(_DI)
	inchlwithflags
	ld (_DI),hl
       _Loop

DECAX
	exx
	dechlwithflags
	exx
       _Loop
DECCX
	ld hl,(_CX)
	dechlwithflags
	ld (_CX),hl
       _Loop
DECDX
	ld hl,(_DX)
	dechlwithflags
	ld (_DX),hl
       _Loop
DECBX
	ld hl,(_BX)
	dechlwithflags
	ld (_BX),hl
       _Loop
DECSI
	ld hl,(_SI)
	dechlwithflags
	ld (_SI),hl
       _Loop
DECDI
	ld hl,(_DI)
	dechlwithflags
	ld (_DI),hl
       _Loop

CALLer
        getHL
       CALCpc
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
JRYer
	ex af,af' ;'
JRer
	get
        next
        RLA
        SBC A,A
        LD H,A
       CALCpc
        ADD HL,DE
        ex de,hl ;new PC 
       _LoopC_JP

JPer
        getHL
        ex de,hl ;new PC ;TODO или это смещение?
       _LoopC_JP

;mov al,[di]
MOVALDI
	ld hl,(_DI)
	getmemDS
	exx
	ld l,a ;al
	exx
       _LoopC

;mov ah,[di]
MOVAHDI
	ld hl,(_DI)
	getmemDS
	exx
	ld h,a ;ah
	exx
       _LoopC

XCHGAXCX
	exx
	ld bc,(_CX)
	ld (_CX),hl
	ld h,b
	ld l,c
	exx
       _Loop_
XCHGAXDX
	exx
	ld bc,(_DX)
	ld (_DX),hl
	ld h,b
	ld l,c
	exx
       _Loop_
XCHGAXBX
	exx
	ld bc,(_BX)
	ld (_BX),hl
	ld h,b
	ld l,c
	exx
       _Loop_
XCHGAXSI
	exx
	ld bc,(_SI)
	ld (_SI),hl
	ld h,b
	ld l,c
	exx
       _Loop_

CMPSBer
	ld hl,(_SI)
	getmemDS
	exx
	ld a,l ;al
	exx
	cmphl
;TODO inc si?
       _LoopC

;rep cmpsb
REPCMPSBer
;TODO
       _LoopC

;jmp word [di]
JMPWORDDI
	ld hl,(_DI)
	getmemDS
	ld e,a
	ld hl,(_DI)
	inc hl
	getmemDS
	ld d,a ;new PC
       _LoopC_JP

LODSBer
	ld hl,(_SI)
        inc hl
        ld (_SI),hl
        dec hl
	getmemDS
	exx
	ld l,a ;al
	exx
;flags not affected
;dec cx не надо!
       _LoopC

STOSBer
	exx
	ld a,l ;al
	exx
	ld hl,(_DI)
        inc hl
        ld (_DI),hl
        dec hl
        putmemDS
;flags not affected
;dec cx не надо!
       _LoopC

;stosw               ; Save onto variable
;in al,0x40          ; Read timer counter 0 
;int 0x20 ;system
;int 0x16 ;ah=0: input key -> al

