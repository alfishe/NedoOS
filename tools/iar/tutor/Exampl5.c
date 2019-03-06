/* using pragma definitions instead of modifiers */
#include <stdio.h>
#pragma language=extended
int ccount;
#pragma memory=dataseg(mydseg)
/* you must define mydseg in the linker file */
int loopc;
#pragma memory=default

#pragma function=monitor
void loop10(void)
{
  for (loopc=1;loopc<10;loopc++);
}
#pragma function=default

#pragma function=non_banked
void printcnt(int ccnt)
{
  printf("the count is now %d",ccnt);
}
void main(void)
{
  int my_int=0;
  int my_int2=0;
  ccount=1;
  
  while (my_int<100)
  {
    loop10();
    my_int++;
    printcnt(my_int);
  }
}