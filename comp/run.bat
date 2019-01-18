call compile.bat

copy *.asm tmp
copy *.var tmp
del *.asm
del *.var

copy *.A_ tmp
copy *.V_ tmp
copy *.S_ tmp
copy *.I_ tmp
del *.A_
del *.V_
del *.S_
del *.I_

del nedolang
ren comp.bin nedolang

nedotrd test.trd -n
nedotrd test.trd -ah ..\batch\batch.$b
nedotrd test.trd -s 64000 -ac ..\batch\batch
nedotrd test.trd -a compile.bat

nedotrd test.trd -a ..\comp\nedolang
nedotrd test.trd -a ..\tok\nedotok
nedotrd test.trd -a ..\asm\nedoasm
nedotrd test.trd -a ..\nedodel\nedodel
nedotrd test.trd -a ..\movedisk\movedisk
nedotrd test.trd -a ..\diff\diff
nedotrd test.trd -a ..\_sdk\str.h
nedotrd test.trd -a ..\_sdk\io.h
nedotrd test.trd -a sizesz80.h
nedotrd test.trd -a ..\_sdk\emit.h
nedotrd test.trd -a ..\_sdk\emit.c
nedotrd test.trd -a ..\_sdk\read.c
nedotrd test.trd -a ..\_sdk\typecode.h
nedotrd test.trd -a regs.c
nedotrd test.trd -a codez80.c
nedotrd test.trd -a commands.c
nedotrd test.trd -a compile.c
nedotrd test.trd -a compcode.s
nedotrd test.trd -a comp.s
nedotrd test.trd -a ..\_sdk\lib.i
nedotrd test.trd -a ..\_sdk\str.i
nedotrd test.trd -a ..\_sdk\iofast.i
nedotrd test.trd -a ..\_sdk\io.c

..\..\emul\emul.exe test.trd
