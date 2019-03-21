@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=dhcpc
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=..\oscalls.asm
SET ADD_LINK_FILES=

call ..\buildiar.bat