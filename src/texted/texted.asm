        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

TSPACES_FILENAME_SZ=42;41
PRSTDIO=1
        if PRSTDIO
_COLOR=0x0007;0x07
_COLOR_RED=0x0107;0x17
        else
_COLOR=0x07
_COLOR_RED=0x17
        endif

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        call initstdio
        ld a,(stdiohgt)
        dec a
        ld (textedhgt),a
        ;ld e,6 ;textmode
        ;OS_SETGFX

        ;YIELD ;чтобы cmd мог доделать свои дела на экране
        
        ;ld e,COLOR
        ;OS_CLS
        
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
        jr z,noautoload
;command line = "texted <file to load>"
        ld (texted_filenameaddr),hl
        ex de,hl ;de=drive/path/file
        OS_OPENHANDLE
;b=new file handle

        ld hl,0
        ld de,0
nvview_load0 ;TODO сделать как в nvview
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
        add hl,bc
        jr nc,$+3
        inc de
        pop af ;NZ = bytes to read != bytes actually read

        pop bc

        ;or a
        jr z,nvview_load0
;dehl=true file size (for TRDOSFS)
        ld (filesize),hl
        ld (filesizeHSW),de
        
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

texted_build
        ;OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ;ld a,d
        ;ld (stdouthandle_wasatstart),a
        ;ld a,e
        ;ld (stdinhandle_wasatstart),a

;keep current path
        ld de,curpath
        OS_GETPATH ;DE = Pointer to MAXPATH_sz byte buffer ;out: DE = Filled in with whole path string (WITH DRIVE! Finished by slash only if root dir), HL = Pointer to start of last item
;new app, get pages for new app, load cmd with command line from cmdbuf
        call loadapp ;NZ=error ;e=id
;run cmd
        push de
        OS_RUNAPP
        pop de
;wait for finish
        WAITPID ;не должно быть, если команда была .bat!
       ;ld (lastresult),hl

;set current path
        ld de,curpath
        OS_CHDIR
        jp setredrawflag
        
loadapp
;set system path
        OS_SETSYSDRV
        ld de,tcmd
        OS_OPENHANDLE
        or a
         push af
        ld a,b
        ld (curhandle),a
         pop af
        ret nz ;jr nz,execcmd_error ;NC!
        
;set path for newapp
        ld de,curpath
        OS_CHDIR
        
        OS_NEWAPP ;на момент создания должна быть включена текущая директория!!!
        or a
        ret nz ;error ;NC!
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
       push bc ;b=id
        ld a,d
        SETPGC000
        push de
        push hl
        ld hl,cmdbuf
        ld de,0xc000+COMMANDLINE
        call strcopy
        pop hl
        pop de
        call readfile_pages_dehl
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
       pop de ;d=id
        ld e,d ;e=id
        xor a
        ret ;Z

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

readfile_pages_dehl
        ld a,d
        SETPGC000
        ld a,0xc100/256
        call cmd_loadpage
        ret nz
        ld a,e
        call cmd_loadfullpage
        ret nz
        ld a,h
        call cmd_loadfullpage
        ret nz
        ld a,l
cmd_loadfullpage
        SETPGC000
        ld a,0xc000/256
cmd_loadpage
;out: a=error, bc=bytes read
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
        call readcurhandle
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        ret

readcurhandle
curhandle=$+1
        ld b,0
        OS_READHANDLE
        ret

textedhgt
        db 0
curpath
        ds MAXPATH_sz
tcmd
        db "cmd.com",0
cmdbuf
        db "cmd build.bat",0

winquit
        dw 0x0a1f ;de=yx
        dw 0x0613 ;bc=hgt,wid
        db 3 ;next line
        db "Text not saved!",0
        db 3 ;next line
        db "     Quit?",0
        db 0 ;end of window

prword
;hl=num
        ld bc,prdwordbuf
        push bc
        call prword_hl_tobc ;bc'=buf
        pop de
        ld hl,5
        jp sendchars

        include "../_sdk/prdword.asm"
        include "textview.asm"
        include "text_mem.asm"

        include "../_sdk/textwindow.asm"
setdrawtablesneeded
getmarkedfiles
        ret
        include "../_sdk/texteditln.asm"

strdelch
;delete char at (hl-1), shift string left
;keeps ix
editcmd_bs0
        ld a,(hl)
        dec hl
        ld (hl),a
        inc hl
        inc hl
        or a
        jr nz,editcmd_bs0
        ret

strinsch
;insert char E at (hl), shift string right
;keeps ix
editcmd_ins0
        ld a,(hl)
        ld (hl),e
        ld e,a
        inc hl
        or a
        jr nz,editcmd_ins0
        ld (hl),a
        ret

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
	
	LABELSLIST "../../us/user.l",1
