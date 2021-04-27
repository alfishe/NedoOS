if "%settedpath%"=="" call ../../_sdk/setpath.bat

@echo off

set installdir=nedogame
set LOCALDIR=ufo2
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war
set XLPZ=" "
set XLPZFLAGS=" "

rem #
rem # Flicks: save locally
rem #
rem copy /y intro\flick.lpz\*.* %LOCALDIR%\ > nul

rem #
rem # Modules: convert images to assembler sources
rem #
rem %NEDORES% images/W1LAND.bmp images/W1LAND.dat W1LAND.ast

rem #
rem # Modules: compile
rem #
rem %SJASMPLUS% %SJASMPLUSFLAGS% W1LAND.ast --raw=%LOCALDIR%/W1LAND.bin

rem #
rem # Executables
rem #
mhmt -mlz ZX_DISC\xm1.dat ZX_DISC\xm1.mlz > nul
mhmt -mlz XMAP\XL0.LND ZX_DISC\XL0.mlz > nul
mhmt -mlz XMAP\XL1.LND ZX_DISC\XL1.mlz > nul

%SJASMPLUS% %SJASMPLUSFLAGS% xcom.asm
mhmt -mlz blk1.bin > nul
mhmt -mlz blk2.bin > nul
mhmt -mlz blk3.bin > nul
mhmt -mlz blk4.bin > nul
%SJASMPLUS% %SJASMPLUSFLAGS% xcom2.asm

mhmt -mlz ZX_DISC\xm2.dat ufo2\xm2.dat > nul
mhmt -mlz ZX_DISC\xm3.dat ufo2\xm3.dat > nul
mhmt -mlz ZX_DISC\xm4.dat ufo2\xm4.dat > nul
mhmt -mlz ZX_DISC\xm5.dat ufo2\xm5.dat > nul
mhmt -mlz ZX_DISC\xm6.dat ufo2\xm6.dat > nul
mhmt -mlz ZX_DISC\xm7.dat ufo2\xm7.dat > nul
mhmt -mlz ZX_DISC\xm8.dat ufo2\xm8.dat > nul
mhmt -mlz ZX_DISC\xm9.dat ufo2\xm9.dat > nul
mhmt -mlz ZX_DISC\xm10.dat ufo2\xm10.dat > nul
mhmt -mlz ZX_DISC\xm11.dat ufo2\xm11.dat > nul
mhmt -mlz ZX_DISC\xm12.dat ufo2\xm12.dat > nul
mhmt -mlz ZX_DISC\xm13.dat ufo2\xm13.dat > nul
mhmt -mlz ZX_DISC\xm14.dat ufo2\xm14.dat > nul
mhmt -mlz ZX_DISC\xm15.dat ufo2\xm15.dat > nul
mhmt -mlz ZX_DISC\xm16.dat ufo2\xm16.dat > nul
mhmt -mlz ZX_DISC\xm17.dat ufo2\xm17.dat > nul
mhmt -mlz ZX_DISC\xm18.dat ufo2\xm18.dat > nul
mhmt -mlz ZX_DISC\xm19.dat ufo2\xm19.dat > nul
mhmt -mlz ZX_DISC\xm20.dat ufo2\xm20.dat > nul

mhmt -mlz XMAP\XL2.LND ufo2\XL2.LND > nul
mhmt -mlz XMAP\XL3.LND ufo2\XL3.LND > nul
mhmt -mlz XMAP\XL4.LND ufo2\XL4.LND > nul
mhmt -mlz XMAP\XL5A.LND ufo2\XL5A.LND > nul
mhmt -mlz XMAP\XL5B.LND ufo2\XL5B.LND > nul
mhmt -mlz XMAP\XL5C.LND ufo2\XL5C.LND > nul
mhmt -mlz XMAP\XL5D.LND ufo2\XL5D.LND > nul
mhmt -mlz XMAP\XL6A.LND ufo2\XL6A.LND > nul
mhmt -mlz XMAP\XL6B.LND ufo2\XL6B.LND > nul
mhmt -mlz XMAP\XL6C.LND ufo2\XL6C.LND > nul
mhmt -mlz XMAP\XL6D.LND ufo2\XL6D.LND > nul
mhmt -mlz XMAP\XL7.LND ufo2\XL7.LND > nul
mhmt -mlz XMAP\XL8A.LND ufo2\XL8A.LND > nul
mhmt -mlz XMAP\XL8B.LND ufo2\XL8B.LND > nul
mhmt -mlz XMAP\XL8C.LND ufo2\XL8C.LND > nul
mhmt -mlz XMAP\XL8D.LND ufo2\XL8D.LND > nul
mhmt -mlz XMAP\XL9.LND ufo2\XL9.LND > nul
mhmt -mlz XMAP\XL10A.LND ufo2\XL10A.LND > nul
mhmt -mlz XMAP\XL10B.LND ufo2\XL10B.LND > nul
mhmt -mlz XMAP\XL10C.LND ufo2\XL10C.LND > nul
mhmt -mlz XMAP\XL10D.LND ufo2\XL10D.LND > nul
mhmt -mlz XMAP\XL11.LND ufo2\XL11.LND > nul
mhmt -mlz XMAP\XL12.LND ufo2\XL12.LND > nul
mhmt -mlz XMAP\XL13.LND ufo2\XL13.LND > nul
mhmt -mlz XMAP\XL14.LND ufo2\XL14.LND > nul
mhmt -mlz XMAP\XL15.LND ufo2\XL15.LND > nul
mhmt -mlz XMAP\XL19.LND ufo2\XL19.LND > nul
mhmt -mlz XMAP\XL17.LND ufo2\XL17.LND > nul
mhmt -mlz XMAP\XL18.LND ufo2\XL18.LND > nul
mhmt -mlz XMAP\XL16.LND ufo2\XL16.LND > nul
mhmt -mlz XMAP\XL20.LND ufo2\XL20.LND > nul

rem copy ZX_DISC\xm*.dat ufo2
rem copy XMAP\xl*.lnd ufo2

SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
rem pause
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 if "%makeall%"=="" ..\us\emul.exe
)