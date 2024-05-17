"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put getpic.com /bin/getpic.com
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put espcom.ini /bin/browser/espcom.ini
copy /Y espcom.ini ..\..\..\release\bin\browser\espcom.ini
copy /Y gpic.bat ..\..\..\release\bin\gpic.bat
if "%makeall%"=="" ..\..\..\us\emul.exe
del getpic.com
rd /Q /S obj