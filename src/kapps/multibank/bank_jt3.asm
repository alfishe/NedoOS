; Jump table @8000 ? bank 03 only.

	MODULE bank_jt3
	PUBLIC bank_jt3

	EXTERN r_bank_entry

	RSEG CODE_RESIDENT
bank_jt3:
	JP	r_bank_entry

	END
