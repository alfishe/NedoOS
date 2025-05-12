@echo off
echo atm=2 > _sdk\syssets.asm
echo atm2clock=0 >> _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo  define KOE >> _sdk\syssets.asm
echo  define KOEDI >> _sdk\syssets.asm
echo  define NOTURBO >> _sdk\syssets.asm
set makeall=1
FOR /F "tokens=1 delims=:MSPUnversiodcty " %%i IN ('svnversion -n') DO echo  define SVNREVISION %%i >> _sdk\syssets.asm
call make.bat
move test.trd ..\release\osp26.trd > nul
if "%notrunemu%"=="" ..\us\emul.exe ..\release\osp26.trd
set makeall=