@echo off
echo atm=3 > _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
call make.bat

move test.trd ..\release\osatm3.trd > nul
if "%makeall%"=="" ..\us\emul.exe ..\release\osatm3.trd
