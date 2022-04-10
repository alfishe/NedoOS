        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"


        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        
        ld hl,twinto866
mktwinto866_0
        ld e,(hl)
        ld d,t866towin/256
        ld a,l
        ld (de),a
        inc l
        jr nz,mktwinto866_0

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jp z,noautoload
;command line = "texted <file to load>"
        ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld hl,0
        ld d,h
        ld e,l
nvview_load0
        push bc
        push de
        push hl
        call reservepage
        pop hl
        pop de
        pop bc
        ret nz ;no memory

        push bc
        
        push de
        push hl
        ld de,0xc000
        ld hl,0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
       push hl ;hl=bytes to read
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l ;bc=bytes actually read
       pop hl ;hl=bytes to read
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        pop hl
        pop de

        ;push af ;NZ = bytes to read != bytes actually read
        add hl,bc ;keep Z
        jr nc,$+3
        inc de
        ;pop af ;NZ = bytes to read != bytes actually read

        pop bc
        jr z,nvview_load0
;dehl=true file size
        ld (filesize),hl
        ld (filesizeHSW),de
        
        OS_CLOSEHANDLE
        
        call getsize ;ahl
        ld b,a
       if CONVBACK
        ld d,t866towin/256
       else
        ld d,twinto866/256
       endif
        jr convloop_go
convloop0
        push hl
        ld a,b
        rl h
        rla
        rl h
        rla
        srl h
        scf
        rr h
        push bc
        ld c,a
        ld b,textpages/256
        ld a,(bc)
        SETPG8000
        pop bc
        ld e,(hl)
        ld a,(de)
        ld (hl),a
        pop hl
convloop_go
        ld a,h
        or l
        dec hl
        jr nz,convloop0
        ld a,b
        sub 1
        ld b,a
        jr nc,convloop0
        
;savefile
texted_filenameaddr=$+1
        ld de,0;defaultfilename
        OS_CREATEHANDLE
        or a
        jr nz,nosavefile ;ret nz
;b=new file handle
        push bc
        ld a,b
        ld (cmd_savepage_handle),a

        call getsize ;ahl
        ld bc,textpages+0
        ld e,a ;remaining HSW
        ld d,c;0
texted_save0
;a=page number in table (0..)
;hlde=remaining size
        push bc ;pg
        push hl ;remaining LSW
        push de ;remaining HSW
        ld a,h
        and 0xc0
        or d
        or e
        jr z,$+5 ;hl=remaining size
        ld hl,0x4000 ;hl=maxsize (if remaining >= 0x4000)
        ld a,(bc)
        SETPG8000
         push hl ;hl=pg size
;hl=size
cmd_savepage_handle=$+1
        ld b,0
        ld de,0x8000
;B = file handle, DE = Buffer address, HL = Number of bytes to write
        OS_WRITEHANDLE
;HL = Number of bytes actually written, A=error
         pop bc ;bc=pg size
        pop de ;remaining HSW
        pop hl ;remaining LSW
        or a
        sbc hl,bc
        jr nc,$+3
        dec de ;size = size-pgsize
        pop bc ;pg
        inc c
        ld a,h
        or l
        or d
        or e
        jr nz,texted_save0
        pop bc ;b=handle
        OS_CLOSEHANDLE
nosavefile
noautoload
        QUIT

getsize
        ld hl,(filesize)
        ld a,(filesizeHSW)
        ret


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

        include "text_mem.asm"

        display $
        align 256
twinto866
        incbin "winto866"
cmd_end
t866towin
        ds 256
        align 256
textpages
        ds 256
filesize
        dw 0
filesizeHSW
        dw 0
        

	display "Size ",/d,cmd_end-cmd_begin," bytes"

       if CONVBACK
	savebin "866towin.com",cmd_begin,cmd_end-cmd_begin
       else
	savebin "winto866.com",cmd_begin,cmd_end-cmd_begin
       endif

	LABELSLIST "../../us/user.l"
