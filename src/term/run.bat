@echo off
echo build term
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war term.asm
if "%currentdir%"=="" (pause)

SET releasedir=../../release/
				if not exist "%releasedir%bin" mkdir "%releasedir%bin"
				FOR %%j IN (*.com) DO (
					move "*.com" "%releasedir%bin" > nul
					IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir%bin\%%~nj\" > nul
				)
cd ../

call ..\tools\chkimg.bat sd
if "%makeall%"=="" ..\us\emul.exe
