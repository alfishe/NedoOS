#include "oscalls.h"

extern unsigned char os_covox_play_hx;
extern void *os_covox_play_data;
extern void *os_covox_play_pt;
extern void OS_PLAYCOVOX_PLAY_CORE(void);

void OS_PLAYCOVOX_PLAY(unsigned char hx, void *data, void *pagetable)
{
	os_covox_play_hx = hx;
	os_covox_play_data = data;
	os_covox_play_pt = pagetable;
	OS_PLAYCOVOX_PLAY_CORE();
}
