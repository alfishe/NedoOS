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

nedotrd test.trd -n
nedotrd ..\batch\basics.trd -eh boot.$b
nedotrd test.trd -ah boot.$b
nedotrd test.trd -s 24576 -ac main.bin

rem ..\..\emul\emul.exe test.trd
..\us\emullvd.exe test.trd
