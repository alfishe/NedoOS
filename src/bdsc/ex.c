#include <stdio.h>
main(argc,argv)
char **argv;
{
int i;
printf("Hello world!\n");
printf("Hello world!\n");

for (i = 1; i < argc; i++)
printf("Arg #%d = %s\n",i,argv[i]);

while(1) {
 i = 0;
 i = 1;
}
}
