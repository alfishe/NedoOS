        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
 
BUF_SIZE=16*256

        org PROGSTART
cmd_begin
 
        LD DE,FILE_NAME
        OS_CREATEHANDLE
        OR A
        JP NZ,ERR_EXIT    ;обработка ошибок
        LD A,B
        LD (handle),A    ;сохраняем дескриптор
 
	LD B, #A0
	LD HL, 0
t0:	
	;push bc
	;LD B, #10
;t1:	
	push bc
	push hl
	LD B,0 ;drive
	LD DE,TRDOS_BUF
	LD IX,0
	LD A,BUF_SIZE/256
	OS_READSECTORS ;b=drive, de=buffer, ixhl=sector number, a=count
        LD A,(handle)
        LD B,A
        LD DE,TRDOS_BUF
        LD HL,BUF_SIZE
        OS_WRITEHANDLE
        OR A
        JP NZ,CLOSE_ERR_EXIT    ;обработка ошибок
	pop hl
	;pop bc
        ;inc hl
	;djnz t1
        ld bc,BUF_SIZE/256
        add hl,bc
	pop bc
	djnz t0
 
CLOSE_ERR_EXIT
        LD A,(handle)
        LD B,A
        OS_CLOSEHANDLE
        ;OR A
        ;JP NZ,ERR_EXIT    ;обработка ошибок
ERR_EXIT 
        QUIT
 
FILE_NAME:
           DEFB "noname.trd",0  
 
handle
	   DEFB 0

TRDOS_BUF:
	ds BUF_SIZE
 
 
cmd_end
 
 
	;display "Size ",/d,cmd_end-cmd_begin," bytes"
 
	savebin "rdtrd.com",cmd_begin,cmd_end-cmd_begin
 
	;LABELSLIST "../../us/user.l"
