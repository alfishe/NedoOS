
	MODULE OSOPENHANDLE
	PUBLIC OS_CLOSEHANDLE,OS_OPENHANDLE,OS_GETFILINFO
    PUBLIC OS_SEEKHANDLE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_GETFILINFO:
	push bc
	ld l,c
	ld h,b
	ld c,CMD_GETFILINFO	
	jr label1
OS_SEEKHANDLE:
    ld b,d
    pop af
    pop hl
    pop de
    push de
    push hl
    push af
	push bc
	ld c,CMD_SEEKHANDLE	
	jr label1
OS_OPENHANDLE:
	push bc
	ld a,c
    ex af,af'
	ld c,CMD_OPENHANDLE	
	jr label1
OS_CLOSEHANDLE:
	push bc
	ld b,d
	ld c,CMD_CLOSEHANDLE
label1:
	push ix
	push iy	
	call BDOS
	ld (errno),a
	ld h,b
	ld l,a
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD

	MODULE OSDIRCALLS
	PUBLIC OS_MKDIR,OS_CHDRV,OS_MOUNT
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_READDIR:
	push bc
	ld c,CMD_READDIR	
	jr label1
OS_OPENDIR:
	push bc
	ld c,CMD_OPENDIR	
	jr label1
;OS_DELETE:
;	push bc
;	ld c,CMD_DELETE	
;	jr label1
OS_MKDIR:
	push bc
	ld c,CMD_MKDIR	
	jr label1
;OS_CHDIR:
;	push bc
;	ld c,CMD_CHDIR	
;	jr label1
OS_MOUNT:
	push bc
	ld c,CMD_MOUNT
	jr label1
OS_CHDRV:
; e = drive index 0..25, or ASCII letter A..Z / a..z
	ld a,e
	cp 26
	jr c,OS_CHDRV_idx
	and 0xdf
	sub 'A'
	jr nc,OS_CHDRV_idx
	cp 26
	jr nc,OS_CHDRV_idx
OS_CHDRV_idx:
	ld e,a
	push bc
	ld c,CMD_SETDRV
label1:
	push ix
	push iy	
	call BDOS
	ld (errno),a
	ld l,a
	ld h,0
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD
	
	
	MODULE OSWRITEHANDLE
	PUBLIC OS_WRITEHANDLE,OS_READHANDLE,OS_READHANDLE_STATUS
	PUBLIC OS_GETFILESIZE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_GETFILESIZE:
	ld c,CMD_GETFILESIZE
	ld b,d
	jr label1
OS_READHANDLE:
OS_READHANDLEMEM:
	ld c,CMD_READHANDLE	
	jr label1
OS_WRITEHANDLE:
	ld c,CMD_WRITEHANDLE
label1:
	pop af
	pop hl
	push hl
	push af
	push ix
	push iy	
	call BDOS
	ld (errno),a
	ld b,d
	ld c,e
	pop iy
	pop ix
	ret

; Same args as OS_READHANDLE.
; HL = bytes read; on BDOS error/EOF returns 0xFFFF (do not use errno).
; Empty pipe (wait): HL=0, not an error.
OS_READHANDLE_STATUS:
	ld c,CMD_READHANDLE
	pop af
	pop hl
	push hl
	push af
	push ix
	push iy
	call BDOS
	ld (errno),a
	pop iy
	pop ix
	or a
	ret z
	ld hl,0xffff
	ret
	ENDMOD
	
	MODULE OSCREATEHANDLE
	PUBLIC OS_CREATEHANDLE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_CREATEHANDLE:
	push ix
	push iy
	ld a,c
	and 0x80
	ld b,a
	ld a,c
	and 0x7f
    ex af,af'
	ld c,CMD_CREATEHANDLE	
	call BDOS
	ld (errno),a
	ld h,b
	ld l,a
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE FS_GET_ERR_STR
	PUBLIC fs_get_err_str
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
fs_get_err_str:
	push de
	LD	HL,(errno)
	LD	H,0
	ADD	HL,HL
	LD	BC,fs_errs
	ADD	HL,BC
	LD	a,(HL)
	INC	HL
	LD	h,(HL)
    ld l,a
	pop de
	ret
    
	RSEG CONST

fs_errs:
	DEFW	?0010
	DEFW	?0011
	DEFW	?0012
	DEFW	?0013
	DEFW	?0014
	DEFW	?0015
	DEFW	?0016
	DEFW	?0017
	DEFW	?0018
	DEFW	?0019
	DEFW	?0020
	DEFW	?0021
	DEFW	?0022
	DEFW	?0023
	DEFW	?0028
	DEFW	?0028
	DEFW	?0028
	DEFW	?0028
	DEFW	?0028
	DEFW	?0029
?0010:
	DEFB	'Succeeded'
	DEFB	0
?0011:
	DEFB	'A hard error occured in the low level disk I/O layer'
	DEFB	0
?0012:
	DEFB	'Assertion failed'
	DEFB	0
?0013:
	DEFB	'The physical drive cannot work'
	DEFB	0
?0014:
	DEFB	'Could not find the file'
	DEFB	0
?0015:
	DEFB	'Could not find the path'
	DEFB	0
?0016:
	DEFB	'The path name format is invalid'
	DEFB	0
?0017:
	DEFB	'Acces denied due to prohibited access or directory full'
	DEFB	0
?0018:
	DEFB	'Acces denied due to prohibited access'
	DEFB	0
?0019:
	DEFB	'The file/directory object is invalid'
	DEFB	0
?0020:
	DEFB	'The physical drive is write protected'
	DEFB	0
?0021:
	DEFB	'The logical drive number is invalid'
	DEFB	0
?0022:
	DEFB	'The volume has no work area'
	DEFB	0
?0023:
	DEFB	'There is no valid FAT volume on the physical drive'
	DEFB	0
?0028:
	DEFB	'file error'
	DEFB	0
?0029:
	DEFB	'Without MBR'
	DEFB	0
	END
	


	