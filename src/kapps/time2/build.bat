"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put time2.com /bin/time2.com
rd /Q /S obj
del time2.com


