if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war main_rcp_robo.asm


if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
rem  "../../tools/dmimg.exe" ../../us_ns2/sd/sd_nedo.vhd put test10.mid /bin/SK_10.RCP.mid
rem pause
if "%makeall%"=="" ..\..\us\emul.exe
)