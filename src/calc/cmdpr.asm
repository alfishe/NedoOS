cmdcalctextaddr
;out: hl=addr, a=curcmdx
;keeps ix
        ld a,(curcmdx)
        ld c,a
        ld b,0
        ld hl,cmdbuf
        add hl,bc
        ret

cmdcalcpromptsz
        ld hl,cmdprompt
        call strlen
        ld a,l
        inc a
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
        ;ld d,txtscrhgt-1
        ld d,CMDLINEY
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
        ld de,_COLOR
        SETCOLOR_
        ;ld de,+(txtscrhgt-1)*256+0
        ld de,CMDLINEY*256+0
        SETX_;SETXY_
        ld hl,cmdprompt
        ld c,0
        call prtext
        push bc
        ld a,'>'
        PRCHAR_
        pop bc
        inc c
        ld hl,(curcmdscroll)
        ld h,0
        ld de,cmdbuf
        add hl,de
        call prtext
;добьём остаток строки пробелами
        ;ld hl,tspaces
        ;jp prtext
        jp clearrestofline

;tspaces
;        ds txtscrwid-1,' '
;        db 0
 
cmdprNchars
;hl=buffer
;de=size
;out: hl=buffer+size
        ex de,hl
        push de
        push hl
        call sendchars
        pop hl
        pop de
        add hl,de
        ret
        
prtext
;c=x
        push bc
        push hl
        ld a,txtscrwid-1
        sub c
        ld c,a
        push bc
        call strlen ;hl=length
        pop bc
        ld b,0
        call minhl_bc_tobc
        ld h,b
        ld l,c
        pop de
        pop bc ;c=x
        ld a,h
        or l
;de=buf
;hl=len
        push bc
        push hl
        call nz,sendchars
        pop hl
        pop bc
        add hl,bc
        ld c,l
;c=x        
        ret

minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
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

curcmdscroll ;сдвиг команды относительно экрана
        db 0
curcmdx ;не на экране, а внутри команды
        db 0
cmdprompt
        ds MAXPATH_sz;MAXCMDSZ+1
;tcmd
;        db "cmd "
;tcmd_sz=$-tcmd
cmdbuf
        db 0
        ds cmdbuf+MAXCMDSZ+1-$
