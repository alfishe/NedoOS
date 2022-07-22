@echo off
path=..\..\..\us\;..\..\..\tools\
sjasmplus main.asm
rem sjasmplus depkmain.asm
pause
del test.tap
rem mhmt -mlz code.c
del code.bin
rem copy /b depkcode.c + code.c.mlz code.bin
copy /b code.c code.bin
copy /b hicode.c hicode.bin
copy /b hicode2.c hicode2.bin
bas2tap -a10 loader.txt test.tap
rem bin2tap -b -a 24576 -r 24576 -o test.tap code.bin
bin2tap -append -a 49152 -o test.tap hicode.bin
bin2tap -append -a 49152 -o test.tap hicode2.bin
bin2tap -append -a 24576 -o test.tap code.bin
rem del code.bin
rem del code.c.mlz
rem del depkcode.c
rem "c:\Program Files\Fuse\fuse.exe" -m 128 test.tap
"c:\Program Files\Fuse\fuse.exe" -m 128 test.tap
"c:\Program Files (x86)\Fuse\fuse.exe" -m 128 test.tap
