@ECHO OFF

setlocal enabledelayedexpansion

set PRJNAME=dmirc
set PRJDEBUG=1
set C_FILES=main.c
set ASM_FILES=..\oscalls.asm ..\dns.asm
SET ADD_LINK_FILES=

call ..\buildiar.bat