path=..\_sdk\;..\..\_sdk\

echo ...compiling...
nedolarm ../_sdk/read.c ../_sdk/fmttg.h migalka.c ../_sdk/io.c ../_sdk/str.c
type err.f

echo ...assembling...
nedotarm _tokarm.s ../_sdk/read.ast ../_sdk/read.var ../_sdk/fmttg.var migalka.ast migalka.var ../_sdk/libarm.i ../_sdk/ioarm.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.ast ../_sdk/str.var
nedoaarm _tokarm.S_

rem nedopad _tokarm.bin _out.bin 0 65536

pause

md tmp
copy *.ast tmp
copy *.var tmp
del *.ast
del *.var

nedotrd test.trd -n
nedotrd test.trd -a ..\_sdk\str.i

rem copy /b _out.bin + test.trd _all.bin
