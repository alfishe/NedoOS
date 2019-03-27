/*				- bnksetup.c -

	    #################################################
	    #						    #
	    #    Ladies and gentlemen!			    #
	    #						    #
	    #    Welcome to the world of high-performance,  #
	    #    high-quality and high-productivity system  #
	    #    software.				    #
	    #						    #
	    #		     IAR Systems AB		    #
	    #		     P.O. Box 23051		    #
	    #		S-750 23 Uppsala, SWEDEN	    #
	    #						    #
	    #################################################

   This is a 64180/Z8018X bank setup utility program.

   Created: 10/Aug/94 IHAT

   (c) Copyright IAR Systems 1994

   $Revision: 1.3 $

*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>


static void wait_for_key(void)
{
  printf("Hit a key...");
  getchar();
}

static unsigned long read_hex(void)
{
  unsigned char buf[10];
  long ret = 0L;

  if (fgets((char*)buf, 10, stdin))
    {
      int len = strlen(buf), i;

      if (len == 0)
	return read_hex();
      if (buf[len - 1] == '\n')
	buf[len - 1] = '\0';
      if (!isxdigit(*buf))
	{
	  printf("%%Expecting hex digits, redo from start\n");
	  return read_hex();
	}
      for (i = 0; buf[i] != '\0'; i++)
	{
	  ret <<= 4L;
	  if (buf[i] >= '0' && buf[i] <= '9')
	    ret |= buf[i] - '0';
	  else if (buf[i] >= 'A' && buf[i] <= 'F')
	    ret |= buf[i] - 'A' + 10;
	  else if (buf[i] >= 'a' && buf[i] <= 'f')
	    ret |= buf[i] - 'a' + 10;
	  else
	    {
	      printf("%%Expecting hex digits, redo from start\n");
	      return read_hex();
	    }
	}
      return ret;
    }
  return (unsigned long)-1L;		/* failed */
}

static unsigned long get_hex(char *prompt, int digits, unsigned long min, unsigned long max)
{
  unsigned long ret;

  printf(prompt);
  while (1)
    {
      ret = read_hex();
      if (ret >= min && ret <= max)
	{
	  if (ret & 0xfff)
	    printf("%%Note, the hex number must end with 000 (even 4K banks)\n");
	  return ret;
	}
      printf("%%Bad input, give a hex number %lX-%lX\n", min, max);
    }
}

int main()
{
  int x, y, cbar, cbr;
  long data_start, data_end, bank_start, bank_end, data_size;

  printf("Welcome to the 64180/Z818X bank setup utility.\n\n");
  printf("Your logical 64K memory map is divided in 3 parts:\n");
  printf("  1. A root code area (Common area 0) which will hold\n");
  printf("     interrupts, non-banked functions and assembly support\n");
  printf("     routines.  This block starts at address 0x0000\n");
  printf("  2. A bank area which will hold your banked C code.\n");
  printf("  3. A fixed data area (Common area 1) which starts above\n");
  printf("     the bank are and ends at 0xFFFF.  This is where you\n");
  printf("     will have your stack and RAM\n\n");
  printf("Each block must start at an even 4K boundary\n");
  wait_for_key();

  printf("The logical memory map can be visualized as:\n\n");
  printf("    +----------------+ FFFF\n");
  printf("    |                |\n");
  printf("    |   Data area    |\n");
  printf("    |                |\n");
  printf("    +----------------+ YYYY\n");
  printf("    |                |\n");
  printf("    |   Bank area    |\n");
  printf("    |                |\n");
  printf("    +----------------+ XXXX\n");
  printf("    |                |\n");
  printf("    |   Root code    |\n");
  printf("    |                |\n");
  printf("    +----------------+ 0000\n\n");
  x = get_hex("Give me the value of XXXX (in hex):", 
	      4, 0x1000L, 0xE000L) / 0x1000L;
  y = get_hex("Give me the value of YYYY (in hex):", 
	      4, x * 0x1000L + 0x1000L, 0xF000L) / 0x1000L;
  
  printf("\nOk, now a few words about the physical memory which can be\n");
  printf("512K or 1024K large depending on your chip.\n");
  printf("In your case, the root code area must be located at physical memory\n");
  printf("address 0000-%1XFFF.\n", x - 1);
  printf("Both the bank area and the data area can start at any 4K\n");
  printf("page within the physical memory.\n");
  bank_start = 
    get_hex("Enter full physical start address for banked code (in hex):",
	    6, x * 0x1000L, 0xff0000L);
  data_start =
    get_hex("Enter full physical start address for the data area (in hex):",
	    6, x * 0x1000L, 0xff0000L);

  printf("\n");

  /* calculate all "magic" MMU register values */
  cbar = (y << 4) | x;
  cbr  = data_start / 0x1000 - y;

  data_start &= 0xfff000L;
  bank_start &= 0xfff000L;
  if (data_start > bank_start)
    {
      data_end = 0xffffffL;
      bank_end = data_start - 1L;
    }
  else
    {
      bank_end = 0xffffffL;
      data_end = bank_start - 1L;
    }
  data_size = (16 - y) * 0x1000L;

  if (data_size + data_start < data_end)
    data_end = data_start + data_size - 1L;
  
  printf("Your logical 64K memory map looks like this:\n");
  printf("    +----------------+ FFFF\n");
  printf("    |                |\n");
  printf("    |   Data area    |\n");
  printf("    |                |\n");
  printf("    +----------------+ %1X000\n",y);
  printf("    |                |\n");
  printf("    |   Bank area    |\n");
  printf("    |                |\n");
  printf("    +----------------+ %1X000\n",x);
  printf("    |                |\n");
  printf("    |   Root code    |\n");
  printf("    |                |\n");
  printf("    +----------------+ 0000\n\n");
  wait_for_key();

  printf("\n\nPhysical memory is layed out as follows:\n");
  printf("Root code ranges from 0000-%01XFFF.\n", x - 1);
  printf("Data is located at %06lX-%06lX\n", data_start, data_end);
  printf("Banked code is located at %06lX-%06lX\n\n", bank_start, bank_end);
  printf("It is perfectly ok if you do not fill out all this memory as\n");
  printf("long as it is enough to hold your application.\n");
  wait_for_key();

  printf("\n\n * * Information to put into your link file:\n");
  printf("-b(CODE)CODE=%06lX,%04X,%06lX\n", 
	 (bank_start - x * 0x1000L) * 0x10L + x * 0x1000L,
	 (y - x) * 0x1000, 
	 (long)((y - x) * 0x10000L));
  printf("-Z(DATA)DATA0,IDATA0,UDATA0,ECSTR,TEMP,CSTACK+200=%04X-FFFF\n",
	 y * 0x1000);
  printf("-Z(CODE)RCODE,CDATA0,CONST,CSTR,CCSTR=100-%04X\n",
	 x * 0x1000 - 1);
  printf("-DCBAR_value=%02X\n", cbar & 0xff);
  printf("-DCBR_value=%02X\n\n", cbr & 0xff);

  printf("If you use the INTVEC segment and interrupt mode 2, you may want\n");
  printf("to make some room by adjusting the RCODE segment above.\n");
  printf("You should also adjust the stack size (200) and insert your own\n");
  printf("segments\n");
  return 0;
}
