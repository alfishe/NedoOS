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

char read_char(void) 
 {  
  /* Loop until bit 7 indicates receive data */  
  while (!receive_full); 
  my_char= RDR0;         
  /* return receive register */ 
  return(my_char);
  }

void do_foreground_process(void)
 {
  call_count++;
  output8(my_port,my_char);
 }

void main(void)
 { 
 /* Initialize comms channel */ 
 /* 2400 with 6.144 MHz clock */
 CNTLB0 = 0x2A;            
 /* enable and data format */
 CNTLA0 = 0x65 ;         
   
   /* now loop forever, taking input when ready */  
 while (1)  
  {    
   if (read_char()) do_foreground_process();  
  } 
}

