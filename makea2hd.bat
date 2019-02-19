@echo off
del _sdk\atm.asm
copy _sdk\atm2.asm _sdk\atm.asm
del _sdk\syssets.asm
copy _sdk\syssets1.asm _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd nedoos.trd -eh code.$C
nedotrd nedoos.trd -a code.$C

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem us\emul791atm.exe nedoos.trd
us\emul.exe -i atm2.ini nedoos.trd
