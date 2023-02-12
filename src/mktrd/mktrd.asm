        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
;COMMANDLINE	EQU #80

        org PROGSTART
cmd_begin


		ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld (par1addr),hl
		ld de,FILE_NAME
		call getname
		inc hl
		ld (hl),0
		ld a,0
		ld (de),a
;		jr $
 
        ld de,FILE_NAME
        OS_CREATEHANDLE
        or a
        jp nz,ERR_EXIT    ;обработка ошибок
        ld a,b
        ld (handle),a    ;сохраняем дескриптор

;Заполняю пустотой внутренний мир файла
		ld	b,160
t1:		push bc
        ld a,(handle)
        ld b,a
        ld de,Empt
        ld hl,4096
        OS_WRITEHANDLE
        or a
        jp nz,ERR_EXIT    ;обработка ошибок
		pop bc

		djnz t1

;Ищу в нем своё место
		ld a, (handle)
		ld b,a
		ld de,#0000
		ld hl,#0800
		OS_SEEKHANDLE

;и заполняю его смыслом
        ld a,(handle)
        ld b,a
        ld de, SYSTEM_TRACK
        ld hl,BUF_SIZE
        OS_WRITEHANDLE
        or a
        jp nz,ERR_EXIT    ;обработка ошибок
 
CLOSE_ERR_EXIT
        ld a,(handle)
        ld b,a
        OS_CLOSEHANDLE

ERR_EXIT 
        QUIT

skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
		cp 0x20
		ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

getname:
        ld a,(hl)
	cp 0
	ret z
        
        cp ' '
        ret z
		ld (de),a
        inc hl
	inc de
        jr getname
		
handle:
	   DEFB 0

;Ну проще я не придумал :-(
;Придумаю переделаю.
Empt: 
	DEFS 16*256

SYSTEM_TRACK:;системная дорожка

BUFF_ADDR:
		DEFB 0
DCU_SEC:
		DEFS 224
FR_SEC_NEXT:;следующий свободный сектор
		DEFB 0
FR_TRK_NEXT:;следующая свободная дорожка
		DEFB 1
TYPE_DISC:; тип диска
		DEFB #10
N_FILES:; количество файлов на диске		
		DEFB 0
; количество свободных секторов на диске 
;(это максимальное количество, будем из него вычитать)
N_FREE_SEC:
		DEFW #09F0
MAIN_BYTE:
		DEFB #10
ZERO:	
		DEFB 0,0
BLANK9:
		DEFB #20,#20,#20,#20,#20,#20,#20,#20,#20,0; последний ноль нужен!
N_DEL_FILES:
		DEFB 0
;заголовок диска
DISC_TITLE:
		DEFB "RESULT",0,0
ZERO_N:
		DEFS 3
BUF_SIZE EQU $-SYSTEM_TRACK

par1addr:
		DEFB 0
par2addr:
		DEFB 0		
FILE_NAME:
        DEFB "dist.trd"
END:	DEFB 0
	DEFB 0

cmd_end
 



	;display "Size ",/d,cmd_end-cmd_begin," bytes"
 
	savebin "mktrd.com",cmd_begin,cmd_end-cmd_begin
 
	LABELSLIST "../../us/user.l"
