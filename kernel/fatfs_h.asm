; Эдесь лежат макросы FatFs.
; Все аргументы передаются через стек, в порядке их перечисления.
; Длинна аргумента кратна двум, то есть, если аргумент типа BYTE,
; то он занимает на стеке два байта.
; Если аргумент типа DWORD, то на стек сначала кладем старшие два байта, затем младшие.
; После выполнения функции все аргументы остаются на стеке,
; не забывайте снимать ненужные (за исключением f_voltopart).
;
; При попадании в функцию на стеке должен быть адрес возврата, затем список переменных.
;
; Строковая переменная должна заканчиватся 0x0 (нулём).
; Можно использовать как абсолютный, так и относительный путь:
; 	"file.txt"		A file in the current directory of the current drive
; 	"/file.txt"		A file in the root directory of the current drive
; 	""				The current directory of the current drive
; 	"/"				The root directory of the current drive
; 	"2:"			The current directory of the drive 2
; 	"2:/"			The root directory of the drive 2
; 	"2:file.txt"	A file in the current directory of the drive 2
; 	"../file.txt"	A file in the parent directory
; 	"."				This directory
; 	".."			Parent directory of the current directory
; 	"dir1/.."		The current directory
; 	"/.."			The root directory (sticks the top level)

; Возвращаемый параметр лежит в HL, если DWORD то DEHL.
;
; Левые порты должны быть скрыты (MEM_HIDE)
; Стек должен быть в текущем адресном пространстве (юзается очень сильно байт 100-200
; свободно может заюзать). И переменные(если на них есть указатель в
; аргументах, а также глобальные переменные типа FATFS), тоже должны быть доступны.

;------------------------СТРУКТУРЫ FATFS --------------------------------------

FA_READ=0x01			;Specifies read access to the object. Data can be read from the file.
					;Combine with FA_WRITE for read-write access.
FA_WRITE=0x02			;Specifies write access to the object. Data can be written to the file.
					;Combine with FA_READ for read-write access.
FA_OPEN_EXISTING=0x00	;Opens the file. The function fails if the file is not existing. (Default)
FA_OPEN_ALWAYS=0x10	;Opens the file if it is existing. If not, a new file is created.
					;To append data to the file, use f_lseek function after file open in this method.
FA_CREATE_NEW=0x04		;Creates a new file. The function fails with FR_EXIST if the file is existing.
FA_CREATE_ALWAYS=0x08	;Creates a new file. If the file is existing, it is truncated and overwritten.



/* File system object structure (FATFS) */

	STRUCT FATFS
fs_type		BYTE;		/* FAT sub-type (0:Not mounted) */
drv		BYTE 0;		/* Physical drive number */
part		BYTE 0;		/* Partition # (0-4) 0-auto*/
csize		BYTE;		/* Sectors per cluster (1,2,4...128) */
n_fats		BYTE;		/* Number of FAT copies (1,2) */
wflag		BYTE;		/* win[] dirty flag (1:must be written back) */
fsi_flag	BYTE;		/* fsinfo dirty flag (1:must be written back) */
id		WORD;		/* File system mount ID */
n_rootdir	WORD;		/* Number of root directory entries (FAT12/16) */
last_clust	DWORD;		/* Last allocated cluster */
free_clust	DWORD;		/* Number of free clusters */
fsi_sector	DWORD;		/* fsinfo sector (FAT32) */
cdir		DWORD;		/* Current directory start cluster (0:root) */ ;TODO use
n_fatent	DWORD;		/* Number of FAT entries (= number of clusters + 2) */
fsize		DWORD;		/* Sectors per FAT */
fatbase		DWORD;		/* FAT start sector */
dirbase		DWORD;		/* Root directory start sector (FAT32:Cluster#) */
database	DWORD;		/* Data start sector */
winsect		DWORD;		/* Current sector appearing in the win[] */
win		BLOCK 512;	/* Disk access window for Directory, FAT (and Data on tiny cfg) */
	ENDS
FATFS_sz=51+512

;/* Directory object structure (DIR) */
	STRUCT DIR
FS		WORD	;/* POINTER TO THE OWNER FILE SYSTEM OBJECT */
ID		WORD	;/* OWNER FILE SYSTEM MOUNT ID */
INDEX	        WORD	;/* CURRENT READ/WRITE INDEX NUMBER */
SCLUST	        DWORD	;/* TABLE START CLUSTER (0:ROOT DIR) */ ;видимо, в том же формате, что FATFS.cdir
CLUST	        DWORD	;/* CURRENT CLUSTER */
SECT	        DWORD	;/* CURRENT SECTOR */
DIR		WORD	;/* POINTER TO THE CURRENT SFN ENTRY IN THE WIN[] */
FN		WORD	;/* POINTER TO THE SFN (IN/OUT) {FILE[8],EXT[3],STATUS[1]} */
	ENDS
DIR_sz=22

/* FILE STATUS STRUCTURE (FILINFO) */
	STRUCT FILINFO
FSIZE	        DWORD		;/* FILE SIZE */
FDATE	        WORD		;/* LAST MODIFIED DATE */
FTIME	        WORD		;/* LAST MODIFIED TIME */
FATTRIB	        BYTE		;/* ATTRIBUTE */
FNAME	        BLOCK 13,0	;/* SHORT FILE NAME (8.3 FORMAT) */
;MARK	        byte		;marking
;NEXT	        WORD
;NEXTP	        BYTE
;PREV	        WORD
;PREVP	        BYTE
;RESERV	        dw
	ENDS

/* File object structure (FIL) */

	struct FIL
FS		WORD	;/* Pointer to the owner file system object */
ID		WORD	;/* Owner file system mount ID */
FLAG	        BYTE	;/* File status flags */
PAD1	        BYTE	;;TODO добавить тут id приложения-хозяина, чтобы можно было автоматически удалить
FPTR	        DWORD	;/* File read/write pointer (0 on file open) */
FSIZE	        DWORD	;/* File size */
FCLUST	        DWORD	;/* File start cluster (0 when fsize==0) */
CLUST	        DWORD	;/* Current cluster */
DSECT	        DWORD	;/* Current data sector */
DIR_SECT	DWORD	;/* Sector containing the directory entry */
DIR_PTR		WORD	;/* Ponter to the directory entry in the window */
BUF		BLOCK 512	;/* File data read/write buffer */
	ENDS
FIL_sz=32+512


;---------------------------------МАКРОСЫ--------------------------------------

	MACRO F_VOLTOPART _VOL,_DRIVE,_PART	; Это типа виртуального предмонтирования, что ли.
	; BYTE VOL - под каким номером монтировать (0-3).
	; BYTE DRIVE - физическое устройство(0-ZSD,1-NEMO master,2-NEMO slave).
	; BYTE PART - номер раздела(0-3).
	LD HL,_VOL		;Кидаем на стек аргументы
	PUSH HL
	LD L,_DRIVE
	PUSH HL
	LD L,_PART
	PUSH HL
	LD A,4			; номер функции, кстати она исключение из правил, на стеке
	call ffs			; остаётся только VOL, а он как раз пригодится нам в F_MOUNT
	ENDM

;/*-----------------------------------------------------------------------*/
;/* Mount/Unmount a Logical Drive                                         */
;/*-----------------------------------------------------------------------*/
;
;FRESULT f_mount (
;	BYTE vol,		/* Logical drive number to be mounted/unmounted */
;	FATFS *fs		/* Pointer to new file system object (NULL for unmount)*/
;)
	MACRO F_MOUNT _VOL,_FS	;vol - уже лежит на стеке.
	ld e,_VOL
	LD bc,_FS
	F_MNT
	ENDM
	MACRO F_MNT
	LD A,0
	call ffs
	ENDM


; FRESULT f_open (
	; FIL *fp,			/* Pointer to the blank file object */
	; TCHAR *path,	/* Pointer to the file name */
	; BYTE mode			/* Access mode and file open mode flags */
; )
	MACRO F_OPEN _FP,_PATH,_MODE
	LD de,_FP
	LD bc,_PATH
	LD HL,_MODE
        F_OP
        ENDM
        MACRO F_OP
	PUSH HL
	LD A,1
	call ffs
	POP BC
	ENDM


;seek
;FRESULT f_lseek (
;	FIL *fp,		/* Pointer to the file object */
;	DWORD ofs		/* File pointer from top of file */
;)
;fp = de
;ofs in stack
	MACRO F_LSEEK
	LD A,3
	call ffs
	ENDM

        
;/*-----------------------------------------------------------------------*/
;/* Read File                                                             */
;/*-----------------------------------------------------------------------*/
;FRESULT f_read
;	FIL *fp, 		/* Pointer to the file object */
;	void *buff,		/* Pointer to data buffer */
;	UINT btr,		/* Number of bytes to read */
;	UINT *br		/* Pointer to number of bytes read */
	MACRO F_READ
	LD A,2
	call ffs
	ENDM
        
        
;/*-----------------------------------------------------------------------*/
;/* Write File                                                            */
;/*-----------------------------------------------------------------------*/
;FRESULT f_write
;	FIL *fp,			/* Pointer to the file object */
;	const void *buff,	/* Pointer to the data to be written */
;	UINT btw,			/* Number of bytes to write */
;	UINT *bw			/* Pointer to number of bytes written */
	MACRO F_WRITE
	LD A,8
	call ffs
	ENDM

; /*-----------------------------------------------------------------------*/
; /* Close File                                                            */
; /*-----------------------------------------------------------------------*/
; FRESULT f_close (
	; FIL *fp		/* Pointer to the file object to be closed */)
	MACRO F_CLOSE _FP
	ld de,_FP
        F_CLOS
        ENDM
        MACRO F_CLOS
	LD A,4
	call ffs
	ENDM



; /*-----------------------------------------------------------------------*/
; /* Create a Directory Object                                             */
; /*-----------------------------------------------------------------------*/
; FRESULT f_opendir
	; DIR *dj,			/* Pointer to directory object to create */
	; TCHAR *path	/* Pointer to the directory path */
	MACRO F_OPENDIR _DJ;,_PATH
		LD de,_DJ
		;LD bc,_PATH
		F_OPDIR
	ENDM
	MACRO F_OPDIR
	LD A,5
	call ffs
	ENDM

; /*-----------------------------------------------------------------------*/
; /* Read Directory Entry in Sequence                                      */
; /*-----------------------------------------------------------------------*/

; FRESULT f_readdir (
	; DIR *dj,			/* Pointer to the open directory object */
	; FILINFO *fno		/* Pointer to file information to return */
; )
	MACRO F_READDIR _DJ,_FNO
		LD de,_DJ
		LD bc,_FNO
		F_RDIR
	ENDM
	MACRO F_RDIR
	LD A,6
	call ffs
	ENDM


;/*-----------------------------------------------------------------------*/
;/* Delete a File or Directory                                            */
;/*-----------------------------------------------------------------------*/
;FRESULT f_unlink
;	const TCHAR *path		/* Pointer to the file or directory path */
	MACRO F_UNLINK
	LD A,12
	call ffs
	ENDM
;/*-----------------------------------------------------------------------*/
;/* Create a Directory                                                    */
;/*-----------------------------------------------------------------------*/
;FRESULT f_mkdir
;	const TCHAR *path		/* Pointer to the directory path */
	MACRO F_MKDIR
	LD A,13
	call ffs
	ENDM
;/*-----------------------------------------------------------------------*/
;/* Rename File/Directory                                                 */
;/*-----------------------------------------------------------------------*/
;FRESULT f_rename
;	const TCHAR *path_old,	/* Pointer to the old name */
;	const TCHAR *path_new	/* Pointer to the new name */

	MACRO F_RENAME
	LD A,16
	call ffs
	ENDM

;/*-----------------------------------------------------------------------*/
;/* Current Drive/Directory Handlings                                     */
;/*-----------------------------------------------------------------------*/
;FRESULT f_chdrive
;	BYTE drv		/* Drive number */
	MACRO F_CHDR
	LD A,17
	call ffs
	ENDM
	MACRO F_CHDRIVE _DRV
	LD e,_DRV
	F_CHDR
	ENDM

; FRESULT f_chdir (
	; TCHAR *path	/* Pointer to the directory path */
; )
	MACRO F_CHDIR
	LD A,18
	call ffs
	ENDM

;FRESULT f_getcwd (
;	DE=TCHAR *path,	/* Pointer to the directory path */ буфер
;	BC=UINT sz_path	/* Size of path */) размер буфера 

	MACRO F_GETCWD
	LD A,19
	call ffs
	ENDM

	;MACRO F_MUL _ARG
	;LD DE,0
	;PUSH DE
	;LD de,_ARG
	;push de
	;LD A,20;19
	;call ffs
	;endm


;FRESULT f_utime (const TCHAR*, WORD fdate, WORD ftime); /* Change timestamp of the file/dir */
;de=name
;bc=date
;stack=time
	MACRO F_UTIME
	LD A,15
	call ffs
	ENDM

;FRESULT f_getutime (const TCHAR*, WORD *ftimedate); /* Get timestamp of the file/dir */
;de=name
;bc=pointer to time,date
	MACRO F_GETUTIME
	LD A,20
	call ffs
	ENDM


; /* File function return code (FRESULT) */

; typedef enum {
	; FR_OK = 0,				/* (0) Succeeded */
	; FR_DISK_ERR,			/* (1) A hard error occured in the low level disk I/O layer */
	; FR_INT_ERR,				/* (2) Assertion failed */
	; FR_NOT_READY,			/* (3) The physical drive cannot work */
	; FR_NO_FILE,				/* (4) Could not find the file */
	; FR_NO_PATH,				/* (5) Could not find the path */
	; FR_INVALID_NAME,		/* (6) The path name format is invalid */
	; FR_DENIED,				/* (7) Access denied due to prohibited access or directory full */
	; FR_EXIST,				/* (8) Access denied due to prohibited access */
	; FR_INVALID_OBJECT,		/* (9) The file/directory object is invalid */
	; FR_WRITE_PROTECTED,		/* (10) The physical drive is write protected */
	; FR_INVALID_DRIVE,		/* (11) The logical drive number is invalid */
	; FR_NOT_ENABLED,			/* (12) The volume has no work area */
	; FR_NO_FILESYSTEM,		/* (13) There is no valid FAT volume on the physical drive */
	; FR_MKFS_ABORTED,		/* (14) The f_mkfs() aborted due to any parameter error */
	; FR_TIMEOUT,				/* (15) Could not get a grant to access the volume within defined period */
	; FR_LOCKED,				/* (16) The operation is rejected according to the file sharing policy */
	; FR_NOT_ENOUGH_CORE,		/* (17) LFN working buffer could not be allocated */
	; FR_TOO_MANY_OPEN_FILES	/* (18) Number of open files > _FS_SHARE */
; } FRESULT;
