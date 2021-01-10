	device pentagon1024

	include "target.asm"

	org #4000
begin
	jp ayfx.INIT		;#4000
	jp ayfx.PLAY		;#4003
	jp ayfx.FRAME		;#4006
	jp pt3player.INIT	;#4009
	jp pt3player.PLAY	;#400c
	jp pt3player.MUTE	;#400f ;NEW for TFM
TURBOFMON db 0			;#4012 ;NEW for TFM
	
	ifdef TFM
		include "tfmplay.asm"
	else
	ifdef WYZ
BUFFER_DEC=#6000 ;place for decoding channel data
		include "wyzplay.asm"
	else
		include "pt3play.asm"
	endif
	endif
	include "ayfxplay.asm"

end

	display "Top: ",/h,$
	savebin "sound.bin",begin,end-begin