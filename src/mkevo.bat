@echo off
echo atm=1 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=12 >> _sdk\syssets.asm
echo INETDRV=0x01 >> _sdk\syssets.asm
echo PS2KBD=0x01 >> _sdk\syssets.asm
echo  define NGSSD >> _sdk\syssets.asm
echo  define ATMRESIDENT >> _sdk\syssets.asm
call make.bat noneedtrd
cd  kernel
..\..\tools\sjasmplus --nologo --msg=war hobeta.asm > nul
cd ..
move /Y kernel\nedoos.$C ..\release\sd_boot.$C > nul
call ..\tools\chkimg.bat sd
if "%makeall%"=="" ..\us\emul.exe