@echo off
REM ZX Evolution ESPNET kernel -> release\sd_boot.$c
cd /d "%~dp0"
echo atm=1 > "%~dp0..\_sdk\syssets.asm"
echo atm2clock=0 >> "%~dp0..\_sdk\syssets.asm"
echo sys_npages=192 >> "%~dp0..\_sdk\syssets.asm"
echo NEMOIDE=1 >> "%~dp0..\_sdk\syssets.asm"
echo SYSDRV=12 >> "%~dp0..\_sdk\syssets.asm"
echo INETDRV=0x02 >> "%~dp0..\_sdk\syssets.asm"
echo PS2KBD=0x01 >> "%~dp0..\_sdk\syssets.asm"
echo  define NGSSD >> "%~dp0..\_sdk\syssets.asm"
echo  define ATMRESIDENT >> "%~dp0..\_sdk\syssets.asm"
call "%~dp0run_kernel.bat" sd_boot esp sd
