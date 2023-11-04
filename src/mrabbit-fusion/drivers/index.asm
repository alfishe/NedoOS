    IFDEF UNO
    	include "uart-uno.asm"
    ENDIF

    IFDEF UNOUART
    	include "uart-uno.asm"
    ENDIF

    IFDEF MB03
    	include "uart-mb03.asm"
    ENDIF

    IFDEF AY
    	include "uart-ay.asm"
    ENDIF
	
    IFDEF ZW
    	include "uart-zxwifi.asm"
    ENDIF
	
	include "utils.asm"
   
	IFDEF NEDOOSATM
		include "uart-atm.asm"
	ENDIF

	IFDEF NEDOOSEVO
		include "uart-evo.asm"
    ENDIF
	
	IFDEF NEDONET
		include "nedowifi.asm"
	ELSE
		include "wifi.asm"
	ENDIF

    IFDEF NEDOOS
    	include "rtc-nos.asm"
    ENDIF

    IFDEF SMUCRTC
    	include "rtc-smuc.asm"
    ENDIF
	
	include "proxy.asm"
	include "memory.asm"
	include "general-sound.asm"
    