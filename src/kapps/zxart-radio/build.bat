cls
"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put zxartrad.com /bin/Radio/zxartrad.com
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put player.ovl /bin/Radio/player.ovl
if "%makeall%"=="" ..\..\..\us\emul.exe
copy /Y player.ovl ..\..\..\release\bin\radio\player.ovl
rd /Q /S obj
del zxartrad.com