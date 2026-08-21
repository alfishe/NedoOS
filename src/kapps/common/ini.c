/*
 * Line-oriented INI reader (network.ini style).
 *   key = value
 *   ; comment to end of line (start or middle)
 * Spaces around '=' are ignored.
 * Does not load the whole file; long lines are skipped, not overflowed.
 *
 * ini_get_param() returns 1 if the key was found, 0 if the file could not
 * be opened or the key is missing. On 0, out[0] = 0 (if outsize > 0).
 */
#ifndef INI_C_INCLUDED
#define INI_C_INCLUDED

#include <string.h>
#include <oscalls.h>
#include <osfs.h>

#define INI_CHUNK 64u
#define INI_LINE 128u

static unsigned char ini_chunk[INI_CHUNK];
static unsigned char ini_line[INI_LINE];

static unsigned char *ini_ltrim(unsigned char *s)
{
	while (*s == ' ' || *s == '\t')
		s++;
	return s;
}

static void ini_rtrim(unsigned char *s)
{
	unsigned char *e;

	e = s;
	while (*e)
		e++;
	while (e > s && (e[-1] == ' ' || e[-1] == '\t' || e[-1] == '\r')) {
		e--;
		*e = 0;
	}
}

static unsigned char ini_keyeq(unsigned char *a, unsigned char *b)
{
	while (*a && *b && *a == *b) {
		a++;
		b++;
	}
	return (unsigned char)(*a == 0 && *b == 0);
}

static unsigned char ini_take_line(unsigned char *key, unsigned char *out,
				   unsigned int outsize)
{
	unsigned char *p;
	unsigned char *eq;
	unsigned char *k;
	unsigned int n;

	p = ini_line;
	while (*p) {
		if (*p == ';') {
			*p = 0;
			break;
		}
		p++;
	}
	p = ini_ltrim(ini_line);
	if (*p == 0)
		return 0;
	eq = p;
	while (*eq && *eq != '=')
		eq++;
	if (*eq != '=')
		return 0;
	*eq = 0;
	ini_rtrim(p);
	k = ini_ltrim(p);
	if (!ini_keyeq(k, key))
		return 0;
	p = ini_ltrim(eq + 1);
	ini_rtrim(p);
	if (outsize == 0)
		return 1;
	n = 0;
	while (p[n] && (n + 1u) < outsize) {
		out[n] = p[n];
		n++;
	}
	out[n] = 0;
	return 1;
}

unsigned char ini_get_param(unsigned char *path, unsigned char *key,
			    unsigned char *out, unsigned int outsize)
{
	FILE *fp;
	unsigned int got;
	unsigned int i;
	unsigned int linelen;
	unsigned char skipping;
	unsigned char c;

	if (outsize)
		out[0] = 0;
	fp = OS_OPENHANDLE(path, 0x80);
	if (((int)fp) & 0xff)
		return 0;
	linelen = 0;
	skipping = 0;
	for (;;) {
		got = OS_READHANDLE(ini_chunk, fp, INI_CHUNK);
		if (got == 0)
			break;
		for (i = 0; i < got; i++) {
			c = ini_chunk[i];
			if (c == '\n' || c == '\r') {
				if (!skipping && linelen) {
					ini_line[linelen] = 0;
					if (ini_take_line(key, out, outsize)) {
						OS_CLOSEHANDLE(fp);
						return 1;
					}
				}
				linelen = 0;
				skipping = 0;
				continue;
			}
			if (skipping)
				continue;
			if (linelen < (INI_LINE - 1u)) {
				ini_line[linelen] = c;
				linelen++;
			} else {
				skipping = 1;
				linelen = 0;
			}
		}
	}
	if (!skipping && linelen) {
		ini_line[linelen] = 0;
		if (ini_take_line(key, out, outsize)) {
			OS_CLOSEHANDLE(fp);
			return 1;
		}
	}
	OS_CLOSEHANDLE(fp);
	return 0;
}

unsigned int ini_parse_uint(unsigned char *s)
{
	unsigned int v;
	unsigned char hex;
	unsigned char c;

	s = ini_ltrim(s);
	hex = 0;
	if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
		hex = 1;
		s += 2;
	}
	v = 0;
	for (;;) {
		c = *s;
		if (c >= '0' && c <= '9')
			v = hex ? (v << 4) + (unsigned int)(c - '0')
			        : v * 10u + (unsigned int)(c - '0');
		else if (hex && c >= 'a' && c <= 'f')
			v = (v << 4) + (unsigned int)(c - 'a' + 10);
		else if (hex && c >= 'A' && c <= 'F')
			v = (v << 4) + (unsigned int)(c - 'A' + 10);
		else
			break;
		s++;
	}
	return v;
}

/* Old espcom.ini: 12 numbers (8 hex ports, then divider/comType/espType/espRetry),
 * whitespace-separated, ';' comments. Used only if key=value keys are missing. */
unsigned char ini_legacy_u16s(unsigned char *path, unsigned int *out, unsigned char n)
{
	FILE *fp;
	static unsigned char buf[280];
	unsigned char *p;
	unsigned char i;
	unsigned char c;

	fp = OS_OPENHANDLE(path, 0x80);
	if (((int)fp) & 0xff)
		return 0;
	memset(buf, 0, sizeof(buf));
	OS_READHANDLE(buf, fp, sizeof(buf) - 1);
	OS_CLOSEHANDLE(fp);
	p = buf;
	for (i = 0; i < n; i++) {
		for (;;) {
			c = *p;
			if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
				p++;
				continue;
			}
			if (c == ';') {
				while (*p && *p != '\n' && *p != '\r')
					p++;
				continue;
			}
			break;
		}
		if (*p == 0)
			return 0;
		out[i] = ini_parse_uint(p);
		if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X'))
			p += 2;
		while ((*p >= '0' && *p <= '9') ||
		       (*p >= 'a' && *p <= 'f') ||
		       (*p >= 'A' && *p <= 'F'))
			p++;
	}
	return 1;
}

#endif
