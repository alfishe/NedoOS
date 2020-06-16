; ff_sj.asm - FatFS driver for NedoOS.
; Compatible compilers: sjasmplus.

	DEVICE ZXSPECTRUM128

;############
;## Header ##
;############

;	EXPORT	tablcall
;	EXPORT	LD_CLUST
;	EXPORT	drv_calls
;	EXPORT	dio_par
;	EXPORT	CurrDir
;	EXPORT	CurrVol
;	EXPORT	FatFs
;	EXPORT	Fsid

;	RSEG	TRST

	ORG	0x4000

__begin:

drv_calls:
	DEFW	0	;init
	DEFW	0	;status
	DEFW	0	;read to userspace
	DEFW	0	;read to buffer
	DEFW	0	;write from userspace
	DEFW	0	;write from buffer
	DEFW	0	;RTC
	DEFW	0	;strcpy_lib2usp
	DEFW	0	;strcpy_usp2lib
	DEFW	0	;memcpy_lib2usp
	DEFW	0	;memcpy_usp2lib
	DEFW	0	;memcpy_buf2usp
	DEFW	0	;memcpy_usp2buf
dio_par:
	DEFB	1	;DRV
	DEFW	0x4000	;*BUF
	DEFW	0	;*sec
	DEFB	32	;NUM
curr_fatfs:
	DEFW	0
curr_dir:
	DEFW	0,0
tablcall:
	DEFW	f_mount
	DEFW	f_open
	DEFW	f_read
	DEFW	f_lseek
	DEFW	f_close
	DEFW	f_opendir
	DEFW	f_readdir
	DEFW	f_stat
	DEFW	f_write
	DEFW	f_getfree
	DEFW	f_truncate
	DEFW	f_sync
	DEFW	f_unlink
	DEFW	f_mkdir
	DEFW	f_chmod
	DEFW	f_utime
	DEFW	f_rename
	DEFW	f_chdrive
	DEFW	f_chdir
	DEFW	f_getcwd
	DEFW	f_getutime
;VolToPart:
;	DEFB	0,0,1,0

FatFs:
	DEFW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Fsid:
	DEFW	0

LD_CLUST:
	LD	HL, 20
	ADD	HL, DE
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	LD	HL, 26
	ADD	HL, DE
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L,A
	RET

;###############
;## C Library ##
;###############

;	EXPORT	clib_CLZ80L_4_06_L00
;	EXPORT	clib_US_RSH_L02
;	EXPORT	clib_L_LSH_L03
;	EXPORT	clib_UL_RSH_L03
;	EXPORT	clib_L_MUL_L03
;	EXPORT	clib_UL_DIV_L03
;	EXPORT	clib_L_DIVMOD_L03
;	EXPORT	clib_L_AND_L03
;	EXPORT	clib_L_INC_L03
;	EXPORT	clib_L_DEC_L03
;	EXPORT	clib_L_NOT_L03
;	EXPORT	clib_L_MULASG_L03
;	EXPORT	clib_L_END_MULDIVASG_L03
;	EXPORT	clib_L_ADDASG_L03
;	EXPORT	clib_L_SUBASG_L03
;	EXPORT	clib_L_ORASG_L03
;	EXPORT	clib_L_INCASG_L03
;	EXPORT	clib_L_END_ASG_L03
;	EXPORT	clib_ENT_PARM_DIRECT_L09
;	EXPORT	clib_ENT_AUTO_DIRECT_L09
;	EXPORT	clib_LEAVE_DIRECT_L09
;	EXPORT	clib_LEAVE_32_L09
;	EXPORT	clib_CALL_IND_L09
;	EXPORT	clib_MEMSET_L11
;	EXPORT	clib_MEMCMP_L11
;	EXPORT	clib_STRCHR_L11

;	RSEG	RCODE

clib_CLZ80L_4_06_L00:

clib_US_RSH_L02:
;
; Input:
;   B - u8 count
;   DE - u16 value
; Output:
;   B = 0
;   DE = value >> count
;
	INC	B
	DEC	B
	RET	Z		; if (!B) return
_Lclib_1:
	SRL	D		; DE <<= 1
	RR	E		; ^
	DJNZ	_Lclib_1
	RET

clib_L_LSH_L03:
;
; Input:
;   A - u8 count
;   BC:HL - u32 value
; Output:
;   A = 0
;   BC:HL = value << count
;
	OR	A
_Lclib_2:
	RET	Z		; if (!A) return
	CP	8
	JR	C, _Lclib_3
	; A >= 8
	LD	B, C		; (u32) BC:HL <<= 8
	LD	C, H		; ^
	LD	H, L		; ^
	LD	L, 0		; ^
	SUB	8
	JR	_Lclib_2
_Lclib_3:
	; A < 8
	ADD	HL, HL		; (u32) BC:HL <<= 1
	RL	C		; ^
	RL	B		; ^
	DEC	A
	JR	NZ, _Lclib_3
	RET

clib_UL_RSH_L03:
;
; Input:
;   A - u8 count
;   BC:HL - u32 value
; Output:
;   A = 0
;   BC:HL = value >> count
;
	OR	A
_Lclib_4:
	RET	Z		; if (!A) return
	CP	8
	JR	C, _Lclib_5
	; A >= 8
	LD	L, H		; (u32) BC:HL >>= 8
	LD	H, C		; ^
	LD	C, B		; ^
	LD	B, 0		; ^
	SUB	8
	JR	_Lclib_4
_Lclib_5:
	; A < 8
	SRL	B		; (u32) BC:HL >>= 1
	RR	C		; ^
	RR	H		; ^
	RR	L		; ^
	DEC	A
	JR	NZ, _Lclib_5
	RET

clib_L_MUL_L03:
	EX	(SP), HL
	PUSH	DE
	PUSH	IX
	LD	IX, 0		; IX = SP
	ADD	IX, SP		; ^
	LD	D, (IX+9)
	LD	(IX+9),	H
	LD	E, (IX+8)
	LD	(IX+8),	L
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	HL, 0
	LD	DE, 0
	LD	B, 32
	LD	C, (IX-3)
_Lclib_6:
	SRL	(IX-1)
	RR	(IX-2)
	RR	(IX+7)
	RR	(IX+6)
	JR	NC, _Lclib_7
	LD	A, L		; L += [IX+4]
	ADD	A, (IX+4)	; ^
	LD	L, A		; ^
	LD	A, H		; H += [IX+5] + CF, CF = ?
	ADC	A, (IX+5)	; ^
	LD	H, A		; ^
	LD	A, E		; E += [IX-4] + CF, CF = ?
	ADC	A, (IX-4)	; ^
	LD	E, A		; ^
	LD	A, D		; A=D += C + CF, CF = ?
	ADC	A, C		; ^
	LD	D, A		; ^
_Lclib_7:
	SLA	(IX+4)
	RL	(IX+5)
	RL	(IX-4)
	RL	C
	DJNZ	_Lclib_6
	LD	(IX-3), C
	LD	B, D		; BC = DE
	LD	C, E		; ^
	POP	AF
	POP	DE		; SP += 4
	POP	DE		; ^
	POP	IX
	POP	DE
	INC	SP		; SP += 4
	INC	SP		; ^
	INC	SP		; ^
	INC	SP		; ^
	RET

clib_UL_DIV_L03:
	EX	DE, HL
	EX	(SP), HL
	PUSH	AF
	PUSH	IX
	LD	IX, 0		; IX = SP
	ADD	IX, SP		; ^
	PUSH	BC
	PUSH	DE
	LD	D, (IX+9)
	LD	(IX+9),	H
	LD	E, (IX+8)
	LD	(IX+8),	L
	CALL	clib_L_DIVMOD_L03
	POP	HL
	POP	BC
	CALL	clib_L_NOT_L03
	POP	IX
	POP	AF
	POP	DE
	INC	SP		; SP += 2
	INC	SP		; ^
	RET

clib_L_DIVMOD_L03:
	PUSH	AF
	LD	HL, 0
	LD	BC, 0
	LD	(IX-8), 33
	JR	_Lclib_9
_Lclib_8:
	ADD	HL, DE
	SCF
_Lclib_9:
	RL	(IX-4)
	RL	(IX-3)
	RL	(IX-2)
	RL	(IX-1)
	DEC	(IX-8)
	JR	Z, _Lclib_12
	RL	C
	RL	B
	RL	L
	RL	H
	SBC	HL, DE
	JR	C, _Lclib_8
	JR	NZ, _Lclib_10
	LD	A, B
	SUB	(IX+7)
	JR	C, _Lclib_8
	JR	NZ, _Lclib_10
	LD	A, C
	SUB	(IX+6)
	JR	C, _Lclib_8
	JR	_Lclib_11
_Lclib_10:
	LD	A, C
	SUB	(IX+6)
_Lclib_11:
	LD	C, A
	LD	A, B		; A=B -= [IX+7] + CF, CF = ?
	SBC	A, (IX+7)	; ^
	LD	B, A		; ^
	JR	NC, _Lclib_9
	DEC	HL
	AND	A
	JR	_Lclib_9
_Lclib_12:
	POP	AF
	PUSH	HL		; BC <=> HL
	LD	H, B		; ^
	LD	L, C		; ^
	POP	BC		; ^
	RET

clib_L_AND_L03:
	EX	DE, HL
	EX	(SP), HL
	PUSH	AF
	PUSH	HL
	LD	HL, 6
	ADD	HL, SP
	LD	A, (HL)
	AND	E
	LD	(HL), A
	INC	HL
	LD	A, (HL)
	AND	D
	LD	(HL), A
	POP	DE
	INC	HL
	LD	A, (HL)
	LD	(HL), E
	AND	C
	LD	C, A
	INC	HL
	LD	A, (HL)
	LD	(HL), D
	AND	B
	LD	B, A
	POP	AF
	POP	DE
	POP	HL
	RET

clib_L_INC_L03:
;
; Input:
;   BC:HL - u32 value
; Output:
;   BC:HL = value + 1
;
	INC	L
	RET	NZ
	INC	H
	RET	NZ
	INC	C
	RET	NZ
	INC	B
	RET

clib_L_DEC_L03:
;
; Input:
;   BC:HL - u32 value
; Output:
;   AF saved
;   BC:HL = value - 1
;
	PUSH	AF
	LD	A, L
	OR	H
	DEC	HL
	JR	NZ, _Lclib_13
	DEC	BC
_Lclib_13:
	POP	AF
	RET

clib_L_NOT_L03:
;
; Input:
;   BC:HL - u32 value
; Output:
;   AF saved
;   BC:HL = ~value
;
	PUSH	AF
	LD	A, L		; L ~= L
	CPL			; ^
	LD	L, A		; ^
	LD	A, H		; H ~= H
	CPL			; ^
	LD	H, A		; ^
	LD	A, C		; C ~= C
	CPL			; ^
	LD	C, A		; ^
	LD	A, B		; B ~= B
	CPL			; ^
	LD	B, A		; ^
	POP	AF
	RET

clib_L_MULASG_L03:
	PUSH	BC
	PUSH	DE
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	EX	DE, HL
	CALL	clib_L_MUL_L03
	JP	clib_L_END_MULDIVASG_L03

clib_L_END_MULDIVASG_L03:
	EX	DE, HL
	LD	(HL), B
	DEC	HL
	LD	(HL), C
	DEC	HL
	LD	(HL), D
	DEC	HL
	LD	(HL), E
	RET

clib_L_ADDASG_L03:
	PUSH	AF
	LD	A, (HL)
	ADD	A, E
	LD	(HL), A
	LD	E, A
	INC	HL
	LD	A, (HL)
	ADC	A, D
	LD	(HL), A
	LD	D, A
	INC	HL
	LD	A, (HL)
	ADC	A, C
	LD	(HL), A
	LD	C, A
	INC	HL
	LD	A, (HL)
	ADC	A, B
	LD	(HL), A
	LD	B, A
	DEC	HL		; HL -= 3
	DEC	HL		; ^
	DEC	HL		; ^
	POP	AF
	RET

clib_L_SUBASG_L03:
	PUSH	AF
	LD	A, (HL)
	SUB	E
	LD	(HL), A
	LD	E, A
	INC	HL
	LD	A, (HL)
	SBC	A, D
	LD	(HL), A
	LD	D, A
	INC	HL
	LD	A, (HL)
	SBC	A, C
	LD	(HL), A
	LD	C, A
	INC	HL
	LD	A, (HL)
	SBC	A, B
	LD	(HL), A
	LD	B, A
	DEC	HL		; HL -= 3
	DEC	HL		; ^
	DEC	HL		; ^
	POP	AF
	RET

clib_L_ORASG_L03:
	PUSH	AF
	LD	A, (HL)
	OR	E
	LD	(HL), A
	LD	E, A
	INC	HL
	LD	A, (HL)
	OR	D
	LD	(HL), A
	LD	D, A
	INC	HL
	LD	A, (HL)
	OR	C
	LD	(HL), A
	LD	C, A
	INC	HL
	LD	A, (HL)
	OR	B
	LD	(HL), A
	LD	B, A
	DEC	HL		; HL -= 3
	DEC	HL		; ^
	DEC	HL		; ^
	POP	AF
	RET

clib_L_INCASG_L03:
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	EX	DE, HL
	CALL	clib_L_INC_L03
	JP	clib_L_END_ASG_L03

clib_L_END_ASG_L03:
	EX	DE, HL
	LD	(HL), B
	DEC	HL
	LD	(HL), C
	DEC	HL
	LD	(HL), D
	DEC	HL
	LD	(HL), E
	RET

clib_ENT_PARM_DIRECT_L09:
	POP	HL
	PUSH	BC		; save BC, DE, IX
	PUSH	DE		; ^
	PUSH	IX		; ^
	LD	IX, 0		; IX = SP
	ADD	IX, SP		; ^
	JP	(HL)

clib_ENT_AUTO_DIRECT_L09:
	POP	HL
	PUSH	BC		; push BC, DE, IX
	PUSH	DE		; ^
	PUSH	IX		; ^
	LD	IX, 0		; IX = SP
	ADD	IX, SP		;
	LD	E, (HL)		; DE = (u16) [HL], HL += 2
	INC	HL		; ^
	LD	D, (HL)		; ^
	INC	HL		; ^
	EX	DE, HL
	ADD	HL, SP
	LD	SP, HL
	EX	DE, HL
	JP	(HL)

clib_LEAVE_DIRECT_L09:
	LD	SP, IX		; SP = IX
	POP	IX		; pop IX, DE, BC
	POP	DE		; ^
	POP	BC		; ^
	RET

clib_LEAVE_32_L09:
	LD	SP, IX		; SP = IX
	POP	IX		; pop IX, DE
	POP	DE		; ^
	INC	SP		; SP += 2
	INC	SP		; ^
	RET

clib_CALL_IND_L09:
;
; Input:
;   HL = call address
;
	JP	(HL)

clib_MEMSET_L11:
	PUSH	AF
	PUSH	HL
	PUSH	DE
	LD	A, B
	OR	C
	JR	Z, _Lclib_14
	LD	A, L
	LD	(DE), A
	DEC	BC
	LD	A, B
	OR	C
	JR	Z, _Lclib_14
	LD	L, E
	LD	H, D
	INC	DE
	LDIR
_Lclib_14:
	POP	DE
	POP	HL
	POP	AF
	RET

clib_MEMCMP_L11:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	A, C
	OR	B
	JR	Z, _Lclib_16
_Lclib_15:
	LD	A, (DE)
	CPI
	JR	NZ, _Lclib_17
	INC	DE
	JP	PE, _Lclib_15
_Lclib_16:
	LD	HL, 0
	JR	_Lclib_18
_Lclib_17:
	DEC	HL
	SUB	(HL)
	LD	L, A
	SBC	A, A
	LD	H, A
_Lclib_18:
	POP	DE
	POP	BC
	POP	AF
	RET

clib_STRCHR_L11:
;
; Input:
;   HL - u8 *s
;   E - u8 c
; Output:
;   Success: HL = end_ptr
;   Fail: HL = 0
;
	LD	A, (HL)
	CP	E
	RET	Z
	OR	A
	INC	HL
	JR	NZ, clib_STRCHR_L11
	LD	HL, 0
	RET

;############
;## Driver ##
;############

;	EXPORT	clust2sect
	EXPORT	f_chdir
	EXPORT	f_chdrive
	EXPORT	f_chmod
	EXPORT	f_close
	EXPORT	f_getcwd
	EXPORT	f_getfree
	EXPORT	f_getutime
	EXPORT	f_lseek
	EXPORT	f_mkdir
	EXPORT	f_mount
;	EXPORT	fno_rddir
	EXPORT	f_open
	EXPORT	f_opendir
	EXPORT	f_read
	EXPORT	f_readdir
	EXPORT	f_rename
	EXPORT	f_stat
	EXPORT	f_sync
	EXPORT	f_truncate
	EXPORT	f_unlink
	EXPORT	f_utime
	EXPORT	f_write
;	EXPORT	get_fat
;	EXPORT	nullstring
;	EXPORT	pathbuf
;	EXPORT	put_fat

;	RSEG	CODE
; 1.	/*----------------------------------------------------------------------------/
; 2.	/  FatFs - FAT file system module  R0.08b                 (C)ChaN, 2011
; 3.	/-----------------------------------------------------------------------------/
; 4.	/ FatFs module is a generic FAT file system module for small embedded systems.
; 5.	/ This is a free software that opened for education, research and commercial
; 6.	/ developments under license policy of following terms.
; 7.	/
; 8.	/  Copyright (C) 2011, ChaN, all right reserved.
; 9.	/
; 10.	/ * The FatFs module is a free software and there is NO WARRANTY.
; 11.	/ * No restriction on use. You can use, modify and redistribute it for
; 12.	/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
; 13.	/ * Redistributions of source code must retain the above copyright notice.
; 14.	/
; 15.	/-----------------------------------------------------------------------------/
; 16.	/ Feb 26,'06 R0.00  Prototype.
; 17.	/
; 18.	/ Apr 29,'06 R0.01  First stable version.
; 19.	/
; 20.	/ Jun 01,'06 R0.02  Added FAT12 support.
; 21.	/                   Removed unbuffered mode.
; 22.	/                   Fixed a problem on small (<32M) partition.
; 23.	/ Jun 10,'06 R0.02a Added a configuration option (_FS_MINIMUM).
; 24.	/
; 25.	/ Sep 22,'06 R0.03  Added f_rename().
; 26.	/                   Changed option _FS_MINIMUM to _FS_MINIMIZE.
; 27.	/ Dec 11,'06 R0.03a Improved cluster scan algorithm to write files fast.
; 28.	/                   Fixed f_mkdir() creates incorrect directory on FAT32.
; 29.	/
; 30.	/ Feb 04,'07 R0.04  Supported multiple drive system.
; 31.	/                   Changed some interfaces for multiple drive system.
; 32.	/                   Changed f_mountdrv() to f_mount().
; 33.	/                   Added f_mkfs().
; 34.	/ Apr 01,'07 R0.04a Supported multiple partitions on a physical drive.
; 35.	/                   Added a capability of extending file size to f_lseek().
; 36.	/                   Added minimization level 3.
; 37.	/                   Fixed an endian sensitive code in f_mkfs().
; 38.	/ May 05,'07 R0.04b Added a configuration option _USE_NTFLAG.
; 39.	/                   Added FSInfo support.
; 40.	/                   Fixed DBCS name can result FR_INVALID_NAME.
; 41.	/                   Fixed short seek (<= csize) collapses the file object.
; 42.	/
; 43.	/ Aug 25,'07 R0.05  Changed arguments of f_read(), f_write() and f_mkfs().
; 44.	/                   Fixed f_mkfs() on FAT32 creates incorrect FSInfo.
; 45.	/                   Fixed f_mkdir() on FAT32 creates incorrect directory.
; 46.	/ Feb 03,'08 R0.05a Added f_truncate() and f_utime().
; 47.	/                   Fixed off by one error at FAT sub-type determination.
; 48.	/                   Fixed btr in f_read() can be mistruncated.
; 49.	/                   Fixed cached sector is not flushed when create and close without write.
; 50.	/
; 51.	/ Apr 01,'08 R0.06  Added fputc(), fputs(), fprintf() and fgets().
; 52.	/                   Improved performance of f_lseek() on moving to the same or following cluster.
; 53.	/
; 54.	/ Apr 01,'09 R0.07  Merged Tiny-FatFs as a configuration option. (_FS_TINY)
; 55.	/                   Added long file name feature.
; 56.	/                   Added multiple code page feature.
; 57.	/                   Added re-entrancy for multitask operation.
; 58.	/                   Added auto cluster size selection to f_mkfs().
; 59.	/                   Added rewind option to f_readdir().
; 60.	/                   Changed result code of critical errors.
; 61.	/                   Renamed string functions to avoid name collision.
; 62.	/ Apr 14,'09 R0.07a Separated out OS dependent code on reentrant cfg.
; 63.	/                   Added multiple sector size feature.
; 64.	/ Jun 21,'09 R0.07c Fixed f_unlink() can return FR_OK on error.
; 65.	/                   Fixed wrong cache control in f_lseek().
; 66.	/                   Added relative path feature.
; 67.	/                   Added f_chdir() and f_chdrive().
; 68.	/                   Added proper case conversion to extended char.
; 69.	/ Nov 03,'09 R0.07e Separated out configuration options from ff.h to ffconf.h.
; 70.	/                   Fixed f_unlink() fails to remove a sub-dir on _FS_RPATH.
; 71.	/                   Fixed name matching error on the 13 char boundary.
; 72.	/                   Added a configuration option, _LFN_UNICODE.
; 73.	/                   Changed f_readdir() to return the SFN with always upper case on non-LFN cfg.
; 74.	/
; 75.	/ May 15,'10 R0.08  Added a memory configuration option. (_USE_LFN = 3)
; 76.	/                   Added file lock feature. (_FS_SHARE)
; 77.	/                   Added fast seek feature. (_USE_FASTSEEK)
; 78.	/                   Changed some types on the API, XCHAR->TCHAR.
; 79.	/                   Changed fname member in the FILINFO structure on Unicode cfg.
; 80.	/                   String functions support UTF-8 encoding files on Unicode cfg.
; 81.	/ Aug 16,'10 R0.08a Added f_getcwd(). (_FS_RPATH = 2)
; 82.	/                   Added sector erase feature. (_USE_ERASE)
; 83.	/                   Moved file lock semaphore table from fs object to the bss.
; 84.	/                   Fixed a wrong directory entry is created on non-LFN cfg when the given name contains ';'.
; 85.	/                   Fixed f_mkfs() creates wrong FAT32 volume.
; 86.	/ Jan 15,'11 R0.08b Fast seek feature is also applied to f_read() and f_write().
; 87.	/                   f_lseek() reports required table size on creating CLMP.
; 88.	/                   Extended format syntax of f_printf function.
; 89.	/                   Ignores duplicated directory separators in given path names.
; 90.	/---------------------------------------------------------------------------*/
; 91.	
; 92.	#include "ff.h"         /* FatFs configurations and declarations */
; 93.	#include "diskio.h"     /* Declarations of low level disk I/O functions */
; 94.	#include <string.h>
; 95.	
; 96.	/*--------------------------------------------------------------------------
; 97.	
; 98.	   Module Private Definitions
; 99.	
; 100.	---------------------------------------------------------------------------*/
; 101.	
; 102.	#if _FATFS != 8237
; 104.	#endif
; 105.	
; 106.	
; 107.	/* Definitions on sector size */
; 108.	#if _MAX_SS != 512 && _MAX_SS != 1024 && _MAX_SS != 2048 && _MAX_SS != 4096
; 110.	#endif
; 111.	#if _MAX_SS != 512
; 113.	#else
; 114.	#define SS(fs)  512U            /* Fixed sector size */
; 115.	#endif
; 116.	
; 117.	
; 118.	/* Reentrancy related */
; 119.	#if _FS_REENTRANT
; 120.	#if _USE_LFN == 1
; 122.	#endif
; 125.	#else
; 126.	#define ENTER_FF(fs)
; 127.	#define LEAVE_FF(fs, res)   return res
; 128.	#endif
; 129.	
; 130.	#define ABORT(fs, res)      { fp->flag |= FA__ERROR; LEAVE_FF(fs, res); }
; 131.	
; 132.	
; 133.	/* File shareing feature */
; 134.	#if _FS_SHARE
; 135.	#if _FS_READONLY
; 137.	#endif
; 144.	#endif
; 145.	
; 146.	
; 147.	/* Misc definitions */
; 148.	//#define LD_CLUST(dir) (((DWORD)LD_WORD(dir+DIR_FstClusHI)<<16) | LD_WORD(dir+DIR_FstClusLO))
; 149.	#define ST_CLUST(dir,cl) {ST_WORD(dir+DIR_FstClusLO, cl); ST_WORD(dir+DIR_FstClusHI, (DWORD)cl>>16);}
; 150.	
; 151.	
; 152.	/* DBCS code ranges and SBCS extend char conversion table */
; 153.	
; 154.	#if _CODE_PAGE == 932   /* Japanese Shift-JIS */
; 164.	#elif _CODE_PAGE == 936 /* Simplified Chinese GBK */
; 172.	#elif _CODE_PAGE == 949 /* Korean */
; 182.	#elif _CODE_PAGE == 950 /* Traditional Chinese Big5 */
; 190.	#elif _CODE_PAGE == 437 /* U.S. (OEM) */
; 197.	#elif _CODE_PAGE == 720 /* Arabic (OEM) */
; 204.	#elif _CODE_PAGE == 737 /* Greek (OEM) */
; 211.	#elif _CODE_PAGE == 775 /* Baltic (OEM) */
; 218.	#elif _CODE_PAGE == 850 /* Multilingual Latin 1 (OEM) */
; 225.	#elif _CODE_PAGE == 852 /* Latin 2 (OEM) */
; 232.	#elif _CODE_PAGE == 855 /* Cyrillic (OEM) */
; 239.	#elif _CODE_PAGE == 857 /* Turkish (OEM) */
; 246.	#elif _CODE_PAGE == 858 /* Multilingual Latin 1 + Euro (OEM) */
; 253.	#elif _CODE_PAGE == 862 /* Hebrew (OEM) */
; 260.	#elif _CODE_PAGE == 866 /* Russian (OEM) */
; 261.	#define _DF1S   0
; 262.	#define _EXCVT {0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F, \
; 263.	                0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF, \
; 264.	                0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF, \
; 265.	                0x90,0x91,0x92,0x93,0x9d,0x95,0x96,0x97,0x98,0x99,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F,0xF0,0xF0,0xF2,0xF2,0xF4,0xF4,0xF6,0xF6,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF}
; 266.	
; 267.	#elif _CODE_PAGE == 874 /* Thai (OEM, Windows) */
; 274.	#elif _CODE_PAGE == 1250 /* Central Europe (Windows) */
; 281.	#elif _CODE_PAGE == 1251 /* Cyrillic (Windows) */
; 288.	#elif _CODE_PAGE == 1252 /* Latin 1 (Windows) */
; 295.	#elif _CODE_PAGE == 1253 /* Greek (Windows) */
; 302.	#elif _CODE_PAGE == 1254 /* Turkish (Windows) */
; 309.	#elif _CODE_PAGE == 1255 /* Hebrew (Windows) */
; 316.	#elif _CODE_PAGE == 1256 /* Arabic (Windows) */
; 323.	#elif _CODE_PAGE == 1257 /* Baltic (Windows) */
; 330.	#elif _CODE_PAGE == 1258 /* Vietnam (OEM, Windows) */
; 337.	#elif _CODE_PAGE == 1   /* ASCII (for only non-LFN cfg) */
; 338.	#if _USE_LFN
; 340.	#endif
; 343.	#else
; 346.	#endif
; 347.	
; 348.	
; 349.	/* Character code support macros */
; 350.	#define IsUpper(c)  (((c)>='A')&&((c)<='Z'))
; 351.	#define IsLower(c)  (((c)>='a')&&((c)<='z'))
; 352.	#define IsDigit(c)  (((c)>='0')&&((c)<='9'))
; 353.	
; 354.	#if _DF1S       /* Code page is DBCS */
; 356.	#ifdef _DF2S    /* Two 1st byte areas */
; 358.	#else           /* One 1st byte area */
; 360.	#endif
; 362.	#ifdef _DS3S    /* Three 2nd byte areas */
; 364.	#else           /* Two 2nd byte areas */
; 366.	#endif
; 368.	#else           /* Code page is SBCS */
; 369.	
; 370.	#define IsDBCS1(c)  0
; 371.	#define IsDBCS2(c)  0
; 372.	
; 373.	#endif /* _DF1S */
; 374.	
; 375.	
; 376.	/* Name status flags */
; 377.	#define NS          11      /* Index of name status byte in fn[] */
; 378.	#define NS_LOSS     0x01    /* Out of 8.3 format */
; 379.	#define NS_LFN      0x02    /* Force to create LFN entry */
; 380.	#define NS_LAST     0x04    /* Last segment */
; 381.	#define NS_BODY     0x08    /* Lower case flag (body) */
; 382.	#define NS_EXT      0x10    /* Lower case flag (ext) */
; 383.	#define NS_DOT      0x20    /* Dot entry */
; 384.	
; 385.	
; 386.	/* FAT sub-type boundaries */
; 387.	/* Note that the FAT spec by Microsoft says 4085 but Windows works with 4087! */
; 388.	#define MIN_FAT16   4086    /* Minimum number of clusters for FAT16 */
; 389.	#define MIN_FAT32   65526   /* Minimum number of clusters for FAT32 */
; 390.	
; 391.	
; 392.	/* FatFs refers the members in the FAT structures as byte array instead of
; 393.	/ structure member because the structure is not binary compatible between
; 394.	/ different platforms */
; 395.	
; 396.	#define BS_jmpBoot          0   /* Jump instruction (3) */
; 397.	#define BS_OEMName          3   /* OEM name (8) */
; 398.	#define BPB_BytsPerSec      11  /* Sector size [byte] (2) */
; 399.	#define BPB_SecPerClus      13  /* Cluster size [sector] (1) */
; 400.	#define BPB_RsvdSecCnt      14  /* Size of reserved area [sector] (2) */
; 401.	#define BPB_NumFATs         16  /* Number of FAT copies (1) */
; 402.	#define BPB_RootEntCnt      17  /* Number of root dir entries for FAT12/16 (2) */
; 403.	#define BPB_TotSec16        19  /* Volume size [sector] (2) */
; 404.	#define BPB_Media           21  /* Media descriptor (1) */
; 405.	#define BPB_FATSz16         22  /* FAT size [sector] (2) */
; 406.	#define BPB_SecPerTrk       24  /* Track size [sector] (2) */
; 407.	#define BPB_NumHeads        26  /* Number of heads (2) */
; 408.	#define BPB_HiddSec         28  /* Number of special hidden sectors (4) */
; 409.	#define BPB_TotSec32        32  /* Volume size [sector] (4) */
; 410.	#define BS_DrvNum           36  /* Physical drive number (2) */
; 411.	#define BS_BootSig          38  /* Extended boot signature (1) */
; 412.	#define BS_VolID            39  /* Volume serial number (4) */
; 413.	#define BS_VolLab           43  /* Volume label (8) */
; 414.	#define BS_FilSysType       54  /* File system type (1) */
; 415.	#define BPB_FATSz32         36  /* FAT size [sector] (4) */
; 416.	#define BPB_ExtFlags        40  /* Extended flags (2) */
; 417.	#define BPB_FSVer           42  /* File system version (2) */
; 418.	#define BPB_RootClus        44  /* Root dir first cluster (4) */
; 419.	#define BPB_FSInfo          48  /* Offset of FSInfo sector (2) */
; 420.	#define BPB_BkBootSec       50  /* Offset of backup boot sectot (2) */
; 421.	#define BS_DrvNum32         64  /* Physical drive number (2) */
; 422.	#define BS_BootSig32        66  /* Extended boot signature (1) */
; 423.	#define BS_VolID32          67  /* Volume serial number (4) */
; 424.	#define BS_VolLab32         71  /* Volume label (8) */
; 425.	#define BS_FilSysType32     82  /* File system type (1) */
; 426.	#define FSI_LeadSig         0   /* FSI: Leading signature (4) */
; 427.	#define FSI_StrucSig        484 /* FSI: Structure signature (4) */
; 428.	#define FSI_Free_Count      488 /* FSI: Number of free clusters (4) */
; 429.	#define FSI_Nxt_Free        492 /* FSI: Last allocated cluster (4) */
; 430.	#define MBR_Table           446 /* MBR: Partition table offset (2) */
; 431.	#define SZ_PTE              16  /* MBR: Size of a partition table entry */
; 432.	#define BS_55AA             510 /* Boot sector signature (2) */
; 433.	
; 434.	#define DIR_Name            0   /* Short file name (11) */
; 435.	#define DIR_Attr            11  /* Attribute (1) */
; 436.	#define DIR_NTres           12  /* NT flag (1) */
; 437.	#define DIR_CrtTime         14  /* Created time (2) */
; 438.	#define DIR_CrtDate         16  /* Created date (2) */
; 439.	#define DIR_FstClusHI       20  /* Higher 16-bit of first cluster (2) */
; 440.	#define DIR_WrtTime         22  /* Modified time (2) */
; 441.	#define DIR_WrtDate         24  /* Modified date (2) */
; 442.	#define DIR_FstClusLO       26  /* Lower 16-bit of first cluster (2) */
; 443.	#define DIR_FileSize        28  /* File size (4) */
; 444.	#define LDIR_Ord            0   /* LFN entry order and LLE flag (1) */
; 445.	#define LDIR_Attr           11  /* LFN attribute (1) */
; 446.	#define LDIR_Type           12  /* LFN type (1) */
; 447.	#define LDIR_Chksum         13  /* Sum of corresponding SFN entry */
; 448.	#define LDIR_FstClusLO      26  /* Filled by zero (0) */
; 449.	#define SZ_DIR              32      /* Size of a directory entry */
; 450.	#define LLE                 0x40    /* Last long entry flag in LDIR_Ord */
; 451.	#define DDE                 0xE5    /* Deleted directory enrty mark in DIR_Name[0] */
; 452.	#define NDDE                0x05    /* Replacement of a character collides with DDE */
; 453.	
; 454.	
; 455.	/*------------------------------------------------------------*/
; 456.	/* Work area                                                  */
; 457.	
; 458.	#if _VOLUMES
; 459.	//extern
; 460.	//FATFS *FatFs[_VOLUMES];   /* Pointer to the file system objects (logical drives) */
; 461.	#else
; 463.	#endif
; 464.	
; 465.	extern WORD Fsid;               /* File system mount ID */
; 466.	
; 467.	#if _FS_RPATH
; 468.	//extern BYTE CurrVol;          /* Current drive */
; 469.	//extern DWORD CurrDir;         /* Current dir start claster */
; 470.	#endif
; 471.	
; 472.	#if _FS_SHARE
; 475.	#endif
; 476.	
; 477.	#if _USE_LFN == 0           /* No LFN */
; 478.	static BYTE sfn[12];
; 479.	#define DEF_NAMEBUF 
; 480.	#define INIT_BUF(dobj)      (dobj).fn = sfn
; 481.	#define FREE_BUF()
; 482.	
; 483.	#elif _USE_LFN == 1         /* LFN with static LFN working buffer */
; 489.	#elif _USE_LFN == 2         /* LFN with dynamic LFN working buffer on the stack */
; 494.	#elif _USE_LFN == 3         /* LFN with dynamic LFN working buffer on the heap */
; 501.	#else
; 503.	#endif
; 504.	
; 505.	no_init unsigned char pathbuf[256];
; 506.	
; 507.	/*--------------------------------------------------------------------------
; 508.	
; 509.	   Module Private Functions
; 510.	
; 511.	---------------------------------------------------------------------------*/
; 512.	
; 513.	extern DWORD LD_CLUST(BYTE *);
; 514.	
; 515.	
; 516.	/*-----------------------------------------------------------------------*/
; 517.	/* String functions                                                      */
; 518.	/*-----------------------------------------------------------------------*/
; 519.	
; 520.	
; 521.	/*-----------------------------------------------------------------------*/
; 522.	/* Request/Release grant to access the volume                            */
; 523.	/*-----------------------------------------------------------------------*/
; 524.	#if _FS_REENTRANT
; 548.	#endif
; 549.	
; 550.	
; 551.	
; 552.	/*-----------------------------------------------------------------------*/
; 553.	/* File shareing control functions                                       */
; 554.	/*-----------------------------------------------------------------------*/
; 555.	#if _FS_SHARE
; 661.	#endif
; 662.	
; 663.	
; 664.	
; 665.	/*-----------------------------------------------------------------------*/
; 666.	/* Change window offset                                                  */
; 667.	/*-----------------------------------------------------------------------*/
; 668.	
; 669.	static
; 670.	FRESULT move_window (
; 671.	    FATFS *fs,      /* File system object */
; 672.	    DWORD sector    /* Sector number to make appearance in the fs->win[] */
; 673.	)                   /* Move to zero only writes back dirty window */
move_window:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65530
	PUSH	IY
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 674.	{
; 675.	    DWORD wsect;
; 676.	
; 677.	
	LD	C,(IY+49)
	LD	B,(IY+50)
	LD	L,(IY+47)
	LD	H,(IY+48)
	LD	(IX-6),L
	LD	(IX-5),H
	LD	(IX-4),C
	LD	(IX-3),B
; 678.	    wsect = fs->winsect;
	LD	E,C
	LD	D,B
	LD	C,(IX+8)
	LD	B,(IX+9)
	AND	A
	SBC	HL,BC
	JR	NZ,_L1004
	EX	DE,HL
	LD	C,(IX+10)
	LD	B,(IX+11)
	SBC	HL,BC
	JP	Z,_L0017
_L1004:
_L0004:
; 679.	    if (wsect != sector) {  /* Changed current window */
; 680.	#if !_FS_READONLY
	LD	A,(IY+5)
	OR	A
	JP	Z,_L0012
_L0006:
; 681.	        if (fs->wflag) {    /* Write back dirty window if needed */
	LD	A,(IY+1)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,2
	ADD	HL,SP
; 682.	            SET_DIO_PAR(fs->drv, fs->win, wsect,1);
	CALL	_L1158
	JP	NZ,_L1005
_L0008:
; 683.	            if (drv_calls.write_from_buf() != RES_OK)
; 684.	                return FR_DISK_ERR;
_L0009:
	LD	(IY+5),A
; 685.	            fs->wflag = 0;
	LD	L,(IY+33)
	LD	H,(IY+34)
	PUSH	HL
	LD	L,(IY+31)
	LD	H,(IY+32)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IY+37)
	LD	H,(IY+38)
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	AND	A
	LD	L,(IX-6)
	LD	H,(IX-5)
	POP	BC
	SBC	HL,BC
	LD	L,(IX-4)
	LD	H,(IX-3)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0012
_L0010:
; 686.	            if (wsect < (fs->fatbase + fs->fsize)) {    /* In FAT area */
; 687.	                BYTE nf;
	LD	B,(IY+4)
	LD	(IX-2),B
_L0013:
	LD	A,1
	CP	(IX-2)
	JR	NC,_L0012
_L0014:
; 688.	                for (nf = fs->n_fats; nf > 1; nf--) {   /* Reflect the change to all FAT copies */
	LD	HL,2
	ADD	HL,SP
	LD	C,(IY+33)
	LD	B,(IY+34)
	LD	E,(IY+31)
	LD	D,(IY+32)
	CALL	clib_L_ADDASG_L03
; 689.	                    wsect += fs->fsize;
	LD	A,(IY+1)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,2
	ADD	HL,SP
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 690.	                    SET_DIO_PAR(fs->drv, fs->win, wsect,1);
	LD	HL,(drv_calls+10)
	CALL	clib_CALL_IND_L09
	DEC	(IX-2)
; 691.	                    drv_calls.write_from_buf();
; 692.	                }
	JR	_L0013
_L0012:
_L0011:
_L0007:
; 693.	            }
; 694.	        }
; 695.	#endif
	LD	A,(IX+8)
	OR	(IX+9)
	OR	(IX+10)
	OR	(IX+11)
	JR	Z,_L0017
_L0016:
; 696.	        if (sector) {
	LD	A,(IY+1)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,16
	ADD	HL,SP
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 697.	                SET_DIO_PAR(fs->drv, fs->win, sector,1);
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JR	Z,_L0019
_L0018:
; 698.	            if (drv_calls.read_to_buf() != RES_OK)
_L1005:
	LD	A,1
; 699.	                return FR_DISK_ERR;
	JR	_L0020
_L0019:
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	L,(IX+8)
	LD	(IY+47),L
	LD	H,(IX+9)
	LD	(IY+48),H
	LD	(IY+49),C
	LD	(IY+50),B
_L0017:
_L0005:
; 700.	            fs->winsect = sector;
; 701.	        }
; 702.	    }
; 703.	
	XOR	A
; 704.	    return FR_OK;
_L0020:
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
_L1160:
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,32
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,22
	ADD	HL,BC
_L1158:
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
	LD	HL,(drv_calls+10)
_L1159:
	CALL	clib_CALL_IND_L09
	OR	A
	RET
; 705.	}
; 706.	
; 707.	
; 708.	
; 709.	
; 710.	/*-----------------------------------------------------------------------*/
; 711.	/* Clean-up cached data                                                  */
; 712.	/*-----------------------------------------------------------------------*/
; 713.	#if !_FS_READONLY
; 714.	static
; 715.	FRESULT sync (  /* FR_OK: successful, FR_DISK_ERR: failed */
; 716.	    FATFS *fs   /* File system object */
; 717.	)
sync:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	PUSH	DE
	POP	IX
; 718.	{
; 719.	    FRESULT res;
; 720.	
; 721.	
	LD	HL,0
	PUSH	HL
	PUSH	HL
	CALL	move_window
	POP	HL
	POP	HL
	LD	IYL,A
; 722.	    res = move_window(fs, 0);
	OR	A
	JP	NZ,_L0028
_L0021:
; 723.	    if (res == FR_OK) {
; 724.	        /* Update FSInfo sector if needed */
	LD	A,(IX+0)
	CP	3
	JP	NZ,_L0024
	LD	A,(IX+6)
	OR	A
	JP	Z,_L0024
_L0026:
_L0025:
_L0023:
; 725.	        if (fs->fs_type == FS_FAT32 && fs->fsi_flag) {
	LD	(IX+6),0
; 726.	            fs->fsi_flag = 0;
	XOR	A
	LD	(IX+47),A
	LD	(IX+48),A
	LD	(IX+49),A
	LD	(IX+50),A
; 727.	            fs->winsect = 0;
; 728.	            /* Create FSInfo structure */
	LD	BC,512
	LD	HL,51
	PUSH	IX
	POP	DE
	ADD	HL,DE
	EX	DE,HL
	LD	L,C
	LD	H,C
	CALL	clib_MEMSET_L11
; 729.	            memset(fs->win, 0, 512);
	LD	L,51
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	DE,510
	ADD	HL,DE
	LD	(HL),85
	INC	HL
	LD	(HL),170
; 730.	            ST_WORD(fs->win+BS_55AA, 0xAA55);
	LD	HL,51
	ADD	HL,BC
	LD	(HL),82
	INC	HL
	LD	(HL),82
	INC	HL
	LD	(HL),97
	INC	HL
	LD	(HL),65
; 731.	            ST_DWORD(fs->win+FSI_LeadSig, 0x41615252);
	LD	HL,51
	ADD	HL,BC
	LD	DE,484
	ADD	HL,DE
	LD	(HL),114
	INC	HL
	LD	(HL),114
	INC	HL
	LD	(HL),65
	INC	HL
	LD	(HL),97
; 732.	            ST_DWORD(fs->win+FSI_StrucSig, 0x61417272);
	LD	HL,51
	ADD	HL,BC
	LD	DE,488
	ADD	HL,DE
	PUSH	HL
	LD	HL,15
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 733.	            ST_DWORD(fs->win+FSI_Free_Count, fs->free_clust);
	LD	HL,51
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	DE,492
	ADD	HL,DE
	PUSH	HL
	LD	HL,11
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 734.	            ST_DWORD(fs->win+FSI_Nxt_Free, fs->last_clust);
; 735.	            /* Write it into the FSInfo sector */
	LD	A,(IX+1)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,19
	ADD	HL,BC
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 736.	            SET_DIO_PAR(fs->drv, fs->win, fs->fsi_sector,1);
	LD	HL,(drv_calls+10)
	CALL	clib_CALL_IND_L09
_L0024:
; 737.	            drv_calls.write_from_buf();
; 738.	        }
; 739.	        /* Make sure that no pending write process in the physical drive */
	XOR	A
	JR	Z,_L0028
_L0027:
; 740.	        if (disk_ioctl(fs->drv, CTRL_SYNC, (void*)0) != RES_OK)
	LD	IYL,1
_L0028:
_L0022:
; 741.	            res = FR_DISK_ERR;
; 742.	    }
; 743.	
	LD	A,IYL
; 744.	    return res;
	POP	IX
	POP	IY
	POP	BC
	RET
; 745.	}
; 746.	#endif
; 747.	
; 748.	
; 749.	
; 750.	
; 751.	/*-----------------------------------------------------------------------*/
; 752.	/* Get sector# from cluster#                                             */
; 753.	/*-----------------------------------------------------------------------*/
; 754.	
; 755.	
; 756.	DWORD clust2sect (  /* !=0: Sector number, 0: Failed - invalid cluster# */
; 757.	    FATFS *fs,      /* File system object */
; 758.	    DWORD clst      /* Cluster# to be converted */
; 759.	)
clust2sect:
	PUSH	IX
	PUSH	DE
	POP	IX
; 760.	{
	LD	HL,4
	ADD	HL,SP
	LD	BC,0
	LD	DE,2
	CALL	clib_L_SUBASG_L03
; 761.	    clst -= 2;
	LD	L,(IX+29)
	LD	H,(IX+30)
	PUSH	HL
	LD	L,(IX+27)
	LD	H,(IX+28)
	PUSH	HL
	LD	HL,65534
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,65535
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	LD	HL,8
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	L,C
	LD	H,B
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	JR	C,_L0030
_L0029:
	LD	BC,0
	LD	L,C
	LD	H,B
; 762.	    if (clst >= (fs->n_fatent - 2)) return 0;       /* Invalid cluster# */
	JR	_L0031
_L0030:
	LD	L,(IX+3)
	LD	BC,0
	LD	H,C
	PUSH	BC
	PUSH	HL
	LD	L,8
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	CALL	clib_L_MUL_L03
	PUSH	BC
	PUSH	HL
	LD	L,(IX+43)
	LD	H,(IX+44)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX+45)
	LD	H,(IX+46)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
; 763.	    return clst * fs->csize + fs->database;
_L0031:
	POP	IX
	RET
; 764.	}
; 765.	
; 766.	
; 767.	
; 768.	
; 769.	/*-----------------------------------------------------------------------*/
; 770.	/* FAT access - Read value of a FAT entry                                */
; 771.	/*-----------------------------------------------------------------------*/
; 772.	
; 773.	
; 774.	DWORD get_fat ( /* 0xFFFFFFFF:Disk error, 1:Internal error, Else:Cluster status */
; 775.	    FATFS *fs,  /* File system object */
; 776.	    DWORD clst  /* Cluster# to get the link information */
; 777.	)
get_fat:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 778.	{
; 779.	    UINT wc, bc;
; 780.	    BYTE *p;
; 781.	
; 782.	
	AND	A
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	BC,2
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L0034
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JR	C,_L0033
_L0034:
_L0035:
_L0032:
; 783.	    if (clst < 2 || clst >= fs->n_fatent)   /* Chack range */
	LD	BC,0
	LD	HL,1
; 784.	        return 1;
; 785.	
	JP	_L0051
_L0033:
	LD	A,(IY+0)
	CP	1
	JP	NZ,_L0045
_L0037:
; 786.	    switch (fs->fs_type) {
; 787.	    case FS_FAT12 :
	EXX
	LD	E,(IX+8)
	LD	D,(IX+9)
	PUSH	DE
	EXX
	POP	BC
	SRL	B
	RR	C
	PUSH	BC
	EXX
	POP	HL
	ADD	HL,DE
	EX	DE,HL
	EXX
; 788.	        bc = (UINT)clst; bc += bc / 2;
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	_L1161
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	OR	A
	JP	NZ,_L0036
_L0038:
_L0039:
; 789.	        if (move_window(fs, fs->fatbase + (bc / SS(fs)))) break;
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,51
	ADD	HL,DE
	LD	E,(HL)
	PUSH	DE
	EXX
	POP	BC
	INC	DE
	EXX
; 790.	        wc = fs->win[bc % SS(fs)]; bc++;
	LD	HL,35
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	PUSH	DE
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	_L1161
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	OR	A
	JP	NZ,_L0036
_L0040:
_L0041:
; 791.	        if (move_window(fs, fs->fatbase + (bc / SS(fs)))) break;
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
	LD	B,(HL)
	LD	C,0
	PUSH	BC
	EXX
	POP	HL
	LD	A,L
	OR	C
	LD	C,A
	LD	A,H
	OR	B
	LD	B,A
	EXX
; 792.	        wc |= fs->win[bc % SS(fs)] << 8;
	BIT	0,(IX+8)
	JR	Z,_L0043
	LD	B,4
	EXX
	PUSH	BC
	EXX
	POP	DE
	CALL	clib_US_RSH_L02
	EX	DE,HL
	JR	_L1008
_L0043:
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	A,H
	AND	15
	LD	H,A
_L1008:
	LD	B,C
; 793.	        return (clst & 1) ? (wc >> 4) : (wc & 0xFFF);
; 794.	
	JP	_L0051
_L0045:
	CP	2
	JR	NZ,_L0048
; 795.	    case FS_FAT16 :
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	L,(IX+9)
	LD	H,C
	LD	E,B
	LD	D,0
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	OR	A
	JR	NZ,_L0036
_L0046:
_L0047:
; 796.	        if (move_window(fs, fs->fatbase + (clst / (SS(fs) / 2)))) break;
	LD	L,(IX+8)
	LD	H,(IX+9)
	ADD	HL,HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
; 797.	        p = &fs->win[clst * 2 % SS(fs)];
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	BC,0
; 798.	        return LD_WORD(p);
; 799.	
	JR	_L0051
_L0048:
	CP	3
	JR	NZ,_L0036
; 800.	    case FS_FAT32 :
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	CALL	_L1164
	LD	E,C
	LD	D,B
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	OR	A
	JR	NZ,_L0036
_L0049:
_L0050:
; 801.	        if (move_window(fs, fs->fatbase + (clst / (SS(fs) / 4)))) break;
	LD	L,(IX+8)
	LD	H,(IX+9)
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
; 802.	        p = &fs->win[clst * 4 % SS(fs)];
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	A,(HL)
	EX	DE,HL
	AND	15
	LD	B,A
; 803.	        return LD_DWORD(p) & 0x0FFFFFFF;
	JR	_L0051
_L0036:
; 804.	    }
; 805.	
	LD	BC,65535
	LD	L,C
	LD	H,B
; 806.	    return 0xFFFFFFFF;  /* An error occurred at the disk I/O layer */
_L0051:
	EXX
	POP	DE
	POP	BC
	EXX
	POP	IY
	JP	clib_LEAVE_32_L09
_L1161:
	CALL	clib_US_RSH_L02
	EX	DE,HL
	LD	DE,0
	RET
_L1163:
	PUSH	IY
	POP	DE
	JP	move_window
_L1164:
	LD	A,7
_L1165:
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	L,(IX+8)
	LD	H,(IX+9)
	JP	clib_UL_RSH_L03
; 807.	}
; 808.	
; 809.	
; 810.	
; 811.	
; 812.	/*-----------------------------------------------------------------------*/
; 813.	/* FAT access - Change value of a FAT entry                              */
; 814.	/*-----------------------------------------------------------------------*/
; 815.	#if !_FS_READONLY
; 816.	
; 817.	FRESULT put_fat (
; 818.	    FATFS *fs,  /* File system object */
; 819.	    DWORD clst, /* Cluster# to be changed in range of 2 to fs->n_fatent - 1 */
; 820.	    DWORD val   /* New value to mark the cluster */
; 821.	)
put_fat:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
	EXX
	PUSH	DE
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 822.	{
; 823.	    UINT bc;
; 824.	    BYTE *p;
; 825.	    FRESULT res;
; 826.	
; 827.	
	AND	A
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	BC,2
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L0054
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JR	C,_L0053
_L0054:
_L0055:
_L0052:
; 828.	    if (clst < 2 || clst >= fs->n_fatent) { /* Check range */
	LD	(IX-2),2
; 829.	        res = FR_INT_ERR;
; 830.	
	JP	_L0056
_L0053:
; 831.	    } else {
	LD	A,(IY+0)
	CP	1
	JP	NZ,_L0069
_L0058:
; 832.	        switch (fs->fs_type) {
; 833.	        case FS_FAT12 :
	EXX
	LD	E,(IX+8)
	LD	D,(IX+9)
	PUSH	DE
	EXX
	POP	BC
	SRL	B
	RR	C
	PUSH	BC
	EXX
	POP	HL
	ADD	HL,DE
	EX	DE,HL
	EXX
; 834.	            bc = clst; bc += bc / 2;
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	_L1161
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	LD	(IX-2),A
; 835.	            res = move_window(fs, fs->fatbase + (bc / SS(fs)));
	OR	A
	JP	NZ,_L0057
_L0059:
_L0060:
; 836.	            if (res != FR_OK) break;
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
	EX	DE,HL
; 837.	            p = &fs->win[bc % SS(fs)];
	BIT	0,(IX+8)
	JR	Z,_L0062
	LD	L,E
	LD	H,D
	LD	A,(HL)
	AND	15
	PUSH	AF
	LD	A,(IX+12)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	B,A
	POP	AF
	OR	B
	JR	_L0063
_L0062:
	LD	A,(IX+12)
_L0063:
	EX	DE,HL
	LD	(HL),A
; 838.	            *p = (clst & 1) ? ((*p & 0x0F) | ((BYTE)val << 4)) : (BYTE)val;
	EXX
	INC	DE
	EXX
; 839.	            bc++;
	LD	(IY+5),1
; 840.	            fs->wflag = 1;
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	_L1161
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	LD	(IX-2),A
; 841.	            res = move_window(fs, fs->fatbase + (bc / SS(fs)));
	OR	A
	JP	NZ,_L0057
_L0064:
_L0065:
; 842.	            if (res != FR_OK) break;
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
	EX	DE,HL
; 843.	            p = &fs->win[bc % SS(fs)];
	BIT	0,(IX+8)
	JR	Z,_L0067
	LD	A,4
	LD	C,(IX+14)
	LD	B,(IX+15)
	LD	L,(IX+12)
	LD	H,(IX+13)
	CALL	clib_UL_RSH_L03
	LD	A,L
	JR	_L0068
_L0067:
	LD	L,E
	LD	H,D
	LD	A,(HL)
	AND	240
	PUSH	AF
	LD	A,(IX+13)
	AND	15
	LD	B,A
	POP	AF
	OR	B
_L0068:
	EX	DE,HL
	LD	(HL),A
; 844.	            *p = (clst & 1) ? (BYTE)(val >> 4) : ((*p & 0xF0) | ((BYTE)(val >> 8) & 0x0F));
	JP	_L0057
_L0069:
	CP	2
	JR	NZ,_L0072
; 845.	            break;
; 846.	
; 847.	        case FS_FAT16 :
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	L,(IX+9)
	LD	H,C
	LD	E,B
	LD	D,0
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	LD	(IX-2),A
; 848.	            res = move_window(fs, fs->fatbase + (clst / (SS(fs) / 2)));
	OR	A
	JP	NZ,_L0057
_L0070:
_L0071:
; 849.	            if (res != FR_OK) break;
	LD	L,(IX+8)
	LD	H,(IX+9)
	ADD	HL,HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
	EX	DE,HL
; 850.	            p = &fs->win[clst * 2 % SS(fs)];
	LD	L,(IX+12)
	LD	H,(IX+13)
	PUSH	HL
	EX	DE,HL
	POP	BC
	JR	_L1011
; 851.	            ST_WORD(p, (WORD)val);
_L0072:
	CP	3
	JR	NZ,_L0075
; 852.	            break;
; 853.	
; 854.	        case FS_FAT32 :
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	CALL	_L1164
	LD	E,C
	LD	D,B
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	PUSH	HL
	PUSH	DE
	CALL	_L1163
	POP	HL
	POP	HL
	LD	(IX-2),A
; 855.	            res = move_window(fs, fs->fatbase + (clst / (SS(fs) / 4)));
	OR	A
	JR	NZ,_L0057
_L0073:
_L0074:
; 856.	            if (res != FR_OK) break;
	LD	L,(IX+8)
	LD	H,(IX+9)
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,51
	ADD	HL,BC
	EX	DE,HL
; 857.	            p = &fs->win[clst * 4 % SS(fs)];
	PUSH	DE
	LD	HL,20
	ADD	HL,SP
	PUSH	HL
	EX	DE,HL
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	E,0
	LD	D,0
	LD	C,B
	AND	240
	LD	B,A
	POP	HL
	CALL	clib_L_ORASG_L03
	POP	DE
; 858.	            val |= LD_DWORD(p) & 0xF0000000;
	LD	C,(IX+14)
	LD	B,(IX+15)
	LD	L,(IX+12)
	LD	H,(IX+13)
	PUSH	HL
	EX	DE,HL
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
_L1011:
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 859.	            ST_DWORD(p, val);
	JR	_L0057
_L0075:
; 860.	            break;
; 861.	
; 862.	        default :
	LD	(IX-2),2
_L0057:
; 863.	            res = FR_INT_ERR;
; 864.	        }
	LD	(IY+5),1
_L0056:
; 865.	        fs->wflag = 1;
; 866.	    }
; 867.	
	LD	A,(IX-2)
; 868.	    return res;
_L1149:
	EXX
	POP	DE
	EXX
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 869.	}
; 870.	#endif /* !_FS_READONLY */
; 871.	
; 872.	
; 873.	
; 874.	
; 875.	/*-----------------------------------------------------------------------*/
; 876.	/* FAT handling - Remove a cluster chain                                 */
; 877.	/*-----------------------------------------------------------------------*/
; 878.	#if !_FS_READONLY
; 879.	static
; 880.	FRESULT remove_chain (
; 881.	    FATFS *fs,          /* File system object */
; 882.	    DWORD clst          /* Cluster# to remove a chain from */
; 883.	)
remove_chain:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65530
	PUSH	IY
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 884.	{
; 885.	    FRESULT res;
; 886.	    DWORD nxt;
; 887.	#if _USE_ERASE
; 889.	#endif
; 890.	
	AND	A
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	BC,2
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L1012
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JR	NC,_L1012
_L0078:
_L0079:
_L0076:
; 891.	    if (clst < 2 || clst >= fs->n_fatent) { /* Check range */
; 892.	        res = FR_INT_ERR;
; 893.	
_L0077:
; 894.	    } else {
	LD	(IX-6),0
_L0082:
; 895.	        res = FR_OK;
	AND	A
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JP	NC,_L0081
_L0083:
; 896.	        while (clst < fs->n_fatent) {           /* Not a last link? */
	LD	L,(IX+10)
	LD	H,(IX+11)
	PUSH	HL
	LD	L,(IX+8)
	LD	H,(IX+9)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	get_fat
	POP	AF
	POP	AF
	LD	(IX-4),L
	LD	(IX-3),H
	LD	(IX-2),C
	LD	(IX-1),B
; 897.	            nxt = get_fat(fs, clst);            /* Get cluster status */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JP	Z,_L0081
_L0084:
_L0085:
; 898.	            if (nxt == 0) break;                /* Empty cluster? */
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0087
_L0086:
_L1012:
	LD	(IX-6),2
	JR	_L0081
_L0087:
; 899.	            if (nxt == 1) { res = FR_INT_ERR; break; }  /* Internal error? */
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	NZ,_L0089
_L0088:
	LD	(IX-6),1
	JR	_L0081
_L0089:
; 900.	            if (nxt == 0xFFFFFFFF) { res = FR_DISK_ERR; break; }    /* Disk error? */
	LD	HL,0
	PUSH	HL
	PUSH	HL
	LD	L,(IX+10)
	LD	H,(IX+11)
	PUSH	HL
	LD	L,(IX+8)
	LD	H,(IX+9)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	put_fat
	POP	HL
	POP	HL
	POP	HL
	POP	HL
	LD	(IX-6),A
; 901.	            res = put_fat(fs, clst, 0);         /* Mark the cluster "empty" */
	OR	A
	JR	NZ,_L0081
_L0090:
_L0091:
; 902.	            if (res != FR_OK) break;
	LD	A,(IY+15)
	AND	(IY+16)
	AND	(IY+17)
	AND	(IY+18)
	INC	A
	JR	Z,_L0093
_L0092:
; 903.	            if (fs->free_clust != 0xFFFFFFFF) { /* Update FSInfo */
	LD	L,(IY+15)
	LD	H,(IY+16)
	LD	C,(IY+17)
	LD	B,(IY+18)
	CALL	clib_L_INC_L03
	LD	(IY+15),L
	LD	(IY+16),H
	LD	(IY+17),C
	LD	(IY+18),B
; 904.	                fs->free_clust++;
	LD	(IY+6),1
_L0093:
; 905.	                fs->fsi_flag = 1;
; 906.	            }
; 907.	#if _USE_ERASE
; 916.	#endif
	LD	C,(IX-2)
	LD	B,(IX-1)
	LD	L,(IX-4)
	LD	H,(IX-3)
	LD	(IX+8),L
	LD	(IX+9),H
	LD	(IX+10),C
	LD	(IX+11),B
; 917.	            clst = nxt; /* Next cluster */
; 918.	        }
	JP	_L0082
_L0081:
_L0080:
; 919.	    }
; 920.	
	LD	A,(IX-6)
; 921.	    return res;
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 922.	}
; 923.	#endif
; 924.	
; 925.	
; 926.	
; 927.	
; 928.	/*-----------------------------------------------------------------------*/
; 929.	/* FAT handling - Stretch or Create a cluster chain                      */
; 930.	/*-----------------------------------------------------------------------*/
; 931.	#if !_FS_READONLY
; 932.	static
; 933.	DWORD create_chain (    /* 0:No free cluster, 1:Internal error, 0xFFFFFFFF:Disk error, >=2:New cluster# */
; 934.	    FATFS *fs,          /* File system object */
; 935.	    DWORD clst          /* Cluster# to stretch. 0 means create a new chain. */
; 936.	)
create_chain:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65522
	PUSH	IY
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 937.	{
; 938.	    DWORD cs, ncl, scl;
; 939.	    FRESULT res;
; 940.	
; 941.	
	LD	A,(IX+8)
	OR	(IX+9)
	OR	(IX+10)
	OR	(IX+11)
	JR	NZ,_L0095
_L0094:
; 942.	    if (clst == 0) {        /* Create a new chain */
	LD	C,(IY+13)
	LD	B,(IY+14)
	LD	L,(IY+11)
	LD	(IX-6),L
	LD	H,(IY+12)
	LD	(IX-5),H
	LD	(IX-4),C
	LD	(IX-3),B
; 943.	        scl = fs->last_clust;           /* Get suggested start point */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	Z,_L0098
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX-4)
	LD	H,(IX-3)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JR	C,_L0100
_L0098:
_L0099:
_L0096:
	XOR	A
	LD	(IX-6),1
	LD	(IX-5),A
	LD	(IX-4),A
	LD	(IX-3),A
_L0097:
; 944.	        if (!scl || scl >= fs->n_fatent) scl = 1;
; 945.	    }
	JR	_L0100
_L0095:
; 946.	    else {                  /* Stretch the current chain */
	LD	L,(IX+10)
	LD	H,(IX+11)
	PUSH	HL
	LD	L,(IX+8)
	LD	H,(IX+9)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	get_fat
	POP	AF
	POP	AF
	LD	(IX-10),L
	LD	(IX-9),H
	LD	(IX-8),C
	LD	(IX-7),B
; 947.	        cs = get_fat(fs, clst);         /* Check the cluster status */
	LD	E,C
	LD	D,B
	AND	A
	LD	BC,2
	SBC	HL,BC
	EX	DE,HL
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	NC,_L0102
_L0101:
	LD	HL,1
; 948.	        if (cs < 2) return 1;           /* It is an invalid cluster */
	JP	_L0131
_L0102:
	LD	L,(IX-10)
	LD	H,(IX-9)
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX-8)
	LD	H,(IX-7)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JP	C,_L0115
_L0103:
; 949.	        if (cs < fs->n_fatent) return cs;   /* It is already followed by next cluster */
_L0104:
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	(IX-6),L
	LD	(IX-5),H
	LD	(IX-4),C
	LD	(IX-3),B
_L0100:
; 950.	        scl = clst;
; 951.	    }
; 952.	
	LD	C,(IX-4)
	LD	B,(IX-3)
	LD	L,(IX-6)
	LD	H,(IX-5)
	LD	(IX-14),L
	LD	(IX-13),H
	LD	(IX-12),C
	LD	(IX-11),B
_L0106:
; 953.	    ncl = scl;              /* Start cluster */
; 954.	    for (;;) {
	LD	L,(IX-14)
	LD	H,(IX-13)
	LD	C,(IX-12)
	LD	B,(IX-11)
	CALL	clib_L_INC_L03
	LD	(IX-14),L
	LD	(IX-13),H
	LD	(IX-12),C
	LD	(IX-11),B
; 955.	        ncl++;                          /* Next cluster */
	AND	A
	LD	C,(IY+27)
	LD	B,(IY+28)
	SBC	HL,BC
	LD	L,(IX-12)
	LD	H,(IX-11)
	LD	C,(IY+29)
	LD	B,(IY+30)
	SBC	HL,BC
	JR	C,_L0110
_L0107:
; 956.	        if (ncl >= fs->n_fatent) {      /* Wrap around */
	XOR	A
	LD	(IX-14),2
	LD	(IX-13),A
	LD	(IX-12),A
	LD	(IX-11),A
; 957.	            ncl = 2;
	LD	L,(IX-6)
	LD	H,(IX-5)
	LD	BC,2
	SBC	HL,BC
	LD	L,(IX-4)
	LD	H,(IX-3)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L1014
_L0109:
; 958.	            if (ncl > scl) return 0;    /* No free cluster */
_L0110:
_L0108:
; 959.	        }
	LD	L,(IX-12)
	LD	H,(IX-11)
	PUSH	HL
	LD	L,(IX-14)
	LD	H,(IX-13)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	get_fat
	POP	AF
	POP	AF
	LD	(IX-10),L
	LD	(IX-9),H
	LD	(IX-8),C
	LD	(IX-7),B
; 960.	        cs = get_fat(fs, ncl);          /* Get the cluster status */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	Z,_L0105
_L0111:
_L0112:
; 961.	        if (cs == 0) break;             /* Found a free cluster */
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	Z,_L0115
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0114
_L0115:
_L0116:
_L0113:
; 962.	        if (cs == 0xFFFFFFFF || cs == 1)/* An error occurred */
	LD	C,(IX-8)
	LD	B,(IX-7)
	LD	L,(IX-10)
	LD	H,(IX-9)
; 963.	            return cs;
	JP	_L0131
_L0114:
	LD	L,(IX-14)
	LD	H,(IX-13)
	LD	C,(IX-6)
	LD	B,(IX-5)
	SBC	HL,BC
	JR	NZ,_L0118
	LD	L,(IX-12)
	LD	H,(IX-11)
	LD	C,(IX-4)
	LD	B,(IX-3)
	SBC	HL,BC
	JR	NZ,_L0118
_L0117:
_L1014:
	LD	BC,0
	LD	L,C
	LD	H,B
; 964.	        if (ncl == scl) return 0;       /* No free cluster */
	JP	_L0131
_L0118:
; 965.	    }
; 966.	
	JP	_L0106
_L0105:
	LD	HL,4095
	PUSH	HL
	LD	H,L
	PUSH	HL
	LD	L,(IX-12)
	LD	H,(IX-11)
	PUSH	HL
	LD	L,(IX-14)
	LD	H,(IX-13)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	put_fat
	POP	HL
	POP	HL
	POP	HL
	POP	HL
	LD	(IX-2),A
; 967.	    res = put_fat(fs, ncl, 0x0FFFFFFF); /* Mark the new cluster "last link" */
	OR	A
	JR	NZ,_L0120
	LD	A,(IX+8)
	OR	(IX+9)
	OR	(IX+10)
	OR	(IX+11)
	JR	Z,_L0120
_L0122:
_L0121:
_L0119:
; 968.	    if (res == FR_OK && clst != 0) {
	LD	L,(IX-12)
	LD	H,(IX-11)
	PUSH	HL
	LD	L,(IX-14)
	LD	H,(IX-13)
	PUSH	HL
	LD	L,(IX+10)
	LD	H,(IX+11)
	PUSH	HL
	LD	L,(IX+8)
	LD	H,(IX+9)
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	put_fat
	POP	HL
	POP	HL
	POP	HL
	POP	HL
	LD	(IX-2),A
_L0120:
; 969.	        res = put_fat(fs, clst, ncl);   /* Link it to the previous one if needed */
; 970.	    }
	XOR	A
	OR	(IX-2)
	JR	NZ,_L0124
_L0123:
; 971.	    if (res == FR_OK) {
	LD	C,(IX-12)
	LD	B,(IX-11)
	LD	L,(IX-14)
	LD	(IY+11),L
	LD	H,(IX-13)
	LD	(IY+12),H
	LD	(IY+13),C
	LD	(IY+14),B
; 972.	        fs->last_clust = ncl;           /* Update FSINFO */
	LD	A,(IY+15)
	AND	(IY+16)
	AND	(IY+17)
	AND	(IY+18)
	INC	A
	JR	Z,_L0127
_L0125:
; 973.	        if (fs->free_clust != 0xFFFFFFFF) {
	LD	L,(IY+15)
	LD	H,(IY+16)
	LD	C,(IY+17)
	LD	B,(IY+18)
	CALL	clib_L_DEC_L03
	LD	(IY+15),L
	LD	(IY+16),H
	LD	(IY+17),C
	LD	(IY+18),B
; 974.	            fs->free_clust--;
	LD	(IY+6),1
_L0126:
; 975.	            fs->fsi_flag = 1;
; 976.	        }
	JR	_L0127
_L0124:
; 977.	    } else {
	LD	B,A
	DEC	B
	JR	NZ,_L0129
	LD	BC,65535
	LD	L,C
	LD	H,B
	JR	_L0130
_L0129:
	LD	BC,0
	LD	HL,1
_L0130:
	LD	(IX-14),L
	LD	(IX-13),H
	LD	(IX-12),C
	LD	(IX-11),B
_L0127:
; 978.	        ncl = (res == FR_DISK_ERR) ? 0xFFFFFFFF : 1;
; 979.	    }
; 980.	
	LD	C,(IX-12)
	LD	B,(IX-11)
	LD	L,(IX-14)
	LD	H,(IX-13)
; 981.	    return ncl;     /* Return new cluster number or error code */
_L0131:
	POP	IY
	JP	clib_LEAVE_32_L09
; 982.	}
; 983.	#endif /* !_FS_READONLY */
; 984.	
; 985.	
; 986.	
; 987.	/*-----------------------------------------------------------------------*/
; 988.	/* FAT handling - Convert offset into cluster with link map table        */
; 989.	/*-----------------------------------------------------------------------*/
; 990.	
; 991.	#if _USE_FASTSEEK
; 1011.	#endif  /* _USE_FASTSEEK */
; 1012.	
; 1013.	
; 1014.	
; 1015.	/*-----------------------------------------------------------------------*/
; 1016.	/* Directory handling - Set directory index                              */
; 1017.	/*-----------------------------------------------------------------------*/
; 1018.	
; 1019.	static
; 1020.	FRESULT dir_sdi (
; 1021.	    DIR *dj,        /* Pointer to directory object */
; 1022.	    WORD idx        /* Directory index number */
; 1023.	)
dir_sdi:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-4
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	EXX
	PUSH	BC
	EXX
	POP	DE
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 1024.	{
; 1025.	    DWORD clst;
; 1026.	    WORD ic;
; 1027.	
; 1028.	
	LD	(IY+4),C
	LD	(IY+5),B
; 1029.	    dj->index = idx;
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	(IX-4),L
	LD	H,(IY+7)
	LD	(IX-3),H
	LD	(IX-2),C
	LD	(IX-1),B
; 1030.	    clst = dj->sclust;
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	Z,_L0134
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	AND	A
	LD	L,(IX-4)
	LD	H,(IX-3)
	POP	BC
	SBC	HL,BC
	LD	L,(IX-2)
	LD	H,(IX-1)
	POP	BC
	SBC	HL,BC
	JR	C,_L0133
_L0134:
_L0135:
_L0132:
; 1031.	    if (clst == 1 || clst >= dj->fs->n_fatent)  /* Check start cluster range */
	JR	_L1016
; 1032.	        return FR_INT_ERR;
_L0133:
	LD	A,(IX-4)
	OR	(IX-3)
	OR	(IX-2)
	OR	(IX-1)
	JR	NZ,_L0137
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	A,(HL)
	CP	3
	JR	NZ,_L0137
_L0139:
_L0138:
_L0136:
; 1033.	    if (!clst && dj->fs->fs_type == FS_FAT32)   /* Replace cluster# 0 with root cluster# if in FAT32 */
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,39
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IX-4),L
	LD	(IX-3),H
	LD	(IX-2),C
	LD	(IX-1),B
_L0137:
; 1034.	        clst = dj->fs->dirbase;
; 1035.	
	LD	A,(IX-4)
	OR	(IX-3)
	OR	(IX-2)
	OR	(IX-1)
	JR	NZ,_L0141
_L0140:
; 1036.	    if (clst == 0) {    /* Static table (root-dir in FAT12/16) */
	LD	C,(IX-2)
	LD	B,(IX-1)
	LD	L,(IX-4)
	LD	(IY+10),L
	LD	H,(IX-3)
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
; 1037.	        dj->clust = clst;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,9
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	C,_L0143
_L0142:
; 1038.	        if (idx >= dj->fs->n_rootdir)       /* Index is out of range */
_L1016:
	JP	_L0152
; 1039.	            return FR_INT_ERR;
_L0143:
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,39
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	JP	_L1015
; 1040.	        dj->sect = dj->fs->dirbase + idx / (SS(dj->fs) / SZ_DIR);   /* Sector# */
; 1041.	    }
_L0141:
; 1042.	    else {              /* Dynamic table (sub-dirs or root-dir in FAT32) */
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	EXX
	POP	BC
_L1018:
_L0146:
; 1043.	        ic = SS(dj->fs) / SZ_DIR * dj->fs->csize;   /* Entries per cluster */
	PUSH	BC
	EXX
	POP	BC
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	C,_L0145
_L0147:
; 1044.	        while (idx >= ic) { /* Follow cluster chain */
	LD	L,(IX-2)
	LD	H,(IX-1)
	PUSH	HL
	LD	L,(IX-4)
	LD	H,(IX-3)
	PUSH	HL
	CALL	_L1166
	POP	AF
	POP	AF
	LD	(IX-4),L
	LD	(IX-3),H
	LD	(IX-2),C
	LD	(IX-1),B
; 1045.	            clst = get_fat(dj->fs, clst);               /* Get next cluster */
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	NZ,_L0149
_L0148:
	LD	A,1
; 1046.	            if (clst == 0xFFFFFFFF) return FR_DISK_ERR; /* Disk error */
	JP	_L0154
_L0149:
	LD	BC,2
	SBC	HL,BC
	LD	L,(IX-2)
	LD	H,(IX-1)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L0152
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	C,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	AND	A
	LD	L,(IX-4)
	LD	H,(IX-3)
	POP	BC
	SBC	HL,BC
	LD	L,(IX-2)
	LD	H,(IX-1)
	POP	BC
	SBC	HL,BC
	JR	C,_L0151
_L0152:
_L0153:
_L0150:
; 1047.	            if (clst < 2 || clst >= dj->fs->n_fatent)   /* Reached to end of table or int error */
	LD	A,2
; 1048.	                return FR_INT_ERR;
	JR	_L0154
_L0151:
	EXX
	PUSH	BC
	EX	DE,HL
	POP	DE
	AND	A
	SBC	HL,DE
	EX	DE,HL
	JR	_L1018
; 1049.	            idx -= ic;
; 1050.	        }
_L0145:
	LD	C,(IX-2)
	LD	B,(IX-1)
	LD	L,(IX-4)
	LD	(IY+10),L
	LD	H,(IX-3)
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
; 1051.	        dj->clust = clst;
	LD	L,C
	LD	H,B
	PUSH	BC
	LD	L,(IX-4)
	LD	H,(IX-3)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	PUSH	BC
	PUSH	HL
_L1015:
	LD	B,4
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	_L1161
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
_L0144:
; 1052.	        dj->sect = clust2sect(dj->fs, clst) + idx / (SS(dj->fs) / SZ_DIR);  /* Sector# */
; 1053.	    }
; 1054.	
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,51
	ADD	HL,BC
	PUSH	HL
	EXX
	PUSH	DE
	EXX
	POP	BC
	LD	A,C
	AND	15
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	C,L
	LD	B,H
	POP	HL
	ADD	HL,BC
	LD	(IY+18),L
	LD	(IY+19),H
; 1055.	    dj->dir = dj->fs->win + (idx % (SS(dj->fs) / SZ_DIR)) * SZ_DIR; /* Ptr to the entry in the sector */
; 1056.	
	XOR	A
; 1057.	    return FR_OK;   /* Seek succeeded */
_L0154:
	EXX
	POP	DE
	POP	BC
	EXX
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
_L1166:
	LD	E,(IY+0)
	LD	D,(IY+1)
	JP	get_fat
_L1168:
	LD	E,(IY+0)
	LD	D,(IY+1)
	JP	clust2sect
; 1058.	}
; 1059.	
; 1060.	
; 1061.	
; 1062.	
; 1063.	/*-----------------------------------------------------------------------*/
; 1064.	/* Directory handling - Move directory index next                        */
; 1065.	/*-----------------------------------------------------------------------*/
; 1066.	
; 1067.	static
; 1068.	FRESULT dir_next (  /* FR_OK:Succeeded, FR_NO_FILE:End of table, FR_DENIED:EOT and could not stretch */
; 1069.	    DIR *dj,        /* Pointer to directory object */
; 1070.	    int stretch     /* 0: Do not stretch table, 1: Stretch table if needed */
; 1071.	)
dir_next:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65528
	PUSH	IY
	EXX
	PUSH	BC
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 1072.	{
; 1073.	    DWORD clst;
; 1074.	    WORD i;
; 1075.	
; 1076.	
	LD	L,(IY+4)
	LD	H,(IY+5)
	INC	HL
	PUSH	HL
	EXX
	POP	BC
	EXX
; 1077.	    i = dj->index + 1;
	LD	A,L
	OR	H
	JR	Z,_L1022
	LD	A,(IY+14)
	OR	(IY+15)
	OR	(IY+16)
	OR	(IY+17)
	JR	Z,_L1022
_L0157:
_L0158:
_L0155:
; 1078.	    if (!i || !dj->sect)    /* Report EOT when index has reached 65535 */
; 1079.	        return FR_NO_FILE;
; 1080.	
_L0156:
	LD	A,L
	AND	15
	JP	NZ,_L0167
_L0159:
; 1081.	    if (!(i % (SS(dj->fs) / SZ_DIR))) { /* Sector changed? */
	LD	L,(IY+14)
	LD	H,(IY+15)
	LD	C,(IY+16)
	LD	B,(IY+17)
	CALL	clib_L_INC_L03
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
; 1082.	        dj->sect++;                 /* Next sector */
; 1083.	
	LD	A,(IY+10)
	OR	(IY+11)
	OR	(IY+12)
	OR	(IY+13)
	JR	NZ,_L0162
_L0161:
; 1084.	        if (dj->clust == 0) {   /* Static table */
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,9
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EXX
	PUSH	BC
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	C,_L0164
_L0163:
; 1085.	            if (i >= dj->fs->n_rootdir) /* Report EOT when end of table */
_L1022:
	JP	_L1023
; 1086.	                return FR_NO_FILE;
_L0164:
; 1087.	        }
	JP	_L0167
_L0162:
; 1088.	        else {                  /* Dynamic table */
	LD	B,4
	EXX
	PUSH	BC
	EXX
	POP	DE
	CALL	clib_US_RSH_L02
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	C,(HL)
	LD	B,0
	DEC	BC
	LD	A,E
	AND	C
	LD	H,A
	LD	A,D
	AND	B
	OR	H
	JP	NZ,_L0167
_L0166:
; 1089.	            if (((i / (SS(dj->fs) / SZ_DIR)) & (dj->fs->csize - 1)) == 0) { /* Cluster changed? */
	LD	L,(IY+12)
	LD	H,(IY+13)
	PUSH	HL
	LD	L,(IY+10)
	LD	H,(IY+11)
	PUSH	HL
	CALL	_L1166
	POP	AF
	POP	AF
	LD	(IX-8),L
	LD	(IX-7),H
	LD	(IX-6),C
	LD	(IX-5),B
; 1090.	                clst = get_fat(dj->fs, dj->clust);              /* Get next cluster */
	PUSH	BC
	PUSH	HL
	AND	A
	LD	HL,1
	POP	BC
	SBC	HL,BC
	LD	HL,0
	POP	BC
	SBC	HL,BC
	JR	NC,_L1024
_L0168:
; 1091.	                if (clst <= 1) return FR_INT_ERR;
_L0169:
	LD	A,(IX-8)
	AND	(IX-7)
	AND	(IX-6)
	AND	(IX-5)
	INC	A
	JP	Z,_L1027
_L0170:
; 1092.	                if (clst == 0xFFFFFFFF) return FR_DISK_ERR;
_L0171:
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	AND	A
	LD	L,(IX-8)
	LD	H,(IX-7)
	POP	BC
	SBC	HL,BC
	LD	L,(IX-6)
	LD	H,(IX-5)
	POP	BC
	SBC	HL,BC
	JP	C,_L0173
_L0172:
; 1093.	                if (clst >= dj->fs->n_fatent) {                 /* When it reached end of dynamic table */
; 1094.	#if !_FS_READONLY
; 1095.	                    BYTE c;
	LD	A,(IX+4)
	OR	(IX+5)
	JR	NZ,_L0175
_L0174:
_L1023:
	LD	A,4
; 1096.	                    if (!stretch) return FR_NO_FILE;            /* When do not stretch, report EOT */
	JP	_L0190
_L0175:
	LD	L,(IY+12)
	LD	H,(IY+13)
	PUSH	HL
	LD	L,(IY+10)
	LD	H,(IY+11)
	PUSH	HL
	CALL	_L1169
	POP	AF
	POP	AF
	LD	(IX-8),L
	LD	(IX-7),H
	LD	(IX-6),C
	LD	(IX-5),B
; 1097.	                    clst = create_chain(dj->fs, dj->clust);     /* Stretch cluster chain */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0177
_L0176:
	LD	A,7
; 1098.	                    if (clst == 0) return FR_DENIED;            /* No free cluster */
	JP	_L0190
_L0177:
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0179
_L0178:
_L1024:
	LD	A,2
; 1099.	                    if (clst == 1) return FR_INT_ERR;
	JP	_L0190
_L0179:
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	Z,_L1026
_L0180:
; 1100.	                    if (clst == 0xFFFFFFFF) return FR_DISK_ERR;
; 1101.	                    /* Clean-up stretched table */
_L0181:
	LD	HL,0
	PUSH	HL
	PUSH	HL
	LD	E,(IY+0)
	LD	D,(IY+1)
	CALL	move_window
	POP	HL
	POP	HL
	OR	A
	JR	Z,_L0183
_L0182:
_L1026:
	JR	_L1027
; 1102.	                    if (move_window(dj->fs, 0)) return FR_DISK_ERR; /* Flush active window */
_L0183:
	LD	BC,512
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	DE,51
	ADD	HL,DE
	EX	DE,HL
	LD	L,C
	CALL	clib_MEMSET_L11
; 1103.	                    memset(dj->fs->win, 0, SS(dj->fs));         /* Clear window buffer */
	LD	L,(IX-6)
	LD	H,(IX-5)
	PUSH	HL
	LD	L,(IX-8)
	LD	H,(IX-7)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	PUSH	HL
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	DE,47
	ADD	HL,DE
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 1104.	                    dj->fs->winsect = clust2sect(dj->fs, clst); /* Cluster start sector */
	LD	(IX-2),0
_L0185:
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	A,(IX-2)
	CP	(HL)
	LD	L,(IY+0)
	LD	H,(IY+1)
	JR	NC,_L0184
_L0186:
; 1105.	                    for (c = 0; c < dj->fs->csize; c++) {       /* Fill the new cluster with 0 */
	LD	BC,5
	ADD	HL,BC
	LD	(HL),1
; 1106.	                        dj->fs->wflag = 1;
	LD	L,B
	LD	H,B
	PUSH	HL
	PUSH	HL
	LD	E,(IY+0)
	LD	D,(IY+1)
	CALL	move_window
	POP	HL
	POP	HL
	OR	A
	JR	Z,_L0189
_L0188:
_L1027:
	LD	A,1
; 1107.	                        if (move_window(dj->fs, 0)) return FR_DISK_ERR;
	JR	_L0190
_L0189:
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	C,47
	ADD	HL,BC
	CALL	clib_L_INCASG_L03
	INC	(IX-2)
; 1108.	                        dj->fs->winsect++;
; 1109.	                    }
	JR	_L0185
_L0184:
	LD	BC,47
	ADD	HL,BC
	LD	E,A
	LD	C,B
	LD	D,C
	CALL	clib_L_SUBASG_L03
_L0173:
; 1110.	                    dj->fs->winsect -= c;                       /* Rewind window address */
; 1111.	#else
; 1113.	#endif
; 1114.	                }
	LD	C,(IX-6)
	LD	B,(IX-5)
	LD	L,(IX-8)
	LD	(IY+10),L
	LD	H,(IX-7)
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
; 1115.	                dj->clust = clst;               /* Initialize data for new cluster */
	LD	L,C
	LD	H,B
	PUSH	BC
	LD	L,(IX-8)
	LD	H,(IX-7)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
_L0167:
_L0165:
_L0160:
; 1116.	                dj->sect = clust2sect(dj->fs, clst);
; 1117.	            }
; 1118.	        }
; 1119.	    }
; 1120.	
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	(IY+4),L
	LD	(IY+5),H
; 1121.	    dj->index = i;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,51
	ADD	HL,BC
	PUSH	HL
	EXX
	PUSH	BC
	EXX
	POP	BC
	LD	A,C
	AND	15
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	C,L
	LD	B,H
	POP	HL
	ADD	HL,BC
	LD	(IY+18),L
	LD	(IY+19),H
; 1122.	    dj->dir = dj->fs->win + (i % (SS(dj->fs) / SZ_DIR)) * SZ_DIR;
; 1123.	
	XOR	A
; 1124.	    return FR_OK;
_L0190:
	EXX
	POP	BC
	EXX
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
_L1169:
	LD	E,(IY+0)
	LD	D,(IY+1)
	JP	create_chain
; 1125.	}
; 1126.	
; 1127.	
; 1128.	
; 1129.	
; 1130.	/*-----------------------------------------------------------------------*/
; 1131.	/* LFN handling - Test/Pick/Fit an LFN segment from/to directory entry   */
; 1132.	/*-----------------------------------------------------------------------*/
; 1133.	#if _USE_LFN
; 1201.	#if !_FS_READONLY
; 1230.	#endif
; 1231.	#endif
; 1232.	
; 1233.	
; 1234.	
; 1235.	/*-----------------------------------------------------------------------*/
; 1236.	/* Create numbered name                                                  */
; 1237.	/*-----------------------------------------------------------------------*/
; 1238.	#if _USE_LFN
; 1277.	#endif
; 1278.	
; 1279.	
; 1280.	
; 1281.	
; 1282.	/*-----------------------------------------------------------------------*/
; 1283.	/* Calculate sum of an SFN                                               */
; 1284.	/*-----------------------------------------------------------------------*/
; 1285.	#if _USE_LFN
; 1297.	#endif
; 1298.	
; 1299.	
; 1300.	
; 1301.	
; 1302.	/*-----------------------------------------------------------------------*/
; 1303.	/* Directory handling - Find an object in the directory                  */
; 1304.	/*-----------------------------------------------------------------------*/
; 1305.	
; 1306.	static
; 1307.	FRESULT dir_find (
; 1308.	    DIR *dj         /* Pointer to the directory object linked to the file name */
; 1309.	)
dir_find:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	EXX
	PUSH	BC
	EXX
	PUSH	AF
; 1310.	{
; 1311.	    FRESULT res;
; 1312.	    BYTE c, *dir;
; 1313.	#if _USE_LFN
; 1315.	#endif
; 1316.	
	CALL	_L1171
; 1317.	    res = dir_sdi(dj, 0);           /* Rewind directory object */
	JR	NZ,_L0193
_L0191:
; 1318.	    if (res != FR_OK) return res;
; 1319.	
; 1320.	#if _USE_LFN
; 1322.	#endif
_L0192:
_L0195:
; 1323.	    do {
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	CALL	_L1162
	POP	HL
	POP	HL
	LD	IYL,A
; 1324.	        res = move_window(dj->fs, dj->sect);
	OR	A
	JR	NZ,_L0193
_L0196:
_L0197:
; 1325.	        if (res != FR_OK) break;
	EXX
	LD	C,(IX+18)
	LD	B,(IX+19)
; 1326.	        dir = dj->dir;                  /* Ptr to the directory entry of current index */
	PUSH	BC
	EXX
	POP	HL
	LD	B,(HL)
; 1327.	        c = dir[DIR_Name];
	OR	B
	JR	NZ,_L0199
_L0198:
	LD	IYL,4
	JR	_L0193
_L0199:
; 1328.	        if (c == 0) { res = FR_NO_FILE; break; }    /* Reached to end of table */
; 1329.	#if _USE_LFN    /* LFN configuration */
; 1350.	#else       /* Non LFN configuration */
	LD	HL,11
	EXX
	PUSH	BC
	EXX
	POP	BC
	ADD	HL,BC
	BIT	3,(HL)
	JR	NZ,_L0201
	LD	BC,11
	EXX
	PUSH	BC
	EXX
	POP	DE
	LD	L,(IX+20)
	LD	H,(IX+21)
	CALL	clib_MEMCMP_L11
	LD	A,L
	OR	H
	JR	Z,_L0193
_L0203:
_L0202:
_L0200:
; 1351.	        if (!(dir[DIR_Attr] & AM_VOL) && !memcmp(dir, dj->fn, 11)) /* Is it a valid entry? */
_L0201:
; 1352.	            break;
; 1353.	#endif
	CALL	_L1172
; 1354.	        res = dir_next(dj, 0);      /* Next entry */
	JR	Z,_L0192
_L0193:
; 1355.	    } while (res == FR_OK);
; 1356.	
	LD	A,IYL
; 1357.	    return res;
_L0204:
	POP	HL
_L1156:
	EXX
	POP	BC
	EXX
	POP	IX
	POP	IY
	POP	BC
	RET
_L1162:
	LD	E,(IX+0)
	LD	D,(IX+1)
	JP	move_window
_L1171:
	PUSH	DE
	POP	IX
	LD	BC,0
	CALL	dir_sdi
	LD	IYL,A
	OR	A
	RET
_L1172:
	LD	BC,0
_L1173:
	PUSH	IX
	POP	DE
	CALL	dir_next
	LD	IYL,A
	OR	A
	RET
; 1358.	}
; 1359.	
; 1360.	
; 1361.	
; 1362.	
; 1363.	/*-----------------------------------------------------------------------*/
; 1364.	/* Read an object from the directory                                     */
; 1365.	/*-----------------------------------------------------------------------*/
; 1366.	#if _FS_MINIMIZE <= 1
; 1367.	static
; 1368.	FRESULT dir_read (
; 1369.	    DIR *dj         /* Pointer to the directory object that pointing the entry to be read */
; 1370.	)
dir_read:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	EXX
	PUSH	BC
	EXX
	PUSH	DE
	POP	IX
; 1371.	{
; 1372.	    FRESULT res;
; 1373.	    BYTE c, *dir;
; 1374.	#if _USE_LFN
; 1376.	#endif
; 1377.	
	LD	IYL,4
_L0206:
; 1378.	    res = FR_NO_FILE;
	LD	A,(IX+14)
	OR	(IX+15)
	OR	(IX+16)
	OR	(IX+17)
	JR	Z,_L0205
_L0207:
; 1379.	    while (dj->sect) {
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	CALL	_L1162
	POP	HL
	POP	HL
	LD	IYL,A
; 1380.	        res = move_window(dj->fs, dj->sect);
	OR	A
	JR	NZ,_L0205
_L0208:
_L0209:
; 1381.	        if (res != FR_OK) break;
	EXX
	LD	C,(IX+18)
	LD	B,(IX+19)
; 1382.	        dir = dj->dir;                  /* Ptr to the directory entry of current index */
	PUSH	BC
	EXX
	POP	HL
	LD	B,(HL)
	LD	IYH,B
; 1383.	        c = dir[DIR_Name];
	INC	B
	DEC	B
	JR	NZ,_L0211
_L0210:
	LD	IYL,4
	JR	_L0205
_L0211:
; 1384.	        if (c == 0) { res = FR_NO_FILE; break; }    /* Reached to end of table */
; 1385.	#if _USE_LFN    /* LFN configuration */
; 1404.	#else       /* Non LFN configuration */
	LD	A,IYH
	CP	229
	JR	Z,_L0213
_L0216:
_L0217:
	LD	HL,11
	EXX
	PUSH	BC
	EXX
	POP	BC
	ADD	HL,BC
	BIT	3,(HL)
	JR	Z,_L0205
_L0215:
_L0214:
_L0212:
; 1405.	        if (c != DDE && (_FS_RPATH || c != '.') && !(dir[DIR_Attr] & AM_VOL))   /* Is it a valid entry? */
_L0213:
; 1406.	            break;
; 1407.	#endif
	CALL	_L1172
; 1408.	        res = dir_next(dj, 0);              /* Next entry */
	JR	Z,_L0206
_L0218:
_L0219:
; 1409.	        if (res != FR_OK) break;
; 1410.	    }
; 1411.	
_L0205:
	LD	B,IYL
	INC	B
	DEC	B
	JR	Z,_L0221
_L0220:
	XOR	A
	LD	(IX+14),A
	LD	(IX+15),A
	LD	(IX+16),A
	LD	(IX+17),A
_L0221:
; 1412.	    if (res != FR_OK) dj->sect = 0;
; 1413.	
	LD	A,IYL
; 1414.	    return res;
	JP	_L1156
; 1415.	}
; 1416.	#endif
; 1417.	
; 1418.	
; 1419.	
; 1420.	/*-----------------------------------------------------------------------*/
; 1421.	/* Register an object to the directory                                   */
; 1422.	/*-----------------------------------------------------------------------*/
; 1423.	#if !_FS_READONLY
; 1424.	static
; 1425.	FRESULT dir_register (  /* FR_OK:Successful, FR_DENIED:No free entry or too many SFN collision, FR_DISK_ERR:Disk error */
; 1426.	    DIR *dj             /* Target directory with object name to be created */
; 1427.	)
dir_register:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	EXX
	PUSH	BC
	EXX
	PUSH	AF
; 1428.	{
; 1429.	    FRESULT res;
; 1430.	    BYTE c, *dir;
; 1431.	#if _USE_LFN    /* LFN configuration */
; 1494.	#else   /* Non LFN configuration */
	CALL	_L1171
; 1495.	    res = dir_sdi(dj, 0);
	JR	NZ,_L0224
_L0222:
_L0226:
; 1496.	    if (res == FR_OK) {
; 1497.	        do {    /* Find a blank entry for the SFN */
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	CALL	_L1162
	POP	HL
	POP	HL
	LD	IYL,A
; 1498.	            res = move_window(dj->fs, dj->sect);
	OR	A
	JR	NZ,_L0224
_L0227:
_L0228:
; 1499.	            if (res != FR_OK) break;
	LD	L,(IX+18)
	LD	H,(IX+19)
	LD	B,(HL)
	LD	A,B
; 1500.	            c = *dj->dir;
	CP	229
	JR	Z,_L0224
	XOR	A
	OR	B
	JR	Z,_L0224
_L0231:
_L0232:
_L0229:
_L0230:
; 1501.	            if (c == DDE || c == 0) break;  /* Is it a blank entry? */
	LD	BC,1
	CALL	_L1173
; 1502.	            res = dir_next(dj, 1);          /* Next entry with table stretch */
	JR	Z,_L0222
_L0224:
_L0223:
; 1503.	        } while (res == FR_OK);
; 1504.	    }
; 1505.	#endif
; 1506.	
	LD	B,IYL
	INC	B
	DEC	B
	JR	NZ,_L0236
_L0233:
; 1507.	    if (res == FR_OK) {     /* Initialize the SFN entry */
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	CALL	_L1162
	POP	HL
	POP	HL
	LD	IYL,A
; 1508.	        res = move_window(dj->fs, dj->sect);
	OR	A
	JR	NZ,_L0236
_L0235:
; 1509.	        if (res == FR_OK) {
	EXX
	LD	C,(IX+18)
	LD	B,(IX+19)
	EXX
; 1510.	            dir = dj->dir;
	LD	C,32
	EXX
	PUSH	BC
	EXX
	POP	DE
	LD	L,B
	CALL	clib_MEMSET_L11
; 1511.	            memset(dir, 0, SZ_DIR); /* Clean the entry */
	LD	BC,11
	LD	L,(IX+20)
	LD	H,(IX+21)
	LDIR
; 1512.	            memcpy(dir, dj->fn, 11);    /* Put SFN */
; 1513.	#if _USE_LFN
; 1515.	#endif
	LD	L,(IX+0)
	LD	H,(IX+1)
	LD	C,5
	ADD	HL,BC
	LD	(HL),1
_L0236:
_L0234:
; 1516.	            dj->fs->wflag = 1;
; 1517.	        }
; 1518.	    }
; 1519.	
	LD	A,IYL
; 1520.	    return res;
	POP	HL
	JP	_L1156
; 1521.	}
; 1522.	#endif /* !_FS_READONLY */
; 1523.	
; 1524.	
; 1525.	
; 1526.	
; 1527.	/*-----------------------------------------------------------------------*/
; 1528.	/* Remove an object from the directory                                   */
; 1529.	/*-----------------------------------------------------------------------*/
; 1530.	#if !_FS_READONLY && !_FS_MINIMIZE
; 1531.	static
; 1532.	FRESULT dir_remove (    /* FR_OK: Successful, FR_DISK_ERR: A disk error */
; 1533.	    DIR *dj             /* Directory object pointing the entry to be removed */
; 1534.	)
dir_remove:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	PUSH	DE
	POP	IX
; 1535.	{
; 1536.	    FRESULT res;
; 1537.	#if _USE_LFN    /* LFN configuration */
; 1554.	#else           /* Non LFN configuration */
	LD	HL,4
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	dir_sdi
; 1555.	    res = dir_sdi(dj, dj->index);
	OR	A
	JR	NZ,_L0242
_L0239:
; 1556.	    if (res == FR_OK) {
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	CALL	_L1162
	POP	HL
	POP	HL
; 1557.	        res = move_window(dj->fs, dj->sect);
	OR	A
	JR	NZ,_L0242
_L0241:
; 1558.	        if (res == FR_OK) {
	LD	L,(IX+18)
	LD	H,(IX+19)
	LD	(HL),229
; 1559.	            *dj->dir = DDE;         /* Mark the entry "deleted" */
	LD	L,(IX+0)
	LD	H,(IX+1)
	LD	BC,5
	ADD	HL,BC
	LD	(HL),1
_L0242:
_L0240:
; 1560.	            dj->fs->wflag = 1;
; 1561.	        }
; 1562.	    }
; 1563.	#endif
; 1564.	
; 1565.	    return res;
	POP	IX
	POP	IY
	POP	BC
	RET
; 1566.	}
; 1567.	#endif /* !_FS_READONLY */
; 1568.	
; 1569.	
; 1570.	
; 1571.	
; 1572.	/*-----------------------------------------------------------------------*/
; 1573.	/* Pick a segment and create the object name in directory form           */
; 1574.	/*-----------------------------------------------------------------------*/
; 1575.	
; 1576.	static
; 1577.	FRESULT create_name (
; 1578.	    DIR *dj,            /* Pointer to the directory object */
; 1579.	    const TCHAR **path  /* Pointer to pointer to the segment in the path string */
; 1580.	)
create_name:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-6
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	EXX
; 1581.	{
; 1582.	#ifdef _EXCVT
; 1583.	    static const BYTE excvt[] = _EXCVT; /* Upper conversion table for extended chars */
; 1584.	#endif
; 1585.	
; 1586.	#if _USE_LFN    /* LFN configuration */
; 1601.	#if !_LFN_UNICODE
; 1611.	#endif
; 1618.	#if _FS_RPATH
; 1627.	#endif
; 1662.	#ifdef _EXCVT
; 1665.	#else
; 1667.	#endif
; 1707.	#else   /* Non-LFN configuration */
; 1708.	    BYTE b, c, d, *sfn;
; 1709.	    UINT ni, si, i;
; 1710.	    const char *p;
; 1711.	
; 1712.	    /* Create file name in directory form */
	LD	A,(BC)
	LD	(IX-4),A
	INC	BC
	LD	A,(BC)
	LD	(IX-3),A
_L0245:
	LD	L,(IX-4)
	LD	H,(IX-3)
	LD	A,(HL)
	CP	47
	JR	Z,_L0247
	LD	A,(HL)
	CP	92
	JR	NZ,_L0244
_L0247:
_L0248:
_L0246:
	INC	(IX-4)
	JR	NZ,_L0245
	INC	(IX-3)
; 1713.	    for (p = *path; *p == '/' || *p == '\\'; p++) ; /* Strip duplicated separator */
	JR	_L0245
_L0244:
	LD	HL,20
	LD	C,(IX+2)
	LD	B,(IX+3)
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	EX	DE,HL
; 1714.	    sfn = dj->fn;
	LD	BC,11
	LD	HL,32
	CALL	clib_MEMSET_L11
; 1715.	    memset(sfn, ' ', 11);
; 1716.	    si = i = b = 0; ni = 8;
; 1717.	#if _FS_RPATH
	LD	(IX-6),H
	EXX
	LD	DE,0
	LD	BC,0
	EXX
	LD	(IX-2),8
	LD	(IX-1),H
	LD	L,(IX-4)
	LD	H,(IX-3)
	LD	A,(HL)
	CP	46
	JR	NZ,_L0251
_L0250:
_L0253:
; 1718.	    if (p[si] == '.') { /* Is this a dot entry? */
; 1719.	        for (;;) {
	EXX
	PUSH	BC
	INC	BC
	EXX
	POP	HL
	LD	C,(IX-4)
	LD	B,(IX-3)
	ADD	HL,BC
	LD	B,(HL)
	LD	IYL,B
; 1720.	            c = (BYTE)p[si++];
	LD	A,B
	CP	46
	JR	NZ,_L0252
	LD	BC,3
	EXX
	PUSH	BC
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0252
_L0256:
_L0257:
_L0254:
_L0255:
; 1721.	            if (c != '.' || si >= 3) break;
	EXX
	PUSH	DE
	INC	DE
	EXX
	POP	HL
	ADD	HL,DE
	LD	B,IYL
	LD	(HL),B
; 1722.	            sfn[i++] = c;
; 1723.	        }
	JR	_L0250
_L0252:
	CP	47
	JR	Z,_L0259
	CP	92
	JR	Z,_L0259
	LD	A,32
	CP	IYL
	JR	C,_L0277
_L0261:
_L0260:
_L0258:
; 1724.	        if (c != '/' && c != '\\' && c > ' ') return FR_INVALID_NAME;
_L0259:
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	C,(IX-4)
	LD	B,(IX-3)
	ADD	HL,BC
	PUSH	HL
	LD	L,(IX+4)
	LD	H,(IX+5)
	POP	BC
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 1725.	        *path = &p[si];                                 /* Return pointer to the next segment */
	LD	HL,11
	ADD	HL,DE
	LD	A,32
	CP	IYL
	JR	C,_L0263
	LD	A,36
_L0263:
	LD	(HL),A
; 1726.	        sfn[NS] = (c <= ' ') ? NS_LAST | NS_DOT : NS_DOT;   /* Set last segment flag if end of path */
	JP	_L1032
; 1727.	        return FR_OK;
_L0251:
_L0266:
; 1728.	    }
; 1729.	#endif
; 1730.	    for (;;) {
	EXX
	PUSH	BC
	INC	BC
	EXX
	POP	HL
	LD	C,(IX-4)
	LD	B,(IX-3)
	ADD	HL,BC
	LD	B,(HL)
	LD	IYL,B
; 1731.	        c = (BYTE)p[si++];
	LD	A,32
	CP	B
	JR	NC,_L0269
	LD	A,IYL
	CP	47
	JR	Z,_L0269
	CP	92
	JR	NZ,_L0268
_L0269:
_L0270:
_L0267:
	JP	_L0265
_L0268:
; 1732.	        if (c <= ' ' || c == '/' || c == '\\') break;   /* Break on end of segment */
	CP	46
	JR	Z,_L0273
	LD	C,(IX-2)
	LD	B,(IX-1)
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	C,_L0272
_L0273:
_L0274:
_L0271:
; 1733.	        if (c == '.' || i >= ni) {
	LD	A,8
	XOR	(IX-2)
	OR	(IX-1)
	JR	NZ,_L1035
	LD	A,IYL
	CP	46
	JR	Z,_L0276
_L0277:
_L0278:
_L0275:
	JR	_L1035
; 1734.	            if (ni != 8 || c != '.') return FR_INVALID_NAME;
_L0276:
; 1735.	            i = 8; ni = 11;
	SLA	(IX-6)
	SLA	(IX-6)
	EXX
	LD	DE,8
	EXX
	LD	(IX-2),11
	LD	(IX-1),0
	JR	_L0251
_L0272:
; 1736.	            b <<= 2; continue;
; 1737.	        }
	CP	128
	JR	C,_L0280
_L0279:
; 1738.	        if (c >= 0x80) {                /* Extended char? */
	LD	A,(IX-6)
	OR	3
	LD	(IX-6),A
; 1739.	            b |= 3;                     /* Eliminate NT flag */
; 1740.	#ifdef _EXCVT
	LD	HL,_L0243-128
	LD	C,IYL
	LD	B,0
	ADD	HL,BC
	LD	B,(HL)
	LD	IYL,B
_L0280:
; 1741.	            c = excvt[c-0x80];          /* Upper conversion (SBCS) */
; 1742.	#else
; 1743.	#if !_DF1S  /* ASCII only cfg */
; 1745.	#endif
; 1746.	#endif
; 1747.	        }
	XOR	A
	JR	Z,_L0282
_L0281:
; 1748.	        if (IsDBCS1(c)) {               /* Check if it is a DBC 1st byte (always false on SBCS cfg) */
	EXX
	PUSH	BC
	EXX
	POP	HL
; 1749.	            d = (BYTE)p[si++];          /* Get 2nd byte */
	JR	_L1036
_L0285:
_L0286:
_L0283:
; 1750.	            if (!IsDBCS2(d) || i >= ni - 1) /* Reject invalid DBC */
; 1751.	                return FR_INVALID_NAME;
_L0284:
; 1752.	            sfn[i++] = c;
; 1753.	            sfn[i++] = d;
_L0282:
; 1754.	        } else {                        /* Single byte code */
	PUSH	DE
	LD	C,IYL
	LD	E,C
	LD	HL,_L0290
	CALL	clib_STRCHR_L11
	LD	A,L
	OR	H
	POP	DE
	JR	Z,_L0289
_L0288:
; 1755.	            if (strchr("\"*+,:;<=>\?[]|\x7F", c))   /* Reject illegal chrs for SFN */
_L1035:
	JR	_L1036
; 1756.	                return FR_INVALID_NAME;
_L0289:
	LD	A,IYL
	CP	65
	JR	C,_L0292
	LD	A,90
	CP	C
	JR	C,_L0292
_L0294:
_L0293:
_L0291:
; 1757.	            if (IsUpper(c)) {           /* ASCII large capital? */
	SET	1,(IX-6)
; 1758.	                b |= 2;
	JR	_L0297
_L0292:
; 1759.	            } else {
	LD	A,IYL
	CP	97
	JR	C,_L0297
	LD	A,122
	CP	C
	JR	C,_L0297
_L0299:
_L0298:
_L0296:
; 1760.	                if (IsLower(c)) {       /* ASCII small capital? */
	SET	0,(IX-6)
	LD	A,IYL
	SUB	32
	LD	IYL,A
_L0297:
_L0295:
; 1761.	                    b |= 1; c -= 0x20;
; 1762.	                }
; 1763.	            }
	EXX
	PUSH	DE
	INC	DE
	EXX
	POP	HL
	ADD	HL,DE
	LD	B,IYL
	LD	(HL),B
_L0287:
; 1764.	            sfn[i++] = c;
; 1765.	        }
; 1766.	    }
	JP	_L0251
_L0265:
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	B,(IX-3)
	ADD	HL,BC
	PUSH	HL
	LD	L,(IX+4)
	LD	H,(IX+5)
	POP	BC
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 1767.	    *path = &p[si];                     /* Return pointer to the next segment */
	LD	A,32
	CP	IYL
	JR	C,_L0301
	LD	A,4
	JR	_L0302
_L0301:
	XOR	A
_L0302:
	LD	IYL,A
; 1768.	    c = (c <= ' ') ? NS_LAST : 0;       /* Set last segment flag if end of path */
; 1769.	
	EXX
	LD	A,E
	OR	D
	EXX
	JR	NZ,_L0304
_L0303:
_L1036:
	LD	A,6
; 1770.	    if (!i) return FR_INVALID_NAME;     /* Reject nul string */
	JR	_L0313
_L0304:
	LD	L,E
	LD	H,D
	LD	A,(HL)
	CP	229
	JR	NZ,_L0306
_L0305:
	LD	(HL),5
_L0306:
; 1771.	    if (sfn[0] == DDE) sfn[0] = NDDE;   /* When first char collides with DDE, replace it with 0x05 */
; 1772.	
	LD	A,8
	XOR	(IX-2)
	OR	(IX-1)
	JR	NZ,_L0308
_L0307:
	SLA	(IX-6)
	SLA	(IX-6)
_L0308:
; 1773.	    if (ni == 8) b <<= 2;
	LD	A,(IX-6)
	AND	3
	DEC	A
	JR	NZ,_L0310
_L0309:
	LD	A,IYL
	OR	16
	LD	IYL,A
_L0310:
; 1774.	    if ((b & 0x03) == 0x01) c |= NS_EXT;    /* NT flag (Name extension has only small capital) */
	LD	A,(IX-6)
	AND	12
	CP	4
	JR	NZ,_L0312
_L0311:
	LD	A,IYL
	OR	8
	LD	IYL,A
_L0312:
; 1775.	    if ((b & 0x0C) == 0x04) c |= NS_BODY;   /* NT flag (Name body has only small capital) */
; 1776.	
	LD	HL,11
	ADD	HL,DE
	LD	B,IYL
	LD	(HL),B
; 1777.	    sfn[NS] = c;        /* Store NT flag, File name is created */
; 1778.	
_L1032:
	XOR	A
; 1779.	    return FR_OK;
; 1780.	#endif
_L0313:
	JP	_L0154
; 1781.	}
; 1782.	
; 1783.	
; 1784.	
; 1785.	
; 1786.	/*-----------------------------------------------------------------------*/
; 1787.	/* Get file information from directory entry                             */
; 1788.	/*-----------------------------------------------------------------------*/
; 1789.	#if _FS_MINIMIZE <= 1
; 1790.	static
; 1791.	void get_fileinfo (     /* No return code */
; 1792.	    DIR *dj,            /* Pointer to the directory object */
; 1793.	    FILINFO *fno        /* Pointer to the file information to be filled */
; 1794.	)
get_fileinfo:
	PUSH	IY
	PUSH	IX
	EXX
	PUSH	BC
	PUSH	DE
	EXX
	PUSH	DE
	PUSH	AF
	PUSH	BC
	POP	IY
; 1795.	{
; 1796.	    UINT i;
; 1797.	    BYTE nt, *dir;
; 1798.	    TCHAR *p, c;
; 1799.	
; 1800.	
	LD	HL,9
	ADD	HL,BC
	PUSH	HL
	EXX
	POP	BC
	EXX
; 1801.	    p = fno->fname;
	LD	L,E
	LD	H,D
	LD	BC,14
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	OR	(HL)
	INC	HL
	OR	(HL)
	INC	HL
	OR	(HL)
	JP	Z,_L0315
_L0314:
; 1802.	    if (dj->sect) {
	LD	C,E
	LD	B,D
	LD	HL,18
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	PUSH	HL
	POP	IX
; 1803.	        dir = dj->dir;
	LD	BC,12
	ADD	HL,BC
	LD	B,(HL)
	LD	HL,1
	ADD	HL,SP
	LD	(HL),B
; 1804.	        nt = dir[DIR_NTres];        /* NT flag */
	EXX
	LD	DE,0
_L1037:
	EXX
_L0317:
	LD	BC,8
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0316
_L0318:
; 1805.	        for (i = 0; i < 8; i++) {   /* Copy name body */
	EXX
	PUSH	DE
	EXX
	POP	HL
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	B,(HL)
	LD	HL,0
	ADD	HL,SP
	LD	(HL),B
; 1806.	            c = dir[i];
	LD	A,B
	CP	32
	JR	Z,_L0316
_L0320:
_L0321:
; 1807.	            if (c == ' ') break;
	CP	5
	JR	NZ,_L0323
_L0322:
	LD	(HL),229
_L0323:
; 1808.	            if (c == NDDE) c = (TCHAR)DDE;
	XOR	A
	JR	Z,_L0325
	INC	HL
	BIT	3,(HL)
	JR	Z,_L0325
	DEC	HL
	LD	A,(HL)
	CP	65
	JR	C,_L0325
	LD	A,90
	CP	(HL)
	JR	C,_L0325
_L0329:
_L0328:
_L0327:
_L0326:
_L0324:
	LD	A,(HL)
	ADD	A,32
	LD	(HL),A
_L0325:
; 1809.	            if (_USE_LFN && (nt & NS_BODY) && IsUpper(c)) c += 0x20;
; 1810.	#if _LFN_UNICODE
; 1815.	#endif
	EXX
	PUSH	BC
	INC	BC
	EXX
	LD	HL,2
	ADD	HL,SP
	LD	B,(HL)
	POP	HL
	LD	(HL),B
	EXX
	INC	DE
	JR	_L1037
; 1816.	            *p++ = c;
; 1817.	        }
_L0316:
	LD	A,(IX+8)
	CP	32
	JR	Z,_L0332
_L0330:
; 1818.	        if (dir[8] != ' ') {        /* Copy name extension */
	EXX
	PUSH	BC
	INC	BC
	EXX
	POP	HL
	LD	(HL),46
; 1819.	            *p++ = '.';
	EXX
	LD	DE,8
_L1038:
	EXX
_L0333:
	LD	BC,11
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0332
_L0334:
; 1820.	            for (i = 8; i < 11; i++) {
	EXX
	PUSH	DE
	EXX
	POP	HL
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	B,(HL)
	LD	HL,0
	ADD	HL,SP
	LD	(HL),B
; 1821.	                c = dir[i];
	LD	A,B
	CP	32
	JR	Z,_L0332
_L0336:
_L0337:
; 1822.	                if (c == ' ') break;
	XOR	A
	JR	Z,_L0339
	INC	HL
	BIT	4,(HL)
	JR	Z,_L0339
	LD	A,B
	CP	65
	JR	C,_L0339
	LD	A,90
	CP	B
	JR	C,_L0339
_L0343:
_L0342:
_L0341:
_L0340:
_L0338:
	DEC	HL
	LD	A,B
	ADD	A,32
	LD	(HL),A
_L0339:
; 1823.	                if (_USE_LFN && (nt & NS_EXT) && IsUpper(c)) c += 0x20;
; 1824.	#if _LFN_UNICODE
; 1829.	#endif
	EXX
	PUSH	BC
	INC	BC
	EXX
	LD	HL,2
	ADD	HL,SP
	LD	B,(HL)
	POP	HL
	LD	(HL),B
	EXX
	INC	DE
	JR	_L1038
; 1830.	                *p++ = c;
; 1831.	            }
_L0332:
_L0331:
; 1832.	        }
	LD	B,(IX+11)
	LD	(IY+8),B
; 1833.	        fno->fattrib = dir[DIR_Attr];               /* Attribute */
	LD	C,(IX+30)
	LD	B,(IX+31)
	LD	L,(IX+28)
	LD	H,(IX+29)
	PUSH	HL
	PUSH	IY
	POP	DE
	EX	DE,HL
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 1834.	        fno->fsize = LD_DWORD(dir+DIR_FileSize);    /* Size */
	LD	L,(IX+24)
	LD	(IY+4),L
	LD	H,(IX+25)
	LD	(IY+5),H
; 1835.	        fno->fdate = LD_WORD(dir+DIR_WrtDate);      /* Date */
	LD	L,(IX+22)
	LD	(IY+6),L
	LD	H,(IX+23)
	LD	(IY+7),H
_L0315:
; 1836.	        fno->ftime = LD_WORD(dir+DIR_WrtTime);      /* Time */
; 1837.	    }
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	(HL),0
; 1838.	    *p = 0;     /* Terminate SFN str by a \0 */
; 1839.	
; 1840.	#if _USE_LFN
; 1849.	#if !_LFN_UNICODE
; 1854.	#endif
; 1861.	#endif
	POP	HL
	POP	HL
	EXX
	POP	DE
	POP	BC
	EXX
	POP	IX
	POP	IY
	RET
; 1862.	}
; 1863.	#endif /* _FS_MINIMIZE <= 1 */
; 1864.	
; 1865.	
; 1866.	
; 1867.	
; 1868.	/*-----------------------------------------------------------------------*/
; 1869.	/* Follow a file path                                                    */
; 1870.	/*-----------------------------------------------------------------------*/
; 1871.	
; 1872.	static
; 1873.	FRESULT follow_path (   /* FR_OK(0): successful, !=0: error code */
; 1874.	    DIR *dj,            /* Directory object to return last directory and found object */
; 1875.	    const TCHAR *path   /* Full-path string to find a file or directory */
; 1876.	)
follow_path:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
	EXX
	PUSH	BC
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 1877.	{
; 1878.	    FRESULT res;
; 1879.	    BYTE *dir, ns;
; 1880.	
; 1881.	
; 1882.	#if _FS_RPATH
	LD	A,(BC)
	CP	47
	JR	Z,_L0346
	LD	L,C
	LD	H,B
	LD	A,(HL)
	CP	92
	JR	NZ,_L0345
_L0346:
_L0347:
_L0344:
; 1883.	    if (*path == '/' || *path == '\\') { /* There is a heading separator */
	INC	(IX+4)
	JR	NZ,_L1040
	INC	(IX+5)
_L1040:
	XOR	A
	LD	(IY+6),A
	LD	(IY+7),A
	LD	(IY+8),A
	LD	(IY+9),A
; 1884.	        path++; dj->sclust = 0;     /* Strip it and start from the root dir */
	JR	_L0348
_L0345:
; 1885.	    } else {                            /* No heading separator */
	LD	HL,drv_calls+34
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IY+6),L
	LD	(IY+7),H
	LD	(IY+8),C
	LD	(IY+9),B
_L0348:
; 1886.	        dj->sclust = drv_calls.curr_dir; //dj->fs->cdir;    /* Start from the current dir */
; 1887.	    }
; 1888.	#else
; 1892.	#endif
; 1893.	
	LD	L,(IX+4)
	LD	H,(IX+5)
	LD	A,(HL)
	CP	32
	JR	NC,_L0350
_L0349:
; 1894.	    if ((UINT)*path < ' ') {            /* Nul path means the start directory itself */
	LD	BC,0
	PUSH	IY
	POP	DE
	CALL	dir_sdi
	LD	(IX-2),A
; 1895.	        res = dir_sdi(dj, 0);
	XOR	A
	LD	(IY+18),A
	LD	(IY+19),A
; 1896.	        dj->dir = 0;
; 1897.	
	JP	_L0352
_L0350:
_L0353:
; 1898.	    } else {                            /* Follow path */
; 1899.	        for (;;) {
	LD	HL,10
	ADD	HL,SP
	LD	C,L
	LD	B,H
	PUSH	IY
	POP	DE
	CALL	create_name
	LD	(IX-2),A
; 1900.	            res = create_name(dj, &path);   /* Get a segment */
	OR	A
	JR	NZ,_L0352
_L0354:
_L0355:
; 1901.	            if (res != FR_OK) break;
	PUSH	IY
	POP	DE
	CALL	dir_find
	LD	(IX-2),A
; 1902.	            res = dir_find(dj);             /* Find it */
	LD	L,(IY+20)
	LD	H,(IY+21)
	LD	BC,11
	ADD	HL,BC
	LD	B,(HL)
; 1903.	            ns = *(dj->fn+NS);
	OR	A
	JR	Z,_L0357
_L0356:
; 1904.	            if (res != FR_OK) {             /* Failed to find the object */
	CP	4
	JR	NZ,_L0352
_L0358:
_L0359:
; 1905.	                if (res != FR_NO_FILE) break;   /* Abort if any hard error occured */
; 1906.	                /* Object not found */
	BIT	5,B
	JR	Z,_L0361
_L0363:
_L0362:
_L0360:
; 1907.	                if (_FS_RPATH && (ns & NS_DOT)) {   /* If dot entry is not exit */
	XOR	A
	LD	(IY+6),A
	LD	(IY+7),A
	LD	(IY+8),A
	LD	(IY+9),A
	LD	(IY+18),A
	LD	(IY+19),A
; 1908.	                    dj->sclust = 0; dj->dir = 0;    /* It is the root dir */
	LD	(IX-2),A
; 1909.	                    res = FR_OK;
	BIT	2,B
	JR	NZ,_L0352
_L0364:
	JR	_L0350
_L0365:
; 1910.	                    if (!(ns & NS_LAST)) continue;
_L0361:
; 1911.	                } else {                            /* Could not find the object */
	BIT	2,B
	JR	NZ,_L0352
_L0367:
	JR	_L1042
_L0368:
_L0366:
; 1912.	                    if (!(ns & NS_LAST)) res = FR_NO_PATH;
; 1913.	                }
_L0357:
; 1914.	                break;
; 1915.	            }
	BIT	2,B
	JR	NZ,_L0352
_L0369:
_L0370:
; 1916.	            if (ns & NS_LAST) break;            /* Last segment match. Function completed. */
	EXX
	LD	C,(IY+18)
	LD	B,(IY+19)
	EXX
; 1917.	            dir = dj->dir;                      /* There is next segment. Follow the sub directory */
	LD	L,C
	LD	H,A
	EXX
	PUSH	BC
	EXX
	POP	BC
	ADD	HL,BC
	BIT	4,(HL)
	JR	NZ,_L0372
_L0371:
; 1918.	            if (!(dir[DIR_Attr] & AM_DIR)) {    /* Cannot follow because it is a file */
_L1042:
	LD	(IX-2),5
	JR	_L0352
_L0372:
; 1919.	                res = FR_NO_PATH; break;
; 1920.	            }
	EXX
	PUSH	BC
	EXX
	POP	DE
	CALL	LD_CLUST
	LD	(IY+6),L
	LD	(IY+7),H
	LD	(IY+8),C
	LD	(IY+9),B
; 1921.	            dj->sclust = LD_CLUST(dir);
; 1922.	        }
	JP	_L0350
_L0352:
_L0351:
; 1923.	    }
; 1924.	
	LD	A,(IX-2)
; 1925.	    return res;
	JP	_L0190
_L1170:
	LD	DE,djo
	CALL	dir_sdi
	LD	(IX-2),A
	OR	A
	RET
; 1926.	}
; 1927.	
; 1928.	
; 1929.	
; 1930.	
; 1931.	/*-----------------------------------------------------------------------*/
; 1932.	/* Load boot record and check if it is an FAT boot record                */
; 1933.	/*-----------------------------------------------------------------------*/
; 1934.	
; 1935.	static
; 1936.	BYTE check_fs ( /* 0:The FAT BR, 1:Valid BR but not an FAT, 2:Not a BR, 3:Disk error */
; 1937.	    FATFS *fs,  /* File system object */
; 1938.	    DWORD sect  /* Sector# (lba) to check if it is an FAT boot record or not */
; 1939.	)
check_fs:
	PUSH	BC
	PUSH	IX
	PUSH	DE
	POP	IX
	EX	DE,HL
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,6
	ADD	HL,SP
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 1940.	{       SET_DIO_PAR(fs->drv, fs->win, sect,1);
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JR	Z,_L0374
_L0373:
; 1941.	    if (drv_calls.read_to_buf() != RES_OK)  /* Load boot record */
	LD	A,3
; 1942.	        return 3;
	JR	_L0381
_L0374:
	LD	HL,561
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	BC,43605
	AND	A
	SBC	HL,BC
	JR	Z,_L0376
_L0375:
; 1943.	    if (LD_WORD(&fs->win[BS_55AA]) != 0xAA55)       /* Check record signature (always placed at offset 510 even if the sector size is >512) */
	LD	A,2
; 1944.	        return 2;
; 1945.	
	JR	_L0381
_L0376:
	LD	E,(IX+107)
	LD	L,(IX+105)
	LD	H,(IX+106)
	LD	D,A
	LD	BC,16710
	AND	A
	SBC	HL,BC
	JR	NZ,_L0378
	EX	DE,HL
	LD	BC,84
	SBC	HL,BC
	JR	Z,_L0381
_L0377:
; 1946.	    if ((LD_DWORD(&fs->win[BS_FilSysType]) & 0xFFFFFF) == 0x544146) /* Check "FAT" string */
; 1947.	        return 0;
_L0378:
	LD	HL,133
	PUSH	IX
	POP	BC
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	LD	L,C
	LD	H,B
	LD	D,A
	LD	BC,16710
	AND	A
	SBC	HL,BC
	JR	NZ,_L0380
	EX	DE,HL
	LD	BC,84
	SBC	HL,BC
	JR	Z,_L0381
_L0379:
; 1948.	    if ((LD_DWORD(&fs->win[BS_FilSysType32]) & 0xFFFFFF) == 0x544146)
; 1949.	        return 0;
; 1950.	
_L0380:
	LD	A,1
; 1951.	    return 1;
_L0381:
	POP	IX
	POP	BC
	RET
; 1952.	}
; 1953.	
; 1954.	
; 1955.	
; 1956.	
; 1957.	/*-----------------------------------------------------------------------*/
; 1958.	/* Check if the file system object is valid or not                       */
; 1959.	/*-----------------------------------------------------------------------*/
; 1960.	
; 1961.	static
; 1962.	FRESULT chk_mounted (   /* FR_OK(0): successful, !=0: any error occurred */
; 1963.	    //const TCHAR **path,   /* Pointer to pointer to the path name (drive number) */
; 1964.	    FATFS **rfs,        /* Pointer to pointer to the found file system object */
; 1965.	    BYTE chk_wp         /* !=0: Check media write protection for write access */
; 1966.	)
chk_mounted:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-28
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	EXX
; 1967.	{
; 1968.	    BYTE fmt, b, *tbl;
; 1969.	    //UINT vol;
; 1970.	    DSTATUS stat;
; 1971.	    DWORD bsect, fasize, tsect, sysect, nclst, szbfat;
; 1972.	    WORD nrsv;
; 1973.	    //const TCHAR *p = *path;
; 1974.	    FATFS *fs;
; 1975.	        
	LD	IY,(drv_calls+32)
	PUSH	IY
	LD	L,(IX+2)
	LD	H,(IX+3)
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
; 1976.	    *rfs = fs = drv_calls.curr_fatfs;               /* Return pointer to the corresponding file system object */
	LD	A,IYL
	OR	IYH
	JR	NZ,_L0383
_L0382:
	LD	A,12
; 1977.	    if (!fs) return FR_NOT_ENABLED;     /* Is the file system object available? */
; 1978.	
	JP	_L0455
_L0383:
; 1979.	    ENTER_FF(fs);                       /* Lock file system */
; 1980.	
	XOR	A
	OR	(IY+0)
	JR	Z,_L0387
_L0384:
; 1981.	    if (fs->fs_type) {                  /* If the logical drive has been mounted */
	LD	E,(IY+1)
	LD	HL,(drv_calls+2)
	CALL	clib_CALL_IND_L09
	LD	(IX-2),A
; 1982.	        stat = disk_status(fs->drv);
	BIT	0,A
	JR	NZ,_L0387
_L0386:
; 1983.	        if (!(stat & STA_NOINIT)) {     /* and the physical drive is kept initialized (has not been changed), */
; 1984.	#if !_FS_READONLY
	XOR	A
	OR	C
	JR	Z,_L0389
	BIT	2,(IX-2)
	JR	NZ,_L1047
_L0391:
_L0390:
_L0388:
; 1985.	            if (chk_wp && (stat & STA_PROTECT)) /* Check write protection if needed */
; 1986.	                return FR_WRITE_PROTECTED;
; 1987.	#endif
_L0389:
	JP	_L1046
; 1988.	            return FR_OK;               /* The file system object is valid */
_L0387:
_L0385:
; 1989.	        }
; 1990.	    }
	LD	(IY+0),0
; 1991.	    fs->fs_type=0;
; 1992.	
; 1993.	    /* The logical drive must be mounted. */
; 1994.	    /* Following code attempts to mount a volume. (analyze BPB and initialize the fs object) */
; 1995.	
; 1996.	    //fs->fs_type = 0;                  /* Clear the file system object */
; 1997.	    //Dimkam fs->drv = (BYTE)LD2PD(vol);            /* Bind the logical drive and a physical drive */
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	E,(IY+1)
	LD	HL,(drv_calls)
	CALL	clib_CALL_IND_L09
	LD	(IX-2),A
; 1998.	    stat = disk_initialize(fs->drv,fs->win);    /* Initialize low level disk I/O layer */
	BIT	0,A
	JR	Z,_L0393
_L0392:
; 1999.	    if (stat & STA_NOINIT)              /* Check if the initialization succeeded */
	LD	A,3
; 2000.	        return FR_NOT_READY;            /* Failed to initialize due to no media or hard error */
; 2001.	#if _MAX_SS != 512                      /* Get disk sector size (variable sector size cfg only) */
; 2004.	#endif
; 2005.	#if !_FS_READONLY
	JP	_L0455
_L0393:
	XOR	A
	OR	(IX+4)
	JR	Z,_L0395
	BIT	2,(IX-2)
	JR	Z,_L0395
_L0397:
_L0396:
_L0394:
; 2006.	    if (chk_wp && (stat & STA_PROTECT)) /* Check disk write protection if needed */
_L1047:
	LD	A,10
; 2007.	        return FR_WRITE_PROTECTED;
; 2008.	#endif
; 2009.	    /* Search FAT partition on the drive. Supports only generic partitionings, FDISK and SFD. */
	JP	_L0455
_L0395:
	XOR	A
	LD	(IX-22),A
	LD	(IX-21),A
	LD	(IX-20),A
	LD	(IX-19),A
	LD	L,A
	LD	H,A
	PUSH	HL
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	check_fs
	POP	HL
	POP	HL
	LD	(IX-28),A
; 2010.	    fmt = check_fs(fs, bsect = 0);      /* Check sector 0 if it is a VBR */
	DEC	A
	JR	NZ,_L0399
_L0398:
; 2011.	    if (fmt == 1) {                     /* Not an FAT-VBR, the disk may be partitioned */
; 2012.	        /* Check the partition listed in top of the partition table */
; 2013.	        //DimkaM tbl = &fs->win[MBR_Table + LD2PT(vol) * SZ_PTE];/* Partition table */
; 2014.	        
	LD	L,(IY+2)
	LD	H,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,497
	ADD	HL,BC
	PUSH	HL
	EXX
	POP	BC
	EXX
; 2015.	        tbl = &fs->win[MBR_Table + (fs->part) * SZ_PTE];/* Partition table */
	LD	BC,4
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	Z,_L0404
_L0400:
; 2016.	        if (tbl[4]) {                                   /* Is the partition existing? */
	LD	HL,8
	EXX
	PUSH	BC
	EXX
	POP	BC
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IX-22),L
	LD	(IX-21),H
	LD	(IX-20),C
	LD	(IX-19),B
; 2017.	            bsect = LD_DWORD(&tbl[8]);                  /* Partition offset in LBA */
	PUSH	BC
	PUSH	HL
	PUSH	IY
	POP	DE
	CALL	check_fs
	POP	HL
	POP	HL
	LD	(IX-28),A
_L0401:
; 2018.	            fmt = check_fs(fs, bsect);                  /* Check the partition */
; 2019.	        }
	JR	_L0404
_L0399:
	XOR	A
	OR	(IX-28)
	JR	NZ,_L0404
	LD	A,(IY+2)
	OR	A
	JR	Z,_L0404
_L0406:
_L0405:
_L0403:
; 2020.	    }else if((!fmt) && fs->part){
	LD	A,19
; 2021.	        return FR_NO_MBR;
	JP	_L0455
_L0404:
_L0402:
; 2022.	    }
	LD	A,(IX-28)
	CP	3
	JR	NZ,_L0408
_L0407:
	LD	A,1
; 2023.	    if (fmt == 3) return FR_DISK_ERR;
	JP	_L0455
_L0408:
	XOR	A
	OR	(IX-28)
	JR	NZ,_L1049
_L0409:
; 2024.	    if (fmt) return FR_NO_FILESYSTEM;                   /* No FAT volume is found */
; 2025.	
; 2026.	    /* Following code initializes the file system object */
; 2027.	
_L0410:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,11
	ADD	HL,BC
	LD	A,2
	INC	HL
	XOR	(HL)
	DEC	HL
	OR	(HL)
	JR	NZ,_L1049
_L0411:
; 2028.	    if (LD_WORD(fs->win+BPB_BytsPerSec) != SS(fs))      /* (BPB_BytsPerSec must be equal to the physical sector size) */
; 2029.	        return FR_NO_FILESYSTEM;
; 2030.	
_L0412:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,22
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	(IX-26),L
	LD	C,A
	LD	B,A
	LD	(IX-25),H
	LD	(IX-24),C
	LD	(IX-23),B
; 2031.	    fasize = LD_WORD(fs->win+BPB_FATSz16);              /* Number of sectors per FAT */
	LD	A,L
	OR	H
	JR	NZ,_L0414
_L0413:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,36
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IX-26),L
	LD	(IX-25),H
	LD	(IX-24),C
	LD	(IX-23),B
_L0414:
; 2032.	    if (!fasize) fasize = LD_DWORD(fs->win+BPB_FATSz32);
	LD	(IY+31),L
	LD	(IY+32),H
	LD	(IY+33),C
	LD	(IY+34),B
; 2033.	    fs->fsize = fasize;
; 2034.	
	LD	B,(IY+67)
	LD	(IX-27),B
	LD	(IY+4),B
; 2035.	    fs->n_fats = b = fs->win[BPB_NumFATs];              /* Number of FAT copies */
	DEC	B
	JR	Z,_L0416
	LD	B,(IX-27)
	DEC	B
	DEC	B
	JR	Z,_L0416
_L0418:
_L0417:
_L0415:
_L1049:
	JR	_L1051
; 2036.	    if (b != 1 && b != 2) return FR_NO_FILESYSTEM;      /* (Must be 1 or 2) */
_L0416:
	LD	HL,8
	ADD	HL,SP
	LD	E,(IX-27)
	LD	C,B
	LD	D,C
	CALL	clib_L_MULASG_L03
; 2037.	    fasize *= b;                                        /* Number of sectors for FAT area */
; 2038.	
	LD	B,(IY+64)
	LD	(IY+3),B
; 2039.	    fs->csize = b = fs->win[BPB_SecPerClus];            /* Number of sectors per cluster */
	XOR	A
	OR	B
	JR	Z,_L1052
	ADD	A,255
	AND	B
	JR	NZ,_L1052
_L0421:
_L0422:
_L0419:
; 2040.	    if (!b || (b & (b - 1))) return FR_NO_FILESYSTEM;   /* (Must be power of 2) */
; 2041.	
_L0420:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,17
	ADD	HL,DE
	LD	D,(HL)
	LD	(IY+9),D
	INC	HL
	LD	H,(HL)
	LD	(IY+10),H
; 2042.	    fs->n_rootdir = LD_WORD(fs->win+BPB_RootEntCnt);    /* Number of root directory entries */
	LD	HL,9
	ADD	HL,BC
	LD	A,(HL)
	AND	15
	JR	Z,_L0424
_L0423:
_L1051:
	JR	_L1052
; 2043.	    if (fs->n_rootdir % (SS(fs) / SZ_DIR)) return FR_NO_FILESYSTEM; /* (BPB_RootEntCnt must be sector aligned) */
; 2044.	
_L0424:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,19
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	(IX-14),L
	LD	C,A
	LD	B,A
	LD	(IX-13),H
	LD	(IX-12),C
	LD	(IX-11),B
; 2045.	    tsect = LD_WORD(fs->win+BPB_TotSec16);              /* Number of sectors on the volume */
	LD	A,L
	OR	H
	JR	NZ,_L0426
_L0425:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,32
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IX-14),L
	LD	(IX-13),H
	LD	(IX-12),C
	LD	(IX-11),B
_L0426:
; 2046.	    if (!tsect) tsect = LD_DWORD(fs->win+BPB_TotSec32);
; 2047.	
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,14
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	PUSH	HL
	EXX
	POP	DE
	EXX
; 2048.	    nrsv = LD_WORD(fs->win+BPB_RsvdSecCnt);             /* Number of reserved sectors */
	LD	A,L
	OR	H
	JR	NZ,_L0428
_L0427:
_L1052:
	JR	_L1053
; 2049.	    if (!nrsv) return FR_NO_FILESYSTEM;                 /* (BPB_RsvdSecCnt must not be 0) */
; 2050.	
; 2051.	    /* Determine the FAT sub type */
_L0428:
	LD	E,(IY+9)
	LD	D,(IY+10)
	LD	B,4
	CALL	clib_US_RSH_L02
	ADD	HL,DE
	LD	BC,0
	PUSH	BC
	PUSH	HL
	LD	L,(IX-26)
	LD	H,(IX-25)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-24)
	LD	H,(IX-23)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IX-10),L
	LD	(IX-9),H
	LD	(IX-8),C
	LD	(IX-7),B
; 2052.	    sysect = nrsv + fasize + fs->n_rootdir / (SS(fs) / SZ_DIR); /* RSV+FAT+DIR */
	PUSH	BC
	PUSH	HL
	AND	A
	LD	L,(IX-14)
	LD	H,(IX-13)
	POP	BC
	SBC	HL,BC
	LD	L,(IX-12)
	LD	H,(IX-11)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0430
_L0429:
_L1053:
	JR	_L1054
; 2053.	    if (tsect < sysect) return FR_NO_FILESYSTEM;        /* (Invalid volume size) */
_L0430:
	LD	L,(IY+3)
	LD	BC,0
	LD	H,C
	PUSH	BC
	PUSH	HL
	LD	L,(IX-14)
	LD	H,(IX-13)
	LD	C,(IX-10)
	LD	B,(IX-9)
	SBC	HL,BC
	EX	DE,HL
	LD	L,(IX-12)
	LD	H,(IX-11)
	LD	C,(IX-8)
	LD	B,(IX-7)
	SBC	HL,BC
	CALL	_L1175
	LD	(IX-18),L
	LD	(IX-17),H
	LD	(IX-16),C
	LD	(IX-15),B
; 2054.	    nclst = (tsect - sysect) / fs->csize;               /* Number of clusters */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0432
_L0431:
_L1054:
	JP	_L1057
; 2055.	    if (!nclst) return FR_NO_FILESYSTEM;                /* (Invalid volume size) */
_L0432:
	LD	(IX-28),1
; 2056.	    fmt = FS_FAT12;
	LD	BC,4086
	SBC	HL,BC
	LD	L,(IX-16)
	LD	H,(IX-15)
	LD	BC,0
	SBC	HL,BC
	JR	C,_L0434
_L0433:
	LD	(IX-28),2
_L0434:
; 2057.	    if (nclst >= MIN_FAT16) fmt = FS_FAT16;
	AND	A
	LD	L,(IX-18)
	LD	H,(IX-17)
	LD	BC,65526
	SBC	HL,BC
	LD	L,(IX-16)
	LD	H,(IX-15)
	LD	BC,0
	SBC	HL,BC
	JR	C,_L0436
_L0435:
	LD	(IX-28),3
_L0436:
; 2058.	    if (nclst >= MIN_FAT32) fmt = FS_FAT32;
; 2059.	
; 2060.	    /* Boundaries and Limits */
	LD	L,C
	LD	H,B
	PUSH	BC
	INC	HL
	INC	HL
	PUSH	HL
	LD	L,(IX-18)
	LD	H,(IX-17)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-16)
	LD	H,(IX-15)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+27),L
	LD	(IY+28),H
	LD	(IY+29),C
	LD	(IY+30),B
; 2061.	    fs->n_fatent = nclst + 2;                           /* Number of FAT entries */
	LD	L,(IX-8)
	LD	H,(IX-7)
	PUSH	HL
	LD	L,(IX-10)
	LD	H,(IX-9)
	PUSH	HL
	LD	L,(IX-22)
	LD	H,(IX-21)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-20)
	LD	H,(IX-19)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+43),L
	LD	(IY+44),H
	LD	(IY+45),C
	LD	(IY+46),B
; 2062.	    fs->database = bsect + sysect;                      /* Data start sector */
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	BC,0
	PUSH	BC
	PUSH	HL
	LD	L,(IX-22)
	LD	H,(IX-21)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-20)
	LD	H,(IX-19)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+35),L
	LD	(IY+36),H
	LD	(IY+37),C
	LD	(IY+38),B
; 2063.	    fs->fatbase = bsect + nrsv;                         /* FAT start sector */
	LD	A,(IX-28)
	CP	3
	LD	A,(IY+9)
	JR	NZ,_L0438
_L0437:
; 2064.	    if (fmt == FS_FAT32) {
	OR	(IY+10)
	JR	NZ,_L1056
_L0439:
; 2065.	        if (fs->n_rootdir) return FR_NO_FILESYSTEM;     /* (BPB_RootEntCnt must be 0) */
_L0440:
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,44
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(IY+39),C
	LD	(IY+40),B
	LD	(IY+41),E
	LD	(IY+42),D
; 2066.	        fs->dirbase = LD_DWORD(fs->win+BPB_RootClus);   /* Root directory start cluster */
	LD	C,(IY+29)
	LD	B,(IY+30)
	LD	L,(IY+27)
	LD	H,(IY+28)
	LD	A,2
	CALL	clib_L_LSH_L03
	JP	_L0446
; 2067.	        szbfat = fs->n_fatent * 4;                      /* (Required FAT size) */
_L0438:
; 2068.	    } else {
	OR	(IY+10)
	JR	NZ,_L0443
_L0442:
_L1056:
	JP	_L1057
; 2069.	        if (!fs->n_rootdir) return FR_NO_FILESYSTEM;    /* (BPB_RootEntCnt must not be 0) */
_L0443:
	LD	L,(IY+37)
	LD	H,(IY+38)
	PUSH	HL
	LD	L,(IY+35)
	LD	H,(IY+36)
	PUSH	HL
	LD	L,(IX-26)
	LD	H,(IX-25)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-24)
	LD	H,(IX-23)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+39),L
	LD	(IY+40),H
	LD	(IY+41),C
	LD	(IY+42),B
; 2070.	        fs->dirbase = fs->fatbase + fasize;             /* Root directory start sector */
; 2071.	        szbfat = (fmt == FS_FAT16) ?                    /* (Required FAT size) */
	LD	B,(IX-28)
	DEC	B
	DEC	B
	JR	NZ,_L0445
	LD	C,(IY+29)
	LD	B,(IY+30)
	LD	L,(IY+27)
	LD	H,(IY+28)
	ADD	HL,HL
	RL	C
	RL	B
	JR	_L0446
_L0445:
	LD	L,(IY+29)
	LD	H,(IY+30)
	PUSH	HL
	LD	L,(IY+27)
	LD	H,(IY+28)
	PUSH	HL
	LD	BC,0
	LD	HL,3
	CALL	clib_L_MUL_L03
	LD	A,1
	CALL	clib_UL_RSH_L03
	PUSH	BC
	PUSH	HL
	LD	A,(IY+27)
	AND	1
	LD	L,A
	LD	H,0
	LD	E,H
	LD	D,E
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
_L0446:
	LD	(IX-6),L
	LD	(IX-5),H
	LD	(IX-4),C
	LD	(IX-3),B
_L0441:
; 2072.	            fs->n_fatent * 2 : fs->n_fatent * 3 / 2 + (fs->n_fatent & 1);
; 2073.	    }
	LD	HL,0
	PUSH	HL
	LD	HL,511
	PUSH	HL
	LD	L,(IX-6)
	LD	H,(IX-5)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-4)
	LD	H,(IX-3)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	A,9
	CALL	clib_UL_RSH_L03
	PUSH	BC
	PUSH	HL
	AND	A
	LD	L,(IY+31)
	LD	H,(IY+32)
	POP	BC
	SBC	HL,BC
	LD	L,(IY+33)
	LD	H,(IY+34)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0448
_L0447:
; 2074.	    if (fs->fsize < (szbfat + (SS(fs) - 1)) / SS(fs))   /* (BPB_FATSz must not be less than required) */
_L1057:
	LD	A,13
; 2075.	        return FR_NO_FILESYSTEM;
; 2076.	
; 2077.	#if !_FS_READONLY
; 2078.	    /* Initialize cluster allocation information */
	JP	_L0455
_L0448:
	LD	B,255
	LD	(IY+15),B
	LD	(IY+16),B
	LD	(IY+17),B
	LD	(IY+18),B
; 2079.	    fs->free_clust = 0xFFFFFFFF;
	XOR	A
	LD	(IY+11),A
	LD	(IY+12),A
	LD	(IY+13),A
	LD	(IY+14),A
; 2080.	    fs->last_clust = 0;
; 2081.	
; 2082.	    /* Get fsinfo if available */
	LD	A,(IX-28)
	CP	3
	JP	NZ,_L0452
_L0449:
; 2083.	    if (fmt == FS_FAT32) {
	LD	(IY+6),0
; 2084.	        fs->fsi_flag = 0;
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,48
	ADD	HL,DE
	LD	D,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,D
	LD	BC,0
	PUSH	BC
	PUSH	HL
	LD	L,(IX-22)
	LD	H,(IX-21)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX-20)
	LD	H,(IX-19)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(IY+19),L
	LD	(IY+20),H
	LD	(IY+21),C
	LD	(IY+22),B
; 2085.	        fs->fsi_sector = bsect + LD_WORD(fs->win+BPB_FSInfo);
	LD	A,(IY+1)
	LD	(drv_calls+26),A
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,19
	ADD	HL,BC
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 2086.	        SET_DIO_PAR(fs->drv, fs->win, fs->fsi_sector,1);
; 2087.	        if (drv_calls.read_to_buf() == RES_OK &&
; 2088.	            LD_WORD(fs->win+BS_55AA) == 0xAA55 &&
; 2089.	            LD_DWORD(fs->win+FSI_LeadSig) == 0x41615252 &&
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JP	NZ,_L0452
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,510
	ADD	HL,BC
	LD	B,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,B
	LD	BC,43605
	AND	A
	SBC	HL,BC
	JR	NZ,_L0452
	LD	L,(IY+51)
	LD	H,(IY+52)
	LD	BC,21074
	AND	A
	SBC	HL,BC
	JR	NZ,_L0452
	LD	L,(IY+53)
	LD	H,(IY+54)
	LD	BC,16737
	SBC	HL,BC
	JR	NZ,_L0452
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,484
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	L,C
	LD	H,B
	LD	BC,29298
	AND	A
	SBC	HL,BC
	JR	NZ,_L0452
	EX	DE,HL
	LD	BC,24897
	SBC	HL,BC
	JR	NZ,_L0452
_L0454:
_L0453:
_L0451:
; 2090.	            LD_DWORD(fs->win+FSI_StrucSig) == 0x61417272) {
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,492
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(IY+11),C
	LD	(IY+12),B
	LD	(IY+13),E
	LD	(IY+14),D
; 2091.	                fs->last_clust = LD_DWORD(fs->win+FSI_Nxt_Free);
	LD	HL,51
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,488
	ADD	HL,DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(IY+15),C
	LD	(IY+16),B
	LD	(IY+17),E
	LD	(IY+18),D
_L0452:
_L0450:
; 2092.	                fs->free_clust = LD_DWORD(fs->win+FSI_Free_Count);
; 2093.	        }
; 2094.	    }
; 2095.	#endif
	LD	B,(IX-28)
	LD	(IY+0),B
; 2096.	    fs->fs_type = fmt;      /* FAT sub-type */
	LD	HL,(Fsid)
	INC	HL
	LD	(Fsid),HL
	LD	(IY+7),L
	LD	(IY+8),H
; 2097.	    fs->id = ++Fsid;        /* File system mount ID */
	XOR	A
	LD	(IY+47),A
	LD	(IY+48),A
	LD	(IY+49),A
	LD	(IY+50),A
; 2098.	    fs->winsect = 0;        /* Invalidate sector cache */
	LD	(IY+5),A
; 2099.	    fs->wflag = 0;
; 2100.	#if _FS_RPATH
	LD	C,A
	LD	B,A
	LD	(drv_calls+34),BC
	LD	(drv_calls+36),BC
; 2101.	    drv_calls.curr_dir = 0; //fs->cdir = 0;         /* Current directory (root dir) */
; 2102.	#endif
; 2103.	#if _FS_SHARE               /* Clear file lock semaphores */
; 2105.	#endif
; 2106.	
_L1046:
	XOR	A
; 2107.	    return FR_OK;
_L0455:
	JP	_L0154
_L1176:
	ADC	HL,BC
_L1175:
	LD	C,L
	LD	B,H
	EX	DE,HL
	JP	clib_UL_DIV_L03
; 2108.	}
; 2109.	
; 2110.	
; 2111.	
; 2112.	
; 2113.	/*-----------------------------------------------------------------------*/
; 2114.	/* Check if the file/dir object is valid or not                          */
; 2115.	/*-----------------------------------------------------------------------*/
; 2116.	
; 2117.	static
; 2118.	FRESULT validate (  /* FR_OK(0): The object is valid, !=0: Invalid */
; 2119.	    FATFS *fs,      /* Pointer to the file system object */
; 2120.	    WORD id         /* Member id of the target object to be checked */
; 2121.	)
validate:
	PUSH	IX
	PUSH	BC
	PUSH	DE
	POP	IX
; 2122.	{
	LD	A,E
	OR	D
	JR	Z,_L0458
	XOR	A
	OR	(IX+0)
	JR	Z,_L0458
	LD	L,(IX+7)
	LD	H,(IX+8)
	SBC	HL,BC
	JR	Z,_L0457
_L0458:
_L0459:
_L0456:
; 2123.	    if (!fs || !fs->fs_type || fs->id != id)
	LD	A,9
; 2124.	        return FR_INVALID_OBJECT;
; 2125.	
	JR	_L0462
_L0457:
; 2126.	    ENTER_FF(fs);       /* Lock file system */
; 2127.	
	LD	E,(IX+1)
	LD	HL,(drv_calls+2)
	CALL	clib_CALL_IND_L09
	BIT	0,A
	JR	Z,_L0461
_L0460:
; 2128.	    if (disk_status(fs->drv) & STA_NOINIT){
	LD	(IX+0),0
; 2129.	        fs->fs_type=0;
	LD	A,3
; 2130.	        return FR_NOT_READY;
	JR	_L0462
_L0461:
; 2131.	    }
	XOR	A
; 2132.	    return FR_OK;
_L0462:
	POP	HL
	POP	IX
	RET
; 2133.	}
; 2134.	
; 2135.	
; 2136.	
; 2137.	
; 2138.	/*--------------------------------------------------------------------------
; 2139.	
; 2140.	   Public Functions
; 2141.	
; 2142.	--------------------------------------------------------------------------*/
; 2143.	
; 2144.	
; 2145.	const TCHAR nullstring[]="";
; 2146.	static DIR djo, djn;
; 2147.	
; 2148.	/*-----------------------------------------------------------------------*/
; 2149.	/* Mount/Unmount a Logical Drive                                         */
; 2150.	/*-----------------------------------------------------------------------*/
; 2151.	
; 2152.	FRESULT f_mount (
; 2153.	    void
; 2154.	    //BYTE vol,     /* Logical drive number to be mounted/unmounted */
; 2155.	    //FATFS *fs     /* Pointer to new file system object (NULL for unmount)*/
; 2156.	)
f_mount:
	PUSH	BC
	PUSH	DE
	LD	HL,(drv_calls+32)
	LD	(HL),0
; 2157.	{
; 2158.	#if 1==0
; 2167.	#if _FS_SHARE
; 2169.	#endif
; 2170.	#if _FS_REENTRANT                   /* Discard sync object of the current volume */
; 2172.	#endif
; 2178.	#if _FS_REENTRANT                   /* Create sync object for the new volume */
; 2180.	#endif
; 2184.	#else
; 2185.	    //static TCHAR *path;
; 2186.	    //path = (TCHAR *)nullstring;
; 2187.	    drv_calls.curr_fatfs->fs_type = 0;
	LD	C,0
	CALL	_L1177
; 2188.	    return chk_mounted(&djo.fs, 0);
; 2189.	#endif
	POP	DE
	POP	BC
	RET
_L1179:
	LD	C,(IX+2)
	LD	B,(IX+3)
_L1178:
	LD	DE,pathbuf
	LD	HL,(drv_calls+16)
	CALL	clib_CALL_IND_L09
	LD	C,1
_L1177:
	LD	DE,djo
	JP	chk_mounted
; 2190.	}
; 2191.	
; 2192.	/*-----------------------------------------------------------------------*/
; 2193.	/* Open or Create a File                                                 */
; 2194.	/*-----------------------------------------------------------------------*/
; 2195.	
; 2196.	FRESULT f_open (
; 2197.	    FIL *fp,            /* Pointer to the blank file object */
; 2198.	    const TCHAR *path,  /* Pointer to the file name */
; 2199.	    BYTE mode           /* Access mode and file open mode flags */
; 2200.	)
f_open:
	PUSH	IY
	PUSH	IX
	PUSH	BC
	PUSH	DE
	POP	IY
; 2201.	{
; 2202.	    static FRESULT res;
; 2203.	    //DIR dj;
; 2204.	    BYTE *dir;
; 2205.	    DEF_NAMEBUF;
; 2206.	
	CALL	_L1180
; 2207.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 2208.	    
	PUSH	IY
	POP	HL
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
; 2209.	    fp->fs = 0;         /* Clear file object */
; 2210.	
; 2211.	#if !_FS_READONLY
	LD	HL,8
	ADD	HL,SP
	LD	A,(HL)
	AND	31
	LD	(HL),A
; 2212.	    mode &= FA_READ | FA_WRITE | FA_CREATE_ALWAYS | FA_OPEN_ALWAYS | FA_CREATE_NEW;
	LD	B,A
	RES	0,B
	LD	C,B
	CALL	_L1177
	LD	(_L0463),A
; 2213.	    res = chk_mounted(&djo.fs, (BYTE)(mode & ~FA_READ));
; 2214.	#else
; 2217.	#endif
	LD	HL,sfn
	LD	(djo+20),HL
; 2218.	    INIT_BUF(djo);
	OR	A
	JR	NZ,_L0465
_L0464:
; 2219.	    if (res == FR_OK)
	CALL	_L1182
	LD	(_L0463),A
_L0465:
; 2220.	        res = follow_path(&djo, pathbuf);   /* Follow the file path */
	LD	IX,(djo+18)
; 2221.	    dir = djo.dir;
; 2222.	
; 2223.	#if !_FS_READONLY   /* R/W configuration */
	OR	A
	JR	NZ,_L0469
_L0466:
; 2224.	    if (res == FR_OK) {
	LD	A,IXL
	OR	IXH
	JR	NZ,_L0469
_L0468:
; 2225.	        if (!dir)   /* Current dir itself */
	LD	A,6
	LD	(_L0463),A
_L0469:
_L0467:
; 2226.	            res = FR_INVALID_NAME;
; 2227.	#if _FS_SHARE
; 2230.	#endif
; 2231.	    }
; 2232.	    /* Create or Open a file */
	LD	HL,8
	ADD	HL,SP
	LD	A,(HL)
	AND	28
	LD	A,(_L0463)
	JP	Z,_L0471
_L0470:
; 2233.	    if (mode & (FA_CREATE_ALWAYS | FA_OPEN_ALWAYS | FA_CREATE_NEW)) {
; 2234.	        static DWORD dw, cl;
; 2235.	
	OR	A
	JR	Z,_L0475
_L0474:
; 2236.	        if (res != FR_OK) {                 /* No file, create new */
	CP	4
	JR	NZ,_L0477
_L0476:
; 2237.	            if (res == FR_NO_FILE)          /* There is no file to open, create a new entry */
; 2238.	#if _FS_SHARE
; 2240.	#else
	LD	DE,djo
	CALL	dir_register
	LD	(_L0463),A
_L0477:
; 2241.	                res = dir_register(&djo);
; 2242.	#endif
	LD	HL,8
	ADD	HL,SP
	SET	3,(HL)
; 2243.	            mode |= FA_CREATE_ALWAYS;       /* File is created */
	LD	IX,(djo+18)
; 2244.	            dir = djo.dir;                  /* New entry */
; 2245.	        }
	JR	_L0483
_L0475:
; 2246.	        else {                              /* Any object is already existing */
	LD	A,(IX+11)
	AND	17
	JR	Z,_L0480
_L0479:
; 2247.	            if (dir[DIR_Attr] & (AM_RDO | AM_DIR)) {    /* Cannot overwrite it (R/O or DIR) */
	LD	A,7
	JR	_L1060
; 2248.	                res = FR_DENIED;
_L0480:
; 2249.	            } else {
	BIT	2,(HL)
	JR	Z,_L0483
_L0482:
; 2250.	                if (mode & FA_CREATE_NEW)   /* Cannot create as new file */
	LD	A,8
_L1060:
	LD	(_L0463),A
_L0483:
_L0481:
_L0478:
; 2251.	                    res = FR_EXIST;
; 2252.	            }
; 2253.	        }
	LD	A,(_L0463)
	OR	A
	JP	NZ,_L0499
	BIT	3,(HL)
	JP	Z,_L0499
_L0487:
_L0486:
_L0484:
; 2254.	        if (res == FR_OK && (mode & FA_CREATE_ALWAYS)) {    /* Truncate it if overwrite mode */
	LD	DE,_L0472
	LD	HL,(drv_calls+12)
	CALL	clib_CALL_IND_L09
; 2255.	            get_fattime(&dw);                   /* Created time */
	LD	BC,(_L0472+2)
	LD	HL,(_L0472)
	LD	(IX+14),L
	LD	(IX+15),H
	LD	(IX+16),C
	LD	(IX+17),B
; 2256.	            ST_DWORD(dir+DIR_CrtTime, dw);
	LD	(IX+11),0
; 2257.	            dir[DIR_Attr] = 0;                  /* Reset attribute */
	XOR	A
	LD	(IX+28),A
	LD	(IX+29),A
	LD	(IX+30),A
	LD	(IX+31),A
; 2258.	            ST_DWORD(dir+DIR_FileSize, 0);      /* size = 0 */
	PUSH	IX
	POP	DE
	CALL	LD_CLUST
	LD	(_L0473),HL
	LD	(_L0473+2),BC
; 2259.	            cl = LD_CLUST(dir);                 /* Get start cluster */
	XOR	A
	LD	(IX+26),A
	LD	(IX+27),A
	LD	(IX+20),A
	LD	(IX+21),A
; 2260.	            ST_CLUST(dir, 0);                   /* cluster = 0 */
	LD	HL,5
	LD	BC,(djo)
	ADD	HL,BC
	LD	(HL),1
; 2261.	            djo.fs->wflag = 1;
	LD	HL,(_L0473)
	LD	A,L
	OR	H
	LD	HL,(_L0473+2)
	OR	L
	OR	H
	JR	Z,_L0491
_L0488:
; 2262.	            if (cl) {                           /* Remove the cluster chain if exist */
	LD	HL,47
	LD	BC,(djo)
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(_L0472),HL
	LD	(_L0472+2),BC
; 2263.	                dw = djo.fs->winsect;
	LD	HL,(_L0473+2)
	PUSH	HL
	LD	HL,(_L0473)
	PUSH	HL
	CALL	_L1184
	POP	HL
	POP	HL
	LD	(_L0463),A
; 2264.	                res = remove_chain(djo.fs, cl);
	OR	A
	JR	NZ,_L0499
_L0490:
; 2265.	                if (res == FR_OK) {
	LD	HL,11
	LD	BC,(djo)
	ADD	HL,BC
	PUSH	HL
	LD	BC,65535
	PUSH	BC
	PUSH	BC
	LD	HL,(_L0473)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(_L0473+2)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 2266.	                    djo.fs->last_clust = cl - 1;    /* Reuse the cluster hole */
	LD	HL,(_L0472+2)
	PUSH	HL
	LD	HL,(_L0472)
	PUSH	HL
	LD	DE,(djo)
	CALL	move_window
	POP	HL
	POP	HL
	LD	(_L0463),A
_L0491:
_L0489:
_L0485:
; 2267.	                    res = move_window(djo.fs, dw);
; 2268.	                }
; 2269.	            }
; 2270.	        }
; 2271.	    }
	JR	_L0499
_L0471:
; 2272.	    else {  /* Open an existing file */
	OR	A
	JR	NZ,_L0499
_L0493:
; 2273.	        if (res == FR_OK) {                     /* Follow succeeded */
	BIT	4,(IX+11)
	JR	Z,_L0496
_L0495:
; 2274.	            if (dir[DIR_Attr] & AM_DIR) {       /* It is a directory */
	LD	A,4
	JR	_L1061
; 2275.	                res = FR_NO_FILE;
_L0496:
; 2276.	            } else {
	BIT	1,(HL)
	JR	Z,_L0499
	BIT	0,(IX+11)
	JR	Z,_L0499
_L0501:
_L0500:
_L0498:
; 2277.	                if ((mode & FA_WRITE) && (dir[DIR_Attr] & AM_RDO)) /* R/O violation */
	LD	A,7
_L1061:
	LD	(_L0463),A
_L0499:
_L0497:
_L0494:
_L0492:
; 2278.	                    res = FR_DENIED;
; 2279.	            }
; 2280.	        }
; 2281.	    }
	LD	A,(_L0463)
	OR	A
	JR	NZ,_L0503
_L0502:
; 2282.	    if (res == FR_OK) {
	LD	HL,8
	ADD	HL,SP
	BIT	3,(HL)
	JR	Z,_L0505
_L0504:
; 2283.	        if (mode & FA_CREATE_ALWAYS)            /* Set file change flag if created or overwritten */
	SET	5,(HL)
_L0505:
; 2284.	            mode |= FA__WRITTEN;
	LD	HL,47
	LD	BC,(djo)
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(IY+26),L
	LD	(IY+27),H
	LD	(IY+28),C
	LD	(IY+29),B
; 2285.	        fp->dir_sect = djo.fs->winsect;         /* Pointer to the directory entry */
	PUSH	IX
	POP	HL
	LD	(IY+30),L
	LD	(IY+31),H
_L0503:
; 2286.	        fp->dir_ptr = dir;
; 2287.	#if _FS_SHARE
; 2290.	#endif
; 2291.	    }
; 2292.	
; 2293.	#else               /* R/O configuration */
; 2302.	#endif
; 2303.	    FREE_BUF();
; 2304.	
	OR	A
	JR	NZ,_L0507
_L0506:
; 2305.	    if (res == FR_OK) {
	LD	HL,8
	ADD	HL,SP
	LD	B,(HL)
	LD	(IY+4),B
; 2306.	        fp->flag = mode;                    /* File access mode */
	PUSH	IX
	POP	DE
	CALL	LD_CLUST
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
; 2307.	        fp->sclust = LD_CLUST(dir);         /* File start cluster */
	LD	C,(IX+30)
	LD	B,(IX+31)
	LD	L,(IX+28)
	LD	(IY+10),L
	LD	H,(IX+29)
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
; 2308.	        fp->fsize = LD_DWORD(dir+DIR_FileSize); /* File size */
	XOR	A
	LD	(IY+6),A
	LD	(IY+7),A
	LD	(IY+8),A
	LD	(IY+9),A
; 2309.	        fp->fptr = 0;                       /* File pointer */
	LD	(IY+22),A
	LD	(IY+23),A
	LD	(IY+24),A
	LD	(IY+25),A
; 2310.	        fp->dsect = 0;
; 2311.	#if _USE_FASTSEEK
; 2313.	#endif
	LD	HL,(djo)
	PUSH	HL
	PUSH	IY
	POP	HL
	POP	BC
	LD	(HL),C
	INC	HL
	LD	(HL),B
	LD	HL,7
	LD	BC,(djo)
	ADD	HL,BC
	LD	B,(HL)
	LD	(IY+2),B
	INC	HL
	LD	H,(HL)
	LD	(IY+3),H
_L0507:
; 2314.	        fp->fs = djo.fs; fp->id = djo.fs->id;   /* Validate file object */
; 2315.	    }
; 2316.	
	LD	A,(_L0463)
; 2317.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	IX
	POP	IY
	RET
_L1181:
	LD	C,E
	LD	B,D
_L1180:
	LD	DE,pathbuf
	LD	HL,(drv_calls+16)
	JP	clib_CALL_IND_L09
_L1183:
	LD	HL,sfn
	LD	(djo+20),HL
_L1182:
	LD	BC,pathbuf
	LD	DE,djo
	JP	follow_path
_L1184:
	LD	DE,(djo)
	JP	remove_chain
; 2318.	}
; 2319.	
; 2320.	
; 2321.	
; 2322.	
; 2323.	/*-----------------------------------------------------------------------*/
; 2324.	/* Read File                                                             */
; 2325.	/*-----------------------------------------------------------------------*/
; 2326.	
; 2327.	FRESULT f_read (
; 2328.	    FIL *fp,        /* Pointer to the file object */
; 2329.	    void *buff,     /* Pointer to data buffer */
; 2330.	    UINT btr,       /* Number of bytes to read */
; 2331.	    UINT *br        /* Pointer to number of bytes read */
; 2332.	)
f_read:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	LD	E,(IX+8)
	LD	D,(IX+9)
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 2333.	{
; 2334.	    FRESULT res;
; 2335.	    static DWORD clst; 
; 2336.	    static DWORD sect; 
; 2337.	    static DWORD remain;
; 2338.	    UINT rcnt;
; 2339.	    static UINT cc;
; 2340.	    BYTE csect;
; 2341.	    static BYTE * rbuff;
	LD	(_L0512),BC
; 2342.	    rbuff = buff;
; 2343.	
; 2344.	
	LD	L,(IX+10)
	LD	H,(IX+11)
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
; 2345.	    *br = 0;    /* Initialize byte counter */
; 2346.	
	CALL	_L1185
; 2347.	    res = validate(fp->fs, fp->id);             /* Check validity */
	OR	A
	JP	NZ,_L0521
_L0513:
; 2348.	    if (res != FR_OK) LEAVE_FF(fp->fs, res);
_L0514:
	LD	A,(IY+4)
	OR	A
	JP	M,_L1067
_L0515:
; 2349.	    if (fp->flag & FA__ERROR)                   /* Aborted file? */
; 2350.	        LEAVE_FF(fp->fs, FR_INT_ERR);
_L0516:
	BIT	0,(IY+4)
	JR	NZ,_L0518
_L0517:
; 2351.	    if (!(fp->flag & FA_READ))                  /* Check access mode */
	LD	A,7
; 2352.	        LEAVE_FF(fp->fs, FR_DENIED);
	JP	_L0521
_L0518:
	AND	A
	LD	L,(IY+10)
	LD	H,(IY+11)
	LD	C,(IY+6)
	LD	B,(IY+7)
	SBC	HL,BC
	EX	DE,HL
	LD	L,(IY+12)
	LD	H,(IY+13)
	LD	C,(IY+8)
	LD	B,(IY+9)
	SBC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	LD	(_L0510),HL
	LD	(_L0510+2),BC
; 2353.	    remain = fp->fsize - fp->fptr;
	EXX
	PUSH	DE
	EXX
	POP	DE
	LD	BC,0
	PUSH	BC
	PUSH	DE
	AND	A
	POP	BC
	SBC	HL,BC
	LD	HL,(_L0510+2)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0520
_L0519:
	EXX
	LD	DE,(_L0510)
_L1064:
	EXX
_L0520:
_L0522:
; 2354.	    if (btr > remain) btr = (UINT)remain;       /* Truncate btr by remaining bytes */
; 2355.	
	EXX
	LD	A,E
	OR	D
	EXX
	JP	Z,_L0521
_L0523:
; 2357.	        rbuff += rcnt, fp->fptr += rcnt, *br += rcnt, btr -= rcnt) {
	LD	L,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	H,A
	LD	A,L
	OR	H
	JP	NZ,_L0526
_L0525:
; 2358.	        if ((fp->fptr % SS(fp->fs)) == 0) {     /* On the sector boundary? */
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	H,(IY+7)
	LD	A,9
	CALL	clib_UL_RSH_L03
	PUSH	HL
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	ADD	A,255
	POP	HL
	AND	L
	LD	(IX-2),A
; 2359.	            csect = (BYTE)(fp->fptr / SS(fp->fs) & (fp->fs->csize - 1));    /* Sector offset in the cluster */
	JR	NZ,_L0528
_L0527:
; 2360.	            if (!csect) {                       /* On the cluster boundary? */
	LD	A,(IY+6)
	OR	(IY+7)
	OR	(IY+8)
	OR	(IY+9)
	JR	NZ,_L0530
_L0529:
; 2361.	                if (fp->fptr == 0) {            /* On the top of the file? */
	LD	C,(IY+16)
	LD	B,(IY+17)
	LD	L,(IY+14)
	LD	H,(IY+15)
	JR	_L1065
; 2362.	                    clst = fp->sclust;          /* Follow from the origin */
_L0530:
; 2363.	                } else {                        /* Middle or end of the file */
; 2364.	#if _USE_FASTSEEK
; 2368.	#endif
	LD	L,(IY+20)
	LD	H,(IY+21)
	PUSH	HL
	LD	L,(IY+18)
	LD	H,(IY+19)
	PUSH	HL
	CALL	_L1166
	POP	AF
	POP	AF
_L1065:
	LD	(_L0508),HL
	LD	(_L0508+2),BC
_L0531:
; 2369.	                        clst = get_fat(fp->fs, fp->clust);  /* Follow cluster chain on the FAT */
; 2370.	                }
	AND	A
	LD	BC,2
	SBC	HL,BC
	LD	HL,(_L0508+2)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	C,_L1071
_L0532:
_L0533:
; 2371.	                if (clst < 2) ABORT(fp->fs, FR_INT_ERR);
	LD	BC,(_L0508+2)
	LD	HL,(_L0508)
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JP	Z,_L1070
_L0534:
_L0535:
; 2372.	                if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	LD	(IY+18),L
	LD	(IY+19),H
	LD	(IY+20),C
	LD	(IY+21),B
_L0528:
; 2373.	                fp->clust = clst;               /* Update current cluster */
; 2374.	            }
	LD	L,(IY+20)
	LD	H,(IY+21)
	PUSH	HL
	LD	L,(IY+18)
	LD	H,(IY+19)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	LD	(_L0509),HL
	LD	(_L0509+2),BC
; 2375.	            sect = clust2sect(fp->fs, fp->clust);   /* Get current sector */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0537
_L0536:
_L1071:
	SET	7,(IY+4)
_L1067:
	LD	A,2
	JP	_L0521
_L0537:
; 2376.	            if (!sect) ABORT(fp->fs, FR_INT_ERR);
	LD	HL,_L0509
	LD	E,(IX-2)
	LD	BC,0
	LD	D,C
	CALL	clib_L_ADDASG_L03
; 2377.	            sect += csect;
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	clib_US_RSH_L02
	LD	(_L0511),DE
; 2378.	            cc = btr / SS(fp->fs);              /* When remaining bytes >= sector size, */
	LD	A,E
	OR	D
	JP	Z,_L0539
_L0538:
; 2379.	            if (cc) {                           /* Read maximum contiguous sectors directly */
	LD	C,(IX-2)
	LD	B,0
	EX	DE,HL
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,0
	AND	A
	SBC	HL,BC
	JR	NC,_L0541
_L0540:
; 2380.	                if (csect + cc > fp->fs->csize) /* Clip at cluster boundary */
	LD	C,(IX-2)
	LD	B,0
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,B
	AND	A
	SBC	HL,BC
	LD	(_L0511),HL
_L0541:
; 2381.	                    cc = fp->fs->csize - csect;
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,(_L0512)
	LD	(drv_calls+27),HL
	EX	DE,HL
	LD	(drv_calls+29),HL
	LD	A,(_L0511)
	LD	(drv_calls+31),A
; 2382.	                SET_DIO_PAR(fp->fs->drv, rbuff, sect, (BYTE)cc);
	LD	HL,(drv_calls+4)
	CALL	_L1159
	JP	NZ,_L1070
_L0542:
; 2383.	                if (drv_calls.read_to_uspace() != RES_OK)
_L0543:
; 2384.	                    ABORT(fp->fs, FR_DISK_ERR);
; 2385.	#if !_FS_READONLY && _FS_MINIMIZE <= 2          /* Replace one of the read sectors with cached data if it contains a dirty sector */
; 2386.	#if _FS_TINY
; 2389.	#else
	BIT	6,(IY+4)
	JR	Z,_L0547
	LD	HL,(_L0511)
	LD	C,A
	LD	B,A
	PUSH	BC
	PUSH	HL
	AND	A
	LD	L,(IY+22)
	LD	H,(IY+23)
	LD	BC,(_L0509)
	SBC	HL,BC
	EX	DE,HL
	LD	L,(IY+24)
	LD	H,(IY+25)
	LD	BC,(_L0509+2)
	SBC	HL,BC
	EX	DE,HL
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	JR	NC,_L0547
_L0549:
_L0548:
_L0546:
; 2390.	                if ((fp->flag & FA__DIRTY) && fp->dsect - sect < cc)
	LD	HL,512
	PUSH	HL
	LD	HL,32
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	DE,(_L0509)
	LD	L,(IY+22)
	LD	H,(IY+23)
	AND	A
	SBC	HL,DE
	LD	H,L
	LD	L,A
	ADD	HL,HL
	LD	DE,(_L0512)
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(drv_calls+22)
	CALL	clib_CALL_IND_L09
	POP	HL
_L0547:
; 2391.	                    drv_calls.memcpy_buf2usp(rbuff + ((fp->dsect - sect) * SS(fp->fs)), fp->buf, SS(fp->fs));
; 2392.	#endif
; 2393.	#endif
	LD	HL,(_L0511)
	LD	H,L
	LD	L,0
	ADD	HL,HL
	PUSH	HL
	EXX
	POP	BC
	EXX
; 2394.	                rcnt = SS(fp->fs) * cc;         /* Number of bytes transferred */
	JP	_L0524
_L0539:
; 2395.	                continue;
; 2396.	            }
; 2397.	#if !_FS_TINY
	LD	L,(IY+22)
	LD	H,(IY+23)
	LD	BC,(_L0509)
	SBC	HL,BC
	JR	NZ,_L1063
	LD	L,(IY+24)
	LD	H,(IY+25)
	LD	BC,(_L0509+2)
	SBC	HL,BC
	JR	Z,_L0557
_L1063:
_L0550:
; 2398.	            if (fp->dsect != sect) {            /* Load data sector if not in cache */
; 2399.	#if !_FS_READONLY
	BIT	6,(IY+4)
	JR	Z,_L0553
_L0552:
; 2400.	                if (fp->flag & FA__DIRTY) {     /* Write-back dirty sector cache */
; 2401.	                    SET_DIO_PAR(fp->fs->drv, fp->buf, fp->dsect, 1);
	CALL	_L1160
	JR	NZ,_L1070
_L0554:
; 2402.	                    if (drv_calls.write_from_buf() != RES_OK)
_L0555:
; 2403.	                        ABORT(fp->fs, FR_DISK_ERR);
	RES	6,(IY+4)
_L0553:
; 2404.	                    fp->flag &= ~FA__DIRTY;
; 2405.	                }
; 2406.	                
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,32
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,_L0509
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 2407.	                SET_DIO_PAR(fp->fs->drv, fp->buf, sect, 1);
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JR	Z,_L0557
_L0556:
; 2408.	                if (drv_calls.read_to_buf() != RES_OK)  /* Fill sector cache */
_L1070:
	SET	7,(IY+4)
	LD	A,1
	JP	_L0521
_L0557:
_L0551:
; 2409.	                    ABORT(fp->fs, FR_DISK_ERR);
; 2410.	            }
; 2411.	#endif
	LD	BC,(_L0509+2)
	LD	HL,(_L0509)
	LD	(IY+22),L
	LD	(IY+23),H
	LD	(IY+24),C
	LD	(IY+25),B
_L0526:
; 2412.	            fp->dsect = sect;
; 2413.	        }
	LD	C,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	B,A
	LD	HL,512
	SBC	HL,BC
	PUSH	HL
	EXX
	POP	BC
	EXX
; 2414.	        rcnt = SS(fp->fs) - (fp->fptr % SS(fp->fs));    /* Get partial sector data from sector buffer */
	LD	C,L
	LD	B,H
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0559
_L0558:
	EXX
	PUSH	DE
	POP	BC
	EXX
_L0559:
; 2415.	        if (rcnt > btr) rcnt = btr;
; 2416.	#if _FS_TINY
; 2420.	#else
	EXX
	PUSH	BC
	EXX
	LD	L,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	H,A
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,32
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	DE,(_L0512)
	LD	HL,(drv_calls+22)
	CALL	clib_CALL_IND_L09
	POP	HL
_L0524:
; 2356.	    for ( ;  btr;                               /* Repeat until all data read */
	EXX
	PUSH	BC
	EXX
	POP	HL
	LD	BC,(_L0512)
	ADD	HL,BC
	LD	(_L0512),HL
	LD	HL,6
	PUSH	IY
	POP	BC
	ADD	HL,BC
	EXX
	PUSH	BC
	EXX
	POP	DE
	LD	BC,0
	CALL	clib_L_ADDASG_L03
	EXX
	PUSH	BC
	EXX
	POP	BC
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	PUSH	BC
	EXX
	EX	DE,HL
	POP	DE
	AND	A
	SBC	HL,DE
	EX	DE,HL
	JP	_L1064
; 2421.	        drv_calls.memcpy_buf2usp(rbuff, &fp->buf[fp->fptr % SS(fp->fs)], rcnt); /* Pick partial sector */
; 2422.	#endif
; 2423.	    }
; 2424.	
_L0521:
; 2425.	    LEAVE_FF(fp->fs, FR_OK);
_L0560:
	JP	_L0154
_L1186:
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
_L1185:
	LD	C,(IY+2)
	LD	B,(IY+3)
	LD	E,(IY+0)
	LD	D,(IY+1)
	JP	validate
; 2426.	}
; 2427.	
; 2428.	
; 2429.	
; 2430.	
; 2431.	#if !_FS_READONLY
; 2432.	/*-----------------------------------------------------------------------*/
; 2433.	/* Write File                                                            */
; 2434.	/*-----------------------------------------------------------------------*/
; 2435.	
; 2436.	FRESULT f_write (
; 2437.	    FIL *fp,            /* Pointer to the file object */
; 2438.	    const void *buff,   /* Pointer to the data to be written */
; 2439.	    UINT btw,           /* Number of bytes to write */
; 2440.	    UINT *bw            /* Pointer to number of bytes written */
; 2441.	)
f_write:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65528
	PUSH	IY
	EXX
	PUSH	DE
	LD	E,(IX+8)
	LD	D,(IX+9)
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	PUSH	HL
	POP	IY
; 2442.	{
; 2443.	    FRESULT res;
; 2444.	    DWORD clst;
; 2445.	    static DWORD sect;
; 2446.	    static UINT wcnt, cc;
	LD	(IX-4),C
	LD	(IX-3),B
; 2447.	    const BYTE *wbuff = buff;
; 2448.	    BYTE csect;
; 2449.	
; 2450.	
	LD	L,(IX+10)
	LD	H,(IX+11)
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
; 2451.	    *bw = 0;    /* Initialize byte counter */
; 2452.	
	CALL	_L1185
; 2453.	    res = validate(fp->fs, fp->id);         /* Check validity */
	OR	A
	JP	NZ,_L0615
_L0564:
; 2454.	    if (res != FR_OK) LEAVE_FF(fp->fs, res);
_L0565:
	LD	A,(IY+4)
	OR	A
	JP	M,_L1084
_L0566:
; 2455.	    if (fp->flag & FA__ERROR)               /* Aborted file? */
; 2456.	        LEAVE_FF(fp->fs, FR_INT_ERR);
_L0567:
	BIT	1,(IY+4)
	JR	NZ,_L0569
_L0568:
; 2457.	    if (!(fp->flag & FA_WRITE))             /* Check access mode */
	LD	A,7
; 2458.	        LEAVE_FF(fp->fs, FR_DENIED);
	JP	_L0615
_L0569:
	LD	L,(IY+12)
	LD	H,(IY+13)
	PUSH	HL
	LD	L,(IY+10)
	LD	H,(IY+11)
	PUSH	HL
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	DE,0
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	POP	BC
	ADC	HL,BC
	EX	DE,HL
	AND	A
	LD	C,(IY+10)
	LD	B,(IY+11)
	SBC	HL,BC
	EX	DE,HL
	LD	C,(IY+12)
	LD	B,(IY+13)
	SBC	HL,BC
	JR	NC,_L0571
_L0570:
	EXX
	LD	DE,0
_L1082:
	EXX
_L0571:
_L0573:
; 2459.	    if ((DWORD)(fp->fsize + btw) < fp->fsize) btw = 0;  /* File size cannot reach 4GB */
; 2460.	
	EXX
	LD	A,E
	OR	D
	EXX
	JP	Z,_L0572
_L0574:
; 2462.	        wbuff += wcnt, fp->fptr += wcnt, *bw += wcnt, btw -= wcnt) {
	LD	L,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	H,A
	LD	A,L
	OR	H
	JP	NZ,_L0577
_L0576:
; 2463.	        if ((fp->fptr % SS(fp->fs)) == 0) { /* On the sector boundary? */
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	H,(IY+7)
	LD	A,9
	CALL	clib_UL_RSH_L03
	PUSH	HL
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	ADD	A,255
	POP	HL
	AND	L
	LD	(IX-2),A
; 2464.	            csect = (BYTE)(fp->fptr / SS(fp->fs) & (fp->fs->csize - 1));    /* Sector offset in the cluster */
	JR	NZ,_L0579
_L0578:
; 2465.	            if (!csect) {                   /* On the cluster boundary? */
	LD	A,(IY+6)
	OR	(IY+7)
	OR	(IY+8)
	OR	(IY+9)
	JR	NZ,_L0581
_L0580:
; 2466.	                if (fp->fptr == 0) {        /* On the top of the file? */
	LD	C,(IY+16)
	LD	B,(IY+17)
	LD	L,(IY+14)
	LD	H,(IY+15)
; 2467.	                    clst = fp->sclust;      /* Follow from the origin */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0584
_L0582:
; 2468.	                    if (clst == 0)          /* When no cluster is allocated, */
	LD	L,A
	LD	H,A
	PUSH	HL
	PUSH	HL
	CALL	_L1169
	POP	AF
	POP	AF
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
_L0583:
; 2469.	                        fp->sclust = clst = create_chain(fp->fs, 0);    /* Create a new cluster chain */
	JR	_L0584
_L0581:
; 2470.	                } else {                    /* Middle or end of the file */
; 2471.	#if _USE_FASTSEEK
; 2475.	#endif
	LD	L,(IY+20)
	LD	H,(IY+21)
	PUSH	HL
	LD	L,(IY+18)
	LD	H,(IY+19)
	PUSH	HL
	CALL	_L1169
	POP	AF
	POP	AF
_L0584:
; 2476.	                        clst = create_chain(fp->fs, fp->clust); /* Follow or stretch cluster chain on the FAT */
; 2477.	                }
	LD	A,L
	OR	H
	OR	C
	OR	B
	JP	Z,_L0572
_L0585:
_L0586:
; 2478.	                if (clst == 0) break;       /* Could not allocate a new cluster (disk full) */
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	Z,_L1088
_L0587:
_L0588:
; 2479.	                if (clst == 1) ABORT(fp->fs, FR_INT_ERR);
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	Z,_L1085
_L0589:
_L0590:
; 2480.	                if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	LD	(IY+18),L
	LD	(IY+19),H
	LD	(IY+20),C
	LD	(IY+21),B
_L0579:
; 2481.	                fp->clust = clst;           /* Update current cluster */
; 2482.	            }
; 2483.	#if _FS_TINY
; 2486.	#else
	BIT	6,(IY+4)
	JR	Z,_L0592
_L0591:
; 2487.	            if (fp->flag & FA__DIRTY) {     /* Write-back sector cache */
; 2488.	                SET_DIO_PAR(fp->fs->drv, fp->buf, fp->dsect, 1);
	CALL	_L1160
	JR	Z,_L0594
_L0593:
; 2489.	                if (drv_calls.write_from_buf() != RES_OK)
_L1085:
	JP	_L1087
_L0594:
; 2490.	                    ABORT(fp->fs, FR_DISK_ERR);
	RES	6,(IY+4)
_L0592:
; 2491.	                fp->flag &= ~FA__DIRTY;
; 2492.	            }
; 2493.	#endif
	LD	L,(IY+20)
	LD	H,(IY+21)
	PUSH	HL
	LD	L,(IY+18)
	LD	H,(IY+19)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	LD	(_L0561),HL
	LD	(_L0561+2),BC
; 2494.	            sect = clust2sect(fp->fs, fp->clust);   /* Get current sector */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0596
_L0595:
_L1088:
	SET	7,(IY+4)
_L1084:
	LD	A,2
	JP	_L0615
_L0596:
; 2495.	            if (!sect) ABORT(fp->fs, FR_INT_ERR);
	LD	HL,_L0561
	LD	E,(IX-2)
	LD	BC,0
	LD	D,C
	CALL	clib_L_ADDASG_L03
; 2496.	            sect += csect;
	LD	B,9
	EXX
	PUSH	DE
	EXX
	POP	DE
	CALL	clib_US_RSH_L02
	LD	(_L0563),DE
; 2497.	            cc = btw / SS(fp->fs);          /* When remaining bytes >= sector size, */
	LD	A,E
	OR	D
	JP	Z,_L0598
_L0597:
; 2498.	            if (cc) {                       /* Write maximum contiguous sectors directly */
	LD	C,(IX-2)
	LD	B,0
	EX	DE,HL
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,0
	AND	A
	SBC	HL,BC
	JR	NC,_L0600
_L0599:
; 2499.	                if (csect + cc > fp->fs->csize) /* Clip at cluster boundary */
	LD	C,(IX-2)
	LD	B,0
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,B
	AND	A
	SBC	HL,BC
	LD	(_L0563),HL
_L0600:
; 2500.	                    cc = fp->fs->csize - csect;
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	L,(IX-4)
	LD	H,(IX-3)
	LD	(drv_calls+27),HL
	EX	DE,HL
	LD	(drv_calls+29),HL
	LD	A,(_L0563)
	LD	(drv_calls+31),A
; 2501.	                SET_DIO_PAR(fp->fs->drv, wbuff, sect, (BYTE)cc);
	LD	HL,(drv_calls+8)
	CALL	_L1159
	JP	NZ,_L1087
_L0601:
; 2502.	                if (drv_calls.write_from_uspace() != RES_OK)
_L0602:
; 2503.	                    ABORT(fp->fs, FR_DISK_ERR);
; 2504.	#if _FS_TINY
; 2509.	#else
	LD	HL,(_L0563)
	LD	C,A
	LD	B,A
	PUSH	BC
	PUSH	HL
	AND	A
	LD	L,(IY+22)
	LD	H,(IY+23)
	LD	BC,(_L0561)
	SBC	HL,BC
	EX	DE,HL
	LD	L,(IY+24)
	LD	H,(IY+25)
	LD	BC,(_L0561+2)
	SBC	HL,BC
	EX	DE,HL
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	JR	NC,_L0604
_L0603:
; 2510.	                if (fp->dsect - sect < cc) { /* Refill sector cache if it gets invalidated by the direct write */
	LD	HL,512
	PUSH	HL
	LD	BC,(_L0561)
	LD	L,(IY+22)
	LD	H,(IY+23)
	AND	A
	SBC	HL,BC
	LD	H,L
	LD	L,A
	ADD	HL,HL
	LD	C,(IX-4)
	LD	B,(IX-3)
	ADD	HL,BC
	LD	C,L
	LD	B,H
	LD	HL,32
	PUSH	IY
	POP	DE
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(drv_calls+24)
	CALL	clib_CALL_IND_L09
	POP	HL
; 2511.	                    drv_calls.memcpy_usp2buf(fp->buf, wbuff + ((fp->dsect - sect) * SS(fp->fs)), SS(fp->fs));
	RES	6,(IY+4)
_L0604:
; 2512.	                    fp->flag &= ~FA__DIRTY;
; 2513.	                }
; 2514.	#endif
	LD	HL,(_L0563)
	LD	H,L
	LD	L,0
	ADD	HL,HL
	LD	(_L0562),HL
; 2515.	                wcnt = SS(fp->fs) * cc;     /* Number of bytes transferred */
	JP	_L0575
_L0598:
; 2516.	                continue;
; 2517.	            }
; 2518.	#if _FS_TINY
; 2523.	#else
	LD	L,(IY+22)
	LD	H,(IY+23)
	LD	BC,(_L0561)
	SBC	HL,BC
	JR	NZ,_L1081
	LD	L,(IY+24)
	LD	H,(IY+25)
	LD	BC,(_L0561+2)
	SBC	HL,BC
	JR	Z,_L0608
_L1081:
_L0605:
; 2524.	            if (fp->dsect != sect) {        /* Fill sector cache with file data */
; 2525.	                
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,32
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,_L0561
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 2526.	                SET_DIO_PAR(fp->fs->drv, fp->buf, sect, 1);
; 2527.	                if (fp->fptr < fp->fsize &&
	LD	HL,10
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	PUSH	DE
	AND	A
	LD	L,(IY+6)
	LD	H,(IY+7)
	POP	BC
	SBC	HL,BC
	LD	L,(IY+8)
	LD	H,(IY+9)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0608
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JR	Z,_L0608
_L0610:
_L0609:
_L0607:
; 2528.	                    drv_calls.read_to_buf() != RES_OK)
_L1087:
	SET	7,(IY+4)
	LD	A,1
	JP	_L0615
_L0608:
_L0606:
; 2529.	                        ABORT(fp->fs, FR_DISK_ERR);
; 2530.	            }
; 2531.	#endif
	LD	BC,(_L0561+2)
	LD	HL,(_L0561)
	LD	(IY+22),L
	LD	(IY+23),H
	LD	(IY+24),C
	LD	(IY+25),B
_L0577:
; 2532.	            fp->dsect = sect;
; 2533.	        }
	LD	C,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	B,A
	LD	HL,512
	SBC	HL,BC
	LD	(_L0562),HL
; 2534.	        wcnt = SS(fp->fs) - (fp->fptr % SS(fp->fs));/* Put partial sector into file I/O buffer */
	LD	C,L
	LD	B,H
	EXX
	PUSH	DE
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0612
_L0611:
	EXX
	PUSH	DE
	EXX
	POP	HL
	LD	(_L0562),HL
_L0612:
; 2535.	        if (wcnt > btw) wcnt = btw;
; 2536.	#if _FS_TINY
; 2541.	#else
	LD	HL,(_L0562)
	PUSH	HL
	LD	C,(IX-4)
	LD	B,(IX-3)
	LD	L,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	H,A
	PUSH	IY
	POP	DE
	ADD	HL,DE
	LD	DE,32
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(drv_calls+24)
	CALL	clib_CALL_IND_L09
	POP	HL
; 2542.	        drv_calls.memcpy_usp2buf(&fp->buf[fp->fptr % SS(fp->fs)], wbuff, wcnt); /* Fit partial sector */
	SET	6,(IY+4)
_L0575:
; 2461.	    for ( ;  btw;                           /* Repeat until all data written */
	LD	HL,8
	ADD	HL,SP
	LD	BC,(_L0562)
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	LD	HL,6
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	DE,(_L0562)
	LD	BC,0
	CALL	clib_L_ADDASG_L03
	LD	BC,(_L0562)
	LD	L,(IX+10)
	LD	H,(IX+11)
	LD	A,(HL)
	ADD	A,C
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	ADC	A,B
	LD	(HL),A
	PUSH	BC
	EXX
	EX	DE,HL
	POP	DE
	AND	A
	SBC	HL,DE
	EX	DE,HL
	JP	_L1082
; 2543.	        fp->flag |= FA__DIRTY;
; 2544.	#endif
; 2545.	    }
; 2546.	
_L0572:
	LD	L,(IY+10)
	LD	H,(IY+11)
	LD	C,(IY+6)
	LD	B,(IY+7)
	SBC	HL,BC
	LD	L,(IY+12)
	LD	H,(IY+13)
	LD	C,(IY+8)
	LD	B,(IY+9)
	SBC	HL,BC
	JR	NC,_L0614
_L0613:
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	H,(IY+7)
	LD	(IY+10),L
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
_L0614:
; 2547.	    if (fp->fptr > fp->fsize) fp->fsize = fp->fptr; /* Update file size if needed */
	SET	5,(IY+4)
; 2548.	    fp->flag |= FA__WRITTEN;                        /* Set file change flag */
; 2549.	
; 2550.	    LEAVE_FF(fp->fs, FR_OK);
_L0615:
	JP	_L1149
; 2551.	}
; 2552.	
; 2553.	
; 2554.	
; 2555.	
; 2556.	/*-----------------------------------------------------------------------*/
; 2557.	/* Synchronize the File Object                                           */
; 2558.	/*-----------------------------------------------------------------------*/
; 2559.	
; 2560.	FRESULT f_sync (
; 2561.	    FIL *fp     /* Pointer to the file object */
; 2562.	)
f_sync:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-6
	PUSH	IY
; 2563.	{
; 2564.	    FRESULT res;
; 2565.	    DWORD tim;
; 2566.	    BYTE *dir;
; 2567.	
; 2568.	
	CALL	_L1186
; 2569.	    res = validate(fp->fs, fp->id);     /* Check validity of the object */
	OR	A
	JP	NZ,_L0625
_L0616:
; 2570.	    if (res == FR_OK) {
	BIT	5,(IY+4)
	JP	Z,_L0625
_L0618:
; 2571.	        if (fp->flag & FA__WRITTEN) {   /* Has the file been written? */
; 2572.	#if !_FS_TINY   /* Write-back dirty buffer */
	BIT	6,(IY+4)
	JR	Z,_L0621
_L0620:
; 2573.	            if (fp->flag & FA__DIRTY) {
; 2574.	                SET_DIO_PAR(fp->fs->drv, fp->buf, fp->dsect, 1);
	CALL	_L1160
	JR	Z,_L0623
_L0622:
; 2575.	                if (drv_calls.write_from_buf() != RES_OK)
	LD	A,1
; 2576.	                    LEAVE_FF(fp->fs, FR_DISK_ERR);
	JP	_L0625
_L0623:
	RES	6,(IY+4)
_L0621:
; 2577.	                fp->flag &= ~FA__DIRTY;
; 2578.	            }
; 2579.	#endif
; 2580.	            /* Update the directory entry */
	LD	L,(IY+28)
	LD	H,(IY+29)
	PUSH	HL
	LD	L,(IY+26)
	LD	H,(IY+27)
	PUSH	HL
	LD	E,(IY+0)
	LD	D,(IY+1)
	CALL	move_window
	POP	HL
	POP	HL
; 2581.	            res = move_window(fp->fs, fp->dir_sect);
	OR	A
	JP	NZ,_L0625
_L0624:
; 2582.	            if (res == FR_OK) {
	LD	E,(IY+30)
	LD	D,(IY+31)
; 2583.	                dir = fp->dir_ptr;
	LD	HL,11
	ADD	HL,DE
	SET	5,(HL)
; 2584.	                dir[DIR_Attr] |= AM_ARC;                    /* Set archive bit */
	PUSH	DE
	LD	C,(IY+12)
	LD	B,(IY+13)
	LD	L,(IY+10)
	LD	H,(IY+11)
	PUSH	HL
	LD	HL,28
	ADD	HL,DE
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
	POP	DE
; 2585.	                ST_DWORD(dir+DIR_FileSize, fp->fsize);      /* Update file size */
	LD	HL,26
	ADD	HL,DE
	LD	C,(IY+14)
	LD	(HL),C
	LD	B,(IY+15)
	INC	HL
	LD	(HL),B
	PUSH	DE
	LD	HL,20
	ADD	HL,DE
	PUSH	HL
	LD	L,(IY+16)
	LD	H,(IY+17)
	EX	DE,HL
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
; 2586.	                ST_CLUST(dir, fp->sclust);                  /* Update start cluster */
	LD	HL,6
	ADD	HL,SP
	EX	DE,HL
	LD	HL,(drv_calls+12)
	CALL	clib_CALL_IND_L09
	POP	DE
; 2587.	                get_fattime(&tim);                      /* Update updated time */
	LD	HL,22
	ADD	HL,DE
	LD	C,(IX-2)
	LD	B,(IX-1)
	LD	E,(IX-4)
	LD	(HL),E
	LD	D,(IX-3)
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 2588.	                ST_DWORD(dir+DIR_WrtTime, tim);
	RES	5,(IY+4)
; 2589.	                fp->flag &= ~FA__WRITTEN;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,5
	ADD	HL,BC
	LD	(HL),1
; 2590.	                fp->fs->wflag = 1;
	LD	E,(IY+0)
	LD	D,(IY+1)
	CALL	sync
_L0625:
_L0619:
_L0617:
; 2591.	                res = sync(fp->fs);
; 2592.	            }
; 2593.	        }
; 2594.	    }
; 2595.	
; 2596.	    LEAVE_FF(fp->fs, res);
_L0626:
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 2597.	}
; 2598.	
; 2599.	#endif /* !_FS_READONLY */
; 2600.	
; 2601.	
; 2602.	
; 2603.	
; 2604.	/*-----------------------------------------------------------------------*/
; 2605.	/* Close File                                                            */
; 2606.	/*-----------------------------------------------------------------------*/
; 2607.	
; 2608.	FRESULT f_close (
; 2609.	    FIL *fp     /* Pointer to the file object to be closed */
; 2610.	)
f_close:
	PUSH	IX
	PUSH	DE
	POP	IX
; 2611.	{
; 2612.	    static FRESULT res;
; 2613.	
; 2614.	#if _FS_READONLY
; 2620.	#else
	CALL	f_sync
	LD	(_L0627),A
; 2621.	    res = f_sync(fp);       /* Flush cached data */
; 2622.	#if _FS_SHARE
; 2624.	#if _FS_REENTRANT
; 2630.	#else
; 2632.	#endif
; 2634.	#endif
	OR	A
	JR	NZ,_L0629
_L0628:
	PUSH	IX
	POP	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
_L0629:
; 2635.	    if (res == FR_OK) fp->fs = 0;   /* Discard file object */
; 2636.	    return res;
; 2637.	#endif
	POP	IX
	RET
; 2638.	}
; 2639.	
; 2640.	
; 2641.	
; 2642.	
; 2643.	/*-----------------------------------------------------------------------*/
; 2644.	/* Current Drive/Directory Handlings                                     */
; 2645.	/*-----------------------------------------------------------------------*/
; 2646.	
; 2647.	#if _FS_RPATH >= 1
; 2648.	
; 2649.	FRESULT f_chdrive (
; 2650.	    BYTE drv        /* Drive number */
; 2651.	)
f_chdrive:
	PUSH	DE
; 2652.	{
; 2653.	    //if (drv >= _VOLUMES) return FR_INVALID_DRIVE;
; 2654.	
; 2655.	    //CurrVol = drv;
; 2656.	
	LD	A,E
; 2657.	    return drv;
	POP	HL
	RET
; 2658.	}
; 2659.	
; 2660.	
; 2661.	
; 2662.	FRESULT f_chdir (
; 2663.	    const TCHAR *path   /* Pointer to the directory path */
; 2664.	)
f_chdir:
	PUSH	BC
	PUSH	IX
	PUSH	DE
; 2665.	{
; 2666.	    FRESULT res;
; 2667.	    //DIR dj;
; 2668.	    DEF_NAMEBUF;
; 2669.	
; 2670.	    
	CALL	_L1181
; 2671.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 2672.	    
	LD	C,0
	CALL	_L1177
	LD	IXL,A
; 2673.	    res = chk_mounted(&djo.fs, 0);
	OR	A
	JR	NZ,_L0641
_L0630:
; 2674.	    if (res == FR_OK) {
; 2675.	        INIT_BUF(djo);
	CALL	_L1183
	LD	IXL,A
; 2676.	        res = follow_path(&djo, pathbuf);       /* Follow the path */
; 2677.	        FREE_BUF();
	OR	A
	JR	NZ,_L0639
_L0632:
; 2678.	        if (res == FR_OK) {                 /* Follow completed */
	LD	HL,(djo+18)
	LD	A,L
	OR	H
	JR	NZ,_L0635
_L0634:
; 2679.	            if (!djo.dir) {
	LD	HL,djo+6
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	JR	_L1090
; 2680.	                drv_calls.curr_dir = djo.sclust;    //dj.fs->cdir = dj.sclust;  /* Start directory itself */
_L0635:
; 2681.	            } else {
	LD	BC,11
	ADD	HL,BC
	BIT	4,(HL)
	JR	Z,_L0638
_L0637:
; 2682.	                if (djo.dir[DIR_Attr] & AM_DIR) /* Reached to the directory */
	CALL	_L1174
_L1090:
	LD	(drv_calls+34),HL
	LD	(drv_calls+36),BC
; 2683.	                    drv_calls.curr_dir = LD_CLUST(djo.dir); //dj.fs->cdir = LD_CLUST(dj.dir);
	JR	_L0639
_L0638:
; 2684.	                else
	LD	IXL,5
_L0639:
_L0636:
_L0633:
; 2685.	                    res = FR_NO_PATH;       /* Reached but a file */
; 2686.	            }
; 2687.	        }
	LD	A,IXL
	CP	4
	JR	NZ,_L0641
_L0640:
	LD	IXL,5
_L0641:
_L0631:
; 2688.	        if (res == FR_NO_FILE) res = FR_NO_PATH;
; 2689.	    }
; 2690.	
	LD	A,IXL
; 2691.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	IX
	POP	BC
	RET
_L1174:
	LD	DE,(djo+18)
	JP	LD_CLUST
; 2692.	}
; 2693.	
; 2694.	
; 2695.	#if _FS_RPATH >= 2
; 2696.	FRESULT f_getcwd (
; 2697.	    TCHAR *path,    /* Pointer to the directory path */
; 2698.	    UINT sz_path    /* Size of path */
; 2699.	)
f_getcwd:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	EXX
; 2700.	{
; 2701.	    FRESULT res;
; 2702.	    //DIR dj;
; 2703.	    UINT i, n;
; 2704.	    static DWORD ccl;
; 2705.	    TCHAR *tp;
; 2706.	    static FILINFO fno;
; 2707.	    DEF_NAMEBUF;
; 2708.	
; 2709.	
	XOR	A
	LD	(pathbuf),A
; 2710.	    *pathbuf = 0;
	LD	C,A
	CALL	_L1177
	LD	(IX-2),A
; 2711.	    res = chk_mounted(&djo.fs, 0);  /* Get current volume */
	OR	A
	JP	NZ,_L0645
_L0644:
; 2712.	    if (res == FR_OK) {
	LD	HL,sfn
	LD	(djo+20),HL
; 2713.	        INIT_BUF(djo);
; 2714.	        i = sz_path;        /* Bottom of buffer (dir stack base) */
	LD	HL,drv_calls+34
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(djo+6),HL
	LD	(djo+8),BC
	EXX
	LD	C,(IX+4)
	LD	B,(IX+5)
	EXX
_L0647:
; 2715.	        djo.sclust = drv_calls.curr_dir;    //dj.fs->cdir;          /* Start to follow upper dir from current dir */
	LD	HL,djo+6
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(_L0642),HL
	LD	(_L0642+2),BC
	LD	A,L
	OR	H
	OR	C
	OR	B
	JP	Z,_L0646
_L0648:
; 2716.	        while ((ccl = djo.sclust) != 0) {   /* Repeat while current dir is a sub-dir */
	LD	BC,1
	CALL	_L1170
; 2717.	            res = dir_sdi(&djo, 1);         /* Get parent dir */
	JP	NZ,_L0646
_L0649:
_L0650:
; 2718.	            if (res != FR_OK) break;
	CALL	_L1189
; 2719.	            res = dir_read(&djo);
	JP	NZ,_L0646
_L0651:
_L0652:
; 2720.	            if (res != FR_OK) break;
	CALL	_L1174
	LD	(djo+6),HL
	LD	(djo+8),BC
; 2721.	            djo.sclust = LD_CLUST(djo.dir); /* Goto parent dir */
	LD	BC,0
	CALL	_L1170
; 2722.	            res = dir_sdi(&djo, 0);
	JP	NZ,_L0646
_L0653:
_L0654:
_L0657:
; 2723.	            if (res != FR_OK) break;
; 2724.	            do {                            /* Find the entry links to the child dir */
	CALL	_L1189
; 2725.	                res = dir_read(&djo);
	JR	NZ,_L0655
_L0658:
_L0659:
; 2726.	                if (res != FR_OK) break;
	CALL	_L1174
	LD	E,C
	LD	D,B
	LD	BC,(_L0642)
	AND	A
	SBC	HL,BC
	JR	NZ,_L0661
	EX	DE,HL
	LD	BC,(_L0642+2)
	SBC	HL,BC
	JR	Z,_L0655
_L0660:
_L0661:
; 2727.	                if (ccl == LD_CLUST(djo.dir)) break;    /* Found the entry */
	LD	BC,0
	LD	DE,djo
	CALL	dir_next
	LD	(IX-2),A
; 2728.	                res = dir_next(&djo, 0);    
	OR	A
	JR	Z,_L0654
_L0655:
; 2729.	            } while (res == FR_OK);
	LD	A,(IX-2)
	CP	4
	JR	NZ,_L0663
_L0662:
	LD	(IX-2),2
_L0663:
; 2730.	            if (res == FR_NO_FILE) res = FR_INT_ERR;/* It cannot be 'not found'. */
	XOR	A
	OR	(IX-2)
	JR	NZ,_L0646
_L0664:
_L0665:
; 2731.	            if (res != FR_OK) break;
; 2732.	#if _USE_LFN
; 2735.	#endif
	LD	BC,_L0643
	LD	DE,djo
	CALL	get_fileinfo
; 2736.	            get_fileinfo(&djo, &fno);       /* Get the dir name and push it to the buffer */
	LD	IY,_L0643+9
; 2737.	            tp = fno.fname;
	XOR	A
	JR	Z,_L0667
	LD	A,(pathbuf)
	OR	A
	JR	Z,_L0667
_L0669:
_L0668:
_L0666:
	LD	IY,pathbuf
_L0667:
; 2738.	            if (_USE_LFN && *pathbuf) tp = pathbuf;
	EXX
	LD	DE,0
_L1091:
_L0671:
	PUSH	DE
	EXX
	POP	HL
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	EXX
	JR	Z,_L0670
_L0672:
	INC	DE
	JR	_L1091
; 2739.	            for (n = 0; tp[n]; n++) ;
_L0670:
	PUSH	DE
	EXX
	POP	BC
	INC	BC
	INC	BC
	INC	BC
	EXX
	PUSH	BC
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	JR	NC,_L0675
_L0674:
; 2740.	            if (i < n + 3) {
	LD	(IX-2),17
	JR	_L0646
_L0675:
; 2741.	                res = FR_NOT_ENOUGH_CORE; break;
; 2742.	            }
	EXX
	DEC	BC
	PUSH	BC
	EXX
	POP	HL
	LD	BC,pathbuf
	ADD	HL,BC
	LD	(HL),47
_L0677:
; 2743.	            pathbuf[--i] = '/';
	EXX
	LD	A,E
	OR	D
	EXX
	JR	Z,_L0676
_L0678:
	EXX
	DEC	DE
	PUSH	DE
	EXX
	POP	HL
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	B,(HL)
	EXX
	DEC	BC
	PUSH	BC
	EXX
	POP	HL
	LD	DE,pathbuf
	ADD	HL,DE
	LD	(HL),B
; 2744.	            while (n) pathbuf[--i] = tp[--n];
	JR	_L0677
_L0676:
; 2745.	        }
	JP	_L0647
_L0646:
	LD	IY,pathbuf
; 2746.	        tp = pathbuf;
	XOR	A
	OR	(IX-2)
	JR	NZ,_L0682
_L0679:
; 2747.	        if (res == FR_OK) {
; 2748.	            //*tp++ = '0' + CurrVol;            /* Put drive number */
; 2749.	            //*tp++ = ':';
	LD	L,(IX+4)
	LD	H,(IX+5)
	EXX
	PUSH	BC
	EXX
	POP	BC
	SBC	HL,BC
	JR	Z,_L0682
_L0681:
_L0685:
; 2750.	            if (i != sz_path) {             /* non Root-dir */
; 2751.	                do      /* Add stacked path str */
	EXX
	PUSH	BC
	INC	BC
	EXX
	POP	HL
	LD	BC,pathbuf
	ADD	HL,BC
	LD	B,(HL)
	LD	(IY+0),B
; 2752.	                    *tp++ = pathbuf[i++];
	LD	C,(IX+4)
	LD	B,(IX+5)
	EXX
	PUSH	BC
	EXX
	POP	HL
	AND	A
	SBC	HL,BC
	INC	IY
	JR	C,_L0681
_L0683:
; 2753.	                while (i < sz_path);
	DEC	IY
_L0682:
_L0680:
; 2754.	                tp--;
; 2755.	            }
; 2756.	        }
	LD	(IY+0),0
_L0645:
; 2757.	        *tp = 0;
; 2758.	        FREE_BUF();
; 2759.	    }
	LD	BC,pathbuf
	LD	E,(IX+2)
	LD	D,(IX+3)
	LD	HL,(drv_calls+14)
	CALL	clib_CALL_IND_L09
; 2760.	    drv_calls.strcpy_lib2usp(path, pathbuf);
	LD	A,(IX-2)
; 2761.	    LEAVE_FF(djo.fs, res);
	JP	_L0154
_L1189:
	LD	DE,djo
	CALL	dir_read
	LD	(IX-2),A
	OR	A
	RET
; 2762.	}
; 2763.	#endif /* _FS_RPATH >= 2 */
; 2764.	#endif /* _FS_RPATH >= 1 */
; 2765.	
; 2766.	
; 2767.	
; 2768.	#if _FS_MINIMIZE <= 2
; 2769.	/*-----------------------------------------------------------------------*/
; 2770.	/* Seek File R/W Pointer                                                 */
; 2771.	/*-----------------------------------------------------------------------*/
; 2772.	
; 2773.	FRESULT f_lseek (
; 2774.	    FIL *fp,        /* Pointer to the file object */
; 2775.	    DWORD ofs       /* File pointer from top of file */
; 2776.	)
f_lseek:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65534
	PUSH	IY
; 2777.	{
; 2778.	    FRESULT res;
; 2779.	
; 2780.	
	CALL	_L1186
	LD	(IX-2),A
; 2781.	    res = validate(fp->fs, fp->id);     /* Check validity of the object */
	OR	A
	JP	NZ,_L0742
_L0686:
; 2782.	    if (res != FR_OK) LEAVE_FF(fp->fs, res);
_L0687:
	LD	A,(IY+4)
	OR	A
	JP	M,_L1098
_L0688:
; 2783.	    if (fp->flag & FA__ERROR)           /* Check abort flag */
; 2784.	        LEAVE_FF(fp->fs, FR_INT_ERR);
; 2785.	
; 2786.	#if _USE_FASTSEEK
; 2825.	#if !_FS_TINY
; 2826.	#if !_FS_READONLY
; 2832.	#endif
; 2835.	#endif
; 2841.	#endif
; 2842.	
; 2843.	    /* Normal Seek */
_L0689:
; 2844.	    {
; 2845.	        static DWORD clst;
; 2846.	        static DWORD bcs;
; 2847.	        static DWORD nsect;
; 2848.	        static DWORD ifptr;
; 2849.	
; 2850.	        if (ofs > fp->fsize                 /* In read-only mode, clip offset with the file size */
; 2851.	#if !_FS_READONLY
; 2852.	             && !(fp->flag & FA_WRITE)
; 2853.	#endif
	AND	A
	LD	L,(IY+10)
	LD	H,(IY+11)
	LD	C,(IX+8)
	LD	B,(IX+9)
	SBC	HL,BC
	LD	L,(IY+12)
	LD	H,(IY+13)
	LD	C,(IX+10)
	LD	B,(IX+11)
	SBC	HL,BC
	JR	NC,_L0695
	BIT	1,(IY+4)
	JR	NZ,_L0695
_L0697:
_L0696:
_L0694:
	LD	C,(IY+12)
	LD	B,(IY+13)
	LD	L,(IY+10)
	LD	(IX+8),L
	LD	H,(IY+11)
	LD	(IX+9),H
	LD	(IX+10),C
	LD	(IX+11),B
_L0695:
; 2854.	            ) ofs = fp->fsize;
; 2855.	
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	H,(IY+7)
	LD	(_L0693),HL
	LD	(_L0693+2),BC
; 2856.	        ifptr = fp->fptr;
	LD	BC,0
	LD	(_L0692),BC
	LD	(_L0692+2),BC
	XOR	A
	LD	(IY+6),A
	LD	(IY+7),A
	LD	(IY+8),A
	LD	(IY+9),A
; 2857.	        fp->fptr = nsect = 0;
	LD	A,(IX+8)
	OR	(IX+9)
	OR	(IX+10)
	OR	(IX+11)
	JP	Z,_L0728
_L0698:
; 2858.	        if (ofs) {
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	INC	HL
	INC	HL
	LD	L,(HL)
	LD	H,C
	LD	A,9
	CALL	clib_L_LSH_L03
	LD	(_L0691),HL
	LD	(_L0691+2),BC
; 2859.	            bcs = (DWORD)fp->fs->csize * SS(fp->fs);    /* Cluster size (byte) */
; 2860.	            if (ifptr > 0 &&
	LD	HL,(_L0693)
	LD	A,L
	OR	H
	LD	HL,(_L0693+2)
	OR	L
	OR	H
	JP	Z,_L0701
	PUSH	BC
	LD	HL,(_L0691)
	PUSH	HL
	LD	HL,65535
	PUSH	HL
	PUSH	HL
	LD	HL,(_L0693)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(_L0693+2)
	POP	BC
	CALL	_L1176
	PUSH	BC
	PUSH	HL
	LD	HL,(_L0691+2)
	PUSH	HL
	LD	HL,(_L0691)
	PUSH	HL
	LD	HL,65535
	PUSH	HL
	PUSH	HL
	LD	L,(IX+8)
	LD	H,(IX+9)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	L,(IX+10)
	LD	H,(IX+11)
	POP	BC
	CALL	_L1176
	LD	E,C
	LD	D,B
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	JR	C,_L0701
_L0703:
_L0702:
_L0700:
; 2861.	                (ofs - 1) / bcs >= (ifptr - 1) / bcs) { /* When seek to same or following cluster, */
	LD	HL,65535
	PUSH	HL
	PUSH	HL
	LD	HL,(_L0691)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(_L0691+2)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	CALL	clib_L_NOT_L03
	PUSH	BC
	PUSH	HL
	LD	HL,65535
	PUSH	HL
	PUSH	HL
	LD	HL,(_L0693)
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,(_L0693+2)
	POP	BC
	ADC	HL,BC
	LD	C,L
	LD	B,H
	EX	DE,HL
	CALL	clib_L_AND_L03
	LD	(IY+6),L
	LD	(IY+7),H
	LD	(IY+8),C
	LD	(IY+9),B
; 2862.	                fp->fptr = (ifptr - 1) & ~(bcs - 1);    /* start from the current cluster */
	LD	HL,12
	ADD	HL,SP
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	E,(IY+6)
	LD	D,(IY+7)
	CALL	clib_L_SUBASG_L03
; 2863.	                ofs -= fp->fptr;
	LD	C,(IY+20)
	LD	B,(IY+21)
	LD	L,(IY+18)
	LD	H,(IY+19)
	LD	(_L0690),HL
	LD	(_L0690+2),BC
; 2864.	                clst = fp->clust;
	JR	_L0704
_L0701:
; 2865.	            } else {                                    /* When seek to back cluster, */
	LD	C,(IY+16)
	LD	B,(IY+17)
	LD	L,(IY+14)
	LD	H,(IY+15)
	LD	(_L0690),HL
	LD	(_L0690+2),BC
; 2866.	                clst = fp->sclust;                      /* start from the first cluster */
; 2867.	#if !_FS_READONLY
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0706
_L0705:
; 2868.	                if (clst == 0) {                        /* If no cluster chain, create a new chain */
	LD	L,A
	LD	H,A
	PUSH	HL
	PUSH	HL
	CALL	_L1169
	POP	AF
	POP	AF
	LD	(_L0690),HL
	LD	(_L0690+2),BC
; 2869.	                    clst = create_chain(fp->fs, 0);
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JP	Z,_L1100
_L0707:
_L0708:
; 2870.	                    if (clst == 1) ABORT(fp->fs, FR_INT_ERR);
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JP	Z,_L1099
_L0709:
_L0710:
; 2871.	                    if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	LD	(IY+14),L
	LD	(IY+15),H
	LD	(IY+16),C
	LD	(IY+17),B
_L0706:
; 2872.	                    fp->sclust = clst;
; 2873.	                }
; 2874.	#endif
	LD	(IY+18),L
	LD	(IY+19),H
	LD	(IY+20),C
	LD	(IY+21),B
_L0704:
; 2875.	                fp->clust = clst;
; 2876.	            }
	LD	A,L
	OR	H
	LD	L,C
	LD	H,B
	OR	L
	OR	H
	JP	Z,_L0728
_L0711:
_L0714:
; 2877.	            if (clst != 0) {
	AND	A
	LD	HL,(_L0691)
	LD	C,(IX+8)
	LD	B,(IX+9)
	SBC	HL,BC
	LD	HL,(_L0691+2)
	LD	C,(IX+10)
	LD	B,(IX+11)
	SBC	HL,BC
	JP	NC,_L0713
_L0715:
; 2878.	                while (ofs > bcs) {                     /* Cluster following loop */
; 2879.	#if !_FS_READONLY
	BIT	1,(IY+4)
	LD	HL,(_L0690+2)
	PUSH	HL
	LD	HL,(_L0690)
	PUSH	HL
	LD	E,(IY+0)
	LD	D,(IY+1)
	JR	Z,_L0717
_L0716:
; 2880.	                    if (fp->flag & FA_WRITE) {          /* Check if in write mode or not */
	CALL	create_chain
	POP	AF
	POP	AF
	LD	(_L0690),HL
	LD	(_L0690+2),BC
; 2881.	                        clst = create_chain(fp->fs, clst);  /* Force stretch if in write mode */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0720
_L0718:
; 2882.	                        if (clst == 0) {                /* When disk gets full, clip file size */
	LD	BC,(_L0691+2)
	LD	HL,(_L0691)
	LD	(IX+8),L
	LD	(IX+9),H
	LD	(IX+10),C
	LD	(IX+11),B
	JP	_L0713
_L0719:
; 2883.	                            ofs = bcs; break;
; 2884.	                        }
_L0717:
; 2885.	                    } else
; 2886.	#endif
	CALL	get_fat
	POP	AF
	POP	AF
	LD	(_L0690),HL
	LD	(_L0690+2),BC
_L0720:
; 2887.	                        clst = get_fat(fp->fs, clst);   /* Follow cluster chain if not in write mode */
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JP	Z,_L1099
_L0721:
_L0722:
; 2888.	                    if (clst == 0xFFFFFFFF) ABORT(fp->fs, FR_DISK_ERR);
	LD	HL,1
	LD	BC,(_L0690)
	SBC	HL,BC
	LD	HL,0
	LD	BC,(_L0690+2)
	SBC	HL,BC
	JR	NC,_L0725
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	AND	A
	LD	HL,(_L0690)
	POP	BC
	SBC	HL,BC
	LD	HL,(_L0690+2)
	POP	BC
	SBC	HL,BC
	JR	C,_L0724
_L0725:
_L0726:
_L0723:
	JR	_L1100
_L0724:
; 2889.	                    if (clst <= 1 || clst >= fp->fs->n_fatent) ABORT(fp->fs, FR_INT_ERR);
	LD	BC,(_L0690+2)
	LD	HL,(_L0690)
	LD	(IY+18),L
	LD	(IY+19),H
	LD	(IY+20),C
	LD	(IY+21),B
; 2890.	                    fp->clust = clst;
	LD	HL,6
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	BC,(_L0691+2)
	LD	DE,(_L0691)
	CALL	clib_L_ADDASG_L03
; 2891.	                    fp->fptr += bcs;
	LD	HL,12
	ADD	HL,SP
	LD	BC,(_L0691+2)
	LD	DE,(_L0691)
	CALL	clib_L_SUBASG_L03
; 2892.	                    ofs -= bcs;
; 2893.	                }
	JP	_L0711
_L0713:
	LD	HL,6
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	C,(IX+10)
	LD	B,(IX+11)
	LD	E,(IX+8)
	LD	D,(IX+9)
	CALL	clib_L_ADDASG_L03
; 2894.	                fp->fptr += ofs;
	LD	L,(IX+8)
	LD	A,(IX+9)
	AND	1
	LD	H,A
	LD	A,L
	OR	H
	JR	Z,_L0728
_L0727:
; 2895.	                if (ofs % SS(fp->fs)) {
	LD	HL,(_L0690+2)
	PUSH	HL
	LD	HL,(_L0690)
	PUSH	HL
	CALL	_L1168
	POP	AF
	POP	AF
	LD	(_L0692),HL
	LD	(_L0692+2),BC
; 2896.	                    nsect = clust2sect(fp->fs, clst);   /* Current sector */
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0730
_L0729:
_L1100:
	SET	7,(IY+4)
_L1098:
	LD	A,2
	JP	_L0743
_L0730:
; 2897.	                    if (!nsect) ABORT(fp->fs, FR_INT_ERR);
	LD	A,9
	CALL	_L1165
	EX	DE,HL
	LD	HL,_L0692
	CALL	clib_L_ADDASG_L03
_L0728:
_L0712:
_L0699:
; 2898.	                    nsect += ofs / SS(fp->fs);
; 2899.	                }
; 2900.	            }
; 2901.	        }
	LD	L,(IY+6)
	LD	A,(IY+7)
	AND	1
	LD	H,A
	LD	A,L
	OR	H
	JR	Z,_L0732
	LD	L,(IY+22)
	LD	H,(IY+23)
	LD	BC,(_L0692)
	SBC	HL,BC
	JR	NZ,_L1092
	LD	L,(IY+24)
	LD	H,(IY+25)
	LD	BC,(_L0692+2)
	SBC	HL,BC
	JR	Z,_L0732
_L1092:
_L0734:
_L0733:
_L0731:
; 2902.	        if (fp->fptr % SS(fp->fs) && nsect != fp->dsect) {  /* Fill sector cache if needed */
; 2903.	#if !_FS_TINY
; 2904.	#if !_FS_READONLY
	BIT	6,(IY+4)
	JR	Z,_L0736
_L0735:
; 2905.	            if (fp->flag & FA__DIRTY) {         /* Write-back dirty sector cache */
; 2906.	                SET_DIO_PAR(fp->fs->drv, fp->buf, fp->dsect, 1);
	CALL	_L1160
	JR	NZ,_L1099
_L0737:
; 2907.	                if (drv_calls.write_from_buf() != RES_OK)
_L0738:
; 2908.	                    ABORT(fp->fs, FR_DISK_ERR);
	RES	6,(IY+4)
_L0736:
; 2909.	                fp->flag &= ~FA__DIRTY;
; 2910.	            }
; 2911.	#endif
	LD	L,(IY+0)
	LD	H,(IY+1)
	INC	HL
	LD	A,(HL)
	LD	(drv_calls+26),A
	LD	HL,32
	PUSH	IY
	POP	BC
	ADD	HL,BC
	LD	(drv_calls+27),HL
	LD	HL,_L0692
	LD	(drv_calls+29),HL
	LD	A,1
	LD	(drv_calls+31),A
; 2912.	            SET_DIO_PAR(fp->fs->drv, fp->buf, nsect, 1);
	LD	HL,(drv_calls+6)
	CALL	_L1159
	JR	Z,_L0740
_L0739:
; 2913.	            if (drv_calls.read_to_buf() != RES_OK)  /* Fill sector cache */
_L1099:
	SET	7,(IY+4)
	LD	A,1
	JR	_L0743
_L0740:
; 2914.	                ABORT(fp->fs, FR_DISK_ERR);
; 2915.	#endif
	LD	BC,(_L0692+2)
	LD	HL,(_L0692)
	LD	(IY+22),L
	LD	(IY+23),H
	LD	(IY+24),C
	LD	(IY+25),B
_L0732:
; 2916.	            fp->dsect = nsect;
; 2917.	        }
; 2918.	#if !_FS_READONLY
	AND	A
	LD	L,(IY+10)
	LD	H,(IY+11)
	LD	C,(IY+6)
	LD	B,(IY+7)
	SBC	HL,BC
	LD	L,(IY+12)
	LD	H,(IY+13)
	LD	C,(IY+8)
	LD	B,(IY+9)
	SBC	HL,BC
	JR	NC,_L0742
_L0741:
; 2919.	        if (fp->fptr > fp->fsize) {         /* Set file change flag if the file size is extended */
	LD	C,(IY+8)
	LD	B,(IY+9)
	LD	L,(IY+6)
	LD	H,(IY+7)
	LD	(IY+10),L
	LD	(IY+11),H
	LD	(IY+12),C
	LD	(IY+13),B
; 2920.	            fp->fsize = fp->fptr;
	SET	5,(IY+4)
_L0742:
; 2921.	            fp->flag |= FA__WRITTEN;
; 2922.	        }
; 2923.	#endif
; 2924.	    }
; 2925.	
	LD	A,(IX-2)
; 2926.	    LEAVE_FF(fp->fs, res);
_L0743:
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 2927.	}
; 2928.	
; 2929.	
; 2930.	
; 2931.	#if _FS_MINIMIZE <= 1
; 2932.	/*-----------------------------------------------------------------------*/
; 2933.	/* Create a Directroy Object                                             */
; 2934.	/*-----------------------------------------------------------------------*/
; 2935.	FRESULT f_opendir (
; 2936.	    DIR *dj         /* Pointer to directory object to create */
; 2937.	    //,const TCHAR *path    /* Pointer to the directory path */
; 2938.	)
f_opendir:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	PUSH	DE
	POP	IX
; 2939.	{
; 2940.	    FRESULT res;
; 2941.	    static TCHAR *path;
; 2942.	    DEF_NAMEBUF;
	LD	HL,nullstring
	LD	(_L0744),HL
; 2943.	    path = (TCHAR *)nullstring;
; 2944.	
	LD	C,0
	CALL	chk_mounted
	LD	IYL,A
; 2945.	    res = chk_mounted(&dj->fs, 0);  //(&path, &dj->fs, 0);
	OR	A
	JR	NZ,_L0757
_L0745:
; 2946.	    if (res == FR_OK) {
	LD	(IX+20),sfn & 255
	LD	(IX+21),sfn / 256
; 2947.	        INIT_BUF(*dj);
	LD	BC,(_L0744)
	PUSH	IX
	POP	DE
	CALL	follow_path
	LD	IYL,A
; 2948.	        res = follow_path(dj, path);            /* Follow the path to the directory */
; 2949.	        FREE_BUF();
	OR	A
	JR	NZ,_L0755
_L0747:
; 2950.	        if (res == FR_OK) {                     /* Follow completed */
	LD	A,(IX+18)
	OR	(IX+19)
	JR	Z,_L0753
_L0749:
; 2951.	            if (dj->dir) {                      /* It is not the root dir */
	LD	L,(IX+18)
	LD	H,(IX+19)
	LD	BC,11
	ADD	HL,BC
	BIT	4,(HL)
	JR	Z,_L0752
_L0751:
; 2952.	                if (dj->dir[DIR_Attr] & AM_DIR) {   /* The object is a directory */
	LD	E,(IX+18)
	LD	D,(IX+19)
	CALL	LD_CLUST
	LD	(IX+6),L
	LD	(IX+7),H
	LD	(IX+8),C
	LD	(IX+9),B
; 2953.	                    dj->sclust = LD_CLUST(dj->dir);
	JR	_L0753
_L0752:
; 2954.	                } else {                        /* The object is not a directory */
	LD	IYL,5
_L0753:
_L0750:
; 2955.	                    res = FR_NO_PATH;
; 2956.	                }
; 2957.	            }
	LD	B,IYL
	INC	B
	DEC	B
	JR	NZ,_L0755
_L0754:
; 2958.	            if (res == FR_OK) {
	LD	L,(IX+0)
	LD	H,(IX+1)
	LD	C,7
	ADD	HL,BC
	LD	B,(HL)
	LD	(IX+2),B
	INC	HL
	LD	H,(HL)
	LD	(IX+3),H
; 2959.	                dj->id = dj->fs->id;
	LD	BC,0
	PUSH	IX
	POP	DE
	CALL	dir_sdi
	LD	IYL,A
_L0755:
_L0748:
; 2960.	                res = dir_sdi(dj, 0);           /* Rewind dir */
; 2961.	            }
; 2962.	        }
	LD	A,IYL
	CP	4
	JR	NZ,_L0757
_L0756:
	LD	IYL,5
_L0757:
_L0746:
; 2963.	        if (res == FR_NO_FILE) res = FR_NO_PATH;
; 2964.	    }
; 2965.	
	JP	_L0028
; 2966.	    LEAVE_FF(dj->fs, res);
; 2967.	}
; 2968.	
; 2969.	
; 2970.	
; 2971.	
; 2972.	/*-----------------------------------------------------------------------*/
; 2973.	/* Read Directory Entry in Sequense                                      */
; 2974.	/*-----------------------------------------------------------------------*/
; 2975.	
; 2976.	FILINFO fno_rddir;
; 2977.	FRESULT f_readdir (
; 2978.	    DIR *dj,            /* Pointer to the open directory object */
; 2979.	    FILINFO *fno        /* Pointer to file information to return */
; 2980.	)
f_readdir:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	65534
	PUSH	IY
; 2981.	{
; 2982.	    FRESULT res;
; 2983.	    DEF_NAMEBUF;
; 2984.	
; 2985.	
	CALL	_L1186
	LD	(IX-2),A
; 2986.	    res = validate(dj->fs, dj->id);         /* Check validity of the object */
	OR	A
	JR	NZ,_L0768
_L0758:
; 2987.	    if (res == FR_OK) {
	LD	A,(IX+4)
	OR	(IX+5)
	JR	NZ,_L0761
_L0760:
; 2988.	        if (!fno) {
	LD	C,A
	LD	B,A
	PUSH	IY
	POP	DE
	CALL	dir_sdi
	JR	_L1112
; 2989.	            res = dir_sdi(dj, 0);           /* Rewind the directory object */
_L0761:
; 2990.	        } else {
	LD	(IY+20),sfn & 255
	LD	(IY+21),sfn / 256
; 2991.	            INIT_BUF(*dj);
	PUSH	IY
	POP	DE
	CALL	dir_read
	LD	(IX-2),A
; 2992.	            res = dir_read(dj);             /* Read an directory item */
	CP	4
	JR	NZ,_L0764
_L0763:
; 2993.	            if (res == FR_NO_FILE) {        /* Reached end of dir */
	XOR	A
	LD	(IY+14),A
	LD	(IY+15),A
	LD	(IY+16),A
	LD	(IY+17),A
; 2994.	                dj->sect = 0;
	LD	(IX-2),A
_L0764:
; 2995.	                res = FR_OK;
; 2996.	            }
	XOR	A
	OR	(IX-2)
	JR	NZ,_L0768
_L0765:
; 2997.	            if (res == FR_OK) {             /* A valid entry is found */
	LD	BC,fno_rddir
	PUSH	IY
	POP	DE
	CALL	get_fileinfo
; 2998.	                get_fileinfo(dj, &fno_rddir);       /* Get the object information */
	LD	BC,0
	PUSH	IY
	POP	DE
	CALL	dir_next
	LD	(IX-2),A
; 2999.	                res = dir_next(dj, 0);      /* Increment index for next */
	CP	4
	JR	NZ,_L0768
_L0767:
; 3000.	                if (res == FR_NO_FILE) {
	XOR	A
	LD	(IY+14),A
	LD	(IY+15),A
	LD	(IY+16),A
	LD	(IY+17),A
; 3001.	                    dj->sect = 0;
_L1112:
	LD	(IX-2),A
_L0768:
_L0766:
_L0762:
_L0759:
; 3002.	                    res = FR_OK;
; 3003.	                }
; 3004.	            }
; 3005.	            FREE_BUF();
; 3006.	        }
; 3007.	    }
	LD	HL,22
	PUSH	HL
	LD	BC,fno_rddir
	LD	E,(IX+4)
	LD	D,(IX+5)
	LD	HL,(drv_calls+18)
	CALL	clib_CALL_IND_L09
	POP	HL
; 3008.	    drv_calls.memcpy_lib2usp(fno,&fno_rddir,sizeof(FILINFO));
	LD	A,(IX-2)
; 3009.	    LEAVE_FF(dj->fs, res);
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 3010.	}
; 3011.	
; 3012.	
; 3013.	
; 3014.	#if _FS_MINIMIZE == 0
; 3015.	/*-----------------------------------------------------------------------*/
; 3016.	/* Get File Status                                                       */
; 3017.	/*-----------------------------------------------------------------------*/
; 3018.	
; 3019.	FRESULT f_stat (
; 3020.	    const TCHAR *path,  /* Pointer to the file path */
; 3021.	    FILINFO *fno        /* Pointer to file information to return */
; 3022.	)
f_stat:
	PUSH	BC
	PUSH	DE
; 3023.	{
; 3024.	    static FRESULT res;
; 3025.	    //DIR dj;
; 3026.	    DEF_NAMEBUF;
; 3027.	
; 3028.	
	CALL	_L1181
; 3029.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3030.	    
	LD	C,0
	CALL	_L1177
	LD	(_L0769),A
; 3031.	    res = chk_mounted(&djo.fs, 0);
	OR	A
	JR	NZ,_L0776
_L0770:
; 3032.	    if (res == FR_OK) {
; 3033.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0769),A
; 3034.	        res = follow_path(&djo, pathbuf);   /* Follow the file path */
	OR	A
	JR	NZ,_L0776
_L0772:
; 3035.	        if (res == FR_OK) {             /* Follow completed */
	LD	HL,(djo+18)
	LD	A,L
	OR	H
	JR	Z,_L0775
_L0774:
; 3036.	            if (djo.dir)        /* Found an object */
	LD	BC,fno_rddir
	LD	DE,djo
	CALL	get_fileinfo
; 3037.	                get_fileinfo(&djo, &fno_rddir);
	JR	_L0776
_L0775:
; 3038.	            else            /* It is root dir */
	LD	A,6
	LD	(_L0769),A
_L0776:
_L0773:
_L0771:
; 3039.	                res = FR_INVALID_NAME;
; 3040.	        }
; 3041.	        FREE_BUF();
; 3042.	    }
; 3043.	
	LD	HL,2
	PUSH	HL
	LD	BC,fno_rddir
	INC	HL
	INC	HL
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,(drv_calls+18)
	CALL	clib_CALL_IND_L09
	POP	HL
; 3044.	    drv_calls.memcpy_lib2usp(fno,&fno_rddir,sizeof(fno));
	LD	A,(_L0769)
; 3045.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	HL
	RET
; 3046.	}
; 3047.	
; 3048.	
; 3049.	
; 3050.	#if !_FS_READONLY
; 3051.	/*-----------------------------------------------------------------------*/
; 3052.	/* Get Number of Free Clusters                                           */
; 3053.	/*-----------------------------------------------------------------------*/
; 3054.	
; 3055.	FRESULT f_getfree (
; 3056.	    //const TCHAR *path,    /* Pointer to the logical drive number (root dir) */
; 3057.	    DWORD *nclst,       /* Pointer to the variable to return number of free clusters */
; 3058.	    FATFS **fatfs       /* Pointer to pointer to corresponding file system object to return */
; 3059.	)
f_getfree:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-6
	PUSH	IY
	EXX
	PUSH	DE
	EXX
	PUSH	BC
	POP	IY
; 3060.	{
; 3061.	    static FRESULT res;
; 3062.	    static DWORD n;
; 3063.	    static DWORD clst;
; 3064.	    static DWORD sect;
; 3065.	    DWORD stat;
; 3066.	    UINT i;
; 3067.	    BYTE fat;
; 3068.	    static BYTE *p;
; 3069.	
; 3070.	
; 3071.	    /* Get drive number */
	LD	C,0
	PUSH	IY
	POP	DE
	CALL	chk_mounted
	LD	(_L0777),A
; 3072.	    res = chk_mounted(fatfs, 0);
	OR	A
	JP	NZ,_L0786
_L0782:
; 3073.	    if (res == FR_OK) {
; 3074.	        /* If free_clust is valid, return it without full cluster scan */
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,15
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	LD	HL,65534
	POP	BC
	ADD	HL,BC
	EX	DE,HL
	LD	HL,65535
	POP	BC
	ADC	HL,BC
	EX	DE,HL
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	LD	L,(IY+0)
	LD	H,(IY+1)
	JR	C,_L0785
_L0784:
; 3075.	        if ((*fatfs)->free_clust <= (*fatfs)->n_fatent - 2) {
	LD	BC,15
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	JP	_L1116
; 3076.	            *nclst = (*fatfs)->free_clust;
_L0785:
; 3077.	        } else {
; 3078.	            /* Get number of free clusters */
	LD	B,(HL)
	LD	(IX-6),B
; 3079.	            fat = (*fatfs)->fs_type;
	LD	E,A
	LD	L,E
	LD	D,A
	LD	H,D
	LD	(_L0778),HL
	LD	(_L0778+2),DE
; 3080.	            n = 0;
	DEC	B
	JR	NZ,_L0788
_L0787:
; 3081.	            if (fat == FS_FAT12) {
	LD	C,L
	LD	B,H
	INC	HL
	INC	HL
	LD	(_L0779),HL
	LD	(_L0779+2),BC
_L0791:
; 3082.	                clst = 2;
; 3083.	                do {
	LD	HL,(_L0779+2)
	PUSH	HL
	LD	HL,(_L0779)
	PUSH	HL
	CALL	_L1166
	POP	AF
	POP	AF
; 3084.	                    stat = get_fat(*fatfs, clst);
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	LD	A,1
	JR	Z,_L1113
_L0792:
_L0793:
; 3085.	                    if (stat == 0xFFFFFFFF) { res = FR_DISK_ERR; break; }
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0795
_L0794:
	LD	A,2
_L1113:
	LD	(_L0777),A
	JR	_L0789
_L0795:
; 3086.	                    if (stat == 1) { res = FR_INT_ERR; break; }
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0797
_L0796:
	CALL	_L1167
_L0797:
; 3087.	                    if (stat == 0) n++;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	LD	HL,(_L0779)
	LD	BC,(_L0779+2)
	CALL	clib_L_INC_L03
	LD	(_L0779),HL
	LD	(_L0779+2),BC
	LD	E,C
	LD	D,B
	AND	A
	POP	BC
	SBC	HL,BC
	EX	DE,HL
	POP	BC
	SBC	HL,BC
	JR	C,_L0791
_L0789:
; 3088.	                } while (++clst < (*fatfs)->n_fatent);
	JP	_L0799
_L0788:
; 3089.	            } else {
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,27
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(_L0779),HL
	LD	(_L0779+2),BC
; 3090.	                clst = (*fatfs)->n_fatent;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,35
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(_L0780),HL
	LD	(_L0780+2),BC
; 3091.	                sect = (*fatfs)->fatbase;
	LD	L,A
	LD	H,A
	LD	(_L0781),HL
	EXX
	LD	DE,0
	EXX
_L0801:
; 3092.	                i = 0; p = 0;
; 3093.	                do {
	EXX
	LD	A,E
	OR	D
	EXX
	JR	NZ,_L0803
_L0802:
; 3094.	                    if (!i) {
	LD	HL,(_L0780)
	LD	BC,(_L0780+2)
	PUSH	BC
	PUSH	HL
	CALL	clib_L_INC_L03
	LD	(_L0780),HL
	LD	(_L0780+2),BC
	LD	E,(IY+0)
	LD	D,(IY+1)
	CALL	move_window
	POP	HL
	POP	HL
	LD	(_L0777),A
; 3095.	                        res = move_window(*fatfs, sect++);
	OR	A
	JR	NZ,_L0799
_L0804:
_L0805:
; 3096.	                        if (res != FR_OK) break;
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,51
	ADD	HL,BC
	LD	(_L0781),HL
; 3097.	                        p = (*fatfs)->win;
	EXX
	LD	DE,512
	EXX
_L0803:
; 3098.	                        i = SS(*fatfs);
; 3099.	                    }
	LD	B,(IX-6)
	DEC	B
	DEC	B
	LD	HL,(_L0781)
	JR	NZ,_L0807
_L0806:
; 3100.	                    if (fat == FS_FAT16) {
	LD	A,(HL)
	INC	HL
	OR	(HL)
	JR	NZ,_L0809
_L0808:
	CALL	_L1167
_L0809:
; 3101.	                        if (LD_WORD(p) == 0) n++;
	LD	HL,2
	LD	BC,(_L0781)
	ADD	HL,BC
	LD	(_L0781),HL
	EXX
	LD	HL,65534
	JR	_L1114
; 3102.	                        p += 2; i -= 2;
_L0807:
; 3103.	                    } else {
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	A,(HL)
	EX	DE,HL
	AND	15
	LD	B,A
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0812
_L0811:
	CALL	_L1167
_L0812:
; 3104.	                        if ((LD_DWORD(p) & 0x0FFFFFFF) == 0) n++;
	LD	HL,4
	LD	BC,(_L0781)
	ADD	HL,BC
	LD	(_L0781),HL
	EXX
	LD	HL,65532
_L1114:
	ADD	HL,DE
	EX	DE,HL
	EXX
_L0810:
; 3105.	                        p += 4; i -= 4;
; 3106.	                    }
	LD	HL,(_L0779)
	LD	BC,(_L0779+2)
	CALL	clib_L_DEC_L03
	LD	(_L0779),HL
	LD	(_L0779+2),BC
	LD	A,L
	OR	H
	OR	C
	OR	B
	JP	NZ,_L0801
_L0799:
_L0798:
; 3107.	                } while (--clst);
; 3108.	            }
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,15
	ADD	HL,BC
	LD	BC,(_L0778+2)
	LD	DE,(_L0778)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 3109.	            (*fatfs)->free_clust = n;
	LD	A,(IX-6)
	CP	3
	JR	NZ,_L0814
_L0813:
	LD	L,(IY+0)
	LD	H,(IY+1)
	LD	BC,6
	ADD	HL,BC
	LD	(HL),1
_L0814:
; 3110.	            if (fat == FS_FAT32) (*fatfs)->fsi_flag = 1;
	LD	BC,(_L0778+2)
_L1116:
	EX	DE,HL
	PUSH	HL
	LD	L,(IX+2)
	LD	H,(IX+3)
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
_L0786:
_L0783:
; 3111.	            *nclst = n;
; 3112.	        }
; 3113.	    }
	LD	A,(_L0777)
; 3114.	    LEAVE_FF(*fatfs, res);
	JP	_L1149
_L1167:
	LD	HL,(_L0778)
	LD	BC,(_L0778+2)
	CALL	clib_L_INC_L03
	LD	(_L0778),HL
	LD	(_L0778+2),BC
	RET
; 3115.	}
; 3116.	
; 3117.	
; 3118.	
; 3119.	
; 3120.	/*-----------------------------------------------------------------------*/
; 3121.	/* Truncate File                                                         */
; 3122.	/*-----------------------------------------------------------------------*/
; 3123.	
; 3124.	FRESULT f_truncate (
; 3125.	    FIL *fp     /* Pointer to the file object */
; 3126.	)
f_truncate:
	PUSH	BC
	PUSH	IY
	PUSH	IX
	PUSH	DE
	POP	IX
; 3127.	{
; 3128.	    FRESULT res;
; 3129.	    static DWORD ncl;
; 3130.	
; 3131.	
	INC	DE
	INC	DE
	LD	A,(DE)
	LD	C,A
	INC	DE
	LD	A,(DE)
	LD	B,A
	LD	E,(IX+0)
	LD	D,(IX+1)
	CALL	validate
	LD	IYL,A
; 3132.	    res = validate(fp->fs, fp->id);     /* Check validity of the object */
	OR	A
	JR	NZ,_L0822
_L0816:
; 3133.	    if (res == FR_OK) {
	LD	A,(IX+4)
	OR	A
	JP	P,_L0819
_L0818:
; 3134.	        if (fp->flag & FA__ERROR) {         /* Check abort flag */
	LD	IYL,2
; 3135.	            res = FR_INT_ERR;
	JR	_L0822
_L0819:
; 3136.	        } else {
	BIT	1,(IX+4)
	JR	NZ,_L0822
_L0821:
; 3137.	            if (!(fp->flag & FA_WRITE))     /* Check access mode */
	LD	IYL,7
_L0822:
_L0820:
_L0817:
; 3138.	                res = FR_DENIED;
; 3139.	        }
; 3140.	    }
	LD	B,IYL
	INC	B
	DEC	B
	JP	NZ,_L0841
_L0823:
; 3141.	    if (res == FR_OK) {
	AND	A
	LD	L,(IX+6)
	LD	H,(IX+7)
	LD	C,(IX+10)
	LD	B,(IX+11)
	SBC	HL,BC
	LD	L,(IX+8)
	LD	H,(IX+9)
	LD	C,(IX+12)
	LD	B,(IX+13)
	SBC	HL,BC
	JP	NC,_L0839
_L0825:
; 3142.	        if (fp->fsize > fp->fptr) {
	LD	C,(IX+8)
	LD	B,(IX+9)
	LD	L,(IX+6)
	LD	H,(IX+7)
	LD	(IX+10),L
	LD	(IX+11),H
	LD	(IX+12),C
	LD	(IX+13),B
; 3143.	            fp->fsize = fp->fptr;   /* Set file size to current R/W point */
	SET	5,(IX+4)
; 3144.	            fp->flag |= FA__WRITTEN;
	LD	A,(IX+6)
	OR	(IX+7)
	OR	(IX+8)
	OR	(IX+9)
	JR	NZ,_L0828
_L0827:
; 3145.	            if (fp->fptr == 0) {    /* When set file size to zero, remove entire cluster chain */
	LD	L,(IX+16)
	LD	H,(IX+17)
	PUSH	HL
	LD	L,(IX+14)
	LD	H,(IX+15)
	PUSH	HL
	LD	E,(IX+0)
	LD	D,(IX+1)
	CALL	remove_chain
	POP	HL
	POP	HL
	LD	IYL,A
; 3146.	                res = remove_chain(fp->fs, fp->sclust);
	XOR	A
	LD	(IX+14),A
	LD	(IX+15),A
	LD	(IX+16),A
	LD	(IX+17),A
; 3147.	                fp->sclust = 0;
	JP	_L0839
_L0828:
; 3148.	            } else {                /* When truncate a part of the file, remove remaining clusters */
	LD	L,(IX+20)
	LD	H,(IX+21)
	PUSH	HL
	LD	L,(IX+18)
	LD	H,(IX+19)
	PUSH	HL
	LD	E,(IX+0)
	LD	D,(IX+1)
	CALL	get_fat
	POP	AF
	POP	AF
	LD	(_L0815),HL
	LD	(_L0815+2),BC
; 3149.	                ncl = get_fat(fp->fs, fp->clust);
	LD	IYL,0
; 3150.	                res = FR_OK;
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	NZ,_L0831
_L0830:
	LD	IYL,1
_L0831:
; 3151.	                if (ncl == 0xFFFFFFFF) res = FR_DISK_ERR;
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0833
_L0832:
	LD	IYL,2
_L0833:
; 3152.	                if (ncl == 1) res = FR_INT_ERR;
	LD	B,IYL
	INC	B
	DEC	B
	JR	NZ,_L0839
	LD	L,(IX+0)
	LD	H,(IX+1)
	LD	C,27
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	PUSH	BC
	AND	A
	LD	HL,(_L0815)
	POP	BC
	SBC	HL,BC
	LD	HL,(_L0815+2)
	POP	BC
	SBC	HL,BC
	JR	NC,_L0839
_L0837:
_L0836:
_L0834:
; 3153.	                if (res == FR_OK && ncl < fp->fs->n_fatent) {
	LD	HL,4095
	PUSH	HL
	LD	H,L
	PUSH	HL
	LD	L,(IX+20)
	LD	H,(IX+21)
	PUSH	HL
	LD	L,(IX+18)
	LD	H,(IX+19)
	PUSH	HL
	LD	E,(IX+0)
	LD	D,(IX+1)
	CALL	put_fat
	POP	HL
	POP	HL
	POP	HL
	POP	HL
	LD	IYL,A
; 3154.	                    res = put_fat(fp->fs, fp->clust, 0x0FFFFFFF);
	OR	A
	JR	NZ,_L0839
_L0838:
	LD	HL,(_L0815+2)
	PUSH	HL
	LD	HL,(_L0815)
	PUSH	HL
	LD	E,(IX+0)
	LD	D,(IX+1)
	CALL	remove_chain
	POP	HL
	POP	HL
	LD	IYL,A
_L0839:
_L0835:
_L0829:
_L0826:
; 3155.	                    if (res == FR_OK) res = remove_chain(fp->fs, ncl);
; 3156.	                }
; 3157.	            }
; 3158.	        }
	LD	B,IYL
	INC	B
	DEC	B
	JR	Z,_L0841
_L0840:
	SET	7,(IX+4)
_L0841:
_L0824:
; 3159.	        if (res != FR_OK) fp->flag |= FA__ERROR;
; 3160.	    }
; 3161.	
	JP	_L0028
; 3162.	    LEAVE_FF(fp->fs, res);
; 3163.	}
; 3164.	
; 3165.	
; 3166.	
; 3167.	
; 3168.	/*-----------------------------------------------------------------------*/
; 3169.	/* Delete a File or Directory                                            */
; 3170.	/*-----------------------------------------------------------------------*/
; 3171.	
; 3172.	FRESULT f_unlink (
; 3173.	    const TCHAR *path       /* Pointer to the file or directory path */
; 3174.	)
f_unlink:
	PUSH	BC
	PUSH	DE
; 3175.	{
; 3176.	    static FRESULT res;
; 3177.	    //DIR dj, sdj;
; 3178.	    static BYTE *dir;
; 3179.	    static DWORD dclst;
; 3180.	    DEF_NAMEBUF;
; 3181.	
	LD	C,E
	LD	B,D
; 3182.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3183.	    
	CALL	_L1178
	LD	(_L0842),A
; 3184.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JP	NZ,_L0880
_L0845:
; 3185.	    if (res == FR_OK) {
; 3186.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0842),A
; 3187.	        res = follow_path(&djo, pathbuf);       /* Follow the file path */
	OR	A
	JR	NZ,_L0848
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0848
_L0850:
_L0849:
_L0847:
; 3188.	        if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0842),A
_L0848:
; 3189.	            res = FR_INVALID_NAME;          /* Cannot remove dot entry */
; 3190.	#if _FS_SHARE
; 3192.	#endif
	OR	A
	JP	NZ,_L0880
_L0851:
; 3193.	        if (res == FR_OK) {                 /* The object is accessible */
	LD	HL,(djo+18)
	LD	(_L0843),HL
; 3194.	            dir = djo.dir;
	LD	A,L
	OR	H
	JR	NZ,_L0854
_L0853:
; 3195.	            if (!dir) {
	LD	A,6
	JR	_L1124
; 3196.	                res = FR_INVALID_NAME;      /* Cannot remove the start directory */
_L0854:
; 3197.	            } else {
	LD	HL,11
	LD	BC,(_L0843)
	ADD	HL,BC
	BIT	0,(HL)
	JR	Z,_L0857
_L0856:
; 3198.	                if (dir[DIR_Attr] & AM_RDO)
	LD	A,7
_L1124:
	LD	(_L0842),A
_L0857:
_L0855:
; 3199.	                    res = FR_DENIED;        /* Cannot remove R/O object */
; 3200.	            }
	LD	DE,(_L0843)
	CALL	LD_CLUST
	LD	(_L0844),HL
	LD	(_L0844+2),BC
; 3201.	            dclst = LD_CLUST(dir);
	LD	A,(_L0842)
	OR	A
	JR	NZ,_L0872
	LD	HL,11
	LD	BC,(_L0843)
	ADD	HL,BC
	BIT	4,(HL)
	JR	Z,_L0872
_L0861:
_L0860:
_L0858:
; 3202.	            if (res == FR_OK && (dir[DIR_Attr] & AM_DIR)) { /* Is it a sub-dir? */
	AND	A
	LD	HL,(_L0844)
	LD	BC,2
	SBC	HL,BC
	LD	HL,(_L0844+2)
	DEC	BC
	DEC	BC
	SBC	HL,BC
	JR	NC,_L0863
_L0862:
; 3203.	                if (dclst < 2) {
	LD	A,2
	JR	_L1125
; 3204.	                    res = FR_INT_ERR;
_L0863:
; 3205.	                } else {
	LD	C,22
	LD	DE,djn
	LD	HL,djo
	LDIR
; 3206.	                    memcpy(&djn, &djo, sizeof(DIR));    /* Check if the sub-dir is empty or not */
	LD	BC,(_L0844+2)
	LD	HL,(_L0844)
	LD	(djn+6),HL
	LD	(djn+8),BC
; 3207.	                    djn.sclust = dclst;
	LD	BC,2
	LD	DE,djn
	CALL	dir_sdi
	LD	(_L0842),A
; 3208.	                    res = dir_sdi(&djn, 2);     /* Exclude dot entries */
	OR	A
	JR	NZ,_L0872
_L0865:
; 3209.	                    if (res == FR_OK) {
	LD	DE,djn
	CALL	dir_read
	LD	(_L0842),A
; 3210.	                        res = dir_read(&djn);
; 3211.	                        if (res == FR_OK            /* Not empty dir */
; 3212.	#if _FS_RPATH
; 3213.	                        || dclst == drv_calls.curr_dir      /*sdj.fs->cdir   Current dir */
; 3214.	#endif
	OR	A
	JR	Z,_L0869
	LD	HL,(_L0844)
	LD	BC,(drv_calls+34)
	AND	A
	SBC	HL,BC
	JR	NZ,_L0868
	LD	HL,(_L0844+2)
	LD	BC,(drv_calls+36)
	SBC	HL,BC
	JR	NZ,_L0868
_L0869:
_L0870:
_L0867:
	LD	A,7
	LD	(_L0842),A
_L0868:
; 3215.	                        ) res = FR_DENIED;
	CP	4
	JR	NZ,_L0872
_L0871:
	XOR	A
_L1125:
	LD	(_L0842),A
_L0872:
_L0866:
_L0864:
_L0859:
; 3216.	                        if (res == FR_NO_FILE) res = FR_OK; /* Empty */
; 3217.	                    }
; 3218.	                }
; 3219.	            }
	OR	A
	JR	NZ,_L0880
_L0873:
; 3220.	            if (res == FR_OK) {
	LD	DE,djo
	CALL	dir_remove
	LD	(_L0842),A
; 3221.	                res = dir_remove(&djo);     /* Remove the directory entry */
	OR	A
	JR	NZ,_L0880
_L0875:
; 3222.	                if (res == FR_OK) {
	LD	HL,(_L0844)
	LD	A,L
	OR	H
	LD	HL,(_L0844+2)
	OR	L
	OR	H
	JR	Z,_L0878
_L0877:
; 3223.	                    if (dclst)              /* Remove the cluster chain if exist */
	PUSH	HL
	LD	HL,(_L0844)
	PUSH	HL
	CALL	_L1184
	POP	HL
	POP	HL
	LD	(_L0842),A
_L0878:
; 3224.	                        res = remove_chain(djo.fs, dclst);
	LD	A,(_L0842)
	OR	A
	JR	NZ,_L0880
_L0879:
	CALL	_L1187
	LD	(_L0842),A
_L0880:
_L0876:
_L0874:
_L0852:
_L0846:
; 3225.	                    if (res == FR_OK) res = sync(djo.fs);
; 3226.	                }
; 3227.	            }
; 3228.	        }
; 3229.	        FREE_BUF();
; 3230.	    }
; 3231.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	BC
	RET
_L1188:
	LD	HL,5
	LD	BC,(djo)
	ADD	HL,BC
	LD	(HL),1
_L1187:
	LD	DE,(djo)
	JP	sync
; 3232.	}
; 3233.	
; 3234.	
; 3235.	
; 3236.	
; 3237.	/*-----------------------------------------------------------------------*/
; 3238.	/* Create a Directory                                                    */
; 3239.	/*-----------------------------------------------------------------------*/
; 3240.	
; 3241.	FRESULT f_mkdir (
; 3242.	    const TCHAR *path       /* Pointer to the directory path */
; 3243.	)
f_mkdir:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-2
	PUSH	IY
; 3244.	{
; 3245.	    static FRESULT res;
; 3246.	    //DIR dj;
; 3247.	    BYTE *dir;
; 3248.	    BYTE n;
; 3249.	    static DWORD dsc;
; 3250.	    static DWORD dcl;
; 3251.	    static DWORD pcl;
; 3252.	    static DWORD tim;
; 3253.	    DEF_NAMEBUF;
	LD	DE,_L0885
	LD	HL,(drv_calls+12)
	CALL	clib_CALL_IND_L09
; 3254.	    get_fattime(&tim);
; 3255.	
; 3256.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3257.	    
	CALL	_L1179
	LD	(_L0881),A
; 3258.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JP	NZ,_L0920
_L0886:
; 3259.	    if (res == FR_OK) {
; 3260.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0881),A
; 3261.	        res = follow_path(&djo, pathbuf);           /* Follow the file path */
	OR	A
	JR	NZ,_L0889
_L0888:
	LD	A,8
	LD	(_L0881),A
_L0889:
; 3262.	        if (res == FR_OK) res = FR_EXIST;       /* Any object with same name is already existing */
	CP	4
	JR	NZ,_L0891
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0891
_L0893:
_L0892:
_L0890:
; 3263.	        if (_FS_RPATH && res == FR_NO_FILE && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0881),A
_L0891:
; 3264.	            res = FR_INVALID_NAME;
	CP	4
	JP	NZ,_L0920
_L0894:
; 3265.	        if (res == FR_NO_FILE) {                /* Can create a new directory */
	LD	HL,0
	PUSH	HL
	PUSH	HL
	LD	DE,(djo)
	CALL	create_chain
	POP	AF
	POP	AF
	LD	(_L0883),HL
	LD	(_L0883+2),BC
; 3266.	            dcl = create_chain(djo.fs, 0);      /* Allocate a cluster for the new directory table */
	XOR	A
	LD	(_L0881),A
; 3267.	            res = FR_OK;
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0897
_L0896:
	LD	A,7
	LD	(_L0881),A
_L0897:
; 3268.	            if (dcl == 0) res = FR_DENIED;      /* No space to allocate a new cluster */
	LD	A,1
	XOR	L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0899
_L0898:
	LD	A,2
	LD	(_L0881),A
_L0899:
; 3269.	            if (dcl == 1) res = FR_INT_ERR;
	LD	A,L
	AND	H
	AND	C
	AND	B
	INC	A
	JR	NZ,_L0901
_L0900:
	LD	A,1
	LD	(_L0881),A
_L0901:
; 3270.	            if (dcl == 0xFFFFFFFF) res = FR_DISK_ERR;
	LD	A,(_L0881)
	OR	A
	JR	NZ,_L0903
_L0902:
; 3271.	            if (res == FR_OK)                   /* Flush FAT */
	LD	L,A
	LD	H,A
	PUSH	HL
	PUSH	HL
	LD	DE,(djo)
	CALL	move_window
	POP	HL
	POP	HL
	LD	(_L0881),A
_L0903:
; 3272.	                res = move_window(djo.fs, 0);
	OR	A
	JP	NZ,_L0910
_L0904:
; 3273.	            if (res == FR_OK) {                 /* Initialize the new directory table */
	PUSH	BC
	LD	HL,(_L0883)
	PUSH	HL
	LD	DE,(djo)
	CALL	clust2sect
	POP	AF
	POP	AF
	LD	(_L0882),HL
	LD	(_L0882+2),BC
; 3274.	                dsc = clust2sect(djo.fs, dcl);
	LD	HL,51
	LD	BC,(djo)
	ADD	HL,BC
	PUSH	HL
	POP	IY
; 3275.	                dir = djo.fs->win;
	LD	BC,512
	EX	DE,HL
	LD	L,C
	LD	H,C
	CALL	clib_MEMSET_L11
; 3276.	                memset(dir, 0, SS(djo.fs));
	LD	BC,11
	LD	L,32
	CALL	clib_MEMSET_L11
; 3277.	                memset(dir+DIR_Name, ' ', 8+3); /* Create "." entry */
	EX	DE,HL
	LD	(HL),46
; 3278.	                dir[DIR_Name] = '.';
	LD	(IY+11),16
; 3279.	                dir[DIR_Attr] = AM_DIR;
	LD	BC,(_L0885+2)
	LD	HL,(_L0885)
	LD	(IY+22),L
	LD	(IY+23),H
	LD	(IY+24),C
	LD	(IY+25),B
; 3280.	                ST_DWORD(dir+DIR_WrtTime, tim);
	LD	HL,(_L0883)
	LD	(IY+26),L
	LD	(IY+27),H
	LD	HL,(_L0883+2)
	LD	(IY+20),L
	LD	(IY+21),H
; 3281.	                ST_CLUST(dir, dcl);
	LD	C,E
	LD	L,C
	LD	B,D
	LD	H,B
	PUSH	IY
	POP	DE
	ADD	HL,DE
	EX	DE,HL
	PUSH	IY
	POP	HL
	LDIR
; 3282.	                memcpy(dir+SZ_DIR, dir, SZ_DIR);    /* Create ".." entry */
	LD	(IY+33),46
	LD	HL,djo+6
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
	LD	(_L0884),HL
	LD	(_L0884+2),BC
; 3283.	                dir[33] = '.'; pcl = djo.sclust;
	LD	HL,(djo)
	LD	A,(HL)
	CP	3
	JR	NZ,_L0907
	LD	HL,39
	LD	BC,(djo)
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	L,C
	LD	H,B
	LD	BC,(_L0884)
	AND	A
	SBC	HL,BC
	JR	NZ,_L0907
	EX	DE,HL
	LD	BC,(_L0884+2)
	SBC	HL,BC
	JR	NZ,_L0907
_L0909:
_L0908:
_L0906:
; 3284.	                if (djo.fs->fs_type == FS_FAT32 && pcl == djo.fs->dirbase)
	LD	C,L
	LD	B,H
	LD	(_L0884),HL
	LD	(_L0884+2),BC
_L0907:
; 3285.	                    pcl = 0;
	LD	HL,(_L0884)
	LD	(IY+58),L
	LD	(IY+59),H
	LD	HL,(_L0884+2)
	LD	(IY+52),L
	LD	(IY+53),H
; 3286.	                ST_CLUST(dir+SZ_DIR, pcl);
	LD	HL,(djo)
	INC	HL
	INC	HL
	INC	HL
	LD	B,(HL)
	LD	(IX-2),B
_L0911:
	XOR	A
	OR	(IX-2)
	JR	Z,_L0910
_L0912:
; 3287.	                for (n = djo.fs->csize; n; n--) {   /* Write dot entries and clear following sectors */
	LD	HL,47
	LD	BC,(djo)
	ADD	HL,BC
	PUSH	HL
	LD	HL,(_L0882)
	LD	BC,(_L0882+2)
	PUSH	BC
	PUSH	HL
	CALL	clib_L_INC_L03
	LD	(_L0882),HL
	LD	(_L0882+2),BC
	POP	DE
	POP	BC
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),C
	INC	HL
	LD	(HL),B
; 3288.	                    djo.fs->winsect = dsc++;
	LD	HL,5
	LD	BC,(djo)
	ADD	HL,BC
	LD	(HL),1
; 3289.	                    djo.fs->wflag = 1;
	LD	HL,0
	PUSH	HL
	PUSH	HL
	LD	DE,(djo)
	CALL	move_window
	POP	HL
	POP	HL
	LD	(_L0881),A
; 3290.	                    res = move_window(djo.fs, 0);
	OR	A
	JR	NZ,_L0910
_L0914:
_L0915:
; 3291.	                    if (res != FR_OK) break;
	LD	BC,512
	PUSH	IY
	POP	DE
	LD	L,C
	CALL	clib_MEMSET_L11
	DEC	(IX-2)
; 3292.	                    memset(dir, 0, SS(djo.fs));
; 3293.	                }
	JR	_L0911
_L0910:
_L0905:
; 3294.	            }
	LD	A,(_L0881)
	OR	A
	JR	NZ,_L0917
_L0916:
	LD	DE,djo
	CALL	dir_register
	LD	(_L0881),A
_L0917:
; 3295.	            if (res == FR_OK) res = dir_register(&djo); /* Register the object to the directoy */
	OR	A
	JR	Z,_L0919
_L0918:
; 3296.	            if (res != FR_OK) {
	LD	HL,(_L0883+2)
	PUSH	HL
	LD	HL,(_L0883)
	PUSH	HL
	CALL	_L1184
	POP	HL
	POP	HL
; 3297.	                remove_chain(djo.fs, dcl);          /* Could not register, remove cluster chain */
	JR	_L0920
_L0919:
; 3298.	            } else {
	LD	IY,(djo+18)
; 3299.	                dir = djo.dir;
	LD	(IY+11),16
; 3300.	                dir[DIR_Attr] = AM_DIR;             /* Attribute */
	LD	BC,(_L0885+2)
	LD	HL,(_L0885)
	LD	(IY+22),L
	LD	(IY+23),H
	LD	(IY+24),C
	LD	(IY+25),B
; 3301.	                ST_DWORD(dir+DIR_WrtTime, tim);     /* Created time */
	LD	HL,(_L0883)
	LD	(IY+26),L
	LD	(IY+27),H
	LD	HL,(_L0883+2)
	LD	(IY+20),L
	LD	(IY+21),H
; 3302.	                ST_CLUST(dir, dcl);                 /* Table start cluster */
; 3303.	                djo.fs->wflag = 1;
	CALL	_L1188
	LD	(_L0881),A
_L0920:
_L0895:
_L0887:
; 3304.	                res = sync(djo.fs);
; 3305.	            }
; 3306.	        }
; 3307.	        FREE_BUF();
; 3308.	    }
; 3309.	
	LD	A,(_L0881)
; 3310.	    LEAVE_FF(djo.fs, res);
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 3311.	}
; 3312.	
; 3313.	
; 3314.	
; 3315.	
; 3316.	/*-----------------------------------------------------------------------*/
; 3317.	/* Change Attribute                                                      */
; 3318.	/*-----------------------------------------------------------------------*/
; 3319.	
; 3320.	FRESULT f_chmod (
; 3321.	    const TCHAR *path,  /* Pointer to the file path */
; 3322.	    BYTE value,         /* Attribute bits */
; 3323.	    BYTE mask           /* Attribute mask to change */
; 3324.	)
f_chmod:
	PUSH	IX
	PUSH	BC
	PUSH	DE
; 3325.	{
; 3326.	    static FRESULT res;
; 3327.	    //DIR dj;
; 3328.	    BYTE *dir;
; 3329.	    DEF_NAMEBUF;
; 3330.	
	LD	C,E
	LD	B,D
; 3331.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3332.	
	CALL	_L1178
	LD	(_L0921),A
; 3333.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JR	NZ,_L0932
_L0922:
; 3334.	    if (res == FR_OK) {
; 3335.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0921),A
; 3336.	        res = follow_path(&djo, pathbuf);       /* Follow the file path */
; 3337.	        FREE_BUF();
	OR	A
	JR	NZ,_L0925
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0925
_L0927:
_L0926:
_L0924:
; 3338.	        if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0921),A
_L0925:
; 3339.	            res = FR_INVALID_NAME;
	OR	A
	JR	NZ,_L0932
_L0928:
; 3340.	        if (res == FR_OK) {
	LD	IX,(djo+18)
; 3341.	            dir = djo.dir;
	LD	A,IXL
	OR	IXH
	JR	NZ,_L0931
_L0930:
; 3342.	            if (!dir) {                     /* Is it a root directory? */
	LD	A,6
	JR	_L1131
; 3343.	                res = FR_INVALID_NAME;
_L0931:
; 3344.	            } else {                        /* File or sub directory */
	LD	HL,8
	ADD	HL,SP
	LD	A,(HL)
	AND	39
	LD	(HL),A
; 3345.	                mask &= AM_RDO|AM_HID|AM_SYS|AM_ARC;    /* Valid attribute mask */
	LD	HL,2
	ADD	HL,SP
	AND	(HL)
	PUSH	AF
	LD	HL,10
	ADD	HL,SP
	LD	A,(HL)
	CPL
	AND	(IX+11)
	LD	B,A
	POP	AF
	OR	B
	LD	(IX+11),A
; 3346.	                dir[DIR_Attr] = (value & mask) | (dir[DIR_Attr] & (BYTE)~mask); /* Apply attribute change */
; 3347.	                djo.fs->wflag = 1;
	CALL	_L1188
_L1131:
	LD	(_L0921),A
_L0932:
_L0929:
_L0923:
; 3348.	                res = sync(djo.fs);
; 3349.	            }
; 3350.	        }
; 3351.	    }
; 3352.	
; 3353.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	HL
	POP	IX
	RET
; 3354.	}
; 3355.	
; 3356.	
; 3357.	
; 3358.	
; 3359.	/*-----------------------------------------------------------------------*/
; 3360.	/* Change Timestamp                                                      */
; 3361.	/*-----------------------------------------------------------------------*/
; 3362.	
; 3363.	FRESULT f_utime (
; 3364.	    const TCHAR *path,  /* Pointer to the file/directory name */
; 3365.	    //const FILINFO *fno    /* Pointer to the time stamp to be set */
; 3366.	    WORD fdate, /* Value to the date stamp to be set */
; 3367.	    WORD ftime  /* Value to the time stamp to be set */
; 3368.	)
f_utime:
	CALL	clib_ENT_PARM_DIRECT_L09
; 3369.	{
; 3370.	    static FRESULT res;
; 3371.	    //DIR dj;
; 3372.	    static BYTE *dir;
; 3373.	    DEF_NAMEBUF;
; 3374.	
	LD	C,E
	LD	B,D
; 3375.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3376.	
	CALL	_L1178
	LD	(_L0933),A
; 3377.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JR	NZ,_L0945
_L0935:
; 3378.	    if (res == FR_OK) {
; 3379.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0933),A
; 3380.	        res = follow_path(&djo, pathbuf);   /* Follow the file path */
; 3381.	        FREE_BUF();
	OR	A
	JR	NZ,_L0938
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0938
_L0940:
_L0939:
_L0937:
; 3382.	        if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0933),A
_L0938:
; 3383.	            res = FR_INVALID_NAME;
	OR	A
	JR	NZ,_L0945
_L0941:
; 3384.	        if (res == FR_OK) {
	LD	HL,(djo+18)
	LD	(_L0934),HL
; 3385.	            dir = djo.dir;
	LD	A,L
	OR	H
	JR	NZ,_L0944
_L0943:
; 3386.	            if (!dir) {                 /* Root directory */
	LD	A,6
	JR	_L1133
; 3387.	                res = FR_INVALID_NAME;
_L0944:
; 3388.	            } else {                    /* File or sub-directory */
	LD	HL,22
	LD	BC,(_L0934)
	ADD	HL,BC
	LD	E,(IX+8)
	LD	(HL),E
	LD	D,(IX+9)
	INC	HL
	LD	(HL),D
; 3389.	                ST_WORD(dir+DIR_WrtTime, ftime);
	LD	HL,24
	ADD	HL,BC
	LD	C,(IX+4)
	LD	(HL),C
	LD	B,(IX+5)
	INC	HL
	LD	(HL),B
; 3390.	                ST_WORD(dir+DIR_WrtDate, fdate);
; 3391.	                djo.fs->wflag = 1;
	CALL	_L1188
_L1133:
	LD	(_L0933),A
_L0945:
_L0942:
_L0936:
; 3392.	                res = sync(djo.fs);
; 3393.	            }
; 3394.	        }
; 3395.	    }
; 3396.	
; 3397.	    LEAVE_FF(djo.fs, res);
	JP	clib_LEAVE_DIRECT_L09
; 3398.	}
; 3399.	
; 3400.	
; 3401.	FRESULT f_getutime (
; 3402.	    const TCHAR *path,  /* Pointer to the file/directory name */
; 3403.	    //const FILINFO *fno    /* Pointer to the time stamp to be set */
; 3404.	    WORD *ftimedate /* Value to the date stamp to be set */
; 3405.	)
f_getutime:
	PUSH	IX
	PUSH	DE
	PUSH	BC
	POP	IX
; 3406.	{
; 3407.	    static FRESULT res;
; 3408.	    //DIR dj;
; 3409.	    static BYTE *dir;
; 3410.	    DEF_NAMEBUF;
; 3411.	
	LD	C,E
	LD	B,D
; 3412.	    drv_calls.strcpy_usp2lib(pathbuf,path);
; 3413.	
	CALL	_L1178
	LD	(_L0946),A
; 3414.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JR	NZ,_L0958
_L0948:
; 3415.	    if (res == FR_OK) {
; 3416.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0946),A
; 3417.	        res = follow_path(&djo, pathbuf);   /* Follow the file path */
; 3418.	        FREE_BUF();
	OR	A
	JR	NZ,_L0951
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0951
_L0953:
_L0952:
_L0950:
; 3419.	        if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0946),A
_L0951:
; 3420.	            res = FR_INVALID_NAME;
	OR	A
	JR	NZ,_L0958
_L0954:
; 3421.	        if (res == FR_OK) {
	LD	HL,(djo+18)
	LD	(_L0947),HL
; 3422.	            dir = djo.dir;
	LD	A,L
	OR	H
	JR	NZ,_L0957
_L0956:
; 3423.	            if (!dir) {                 /* Root directory */
	LD	A,6
	JR	_L1139
; 3424.	                res = FR_INVALID_NAME;
_L0957:
; 3425.	            } else {                    /* File or sub-directory */
; 3426.	                //drv_calls.memcpy_lib2usp(ftimedate,dir+DIR_WrtTime,4); //not userspace!!!
	LD	HL,22
	LD	BC,(_L0947)
	ADD	HL,BC
	LD	D,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,D
	PUSH	HL
	PUSH	IX
	POP	DE
	EX	DE,HL
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
; 3427.	                *ftimedate = LD_WORD(dir+DIR_WrtTime);
	LD	HL,24
	ADD	HL,BC
	LD	B,(HL)
	LD	(IX+2),B
	INC	HL
	LD	H,(HL)
	LD	(IX+3),H
; 3428.	                *(ftimedate+1) = LD_WORD(dir+DIR_WrtDate);
; 3429.	                djo.fs->wflag = 1;
	CALL	_L1188
_L1139:
	LD	(_L0946),A
_L0958:
_L0955:
_L0949:
; 3430.	                res = sync(djo.fs);
; 3431.	            }
; 3432.	        }
; 3433.	    }
; 3434.	
; 3435.	    LEAVE_FF(djo.fs, res);
	POP	HL
	POP	IX
	RET
; 3436.	}
; 3437.	
; 3438.	
; 3439.	
; 3440.	/*-----------------------------------------------------------------------*/
; 3441.	/* Rename File/Directory                                                 */
; 3442.	/*-----------------------------------------------------------------------*/
; 3443.	
; 3444.	FRESULT f_rename (
; 3445.	    const TCHAR *path_old,  /* Pointer to the old name */
; 3446.	    const TCHAR *path_new   /* Pointer to the new name */
; 3447.	)
f_rename:
	CALL	clib_ENT_AUTO_DIRECT_L09
	DEFW	-4
	PUSH	IY
; 3448.	{
; 3449.	    static FRESULT res;
; 3450.	    //DIR djo, djn;
; 3451.	    static BYTE buf[21];
; 3452.	    BYTE *dir;
; 3453.	    DWORD dw;
; 3454.	    DEF_NAMEBUF;
; 3455.	
; 3456.	    drv_calls.strcpy_usp2lib(pathbuf,path_old);
; 3457.	
	CALL	_L1179
	LD	(_L0959),A
; 3458.	    res = chk_mounted(&djo.fs, 1);
	OR	A
	JP	NZ,_L0998
_L0961:
; 3459.	    if (res == FR_OK) {
	LD	HL,(djo)
	LD	(djn),HL
; 3460.	        djn.fs = djo.fs;
; 3461.	        INIT_BUF(djo);
	CALL	_L1183
	LD	(_L0959),A
; 3462.	        res = follow_path(&djo, pathbuf);       /* Check old object */
	OR	A
	JR	NZ,_L0964
	LD	HL,(djo+20)
	LD	BC,11
	ADD	HL,BC
	BIT	5,(HL)
	JR	Z,_L0964
_L0966:
_L0965:
_L0963:
; 3463.	        if (_FS_RPATH && res == FR_OK && (djo.fn[NS] & NS_DOT))
	LD	A,6
	LD	(_L0959),A
_L0964:
; 3464.	            res = FR_INVALID_NAME;
; 3465.	#if _FS_SHARE
; 3467.	#endif
	OR	A
	JP	NZ,_L0998
_L0967:
; 3468.	        if (res == FR_OK) {                     /* Old object is found */
	LD	HL,(djo+18)
	LD	A,L
	OR	H
	JR	NZ,_L0970
_L0969:
; 3469.	            if (!djo.dir) {                     /* Is root dir? */
	LD	A,4
	JP	_L1142
; 3470.	                res = FR_NO_FILE;
_L0970:
; 3471.	            } else {
	LD	BC,21
	LD	DE,_L0960
	LD	C,11
	ADD	HL,BC
	LD	C,21
	LDIR
; 3472.	                memcpy(buf, djo.dir+DIR_Attr, 21);      /* Save the object information except for name */
	LD	C,22
	LD	DE,djn
	LD	HL,djo
	LDIR
; 3473.	                memcpy(&djn, &djo, sizeof(DIR));        /* Check new object */
	LD	C,(IX+4)
	LD	B,(IX+5)
	CALL	_L1180
; 3474.	                drv_calls.strcpy_usp2lib(pathbuf,path_new);
	LD	BC,pathbuf
	LD	DE,djn
	CALL	follow_path
	LD	(_L0959),A
; 3475.	                res = follow_path(&djn, pathbuf);
	OR	A
	JR	NZ,_L0973
_L0972:
	LD	A,8
	LD	(_L0959),A
_L0973:
; 3476.	                if (res == FR_OK) res = FR_EXIST;       /* The new object name is already existing */
	CP	4
	JP	NZ,_L0998
_L0974:
; 3477.	                if (res == FR_NO_FILE) {                /* Is it a valid path and no name collision? */
; 3478.	/* Start critical section that any interruption or error can cause cross-link */
	LD	DE,djn
	CALL	dir_register
	LD	(_L0959),A
; 3479.	                    res = dir_register(&djn);           /* Register the new entry */
	OR	A
	JP	NZ,_L0998
_L0976:
; 3480.	                    if (res == FR_OK) {
	LD	IY,(djn+18)
; 3481.	                        dir = djn.dir;                  /* Copy object information except for name */
	LD	BC,19
	LD	HL,13
	PUSH	IY
	POP	DE
	ADD	HL,DE
	EX	DE,HL
	LD	HL,_L0960+2
	LDIR
; 3482.	                        memcpy(dir+13, buf+2, 19);
	LD	A,(_L0960)
	SET	5,A
	LD	(IY+11),A
; 3483.	                        dir[DIR_Attr] = buf[0] | AM_ARC;
	LD	HL,5
	LD	BC,(djo)
	ADD	HL,BC
	LD	(HL),1
; 3484.	                        djo.fs->wflag = 1;
	LD	HL,(djo+6)
	LD	BC,(djn+6)
	AND	A
	SBC	HL,BC
	JR	NZ,_L1141
	LD	HL,(djo+8)
	LD	BC,(djn+8)
	SBC	HL,BC
	JP	Z,_L0986
_L1141:
	BIT	4,(IY+11)
	JP	Z,_L0986
_L0981:
_L0980:
_L0978:
; 3485.	                        if (djo.sclust != djn.sclust && (dir[DIR_Attr] & AM_DIR)) {     /* Update .. entry in the directory if needed */
	PUSH	IY
	POP	DE
	CALL	LD_CLUST
	PUSH	BC
	PUSH	HL
	LD	DE,(djn)
	CALL	clust2sect
	POP	AF
	POP	AF
; 3486.	                            dw = clust2sect(djn.fs, LD_CLUST(dir));
	LD	A,L
	OR	H
	OR	C
	OR	B
	JR	NZ,_L0983
_L0982:
; 3487.	                            if (!dw) {
	LD	A,2
	LD	(_L0959),A
; 3488.	                                res = FR_INT_ERR;
	JR	_L0986
_L0983:
; 3489.	                            } else {
	PUSH	BC
	PUSH	HL
	LD	DE,(djn)
	CALL	move_window
	POP	HL
	POP	HL
	LD	(_L0959),A
; 3490.	                                res = move_window(djn.fs, dw);
	LD	HL,51
	LD	BC,(djn)
	ADD	HL,BC
	LD	BC,32
	ADD	HL,BC
	PUSH	HL
	POP	IY
; 3491.	                                dir = djn.fs->win+SZ_DIR;   /* .. entry */
	OR	A
	JR	NZ,_L0986
	LD	A,(IY+1)
	CP	46
	JR	NZ,_L0986
_L0988:
_L0987:
_L0985:
; 3492.	                                if (res == FR_OK && dir[1] == '.') {
	LD	HL,(djn)
	LD	A,(HL)
	CP	3
	JR	NZ,_L0992
	LD	HL,39
	LD	BC,(djn)
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	L,C
	LD	H,B
	LD	BC,(djn+6)
	AND	A
	SBC	HL,BC
	JR	NZ,_L0992
	EX	DE,HL
	LD	BC,(djn+8)
	SBC	HL,BC
	JR	NZ,_L0992
	LD	C,L
	LD	B,H
	JR	_L0993
_L0992:
	LD	HL,djn+6
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	EX	DE,HL
_L0993:
; 3493.	                                    dw = (djn.fs->fs_type == FS_FAT32 && djn.sclust == djn.fs->dirbase) ? 0 : djn.sclust;
	LD	(IY+26),L
	LD	(IY+27),H
	LD	(IY+20),C
	LD	(IY+21),B
; 3494.	                                    ST_CLUST(dir, dw);
	LD	HL,5
	LD	BC,(djn)
	ADD	HL,BC
	LD	(HL),1
_L0986:
_L0984:
_L0979:
; 3495.	                                    djn.fs->wflag = 1;
; 3496.	                                }
; 3497.	                            }
; 3498.	                        }
	LD	A,(_L0959)
	OR	A
	JR	NZ,_L0998
_L0995:
; 3499.	                        if (res == FR_OK) {
	LD	DE,djo
	CALL	dir_remove
	LD	(_L0959),A
; 3500.	                            res = dir_remove(&djo);     /* Remove old entry */
	OR	A
	JR	NZ,_L0998
_L0997:
; 3501.	                            if (res == FR_OK)
	CALL	_L1187
_L1142:
	LD	(_L0959),A
_L0998:
_L0996:
_L0977:
_L0975:
_L0971:
_L0968:
_L0962:
; 3502.	                                res = sync(djo.fs);
; 3503.	                        }
; 3504.	                    }
; 3505.	/* End critical section */
; 3506.	                }
; 3507.	            }
; 3508.	        }
; 3509.	        FREE_BUF();
; 3510.	    }
; 3511.	    LEAVE_FF(djo.fs, res);
	POP	IY
	JP	clib_LEAVE_DIRECT_L09
; 3512.	}
; 3513.	
; 3514.	#endif /* !_FS_READONLY */
; 3515.	#endif /* _FS_MINIMIZE == 0 */
; 3516.	#endif /* _FS_MINIMIZE <= 1 */
; 3517.	#endif /* _FS_MINIMIZE <= 2 */
; 3518.	
; 3519.	
; 3520.	
; 3521.	/*-----------------------------------------------------------------------*/
; 3522.	/* Forward data to the stream directly (available on only tiny cfg)      */
; 3523.	/*-----------------------------------------------------------------------*/
; 3524.	#if _USE_FORWARD && _FS_TINY
; 3577.	#endif /* _USE_FORWARD */
; 3578.	
; 3579.	
; 3580.	
; 3581.	#if _USE_MKFS && !_FS_READONLY
; 3617.	#if _MAX_SS != 512                  /* Get disk sector size */
; 3620.	#endif
; 3776.	#if _USE_ERASE  /* Erase data area if needed */
; 3783.	#endif
; 3799.	#endif /* _USE_MKFS && !_FS_READONLY */
; 3800.	
; 3801.	
; 3802.	
; 3803.	
; 3804.	#if _USE_STRFUNC
; 3824.	#if _LFN_UNICODE                    /* Read a character in UTF-8 encoding */
; 3843.	#endif
; 3844.	#if _USE_STRFUNC >= 2
; 3846.	#endif
; 3857.	#if !_FS_READONLY
; 3871.	#if _USE_STRFUNC >= 2
; 3873.	#endif
; 3875.	#if _LFN_UNICODE    /* Write the character in UTF-8 encoding */
; 3891.	#else               /* Write the character without conversion */
; 3894.	#endif
; 4018.	#endif /* !_FS_READONLY */
; 4019.	#endif /* _USE_STRFUNC */
;	RSEG	CONST
_L0243:
	DEFB	128
	DEFB	129
	DEFB	130
	DEFB	131
	DEFB	132
	DEFB	133
	DEFB	134
	DEFB	135
	DEFB	136
	DEFB	137
	DEFB	138
	DEFB	139
	DEFB	140
	DEFB	141
	DEFB	142
	DEFB	143
	DEFB	144
	DEFB	145
	DEFB	146
	DEFB	147
	DEFB	148
	DEFB	149
	DEFB	150
	DEFB	151
	DEFB	152
	DEFB	153
	DEFB	154
	DEFB	155
	DEFB	156
	DEFB	157
	DEFB	158
	DEFB	159
	DEFB	128
	DEFB	129
	DEFB	130
	DEFB	131
	DEFB	132
	DEFB	133
	DEFB	134
	DEFB	135
	DEFB	136
	DEFB	137
	DEFB	138
	DEFB	139
	DEFB	140
	DEFB	141
	DEFB	142
	DEFB	143
	DEFB	176
	DEFB	177
	DEFB	178
	DEFB	179
	DEFB	180
	DEFB	181
	DEFB	182
	DEFB	183
	DEFB	184
	DEFB	185
	DEFB	186
	DEFB	187
	DEFB	188
	DEFB	189
	DEFB	190
	DEFB	191
	DEFB	192
	DEFB	193
	DEFB	194
	DEFB	195
	DEFB	196
	DEFB	197
	DEFB	198
	DEFB	199
	DEFB	200
	DEFB	201
	DEFB	202
	DEFB	203
	DEFB	204
	DEFB	205
	DEFB	206
	DEFB	207
	DEFB	208
	DEFB	209
	DEFB	210
	DEFB	211
	DEFB	212
	DEFB	213
	DEFB	214
	DEFB	215
	DEFB	216
	DEFB	217
	DEFB	218
	DEFB	219
	DEFB	220
	DEFB	221
	DEFB	222
	DEFB	223
	DEFB	144
	DEFB	145
	DEFB	146
	DEFB	147
	DEFB	157
	DEFB	149
	DEFB	150
	DEFB	151
	DEFB	152
	DEFB	153
	DEFB	154
	DEFB	155
	DEFB	156
	DEFB	157
	DEFB	158
	DEFB	159
	DEFB	240
	DEFB	240
	DEFB	242
	DEFB	242
	DEFB	244
	DEFB	244
	DEFB	246
	DEFB	246
	DEFB	248
	DEFB	249
	DEFB	250
	DEFB	251
	DEFB	252
	DEFB	253
	DEFB	254
	DEFB	255
nullstring:
	DEFB	0
;	RSEG	CSTR
_L0290:
	DEFB	'"*+,:;<=>?[]|'
	DEFB	127,0

__end:

;	RSEG	UDATA0
sfn:
	DEFS	12
djo:
	DEFS	22
djn:
	DEFS	22
_L0463:
	DEFS	1
_L0472:
	DEFS	4
_L0473:
	DEFS	4
_L0508:
	DEFS	4
_L0509:
	DEFS	4
_L0510:
	DEFS	4
_L0511:
	DEFS	2
_L0512:
	DEFS	2
_L0561:
	DEFS	4
_L0562:
	DEFS	2
_L0563:
	DEFS	2
_L0627:
	DEFS	1
_L0642:
	DEFS	4
_L0643:
	DEFS	22
_L0690:
	DEFS	4
_L0691:
	DEFS	4
_L0692:
	DEFS	4
_L0693:
	DEFS	4
_L0744:
	DEFS	2
fno_rddir:
	DEFS	22
_L0769:
	DEFS	1
_L0777:
	DEFS	1
_L0778:
	DEFS	4
_L0779:
	DEFS	4
_L0780:
	DEFS	4
_L0781:
	DEFS	2
_L0815:
	DEFS	4
_L0842:
	DEFS	1
_L0843:
	DEFS	2
_L0844:
	DEFS	4
_L0881:
	DEFS	1
_L0882:
	DEFS	4
_L0883:
	DEFS	4
_L0884:
	DEFS	4
_L0885:
	DEFS	4
_L0921:
	DEFS	1
_L0933:
	DEFS	1
_L0934:
	DEFS	2
_L0946:
	DEFS	1
_L0947:
	DEFS	2
_L0959:
	DEFS	1
_L0960:
	DEFS	21
;	RSEG	NO_INIT
pathbuf:
	DEFS	256

	SAVEBIN "fatfs.raw",__begin,__end-__begin

	END
