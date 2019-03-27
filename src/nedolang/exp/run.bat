path=..\_sdk\;..\..\_sdk\
call compile.bat

md tmp
copy *.ast tmp
copy *.var tmp
del *.ast
del *.var

del tok.f
copy export.A_ tok.f

copy *.A_ tmp
copy *.V_ tmp
copy *.S_ tmp
copy *.I_ tmp
del *.A_
del *.V_
del *.S_
del *.I_

del exp
ren exp.bin exp

nedotrd ../batch/basics.trd -eh exp.$b

nedotrd test.trd -n
nedotrd test.trd -ah exp.$b
nedotrd test.trd -ac exp
nedotrd test.trd -a tok.f

..\..\..\us\emul.exe test.trd
