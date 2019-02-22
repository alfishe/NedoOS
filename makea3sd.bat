@echo off
rem del _sdk\atm.asm
rem copy _sdk\atm3.asm _sdk\atm.asm
rem del _sdk\syssets.asm
rem copy _sdk\syssets0.asm _sdk\syssets.asm
echo atm=3 > _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd nedoos.trd -eh code.$C
nedotrd nedoos.trd -a code.$C

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
us\emul.exe nedoos.trd
