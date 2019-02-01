@ECHO OFF
setlocal enabledelayedexpansion

set C_FILES=
set ASM_FILES=Cstartup.s01
SET ADD_LINK_FILES=

set Z80_IDE_PATH=..\..\..\utils\iar

set ICCZ80=%Z80_IDE_PATH%\iccz80
set AZ80=%Z80_IDE_PATH%\az80
set XLINK=%Z80_IDE_PATH%\xlink
set IARINC=%Z80_IDE_PATH%\
set IARLIB=%Z80_IDE_PATH%
set C_OPTIONS=-v0 -ml -r -uua -q -e -K -gA -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
set LINK_OPTIONS=-FIEEE695 -C %IARLIB%\clz80 -f Lnk.xcl -yv
rem set LINK_OPTIONS=-FRAW-BINARY -o ktest.com -C %IARLIB%\clz80 -f Lnk.xcl

if not exist list mkdir list

echo Compiling ktest.com ...
FOR %%a IN (!C_FILES!) do (
	rem echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~na.r01
	%ICCZ80% -S %C_OPTIONS% %%a
)

rem echo --------------Compiling ASM_FILES--------------
FOR %%a IN (!ASM_FILES!) do (
	rem echo %%a
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~na.r01
	%AZ80% -r -v0 -S -Olist\ %%a 
)

rem echo ------------------Linking files----------------
rem echo !ADD_LINK_FILES!
%XLINK% -S !ADD_LINK_FILES! !LINK_OPTIONS!
