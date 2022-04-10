        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

MAXCMDSZ=COMMANDLINE_sz-1;127 ;не считая терминатора

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS
        OS_HIDEFROMPARENT

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        push hl
        OS_DELPAGE
        pop hl
        push hl
        ld e,h
        OS_DELPAGE
        pop hl
        ld e,l
        OS_DELPAGE

        ld hl,COMMANDLINE ;command line
;command line = "print <file>"
        ld de,wordbuf
        call getword
        call skipspaces
        ld de,wordbuf
        push de
        call getword
        pop de
        OS_OPENHANDLE
        or a
        jr nz,errorquit
        push bc
        ld a,b
        ld (filehandle),a
         ld a,0x3c ;"inc a"
         ld (readbyte_readbuf_last),a
        ld iy,file_buf_end
        call readandprint
        pop bc
        OS_CLOSEHANDLE
       ld hl,0
        QUIT
errorquit
       ld l,a
       ld h,0
        QUIT

getword
;hl=string
;de=wordbuf
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        jr z,getwordq
        sub ' '
        jr z,getwordq
        ldi
        jp getword0
getwordq
        ;xor a
        ld (de),a
        ret

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

        macro READBYTE_A
;out: z=EOF
        inc ly
        call m,readbyte_readbuf
        ld a,(iy)
        endm

readandprint
        call LPINIT
readandprint0
        READBYTE_A ;z=EOF
        jr z,readandprintEOF
        call LPRINT
        jr nc,readandprint0
;error (break)
readandprintEOF
;EOF
        ret

readbyte_readbuf
;out: z=EOF
        push bc
        push de
        push hl
        push ix
        xor a
readbyte_readbuf_last=$
        inc a ;/nop(z)=last, inc a(nz)=not last
        jr z,readbyte_readbufq

;B = file handle, DE = Buffer address, HL = Number of bytes to read
filehandle=$+1
        ld b,0
        ld de,file_buf
        push de
        ld hl,128
        OS_READHANDLE
        pop iy
;HL = Number of bytes actually read, A=error
        ld a,l
        or a
        jr z,readbyte_readbufq ;0 bytes (=>EOF)
        jp m,readbyte_readbufq ;128 bytes (NZ no EOF) (not last block)
        
;last block: shift data to the end of buf, mark last
	ld c,a ;1..128
	ld b,0 ;nz!
        ld a,b
        ld (readbyte_readbuf_last),a ;last block
        ld hl,file_buf
        add hl,bc
        dec hl ;end of data
	ld de,file_buf+127
	lddr
        inc de
        push de
        pop iy
        ;nz!
readbyte_readbufq
;iy=addr
;z=EOF
        pop ix
        pop hl
        pop de
        pop bc
        ret

;------------------------------------ driver for ZX Evo by DDp
LPRINT
;a=char
;out: CY=error
        push af
        ld bc,0xfffd
        ld a,14
        out (c),a
        ld b,0xbf
        pop af
        out (c),a
        ld b,0xff
        ld a,15
        out (c),a
LPRIN1
        ld a,0xfe
        in a,(0xfe)
        rra
        jr c,LPRINT_nobreak
        ld a,0x7f
        in a,(0xfe)
        rra
        jr nc,LPRIN2 ;break (system keyboard is not available for background programs; anyway, user can "kill" the print process)
LPRINT_nobreak
        in a,(c)
        rla
        jr nc,LPRIN1 ;wait for printer READY
        
        ld a,7
        out (c),a
        ld b,0xbf
        ld a,0xff
        out (c),a
        push ix
        pop ix
        push ix
        pop ix ;pause
        ld a,0x7f
        out (c),a
        xor a
        ret
LPRIN2
        scf
        ret

LPINIT
        ld bc,0xfffd
        ld a,7
        out (c),a
        ld b,0xbf
        ld a,0x7f
        out (c),a
        ld b,0xff
        ld a,15
        out (c),a
        ld b,0xbf
        xor a
        out (c),a
        ld hl,STRINIT
LPINI1
        ld a,(hl)
        cp 0xff
        ret z
        call LPRINT
        inc hl
        jr LPINI1
STRINIT
        db 0x1b,"@",0xff

cmd_end

wordbuf
        ds MAXCMDSZ+1

        align 256
file_buf
        ds 128 ;buf for reading .bat
file_buf_end=$-1


	savebin "print.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "..\..\us\user.l"
