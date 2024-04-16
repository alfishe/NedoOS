MAXSEARCHFILENAME=64
MAXSEARCHTEXT=64

FOUNDFILESFNSZ=80
FOUNDFILESMAX=20;TODO txtscrhgt-5
FOUNDFILESTABLE=0x8000
FOUNDFILESTABLE_END=0x8000+(FOUNDFILESMAX*FOUNDFILESFNSZ)

editcmd_2
        call ifcmdnonempty_typedigit
editcmd_F2
        call setdrawtablesneeded
        OS_NEWPAGE
        ld a,e
        ld (findpg),a
       ld hl,nvfind_freepg
       push hl
       ld hl,editcmd_reprintall_noreaddir
       push hl

nvfind_redrawloop
        ld a,(findpg)
        ld e,a
        SETPG8000
        call nvfind_reprintmenu

nvfind_mainloop
        call nvfind_getx
        ld e,a
        ld a,(nvfind_curtab)
        add a,a
        inc a
        ld d,a
        call nv_setxy ;keeps de,hl,ix
      if 0
        ld a,2
nvfind_yieldkeep
        ld (nvfind_wasnokey),a
	YIELDKEEP
        ld a,55+128 ;"or a"
        ld (nvfind_wasyield),a
      endif
nvfind_mainloop_nokey
      if 0
      else
        YIELD
      endif
       if PRSTDIO
        GETKEY_
        jr nz,nvfind_mainloop_keyq
        ;GETKEY_
        ;jr nz,nvfind_mainloop_keyq
        ;GETKEY_
        ;jr nz,nvfind_mainloop_keyq ;event бывает 3-символьный
       ;ld a,(stdindatacount)
       ;or a
       ;jr nz,nvfind_mainloop
       else
        GET_KEY
        ld a,c ;keynolang
        ;cp NOKEY
         or a
        jr nz,nvfind_mainloop_keyq
       endif
      if 0
;если два раза подряд нет события, то делаем YIELD, иначе YIELDKEEP
nvfind_wasnokey=$+1
        ld a,1
        dec a
        jr nz,nvfind_yieldkeep
;рисовать панельку только при отсутствии события после YIELD
nvfind_wasyield=$
        scf
        call c,nvfind_panel
	YIELD
        ld a,55 ;"scf"
        ld (nvfind_wasyield),a
      else
        call nvfind_panel
      endif
        jr nvfind_mainloop;_nokey
nvfind_mainloop_keyq
        cp key_redraw
        jr z,nvfind_redrawloop
        cp key_esc
        ret z
        cp key_F3
        jp z,nvfind_view
        ld hl,nvfind_mainloop
        push hl
        cp key_enter
        jp z,nvfind_enter
        cp key_tab
        jp z,nvfind_tab
        cp key_up
        jp z,nvfind_up
        cp key_down
        jp z,nvfind_down
        cp key_left
        jp z,nvfind_left
        cp key_right
        jp z,nvfind_right
        cp key_backspace
        jp z,nvfind_backspace

        cp 0x20
        ret c ;прочие системные кнопки не нужны
nvfind_typein
;keeps ix
        ld e,a
        ld a,(nvfind_curtab)
        or a
        jr nz,nvfind_typein_cursearchtext

nvfind_typein_cursearchfilename
        call nvfind_gettext
        call strlen ;hl=length
        ld bc,MAXSEARCHFILENAME
        or a
        sbc hl,bc
        ret nc ;некуда вводить
        call nvfind_calctextaddr ;hl=addr, a=curx
        inc a
        call nvfind_setx
        jp strinsch

nvfind_typein_cursearchtext
        call nvfind_gettext
        call strlen ;hl=length
        ld bc,MAXSEARCHTEXT
        or a
        sbc hl,bc
        ret nc ;некуда вводить
        call nvfind_calctextaddr ;hl=addr, a=curx
        inc a
        call nvfind_setx
        jp strinsch

nvfind_gettext
        ld a,(nvfind_curtab)
        or a
        ld hl,cursearchtext
        ret nz;jr nz,nvfind_gettext_cursearchtext
        ld hl,cursearchfilename
nvfind_gettext_cursearchtext
        ret

nvfind_getx
        ld a,(nvfind_curtab)
        or a
        ld a,(nvfind_curtextx)
        ret nz;jr nz,nvfind_getx_cursearchtext
        ld a,(nvfind_curx)
nvfind_getx_cursearchtext
        ret

nvfind_setx
        ld c,a
        ld a,(nvfind_curtab)
        or a
        ld a,c
        jr nz,nvfind_setx_cursearchtext
        ld (nvfind_curx),a
        ret
nvfind_setx_cursearchtext
        ld (nvfind_curtextx),a
        ret

nvfind_view
        ld a,(nvfind_curfoundfiles)
        or a
        ret z
        call nvfind_findselectedname
        ld de,filenametext
        call strcopy
        call nvview
        jp nvfind_redrawloop

nvfind_left
        call nvfind_getx
        or a
        ret z
        dec a
        jp nvfind_setx

nvfind_right
        call nvfind_gettext
        call strlen ;hl=length
        call nvfind_getx
        cp l
        ret z
        inc a
        jp nvfind_setx

nvfind_up
        ld de,_COLOR
        call nvfind_printbigcursor
        ld a,(nvfind_curfoundfile)
        or a
        ret z
        dec a
        ld (nvfind_curfoundfile),a
        ret

nvfind_down
        ld de,_COLOR
        call nvfind_printbigcursor
        ld a,(nvfind_curfoundfile)
        ld hl,nvfind_curfoundfiles
        inc a
        cp (hl)
        ret z
        ld (nvfind_curfoundfile),a
        ret

nvfind_tab
        ld hl,nvfind_curtab
        ld a,(hl)
        xor 1
        ld (hl),a
        ret

nvfind_backspace
        call nvfind_calctextaddr ;hl=addr, a=curx
        or a
        ret z
        ld a,(nvfind_curtab)
        or a
        jr nz,nvfind_backspace_cursearchtext
        ld de,nvfind_curx
        ld a,(de)
        dec a
        ld (de),a
        jp strdelch
nvfind_backspace_cursearchtext
        ld de,nvfind_curtextx
        ld a,(de)
        dec a
        ld (de),a
        jp strdelch

nvfind_enter_select
;TODO select from list y=(nvfind_curfoundfile)
        call nvfind_findselectedname
        push hl
        call findlastslash. ;de = after last slash
        dec de
        xor a
        ld (de),a ;drop filename after path
        pop de
        OS_CHDIR
        ld hl,(curpanel)
        call editcmd_setpaneldirfromcurdir_panelhl
        pop af ;loop return
        pop af ;reprint return
        jp editcmd_reprintall

nvfind_enter
        ld a,(nvfind_curtab)
        or a
        jr z,nvfind_enter_research ;Enter on filename - new search
        ld a,(nvfind_curfoundfiles)
        or a
        jr nz,nvfind_enter_select ;Enter on search text - go to result
nvfind_enter_research
        ld (nvfind_sp),sp
        
        xor a
        ld (nvfind_curfoundfiles),a
        ld (nvfind_curfoundfile),a
        ld hl,FOUNDFILESTABLE
        ld (nvfind_curfoundnameaddr),hl

        call nvfind_reprintmenu

        ld de,0x0400
        call nv_setxy ;keeps de,hl,ix

        ;ld hl,emptypath
        call getcurpaneldir_hl
        ld de,nvfind_curpath
        call strcopy_addslash

        call nvfind_loaddir
nvfind_break
nvfind_sp=$+1
        ld sp,0
        ret

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

nvfind_loaddir
        ld de,nvfind_curpath
        OS_CHDIR
        ld de,emptypath;nvfind_curpath
        OS_OPENDIR ;не понимает путь!!!
        
        ld bc,0 ;file#
nvfind_loaddir0
        ;push bc
        call loaddir_filinfo
        ;pop bc
        inc bc
        jp c,nvfind_loaddirq
        jr z,nvfind_loaddir0
        ld hl,filinfo+FILINFO_FATTRIB
        ld a,(hl)
        and FATTRIB_DIR
        jr z,nvfind_loaddir_ndir
         ld hl,filinfo+FILINFO_FNAME
         ld a,'.'
         cp (hl)
         jr nz,nvfind_loaddir_subdir
         inc hl
         cp (hl)
         jr z,nvfind_loaddir0
nvfind_loaddir_subdir
        push bc
;open subdir
        ld hl,nvfind_curpath
        STRPUSH
        ld hl,nvfind_curpath
        call strfindeol
        ex de,hl
        ld hl,filinfo+FILINFO_FNAME
        call strcopy ;out: hl,de after terminator
        ex de,hl
        dec hl
        ld (hl),'/'
        inc hl ;curpath = oldcurpath+dir+'/'
        ld (hl),0
        ;ld de,nvfind_curpath
        ;OS_OPENDIR
        ;jr $
        
        ld de,filinfo+FILINFO_FNAME
        OS_CHDIR

        call nvfind_loaddir

        ld de,tdotdot
        OS_CHDIR

;reopen dir
        ld hl,nvfind_curpath
        STRPOP
        ld de,nvfind_curpath
        OS_CHDIR
        ld de,emptypath;nvfind_curpath
        OS_OPENDIR ;не понимает путь!!!
        pop bc
        push bc
nvfind_loaddir_recreread0
        ;push bc
        call loaddir_filinfo
        ;pop bc
        dec bc
        ld a,b
        or c
        jr nz,nvfind_loaddir_recreread0
        pop bc
        jr nvfind_loaddir0
nvfind_loaddir_ndir
        push bc
        ld de,cursearchfilename
        ld hl,filinfo+FILINFO_FNAME
        call nvfind_compare
        jr z,nvfind_loaddir_ok
        ld de,cursearchfilename
        ld hl,filinfo+FILINFO_LNAME
        call nvfind_compare
        jr nz,nvfind_loaddir_fail
nvfind_loaddir_ok
        call nvfind_found
        
nvfind_loaddir_fail
        pop bc ;file#
        jp nvfind_loaddir0
nvfind_loaddirq
        ret


nvfind_found
;TODO generate curpath/hlname
        push hl
        ld hl,nvfind_curpath
        call strfindeol
        pop de
        push hl
        ;ld (hl),'/'
        ;inc hl
        ex de,hl
        call strcopy
        ld hl,nvfind_curpath
        ld (nvfind_curfilename),hl
        ld a,(cursearchtext)
        or a
        jr z,nvfind_foundnosearchinfile

;open file with name=HL
        ex de,hl
        OS_OPENHANDLE
        ld a,b
        ld (nvfind_curhandle),a
        
        call nvfind_searchinfile
        push af
nvfind_curhandle=$+1
        ld b,0
        OS_CLOSEHANDLE
        pop af
        jr nz,nvfind_found_q
        
nvfind_foundnosearchinfile
nvfind_curfoundnameaddr=$+1
        ld de,0
        ld hl,FOUNDFILESTABLE_END
        or a
        sbc hl,de
        jp z,nvfind_break
        ld hl,(nvfind_curfilename)
        ld bc,FOUNDFILESFNSZ
        ldir
        ld (nvfind_curfoundnameaddr),de
        ld hl,nvfind_curfoundfiles
        inc (hl)

        call prcrlf
nvfind_curfilename=$+1
        ld hl,0
        ld c,0 ;x
        call prtext
        call clearrestofline
        
       if PRSTDIO
        GETKEY_
       else
        GET_KEY
       endif
        cp key_esc
        jp z,nvfind_break
nvfind_found_q
        pop hl
        ld (hl),0
        ret

nvfind_searchinfile
;out: NZ=not found, Z=found, hl=place after
;сначала cursearchbuf=searchbuf, грузим туда два сегмента
        call nvfind_loadsegment
nvfind_searchinfile0
        call nvfind_loadsegment ;запасной сегмент впереди
        call nvfind_searchinsegment
        jr c,nvfind_searchinfileq
        jr nz,nvfind_searchinfile0
nvfind_searchinfileq
        ret

nvfind_searchinsegment
;out: CY=end of file(NZ); else NZ=not found, Z=found, hl=place after
cursearchbuf=$+1
        ld hl,searchbuf
nvfind_cursize=$+1
        ld bc,128
nvfind_searchinsegment_retry
        ld a,b
        or c
        jr z,nvfind_searchinsegment_eof
        ld de,cursearchtext
        ld a,(de)
        cpir
         scf
         ccf
        ret nz ;NZ,NC
         ld (nvfind_searchinsegment_tempaddr),hl
        dec hl ;for use inc l later
nvfind_searchinsegment0
        inc l
        inc de
        ld a,(de)
        or a
        ret z ;Z,NC
        xor (hl)
        jr z,nvfind_searchinsegment0
nvfind_searchinsegment_tempaddr=$+1
         ld hl,0
         jr nvfind_searchinsegment_retry
        ;ret ;NZ,NC
nvfind_searchinsegment_eof
        sub 1
        ret ;CY,NZ

nvfind_loadsegment
nvfind_nextsize=$+1
        ld hl,0
        ld (nvfind_cursize),hl
        ld a,(nvfind_curhandle)
        ld b,a
        ld hl,SEARCHBUF_SZ
        ld de,(cursearchbuf)
        OS_READHANDLE
;hl=true size
        ld (nvfind_nextsize),hl
        ld hl,cursearchbuf
        ld a,(hl)
        xor 128
        ld (hl),a
        ret

nvfind_compare
;de=search string
;hl=test string
;out: Z=ok, NZ=fail
        push hl
        call nvfind_compare0
        pop hl
        ret
nvfind_compare0
        ld a,(de)
        cp '*'
        ret z
        cp '?'
        jr z,nvfind_compare_skip
         or 0x20
        xor (hl)
        jr z,nvfind_compare_skip
        cp 0x20
        ret nz
        ld a,(de)
        or a
        ret z
nvfind_compare_skip
        inc hl
        inc de
        jr nvfind_compare0

nvfind_calctextaddr
        ld a,(nvfind_curtab)
        or a
        jr z,nvfind_calctextaddr_cursearchfilename
        ld hl,cursearchtext
nvfind_curtextx=$+1
        ld a,0
        jp cmdcalctextaddr_hlbase_ax ;hl=addr, a=x
        
nvfind_calctextaddr_cursearchfilename
        ld hl,cursearchfilename
nvfind_curx=$+1
        ld a,0
        jp cmdcalctextaddr_hlbase_ax ;hl=addr, a=x

nvfind_findselectedname
        ld hl,FOUNDFILESTABLE
        ld de,FOUNDFILESFNSZ
nvfind_curfoundfile=$+1
        ld b,0
        inc b
        dec b
        ret z ;hl=name
        add hl,de
        djnz $-1
;hl=name
        ret

nvfind_printbigcursor
;de=color
nvfind_curfoundfiles=$+1
        ld a,0
        or a
        ret z
        call nv_setcolor
        ld a,(nvfind_curfoundfile)
        add a,5
        ld d,a
        ld e,0
        call nv_setxy ;keeps de,hl,ix
        call nvfind_findselectedname
        ld c,0 ;x
        call prtext
        ld de,_COLOR
        jp nv_setcolor

nvfind_panel
        ld de,_CURSORCOLOR
        call nvfind_printbigcursor
nvfind_curtab=$+1
        ld a,0
        or a
        ;jp z,nvfind_prcursearchfilename
        jr nz,nvfind_prcursearchtext
nvfind_prcursearchfilename
        ld de,0x0100
        ;push de
        call nv_setxy ;keeps de,hl,ix
        ld c,0 ;x
        ld hl,cursearchfilename
        call prtext
        jp clearrestofline
        ;call nvfind_getx
        ;pop de
        ;ld e,a
        ;call nv_setxy ;keeps de,hl,ix
        ;ret
nvfind_prcursearchtext
        ld de,0x0300
        ;push de
        call nv_setxy ;keeps de,hl,ix
        ld c,0 ;x
        ld hl,cursearchtext
        call prtext
        jp clearrestofline

nvfind_reprintmenu
       if PRSTDIO
        ld de,0
        call nv_setxy ;keeps de,hl,ix
        CLS_
       else
        ld de,_COLOR
        OS_CLS
       endif
        
        ld de,0x0000
        call nv_setxy ;keeps de,hl,ix
        ld c,0 ;x
        ld hl,tsearchfilename
        call prtext
        call nvfind_prcursearchfilename

        ld de,0x0200
        call nv_setxy ;keeps de,hl,ix
        ld c,0 ;x
        ld hl,tsearchtext
        call prtext
        call nvfind_prcursearchtext
        
        ld de,0x0400
        call nv_setxy ;keeps de,hl,ix
        ld c,0 ;x
        ld hl,tresults
        call prtext
        
        ld hl,FOUNDFILESTABLE
        ld a,(nvfind_curfoundfiles)
nvfind_reprintmenu_files0
        or a
        ret z
        push af
        push hl
        call prcrlf
        pop hl
        push hl
        ld c,0 ;x
        call prtext
        pop hl
        ld bc,FOUNDFILESFNSZ
        add hl,bc
        pop af
        dec a
        jr nvfind_reprintmenu_files0

nvfind_freepg
findpg=$+1
        ld e,0
        OS_DELPAGE
        ret

strfindeol
        xor a
        ld b,a
        ld c,a
        cpir
        dec hl
        ret

tsearchfilename
        db "Search filename:",0

cursearchfilename
        ds MAXSEARCHFILENAME+1

tsearchtext
        db "Search text:",0

tresults
        db "Results:",0

cursearchtext
        ds MAXSEARCHTEXT+1

nvfind_curpath
        ds MAXPATH_sz

