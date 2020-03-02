#include <stdint.h>

#include "global.h"

struct global g;

void init_global(void)
{
	g.prebuf = 100;

	g.syncchk = 0;

	g.framechk = 0;
}

