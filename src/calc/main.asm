        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

MAXCMDSZ=COMMANDLINE_sz-1;127 ;не считая терминатора
;txtscrhgt=25
txtscrwid=80
CMDLINEY=24

_COLOR=0x0007;7
_ERRORCOLOR=0x0009;0x42

        macro asmgetchar
        ld a,(de)
        endm
        
        macro asmnextchar
        inc de
        endm

       macro MATCH_NOEAT s1
        cp s1
        ret nz
       endm
       macro MATCH_NOGET s1
        cp s1
        ret nz
        asmnextchar ;eat
       endm
       macro MATCH s1
        MATCH_NOGET s1
        asmgetchar
       endm

        org PROGSTART
cmd_begin
        ld sp,0x4000 ;не должен опускаться ниже 0x3b00! иначе возможна порча OS        
        call initstdio

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
        
cmdmainloop
        call editcmd
        call prcrlf
        
        ld hl,cmdbuf
        ld de,oldcmd
        ld bc,MAXCMDSZ+1
        ldir

        ld hl,xnumstack
        ld (xnumstacktop),hl

        ld de,cmdbuf
        asmgetchar
;TODO определить тип команды (присваивание, вызов, ветвление)
        call matchexpr

        ld de,xnum1
        call popxnum
        ld hl,xnum1
        ld de,xOP1
        call mov10 ;без этого почему-то не работает
        ld hl,xOP1 ;куда печатаем?
         ld bc,xOP1 ;что печатаем?
        call xtostr
        ;ld hl,strout-1
        ld c,0
        call prtext
        call prcrlf

        xor a
        ld (cmdbuf),a
        ld (curcmdscroll),a
        jp cmdmainloop

cmd_exit
lastresult=$+1
       ld hl,0
        QUIT

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

execcmd
;a=0: command executed
;a!=0: no such internal command
        ld hl,cmdbuf
        ld a,(hl)
        or a
        ret z
        ld de,wordbuf
        call getword ;hl=terminator/space addr
        ;call skipspaces
        ;ld (execcmd_pars),hl
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

;;;;;;;;;;;;;;;;

matchexpr
;a=char (двигает курсор до первого символа, не годящегося для вычисления выражения, возвращает его в a)
;out: bc=result
        call matchmulexpr
        ret nz ;error
matchexpr_loop
;TODO << >> || ^^ == != < > <= >=
        cp '-'
        jr z,matchexpr_minus
        cp '+'
        jr z,matchexpr_plus
        ;cp '|'
        ;jr z,matchexpr_or
        ;cp '^'
        ;jr z,matchexpr_xor
        cp a
        ret ;z=no error (end of expr)
matchexpr_minus
        call compilepushold
        asmnextchar ;eat
        asmgetchar
        call matchmulexpr
        ret nz ;error
        call compilesuboldnew
        jr matchexpr_loop
matchexpr_plus
        call compilepushold
        asmnextchar ;eat
        asmgetchar
        call matchmulexpr
        ret nz ;error
        call compileaddnewold
        jr matchexpr_loop

matchmulexpr
;a=char (двигает курсор до первого символа, не годящегося для вычисления выражения, возвращает его в a)
;out: bc=result
        call matchval
        ret nz ;error
matchmulexpr_loop
;TODO &&
        cp '*'
        jr z,matchmulexpr_mul
        cp '/'
        jr z,matchmulexpr_div
        ;cp '&'
        ;jr z,matchmulexpr_and
        cp a
        ret ;z=no error (end of expr)
matchmulexpr_mul
        call compilepushold
        asmnextchar ;eat
        asmgetchar
        call matchval
        ret nz ;error
;TODO:
;если у нас слева не константа (где признак? af'?), то для неё уже сгенерирован код
;если у нас две константы, не делаем call mul, а вычисляем в bc как константу
        call compilemulnewold
        jr matchmulexpr_loop
matchmulexpr_div
        call compilepushold
        asmnextchar ;eat
        asmgetchar
        call matchval
        ret nz ;error
        call compiledivoldnew
        jr matchmulexpr_loop

matchval_plus
        asmnextchar ;eat
        asmgetchar
matchval
;nnn
;var ;TODO labels
;(expr)
;-val
;+val
        cp '-'
        jp z,matchval_minus
        cp '('
        jp z,matchval_bracket
        cp '#'
        jr z,matchval_hex
        cp '+'
        jr z,matchval_plus
        cp '.'
        jr z,matchdec
        sub '0'
        cp 10
        jr nc,matchval_nodigit
        add a,'0'
matchdec
        ld hl,wordbuf
matchdec0
        ld (hl),a
        inc hl
        asmnextchar
        asmgetchar
        cp '.'
        jr z,matchdec0
        cp '0'
        jr c,matchdec0q
        cp '0'+10
        jr c,matchdec0
matchdec0q
        cp 'e'
        jr nz,matchdecnoexp
        ld (hl),a
        inc hl
        asmnextchar
        asmgetchar
        cp '-'
        jr nz,matchdecnoexpminus
        ld (hl),a
        inc hl
        asmnextchar
        asmgetchar
matchdecnoexpminus
        sub '0'
        cp 10
        jr nc,matchval_nodigit
        add a,'0'
matchdec1
        ld (hl),a
        inc hl
        asmnextchar
        asmgetchar
        cp '0'
        jr c,matchdec1q
        cp '0'+10
        jr c,matchdec1
matchdec1q
matchdecnoexp
        ld (hl),0
       push af
       push de
        ld hl,wordbuf
        ld bc,xnum1
        call strtox
        ld hl,xnum1
        call pushxnum
       pop de
       pop af
        cp a ;z
        ret
matchval_nodigit
        add a,'0' ;как было (для следующих match)
;TODO функции

        ;dec c ;nz (error)
        or a ;nz (error)
        asmgetchar        
        ret

matchval_hex
        asmnextchar ;eat
        asmgetchar
        ld bc,0
matchval_hex0
        sub '0'+10
        cp -10
        jr c,matchval_hex_nodigit
matchval_hex_add
        add a,10
       dup 4
        sla c
        rl b
       edup
        or c
        ld c,a
        asmnextchar ;eat
        asmgetchar
        jr matchval_hex0
matchval_hex_nodigit
        sub 'a'-('0'+10)
        cp 6
        jr c,matchval_hex_add
        sub 'A'-'a'
        cp 6
        jr c,matchval_hex_add
        ;sub -'A' ;как было
       call compilenum_bc
        asmgetchar
        cp a ;z
        ret

matchval_minus
        asmnextchar ;eat
        asmgetchar
        call matchval
        ret nz
       call compileneg
        asmgetchar
        cp a ;z
        ret

matchval_bracket
        asmnextchar ;eat
        asmgetchar
        call matchexpr
        ret nz
        MATCH ')'
        ret

compilenum_bc
       push af
       push de
        ld h,b
        ld l,c
        ld bc,xnum1
        call i16tox ; Converts the 16-bit signed integer in HL to an extended precision float at BC ;TODO u64tox
        ld hl,xnum1
        call pushxnum
       pop de
       pop af
        ret

compilepushold
       push af
       push de
        ld de,xnum1
        call popxnum
        ld hl,xnum1
        call pushxnum
        ld hl,xnum1
        call pushxnum
       pop de
       pop af
        ret

compileaddnewold
       push af
       push de
        ld de,xnum1
        call popxnum
        ld de,xnum2
        call popxnum
        ld hl,xnum2
        ld de,xnum1
        ld bc,xOP1
        call xadd
        ld hl,xOP1
        call pushxnum
       pop de
       pop af
        ret

compilesuboldnew
       push af
       push de
        ld de,xnum1
        call popxnum
        ld de,xnum2
        call popxnum
        ld hl,xnum2
        ld de,xnum1
        ld bc,xOP1
        call xsub
        ld hl,xOP1
        call pushxnum
       pop de
       pop af
        ret

compilemulnewold
       push af
       push de
        ld de,xnum1
        call popxnum
        ld de,xnum2
        call popxnum
        ld hl,xnum2
        ld de,xnum1
        ld bc,xOP1
        call xmul
        ld hl,xOP1
        call pushxnum
       pop de
       pop af
        ret

compiledivoldnew
       push af
       push de
        ld de,xnum1
        call popxnum
        ld de,xnum2
        call popxnum
        ld hl,xnum2
        ld de,xnum1
        ld bc,xOP1
        call xdiv
        ld hl,xOP1
        call pushxnum
       pop de
       pop af
        ret

compileneg
       push af
       push de
        ld de,xnum1
        call popxnum
        ld hl,xnum1
        ld bc,xOP1
        call xneg
        ld hl,xOP1
        call pushxnum
       pop de
       pop af
        ret


cmd_sin
cmd_sqrt
        ret


;;;;;;;;;;;;;;

pushxnum
;hl=xnum to push
xnumstacktop=$+1
        ld de,xnumstack
        ld bc,10
        ldir
        ld (xnumstacktop),de
        ret
popxnum
;de=xnum buf to pop
        ld hl,(xnumstacktop)
        ld bc,-10
        add hl,bc
        ld (xnumstacktop),hl
        ld bc,10
        ldir
        ret

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

commandslist
        dw cmd_sin
        db "sin",0
        dw cmd_sqrt
        db "sqrt",0
        
        dw -1 ;конец таблицы команд

tunknowncommand
        db "Unknown command",0


        include "str.asm"
        include "cmdpr.asm"
        include "../_sdk/stdio.asm"

xOP1; = 8000h
        ds 182 ;162 for atan,182 for xlog
xOP2 = xOP1+10
xOP3 = xOP1+20
xOP4 = xOP1+30
xOP5 = xOP1+40
seed0=80F8h
seed1=80FCh

; Defines
;#define addx(o1,o2,d) ld hl,o1 \ ld de,o2 \ ld bc,d \ call xadd
;#define subx(o1,o2,d) ld hl,o1 \ ld de,o2 \ ld bc,d \ call xsub
;#define rsubx(o1,o2,d) ld hl,o1 \ ld de,o2 \ ld bc,d \ call xrsub
;#define mulx(o1,o2,d) ld hl,o1 \ ld de,o2 \ ld bc,d \ call xmul
;#define divx(o1,o2,d) ld hl,o1 \ ld de,o2 \ ld bc,d \ call xdiv
;#define sqrtx(o1,d) ld hl,o1 \ ld bc,d \ call xsqrt
;#define strx(o1,d) ld hl,o1 \ ld bc,d \ call xtostr
;#define movx(src,dest)  ld hl,src \ ld de,dest \ call mov10

; Macros
        macro dec_hl_opt x
        if ((x)&255)>0
  dec l
        else
  dec hl
        endif
        endm

        macro inc_hl_opt x
        if ((x)&255)<255
  inc l
        else
  inc hl
        endif
        endm

        include "extended/constantsx.asm"
        include "extended/xadd.asm"
        include "extended/xsub.asm"
        include "extended/xmul.asm"
        include "extended/xdiv.asm"
        include "extended/xcmp.asm"
        include "extended/xneg.asm"
        include "extended/xabs.asm"
        include "extended/xsqrt.asm"
        include "extended/xln.asm"
        include "extended/xlog.asm" ;log_y(x) (делается через xln)
        include "extended/xlg.asm" ;log2(x) (делается через xln)
        include "extended/xlog10.asm" ;log10(x) (делается через xln)
        include "extended/xexp.asm" ;e^x (делается через xpow2)
        include "extended/xpow.asm" ;x^y (делается через xpow2)
        include "extended/xpow10.asm" ;10^x (делается через xpow2)
        include "extended/xsin.asm"
        include "extended/xcos.asm"
        include "extended/xtan.asm"
        include "extended/xasin.asm"
        include "extended/xacos.asm"
        include "extended/xatan.asm"
        include "extended/xsinh.asm"
        include "extended/xcosh.asm"
        include "extended/xtanh.asm"
        include "extended/xasinh.asm"
        include "extended/xacosh.asm"
        include "extended/xatanh.asm"
        include "extended/xrand.asm"
        include "extended/xtostr.asm"
        include "extended/strtox.asm"

wordbuf
        ds MAXCMDSZ+1
oldcmd
        ds MAXCMDSZ+1

xnum1
        ds 10
xnum2
        ds 10
xnum3
        ds 10

xnumstack
;продолжается дальше вперёд

cmd_end

	;display "cmd size ",/d,cmd_end-cmd_begin," bytes"

	savebin "calc.com",cmd_begin,cmd_end-cmd_begin
	
	LABELSLIST "..\..\us\user.l",1
