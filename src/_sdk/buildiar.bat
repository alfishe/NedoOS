set Z80_IDE_PATH=%~dp0../../iar
set ICCZ80=%Z80_IDE_PATH%/bin/iccz80
set AZ80=%Z80_IDE_PATH%/bin/az80
set XLINK=%Z80_IDE_PATH%/bin/xlink
set IARINC=%Z80_IDE_PATH%/inc/
set IARLIB=%Z80_IDE_PATH%/lib/
IF NOT EXIST %ICCZ80%.exe (
	ECHO IAR not found. Skipping build "%PRJNAME%"
	EXIT /b
)
rem echo Build "%PRJNAME%"

if not exist list mkdir list
if exist list/lfiles.lnk del list\lfiles.lnk
IF "%PRJDEBUG%"=="1" (
	set LINK_OPTIONS=-FIEEE695 -yvgbls -l list/cout.html -xehinms -Z^(CODE^)DBGMON=FBF0-FFFF
)ELSE (
	set LINK_OPTIONS=-FRAW-BINARY -S -o %PRJNAME%.com -Z^(CODE^)DBGMON=FFFF-FFFF
)

FOR %%f IN (%C_FILES%) do (
	echo %%~nf.r01 >> list/lfiles.lnk
	IF "%PRJDEBUG%"=="1" (
		%ICCZ80% -v0 -ml -r -uu -q -e -K -gA -t4 -l list/%%~nf.lst -o list/%%~nf.r01 -a list/%%~nf.s01 -I%IARINC% -I%~dp0 %%f 
	)ELSE (
		%ICCZ80% -v0 -ml -s7 -S -uu -e -K -gA -o list/%%~nf.r01 -a list/%%~nf.s01 -I%IARINC% -I%~dp0 %%f 
	)
)
FOR %%f IN (%ASM_FILES%) do (
	echo %%~nf.r01 >> list/lfiles.lnk
	%AZ80% -S -uu -Olist/ %%f -I%currentdir%/_sdk/
)
%XLINK% -f list/lfiles.lnk %LINK_OPTIONS% -C %~dp0iar.lib -C %IARLIB%/clz80 -f Lnk.xcl