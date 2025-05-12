@echo off
echo atm=3 > _sdk\syssets.asm
echo atm2clock=0 >> _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=4 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
		echo "%savepath%"
set makeall=1
FOR /F "tokens=1 delims=:MSP " %%i IN ('svnversion -n') DO echo  define SVNREVISION %%i >> _sdk\syssets.asm
call make.bat noneedtrd
cd kernel
..\..\tools\sjasmplus --nologo --msg=war hobeta.asm > nul
cd ..
move /Y kernel\nedoos.$C ..\release\osatm3hd.$C > nul
call ..\tools\chkimg.bat hdd
if "%notrunemu%"=="" ..\us\emul.exe
set makeall=