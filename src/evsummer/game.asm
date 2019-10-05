	org GAMEADDRESS
/*
Node description
	BYTE NODESIZE
	{
	byte CMD : DATA
	..
	}

Commands
	GCMD_PRTEXT - Prints text
	DATA: 2 byte pointer to ASZIIZ text
	
	GCMD_LOADTEXT - Loads text to memory
	DATA: ASCIIZ filename string

	GCMD_JUMP - Jump to symbol <s>
	DATA symbol byte

	GCMD_PICTURE - Load picture
	DATA: ASZIIZ text string to filename

	GCMD_INPUT - User key byte input
	DATA: NULL

	GCMD_CHECKVAR - load byte var for check
	DATA: 
	    word var

	GCMD_VARIANT - Answer variant
	DATA:
	    byte key
	    word nextvar_addr1
	    COMMANDS
nextvar1    byte key
	    word nextvar_addr2
	    COMMANDS
	    ...
	    byte key
	    word return_addr
	    COMMANDS
	

	GCMD_QUIT - QUIT

	GCMD_GOTO
	DATA:
	    word goto_addr

	GCMD_SETVARB
	DATA:
	    word var_addr
	    byte value

	GCMD_SETVARW
	DATA:
	    word var_addr
	    word value


*/

game_obj
; MAINMENU
/*mainnode 
	db GCMD_PRTEXT
	dw txt_mainmenu
mainnode_input
	db GCMD_INPUT
mainnode_var0
	db GCMD_VARIANT,0x30
	dw mainnode_var1
	db GCMD_QUIT
mainnode_var1
	db GCMD_VARIANT,0x31
	dw mainnode_var2
	db GCMD_CHECKVAR
	dw gmode
	db GCMD_GOTO
	dw mainnode_varg0
mainnode_var2
	db GCMD_VARIANT,0x32
	dw mainnode_var3
	db GCMD_CHECKVAR
	dw smode
	db GCMD_GOTO
	dw mainnode_vars0
mainnode_var3
	db GCMD_VARIANT,0x33
	dw mainnode_input
	db GCMD_GOTO
	dw prolog1

mainnode_vars0
	db GCMD_VARIANT,SMODE_AY
	dw mainnode_vars1
	db GCMD_SETVARB
	dw smode
	db SMODE_GS
	db GCMD_SETVARW
	dw text_smode,txt_gs
	db GCMD_GOTO
	dw mainnode

mainnode_vars1
	db GCMD_VARIANT,SMODE_GS
	dw mainnode_input
	db GCMD_SETVARB
	dw smode
	db SMODE_AY
	db GCMD_SETVARW
	dw text_smode,txt_ay
	db GCMD_GOTO
	dw mainnode

mainnode_varg0
	db GCMD_VARIANT,GMODE_TEXT
	dw mainnode_varg1
	db GCMD_SETVARB
	dw gmode
	db GMODE_16C
	db GCMD_SETVARW
	dw text_gmode,txt_16c
	db GCMD_GOTO
	dw mainnode

mainnode_varg1
	db GCMD_VARIANT,GMODE_16C
	dw mainnode_input
	db GCMD_SETVARB
	dw gmode
	db GMODE_TEXT
	db GCMD_SETVARW
	dw text_gmode,txt_text
	db GCMD_GOTO
	dw mainnode*/


; STARTGAME
prolog1
	db GCMD_LOADTEXT,"txt/prolog1",0
	db GCMD_PRTEXT
	dw TEXTADDRESS
prolog1_input1
;	db GCMD_INPUT
	db GCMD_VARIANT,'1'
	dw prolog1_input2
	db GCMD_SETVARB
	dw var_prologue
	db 1
	db GCMD_GOTO
	dw prolog2
prolog1_input2
	db GCMD_VARIANT,'2'
	dw prolog1_input1
	db GCMD_SETVARB
	dw var_prologue
	db 0
prolog2
	db GCMD_LOADTEXT,"txt/prolog2",0
	db GCMD_PRTEXT
	dw TEXTADDRESS
day1
	db GCMD_LOADTEXT,"txt/day1",0
	db GCMD_PRTEXT
	dw TEXTADDRESS
day1_sl0
;	db GCMD_INPUT
	db GCMD_VARIANT,'1'
	dw day1_sl1
	db GCMD_CONTINUE
	db GCMD_GOTO
	dw day1_camp0
day1_sl1
	db GCMD_VARIANT,'2'
	dw day1_sl0
	db GCMD_INCVARB
	dw var_slavya
	db GCMD_JUMP,'$'
	db GCMD_GOTO
	dw day1_camp0

day1_camp0

input1
	db GCMD_INPUT
	db GCMD_VARIANT,key_esc
	dw input1
	db GCMD_QUIT


game_obj_end