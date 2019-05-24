@ECHO OFF
setlocal enabledelayedexpansion
set wascurrentdir=%currentdir%

set C_FILES=ff
set ASM_FILES=mylib.asm
SET ADD_LINK_FILES=

set Z80_IDE_PATH=..\..\iar
IF NOT EXIST %Z80_IDE_PATH%\bin\iccz80.exe (
	ECHO IAR not found. Skipping build FatFS
	EXIT /b
)

set ICCZ80=%Z80_IDE_PATH%\bin\iccz80
set AZ80=%Z80_IDE_PATH%\bin\az80
set XLINK=%Z80_IDE_PATH%\bin\xlink
set IARINC=%Z80_IDE_PATH%\inc\
set IARLIB=%Z80_IDE_PATH%\lib\
IF NOT EXIST %ICCZ80%.exe (
	ECHO IAR not found. Skipping build "%PRJNAME%"
	EXIT /b
)
echo Build fatfs
set C_OPTIONS=-S -v0 -ml -uua -q -e -K -gA -z9 -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
set LINK_OPTIONS=-S -cZ80 -Ilist -FRAW-BINARY -C %IARLIB%\clz80 -o fatfs.raw -l list/cout.html -xehinms
set LINK_OPTIONS=!LINK_OPTIONS! -Z(CODE)TRST,RCODE,CODE,CDATA0,CONST,CSTR,CCSTR,DATA0,IDATA0,UDATA0,ECSTR,NO_INIT,TEMP=4000-7FFF

if not exist list mkdir list

FOR %%f IN (!C_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%ICCZ80% %C_OPTIONS% %%f 
)

FOR %%f IN (!ASM_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%AZ80% -S -Olist\ -uu %%f 
)

%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS!

rem if "%wascurrentdir%"=="" (pause)
