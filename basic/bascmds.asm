functionslist
        dw func_rnd
        db "$rnd",0
        
        dw -1 ;конец таблицы функций

getval_function
;hl'=text
        call eatword
        ld hl,functionslist ;list of internal commands
getval_function0
        ld c,(hl)
        inc hl
        ld b,(hl) ;адрес процедуры, соответствующей этой команде
        inc hl
        ld a,b
        cp -1
        jp z,fail ;ret z ;jr z,strcpexec_tryrun ;a!=0: no such internal command
        ld de,wordbuf
        push hl
        call strcp
        pop hl
        jr nz,getval_function_fail
        ld h,b
        ld l,c
        jp (hl) ;run internal command
getval_function_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr getval_function0

commandslist
        dw cmd_for
        db "for",0
        dw cmd_next
        db "next",0
        
        dw cmd_clear
        db "clear",0
        dw cmd_new
        db "new",0
        dw cmd_quit
        db "quit",0
        dw cmd_run
        db "run",0
        dw cmd_goto
        db "goto",0
        dw cmd_edit
        db "edit",0
        dw cmd_list
        db "list",0
        dw cmd_save
        db "save",0
        dw cmd_load
        db "load",0
        dw cmd_system
        db "system",0
        dw cmd_pause
        db "pause",0
        
        dw cmd_let
        db "let",0
        dw cmd_dim
        db "dim",0
        dw cmd_print
        db "print",0
        dw cmd_cls
        db "cls",0
        dw cmd_gfx
        db "gfx",0
        dw cmd_plot
        db "plot",0
        dw cmd_line
        db "line",0
        
        dw cmd_if
        db "if",0
        dw cmd_then
        db "then",0
        dw cmd_colon
        db ":",0
        dw cmd_rem
        db "rem",0
        
        dw -1 ;конец таблицы команд

docmd
;hl'=text
        exx
        push hl
        GET_KEY
        pop hl
        exx
        cp csSpace
        jp z,endbreak

        call eatword
        ld hl,commandslist ;list of internal commands
strcpexec0
        ld c,(hl)
        inc hl
        ld b,(hl) ;адрес процедуры, соответствующей этой команде
        inc hl
        ld a,b
        cp -1
        jp z,fail ;ret z ;jr z,strcpexec_tryrun ;a!=0: no such internal command
        ld de,wordbuf
        push hl
        call strcp
        pop hl
        jr nz,strcpexec_fail
        ld h,b
        ld l,c
        jp (hl) ;run internal command
strcpexec_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr strcpexec0
        
eat
;hl'=курсор
        exx
        inc hl
        call skipspaces
        exx
        ret

eatword
        exx
        ld de,wordbuf
        call getword
        call skipspaces
        exx
        ret

eatclosebracket
        exx
        ld a,(hl)
        exx
        cp ')'
        jp nz,fail
        jp eat
        
eateq
        exx
        ld a,(hl)
        exx
        cp '='
        jp nz,fail
        jp eat
        
eatcomma
        exx
        ld a,(hl)
        exx
        cp ','
        jp nz,fail
        jp eat
        
cmd_pause
        exx
        push hl
        YIELDGETKEYLOOP
        pop hl
        exx
        ret

cmd_gfx
        call getexpr
        exx
        push hl
        exx
        ld a,e
        and 7
        OS_SETGFX
        pop hl
        exx
        ret

getexprcolor
;out: a=color = %33210210
        call getexpr
        ld a,e
        and 7
        ld d,a
        ld a,e
        and 15
        add a,a
        add a,a
        add a,a
        or d ;%.3210210
        rlca
        rlca ;%210210.3, CY=3
        rra  ;%3210210., CY=3
        rra  ;%33210210
        ret

cmd_line
;hl'=курсор
;line x2,y2,color
        call getexpr
        ld (cmd_line_x2),de
        call eatcomma
        call getexpr
        ld (cmd_line_y2),de
        call eatcomma
        call getexprcolor ;a=color = %33210210

        push af ;color
        call setpgs_scr
        pop af ;color
        ld bc,(cmd_plot_x)
        ld de,(cmd_plot_y)
cmd_line_x2=$+2
        ld ix,0
        ld (cmd_plot_x),ix
cmd_line_y2=$+1
        ld hl,0
        ld (cmd_plot_y),hl
;bc=x (в плоскости экрана, но может быть отрицательным)
;de=y (в плоскости экрана, но может быть отрицательным)
;ix=x2
;hl=y2
;a=color = %332103210
        exx
        push hl
        exx
        call shapes_line
        ;exx
        pop hl
        exx
        jp restorebasicpages
        
cmd_plot
;hl'=курсор
;plot x,y,color
        call getexpr
        ld (cmd_plot_x),de
        call eatcomma
        call getexpr
        ld (cmd_plot_y),de
        call eatcomma
        call getexprcolor
        ld lx,a ;lx=color = %33210210
cmd_plot_x=$+1
        ld hl,0
        ld bc,320
        or a
        sbc hl,bc
        add hl,bc
        ret nc
        ex de,hl
        
cmd_plot_y=$+1
        ld hl,0
        ld bc,200
        or a
        sbc hl,bc
        add hl,bc
        ret nc
;l=y
        call setpgs_scr
        ld c,l
;de=x
;c=y
;lx=color = %33210210
        call prpixel
        jp restorebasicpages

setpgs_scr
setpgs_scr_low=$+1
        ld a,0;pgscr0_0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0;pgscr0_1 ;scr0_1
        SETPG32KHIGH
        ret

        
scrbase=0x8000
prpixel
;de=x (не портится)
;c=y (bc не портится)
;lx=color = %33210210
       ld a,b
        ld l,c
        ld h,0
        ld b,scrbase/256/8 ;h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
       ld b,a
prpixel_cury
;de=x (не портится)
;hl=addr(y)
;lx=color = %33210210
        ld a,d
        rra
        ld a,e
        rra
        jr c,prpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and %00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,lx
        xor (hl)
        and %01000111 ;keep left pixel 
        xor (hl) ;right pixel from screen
        ld (hl),a
        ret
prpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and %00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,lx
        xor (hl)
        and %10111000 ;keep right pixel 
        xor (hl) ;left pixel from screen
        ld (hl),a
        ret

shapes_line
;bc=x (в плоскости экрана, но может быть отрицательным)
;de=y (в плоскости экрана, но может быть отрицательным)
;ix=x2
;hl=y2
;a=color = %332103210
        ld (line_pixel_color),a
        or a
        sbc hl,de
        add hl,de
        jp p,shapes_line_noswap
        ex de,hl ;y <-> y2
        push ix
        push bc
        pop ix
        pop bc ;x <-> x2
shapes_line_noswap
        or a
        sbc hl,de ;dy >= 0
        push hl ;dy
        push ix
        pop hl
        sbc hl,bc
        push hl ;dx
        exx
        pop bc ;dx
        ld a,#03 ;inc bc
        jp p,shapes_line_nodec
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;dx >= 0
        ld a,#0b ;dec bc
shapes_line_nodec
        pop de ;dy
;a=код inc/dec bc
;bc'=x (в плоскости экрана, но может быть отрицательным)
;de'=y (в плоскости экрана, но может быть отрицательным)
;bc=dx
;de=dy
        ex de,hl
        or a
        sbc hl,bc
        add hl,bc
        ex de,hl
        jr nc,shapes_linever ;dy>=dx
        ld hy,b
        ld ly,c ;counter=dx
        inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,b
        ld l,c
        sra h
        rr l ;ym=dx div 2 ;TODO а если dx<0?
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mym=256-(dx div 2)
        exx
        ld (shapes_lineincx),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linehor0
        call line_pixel
shapes_lineincx=$
        inc bc ;x+1        
        exx
        ;add hl,de ;mym+dy
        or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehor1
        inc de ;y+1
        exx
        ;or a
        ;sbc hl,bc ;mym-dx
        add hl,bc ;ym+dx
        exx
shapes_linehor1
        dec iy
        ld a,hy
        rla
        jp nc,shapes_linehor0
        ret
shapes_linever
        ld hy,d
        ld ly,e ;counter=dy
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,d
        ld l,e
        sra h
        rr l
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mxm=256-(dy div 2)
        exx
        ld (shapes_lineincx2),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linever0
        call line_pixel
        inc de ;y+1
        exx
        ;add hl,bc ;mxm+dx
        or a
        sbc hl,bc ;xm-dx ;TODO а если dx<0?
        exx
        jr nc,shapes_linever1
shapes_lineincx2=$
        inc bc ;x+1
        exx
        ;or a
        ;sbc hl,de ;mxm-dy
        add hl,de ;xm+dy
        exx
shapes_linever1
        dec iy
        ld a,hy
        rla
        jp nc,shapes_linever0
        ret

line_pixel
;bc=x (может быть отрицательным)
;de=y (может быть отрицательным)
        ld hl,199
        or a
        sbc hl,de ;y
        ret c ;y>199
        ld hl,319
        or a
        sbc hl,bc ;x
        ret c ;x>319
        push bc
        push de
        push ix
        ld a,e
        ld d,b
        ld e,c ;de=x
        ld c,a ;c=y
line_pixel_color=$+2
        ld lx,0
;de=x (не портится)
;c=y (bc не портится)
;lx=color = %33210210
        call prpixel
        pop ix
        pop de
        pop bc
        ret
        
cmd_system
;hl'=курсор
;system "command params"
        call getexpr
        bit 7,c
        jp z,fail
        exx
        push hl
        exx
;hl = wordbuf = string

        ld de,curdir ;DE = Pointer to 64 byte buffer
        OS_GETPATH
        OS_SETSYSDRV ;TODO каталог cmd
        
        ld de,tcmd
        OS_OPENHANDLE
        or a
        jp nz,fail
        ld a,b
        ld (cmd_system_handle),a
        OS_NEWAPP
        or a
        jp nz,close_restoredir_fail
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id
        
        ld a,d
        SETPG32KHIGH
        push de
        push hl
        ld hl,syscmdbuf
        ld de,#c000+COMMANDLINE
        ld bc,COMMANDLINE_sz
        ldir ;command line
        xor a
        ld (#c000+COMMANDLINE+COMMANDLINE_sz-1),a ;на случай, если "cmd "+wordbuf больше 128 байт
        pop hl
        pop de
cmd_system_handle=$+1
        ld b,0
        call readfile_pages_dehl
        call cmd_system_close_restoredir

        pop af ;a=id
        ld e,a
        push de
        OS_RUNAPP
        pop de
        WAITPID
        pop hl
        exx
        ret
        
cmd_system_close_restoredir
        ld a,(cmd_system_handle)
        ld b,a
        OS_CLOSEHANDLE
        ld de,curdir
        OS_CHDIR
        jp restorebasicpages
        
close_restoredir_fail
        call cmd_system_close_restoredir
        jp fail

popret
        pop af
        ret
readfile_pages_dehl
        ld a,d
        push bc
        SETPG32KHIGH
        pop bc
         ld a,e
         push af
        ld a,+(#c000+PROGSTART)/256
        call cmd_loadpage
        jr nz,popret
         pop af ;e
        call cmd_setpgloadpage
        ret nz
        ld a,h
        call cmd_setpgloadpage
        ret nz
        ld a,l
cmd_setpgloadpage
        push bc
        SETPG32KHIGH
        pop bc
        ld a,#c000/256
cmd_loadpage
;a=loadaddr/256
;b=handle
;out: de=bytes read, NZ=end of file
;keeps hl,bc
        push bc
        push hl
        ld d,a
        ld e,0
        ld hl,0
        or a
        sbc hl,de
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push hl
        OS_READHANDLE
;HL = Number of bytes actually read, A=error(=0)
        ex de,hl
        pop hl
        or a
        sbc hl,de ;Number of bytes to read - Number of bytes actually read
        pop hl
        pop bc
        ret


tcmd
        db "cmd.com",0
        
        
cmd_load
;hl'=курсор
;load "name.bas"
        call getexpr
        bit 7,c
        jp z,fail
        call cmd_load_hl
;нельзя выходить по ret, потому что старая программа уничтожена
        jp endofprog
        
cmd_load_hl
;hl = wordbuf = filename
        ;exx
        ;ld a,(hl)
        ;exx
        ;cp '"'
        ;jp nz,fail
        ;call readstr
        ;jp c,fail
;wordbuf = filename
        ;ld de,wordbuf ;de=drive/path/file
        ex de,hl
        OS_OPENHANDLE
;b=new file handle
        or a
        jp nz,fail
        ld de,progmem
        ld hl,szprogmem
;B = file handle, DE = Buffer address, HL = Number of bytes to read
        push bc
        OS_READHANDLE
        pop bc
;HL = Number of bytes actually read, A=error
        ld de,progmem
        add hl,de
        ld (progend),hl
        OS_CLOSEHANDLE        
        call cmd_clear
        ret

cmd_save
;hl'=курсор
;save "name.bas"
        call getexpr
        bit 7,c
        jp z,fail
        ;exx
        ;ld a,(hl)
        ;exx
        ;cp '"'
        ;jp nz,fail
        ;call readstr
        ;jp c,fail
;wordbuf = filename
        ;ld de,wordbuf ;de=drive/path/file
        ex de,hl
        OS_CREATEHANDLE
;b=new file handle
        or a
        jp nz,fail
        ld hl,(progend)
        ld de,progmem
        ;or a
        sbc hl,de
;B = file handle, DE = Buffer address, HL = Number of bytes to write
        push bc
        OS_WRITEHANDLE
        pop bc
        OS_CLOSEHANDLE        
        ret
        
cmd_new
        ld hl,progmem
        ld (progend),hl
        call cmd_clear
        jp endofprog

cmd_clear
        ld hl,varmem
        ld (varend),hl
        ld hl,varindex_int
        ld de,varindex_int+1
        ld bc,511
        ld (hl),l;0
        ldir
        ret
        
cmd_rem
        jp gotonextline
        
cmd_for
;hl'=курсор
;for i=1 to 10 step 2
;параметры цикла (4+4(step)+4(to)+4(goto) байта)
        exx
        ld a,(hl)
        exx
        ld c,a ;имя
        call eat
        
        ld a,c
        call findvar_index
        jr nz,cmd_for_nocreate
        ld hl,(varend)
        push hl
        ld de,4*4
        add hl,de
        ld (varend),hl
        pop de
;de=addr
        ld h,varindex_int/256
        ld l,c
        ld (hl),e
        inc h
        ld (hl),d
cmd_for_nocreate

        call eateq
        push bc
        call getexpr
        pop bc
        ld a,c
        call setvar_int
        
        call eatword ;to
        
        push bc
        call getexpr
        pop bc
        push hl ;HSW
        push de ;LSW
        ld a,c
        call findvar_index
        ld de,4+4
        add hl,de
        pop de ;LSW
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        pop de ;HSW
        ld (hl),e
        inc hl
        ld (hl),d
        
        call eatword ;step
        
        push bc
        call getexpr ;hlde=step
        pop bc
        
        ld a, h
        or l
        or d
        or e
        jp z,fail
               
        push hl ;HSW
        push de ;LSW
        ld a,c
        call findvar_index
        ld de,4
        add hl,de
        pop de ;LSW
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        pop de ;HSW
        ld (hl),e
        inc hl
        ld (hl),d
        
        ld a,c
        call findvar_index
        ld de,4+4+4
        add hl,de
;currunline=$+1
        ;ld de,0
        ;inc de
        exx
        push hl
        exx
        pop de
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0

        ret
        
cmd_next
;hl'=курсор
;next i (i = i+step, if i<=to then goto...)
        exx
        ld a,(hl)
        exx
        ld c,a ;имя
        call eat
        
        ld a,c
        call findvar_index
        jp z,fail
        
        push hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl ;bcde = i
        
        ld a,(hl)
        add a,e
        ld e,a
        inc hl
        ld a,(hl)
        adc a,d
        ld d,a
        inc hl
        ld a,(hl)
        adc a,c
        ld c,a
        inc hl
        ld a,(hl)
        adc a,b
        ld b,a ;bcde = i = i+step
        
        ex (sp),hl
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        pop hl
        
        bit 7,(hl) ;step>=0?
        push af
        inc hl
        
;to>=i?
        ld a,(hl)
        sub e
        ld e,a
        inc hl
        ld a,(hl)
        sbc a,d
        ld d,a
        inc hl
        ld a,(hl)
        sbc a,c
        ld c,a
        inc hl
        ld a,(hl)
        sbc a,b
        ld b,a
        inc hl
;bcde = to-i
;TODO знаковое переполнение
        pop af ;NZ = step<0
        call nz,negbcde
;i<=to (to-i >= 0) - continue loop
        bit 7,b ;Z = to-i>=0
        ret nz ;end of loop
        call getint ;de=адрес после for ;было hlde=номер строки
        ex de,hl
        exx
        ret
        ;jp cmd_goto_ok
        
cmd_dim
;hl'=курсор
;dim a(15) - нумерация элементов с нуля
        exx
        ld a,(hl)
        exx
        ld c,a ;имя
        call eat
        
        ld a,c
        call findvar_array
        jp nz,fail ;уже есть такая переменная

        exx
        ld a,(hl)
        exx
        cp '('
        jp nz,fail
        call eat
        push bc
        call getexpr
        pop bc
        call eatclosebracket
        
;hlde=de=size

;c=name (char)
        ld hl,(varend)
        push hl
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        add hl,de
        add hl,de
        add hl,de
        add hl,de
        ld (varend),hl
        pop de
;de=addr
        ld h,varindex_int/256
        ld l,c
        ld (hl),e
        inc h
        ld (hl),d
        ret
        
cmd_edit
;hl'=курсор
        call getexpr
        call findline
        ld a,(hl)
        cp d
        jp nz,fail
        inc hl
        ld a,(hl)
        cp e
        jp nz,fail
        ;hl=адрес строки, которую надо взять + 1
        inc hl
        inc hl
        inc hl
        
        push hl
        exx
        ld hl,cmdbuf
        exx
        call prlinenum_tomem
        exx
        ld (hl),' '
        inc hl
        push hl
        exx
        pop de ;cmdbuf+номер
        pop hl ;hl=адрес строки (текст)
        
        push hl
        call strlen
        ld b,h
        ld c,l
        inc bc ;длина с терминатором
        pop hl
        
        ;ld de,cmdbuf
        ;ld bc,MAXCMDSZ+1
        ldir
        jp endofedit
        
cmd_then
cmd_colon
        ret
        
cmd_list
;номер строки(ст,мл), длина строки(мл,ст), строка(asciiz)
        ld hl,progmem
list_lines0
        ld de,(progend)
        or a
        sbc hl,de
        add hl,de
        ret z
        
        push hl
        ;exx
        ;push hl
        GET_KEY
        ;pop hl
        ;exx
        pop hl
        cp csSpace
        jp z,endbreak

        ld d,(hl)
        inc hl
        ld e,(hl) ;номер строки
        inc hl
        push hl
        call prword_de ;номер строки
        ld a,' '
        PRCHAR
        
        pop hl
        ;ld e,(hl)
        inc hl
        ;ld d,(hl) ;длина строки
        inc hl
        call prtext ;hl after terminator
        
        call prcrlf
        jr list_lines0
        
        
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
        

cmd_let
;hl'=курсор
        exx ;ld hl,(execcmd_pars)
        ld a,(hl)
        exx
        ld c,a
        exx
        inc hl ;call eat
        ld a,(hl)
        exx
        cp '$'
        jr z,cmd_let_str
        cp '('
        jr z,cmd_let_array
;hl'=курсор
        call eatspaces
        call eateq
        ld a,c
        call findvar_int
        jr nz,cmd_let_createq
        ld a,c
        call addvar_int
cmd_let_createq
        push bc
        call getexpr ;hlde=value
        pop bc ;иначе выражение может запороть c
        ld a,c
        call setvar_int ;TODO не искать переменную второй раз
        ret

cmd_let_array
        call eat ;skip '(' and spaces
        push bc
        call getexpr
        pop bc
        call eatclosebracket
        ld a,c
        call findvar_int
        jp z,fail
        call indexarray
        push hl ;адрес элемента
        call eateq
        call getexpr ;hlde
        ld b,h
        ld c,l ;bcde
        pop hl ;адрес элемента
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (hl),c
        inc hl
        ld (hl),b
        ret
        
cmd_let_str
        call eat ;skip '$' and spaces
        exx
        ld a,(hl)
        exx
        cp '('
        jr z,cmd_let_strarray
        ld a,c
        call findvar_str
        jr nz,cmd_let_str_createq
        ld a,c
        call addvar_str
cmd_let_str_createq
;hl'=курсор
        call eateq
        exx
        ld a,(hl)
        exx
        cp '"'
        jp nz,fail
        
        call readstr ;hl=str, hl'=after num and spaces, CY=error
        jp c,fail
        
        ;ld hl,wordbuf
        ;STRPUSH
        
        ;ld hl,wordbuf
        ld a,c
        call setvar_str
        
        ;ld hl,wordbuf
        ;STRPOP
        
        ret

cmd_let_strarray
        call eat ;skip '(' and spaces
        push bc
        call getexpr ;hlde=index
        pop bc
        call eatclosebracket
        call eateq
        ld a,c
        call findvar_str
        jp z,fail
        ld a,d
        or a
        jp nz,fail ;range check
        add hl,de
        push hl ;addr in str
        call getexpr ;hlde=char
        pop hl ;addr in str       
        ld (hl),e
        ret
        
cmd_cls
        exx
        push hl
        ld e,0;COLOR
        OS_CLS
        pop hl
        exx
        ret

cmd_if
;hl'=курсор
        call getexpr
	ld a,h
	or l
	or d
	or e
	ret nz ;true = continue this line
gotonextline
	exx
	xor a
	ld bc,0
	cpir
        dec hl ;на терминаторе	
	ld a,(runmode)
	cp RUNMODE_PROG
	jr nz,gotonextlineq
        inc hl ;после строки
        call startline
gotonextlineq
	exx
	ret
        
cmd_goto
;hl'=курсор
        call getexpr
cmd_goto_ok
;hlde=номер строки
        call findline
        call startline
        exx
        ld a,RUNMODE_PROG
        ld (runmode),a
        ret


cmd_run
;нельзя выходить по ret, потому что run могли вызвать из обработчика командной строки
        ld a,RUNMODE_PROG
        ld (runmode),a
        ld hl,progmem
        jr cmd_run_startline
cmd_run0
;hl'=адрес строки
        exx
        ld a,(hl)
        or a
        jr nz,cmd_run_nonextline
runmode=$+1
        ld a,0
        cp RUNMODE_INTERACTIVE
        jp z,endofprog ;ret z ;end of line in interactive mode
        inc hl
cmd_run_startline
        call startline
cmd_run_nonextline
        exx
        call docmd
        jr cmd_run0

startline
        ld bc,(progend)
        or a
        sbc hl,bc
        add hl,bc
        jp nc,endofprog ;ret nc ;end of program
        ;ld d,(hl)
        inc hl
        ;ld e,(hl)
        inc hl
        ;ld (currunline),de
        ;ld e,(hl)
        inc hl
        ;ld d,(hl) ;line size
        inc hl
        ret
        
eatcolon
;out: z=end of command
        exx
        ld a,(hl)
        exx
        or a
        ret z
        cp ':'
        ret nz
        call eat
        xor a ;Z
        ret
        
cmd_print
;hl'=курсор
        call eatcolon
        jp z,prcrlf
cmd_print0
        exx
        ld a,(hl)
        exx
        cp ';'
        jp z,cmd_print_semicolon
        call getexpr
        call prval
        jr cmd_print
cmd_print_semicolon
        call eat
        call eatcolon
        jr nz,cmd_print ;TODO cmd_print0?
        ret
        
getexpr
;out: hlde=value, c=type
        call getaddexpr
getexpr0        
        exx
        ld a,(hl)
        exx
        ;cp ','
        ;ret z ;jp z,eat
        ;cp ')'
        ;ret z ;jp z,eat
        ;cp ':' ;call eatcolon
        ;ret z
        ;or a
        ;ret z
        cp '='
        jr z,getexpr_eq
        cp '>'
        jr z,getexpr_more
        cp '<'
        jr z,getexpr_less
        ret
        
getexpr_eq
        call eat
        call getexpr_eq_subr
        jr getexpr0
        
getexpr_more
        call eat
        exx
        ld a,(hl)
        exx
        cp '='
        jr z,getexpr_moreeq
        call getexpr_more_subr
        jr getexpr0

getexpr_less
        call eat
        exx
        ld a,(hl)
        exx
        cp '='
        jr z,getexpr_lesseq
        cp '>'
        jr z,getexpr_noteq
        call getexpr_less_subr
        jr getexpr0
        
getexpr_noteq
        call eat
        call getexpr_eq_subr
        call loginv
        jr getexpr0

getexpr_moreeq
        call eat
        call getexpr_less_subr
        call loginv
        jr getexpr0

getexpr_lesseq
        call eat
        call getexpr_more_subr
        call loginv
        jr getexpr0

getexpr_more_subr        
;old > new: new-old = CY
        push bc
        push hl ;HSW
        push de ;LSW
        call getaddexpr
        pop bc ;LSW
        ex de,hl
	or a
        sbc hl,bc
        ex de,hl
        pop bc ;HSW
        sbc hl,bc
        pop bc
	ld hl,0
	ld de,0
	ret nc
	dec hl
	dec de ;old > new
        ret
        
getexpr_less_subr
;old < new: old-new = CY
        push bc
        push hl ;old HSW
        push de ;old LSW
        call getaddexpr
	pop bc ;old LSW
	pop af ;old HSW
	push hl ;new HSW
	push de ;new LSW
        push af ;old HSW
        push bc ;old LSW
	pop de ;old LSW
	pop hl ;old HSW
	
        pop bc ;LSW
        ex de,hl
	or a
        sbc hl,bc
        ex de,hl
        pop bc ;HSW
        sbc hl,bc
        pop bc
	ld hl,0
	ld de,0
	ret nc
	dec hl
	dec de ;old < new
        ret

getexpr_eq_subr
        push bc
        push hl ;HSW
        push de ;LSW
        call getaddexpr
        pop bc ;LSW
        ex de,hl
	or a
        sbc hl,bc
        ex de,hl
        pop bc ;HSW
        sbc hl,bc
	ld a,d
	or e
	or h
	or l
        pop bc
	ld hl,0
	ld de,0
	ret nz
	dec hl
	dec de ;old = new
        ret
        
getaddexpr
        call getmulexpr
getaddexpr0        
        exx
        ld a,(hl)
        exx
        ;or a
        ;ret z
        ;cp ')'
        ;ret z ;jp z,eat
        ;cp ','
        ;ret z ;jp z,eat
        ;cp ':' ;call eatcolon
        ;ret z
        cp '+'
        jr z,getaddexpr_plus
        cp '-'
        jr z,getaddexpr_minus
        ret
        
getaddexpr_plus
        call eat
        push bc
        push hl ;HSW
        push de ;LSW
        call getmulexpr
        pop bc ;LSW
        ex de,hl
        add hl,bc
        ex de,hl
        pop bc ;HSW
        adc hl,bc
        pop bc
        jr getaddexpr0
        
getaddexpr_minus
        call eat
        push bc
        push hl ;HSW
        push de ;LSW
        call getmulexpr
        pop bc ;LSW
        ex de,hl
        or a
        sbc hl,bc
        ex de,hl
        pop bc ;HSW
        sbc hl,bc
        call neghlde
        pop bc
        jr getaddexpr0

getmulexpr
        call getval_
getmulexpr0        
        exx
        ld a,(hl)
        exx
        ;or a
        ;ret z
        ;cp ')'
        ;ret z ;jp z,eat
        ;cp ','
        ;ret z ;jp z,eat
        ;cp ':' ;call eatcolon
        ;ret z
        cp '*'
        jr z,getmulexpr_mul
        cp '/'
        jr z,getmulexpr_div
        ret
        
getmulexpr_div
        call eat
        push bc
        push hl ;HSW old
        push de ;LSW old
        call getval_
        push hl ;LSW new
        push de ;HSW new
        exx
        pop ix ;LSW new
        pop bc ;HSW new
        pop de ;LSW old
        ex (sp),hl ;pop hl ;HSW old
        call _DIVLONG.
        exx
        pop hl ;курсор
        exx
        pop bc
        jr getmulexpr0

getmulexpr_mul
        call eat
        push bc
        push hl ;HSW
        push de ;LSW
        call getval_
        pop ix ;LSW
        pop bc ;HSW
        call _MULLONG.
        pop bc
        jr getmulexpr0
        
;hl, de / bc, ix
;out: hl(high), de(low)
_DIVLONG.
	;EXPORT _DIVLONG.
	ld a,h
	xor b
	push af
	xor b
	call m,neghlde
	ld a,b
	rla
	jr nc,divlongnonegbcix
	xor a
	sub lx
	ld lx,a
	ld a,0
	sbc a,hx
	ld hx,a
	ld a,0
	sbc a,c
	ld c,a
	ld a,0
	sbc a,b
	ld b,a
divlongnonegbcix
;unsigned!!!
;hl'hl,de'de <= hlde,bcix:
	push bc
	exx
	pop de ;de' = "bc_in"
	ld hl,0
	exx
	ld a,e
	ex af,af' ;e_in
	push de ;d_in
	ld c,l ;l_in
	ld a,h ;h_in
	ld hl,0
	push ix
	pop de ;de = "ix_in"
	;a="h_in"
;hl'hla <= 0000h_in
	call _DIVLONGP. ;"h"
	ld b,c ;"l_in"
	ld c,a ;"h"
	ld a,b ;a="l_in"
;hl'hla <= 000hl_in
	call _DIVLONGP. ;"l"
	ld b,a ;"l"
	pop af ;a="d_in"
	push bc ;b="l"
;hl'hla <= 00hld_in
	call _DIVLONGP. ;"d"
	ex af,af' ;a="e_in", a'="d"
	;a="e_in"
;hl'hla <= 0hlde_in
	call _DIVLONGP. ;"e"
	ld e,a ;"e"
	ex af,af' ;"d"
	ld d,a
	pop hl ;h="l"
	ld l,h
	ld h,c ;"h"
	
	pop af
	ret p
	jp neghlde
;a = hl'hla/de'de
;c not used
_DIVLONGP.
;do 8 bits
	ld b,8
_DIVLONG0.
;shift left hl'hla
	rla
	adc hl,hl
	exx
	adc hl,hl
	exx
;no carry
;try sub
	sbc hl,de
	exx
	sbc hl,de
	exx
	jr nc,$+2+1+1+2+1
	add hl,de
	exx
	adc hl,de
	exx
;carry = inverted bit of result
	djnz _DIVLONG0.
	rla
	cpl
	ret
        
;hl, de * bc, ix
;out: hl(high), de(low)
_MULLONG.
	;EXPORT _MULLONG.
;signed mul is equal to unsigned mul
;hlde*bcix = hlde*b000 + hlde*c00 + hlde*i0 + hlde*x
	ld a,lx
	push af ;lx
	push ix ;hx
	ld a,c
	push af ;c
	ld a,b
;bcde <= hlde:
	ld b,h
	ld c,l
;hlix <= 0
	ld hl,0
	;ld ix,0
	push hl
	pop ix
	call _MULLONGP. ;hlix = (hlix<<8) + "b*hlde"
	pop af ;c
	call _MULLONGP. ;hlix = (hlix<<8) + "c*hlde"
	pop af ;hx
	call _MULLONGP. ;hlix = (hlix<<8) + "hx*hlde"
	pop af ;lx
	call _MULLONGP. ;hlix = (hlix<<8) + "lx*hlde"
	push ix
	pop de
	ret
;hlix = (hlix<<8) + a*bcde
_MULLONGP.
	exx
	ld b,8
_MULLONG0.
	exx
	add ix,ix
	adc hl,hl
	rla
	jr nc,$+2+2+2
	add ix,de
	adc hl,bc
	exx
	djnz _MULLONG0. ;можно по a==0 (первый вход с scf:rla, далее add a,a)
	exx
	ret


        
getval_unaryminus
        call eat
        call getval_
        jp neghlde
getval_bracket
        call eat
        call getexpr
        jp eatclosebracket
        
getval_
;hl'=курсор
;out: hlde=value, c=type
        exx
        ld a,(hl)
        exx
        cp '$'
        jp z,getval_function
        cp '-'
        jr z,getval_unaryminus
        cp '('
        jr z,getval_bracket
        cp '"'
        jr z,getval_str
        sub '0'
        cp 10
        jr c,getval_num
        exx
        ld a,(hl)
        exx
        ld c,a ;name
        exx
        inc hl ;call eat
        ld a,(hl)
        exx
        cp '$'
        jr z,getval_varstr
        cp '('
        jr z,getval_vararray
        call eatspaces
        ld a,c
        call findvar_int
        jp z,fail
        ;ld a,c
        ;call getvar_int
        call getint
        res 7,c ;ld c,0 ;int
        ret
getval_varstr
        call eat ;skip '$' and spaces
        exx
        ld a,(hl)
        exx
        cp '('
        jr z,getval_varchararray        
        ld a,c
        call findvar_str
        jp z,fail
        ;ld a,c
        ;call getvar_str
        set 7,c ;ld c,128 ;str
        ret
getval_varchararray
        call eat
        push bc
        call getexpr
        pop bc
        call eatclosebracket
        ld a,c
        call findvar_str
        jp z,fail
        ld a,d
        or a
        jp nz,fail ;range check
        add hl,de
        ld e,(hl)
        ld hl,0
        ld d,h ;hlde=char
        res 7,c ;ld c,0 ;int
        ret
getval_vararray
        call eat
        push bc
        call getexpr
        pop bc
        call eatclosebracket
        ld a,c
        call findvar_array
        jp z,fail
        call indexarray
        call getint
        res 7,c ;ld c,0 ;int
        ret
getval_num
        call readnum ;hlde=num, hl'=after num and spaces, CY=error
        jp c,fail
        res 7,c ;ld c,0 ;int
        ret
getval_str
        call readstr ;hl=str, hl'=after str and spaces, CY=error
        jp c,fail
        set 7,c ;ld c,0 ;str
        ret

prval
;hlde=value, c=type
        exx
        push hl
        exx
        bit 7,c
        jr nz,prval_str
        call prdword_hlde
        pop hl
        exx
        ret
prval_str
        call prstr_withlen
        pop hl
        exx
        ret


readstr
;hl'=курсор (указывает на открывающую кавычку)
;out: hl=str, hl'=after num and spaces, CY=error
        exx
        inc hl
        ld de,wordbuf
;TODO проверка длины
quote_getword0
        ld a,(hl)
        or a
        ccf
        ret z ;CY=error
        ;jp z,fail ;jr z,quote_getwordq
        sub '"'
        jr z,quote_getwordq
        ldi
        jp quote_getword0
quote_getwordq
        xor a
        ld (de),a
        exx
        call eat ;съедаем кавычку и последующие пробелы
        ld hl,wordbuf
        or a ;NC = OK
        ret ;NC

indexarray
;hl=адрес массива
;de=индекс
;c=имя массива?
;out: hl=адрес элемента (fail, если out of bounds)
        push bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ex de,hl
        or a
        sbc hl,bc
        add hl,bc
        ex de,hl
        pop bc
        jp nc,fail ;range check
        add hl,de
        add hl,de
        add hl,de
        add hl,de
        ret

func_rnd
;Patrik Rak
rndseed1=$+1
        ld  hl,0xA280   ; xz -> yw
rndseed2=$+1
        ld  de,0xC0DE   ; yw -> zt
        ld  (rndseed1),de  ; x = y, z = w
        ld  a,e         ; w = w ^ ( w << 3 )
        add a,a
        add a,a
        add a,a
        xor e
        ld  e,a
        ld  a,h         ; t = x ^ (x << 1)
        add a,a
        xor h
        ld  d,a
        rra             ; t = t ^ (t >> 1) ^ w
        xor d
        xor e
        ld  h,l         ; y = z
        ld  l,a         ; w = t
        ld  (rndseed2),hl
        ex de,hl
        ld hl,0
        res 7,c ;int
        ret
