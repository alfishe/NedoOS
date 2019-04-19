@echo off
echo atm=2 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV EQU 0x00 >> _sdk\syssets.asm
call make.bat

move test.trd ..\release\osatm2.trd > nul
if "%makeall%"=="" ..\us\emul.exe -i atm2.ini ..\release\osatm2.trd
