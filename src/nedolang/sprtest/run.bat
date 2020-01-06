if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
set path=%PATH%;..\_sdk\
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
nedotrd test.trd -n
nedotrd ..\batch\basics.trd -eh boot.$b
nedotrd test.trd -ah boot.$b
nedotrd test.trd -s 24576 -ac main.bin
..\..\..\us\emul.exe test.trd
