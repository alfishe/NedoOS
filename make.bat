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

rem copy cmd\cmd.com bin\cmd.com
rem copy nv\nv.com bin\nv.com
rem copy gfxed\gfxed.com bin\gfxed.com
rem copy texted\texted.com bin\texted.com
rem copy comp\comp.com bin\comp.com
rem copy tok\tok.com bin\tok.com
rem copy asm\asm.com bin\asm.com
rem copy basic\basic.com bin\basic.com
rem copy diff\diff.com bin\diff.com
rem copy setfont\setfont.com bin\setfont.com
rem copy browser\browser.com bin\browser.com
rem copy player\player.com bin\player.com

@echo off
path=_sdk\
nedotrd test.trd -n
nedotrd test.trd -ah boot6000.$b
nedotrd test.trd -s 24576 -ac kernel/code.c

for %%i in (bin\*.*) do (
    nedotrd test.trd -a %%i
)
rem nedotrd test.trd -a bin/cmd.com
rem nedotrd test.trd -a bin/gfxed.com
rem nedotrd test.trd -a bin/texted.com
rem nedotrd test.trd -a bin/nv.com
rem nedotrd test.trd -a bin/nv.ext
rem nedotrd test.trd -a bin/basic.com
rem nedotrd test.trd -a bin/diff.com
rem nedotrd test.trd -a bin/setfont.com
rem nedotrd test.trd -a bin/player.com
rem nedotrd test.trd -a bin/browser.com
rem nedotrd test.trd -a bin/autoexec.bat
rem nedotrd test.trd -a bin/comp.com
rem nedotrd test.trd -a bin/tok.com
rem nedotrd test.trd -a bin/asm.com

rem nedotrd test.trd -a setfont/1125code.fnt
nedotrd test.trd -a gfxed/lanscape.bmp

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

nedotrd test.trd -a nedogift/testmusi.pt3
nedotrd test.trd -a player/COCO.pt2
nedotrd test.trd -a browser/index.html
nedotrd test.trd -a browser/page.html
nedotrd test.trd -a browser/gobutton.gif

nedotrd test.trd -a license.txt

del nedoos.trd
ren test.trd nedoos.trd
