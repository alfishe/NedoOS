	org TEXTADDRESS

/*
Commands
	0xB0 next word is the pointer to text to show
	\p scroll pause
	\s scroll nopause
	\f fade to black
	\u text cursor to up and clear
	\c clear text
	\w waitkey
	\l load image to buf
	\i show image from buf
	\F fade image from buf
	\d wait 1 sec
	\T text window to fullscreen
	\3 text window to bottom 3 lines
	\4 text window to bottom 4 lines
	\b save breakpoint
	\x save breakpoint and exit to game control node
	\U text cursor to up without clear
	\W fade to white
	\j<s> jump to symbol @
	\e end of text
*/

text_obj

txt_mainmenu
	db 0x0A
	db "    Бесконечное лето",0x0D,0x0A
	db 0x0D,0x0A
	db " 1. Графический режим: ", 0xB0
text_gmode
	dw txt_text,0x0D0A
	db " 2. Музыкальный процессор: ", 0xB0
text_smode
	dw txt_ay,0x0D0A
	db " 3. Начать игру",0x0D,0x0A
	db " 0. Выход",0x0D,0x0A
	db ":"
	db 0

txt_prolog1
	incbin "txt/prolog1"
	db 0
txt_prolog2
	incbin "txt/prolog2"
	db 0

text_obj_end