#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "zetaZ80/Z80_lite.h"

#include "z80-wrap.h"

int main(int argc, char ** argv)
{
	if( argc!=2 )
	{
		fprintf(stderr,"There must be exactly one argument!\n");
		exit(1);
	}

	struct z80_context * z80 = z80_init(argv[1]);
	if( z80 )
	{
		z80_exec(z80,100000000000,0x100);
	}


	return 0;
}

