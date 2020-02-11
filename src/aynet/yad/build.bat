@ECHO OFF
set PRJNAME=yad
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=yadplay.asm
SET ADD_LINK_FILES=
call ..\..\_sdk\buildiar.bat

rem ..\..\..\us\emul