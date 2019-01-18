_JPHL__
	BX R1

;R1 >> R2
;out: R1
_SHR__
_SHRB__
	PUSH {LR}
	ASRS R1,R2
	POP {PC}

;R1 << R2
;out: R1
_SHL__
	PUSH {LR}
	LSLS R1,R2
	POP {PC}

;R1 << R2
;out: R1
_SHLB__
	PUSH {LR}
	LSLS R1,R2
	ANDS R1,R7 ;0xff
	POP {PC}
