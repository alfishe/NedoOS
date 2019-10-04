@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
		echo "%savepath%"
call make.bat noneedtrd
..\tools\sjasmplus --nologo kernel\hobeta.asm > nul
call ..\tools\chkimg.bat hdd
move /Y nedoos.$C ..\release\osatm3hd.$C > nul
if "%makeall%"=="" ..\us\emul.exe -i ..\us\dimkam.ini