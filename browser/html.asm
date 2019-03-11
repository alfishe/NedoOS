WORDBUFSIZE=128

CBOLD=1
CITALIC=1;0x87;add a,a
CUNDERLINE=1;0x2f;cpl
CSTROKE=1;0xff
CLINK=2 ;TODO visited link
CMARK=4



loadhtml
        push af ;first char
        
         ld a,1 ;utf-8 by default
         ld (utf8flag),a
        call setdefaultfontweight

        ld hl,-1
        ld a,-1
        ld (lastpointer),hl
        ld (lastpointerHSB),a
        ld (last2pointer),hl
        ld (last2pointerHSB),a
        ld (firstpointer),hl
        ld (firstpointerHSB),a
        ld (first2pointer),hl
        ld (first2pointerHSB),a

        xor a
        ld (laststringx),a
        ld h,a
        ld l,a ;0
        ld (laststringy),hl
        ld (curprintvirtualy),hl

        ;call setfontweight
        call initstringbuf1 ;buf2 инициализируетс€ в тэге a/img
        
        ;ld de,0
        ;call setxymc_stateful
        pop af;ld a,'<' ;already read
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
        
        
loadhtml_mainloop
        rdbyte
        or a
        ret z
loadhtml_mainloop_go
        cp '<'
        jr z,loadhtml_mainloop_tag
        cp '&'
        jr z,loadhtml_mainloop_mangledchar
        cp 0x0d
        jr z,loadhtml_checkpremainloop
        cp 0x0a
        jr z,loadhtml_checkpremainloop
loadhtml_mainloop_mangledcharq
        call prcharvirtual_stateful
        jr loadhtml_mainloop
loadhtml_checkpremainloop
ispre=$+1
        ld b,0        
        djnz loadhtml_spacemainloop
        jr loadhtml_mainloop_mangledcharq

loadhtml_spacemainloop
        call countlinewidth
        ld a,h
        or l
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
        cpir ;найдЄм об€зательно
        jr mangledcharstrcp0
mangledchar_error=loadhtml_mainloop
        
loadhtml_mainloop_tag
        rdbyte
        ld (loadhtml_tagcloser),a
        cp '/'
        jr nz,executetag
        rdbyte
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
        cpir ;найдЄм об€зательно
        jr strcpexec0

executetag_error
;no such tag
         ;call skiprestoftag ;TODO
        jp loadhtml_mainloop
        
getword_tag
;hl=string
;de=wordbuf
;out: hl=terminator/space/> addr, a=terminator/space/> char
;TODO провер€ть переполнение WORDBUFSIZE
getword_tag0
        rdbyte
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
        jp getword_tag0
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
;TODO провер€ть переполнение WORDBUFSIZE
getword_mangledchar0
        rdbyte
getword_param_go
        or a
        jr z,getword_mangledcharq
        cp ' '
        jr z,getword_mangledcharq
        cp ';'
        jr z,getword_mangledcharq
        cp '>'
        jr z,getword_mangledcharq ;for param
	 or 0x20
        ld (de),a
        inc de
        jp getword_mangledchar0
getword_mangledcharq
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
	jp nz,strcp0.
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
        
        dw -1 ;end of tags list
        
;Z=closing tag

tag_p
        call prcharvirtual_crlf_stateful ;opening&closing
        jp skiprestoftag

tag_code
tag_pre
        call prcharvirtual_crlf_stateful ;opening&closing
        ld hl,ispre
        ld a,1
        jp skiprestoftag

tag_center
        ld hl,iscentered
        ld a,1
        jr tag_u_b_i

tag_h1
tag_h2
tag_h3
tag_h4
tag_h5
tag_h6
        jr z,tag_b
        ld a,1
        ld (iscentered),a
        jr tag_b

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
        call setfontweight
        jp skiprestoftag
        
tag_ul ;list
        jp nz,skiprestoftag ;opening (li does newline)
tag_div
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

tag_img
        jp z,skiprestoftag ;Z=closing tag (does nothing)
        ld a,CLINK
        ld (curlink),a
        call setfontweight
         call rememberhrefyxposition
;TODO skip spaces before read src
        ld hl,tsrc
        call eatgivenword
        jr nz,tag_img_opening_fail
;read link to stringbuf2 until doublequote
        call initstringbuf2
tag_img_opening_read0
        rdbyte
        or a
        ret z
        cp 34
        jr z,tag_img_opening_readq
        call printtostringbuf2
        jr tag_img_opening_read0
tag_img_opening_readq
tag_img_opening_fail
;TODO skip spaces before read alt
        ld a,'['
        call prcharvirtual_stateful
        ld hl,talt
        call eatgivenword
        jr nz,tag_img_opening_altfail
tag_img_opening_readalt0
        rdbyte
        or a
        ret z
        cp 34
        jr z,tag_img_opening_readaltq
        call prcharvirtual_stateful
        jr tag_img_opening_readalt0
tag_img_opening_readaltq
tag_img_opening_altfail
        ld a,']'
        call prcharvirtual_stateful
        
        call savestringbuf2 ;after printing ']' to count full size
        
        xor a
        ld (curlink),a
        call setfontweight
        jp skiprestoftag

tag_a
        jr nz,tag_a_opening
        ld a,'}'
        call prcharvirtual_stateful
        
        call savestringbuf2 ;after printing '}' to count full size
        
        xor a
        ld (curlink),a
        call setfontweight
        jp skiprestoftag
tag_a_opening
        ld a,CLINK
        ld (curlink),a
        call setfontweight
         call rememberhrefyxposition
;TODO skip spaces before read href
        ld hl,thref
        call eatgivenword
        jr nz,tag_a_opening_fail
        
        call initstringbuf2
        
        ;zxdn: no quotes in href
        rdbyte
        cp 34
        jr nz,tag_a_opening_read_go
        
;read link to stringbuf2 until doublequote
tag_a_opening_read0
        rdbyte
tag_a_opening_read_go
        or a
        ret z
        cp '>'
        jr z,tag_a_opening_readq
        cp 34
        jr z,tag_a_opening_readq
        call printtostringbuf2
        jr tag_a_opening_read0
tag_a_opening_readq
         ld (executetag_endchar),a
tag_a_opening_fail
        ld a,'{'
        call prcharvirtual_stateful
        jp skiprestoftag

eatgivenword
        ;jr $
;hl=word (asciiz)
;out: Z=OK (or else a=last char read)
eatgivenword0
        ld a,(hl)
        or a
        ret z
        rdbyte
        ld (executetag_endchar),a
        cp (hl)
        inc hl
        jr z,eatgivenword0
        ret ;fail
        
thref
        db "href=",0
tsrc
        db "src=",34,0
talt
        db " alt=",34,0
        
rememberhrefyxposition
        ld a,(prcharvirtual_stateful_x)
        ld (hrefxposition),a
        ld hl,(curprintvirtualy)
        ld (hrefyposition),hl
        ;jr $
        ret

tag_title
        ;jp z,tag_titleclose
        jp nz,tag_h1 ;open
;tag_titleclose
         ;ld a,1
         ;ld (utf8flag),a ;нельзя, т.к. title после charset
        call prcharvirtual_crlf_stateful ;</title> forces newline
        xor a ;z
        jp tag_h1

tag_li ;list line (no closing tag)
        jp z,skiprestoftag ;closing
        call prcharvirtual_crlf_stateful
        ld a,'*';'Х';'*' ;TODO с учётом UTF8
        call prcharvirtual_stateful
        ld a,' '
        call prcharvirtual_stateful
        jp skiprestoftag

tag_meta
;TODO find "charset=UTF-8" or "charset=windows-1251"
        ;jp skiprestoftag
tag_meta0
        ld b,a
        push bc
        rdbyte
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
         ld a,0
         ld (utf8flag),a
        jp skiprestoftag

tag_script
;TODO skip until </script>
tag_scriptb0
        ld b,a
;tag_script0
        push bc
        rdbyte
        pop bc
        or a
        ret z
        cp '/'
        jr nz,tag_scriptb0
        ld a,b
        cp '<'
         ld a,'/'
        jr nz,tag_scriptb0
        jp skiprestoftag

htmlskipspaces0
        rdbyte
htmlskipspaces
        cp ' '
        jr z,htmlskipspaces0
        ld (executetag_endchar),a
        ret
        
tag_frame
;TODO find src="..." (now we find last param)
        ;jr $
tag_frame0
        ld a,(executetag_endchar)
        call htmlskipspaces
        
        ld de,wordbuf
        call getword_param_go
        ld (executetag_endchar),a
        or a
        ret z
        cp '>'
        jr nz,tag_frame0

        ld a,CLINK
        ld (curlink),a
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
         jr z,tag_frame_typetagq
         cp 34
         jr z,tag_frame_typetagq
         inc hl
         push hl
         push af
         call prcharvirtual_stateful
         pop af
        call printtostringbuf2
         pop hl
         jr tag_frame_typetag0
tag_frame_typetagq
        jp tag_img_opening_readaltq
        ;jp skiprestoftag
        
tag_font
;TODO push old font/pop old font

tag_link
;TODO find href


tag_frameset
tag_style
tag_COMMENT
tag_doctype
tag_span
tag_html
tag_tbody
tag_body

        jp skiprestoftag
        
skiprestoftag
;we can be at >/space/EOF (in executetag_endchar)
executetag_endchar=$+1
        ld a,0
skiprestoftag0
        cp '>'
        ret z
        rdbyte
        or a
        ret z
        jr skiprestoftag0

setdefaultfontweight
        xor a
        ld (curbold),a
        ld (curlink),a
        ld (curitalic),a
        ld (curunderline),a
        ld (curstroke),a
        ret

setfontweight
        ;jr $

        if 1==1
         ld a,1
         call prcharvirtual_stateful
curbold=$+1
        ld a,0
curlink=$+1
        or 0
curmark=$+1
        or 0
        inc a
        call prcharvirtual_stateful
         ld a,2
         call prcharvirtual_stateful
curitalic=$+1
        ld a,0
        inc a
        call prcharvirtual_stateful
         ld a,3
         call prcharvirtual_stateful
curstroke=$+1
        ld a,0
        inc a
        call prcharvirtual_stateful
         ld a,4
         call prcharvirtual_stateful
curunderline=$+1
        ld a,0
        inc a
        call prcharvirtual_stateful
        
        else
        
curbold=$+1
        ld a,0
curlink=$+1
        or 0
        ld hl,tfontweight
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        ld (prcharmc_attr),a
curitalic=$+1
        ld a,0
        ld (prcharmc_italic1),a
        ld (prcharmc_italic2),a
        ld (prcharmc_italic3),a
        ld (prcharmc_italic4),a
curstroke=$+1
        ld a,0
        ld (prcharmc_stroke),a
curunderline=$+1
        ld a,0
        ld (prcharmc_underline),a
        endif
        
        ret

        
wordbuf
        ds WORDBUFSIZE
