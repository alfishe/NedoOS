        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
cmd_begin

        
        QUIT

cmd_end

	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "emptyapp.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../../us/user.l"
