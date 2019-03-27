path=..\_sdk\;..\..\_sdk\
call compile.bat

md tmp
copy *.ast tmp
copy *.var tmp
del *.ast
del *.var

copy *.A_ tmp
copy *.V_ tmp
copy *.S_ tmp
copy *.I_ tmp
del *.A_
del *.V_
del *.S_
del *.I_

del movedisk
ren movedisk.bin movedisk

call ..\asm\mktrd.bat
nedotrd test.trd -a ..\movedisk\movedisk
nedotrd test.trd -a ..\nedodel\nedodel

..\..\..\us\emul.exe test.trd
