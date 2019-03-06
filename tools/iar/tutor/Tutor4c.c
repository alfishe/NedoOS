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

#pragma function=RCODE

#pragma function=non_banked
interrupt [11] void receive_char( void) 
{  
  /* interrupt indicates received data */  
  my_char= RDR0;         
  /* output receive register */ 
  output8(my_port,my_char);
}

