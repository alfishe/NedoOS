cmdbuf=curfulllink

browser_editline
        call cleanstatusline
        call keepcurlink
        ld hl,curfulllink
        call strlen
        ld a,l
        ld (curcmdx),a

browser_editline0

editcmd_scroll0
        call cmdcalccurxy ;e=scrx
        ld hl,browser_editline_scroll;curcmdscroll
        inc e ;scrx
        jr nz,editcmd_noscrollleft ;x>=promptsz (x>(promptsz-1))
;x<promptsz - скролл влево
        dec (hl)
        jr editcmd_scroll0
editcmd_noscrollleft
        dec e
        ld a,e ;scrx
        cp EDITLINEMAXVISIBLEX;txtscrwid
        jr c,editcmd_noscrollright
;x>=txtscrwid - скролл вправо
        inc (hl)
        jr editcmd_scroll0
editcmd_noscrollright

        call browser_editline_print
        
        ld a,0x07
        call browser_editline_cursor
        
browser_editlinenokey
        call yieldgetkeynolang ;z=nokey
        jr z,browser_editlinenokey
        
        push af
        ld a,STATUSCOLOR
        call browser_editline_cursor
        pop af
        
        cp key_redraw
        jr z,browser_editline0
        cp key_enter
        jp z,browser_reload ;curfulllink содержит полный url
        ld hl,browser_editline0
        push hl
        cp key_left
        jr z,browser_editline_left
        cp key_right
        jr z,browser_editline_right
        cp key_backspace
        jr z,browser_editline_backspace
        cp 0x20
        ret c ;прочие системные кнопки не нужны
        ld e,a
        ld hl,curfulllink
        call strlen ;hl=length
        ld bc,MAXLINKSZ
        or a
        sbc hl,bc
        ret nc ;некуда вводить
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc a
        ld (curcmdx),a
        jp strinsch ;e=ch

browser_editline_backspace
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        or a
        ret z ;jr z,editcmdok ;нечего удалять
        dec a
        ld (curcmdx),a
        jp strdelch ;удаляет предыдущий символ
      
browser_editline_left
        ld a,(curcmdx)
        or a
        ret z ;jr z,editcmdok ;некуда влево
        dec a
        ld (curcmdx),a
        ret
      
browser_editline_right
        call cmdcalctextaddr ;hl=addr, a=curcmdx
        inc (hl)
        dec (hl)
        ret z ;jr z,editcmdok ;некуда право, стоим на терминаторе
        inc a
        ld (curcmdx),a
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

curcmdx ;не на экране, а внутри команды
        db 0
        
browser_editline_print
        call setpgs_scr
        call setpgcode4000
        ld de,EDITLINEY*256
        call setxymc
        ld de,curfulllink
        ex de,hl
browser_editline_scroll=$+1 ;сдвиг команды относительно экрана
        ld bc,0
        add hl,bc
        ex de,hl
        ld b,EDITLINEMAXVISIBLEX
browser_editline_print0
        ld a,(de)
        or a
        jr z,browser_editline_print0q
        push bc
        push de
        call prcharmc
        pop de
        pop bc
        inc de
        djnz browser_editline_print0
        ret;jr browser_editline_print0qq
browser_editline_print0q
        ld a,' '
        jp prcharmc
;browser_editline_print0qq
;        jp setpgtemp8000

browser_editline_cursor
;a=attr
        ;jr $
        push af
        ;ld de,(curcmdx)
        ;ld d,EDITLINEY
        call cmdcalccurxy
        call setxymc
        res 6,h
        pop af
;hl=screen addr
        jp html_prattr
        
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
;x=curcmdx-curcmdscroll
        ld a,(curcmdx) ;не на экране, а внутри команды
        ld hl,browser_editline_scroll;curcmdscroll ;сдвиг команды относительно экрана
        sub (hl)
        ld e,a
        ld d,EDITLINEY
        ret
