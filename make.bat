SET currentdir=%CD%
FOR /R . %%i IN (build.bat) DO (
	if exist %%i (
		cd "%%~pi"
		call build.bat
		copy *.com %currentdir%\bin\
		rem copy *.ini %currentdir%\bin\
		rem copy *.ext %currentdir%\bin\
	)
)
cd %currentdir%

copy nv\nv.ext bin\nv.ext

@echo off
path=_sdk\
nedotrd test.trd -n
nedotrd test.trd -ah boot6000.$b
nedotrd test.trd -s 24576 -ac kernel/code.c

for %%i in (bin\*.*) do (
    nedotrd test.trd -a %%i
)

rem nedotrd test.trd -a scratch/lanscape.bmp

nedotrd test.trd -a comp/sizesz80.h
nedotrd test.trd -a comp/comp_os.s
nedotrd test.trd -a comp/compc_os.s
nedotrd test.trd -a comp/compile.c
nedotrd test.trd -a comp/codez80.c
nedotrd test.trd -a comp/commands.c
nedotrd test.trd -a comp/regs.c
nedotrd test.trd -a comp/test.bat

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
nedotrd test.trd -a nedogift/testmusi.pt3
nedotrd test.trd -a player/COCO.pt2
nedotrd test.trd -a browser/index.html
nedotrd test.trd -a browser/page.html
rem nedotrd test.trd -a browser/zajchik.gif
rem nedotrd test.trd -a browser/GIRL.JPG
rem nedotrd test.trd -a browser/csprmain.htm
rem nedotrd test.trd -a browser/spwiki.html
rem nedotrd test.trd -a browser/atmmain.htm
rem nedotrd test.trd -a browser/atmpg.htm
rem nedotrd test.trd -a browser/atmpg2.htm
nedotrd test.trd -a browser/6914fast.gif
nedotrd test.trd -a browser/6908fast.gif
nedotrd test.trd -a browser/animatie.gif
nedotrd test.trd -a browser/sprites.gif
nedotrd test.trd -a pkunzip/pkunzip.zip

nedotrd test.trd -a license.txt

del nedoos.trd
ren test.trd nedoos.trd
