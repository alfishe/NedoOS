	NAME	CSTARTUP
	EXTERN	main_args,exit			; where to begin execution
	EXTERN	?C_EXIT,main			; where to go when program is done
	PUBLIC dbg_mon
	RSEG	CSTACK
	DEFS	0			; a bare minimum !
	RSEG	UDATA0
	RSEG	IDATA0
	RSEG	ECSTR
	RSEG	TEMP
	RSEG	DATA0
	RSEG	WCSTR
	RSEG	CDATA0
	RSEG	CCSTR
	RSEG	CONST
	RSEG	CSTR
	RSEG	DBGMON
dbg_mon
	DEFS 1
	ASEG
	ORG	0x0100
init_A
	LD	SP,.SFE.(CSTACK-1)	; from high to low address
	CALL	seg_init
	call 	main_args
	CALL	main			; non-banked call to main()
	JP	exit
	
	RSEG	RCODE
init_C
	
seg_init
	LD	HL,.SFE.(UDATA0)
	LD	DE,.SFB.(UDATA0)
	CALL	zero_mem
	LD	DE,.SFB.(IDATA0)		;destination address
	LD	HL,.SFE.(CDATA0)
	LD	BC,.SFB.(CDATA0)
	CALL	copy_mem
	LD	DE,.SFB.(ECSTR)			;destination address
	LD	HL,.SFE.(CCSTR)
	LD	BC,.SFB.(CCSTR)
copy_mem
	XOR	A
	SBC	HL,BC
	PUSH	BC
	LD	C,L
	LD	B,H				; BC - that many bytes
	POP	HL				; source address
	RET	Z				; If block size = 0 return now
	LDIR
	RET
zero_mem
	XOR	A
again	PUSH	HL
	SBC	HL,DE
	POP	HL
	RET	Z
	LD	(DE),A
	INC	DE
	JR	again
	COMMON	INTVEC
	ENDMOD	init_A
	
	MODULE	exit
	PUBLIC	exit
	PUBLIC	?C_EXIT
	RSEG	RCODE
?C_EXIT
exit	EQU	?C_EXIT
	jp 0x0000			; loop forever
	END