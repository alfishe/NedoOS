#include <iostream>
#include <cstring>
#include <string>
#include <msclr/marshal.h>

using namespace std;


class ArgsParser {
private:
	string key[32];
	string val[32];
	int keysCount;
public:
	void parse(int argc,char* argv[]) {
		keysCount=0;
		string str = argv[0];
		
		for(int a=0;a+2<argc;) {
			if(strcmpi(argv[a+1],"=")==0) {
				key[keysCount]=argv[a];
				val[keysCount]=argv[a+2];
				keysCount++;
				a++;
			}
			a++;
		}
	}
};
