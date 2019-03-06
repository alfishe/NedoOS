path=..\sjasm\;..\us\;..\tools\
sjasmplus main.asm
del code.c
mhmt -mlz syscode.c
copy /b initcode.c + syscode.c.mlz code.c
del initcode.c
del syscode.c
del syscode.c.mlz
