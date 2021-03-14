@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=128 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo 	define KOE >> _sdk\syssets.asm
rem echo 	define KOEDI >> _sdk\syssets.asm
rem echo 	define NOMOUSE >> _sdk\syssets.asm
rem echo 	define NOCMOS >> _sdk\syssets.asm
rem echo 	define NOPAL >> _sdk\syssets.asm
call make.bat noneedtrd
cd kernel
..\..\tools\sjasmplus --nologo --msg=war hobeta.asm > nul
cd ..
move /Y kernel\nedoos.$C ..\release\osp26sd.$C > nul
call ..\tools\chkimg.bat sd
if "%makeall%"=="" ..\us\emul.exe -i ..\us\dimkam.ini