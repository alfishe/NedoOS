#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <../common/terminal.c>

#define COMMANDLINE 0x0080
#define true 1
#define false 0

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

struct window
{
    unsigned char x;
    unsigned char y;
    unsigned char w;
    unsigned char h;
    unsigned char text;
    unsigned char back;
    unsigned char tittle[80];
} curWin;

int procnum, prccount;
unsigned char c1, c2, pgbak, freemem, sysmem, usedmem, curpos;
unsigned char procname;
union APP_PAGES main_pg;

void redraw(void)
{
    unsigned char c3;

    BDBOX(13, 4, 41, prccount, 119, ' ');

    OS_SETCOLOR(48);

    for (c3 = 0; c3 < prccount; c3++)
    {
        OS_SETXY(11, 4 + c3);
        if (c3 == curpos - 1)
        {
            OS_SETCOLOR(6);
            printf("%2X.%s", table[c3].nomer, table[c3].name);
            OS_SETXY(49, 4 + c3);
            printf("%u  ", table[c3].used);
            OS_SETXY(54, 4 + c3);
            printf("%2X.%2X.%2X.%2X ", table[c3].window_0, table[c3].window_1, table[c3].window_2, table[c3].window_3);
            OS_SETXY(11, 4 + c3);
            OS_SETCOLOR(48);
        }
        else
        {
            printf("%2X.%s", table[c3].nomer, table[c3].name);
            OS_SETXY(49, 4 + c3);
            printf("%u  ", table[c3].used);
            OS_SETXY(54, 4 + c3);
            printf("%2X.%2X.%2X.%2X ", table[c3].window_0, table[c3].window_1, table[c3].window_2, table[c3].window_3);
        }
    }

    BDBOX(11, 4 + prccount, 55, 1, 87, ' ');
    OS_SETXY(11, 4 + prccount);
    OS_SETCOLOR(22);
    printf("    Free:%u pages     Used:%u pages  Sys:%u pages", freemem, usedmem, sysmem);

    BDBOX(11, 5 + prccount, 55, 3, 0, ' ');
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
    OS_HIDEFROMPARENT();
    OS_SETGFX(0x86);
    OS_CLS(0);
    YIELD();
    curpos = 1;
    BDBOX(11, 3, 55, 1, 87, ' ');
    OS_SETXY(32, 3);
    OS_SETCOLOR(87);
    puts("TASK MANAGER");
    filltable();
    redraw();

    while (42)
    {
        filltable();
        redraw();
        do
        {
            procname = OS_GETKEY();
            if (procname == 0)
                YIELD();
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
    OS_CLS(0);
    OS_SETCOLOR(7);
    return 0;
}
