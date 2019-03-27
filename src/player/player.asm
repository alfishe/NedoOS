	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

COLOR=7
module=0xc000
        
        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускатьс€ ниже #3b00! иначе возможна порча OS
        ld e,6 ;textmode
        OS_SETGFX
        
        ;ld e,COLOR
        ;OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
        ld (filenameaddr),hl
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld de,module;0xc000
        ld hl,0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        OS_READHANDLE
        pop bc

;B = file handle
        OS_CLOSEHANDLE
        
	ld a,(module)
	cp 'P' ;'P'/'V' for PT3
	ld a,%00100000 ;PT3
	jr z,$+4
	ld a,%00000010 ;PT2
	ld (SETUP),a
	
        ld hl,module
        call INIT
        
mainloopredraw
filenameaddr=$+1
        ld hl,0
        call prtext
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        
mainloop
        YIELD
	di ;TODO fix player
        call PLAY
	ei
        GET_KEY
        cp key_redraw
        jr z,mainloopredraw
        ;or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+2+1+2
        ;cp c ;keynolang==0?
        ;jr z,_1;1b;prwindow_waitkey_nokey
        cp csSpace
        jr nz,mainloop
        call MUTE
noautoload
        QUIT

        
skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

prtext
;out: hl=after terminator
prtext0
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        jp prtext0

        
oldtimer
        dw 0

        ;include "../_sdk/pt3play.i"
        include "PTSPLAY.ASM"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "player.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
