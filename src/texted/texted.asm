        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

_COLOR=0x0007;7
TSPACES_FILENAME_SZ=41

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        call initstdio
        ;ld e,6 ;textmode
        ;OS_SETGFX

        ;YIELD ;чтобы cmd мог доделать свои дела на экране
        
        ;ld e,COLOR
        ;OS_CLS

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = "texted <file to load>"
        ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld hl,0
        ld de,0
nvview_load0
        push bc
        push de
        push hl
        call reservepage
        pop hl
        pop de
        pop bc
        ret nz ;no memory
        ;ld a,#c000/256
        ;call cmd_loadpage

        push bc
        
        push de
        push hl
        ld de,0xc000
        ld hl,0x4000
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        ld b,h
        ld c,l
        ld hl,0x4000
        or a
        sbc hl,bc ;NZ = bytes to read != bytes actually read
        pop hl
        pop de

        push af ;NZ = bytes to read != bytes actually read
        ex de,hl
        add hl,bc
        ex de,hl
        jr nc,$+3
        inc hl
        pop af ;NZ = bytes to read != bytes actually read

        pop bc

        ;or a
        jr z,nvview_load0
;hlde=true file size (for TRDOSFS)
        ld (filesize),de
        ld (filesizeHSW),hl
        
        OS_CLOSEHANDLE
        
        ;ld hl,text
        ;call prtext
noautoload
        ld hl,(texted_filenameaddr)
	ld de,tshown_filename
;copy hl->de no more than TSPACES_FILENAME_SZ bytes
	ld b,TSPACES_FILENAME_SZ
	call strcopy_maxb

        call textview
        QUIT

strcopy_maxb
;copy hl->de no more than b bytes
strcopy_maxb0
	ld a,(hl)
	or a
	ret z
	ld (de),a
	inc hl
	inc de
	djnz strcopy_maxb0
	ret

;out: hl=after terminator
        if 1==1
prtext
;hl=text
        push hl
        call strlen ;hl=length
        pop de ;de=text
        push de
        push hl
        call sendchars
        pop hl
        pop de
        add hl,de
        inc hl ;out: hl=after terminator
        ret

strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret
        else
prtext
prtext0
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR_
        pop hl
        jp prtext0
        endif
        
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

nv_setxy
;de=yx (kept)
;keeps hl
        push de
        push hl
        push ix
        SETXY_
        pop ix
        pop hl
        pop de
        ret
        
minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

        include "prdword.asm"
        include "textview.asm"
        include "text_mem.asm"
        include "../_sdk/stdio.asm"

filesize
        dw 0
filesizeHSW
        dw 0

defaultfilename
	db "1.txt",0
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "texted.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l"
