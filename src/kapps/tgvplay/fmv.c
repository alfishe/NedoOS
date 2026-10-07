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
unsigned char tgv_time_on;
unsigned char tgv_time_n;
const char *tgv_time_msg;
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

static void map_which(unsigned char which)
{
	if (which == 0u)
		map_pages(g_scr0_low, g_scr0_high);
	else
		map_pages(g_scr1_low, g_scr1_high);
}

/* RLE: bit7 set = repeat (n&127)+1 of the next byte, else copy n+1 literals. */
static const unsigned char *unrle(unsigned char *dst, const unsigned char *p,
	unsigned int n)
{
	unsigned int i;
	unsigned char c;
	unsigned char k;
	unsigned char v;

	i = 0u;
	while (i < n)
	{
		c = *p++;
		if ((c & 0x80u) != 0u)
		{
			k = (unsigned char)((c & 0x7fu) + 1u);
			v = *p++;
			do
				dst[i++] = v;
			while (--k != 0u);
		}
		else
		{
			k = (unsigned char)(c + 1u);
			do
				dst[i++] = *p++;
			while (--k != 0u);
		}
	}
	return p;
}

static void paint_banks(const unsigned char *rle)
{
	rle = unrle((unsigned char *)TGV_VRAM_LO, rle, 8000u);
	rle = unrle((unsigned char *)TGV_VRAM_HI, rle, 8000u);
	rle = unrle((unsigned char *)0xA000u, rle, 8000u);
	unrle((unsigned char *)0xE000u, rle, 8000u);
}

int tgv_show_still(const char *path)
{
	FILE *fp;
	unsigned int got;
	unsigned int n;
	unsigned int len;
	unsigned char front;
	const unsigned char *rle;

	if (path == 0 || path[0] == 0)
		return -1;
	fp = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((unsigned int)fp & 0xFFu) != 0u)
		return -1;
	got = 0u;
	while (got < FMV_BATCH_SIZE)
	{
		n = OS_READHANDLE(secstore + got, fp,
			(unsigned int)(FMV_BATCH_SIZE - got));
		if (n == 0u || n > (unsigned int)(FMV_BATCH_SIZE - got))
			break;
		got = (unsigned int)(got + n);
	}
	OS_CLOSEHANDLE(fp);
	if (got < 36u)
		return -1;
	len = secstore[0];
	len = (unsigned int)(len | ((unsigned int)secstore[1] << 8));
	if (len == 0u || (unsigned int)(34u + len) > got)
		return -1;

	/* Black both buffers before the palette moves, so the last frame
	   does not flash in the new colours. Index 0 stays black. */
	front = g_front;
	map_which(front);
	clear_mapped_vram();
	map_which((unsigned char)(front ^ 1u));
	clear_mapped_vram();
	tgv_set_main();
	tgv_setpal(secstore + 2);

	rle = secstore + 34;
	map_which((unsigned char)(front ^ 1u));
	paint_banks(rle);
	map_which(front);
	paint_banks(rle);
	tgv_set_main();
	return 0;
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

/* CP866 uppercase €-Ÿ, 8x8, bit 7 is the left pixel. */
static const unsigned char font_az[32 * 8] = {
	0x18,0x24,0x42,0x7E,0x42,0x42,0x42,0x00, /* € */
	0x7E,0x42,0x42,0x7C,0x42,0x42,0x7E,0x00, /*  */
	0x7C,0x42,0x42,0x7C,0x42,0x42,0x7C,0x00, /* ‚ */
	0x7E,0x40,0x40,0x40,0x40,0x40,0x40,0x00, /* ƒ */
	0x3C,0x22,0x22,0x22,0x22,0x7E,0x42,0x00, /* „ */
	0x7E,0x40,0x40,0x7C,0x40,0x40,0x7E,0x00, /* … */
	0x49,0x49,0x2A,0x1C,0x2A,0x49,0x49,0x00, /* † */
	0x3C,0x42,0x02,0x1C,0x02,0x42,0x3C,0x00, /* ‡ */
	0x42,0x46,0x4A,0x52,0x62,0x42,0x42,0x00, /* ˆ */
	0x24,0x18,0x42,0x46,0x4A,0x52,0x62,0x42, /* ‰ */
	0x42,0x44,0x48,0x70,0x48,0x44,0x42,0x00, /* Š */
	0x1E,0x22,0x42,0x42,0x42,0x42,0x42,0x00, /* ‹ */
	0x42,0x66,0x5A,0x42,0x42,0x42,0x42,0x00, /* Œ */
	0x42,0x42,0x42,0x7E,0x42,0x42,0x42,0x00, /*  */
	0x3C,0x42,0x42,0x42,0x42,0x42,0x3C,0x00, /* Ž */
	0x7E,0x42,0x42,0x42,0x42,0x42,0x42,0x00, /*  */
	0x7C,0x42,0x42,0x7C,0x40,0x40,0x40,0x00, /*  */
	0x3C,0x42,0x40,0x40,0x40,0x42,0x3C,0x00, /* ‘ */
	0x7E,0x18,0x18,0x18,0x18,0x18,0x18,0x00, /* ’ */
	0x42,0x42,0x42,0x22,0x1C,0x10,0x20,0x00, /* “ */
	0x18,0x7E,0x5A,0x5A,0x7E,0x18,0x18,0x00, /* ” */
	0x42,0x24,0x18,0x18,0x18,0x24,0x42,0x00, /* • */
	0x42,0x42,0x42,0x42,0x42,0x7E,0x02,0x00, /* – */
	0x42,0x42,0x42,0x3E,0x02,0x02,0x02,0x00, /* — */
	0x49,0x49,0x49,0x49,0x49,0x49,0x7F,0x00, /* ˜ */
	0x49,0x49,0x49,0x49,0x49,0x7F,0x01,0x00, /* ™ */
	0x60,0x20,0x20,0x3C,0x22,0x22,0x3C,0x00, /* š */
	0x42,0x42,0x42,0x72,0x4A,0x4A,0x72,0x00, /* › */
	0x40,0x40,0x40,0x7C,0x42,0x42,0x7C,0x00, /* œ */
	0x3C,0x42,0x02,0x1E,0x02,0x42,0x3C,0x00, /*  */
	0x76,0x4A,0x4A,0x7E,0x4A,0x4A,0x46,0x00, /* ž */
	0x3E,0x42,0x42,0x3E,0x12,0x22,0x42,0x00  /* Ÿ */
};

static void draw_time_msg(void)
{
	unsigned char col;
	unsigned char c;
	unsigned char r;
	unsigned char ch;
	unsigned char bits;
	const char *s;

	col = 8u;
	for (r = 0u; r < 8u; r++)
	{
		for (c = 8u; c < 38u; c++)
			plane_put(c, (unsigned int)(184u + r), 0u);
	}
	s = tgv_time_msg;
	if (s == 0)
		return;
	while (*s != 0 && col < 38u)
	{
		ch = (unsigned char)*s;
		s++;
		if (ch == (unsigned char)' ')
		{
			col++;
			continue;
		}
		if (ch >= 0x80u && ch <= 0x9Fu)
		{
			ch = (unsigned char)(ch - 0x80u);
			for (r = 0u; r < 8u; r++)
			{
				bits = font_az[(unsigned int)ch * 8u + r];
				plane_put(col, (unsigned int)(184u + r), bits);
			}
		}
		col++;
	}
}

void tgv_mark_paint(void)
{
	if (tgv_time_msg != 0)
		draw_time_msg();
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
