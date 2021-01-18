rem скрипт сборки проекта

if not defined output goto end
if %output%=="" goto end
if %title%=="" goto end

set error=1

PATH=..\_sdk\tools\sdcc\bin;..\_sdk;%PATH%
set temp=_temp_

rem создаЄм временную директорию дл€ компил€ции

mkdir %temp%

rem создаЄм список палитр

set palette._dummy_=:

echo rem palette>%temp%\palette.lst
FOR /F "tokens=2* delims=.=" %%A IN ('SET palette') DO ECHO %%B>>%temp%\palette.lst

rem создаЄм список изображений

set image._dummy_=:

echo rem image>%temp%\image.lst
FOR /F "tokens=2* delims=.=" %%A IN ('SET image') DO ECHO %%B>>%temp%\image.lst

rem создаЄм список спрайтов

set sprite._dummy_=:

echo rem sprite>%temp%\sprite.lst
FOR /F "tokens=2* delims=.=" %%A IN ('SET sprite') DO ECHO %%B>>%temp%\sprite.lst

rem создаЄм список музыки

set music._dummy_=:

echo rem music>%temp%\music.lst
for /F "tokens=2* delims=.=" %%a in ('set music') do echo %%b>>%temp%\music.lst

rem создаЄм список сэмплов

set sample._dummy_=:

echo rem sample>%temp%\sample.lst
FOR /F "tokens=2* delims=.=" %%A IN ('SET sample') DO ECHO %%B>>%temp%\sample.lst

rem создаЄм resources.h с идентификаторами ресурсов

makeresh "%temp%\image.lst" "%temp%\palette.lst" "%temp%\music.lst" "%temp%\sample.lst" "%temp%\sprite.lst" "%soundfx%"

rem компилируем исходник на C

sdcc -mz80 --xstack --code-loc 0x4000 --data-loc 0 --no-std-crt0 -I..\_sdk ..\_sdk\crt0.rel ..\_sdk\evo.rel --opt-code-size main.c -o %temp%\out.ihx

if ERRORLEVEL 1 goto clean

rem вызываем компил€тор ресурсов
rem он создаЄт набор бинарных файлов по одному на банк пам€ти
rem плюс скрипты дл€ сжати€ файлов megalz и сборки образа диска

rem evoresc "%temp%\out.ihx" "..\_sdk\startup.bin" "%soundfx%" "%temp%\music.lst" "%temp%\palette.lst" "%temp%\image.lst" "%temp%\sample.lst" "%temp%\sprite.lst"
echo tools\sjasmplus\sjasmplus.exe "%temp%\..\nedoload.asm" 
..\_sdk\tools\sjasmplus\sjasmplus.exe nedoload.asm

rem evoresc_new.exe BINARY_FILE "%temp%\out.ihx" STARTUP_FILE "..\_sdk\startup.bin" SFX_LIST "%soundfx%" MUSIC_LIST "%temp%\music.lst" PALETTE_LIST "%temp%\palette.lst" IMAGE_LIST "%temp%\image.lst" SAMPLE_LIST "%temp%\sample.lst" SPRITE_LIST "%temp%\sprite.lst" ALT_PAGE_NUMERING "1"
evoresc_new.exe BINARY_FILE "%temp%\out.ihx" STARTUP_FILE "..\_sdk\startup.bin" SFX_LIST "%soundfx%" MUSIC_LIST "%temp%\music.lst" PALETTE_LIST "%temp%\palette.lst" IMAGE_LIST "%temp%\image.lst" SAMPLE_LIST "%temp%\sample.lst" SPRITE_LIST "%temp%\sprite.lst" ALT_PAGE_NUMERING "1"  SOUND_BIN_FILE "../_sdk/sound.bin"
if ERRORLEVEL 1 goto clean

rem переходим во временную директорию

rem echo -11----------------------------
rem echo %CD%
cd %temp%

rem пакуем файлы

copy ..\..\_sdk\getsize.bat >nul
rem kills PATH!!!
rem call compress.bat

rem собираем загрузчик

copy ..\..\_sdk\loader.asm loader.asm >nul
copy ..\..\_sdk\unmegalz.asm unmegalz.asm >nul
copy ..\..\_sdk\target.asm target.asm >nul
..\..\_sdk\tools\sjasmplus\sjasmplus.exe loader.asm >nul

rem собираем образ и делаем его моноблочным

rem call createscl.bat

cd ..
rem echo -12----------------------------
rem echo %CD%

rem copy %temp%\disk.scl %output% >nul
rem ..\..\_sdk\monoscl %output%

set error=0

rem удал€ем временную директорию

:clean

rem rd /s /q %temp%

:end

if %error%==1 pause