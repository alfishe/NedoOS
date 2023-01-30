PLAYERSTART = 0x4000

	macro PLAYERHEADER
	dw playerinit
	dw playerdeinit
	dw musicload
	dw musicunload
	dw musicplay
	dw isfilesupported
	endm
