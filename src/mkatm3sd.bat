@echo off
echo atm=3 > _sdk\syssets.asm
echo sys_npages=192 >> _sdk\syssets.asm
echo NEMOIDE=1 >> _sdk\syssets.asm
echo SYSDRV=0 >> _sdk\syssets.asm
echo INETDRV EQU 0x01 >> _sdk\syssets.asm
if "%savepath%"=="" set savepath=%PATH%

call make.bat noneedtrd

path %savepath%

..\tools\sjasmplus --nologo kernel\hobeta.asm > nul

IF NOT EXIST ..\us\sd_nedo.vhd (
	echo create vdisk file="%cd%\sd_nedo.vhd" MAXIMUM=64 TYPE=FIXED > VHDcreate.txt
	echo select vdisk file="%cd%\sd_nedo.vhd" >> VHDcreate.txt
	echo attach vdisk >> VHDcreate.txt
	echo create part primary  >> VHDcreate.txt
	echo select part 1 >> VHDcreate.txt
	echo format label="NEDOOS" quick fs=FAT32 >> VHDcreate.txt
	echo detach vdisk >> VHDcreate.txt
	diskpart /s VHDcreate.txt
	del VHDcreate.txt
	move sd_nedo.vhd ..\us\
)

..\tools\dmimg ..\us\sd_nedo.vhd mkdir bin > nul
..\tools\dmimg ..\us\sd_nedo.vhd mkdir bin/www > nul
..\tools\dmimg ..\us\sd_nedo.vhd mkdir bin/doc > nul
..\tools\dmimg ..\us\sd_nedo.vhd put nedoos.$c nedoos.$c
FOR %%i IN (..\release\bin\*.*) DO (
        ..\tools\dmimg ..\us\sd_nedo.vhd put %%i bin/%%~nxi
)
FOR %%i IN (..\release\bin\www\*.*) DO (
        ..\tools\dmimg ..\us\sd_nedo.vhd put %%i bin/www/%%~nxi
)
FOR %%i IN (..\release\doc\*.*) DO (
        ..\tools\dmimg ..\us\sd_nedo.vhd put %%i bin/doc/%%~nxi
)

move /Y nedoos.$C ..\release\osatm3sd.$C > nul

if "%makeall%"=="" ..\us\emul.exe