#ifndef TGVPLAY_H
#define TGVPLAY_H

void tgv_gfx_init(void);
void tgv_set_main(void);
void tgv_map_draw(void);
void tgv_unmount_draw(void);
void tgv_flip(void);
extern unsigned char tgv_flip_halt; /* 1=HALT after SETSCREEN, 0=skip */
void tgv_text_mode(void);

void tgv_blit_tables_init(void);
void tgv_capture_task_iy(void);
int tgv_decode_sector(void);

int tgv_fmv_play(const char *path);
/* Set before tgv_fmv_play: 1 = no HALT in flip. */
extern unsigned char tgv_fmv_no_halt;
unsigned char tgv_fmv_aborted(void);

#endif
