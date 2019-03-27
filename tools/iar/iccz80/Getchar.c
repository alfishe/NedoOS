/*			- getchar.c -

  The ANSI "getchar" function delivered here is supposed to be tailored
  for the actual target hardware.  This version of getchar contains a simple
  line-editor that can back-space and delete  (In_DELETE), skip line and
  start over again (In_SKIP), as well as recognize end of file (In_EOF).

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


#define LINE_LENGTH 80		/* Change if you need */

#define In_DELETE 0x7F		/* ASCII <DEL> */
#define In_EOL '\r'		/* ASCII <CR> */
#define In_SKIP '\3'		/* ASCII control-C */
#define In_EOF '\x1A'		/* ASCII control-Z */

#define Out_DELETE "\x8 \x8"	/* VT100 backspace and clear */
#define Out_SKIP "^C\n"		/* ^C and new line */
#define Out_EOF	"^Z"		/* ^Z and return EOF */



static char low_level_get(void)	/* Read one char from I/O - Hardware-dep. */
{
  while ((input(SIO_CONT_A) & 1) == 0)
    ;
  return input(SIO_DATA_A);

/* return In_EOF; */		/* indicate failure */
}


static void put_message (char *s)
{
  while (*s)
    {
      putchar (*s);
      s++;
    }
}


int getchar(void)
{
  static char io_buffer[LINE_LENGTH + 2]; /* Where to put chars */
  static int ptr;			  /* Pointer in buffer */
  char c;
  
  while (42)
    {
      if (io_buffer[ptr])
	return (io_buffer[ptr++]);
      ptr = 0;
      while (42)
	{
	  if ( (c = low_level_get()) == In_EOF && ! ptr)
	    {
	      put_message (Out_EOF);
	      return (EOF);
	    }
	  if (c == In_DELETE)
	    {
	      if (ptr)
		{
		  ptr--;
		  put_message (Out_DELETE);
		}
	    }
	  else if (c == In_SKIP)
	    {
	      put_message (Out_SKIP);
	      ptr = LINE_LENGTH + 1;	/* Where there always is a zero... */
	      break;
	    }
	  else if (c == In_EOL)
	    {
	      putchar (io_buffer[ptr++] = '\n');
	      io_buffer[ptr] = 0;
	      ptr = 0;
	      break;
	    }
	  else if (ptr < LINE_LENGTH)
	    {
	      if (c >= ' ')
		{
		  putchar (io_buffer[ptr++] = c);
		}
	    }
	  else
	    {
	      putchar ('\7');
	    }
	}
    }
}


