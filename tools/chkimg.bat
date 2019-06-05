@echo off
IF EXIST ..\us\sd_nedo.vhd IF EXIST ..\us\hdd_nedo.vhd (
	GOTO COPYFILES
)

IF NOT EXIST ..\tools\images.exe (
	ECHO Error: Image not found!
	exit /b
)
..\tools\images.exe
IF NOT EXIST ..\us\sd_nedo.vhd move sd_nedo.vhd ..\us\
IF NOT EXIST ..\us\hdd_nedo.vhd move hdd_nedo.vhd ..\us\
IF EXIST sd_nedo.vhd del sd_nedo.vhd
IF EXIST hdd_nedo.vhd del hdd_nedo.vhd
IF EXIST b.bat del b.bat

:COPYFILES
..\tools\dmimg ..\us\%1_nedo.vhd mkdir bin > nul
..\tools\dmimg ..\us\%1_nedo.vhd mkdir bin/www > nul
..\tools\dmimg ..\us\%1_nedo.vhd mkdir bin/doc > nul
..\tools\dmimg ..\us\%1_nedo.vhd put nedoos.$c nedoos.$c
FOR %%i IN (..\release\bin\*.*) DO (
        ..\tools\dmimg ..\us\%1_nedo.vhd put %%i bin/%%~nxi
)
FOR %%i IN (..\release\bin\www\*.*) DO (
        ..\tools\dmimg ..\us\%1_nedo.vhd put %%i bin/www/%%~nxi
)
FOR %%i IN (..\release\doc\*.*) DO (
        ..\tools\dmimg ..\us\%1_nedo.vhd put %%i bin/doc/%%~nxi
)