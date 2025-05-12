@echo off
echo atm=3 > _sdk\syssets.asm
echo atm2clock=0 >> _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
set makeall=1
FOR /F "tokens=1 delims=:MSPUnversiodcty " %%i IN ('svnversion -n') DO echo  define SVNREVISION %%i >> _sdk\syssets.asm
call make.bat
move test.trd ..\release\osatm3.trd > nul
if "%notrunemu%"=="" ..\us\emul.exe ..\release\osatm3.trd
set makeall=