@echo off
path=..\_sdk\

nedotrd basics.trd -eb net-35.s
nedotrd basics.trd -eb net-tort.s
nedotrd basics.trd -eh NedoGift.$b

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

del code
ren demo.bin code
del nedogift.trd
nedotrd nedogift.trd -n
nedotrd nedogift.trd -ah NedoGift.$b
nedotrd nedogift.trd -ac code

..\..\emul\emul.exe nedogift.trd
