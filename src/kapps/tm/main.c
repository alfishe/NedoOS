
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
    unsigned char nomer2;
    unsigned char name[32];
    unsigned char used;
    unsigned char window_0;
    unsigned char window_1;
    unsigned char window_2;
    unsigned char window_3;
} table[17];

int procnum, prccount;
unsigned char c1, c2, pgbak, freemem, sysmem, usedmem, curpos;
unsigned char procname;
union APP_PAGES main_pg;

void redraw(void)
{
    unsigned char c3;

    BOX(14, 5, 41, prccount, 43);

    for (c3 = 0; c3 < prccount; c3++)
    {
        AT(12, 5 + c3);
        ATRIB(30);
        if (c3 == curpos - 1)
        {
            ATRIB(31);
        }

        printf("%2X.", table[c3].nomer);
        puts(table[c3].name);
        AT(50, 5 + c3);
        printf("%u  ", table[c3].used);
        
        AT(55, 5 + c3);
        printf("%2X.", table[c3].window_0);
        printf("%2X.", table[c3].window_1);
        printf("%2X.", table[c3].window_2);
        printf("%2X", table[c3].window_3);
        
    }
    BOX(12, 5 + prccount, 54, 1, 41);
    AT(12, 5 + prccount);
    ATRIB(33);
    printf("    Free:%u pages     Used:%u pages  Sys:%u pages", freemem, usedmem, sysmem);
    BOX(12, 6 + prccount, 54, 2, 40);
}
void filltable(void)
{
    unsigned char c3, c4;
    main_pg.l = OS_GETMAINPAGES();
    pgbak = main_pg.pgs.window_3;
    prccount = 0;
    for (c3 = 0; c3 < 16; c3++)
    {
        c4 = c3 + 1;
        main_pg.l = OS_GETAPPMAINPAGES(c4);

        if (errno == 0)
        {

            table[prccount].nomer = c4;
            table[c3].nomer2 = prccount;
            table[prccount].window_0 = main_pg.pgs.window_0;
            table[prccount].window_1 = main_pg.pgs.window_1;
            table[prccount].window_2 = main_pg.pgs.window_2;
            table[prccount].window_3 = main_pg.pgs.window_3;
            SETPG32KHIGH(table[prccount].window_0);
            memcpy(table[prccount].name, (char *)(0xc000 + COMMANDLINE), 31);
            prccount++;
        }
        else
        {
            table[c3].nomer2 = 0;
        }
        table[c3].used = 0;
    }

    SETPG32KHIGH(pgbak);

    freemem = 0;
    sysmem = 0;
    usedmem = 0;
    for (c2 = 0; c2 < 255; c2++)
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
            table[table[owner - 1].nomer2].used++;
            usedmem++;
        }
    }
}

C_task main(void)
{
    curpos = 1;
    os_initstdio();
    BOX(1, 1, 80, 25, 40);
    BOX(12, 4, 54, 1, 41);
    AT(33, 4);
    ATRIB(33);
    puts("TASK MANAGER");
    while (42)
    {
        filltable();
        redraw();
        do
        {
            procname = _low_level_get();
        } while (procname == 0);

        if (procname == 27)
        {
            break;
        }
        else if (procname == 250)
        {
            curpos--;
            if (curpos < 1)
            {
                curpos = prccount;
            }
        }
        else if (procname == 249)
        {
            curpos++;
            if (curpos > prccount)
            {
                curpos = 1;
            }
        }
        else if (procname > '0' && procname < 58)
        {
            OS_DROPAPP(procname - '0');
        }
        else if (procname > '@' && procname < 'G')
        {
            OS_DROPAPP(procname - 55);
        }
        else if (procname > 96 && procname < 'g')
        {
            OS_DROPAPP(procname - 87);
        }
        else if (procname == 13 || procname == 252)
        {
            OS_DROPAPP(table[curpos - 1].nomer);
        }
    }
    BOX(1, 1, 80, 25, 40);
    AT(1, 1);
    ATRIB(47);
    return 0;
}
