/* More uses of variables */
int staticint;
char staticchar;
const char conschar='a';
const int consint=3;
char * cstring="constant";
const char constrin[]="rom";
no_init int noinitv;
unsigned char carr[0x100];
struct
{
  short a:2;
  short :1; /* gap in bitfield */
  short b:1;
} bf;

unsigned char * intram_0 = (unsigned char *) 0x100;
unsigned char * intram_1 = (unsigned char *) 0x110;
char m_ram[]={ "Place your message here" };
const char m_rom[]={ "Fixed text" };

void main(void)
{
  char localint=1;
  char localchar='c';
  bf.a=1; /* set two bits of bf to 01 */
  * intram_0 = 0x80;
  strcpy(m_ram,m_rom);
}
