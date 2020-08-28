#include <stdio.h>
main(argc,argv)
char **argv;
{
int i;
printf("Hello world!\n");

for (i = 1; i < argc; i++) printf("Arg #%d = %s\n",i,argv[i]);

getchar();
setgfx();
cls();
putpixel(100,100,3);
putpixel(101,102,3);
getchar();
/*while(1) {
 i = 0;
 i = 1;
}*/
}
