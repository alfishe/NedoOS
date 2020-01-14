        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

COLOR=7

        include "gsports.asm"
        
        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        ld e,6 ;textmode
        OS_SETGFX
        
        ;ld e,COLOR
        ;OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jp z,noautoload
        ld (filenameaddr),hl
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        call openstream_file
        or a
        jr nz,openerror

readmod0
        ld de,0xc000
        ld hl,0x4000
;DE = Buffer address, HL = Number of bytes to read
        push de
        call readstream_file
;hl=actual size
        ex (sp),hl ;hl=buffer address, (sp)=actual size
        
       ;SC 0x38 ;Load FX        SC 0x30 ;Load module        WC        SC 0xD1 ;Open Stream        WC        pop bc ;actual size
        ld a,b
        or c
        jr z,readmodqLDSMP0        LD A,(HL)        INC HL        OUT (GSDAT),A        WD        DEC BC        LD A,B        OR C        JR NZ,LDSMP0
        jr readmod0
readmodq
                SC 0xD2 ;Close Stream        WC
        call closestream_file
        LD A,1 ;mod        OUT (GSDAT),A        SC 0x31 ;play module        WC        
        
mainloopredraw
filenameaddr=$+1
        ld hl,0
        call prtext
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        
        if 1==0
mainloop
        YIELD
        GET_KEY
        cp key_redraw
        jr z,mainloopredraw
        cp key_esc
        jr nz,mainloop
        endif
        QUIT

openerror        
noautoload
        SC 0x32 ;stop module        WC        
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

        
;oldtimer
;        dw 0

        include "../_sdk/file.asm"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "modplay.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
