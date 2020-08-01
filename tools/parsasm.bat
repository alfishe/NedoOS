@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET PSTR=%*
SET CEL=
FOR %%a IN ("%PSTR:-=" "%") DO (
	FOR /F "tokens=1,2,3" %%b IN (%%a) DO (
		IF "%%b"=="MT" SET CEL=%%c !CEL!
		IF "%%b"=="MF" SET DOTD=%%c
		IF "%%b"=="I" SET WINSDK=%%~dpnc
		IF NOT "%%d"=="" SET SRC=%%d
	)
)

SET PARS=!CEL!:

CALL :FUNC !SRC!
GOTO :EXIT

:FUNC
SET PARS=!PARS! %1
FOR /F "eol=; tokens=1,2,3 " %%i IN (%1) DO (
	IF "%%i"=="include" (
		IF EXIST %%~j (
			CALL :FUNC %%~j
		) ELSE (
			CALL :FUNC !WINSDK!%%~j
		)
	)
)
exit /b

:EXIT
ECHO !PARS! > !DOTD!