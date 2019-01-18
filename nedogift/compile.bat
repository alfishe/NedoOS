@echo off
path=..\_sdk\

rem nedodefb lvnt_1 font.asm font 0 2048
nedopad lvnt_1 font.bin 0 2048
rem nedodefb net-35.s net35.asm _net35 6144 768
nedopad net-35.s net35.bin 6144 768
rem nedodefb net-tort.s nettort.asm _nettort 6144 768
nedopad net-tort.s nettort.bin 6144 768

echo ...compiling...
nedolang demo.c
type err.f

echo ...tokenizing...
nedotok demo.s demoproc.s demo.asm demo.var ../_sdk/pt3play.i ../_sdk/lib.i

echo ...assembling...
nedoasm demo.S_
type asmerr.f

pause
