@ECHO OFF
echo Build fatfs
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
if not exist list mkdir list
set C_OPTIONS=-S -v0 -ml -uua -q -e -K -gA -z9 -t4 -T -Llist\ -Olist\ -Alist\ -I%IARINC%

%ICCZ80% %C_OPTIONS% ff.c 
%ICCZ80% %C_OPTIONS% ccsbcs.c 
%AZ80% -S -Olist\ -uu mylib.asm

%XLINK% ff ccsbcs mylib -f link.lnk

echo ;FatFS calls > ..\kernel\ffsfunc.asm
echo ffsfunc >> ..\kernel\ffsfunc.asm
FOR /F "eol=# tokens=1,2,3 delims=_ " %%i in (list/cout.l) do (
	IF "%%i"=="f" (
		@echo .%%i_%%j EQU 0x%%k >> ../kernel/ffsfunc.asm
	)
)
