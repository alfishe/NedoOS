@echo off
echo atm=2 > _sdk\syssets.asm
echo sys_npages=64 >> _sdk\syssets.asm
echo NEMOIDE=0 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo 	define KOE >> _sdk\syssets.asm
if "%savepath%"=="" set savepath=%PATH%
call make.bat noneedtrd
path %savepath%
..\tools\sjasmplus --nologo kernel\hobeta.asm > nul
call ..\tools\chkimg.bat sd
move /Y nedoos.$C ..\release\osp26sd.$C > nul
if "%makeall%"=="" ..\us\emul.exe -i ..\us\dimkam.ini
