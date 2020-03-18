if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
copy intro\flick.lpz\*.* br\
"../../_sdk/nedores.exe" images/W1LAND.bmp images/W1LAND.dat W1LAND.ast
"../../_sdk/nedores.exe" images/W2LAND.bmp images/W2LAND.dat W2LAND.ast
"../../_sdk/nedores.exe" images/W3LAND.bmp images/W3LAND.dat W3LAND.ast
"../../_sdk/nedores.exe" images/W4LAND.bmp images/W4LAND.dat W4LAND.ast
"../../_sdk/nedores.exe" images/WBAR.bmp images/WBAR.dat WBAR.ast
"../../_sdk/nedores.exe" images/WHUMBUTT.bmp images/WHUMBUTT.dat WHUMBUTT.ast
"../../_sdk/nedores.exe" images/WORCBUTT.bmp images/WORCBUTT.dat WORCBUTT.ast
"../../_sdk/nedores.exe" images/WHUM1.bmp images/WHUM1.dat WHUM1.ast
"../../_sdk/nedores.exe" images/WHUM1.bmp images/WHUM1b.dat WHUM1b.ast
"../../_sdk/nedores.exe" images/WHUM1.bmp images/WHUM1c.dat WHUM1c.ast
"../../_sdk/nedores.exe" images/WHUM2.bmp images/WHUMCAT.dat WHUMCAT.ast
"../../_sdk/nedores.exe" images/WHUM2.bmp images/WHUMHOR.dat WHUMHOR.ast
"../../_sdk/nedores.exe" images/WORC1.bmp images/WORC1.dat WORC1.ast
"../../_sdk/nedores.exe" images/WORC1.bmp images/WORC1b.dat WORC1b.ast
"../../_sdk/nedores.exe" images/WORC1.bmp images/WORC1c.dat WORC1c.ast
"../../_sdk/nedores.exe" images/WORC2.bmp images/WORCCAT.dat WORCCAT.ast
"../../_sdk/nedores.exe" images/WORC2.bmp images/WORCHOR.dat WORCHOR.ast
"../../_sdk/nedores.exe" images/WCREAT1.bmp images/WCREAT1.dat WCREAT1.ast
"../../_sdk/nedores.exe" images/WCREAT1.bmp images/WCREAT1b.dat WCREAT1b.ast
"../../_sdk/nedores.exe" images/WCREAT1.bmp images/WCREAT1c.dat WCREAT1c.ast
"../../_sdk/nedores.exe" images/WCREAT2.bmp images/WCREAT2.dat WCREAT2.ast
"../../_sdk/nedores.exe" images/WCREAT2.bmp images/WCREAT2b.dat WCREAT2b.ast
"../../_sdk/nedores.exe" images/WCREAT2.bmp images/WCREAT2c.dat WCREAT2c.ast
"../../_sdk/nedores.exe" images/WMISC.bmp images/WBODY.dat WBODY.ast
"../../_sdk/nedores.exe" images/WMISC.bmp images/WBULLET.dat WBULLET.ast
"../../_sdk/nedores.exe" images/demobar.bmp images/demobar.dat demobar.ast
sjasmplus --nologo --msg=war --msg=war W1LAND.ast --raw=br/W1LAND.bin
sjasmplus --nologo --msg=war --msg=war W2LAND.ast --raw=br/W2LAND.bin
sjasmplus --nologo --msg=war --msg=war W3LAND.ast --raw=br/W3LAND.bin
sjasmplus --nologo --msg=war --msg=war W4LAND.ast --raw=br/W4LAND.bin
sjasmplus --nologo --msg=war --msg=war WBAR.ast --raw=br/WBAR.bin
sjasmplus --nologo --msg=war --msg=war WHUMBUTT.ast --raw=br/W0BUT.bin
sjasmplus --nologo --msg=war --msg=war WORCBUTT.ast --raw=br/W1BUT.bin
sjasmplus --nologo --msg=war --msg=war WHUM1.asm
sjasmplus --nologo --msg=war --msg=war WHUM1b.asm
sjasmplus --nologo --msg=war --msg=war WHUM1c.asm
sjasmplus --nologo --msg=war --msg=war WHUMCAT.asm
sjasmplus --nologo --msg=war --msg=war WHUMHOR.asm
sjasmplus --nologo --msg=war --msg=war WORC1.asm
sjasmplus --nologo --msg=war --msg=war WORC1b.asm
sjasmplus --nologo --msg=war --msg=war WORC1c.asm
sjasmplus --nologo --msg=war --msg=war WORCCAT.asm
sjasmplus --nologo --msg=war --msg=war WORCHOR.asm
sjasmplus --nologo --msg=war --msg=war WCREAT1.asm
sjasmplus --nologo --msg=war --msg=war WCREAT1b.asm
sjasmplus --nologo --msg=war --msg=war WCREAT1c.asm
sjasmplus --nologo --msg=war --msg=war WCREAT2.asm
sjasmplus --nologo --msg=war --msg=war WCREAT2b.asm
sjasmplus --nologo --msg=war --msg=war WCREAT2c.asm
rem sjasmplus --nologo --msg=war --msg=war WBODY.asm
sjasmplus --nologo --msg=war --msg=war WBULLET.asm

sjasmplus --nologo --msg=war --msg=war levels/w~104.a80
sjasmplus --nologo --msg=war --msg=war levels/w~107.a80
sjasmplus --nologo --msg=war --msg=war levels/w~112.a80
sjasmplus --nologo --msg=war --msg=war levels/w~117end.a80
sjasmplus --nologo --msg=war --msg=war levels/w~205.a80
sjasmplus --nologo --msg=war --msg=war levels/w~213.a80
sjasmplus --nologo --msg=war --msg=war levels/w~217end.a80
sjasmplus --nologo --msg=war --msg=war brfinal.asm
sjasmplus --nologo --msg=war --msg=war main.asm
sjasmplus --nologo --msg=war --msg=war WSTART1.asm
if "%currentdir%"=="" (pause)
