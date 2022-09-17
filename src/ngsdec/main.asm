        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
        include "common.asm"
        include "gsports.asm"
        include "vs10xx.asm"

        org PROGSTART
begin
        ld sp,0x4000
        OS_HIDEFROMPARENT
        ld e,6 ;textmode
        OS_SETGFX

gsinit
        call gssoftreset
        call z,gshardreset              ;GS didn't reply, try hw reset
        jr nz,parsecommandline
;no GS
        ld hl,gsnotfoundstr
        call print_hl
        QUIT

parsecommandline
        ld hl,COMMANDLINE
        call skipword_hl
        call skipspaces_hl
        ld (filenameaddr),hl
        ld a,(hl)
        or a
        jp nz,uploadcode
        QUIT

uploadcode
        ld bc,GSDAT
        ld de,gscode_end-gscode
        ld hl,GSADDR
        out (c),e
        SC 0x14
        WC
        out (c),d
        WD
        out (c),l
        WD
        out (c),h
        WD
;start upload
        ld hl,gscode
uploadcodeloop
        outi
        WD
        dec de
        ld a,d
        or e
        jr nz,uploadcodeloop
;launch the code
        ld hl,GSADDR
        out (c),l
        SC 0x13
        WC
        out (c),h
        WD
;update screen
        call redraw
        YIELD
        YIELD
        YIELD
;load extension
        ld hl,(filenameaddr)
        call findlastdot ;out: de = after last dot or start
        ex de,hl
        ld d,(hl)
        inc hl
        ld e,(hl)
;get chip id
        SC CMDGETCHIPID
        WC
        WN
        GD
;check if the device can play it
        call isfiletypesupported
        ld hl,unsupportedfiletype
        jp nz,printerrorandexit
filenameaddr=$+1
        ld de,0
        call openstream_file
        or a
        ld hl,fileerrorstr
        jp nz,printerrorandexit
        ld bc,0
readfilechunk
        ld hl,0x8000
        ld de,hl
        add hl,bc
        ex de,hl
        sub hl,bc
;de = buffer address, hl = bytes to read
        push bc
        call readstream_file
;hl = actual size
        pop de
        add hl,de
        bit 7,h
        jr nz,startupload
;seek to the beginning
        push hl
        ld hl,0
        ld de,hl
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
        pop bc
        jr readfilechunk

startupload
        ld c,h
        ld b,l
        ld hl,0x8000
        jr checkifcanupload

uploaddataloop
        ld a,(hl)
        out (GSDAT),a
        WD
        inc hl
        djnz uploaddataloop
        dec c
        jr z,readfilechunk              ;done uploading current chunk
        bit 0,c
        jr z,uploaddataloop             ;poll GS once per 512 bytes
checkifcanupload
        SC CMDGETFREEBUFFERSPACE
        WC
        WN
        GD
        cp 6
        jr nc,uploaddataloop            ;keep uploading until we have less than 1024 free buffer space
;handle app input
        push hl
        push bc
        YIELDGETKEY
        push af
        cp key_redraw
        call z,redraw
        pop af
        pop bc
        pop hl
        cp key_esc
        jr nz,checkifcanupload
;exit player
        call closestream_file
        jr gsshutdown

filereaderror
        call closestream_file
printerrorandexit
        call print_hl
gsshutdown
        SC CMDRESTART
        QUIT

gshardreset
;out: zf=1 if got reply from GS, zf=0 otherwise
        ld a,C_GRST
        out (GSCTR),a                   ;hw reset
        YIELD
        YIELD
gssoftreset
        SC 0xf3                         ;GS reset
        ld b,0x30                       ;max spins
wcloop
        push bc
        YIELD
        YIELD
        pop bc
        dec b
        ret z                           ;zf=1 if out of spins
        in a,(GSCOM)
        rrca
        jr c,wcloop
        or 1                            ;zf=0
        ret

redraw
        ld e,7
        OS_CLS
        ld hl,(filenameaddr)
        jp print_hl

;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot

;de = first two character of file extension
;a = chip id
;out: zf=1 if codec can play it, zf=0 otherwise
isfiletypesupported
        ld hl,'mi'
        sub hl,de
        jr nz,checkogg
        cp SS_VER_VS1003
        ret z
        cp SS_VER_VS1033
        ret z
        cp SS_VER_VS1053
        ret z
        cp SS_VER_VS1103
        ret
checkogg
        ld hl,'og'
        sub hl,de
        jr nz,checkaac
        cp SS_VER_VS1053
        ret z
        cp SS_VER_VS1063
        ret        
checkaac
        ld hl,'aa'
        sub hl,de
        jr nz,checkmp3
        cp SS_VER_VS1033
        ret z
        cp SS_VER_VS1053
        ret z
        cp SS_VER_VS1063
        ret
checkmp3
        xor a                           ;I guess there's no point in checking mp3 support
        ret

prdigit
	sub 10
	jr c,$+4
	add 7
	add 0x3A
	PRCHAR
        ret

print_hl
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        inc hl
        jp print_hl
        ret

skipword_hl
	ld a,(hl)
	or a
	ret z
	cp ' '
	ret z
	inc hl
	jr skipword_hl

skipspaces_hl
	ld a,(hl)
	cp ' '
	ret nz
	inc hl
	jr skipspaces_hl

fileerrorstr
        db "Failed to read the file.\r\n",0
unsupportedfiletype
        db "Your codec can't play this media file.\r\n",0
gsnotfoundstr
        db "This program requires NeoGS.\r\n",0

gscode
        incbin gscode.bin
gscode_end

        include "../_sdk/stdio.asm"
        include "../_sdk/file.asm"
end
        savebin "ngsdec.com",begin,end-begin
