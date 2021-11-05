    IFDEF UNO
    include "uno-uart.asm"
    ENDIF

    IFDEF MB03
    include "mb03-uart.asm"
    ENDIF

    IFDEF AY
    include "ay-uart.asm"
    ENDIF
    
	include "utils.asm"
   
	IFDEF NEDOOSATM
		IFNDEF NEDOOSEVO
			include "atm-uart.asm"
			include "wifi.asm"
		ENDIF
	ENDIF

	IFDEF NEDOOSEVO
 	 	include "evo-uart.asm"
        include "wifi.asm"
	ENDIF

	
	IFDEF NEDOOS
		IFNDEF NEDOOSATM
			IFNDEF NEDOOSEVO
			include "nedowifi.asm"
			ENDIF
		ENDIF
        include "nedoos.asm"
    ELSE
        include "wifi.asm"
    ENDIF
    include "proxy.asm"
    include "memory.asm"
    include "general-sound.asm"
    