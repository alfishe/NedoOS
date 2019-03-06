@echo off
rem del _sdk\atm.asm
rem copy _sdk\atm3.asm _sdk\atm.asm
rem del _sdk\syssets.asm
rem copy _sdk\syssets4.asm _sdk\syssets.asm
echo atm=3 > _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
call make.bat

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
us\emul.exe nedoos.trd
