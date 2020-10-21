        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

READ_BUF_SZ=8*256
 
        org PROGSTART
cmd_begin
 
        LD DE,FILE_NAME
        OS_OPENHANDLE
        OR A
        JP NZ,ERR_EXIT    ;обработка ошибок
        LD A,B
        LD (handle),A    ;сохраняем дескриптор

		LD B,2
		LD HL,0
		LD IX,0
t0		PUSH BC
		ld B,#A0

t1		PUSH BC
		PUSH HL

		LD A,(handle)
        LD B,A

		LD DE,READ_BUF
		LD HL,READ_BUF_SZ;2048
        OS_READHANDLE
        OR A
        JP NZ,ERR_EXIT    ;обработка ошибок
        LD A,H
        OR L
        JP Z,END_READ    ;данных для чтения нет, либо указатель чтения\записи указывает на конец файла
		POP HL

		PUSH HL
		LD B,0
		LD DE,READ_BUF
		LD A,READ_BUF_SZ/256;8
		OS_WRITESECTORS ;b=drive, de=buffer, ixhl=sector number, a=count
		POP HL
		
		LD BC,8
		ADD HL,BC
		POP BC
		DJNZ t1
		POP BC
		DJNZ t0






END_READ



 
CLOSE_ERR_EXIT
        LD A,(handle)
        LD B,A
        OS_CLOSEHANDLE
        ;OR A
        ;JP NZ,ERR_EXIT    ;обработка ошибок
ERR_EXIT 
        QUIT
		
 
FILE_NAME:
           DEFB "source.trd",0  
 
handle
	   DEFB 0

READ_BUF
        DEFS READ_BUF_SZ
 
cmd_end
 
 
	;display "Size ",/d,cmd_end-cmd_begin," bytes"
 
	savebin "wrtrd.com",cmd_begin,cmd_end-cmd_begin
 
	LABELSLIST "../../us/user.l"
