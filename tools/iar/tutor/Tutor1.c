#include <stdio.h>

int call_count;
unsigned char my_char;
const char con_char='a';

void do_foreground_process(void)
 {
  int fp_var=1;
  call_count++;
  putchar(my_char);
 }

void set_local(void)
 {
  int inc_var=1;
  char inc_char;
  inc_char='b';
 }

void main(void)
 {
  int my_int=0;
  call_count=0;
  my_char=con_char;
  set_local();
  while (my_int<100)
  { 
   do_foreground_process();
   my_int++;
  }
 }
