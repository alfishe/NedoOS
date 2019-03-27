@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=ktest
set PRJDEBUG=0
set C_FILES=
set ASM_FILES=Cstartup.asm
SET ADD_LINK_FILES=

call ..\buildiar.bat