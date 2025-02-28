#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zetaZ80/Z80_lite.h"

#include "z80-wrap.h"

int main(int argc, char ** argv)
{
	if( argc!=3 || (strcmp(argv[1],"--cpm") && strcmp(argv[1],"--nedoos")) )
	{
		fprintf(stderr,"There must be exactly two arguments!\n");
		fprintf(stderr," First: either --cpm or --nedoos\n");
		fprintf(stderr," Second: filename to load\n");
		exit(1);
	}

	struct z80_context * z80 = z80_init(argv[2],strcmp(argv[1],"--cpm"));
	if( z80 )
	{
		z80_exec(z80,100000000000,0x100);
	}


	return 0;
}

