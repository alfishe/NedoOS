@ECHO OFF
CLS
setlocal enabledelayedexpansion

set C_FILES=ff
set ASM_FILES=mylib
SET ADD_LINK_FILES=

set Z80_IDE_PATH=iar

set ICCZ80=%Z80_IDE_PATH%\iccz80
set AZ80=%Z80_IDE_PATH%\az80
set XLINK=%Z80_IDE_PATH%\xlink
set IARINC=%Z80_IDE_PATH%\
set IARLIB=%Z80_IDE_PATH%
set C_OPTIONS=-v0 -ml -uua -q -e -K -gA -z9 -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
set LINK_OPTIONS=-cZ80 -Ilist -FRAW-BINARY -C %IARLIB%\clz80 -o fatfs.raw -l list/cout.html -xehinms
set LINK_OPTIONS=!LINK_OPTIONS! -Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,DATA0,IDATA0,UDATA0,ECSTR,TEMP=4000-7FFF

if not exist list mkdir list

echo ---------------Compiling C_FILES---------------
FOR %%a IN (!C_FILES!) do (
	echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%a.r01
	%ICCZ80% %C_OPTIONS% %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

echo --------------Compiling ASM_FILES--------------
FOR %%a IN (!ASM_FILES!) do (
	echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%a.r01
	%AZ80% -Olist\ -uu %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

echo ------------------Linking files----------------
echo !ADD_LINK_FILES!
@ECHO ON
%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS!
pause

exit /b

:errexit
TYPE err.log
pause
exit /b