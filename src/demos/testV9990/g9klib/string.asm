		ifndef STRING_ASM
		define STRING_ASM
		
		MODULE String
                
;---------------------------------------------------------------------------------

;  input  HL = String 1
;         DE = String 2
;          B = Length string
;  output  nz = not equal  z=equal
StringCompare:
			LD	A,(DE)
			CP      A,(HL)
	                RET     NZ
	                INC     DE
	                INC     HL
	                DJNZ    StringCompare
	                RET             

		ENDMODULE
		
		endif
