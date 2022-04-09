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
del batch
ren batch.bin batch
nedotrd basics.trd -eh ace.$b
nedotrd basics.trd -eh batch.$b
call ..\asm\mktrd.bat
..\..\..\us\emul.exe test.trd
