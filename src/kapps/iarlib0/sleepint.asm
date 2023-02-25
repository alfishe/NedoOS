	MODULE sleepint
	PUBLIC sleepint
//	#include "sysdefs.asm"
	RSEG CODE
sleepint:	;de=sleep numbers of int

	halt 
    dec de
    ld a,d
    or e
    jp nz, sleepint
    ret

	ENDMOD

	END
