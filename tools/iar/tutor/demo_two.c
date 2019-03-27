/* second part of C-SPY DEMO */
#include "stdio.h"

char  array[10] = "abcd";

void demo_two(int i)
  {
    char *cp;

    cp = &array[i];
    printf ("%c\n", *cp);
  }
