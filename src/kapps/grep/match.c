#include <stdio.h>
#include <string.h>
#include <osfs.h>
#include "grep.h"

grep_opts_t g_opts;
grep_pat_t g_pats[GREP_MAX_PATTERNS];
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
	if (c >= 'A' && c <= 'Z')
	{
		return (unsigned char)(c + 32);
	}
	return c;
}

static unsigned char other_case(unsigned char c)
{
	if (c >= 'a' && c <= 'z')
	{
		return (unsigned char)(c - 32);
	}
	if (c >= 'A' && c <= 'Z')
	{
		return (unsigned char)(c + 32);
	}
	return 0;
}

static int chars_equal(unsigned char a, unsigned char b)
{
	if (a == b)
	{
		return 1;
	}
	if (!g_opts.ignore_case)
	{
		return 0;
	}
	return fold_ch(a) == fold_ch(b);
}

/* True if pattern has no regex metacharacters for current mode. */
static unsigned char pattern_is_literal(const unsigned char *pat)
{
	unsigned char c;
	unsigned char ext;

	if (g_opts.regex_mode == GREP_MODE_FIXED)
	{
		return 1;
	}
	ext = (g_opts.regex_mode == GREP_MODE_EXTENDED) ? 1 : 0;
	while ((c = *pat++) != 0)
	{
		if (c == '.' || c == '*' || c == '[' || c == '\\' ||
		    c == '^' || c == '$')
		{
			return 0;
		}
		if (ext && (c == '+' || c == '?' || c == '|' || c == '(' || c == ')'))
		{
			return 0;
		}
	}
	return 1;
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
		g_pats[g_pat_count].text[i] = pat[i];
	}
	g_pats[g_pat_count].text[i] = 0;
	g_pats[g_pat_count].len = (unsigned char)i;
	g_pats[g_pat_count].literal = 0;
	g_pats[g_pat_count].first = 0;
	g_pats[g_pat_count].first2 = 0;
	g_pats[g_pat_count].has_dol = 0;
	g_pat_count++;
	return 0;
}

/* Call once after argv parse (when -i / -F / -E are known). */
void grep_prepare(void)
{
	unsigned char i;
	unsigned char j;
	grep_pat_t *p;
	unsigned char c;

	for (i = 0; i < g_pat_count; i++)
	{
		p = &g_pats[i];
		p->literal = pattern_is_literal(p->text);
		p->has_dol = 0;
		for (j = 0; j < p->len; j++)
		{
			if (p->text[j] == '$')
			{
				p->has_dol = 1;
				break;
			}
		}
		if (p->len > 0)
		{
			c = p->text[0];
			if (g_opts.ignore_case)
			{
				p->first = fold_ch(c);
				p->first2 = other_case(c);
				/* Fold whole literal pattern once for fast -i compare. */
				if (p->literal)
				{
					for (j = 0; j < p->len; j++)
					{
						p->text[j] = fold_ch(p->text[j]);
					}
				}
			}
			else
			{
				p->first = c;
				p->first2 = 0;
			}
		}
	}
}

/*
 * Fixed / literal search: first-byte filter, then compare.
 * Pattern already folded when -i (see grep_prepare).
 */
static int fixed_find(const unsigned char *line, unsigned int len,
                      const grep_pat_t *pat, unsigned int from,
                      grep_span_t *out)
{
	unsigned int plen;
	unsigned int i;
	unsigned int j;
	unsigned char first;
	unsigned char first2;
	unsigned char c;
	const unsigned char *ptext;

	plen = pat->len;
	if (plen == 0 || from + plen > len)
	{
		return 0;
	}
	ptext = pat->text;
	first = pat->first;
	first2 = pat->first2;

	if (!g_opts.ignore_case)
	{
		for (i = from; i + plen <= len; i++)
		{
			if (line[i] != first)
			{
				continue;
			}
			for (j = 1; j < plen; j++)
			{
				if (line[i + j] != ptext[j])
				{
					goto next_cs;
				}
			}
			if (g_opts.whole_word)
			{
				if (i > 0 && grep_is_word_char(line[i - 1]))
				{
					goto next_cs;
				}
				if (i + plen < len && grep_is_word_char(line[i + plen]))
				{
					goto next_cs;
				}
			}
			if (out != 0)
			{
				out->start = i;
				out->len = plen;
			}
			return 1;
next_cs:
			;
		}
		return 0;
	}

	/* -i: pattern text is lowercased; fold line bytes while comparing. */
	for (i = from; i + plen <= len; i++)
	{
		c = line[i];
		if (c != first && c != first2 && fold_ch(c) != first)
		{
			continue;
		}
		for (j = 1; j < plen; j++)
		{
			if (fold_ch(line[i + j]) != ptext[j])
			{
				goto next_ci;
			}
		}
		if (g_opts.whole_word)
		{
			if (i > 0 && grep_is_word_char(line[i - 1]))
			{
				goto next_ci;
			}
			if (i + plen < len && grep_is_word_char(line[i + plen]))
			{
				goto next_ci;
			}
		}
		if (out != 0)
		{
			out->start = i;
			out->len = plen;
		}
		return 1;
next_ci:
		;
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
			lo = g_opts.ignore_case ? fold_ch(p[0]) : p[0];
			hi = g_opts.ignore_case ? fold_ch(p[2]) : p[2];
			{
				unsigned char fc;

				fc = g_opts.ignore_case ? fold_ch(c) : c;
				if (fc >= lo && fc <= hi)
				{
					found = 1;
				}
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
                                       const unsigned char *p, const unsigned char *p_end);

static const unsigned char *match_star(const unsigned char *s, const unsigned char *end,
                                       const unsigned char *p, const unsigned char *p_end,
                                       const unsigned char *atom,
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
			t = match_here(s, end, p, p_end);
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
		t = match_here(s, end, atom, p_end);
		if (t == 0 || t == s)
		{
			break;
		}
		s = t;
		n++;
	}
	if (n >= min && best != 0)
	{
		return match_here(best, end, p, p_end);
	}
	return 0;
}

static const unsigned char *match_piece(const unsigned char *s, const unsigned char *end,
                                        const unsigned char **pp, const unsigned char *p_end)
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
			return match_star(s, end, *pp, p_end, atom, 0, 65535);
		}
		if (*p == '+')
		{
			(*pp) = p + 1;
			return match_star(s, end, *pp, p_end, atom, 1, 65535);
		}
		if (*p == '?')
		{
			(*pp) = p + 1;
			return match_star(s, end, *pp, p_end, atom, 0, 1);
		}
		(*pp) = p;
		return match_here(s, end, atom, p);
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
			return match_star(s + 1, end, *pp, p_end, atom, 0, 65535);
		}
		if (ext && *p == '+')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, p_end, atom, 1, 65535);
		}
		if (ext && *p == '?')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, p_end, atom, 0, 1);
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
		atom = cls;
		if (*p == '*')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, p_end, atom, 0, 65535);
		}
		if (ext && *p == '+')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, p_end, atom, 1, 65535);
		}
		if (ext && *p == '?')
		{
			(*pp) = p + 1;
			return match_star(s + 1, end, *pp, p_end, atom, 0, 1);
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

	if (*p == 0 || p >= p_end)
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
		return match_star(s + 1, end, *pp, p_end, atom, 0, 65535);
	}
	if (ext && *p == '+')
	{
		(*pp) = p + 1;
		return match_star(s + 1, end, *pp, p_end, atom, 1, 65535);
	}
	if (ext && *p == '?')
	{
		(*pp) = p + 1;
		return match_star(s + 1, end, *pp, p_end, atom, 0, 1);
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
		if (g_opts.regex_mode == GREP_MODE_EXTENDED && (*p == '|' || *p == ')'))
		{
			break;
		}
		pp = p;
		t = match_piece(s, end, &pp, p_end);
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
                                       const unsigned char *p, const unsigned char *p_end)
{
	const unsigned char *best;
	const unsigned char *t;
	const unsigned char *q;

	if (g_opts.regex_mode != GREP_MODE_EXTENDED)
	{
		return match_branch(s, end, p, p_end);
	}

	best = 0;
	q = p;
	while (1)
	{
		t = match_branch(s, end, q, p_end);
		if (t != 0 && (best == 0 || t > best))
		{
			best = t;
		}
		while (q < p_end && *q != '|')
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
		if (q >= p_end || *q != '|')
		{
			break;
		}
		q++;
	}
	return best;
}

static int regex_match_span(const unsigned char *line, unsigned int len,
                            const grep_pat_t *pat, unsigned int from,
                            grep_span_t *out)
{
	const unsigned char *end;
	const unsigned char *p;
	const unsigned char *p_end;
	const unsigned char *t;
	unsigned int i;
	unsigned int i_last;
	unsigned char anchored;

	end = line + len;
	p = pat->text;
	p_end = p + pat->len;
	anchored = (*p == '^') ? 1 : 0;

	if (anchored)
	{
		if (from != 0)
		{
			return 0;
		}
		i = 0;
		i_last = 0;
	}
	else
	{
		i = from;
		i_last = len;
	}

	for (; i <= i_last; i++)
	{
		p = pat->text;
		if (anchored)
		{
			p++;
		}
		t = match_here(line + i, end, p, p_end);
		if (t == 0)
		{
			continue;
		}
		if (pat->has_dol)
		{
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
                           const grep_pat_t *pat, unsigned int from,
                           grep_span_t *out)
{
	grep_span_t span;
	int hit;

	if (pat->literal)
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
	grep_span_t best;
	unsigned char found;

	found = 0;
	best.start = 0;
	best.len = 0;

	/* -x: only a full-line hit counts; try each pattern once from 0. */
	if (g_opts.whole_line && from != 0)
	{
		return 0;
	}

	for (i = 0; i < g_pat_count; i++)
	{
		local.start = 0;
		local.len = 0;
		if (pattern_matches(line, len, &g_pats[i], from, &local))
		{
			if (!found || local.start < best.start ||
			    (local.start == best.start && local.len > best.len))
			{
				best = local;
				found = 1;
			}
		}
	}
	if (found && out != 0)
	{
		*out = best;
	}
	return found;
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
