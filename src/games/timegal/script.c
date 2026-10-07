/*
 * Time Gal choices, from GALSCRIP.asm (ALASM).
 * HOD times are sound frames (2048 bytes at 17500 Hz, 0.117 s).
 * The arrow is up for reaction=5 of those frames and closes at z=6.
 * A wrong key or a miss plays the death clip and the level runs again.
 * Checked once per frame, not per tile.
 */
#include <tgvplay.h>
#include "script.h"

#define TG_Z      6
#define TG_REACT  5

#define K_LEFT  0xF8u
#define K_DOWN  0xF9u
#define K_UP    0xFAu
#define K_RIGHT 0xFBu
#define K_FIRE  1u

struct ev {
	unsigned int frame;
	unsigned char key;
	const char *death;
};

static const struct ev ev_l1[] = {
	{44, K_RIGHT, "l1d1"}, {69, K_RIGHT, "l1d1"}, {91, K_LEFT, "l1d1"},
	{131, K_RIGHT, "l1d2"}, {147, K_LEFT, "l1d3"}, {168, K_UP, "l1d4"},
	{199, K_DOWN, "l1d5"}
};
static const struct ev ev_l2[] = {
	{50, K_UP, "l2d1"}, {126, K_LEFT, "l2d2"},
	{157, K_FIRE, "l2d3"}, {218, K_FIRE, "l2d4"}
};
static const struct ev ev_l3[] = {
	{47, K_DOWN, "l3d1"}, {67, K_RIGHT, "l3d1"}, {85, K_LEFT, "l3d2"},
	{105, K_RIGHT, "l3d3"}, {133, K_DOWN, "l3d4"}, {161, K_RIGHT, "l3d5"},
	{190, K_RIGHT, "l3d6"}, {212, K_RIGHT, "l3d6"},
	{246, K_FIRE, "l3d7"}, {296, K_FIRE, "l3da"}
};
static const struct ev ev_l4[] = {
	{65, K_RIGHT, "l4d1"}, {83, K_UP, "l4d1"}, {138, K_RIGHT, "l4d2"}
};
static const struct ev ev_l5[] = {
	{55, K_RIGHT, "l5d1"}, {85, K_FIRE, "l5d1"}, {98, K_FIRE, "l5d1"},
	{121, K_FIRE, "l5d1"}, {146, K_LEFT, "l5d1"}, {165, K_UP, "l5d1"},
	{228, K_LEFT, "l5d2"}, {256, K_RIGHT, "l5d3"}, {291, K_LEFT, "l5d2"},
	{325, K_UP, "l5d1"}, {361, K_FIRE, "l5d1"}
};
static const struct ev ev_l6[] = {
	{45, K_RIGHT, "l6d1"}, {68, K_DOWN, "l6d2"}, {96, K_UP, "l6d3"},
	{129, K_DOWN, "l6d1"}, {184, K_RIGHT, "l6d4"}, {209, K_LEFT, "l6d5"},
	{242, K_UP, "l6d6"}, {283, K_FIRE, "l6d7"}, {314, K_RIGHT, "l6d8"},
	{366, K_RIGHT, "l6d9"}
};
static const struct ev ev_l7[] = {
	{72, K_UP, "l7d1"}, {99, K_RIGHT, "l7d1"}, {123, K_FIRE, "l7d1"},
	{177, K_LEFT, "l7d1"}, {197, K_FIRE, "l7d1"}, {245, K_FIRE, "l7d2"}
};
static const struct ev ev_l8[] = {
	{53, K_LEFT, "l8d1"}, {78, K_FIRE, "l8d1"}, {111, K_UP, "l8d1"},
	{140, K_UP, "l8d1"}, {166, K_UP, "l8d2"}, {219, K_UP, "l8d3"},
	{244, K_LEFT, "l8d4"}, {263, K_RIGHT, "l8d5"}, {308, K_FIRE, "l8d6"}
};
static const struct ev ev_l9[] = {
	{38, K_RIGHT, "l9d1"}, {60, K_RIGHT, "l9d2"}, {84, K_DOWN, "l9d3"},
	{117, K_UP, "l9d4"}, {174, K_FIRE, "l9d2"},
	{306, K_FIRE, "l9d5"}, {406, K_UP, "l9d6"}, {423, K_LEFT, "l9d7"},
	{450, K_RIGHT, "l9d8"}, {470, K_RIGHT, "l9d9"}
};
static const struct ev ev_la[] = {
	{53, K_RIGHT, "lad1"}, {87, K_LEFT, "lad2"}, {117, K_DOWN, "lad3"},
	{172, K_RIGHT, "lad4"}, {217, K_RIGHT, "lad5"}, {254, K_LEFT, "lad6"},
	{312, K_FIRE, "lad1"}
};
static const struct ev ev_lb[] = {
	{44, K_LEFT, "lbd1"}, {94, K_RIGHT, "lbd2"}, {162, K_LEFT, "lbd3"},
	{198, K_DOWN, "lbd4"}, {236, K_FIRE, "lbd5"}
};
static const struct ev ev_lc[] = {
	{47, K_RIGHT, "lcd1"}, {92, K_UP, "lcd2"}, {125, K_LEFT, "lcd3"},
	{143, K_UP, "lcd4"}, {197, K_RIGHT, "lcd5"}, {231, K_DOWN, "lcd6"},
	{257, K_FIRE, "lcd7"}, {286, K_RIGHT, "lcd8"}, {305, K_DOWN, "lcd9"}
};
static const struct ev ev_ld[] = {
	{44, K_LEFT, "ldd1"}, {60, K_LEFT, "ldd2"}, {89, K_RIGHT, "ldd1"},
	{138, K_FIRE, "ldd3"}, {177, K_LEFT, "ldd4"}, {208, K_RIGHT, "ldd5"},
	{238, K_FIRE, "ldd6"}, {292, K_FIRE, "ldd7"}
};
static const struct ev ev_le[] = {
	{57, K_FIRE, "led1"}, {116, K_DOWN, "led2"}, {140, K_LEFT, "led3"},
	{164, K_RIGHT, "led4"}, {232, K_FIRE, "led7"},
	{337, K_RIGHT, "led5"}, {351, K_FIRE, "led6"}
};
static const struct ev ev_lf[] = {
	{59, K_LEFT, "lfd1"}, {87, K_RIGHT, "lfd2"}, {143, K_RIGHT, "lfd3"},
	{165, K_FIRE, "lfd4"}, {183, K_FIRE, "lfd5"}, {231, K_DOWN, "lfd6"}
};
static const struct ev ev_lg[] = {
	{52, K_RIGHT, "lgd1"}, {73, K_FIRE, "lgd2"}, {123, K_FIRE, "lgd3"},
	{139, K_FIRE, "lgd4"}, {155, K_UP, "lgd5"}, {202, K_RIGHT, "lgd6"},
	{220, K_FIRE, "lgd7"}, {261, K_LEFT, "lgd8"}, {309, K_FIRE, "lgd4"}
};

static const char *const files[] = {
	"gintro",
	"lev1", "lev2", "lev3", "lev4", "lev5", "lev6", "lev7", "lev8", "lev9",
	"leva", "levb", "levc", "levd", "leve", "levf", "levg"
};

static const struct ev *const tabs[] = {
	0,
	ev_l1, ev_l2, ev_l3, ev_l4, ev_l5, ev_l6, ev_l7, ev_l8, ev_l9,
	ev_la, ev_lb, ev_lc, ev_ld, ev_le, ev_lf, ev_lg
};

static const unsigned char counts[] = {
	0,
	7, 4, 10, 3, 11, 10, 6, 9, 10,
	7, 5, 9, 8, 7, 6, 9
};

static unsigned char cur_lv;
static unsigned char cur_i;
static const char *cur_death;
static unsigned char failed;
static unsigned char hint_on;
static unsigned char got_good;
static unsigned char lives;
static unsigned char cur_mirror;
static unsigned char stop_on;
static unsigned char stop_done;
static unsigned char stop_sel;

static unsigned char hint_of(unsigned char key)
{
	if (key == K_LEFT)
		return 1u;
	if (key == K_RIGHT)
		return 2u;
	if (key == K_UP)
		return 3u;
	if (key == K_DOWN)
		return 4u;
	return 5u;
}

static void marks_off(void)
{
	if (tgv_cover == 0u)
		tgv_cover = tgv_hint;
	tgv_hint = 0u;
	if (tgv_cover != 0u)
		tgv_cover_ttl = 4u;
}

static void arm_at(unsigned char i)
{
	unsigned int fr;
	unsigned char key;

	cur_i = i;
	cur_death = tabs[cur_lv][i].death;
	fr = tabs[cur_lv][i].frame;
	key = tabs[cur_lv][i].key;
	if (cur_mirror != 0u)
	{
		if (key == K_LEFT)
			key = K_RIGHT;
		else if (key == K_RIGHT)
			key = K_LEFT;
	}
	hint_on = 0u;
	got_good = 0u;
	tgv_hint = 0u;
	tgv_ev_arm((unsigned int)(fr + TG_Z - TG_REACT), (unsigned int)(fr + TG_Z), key);
}

unsigned char script_levels(void)
{
	return (unsigned char)(sizeof(files) / sizeof(files[0]));
}

const char *script_file(unsigned char level)
{
	return files[level];
}

static const char *const mirror_file[] = {
	0, "mev1", 0, "mev3", 0, 0, "mev6", 0, 0, "mev9",
	"meva", 0, 0, "mevd", 0, "mevf", 0
};

static const char *const mirror_death[] = {
	"l1d2", "l1d5",
	"l3d3", "l3d5", "l3d6", "l3d9", "l3da",
	"l6d2", "l6d4", "l6d5", "l6d8",
	"l9d1", "l9d4", "l9d5", "l9d7", "l9d9", "l9dc",
	"lad1", "lad4", "lad5", "lad7",
	"ldd2", "ldd5", "ldd6", "ldd8",
	"lfd1", "lfd2", "lfd4"
};

struct stop {
	unsigned int begin;
	unsigned int end;
	const char *s0;
	const char *s1;
	const char *s2;
	const char *d0;
	const char *d1;
};

static const struct stop stop_l2 = {
	232, 291,
	"\x82\x9B\x91\x92\x90\x85\x8B\x88\x92\x9C",
	"\x93\x82\x85\x90\x8D\x93\x92\x9C\x91\x9F",
	"\x8F\x8B\x9B\x92\x9C\x20\x82\x82\x85\x90\x95",
	"l2d5", "l2d6"
};
static const struct stop stop_l3 = {
	306, 366,
	"\x82\x9B\x91\x92\x90\x85\x8B\x88\x92\x9C\x20\x82\x8E\x20\x82\x90\x80\x83\x8E\x82",
	"\x8F\x8E\x89\x8C\x80\x92\x9C\x20\x82\x90\x80\x83\x8E\x82\x20\x91\x85\x92\x9C\x9E",
	"\x8F\x85\x90\x85\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x90\x80\x83\x8E\x82",
	"l3d8", "l3d9"
};
static const struct stop stop_l8 = {
	317, 377,
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x20\x8B\x8E\x84\x8A\x93",
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x20\x82\x8E\x84\x93",
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x8D\x80\x20\x8A\x8E\x90\x80\x81\x8B\x9C",
	"l8d7", "l8d8"
};
static const struct stop stop_l9 = {
	183, 243,
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x8D\x80\x20\x8A\x8E\x90\x80\x81\x8B\x9C",
	"\x8C\x8E\x8B\x88\x92\x9C\x91\x9F",
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x20\x82\x8E\x84\x93",
	"l9db", "l9dc"
};
static const struct stop stop_la = {
	325, 385,
	"\x8B\x85\x87\x92\x9C\x20\x82\x82\x85\x90\x95",
	"\x91\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x8D\x88\x87",
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x8D\x80\x20\x82\x85\x90\x92\x8E\x8B\x85\x92",
	"lad7", "lad8"
};
static const struct stop stop_lb = {
	245, 305,
	"\x91\x82\x85\x90\x8D\x93\x92\x9C\x20\x82\x20\x91\x92\x8E\x90\x8E\x8D\x93",
	"\x90\x80\x87\x82\x85\x90\x8D\x93\x92\x9C\x91\x9F",
	"\x85\x95\x80\x92\x9C\x20\x8F\x8E\x84\x20\x96\x88\x91\x92\x85\x90\x8D\x8E\x89",
	"lbd6", "lbd7"
};
static const struct stop stop_ld = {
	319, 378,
	"\x91\x92\x90\x85\x8B\x9F\x92\x9C\x20\x82\x20\x90\x8E\x81\x8E\x92\x80",
	"\x91\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x8D\x88\x87",
	"\x8F\x8E\x84\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x82\x85\x90\x95",
	"ldd8", "ldd9"
};
static const struct stop stop_le = {
	244, 304,
	"\x8F\x90\x9B\x83\x8D\x93\x92\x9C\x20\x82\x82\x85\x90\x95",
	"\x91\x92\x90\x85\x8B\x9F\x92\x9C\x20\x8F\x8E\x20\x92\x90\x80\x93\x90\x80\x8C",
	"\x8D\x80\x86\x80\x92\x9C\x20\x8A\x8D\x8E\x8F\x8A\x93\x20\x98\x8B\x9E\x87\x80",
	"led8", "led9"
};

static const struct stop *const stop_tab[] = {
	0, 0, &stop_l2, &stop_l3, 0, 0, 0, 0, &stop_l8, &stop_l9,
	&stop_la, &stop_lb, 0, &stop_ld, &stop_le, 0, 0
};

static const char *stop_line(const struct stop *st)
{
	if (stop_sel == 0u)
		return st->s0;
	if (stop_sel == 1u)
		return st->s1;
	return st->s2;
}

static unsigned char timestop_tick(void)
{
	const struct stop *st;
	unsigned char n;

	if (cur_lv >= (unsigned char)(sizeof(stop_tab) / sizeof(stop_tab[0])))
		return 0u;
	st = stop_tab[cur_lv];
	if (st == 0 || stop_done)
		return 0u;
	if (tgv_snd_n < st->begin)
		return 0u;
	if (tgv_snd_n < st->end)
	{
		if (!stop_on)
		{
			stop_on = 1u;
			stop_sel = (unsigned char)((tgv_frm_n + tgv_snd_n) % 3u);
			tgv_time_on = 1u;
			tgv_time_n = 0u;
			tgv_hint = 0u;
		}
		n = tgv_time_n;
		if (n != 0u)
		{
			stop_sel = (unsigned char)((stop_sel + n) % 3u);
			tgv_time_n = 0u;
			tgv_bibik_good();
		}
		tgv_time_msg = stop_line(st);
		return 1u;
	}
	tgv_time_on = 0u;
	tgv_time_msg = 0;
	tgv_time_n = 0u;
	stop_on = 0u;
	stop_done = 1u;
	if (stop_sel == 0u)
	{
		cur_death = st->d0;
		failed = 1u;
		tgv_ev_fail = 1u;
		tgv_bibik_bad();
		return 1u;
	}
	if (stop_sel == 1u)
	{
		cur_death = st->d1;
		failed = 1u;
		tgv_ev_fail = 1u;
		tgv_bibik_bad();
		return 1u;
	}
	tgv_bibik_good();
	return 0u;
}

void script_bind(unsigned char level)
{
	cur_lv = level;
	cur_i = 0;
	cur_death = 0;
	failed = 0;
	hint_on = 0u;
	got_good = 0u;
	tgv_hint = 0u;
	tgv_cover = 0u;
	tgv_cover_ttl = 0u;
	stop_on = 0u;
	stop_done = 0u;
	tgv_time_on = 0u;
	tgv_time_n = 0u;
	tgv_time_msg = 0;
	tgv_ev_disarm();
	if (counts[level] != 0)
		arm_at(0);
}

void script_pump(void)
{
	if (timestop_tick())
		return;
	if (!tgv_ev_on && !tgv_ev_fail)
		return;
	if (tgv_ev_fail) {
		if (hint_on && !got_good)
			tgv_bibik_bad();
		hint_on = 0u;
		got_good = 0u;
		marks_off();
		failed = 1u;
		tgv_ev_disarm();
		return;
	}
	if (tgv_snd_n < tgv_ev_open)
		return;
	if (tgv_snd_n <= tgv_ev_close) {
		if (!hint_on) {
			hint_on = 1u;
			tgv_bibik_ask();
		}
		if (tgv_ev_hit && !got_good) {
			got_good = 1u;
			if (tgv_cover == 0u)
				tgv_cover = hint_of(tgv_ev_key);
			tgv_hint = 0u;
			tgv_bibik_good();
		} else if (!got_good)
			tgv_hint = hint_of(tgv_ev_key);
		return;
	}
	/* The mark is still on the last frame while the next sound block
	   loads. Take that press before calling it a miss. */
	if (!tgv_ev_hit)
		tgv_ev_last();
	if (tgv_ev_hit && !got_good) {
		got_good = 1u;
		if (tgv_cover == 0u)
			tgv_cover = hint_of(tgv_ev_key);
		tgv_hint = 0u;
		tgv_bibik_good();
	}
	if (hint_on && !got_good)
		tgv_bibik_bad();
	hint_on = 0u;
	got_good = 0u;
	marks_off();
	if (!tgv_ev_hit) {
		failed = 1u;
		tgv_ev_fail = 1u;
		tgv_ev_disarm();
		return;
	}
	cur_i++;
	if (cur_i >= counts[cur_lv]) {
		tgv_ev_disarm();
		return;
	}
	arm_at(cur_i);
}

unsigned char script_failed(void)
{
	return failed;
}

const char *script_death(void)
{
	return cur_death;
}

static unsigned char same_name(const char *a, const char *b)
{
	unsigned char i;

	if (a == 0 || b == 0)
		return 0u;
	for (i = 0u; a[i] != 0 || b[i] != 0; i++)
	{
		if (a[i] != b[i])
			return 0u;
	}
	return 1u;
}

void script_reset(void)
{
	lives = 5u;
	cur_mirror = 0u;
}

unsigned char script_take_life(void)
{
	if (lives != 0u)
		lives--;
	return lives;
}

unsigned char script_lives(void)
{
	return lives;
}

void script_use_mirror(unsigned char on)
{
	cur_mirror = on;
}

const char *script_level_file(unsigned char level)
{
	if (cur_mirror != 0u && mirror_file[level] != 0)
		return mirror_file[level];
	return files[level];
}

unsigned char script_death_to_mirror(void)
{
	unsigned char i;

	for (i = 0u; i < (unsigned char)(sizeof(mirror_death) / sizeof(mirror_death[0])); i++)
	{
		if (same_name(cur_death, mirror_death[i]))
			return 1u;
	}
	return 0u;
}
