set wascurrentdir=%currentdir%
if "%settedpath%"=="" call "..\..\..\_sdk\setpath.bat"

for %%j in (*asm) do (
        sjasmplus .\%%~nj.asm --raw=..\BOD\ovl\rus\%%~nj.ovl
)
