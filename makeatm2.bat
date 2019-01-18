@echo off
del _sdk\atm.asm
copy _sdk\atm2.asm _sdk\atm.asm
del _sdk\syssets.asm
copy _sdk\syssets4.asm _sdk\syssets.asm
call make.bat

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem ..\us035\emul791atm.exe test.trd
rem us\emul791atm.exe test.trd
us\unreal0380atm.exe test.trd
