@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolspt -C state.c
type err.f
..\_sdk\nedolspt -C global.c
type err.f
..\_sdk\nedolspt -C constarr.c
type err.f
..\_sdk\nedolspt cmdlist.c
type err.f
..\_sdk\nedotok state.s
..\_sdk\nedoaspt state.S_
type asmerr.f
if "%currentdir%"=="" (pause)
del label0.f
