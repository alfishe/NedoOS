"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put zxartrad.com /bin/zxartrad.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put player.ovl /bin/Radio/player.ovl
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put radio.bat /bin/radio.bat
copy /Y player.ovl ..\..\..\release\bin\radio\player.ovl
copy /Y radio.bat ..\..\..\release\bin\radio.bat
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
del zxartrad.com