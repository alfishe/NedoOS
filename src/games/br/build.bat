if "%settedpath%"=="" call ../../_sdk/setpath.bat

@echo off

set installdir=nedogame
set LOCALDIR=br
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war
set XLPZ=" "
set XLPZFLAGS=" "

rem #
rem # Flicks: save locally
rem #
copy /y intro\flick.lpz\*.* %LOCALDIR%\ > nul

rem #
rem # Modules: convert images to assembler sources
rem #
%NEDORES% images/W1LAND.bmp images/W1LAND.dat W1LAND.ast
%NEDORES% images/W2LAND.bmp images/W2LAND.dat W2LAND.ast
%NEDORES% images/W3LAND.bmp images/W3LAND.dat W3LAND.ast
%NEDORES% images/W4LAND.bmp images/W4LAND.dat W4LAND.ast
%NEDORES% images/WBAR.bmp images/WBAR.dat WBAR.ast
%NEDORES% images/WHUMBUTT.bmp images/WHUMBUTT.dat WHUMBUTT.ast
%NEDORES% images/WORCBUTT.bmp images/WORCBUTT.dat WORCBUTT.ast
%NEDORES% images/WHUM1.bmp images/WHUM1.dat WHUM1.ast
%NEDORES% images/WHUM1.bmp images/WHUM1b.dat WHUM1b.ast
%NEDORES% images/WHUM1.bmp images/WHUM1c.dat WHUM1c.ast
%NEDORES% images/WHUM2.bmp images/WHUMCAT.dat WHUMCAT.ast
%NEDORES% images/WHUM2.bmp images/WHUMHOR.dat WHUMHOR.ast
%NEDORES% images/WORC1.bmp images/WORC1.dat WORC1.ast
%NEDORES% images/WORC1.bmp images/WORC1b.dat WORC1b.ast
%NEDORES% images/WORC1.bmp images/WORC1c.dat WORC1c.ast
%NEDORES% images/WORC2.bmp images/WORCCAT.dat WORCCAT.ast
%NEDORES% images/WORC2.bmp images/WORCHOR.dat WORCHOR.ast
%NEDORES% images/WCREAT1.bmp images/WCREAT1.dat WCREAT1.ast
%NEDORES% images/WCREAT1.bmp images/WCREAT1b.dat WCREAT1b.ast
%NEDORES% images/WCREAT1.bmp images/WCREAT1c.dat WCREAT1c.ast
%NEDORES% images/WCREAT2.bmp images/WCREAT2.dat WCREAT2.ast
%NEDORES% images/WCREAT2.bmp images/WCREAT2b.dat WCREAT2b.ast
%NEDORES% images/WCREAT2.bmp images/WCREAT2c.dat WCREAT2c.ast
%NEDORES% images/WMISC.bmp images/WBODY.dat WBODY.ast
%NEDORES% images/WMISC.bmp images/WBULLET.dat WBULLET.ast
%NEDORES% images/demobar.bmp images/demobar.dat demobar.ast

rem #
rem # Modules: compile
rem #
%SJASMPLUS% %SJASMPLUSFLAGS% W1LAND.ast --raw=%LOCALDIR%/W1LAND.bin
%SJASMPLUS% %SJASMPLUSFLAGS% W2LAND.ast --raw=%LOCALDIR%/W2LAND.bin
%SJASMPLUS% %SJASMPLUSFLAGS% W3LAND.ast --raw=%LOCALDIR%/W3LAND.bin
%SJASMPLUS% %SJASMPLUSFLAGS% W4LAND.ast --raw=%LOCALDIR%/W4LAND.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WBAR.ast --raw=%LOCALDIR%/WBAR.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUMBUTT.ast --raw=%LOCALDIR%/W0BUT.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORCBUTT.ast --raw=%LOCALDIR%/W1BUT.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUM1.asm --raw=%LOCALDIR%/WHUM1.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUM1b.asm --raw=%LOCALDIR%/WHUM1b.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUM1c.asm --raw=%LOCALDIR%/WHUM1c.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUMCAT.asm --raw=%LOCALDIR%/WHUMCAT.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WHUMHOR.asm --raw=%LOCALDIR%/WHUMHOR.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORC1.asm --raw=%LOCALDIR%/WORC1.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORC1b.asm --raw=%LOCALDIR%/WORC1b.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORC1c.asm --raw=%LOCALDIR%/WORC1c.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORCCAT.asm --raw=%LOCALDIR%/WORCCAT.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WORCHOR.asm --raw=%LOCALDIR%/WORCHOR.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT1.asm --raw=%LOCALDIR%/WCREAT1.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT1b.asm --raw=%LOCALDIR%/WCREAT1b.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT1c.asm --raw=%LOCALDIR%/WCREAT1c.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT2.asm --raw=%LOCALDIR%/WCREAT2.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT2b.asm --raw=%LOCALDIR%/WCREAT2b.bin
%SJASMPLUS% %SJASMPLUSFLAGS% WCREAT2c.asm --raw=%LOCALDIR%/WCREAT2c.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% WBODY.asm --raw=%LOCALDIR%/
%SJASMPLUS% %SJASMPLUSFLAGS% WBULLET.asm --raw=%LOCALDIR%/WBULLET.bin

rem #
rem # Levels: compile
rem #
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~101.a80 --raw=levels/w~101.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~102.a80 --raw=levels/w~102.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~103.a80 --raw=levels/w~103.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~104.a80 --raw=levels/w~104.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~105.a80 --raw=levels/w~105.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~106.a80 --raw=levels/w~106.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~107.a80 --raw=levels/w~107.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~108.a80 --raw=levels/w~108.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~109.a80 --raw=levels/w~109.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~110.a80 --raw=levels/w~110.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~111.a80 --raw=levels/w~111.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~112.a80 --raw=levels/w~112.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~113.a80 --raw=levels/w~113.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~114.a80 --raw=levels/w~114.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~115.a80 --raw=levels/w~115.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~116.a80 --raw=levels/w~116.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~117end.a80 --raw=levels/w~117end.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~201.a80 --raw=levels/w~201.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~202.a80 --raw=levels/w~202.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~203.a80 --raw=levels/w~203.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~204.a80 --raw=levels/w~204.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~205.a80 --raw=levels/w~205.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~206.a80 --raw=levels/w~206.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~207.a80 --raw=levels/w~207.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~208.a80 --raw=levels/w~208.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~209.a80 --raw=levels/w~209.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~210.a80 --raw=levels/w~210.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~211.a80 --raw=levels/w~211.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~212.a80 --raw=levels/w~212.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~213.a80 --raw=levels/w~213.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~214.a80 --raw=levels/w~214.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~215.a80 --raw=levels/w~215.dat
rem %SJASMPLUS% %SJASMPLUSFLAGS% levels/w~216.a80 --raw=levels/w~216.dat
%SJASMPLUS% %SJASMPLUSFLAGS% levels/w~217end.a80 --raw=levels/w~217end.dat

rem #
rem # Levels: pack
rem #
rem %XLPZ% %XLPZFLAGS% levels\w~101.dat levels\w~101.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~102.dat levels\w~102.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~103.dat levels\w~103.lpz
copy /y levels\w~104.dat levels\w~104.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~105.dat levels\w~105.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~106.dat levels\w~106.lpz
copy /y levels\w~107.dat levels\w~107.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~108.dat levels\w~108.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~109.dat levels\w~109.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~110.dat levels\w~110.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~111.dat levels\w~111.lpz
copy /y levels\w~112.dat levels\w~112.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~113.dat levels\w~113.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~114.dat levels\w~114.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~115.dat levels\w~115.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~116.dat levels\w~116.lpz
copy /y levels\w~117end.dat levels\w~117end.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~201.dat levels\w~201.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~202.dat levels\w~202.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~203.dat levels\w~203.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~204.dat levels\w~204.lpz
copy /y levels\w~205.dat levels\w~205.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~206.dat levels\w~206.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~207.dat levels\w~207.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~208.dat levels\w~208.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~209.dat levels\w~209.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~210.dat levels\w~210.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~211.dat levels\w~211.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~212.dat levels\w~212.lpz
copy /y levels\w~213.dat levels\w~213.lpz > nul
rem %XLPZ% %XLPZFLAGS% levels\w~214.dat levels\w~214.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~215.dat levels\w~215.lpz
rem %XLPZ% %XLPZFLAGS% levels\w~216.dat levels\w~216.lpz
copy /y levels\w~217end.dat levels\w~217end.lpz > nul

rem #
rem # Levels: save locally
rem #
copy /y levels\w~101.lpz %LOCALDIR%\br101.dat > nul
copy /y levels\w~102.lpz %LOCALDIR%\br102.dat > nul
copy /y levels\w~103.lpz %LOCALDIR%\br103.dat > nul
copy /y levels\w~104.lpz %LOCALDIR%\br104.dat > nul
copy /y levels\w~105.lpz %LOCALDIR%\br105.dat > nul
copy /y levels\w~106.lpz %LOCALDIR%\br106.dat > nul
copy /y levels\w~107.lpz %LOCALDIR%\br107.dat > nul
copy /y levels\w~108.lpz %LOCALDIR%\br108.dat > nul
copy /y levels\w~109.lpz %LOCALDIR%\br109.dat > nul
copy /y levels\w~110.lpz %LOCALDIR%\br110.dat > nul
copy /y levels\w~111.lpz %LOCALDIR%\br111.dat > nul
copy /y levels\w~112.lpz %LOCALDIR%\br112.dat > nul
copy /y levels\w~113.lpz %LOCALDIR%\br113.dat > nul
copy /y levels\w~114.lpz %LOCALDIR%\br114.dat > nul
copy /y levels\w~115.lpz %LOCALDIR%\br115.dat > nul
copy /y levels\w~116.lpz %LOCALDIR%\br116.dat > nul
copy /y levels\w~117end.lpz %LOCALDIR%\br117.dat > nul
copy /y levels\w~201.lpz %LOCALDIR%\br201.dat > nul
copy /y levels\w~202.lpz %LOCALDIR%\br202.dat > nul
copy /y levels\w~203.lpz %LOCALDIR%\br203.dat > nul
copy /y levels\w~204.lpz %LOCALDIR%\br204.dat > nul
copy /y levels\w~205.lpz %LOCALDIR%\br205.dat > nul
copy /y levels\w~206.lpz %LOCALDIR%\br206.dat > nul
copy /y levels\w~207.lpz %LOCALDIR%\br207.dat > nul
copy /y levels\w~208.lpz %LOCALDIR%\br208.dat > nul
copy /y levels\w~209.lpz %LOCALDIR%\br209.dat > nul
copy /y levels\w~210.lpz %LOCALDIR%\br210.dat > nul
copy /y levels\w~211.lpz %LOCALDIR%\br211.dat > nul
copy /y levels\w~212.lpz %LOCALDIR%\br212.dat > nul
copy /y levels\w~213.lpz %LOCALDIR%\br213.dat > nul
copy /y levels\w~214.lpz %LOCALDIR%\br214.dat > nul
copy /y levels\w~215.lpz %LOCALDIR%\br215.dat > nul
copy /y levels\w~216.lpz %LOCALDIR%\br216.dat > nul
copy /y levels\w~217end.lpz %LOCALDIR%\br217.dat > nul

rem #
rem # Executables
rem #
%SJASMPLUS% %SJASMPLUSFLAGS% main.asm
%SJASMPLUS% %SJASMPLUSFLAGS% WSTART1.asm
%SJASMPLUS% %SJASMPLUSFLAGS% brfinal.asm --raw=%LOCALDIR%/brfinal.dat


SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
 pause
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 if "%makeall%"=="" ..\us\emul.exe
)