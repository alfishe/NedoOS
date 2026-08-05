@echo off
REM Build standalone mbgen.exe (GUI). Separate from multibank app build.
setlocal
set SRC=%~dp0src
set OUT=%~dp0mbgen.exe
set CSC64=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe
set CSC32=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe
set CSC=%CSC64%
if not exist "%CSC%" set CSC=%CSC32%
if not exist "%CSC%" (
	echo mbgen: csc.exe not found. Need .NET Framework 4.x Developer Pack / targeting pack.
	exit /b 1
)

"%CSC%" /nologo /target:exe /optimize+ /platform:anycpu ^
	/reference:System.dll ^
	/reference:System.Drawing.dll ^
	/reference:System.Windows.Forms.dll ^
	/out:"%OUT%" ^
	"%SRC%\Program.cs" "%SRC%\MainForm.cs" "%SRC%\Engine.cs"
if errorlevel 1 exit /b 1
echo Built %OUT%
