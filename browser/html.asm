WORDBUFSIZE=128

CBOLD=1
CITALIC=2
CUNDERLINE=4
CSTROKE=8
        

loadhtml
        ;jr $
        ld de,0
        call setxymc_stateful
        ld a,'<' ;already read
        jr loadhtml_mainloop_go
        
loadhtml_mainloop
        rdbyte
        or a
        jp z,closequit
loadhtml_mainloop_go
        cp '<'
        jr z,loadhtml_mainloop_tag
        cp '&'
        jr z,loadhtml_mainloop_mangledchar
        cp 0x0d
        jr z,loadhtml_mainloop
        cp 0x0a
        jr z,loadhtml_mainloop
loadhtml_mainloop_mangledchar ;TODO
        call prcharmc_stateful
        jr loadhtml_mainloop

        
loadhtml_mainloop_tag
        ;jr $
        rdbyte
        ld (loadhtml_tagcloser),a
        cp '/'
        jr nz,executetag
        rdbyte
executetag
        ld de,wordbuf
        call getword_tag_go ;hl=terminator/space addr,a=char ;first char already read
        ld (executetag_endchar),a
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
        jp loadhtml_mainloop
        
getword_tag
;hl=string
;de=wordbuf
;out: hl=terminator/space/> addr, a=terminator/space/> char
;TODO проверять переполнение WORDBUFSIZE
getword_tag0
        rdbyte
getword_tag_go
        or a
        jr z,getword_tagq
        cp ' '
        jr z,getword_tagq
        cp '>'
        jr z,getword_tagq
        ld (de),a
        inc de
        jp getword_tag0
getword_tagq
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


tagslist
        dw tag_u
        db "u",0
        dw tag_b
        db "b",0
        dw tag_i
        db "i",0
        dw tag_i
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
        
        dw -1 ;end of tags list
        
tag_s
        ld hl,curstroke
        ld a,CSTROKE
        jr tag_u_b_i
tag_u
        ld hl,curunderline
        ld a,CUNDERLINE
        jr tag_u_b_i
tag_b
tag_strong
        ld hl,curbold
        ld a,CBOLD
        jr tag_u_b_i
tag_i
        ld hl,curitalic
        ld a,CITALIC
tag_u_b_i
        ld (hl),0
        jr z,$+3 ;Z=closing tag
        ld (hl),a
        call setfontweight
        jp skiprestoftag
        
tag_table
tag_br
        call prcharmc_crlf_stateful
        jp skiprestoftag
tag_tr
;only closing tr works as crlf
        call z,prcharmc_crlf_stateful
        jp skiprestoftag
tag_td
;only closing td works as tab
        call z,prcharmc_tab_stateful
        jp skiprestoftag

tag_head
;TODO read all tags inside (meta, title)
        
tag_a
;TODO skip spaces, read href

tag_font
;TODO push old font/pop old font


tag_img
tag_html
tag_meta
tag_title
tag_body
tag_tbody

        call skiprestoftag

        ret
        
skiprestoftag
;we can be at >/space/EOF (in executetag_endchar)
executetag_endchar=$+1
        ld a,0
        ;jr $
skiprestoftag0
        cp '>'
        ret z
        rdbyte
        or a
        ret z
        jr skiprestoftag0

setfontweight
curbold=$+1
        ld a,0
curitalic=$+1
        or 0
curunderline=$+1
        or 0
curstroke=$+1
        or 0
        ld hl,tfontweight
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        ld (prcharmc_attr),a
        ret
tfontweight
        db 0+64 ;S
        db 7 ;W
        db 3+64 ;g
        db 4 ;G
        db 4+64 ;r
        db 2 ;R
        db 6 ;y
        db 5+64 ;Y
STROKEPAPER=16
        db STROKEPAPER+0+64 ;S
        db STROKEPAPER+7 ;W
        db STROKEPAPER+3+64 ;g
        db STROKEPAPER+4 ;G
        db STROKEPAPER+4+64 ;r
        db STROKEPAPER+2 ;R
        db STROKEPAPER+6 ;y
        db STROKEPAPER+5+64 ;Y
       
        
wordbuf
        ds WORDBUFSIZE
