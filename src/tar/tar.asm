        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

COLOR=7
        
        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
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
        ;ld (filenameaddr),hl
;command line = "texted <file to load>"
        ;ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        call openstream_file
        or a
        jp nz,openerror

readtar0
        ld de,header
         xor a
         ld (de),a
        ld hl,0x200
        call readstream_file
        ld hl,header
        ld a,(hl)
        or a
        jp z,tarend
        ld de,filename
        call copyname83
        
        ld a,(header+0x09c) ;type (0=file, 5=dir)
        cp '5'
        jr nz,readtar_nodir
;убираем слеш в конце
        ld hl,filename
        push hl
        xor a
        ld b,-1
        cpir
        ld a,'/'
        dec hl ;на терминаторе
        dec hl ;перед терминатором
        sub (hl)
        jr nz,$+3
        ld (hl),a ;0
        pop de ;ld de,filename
        OS_MKDIR
        jr readtar0
readtar_nodir

        ld hl,0
        ld d,h
        ld e,l
        ld bc,header+0x07c ;size in octal (TODO size in bytes - найти пример)
readtar_getsize0
        ld a,(bc)
        inc bc
        sub '0'
        jr c,readtar_getsizeq
        dup 3
        add hl,hl
        rl e
        rl d
        edup
        adc a,l
        ld l,a
        ld a,h
        adc a,0
        ld h,a
        jr nc,$+3
        inc de
        jr readtar_getsize0
readtar_getsizeq
        
;dehl=size
        push de
        push hl
        call SAVECREATE
        pop hl
        pop de
readfile0
        ld a,d
        or e
        ld bc,0x4000
        call z,minhl_bc_tobc
;bc=save size
        ld a,b
        or c
        jr z,readfileq
        push de
        push hl
        push bc
         push bc ;save size
;0x200 -> 0x200
;0x201 -> 0x400
        dec bc
        ld a,b
        add a,2
        and 0xfe
        ld h,a ;0..1->2, 2..3->4
        ld de,0xc000
        ld l,e;0
;DE = Buffer address, HL = Number of bytes to read
        push de
        call readstream_file
;hl=actual size
        pop de
         pop hl ;save size
        call SAVE
        pop bc
        pop hl
        pop de
        or a
        sbc hl,bc
        jr nc,$+3
        dec de
        jr readfile0
readfileq
        call SAVECLOSE
        jp readtar0
tarend
        call closestream_file
noautoload
openerror
        QUIT

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
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

;hl = size to write
;de = addr
SAVE        ld a,(savefilehandle)
        ld b,a
        push iy
        OS_WRITEHANDLE
        pop iy
        ret

SAVECREATE
        push iy
        ld de,filename
        OS_CREATEHANDLE
;b=new file handle
        ld a,b
        ld (savefilehandle),a
        pop iy
        ret

SAVECLOSE
        push iy
savefilehandle=$+1
        ld b,0
        OS_CLOSEHANDLE
        pop iy
        ret

        
copyname83
;hl->de
copyname83_element
        ld b,8
copyname83_0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_ext
        ld (de),a
        inc de
        djnz copyname83_0
;8 chars of name copied, wait for dot or slash or terminator
copyname83_skipname0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr nz,copyname83_skipname0
copyname83_ext
        ld (de),a ;'.'
        inc de
        ld b,3
copyname83_ext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr z,copyname83_endelement
        cp '.'
        jr z,copyname83_skipext0
        ld (de),a
        inc de
        djnz copyname83_ext0
copyname83_skipext0
        ld a,(hl)
        inc hl
        or a
        jr z,copyname83_q
        cp '/'
        jr nz,copyname83_skipext0
copyname83_endelement
        ld (de),a ;'/'
        inc de
        jr copyname83_element
copyname83_q
        ld (de),a ;0
        ret
        
oldtimer
        dw 0
        
filename
        db "depkfile.fil"
        ds filename+256-$ ;для длинных имён
        
        include "../_sdk/file.asm"
        
cmd_end
header
        ;ds 512

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "tar.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
