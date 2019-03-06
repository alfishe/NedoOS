#pragma language=extended
char mychar;
/* global variable to hold char data from pointers */

char * gp;
char * pcd;
/* global pointers to character */

#define my_data ((char *) 0xD000)

char text[10];

void main(void)
{
  char *lp;   /* local pointer to char */
  pcd="abcd"; /* pointer to string in ROM */
  pcd=(char *) 0xDEEE;
  mychar= * my_data;
  gp=(char *) 0xDEED;
  /* constant pointers to uninitialized char */
  text[0]= * pcd;
  putchar(* (text+1));
  putchar(* gp);
  putchar('a');
  pcd= gp;
  mychar=* pcd;
  pcd=text;
  mychar=* pcd;
  lp=my_data;
  * pcd= mychar;
  * pcd='a';
  * gp= 'a';
}
