MODULE mylib
  PUBLIC tablcall
  PUBLIC LD_CLUST
  PUBLIC drv_calls,dio_par	;,CurrDir
  ;PUBLIC CurrVol
  PUBLIC FatFs
  PUBLIC Fsid
  EXTERN f_mount
  EXTERN f_open
  EXTERN f_read
  EXTERN f_lseek
  EXTERN f_close
  EXTERN f_opendir
  EXTERN f_readdir
  EXTERN f_stat
  EXTERN f_write
  EXTERN f_getfree
  EXTERN f_truncate
  EXTERN f_sync
  EXTERN f_unlink
  EXTERN f_mkdir
  EXTERN f_chmod
  EXTERN f_utime
  EXTERN f_rename
  EXTERN f_chdrive
  EXTERN f_chdir,f_getcwd
  EXTERN ?L_MUL_L03
  EXTERN f_getutime
  

  RSEG TRST
  
drv_calls:
		defw 0	;init
		defw 0	;status
		defw 0	;read to userspace
		defw 0	;read to buffer
		defw 0	;write from userspace
		defw 0	;write from buffer
		defw 0	;RTC
		defw 0	;strcpy_lib2usp
		defw 0	;strcpy_usp2lib
		defw 0	;memcpy_lib2usp
		defw 0	;memcpy_usp2lib
		defw 0	;memcpy_buf2usp
		defw 0	;memcpy_usp2buf
dio_par:
        DEFB 1        ;DRV
        DEFW 0x4000   ;*BUF
        DEFW 0        ;*sec
        DEFB 32       ;NUM
curr_fatfs:
        DEFW 0
curr_dir:
		DEFW 0,0
tablcall:  
  DEFW f_mount
  DEFW f_open
  DEFW f_read
  DEFW f_lseek
  DEFW f_close
  DEFW f_opendir
  DEFW f_readdir
  DEFW f_stat
  DEFW f_write
  DEFW 0	;f_getfree
  DEFW 0	;f_truncate
  DEFW f_sync
  DEFW f_unlink
  DEFW f_mkdir
  DEFW 0	;f_chmod
  DEFW f_utime
  DEFW f_rename
  DEFW f_chdrive
  DEFW f_chdir
  DEFW f_getcwd
  DEFW f_getutime
//VolToPart:
//        DEFB 0,0,1,0

FatFs:
        DEFW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Fsid:
        DEFW 0
		
LD_CLUST:
  LD HL,20
  ADD HL,DE
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD HL,26
  ADD HL,DE
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  ret
  
ENDMOD

MODULE STRIP_SP_DOT
  
    PUBLIC fs_strip_sp_dot
    RSEG CODE
fs_strip_sp_dot:
    ld hl,0xffff
loop:
    ld a,(de)
    inc hl
    inc de
    cp ' '
    jr z,loop
    cp '.'
    ret nz
    jr loop
  
ENDMOD

MODULE FS_STRCPY
  
  PUBLIC fs_strcpy
  RSEG CODE
fs_strcpy:
    ld h,b
    ld l,c
loop:
    ld a,(hl)
    ldi
    or a
    jp nz,loop
    ret

ENDMOD

MODULE UNICODE_CP866
  
  PUBLIC unicode_to_cp866
  RSEG CODE
    
unicode_to_cp866:
    ; у IAR первый аргумент в DE
    ; Проверяем старший байт Unicode
    ld   a, d
    or   a              ; Проверка на 0x00 (ASCII)
    ld   a, e
    ret  z              ; быстрый выход если ASCII

    ld   a, d
    cp   0x04           ; Проверяем, кириллица ли это ( == 0x04)
    jr  nz, bad_char    ; Если не 0x00 и не 0x04, символ нам не подходит

    ; Работаем с младшим байтом (загружаем L в аккумулятор)
    ld   a, e

    ; Проверяем диапазон U+0410 .. U+043F (младший байт 0x10 .. 0x3F)
    add a,0x70
    jp p, check_yo
    cp   0x40+0x70           ; Верхняя граница + 1
    ret c

    ; Проверяем диапазон U+0440 .. U+044F (младший байт 0x40 .. 0x4F)
    cp   0x50+0x70           ; Верхняя граница + 1
    jr   nc, check_yo_small

    ; Блок 2: low - 0x40 + 0xE0 -> low + 0xA0
    add  a, 0xA0-0x70
    ret

check_yo:
    cp   0x01+0x70           ; Младший байт 'Ё' (U+0401)
    ld   a, 0xF0        ; Код 'Ё' в CP866
    ret z
bad_char:
    ld   a, 0x5F        ; Возвращаем '_' (заглушка для неподдерживаемых символов)
    ret

check_yo_small:
    cp   0x51+0x70           ; Младший байт 'ё' (U+0451)
    ld   a, 0xF1        ; Код 'ё' в CP866
    ret z
    ld   a, 0x5F        ; Возвращаем '_' (заглушка для неподдерживаемых символов)
    ret

ENDMOD

MODULE CP866_UNICODE
  PUBLIC cp866_to_unicode
  
  RSEG CODE

cp866_to_unicode:
    ld   a, e
    ld   l, a

    ld   h, 0x00
    or   a           ; Проверяем, не ASCII ли это (A < 0x80)
    ret  p             ; Быстрый выход для ascii
    
    ld   h, 0x04        ; Старший байт в H (блок кириллицы)

    ; Проверяем диапазон 0x80 .. 0xAF ('А'..'п')
    cp   0xB0           ; Сравниваем с верхней границей + 1
    jr   nc, not_block1 ; Если >= 0xB0, идем проверять следующий блок

    ; Блок 1: src - 0x80 + 0x10 -> src - 0x70. Старший байт всегда 0x04.
    sub  0x70           ; Математика: A = A - 0x70
    ld   l, a           ; Младший байт в L
    ret

not_block1:
    ; Проверяем диапазон 0xE0 .. 0xEF ('р'..'я')
    cp   0xE0           ; Если меньше 0xE0 (но больше 0xAF), это псевдографика
    jr   c, is_unknown
    cp   0xF0           ; Верхняя граница блока 'р'..'я'
    jr   nc, not_block2

    ; Блок 2: src - 0xE0 + 0x40 -> src - 0xA0. Старший байт 0x04.
    sub  0xA0           ; Математика: A = A - 0xA0
    ld   l, a
    ret

not_block2:
    ld   l, 0x01     ; Буква 'Ё' (U+0401)
    ; Проверяем 'Ё' (0xF0) и 'ё' (0xF1)
    cp   0xF0
    ret   z

is_yo_small:
    ld   l, 0x51     ; Буква 'ё' (U+0451)
    cp   0xF1
    ret  z

is_unknown:
    ld   hl, 0x005F     ; Спецсимволы и псевдографику заменяем на '_' (ASCII 0x5F)
    ret
  
ENDMOD

END

