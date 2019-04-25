;TODO в батнике %0 (параметры запуска), %1 ...
;TODO %~dp0 (драйв и путь запуска)
;TODO %~t1 (дата-время 1-го параметра)
;TODO goto и метки :label
;TODO if ???==??? goto
;TODO for
;TODO PATH (где хранить? должна подгружаться при старте новой копии cmd)

        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
MAXCMDSZ=COMMANDLINE_sz-1;127 ;не считая терминатора
txtscrhgt=25
txtscrwid=80
CMDLINEY=24

COLOR=7
CURSORCOLOR=#38

        org PROGSTART
cmd_begin
        ld sp,#4000 ;не должен опускаться ниже #3b00! иначе возможна порча OS
        ld e,6 ;textmode
        OS_SETGFX
        ;ld e,COLOR
        ;OS_CLS
        
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
        ld de,wordbuf
        call getword
        call skipspaces
         ;jr cmd_interactive
        ld a,(hl)
        or a
        jr z,cmd_interactive
;command line = "cmd <command to run>"
        ld de,cmdbuf
        call strcopy
        
        ;ld hl,cmdbuf
        ;call prtext
        ;call prcrlf
        call makeprompt ;иначе запустится из неправильной директории
         ;jr cmd_interactive
        
        call execcmd ;can show errors ;a!=0: no such internal command
        or a
        call nz,strcpexec_tryrun ;запускает по фону
        YIELD ;чтобы запущенная задача успела захватить фокус ;???
;если командная строка была со словом autoexec.bat вместо слова cmd, то это начальный запуск autoexec.bat, из него надо входить в интерактивный режим
        ld a,(COMMANDLINE)
        cp 'a'
        jr z,cmd_interactive
        ;jr $
        QUIT
        
cmd_interactive
        
        ;OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ;ld a,e
        ;ld (curpgshapes),a
        ;ld a,h
        ;ld (curpgpal),a
        ;ld a,l
        ;ld (curpgtemp),a
;TODO free pages
        
        ;ld a,4;TR-DOS ;0=SD card (Z-controller)
        ;call cmdsetdrive
       
cmdmainloop
        call makeprompt
        call editcmd
        call prcrlf
        
        ld hl,cmdbuf
        ld de,oldcmd
        ld bc,MAXCMDSZ+1
        ldir
        
        call execcmd ;a!=0: no such internal command
        or a
        call nz,strcpexec_tryrun
        ld hl,cmdbuf
        ld (hl),0
        jp cmdmainloop

;;;;;;;;;;;;;;;;;;
prNNcmd
;a=NN
        ld c,10
        call prNcmd
        add a,'0'
        PRCHAR
        ret
prNcmd
;a=NN
;c=divisor
        ld b,'0'-1
        sub c
        inc b
        jr nc,$-2
        add a,c
        push af
        ld a,b
        PRCHAR
        pop af
        ret
        
editcmd_up
        ld de,cmdbuf
        ld hl,oldcmd
        ld bc,MAXCMDSZ+1
        ldir
        ;jp editcmd

editcmd
        ld hl,cmdbuf
        call strlen
        ld a,l
        ld (curcmdx),a
editcmd0
        call fixscroll_prcmd
        call cmdcalccurxy
        OS_SETXY
        ld e,CURSORCOLOR;#38
        OS_PRATTR ;нарисовать курсор
        YIELDGETKEYLOOP
         ;ld a,c ;keynolang
        push af
        call cmdcalccurxy
        OS_SETXY
        ld e,COLOR;7
        OS_PRATTR ;стереть курсор
        pop af
        cp Enter
        ret z
        cp cs7 ;up
        jr z,editcmd_up
         ld hl,editcmd0
         push hl
        ;ld hl,cmdbuf
        cp cs0 ;backspace
        jr z,editcmd_backspace
        cp cs5 ;left
        jr z,editcmd_left
        cp cs8 ;right
        jr z,editcmd_right
        cp ' '
        ret c ;jr c,editcmdok ;прочие системные кнопки не нужны
;type in
editcmdtypein
        ld e,a
        ld hl,cmdbuf
        call strlen ;hl=length
        ld bc,MAXCMDSZ
        or a
        sbc hl,bc
        ret nc ;jr nc,editcmdok ;некуда вводить
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc a
        ld (curcmdx),a
        jp strinsch ;e=ch
;editcmdok
        ;ret ;jp editcmd0
        
editcmd_backspace
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        ret z ;jr z,editcmdok ;нечего удалять
        dec a
        ld (curcmdx),a
        jp strdelch ;удаляет предыдущий символ
        ;jr editcmdok
      
editcmd_left
        ld a,(curcmdx)
        or a
        ret z ;jr z,editcmdok ;некуда влево
        dec a
        ld (curcmdx),a
        ret ;jr editcmdok
      
editcmd_right
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc (hl)
        dec (hl)
        ret z ;jr z,editcmdok ;некуда право, стоим на терминаторе
        inc a
        ld (curcmdx),a
        ret ;jr editcmdok

prtext
prtext0
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR ;testing (351/352t) (was 986/987t)
        pop hl
        inc hl
        jp prtext0

cmdprNchars
        push bc
        ld a,(hl)
        inc hl
        push hl
        PRCHAR
        pop hl
        pop bc
        djnz cmdprNchars
        ret
        
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

execcmd
;a=0: command executed
;a!=0: no such internal command
        ld hl,cmdbuf
        ld a,(hl)
        or a
        ret z
        
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld (execcmd_pars),hl
        ld hl,commandslist ;list of internal commands
strcpexec0
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld a,b
        cp -1
        ret z ;jr z,strcpexec_tryrun ;a!=0: no such internal command
        ld de,wordbuf
        push hl
        call strcp
        pop hl
        jr nz,strcpexec_fail
        ld h,b
        ld l,c
        call jphl ;execute command
        xor a
        ret ;a=0: command executed
jphl
        jp (hl) ;run internal command
strcpexec_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr strcpexec0

cmd_start
        ld hl,cmdbuf
        ld a,(hl)
        or a
        ret z
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld de,cmdbuf
        ld bc,MAXCMDSZ+1
        ldir
strcpexec_tryrun
;выполнить файл с именем cmdbuf и параметрами там
        call loadapp ;загрузить файл с именем cmdbuf, e=id, cy=end of .bat
        jr nz,execcmd_tryrunerror
execcmd_tryrunok
        ret c ;cy=end of .bat
        OS_RUNAPP
        ret

execcmd_tryrunerror
;выполнить файл с именем SYSDIR/cmdbuf и параметрами там
        ;call loadapp_keeppath
        OS_SETSYSDRV
        ld de,sysdir
        push de
        OS_GETPATH
        ;call loadapp_setoldpath ;TODO из prompt
        ;ld de,cmdprompt
        ;OS_CHDIR
        ;call makeprompt
        ;ld de,cmdprompt
        ;jr $
        ;OS_CHDIR
        pop hl
        push hl
;если в конце нет слеша, то добавим:
        ;ld bc,0 ;чтобы точно найти терминатор
        xor a
        ld b,a
        ld c,a;0
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        dec hl ;на терминаторе
        dec hl ;перед терминатором
        ld a,'/'
        cp (hl)
        jr z,$+2+5
         inc hl
         ld (hl),a
         inc hl
         ld (hl),0
        pop hl ;sysdir
        call strlen
        ld b,h
        ld c,l ;bc=SYSDIR_size
         push bc ;SYSDIR_size
        ld hl,MAXCMDSZ+1
        or a
        sbc hl,bc
        push hl ;MAXCMDSZ+1-SYSDIR_size
;bc=SYSDIR_size
        ld hl,cmdbuf+MAXCMDSZ;+1
        or a
        sbc hl,bc
        ld de,cmdbuf+MAXCMDSZ;+1
        pop bc ;MAXCMDSZ+1-SYSDIR_size
        lddr
        ld hl,sysdir
        ld de,cmdbuf
         pop bc ;SYSDIR_size
        ldir ;нельзя strcopy, т.к. не нужен терминатор
        call loadapp ;загрузить файл с именем cmdbuf, e=id, cy=end of .bat
        jr z,execcmd_tryrunok
execcmd_error
        ld hl,tunknowncommand
        jp cmderror
        
callcmd
;call command (cmdbuf) with waiting
        call execcmd ;a!=0: no such internal command
        or a
        ret z ;command executed
        call loadapp ;загрузить файл с именем cmdbuf, e=id
        jr nz,execcmd_error
        push de
        OS_RUNAPP
        pop de
        WAITPID
        ret

loadapp_keeppath
        ld hl,cmdprompt
        ld de,oldpath
        ld bc,MAXPATH_sz;MAXCMDSZ+1
        ldir ;TODO рекурсивно (для .bat)
        ret

loadapp_setoldpath
        push de
        ld de,oldpath ;TODO рекурсивно (для .bat)
        OS_CHDIR
        pop de
        xor a
        ret ;Z
        
loadapp
;out: nz=error, cy=end of .bat, or else e=id
        ld hl,cmdbuf
        ld de,wordbuf
        call getword
;учесть путь в имени (TODO использовать OS_OPENHANDLE)
        ld hl,wordbuf
        push hl
        call findlastslash. ;de=after last slash or beginning of path
        pop hl
        push de ;de=after last slash or beginning of path
        dec de
        ld a,(de)
        cp '/'
        jr nz,$+4
         xor a
         ld (de),a ;отрезать имя файла
        inc de
        ex de,hl;ld de,wordbuf ;ASCIIZ string for parsing (в #c000...)
        pop hl ;hl=after last slash
        jr nz,loadapp_nopath

        ;ld bc,loadapp_setoldpath
        ;push bc

        push hl ;hl=after last slash
        OS_CHDIR
        call loadapp_keeppath
        pop hl ;hl=after last slash
loadapp_nopath
        ex de,hl ;de=after last slash
        ;ld de,wordbuf ;ASCIIZ string for parsing (в #c000...)
        ld hl,fcb_filename ;Pointer to 11 byte buffer
        OS_PARSEFNAME
        
        ld hl,fcb_filename+8
        ld a,(hl)
        or 0x20
        cp 'b'
        jr z,strcpexec_tryrun_bat
        cp ' '
        jr nz,strcpexec_tryrun_noemptyext
        ld (hl),'c'
        inc hl
        ld (hl),'o'
        inc hl
        ld (hl),'m'
strcpexec_tryrun_noemptyext
        ld de,fcb
        OS_FOPEN
         push af
         call loadapp_setoldpath
         pop af
        or a
        ret nz ;jr nz,execcmd_error
        OS_NEWAPP ;на момент создания должна быть включена текущая директория!!!
        or a
        ret nz ;error
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id
        ld a,d
        SETPG32KHIGH
        push de
        push hl
        ld hl,cmdbuf
        ld de,#c000+COMMANDLINE
        ld bc,COMMANDLINE_sz
        ldir ;command line
        pop hl
        pop de
        call readfile_pages_dehl

        ld de,fcb
        OS_FCLOSE
        pop de
        ld e,d ;e=id
        xor a
        ret ;Z
        
strcpexec_tryrun_bat
;filename in fcb
;out: nz=error, cy=end of .bat
;open .bat
        ld hl,fcb_filename
        ld de,fcb_bat_filename
        ld bc,11
        ldir

        ld de,fcb_bat
        OS_FOPEN
        or a
        ret nz ;jp nz,execcmd_error
        
         ld a,0x3c ;"inc a"
         ld (readbyte_readbuf_last),a
        ld iy,file_buf_end
strcpexec_tryrun_bat0
;load line to cmdbuf
        ld hl,cmdbuf
        call readstr ;nz=EOF
        jr nz,strcpexec_tryrun_batq ;TODO последнюю строку всё-таки выполнить

        push iy
        ld hl,cmdbuf
        call prtext
        call prcrlf
        pop iy
        
;call command in cmdbuf
        push iy
        call callcmd
        pop iy
        jr strcpexec_tryrun_bat0
strcpexec_tryrun_batq
;close .bat
        ld de,fcb_bat
        OS_FCLOSE
        xor a
         scf ;чтобы на выходе не делать RUNAPP
        ret ;Z

        macro READBYTE_A
;out: z=EOF
        inc ly
        call m,readbyte_readbuf
        ld a,(iy)
        endm

readstr
;out: nz=EOF
;skips empty lines!
        READBYTE_A ;z=EOF
        jr z,readstrEOF
        cp 0x0d
        jr z,readstr ;empty string - retry
        cp 0x0a
        jr z,readstr ;empty string - retry
        ld b,MAXCMDSZ
        jr readstr0go
readstr0
        READBYTE_A ;z=EOF
        jr z,readstrEOF
        cp 0x0d
        jr z,readstrq
        cp 0x0a
        jr z,readstrq
readstr0go
        ld (hl),a
        inc hl
        djnz readstr0
readstrq
        xor a ;Z
        ld (hl),a
        inc hl
        ret ;Z
readstrEOF
        xor a
        ld (hl),a
        inc hl
        dec a
        ret ;NZ

readbyte_readbuf
;out: z=EOF
        push bc
        push de
        push hl
        push ix

        xor a
readbyte_readbuf_last=$ ;TODO keep if recursive!
        inc a ;/nop(z)=last, inc a(nz)=not last
        jr z,readbyte_readbufq
        
        ld de,file_buf
        push de
        OS_SETDTA ;set disk transfer address = de
        ld de,fcb_bat
        OS_FREAD
        pop iy
        xor 128 ;a = bytes read
        jr z,readbyte_readbufq
        jp m,readbyte_readbufq ;full block = not last block
;last block: shift data to the end of buf, mark last
	ld c,a ;1..128
	ld b,0 ;nz!
        ld a,b
        ld (readbyte_readbuf_last),a
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

readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,+(#c000+PROGSTART)/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,e
        SETPG32KHIGH
        ld a,#c000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,h
        SETPG32KHIGH
        ld a,#c000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,l
        SETPG32KHIGH
        ld a,#c000/256
        jp cmd_loadpage

cmd_dir
        ld de,fcb
        OS_SETDTA ;set disk transfer address = de
        ;call makeemptymask
        ld de,fcbmask
        OS_FSEARCHFIRST
        or a
        ld bc,0 ;nfiles
        jp nz,loaddir_error
loaddir0
        ld hl,fcb+FCB_FNAME
        ;ld a,(hl)
        ;cp ' ' 
        ;jp z,loaddirq
        push bc
        ld b,8
        call cmdprNchars
        ld a,(fcb+FCB_FATTRIB)
        and FATTRIB_DIR
        xor '.'
        push hl
        PRCHAR
        pop hl
        ld b,3
        call cmdprNchars
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        exx
        ld hl,(fcb+FCB_FSIZE+2)
        exx
        ld hl,(fcb+FCB_FSIZE)
        call prdword
        ld a,' '
        PRCHAR
        ld hl,(fcb+FCB_FDATE)
        call prdate
        ld a,' '
        PRCHAR
        ld hl,(fcb+FCB_FTIME)
        call prtime
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call prcrlf
        ld de,fcb
        OS_SETDTA ;set disk transfer address = de
         ;call makeemptymask ;в CP/M не нужно, но отсутствие вредит многозадачности
         ld de,fcbmask ;в CP/M не нужно, но отсутствие вредит многозадачности
        OS_FSEARCHNEXT
        pop bc ;nfiles
        inc bc ;nfiles
        or a
        jp z,loaddir0
loaddir_error
loaddirq
;bc=nfiles
        ld h,b
        ld l,c
        call prword
        ld hl,t_files_crlf
        jp prtext

prdate
        push hl
        ld a,h
        srl a
        sub 20
        jr nc,$+4
        add a,100 ;XX century
        call prNNcmd ;year
        ld a,'-'
        PRCHAR
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 0x0f
        call prNNcmd ;month
        ld a,'-'
        PRCHAR
        pop af
        and 0x1f
        jp prNNcmd ;day

prtime
        push hl
        ld a,h
        rra
        rra
        rra
        and 0x1f
        call prNNcmd ;hour
        ld a,':'
        PRCHAR
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 0x3f
        call prNNcmd ;minute
        ld a,':'
        PRCHAR
        pop af
        add a,a
        and 0x3f
        jp prNNcmd ;second

;makeemptymask
        ;ld hl,fcbmask_filename
        ;ld d,h
        ;ld e,l
        ;inc de
        ;ld bc,11-1
        ;ld (hl),'?'
        ;ldir
        ;ret
        
skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

strcopy
;hl->de
strcopy0
        ld a,(hl)
        ldi
        or a
        jr nz,strcopy0
        ret

cmd_cd
execcmd_pars=$+1
        ld hl,0
        ld a,(hl)
        or a
        jr z,cmd_error_nopars
        ex de,hl ;de=path
        OS_CHDIR
        or a
        ret z
        ld hl,twrongpath
        jp cmderror
        
cmd_error_nopars
        ld hl,tnopars
        jp cmderror
cmd_error_notenoughpars
        ld hl,tnotenoughpars
        jp cmderror

cmd_md
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jr z,cmd_error_nopars
        ex de,hl ;de=dirname
        OS_MKDIR
        or a
        ret z
cmd_error_cantmakedir
        ld hl,tcantmakedir
        jp cmderror
        
cmd_del
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jr z,cmd_error_nopars
        if 1==1
        ex de,hl
        OS_DELETE
        else ;CP/M-like
        ex de,hl
        ld hl,fcb_filename
        OS_PARSEFNAME
        ld de,fcb
        OS_FDEL
        endif
        or a
        ret z
cmd_error_wrongfile
        ld hl,twrongfile
        jp cmderror
        
cmd_ren
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jr z,cmd_error_nopars
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld a,(hl)
        or a
        jr z,cmd_error_notenoughpars
        ld de,wordbuf2
        call getword ;hl=terminator/space addr
        ld de,wordbuf
        ld hl,wordbuf2
        OS_RENAME
        or a
        ret z
        ld hl,tcantrename
        jp cmderror
        
cmd_copy
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jr z,cmd_error_nopars
        ld de,filenamebuf;wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld a,(hl)
        or a
        jr z,cmd_error_notenoughpars
        ld de,filenamebuf2;wordbuf2
        call getword ;hl=terminator/space addr

        if 1==1
        
        ld de,filenamebuf;wordbuf ;de=drive/path/file
        OS_OPENHANDLE
        or a
        jp nz,cmd_error_wrongfile
        ld a,b
        ld (close_file1_handle),a
        ld hl,close_file1
        push hl
        
        ld de,filenamebuf2;wordbuf2 ;de=drive/path/file
        OS_CREATEHANDLE
        or a
        jp nz,cmd_error_cant_copy
        ld a,b
        ld (cmd_copy_close_file2_handle),a
        ld hl,cmd_copy_close_file2
        push hl
cmd_copy0
        ld hl,copybuf_sz
        ld de,copybuf
        ld a,(close_file1_handle)
        ld b,a
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push de
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        pop de
        ld a,h
        or l
        ret z ;0 bytes remain
        ld a,(cmd_copy_close_file2_handle)
        ld b,a
;B = file handle, DE = Buffer address, HL = Number of bytes to write
        OS_WRITEHANDLE
        jr cmd_copy0
        
close_file1
close_file1_handle=$+1
        ld b,0
        OS_CLOSEHANDLE
        ret
        
cmd_copy_close_file2
cmd_copy_close_file2_handle=$+1
        ld b,0
        OS_CLOSEHANDLE
        ld de,filenamebuf;wordbuf;filenametext
        OS_GETFILETIME ;ix=date, hl=time
        ld de,filenamebuf2;wordbuf2
        OS_SETFILETIME
        ret
        
        else ;CP/M-like functions
        
        ld de,filenamebuf;wordbuf
        ld hl,fcb_filename
        OS_PARSEFNAME
        
        ld de,fcb
        OS_FOPEN
        or a
        jp nz,cmd_error_wrongfile
        ld hl,cmd_copy_close_fcb
        push hl
        
        ld de,filenamebuf2;wordbuf2
        ld hl,fcb2_filename
        OS_PARSEFNAME
        
        ld de,fcb2
        OS_FCREATE
        or a
        jp nz,cmd_error_cant_copy
        ld hl,cmd_copy_close_fcb2
        push hl
        
cmd_copy0
        ld de,copybuf
        OS_SETDTA
        ld de,fcb
        OS_FREAD
        cp 128
        ret z ;прочитали 0 байт
        xor 128
        ld l,a
        ld h,0
        push hl
        ld de,copybuf
        OS_SETDTA
        pop hl
        ld de,fcb2
        OS_FWRITE_NBYTES
        or a
        jr z,cmd_copy0
        ld hl,tcantwrite
        jp cmderror
        
cmd_copy_close_fcb2
        ld de,fcb2
        OS_FCLOSE
        ret

cmd_copy_close_fcb
        ld de,fcb
        OS_FCLOSE
        ret

        endif
        
cmd_error_cant_copy
        ld hl,tcantcopy
        jp cmderror
        
cmd_exit
        QUIT
        
cmd_rem
        ret
        
cmd_mem
        ld hl,tfree
        call prtext
        ld b,0
cmd_mem0
        push bc
        OS_NEWPAGE
        pop bc
        or a
        jr nz,cmd_mem_del
        inc b
        push de
        jr cmd_mem0
cmd_mem_del
        ld c,b
        inc b
        dec b
        jr z,cmd_mem_q
cmd_mem_del0
        pop de
        push bc
        OS_DELPAGE
        pop bc
        djnz cmd_mem_del0
cmd_mem_q
;c=free pages
        ld l,c
        ld h,0
        call prword
        jp prcrlf

cmd_drop
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        xor a
        ld d,a
cmd_drop_par0
        add a,d
        ld e,a ;id
        add a,a
        add a,a
        add a,e
        add a,a
        ld d,a ;d=e*10
        ld a,(hl)
        inc hl
        sub '0'
        cp 10
        jr c,cmd_drop_par0
        ;e=id
        OS_DROPAPP
        or a
        ret z
        ld hl,twrongid
        jp cmderror
        
cmd_proc
        ld e,1 ;no id 0
cmd_proc0
        push de
        OS_GETAPPMAINPAGES ;d,e,h,l=pages in 0000,4000,8000,c000, c=flags
        or a
        jr nz,cmd_proc_skip
        ld a,d
        pop de
        push de
         push bc
        push af
        ex de,hl
        ld h,0
        call prword
        ld a,' '
        PRCHAR
        pop af ;main page
        SETPG32KHIGH
         pop bc ;c=flags
         push bc
         bit factive,c
         ld a,'-'
         jr z,$+4
         ld a,'+'
         PRCHAR
         pop bc
         push bc
         bit fgfx,c
         ld a,' '
         jr z,$+4
         ld a,'g'
         PRCHAR
         pop bc
          bit fwaiting,c
          ld a,' '
          jr z,$+4
          ld a,'w'
          PRCHAR
         ld a,' '
         PRCHAR
        ld hl,0xc000+COMMANDLINE
        call prtext
        call prcrlf
cmd_proc_skip
        pop de
        inc e
        ld a,e
        inc a ;no id #ff
        jr nz,cmd_proc0
        ret

cmd_date
        OS_GETTIME ;ix=date, hl=time
        push hl
        push ix
        pop hl ;date
        call prdate
        ld a,' '
        PRCHAR
        pop hl ;time
        call prtime
        jp prcrlf
        
cmd_t0
cmd_t1
cmd_t2
cmd_t3
cmd_t4
cmd_t5
cmd_t6
cmd_t7
        ld a,(wordbuf)
        sub '0'
        call cmdsetdrive
        or a
        ret z
        ld hl,tdrivenotfound
        jp cmderror
        
cmderror
        push hl
        ld e,#42
        OS_SETCOLOR
        pop hl
        call prtext
        ld e,COLOR
        OS_SETCOLOR
prcrlf
        ld a,#0d
        PRCHAR
        ld a,#0a
        PRCHAR
        ret
        
cmdsetdrive
        ;ld (curdrive),a
        ld e,a
        OS_SETDRV
        ret

cmd_type
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        ld de,wordbuf
        call getword ;hl=terminator/space addr

        ld de,wordbuf ;de=drive/path/file
        OS_OPENHANDLE
        or a
        jp nz,cmd_error_wrongfile
        ld a,b
        ld (close_file1_handle),a
        ld hl,close_file1
        push hl
        
cmd_type0
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        ld de,cmd_type_buf
        ld hl,1
        OS_READHANDLE
;HL = Number of bytes actually read, A=error
        pop bc
        ld a,h
        or l
        ret z ;0 bytes remain
        push bc
cmd_type_buf=$+1
        ld a,0
        PRCHAR
        pop bc
        jr cmd_type0
        
cmd_echo
        ld hl,(execcmd_pars)
        call prtext
        jp prcrlf
        
cmd_pause
        YIELDGETKEYLOOP
         cp key_redraw
         jr z,cmd_pause
        ret

cmd_copydir
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld a,(hl)
        or a
        jp z,cmd_error_notenoughpars
        ld de,wordbuf2
        call getword ;hl=terminator/space addr

cmd_copydir_go
        ld hl,wordbuf
        call prtext
        ld a,'>'
        PRCHAR
        ld hl,wordbuf2
        call prtext
        call prcrlf
        
        ld de,wordbuf2
        OS_MKDIR

        ld bc,0 ;номер файла в директории
cmd_copydir0
        push bc
        ld de,cmdprompt
        OS_CHDIR
        ld de,wordbuf
        OS_CHDIR
        pop bc
        push bc
        call getdirfcb_bc
        pop bc
        ret nz ;jr nz,cmd_copydirq

        ld a,(fcb_filename)
        cp '.'
        jr z,cmd_copydir0_skip
        ld a,(fcb+FCB_FATTRIB)
        and FATTRIB_DIR
        jr nz,cmd_copydir0_recursive
        
        push bc
        ld hl,fcb_filename
        ld de,filenamebuf
        call cpmname_to_dotname
        call open_setdir2_create_copy
        pop bc
cmd_copydir0_skip
        inc bc
        jr cmd_copydir0
;cmd_copydirq
        ;ret

        macro STRPUSH
;hl=string addr
        xor a
        push af
         ld a,(hl)
         inc hl
         or a
         push af
        jr nz,$-4
        pop af
;в стеке лежит \0, текст (без терминатора)
        endm
        
        macro STRPOP
;hl=string addr
        ld d,h
        ld e,l
         pop af
         ld (hl),a
         inc hl
         or a
        jr nz,$-4
        ex de,hl
        call strmirror
        endm
        
strmirror
;hl=string addr
        ld d,h
        ld e,l
        call strlen
        ld b,h
        ld c,l
;de=начало, bc=hl=длина
        ;ld h,b
        ;ld l,c
        add hl,de ;hl=конец+1
        srl b
        rr c ;bc=wid/2
mirrorbytes0
        dec hl
        ld a,(de)
        ldi
        dec hl
        ld (hl),a
        jp pe,mirrorbytes0
        ret
        
cmd_copydir0_recursive
;recursive copydir <wordbuf>/<filename> <wordbuf2>/<filename>
        push bc
        ld hl,wordbuf
        STRPUSH
        ld hl,wordbuf2
        STRPUSH
        ;ld hl,cmdprompt
        ;STRPUSH

        ld hl,wordbuf
        ld bc,0
        xor a
        cpir
        dec hl ;hl=terminator addr
        ld (hl),'/'
        inc hl
        ex de,hl
        ld hl,fcb_filename
        ;ld de,filenamebuf
        call cpmname_to_dotname
        
        ld hl,wordbuf2
        ld bc,0
        xor a
        cpir
        dec hl ;hl=terminator addr
        ld (hl),'/'
        inc hl
        ex de,hl
        ld hl,fcb_filename
        ;ld de,filenamebuf
        call cpmname_to_dotname
        
        call cmd_copydir_go

;restore dirnames, file #
        ;ld hl,cmdprompt
        ;STRPOP
        ld hl,wordbuf2
        STRPOP
        ld hl,wordbuf
        STRPOP
        pop bc
        jr cmd_copydir0_skip
        
open_setdir2_create_copy
        ;open....
        ld de,filenamebuf;wordbuf ;de=drive/path/file
        OS_OPENHANDLE
        or a
        jp nz,cmd_error_wrongfile
        ld a,b
        ld (close_file1_handle),a
        ld hl,close_file1
        push hl

        ;set dir2...
        ld de,cmdprompt
        OS_CHDIR
        ld de,wordbuf2
        OS_CHDIR

        ;create....
        ld de,filenamebuf;2;wordbuf2 ;de=drive/path/file
        OS_CREATEHANDLE
        or a
        jp nz,cmd_error_cant_copy
        ld a,b
        ld (cmd_copy_close_file2_handle),a
        ld hl,cmd_copy_close_file2
        push hl

        ;copy....
        jp cmd_copy0
        
        
getdirfcb_bc
;bc=file number in current dir to read to fcb
;nz=error
        push bc
        ld de,fcb
        OS_SETDTA
        ld de,fcbmask
        OS_FSEARCHFIRST ;de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
        pop bc
        or a
        ret nz
       
getdirfcb_bc0
        ld a,b
        or c
        ret z
        dec bc
        push bc
        ld de,fcb
        OS_SETDTA
        ld de,fcbmask
        OS_FSEARCHNEXT ;(NOT CP/M!!!)de = pointer to unopened FCB (filename with ????????), read matching FCB to DTA
        pop bc
        or a
        jr z,getdirfcb_bc0
        ret
        
        
;hl = poi to filename in string
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
;find last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
nfopenfnslashq.
;de = after last slash
	ret

commandslist
        dw cmd_dir
        db "dir",0
        dw cmd_t0
        db "0:",0
        dw cmd_t1
        db "1:",0
        dw cmd_t2
        db "2:",0
        dw cmd_t3
        db "3:",0
        dw cmd_t4
        db "4:",0
        dw cmd_t5
        db "5:",0
        dw cmd_t6
        db "6:",0
        dw cmd_t7
        db "7:",0
        dw cmd_del
        db "del",0
        dw cmd_exit
        db "exit",0
        dw cmd_cd
        db "cd",0
        dw cmd_copy
        db "copy",0
        dw cmd_rem
        db "rem",0
        dw cmd_md
        db "md",0
        dw cmd_ren
        db "ren",0
        dw cmd_mem
        db "mem",0
        dw cmd_proc
        db "proc",0
        dw cmd_drop
        db "drop",0
        dw cmd_date
        db "date",0
        dw cmd_start
        db "start",0
        dw cmd_copydir
        db "copydir",0
        dw cmd_type
        db "type",0
        dw cmd_echo
        db "echo",0
        dw cmd_pause
        db "pause",0
        
        dw -1 ;конец таблицы команд

tunknowncommand
        db "Unknown command",0
tdrivenotfound
        db "Drive not found",0
tnopars
        db "No parameters",0
tnotenoughpars
        db "Not enough parameters",0
tcantcopy
        db "Can't copy",0
tcantwrite
        db "Can't write",0
twrongpath
        db "Wrong path",0
twrongfile
        db "Wrong file",0
tcantmakedir
        db "Can't make the directory",0
tcantrename
        db "Can't rename",0
t_files_crlf
        db " files",#0d,#0a,0
tfree
        db "free pages=",0
twrongid
        db "Wrong ID",0
        
oldtimer
        dw 0
        
wordbuf
        ds MAXCMDSZ+1
wordbuf2
        ds MAXCMDSZ+1
filenamebuf
        ds MAXCMDSZ+1
filenamebuf2
        ds MAXCMDSZ+1

fcb
        ds FCB_sz
fcb_filename=fcb+FCB_FNAME        

fcbmask
        db 0
        db "???????????"
        ds FCB_sz-11-1
fcbmask_filename=fcbmask+FCB_FNAME

fcb2
        ds FCB_sz
fcb2_filename=fcb2+FCB_FNAME        

fcb_bat
        ds FCB_sz
fcb_bat_filename=fcb_bat+FCB_FNAME        

oldpath ;TODO убрать (когда будет loadapp через OPENHANDLE)
        ds MAXPATH_sz;MAXCMDSZ+1

sysdir
        ds MAXPATH_sz
        
oldcmd
        ds MAXCMDSZ+1
        
copybuf
        ds 128
copybuf_sz=$-copybuf

        align 256
file_buf
        ds 128
file_buf_end=$-1

        include "../_sdk/prdword.asm"
        include "../_sdk/loadpage.asm"
        include "../_sdk/cmdpr.asm"

cmd_end

	display "cmd size ",/d,cmd_end-cmd_begin," bytes"

	savebin "cmd.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "..\us\user.l"
