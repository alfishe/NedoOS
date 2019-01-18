call compile.bat

copy *.asm tmp
copy *.var tmp
del *.asm
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

nedotrd basics.trd -eh exp.$b

nedotrd testexp.trd -n
nedotrd testexp.trd -ah exp.$b
nedotrd testexp.trd -ac exp
nedotrd testexp.trd -a tok.f

..\..\emul\emul.exe testexp.trd
