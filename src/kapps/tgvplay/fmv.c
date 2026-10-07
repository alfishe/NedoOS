/*
 * AloneVid c16on FMV player (NedoOS).
 * Screen helpers + play loop; blit/decode/flip in tgv_hot.asm.
 */
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <graphic.h>
#include <intrz80.h>
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
unsigned char tgv_pace_on;
unsigned char tgv_pace_ticks;
unsigned int tgv_pace_num;
unsigned int tgv_pace_den;
extern unsigned int tgv_frm_n;
unsigned int tgv_snd_n;
extern unsigned int tgv_irq_n;
extern unsigned int tgv_irq_seen;
extern unsigned int tgv_pace_acc;

static unsigned int batch_pos;
static unsigned int batch_end;
static unsigned long stream_sec_idx;
static FILE *fmv_fp;
static unsigned char fmv_open;
unsigned char user_abort;
static unsigned char key_countdown;
static unsigned char seen_snd;
static unsigned char session;

unsigned char tgv_ev_on;
unsigned char tgv_ev_key;
unsigned char tgv_ev_hit;
unsigned char tgv_ev_fail;
unsigned int tgv_ev_open;
unsigned int tgv_ev_close;
void (*tgv_on_sector)(void);
static unsigned char pace_locked;
static unsigned int frm_mark;
static unsigned int blk_n;
static unsigned int frm_sum;
unsigned char tgv_fmv_no_halt;
unsigned char tgv_key_skip;
unsigned char tgv_hint;
unsigned char tgv_cover;
unsigned char tgv_cover_ttl;
static unsigned char clip_skip;

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

	g_front = 0u;
	fmv_mounted = 0u;
	tgv_flip_halt = 1u;

	tgv_capture_task_iy();
	tgv_blit_tables_init();
	tgv_set_main();

	/* SETGFX publishes user_scr*. tgvplay gets them from the text mode
	   it enters first. Reading earlier returns the killable page, and
	   the blit never reaches the screen that is actually shown. */
	OS_SETGFX(0x80u);
	OS_SETSCREEN(0u);

	s0 = OS_GETSCR0();
	s1 = OS_GETSCR1();
	g_scr0_low = (unsigned char)(s0 & 0xFFu);
	g_scr0_high = (unsigned char)((s0 >> 8) & 0xFFu);
	g_scr1_low = (unsigned char)(s1 & 0xFFu);
	g_scr1_high = (unsigned char)((s1 >> 8) & 0xFFu);

	map_pages(g_scr0_low, g_scr0_high);
	clear_mapped_vram();
	map_pages(g_scr1_low, g_scr1_high);
	clear_mapped_vram();

	OS_SETSCREEN(g_front);
	tgv_map_draw();
	tgv_int_hook();
}

void tgv_session_begin(void)
{
	/* GS once for the whole game. Graphics mode is set in tgv_fmv_play
	   after the file is open: an open before SETGFX leaves a black screen. */
	gs_pcm_init();
	tgv_ay_init();
	session = 1u;
	tgv_ev_on = 0u;
	tgv_ev_fail = 0u;
	tgv_ev_hit = 0u;
}

void tgv_session_end(void)
{
	session = 0u;
	tgv_ev_on = 0u;
	tgv_on_sector = 0;
	tgv_text_mode();
}

void tgv_ev_arm(unsigned int open_frame, unsigned int close_frame, unsigned char key)
{
	tgv_ev_open = open_frame;
	tgv_ev_close = close_frame;
	tgv_ev_key = key;
	tgv_ev_hit = 0u;
	tgv_ev_fail = 0u;
	tgv_ev_on = 1u;
}

void tgv_ev_disarm(void)
{
	tgv_ev_on = 0u;
}

unsigned char tgv_ev_failed(void)
{
	return tgv_ev_fail;
}

/* AY channel B with the envelope, same registers as the original bibik.
   GS keeps the movie sound; this is only the "press now" beep. */
static void ay_out(unsigned char reg, unsigned char val)
{
	output(0xFFFDu, reg);
	output(0xBFFDu, val);
}

void tgv_ay_init(void)
{
	unsigned char r;

	for (r = 0u; r < 14u; r++)
		ay_out(r, 0u);
	ay_out(7u, 0xFDu);
	ay_out(9u, 0x10u);
}

static void bibik(unsigned char env, unsigned int tone)
{
	ay_out(12u, env);
	ay_out(11u, 0u);
	ay_out(2u, (unsigned char)tone);
	ay_out(3u, (unsigned char)(tone >> 8));
	ay_out(13u, 1u);
}

void tgv_bibik_ask(void)
{
	bibik(10u, 200u);
}

void tgv_bibik_good(void)
{
	bibik(7u, 50u);
}

void tgv_bibik_bad(void)
{
	bibik(15u, 800u);
}

/* Gray is a black/white checker, so it stays gray in any palette.
   Directions are squares. Fire is a circle on the bottom. */
static void plane_put(unsigned char col, unsigned int y, unsigned char bits)
{
	unsigned char p;
	unsigned int off;
	unsigned int hi;
	static const unsigned char plane_hi[4] = { 0x80, 0xC0, 0xA0, 0xE0 };

	off = (unsigned int)(y * 40u + col);
	for (p = 0u; p < 4u; p++)
	{
		hi = plane_hi[p];
		hi = (unsigned int)(hi << 8);
		*((unsigned char *)(hi + off)) = bits;
	}
}

static void paint_gray(unsigned char col, unsigned int y, unsigned char rows,
	const unsigned char *mask)
{
	unsigned char r;
	unsigned char bits;
	unsigned char gray;

	for (r = 0u; r < rows; r++)
	{
		gray = (r & 1u) ? 0x55u : 0xAAu;
		bits = mask ? (unsigned char)(mask[r] & gray) : gray;
		plane_put(col, (unsigned int)(y + r), bits);
		bits = mask ? (unsigned char)(mask[r + rows] & gray) : gray;
		plane_put((unsigned char)(col + 1u), (unsigned int)(y + r), bits);
	}
}

static void paint_black(unsigned char col, unsigned int y, unsigned char rows)
{
	unsigned char r;

	for (r = 0u; r < rows; r++)
	{
		plane_put(col, (unsigned int)(y + r), 0u);
		plane_put((unsigned char)(col + 1u), (unsigned int)(y + r), 0u);
	}
}

/* 16x16 disc, left column then right column. */
static const unsigned char fire_disc[32] = {
	0x07, 0x1F, 0x3F, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0x7F, 0x3F, 0x1F, 0x07,
	0xE0, 0xF8, 0xFC, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0xFC, 0xF8, 0xE0
};

static void mark_at(unsigned char id, unsigned char erase)
{
	unsigned char col;
	unsigned int y;
	unsigned char rows;

	col = 18u;
	y = 176u;
	rows = 16u;
	if (id == 1u) { col = 4u; y = 80u; }
	else if (id == 2u) { col = 34u; y = 80u; }
	else if (id == 3u) { col = 18u; y = 0u; }
	else if (id == 5u) { col = 31u; y = 176u; }
	if (erase)
		paint_black(col, y, rows);
	else if (id == 5u)
		paint_gray(col, y, rows, fire_disc);
	else
		paint_gray(col, y, rows, 0);
}

void tgv_mark_paint(void)
{
	if (tgv_hint != 0u)
		mark_at(tgv_hint, 0u);
	else if (tgv_cover != 0u)
	{
		mark_at(tgv_cover, 1u);
		if (tgv_cover_ttl != 0u)
		{
			tgv_cover_ttl--;
			if (tgv_cover_ttl == 0u)
				tgv_cover = 0u;
		}
	}
}

void tgv_text_mode(void)
{
	gs_pcm_stop();
	tgv_int_unhook();
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
		/* Queue holds pointers into secstore. Drain before the refill. */
		if (tgv_qmode)
			tgv_qwait_flush();
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

	/* The choice window reads the key itself. A second read here
	   would swallow the press. */
	if (tgv_ev_on != 0u)
		return;
	/* Intro skip looks at every sector, so a short tap is not missed.
	   Esc during a level stays on the slow poll. */
	if (tgv_key_skip == 0u)
	{
		if (key_countdown != 0u)
		{
			key_countdown--;
			return;
		}
		key_countdown = FMV_KEY_EVERY_SECS;
	}
	k = (unsigned char)(OS_GETKEY() & 0xFFu);
	if (k == 0u)
		return;
	if (tgv_key_skip != 0u)
		clip_skip = 1u;
	else if (k == TGV_KEY_ESC)
		user_abort = 1u;
}

static int video_play(void)
{
	static int r;

	tgv_map_draw();
	key_countdown = 0u;

	for (;;)
	{
		if (tgv_on_sector)
			tgv_on_sector();
		if (tgv_ev_fail)
			break;
		poll_esc();
		if (user_abort || clip_skip)
			break;

		if (stream_load_sector() < 0)
		{
			close_fmv();
			tgv_unmount_draw();
			/* A finished movie has already shown frames. Zero frames
			   means the read failed before any picture. */
			if (tgv_frm_n == 0u && !clip_skip)
				return -3;
			return 0;
		}

		/* sectcycl=8: 2048 samples at 17500 Hz, then video frames. */
		if ((stream_sec_idx & 7u) == 0u)
		{
			if (seen_snd)
			{
				unsigned int d;

				d = (unsigned int)(tgv_frm_n - frm_mark);
				frm_sum = (unsigned int)(frm_sum + d);
				blk_n++;
				if (!pace_locked && blk_n >= 4u && frm_sum != 0u)
					pace_locked = 1u;
			}
			seen_snd = 1u;
			frm_mark = tgv_frm_n;
			tgv_snd_n = (unsigned int)((stream_sec_idx - 1ul) >> 3);
			gs_pcm_play((unsigned char *)secbase, FMV_SECTOR_SIZE);
			continue;
		}

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
	clip_skip = 0;
	frame_open = 0;
	fmv_open = 0;
	batch_pos = 0;
	batch_end = 0;
	secbase = (unsigned int)secstore;
	key_countdown = 0u;
	tgv_pace_on = 0;
	seen_snd = 0;
	pace_locked = 0;
	blk_n = 0;
	frm_sum = 0;
	tgv_frm_n = 0;
	tgv_snd_n = 0;

	if (path == 0 || path[0] == 0)
		return -1;

	fmv_fp = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((unsigned int)fmv_fp & 0xFFu) != 0u)
		return -2;
	fmv_open = 1;

	OS_SEEKHANDLE(fmv_fp, FMV_SECTOR_SIZE);
	stream_sec_idx = 0u;

	tgv_ev_hit = 0u;
	tgv_ev_fail = 0u;
	tgv_gfx_init();
	if (!session)
		gs_pcm_init();
	tgv_flip_halt = tgv_fmv_no_halt ? 0u : 1u;
	return video_play();
}

unsigned char tgv_fmv_aborted(void)
{
	return user_abort;
}
