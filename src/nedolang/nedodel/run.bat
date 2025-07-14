call compile.bat
md tmp
copy *.A_ tmp
copy *.V_ tmp
copy *.S_ tmp
copy *.I_ tmp
del *.A_
del *.V_
del *.S_
del *.I_
del nedodel
ren del.bin nedodel
call ..\asm\mktrd.bat
nedotrd test.trd -a ..\movedisk\movedisk
nedotrd test.trd -a ..\nedodel\nedodel
..\..\..\us\emul.exe test.trd
