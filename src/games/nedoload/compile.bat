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

set palette.0=bg.bmp

rem список изображений, откуда брать графику

set image.0=bg.bmp

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
@if %error% ==0 ..\..\us\emul.exe %output%
