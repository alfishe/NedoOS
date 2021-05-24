;cmp byte [si],n
CMPSIBYTE
	get
	next
	ld (CMPSIBYTE_n),a
	ld hl,(_SI)
	getmemDS
	ex af,af'
CMPSIBYTE_n=$+1
	cp 0
	ex af,af'
       _LoopC

;make ah zero
CBWer
	exx
	ld h,0
	exx
       _Loop_

;add di,cx
ADDDICX
	ld hl,(_DI)
	ld bc,(_CX)
	ex af,af'
	or a
	adc hl,bc
	ex af,af'
	ld (_DI),hl
       _Loop_

;cmp ax,nn
CMPAX
	getHL
	exx
	ld a,l ;al
	exx
	cmpc
       _Loop_

XORAXAX
	exx
	ex af,af'
	xor a
	ld h,a
	ld l,a ;CF=0
	ld d,a ;parity data ;the SF, ZF, and PF flags are set according to the result. The state of the AF flag is undefined. 
	ex af,af'
        ld e,0 ;OF=0
	exx
       _Loop_
XORCXCX
	ex af,af'
	xor a
	ld h,a
	ld l,a
        ld (_CX),hl
        exx
	ld d,a ;parity data
        ld e,0 ;OF=0
        exx
	ex af,af'
       _Loop_
XORDXDX
	ex af,af'
	xor a
	ld h,a
	ld l,a
        ld (_DX),hl
        exx
	ld d,a ;parity data
        ld e,0 ;OF=0
        exx
	ex af,af'
       _Loop_
XORBXBX
	ex af,af'
	xor a
	ld h,a
	ld l,a
        ld (_DX),hl
        exx
	ld d,a ;parity data
        ld e,0 ;OF=0
        exx
	ex af,af'
       _Loop_

ORAXAX
	exx
	ex af,af'
	ld a,h
	or l ;CF=0
	ld d,a ;parity data
        ld e,0 ;OF=0
	ex af,af'
	exx
       _Loop_

;neg ax
NEGAX
	exx
	ex af,af'
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a
	or l ;Z
	ex af,af'
        ld a,h
        xor l
	ld d,a ;parity data ;TODO другие флаги? The CF flag set to 0 if the source operand is 0; otherwise it is set to 1. The OF, SF, ZF, AF, and PF flags are set according to the result. 
	exx
       _Loop_

;add al,al
ADDALAL
        exx
	ex af,af'
        ld a,l
        add a,a
        ld l,a
	ld d,a ;parity data ;TODO другие флаги?
	ex af,af'
	exx
       _Loop_

;cmp al,n
CMPAL
	get
	next
	ld c,a
	exx
	ld a,l ;al
	exx
	cmpc
       _Loop_

;and al,0x1f
ANDAL
	get
	next
        exx
	ex af,af'
        and l ;al
        ld l,a
	ld d,a ;parity data ;TODO другие флаги?
	ex af,af'
	exx
       _Loop_

;add al,'0'
;sub al,'0'
;imul cx
;cwd ; Expand AX to DX:AX
;idiv cx             ; Signed division (DXAX/CX?)
;div cx
;mul cx
;cmp sp,stack-2
;add ax,max_length
;cmp ax,program+max_size
