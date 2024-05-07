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

cpmname_to_dotname
;hl -> de
        push hl
        ld b,8
cpmname_to_dotname0
        ld a,(hl)
        cp ' '
        jr z,cpmname_to_dotname0q
        ld (de),a
        inc hl
        inc de
        djnz cpmname_to_dotname0
cpmname_to_dotname0q
        pop hl
        ld bc,8
        add hl,bc ;hl=pointer to ext
        ld a,(hl)
        cp ' '
        jr z,cpmname_to_dotnameq
        ld a,'.'
        ld (de),a
        inc de
        ld  c,3
        ldir
cpmname_to_dotnameq
        xor a
        ld (de),a
        ret

makeprompt
;keeps ix
        push ix
        ld de,cmdprompt ;de=pointer to 64 byte (MAXPATH_sz!) buf
        OS_GETPATH
        pop ix
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
        ;ld c,0
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
        call prtext_c
;добьём остаток строки пробелами
        ;ld hl,tspaces
        ;jp prtext_c
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
        ;ld c,0
        push hl ;text
        call strlen ;hl=length
        jr prtextgo
prtext_c
;c=x
        push hl ;text
        push bc
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
        pop bc ;c=x
prtextgo
        pop de ;text
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
