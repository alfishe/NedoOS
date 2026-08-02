#include <stdio.h>
#include <string.h>
#include <osfs.h>
#include "grep.h"

grep_opts_t g_opts;
unsigned char g_patterns[GREP_MAX_PATTERNS][GREP_PATTERN_LEN + 1];
unsigned char g_pat_count;
unsigned char g_any_match;
unsigned char g_any_error;
unsigned int  g_files_total;

unsigned char grep_is_word_char(unsigned char c)
{
	if (c >= 'a' && c <= 'z')
	{
		return 1;
	}
	if (c >= 'A' && c <= 'Z')
	{
		return 1;
	}
	if (c >= '0' && c <= '9')
	{
		return 1;
	}
	if (c == '_')
	{
		return 1;
	}
	return 0;
}

static unsigned char fold_ch(unsigned char c)
{
	if (g_opts.ignore_case && c >= 'A' && c <= 'Z')
	{
		return (unsigned char)(c + 32);
	}
	return c;
}

static int chars_equal(unsigned char a, unsigned char b)
{
	return fold_ch(a) == fold_ch(b);
}

int grep_add_pattern(const unsigned char *pat)
{
	unsigned int i;

	if (pat == 0 || pat[0] == 0)
	{
		return 0;
	}
	if (g_pat_count >= GREP_MAX_PATTERNS)
	{
		return -1;
	}
	for (i = 0; i < GREP_PATTERN_LEN && pat[i] != 0; i++)
	{
		g_patterns[g_pat_count][i] = pat[i];
	}
	g_patterns[g_pat_count][i] = 0;
	g_pat_count++;
	return 0;
}

static int fixed_find(const unsigned char *line, unsigned int len,
                      const unsigned char *pat, unsigned int from,
                      grep_span_t *out)
{
	unsigned int plen;
	unsigned int i;
	unsigned int j;

	plen = (unsigned int)strlen((const char *)pat);
	if (plen == 0)
	{
		return 0;
	}
	for (i = from; i + plen <= len; i++)
	{
		for (j = 0; j < plen; j++)
		{
			if (!chars_equal(line[i + j], pat[j]))
			{
				break;
			}
		}
		if (j == plen)
		{
			if (g_opts.whole_word)
			{
				if (i > 0 && grep_is_word_char(line[i - 1]))
				{
					continue;
				}
				if (i + plen < len && grep_is_word_char(line[i + plen]))
				{
					continue;
				}
			}
			if (out != 0)
			{
				out->start = i;
				out->len = plen;
			}
			return 1;
		}
	}
	return 0;
}

static int in_class(unsigned char c, const unsigned char **pp)
{
	const unsigned char *p;
	unsigned char negate;
	unsigned char found;
	unsigned char lo;
	unsigned char hi;

	p = *pp;
	negate = 0;
	found = 0;
	if (*p == '^')
	{
		negate = 1;
		p++;
	}
	while (*p != 0 && *p != ']')
	{
		if (*p == '\\' && p[1] != 0)
		{
			p++;
			if (chars_equal(c, *p))
			{
				found = 1;
			}
			p++;
			continue;
		}
		if (p[1] == '-' && p[2] != 0 && p[2] != ']')
		{
			lo = fold_ch(p[0]);
			hi = fold_ch(p[2]);
			if (fold_ch(c) >= lo && fold_ch(c) <= hi)
			{
				found = 1;
			}
			p += 3;
			continue;
		}
		if (chars_equal(c, *p))
		{
			found = 1;
		}
		p++;
	}
	if (*p == ']')
	{
		p++;
	}
	*pp = p;
	if (negate)
	{
		return !found;
	}
	return found;
}

static const unsigned char *skip_group(const unsigned char *p)
{
	int depth;

	depth = 1;
	p++;
	while (*p != 0 && depth > 0)
	{
		if (*p == '\\' && p[1] != 0)
		{
			p += 2;
			continue;
		}
		if (*p == '(')
		{
			depth++;
		}
		else if (*p == ')')
		{
			depth--;
		}
		p++;
	}
	return p;
}

static const unsigned char *match_here(const unsigned char *s, const unsigned char *end,
                                       const unsigned char *p);

static const unsigned char *match_star(const unsigned char *s, const unsigned char *end,
                                       const unsigned char *p, const unsigned char *atom,
                                       int min, int max_more)
{
	const unsigned char *best;
	const unsigned char *t;
	int n;

	best = 0;
	n = 0;
	for (;;)
	{
		if (n >= min)
		{
			t = match_here(s, end, p);
			if (t != 0)
			{
				return t;
			}
			best = s;
		}
		if (n > max_more)
		{
			break;
		}
		t = match_here(s, end, atom);
		if (t == 0 || t == s)
		{
			break;
		}
		s = t;
		n++;
	}
	if (n >= min && best != 0)
	{
		return match_here(best, end, p);
	}
	return 0;
}

static const unsigned char *match_piece(const unsigned char *s, const unsigned char *end,
                                        const unsigned char **pp)
{
	const unsigned char *p;
	const unsigned char *atom;
	unsigned char c;
	int ext;

	p = *pp;
	ext = (g_opts.regex_mode == GREP_MODE_EXTENDED);

	if (ext && *p == '(')
	{
		atom = p;
		p = skip_group(p);
		if (*p == '*')
		{
			(*pp) = p + 1;
			return match_star(s, end, *pp, atom, 0, 65535);
		}
		if (*p == '+')
		{
			(*pp) = p + 1;
			return match_star(s, end, *pp, atom, 1, 65535);
		}
		if (*p == '?')
		{
			(*pp) = p + 1;
			return match_star(s, end, *pp, atom, 0, 1);
		}
		(*pp) = p;
		return match_here(s, end, atom);
	}

	if (*p == '.')
	{
		if (s >= end)
		{
			return 0;
		}
		atom = p;
		p++;
		if (*p == '*')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 0, 65535);
		}
		if (ext && *p == '+')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 1, 65535);
		}
		if (ext && *p == '?')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 0, 1);
		}
		(*pp) = p;
		return s + 1;
	}

	if (*p == '[')
	{
		const unsigned char *cls;
		if (s >= end)
		{
			return 0;
		}
		cls = p;
		p++;
		if (!in_class(*s, &p))
		{
			return 0;
		}
		if (*p != ']')
		{
			return 0;
		}
		p++;
		atom = cls;
		if (*p == '*')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 0, 65535);
		}
		if (ext && *p == '+')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 1, 65535);
		}
		if (ext && *p == '?')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, atom, 0, 1);
		}
		(*pp) = p;
		return s + 1;
	}

	if (*p == '$')
	{
		if (s >= end)
		{
			(*pp) = p + 1;
			return s;
		}
		return 0;
	}

	if (!ext && *p == '\\' && p[1] != 0)
	{
		p++;
	}

	if (*p == 0)
	{
		return s;
	}

	c = *p;
	if (s >= end || !chars_equal(*s, c))
	{
		return 0;
	}
	atom = p;
	p++;
	if (*p == '*')
	{
		(*pp) = p + 1;
		return match_star(s + 1, end, *pp, atom, 0, 65535);
	}
	if (ext && *p == '+')
	{
		(*pp) = p + 1;
		return match_star(s + 1, end, *pp, atom, 1, 65535);
	}
	if (ext && *p == '?')
	{
		(*pp) = p + 1;
		return match_star(s + 1, end, *pp, atom, 0, 1);
	}
	(*pp) = p;
	return s + 1;
}

static const unsigned char *match_branch(const unsigned char *s, const unsigned char *end,
                                         const unsigned char *p, const unsigned char *p_end)
{
	const unsigned char *pp;
	const unsigned char *t;

	while (p < p_end)
	{
		if (g_opts.regex_mode == GREP_MODE_EXTENDED && *p == '|')
		{
			break;
		}
		if (g_opts.regex_mode == GREP_MODE_EXTENDED && *p == ')')
		{
			break;
		}
		pp = p;
		t = match_piece(s, end, &pp);
		if (t == 0)
		{
			return 0;
		}
		s = t;
		p = pp;
	}
	return s;
}

static const unsigned char *match_here(const unsigned char *s, const unsigned char *end,
                                       const unsigned char *p)
{
	const unsigned char *best;
	const unsigned char *t;
	const unsigned char *q;

	if (g_opts.regex_mode != GREP_MODE_EXTENDED)
	{
		return match_branch(s, end, p, p + strlen((const char *)p));
	}

	best = 0;
	q = p;
	while (1)
	{
		t = match_branch(s, end, q, p + strlen((const char *)p));
		if (t != 0 && (best == 0 || t > best))
		{
			best = t;
		}
		while (*q != 0 && *q != '|')
		{
			if (*q == '(')
			{
				q = skip_group(q);
			}
			else if (*q == '\\' && q[1] != 0)
			{
				q += 2;
			}
			else
			{
				q++;
			}
		}
		if (*q != '|')
		{
			break;
		}
		q++;
	}
	return best;
}

static int regex_match_span(const unsigned char *line, unsigned int len,
                            const unsigned char *pat, unsigned int from,
                            grep_span_t *out)
{
	const unsigned char *end;
	const unsigned char *p;
	const unsigned char *t;
	unsigned int i;

	end = line + len;
	for (i = from; i <= len; i++)
	{
		p = pat;
		if (*p == '^')
		{
			if (i != 0)
			{
				continue;
			}
			p++;
		}
		t = match_here(line + i, end, p);
		if (t == 0)
		{
			continue;
		}
		if (strchr((const char *)p, '$') != 0)
		{
			/* $ anchor: match must reach end */
			if (t != end)
			{
				continue;
			}
		}
		if (g_opts.whole_word)
		{
			if (i > 0 && grep_is_word_char(line[i - 1]))
			{
				continue;
			}
			if (t < end && grep_is_word_char(*t))
			{
				continue;
			}
		}
		if (out != 0)
		{
			out->start = i;
			out->len = (unsigned int)(t - (line + i));
		}
		return 1;
	}
	return 0;
}

static int pattern_matches(const unsigned char *line, unsigned int len,
                           const unsigned char *pat, unsigned int from,
                           grep_span_t *out)
{
	grep_span_t span;
	int hit;

	if (g_opts.regex_mode == GREP_MODE_FIXED)
	{
		hit = fixed_find(line, len, pat, from, out);
	}
	else
	{
		hit = regex_match_span(line, len, pat, from, out);
	}
	if (!hit)
	{
		return 0;
	}
	if (g_opts.whole_line)
	{
		if (out != 0)
		{
			span = *out;
		}
		else
		{
			span.start = 0;
			span.len = len;
		}
		if (span.start != 0 || span.start + span.len != len)
		{
			return 0;
		}
	}
	return 1;
}

int grep_find_match(const unsigned char *line, unsigned int len,
                    unsigned int from, grep_span_t *out)
{
	unsigned char i;
	grep_span_t local;

	for (i = 0; i < g_pat_count; i++)
	{
		local.start = 0;
		local.len = 0;
		if (pattern_matches(line, len, g_patterns[i], from, &local))
		{
			if (out != 0)
			{
				*out = local;
			}
			return 1;
		}
	}
	return 0;
}

int grep_line_matches(const unsigned char *line, unsigned int len)
{
	int hit;

	hit = grep_find_match(line, len, 0, 0);
	if (g_opts.invert)
	{
		return !hit;
	}
	return hit;
}

int grep_load_patterns_file(const unsigned char *path)
{
	FILE *fp;
	unsigned int got;
	static unsigned char buf[GREP_LINE_LEN + 1];
	unsigned int pos;
	unsigned char c;

	fp = OS_OPENHANDLE((unsigned char *)path, 0x80);
	if (((int)fp) & 0xff)
	{
		return -1;
	}
	pos = 0;
	for (;;)
	{
		got = OS_READHANDLE(buf + pos, fp, 1);
		if (got == 0)
		{
			break;
		}
		c = buf[pos];
		if (c == '\r' || c == '\n')
		{
			buf[pos] = 0;
			if (pos > 0 && buf[0] != '#')
			{
				if (grep_add_pattern(buf) != 0)
				{
					OS_CLOSEHANDLE(fp);
					return -1;
				}
			}
			pos = 0;
			continue;
		}
		if (pos < GREP_LINE_LEN)
		{
			pos++;
		}
	}
	if (pos > 0 && buf[0] != '#')
	{
		buf[pos] = 0;
		if (grep_add_pattern(buf) != 0)
		{
			OS_CLOSEHANDLE(fp);
			return -1;
		}
	}
	OS_CLOSEHANDLE(fp);
	return 0;
}
