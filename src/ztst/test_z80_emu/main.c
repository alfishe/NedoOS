#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zetaZ80/Z80_lite.h"

#include "z80-wrap.h"

#define MAX_Z80_CLOCKS (50000000000ULL)

struct type_detect type_list[] =
{
	{"--cpm",    SYS_CPM},
	{"--nedoos", SYS_NEDOOS},
	{"--zx",     SYS_ZX},
	{NULL,       0}
};

int main(int argc, char ** argv)
{
	int sys_type = (-1);

	if( argc>1 )
	{
		struct type_detect * ptr = type_list;

		while( ptr->argument_name )
		{
			if( !strcmp(ptr->argument_name,argv[1]) )
			{
				sys_type = ptr->sys_type;
			}

			ptr++;
		}
	}

	if( argc!=3 || sys_type<=0 )
	{
		fprintf(stderr,"There must be exactly two arguments!\n");
		fprintf(stderr," First: either --cpm, --zx or --nedoos\n");
		fprintf(stderr," Second: filename to load\n");
		exit(1);
	}

	struct z80_context * z80 = z80_init(argv[2],sys_type);
	if( !z80 )
	{
		fprintf(stderr,"Can't init z80 struct!\n");
		exit(1);
	}

	z80_exec(z80,MAX_Z80_CLOCKS);

	fprintf(stderr,"Max clocks of %llu exceeded, probably a lock-up!",MAX_Z80_CLOCKS);
	exit(1);

	return 0;
}

