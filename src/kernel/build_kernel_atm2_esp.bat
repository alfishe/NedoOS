@echo off
REM ATM2+HD ESPNET kernel -> release\osatm2hd.$c
cd /d "%~dp0"
echo atm=2 > "%~dp0..\_sdk\syssets.asm"
echo atm2clock=1 >> "%~dp0..\_sdk\syssets.asm"
echo sys_npages=64 >> "%~dp0..\_sdk\syssets.asm"
echo NEMOIDE=0 >> "%~dp0..\_sdk\syssets.asm"
echo SYSDRV=4 >> "%~dp0..\_sdk\syssets.asm"
echo INETDRV=0x02 >> "%~dp0..\_sdk\syssets.asm"
echo PS2KBD=0x00 >> "%~dp0..\_sdk\syssets.asm"
echo  define ATMRESIDENT >> "%~dp0..\_sdk\syssets.asm"
echo  define KEEPPG38 >> "%~dp0..\_sdk\syssets.asm"
call "%~dp0run_kernel.bat" osatm2hd esp
