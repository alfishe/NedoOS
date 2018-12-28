@ECHO OFF
CLS
setlocal enabledelayedexpansion

set C_FILES=main.c
set ASM_FILES=Cstartup.s01 ..\oscalls.s01
SET ADD_LINK_FILES=

set Z80_IDE_PATH=..\..\..\utils\iar

set ICCZ80=%Z80_IDE_PATH%\iccz80
set AZ80=%Z80_IDE_PATH%\az80
set XLINK=%Z80_IDE_PATH%\xlink
set IARINC=%Z80_IDE_PATH%\
set IARLIB=%Z80_IDE_PATH%
set C_OPTIONS=-v0 -ml -r -s3 -uua -q -e -K -gA -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
rem set LINK_OPTIONS=-FIEEE695 -C %IARLIB%\clz80 -f Lnk.xcl -yv
set LINK_OPTIONS=-FRAW-BINARY -o dmftp.com -C %IARLIB%\clz80 -f Lnk.xcl

if not exist list mkdir list

echo ---------------Compiling C_FILES---------------
FOR %%a IN (!C_FILES!) do (
	echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~na.r01
	%ICCZ80% %C_OPTIONS% %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

echo --------------Compiling ASM_FILES--------------
FOR %%a IN (!ASM_FILES!) do (
	echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~na.r01
	%AZ80% -Olist\ %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

echo ------------------Linking files----------------
echo !ADD_LINK_FILES!
@ECHO ON
%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS!


exit /b

:errexit
TYPE err.log

exit /b