@ECHO OFF
IF NOT EXIST ..\..\..\iar\bin\az80.exe (
	ECHO IAR not found. Skipping build "yad"
	EXIT /b
)
if not exist list mkdir list

..\..\..\iar\bin\az80 -S -uu -Olist/ main.asm
..\..\..\iar\bin\az80 -S -uu -Olist/ yadplay.asm
..\..\..\iar\bin\xlink list/main.r01 list/yadplay.r01 -FRAW-BINARY -S -o yad.com -f Lnk.xcl
