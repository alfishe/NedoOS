#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "args.h"
#include "global.h"


struct argstruct 
{
	const char * match;
	int * const value_ptr;
	const int is_int;
};

struct argstruct args_info[] = 
{
	{ .match     = "--prebuf",
	  .value_ptr = &g.buf_num,
	  .is_int    = 1
	},

	{ .match     = "--testsync",
	  .value_ptr = &g.test_sync,
	  .is_int    = 0
	},

	{ .match     = NULL,
	  .value_ptr = NULL,
	  .is_int    = 0
	}
};



int parse_args(int cur_arg, int argc, char ** argv)
{
	if( cur_arg>argc ) return 0;

	struct argstruct * m = NULL;

	int read_value = 0;



	while( cur_arg < argc )
	{
		if( read_value )
		{	
			if( 1!=sscanf(argv[cur_arg++],"%d",m->value_ptr) ) return 0;

			read_value = 0;
			m = NULL;

			continue;
		}

		
		for(m=args_info; m->match!=NULL; m++)
		{
			if( !strcmp(m->match,argv[cur_arg]) )
			{
				if( !m->is_int )
					*(m->value_ptr) = 1;
				else
					read_value = 1;

				cur_arg++;
				
				break;
			}
		}

		if( !m->match ) return 0;
	}

	if( read_value ) return 0;



	return 1;
}


