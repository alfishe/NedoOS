@ECHO OFF
echo Build fatfs
set Z80_IDE_PATH=..\..\iar
IF NOT EXIST %Z80_IDE_PATH%\bin\az80.exe (
	ECHO IAR not found. Skipping build FatFS
	EXIT /b
)
set AZ80=%Z80_IDE_PATH%\bin\az80
set XLINK=%Z80_IDE_PATH%\bin\xlink
set IARLIB=%Z80_IDE_PATH%\lib\

if not exist list mkdir list

%AZ80% -S -Olist\ -uu ff.asm
%AZ80% -S -Olist\ -uu mylib.asm

%XLINK% ff mylib -f link.lnk

echo ;FatFS calls > ..\kernel\ffsfunc.asm
echo ffsfunc >> ..\kernel\ffsfunc.asm
FOR /F "eol=# tokens=1,2,3 delims=_ " %%i in (list/cout.l) do (
	IF "%%i"=="f" (
		@echo .%%i_%%j EQU 0x%%k >> ../kernel/ffsfunc.asm
	)
)
