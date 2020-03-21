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
					move "*.com" "%releasedir%!installdir!" > nul
					IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir%!installdir!\%%~nj\" > nul
				)
				if exist *.ext ( copy *.ext %releasedir%!installdir!\ > nul )
			)
		)
	)
	cd %currentdir%

	FOR /R . %%i IN (*.txt) DO (
		if exist %%i (
			copy %%i %releasedir%\doc\ > nul
		)
	)
	cd %currentdir%

	FOR /R . %%i IN (*.new) DO (
		if exist %%i (
			copy %%i %releasedir%\doc\ > nul
		)
	)
	cd %currentdir%

	copy autoexec.bat %releasedir%\bin\ > nul
	copy net.ini %releasedir%\bin\ > nul
	copy games\smb\antipac.fm2 %releasedir%\bin\ > nul
	copy ..\smb.nes %releasedir%\bin\ > nul
	copy basic\example.bas %releasedir%\bin\ > nul
	rem copy games\wolf3d\wolftex.* %releasedir%\bin\ > nul
)

if not "%1"=="noneedtrd" (
        del %releasedir%\bin\forest.dat > nul
        del %releasedir%\bin\*.zip > nul
        del %releasedir%\bin\*.fm2 > nul
        md %releasedir%\br
        ren %releasedir%\bin\browser.com mowser.com
        move %releasedir%\bin\evsummer.com %releasedir%\br\
        move %releasedir%\bin\br*.* %releasedir%\br\
        ren %releasedir%\bin\mowser.com browser.com
	nedotrd test.trd -n
	nedotrd test.trd -ah boot6000.$b
	nedotrd test.trd -s 24576 -ac kernel/code.c

	for %%i in (%releasedir%\bin\*.*) do (
		nedotrd test.trd -a %%i
	)
        move %releasedir%\br\*.* %releasedir%\bin\
        rd %releasedir%\br

	rem nedotrd test.trd -a scratch/lanscape.bmp

	rem nedotrd test.trd -a nedolang/comp/sizesz80.h
	rem nedotrd test.trd -a nedolang/comp/comp_os.s
	rem nedotrd test.trd -a nedolang/comp/compc_os.s
	rem nedotrd test.trd -a nedolang/comp/compile.c
	rem nedotrd test.trd -a nedolang/comp/codez80.c
	rem nedotrd test.trd -a nedolang/comp/commands.c
	rem nedotrd test.trd -a nedolang/comp/regs.c
	rem nedotrd test.trd -a nedolang/comp/test.bat

	rem nedotrd test.trd -a nedolang/_sdk/str.h
	rem nedotrd test.trd -a nedolang/_sdk/io.h
	rem nedotrd test.trd -a nedolang/_sdk/emit.h
	nedotrd test.trd -a nedolang/_sdk/emit.c
	rem nedotrd test.trd -a nedolang/_sdk/read.c
	rem nedotrd test.trd -a nedolang/_sdk/typecode.h
	rem nedotrd test.trd -a nedolang/_sdk/lib.i
	rem nedotrd test.trd -a nedolang/_sdk/str.i
	rem nedotrd test.trd -a nedolang/_sdk/io_os.i
	rem nedotrd test.trd -a _sdk/sysdefs.asm

	rem nedotrd test.trd -a basic/example.bas
	rem nedotrd test.trd -a nedolang/nedogift/testmusi.pt3
	rem nedotrd test.trd -a player/coco.pt2
	nedotrd test.trd -a browser/browser/nos.htm
	nedotrd test.trd -a browser/house.svg
	rem nedotrd test.trd -a browser/test/zajchik.gif
	rem nedotrd test.trd -a browser/test/girl.jpg
	rem nedotrd test.trd -a browser/test/csprmain.htm
	rem nedotrd test.trd -a browser/test/spwiki.htm
	rem nedotrd test.trd -a browser/test/atmpg.htm
	rem nedotrd test.trd -a browser/test/atmpg2.htm
	rem nedotrd test.trd -a browser/test/6914fast.gif
	rem nedotrd test.trd -a browser/test/6908fast.gif
	rem nedotrd test.trd -a browser/test/6909wrbg.gif
	rem nedotrd test.trd -a browser/test/animatie.gif
	rem nedotrd test.trd -a browser/test/sprites.gif
	rem nedotrd test.trd -a browser/test/listh.htm
	rem nedotrd test.trd -a browser/test/alphaba3.png
	rem nedotrd test.trd -a browser/test/clown.png
	rem nedotrd test.trd -a browser/test/basn3p01.png
	rem nedotrd test.trd -a browser/test/basn3p02.png
	rem nedotrd test.trd -a browser/test/basn3p04.png
	rem nedotrd test.trd -a browser/test/s40n3p04.png
	rem nedotrd test.trd -a browser/test/basn0g01.png
	rem nedotrd test.trd -a browser/test/basn0g02.png
	rem nedotrd test.trd -a browser/test/basn0g04.png
	rem nedotrd test.trd -a browser/test/basi0g16.png
	rem nedotrd test.trd -a pkunzip/pkunzip.zip
	rem nedotrd test.trd -a modplay/scalsfjy.mod

	rem nedotrd test.trd -a browser/test/newview.png

	for %%i in (%releasedir%\doc\*.*) do (
		nedotrd test.trd -a %%i
	)
        
)