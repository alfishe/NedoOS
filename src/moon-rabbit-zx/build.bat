@echo off
del /Q moon.com
del /Q moonua.com
del /Q moonue.com


"../../tools\mingw\make.exe" nedoosevo
ren  moon.com moonue.com
"../../tools\mingw\make.exe" nedoosatm
ren  moon.com moonua.com
copy /Y moonua.com ..\..\release\bin\kapps\moonua.com
copy /Y moonue.com ..\..\release\bin\kapps\moonue.com
"../../tools\mingw\make.exe" nedoos
copy /Y moon.com ..\..\release\bin\moon.com
rem copy /Y data\index.gph ..\..\release\bin\browser\index.gph
copy /Y data\logo.scr ..\..\release\bin\browser\logo.scr

"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put moon.com /bin/moon.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put moonua.com /bin/kapps/moonua.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put moonue.com /bin/kapps/moonue.com
rem "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/index.gph /bin/browser/index.gph
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/logo.scr /bin/browser/logo.scr

del /Q *.lst
