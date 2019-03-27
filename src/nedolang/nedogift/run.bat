@echo off
path=..\_sdk\;..\..\_sdk\

nedotrd basics.trd -eb net-35.s
nedotrd basics.trd -eb net-tort.s
nedotrd basics.trd -eh NedoGift.$b

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

del code
ren demo.bin code
del nedogift.trd
nedotrd test.trd -n
nedotrd test.trd -ah NedoGift.$b
nedotrd test.trd -ac code

del font.bin
del net35.bin
del nettort.bin

..\..\..\us\emul.exe test.trd
