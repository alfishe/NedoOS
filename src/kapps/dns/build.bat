"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put dns.com /bin/dns.com
rd /Q /S obj
del dns.com
if "%makeall%"=="" ..\..\..\us\emul.exe


