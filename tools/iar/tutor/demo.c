/*    DEMO.C    -   C-SPY Demo Program   */

#include "stdio.h"
#include "defns.h"
void demo_two(int i);

int d; 

void main(void) 
  {
    int i;

    for (i = 0, d = 1; i < TWO_POWER; i++)
      d *= 2;
    printf("2 to the power of %d is %d\n",
                 TWO_POWER, d);
    demo_two(3);
  } 
