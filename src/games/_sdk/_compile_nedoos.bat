rem скрипт сборки проекта

if not defined output goto end
if %output%=="" goto end
if %title%=="" goto end

set error=1

PATH=..\_sdk\tools\sdcc\bin;..\_sdk;%PATH%
set temp=_temp_

rem создаЄм временную директорию дл€ компил€ции

if not exist %temp% mkdir %temp%

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
sjasmplus --nologo --msg=war ..\_sdk\lib_sndpage.asm
copy sound.bin ..\_sdk\ > nul
del sound.bin > nul

sjasmplus.exe --nologo --msg=war --exp=_temp_/nedoload.exp nedoload.asm
java -jar ../_sdk/exp2hConverter.jar _temp_/nedoload.exp > nul

makeresh "%temp%\image.lst" "%temp%\palette.lst" "%temp%\music.lst" "%temp%\sample.lst" "%temp%\sprite.lst" "%soundfx%"

rem компилируем исходник на C

sdcc -mz80 -I. -c ..\_sdk\evo.c
rem copy evo.rel ..\_sdk\
rem sdcc -mz80 --fno-omit-frame-pointer --xstack --code-loc 0x4000 --data-loc 0 --no-std-crt0 -I..\_sdk ..\_sdk\crt0.rel ..\_sdk\evo.rel --opt-code-size main.c -o %temp%\out.ihx
sdcc -mz80 --code-loc 0x4000 --data-loc 0 --no-std-crt0 -I..\_sdk ..\_sdk\crt0.rel evo.rel --opt-code-size --nogcse main.c -o %temp%\out.ihx
del evo.rel

if ERRORLEVEL 1 goto clean

rem вызываем компил€тор ресурсов
rem он создаЄт набор бинарных файлов по одному на банк пам€ти
rem плюс скрипты дл€ сжати€ файлов megalz и сборки образа диска

rem evoresc "%temp%\out.ihx" "..\_sdk\startup.bin" "%soundfx%" "%temp%\music.lst" "%temp%\palette.lst" "%temp%\image.lst" "%temp%\sample.lst" "%temp%\sprite.lst"
rem echo tools\sjasmplus\sjasmplus.exe "%temp%\..\nedoload.asm" 
sjasmplus.exe --nologo --msg=war --exp=_temp_/nedoload.exp nedoload.asm

rem echo -CALL NEDORESC------------------------------
rem evoresc_new.exe BINARY_FILE "%temp%\out.ihx" STARTUP_FILE "..\_sdk\startup.bin" SFX_LIST "%soundfx%" MUSIC_LIST "%temp%\music.lst" PALETTE_LIST "%temp%\palette.lst" IMAGE_LIST "%temp%\image.lst" SAMPLE_LIST "%temp%\sample.lst" SPRITE_LIST "%temp%\sprite.lst" ALT_PAGE_NUMERING "1"
evoresc_new.exe BINARY_FILE "%temp%\out.ihx" STARTUP_FILE "..\_sdk\startup.bin" SFX_LIST "%soundfx%" MUSIC_LIST "%temp%\music.lst" PALETTE_LIST "%temp%\palette.lst" IMAGE_LIST "%temp%\image.lst" SAMPLE_LIST "%temp%\sample.lst" SPRITE_LIST "%temp%\sprite.lst" ALT_PAGE_NUMERING "0"  SOUND_BIN_FILE "../_sdk/sound.bin" SND_PAGE 0 SPRTBL_PAGE 1 PAL_PAGE 2  SPRBUF_PAGE 3 GFX_PAGE 10 CC_PAGE0 100 CC_PAGE1 101 CC_PAGE2 102 CC_PAGE3 103
if ERRORLEVEL 1 goto clean

rem echo %PATH%
rem echo %CD%
perl ../_sdk/getMainAddr.pl .\_temp_\out.map _temp_\addr.bin

rem переходим во временную директорию

rem echo -11----------------------------
rem echo %CD%
cd %temp%

rem пакуем файлы

copy ..\..\_sdk\getsize.bat >nul
rem kills PATH!!!
rem call compress.bat

rem собираем загрузчик

rem echo -12----------------------------
rem copy ..\..\_sdk\loader.asm loader.asm >nul
rem echo -13----------------------------
rem copy ..\..\_sdk\unmegalz.asm unmegalz.asm >nul
rem echo -14----------------------------
rem copy ..\..\_sdk\target.asm target.asm >nul
rem echo -15----------------------------
rem ..\..\_sdk\tools\sjasmplus\sjasmplus.exe loader.asm >nul

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

set palette.0=
set palette.1=
set palette.2=
set palette.3=
set palette.4=
set palette.5=
set palette.6=
set palette.7=
set palette.8=
set palette.9=
set palette.10=
set palette.11=
set palette.12=
set palette.13=
set palette.14=
set palette.15=
set palette.16=
set palette.17=
set palette.18=
set palette.19=
set image.0=
set image.1=
set image.2=
set image.3=
set image.4=
set image.5=
set image.6=
set image.7=
set image.8=
set image.9=
set image.10=
set image.11=
set image.12=
set image.13=
set image.14=
set image.15=
set image.16=
set image.17=
set image.18=
set image.19=
set image.20=
set image.21=
set image.22=
set image.23=
set image.24=
set image.25=
set image.26=
set image.27=
set image.28=
set image.29=
set image.30=
set sprite.0=
set sprite.1=
set sprite.2=
set sprite.3=
set sprite.4=
set sprite.5=
set sprite.6=
set sprite.7=
set sprite.8=
set sprite.9=
set sprite.10=
set sprite.11=
set sprite.12=
set sprite.13=
set sprite.14=
set sprite.15=
set sprite.16=
set sprite.17=
set sprite.18=
set sprite.19=
set soundfx=
set music.0=
set music.1=
set music.2=
set music.3=
set music.4=
set music.5=
set music.6=
set music.7=
set music.8=
set music.9=
set music.10=
set music.11=
set music.12=
set music.13=
set music.14=
set music.15=
set music.16=
set music.17=
set music.18=
set music.19=
set sample.0=
set sample.1=
set sample.2=
set sample.3=
set sample.4=
set sample.5=
set sample.6=
set sample.7=
set sample.8=
set sample.9=
set sample.10=
set sample.11=
set sample.12=
set sample.13=
set sample.14=
set sample.15=
set sample.16=
set sample.17=
set sample.18=
set sample.19=


if %error%==1 pause