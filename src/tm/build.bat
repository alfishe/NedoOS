@ECHO OFF
"../../tools\mingw\make.exe"
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put tm.com /bin/tm.com
copy /Y tm.com ..\..\release\bin\tm.com

rd /Q /S obj
if "%makeall%"=="" ..\..\us\emul.exe