@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd test.trd -eh code.$C
nedotrd test.trd -a code.$C
copy code.$C ..\release\osatm3sd.$C > nul

move test.trd ..\release\osatm3sd.trd > nul
if "%makeall%"=="" ..\us\emul.exe ..\release\osatm3sd.trd
