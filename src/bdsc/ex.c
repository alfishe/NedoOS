#include <stdio.h>

main(argc,argv)
char **argv;
{
FILE *fp;
FILE *fpout;

setgfx();
cls();
putpixel(100,100,3);
putpixel(101,102,3);
getchar();
}
