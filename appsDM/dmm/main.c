
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include "..\oscalls.h"


enum DRV_ENUM {DRV_A=0x0000, DRV_B=0x0001, DRV_C=0x0002, DRV_D=0x0003, DRV_ZSD=0x0004,
	DRV_NSD=0x0005, DRV_NEMOM=0x0006, DRV_NEMOS=0x0106, DRV_SMUCM=0x0007, DRV_SMUCS=0x0107};
enum HDD_MS {HDD_MASTER, HDD_SLAVE};
enum VOL_TYPE {VOL_FAT12, VOL_FAT16, VOL_FAT32};

typedef struct {enum DRV_ENUM drv; enum VOL_TYPE fat;
	unsigned long ssec; unsigned char res;} VOLDESCR;
	
enum RSTFUNC { 
	_BIOS = 0x4f, _COM_DEV, _COM_FAT, _SORT_FINDFILES, _MOUNTER,
	_INST_FATBOOT, _CMOS_RW, _SETUP_PAL, _SETUP_FONT};
	
enum SUB_COM_DEV {
	_DEVFIND = 0x0050, _SET_VOL = 0x0150, _KOL_VOL = 0x0250, _GET_FNDVOLUME = 0x0350,
	_TO_DRV = 0x0450, _SET_DEVICE = 0x0550, _CONTROL_SD = 0x0650, _COMHDDN = 0x0750, 
	_FREINIT_VOL = 0x0850};
	
enum SUB_COM_FAT {
	_INIT_FATVARS = 0x0051, _READ_DIR = 0x0151, _ENTER_DIR = 0x0251, _GET_PATH = 0x0351,
	_GET_LONGNAME = 0x0451, _FIND_NAME = 0x0551, _FIND_FILEITEM = 0x0651, _SET_MASK_EXT = 0x0751, 
	_OPEN_FILE = 0x0851, _READ_FILE = 0x0951, _INIT_TEKDIR = 0x0a51, _POS_FILES = 0x0b51};


unsigned int rst8call(unsigned int func, unsigned int, void *);
#define GET_FNDVOLUME(_ptr) rst8call(_GET_FNDVOLUME, 0, _ptr)
#define GET_KOL_VOL() rst8call(_KOL_VOL, 0, 0)
#define GET_SET_VOL(_vol) rst8call(_SET_VOL, _vol, 0)
#define RST8_FIND_NAME(_ptr) rst8call(_FIND_NAME, 0, _ptr)
#define RST8_ENTER_DIR() rst8call(_ENTER_DIR, 0, 0)
#define RST8_DEVFIND() rst8call(_DEVFIND, 0, 0)
#define RST8_OPEN_FILE() rst8call(_OPEN_FILE, 0, 0)
#define RST8_OPEN_MOUNT(_vol) rst8call(_MOUNTER, _vol, 0)

no_init unsigned char save_pg;
no_init union {VOLDESCR v[256/8];unsigned char b[256];}buf;
//VOLDESCR volumes[256/8];
//no_init unsigned char volumes[256]; 
no_init unsigned char cpath[256];
unsigned char * cpath_ptr;
no_init unsigned char * ptr;
no_init unsigned char vols;
no_init unsigned int tint;
no_init unsigned char tchar;
enum DRV_ENUM vol_os_ers[]={DRV_ZSD,DRV_NEMOM,DRV_NEMOS,DRV_ZSD};

void initMCU(void){
	YIELD();
	OS_SETGFX(6);
	save_pg=(input(0x0abe)&0x10)?input(0x04be):input(0x00be);
}

C_task main (int argc, char *argv[]) 
{
	unsigned char i;
	initMCU();
	if(argc<2){
		puts("Need more parameters");
		exit();
	}
	//RST8_DEVFIND();
	GET_FNDVOLUME(buf.v);
	vols=GET_KOL_VOL() & 0xff;
	ptr=OS_GETPATH(cpath);
	if(argv[1][1]==':'){
		tchar=argv[1][0]-'0';
		argv[1]+=2;
	}else{
		tchar=cpath[0]-'0';
	}
	cpath_ptr=cpath+3;
	if(tchar>=(sizeof(vol_os_ers)/2)) goto errdrv;
	tint=vol_os_ers[tchar];
	i=0;
	for(i=0;(i<vols)&&(tint!=buf.v[i].drv);i++);
	if(i==vols) goto errdrv;
	if(GET_SET_VOL(i),errno) goto errdrv;
	while((RST8_FIND_NAME(".."),errno)==0) RST8_ENTER_DIR();
	if(argv[1][0]!='/'){
		ptr=cpath_ptr;
		while(1){
			while((*ptr!='/')&&(*ptr!=0x00)) ptr++;
			if(*ptr==0x00){
				if(RST8_FIND_NAME(cpath_ptr),errno) goto errpath;
				RST8_ENTER_DIR();
				break;
			}else{
				*ptr=0x00;
				if(RST8_FIND_NAME(cpath_ptr),errno) goto errpath;
				RST8_ENTER_DIR();
				ptr++;
				cpath_ptr=ptr;
			}
		}
	}else{
		argv[1]++;
	}
	if(argc>2) tchar = (argv[2][0]&0xdf)-'A';
	else tchar = 0;
	if(tchar>3){
		puts("Uncorrect fdd letter");
		return 0;
		
	}
	strcpy(cpath,argv[1]);
	cpath_ptr = cpath;
	ptr = cpath;
	while(1){
		while((*ptr!='/')&&(*ptr!=0x00)) ptr++;
		if(*ptr==0x00){
			if(RST8_FIND_NAME(cpath_ptr),errno) goto errfile;
			RST8_OPEN_MOUNT(tchar);
			break;
		}else{
			*ptr=0x00;
			if(RST8_FIND_NAME(cpath_ptr),errno) goto errpath;
			RST8_ENTER_DIR();
			ptr++;
			cpath_ptr=ptr;
		}
	}
	return 0;
errdrv:
	puts("Uncorrect drive-number");
	return 0;
errpath:
	puts("Uncorrect path");
	return 0;
errfile:
	puts("Uncorrect filename");
	return 0;
}