
	MODULE CMDLIST
	PUBLIC cmdlist
	RSEG	CONST
cmdlist:
	defb 'open    '
	defb 'close   '
	defb 'quit    '
	defb 'dir     '
	defb 'mkdir   '
	defb 'delete  '
	defb 'cd      ',0x00
	
	END