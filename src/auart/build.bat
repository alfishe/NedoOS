@ECHO OFF
cls
"../../tools\mingw\make.exe"
"../../tools/dmimg.exe" ../../us/sd_nedo.vhd put auart.com /bin/auart.com
copy /Y auart.com ..\..\release\bin\auart.com
rd /Q /S obj
rem if "%makeall%"=="" ..\..\us\emul.exe