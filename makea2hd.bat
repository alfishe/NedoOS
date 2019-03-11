@echo off
rem del _sdk\atm.asm
rem copy _sdk\atm2.asm _sdk\atm.asm
rem del _sdk\syssets.asm
rem copy _sdk\syssets1.asm _sdk\syssets.asm
echo atm=2 > _sdk\syssets.asm
echo SYSDRV=1 >> _sdk\syssets.asm
echo INETDRV EQU 0x00 >> _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd nedoos.trd -eh code.$C
nedotrd nedoos.trd -a code.$C

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem us\emul791atm.exe nedoos.trd
us\emul.exe -i atm2.ini nedoos.trd
