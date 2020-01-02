@echo off
if "%settedpath%"=="" call "_sdk\setpath.bat"
echo atm=2 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV=0x00 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
call make.bat
nedotrd test.trd -eh code.$C
nedotrd test.trd -a code.$C
copy code.$C ..\release\osatm2hd.$C > nul
move test.trd ..\release\osatm2hd.trd > nul
call ..\tools\chkimg.bat hdd
if "%makeall%"=="" ..\us\emul.exe -i atm2.ini ..\release\osatm2hd.trd
