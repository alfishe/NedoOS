@echo off
echo atm equ 3 > _sdk\atm.asm
echo iszxevo equ 1 >> _sdk\atm.asm
echo SYSDRV=4 > _sdk\syssets.asm
call make.bat

rem del ..\us035\user.l
rem copy us\user.l ..\us035\user.l
rem ..\us035\emullvd test.trd
us\emullvd test.trd
