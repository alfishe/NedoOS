"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put getpic.com /bin/getpic.com
@rem if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put espcom.ini /ini/espcom.ini
@rem copy /Y espcom.ini ..\..\..\release\ini\espcom.ini
@rem copy /Y gpic.bat ..\..\..\release\bin\gpic.bat
if "%makeall%"=="" ..\..\..\us\emul.exe
del getpic.com
rd /Q /S obj