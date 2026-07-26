"../../../../tools/mingw/make.exe" -f Makefile %1
"../../../../tools/dmimg.exe" ../../../../us/sd_nedo.vhd put tdesk.com /bin/kapps/tdesk.com
"../../../../tools/dmimg.exe" ../../../../us/sd_nedo.vhd put forms\welcome.frm /bin/kapps/welcome.frm
"../../../../tools/dmimg.exe" ../../../../us/sd_nedo.vhd put forms\dialog.frm /bin/kapps/dialog.frm
rd /Q /S obj
rem del tdesk.com
if "%makeall%"=="" ..\..\..\..\us\emul.exe
