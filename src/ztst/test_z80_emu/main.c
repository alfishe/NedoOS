#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zetaZ80/Z80_lite.h"

#include "z80-wrap.h"

#define MAX_Z80_CLOCKS (50000000000ULL)

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
	if( !z80 )
	{
		fprintf(stderr,"Can't init z80 struct!\n");
		exit(1);
	}

	z80_exec(z80,MAX_Z80_CLOCKS,0x100);

	fprintf(stderr,"Max clocks of %llu exceeded, probably a lock-up!",MAX_Z80_CLOCKS);
	exit(1);

	return 0;
}

