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
	set LINK_OPTIONS=-FIEEE695 -C %IARLIB%/clz80 -f Lnk.xcl -yvgbls -l list/cout.html -xehinms
	set C_OPTIONS=-v0 -ml -r -uu -q -e -K -gA -t4 -Llist/ -Olist/ -Alist/ -I%IARINC% -I%~dp0
)ELSE (
	set LINK_OPTIONS=-FRAW-BINARY -S -o %PRJNAME%.com -C %IARLIB%/clz80 -f Lnk.xcl
	set C_OPTIONS=-v0 -ml -s7 -S -uu -e -K -gA -Olist/ -Alist/ -I%IARINC% -I%~dp0
)

FOR %%f IN (%C_FILES%) do (
	echo %%~nf.r01 >> list/lfiles.lnk
	%ICCZ80% %C_OPTIONS% %%f 
)
FOR %%f IN (%ASM_FILES%) do (
	echo %%~nf.r01 >> list/lfiles.lnk
	%AZ80% -S -uu -Olist/ %%f -I%currentdir%/_sdk/
)
%XLINK% -f list/lfiles.lnk %LINK_OPTIONS%