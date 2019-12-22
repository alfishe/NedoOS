@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
call make.bat noneedtrd
..\tools\sjasmplus --nologo kernel\hobeta.asm > nul
move /Y nedoos.$C ..\release\osatm3sd.$C > nul
call ..\tools\chkimg.bat sd
if "%makeall%"=="" ..\us\emul.exe