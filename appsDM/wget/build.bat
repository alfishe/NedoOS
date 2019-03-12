@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=wget
set PRJDEBUG=1
set C_FILES=main.c
set ASM_FILES=Cstartup.s01 ..\oscalls.s01 ..\dns.s01 
SET ADD_LINK_FILES=

call ..\buildiar.bat