@echo off
if "%settedpath%"=="" call "_sdk\setpath.bat"
echo atm=2 > _sdk\syssets.asm
echo atm2clock=1 >> _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
rem echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo 	define ATMRESIDENT >> _sdk\syssets.asm
rem echo 	define USETOPDOWNMEM >> _sdk\syssets.asm
echo 	define KEEPPG38 >> _sdk\syssets.asm
rem echo 	define FREEPG0 >> _sdk\syssets.asm
rem echo 	define FREEPG4 >> _sdk\syssets.asm
rem echo 	define FREEPG6 >> _sdk\syssets.asm
set makeall=1
FOR /F "tokens=1 delims=: " %%i IN ('svnversion -n') DO echo define SVNREVISION %%i >> _sdk\syssets.asm
call make.bat
nedotrd test.trd -eh code.$C
nedotrd test.trd -a code.$C
copy code.$C ..\release\osatm2hd.$C > nul
move test.trd ..\release\osatm2hd.trd > nul
call ..\tools\chkimg.bat hdd
if "%notrunemu%"=="" ..\us\emul.exe -i atm2.ini ..\release\osatm2hd.trd
set makeall=