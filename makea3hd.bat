@echo off
del _sdk\atm.asm
copy _sdk\atm3.asm _sdk\atm.asm
del _sdk\syssets.asm
copy _sdk\syssets1.asm _sdk\syssets.asm
call make.bat

path=_sdk\
nedotrd test.trd -eh code.$C
nedotrd test.trd -a code.$C

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem ..\us035\emullvd test.trd
us\emullvd test.trd
