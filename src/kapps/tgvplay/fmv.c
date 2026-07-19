/*
 * AloneVid c16on FMV player (NedoOS).
 * Screen helpers + play loop; blit/decode/flip in tgv_hot.asm.
 */
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <graphic.h>
#include <tgvplay.h>

#define TGV_VRAM_LO   0x8000u
#define TGV_VRAM_HI   0xC000u
#define TGV_SCR_BYTES 0x4000u

#define FMV_SECTOR_SIZE 2048u
#define FMV_BATCH_SIZE 16384u
#define FMV_CHUNK_EOF 1
#define FMV_KEY_EVERY_SECS 32u
#define TGV_KEY_ESC 27u

/* Owned by tgv_hot.asm */
extern unsigned char g_front;
extern unsigned char g_scr0_low;
extern unsigned char g_scr0_high;
extern unsigned char g_scr1_low;
extern unsigned char g_scr1_high;
extern unsigned char fmv_mounted;

static unsigned char pg_main8000;
static unsigned char pg_mainc000;

unsigned char secstore[FMV_BATCH_SIZE];
unsigned int secbase;
unsigned int secpos;
unsigned char frame_open;

static unsigned int batch_pos;
static unsigned int batch_end;
static unsigned long stream_sec_idx;
static FILE *fmv_fp;
static unsigned char fmv_open;
static unsigned char user_abort;
static unsigned char key_countdown;
unsigned char tgv_fmv_no_halt;

static void map_pages(unsigned char lo, unsigned char hi)
{
	OS_SETPG8000(lo);
	SETPG32KHIGH(hi);
}

void tgv_set_main(void)
{
	map_pages(pg_main8000, pg_mainc000);
	fmv_mounted = 0;
}

void tgv_unmount_draw(void)
{
	if (!fmv_mounted)
		return;
	tgv_set_main();
}

static void clear_mapped_vram(void)
{
	memset((void *)TGV_VRAM_LO, 0, TGV_SCR_BYTES);
	memset((void *)TGV_VRAM_HI, 0, TGV_SCR_BYTES);
}

void tgv_gfx_init(void)
{
	union APP_PAGES mp;
	unsigned int s0;
	unsigned int s1;

	mp.l = OS_GETMAINPAGES();
	pg_main8000 = mp.pgs.window_2;
	pg_mainc000 = mp.pgs.window_3;

	s0 = OS_GETSCR0();
	s1 = OS_GETSCR1();
	g_scr0_low = (unsigned char)(s0 & 0xFFu);
	g_scr0_high = (unsigned char)((s0 >> 8) & 0xFFu);
	g_scr1_low = (unsigned char)(s1 & 0xFFu);
	g_scr1_high = (unsigned char)((s1 >> 8) & 0xFFu);

	g_front = 0u;
	fmv_mounted = 0u;
	tgv_flip_halt = 1u;

	tgv_capture_task_iy();
	tgv_blit_tables_init();
	tgv_set_main();

	OS_SETGFX(0x80u);
	OS_SETSCREEN(0u);

	map_pages(g_scr0_low, g_scr0_high);
	clear_mapped_vram();
	map_pages(g_scr1_low, g_scr1_high);
	clear_mapped_vram();

	OS_SETSCREEN(g_front);
	tgv_map_draw();
}

void tgv_text_mode(void)
{
	tgv_unmount_draw();
	tgv_set_main();
	OS_SETSCREEN(0u);
	OS_SETGFX(6u);
	OS_CLS(0);
	OS_SETCOLOR(7u);
	OS_HALT();
}

static int stream_load_sector(void)
{
	unsigned int n;
	unsigned int got;

	secpos = 0;
	if (batch_pos >= batch_end)
	{
		got = 0;
		while (got < FMV_BATCH_SIZE)
		{
			n = OS_READHANDLE(secstore + got, fmv_fp, FMV_BATCH_SIZE - got);
			if (n == 0u)
				break;
			got += n;
		}
		if (got < FMV_SECTOR_SIZE)
			return -1;
		batch_pos = 0;
		batch_end = got - (got % FMV_SECTOR_SIZE);
	}

	secbase = (unsigned int)(secstore + batch_pos);
	batch_pos = (unsigned int)(batch_pos + FMV_SECTOR_SIZE);
	stream_sec_idx++;
	return 0;
}

static void close_fmv(void)
{
	if (!fmv_open)
		return;
	OS_CLOSEHANDLE(fmv_fp);
	fmv_open = 0;
}

static void poll_esc(void)
{
	unsigned char k;

	if (key_countdown != 0u)
	{
		key_countdown--;
		return;
	}
	key_countdown = FMV_KEY_EVERY_SECS;
	k = (unsigned char)(OS_GETKEY() & 0xFFu);
	if (k == TGV_KEY_ESC)
		user_abort = 1u;
}

static int video_play(void)
{
	static int r;

	tgv_map_draw();
	key_countdown = 0u;

	for (;;)
	{
		poll_esc();
		if (user_abort)
			break;

		if (stream_load_sector() < 0)
			break;

		/* sectcycl=8: sectors 8,16,... = sound ? skip. */
		if ((stream_sec_idx & 7u) == 0u)
			continue;

		r = tgv_decode_sector();
		if (r == FMV_CHUNK_EOF)
		{
			tgv_map_draw();
			continue;
		}
		if (r < 0)
		{
			close_fmv();
			tgv_unmount_draw();
			return r;
		}
	}

	close_fmv();
	tgv_unmount_draw();
	return 0;
}

int tgv_fmv_play(const char *path)
{
	stream_sec_idx = 0;
	user_abort = 0;
	frame_open = 0;
	fmv_open = 0;
	batch_pos = 0;
	batch_end = 0;
	secbase = (unsigned int)secstore;
	key_countdown = 0u;

	if (path == 0 || path[0] == 0)
		return -1;

	fmv_fp = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((unsigned int)fmv_fp & 0xFFu) != 0u)
		return -2;
	fmv_open = 1;

	OS_SEEKHANDLE(fmv_fp, FMV_SECTOR_SIZE);
	stream_sec_idx = 0u;

	tgv_gfx_init();
	tgv_flip_halt = tgv_fmv_no_halt ? 0u : 1u;
	return video_play();
}

unsigned char tgv_fmv_aborted(void)
{
	return user_abort;
}
