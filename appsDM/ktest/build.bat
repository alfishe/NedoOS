@ECHO OFF
setlocal enabledelayedexpansion

set PRJNAME=ktest
set PRJDEBUG=1
set C_FILES=
set ASM_FILES=Cstartup.s01
SET ADD_LINK_FILES=

call ..\buildiar.bat