path=..\_sdk\

echo ...compiling...
nedolarm ../_sdk/read.c ../_sdk/fmttg.h migalka.c ../_sdk/io.c ../_sdk/str.c
type err.f

echo ...assembling...
nedotarm _tokarm.s ../_sdk/read.asm ../_sdk/read.var ../_sdk/fmttg.var migalka.asm migalka.var ../_sdk/libarm.i ../_sdk/ioarm.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/str.asm ../_sdk/str.var
nedoaarm _tokarm.S_

rem nedopad _tokarm.bin _out.bin 0 65536

pause

copy *.asm tmp
copy *.var tmp
rem del *.asm
rem del *.var

nedotrd testtrd.bin -n
nedotrd testtrd.bin -a ..\_sdk\str.i

rem copy /b _out.bin + testtrd.bin _all.bin
