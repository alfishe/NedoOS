@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=dhcpc
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=Cstartup.s01 ..\oscalls.s01
SET ADD_LINK_FILES=

call ..\buildiar.bat