PATH=..\..\evosdk
echo messageStr > filelist.asm
echo 	db %title%,0 >> filelist.asm
echo fileList >> filelist.asm
megalz page_16.bin >nul
call _getsize.bat page_16.bin.mlz 16
megalz page_17.bin >nul
call _getsize.bat page_17.bin.mlz 17
megalz page_4.bin >nul
call _getsize.bat page_4.bin.mlz 4
