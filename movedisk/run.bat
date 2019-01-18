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

del movedisk
ren movedisk.bin movedisk

call ..\asm\mktrd.bat
nedotrd test.trd -a ..\movedisk\movedisk
nedotrd test.trd -a ..\nedodel\nedodel

..\..\emul\emul.exe test.trd
