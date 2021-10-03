ren st12.bmp st12.bmt
FOR %%j IN (*.bmp) DO copy oi.bmp %%~nj.bmz
del *.bmp
ren *.bmz *.bmp
ren *.bmt *.bmp
