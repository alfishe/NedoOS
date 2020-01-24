if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist nedoload mkdir nedoload
sjasmplus --nologo --msg=war --msg=war nedoload.asm
java -jar exp2hConverter.jar nedoload.exp
copy functions.h nedoload.h
java -jar exp2hConverter.jar lib_tiles.exp
copy functions.h lib_tiles.h
if "%currentdir%"=="" (pause)
