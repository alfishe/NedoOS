#include <stdio.h>
int putchar(int outchar)
{
  unsigned char *LCD_IO;
  LCD_IO= (unsigned char *) 0x8000;
  * LCD_IO=outchar;
  return(outchar);
}
