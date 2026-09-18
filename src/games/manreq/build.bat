if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame

textprep\fasm   textprep\r_mdl1.asm jb2manreq\r_mdl1.bin
textprep\fasm   textprep\r_mdl2.asm jb2manreq\r_mdl2.bin
textprep\fasm   textprep\r_mdl3.asm jb2manreq\r_mdl3.bin
textprep\fasm   textprep\r_mdl4.asm jb2manreq\r_mdl4.bin
textprep\fasm   textprep\r_mdl5.asm jb2manreq\r_mdl5.bin
textprep\fasm   textprep\r_mdl6.asm jb2manreq\r_mdl6.bin
textprep\fasm   textprep\j_mdl1.asm jb2manreq\j_mdl1.bin
textprep\fasm   textprep\j_mdl2.asm jb2manreq\j_mdl2.bin
textprep\fasm   textprep\j_mdl3.asm jb2manreq\j_mdl3.bin
textprep\fasm   textprep\j_mdl4.asm jb2manreq\j_mdl4.bin
textprep\fasm   textprep\j_mdl5.asm jb2manreq\j_mdl5.bin

sjasmplus --nologo --msg=war main.asm


SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y /E "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
rem pause

 if "%makeall%"=="" ..\us\emul.exe
)