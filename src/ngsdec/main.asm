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
        ld e,7
        OS_CLS
;GS init
        call gssoftreset
        call z,gshardreset              ;GS didn't reply, try hw reset
        jr nz,uploadcode
;no GS
        ld hl,gsnotfoundstr
        jp printerror

uploadcode
        ld bc,GSDAT
        ld de,gscode_end-gscode
        ld hl,GSPROGSTART
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
        ld hl,GSPROGSTART
        out (c),l
        SC 0x13
        WC
        out (c),h
        WD
;the code is starting
        YIELD
        YIELD
        YIELD
;get chip id
        SC CMDGETCHIPID
        WC
        WN
        GD
        ld (vsversion),a
;open current folder in case we want to read it
        ld de,emptypath
        OS_OPENDIR
;check args
        ld hl,COMMANDLINE
        call skipword_hl
        call skipspaces_hl
        ld a,(hl)
        or a
        jr nz,gotinputfile
;look for a playable file
        call findnextsupportedfile
        ld hl,nofiletoplaystr
        jp nz,printerrorandclosegs
        ld (filenameaddr),de
        jr playfile

gotinputfile
        ld (filenameaddr),hl
        call isfiletypesupported
        ld hl,unsupportedfiletypestr
        jp nz,printerrorandclosegs
;switch to single file loop mode
        xor a
        ld (playmode),a
playfile
        call printfilename
filenameaddr=$+1
        ld de,emptypath
        call openstream_file
        or a
        ld hl,fileerrorstr
        jp nz,printerrorandclosegs
prefilledbuffersize=$+1
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
playmode=$+1
        jr findnextfile
        push hl
        ld hl,0
        ld de,hl
        ld a,(filehandle)
        ld b,a
        OS_SEEKHANDLE
        pop bc
        jr readfilechunk

findnextfile
        ld (prefilledbuffersize),hl
        call closestream_file
        call findnextsupportedfile
        jr z,foundnextfile
;reopen dir
        ld de,emptypath
        OS_OPENDIR
        call findnextsupportedfile
        ld hl,nofiletoplaystr
        jp nz,printerrorandclosegs
foundnextfile
        ld (filenameaddr),de
        jp playfile

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
        cp key_redraw
        jr nz,checkskipfile
        call redraw
        pop bc
        pop hl
        jr checkifcanupload

checkskipfile
        cp key_right
        jr nz,checkvolumeup
        SC CMDRESTARTSTREAM
        WC
        pop hl
        pop hl
        ld hl,0
        jp findnextfile

checkvolumeup
        pop bc
        pop hl
        cp key_up
        jr nz,checkvolumedown
        SC CMDVOLUMEUP
        WC        
        jr checkifcanupload

checkvolumedown
        cp key_down
        jr nz,checkexit
        SC CMDVOLUMEDOWN
        WC        
        jr checkifcanupload

checkexit
        cp key_esc
        jr nz,checkifcanupload
;exit player
        SC CMDRESTART
        call closestream_file
        QUIT

printerrorandclosegs
        SC CMDRESTART
printerror
        call print_hl
        ld hl,pressanykeystr
        call print_hl
        YIELDGETKEYLOOP
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
printfilename
        ld hl,(filenameaddr)
        call print_hl
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        ret

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

;hl = filename
;out: zf=1 if codec can play it, zf=0 otherwise
isfiletypesupported
        call findlastdot ;out: de = after last dot or start
        ex de,hl
        ld a,(hl)
        call tolower
        ld d,a
        inc hl
        ld a,(hl)
        call tolower
        ld e,a
vsversion=$+1
        ld a,255
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
        ld hl,'mp'
        sub hl,de
        ret                             ;I guess there's no point in checking mp3 support

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

tolower
        cp 'A'
        ret c
        cp 'Z'+1
        ret nc
        add 32
        ret

findnextsupportedfile
;out: zf=1 and de=filename if file was found, zf=0 otherwise
        ld de,filinfo
        OS_READDIR
        or a
        ret nz
        ld a,(filinfo+FILINFO_FATTRIB)
        and FATTRIB_DIR
        jr nz,findnextsupportedfile
        ld hl,filinfo+FILINFO_FNAME
        call isfiletypesupported
        jr nz,findnextsupportedfile
        ld de,filinfo+FILINFO_FNAME
        ld hl,filinfo+FILINFO_LNAME
        ld a,(hl)
        or a
        ret z
        ex de,hl
        xor a
        ret

nofiletoplaystr
        db "There are no supported files for playing in the current folder.\r\n",0
fileerrorstr
        db "Failed to read the file.\r\n",0
unsupportedfiletypestr
        db "Your codec can't play this media file.\r\n",0
gsnotfoundstr
        db "This program requires NeoGS.\r\n",0
pressanykeystr
        db "Press any key to exit...\r\n",0

filinfo
        ds FILINFO_sz
emptypath
        db 0

gscode
        incbin gscode.bin
gscode_end

        include "../_sdk/file.asm"
end
        savebin "ngsdec.com",begin,end-begin
