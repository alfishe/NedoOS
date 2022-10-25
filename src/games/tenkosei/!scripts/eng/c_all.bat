for %%j in (*asm) do (
        .\sjasm\sjasmplus .\%%~nj.asm --raw=%%~nj.ovl
)
rem  2> %%~nj.txt