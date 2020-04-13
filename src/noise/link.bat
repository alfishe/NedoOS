rem ходом коня (чтобы всегда чередовалась чётность сетки 50%):
rem e 1 8 5
rem b 4 f 2
rem 0 d 6 9
rem 7 a 3 c

rem порядок получился такой:
rem 20 01 13 32
rem 11 03 22 30
rem 02 23 31 10
rem 33 21 00 12

copy /b 0forest20.bmpx + 16b + 1forest20.bmpx + 16b forest.dat
copy /b forest.dat + 0forest01.bmpx + 16b + 1forest01.bmpx + 16b forest.dat
copy /b forest.dat + 0forest13.bmpx + 16b + 1forest13.bmpx + 16b forest.dat
copy /b forest.dat + 0forest32.bmpx + 16b + 1forest32.bmpx + 16b forest.dat

copy /b forest.dat + 0forest11.bmpx + 16b + 1forest11.bmpx + 16b forest.dat
copy /b forest.dat + 0forest03.bmpx + 16b + 1forest03.bmpx + 16b forest.dat
copy /b forest.dat + 0forest22.bmpx + 16b + 1forest22.bmpx + 16b forest.dat
copy /b forest.dat + 0forest30.bmpx + 16b + 1forest30.bmpx + 16b forest.dat

copy /b forest.dat + 0forest02.bmpx + 16b + 1forest02.bmpx + 16b forest.dat
copy /b forest.dat + 0forest23.bmpx + 16b + 1forest23.bmpx + 16b forest.dat
copy /b forest.dat + 0forest31.bmpx + 16b + 1forest31.bmpx + 16b forest.dat
copy /b forest.dat + 0forest10.bmpx + 16b + 1forest10.bmpx + 16b forest.dat

copy /b forest.dat + 0forest33.bmpx + 16b + 1forest33.bmpx + 16b forest.dat
copy /b forest.dat + 0forest21.bmpx + 16b + 1forest21.bmpx + 16b forest.dat
copy /b forest.dat + 0forest00.bmpx + 16b + 1forest00.bmpx + 16b forest.dat
copy /b forest.dat + 0forest12.bmpx + 16b + 1forest12.bmpx + 16b forest.dat

copy forest.dat noise
del forest.dat
