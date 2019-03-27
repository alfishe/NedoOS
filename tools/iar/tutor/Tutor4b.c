 /* enable use of extended keywords */
#pragma language=extended         
/*********************************** 
*                                 * 
*        Start of code            * 
*                                 * 
***********************************/
int call_count;

#pragma function=RCODE
non_banked void do_foreground_process(void)
{
  call_count++;
}

