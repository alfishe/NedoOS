set wascurrentdir=%currentdir%
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"

sjasmplus --nologo --msg=war  s98_plr.asm

if "%wascurrentdir%"=="" (pause)

copy /Y s98_plr.bin "../../../release/nedogame/tenkosei/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put s98_plr.bin /nedogame/tenkosei/s98_plr.bin
