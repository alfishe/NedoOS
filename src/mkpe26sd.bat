@echo off
echo atm=3 > _sdk\syssets.asm
echo atm2clock=0 >> _sdk\syssets.asm
echo sys_npages=128 >> _sdk\syssets.asm
rem так можно запороть рамдиск!

echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x00 >> _sdk\syssets.asm
echo 	define KOE >> _sdk\syssets.asm
echo 	define NGSSD >> _sdk\syssets.asm
FOR /F "tokens=1 delims=:MSPUnversiodcty " %%i IN ('svnversion -n') DO echo  define SVNREVISION %%i >> _sdk\syssets.asm
rem echo  define KOEDI >> _sdk\syssets.asm
rem echo  define NOMOUSE >> _sdk\syssets.asm
rem echo  define NOCMOS >> _sdk\syssets.asm
rem echo  define NOPAL >> _sdk\syssets.asm
set makeall=1
call make.bat noneedtrd
cd kernel
..\..\tools\sjasmplus --nologo --msg=war hobeta.asm > nul
cd ..
move /Y kernel\nedoos.$C ..\release\osp26sd.$C > nul
call ..\tools\chkimg.bat sd
if "%notrunemu%"=="" ..\us\emul.exe -i ..\us\dimkam.ini
set makeall=