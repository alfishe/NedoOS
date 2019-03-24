@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=dmm
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=..\oscalls.asm ..\dns.asm rstcalls.asm
SET ADD_LINK_FILES=

call ..\buildiar.bat