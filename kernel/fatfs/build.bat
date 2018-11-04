@ECHO OFF
CLS
setlocal enabledelayedexpansion

set Z80_IDE_PATH=C:\Users\cash\Desktop\txt\dimkam\utils\iar

set ICCZ80=%Z80_IDE_PATH%\iccz80
set AZ80=%Z80_IDE_PATH%\az80
set XLINK=%Z80_IDE_PATH%\xlink
set IARINC=%Z80_IDE_PATH%\
set IARLIB=%Z80_IDE_PATH%
set C_OPTIONS=-v0 -ml -uua -q -e -K -gA -s9 -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
set GLINK_OPTIONS=-cZ80 -Ilist -FRAW-BINARY -C %IARLIB%\clz80

if not exist list mkdir list

ECHO ------------------Build FATFS----------------
SET itemname=ffs
set C_FILES=ff ffunicode shell
set ASM_FILES=savelij ffasm
SET ADD_LINK_FILES=!C_FILES! !ASM_FILES!
call :compileitem %1

echo // > !itemname!.def
FOR /F "usebackq delims==" %%a IN (`findstr /R "fs_" list\!itemname!.txt`) DO (
	SET def=
	FOR %%b IN (%%a) DO IF "!def!"=="" (SET def=#define %%b) ELSE SET def=!def! 0x%%b
	ECHO !def! >> !itemname!.def
)

ECHO ------------------Build KRST----------------
SET itemname=krst
set C_FILES=
set ASM_FILES=krst
SET ADD_LINK_FILES=!C_FILES! !ASM_FILES!
call :compileitem %1

if not "%1"=="npp" pause
exit

:errexit
TYPE err.log
if not "%1"=="npp" pause
exit

:compileitem
echo Compile: !C_FILES! !ASM_FILES!
FOR %%a IN (!C_FILES!) do (
	rem echo %%a
	rem SET ADD_LINK_FILES=!ADD_LINK_FILES! %%a.r01
	%ICCZ80% %C_OPTIONS% %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

FOR %%a IN (!ASM_FILES!) do (
	rem echo %%a
	rem SET ADD_LINK_FILES=!ADD_LINK_FILES! %%a.r01
	%AZ80% -Olist\ -uu %%a > err.log & if errorlevel 1 goto errexit
	FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
)

echo Link: !ADD_LINK_FILES!
set LINK_OPTIONS=!GLINK_OPTIONS! -f !itemname!.xcl -o list\!itemname!.bin -D?BANK_SWITCH_PORT_L08=25
%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS! -xe -l list\!itemname!.txt > err.log & if errorlevel 1 goto errexit
FINDSTR "Warning[" err.log >nul & if NOT errorlevel 1 TYPE err.log
%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS! -xehinms -d -l list/!itemname!.html  > NUL

exit /b