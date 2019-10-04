if "%settedpath%"=="" call "..\_sdk\setpath.bat"
nedolarm ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c ../_sdk/io.c ../_sdk/str.c
type err.f
rem not tested after change *.asm -> *.ast
nedotarm _tokarm.s ../_sdk/read.ast ../_sdk/read.var ../_sdk/fmttg.var token.ast token.var tokenz80.ast tokenz80.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.ast ../_sdk/str.var
nedoaarm _tokarm.S_
nedopad _tokarm.bin _out.bin 0 65536
pause
copy *.ast tmp
copy *.var tmp
nedotrd testtrd.bin -n
nedotrd testtrd.bin -a ..\_sdk\str.i
copy /b _out.bin + testtrd.bin _all.bin
