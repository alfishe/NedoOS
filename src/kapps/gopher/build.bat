"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put gopher.com /bin/gopher.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put nedogoph.gph /bin/browser/nedogoph.gph
copy /Y nedogoph.gph ..\..\..\release\bin\browser\nedogoph.gph
rd /Q /S obj
del gopher.com
if "%makeall%"=="" ..\..\..\us\emul.exe


