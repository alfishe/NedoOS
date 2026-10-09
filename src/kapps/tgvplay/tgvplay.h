#ifndef TGVPLAY_H
#define TGVPLAY_H

void tgv_gfx_init(void);
void tgv_set_main(void);
void tgv_map_draw(void);
void tgv_unmount_draw(void);
void tgv_flip(void);
extern unsigned char tgv_flip_halt; /* 1=HALT after SETSCREEN, 0=skip */
extern unsigned char tgv_qmode;
void tgv_qwait_flush(void);
void tgv_int_hook(void);
void tgv_int_unhook(void);
void tgv_text_mode(void);

void tgv_blit_tables_init(void);
void tgv_capture_task_iy(void);
int tgv_decode_sector(void);

int tgv_fmv_play(const char *path);
/* One gfx/GS init for a chain of clips. Later plays keep the last frame
   (no black clear / SETGFX). */
void tgv_session_begin(void);
void tgv_session_end(void);
/* Set to 1 before tgv_fmv_play: next file is the next part of the same
   stream (keep palette and frame/sound counters). Cleared after open. */
extern unsigned char tgv_fmv_stream;
/* Called once per sector from the play loop, never from the blit. */
extern void (*tgv_on_sector)(void);
extern unsigned char tgv_ev_on;
extern unsigned char tgv_ev_hit;
extern unsigned char tgv_ev_fail;
extern unsigned char tgv_ev_key;
extern unsigned int tgv_ev_open;
extern unsigned int tgv_ev_close;
void tgv_ay_init(void);
void tgv_bibik_ask(void);
void tgv_bibik_good(void);
void tgv_bibik_bad(void);
/* 1..5 while the choice marker is drawn. Same codes in tgv_cover erase it. */
extern unsigned char tgv_hint;
extern unsigned char tgv_cover;
extern unsigned char tgv_cover_ttl;
void tgv_mark_paint(void);
extern unsigned char tgv_time_on;
extern unsigned char tgv_time_n;
extern const char *tgv_time_msg;
/* Choice window in frame numbers. The flip polls a key only inside it. */
void tgv_ev_arm(unsigned int open_frame, unsigned int close_frame, unsigned char key);
void tgv_ev_disarm(void);
/* One more key read after the window. The last frame stays up while the next sound block loads. */
void tgv_ev_last(void);
unsigned char tgv_ev_failed(void);
unsigned char gs_pcm_init(void);
void gs_pcm_play(unsigned char *src, unsigned int len);
void gs_pcm_stop(void);
/* Set before tgv_fmv_play: 1 = no HALT in flip. */
extern unsigned char tgv_fmv_no_halt;
/* 1 = any key ends this clip and the caller continues. 0 = only Esc aborts. */
extern unsigned char tgv_key_skip;
unsigned char tgv_fmv_aborted(void);
extern unsigned int tgv_frm_n;
extern unsigned int tgv_snd_n;

/* 32-byte DDp palette. The kernel puts it on screen at the next frame. */
void tgv_setpal(const unsigned char *pal);
/* Same 32 bytes, from the task that currently has the screen. */
void tgv_getpal(unsigned char *pal);
/* Both EGA screens. File: le16 rle length, 32-byte palette, then RLE.
   Four banks of 8000 bytes, column order 80/C0/A0/E0, pair-packed pixels.
   0 = shown, -1 = the file is missing or short. */
int tgv_show_still(const char *path);

#endif
