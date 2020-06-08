@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolspt state.c
type err.f
..\_sdk\nedolspt cmdlist.c
type err.f
..\_sdk\nedotok state.s state.ast state.var cmdlist.var
..\_sdk\nedoaspt state.S_
type asmerr.f
if "%currentdir%"=="" (pause)
