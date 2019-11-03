        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
MAXCMDSZ=255
txtscrhgt=25
txtscrwid=80

STACK=0x8000 ;нельзя 0x0000, иначе не получится грузить через верхнее окно и переключать страницы программы и переменных

COLOR=7
CURSORCOLOR=#38

varmem=0x4000 ;строки (256 байт asciiz), числа (4 байта), параметры цикла (4+4(step)+4(to)+4(goto) байта), массивы (2 байта число элементов, элементы по 4 байта)
progmem=0x8000 ;номер строки(ст,мл), длина строки(мл,ст без терминатора), строка(asciiz)
szprogmem=0x8000

RUNMODE_PROG=1
RUNMODE_INTERACTIVE=0

        org PROGSTART

cmd_begin
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,h
        ld (pg32klow),a
        ld a,l
        ld (pg32khigh),a
        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
        ld a,d
        ld (setpgs_scr_high),a

        ld e,6 ;textmode
        OS_SETGFX
        
        ld sp,STACK
        
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload ;Нет ключей и имени файла
;command line = "basic [-c] [-n] [-h] [-V] [file to load]" c - fast load as code file, n - no autorun, h - help, v - version
        call cmd_line_parse
        ld a,(cmd_line_h)
        or a
        jr nz,show_usage_info
        ld a,(cmd_line_v)
        or a
        jr nz,show_version
        ld a,(cmd_line_c)
        or a
        call z,cmd_load_text
        ld a,(cmd_line_c)
        cp 1
        call z,cmd_load_hl
        ld a,(cmd_line_n)
        or a
        jp z,cmd_run
noautoload
        
mainloop
        ld sp,STACK
        ld e,6 ;textmode
        OS_SETGFX
        ;call restorebasicpages

        ;ld (fail_sp),sp
        call editcmd
        call prcrlf

        ld a,RUNMODE_INTERACTIVE
        ld (runmode),a
        call add_or_run_line
        
        ld hl,cmdbuf
        ld (hl),0
        jp mainloop


show_usage_info
        ld hl,usage_info
        call prtext
        call prcrlf
        jr cmd_quit

show_version
        ld hl,VERSION
        call prtext
        jr cmd_quit

restorebasicpages
pg32khigh=$+1
        ld a,0
        SETPG32KHIGH
pg32klow=$+1
        ld a,0
        SETPG32KLOW
        ret

skipword
;hl=string
;out: hl=terminator/space addr
skipword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr skipword0

        
cmd_quit
        QUIT

endofedit
        ld hl,tendofprog
        jr fail_or_ok
        
endofprog
        ld hl,cmdbuf
        ld (hl),0
        ld hl,tendofprog
        jr fail_or_ok
        
endbreak
        ld hl,tendbreak
        jr fail_or_ok

fail
        ld hl,terror
fail_or_ok
;fail_sp=$+1
        ;ld sp,0
        call prtext
        call prcrlf
        jr mainloop

fail_syntax
    ld hl,fsyntax
    call prtext
    ld hl,wordbuf
    call prtext
    call prcrlf
    jp mainloop

fail_fo
    ld hl,fopenerror
    call prtext
    call prcrlf
    jp mainloop




VERSION db "Basic interpreter v0.11",0x0d,0x0a,"Nedopc group 2019",0x0d,0x0a,0

usage_info
        db "Use basic.com [-c] [-h] [-n] [-V] [inputfile]",0x0d,0x0a
	db "              -c : Input file in code format",0x0d,0x0a
        db "              -h : Show this help",0x0d,0x0a
        db "              -n : Do not autostart inputfile",0x0d,0x0a
	db "              -V : Show version info and quit",0x0d,0x0a,0
        

terror
        db "Unknown error",0
        
fopenerror
        db "File input/output error",0
fsyntax
        db "Syntax error near ",0
tendofprog
        db "O.K.",0
        
tendbreak
        db "Break",0
        
findline
;ищет адрес строки с заданным номером или не меньше
;de=linenum
;out: hl=адрес строки или (progend)
        ld hl,progmem
findline_lines0
        ld bc,(progend)
        or a
        sbc hl,bc
        add hl,bc
        ret z
        ld a,(hl)
        cp d
        inc hl
        jr z,findline_lines_HSBequal
        jr c,findline_lines_less
findline_OK
        dec hl
        ret
findline_lines_HSBequal
        ld a,(hl)
        cp e
        jr nc,findline_OK
findline_lines_less
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl) ;длина строки без терминатора
        inc hl
        add hl,bc
        inc hl ;пропускаем терминатор
        jr findline_lines0
       
readnum_
;out: hlde=num, hl'=text, CY=error
        exx
        ld a,(hl)
        exx
        sub '0'
        cp 10 ;NC = не число
        ccf ;CY = не число
        ret c ;error
readnum
;out: hlde=num, hl'=text, CY=error
        ld hl,0
        ld de,0 ;накопитель
readnum0
        exx
        ld a,(hl)
        exx
        sub '0'
        cp 10 ;NC = конец числа
        jr nc,readnumq
        exx
        inc hl
        exx
         push hl ;HSW
         push de ;LSW
        sla e
        rl d
        adc hl,hl ;*2
        sla e
        rl d
        adc hl,hl ;*4
         pop bc ;LSW
         ex de,hl
         add hl,bc
         ex de,hl
         pop bc ;HSW
         adc hl,bc ;*5
        sla e
        rl d
        adc hl,hl ;*10
        add a,e
        ld e,a
        ld a,d
        adc a,0
        ld d,a
        jr nc,$+3
        inc hl
        jr readnum0
readnumq
        call eatspaces
        or a ;NC=OK
        ret

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

eatspaces
        exx
        call skipspaces
        exx
        ret
        
add_or_run_line
;добавляет в программу строку в cmdbuf
        ld hl,cmdbuf
        exx
        call eatspaces
        call readnum_ ;hlde=linenum, hl'=text, CY=error
        jp c,cmd_run0;runline
        exx
        ld a,(hl)
        exx
        or a
        jr z,delline
        exx
        push hl
        call strlen
        ld (addline_linelen),hl
        pop hl
        exx
        push de ;linenum
        call findline ;hl=адрес строки или (progend)
;мы должны вставить строку перед этим местом (или заменить строку там)
        ld bc,(progend)
        or a
        sbc hl,bc
        add hl,bc
        jr z,addline_nodel
        ld a,(hl)
        cp d
        jr nz,addline_nodel
        inc hl
        ld a,(hl)
        dec hl
        cp e
        jr nz,addline_nodel
        push hl
        call delline_hl
        pop hl
addline_nodel

        push hl ;hl=адрес вставки

        ex de,hl ;de=адрес вставки
        ld hl,(progend)
        or a
        sbc hl,de ;progend-адрес вставки
        ld b,h
        ld c,l ;bc=длина смещаемой памяти (до конца программы)
        ld hl,(progend)
        push hl
        ld de,(addline_linelen)
        add hl,de
        ld de,4+1 ;номер,длина,терминатор
        add hl,de
        ld (progend),hl
        ex de,hl ;new progend
        pop hl ;old progend
        dec hl
        dec de
        call safelddr

        pop hl ;hl=адрес вставки
        pop de ;de=linenum
        
        ld (hl),d
        inc hl
        ld (hl),e ;номер строки
        inc hl
        
addline_linelen=$+1
        ld de,0
        ld (hl),e
        inc hl
        ld (hl),d ;длина строки
        inc hl
        push hl ;адрес вставки
        push de ;длина строки
        exx
        pop bc ;длина строки
        inc bc ;длина включая терминатор
        pop de ;адрес вставки
        call safeldir ;hl -> de (bc bytes)
        
        ret
        
delline
;de=linenum
        call findline ;hl=адрес строки или (progend)
        ld bc,(progend)
        or a
        sbc hl,bc
        add hl,bc
        ret z
        ld a,(hl)
        cp d
        ret nz
        inc hl
        ld a,(hl)
        dec hl
        cp e
        ret nz
delline_hl
;hl=адрес строки, которую надо удалить
        push hl ;адрес строки, которую надо удалить
        
        inc hl
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl) ;длина строки без терминатора
        inc hl
        add hl,bc
        inc hl ;пропускаем терминатор
        push hl ;hl=адрес следующей строки

        ex de,hl ;de=адрес вставки
        ld hl,(progend)
        or a
        sbc hl,de ;progend-адрес вставки
        ld b,h
        ld c,l ;bc=длина смещаемой памяти (до конца программы)
        pop hl ;hl=адрес следующей строки
        pop de ;de=адрес строки, которую надо удалить

        call safeldir
        ld (progend),de
        ret

getword
;hl=string
;de=wordbuf
;out: hl=terminator/space addr
        push bc
        ld a,(hl)
        cp ':'
        jr z,getword_colon
getword0
        ld a,(hl)
        or a
        jr z,getwordq
        ;TODO обрывать слово по нецифробукве
        sub ' '
        jr z,getwordq0
        ldi
        jp getword0
getword_colon
        ldi
getwordq
        xor a
getwordq0
        ;xor a
        ld (de),a
        pop bc
        ret

strcp
;hl=s1
;de=s2
;out: Z (equal, hl=terminator of s1+1, de=terminator of s2+1), NZ (not equal, hl=erroraddr in s1, de=erroraddr in s2)
strcp0.
	ld a,[de] ;s2
	cp [hl] ;s1
	ret nz
	inc hl
	inc de
	or a
	jp nz,strcp0.
	ret ;z

        include "bascmds.asm"
        
tunknowncommand
        db "Unknown command",0
        
        
safeldir
;hl -> de (bc bytes)
        ld a,b
        or c
        ret z
        ldir
        ret
        
safelddr
;hl -> de (bc bytes)
        ld a,b
        or c
        ret z
        lddr
        ret
        
        
prcrlf        
        push hl
        ld a,0x0d
        PRCHAR
        ld a,0x0a
        PRCHAR
        pop hl
        ret
        
prtext
;hl=text (asciiz)
;out: hl after terminator
        ld a,(hl)
        inc hl
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        jr prtext

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
        push af
        call cmdcalccurxy
        OS_SETXY
        ld e,COLOR;7
        OS_PRATTR ;стереть курсор
        pop af
        ld hl,cmdbuf
        cp key_enter
        ret z
        cp key_backspace
        jr z,editcmd_backspace
        cp key_left
        jr z,editcmd_left
        cp key_right
        jr z,editcmd_right
        ;cp key_up
        ;jr z,editcmd_up
        cp 0x20
        jr c,editcmdok ;прочие системные кнопки не нужны
;type in
        ld e,a
        ld hl,cmdbuf
        call strlen ;hl=length
        ld bc,MAXCMDSZ
        or a
        sbc hl,bc
        jr nc,editcmdok ;некуда вводить
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc a
        ld (curcmdx),a
        call strinsch ;e=ch
editcmdok
        jp editcmd0
        
editcmd_backspace
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        jr z,editcmdok ;нечего удалять
        dec a
        ld (curcmdx),a
        call strdelch ;удаляет предыдущий символ
        jr editcmdok
      
editcmd_left
        ld a,(curcmdx)
        or a
        jr z,editcmdok ;некуда влево
        dec a
        ld (curcmdx),a
        jr editcmdok
      
editcmd_right
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc (hl)
        dec (hl)
        jr z,editcmdok ;некуда право, стоим на терминаторе
        inc a
        ld (curcmdx),a
        jr editcmdok

;editcmd_up
;        ld de,cmdbuf
;        ld hl,oldcmd
;        ld bc,MAXCMDSZ+1
;        ldir
;        jp editcmd

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

cmdcalcpromptsz
        ld a,1
        ret

cmdcalctextaddr
;out: hl=addr, a=curcmdx
;keeps ix
        ld a,(curcmdx)
        ld c,a
        ld b,0
        ld hl,cmdbuf
        add hl,bc
        ret

cmdcalccurxy
;out: de=yx
;x=cmdpromptsz+curcmdx-curcmdscroll
        call cmdcalcpromptsz ;a=promptsz
        ld hl,curcmdx ;не на экране, а внутри команды
        add a,(hl)
        ld hl,curcmdscroll ;сдвиг команды относительно экрана
        sub (hl)
        ld e,a
        ld d,txtscrhgt-1
        ret

fixscroll_prcmd
;цикл поиска скролла для текущего положения курсора
editcmd_scroll0
        call cmdcalccurxy ;e=scrx
        call cmdcalcpromptsz ;a=promptsz
        ld hl,curcmdscroll
        dec a
        cp e ;scrx
        jr c,editcmd_noscrollleft ;x>=promptsz (x>(promptsz-1))
;x<promptsz - скролл влево
        dec (hl)
        jr editcmd_scroll0
editcmd_noscrollleft
        ld a,e ;scrx
        cp txtscrwid
        jr c,editcmd_noscrollright
;x>=txtscrwid - скролл вправо
        inc (hl)
        jr editcmd_scroll0
editcmd_noscrollright
;prcmd
        ld e,COLOR
        OS_SETCOLOR
        ld de,+(txtscrhgt-1)*256+0
        OS_SETXY
        ;ld hl,cmdprompt
        ld c,0
        ;call cmdprtext
        push bc
        ld a,'>'
        PRCHAR
        pop bc
        inc c
        ld hl,(curcmdscroll)
        ld h,0
        ld de,cmdbuf
        add hl,de
        call cmdprtext
;добьём остаток строки пробелами
prcmdspc0
        ld a,c
        cp txtscrwid-1 ;оставлям место справа для курсора
        ret z
        push bc
        ld a,' '
        PRCHAR
        pop bc
        inc c
        jp prcmdspc0

cmdprtext
cmdprtext0
        ld a,(hl)
        or a
        ret z
        push bc
        push hl
        PRCHAR ;testing (351/352t) (was 986/987t)
        pop hl
        pop bc
        inc c
        inc hl
        ld a,c
        cp txtscrwid-1 ;оставлям место справа для курсора
        jp nz,cmdprtext0
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

loginv
        ld a,e
        cpl
        ld e,a
        ld a,d
        cpl
        ld d,a
        ld a,l
        cpl
        ld l,a
        ld a,h
        cpl
        ld h,a
        ret
        

neghlde
        xor a
        sub e
        ld e,a
        ld a,0
        sbc a,d
        ld d,a
        ld a,0
        sbc a,l
        ld l,a
        ld a,0
        sbc a,h
        ld h,a
        ret

negbcde
        xor a
        sub e
        ld e,a
        ld a,0
        sbc a,d
        ld d,a
        ld a,0
        sbc a,c
        ld c,a
        ld a,0
        sbc a,b
        ld b,a
        ret

prlinenum_tomem
        ld bc,prdword_digit_tomem
        ld (prdword_digit_prchar_jp),bc
        ld hl,0
        jr prdword_subr
        
prword_de
;de=num
        ld hl,0
prdword_hlde
;hlde=num
        ld bc,prdword_digit_toscr
        ld (prdword_digit_prchar_jp),bc
        bit 7,h
        jr z,prdword_hlde_positive
        ld a,'-'
        call prdword_digit_prchar
        call neghlde
prdword_hlde_positive
prdword_subr
        ld a,' '
        ld (prnumdwordcmd_zero),a
        ld lx,0
        ld bc,1000000000/65536
        ld a,1000000000/256&#ff
        call prdword_digit
        ld bc,100000000/65536
        ld a,100000000/256&#ff
        call prdword_digit
        ld a,h
        ld lx,a
        ld h,l
        ld l,d
        ld d,e
        ld bc,10000000/256
        ld a,10000000&#ff ;0x989680
        call prdword_digit
        ld bc,1000000/256
        ld a,1000000&#ff
        call prdword_digit
        ld bc,100000/256
        ld a,100000&#ff
        call prdword_digit
        ld bc,10000/256
        ld a,10000&#ff
        call prdword_digit
        ld bc,1000/256
        ld a,1000&#ff
        call prdword_digit
        ld bc,100/256
        ld a,100&#ff
        call prdword_digit
        ld bc,10/256
        ld a,10&#ff
        call prdword_digit
        ld a,d
        add a,'0'
prdword_digit_prchar
prdword_digit_prchar_jp=$+1
        jp prdword_digit_tomem
prdword_digit_toscr
        push de
        push hl
        push ix
        PRCHAR
        pop ix
        pop hl
        pop de
        ret
prdword_digit_tomem
        exx
        ld (hl),a
        inc hl
        exx
        ret
prdword_digit
;hlde=num
;bca0=divisor
        push de
        ld e,a
        ld a,d
        ld d,'0'-1
;hla0=num
;bce0=divisor
;d=digit
prdword_digit0
        inc d
        sub e
        sbc hl,bc
        jr nc,prdword_digit0
        dec lx
        jp p,prdword_digit0
        add a,e
        adc hl,bc
        jr nc,$+4
        inc lx
         ld c,d ;digit
        pop de
        ld d,a ;hlde=num
         ld a,c ;digit
        cp '0'
        jr nz,prnumdwordcmd_nozero
prnumdwordcmd_zero=$+1
        ld a,' '
        cp ' '
        ret z
        jp prdword_digit_prchar
prnumdwordcmd_nozero
        call prdword_digit_prchar
        ld a,'0'
        ld (prnumdwordcmd_zero),a
        ret

prstr_withlen=prtext
;hl=straddr
        if 0
;hl=straddr (first byte = len (0..255))
        ld a,(hl)
        inc hl
        or a
        ret z
        ld b,a
prstr_withlen0
        push bc
        push hl
        ld a,(hl)
        PRCHAR
        pop hl
        inc hl
        pop bc
        djnz prstr_withlen0
        ret
        endif
        
;getvar_int
;a=name (char)
;out: hlde
        ;call findvar_int ;hl=addr
getint
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ret

;getvar_str
;a=name (char)
;out: hl=straddr (first byte = len (0..255))
        ;call findvar_str ;hl=addr
        ;ret

setvar_int
;a=name (char), hlde=value
        push hl
        call findvar_int ;hl=addr
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        pop de
        ld (hl),e
        inc hl
        ld (hl),d
        ret

setvar_str
;a=name (char), hl=straddr
        push hl
        call findvar_str ;hl=addr
        ex de,hl
        pop hl
strcopy
;hl -> de (first byte = len (0..255))
        ld bc,256
        ldir
        ret

addvar_int
;a=name (char)
        push de
        ld hl,(varend)
        ld d,h
        ld e,l
        inc hl
        inc hl
        inc hl
        inc hl
        ld (varend),hl
;de=addr
        ld h,varindex_int/256
        ld l,a
        ld (hl),e
        inc h
        ld (hl),d
        pop de
        ret

addvar_str
;a=name (char)
        push de
        ld hl,(varend)
        ld d,h
        ld e,l
        inc h
        ld (varend),hl
;de=addr
        ld h,varindex_int/256
        add a,128
        ld l,a
        ld (hl),e
        inc h
        ld (hl),d
        pop de
        ret

findvar_index
;TODO проверка типа переменной (int не разрешается)
findvar_array
;TODO проверка типа переменной
findvar_int
;TODO проверка типа переменной (index разрешается, array не разрешается)
;a=name (char)
;out: hl=addr, z=error
        ld h,varindex_int/256
        ld l,a
        ld a,(hl)
        inc h
        ld h,(hl)
        ld l,a
        or h
        ret

findvar_str
;a=name (char)
;out: hl=addr, z=error
        ld h,varindex_int/256
        add a,128
        ld l,a
        ld a,(hl)
        inc h
        ld h,(hl)
        ld l,a
        or h
        ret



cmd_line_parse
;hl= cmd line after basic.com and spaces
cmd_line_parse_loop
        ld a,(hl)
        cp "-"
        ret nz; не ключ, значит возврат
        inc hl
        ld a,(hl)
        cp "c"
        call z, case_key_c
        cp "n"
        call z, case_key_n
        cp "h"
        call z, case_key_h
        cp "V"
        call z, case_key_v
        inc hl
        call skipspaces
        jp cmd_line_parse_loop

case_key_c
        ld a,1
        ld (cmd_line_c),a
        ret
case_key_n
        ld a,1
        ld (cmd_line_n),a
        ret
case_key_h
        ld a,1
        ld (cmd_line_h),a
        ret
case_key_v
        ld a,1
        ld (cmd_line_v),a
        ret

cmd_line_c db 0
cmd_line_n db 0
cmd_line_h db 0
cmd_line_v db 0

        ;include "../_sdk/prdword.asm"
        
text
        db "Hello world!",0x0d,0x0a,0
        
cmdbuf
        ds MAXCMDSZ+1
        
syscmdbuf
        db "cmd "
wordbuf
        ds MAXCMDSZ+1

curdir
        ds MAXPATH_sz;MAXCMDSZ+1
        
;oldtimer
;        dw 0

execcmd_pars
        dw 0

curcmdscroll ;сдвиг команды относительно экрана
        db 0
curcmdx ;не на экране, а внутри команды
        db 0

progend
        dw progmem
varend
        dw varmem
        
        
        align 256
varindex_int ;varindex_str лежат по адресу+128
        ds 512

;varmem
        
cmd_end

	;display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "basic.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
