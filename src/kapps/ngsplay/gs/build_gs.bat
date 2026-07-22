@echo off
cd /d "%~dp0"
..\..\..\..\tools\sjasmplus107.exe --nologo build_gs.a80
if errorlevel 1 exit /b 1
python bin2c.py ngsdrv.bin ngsdrv_bin.c ngsdrv_bin ngsdrv_bin_len
python bin2c.py ngsldr.bin ngsldr_bin.c ngsldr_bin ngsldr_bin_len
python bin2c.py neopg2.bin neopg2_bin.c neopg2_bin neopg2_bin_len
copy /Y ngsdrv_bin.c ..\ngsdrv_bin.c >nul
copy /Y ngsldr_bin.c ..\ngsldr_bin.c >nul
copy /Y neopg2_bin.c ..\neopg2_bin.c >nul
echo GS blobs OK
