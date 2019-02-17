@ECHO OFF
setlocal enabledelayedexpansion

REM zxevo, atm2, atm3
SET PLATFORM=zxevo
SET SYSDRIVE=4
REM 0-none,1-w5300
SET INETDRV=1
SET BIN=cmd\cmd.com nv\nv.com gfxed\gfxed.com texted\texted.com comp\comp.com
SET BIN=!BIN! tok\tok.com asm\asm.com basic\basic.com diff\diff.com
SET ADDBIN=nv\nv.ext
SET TOTRD=gfxed/lanscape.bmp autoexec.bat comp/sizesz80.h comp/comp_os.s comp/compile.c
SET TOTRD=!TOTRD! comp/codez80.c comp/commands.c comp/regs.c comp/test.bat
SET TOTRD=!TOTRD! _sdk/str.h _sdk/io.h _sdk/emit.h _sdk/emit.c _sdk/read.c
SET TOTRD=!TOTRD! _sdk/typecode.h _sdk/lib.i _sdk/str.i _sdk/io_os.i license.txt

SET EVOBIN=appsDM\setfont\setfont.com appsDM\noice\nim.com


IF %PLATFORM%==atm2 (
	echo atm=2 > _sdk\atm.asm
) ELSE IF %PLATFORM%==atm3 (
	echo atm=3 > _sdk\atm.asm
) ELSE IF %PLATFORM%==zxevo (
	echo atm=3 > _sdk\atm.asm
	SET BIN=!BIN! %EVOBIN%
)
echo SYSDRV=%SYSDRIVE% > _sdk\syssets.asm
echo INETDRV=%INETDRV% >> _sdk\atm.asm
IF %INETDRV%==1 (
	SET BIN=!BIN! appsDM\dhcpc\dhcpc.com appsDM\dmirc\dmirc.com appsDM\dmftp\dmftp.com
)

cd kernel
call build.bat
cd ..

SET rootdir=%CD%
FOR %%a IN (!BIN!) do (
	CD %%~dpa
	call build.bat
	CD %rootdir%
)

FOR %%a IN (!BIN! %ADDBIN%) do copy %%a "bin\%%~nxa"

@echo off
path=_sdk\
nedotrd test.trd -n
nedotrd test.trd -ah boot6000.$b
nedotrd test.trd -s 24576 -ac kernel/code.c
FOR %%a IN (!BIN! %ADDBIN% !TOTRD!) do 	nedotrd test.trd -a %%a
pause