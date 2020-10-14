
;KEYSCAN
;.rep_wait=$+1
;	ld a,0
;	dec a
;	ret m
;	ld (.rep_wait),a
;	ret


;--------------------------------------------------
keyqueueput_codenolang

GETKEY
.KEY_MODE_NONE		= 0x00
.KEY_MODE_SHIFT		= 0x01
.KEY_MODE_ALT		= 0x02
.KEY_MODE_CTRL		= 0x04
.KEY_MODE_RUS		= 0x08
.KEY_MODE_UP		= 0x10
.KEY_MODE_E0		= 0x20
.KEY_MODE_CAPS		= 0x40
.KEY_MODE_NUML		= 0x80

.bKEY_MODE_SHIFT	= 0x00
.bKEY_MODE_ALT		= 0x01
.bKEY_MODE_CTRL		= 0x02
.bKEY_MODE_RUS		= 0x03
.bKEY_MODE_UP		= 0x04
.bKEY_MODE_E0		= 0x05
.bKEY_MODE_CAPS		= 0x06
.bKEY_MODE_NUML		= 0x07
;out: ha=key (NOKEY=none), bc=keynolang keeps de,l
;H0=1 for control codes, H0=0 for symbols
;TODO где-то в H добавить биты регистра клавиатуры
		ld hl,(KEY_PUTREDRAW.redrawkey)
		ld a,l
		or a
		jr z,.noredraw
		ld bc,0x0000
		ld (KEY_PUTREDRAW.redrawkey),bc
		ld c,a
		ld b,h
		ret
.noredraw
.mode=$+1
		ld hl,0x0000
		ld bc,0xdef7
		out (c),c
		ld b,0xbe
		in a,(c)
		jr nz,.not_zero
		ld a,(KEYSCAN.rep_wait)
		or a
		jr nz,.zero_ret

		ld bc,(KEY_PUTREDRAW.rep_key)
		ld a,c
		or a
		jr z,.zero_ret
		ld a,1;3
		ld (KEYSCAN.rep_wait),a
		ld a,b
		jp nz,.retsymb1
.zero_ret
		xor a
		ld h,a
		ld b,h
		ld c,a
		ret

.not_zero
		ld de,0
		ld (KEY_PUTREDRAW.rep_key),de
		cp 0xff
		jr nz,.decode
		ld b,0xde		;переполнено
		ld a,0x0c		;сбросить буфер
		out (c),a
		ld b,0xbe
		ld a,1
		out (c),a
		xor a
		ld (.mode),a
		jr .zero_ret
.decode
		bit .bKEY_MODE_UP,l
		jp nz,.keypressmode
		
		cp 0xe0
		jr c,.iskeycode
		jr z,.isE0
		ld a,.KEY_MODE_UP
.savemode_or
		or l
.savemode
		ld (.mode),a
		jr .noredraw
.isE0		
		ld a,.KEY_MODE_E0
		jr .savemode_or
.iskeycode
		add 0xff&.scodes
		ld e,a
		ld a,0
		adc 0xff&(.scodes>>8)
		ld d,a
		ld a,(de)
		or a
		jr z,.zero_ret	;кнопка не поддерживается
		 ;bit .bKEY_MODE_CTRL,l
		 ;jr nz,.zero_ret ;Ctrl+F1 - это не F1
		cp 64
		jr nc,.not_simbol
		ld b,a
		 bit .bKEY_MODE_CTRL,l
		 jr nz,.ctrl_mod
		cp 27
		ld a,.KEY_MODE_SHIFT
		jr nc,.base_noneed_caps
		bit .bKEY_MODE_ALT,l
		jr z,.no_alt_mod
		ld a,b
		jr .retsymb
;.no_alt_mod
		;bit .bKEY_MODE_CTRL,l
		;jr z,.no_ctrl_mod
.ctrl_mod
		ld a,b
		add a,0xff&.ctrl_decode
		ld e,a
		ld a,0
		adc a,0xff&(.ctrl_decode>>8)
		ld d,a
		ld a,(de)
		ld c,a
		jr .retsymb
.no_alt_mod
.no_ctrl_mod
		ld a,.KEY_MODE_SHIFT|.KEY_MODE_CAPS
.base_noneed_caps
		and l
		ld a,0
		jp pe,.base_not_sh
		ld a,.mod_sh-.mod_base
.base_not_sh
		add a,b
		add 0xff&.char_decode
		ld e,a
		ld a,0
		adc 0xff&(.char_decode>>8)
		ld d,a
		ld a,(de)
		ld c,a
		bit .bKEY_MODE_E0,l
		jr nz,.retsymb
		bit .bKEY_MODE_RUS,l
		jr nz,.rus_decode
.retsymb
		ld b,a
		ld (KEY_PUTREDRAW.rep_key),bc
		ex af,af' ;'
		ld a,35
		ld (KEYSCAN.rep_wait),a
		ex af,af' ;'
.retsymb1
		ld b,0
		ld h,b
		res .bKEY_MODE_E0,l
		ld (.mode),hl
		ret
.rus_decode
		ld a,b
		cp 33
		ld a,.KEY_MODE_SHIFT
		jr nc,.rus_noneed_caps
		ld a,.KEY_MODE_SHIFT|.KEY_MODE_CAPS
.rus_noneed_caps
		and l
		ld a,0
		jp pe,.rus_not_sh
		ld a,.mod_sh-.mod_base
.rus_not_sh
		add a,b
		add a,0xff&.char_decode_ru
		ld e,a
		ld a,0
		adc a,0xff&(.char_decode_ru>>8)
		ld d,a
		ld a,(de)
		jr .retsymb
.not_simbol
		ld b,a
		cp 128
		jr c,.is_mode_key
		cp 139
		jr nc,.unmod_no_lock
		bit .bKEY_MODE_E0,l
		jr nz,.unmod_no_lock
		bit .bKEY_MODE_NUML,l
		jr nz,.unmod_no_lock
		add .unmod_sh-.unmod
.unmod_no_lock
		add a,0xff&.unmod_decode
		ld e,a
		ld a,0
		adc a,0xff&(.unmod_decode>>8)
		ld d,a
		ld a,(de)
		ld c,a
		 bit .bKEY_MODE_SHIFT,l
		 jp nz,.zero_ret ;Shift+F1 - это не F1
		jr .retsymb
.is_mode_key
		cp 64
		jr nz,.not_shift_key
		ld a,l
		or .KEY_MODE_SHIFT
		and ~.KEY_MODE_E0
		bit .bKEY_MODE_ALT,a
		jp z,.savemode
.chruslat
		xor .KEY_MODE_RUS
		jp .savemode
.not_shift_key
		cp 66
		jr nz,.not_alt_key
		ld a,l
		or .KEY_MODE_ALT
		and ~.KEY_MODE_E0
		bit .bKEY_MODE_SHIFT,a
		jp z,.savemode
		jr .chruslat
.not_alt_key
		cp 68
		jr nz,.not_ctrl_key
		ld a,l
		or .KEY_MODE_CTRL
		and ~.KEY_MODE_E0
		jp .savemode
.not_ctrl_key		
		ld a,l
		and ~.KEY_MODE_E0
		jp .savemode

.keypressmode
		cp 0xe0
		jp z,.noredraw
		ld h,~(.KEY_MODE_UP|.KEY_MODE_E0|.KEY_MODE_SHIFT)
		cp 0x12
		jr z,.keypressend
		cp 0x59
		jr z,.keypressend
		ld h,~(.KEY_MODE_UP|.KEY_MODE_E0|.KEY_MODE_ALT)
		cp 0x11
		jr z,.keypressend
		ld h,~(.KEY_MODE_UP|.KEY_MODE_E0|.KEY_MODE_CTRL)
		cp 0x14
		jr z,.keypressend
		ld h,~(.KEY_MODE_UP|.KEY_MODE_E0)
		ld e,.KEY_MODE_CAPS
		cp 0x58
		jr z,.keypressm_xor
		ld e,.KEY_MODE_NUML
		cp 0x77
		jr nz,.keypressend
.keypressm_xor
		ld a,l
		and h
		xor e
		jr .keypressend1
.keypressend
		ld a,h
		and l
.keypressend1
		ld (.mode),a
        jp .noredraw

.scodes
                ;0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xa 0xb 0xc 0xd 0xe 0xf
                ;0, F9,  0, F5, F3, F1, F2,F12,  0,F10, F8, F6, F4,TAB,'`',  0
	defb	0,151,  0,147,145,143,144,  0,  0,152,150,148,146,140, 33,  0	;0x00
                ;0,LAl,LSh,  0,LCt,'q','1',  0,  0,  0,'z','s','a','w','2',  0 
	defb	0, 66, 64,  0, 68, 17, 34,  0,  0,  0, 26, 19,  1, 23, 35,  0 	;0x10
                ;0,'c','x','d','e','4','3',  0,  0,' ','v','f','t','r','5',  0 
	defb	0,  3, 24,  4,  5, 37, 36,  0,  0,142, 22,  6, 20, 18, 38,  0 	;0x20
                ;0,'n','b','h','g','y','6',  0,  0,  0,'m','j','u','7','8',  0 
	defb	0, 14,  2,  8,  7, 25, 39,  0,  0,  0, 13, 10, 21, 40, 41,  0 	;0x30
                ;0,',','k','i','o','0','9',  0,  0,'.','/','l',';','p','-',  0 
	defb	0, 31, 11,  9, 15, 43, 42,  0,  0, 32, 47, 12, 29, 16, 44,  0 	;0x40
                ;0,  0,  ',  0,'[','=',  0,  0,  0,RSh,ENT,']',  0,  \,  0,  0
	defb	0,  0, 30,  0, 27, 45,  0,  0,  0, 64,156, 28,  0, 46,  0,  0 	;0x50
                ;0,  0,  0,  0,  0,  0, BS,  0,  0,'1',  0,'4','7',  0,  0,  0
	defb	0,  0,  0,  0,  0,  0,139,  0,  0,137,  0,128,136,  0,  0,  0 	;0x60
                ;'0','.','2','5','6','8',ESC,  0,F11,'+','3','-','*','9',  0,  0
	defb  134,135,131,138,129,130,141,  0,  0,155,133,154,153,132,  0,  0 	;0x70
                ;0,  0,  0, F7	 								
	defb	0,  0,  0,149
	
.mod_base
		 ;		   11111111112222222   2223 333   333333444444 44
		 ;12345678901234567890123456   7890 123   456789012345 67
.char_decode=$-1
	defb "abcdefghijklmnopqrstuvwxyz","[];\',.`","1234567890-=\\/"
.mod_sh
	defb "ABCDEFGHIJKLMNOPQRSTUVWXYZ","{}:\"<>~","!@#$%^&*()_+|?"
.mod_ru
.char_decode_ru=$-1
	defb "фисвуапршолдьтщзйкыегмцчня","хъжэбюё","1234567890-=\\."
.mod_ru_sh
	defb "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ","ХЪЖЭБЮЁ","!\"№;%:?*()_+/,"
.unmod
.unmod_decode=$-128
	defb key_left,key_right,key_up,key_down	;128
	defb key_pgup,key_pgdown,key_ins,key_del ;132
	defb key_home,key_end,0,key_backspace	;136
	defb key_tab,key_esc,' ',key_F1	;140
	defb key_F2,key_F3,key_F4,key_F5	;144
	defb key_F6,key_F7,key_F8,key_F9	;148
	defb key_F10,'*','-','+',key_enter	;152
.unmod_sh
	defb "4682930.715"
	
.ctrl_decode=$-1
	defb ssA,ssB,ssC,ssD,ssE,ssF,ssG,ssH,ssI,ssJ,ssK,ssL,ssM
	defb ssN,ssO,ssP,ssQ,ssR,ssS,ssT,ssU,ssV,ssW,ssX,ssY,ssZ
        db "{}:\"<>~",ss1,ss2,ss3,ss4,ss5,ss6,ss7,ss8,ss9,ss0,"_+|?"
