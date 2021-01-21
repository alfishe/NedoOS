@echo off

rem имя SCL файла

set output=empty.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title=" NOTHING IS LOADING"

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

set palette.0=gfx\pic1.bmp
set palette.1=gfx\pic2.bmp
set palette.2=gfx\pic3.bmp
set palette.3=gfx\pic4.bmp
set palette.4=gfx\pic5.bmp

rem список изображений, откуда брать графику

set image.0=gfx\pic1.bmp
set image.1=gfx\pic2.bmp
set image.2=gfx\pic3.bmp
set image.3=gfx\pic4.bmp
set image.4=gfx\pic5.bmp

rem спрайты

set sprite.0=balls.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=

rem музыка, нужное число треков

set music.0=

rem сэмплы

set sample.0=

call ..\_sdk\_compile_new.bat
@if %error% ==0 ..\..\..\us\emul.exe %output%
