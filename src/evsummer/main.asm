        DEVICE ZXSPECTRUM48
        include "../_sdk/sys_h.asm"
        org PROGSTART

GCMD_PRTEXT EQU 0xF0
GCMD_INPUT EQU 0xF1
GCMD_VARIANT EQU 0xF2
GCMD_GOTO EQU 0xF3
GCMD_SETVARB EQU 0xF4
GCMD_SETVARW EQU 0xF5
GCMD_CHECKVAR EQU 0xF6
GCMD_SHOWPICTURE EQU 0xF7
GCMD_CLEARTEXT EQU 0xF8
GCMD_CONTINUE EQU 0xF9
GCMD_LOADTEXT EQU 0xFA
GCMD_CLOSEFILE EQU 0xFB
GCMD_JUMP EQU 0xFC
GCMD_INCVARB EQU 0xFD
GCMD_QUIT EQU 0xFF
GMODE_TEXT EQU 0
GMODE_16C EQU 1
GMODE_256C EQU 2
SMODE_AY EQU 0
SMODE_GS EQU 1


GAMEADDRESS EQU 0x8000
TEXTADDRESS EQU 0xC000
;STARTNODE EQU mainnode

cmd_begin
	ld sp,0x3FFF
	ld e,6
	OS_SETGFX

	OS_GETSCREENPAGES
	ld (screenpage1),de
	ld (screenpage3),hl

	OS_GETMAINPAGES
	ld a,d
	ld (win1page),a
	ld a,e
	ld (win2page),a
	ld a,h
	ld (win3page),a
	ld a,l
	ld (win4page),a

	OS_NEWPAGE
	or a
	jp nz,memoryerror
	ld a,e
	ld (picbufpage1),a
	OS_NEWPAGE
	or a
	jp nz,memoryerror
	ld a,e
	ld (picbufpage2),a

	ld hl,gamefile
	ld de,GAMEADDRESS
	call loadfile_hlde
	call closefile

	ld e,0
	OS_SETGFX
	ld e,0
	OS_CLS

	call setgraphpages
	ld hl,0

	call cleartoend_hl
	call setscreen
	ld hl,(textstart)
	call setcursor_hl

	call setgamepages
	ld hl,prolog1
	call parsenode_hl

	ld e,6
	OS_SETGFX
        QUIT
	display "loadfile_hlde: ",loadfile_hlde

loadfile_hlde
	push de
	ld de,buf
	call strcopy_hlde
	pop de
loadfile_bufde ;hl=fn de=address
	ld hl,buf
	ld bc,(filehandle)
	ld a,b
	or c
	push de
	push hl
	call nz,closefile
	pop hl
	pop de
	push de
	ex hl,de
	OS_OPENHANDLE
	or a
	jp nz,fileopenerror
	pop de
	ld (filehandle),bc
readfile ;read to de
	ld hl,0x4000
	ld bc,(filehandle)
	push de
	OS_READHANDLE
	pop de ; read address
	or a
	jp nz,filereaderror
	ret
closefile
	ld bc,(filehandle)
	OS_CLOSEHANDLE
	ld bc,0
	ld (filehandle),bc
	ret

parsenode_hl
;	ld a,(hl)
;	inc hl ; size
parsenode_hl0
	ld de,parsenode_hl0 ; точка возврата
	push de
	ld a,(hl)
	inc hl
	cp GCMD_PRTEXT
	jp z,showtext_hl
	cp GCMD_SHOWPICTURE
	jp z,cmd_showpicture
	cp GCMD_CLEARTEXT
	jp z,cmd_cleartext
	cp GCMD_INPUT
	jp z,cmd_inputkey
	cp GCMD_VARIANT
	jp z,cmd_variant
	cp GCMD_GOTO
	jp z,cmd_goto
	cp GCMD_SETVARB
	jp z,cmd_setvarb
	cp GCMD_SETVARW
	jp z,cmd_setvarw
	cp GCMD_CHECKVAR
	jp z,cmd_checkvar
	cp GCMD_CONTINUE
	jp z,cmd_continue
	cp GCMD_LOADTEXT
	jp z,cmd_loadtext
	cp GCMD_JUMP
	jp z,cmd_jump
	cp GCMD_INCVARB
	jp z,cmd_incvarb
	cp GCMD_QUIT
	jp z,cmd_quit
/*	YIELDGETKEY
	ld a,c
	cp key_esc
	ret z*/
	jp parsenode_hl0

/*input
	call inputtext_a

	ret*/

cmd_showpicture
	ld de,buf
	call strcopy_hlde
	push hl
;	call nextscreen
	call setgraphpages
	call loadpicture
	call showpicture
	call setgamepages
	call setscreen
	pop hl
	ret

cmd_cleartext
	push hl
	call setgraphpages
	call cleartext
	call setgamepages
	pop hl
	ret

cmd_variant
	ld a,(lastkey)
cmd_variant0
	ld b,(hl) ;variantkey
	inc hl
	cp b
	jp nz,cmd_variant_next
	inc hl ;skip pointer to next variant
	inc hl
	ret
cmd_variant_next
cmd_goto
	ld e,(hl) ; load nextcmd address
	inc hl
	ld d,(hl)
	inc hl
	ex hl,de
	ret

cmd_quit
	pop hl
	call closefile
	ret

cmd_setvarb
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	inc hl
	ld (de),a
	ret

cmd_setvarw
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	ld a,(hl)
	ld (de),a
	inc hl
	ret

cmd_checkvar
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(de)
	ld (lastvar),a
	ret

cmd_inputkey
	push hl
	YIELDGETKEYLOOP
	pop hl
	ld (lastkey),a
	ret

cmd_continue
	ld de,(breakpoint)
	jp showtext_de

cmd_loadtext
	ld de,buf
	call strcopy_hlde
	push hl
	ld de,TEXTADDRESS
	call loadfile_bufde
	pop hl
	ret

cmd_jump
	ld a,(hl) 
	inc hl
	push hl
	ld b,a
	ld de,(breakpoint)
cmd_jump0
	push bc
	call getchar
	pop bc
	cp 0x0A
	jr nz,cmd_jump0
	push bc
	call getchar
	pop bc
	cp b
	jr nz,cmd_jump0
	pop hl
	jp showtext_de

cmd_incvarb
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(de)
	inc a
	ld (de),a
	ret

	display "showtext_hl ",showtext_hl
getchar ;reads char from de to a. If end of memory - read from file
	ld a,(de)
	push af
	inc de
	ld a,d
	or e
	jr nz,nextchar_end
	ld de,TEXTADDRESS
	call readfile
nextchar_end
	pop af
	ret

copytohl_c ; getchar from de, copy to hl while (de) != c
	push bc
	push hl
	call getchar
	pop hl
	pop bc
	cp c
	jp z,copytohl_c_end
	ld (hl),a
	inc hl
	jp copytohl_c
copytohl_c_end
	xor a
	ld (hl),a
	ret

skipto_c ; skip de, while (de) != c
	push bc
	call getchar
	pop bc
	cp c
	jp nz,skipto_c
	ret

showtext_hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
showtext_de
	push hl
	push de
	call setgraphpages
	pop de
showtext_hl0
	call getchar
	or a
	jp z,showtext_hl_end
	cp 0xB0
	jp z,showtext_hl_cmdB0
	cp '\'
	jp z,showtext_hl_textcmd
	cp '|'
	jp z,showtext_hl_skiptonextline
	cp '"'
	jp z,showtext_hl_doublequotes
	cp 0x0D
	jp z,showtext_hl0
	cp ' '
	jp z,showtext_hl0
	cp 0x0A
	jp z,showtext_hl0
	jp showtext_hl_keyword
;	jp nz,showtext_hl_print
;	jp nz,showtext_hl0
showtext_hl_nextline
	ld a,(scrollpause)
	or a
	jp z,showtext_hl_nextline_nopause
	push de
	YIELDGETKEYLOOP
	pop de
	ld a,c
	cp key_esc
	jp z,showtext_hl_endandquit
showtext_hl_nextline_nopause
	push de
	call nextline
	pop de
	jp showtext_hl0
showtext_hl_skiptonextline
	call getchar
	cp 0x0A
	jp nz,showtext_hl_skiptonextline
	jp showtext_hl0
showtext_hl_print
	push de
;	dec de ;???
	call printdelay
	call printchar
	pop de
showtext_hl_cmdB0
	ex hl,de
	call showtext_hl
	ex hl,de
	jp showtext_hl0

showtext_hl_doublequotes
	call showtext_hl_dq_start
	jp showtext_hl_textcmd_w

showtext_hl_keyword
	ld hl,buf
	ld (hl),a
	inc hl
	ld c,' '
	call copytohl_c
	push de

	ld hl,buf
	ld de,txt_menu
	call strcmp_hlde
	jp z,showtext_hl_keyword_menu
	ld hl,buf
	ld de,template_dg
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_th
	call strcmp_hlde
	jp z,showtext_hl_keyword_th
	ld hl,buf
	ld de,template_me
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_el
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_un
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_dv
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_sl
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_us
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_mt
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_elp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_unp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_dvp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_slp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_usp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	ld hl,buf
	ld de,template_mtp
	call strcmp_hlde
	jp z,showtext_hl_keyword_name
	pop de
	ld c,0x0A
	call skipto_c
	jp showtext_hl0
showtext_hl_keyword_name
	ld hl,(textstart)
	push de
	call setcursor_hl
	call cleartext
	pop hl
	call printgr_hl
	pop de
	ld c,'"'
	call skipto_c
	call showtext_hl_dq_noclear
	jp showtext_hl_textcmd_w
showtext_hl_keyword_menu
	pop de
	ld c,'"'
	call skipto_c
	call showtext_hl_dq_start
	jp showtext_hl0
showtext_hl_keyword_th
	ld hl,(textstart)
	push de
	call setcursor_hl
	call cleartext
	pop hl
	call printgr_hl
	pop de
	ld c,'"'
	call skipto_c
	call showtext_hl_dq_noclear0
	jp showtext_hl_textcmd_w

	display "showtext_hl_keyword: ",showtext_hl_keyword


showtext_hl_brace
	ld c,'}'
	ld hl,bracebuf
	call copytohl_c
	push de
	ld de,bracebuf
	ld hl,txt_w
	call strcmp_hlde
	jp z,showtext_hl_brace_w
	ld de,bracebuf
	ld hl,txt_i
	call strcmp_hlde
	jp z,showtext_hl_brace_i
	ld de,bracebuf
	ld hl,txt_i_close
	call strcmp_hlde
	jp z,showtext_hl_brace_i_close
	pop de
	jp showtext_hl_dq_print0
showtext_hl_brace_w
	YIELDGETKEYLOOP
	pop de
	ld a,c
	cp key_esc
	jp z,showtext_hl_endandquit
	jp showtext_hl_dq_print0
showtext_hl_brace_i
	pop de
	dec de
	ld a,'<'
	ld (de),a
	jp showtext_hl_dq_print0
showtext_hl_brace_i_close
	pop de
	dec de
	ld a,'>'
	ld (de),a
	jp showtext_hl_dq_print0


showtext_hl_dq_start
	ld hl,(autoclear)
	ld a,h
	or l
	jp z,showtext_hl_dq_noclear
	push de
	ld hl,(textstart)
	call setcursor_hl
	call cleartext
	pop de
	jp showtext_hl_dq_noclear0
showtext_hl_dq_noclear
	push de
	call nextline
	pop de
showtext_hl_dq_noclear0
	ld hl,buf
	ld a,' '
	ld (hl),a
	inc hl
	ld c,'"'
	call copytohl_c
	push de ;original pointer
	ld de,buf
	jp showtext_hl_dq
showtext_hl_dq_nl
	push de
	call nextline
	pop de
	push de
	ld bc,0
	ld hl,0xFFFF
	ld (lastspace),hl
	jp showtext_hl_dq0
	display "showtext_hl_dq: ",showtext_hl_dq
showtext_hl_dq
	ld bc,0x0200 ;space
	ld hl,0xFFFF
	ld (lastspace),hl
	push de 
showtext_hl_dq0
	ld a,(de)
	inc de
	or a
	jp z,showtext_hl_dq_print_full
	cp ' '
	call z,showtext_hl_dq_rememspace
	push bc
	push de
	call get_char_address
	pop de
	pop bc
	inc hl ;to width
	ld a,(hl)
	add b
	cp 160 ;Screen width
	jp nc,showtext_hl_dq_print
	ld b,a
	jp showtext_hl_dq0
showtext_hl_dq_rememspace
	dec de
	ld (lastspace),de
	inc de
	ret
showtext_hl_dq_print_full ;do not check lastspace
	ld hl,0xFFFF
	ld (lastspace),hl
showtext_hl_dq_print ;print fragment
	pop de
showtext_hl_dq_print0
	ld a,(de)
	inc de
	cp '{'
	jp z,showtext_hl_brace
	cp 0x0A
	jp z,showtext_hl_dq_nl
	or a
	jp z,showtext_hl_dq_end
	push de
	call printchar
	call printdelay
	pop de
	ld hl,(lastspace)
	or a
	sbc hl,de
	jp c,showtext_hl_dq_nl
	jp showtext_hl_dq_print0
showtext_hl_dq_end
	pop de ; original text pointer
	ret

showtext_hl_textcmd
	call getchar
	cp 'A'
	jp z,showtext_hl_textcmd_A
	cp 'a'
	jp z,showtext_hl_textcmd_a
	cp 'p'
	jp z,showtext_hl_textcmd_p
	cp 's'
	jp z,showtext_hl_textcmd_s
	cp 'u'
	jp z,showtext_hl_textcmd_u
	cp 'U'
	jp z,showtext_hl_textcmd_U
	cp 'c'
	jp z,showtext_hl_textcmd_c
	cp 'w'
	jp z,showtext_hl_textcmd_w
	cp 'i'
	jp z,showtext_hl_textcmd_i
	cp 'f'
	jp z,showtext_hl_textcmd_f
	cp 'W'
	jp z,showtext_hl_textcmd_W
	cp 'F'
	jp z,showtext_hl_textcmd_F
	cp 'l'
	jp z,showtext_hl_textcmd_l
	cp 'd'
	jp z,showtext_hl_textcmd_d
	cp '2'
	jp z,showtext_hl_textcmd_2
	cp '3'
	jp z,showtext_hl_textcmd_3
	cp '4'
	jp z,showtext_hl_textcmd_4
	cp '5'
	jp z,showtext_hl_textcmd_5
	cp 'T'
	jp z,showtext_hl_textcmd_T
	cp 'b'
	jp z,showtext_hl_textcmd_b
	cp 'x'
	jp z,showtext_hl_textcmd_x
	cp 'j'
	jp z,showtext_hl_textcmd_j
	cp 'e'
	jp z,showtext_hl_end
	jp showtext_hl0
showtext_hl_textcmd_A
	ld a,1
	ld (autoclear),a
	jp showtext_hl0
showtext_hl_textcmd_a
	xor a
	ld (autoclear),a
	jp showtext_hl0
showtext_hl_textcmd_p
	ld a,1
	ld (scrollpause),a
	jp showtext_hl0
showtext_hl_textcmd_s
	xor a
	ld (scrollpause),a
	jp showtext_hl0
showtext_hl_textcmd_u
	ld hl,(textstart)
	push de
	call setcursor_hl
	call cleartext
	pop de
	jp showtext_hl0
showtext_hl_textcmd_U
	ld hl,(textstart)
	push de
	call setcursor_hl
	pop de
	jp showtext_hl0
showtext_hl_textcmd_c
	push de
	call cleartext
	pop de
	jp showtext_hl0
showtext_hl_textcmd_w
	push de
	YIELDGETKEYLOOP
	pop de
	ld a,c
	cp key_esc
	jp z,showtext_hl_endandquit
	ld (lastkey),a
	jp showtext_hl0
showtext_hl_textcmd_i
	push de
	call nextscreen
	call showpicture
	pop de
	jp showtext_hl0
showtext_hl_textcmd_f
	push de
	call fadeblack
	pop de
	jp showtext_hl0
showtext_hl_textcmd_W
	push de
	call fadewhite
	pop de
	jp showtext_hl0
showtext_hl_textcmd_F
	push de
;	call nextscreen
;	call setgraphpages
;	call makefadepixel
;	ld de,(fadepixel)
;	call fillwithpixel
	call setpal
;	call setscreen
	call fadein
	pop de
	jp showtext_hl_textcmd_2
showtext_hl_textcmd_l
	ex hl,de
	ld de,buf
	call strcopy_hlde
	push hl
	call setpicbufpages
	call loadpicture
	call setgraphpages
	pop de
	jp showtext_hl_textcmd_2
showtext_hl_textcmd_d
	push de
	call bigdelay
	pop de
	jp showtext_hl0
showtext_hl_textcmd_2
	ld hl,0xB400
	ld (textstart),hl
	jp showtext_hl0
showtext_hl_textcmd_3
	ld hl,0xAA00
	ld (textstart),hl
	jp showtext_hl0
showtext_hl_textcmd_4
	ld hl,0xA000
	ld (textstart),hl
	jp showtext_hl0
showtext_hl_textcmd_5
	ld hl,0x9600
	ld (textstart),hl
	jp showtext_hl0
showtext_hl_textcmd_T
	ld hl,0x0000
	ld (textstart),hl
	jp showtext_hl0
showtext_hl_textcmd_b
	ld (breakpoint),de
	jp showtext_hl0
showtext_hl_textcmd_j
	call getchar
	ld b,a
showtext_hl_textcmd_j0
	push bc
	call getchar
	pop bc
	cp 0x0A
	jr nz,showtext_hl_textcmd_j0
	push bc
	call getchar
	pop bc
	cp b
	jr nz,showtext_hl_textcmd_j0
	jp showtext_hl0
showtext_hl_textcmd_x
	ld (breakpoint),de
showtext_hl_end
	call setgamepages
	pop hl
	ret
showtext_hl_endandquit
	call setgamepages
	pop hl
	ld hl,pcmd_quit
	ret

memoryerror
	OS_CLOSEHANDLE
	ld e,6
	OS_SETGFX
	ld e,0
	OS_CLS
	ld hl,txt_memoryerror
	call print_hl
	QUIT

fileopenerror
	ld e,6
	OS_SETGFX
	ld e,0
	OS_CLS
	ld hl,txt_fopenerror
	call print_hl
	ld hl,buf
	call print_hl
	ld hl,txt_nl
	call print_hl
	QUIT

filereaderror
	OS_CLOSEHANDLE
	ld e,6
	OS_SETGFX
	ld e,0
	OS_CLS
	ld hl,txt_freaderror
	call print_hl
	ld hl,buf
	call print_hl
	ld hl,txt_nl
	call print_hl
	QUIT

print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR
	pop hl
	inc hl
	jp print_hl
	ret

strcopy_hlde
	ld a,(hl)
	cp 0x0A
	jr z,strcopy_hlde_end
	cp 0x0D
	jr z,strcopy_hlde_skip
	ld (de),a
	inc hl
	inc de
	ret z
	or a
	jr nz,strcopy_hlde
	ret
strcopy_hlde_end
	inc hl
	xor a
	ld (de),a
	ret
strcopy_hlde_skip
	inc hl
	jr strcopy_hlde

strcmp_hlde ;de start from or eq to hl
	ld a,(de)
	cpi
	ret nz
	inc de
	or a
	ret z
	jr strcmp_hlde

win1page ds 1
win2page ds 1
win3page ds 1
win4page ds 1
oldtimer ds 2
screenpage1 ds 1
screenpage2 ds 1
screenpage3 ds 1
screenpage4 ds 1
picbufpage1 ds 1
picbufpage2 ds 1
gamefile db "game.o",0
textfile db "text.o",0
buf ds 255
bracebuf ds 16
breakpoint dw TEXTADDRESS
filehandle dw 0

pal	ds 32

lastvar
lastkey db 0
lastspace dw 0
lastchar db 0

var_gmode db 0
var_sound db 0
gmode db GMODE_TEXT
smode db SMODE_AY


;game variables
var_prologue db 0
var_slavya db 0
var_alisa db 0

txt_w db "w",0
txt_i db "i",0
txt_i_close db "/i",0


txt_text db "textmode",0
txt_16c db "16 color (ATM/EVOLUTION)",0
txt_256c db "256 color (EVOLUTION)",0
txt_ay db "AY",0
txt_gs db "GS",0
txt_menu db "menu:",0
template_elp db "elp",0,"Пионер",0
template_mtp db "mtp",0,"Вожатая",0
template_slp db "slp",0,"Пионерка",0
template_dvp db "dvp",0,"Пионерка",0
template_unp db "unp",0,"Пионерка",0
template_usp db "usp",0,"Пионерка",0
template_dg db "dg",0,"Девочка",0
template_th db "th",0," ~ ",0
template_me db "me",0,"Семён",0
template_el db "el",0,"Электроник",0
template_sl db "sl",0,"Славя",0
template_un db "un",0,"Лена",0
template_dv db "dv",0,"Алиса",0
template_us db "us",0,"Ульяна",0
template_mt db "mt",0,"Ольга Дмитриевна",0

pcmd_quit db GCMD_QUIT

txt_fopenerror 	db 0x0A,"Cannot open file: ",0
txt_freaderror 	db 0x0A,"Cannot read file: ",0
txt_nl		db 0x0D,0x0A,0
txt_memoryerror db 0x0A,"Memory allocation error!",0x0D,0x0A,0

	include "graphics.asm"
	include "music.asm"

cmd_end
	include "game.asm"

	display "parsenode_hl ", parsenode_hl
	display "main.com size ",/d,cmd_end-cmd_begin," bytes"
	display "game.o ",/d,game_obj_end-game_obj," bytes"

	savebin "evsummer.com",cmd_begin,cmd_end-cmd_begin
	savebin "game.o",game_obj,game_obj_end-game_obj
	;LABELSLIST "../us/user.l"
