        ;TODO %~dp0 (драйв и путь запуска)
;TODO %~t1 (дата-время 1-го параметра)
;TODO goto и метки :label
;TODO if ???==??? goto
;TODO for
;TODO PATH (где хранить? должна подгружаться при старте новой копии cmd)

        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
DEBUG=0

MAXCMDSZ=COMMANDLINE_sz-1;127 ;не считая терминатора
;txtscrhgt=25
txtscrwid=80
CMDLINEY=24

_COLOR=0x0007;7
_ERRORCOLOR=0x0009;0x42

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS        
        call initstdio

        OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld a,d
        ld (stdouthandle_wasatstart),a
        ld a,e
        ld (stdinhandle_wasatstart),a

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
        push hl
        ld de,params
        call strcopy
        
        ld hl,params
        call cmd_skip_cmdcom
        call skipspaces
        ld (cmdlineword2),hl
        ld a,(hl)
        or a
        jp z,cmd_interactive
;command line = "cmd [/k|/p] <command>"
        xor a
        ld (cmd_afterrun),a
        call cmd_skipflags
        ld a,(cmd_afterrun)
        ld (cmd_afterrun_saved),a
        ld a,(hl)
        or a
        jr z,cmd_onerun_nocmd
        ld de,cmdbuf
        call strcopy
        
        call makeprompt ;иначе запустится из неправильной директории
        
        call execcmd_maybepipes ;can show errors ;a!=0: no such internal command
        ;or a
        ;call nz,callcmd;strcpexec_tryrun ;запускает по фону
        YIELD ;чтобы запущенная задача успела захватить фокус ;???
        jp cmd_afterrun_done
cmd_onerun_nocmd
        jp cmd_afterrun_done
cmd_afterrun_done
        ld a,(cmd_afterrun_saved)
        or a
        jr z,cmd_afterrun_use_live
        ld (cmd_afterrun),a
cmd_afterrun_use_live
        ld a,(cmd_afterrun)
        cp 1
        jp z,cmd_interactive ; /k
        cp 2
        jp z,cmd_press_exit ; /p
;если командная строка была со словом autoexec.bat в параметре, то это начальный запуск autoexec.bat, из него надо входить в интерактивный режим
        ld hl,tautoexecbat
cmdlineword2=$+1
        ld de,0
        call strcp ;z=yes
        jr z,cmd_interactive
cmd_exit
lastresult=$+1
       ld hl,0
        QUIT

cmd_press_exit
        call cmd_flushstdin
        ld hl,tpresstoexit
        call prtext
cmd_press_exit0
        call cmd_pause_infin
        jp cmd_exit

cmd_flushstdin
        call receivechar
        ret c
        or a
        jr nz,cmd_flushstdin
        ret
        
tautoexecbat
        db "autoexec.bat",0

tpresstoexit
        db "Press any key to exit...",0x0d,0x0a,0
version_text
		defb "Command line interpreter. rev.",0
		
cmd_interactive
        xor a
        ld (cmd_afterrun),a ; /k|/p only for initial one-shot
        ld (cmdbuf),a
        ld (oldcmd),a
        ld (curcmdscroll),a
	ld hl,version_text
        call prtext
        ifdef SVNREVISION
                ld de,((SVNREVISION+1) >> 16) & 0xffff
                ld hl,(SVNREVISION+1) & 0xffff
	        call prdword_dehl
		call prcrlf
        endif
cmdmainloop
       if DEBUG
        call printcurdir
       endif
        call makeprompt
        call editcmd
        call prcrlf
        
        ld hl,cmdbuf
        ld de,oldcmd
        ld bc,MAXCMDSZ+1
        ldir

        call execcmd_maybepipes
        ;or a
        ;call nz,callcmd;strcpexec_tryrun ;запускает по фону
        xor a
        ld (cmdbuf),a
        ld (curcmdscroll),a
        jp cmdmainloop

execcmd_maybepipes
;out:a!=0: no such internal command
;если command pars >file, то create file, перенаправить вывод в него, execcmd, close file, перенаправить вывод обратно
        ld hl,cmdbuf
        ld a,'|'
        ld bc,MAXCMDSZ
        cpir
        jp z,execcmd_pipe

        ld hl,cmdbuf
        ld a,'<'
        ld bc,MAXCMDSZ
        cpir
        jr z,execcmd_changestdin ;jr nz,cmd_noexeccmdtofile

        ld hl,cmdbuf
        ld a,'>'
        ld bc,MAXCMDSZ
        cpir
        jp nz,callcmd ;exec or run ;execcmd_or_runprog ;jr nz,cmd_noexeccmdtofile
         cp (hl)
         jr nz,redirect_noadd
         ld (hl),' '
         xor a
redirect_noadd
         ld (redirect_mode),a
;change stdout
        dec hl
        ld (hl),0
        inc hl
         call skipspaces
        ex de,hl ;de=filename
redirect_mode=$+1
         ld a,0 ;0=open, else create
         or a
         jr nz,redirect_create
        push de
        OS_OPENHANDLE
        pop de
        or a
        jr nz,redirect_create
        push bc
        OS_GETFILESIZE
        pop bc
        push bc
        OS_SEEKHANDLE ;b=file handle, dehl=offset
        pop bc
        jr redirect_openq
redirect_create
        OS_CREATEHANDLE
redirect_openq
        ld a,b
        ld (execcmdtofile_handle),a
        call setstdouthandle
;changestdin_stdout_execcmd
        ;call execcmd ;can show errors ;a!=0: no such internal command
        ; or a
        ; call nz,callcmd
         call callcmd ;exec or run
        ;push af
;команда выполнилась в блокирующем режиме и вышла
execcmdtofile_handle=$+1
        ld b,0
        OS_CLOSEHANDLE ;закрыли выходной файл
stdouthandle_wasatstart=$+1
        ld a,0
        call setstdouthandle
;stdinhandle_wasatstart=$+1
;        ld a,0
;        call setstdinhandle

        ;pop af
        ret
        ;jr cmd_noexeccmdtofileq
;cmd_noexeccmdtofile
;        jp execcmd ;a!=0: no such internal command
;cmd_noexeccmdtofileq
;        ret

execcmd_changestdin
        dec hl
        ld (hl),0
        inc hl
         call skipspaces
        ex de,hl ;de=filename
        OS_OPENHANDLE
        ld a,b
        ;ld (execcmdtofile_changestdin_handle),a
        call setstdinhandle
        call setstdinout
        ;jr changestdin_stdout_execcmd
        ;call execcmd ;can show errors ;a!=0: no such internal command
        ; or a
        ; call nz,callcmd
         call callcmd ;exec or run
        ;push af
;команда выполнилась в блокирующем режиме и вышла (или запустилась программа по фону)

;execcmdtofile_changestdin_handle=$+1
;        ld b,0
;        OS_CLOSEHANDLE ;закрыли входной файл программы
;stdouthandle_wasatstart=$+1
;        ld a,0
;        call setstdouthandle
stdinhandle_wasatstart=$+1
        ld a,0
        call setstdinhandle
        call setstdinout

        ;pop af
        ret
        ;jr cmd_noexeccmdtofileq

execcmd_pipe
;cmd |app
        dec hl
        ld (hl),0
        inc hl
         call skipspaces
        ;hl=right app filename
        ld (rightapp_filename),hl
        push hl
        call skipword
        ld (rightapp_filename_end),hl
        ld a,(hl)
        ld (rightapp_filename_endchar),a
        ld (hl),0
        pop hl
        
        ex de,hl ;de=right app filename

        OS_OPENHANDLE
        or a
        jr nz,execcmd_pipe_error

        push bc ;b=right app file handle
        ld de,tpipename
        OS_CREATEHANDLE
        ld a,b
        ld (pipehandle),a
        call setstdouthandle
        pop bc ;b=right app file handle
        
        call readapp ;out: dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error ;делает CLOSE ;TODO через loadapp, чтобы дописывать .com и грузить из /bin
        push bc ;b=id
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        ld a,d
        SETPGC000
rightapp_filename_end=$+1
        ld hl,0
rightapp_filename_endchar=$+1
        ld (hl),0
rightapp_filename=$+1
        ld hl,0
        ld de,0xc000+COMMANDLINE
        ld bc,COMMANDLINE_sz
        ldir ;command line       
        pop bc ;b=id
        push bc
pipehandle=$+1
        ld e,0 ;stdin for right app
        ld a,(stdouthandle_wasatstart)
        ld d,a ;stdout for right app
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT
        pop af ;id
        ld e,a ;e=id
        ;ld (waitpid_id),a
        push de ;e=id
        OS_RUNAPP
        
        ;call execcmd ;can show errors ;a!=0: no such internal command
        ; or a
        ; call nz,callcmd
         call callcmd ;exec or run
        pop de ;e=id
        ;push af ;a=error
        push de ;e=id
        ld a,(pipehandle)
        ld b,a
        OS_CLOSEHANDLE ;закрыли источник данных
        pop de ;e=id
       ;call waitpid_keepresult
        ;WAITPID ;hl=result
        ;ld (lastresult),hl
        ;call prword_hl_crlf

        ld a,(stdouthandle_wasatstart)
        call setstdouthandle
;закрыть входной файл правой программы
        ;ld a,(pipehandle)
        ;ld b,a
        ;OS_CLOSEHANDLE

        ;pop af ;a=error
execcmd_pipe_error
        ret

tpipename
        db "z:",0

;;;;;;;;;;;;;;;;;;
        
editcmd_up
        xor a
        ld (curcmdscroll),a
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
        SETX_;SETXY_
        ;ld e,CURSORCOLOR;0x38
        ;OS_PRATTR ;нарисовать курсор
        call yieldgetkeyloop ;YIELDGETKEYLOOP
       ;push af
       ;ld a,r
       ;out (0xfe),a
       ;pop af
         ;ld a,c ;keynolang
        ;push af
        ;call cmdcalccurxy
        ;SETXY_
        ;ld e,COLOR;7
        ;OS_PRATTR ;стереть курсор
        ;pop af
        cp key_enter
        ret z
        cp key_up
        jr z,editcmd_up
         ld hl,editcmd0
         push hl
        ;ld hl,cmdbuf
        cp key_backspace
        jr z,editcmd_backspace
        cp key_left
        jr z,editcmd_left
        cp key_right
        jr z,editcmd_right
        cp key_home
        jr z,editcmd_home
        cp key_end
        jr z,editcmd_end
        cp key_del
        jr z,editcmd_del
        cp 0x20
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
        
editcmd_backspace
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        ret z ;jr z,editcmdok ;нечего удалять
        dec a
        ld (curcmdx),a
        jp strdelch ;удаляет предыдущий символ
      
editcmd_del
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc hl
        jp strdelch ;удаляет предыдущий символ
      
editcmd_left
        ld a,(curcmdx)
        or a
        ret z ;jr z,editcmdok ;некуда влево
        dec a
editcmd_leftq
        ld (curcmdx),a
        ret
editcmd_home
        xor a
        jr editcmd_leftq
editcmd_end
        ld hl,cmdbuf
        call strlen ;hl=length
        ld a,l
        jr editcmd_leftq

editcmd_right
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc (hl)
        dec (hl)
        ret z ;jr z,editcmdok ;некуда право, стоим на терминаторе
        inc a
        ld (curcmdx),a
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
		;display $
		;display wordbuf
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld (execcmd_pars),hl
		inc hl
		ld a,(wordbuf+1)
		cp ':'
		jp nz,execcmd0
		ld a,(wordbuf+2)
		or a
		jp z,cmd_t0
execcmd0
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
        push bc
        ld hl,cmd_exit
        ld a,b
        cp h
        jr nz,strcpexec_docall
        ld a,c
        cp l
        jr nz,strcpexec_docall
        pop bc
        jp cmd_exit
strcpexec_docall
        pop bc
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
;выполнить командную строку по фону (нужно из .bat)
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
        call strcpexec_tryrun ;выполнить файл с именем cmdbuf или SYSDIR/cmdbuf и параметрами там, e=id, nz=error, cy=end of .bat
        ret z
execcmd_error
        ld hl,tunknowncommand
        jp cmderror
        
strcpexec_tryrun
;выполнить файл с именем cmdbuf или SYSDIR/cmdbuf и параметрами там, e=id, nz=error, cy=end of .bat
        call loadapp ;загрузить файл с именем cmdbuf, e=id, nz=error, cy=end of .bat
        ret c ;cy=end of .bat        
        jr nz,execcmd_tryrunerror
execcmd_tryrunok
        ret c ;cy=end of .bat
        if 1==1
       push de
        ld b,e ;id
        ld a,(stdinhandle)
        ld e,a
        ld a,(stdouthandle)
        ld d,a
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT
       pop de
        endif
        push de        
        OS_RUNAPP ;e=id
        pop de
         xor a ;z
        ret

execcmd_tryrunerror
;выполнить файл с именем SYSDIR/cmdbuf и параметрами там (через loadapp)
        call loadapp_keeppath
        OS_SETSYSDRV
        ld de,sysdir
        push de
        OS_GETPATH
        call loadapp_setoldpath ;TODO из prompt
         ;OS_SETSYSDRV
         ;ld de,wordbuf2
         ;OS_GETPATH
        ;ld de,cmdprompt
        ;OS_CHDIR
        ;call makeprompt
        ;ld de,cmdprompt
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
         ;ld hl,sysdir
         ;ld de,oldpath
         ;ld bc,MAXPATH_sz;MAXCMDSZ+1
         ;ldir ;TODO рекурсивно (для .bat)
         ;jr $
        call loadapp ;загрузить файл с именем cmdbuf, e=id, nz=error, cy=end of .bat
        jr z,execcmd_tryrunok
        ret ;nz=error
        
openparams
;open %0 (progname), %1...
        ld hl,cmdbuf
        call strlen
        ld b,h
        ld c,l ;bc=len (without terminator)
        ld hl,cmdbuf
        add hl,bc ;at terminator
        ld de,cmdbuf+MAXCMDSZ ;at last byte of buffer
        inc bc ;bc=len (with terminator)
        lddr
        ex de,hl
        inc hl
        ld de,cmdbuf
chgparams0
        ld a,(hl)
        ld (de),a
        or a
        jr z,chgparams0q
        inc hl
        cp '%'
        jr nz,chgparams0skip
        ld a,(hl)
        ld (de),a
        or a
        jr z,chgparams0q
        inc hl
        sub '0' ;a=param
        cp 10
        jr nc,chgparams0skip ;%%
        push hl
        ld hl,params
        inc a
        ld b,a
chgparams1
        call skipword ;doesn't move at terminator
        call skipspaces ;doesn't move at terminator
        djnz chgparams1
;hl=param text (end=space or terminator)        
chgparams2
        ld a,(hl)
        or a
        jr z,chgparams2q
        cp ' '
        jr z,chgparams2q
        ld (de),a
        inc hl
        inc de
        djnz chgparams2
chgparams2q
        pop hl
        dec de
chgparams0skip
        inc de
        jr chgparams0
chgparams0q
        ret

;execcmd_or_runprog
;        call execcmd
;        or a
;        ret z
;        jp callcmd;strcpexec_tryrun ;запускает по фону

callcmd
;call command (cmdbuf) with waiting
        call execcmd ;a!=0: no such internal command
        or a
        ret z ;command executed
        ;call loadapp ;загрузить файл с именем cmdbuf, e=id
        call strcpexec_tryrun ;загрузить файл с именем cmdbuf или SYSDIR/cmdbuf, e=id, nz=error, CY=end of .bat
        ret c
        jp nz,execcmd_error
        ;push de
        ;OS_RUNAPP
        ;pop de
waitpid_keepresult
        WAITPID ;не должно быть, если команда была .bat!
       ld (lastresult),hl
;hl=result
        ret
        ;jp prword_hl_crlf

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
        push de
        call getword
;учесть путь в имени (TODO использовать OS_OPENHANDLE)
        pop hl ;ld hl,wordbuf
        push hl
        call findlastslash. ;de=after last slash or beginning of path
        pop hl

        ;push hl
;ищем точку, проверяем, что после неё стоит .com или .bat
loadapp_finddot0
        ld a,(hl)
        or a
        jr z,loadapp_nodot
        cp '.'
        inc hl
        jr nz,loadapp_finddot0
;проверяем, что после неё стоит .com или .bat
        ld (exthlpointer),hl
        ld a,(hl)
        or 0x20
        cp 'b'
; TODO где проверка на остальные буквы?
        jp z,strcpexec_tryrun_bat
;считаем, что написано .com (в принципе расширение безразлично - просто запускаем)
        jr loadapp_finddotok1

loadapp_nodot
;TODO или сначала проверять bat, потом com?
;a=0
        ld (hl),'.'
        inc hl
        ld (exthlpointer),hl
        ld (hl),'c'
        inc hl
        ld (hl),'o'
        inc hl
        ld (hl),'m'
        inc hl
        ld (hl),a ;0        
loadapp_finddotok
        call open_file_exec
        jp z,fileopenok
        ld hl,(exthlpointer)  
        ld (hl),'b'
        inc hl
        ld (hl),'a'
        inc hl
        ld (hl),'t'
        inc hl
        xor a
        ld (hl),a ;0
        ;ret nz ;jr nz,execcmd_error ;NC!
        jp strcpexec_tryrun_bat 

loadapp_finddotok1
        call open_file_exec
        ret nz ;jr nz,execcmd_error ;NC!
fileopenok
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
        ld bc,COMMANDLINE_sz
        ldir ;command line
        pop hl
        pop de
        call readfile_pages_dehl

        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
        pop de
        ld e,d ;e=id
        xor a
        ret ;Z
open_file_exec
        ld de,wordbuf ;pop de
        OS_OPENHANDLE
        or a
        push af
        ld a,b
        ld (curhandle),a
         ;call loadapp_setoldpath
       if DEBUG
         call printcurdir
         ;call yieldgetkeyloop
       endif
        pop af
        ret
exthlpointer
        dw 0000
        ;dw 0000    

readapp
        ld a,b
        ld (curhandle),a
        
        OS_NEWAPP ;для первой создаваемой задачи будут созданы первые два пайпа и подключены
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id

        ld a,d
        SETPGC000
        push de
        push hl
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces ;пропустили первое слово (там было term.com, а дальше, например, cmd.com autoexec.bat)
        ld de,0xc080
        ld bc,128  
        ldir ;command line
        pop hl
        pop de

        push de
        push hl
        call readfile_pages_dehl
       push af
        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE
       pop af ;error
        pop hl
        pop de

        pop bc ;id
        ret

skipword
;hl=string
;out: hl=terminator/space addr
skipword0
        ld a,(hl)
        or a
        ret z ;jr z,skipwordq
        sub ' '
        ret z ;jr z,skipwordq
        inc hl ;ldi
        jr skipword0

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
;out: a=error
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
curhandle=$+1
        ld b,0
        OS_READHANDLE
        pop hl
        pop de
        or a
        ret
     
strcpexec_tryrun_bat
	;display "strcpexec_tryrun_bat",strcpexec_tryrun_bat
;out: nz=error, cy=end of .bat
;open .bat
;filename in wordbuf
        ld de,wordbuf ;pop de
        OS_OPENHANDLE
        or a
        jr z,strcpexec_tryrun_bat_opened
;retry basename only (nv passes m:/path/file.bat; cwd may already be that dir)
        ld hl,wordbuf
        call findlastslash.
        ex de,hl
        OS_OPENHANDLE
        or a
        ret nz ;jp nz,execcmd_error ;NC!
strcpexec_tryrun_bat_opened
        ld a,b
        ld (curbathandle),a
        
         ld a,0x3c ;"inc a"
         ld (readbyte_readbuf_last),a
        ld iy,file_buf_end
strcpexec_tryrun_bat0
;load line to cmdbuf
        ld hl,cmdbuf
        LD (hl),0
        call readstr ;nz=EOF
        push af ;jr nz,strcpexec_tryrun_batq ;чтобы последнюю строку всё-таки выполнить

        push iy
        ld hl,cmdbuf
        call prtext
        call prcrlf
        pop iy
        
;call command in cmdbuf
        push iy
        call openparams
        call execcmd_maybepipes ;callcmd
        pop iy
        
        pop af
        jr z,strcpexec_tryrun_bat0 ;nz=EOF
strcpexec_tryrun_batq
;close .bat
        ld a,(curbathandle)
        ld b,a
        OS_CLOSEHANDLE
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
        jr z,readstrEOF ;возвращает NZ
	;jr z,readstrq ;возвращает Z
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
         ;jr $
        xor a
readbyte_readbuf_last=$ ;TODO keep if recursive!
        inc a ;/nop(z)=last, inc a(nz)=not last
        jr z,readbyte_readbufq

        if 1==1
;B = file handle, DE = Buffer address, HL = Number of bytes to read
curbathandle=$+1
        ld b,0
        ld de,file_buf
        push de
        ld hl,128
        OS_READHANDLE
        ;jr $
        pop iy
;HL = Number of bytes actually read, A=error
        ;sub 1
        ;sbc a,a ;error=0 => a=255, else a=0 (Z)
        ;jr z,readbyte_readbufq ;error (=>EOF)
         ;jr $
        ld a,l
        or a
        jr z,readbyte_readbufq ;0 bytes (=>EOF)
        jp m,readbyte_readbufq ;128 bytes (NZ no EOF) (not last block)
        
        else ;CP/M-like
        
        ld de,file_buf
        push de
        OS_SETDTA ;set disk transfer address = de
        ld de,fcb_bat
        OS_FREAD
        pop iy
        xor 128 ;a = bytes read
        jr z,readbyte_readbufq
        jp m,readbyte_readbufq ;full block = not last block
        
        endif
        
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

cmd_dir
        ld de,(execcmd_pars)
        ;ld de,emptypath
        OS_OPENDIR
        or a
        ld bc,0 ;nfiles
        jp nz,loaddir2_error
cmd_dir2_0
       push bc
        ld de,filinfo
        OS_READDIR
       pop bc
        or a
        jr nz,loaddir2q
        ld a,(filinfo+FILINFO_FNAME)
        or a
        jr z,loaddir2q
       push bc
        ld ix,(filinfo+FILINFO_FDATE)
        ld hl,(filinfo+FILINFO_FTIME)
        call prdate_time

        ld a,' '
        PRCHAR_

        ld hl,(filinfo+FILINFO_FSIZE)
        ld de,(filinfo+FILINFO_FSIZE+2)
        call prdword_dehl
        ld a,' '
        PRCHAR_

        ld hl,filinfo+FILINFO_LNAME
        ld a,(hl)
        or a
        jr nz,$+5
        ld hl,filinfo+FILINFO_FNAME
        ;ld c,0 ;c=x???
        call prtext
;c=x???
        call prcrlf
       pop bc ;nfiles
        inc bc ;nfiles
        or a
        jr cmd_dir2_0
loaddir2_error
loaddir2q
;bc=nfiles
        ld h,b
        ld l,c
        call prword
        ld hl,t_files_crlf
        jp prtext

prdate_time
;ix=date, hl=time
        ld de,datetimebuf
       push de
       push hl ;time
        ;push ix ;date
        ld a,hx
        srl a
        sub 20
        jr nc,$+4
        add a,100 ;XX century
        call prNNcmd ;year
        ;ld a,'-'
        ;PRCHAR_
         inc de
        ;pop hl
        ld a,lx
        push af
        add ix,ix
        add ix,ix
        add ix,ix
        ld a,hx
        and 0x0f
        call prNNcmd ;month
        ;ld a,'-'
        ;PRCHAR_
         inc de
        pop af
        and 0x1f
        call prNNcmd ;day

        ;ld a,' '
        ;PRCHAR_
         inc de
       pop hl ;time
        push hl
        ld a,h
        rra
        rra
        rra
        and 0x1f
        call prNNcmd ;hour
        ;ld a,':'
        ;PRCHAR_
         inc de
        pop hl
        ld a,l
        push af
        add hl,hl
        add hl,hl
        add hl,hl
        ld a,h
        and 0x3f
        call prNNcmd ;minute
        ;ld a,':'
        ;PRCHAR_
         inc de
        pop af
        add a,a
        and 0x3f
        call prNNcmd ;second
       pop hl
        ld de,8+1+8
        jp cmdprNchars

prNNcmd
;a=NN
;de=buf
        ld bc,10+(256*('0'-1))
        sub c
        inc b
        jr nc,$-2
         ex de,hl
         ld (hl),b
         ex de,hl
         inc de
        add a,'0'+10
         ld (de),a
         inc de
        ret

datetimebuf
        db "00-00-00 00:00:00"
        
skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

cmd_skipflags
;hl=after "cmd.com", skip optional /k /p
        ld a,(hl)
        or a
        ret z
        cp '/'
        ret nz
        inc hl
        ld a,(hl)
        or 0x20
        dec hl
        cp 'k'
        jr z,cmd_skipflags_k
        cp 'p'
        jr z,cmd_skipflags_p
        ret
cmd_skipflags_k
        ld b,1
        jr cmd_skipflags_set
cmd_skipflags_p
        ld b,2
        jr cmd_skipflags_set
cmd_skipflags_set
        inc hl
        inc hl
        ld a,b
        ld (cmd_afterrun),a
        call skipspaces
        jr cmd_skipflags

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
        ex de,hl
        OS_DELETE
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
       ld a,(de)
       cp '*'
       jr z,cmd_ren_star
        OS_RENAME
        or a
        ret z
cmd_ren_star_error
        ld hl,tcantrename
        jp cmderror
cmd_ren_star
       cp (hl)
       jr nz,cmd_ren_star_error
;поддерживаем только переименование вида ren *.ext1 *.ext2
        inc hl
        inc de
        ld a,(de)
       cp '.'
       jr nz,cmd_ren_star_error
       cp (hl)
       jr nz,cmd_ren_star_error
        inc hl
        inc de
;de,hl указывают на ext1, ext2
        ld (cmd_ren_star_ext1),de
        ld (cmd_ren_star_ext2),hl
        ld de,emptypath
        OS_OPENDIR
;проверяем все файлы в текущей директории на соответствие filename.ext1
;если совпало, то переименовываем в filename.ext2
cmd_ren_star0
        ld de,filinfo
;de=buf for FILINFO (if no LNAME, use FNAME), 0x00 in FILINFO_FNAME = end dir
        OS_READDIR
;out in A=error(0 - no error, 4 - no more files, other - critical error)
        or a
        ret nz ;todo show N files renamed
        ld hl,filinfo+FILINFO_LNAME ;длинного имени может не быть
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,filinfo+FILINFO_FNAME
       push hl ;from name
        call findlastdot
;de=after last dot
cmd_ren_star_ext1=$+1
        ld hl,0
        call strcp ;z=yes
       pop hl ;from name
        jr nz,cmd_ren_star0

        ;ld hl,filinfo+FILINFO_LNAME
       push hl ;from name
        ld de,filenamebuf
       push de
        call strcopy
       pop hl ;to name
       push hl
        call findlastdot
;de=after last dot in toname
cmd_ren_star_ext2=$+1
        ld hl,0
        call strcopy ;z=yes ;возможное переполнение уходит в filenamebuf2
       pop hl ;to name
       pop de ;from name
        ;ld hl,filenamebuf2 ;to name
        OS_RENAME
;TODO inc count
        jr cmd_ren_star0

cmd_copy
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        ld de,filenamebuf;wordbuf
        call getword ;hl=terminator/space addr
        call skipspaces
        ld a,(hl)
        or a
        jp z,cmd_error_notenoughpars
        ld de,filenamebuf2;wordbuf2
        call getword ;hl=terminator/space addr

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
        
cmd_error_cant_copy
        ld hl,tcantcopy
        jp cmderror

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
prword_hl_crlf
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
       ld a,e
       ld (cmd_proc_id),a
        push de
        OS_GETAPPMAINPAGES ;d,e,h,l=pages in 0000,4000,8000,c000, c=flags
        or a
        jr nz,cmd_proc_skip
        ld a,d
        pop de ;e=id
        push de ;e=id
         push bc
        push af ;main page
        ex de,hl ;l=id
        ld h,0
        call prword
        ld a,' '
        PRCHAR_
        pop af ;main page
        SETPGC000
         pop bc ;c=flags
         push bc
         bit factive,c
         ld a,'-'
         jr z,$+4
         ld a,'+'
         PRCHAR_
         pop bc
         push bc
         bit fgfx,c
         ld a,' '
         jr z,$+4
         ld a,'g'
         PRCHAR_
         pop bc
          bit fwaiting,c
          ld a,' '
          jr z,$+4
          ld a,'w'
          PRCHAR_
         ld a,' '
         PRCHAR_

        ld de,0 ;e=page, d=number of pages for this id
cmd_proc_countmem0
       push de
        OS_GETPAGEOWNER
        ld a,e
       pop de
cmd_proc_id=$+1
        cp 0
        jr nz,$+3
         inc d
        inc e
        jr nz,cmd_proc_countmem0
        ld l,d ;print number of used pages
        ld h,0
        call prword

         ld a,' '
         PRCHAR_
         
        ld hl,0xc000+COMMANDLINE
        call prtext
        call prcrlf
cmd_proc_skip
        pop de
        inc e
        ld a,e
        inc a ;no id 0xff
        jr nz,cmd_proc0
        ret

cmd_date
        OS_GETTIME ;ix=date, hl=time
        call prdate_time
        jp prcrlf
        
cmd_t0
        ld a,(wordbuf)
	and 0xdf
        sub 'A'
        call cmdsetdrive
        or a
        ret z
        ld hl,tdrivenotfound
        jp cmderror
        
cmderror
        push hl
        ld de,_ERRORCOLOR
        SETCOLOR_
        pop hl
        call prtext
        ld de,_COLOR
        SETCOLOR_
prcrlf
        ;ld a,0x0d
        ;PRCHAR_
        ;ld a,0x0a
        ;PRCHAR_
        ld hl,crlfbuf
        ld de,2
        jp cmdprNchars
crlfbuf
        db 0x0d,0x0a
        
cmdsetdrive
        ld e,a
        OS_SETDRV
        ret

cmd_type
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        ld de,wordbuf
        push de
        call getword ;hl=terminator/space addr
        pop de ;ld de,wordbuf ;de=drive/path/file
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
        PRCHAR_
        pop bc
        jr cmd_type0
        
cmd_tee
;tee filename
;copy stdin to filename and to stdout
        ld hl,(execcmd_pars)
        ld a,(hl)
        or a
        jp z,cmd_error_nopars
        ld de,wordbuf
        push de
        call getword ;hl=terminator/space addr
        pop de ;ld de,wordbuf ;de=drive/path/file
        OS_CREATEHANDLE
        or a
        jp nz,cmd_error_wrongfile
        ld a,b
        ld (close_file1_handle),a
        ld hl,close_file1
        push hl
cmd_tee0
        push bc
        GETKEY_
        ld (cmd_type_buf),a
        pop bc
        ret c ;input pipe closed
        ld a,(cmd_type_buf)
        PRCHAR_
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        ld de,cmd_type_buf
        ld hl,1 ;TODO набивать буфер, потом писать много
        OS_WRITEHANDLE
;HL = Number of bytes actually written, A=error?
        pop bc
        jr cmd_tee0

cmd_uname
	ld hl,nedostr
        call prtext
	OS_GETCONFIG
	push ix
	pop de
	ld h,b
	ld l,c
	call prdword_dehl
        jp prcrlf
nedostr defb "NedoOS Kernel revision ",0

cmd_echo
        ld hl,(execcmd_pars)
        call prtext
        jp prcrlf
		
cmd_pause
        call getkey
        ld hl,(execcmd_pars)
	ld a,(hl)
        or a
        jr z,cmd_pause_infin
	ld de,copybuf
	call strtobyte_hltode
	ld hl,(copybuf)	;умножаем на 50 интов в секунде
	ld d,h
	ld e,l
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	add hl,hl
	;display "cmd_pause ",cmd_pause
cmd_pause_loop	;ждем окончания счетчика, либо кнопку
	ld a,h
	or l
	ret z
	push hl
	ld c,CMD_YIELD
	call BDOS	;YIELD
	call getkey
	pop hl
        ret c ;error
	or a
	ret nz
	dec hl
	jr cmd_pause_loop
		
cmd_pause_infin
        call yieldgetkeyloop ;YIELDGETKEYLOOP
        cp key_redraw
        jr z,cmd_pause_infin
        ret

cmd_skip_cmdcom
;in: hl=command line, out: hl=after optional "cmd.com" (with optional path prefix)
        ld de,wordbuf
        push hl
        call getword
        ld bc,hl
        ld hl,wordbuf
        call findlastslash. ;de=basename (e.g. cmd.com in bin/cmd.com)
        ex de,hl
        ld de,tcmdcom
        call strcp
        pop hl
        ret nz
        ld hl,bc
        call skipspaces
        ret

tcmdcom
        db "cmd.com",0

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
        PRCHAR_
        ld hl,wordbuf2
        push hl
        call prtext
        call prcrlf
        pop de ;ld de,wordbuf2
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
	 ld a,b
	 or c
	 ret z
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
        jp cmd_copydir0_skip
        
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
;out: ;de = after last slash
findlastslash.
nfopenfnslash.
	ld d,h
	ld e,l ;de = after last slash
nfopenfnslash0.
	ld a,[hl]
	inc hl
	or a
	ret z ;jr z,nfopenfnslashq.
	cp '/'
	jr nz,nfopenfnslash0.
	jr nfopenfnslash.
;nfopenfnslashq.
;de = after last slash
	;ret

;hl = poi to filename in string
;out: ;de = after last slash
findlastdot
nfopenfndot.
	ld d,h
	ld e,l ;de = after last dot
nfopenfndot0.
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,nfopenfndot0.
	jr nfopenfndot.

commandslist
        dw cmd_dir
        db "ls",0
        dw cmd_dir
        db "dir",0
        dw cmd_del
        db "del",0
        dw cmd_del
        db "rm",0
        dw cmd_exit
        db "exit",0
        dw cmd_exit
        db "quit",0
        dw cmd_cd
        db "cd",0
        dw cmd_copy
        db "copy",0
        dw cmd_copy
        db "cp",0
        dw cmd_rem
        db "rem",0
        dw cmd_md
        db "md",0
        dw cmd_md
        db "mkdir",0
        dw cmd_ren
        db "ren",0
        dw cmd_ren
        db "mv",0
        dw cmd_mem
        db "mem",0
        dw cmd_mem
        db "free",0
        dw cmd_proc
        db "proc",0
        dw cmd_proc
        db "ps",0
        dw cmd_tee
        db "tee",0
        dw cmd_drop
        db "drop",0
        dw cmd_drop
        db "kill",0
        dw cmd_date
        db "date",0
        dw cmd_start
        db "start",0
        dw cmd_copydir
        db "copydir",0
        dw cmd_type
        db "type",0
        dw cmd_type
        db "cat",0
        dw cmd_echo
        db "echo",0
        dw cmd_pause
        db "pause",0
        dw cmd_cls
        db "cls",0
        dw cmd_uname
        db "uname",0
        
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
        db " files",0x0d,0x0a,0
tfree
        db "free pages=",0
twrongid
        db "Wrong ID",0
        
;oldtimer
;        dw 0
        
	db 0 ;для запарывания на случай отсутствия пути
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
        
cmd_afterrun
        ds 1
cmd_afterrun_saved
        ds 1

oldcmd
        ds MAXCMDSZ+1
        
copybuf
        ds 4096;128 ;можно сколько угодно
copybuf_sz=$-copybuf

params
        ds MAXCMDSZ+1

filinfo
        ds FILINFO_sz

emptypath
        db 0

        align 256
file_buf
        ds 128 ;buf for reading .bat
file_buf_end=$-1

        if DEBUG
printcurdir
        ld de,curdir__
        push de
        OS_GETPATH
        pop hl
        ;ld c,0
        call prtext
        jp prcrlf

curdir__
        ds 256
        endif

prword
        ld de,0
        jp prdword_dehl

        include "../_sdk/prdword.asm"
        include "../_sdk/string.asm"
        include "cmdpr.asm"
        include "../_sdk/stdio.asm"

cmd_cls=clearterm ;print 25 lines of spaces except one

cmd_end

	;display "cmd size ",/d,cmd_end-cmd_begin," bytes"

	savebin "cmd.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "../../us/user.l",1
