/*			- putchar.c -

    The ANSI C "putchar" ...

    This example file for Z80SIO assumes that you have set up the
    serial port elsewhere.

    Version: 1.00 [IJAR]

*/

#include <stdio.h>
#include <intrz80.h>
#pragma language=extended

/* If the SIO pin CE is connected to A7, B/A to A1 and C/D to A0
   then the port addresses are as follows:                           */

#define SIO_DATA_A 0x7c
#define SIO_CONT_A 0x7d
#define SIO_DATA_B 0x7e
#define SIO_CONT_B 0x7f

static void __low_level_put(char c)
{
  while ((input(SIO_CONT_A) & 4) == 0) /* while buffer not ready */
    ;
  output(SIO_DATA_A, c);
}


int putchar(int val)
{
  if (val == '\n')		/* Convert EOL to CR/LF */
    __low_level_put('\r');
  __low_level_put(val);
  return val;
}
