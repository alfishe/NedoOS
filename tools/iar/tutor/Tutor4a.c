 /* enable use of extended keywords */
#pragma language=extended         
 /* include definitions for IO registers */
#include <io64180.h>               
 /* include definitions for intrinsics */
#include <intrz80.h>
/*********************************** 
*                                 * 
*        Start of code            * 
*                                 * 
***********************************/
extern char my_char;   
#pragma function=RCODE
extern non_banked void do_foreground_process(void);
#pragma function=default
 
void init_comms(void)
{
 /* Initialize comms channel */ 
 /* 2400 with 6.144 MHz clock */
 CNTLB0 = 0x2A;            
 /* enable and data format */
 CNTLA0 = 0x65 ;         
 /* enable interrupts on received char */
 STAT0|=1;
 /* enable interrupts through C function */
 enable_interrupt();
}

void main(void)
{ 
 init_comms();
 while (1)  
  {    
   /* now loop forever, taking input automatically */  
   do_foreground_process();  
  } 
}

