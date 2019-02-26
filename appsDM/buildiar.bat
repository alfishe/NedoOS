
set Z80_IDE_PATH=..\..\..\utils\iar
set ICCZ80=%Z80_IDE_PATH%\iccz80
set AZ80=%Z80_IDE_PATH%\az80
set XLINK=%Z80_IDE_PATH%\xlink
set IARINC=%Z80_IDE_PATH%\
set IARLIB=%Z80_IDE_PATH%

IF NOT EXIST %Z80_IDE_PATH%\iccz80.exe (
	ECHO IAR not found. Skipping build "%PRJNAME%"
	EXIT /b
)
echo Build "%PRJNAME%"

IF "%PRJDEBUG%"=="1" (
	set LINK_OPTIONS=-FIEEE695 -S -C %IARLIB%\clz80 -f Lnk.xcl -yv
	set C_OPTIONS=-v0 -ml -r -S -uua -q -e -K -gA -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
)ELSE (
	set LINK_OPTIONS=-FRAW-BINARY -S -o %PRJNAME%.com -C %IARLIB%\clz80 -f Lnk.xcl
	set C_OPTIONS=-v0 -ml -r -s7 -S -uua -q -e -K -gA -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%
)

if not exist list mkdir list

FOR %%f IN (!C_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%ICCZ80% %C_OPTIONS% %%f 
)

FOR %%f IN (!ASM_FILES!) do (
	SET ADD_LINK_FILES=!ADD_LINK_FILES! %%~nf.r01
	%AZ80% -S -Olist\ %%f 
)

%XLINK% !ADD_LINK_FILES! !LINK_OPTIONS!
rem @ECHO ON