#include <iostream>
#include <cstring>
#include <string>
#include <stdio.h>

using namespace std;
#define BINARY_FILE 0
#define STARTUP_FILE 1
#define	IMAGE_LIST 2
#define	MUSIC_LIST 3
#define	PALETTE_LIST 4
#define	SAMPLE_LIST 5
#define	SPRITE_LIST 6
#define	SFX_LIST 7
#define	SPRTBL_PAGE 8
#define	STARTUP_ADR 9
#define	STACK_SIZE 10
#define	SMP_COUNT 11
#define	MUS_COUNT 12
#define	MUSLIST_ADR 13
#define SMPLIST_ADR 14
#define	SFX_ADR 15
#define PAL_ADR 16
#define	IMGLIST_ADR 17
#define	TSPR_ADR 18
#define	SPRBUF_PAGE 19
#define	SPRTBL_PAGE2 20
#define	SPRTBL_SLOT 21
#define	SPRITE_SLOT 22
#define CC_PAGE0 23
#define CC_PAGE1 24
#define CC_PAGE2 25
#define CC_PAGE3 26
#define SND_PAGE 27
#define PAL_PAGE 28
#define GFX_PAGE 29
#define ALT_PAGE_NUMERING 30
#define SOUND_BIN_FILE 31

#define argsCount 32
class ArgsParser {

private:
	
	char* val[32];
	int keysCount;

public:
	ArgsParser() {
		
		char* vals[]={	"_temp_\\out.ihx",
						"..\\evosdk\\startup.bin",
						"_temp_\\image.lst",
						"_temp_\\music.lst",
						"_temp_\\palette.lst",
						"_temp_\\sample.lst",
						"_temp_\\sprite.lst",
						"",
						"6","0xe000","0x0400",
						"0x49ff","0x49fe",
						"0x4a00","0x4d00",
						"0x5100","0x0000",
						"0x1000","0xfa00",
						"8","6","0","0",
						"12","13","14",
						"15","0","4","16","0",
						"../evosdk/sound.bin"};
		for(int a=0;a<argsCount;a++) {
			val[a]=vals[a];
		}
	}

	void parse(int argc,char* argv[]) {
		char* key[] = {"BINARY_FILE",
						"STARTUP_FILE",
						"IMAGE_LIST",
						"MUSIC_LIST",
						"PALETTE_LIST",
						"SAMPLE_LIST",
						"SPRITE_LIST",
						"SFX_LIST",
						"SPRTBL_PAGE",
						"STARTUP_ADR",
						"STACK_SIZE",
						"SMP_COUNT",
						"MUS_COUNT",
						"MUSLIST_ADR",
						"SMPLIST_ADR",
						"SFX_ADR",
						"PAL_ADR",
						"IMGLIST_ADR",
						"TSPR_ADR",
						"SPRBUF_PAGE",
						"SPRTBL_PAGE",
						"SPRTBL_SLOT",
						"SPRITE_SLOT",
						"CC_PAGE0",
						"CC_PAGE1",
						"CC_PAGE2",
						"CC_PAGE3",
						"SND_PAGE",
						"PAL_PAGE",
						"GFX_PAGE",
						"ALT_PAGE_NUMERING",
						"SOUND_BIN_FILE"
		};

		keysCount=0;
		/*for(int a=0;a<argc;a++) {
			printf("[arg %d = %s]\n",a,argv[a]);
		}*/
		for(int a=0;a+1<argc;) {
			for(int b=0;b<argsCount;b++) {
				if(strcmpi(argv[a],key[b])==0) {
					val[b]=argv[a+1];
					a++;
					b=argsCount;
				}
			}
			a++;
		}
	}
	char* getArg (int argName) {
		return val[argName];
	}
	void printHelp() {
		char* key[] = {"BINARY_FILE",
						"STARTUP_FILE",
						"IMAGE_LIST",
						"MUSIC_LIST",
						"PALETTE_LIST",
						"SAMPLE_LIST",
						"SPRITE_LIST",
						"SFX_LIST",
						"SPRTBL_PAGE",
						"STARTUP_ADR",
						"STACK_SIZE",
						"SMP_COUNT",
						"MUS_COUNT",
						"MUSLIST_ADR",
						"SMPLIST_ADR",
						"SFX_ADR",
						"PAL_ADR",
						"IMGLIST_ADR",
						"TSPR_ADR",
						"SPRBUF_PAGE",
						"SPRTBL_PAGE",
						"SPRTBL_SLOT",
						"SPRITE_SLOT",
						"CC_PAGE0",
						"CC_PAGE1",
						"CC_PAGE2",
						"CC_PAGE3",
						"SND_PAGE",
						"PAL_PAGE",
						"GFX_PAGE",
						"ALT_PAGE_NUMERING",
						"SOUND_BIN_FILE"};
		printf("EVOSDK Resource Compiler by Shiru and Alone Coder 03'12\n");
		printf("modified by Hippiman 2021\n");
		printf("Key\t\tDefault Value\n");
		for(int a=0;a<argsCount;a++) {
			printf("%s\t\t%s\n",key[a],val[a]);
		}
	}
};
