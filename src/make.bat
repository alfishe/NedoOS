@echo off
if "%edeset%"=="" (
	setlocal ENABLEDELAYEDEXPANSION
	set edeset=1
)
SET currentdir=%CD%
SET releasedir=%CD%\..\release\

if not exist ..\release mkdir ..\release 
if not exist %releasedir%\bin mkdir %releasedir%\bin 
if not exist %releasedir%\doc mkdir %releasedir%\doc 

IF "%softbuilded%"=="" (
	cd %currentdir%\fatfs4os
	call build.bat
)
cd %currentdir%\kernel
call build.bat

cd %currentdir%
IF "%softbuilded%"=="" (
	set softbuilded=1
	FOR /R . %%i IN (build.bat) DO (
		if exist %%i (
			cd "%%~pi"
			IF NOT EXIST ffconf.h IF NOT EXIST ffsfunc.asm (
				SET installdir=bin
				echo "%%~pi"
				call build.bat
				if not exist "%releasedir%!installdir!" mkdir "%releasedir%!installdir!"
				FOR %%j IN (*.com) DO (
					copy /Y "*.com" "%releasedir%!installdir!" > nul
					IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir%!installdir!\%%~nj\" > nul
				)
				if exist *.ext ( copy *.ext %releasedir%!installdir!\ > nul )
				if exist *.ccc ( copy *.ccc %releasedir%!installdir!\ > nul )
				if exist *.crl ( copy *.crl %releasedir%!installdir!\ > nul )
				if exist *.crl ( copy *.i %releasedir%!installdir!\ > nul )
				if exist *.crl ( copy *.h %releasedir%!installdir!\ > nul )
			)
		)
	)
	cd %currentdir%

	FOR /R . %%i IN (*.txt) DO (
		if exist %%i (
			copy %%i %releasedir%\doc\ > nul
		)
	)
	FOR /R . %%i IN (*.new) DO (
		if exist %%i (
			copy %%i %releasedir%\doc\ > nul
		)
	)
	FOR /R . %%i IN (*.md) DO (
		if exist %%i (
			copy %%i %releasedir%\doc\ > nul
		)
	)

	copy autoexec.bat %releasedir%\bin\ > nul
	copy net.ini %releasedir%\bin\ > nul
	copy games\smb\antipac.fm2 %releasedir%\nedogame\ > nul
	copy ..\smb.nes %releasedir%\nedogame\ > nul
	copy basic\example.bas %releasedir%\bin\ > nul
)

if not "%1"=="noneedtrd" (
	nedotrd test.trd -n
	nedotrd test.trd -ah boot6000.$b
	nedotrd test.trd -s 24576 -ac kernel/code.c
        nedotrd test.trd -a %releasedir%/bin/autoexec.bat
        nedotrd test.trd -a %releasedir%/bin/reset.com
        nedotrd test.trd -a %releasedir%/bin/term.com
        rem nedotrd test.trd -a %releasedir%/bin/netterm.com
        nedotrd test.trd -a %releasedir%/bin/cmd.com
        nedotrd test.trd -a %releasedir%/bin/nv.com
        nedotrd test.trd -a %releasedir%/bin/nv.ext
        nedotrd test.trd -a %releasedir%/bin/hddfdisk.com
        nedotrd test.trd -a %releasedir%/bin/texted.com
        rem nedotrd test.trd -a %releasedir%/bin/more.com
        rem nedotrd test.trd -a %releasedir%/bin/nim.com
        rem nedotrd test.trd -a %releasedir%/bin/diff.com

rem 	for %%i in (%releasedir%\bin\*.*) do (
rem		nedotrd test.trd -a %%i
rem	)

rem network
        nedotrd test.trd -a %releasedir%/bin/wizcfg.com
        nedotrd test.trd -a %releasedir%/bin/ping.com
        nedotrd test.trd -a %releasedir%/bin/browser.com
        nedotrd test.trd -a %releasedir%/bin/browser/nos.htm
        nedotrd test.trd -a %releasedir%/bin/wget.com
        nedotrd test.trd -a %releasedir%/bin/moon.com
        nedotrd test.trd -a %releasedir%/bin/3ws.com
        nedotrd test.trd -a %releasedir%/bin/time.com
        nedotrd test.trd -a %releasedir%/bin/dmirc.com
        nedotrd test.trd -a %releasedir%/bin/dmftp.com
        nedotrd test.trd -a %releasedir%/bin/telnet.com

rem archives
        nedotrd test.trd -a %releasedir%/bin/pkunzip.com
        nedotrd test.trd -a %releasedir%/bin/tar.com
        nedotrd test.trd -a %releasedir%/bin/zxrar.com
        nedotrd test.trd -a %releasedir%/bin/unrar.com

rem disk/tape images
        rem nedotrd test.trd -a %releasedir%/bin/nedodel.com
        nedotrd test.trd -a %releasedir%/bin/rdtrd.com
        nedotrd test.trd -a %releasedir%/bin/wrtrd.com
        nedotrd test.trd -a %releasedir%/bin/playtap.com
        nedotrd test.trd -a %releasedir%/bin/dmm.com
        nedotrd test.trd -a %releasedir%/bin/nmisvc.com
        nedotrd test.trd -a %releasedir%/bin/tazres.bin

rem Pascal compiler
        nedotrd test.trd -a %releasedir%/bin/tp.com
        nedotrd test.trd -a %releasedir%/bin/turbo.msg

rem Nedolang compiler
        nedotrd test.trd -a %releasedir%/bin/comp.com
        nedotrd test.trd -a %releasedir%/bin/tok.com
        nedotrd test.trd -a %releasedir%/bin/asm.com
        rem nedotrd test.trd -a %releasedir%/bin/exp.com
        nedotrd test.trd -a %releasedir%/bin/io.h
        nedotrd test.trd -a %releasedir%/bin/iofast.i
        nedotrd test.trd -a %releasedir%/bin/lib.i

rem BASIC
        nedotrd test.trd -a %releasedir%/bin/basic.com
	nedotrd test.trd -a %releasedir%/bin/example.bas

rem C compiler
        nedotrd test.trd -a %releasedir%/bin/cc.com
        nedotrd test.trd -a %releasedir%/bin/cc2.com
        nedotrd test.trd -a %releasedir%/bin/clink.com
        nedotrd test.trd -a %releasedir%/bin/c.ccc
        nedotrd test.trd -a %releasedir%/bin/deff2.crl

rem music
        nedotrd test.trd -a %releasedir%/bin/player.com
        nedotrd test.trd -a %releasedir%/bin/modplay.com
        nedotrd test.trd -a %releasedir%/bin/pt.com
        rem nedotrd test.trd -a %releasedir%/bin/untr.com

rem gfx
        nedotrd test.trd -a %releasedir%/bin/scratch.com
        nedotrd test.trd -a %releasedir%/bin/view.com

	rem for %%i in (%releasedir%\doc\*.*) do (
	rem	nedotrd test.trd -a %%i
	rem )
        
)