@echo off
echo atm=1 > _sdk\syssets.asm
echo atm2clock=0 >> _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x01 >> _sdk\syssets.asm
echo 	define NONGSSD >> _sdk\syssets.asm
call make.bat noneedtrd
cd kernel
..\..\tools\sjasmplus --nologo --msg=war hobeta.asm > nul
cd ..
move /Y kernel\nedoos.$C ..\release\osevsd-g.$C > nul
call ..\tools\chkimg.bat sd
if "%makeall%"=="" ..\us\emul.exe