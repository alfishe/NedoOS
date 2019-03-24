
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include "..\oscalls.h"


enum RSTFUNC { 
	_BIOS = 0x4f, _COM_DEV, _COM_FAT, _SORT_FINDFILES, _MOUNTER,
	_INST_FATBOOT, _CMOS_RW, _SETUP_PAL, _SETUP_FONT};
	
enum SUB_COM_DEV {
	_DEVFIND = 0x0050, _SET_VOL = 0x0150, _KOL_VOL = 0x0250, _GET_FNDVOLUME = 0x0350,
	_TO_DRV = 0x0450, _SET_DEVICE = 0x0550, _CONTROL_SD = 0x0650, _COMHDDN = 0x0750, 
	_FREINIT_VOL = 0x0850};


unsigned int rst8call(unsigned int func, unsigned int, void *);
#define GET_FNDVOLUME(_ptr) rst8call(_GET_FNDVOLUME, 0, _ptr)
#define GET_KOL_VOL() rst8call(_KOL_VOL, 0, _ptr)

no_init unsigned char save_pg;
no_init unsigned char volumes[256]; 
no_init unsigned char vols;

void initMCU(void){
	YIELD();
	OS_SETGFX(6);
}

C_task main (int argc, char *argv[]) 
{
	initMCU();
	save_pg=(input(0x0abe)&0x10)?input(0x04be):input(0x00be);
	//if(argc==1){
	//	puts("Need more parameters");
	//	return 1;
	//}
	GET_FNDVOLUME(volumes);
	vols=GET_KOL_VOL() & 0xff;
	return 0;
}