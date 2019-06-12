@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
echo PS2KBD EQU 0x00 >> _sdk\syssets.asm
call make.bat

move test.trd ..\release\osatm3.trd > nul
if "%makeall%"=="" ..\us\emul.exe ..\release\osatm3.trd
