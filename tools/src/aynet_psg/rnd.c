#include <stdint.h>

#include "rnd.h"

uint32_t get_rnd(void)
{
	static uint32_t seed=0;

	if(!seed)
	{
		seed = 1;
	}
	else
	{
		// xorshift, period = 2^32-1
		seed ^= seed<<13;
		seed ^= seed>>17;
		seed ^= seed<<5;
	}

	return seed;
}

