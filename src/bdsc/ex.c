#include <stdio.h>
main(argc,argv)
char **argv;
{
int i;
for (i = 1; i < argc; i++)
printf("Arg #%d = %s\n",argv[i]);
}
