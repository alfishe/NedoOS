@echo off
echo atm=2 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=8 >> _sdk\syssets.asm
echo INETDRV EQU 0x00 >> _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd test.trd -eh code.$C
nedotrd test.trd -a code.$C
copy code.$C ..\release\osatm2hd.$C > nul

move test.trd ..\release\osatm2hd.trd > nul
if "%makeall%"=="" ..\us\emul.exe -i atm2.ini ..\release\osatm2hd.trd
