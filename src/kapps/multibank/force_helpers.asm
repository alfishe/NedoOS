; Pull common IAR helpers into multibank.com so every ovl link
; keeps the same 0100-7FFF layout (mbovl root-hash / check-addrs).
; When a bank starts calling new libc/OS symbols, EXTERN them here too.
	MODULE force_helpers
	PUBLIC force_helpers

	EXTERN ?L_ADDASG_L03
	EXTERN ?L_DEC_L03
	EXTERN ?L_S_SWITCH_L06
	EXTERN ?S_S_SWITCH_L06
	EXTERN ?S_V_SWITCH_L06
	EXTERN ?S_MUL_L02

	RSEG CODE
force_helpers:
	ld	hl,?L_ADDASG_L03
	ld	hl,?L_DEC_L03
	ld	hl,?L_S_SWITCH_L06
	ld	hl,?S_S_SWITCH_L06
	ld	hl,?S_V_SWITCH_L06
	ld	hl,?S_MUL_L02
	ret

	END
