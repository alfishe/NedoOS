/*			 - intrz80.h -

   Intrinsic functions for the ICCZ80
	   
   Version: 4.00 [IHAT]

*/

#ifndef _INTRINS_INCLUDED
#define _INTRINS_INCLUDED

#pragma language=extended

#if __TID__ & 0x8000
#pragma function=intrinsic(0)
#endif


void enable_interrupt(void);
void disable_interrupt(void);
unsigned char input(unsigned short);
void output(unsigned short, unsigned char);
void halt(void);
void interrupt_mode_0(void);
void interrupt_mode_1(void);
void interrupt_mode_2(void);
void load_I_register(unsigned char);
unsigned char dump_I_register(void);
void _opc(unsigned char);
long address_24_of(void *);
void input_block_inc(unsigned char, unsigned char *, unsigned char);
void input_block_dec(unsigned char, unsigned char *, unsigned char);
void output_block_inc(unsigned char, unsigned char *, unsigned char);
void output_block_dec(unsigned char, unsigned char *, unsigned char);
unsigned char input8(unsigned char);
void output8(unsigned char, unsigned char);

/* HD64180/Z8018X functions */
void sleep(void);
void output_memory_block_inc(unsigned char, unsigned char *, unsigned char);
void output_memory_block_dec(unsigned char, unsigned char *, unsigned char);
#if __TID__ & 0x8000
#pragma function=default
#endif

#endif
