@echo off
if not exist %CD% (
	echo ERROR: No spaces allowed in the path.
	pause
	exit
)
if not "%settedpath%"=="" (
	echo Environment variables are already set - skipping.
	exit /b
)
echo Setting environment variables...

rem Flags
set settedpath=1

rem Paths
call :ExpandRootDir %~dp0..\..
set SRCDIR=%ROOTDIR%src\
set SDKDIR=%SRCDIR%_sdk\
set TOOLSDIR=%ROOTDIR%tools\
set EMULDIR=%ROOTDIR%us\
set PATH=%TOOLSDIR%;%TOOLSDIR%mingw\;%TOOLSDIR%msys\;%ROOTDIR%;%ROOTDIR%us\;%SRCDIR%nedolang\_sdk\;%PATH%
set INSTALLDIR=%ROOTDIR%release\
set BIN_INSTALLDIR=%INSTALLDIR%bin\
set RES_INSTALLDIR=%INSTALLDIR%bin\
set DOC_INSTALLDIR=%INSTALLDIR%doc\

rem Shell hacks
set COMMENT=@rem
set NUL=nul

rem GNU core utilities
set CAT=%TOOLSDIR%msys\cat.exe
set CP=%TOOLSDIR%msys\cp.exe
set MKDIR=%TOOLSDIR%msys\mkdir.exe -p
set MV=%TOOLSDIR%msys\mv.exe
set RM=%TOOLSDIR%msys\rm.exe -f
set RMDIR=%TOOLSDIR%msys\rmdir.exe

rem XZ utilities
set XZ=%TOOLSDIR%msys\xz.exe

rem GNU make utility
set MAKE=%TOOLSDIR%mingw\make.exe
set MFLAGS=-w

rem SjAsmPlus compiler
set AS=%TOOLSDIR%sjasmplus
set AFLAGS=--nologo --msg=war

rem Free Pascal compiler
set FPC=fpc
set FPFLAGS=

rem SDK tools
set MHMT=%TOOLSDIR%mhmt.exe
set DMIMG=%TOOLSDIR%dmimg.exe
set DMIMG_ADDDIR=%TOOLSDIR%dmimg-adddir.bat
set CONVEGA=%SDKDIR%bin\convega.exe
set NEDOPAD=%SDKDIR%bin\nedopad.exe
set NEDORES=%SDKDIR%bin\nedores.exe
set NEDOTRD=%SDKDIR%bin\nedotrd.exe

rem Z80 emulator
set EMUL=%EMULDIR%emul.exe
exit /b

:ExpandRootDir
set ROOTDIR=%~f1\
exit /b
