cd kernel
call build.bat
cd ..
cd cmd
call build.bat
cd ..
cd nv
call build.bat
cd ..
cd gfxed
call build.bat
cd ..
cd tok
call build.bat
cd ..
cd asm
call build.bat
cd ..
cd comp
call build.bat
cd ..
cd texted
call build.bat
cd ..
cd basic
call build.bat
cd ..
cd diff
call build.bat
cd ..
copy cmd\cmd.com bin\cmd.com
copy nv\nv.com bin\nv.com
copy nv\nv.ext bin\nv.ext
copy gfxed\gfxed.com bin\gfxed.com
copy texted\texted.com bin\texted.com
copy comp\comp.com bin\comp.com
copy tok\tok.com bin\tok.com
copy asm\asm.com bin\asm.com
copy basic\basic.com bin\basic.com
copy diff\diff.com bin\diff.com
@echo off
path=_sdk\
nedotrd test.trd -n
nedotrd test.trd -ah boot6000.$b
nedotrd test.trd -s 24576 -ac kernel/code.c
nedotrd test.trd -a bin/cmd.com
nedotrd test.trd -a bin/gfxed.com
nedotrd test.trd -a bin/texted.com
nedotrd test.trd -a bin/nv.com
nedotrd test.trd -a bin/nv.ext
nedotrd test.trd -a bin/basic.com
nedotrd test.trd -a bin/diff.com
nedotrd test.trd -a gfxed/lanscape.bmp
nedotrd test.trd -a autoexec.bat

nedotrd test.trd -a bin/comp.com
nedotrd test.trd -a bin/tok.com
nedotrd test.trd -a bin/asm.com
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

nedotrd test.trd -a license.txt
