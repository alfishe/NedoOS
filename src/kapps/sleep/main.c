#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
unsigned char *p;

void error(void)
{
	printf("Usage: sleep.com delay \r\n");
	printf("Delay in range from 0 to 65500 ms with step of 50ms\r\n");
	printf("If delay = 0 then program waiting for keypress\r\n");
	exit(0);
}

C_task main(int argc, char *argv[])
{
	unsigned int counter;
	long start, finish;
	unsigned char key;
	os_initstdio();

	if (argc == 2)
	{
		p = argv[1];
		counter = atoi(p);

		if (counter == 0)
		{
			do
			{
				key = _low_level_get();
			} while (key == 0);
			exit(0);
		}
		counter = counter / 20;
		if (counter < 1)
		{
			counter = 1;
		}
		start = time();
		finish = start + counter;

		while (start < finish)
		{
			start = time();
		}
		exit(0);
	}
	error();
	//	return 0;
}
