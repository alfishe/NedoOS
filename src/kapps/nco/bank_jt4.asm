; Jump table @8000 -- bank 04 view/edit/run + nvext.

	MODULE bank_jt4
	PUBLIC bank_jt4

	EXTERN r_action_view
	EXTERN r_action_edit
	EXTERN r_run_selected_file
	EXTERN r_nvext_load
	EXTERN r_nvext_find_handler

	RSEG CODE_RESIDENT
bank_jt4:
	JP	r_action_view
	JP	r_action_edit
	JP	r_run_selected_file
	JP	r_nvext_load
	JP	r_nvext_find_handler

	END
