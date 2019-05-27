htmlview
        call showtime

        ld hl,(curprintvirtualy)
        ld (html_endy),hl
        call prcharmc_stateful_resethandler
        ;ld hl,0
        ;ld (html_curtopy),hl
        
        ld hl,(firstpointer)
        ld (htmlshowline_accessedpointer),hl
        ld a,(firstpointerHSB)
        ld (htmlshowline_accessedpointerHSB),a
        
html_redrawloop
;TODO redraw interface
        call htmlshowpage
        ;call setpgs_scr
        
html_mainloop

htmlcursorxy=$+1
        ld de,HTMLTOPY*256
	call html_setxy
        call setpgs_scr
        ld e,(hl)
	push de ;e=oldcolor
	ld a,0x38
        call html_prattr

1
	;YIELD ;halt ;если сделать просто di:rst #38, то 1.сдвинем таймер и 2.можем потерять кадровое прерывание, а если без ei, то будут глюки
        ;GET_KEY ;OS_GETKEYNOLANG
        ;ld a,c ;keynolang        
        ;cp NOKEY
        call yieldgetkeynolang
        jr nz,html_mainloop_keyq
        ;call nvview_panel
        jr 1b
html_mainloop_keyq

        pop de ;e=oldcolor
        push af
        push de
        ld de,(htmlcursorxy)
	call html_setxy
        pop de
	ld a,e
        call html_prattr
        pop af
        cp key_redraw
        jr z,html_redrawloop
        ;cp key_esc
        ;jp z,browser_quit
        call globalbuttons
        ld hl,html_mainloop
        push hl
        cp key_up
        jp z,html_up
        cp key_down
        jp z,html_down
        cp key_right
        jp z,html_right
        cp key_left
        jp z,html_left
        cp key_enter
        jp z,html_enter
	cp 'l'
	jr z,html_download
	;cp 's'
	;jp z,browser_downloadthis
        ;cp '5'
        ;jp z,browser_reload
        cp 'u'
        jr z,html_changeencoding
        ;cp key_backspace
        ;jp z,browser_backspace
        cp key_pgup
        jp z,html_pgup
        cp key_pgdown
        jp z,html_pgdown
        cp key_home
        jp z,html_home
        cp key_end
        jp z,html_endkey
        ret

html_changeencoding
        ld hl,defaultunicodeflag
        ld a,(hl)
        xor 1
        ld (hl),a
        jp browser_reload
        
html_download
        call html_enter_find
        call keepcurlink
;linkbuf=relative link
        call makefulllink
;curfulllink=url

wgetloaded_pid=$+1
        ld a,0
        or a
        call z,reloadwget

;TODO проверить, что wget жив:
        ld a,(wgetloaded_pid)
        ld e,a
        OS_WAITPID
        or a
        call z,reloadwget

;ждём готовности wget
waitwgetinit0
        YIELD
wgetmainpg=$+1
        ld a,0
        SETPG32KHIGH
        ld a,(0xc000+COMMANDLINE)
        inc a
        jr z,waitwgetinit0
        
        ld hl,curfulllink
        ld de,0xc000+WGETBUF
        call strcopy
        ld a,0xff
        ld (0xc000+COMMANDLINE),a ;строка задания готова
        
        jp remembercurlink
	;jp browser_godownload

reloadwget
        OS_SETSYSDRV
        ld de,wgetfilename
        call openstream_file
        or a
        ret nz
        OS_NEWAPP ;на момент создания должна быть включена текущая директория!!!
        or a
        jr nz,html_download_closeq ;error
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id
        ld a,d
        ld (wgetmainpg),a
        SETPG32KHIGH
        ;push de
        ;push hl
        ld hl,0xc000+COMMANDLINE
        ld (hl),0xff ;daemon mode
        inc hl
        ld (hl),0
        ;pop hl
        ;pop de
        ld de,0xc100
        ld hl,0x3f00
        call readstream_file
        pop af
        ld (wgetloaded_pid),a
        ld e,a ;e=id
        OS_RUNAPP
html_download_closeq
        jp closestream_file

html_enter
;click on href
        call html_enter_find
        jp browser_go

html_enter_find
        ld a,(htmlcursorxy+1)
        sub HTMLTOPY
        ld c,a
        ld b,0
        ld hl,(html_curtopy)
        add hl,bc
        ld (html_enter_virtualy),hl

         ;jr $
        ld hl,(first2pointer)
        ld a,(first2pointerHSB)
html_enter_find0
        call isnull
        jr z,html_enter_findq
        push af
        push hl
        
        if 1==0
        
        ld bc,HREF_Y
        add hl,bc
        adc a,0
        call readword ;de=beginy
        ex de,hl
html_enter_virtualy=$+1
        ld bc,0
        or a
        sbc hl,bc ;HREF_Y - y
        ex de,hl
        jr z,html_enter_findlineok ;для правильной ссылки HREF_Y<=y
         ;jr c,html_enter_findlineok_hrefy_lessthan_y
        
        endif
         
;for long linktexts: beginyx<=yx<endyx
;можно первичную фильтрацию (beginy<=y<=endy), но неудобно

        ld bc,HREF_Y
        add hl,bc
        adc a,b;0
        call readword ;de=beginy
        call readbyte ;c=beginx
html_enter_virtualy=$+1
        ld hl,0
        ld a,(htmlcursorxy)
        ;hla=Yyx
        ;dec=beginYyx
        cp c
        sbc hl,de
        jr c,html_enter_findnext
        pop hl
        pop af
        push af
        push hl
        ld bc,HREF_ENDY
        add hl,bc
        adc a,b;0
        call readword ;de=endy
        call readbyte ;c=endx
        ld hl,(html_enter_virtualy)
        ld a,(htmlcursorxy)
        ;hla=Yyx
        ;dec=endYyx
        cp c
        sbc hl,de
        ;jr nc,html_enter_findnext
        jr c,html_enter_findok

html_enter_findnext
        pop hl
        pop af
        call getnextelement
        jr html_enter_find0
        
        
        if 1==0
        
html_enter_findlineok_hrefy_lessthan_y

        
html_enter_findlineok
        call readbyte ;c=beginx
        ld b,a
        ld a,(htmlcursorxy)
        cp c
        ld a,b
;x<beginx => fail
        jr c,html_enter_findnext
         ;jr $
        call readword ;de=endy
        push hl
        ld hl,(html_enter_virtualy)
        or a
        sbc hl,de
        pop hl
;y==endy => ok (long linktext)
        push af
        call readbyte ;c=endx
        pop af
        ;jr z,html_enter_findok_endy

        ld b,a
        ld a,(htmlcursorxy)
        cp c
        ld a,b
;x>=endx =>fail
        jr nc,html_enter_findnext
        ;jr html_enter_findok
                
html_enter_findok_endy
        endif

html_enter_findok
	 ;pop bc
	 ;pop bc
        ;call readbyte ;skip VISITED
         
         pop hl
         pop af
        ld bc,HREF_TEXT
        add hl,bc
        adc a,b;0
         
        ld de,linkbuf
html_enter_findok_copyname0
        call readbyte
        ex de,hl
        ld (hl),c
        inc hl
        ex de,hl
        inc c
        dec c
        jr nz,html_enter_findok_copyname0
         ;jr $
	ret
        
html_enter_findq
	pop af
        ret

html_prattr
        ld de,40
        ld b,8
html_prattr0
	ld (hl),a
        add hl,de
        djnz html_prattr0
        ret

html_setxy
;de=yx (kept)
        push de
        sla d
        sla d
        sla d
        call setxymc
        res 6,h
        pop de
        ret

html_left
        ld a,(htmlcursorxy)
        sub 1
        ret c
        ld (htmlcursorxy),a
        ret
        
html_right
        ld a,(htmlcursorxy)
        inc a
        cp 80
        ret nc
        ld (htmlcursorxy),a
        ret
        
html_up
        ld a,(htmlcursorxy+1)
        cp HTMLTOPY
        jr z,html_up_scroll
        dec a
        ld (htmlcursorxy+1),a
        ret
html_up_scroll
        ld hl,(html_curtopy)
        ld a,h
        or l
        ret z
        dec hl
        ld (html_curtopy),hl
        push hl
        call scrollmcdown
        pop hl
        ld d,HTMLTOPY
;hl=virtual Y
;d=scry
        jp htmlcleanshowline
        
html_down
        ld a,(htmlcursorxy+1)
        cp HTMLTOPY+HTMLHGT-1
        jr z,html_down_scroll
        inc a
        ld (htmlcursorxy+1),a
        ret
html_down_scroll
        ld hl,(html_curtopy)
        inc hl
        ld (html_curtopy),hl
        push hl
        call scrollmcup
        pop hl
        ld bc,HTMLHGT-1
        add hl,bc
        ld d,HTMLTOPY+HTMLHGT-1
;hl=virtual Y
;d=scry
        jp htmlcleanshowline

html_pgup
        ld hl,(html_curtopy)
        ld bc,HTMLHGT-1
        xor a
        sbc hl,bc
        jr nc,$+4
        ld h,a
        ld l,a
topy_showpage_slearkeyboardbuffer
        ld (html_curtopy),hl
        call htmlshowpage
clear_keyboardbuffer
        push bc
        ld b,5
clear_keyboardbuffer0
        push bc
        GET_KEY
        pop bc
        djnz clear_keyboardbuffer0
        pop bc
        ret
        
html_pgdown
        ld hl,(html_curtopy)
        ld bc,HTMLHGT-1
        add hl,bc
        jr topy_showpage_slearkeyboardbuffer
        ;ld (html_curtopy),hl
        ;call htmlshowpage
        ;ret
        
html_home
        ld hl,0
        jr topy_showpage_slearkeyboardbuffer

html_endkey
html_endy=$+1
        ld hl,0
        jr topy_showpage_slearkeyboardbuffer
        
htmlshowpage
        ld d,HTMLTOPY
html_curtopy=$+1
        ld hl,0
htmlshowpage0
;hl=virtual Y
;d=scry
        call htmlcleanshowline
        inc hl
        inc d
        ld a,d
        cp HTMLTOPY+HTMLHGT
        jr nz,htmlshowpage0
        ret

htmlcleanshowline
;hl=virtual Y
;d=scry
        push de
        push hl
        ld e,0
        sla d
        sla d
        sla d
        call setxymc ;hl=0xc000+        
        call setpgs_scr
        xor a
        call cleanlinemc
        call setpgtemp8000
        pop hl
        pop de
        
        ;jr $
        push de
        push hl
        call htmlshowline
        pop hl
        pop de
        ret
        
htmlshowline
;hl=virtual Y
;d=scry
        ;jr $
        ld a,d
        add a,a
        add a,a
        add a,a
        ld (htmlshowline_scry),a
        ld (htmlshowline_virtualy),hl

htmlshowline_accessedpointer=$+1
        ld hl,0
htmlshowline_accessedpointerHSB=$+1
        ld a,0
        
;ищем вниз, если (accessedpointer.HREF_Y < y), иначе ищем вверх
        push af
        push hl
        call getandcompareHREF_Y ;CY = (HREF_Y < y)
        jr c,htmlshowline_finddown

;htmlshowline_findup
        pop hl
        pop af
htmlshowline_findup0
        call isnull
        jr z,htmlshowline_findq
        push af
        push hl
        call getandcompareHREF_Y
        jr z,htmlshowline_findok
         jr c,htmlshowline_pop2findq
        pop hl
        pop af
        call getprevelement
        jr htmlshowline_findup0

htmlshowline_finddown
        pop hl
        pop af
htmlshowline_finddown0
        call isnull
        jr z,htmlshowline_findq
        push af
        push hl
;        ld bc,HREF_Y
;        add hl,bc
;        adc a,b;0
;        call readword ;de
;        ex de,hl
;htmlshowline_virtualy=$+1
;        ld bc,0
;        or a
;        sbc hl,bc
;        ex de,hl
        call getandcompareHREF_Y
        jr z,htmlshowline_findok
         jr nc,htmlshowline_pop2findq
        pop hl
        pop af
        call getnextelement
        jr htmlshowline_finddown0
        
getandcompareHREF_Y
        ld bc,HREF_Y
        add hl,bc
        adc a,b;0
        call readword ;de
        ex de,hl
htmlshowline_virtualy=$+1
        ld bc,0
        or a
        sbc hl,bc
        ex de,hl
        ret ;CY = (HREF_Y < y), Z = equal

htmlshowline_findok
        push af
        push hl
        ld bc,HREF_Y+2
        or a
        sbc hl,bc
        sbc a,b;0
        ld (htmlshowline_accessedpointer),hl
        ld (htmlshowline_accessedpointerHSB),a
        pop hl
        pop af

        call readbyte ;x
        ld e,c
htmlshowline_scry=$+1
        ld d,0
        push af
        push hl
        call setxymc_stateful
        pop hl
        pop af
htmlshowline_showtext0
        call readbyte ;c
        inc c
        dec c
        jr z,htmlshowline_showtextq
        push af
        push hl
        ld a,c
        call prcharmc_stateful
        pop hl
        pop af
        jr htmlshowline_showtext0
htmlshowline_showtextq
        
htmlshowline_pop2findq
        pop hl
        pop af
        
htmlshowline_findq

        ret
        
        if 1==0
        ld hl,(firstpointer)
        ld a,(firstpointerHSB)
loadhtml_showtexts0
        call isnull
        jr z,loadhtml_showtextsq
        push af
        push hl
        ld bc,stringbuf1-stringbuf1header
        add hl,bc
        adc a,0
        ;jr $
loadhtml_showtext0
        call readbyte ;c
        inc c
        dec c
        jr z,loadhtml_showtextq
        push af
        push hl
        ld a,c
        call prcharmc_stateful
        pop hl
        pop af
        jr loadhtml_showtext0
loadhtml_showtextq
        call prcharmc_crlf_stateful
        pop hl
        pop af
        call getnextelement
        jr loadhtml_showtexts0
loadhtml_showtextsq
        
        
        ld hl,(first2pointer)
        ld a,(first2pointerHSB)
loadhtml_showhrefs0
        call isnull
        jr z,loadhtml_showhrefsq
        push af
        push hl
        ld bc,stringbuf2-stringbuf2header
        add hl,bc
        adc a,0
        ;jr $
loadhtml_showhref0
        call readbyte ;c
        inc c
        dec c
        jr z,loadhtml_showhrefq
        push af
        push hl
        ld a,c
        call prcharmc_stateful
        pop hl
        pop af
        jr loadhtml_showhref0
loadhtml_showhrefq
        call prcharmc_crlf_stateful
        pop hl
        pop af
        call getnextelement
        jr loadhtml_showhrefs0
loadhtml_showhrefsq

        jp closequit
        endif
