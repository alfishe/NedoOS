#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <oscalls.h>

#include "zip.h"
#include "deflate.h"

static void usage(void)
{
	printf("Usage: pkzip2 [-rle] <archive.zip> <file|dir>...\r\n");
	printf("  default  fast deflate (fixed Huffman)\r\n");
	printf("  -rle     RLE-oriented deflate (dist=1 runs)\r\n");
	printf("  Deflate when smaller, else store. Dirs recursive.\r\n");
}

C_task main(int argc, char *argv[])
{
	const char *archive;
	int level;
	int argi;
	int rc;

	os_initstdio();

	level = DEFL_FAST;
	argi = 1;

	while (argi < argc && argv[argi][0] == '-')
	{
		if (strcmp(argv[argi], "-rle") == 0 || strcmp(argv[argi], "-RLE") == 0)
			level = DEFL_RLE;
		else if (strcmp(argv[argi], "-l0") == 0 || strcmp(argv[argi], "-L0") == 0 ||
			 strcmp(argv[argi], "-l1") == 0 || strcmp(argv[argi], "-L1") == 0)
			level = DEFL_FAST; /* -l1 removed: was slower, almost no gain */
		else
		{
			usage();
			exit(1);
		}
		argi++;
	}

	if (argi + 1 >= argc)
	{
		usage();
		exit(1);
	}

	archive = argv[argi];
	argi++;

	rc = zip_create(archive, level, argc - argi, &argv[argi]);
	exit(rc);
}
