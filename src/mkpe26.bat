@echo off
echo atm=2 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
rem NEMOIDE=1 при монтировании виснет с левым символом на экране
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo 	define KOE >> _sdk\syssets.asm
echo 	define KOEDI >> _sdk\syssets.asm
echo 	define NOTURBO >> _sdk\syssets.asm
call make.bat

move test.trd ..\release\osp26.trd > nul
if "%makeall%"=="" ..\us\emul.exe ..\release\osp26.trd
