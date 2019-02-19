@echo off
del _sdk\atm.asm
copy _sdk\atm2.asm _sdk\atm.asm
del _sdk\syssets.asm
copy _sdk\syssets4.asm _sdk\syssets.asm
call make.bat

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem us\emul791atm.exe nedoos.trd
us\emul.exe -i atm2.ini nedoos.trd
