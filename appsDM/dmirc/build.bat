@ECHO OFF

setlocal enabledelayedexpansion

set PRJNAME=dmirc
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=..\oscalls.s01 ..\dns.s01
SET ADD_LINK_FILES=

call ..\buildiar.bat