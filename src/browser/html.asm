WORDBUFSIZE=128

CBOLD=1
CITALIC=1;0x87;add a,a
CUNDERLINE=1;0x2f;cpl
CSTROKE=1;0xff
CLINK=2
CLINKIMG=4
CMARK=8
;TODO visited link



loadhtml
         display "decode html=",$
        push af ;first char
;skip spaces and line breaks
        cp 0xef ;hippiman.16mb.com начинается с ef bb bf (UTF-8 BOM)
        jr z,loadhtml_html
        call htmlskipspaces_go
         cp '<'
loadhtml_html
         ld a,1
         jr nz,$+3 ;not html
         xor a ;html
         ld (ispre),a
         ;xor a
         ld (printableflag),a ;header is invisible for html
defaultunicodeflag=$+1
         xor 1 ;ld a,1 ;utf-8 by default for html, windows-1251 for text
         ld (utf8flag),a
        call setdefaultfontweight

        xor a
        ld (laststringx),a
        ld h,a
        ld l,a ;0
        ld (laststringy),hl
        ld (curprintvirtualy),hl

        dec a
        dec hl
        ld (lastpointer),hl
        ld (lastpointerHSB),a
        ld (last2pointer),hl
        ld (last2pointerHSB),a
        ld (firstpointer),hl
        ld (firstpointerHSB),a
        ld (first2pointer),hl
        ld (first2pointerHSB),a

        call initstringbuf1 ;buf2 инициализируется в тэге a/img ;содержит setfontweight
         call rememberhrefyxposition ;иначе ссылки могут записаться с неправильным Y после div
        
        ;ld de,0
        ;call setxymc_stateful
        pop af;ld a,'<' ;already read ;TODO может не там сделали push? по идее надо на '<'?
         ;jr $
        call loadhtml_mainloop_go
         call prcharvirtual_crlf_stateful
         ;ld a,-2
         ;in a,(-2)
         ;rra
         ;jr nc,$
         ;jr $
        call closestream
        jp htmlview ;can exit to browser_go via Enter
        
loadhtml_mainloop_mangledcharq
        call prcharvirtual_stateful
loadhtml_mainloop
        rdbyte
loadhtml_mainloop_go
         ;push af
         ;call prcharvirtual_stateful
         ;pop af
         cp '<'+1
         jp nc,loadhtml_mainloop_mangledcharq ;speedup
        or a
        ret z
        cp '<'
        jr z,loadhtml_mainloop_tag
        cp '&'
        jr z,loadhtml_mainloop_mangledchar
        cp 0x0d
        jr z,loadhtml_checkpremainloop
        cp 0x0a
        jr z,loadhtml_checkpremainloop
        cp ' '
        jr z,loadhtml_checkpremainloop
        cp 0x09
        jr z,loadhtml_checkpremainloop
        jp loadhtml_mainloop_mangledcharq
loadhtml_checkpremainloop
ispre=$+1
        ld b,0        
        djnz loadhtml_spacemainloop
         ;jr $
        jr loadhtml_mainloop_mangledcharq

loadhtml_spacemainloop
         ;jr $
        ;call countlinewidth
        ;ld a,h
        ;or l ;а там уже управляющие коды
        ld a,(prcharvirtual_stateful_x)
        or a
        jr z,loadhtml_mainloop
        ld a,' '
        jr loadhtml_mainloop_mangledcharq

loadhtml_mainloop_mangledchar
;read until ;
        ld hl,mangledcharslist
        ld de,wordbuf
        call getword_mangledchar ;hl=terminator/space addr,a=char
        ld hl,mangledcharslist
mangledcharstrcp0
        ld a,(hl) ;decoded char
        inc hl
        or a
        jr z,mangledchar_error
        ld de,wordbuf
        push hl
        call strcp
        pop hl
        jr nz,mangledcharstrcp_fail
        dec hl
        ld a,(hl) ;decoded char
        jp loadhtml_mainloop_mangledcharq
mangledcharstrcp_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr mangledcharstrcp0
mangledchar_error=loadhtml_mainloop
        
loadhtml_mainloop_tag
        call RDBYTE;rdbyte
        ld (loadhtml_tagcloser),a
        cp '/'
        jr nz,executetag
        call RDBYTE;rdbyte
executetag
        ld de,wordbuf
        call getword_tag_go ;hl=terminator/space addr,a=char ;first char already read
        ld (executetag_endchar),a
        
        if 1==0
         ld hl,wordbuf
executetag_typetag0
         ld a,(hl)
         or a
         jr z,executetag_typetagq
         inc hl
         push hl
         call prcharvirtual_stateful
         pop hl
         jr executetag_typetag0
executetag_typetagq
        endif
        
        ;cp '>'
        ;call skipspaces
        ;ld (execcmd_pars),hl
        ld hl,tagslist ;list of internal commands
strcpexec0
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld a,b
        cp -1
        jr z,executetag_error ;a!=0: no such internal command
        ld de,wordbuf
        push hl
        call strcp
        pop hl
        jr nz,strcpexec_fail
        ld h,b
        ld l,c
loadhtml_tagcloser=$+1
        ld a,0
        cp '/'
        call jphl ;execute command (Z=closing tag)

;TODO read the rest of the tag?
        
        jp loadhtml_mainloop
jphl
        jp (hl) ;run internal command
strcpexec_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr strcpexec0

executetag_error
;no such tag
         call skiprestoftag
        jp loadhtml_mainloop
        
        
mangledcharslist
        db "&"
        db "amp",0
        db "<"
        db "lt",0
        db ">"
        db "gt",0
        db " "
        db "nbsp",0
        db 34
        db "quote",0
        db 34
        db "lquote",0
        db 34
        db "rquote",0

        db 0 ;end of mangled chars list

tagslist
        dw tag_p
        db "p",0
        dw tag_pre
        db "pre",0
        dw tag_code
        db "code",0
        dw tag_div
        db "div",0
        dw tag_ul
        db "ul",0
        dw tag_li
        db "li",0
        dw tag_th
        db "th",0
        dw tag_center
        db "center",0 ;deprecated
        dw tag_h1
        db "h1",0
        dw tag_h2
        db "h2",0
        dw tag_h3
        db "h3",0
        dw tag_h4
        db "h4",0
        dw tag_h5
        db "h5",0
        dw tag_h6
        db "h6",0
        dw tag_ins
        db "ins",0
        dw tag_u
        db "u",0
        dw tag_b
        db "b",0
        dw tag_em
        db "em",0
        dw tag_cite
        db "cite",0
        dw tag_i
        db "i",0
        dw tag_del
        db "del",0
        dw tag_s
        db "s",0
        dw tag_a
        db "a",0
        dw tag_strong
        db "strong",0
        dw tag_img
        db "img",0
        dw tag_html
        db "html",0
        dw tag_head
        db "head",0
        dw tag_meta
        db "meta",0
        dw tag_title
        db "title",0
        dw tag_body
        db "body",0
        dw tag_font
        db "font",0
        dw tag_br
        db "br",0
        dw tag_table
        db "table",0
        dw tag_tbody
        db "tbody",0
        dw tag_tr
        db "tr",0
        dw tag_td
        db "td",0
        dw tag_mark
        db "mark",0
        dw tag_span
        db "span",0
        dw tag_script
        db "script",0
        dw tag_doctype
        db "!doctype",0
        dw tag_COMMENT
        db "!--",0
        dw tag_link
        db "link",0
        dw tag_style
        db "style",0
        dw tag_frameset
        db "frameset",0
        dw tag_frame
        db "frame",0
        dw tag_iframe
        db "iframe",0
        dw tag_label
        db "label",0
        dw tag_form
        db "form",0
        dw tag_input
        db "input",0
        dw tag_dl ;forum.nedopc.com
        db "dl",0
        dw tag_dd ;forum.nedopc.com
        db "dd",0
        dw tag_dt ;forum.nedopc.com
        db "dt",0
        
        dw -1 ;end of tags list
        
;Z=closing tag

tag_label
;<label for="searchInput">Поиск</label>
;TODO
        jp skiprestoftag

tag_form
tag_input
;<form action="http://speccy.info/w/index.php" id="searchform">
;<input type="hidden" name="title" value="Служебная:Поиск">
;<input type="search" name="search" placeholder="Поиск" title="Искать в SpeccyWiki [shift-esc-f]" accesskey="f" id="searchInput" autocomplete="off">
;<input type="submit" name="go" value="Перейти" title="Перейти к странице, имеющей в точности такое название" id="searchGoButton" class="searchButton">&nbsp;
;<input type="submit" name="fulltext" value="Найти" title="Найти страницы, содержащие указанный текст" id="mw-searchButton" class="searchButton">
;</form>
;TODO
        jp skiprestoftag

tag_p
        call prcharvirtual_crlf_stateful ;opening&closing
        jp skiprestoftag

tag_code
tag_pre
        push af ;z/nz
        call prcharvirtual_crlf_stateful ;opening&closing
        call htmlinitbody ;zxdn реклама в plain text
        pop af ;z/nz
        ld hl,ispre
        ld a,1
        jr tag_u_b_i

tag_center
;TODO test
        ld hl,iscentered
        ld a,1
        jr tag_u_b_i

tag_h1
tag_h2
tag_h3
tag_h4
tag_h5
tag_h6
        jr z,tag_hclose
        ld a,1
        ld (iscentered),a
        jr tag_b
tag_hclose
        call prcharvirtual_crlf_stateful
        ;xor a
        ;ld (iscentered),a
        jr tag_u_b_iq

tag_mark
        ld hl,curmark
        ld a,CMARK
        jr tag_u_b_i
        
tag_del
tag_s
        ld hl,curstroke
        ld a,CSTROKE
        jr tag_u_b_i
tag_ins
tag_u
        ld hl,curunderline
        ld a,CUNDERLINE
        jr tag_u_b_i
tag_th ;table header: TODO also center in cell
tag_b
tag_strong
        ld hl,curbold
        ld a,CBOLD
        jr tag_u_b_i
tag_em
tag_cite
tag_i
        ld hl,curitalic
        ld a,CITALIC
tag_u_b_i
        ld (hl),0
        jr z,$+3 ;Z=closing tag
        ld (hl),a
tag_u_b_iq
        call setfontweight
        jp skiprestoftag
        
tag_ul ;list
        jp nz,skiprestoftag ;opening (li does newline)
tag_dd ;на lib.ru это перевод строки
tag_div
        ;jr $
tag_table
tag_br
        call prcharvirtual_crlf_stateful
        jp skiprestoftag
tag_tr
;only closing tr works as crlf
        call z,prcharvirtual_crlf_stateful
        jp skiprestoftag
tag_td
;only closing td works as tab
        call z,prcharvirtual_tab_stateful
        jp skiprestoftag

tag_head
;TODO read all tags inside (meta, title)
        jp skiprestoftag

tag_iframe
tag_frame
;TODO find src="..." (now we find last param)
        ;jr $
        call htmlskipspaces
tag_frame0
        ;ld a,(prcharvirtual_stateful_x)
        ;jr $
        
        ld a,(executetag_endchar)
        call htmlskipspaces_go

        ld de,wordbuf
        call getword_param_go ;в параметре могут быть закавыченные пробелы!
        ld (executetag_endchar),a
        or a
        ret z
        cp '>'
        jr nz,tag_frame0

        ld a,CLINKIMG
        ld (curlinkimg),a
        call setfontweight
         call rememberhrefyxposition
        call initstringbuf2

        ld a,'['
        call prcharvirtual_stateful
;read link to stringbuf2 until doublequote
;print it
        ld hl,wordbuf+5 ;after src="
tag_frame_typetag0
         ld a,(hl)
         or a
         jp z,tag_frame_typetagq
         cp 34
         jp z,tag_frame_typetagq
          cp "'"
          jp z,tag_frame_typetagq
         inc hl
         push hl
         push af
         call prcharvirtual_stateful
         pop af
        call printtostringbuf2
         pop hl
         jr tag_frame_typetag0

inithref
        display "inithref=",inithref
         ld a,(curlink)
         or a
         call nz,savestringbuf2 ;если img внутри a
        call initstringbuf2
        ;ld a,CLINK
        ;ld (curlink),a
        call setfontweight
         jp rememberhrefyxposition
         
tag_img
        jp z,skiprestoftag ;Z=closing tag (does nothing)
        ;jr $
        call htmlskipspaces
tag_img_readsrc
        call htmlskipspaces_go
        ld hl,tsrc
        call eatgivenword_go
        ;jr nz,tag_img_srcfail
        
        jr z,tag_img_srcq
tag_img_srcfail
        call htmlskipparam
          or a
          ret z
         cp '>'
        jr nz,tag_img_readsrc
        jr tag_img_opening_readaltq
tag_img_srcq
        
        ;ld hl,tsrc
        ;call eatgivenword_go
        ;jr nz,tag_img_opening_fail
;read link to stringbuf2 until doublequote
        ld a,CLINKIMG
        ld (curlinkimg),a
        call inithref
        
        call RDBYTE;rdbyte
         cp "'"
         jr z,tag_img_opening_read0
        cp 34
        jr nz,tag_img_opening_read_go

tag_img_opening_read0
        call RDBYTE;rdbyte
tag_img_opening_read_go
        or a
        ret z
        cp 34
        jr z,tag_img_opening_readq
         cp "'"
         jr z,tag_img_opening_readq
          cp " "
          jr z,tag_img_opening_readq
         ;push af
         ;call prcharvirtual_stateful
         ;pop af
        call printtostringbuf2
        jr tag_img_opening_read0
tag_img_opening_readq
tag_img_opening_fail
;a=last char read=quote
         ;jr $
        call htmlskipspaces
        push af
        ld a,'['
        call prcharvirtual_stateful
        pop af
tag_img_opening_readalt
;a=last char read
        call htmlskipspaces_go
        ld hl,talt
        call eatgivenword_go
        jr nz,tag_img_opening_altfail
        
        call RDBYTE;rdbyte
         cp "'"
         jr z,tag_img_opening_readalt0
        cp 34
        jr nz,tag_img_opening_readalt_go

tag_img_opening_readalt0
        call RDBYTE;rdbyte
tag_img_opening_readalt_go
        or a
        ret z
        cp 34
        jr z,tag_img_opening_readaltq
         cp "'"
         jr z,tag_img_opening_readaltq
;TODO mangled symbols
        call prcharvirtual_stateful
        jr tag_img_opening_readalt0
tag_img_opening_altfail
;find alt in next parameters
        call htmlskipparam
          or a
          ret z
         cp '>'
        jr nz,tag_img_opening_readalt
tag_img_opening_readaltq
         ld (executetag_endchar),a
tag_frame_typetagq ;TODO почему выше съедает первый фрейм atmturbo?
        ld a,']'
        call prcharvirtual_stateful
        xor a
        ld (curlinkimg),a
        jr closehrefq
        ;call prcharvirtual_stateful
        ;call savestringbuf2 ;after printing ']' to count full size
        ;xor a
        ;ld (curlink),a
        ;call setfontweight
        ;jp skiprestoftag

tag_a
        jr nz,tag_a_opening
        ld a,'}'
        call prcharvirtual_stateful
        xor a
        ld (curlink),a
closehrefq
        call savestringbuf2 ;after printing '}' to count full size
        ;xor a
        ;ld (curlink),a
        call setfontweight
        jp skiprestoftag
tag_a_opening
         ;jr $
        call htmlskipspaces
tag_a_opening_readhref
        call htmlskipspaces_go
        ld hl,thref
        call eatgivenword_go
        jr nz,tag_a_opening_hreffail
  
        ld a,CLINK
        ld (curlink),a
        call inithref
        
        ;zxdn: no quotes in href
        call RDBYTE;rdbyte
         cp "'"
         jr z,tag_a_opening_read0
        cp 34
        jr nz,tag_a_opening_read_go

;read link to stringbuf2 until doublequote
tag_a_opening_read0
        call RDBYTE;rdbyte
tag_a_opening_read_go
        or a
        ret z
        cp '>'
        jr z,tag_a_opening_readq
        cp 34
        jr z,tag_a_opening_readq
         cp "'"
         jr z,tag_a_opening_readq
        cp 0x0d
        jr z,tag_a_opening_read0 ;lib.ru
        cp 0x0a
        jr z,tag_a_opening_read0 ;lib.ru
         if 1==0
         cp '&'
         jr nz,tag_a_opening_read0ok
        call printtostringbuf2
;TODO проверить &amp; (forum.nedopc.com)
        call RDBYTE;rdbyte
         cp 'a'
         jr nz,tag_a_opening_read0ok
        call RDBYTE;rdbyte
        call RDBYTE;rdbyte
        call RDBYTE;rdbyte         
        jr tag_a_opening_read0
tag_a_opening_read0ok
         endif
         ;push af
         ;call prcharvirtual_stateful ;debug print
         ;pop af
        call printtostringbuf2
        jr tag_a_opening_read0
tag_a_opening_hreffail
;find href in next parameters
        call htmlskipparam
          or a
          ret z
         cp '>'
        jr nz,tag_a_opening_readhref
tag_a_opening_readq
         ld (executetag_endchar),a
tag_a_opening_fail
        ld a,'{'
        call prcharvirtual_stateful
        jp skiprestoftag


;skip until space/>/"/EOF
;if ", skip until another ", then skip space/>
;a=last char read
;out: a=last char (space/>/")
htmlskipparam0
        call RDBYTE;rdbyte
htmlskipparam
        or a
        ret z
        cp ' '
        ret z
        cp '>'
        ret z
        cp 34
        jr nz,htmlskipparam0
htmlskipparamquote0
        call RDBYTE;rdbyte
        or a
        ret z
        cp 34
        jr nz,htmlskipparamquote0
        jp RDBYTE;rdbyte ;skip space/>        

eatgivenword
;hl=word (asciiz)
;out: Z=OK (or else a=last char read)
eatgivenword0
        ld a,(hl)
        or a
        ret z
        call RDBYTE;rdbyte
        ;ld (executetag_endchar),a
eatgivenword_go
         or 0x20
        cp (hl)
        inc hl
        jr z,eatgivenword0
        ld (executetag_endchar),a
        ret ;fail

getword_tag
;hl=string
;de=wordbuf
;out: hl=terminator/space/> addr, a=terminator/space/> char
;TODO проверять переполнение WORDBUFSIZE
getword_tag0
        call RDBYTE;rdbyte
getword_tag_go
        or a
        jr z,getword_tagq
        cp ' '
        jr z,getword_tagq
        cp '>'
        jr z,getword_tagq
	 or 0x20
        ld (de),a
        inc de
        jr getword_tag0
getword_tagq
        push af
        xor a
        ld (de),a
        pop af
        ret


getword_mangledchar
;hl=string
;de=wordbuf
;out: hl=terminator/space/; addr, a=terminator/space/; char
;TODO проверять переполнение WORDBUFSIZE
getword_mangledchar0
        call RDBYTE;rdbyte
        ;or a
        ;jr z,getword_mangledcharq
         cp "A"
         jr c,getword_mangledcharq
        ;cp ';'
        ;jr z,getword_mangledcharq
        ;cp '#'
        ;jr z,getword_mangledcharq ;lib.ru &#97&#102&#114&#97&#110&#105&#117&#115&#64&#110&#101&#119&#109&#97&#105&#108&#46&#114&#117
        ld (de),a
        inc de
        jr getword_mangledchar0
getword_mangledcharq
        push af
        xor a
        ld (de),a
        pop af
        ret

;getword_param
;hl=string
;de=wordbuf
;out: hl=terminator/space/; addr, a=terminator/space/; char
;TODO проверять переполнение WORDBUFSIZE
getword_param0
        call RDBYTE;rdbyte
getword_param_go ;в параметре могут быть закавыченные пробелы!
        or a
        jr z,getword_paramq
         cp "'"
         jr z,getword_paramquote
         cp 34
         jr z,getword_paramquote
        cp ' '
        jr z,getword_paramspaceq
        ;cp ';'
        ;jr z,getword_paramcharq
        ;cp '#'
        ;jr z,getword_paramcharq ;lib.ru &#97&#102&#114&#97&#110&#105&#117&#115&#64&#110&#101&#119&#109&#97&#105&#108&#46&#114&#117
        cp '>'
        jr z,getword_paramq
getword_param0ok
	 or 0x20
        ld (de),a
        inc de
        jr getword_param0
getword_paramquote
        ld c,a
getword_paramquote0
        ld (de),a
        inc de
        call RDBYTE;rdbyte
        cp c
        jr nz,getword_paramquote0 ;TODO а если она никогда не закроетсЯ???
        jr getword_param0ok
getword_paramspaceq
;или тут проверЯть, в кавычках ли мы?
getword_paramq
        push af
        xor a
        ld (de),a
        pop af
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
	jr nz,strcp0.
	ret ;z

strcp_tillde0
;hl=s1
;de=s2
;out: Z (equal, hl=terminator of s1+1, de=terminator of s2+1), NZ (not equal, hl=erroraddr in s1, de=erroraddr in s2)
strcp_tillde0_0.
	ld a,[de] ;s2
        or a
        ret z
	cp [hl] ;s1
	ret nz
	inc hl
	inc de
	jr strcp_tillde0_0.

        
thref
        db "href=",0
tsrc
        db "src=",0
talt
        db "alt=",0
        
rememberhrefyxposition
        ld a,(prcharvirtual_stateful_x) ;для центрированных получается неправильно! на этом этапе экранный x ещё не известен!
        ld (hrefxposition),a
        ld hl,(curprintvirtualy)
        ld (hrefyposition),hl
        ret

tag_title
;not used, because header is skipped (TODO)
        ;jp z,tag_titleclose
        jp nz,tag_h1 ;open
;tag_titleclose
         ;ld a,1
         ;ld (utf8flag),a ;нельзя, т.к. title после charset
        call prcharvirtual_crlf_stateful ;</title> forces newline
        xor a ;z
        jp tag_h1

tag_li ;list line (no closing tag)? но на msn.com куча <li ><a...>...</a></li>
        jp z,skiprestoftag ;closing
        call prcharvirtual_crlf_stateful
        ld a,'*';'-';'*' ;TODO с учётом UTF8
        call prcharvirtual_stateful
        ld a,' '
        call prcharvirtual_stateful
        jp skiprestoftag

tag_meta
;TODO find "charset=UTF-8" or "charset=windows-1251"
tag_meta0
        ld b,a
        push bc
        call RDBYTE;rdbyte
        pop bc
        or a
        ret z
        cp '>'
        jp z,skiprestoftag0
        or 0x20
        cp 'w'
        jr nz,tag_meta0
        ld a,b
        cp '='
         ld a,'w'
         jr nz,tag_meta0
         xor a;ld a,0
         ld (utf8flag),a
        jp skiprestoftag_go

tag_style
tag_script
;TODO skip until </script>
tag_script0
        ld b,a
        push bc
        call RDBYTE;rdbyte
        pop bc
        or a
        ret z
        cp '/'
        jr nz,tag_script0
        ld a,b
        cp '<'
         ld a,'/'
        jr nz,tag_script0
        jp skiprestoftag_go

htmlskipspaces
htmlskipspaces0
        call RDBYTE;rdbyte
htmlskipspaces_go
        cp ' '
        jr z,htmlskipspaces0
        cp 0x0d
        jr z,htmlskipspaces0
        cp 0x0a
        jr z,htmlskipspaces0
        ld (executetag_endchar),a
        ret

tag_COMMENT
        call RDBYTE
        or a
        ret z
        cp '-'
        jr nz,tag_COMMENT
        call RDBYTE
        or a
        ret z
        cp '-'
        jr nz,tag_COMMENT
        call RDBYTE
        or a
        ret z
        cp '>'
        jr nz,tag_COMMENT
        ret
        
tag_font
;TODO push old font/pop old font

tag_link
;TODO find href

tag_dl
tag_dt
tag_doctype
tag_span
tag_html
tag_tbody
        jp skiprestoftag

tag_frameset ;before body
tag_body
        call htmlinitbody
        jp skiprestoftag

htmlinitbody
         xor a
         ld (iscentered),a
         inc a ;ld a,1
         ld (printableflag),a
;эти манипуляции затрут уже напечатанные фреймы:
         ;call prcharvirtual_x0
         call setdefaultfontweight
         jp setfontweight;call initstringbuf1 ;без этого не пишет коды установки цвета
        
skiprestoftag
;we can be at >/space/EOF (in executetag_endchar)
executetag_endchar=$+1
        ld a,0
skiprestoftag0
        cp '>'
        ret z
skiprestoftag_go
        call RDBYTE;rdbyte
        or a
        ret z
        jr skiprestoftag0

        
wordbuf
        ds WORDBUFSIZE
