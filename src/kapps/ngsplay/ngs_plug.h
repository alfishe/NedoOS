#ifndef NGS_PLUG_H
#define NGS_PLUG_H

#include <oscalls.h>
#include "app_bank.h"
#include "ngsplay.h"

#define NGS_BANK_SLOT_RESIDENT 0u
#define NGS_BANK_SLOT_LIST0    1u
#define NGS_BANK_SLOT_LIST1    2u

#define NGS_NAME_LEN 64
#define NGS_FENT_DIR 0x01u

/* 69 bytes; 16384/69 = 237 per page; 2 pages => 474 */
typedef struct
{
	unsigned char name[NGS_NAME_LEN];
	unsigned long size;
	unsigned char flags;
} ngs_fent;

#define NGS_FENT_SIZE ((unsigned int)sizeof(ngs_fent))
#define NGS_ENT_PER_PAGE (BANK_PAGE_SIZE / NGS_FENT_SIZE)
#define NGS_LIST_PAGES 2u
#define NGS_MAX_ENTRIES (NGS_ENT_PER_PAGE * NGS_LIST_PAGES)

struct coordinates
{
	unsigned char winX;
	unsigned char winY;
	unsigned char winW;
	unsigned char winH;
	unsigned char color;
};

#define COL_LIST 103
#define COL_CURSOR 188
#define COL_STAT 223 /* title / hint / status window (magenta) */
#define COL_BTN 79   /* control buttons: bright white on blue */
/* Each button 5x3; 2x2 grid with 1-col gap => 11 wide, 6 tall. */
#define BTN_W 5u
#define BTN_H 3u
#define BTN_GAP 1u
#define BTN_PANEL_W (BTN_W + BTN_GAP + BTN_W)

extern unsigned char residentPg;
extern unsigned char list_pg[NGS_LIST_PAGES];
extern union APP_PAGES main_pg;

extern struct coordinates winPos;
extern struct coordinates statPos;
extern struct coordinates btnPos;
extern unsigned int entry_count;
extern unsigned int ui_selected;
extern unsigned int ui_scroll;
extern unsigned char is_playing;
extern unsigned char is_paused;
extern unsigned char is_loading;
extern ngs_mod_info mod;
extern unsigned char cur_file[NGS_NAME_LEN];
extern unsigned char path_buf[80];
extern unsigned char load_pct;
extern unsigned char bar_filled;
extern unsigned char bar_inited;
extern unsigned int shown_time_sec;
extern long play_start_tick;

void ngs_init_banks(void);
void ui_resident_map(void);

/* CODE_RESIDENT @ C000 ? call only while residentPg is mapped. */
void r_spaces(unsigned char n);
void r_print_static(const char *s);
void r_put_clipped(const unsigned char *s, unsigned char maxn);
void r_restore_right_border_row(struct coordinates win, unsigned char row);
void r_clear_window_bg(struct coordinates win);
void r_draw_player_frame(struct coordinates win);
void r_draw_title_bar(void);
void r_draw_hint_bar(void);
void r_clear_status_line(unsigned char row);
unsigned char r_status_bar_w(void);
void r_progress_bar_reset(void);
void r_progress_bar_grow(unsigned char pct);
void r_draw_status_meta(void);
void r_draw_status_bottom(void);
void r_draw_status(void);
void r_draw_static_chrome(void);

/* Main wrappers: map resident, call, leave resident mapped (idle rule). */
void ui_draw_static_chrome(void);
void ui_draw_title_bar(void);
void ui_draw_status(void);
void ui_draw_status_meta(void);
void ui_draw_status_bottom(void);
void ui_progress_bar_reset(void);
void ui_progress_bar_grow(unsigned char pct);
void ui_draw_stat_buttons(void);

#endif
