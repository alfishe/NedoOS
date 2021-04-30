set PATH=C:\mingw\mingw32\bin;%PATH%
make nedoos
copy /Y moon.com ..\..\release\bin\moon.com
copy /Y data\index.gph ..\..\release\bin\browser\index.gph
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put moon.com /bin/moon.com
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put data/index.gph /bin/browser/index.gph