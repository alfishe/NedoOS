for %%j in (*asm) do (
        .\sjasm\sjasmplus .\%%~nj.asm --raw=%%~nj.ovl
)
