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

del nedotok
ren tok.bin nedotok

nedotrd test.trd -n
nedotrd test.trd -ah ..\batch\batch.$b
nedotrd test.trd -s 64000 -ac ..\batch\batch
nedotrd test.trd -a compile.bat
nedotrd test.trd -a ..\comp\nedolang
nedotrd test.trd -a ..\tok\nedotok
nedotrd test.trd -a ..\asm\nedoasm
nedotrd test.trd -a ..\diff\diff
nedotrd test.trd -a ..\_sdk\str.h
nedotrd test.trd -a ..\_sdk\io.h
nedotrd test.trd -a ..\_sdk\read.c
nedotrd test.trd -a ..\_sdk\fmttg.h
nedotrd test.trd -a ..\_sdk\fmtz80.h
nedotrd test.trd -a token.c
nedotrd test.trd -a tokenz80.c
nedotrd test.trd -a tok.s
nedotrd test.trd -a ..\_sdk\lib.i
nedotrd test.trd -a ..\_sdk\str.i
nedotrd test.trd -a ..\_sdk\io.i
nedotrd test.trd -a ..\_sdk\io.c

..\..\emul\emul.exe test.trd
