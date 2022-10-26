	IFNDEF NEDOOS
		IFDEF TRDOS
			include "trdos.asm"
    			include "console.asm"
    		ELSE
    			include "console.asm"
    			include "esxdos.asm"
			ENDIF	

	ELSE
    		include "nedoconsole.asm"
	ENDIF