@echo off
REM Build tools\mbovl.exe with MSVC (one-time; not needed when adding codebanks).
setlocal
set ROOT=%~dp0..\..
set SRC=%~dp0mbovl.c
set OUT=%ROOT%\mbovl.exe
set VCVARS="%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not exist %VCVARS% set VCVARS="%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not exist %VCVARS% (
	echo mbovl: vcvars64.bat not found. Install VS 2022 C++ tools, or copy a prebuilt mbovl.exe to tools\
	exit /b 1
)
call %VCVARS% >nul
cl /nologo /O2 /W3 /D_CRT_SECURE_NO_WARNINGS /Fe"%OUT%" "%SRC%" /link /nologo
if errorlevel 1 exit /b 1
del /q "%~dp0mbovl.obj" 2>nul
echo Built %OUT%
