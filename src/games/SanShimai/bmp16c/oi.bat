FOR %%j IN (*.bmp) DO copy oi.bmp %%~nj.bmz
del *.bmp
ren *.bmz *.bmp
