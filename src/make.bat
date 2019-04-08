SET currentdir=%CD%
SET releasedir=%CD%\..\release\
@echo off

FOR /R . %%i IN (build.bat) DO (
        rem echo "%%i"
	if exist %%i (
                echo "%%~pi"
		cd "%%~pi"
		call build.bat
		if exist *.com ( move *.com %releasedir%\bin\ > nul )
		if exist *.ext ( copy *.ext %releasedir%\bin\ > nul )
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

path=_sdk\
nedotrd test.trd -n
nedotrd test.trd -ah boot6000.$b
nedotrd test.trd -s 24576 -ac kernel/code.c

for %%i in (%releasedir%\bin\*.*) do (
    nedotrd test.trd -a %%i
)

nedotrd test.trd -a scratch/lanscape.bmp

nedotrd test.trd -a nedolang/comp/sizesz80.h
nedotrd test.trd -a nedolang/comp/comp_os.s
nedotrd test.trd -a nedolang/comp/compc_os.s
nedotrd test.trd -a nedolang/comp/compile.c
nedotrd test.trd -a nedolang/comp/codez80.c
nedotrd test.trd -a nedolang/comp/commands.c
nedotrd test.trd -a nedolang/comp/regs.c
nedotrd test.trd -a nedolang/comp/test.bat

nedotrd test.trd -a _sdk/str.h
nedotrd test.trd -a _sdk/io.h
nedotrd test.trd -a _sdk/emit.h
nedotrd test.trd -a _sdk/emit.c
nedotrd test.trd -a _sdk/read.c
nedotrd test.trd -a _sdk/typecode.h
nedotrd test.trd -a _sdk/lib.i
nedotrd test.trd -a _sdk/str.i
nedotrd test.trd -a _sdk/io_os.i
nedotrd test.trd -a _sdk/sysdefs.asm

nedotrd test.trd -a basic/example.bas
nedotrd test.trd -a nedolang/nedogift/testmusi.pt3
nedotrd test.trd -a player/coco.pt2
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
nedotrd test.trd -a modplay/scalsfjy.mod

for %%i in (%releasedir%\doc\*.*) do (
    nedotrd test.trd -a %%i
)
