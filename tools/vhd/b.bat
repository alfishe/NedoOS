@echo off
rem Create sd & hdd images
echo create vdisk file="%cd%\sd_nedo.vhd" MAXIMUM=64 TYPE=FIXED > VHDcreate.txt
echo select vdisk file="%cd%\sd_nedo.vhd" >> VHDcreate.txt
echo attach vdisk >> VHDcreate.txt
echo create part primary >> VHDcreate.txt
echo select part 1 >> VHDcreate.txt
echo format label="SD_NEDOOS" quick fs=FAT32 >> VHDcreate.txt
echo detach vdisk >> VHDcreate.txt
echo create vdisk file="%cd%\hdd_nedo.vhd" MAXIMUM=128 TYPE=FIXED >> VHDcreate.txt
echo select vdisk file="%cd%\hdd_nedo.vhd" >> VHDcreate.txt
echo attach vdisk >> VHDcreate.txt
echo create part primary size=60  >> VHDcreate.txt
echo create part primary >> VHDcreate.txt
echo select part 1 >> VHDcreate.txt
echo format label="NEDOOS" quick fs=FAT32 >> VHDcreate.txt
echo select part 2 >> VHDcreate.txt
echo format label="TESTVOL" quick fs=FAT32 >> VHDcreate.txt
echo detach vdisk >> VHDcreate.txt
diskpart /s VHDcreate.txt
del VHDcreate.txt