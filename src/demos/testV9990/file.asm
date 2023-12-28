	ifndef FILE_ASM
	define FILE_ASM
		
	MODULE File
		
FileOpen
	push ix,iy,hl,de
        OS_OPENHANDLE
	pop de,hl,iy,ix
	or a
	ret

FileRead
	push ix,iy,de,bc
        OS_READHANDLE
	pop bc,de,iy,ix
	xor a
	ret

FileClose
	push ix,iy,hl,de,bc
        OS_CLOSEHANDLE
	pop bc,de,hl,iy,ix
	ret

	ENDMODULE

	endif
