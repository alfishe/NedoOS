#include <oscalls.h>
#include "winmem.h"

static unsigned char win_pg0;
static unsigned char win_pg1;
static unsigned char win_saved0;
static unsigned char win_saved1;
static unsigned char win_active;

int win_alloc(void)
{
	unsigned int r;
	union APP_PAGES pages;

	pages.l = OS_GETMAINPAGES();
	win_saved0 = pages.pgs.window_2;
	win_saved1 = pages.pgs.window_3;

	r = OS_NEWPAGE();
	if ((unsigned char)(r >> 8) != 0)
		return -1;
	win_pg0 = (unsigned char)r;

	r = OS_NEWPAGE();
	if ((unsigned char)(r >> 8) != 0)
	{
		OS_DELPAGE((char)win_pg0);
		return -1;
	}
	win_pg1 = (unsigned char)r;

	OS_SETPG8000(win_pg0);
	OS_SETPGC000(win_pg1);
	win_active = 1;
	return 0;
}

void win_free(void)
{
	if (!win_active)
		return;
	OS_SETPG8000(win_saved0);
	OS_SETPGC000(win_saved1);
	OS_DELPAGE((char)win_pg0);
	OS_DELPAGE((char)win_pg1);
	win_active = 0;
}
