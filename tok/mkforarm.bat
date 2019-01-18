path=..\_sdk\

echo ...compiling...
nedolarm ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c ../_sdk/io.c ../_sdk/str.c
type err.f

echo ...assembling...
nedotarm _tokarm.s ../_sdk/read.asm ../_sdk/read.var ../_sdk/fmttg.var token.asm token.var tokenz80.asm tokenz80.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/str.asm ../_sdk/str.var
nedoaarm _tokarm.S_

nedopad _tokarm.bin _out.bin 0 65536

pause

copy *.asm tmp
copy *.var tmp

nedotrd testtrd.bin -n
nedotrd testtrd.bin -a ..\_sdk\str.i

copy /b _out.bin + testtrd.bin _all.bin
