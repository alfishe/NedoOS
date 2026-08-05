; Jump table @8000 -- bank 03 file operations.

	MODULE bank_jt3
	PUBLIC bank_jt3

	EXTERN r_action_copy
	EXTERN r_action_delete
	EXTERN r_action_rename
	EXTERN r_action_mkdir
	EXTERN r_action_move

	RSEG CODE_RESIDENT
bank_jt3:
	JP	r_action_copy
	JP	r_action_delete
	JP	r_action_rename
	JP	r_action_mkdir
	JP	r_action_move

	END
