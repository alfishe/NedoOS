if "%currentdir%"=="" set currentdir=..\..
set Z80_IDE_PATH=%currentdir%\tools\iar
set ICCZ80=%Z80_IDE_PATH%\bin\iccz80
set AZ80=%Z80_IDE_PATH%\bin\az80
set XLINK=%Z80_IDE_PATH%\bin\xlink
set IARINC=%Z80_IDE_PATH%\inc\
set IARLIB=%Z80_IDE_PATH%\lib\

IF NOT EXIST %ICCZ80%.exe (
	ECHO IAR not found. Skipping build "%PRJNAME%"
	EXIT /b
)
echo Build "%PRJNAME%"

IF "%PRJDEBUG%"=="1" (
	set LINK_OPTIONS=-FIEEE695 -C %IARLIB%\clz80 -f Lnk.xcl -yvgbls -l list/cout.html -xehinms
	set C_OPTIONS=-v0 -ml -r -uu -q -e -K -gA -t4 -Llist\ -Olist\ -Alist\ -I%IARINC%
)ELSE (
	set LINK_OPTIONS=-FRAW-BINARY -S -o %PRJNAME%.com -C %IARLIB%\clz80 -f Lnk.xcl
	set C_OPTIONS=-v0 -ml -s7 -S -uu -e -K -gA -Olist\ -Alist\ -I%IARINC%
)

if not exist list mkdir list

FOR %%f IN (!C_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%ICCZ80% %C_OPTIONS% %%f 
)

FOR %%f IN (!ASM_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%AZ80% -S -Olist\ %%f -I%currentdir%\_sdk\
)

%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS!