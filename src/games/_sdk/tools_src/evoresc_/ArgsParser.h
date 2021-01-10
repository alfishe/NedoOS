#include <iostream>
#include <cstring>
#include <string>

using namespace std;

#define argsCount 13
class ArgsParser {

private:
	char* key[32];
	char* val[32];
	int keysCount;

public:
	ArgsParser() {
		char* keys[] = {"IMAGE_LIST","SPRTBL_PAGE","STARTUP_ADR","STACK_SIZE","SMP_COUNT","MUS_COUNT",
			"MUSLIST_ADR","SMPLIST_ADR","SFX_ADR","PAL_ADR","IMGLIST_ADR","TSPR_ADR","SPRBUF_PAGE","SPRTBL_PAGE"};
		char* vals[]={"","6","0xe000","0x0400","0x49ff","0x49fe","0x4a00","0x4d00","0x5100","0x0000","0x1000",
			"0xfa00","8","6"};
		for(int a=0;a<argsCount;a++) {
			key[a]=keys[a];
			val[a]=vals[a];
		}
	}

	void parse(int argc,char* argv[]) {

		keysCount=0;

		for(int a=0;a+1<argc;) {
			for(int b=0;b<argsCount;b++) {
				if(strcmpi(argv[a],key[b])==0) {
					//val[b]=strtol(argv[a+1],NULL,0);
					val[b]=argv[a+1];
					a++;
					b=argsCount;
				}
			}
			a++;
		}
	}
	char* getArg (char* argName) {
		for (int a=0;a<argsCount;a++) {
			if(strcmpi(key[a],argName)==0) {
				return val[a];
			}
		}
		return "";
	}
};
