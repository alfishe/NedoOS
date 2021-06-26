	module GAME
init:
	call fadeOutFull
       if EGA
        call setEGA
       else
	call clearScreen
       endif
	call LEVEL.build 	
	; current HL for next call
	call OBJECTS.create
	ld a,SYSTEM.GAME_UPDATE
	ret
;-----------------------------------------------
update:
	BORDER 1
	call OBJECTS.draw
	BORDER 2
	push ix
	call POP_UP_INFO.show
	pop ix
	BORDER 3
	call CONTROL.update
	BORDER 4
	call OBJECTS.update
	BORDER 5
	call returnKey
	ld a,l
	or a
	ret nz 		; to main menu
	call rebuildLvl ;выбирает, на какую сцену выйти (при NZ)
	ret nz 		; rebuild level
; 	; check level passed
	call nextLevel
	ret z 		; next level
	ld a,(delta)
	inc a
	ld (delta),a
	BORDER 0
	ld a,SYSTEM.GAME_UPDATE 	; loop
	ret
;-----------------------------------------------
rebuildLvl:
	ld hl,rebuildLevel
	ld a,(hl)
	or a
	ret z
	;scf
	;ret
	;cp SYSTEM.SHOP_INIT
	;ret nz
	ld (hl),0 ;не ребилдим больше
	ld d,a
	ld a,(lives)
	or a
	ld a,SYSTEM.MAIN_MENU_INIT
	jr z,RETNZer;ret z
	;ld a,d
	;cp d
	;ret ;Z
        ld a,SYSTEM.SHOP_INIT
RETNZer
        cp -1
        ret ;NZ
; 	jr nextLevel + 3
nextLevel:
	ld a,(isLevelPassed)
	cp SYSTEM.SHOP_INIT
	ret nz
	ld c,a
	call POP_UP_INFO.isFinish
	cpl 
	ld a,c ;(isLevelPassed)
       if EGA
	ret nz
       push af
        call set6912
       pop af
       endif
        ret
;-----------------------------------------------
returnKey:		
	ld l,0
	call CONTROL.caps
	ret nz
	call CONTROL.enter
	ret nz
       if EGA
        call set6912
       endif
	ld hl,(lives)
	ld bc,#FFFF
	add hl,bc
	ld (lives),hl
	ld a,l
	or h
	ld l,SYSTEM.MAIN_MENU_INIT
	ret z
	ld l,SYSTEM.SHOP_INIT
	ret
;-----------------------------------------------
	endmodule
