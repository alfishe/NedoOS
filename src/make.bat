SET currentdir=%CD%
SET releasedir=%CD%\..\release\
@echo off

if not exist ..\release mkdir ..\release 
if not exist %releasedir%\bin mkdir %releasedir%\bin 
if not exist %releasedir%\doc mkdir %releasedir%\doc 

for %%i in (%currentdir%\fatfs4os,%currentdir%\kernel) do IF EXIST %%i\build.bat (
	echo %%i
	cd %%i
	call build.bat
)
cd %currentdir%
IF "%softbuilded%"=="" (
	set softbuilded=1
	FOR /R . %%i IN (build.bat) DO (
		if exist %%i (
			cd "%%~pi"
			IF NOT EXIST ffconf.h IF NOT EXIST ffsfunc.asm (
				echo "%%~pi"
				call build.bat
				if exist *.com ( move *.com %releasedir%\bin\ > nul )
				if exist *.ext ( copy *.ext %releasedir%\bin\ > nul )
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

	if not exist %releasedir%\bin\www mkdir %releasedir%\bin\www
	copy appsdm\3ws\www\*.* %releasedir%\bin\www\

	copy autoexec.bat %releasedir%\bin\ > nul
	copy net.ini %releasedir%\bin\ > nul
	copy games\smb\antipac.fm2 %releasedir%\bin\ > nul
	copy ..\smb.nes %releasedir%\bin\ > nul
	copy basic\example.bas %releasedir%\bin\ > nul
	copy games\wolf3d\wolftex.* %releasedir%\bin\ > nul
)

if not "%1"=="noneedtrd" (
        del %releasedir%\bin\*.zip > nul
        del %releasedir%\bin\*.fm2 > nul
	path=_sdk\
	nedotrd test.trd -n
	nedotrd test.trd -ah boot6000.$b
	nedotrd test.trd -s 24576 -ac kernel/code.c

	for %%i in (%releasedir%\bin\*.*) do (
		nedotrd test.trd -a %%i
	)

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
	rem nedotrd test.trd -a browser/test/index.htm
	rem nedotrd test.trd -a browser/test/page.htm
	rem nedotrd test.trd -a browser/test/atmmain.htm
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