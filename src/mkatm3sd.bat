@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
echo PS2KBD EQU 0x00 >> _sdk\syssets.asm
if "%savepath%"=="" set savepath=%PATH%

call make.bat noneedtrd

path %savepath%

..\tools\sjasmplus --nologo kernel\hobeta.asm > nul

call ..\tools\chkimg.bat sd

move /Y nedoos.$C ..\release\osatm3sd.$C > nul

if "%makeall%"=="" ..\us\emul.exe -i ..\us\dimkam.ini