    device	zxspectrum128
    IFDEF NEDOOS
        MODULE nos
            include "../_sdk/sysdefs.asm"
        ENDMODULE
        org nos.PROGSTART
    ELSE
        org 24576
    ENDIF
asmOrg:
    jp start
    include "vdp/index.asm"
    include "utils/index.asm"
    include "gopher/render/index.asm"
    include "dos/index.asm"
    include "gopher/engine/history/index.asm"
    include "gopher/engine/urlencoder.asm"
    include "gopher/engine/fetcher.asm"
    include "gopher/engine/media-processor.asm"
    include "gopher/gopher.asm"
    include "drivers/index.asm"
    IFNDEF NEDOOS
    include "player/vortex-processor.asm"
    include "screen/screen.asm"
	ELSE
    include "screen/nedoscreen.asm"
    include "player/vortexnedoos.asm"
    ENDIF
start:
    di
    IFNDEF NEDOOS
        ld sp, asmOrg
    ELSE
        ld sp, 0x4000
    ENDIF
    ei
    call TextMode.init
    IFNDEF NEDOOS
		ld hl, initing : call TextMode.printZ
        call Wifi.init
    ENDIF
    call History.home
    jr $

outputBuffer:
initing db "Initing Wifi...",13,0

    display "ENDS: ", $
    display "Buff size", #ffff - $
    IFDEF NEDOOS
        savebin "moon.com", asmOrg, $ - asmOrg
    ELSE
        savebin "moon.bin", asmOrg, $ - asmOrg
    ENDIF
    