#include <stdio.h>
#include <stdint.h>

#include "psg.h"
#include "net.h"

int main(int argc, char ** argv)
{
	net_init();
	
	net_test();

	net_dispose();
	return 0;
}

