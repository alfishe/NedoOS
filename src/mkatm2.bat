@echo off
echo atm=2 > _sdk\syssets.asm
echo atm2clock=1 >> _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo  define ATMRESIDENT >> _sdk\syssets.asm
echo  define KEEPPG38 >> _sdk\syssets.asm
set makeall=1
FOR /F "tokens=1 delims=:MSPUnversiodcty " %%i IN ('svnversion -n') DO echo  define SVNREVISION %%i >> _sdk\syssets.asm
call make.bat
move test.trd ..\release\osatm2.trd > nul
if "%notrunemu%"=="" ..\us\emul.exe -i atm2.ini ..\release\osatm2.trd
set makeall=