#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <../common/terminal.c>

#define COMMANDLINE 0x0080
#define TM_MAX_SLOT   16
#define TM_NAME_LEN   31

#define TM_LIST_X       11
#define TM_HEADER_Y     4
#define TM_LIST_Y       5
#define TM_COL_ID_X     11
#define TM_COL_ID_W     3
#define TM_COL_PROC_X   15
#define TM_COL_PROC_W   33
#define TM_COL_USED_X   49
#define TM_COL_USED_W   4
#define TM_HDR_USED_X   48
#define TM_COL_PAGES_X  54
#define TM_COL_PAGES_W  12
#define TM_ROW_COLOR    48
#define TM_SEL_COLOR    6
#define TM_KEY_FOCUS    31
#define TM_VIEW_LIST    0
#define TM_VIEW_MAP     1

#define TM_MAP_X        9
#define TM_MAP_TITLE_Y  1
#define TM_MAP_Y        3
#define TM_MAP_COLS     32
#define TM_MAP_ROWS     8
#define TM_MAP_LIST_Y   12
#define TM_LINE_X         1
#define TM_LINE_W         78
#define TM_MAP_COL1_X     TM_LINE_X
#define TM_MAP_COL1_W     38
#define TM_MAP_SEP_X      39
#define TM_MAP_COL2_X     41
#define TM_MAP_COL2_W     38
#define TM_MAP_NAME_MAX   12
#define TM_MAP_NAME_OFFS  3
#define TM_MAP_FOOTER_Y   23
#define TM_PROC_PG_MAX  64

#define TM_MAP_COLOR_FREE  0xE7
#define TM_MAP_COLOR_SYS   0xD7
#define TM_MAP_COLOR_USED_G 0x4C
#define TM_MAP_COLOR_USED_Y 0x4E
#define TM_MAP_LIST_COLOR  7
#define TM_MAP_LIST_NAME   0xC2

struct process
{
    unsigned char nomer;
    unsigned char nomer2;
    unsigned char name[TM_NAME_LEN + 1];
    unsigned char used;
    unsigned char window_0;
    unsigned char window_1;
    unsigned char window_2;
    unsigned char window_3;
} table[TM_MAX_SLOT];

static const unsigned char hex_digits[] = "0123456789ABCDEF";

unsigned char prccount;
unsigned char pgbak, freemem, sysmem, usedmem, curpos;
union APP_PAGES main_pg;

static unsigned char s_prev_count;
static unsigned char s_prev_curpos;
static unsigned char s_prev_free;
static unsigned char s_prev_used;
static unsigned char s_prev_sys;
static struct process s_prev[TM_MAX_SLOT];

static unsigned char g_view_mode;
static unsigned char g_page_owner[256];
static unsigned char g_proc_npages[TM_MAX_SLOT];
static unsigned char g_proc_pgs[TM_MAX_SLOT][TM_PROC_PG_MAX];
static unsigned char s_prev_owner[256];

static unsigned char tm_map_app_color(unsigned char owner)
{
    if (owner & 1)
    {
        return TM_MAP_COLOR_USED_G;
    }
    return TM_MAP_COLOR_USED_Y;
}

static void tm_put_hex2(unsigned char v)
{
    putchar(hex_digits[v >> 4]);
    putchar(hex_digits[v & 0x0F]);
}

static void tm_put_dec(unsigned char v)
{
    if (v >= 100)
    {
        putchar((char)('0' + v / 100));
        v = (unsigned char)(v % 100);
    }
    if (v >= 10)
    {
        putchar((char)('0' + v / 10));
        v = (unsigned char)(v % 10);
    }
    putchar((char)('0' + v));
}

static void tm_print_name(const unsigned char *name)
{
    unsigned char i;

    for (i = 0; i < TM_NAME_LEN && name[i] != 0; i++)
    {
        putchar((char)name[i]);
    }
}

static unsigned char tm_str_len(const char *s)
{
    unsigned char n;

    n = 0;
    while (s[n] != 0)
    {
        n++;
    }
    return n;
}

static void tm_puts_centered(unsigned char x, unsigned char y, unsigned char w, const char *s)
{
    unsigned char len;
    unsigned char pad;

    len = tm_str_len(s);
    if (len > w)
    {
        len = w;
    }
    pad = (unsigned char)((w - len) / 2);
    OS_SETXY((unsigned char)(x + pad), y);
    puts(s);
}

static void tm_draw_map_cell(unsigned char x, unsigned char y, unsigned char owner)
{
    OS_SETXY(x, y);
    if (owner == 0)
    {
        OS_SETCOLOR(TM_MAP_COLOR_FREE);
        putchar('[');
        putchar(']');
    }
    else if (owner == 255)
    {
        OS_SETCOLOR(TM_MAP_COLOR_SYS);
        putchar('[');
        putchar(']');
    }
    else
    {
        OS_SETCOLOR(tm_map_app_color(owner));
        tm_put_hex2(owner);
    }
}

static unsigned char tm_map_short_name_len(const unsigned char *name, unsigned char max_len)
{
    unsigned char i;

    for (i = 0; i < max_len && name[i] != 0 && name[i] != ' '; i++)
    {
    }
    return i;
}

static void tm_print_map_short_name(const unsigned char *name, unsigned char max_len)
{
    unsigned char i;

    for (i = 0; i < max_len && name[i] != 0 && name[i] != ' '; i++)
    {
        putchar((char)name[i]);
    }
}

static void draw_map_grid(void)
{
    unsigned char row;
    unsigned char col;
    unsigned char page;
    unsigned char x;
    unsigned char y;

    for (row = 0; row < TM_MAP_ROWS; row++)
    {
        y = (unsigned char)(TM_MAP_Y + row);
        for (col = 0; col < TM_MAP_COLS; col++)
        {
            page = (unsigned char)(row * TM_MAP_COLS + col);
            x = (unsigned char)(TM_MAP_X + col * 2);
            tm_draw_map_cell(x, y, g_page_owner[page]);
        }
    }
}

static void draw_chrome_map(void)
{
    BDBOX(11, TM_MAP_TITLE_Y, 55, 1, 0, ' ');
    OS_SETXY(33, TM_MAP_TITLE_Y);
    OS_SETCOLOR(TM_MAP_LIST_COLOR);
    puts("MEMORY MAP");
    BDBOX(11, 2, 55, 1, 0, ' ');
}

static unsigned char draw_map_proc_entry(unsigned char idx, unsigned char y, unsigned char col_x, unsigned char col_w)
{
    struct process *p;
    unsigned char i;
    unsigned char n;
    unsigned char x;
    unsigned char lines;
    unsigned char need;
    unsigned char name_len;

    if (idx >= prccount || y >= TM_MAP_FOOTER_Y)
    {
        return 0;
    }

    p = &table[idx];
    n = g_proc_npages[idx];
    lines = 1;
    name_len = tm_map_short_name_len(p->name, TM_MAP_NAME_MAX);
    OS_SETXY(col_x, y);
    OS_SETCOLOR(TM_MAP_LIST_COLOR);
    tm_put_hex2(p->nomer);
    putchar(' ');
    OS_SETCOLOR(TM_MAP_LIST_NAME);
    tm_print_map_short_name(p->name, TM_MAP_NAME_MAX);
    OS_SETCOLOR(TM_MAP_LIST_COLOR);
    putchar(':');
    putchar(' ');
    x = (unsigned char)(col_x + 2 + 1 + name_len + 2);

    for (i = 0; i < n; i++)
    {
        need = (unsigned char)((i > 0) ? 3 : 2);
        if ((unsigned char)(x + need) > (unsigned char)(col_x + col_w))
        {
            y++;
            lines++;
            if (y >= TM_MAP_FOOTER_Y)
            {
                OS_SETXY(col_x, (unsigned char)(y - 1));
                OS_SETCOLOR(TM_MAP_LIST_COLOR);
                puts("...");
                return lines;
            }
            x = (unsigned char)(col_x + TM_MAP_NAME_OFFS);
            OS_SETXY(x, y);
            OS_SETCOLOR(TM_MAP_LIST_COLOR);
        }
        else if (i > 0)
        {
            putchar(',');
            x++;
        }
        tm_put_hex2(g_proc_pgs[idx][i]);
        x = (unsigned char)(x + 2);
    }
    return lines;
}

static void draw_map_status(void)
{
    OS_SETXY(TM_LINE_X, TM_MAP_FOOTER_Y);
    OS_SETCOLOR(22);
    printf("Free:%u Used:%u Sys:%u  ", freemem, usedmem, sysmem);
    OS_SETCOLOR(TM_ROW_COLOR);
    puts("Esc=exit M=list");
}

static void draw_map_column_sep(void)
{
    unsigned char y;

    for (y = TM_MAP_LIST_Y; y < TM_MAP_FOOTER_Y; y++)
    {
        OS_SETXY(TM_MAP_SEP_X, y);
        OS_SETCOLOR(TM_MAP_LIST_COLOR);
        putchar('|');
        putchar(' ');
    }
}

static void draw_map_body_clear(void)
{
    BDBOX(TM_LINE_X, TM_MAP_Y, TM_LINE_W, (unsigned char)(TM_MAP_FOOTER_Y - TM_MAP_Y), 0, ' ');
}

static void draw_map_full(void)
{
    unsigned char i;
    unsigned char left_y;
    unsigned char right_y;
    unsigned char used;
    unsigned char skipped;
    unsigned char col_x;
    unsigned char col_w;
    unsigned char y;
    unsigned char *py;

    draw_map_body_clear();
    draw_map_grid();
    BDBOX(TM_LINE_X, (unsigned char)(TM_MAP_Y + TM_MAP_ROWS), TM_LINE_W, 1, 0, ' ');
    left_y = TM_MAP_LIST_Y;
    right_y = TM_MAP_LIST_Y;
    skipped = 0;
    for (i = 0; i < prccount; i++)
    {
        if (i & 1)
        {
            col_x = TM_MAP_COL2_X;
            col_w = TM_MAP_COL2_W;
            py = &right_y;
        }
        else
        {
            col_x = TM_MAP_COL1_X;
            col_w = TM_MAP_COL1_W;
            py = &left_y;
        }
        if (*py >= TM_MAP_FOOTER_Y)
        {
            skipped++;
            continue;
        }
        used = draw_map_proc_entry(i, *py, col_x, col_w);
        if (used == 0)
        {
            skipped++;
            continue;
        }
        *py = (unsigned char)(*py + used);
    }
    draw_map_column_sep();
    if (skipped > 0)
    {
        y = left_y;
        if (right_y > y)
        {
            y = right_y;
        }
        if (y < TM_MAP_FOOTER_Y)
        {
            OS_SETXY(TM_LINE_X, y);
            OS_SETCOLOR(TM_MAP_LIST_COLOR);
            printf("... +%u proc", (unsigned int)skipped);
        }
    }
    BDBOX(TM_LINE_X, TM_MAP_FOOTER_Y, TM_LINE_W, 1, 87, ' ');
    draw_map_status();
    BDBOX(TM_LINE_X, (unsigned char)(TM_MAP_FOOTER_Y + 1), TM_LINE_W, 2, 0, ' ');
}

static void draw_row_bg(unsigned char idx, unsigned char selected)
{
    unsigned char y;
    unsigned char color;

    y = (unsigned char)(TM_LIST_Y + idx);
    color = selected ? TM_SEL_COLOR : TM_ROW_COLOR;
    OS_SETCOLOR(color);
    BDBOX(TM_LIST_X, y, 55, 1, color, ' ');
}

static void draw_row(unsigned char idx, unsigned char selected)
{
    struct process *p;
    unsigned char y;
    unsigned char color;

    if (idx >= prccount)
    {
        return;
    }

    p = &table[idx];
    y = (unsigned char)(TM_LIST_Y + idx);
    color = selected ? TM_SEL_COLOR : TM_ROW_COLOR;

    draw_row_bg(idx, selected);

    OS_SETXY(TM_COL_ID_X, y);
    OS_SETCOLOR(color);
    tm_put_hex2(p->nomer);

    OS_SETXY(TM_COL_PROC_X, y);
    OS_SETCOLOR(color);
    tm_print_name(p->name);

    OS_SETXY(TM_COL_USED_X, y);
    OS_SETCOLOR(color);
    tm_put_dec(p->used);

    OS_SETXY(TM_COL_PAGES_X, y);
    OS_SETCOLOR(color);
    tm_put_hex2(p->window_0);
    putchar('.');
    tm_put_hex2(p->window_1);
    putchar('.');
    tm_put_hex2(p->window_2);
    putchar('.');
    tm_put_hex2(p->window_3);
}

static void draw_status(void)
{
    OS_SETXY(TM_LIST_X, (unsigned char)(TM_LIST_Y + prccount));
    OS_SETCOLOR(22);
    printf("    Free:%u pages     Used:%u pages  Sys:%u pages", freemem, usedmem, sysmem);
}

static void draw_footer(void)
{
    unsigned char y;

    y = (unsigned char)(TM_LIST_Y + prccount);
    BDBOX(TM_LIST_X, y, 55, 1, 87, ' ');
    draw_status();
    BDBOX(TM_LIST_X, (unsigned char)(y + 1), 55, 3, 0, ' ');
}

static void clear_stale_rows(unsigned char old_count)
{
    unsigned char y;

    if (old_count <= prccount || old_count >= 255)
    {
        return;
    }

    for (y = (unsigned char)(TM_LIST_Y + prccount); y < (unsigned char)(TM_LIST_Y + old_count); y++)
    {
        BDBOX(TM_LIST_X, y, 55, 1, TM_ROW_COLOR, ' ');
    }
}

static void clear_old_footer(unsigned char old_count)
{
    unsigned char y;

    if (old_count >= 255 || old_count <= prccount)
    {
        return;
    }

    y = (unsigned char)(TM_LIST_Y + old_count);
    BDBOX(TM_LIST_X, y, 55, 4, 0, ' ');
}

static void redraw_on_count_change(unsigned char old_count)
{
    unsigned char i;

    clear_stale_rows(old_count);

    if (prccount > 0)
    {
        BDBOX(TM_LIST_X, TM_LIST_Y, 55, prccount, TM_ROW_COLOR, ' ');
    }

    for (i = 0; i < prccount; i++)
    {
        draw_row(i, (unsigned char)(i == curpos - 1));
    }

    draw_footer();
    clear_old_footer(old_count);
}

static void draw_column_headers(void)
{
    BDBOX(TM_LIST_X, TM_HEADER_Y, 55, 1, TM_ROW_COLOR, ' ');
    OS_SETCOLOR(TM_ROW_COLOR);
    tm_puts_centered(TM_COL_ID_X, TM_HEADER_Y, TM_COL_ID_W, "id");
    tm_puts_centered(TM_COL_PROC_X, TM_HEADER_Y, TM_COL_PROC_W, "process");
    tm_puts_centered(TM_HDR_USED_X, TM_HEADER_Y, TM_COL_USED_W, "used");
    tm_puts_centered(TM_COL_PAGES_X, TM_HEADER_Y, TM_COL_PAGES_W, "main pages");
}

static void draw_chrome(void)
{
    BDBOX(11, 3, 55, 1, 87, ' ');
    OS_SETXY(32, 3);
    OS_SETCOLOR(87);
    puts("TASK MANAGER");
    draw_column_headers();
}

static unsigned char row_changed(unsigned char idx)
{
    return (unsigned char)(memcmp(&table[idx], &s_prev[idx], sizeof(struct process)) != 0);
}

static void snapshot_table(void)
{
    unsigned char i;

    s_prev_count = prccount;
    s_prev_curpos = curpos;
    s_prev_free = freemem;
    s_prev_used = usedmem;
    s_prev_sys = sysmem;
    for (i = 0; i < prccount; i++)
    {
        s_prev[i] = table[i];
    }
}

static void redraw(void)
{
    unsigned char i;
    unsigned char count_changed;
    unsigned char stats_changed;

    if (g_view_mode == TM_VIEW_MAP)
    {
        if (memcmp(g_page_owner, s_prev_owner, 256) != 0 ||
            freemem != s_prev_free || usedmem != s_prev_used || sysmem != s_prev_sys ||
            prccount != s_prev_count)
        {
            draw_map_full();
            memcpy(s_prev_owner, g_page_owner, 256);
            s_prev_free = freemem;
            s_prev_used = usedmem;
            s_prev_sys = sysmem;
            s_prev_count = prccount;
        }
        return;
    }

    count_changed = (unsigned char)(prccount != s_prev_count);
    stats_changed = (unsigned char)(freemem != s_prev_free || usedmem != s_prev_used || sysmem != s_prev_sys);

    if (count_changed)
    {
        redraw_on_count_change(s_prev_count);
        snapshot_table();
        return;
    }

    if (curpos != s_prev_curpos)
    {
        if (s_prev_curpos >= 1 && s_prev_curpos <= s_prev_count)
        {
            draw_row((unsigned char)(s_prev_curpos - 1), 0);
        }
        if (curpos >= 1 && curpos <= prccount)
        {
            draw_row((unsigned char)(curpos - 1), 1);
        }
    }

    for (i = 0; i < prccount; i++)
    {
        if (row_changed(i))
        {
            draw_row(i, (unsigned char)(i == curpos - 1));
        }
    }

    if (stats_changed)
    {
        draw_status();
    }

    snapshot_table();
}

static void redraw_full(void)
{
    unsigned char old_count;

    old_count = s_prev_count;
    if (old_count >= 255)
    {
        old_count = prccount;
    }
    redraw_on_count_change(old_count);
    snapshot_table();
}

static void tm_switch_view(unsigned char view)
{
    g_view_mode = view;
    if (g_view_mode == TM_VIEW_MAP)
    {
        draw_chrome_map();
        draw_map_full();
        memcpy(s_prev_owner, g_page_owner, 256);
        s_prev_count = prccount;
        s_prev_free = freemem;
        s_prev_used = usedmem;
        s_prev_sys = sysmem;
    }
    else
    {
        OS_CLS(0);
        YIELD();
        s_prev_count = 255;
        s_prev_curpos = 255;
        draw_chrome();
        redraw_full();
    }
}

void filltable(void)
{
    unsigned char slot;
    unsigned char row;
    unsigned int page;

    main_pg.l = OS_GETMAINPAGES();
    pgbak = main_pg.pgs.window_3;
    prccount = 0;

    for (slot = 0; slot < TM_MAX_SLOT; slot++)
    {
        table[slot].nomer2 = 0;
    }

    for (slot = 0; slot < TM_MAX_SLOT; slot++)
    {
        main_pg.l = OS_GETAPPMAINPAGES((unsigned char)(slot + 1));

        if (errno == 0)
        {
            row = prccount;
            table[row].nomer = (unsigned char)(slot + 1);
            table[slot].nomer2 = row;
            table[row].window_0 = main_pg.pgs.window_0;
            table[row].window_1 = main_pg.pgs.window_1;
            table[row].window_2 = main_pg.pgs.window_2;
            table[row].window_3 = main_pg.pgs.window_3;
            table[row].used = 0;

            /* BDOS restores caller mapping on return ? remap main page (window_0). */
            SETPG32KHIGH(main_pg.pgs.window_0);
            memcpy(table[row].name, (char *)(0xC000 + COMMANDLINE), TM_NAME_LEN);
            table[row].name[TM_NAME_LEN] = 0;
            prccount++;
        }
    }

    SETPG32KHIGH(pgbak);

    freemem = 0;
    sysmem = 0;
    usedmem = 0;

    for (row = 0; row < TM_MAX_SLOT; row++)
    {
        g_proc_npages[row] = 0;
    }

    for (page = 0; page < 256; page++)
    {
        unsigned char owner;
        unsigned char row_idx;

        owner = OS_GETPAGEOWNER((unsigned char)page);
        g_page_owner[page] = owner;
        if (owner == 0)
        {
            freemem++;
        }
        else if (owner == 255)
        {
            sysmem++;
        }
        else
        {
            usedmem++;
            if (owner >= 1 && owner <= TM_MAX_SLOT)
            {
                row_idx = table[owner - 1].nomer2;
                if (row_idx < prccount)
                {
                    table[row_idx].used++;
                    if (g_proc_npages[row_idx] < TM_PROC_PG_MAX)
                    {
                        g_proc_pgs[row_idx][g_proc_npages[row_idx]] = (unsigned char)page;
                        g_proc_npages[row_idx]++;
                    }
                }
            }
        }
    }
}

static unsigned char wait_for_input(void)
{
    unsigned long oldTime;
    unsigned char procname;

    oldTime = time();
    for (;;)
    {
        filltable();
        redraw();

        if (time() - oldTime > 100)
        {
            return 0;
        }

        procname = (unsigned char)OS_GETKEY();
        if (procname == TM_KEY_FOCUS)
        {
            filltable();
            if (prccount == 0)
            {
                curpos = 0;
            }
            else if (curpos < 1 || curpos > prccount)
            {
                curpos = 1;
            }
            if (g_view_mode == TM_VIEW_MAP)
            {
                draw_chrome_map();
                draw_map_full();
            }
            else
            {
                redraw_full();
            }
            continue;
        }
        if (procname != 0)
        {
            return procname;
        }

        YIELD();
    }
}

C_task main(void)
{
    unsigned char procname;

    OS_HIDEFROMPARENT();
    OS_SETGFX(0x86);
    OS_CLS(0);
    YIELD();

    curpos = 1;
    g_view_mode = TM_VIEW_LIST;
    s_prev_count = 255;
    s_prev_curpos = 255;

    draw_chrome();
    filltable();
    redraw();

    while (42)
    {
        procname = wait_for_input();

        if (procname == 0)
        {
            continue;
        }

        if (procname == 27)
        {
            break;
        }
        else if (procname == TM_KEY_FOCUS)
        {
            filltable();
            if (prccount == 0)
            {
                curpos = 0;
            }
            else if (curpos < 1 || curpos > prccount)
            {
                curpos = 1;
            }
            if (g_view_mode == TM_VIEW_MAP)
            {
                draw_chrome_map();
                draw_map_full();
            }
            else
            {
                redraw_full();
            }
        }
        else if (procname == 'M' || procname == 'm')
        {
            tm_switch_view((unsigned char)(1 - g_view_mode));
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
            OS_DROPAPP((unsigned char)(procname - '0'));
        }
        else if (procname > '@' && procname < 'G')
        {
            OS_DROPAPP((unsigned char)(procname - 55));
        }
        else if (procname > 96 && procname < 'g')
        {
            OS_DROPAPP((unsigned char)(procname - 87));
        }
        else if (procname == 13 || procname == 252)
        {
            if (curpos >= 1 && curpos <= prccount)
            {
                OS_DROPAPP(table[curpos - 1].nomer);
            }
        }

        if (prccount == 0)
        {
            curpos = 0;
        }
        else if (curpos < 1 || curpos > prccount)
        {
            curpos = 1;
        }
    }

    OS_CLS(0);
    OS_SETCOLOR(7);
    return 0;
}
