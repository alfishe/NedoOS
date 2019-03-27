 /* enable use of extended keywords */
#pragma language=extended         
 /* include definitions for IO registers */
#include <io64180.h>               
 /* include definitions for intrinsics */
#include <intrz80.h>
 /* combines input function and mask */
#define receive_full (STAT0 & 128) 
 /* output port decoded by external logic */
#define my_port  0xC0  
/*********************************** 
*                                 * 
*        Start of code            * 
*                                 * 
***********************************/
char my_char;   
int call_count;

interrupt [11] void receive_char( void) 
{  
  /* interrupt indicates received data */  
  my_char= RDR0;         
  /* output receive register */ 
  output8(my_port,my_char);
}

void do_foreground_process(void)
{
  call_count++;
  
}

void main(void)
{ 
 /* Initialize comms channel */ 
 /* 2400 with 6.144 MHz clock */
 CNTLB0 = 0x2A;            
 /* enable and data format */
 CNTLA0 = 0x65 ;         
 /* enable interrupts on received char */
 STAT0|=1;
   /* now loop forever, taking input automatically */  
 /* enable interrupts through C function */
 enable_interrupt();
 while (1)  
  {    
   do_foreground_process();  
  } 
}

