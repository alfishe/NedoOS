
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <terminal.c>
#define COMMANDLINE 0x0080

struct process
{
  unsigned char nomer;
  unsigned char name[32];
  unsigned char used;
  unsigned char window_0;
  unsigned char window_1;
  unsigned char window_2;
  unsigned char window_3;
} table[16];

int procnum, prccount;
unsigned char c1, c2, pgbak, freemem, sysmem, usedmem, curpos,oldcurpos;
unsigned char procname;


void redraw(void)
{
  BOX(12, 4, 54, 1, 41);
  AT(33, 4);
  ATRIB(33);
  puts("TASK MANAGER");
  BOX(15, 5, 40, prccount, 43);
  c2 = 1;
  for (c1 = 1; c1 < 16; c1++)
  {
    if  (table[c1].nomer != 0)
    {
      AT(12, 5 + c2 - 1);
      ATRIB(30);
      putdec(table[c1].nomer);
      putchar('.');
      puts(table[c1].name);


      AT(50, 5 + c2 - 1);
      printf("%u  ", table[c1].used);
      AT(55, 5 + c2 - 1);
      printf("%X.", table[c1].window_0);
      printf("%X.", table[c1].window_1);
      printf("%X.", table[c1].window_2);
      printf("%X",  table[c1].window_3);
      c2++;
    }
  }


  BOX(12, 4 + c2, 54, 1, 41);
  AT(14, 4 + c2);
  ATRIB(33);
  printf("  Free:%u pages     Used:%u pages  Sys:%u pages", freemem, usedmem, sysmem);

}


C_task main (int argc, char *argv[])
{
  unsigned char  loop = 1;
  curpos = 1;
  
  while (loop)
  {

    union APP_PAGES main_pg;


    os_initstdio();
    main_pg.l = OS_GETMAINPAGES();
    pgbak = main_pg.pgs.window_3;
    prccount = 0;
    for (c1 = 1; c1 < 16; c1++)
    {
      main_pg.l = OS_GETAPPMAINPAGES(c1);

      if (errno == 0)
      {
        table[c1].nomer    = c1;
        table[c1].used     = 0;
        table[c1].window_0 = main_pg.pgs.window_0;
        table[c1].window_1 = main_pg.pgs.window_1;
        table[c1].window_2 = main_pg.pgs.window_2;
        table[c1].window_3 = main_pg.pgs.window_3;
        SETPG32KHIGH(table[c1].window_0);
        memcpy(table[c1].name, (char*)(0xc000 + COMMANDLINE), 31);
        prccount++;
      }
      else
      {
        table[c1].nomer    = 0;
        table[c1].used     = 0;
        table[c1].window_0 = 0;
        table[c1].window_1 = 0;
        table[c1].window_2 = 0;
        table[c1].window_3 = 0;
        table[c1].name[0] = '\0';
      }
    }

    SETPG32KHIGH(pgbak);
	
    freemem = 0;
    sysmem  = 0;
    usedmem = 0;
    for ( c2 = 0; c2 < 255; c2++)
    {
      unsigned char owner;
      owner = OS_GETPAGEOWNER(c2);
      if (owner == 0)
      {
        freemem++;
      }
      else

        if (owner == 255)
        {
          sysmem++;
        }
        else
        {
          table[owner].used++;
          usedmem++;
        }
    }


    redraw();
    putchar('\r');
    putchar('\n');

    procname = getchar();

    if  (procname > '0' && procname < '9')
    {
      procnum = procname - '0';
      OS_DROPAPP (procnum);
      BOX(12, 4, 58, prccount + 2, 40);
    }
    else if (procname == '\e')
    {
      loop = 0;
    }

	if  (procname == 'q' || procname == 'Q') {oldcurpos = curpos; curpos--;}
	if  (procname == 'a' || procname == 'A`'){oldcurpos = curpos; curpos++;}
	if (curpos < 1) {curpos = prccount;}
	if (curpos > prccount) {curpos = 1;}
ATRIB(33);
BOX(12, 4 + curpos, 54, 1, 40);

c1 = curpos;

if ( table[c1].nomer != 0)
{
	  AT(12, 4 + curpos);
	  putdec(table[c1].nomer);
      putchar('.');
      puts(table[c1].name);
      AT(50, 4 + curpos);
      printf("%u  ", table[c1].used);
      AT(55, 4 + curpos);
      printf("%X.", table[c1].window_0);
      printf("%X.", table[c1].window_1);
      printf("%X.", table[c1].window_2);
      printf("%X",  table[c1].window_3);
      c2++;
}
c1++;

	
  }
  return 0;
}

