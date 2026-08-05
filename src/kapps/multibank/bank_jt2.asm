; Jump table @8000 ? bank 02 only (add r_* via mbgen here, not bank_jt.asm).

	MODULE bank_jt2
	PUBLIC bank_jt2

	EXTERN r_bank_entry

	RSEG CODE_RESIDENT
bank_jt2:
	JP	r_bank_entry

	END
