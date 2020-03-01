#include <stdint.h>

#include "global.h"

struct global g;

void init_global(void)
{
	g.buf_num = 100;

	g.test_sync = 0;
}

