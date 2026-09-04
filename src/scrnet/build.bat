if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war main.asm

set RELBIN=../../release/bin
if not exist "%RELBIN%" mkdir "%RELBIN%"
if not exist "%RELBIN%\scrnet" mkdir "%RELBIN%\scrnet"

copy /Y scrnet.com "%RELBIN%\scrnet.com" > nul
xcopy /Y /E /I /Q scrnet "%RELBIN%\scrnet\" > nul

set DMIMG=../../tools/dmimg.exe
set VHD=../../us/sd_nedo.vhd
"%DMIMG%" %VHD% put scrnet.com /bin/scrnet.com
"%DMIMG%" %VHD% mkdir /bin/scrnet
for %%f in (scrnet\*.*) do (
	"%DMIMG%" %VHD% put "%%f" /bin/scrnet/%%~nxf
)

if "%currentdir%"=="" (
	if "%makeall%"=="" ..\..\us\emul.exe
)
