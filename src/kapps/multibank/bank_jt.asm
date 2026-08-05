; Jump table @8000 ? bank 01.
; Linked BEFORE codebank_01. Each bank has its own bank_jtN.asm.

	MODULE bank_jt
	PUBLIC bank_jt

	EXTERN r_bank_entry

	RSEG CODE_RESIDENT
bank_jt:
	JP	r_bank_entry

	END
