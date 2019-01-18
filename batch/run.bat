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

del batch
ren batch.bin batch

nedotrd basics.trd -eh batch.$b

call ..\asm\mktrd.bat

..\..\emul\emul.exe test.trd
