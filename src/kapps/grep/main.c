#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include "grep.h"

#define FS_OPEN 0x80u

static unsigned char g_show_name;
static fileInfo g_finfo;

static unsigned char g_line[GREP_LINE_LEN + 1];
static unsigned char g_ctx_buf[GREP_CTX_MAX][GREP_LINE_LEN + 1];
static unsigned char g_ctx_len[GREP_CTX_MAX];
static unsigned int  g_ctx_pos;
static unsigned int  g_ctx_fill;
static unsigned int  g_after_left;
static unsigned char g_need_sep;

static unsigned char g_pathbuf[GREP_PATH_LEN];
static unsigned char g_files[GREP_MAX_PATTERNS][GREP_PATH_LEN + 1];
static unsigned char g_file_count;
static unsigned char g_tokbuf[GREP_PATH_LEN + 1];

static void usage(void)
{
	printf("Usage: grep [OPTIONS] PATTERN [FILE...]\r\n");
	printf("       grep [OPTIONS] -e PATTERN ... [FILE...]\r\n");
	printf("       grep [OPTIONS] -f FILE [FILE...]\r\n");
	printf("Options:\r\n");
	printf("  -E  extended regex (egrep)\r\n");
	printf("  -F  fixed strings\r\n");
	printf("  -G  basic regex (default)\r\n");
	printf("  -e PATTERN  add pattern\r\n");
	printf("  -f FILE     patterns from file\r\n");
	printf("  -i  ignore case\r\n");
	printf("  -v  invert match\r\n");
	printf("  -x  whole line\r\n");
	printf("  -w  whole word\r\n");
	printf("  -n  line numbers\r\n");
	printf("  -c  count matches\r\n");
	printf("  -l  list matching files\r\n");
	printf("  -L  list non-matching files\r\n");
	printf("  -o  only matching part\r\n");
	printf("  -q  quiet (exit status only)\r\n");
	printf("  -s  suppress errors\r\n");
	printf("  -h  no filename prefix\r\n");
	printf("  -H  always show filename\r\n");
	printf("  -a  treat binary as text\r\n");
	printf("  -b  byte offset\r\n");
	printf("  -m NUM  max matches per file\r\n");
	printf("  -A NUM  lines after match\r\n");
	printf("  -B NUM  lines before match\r\n");
	printf("  -C NUM  context lines\r\n");
	printf("  -r -R  recursive\r\n");
	printf("  -N  no color (disable ESC sequences)\r\n");
}

static int add_file_arg(const unsigned char *name)
{
	unsigned int i;

	if (g_file_count >= GREP_MAX_PATTERNS)
	{
		return -1;
	}
	for (i = 0; i < GREP_PATH_LEN && name[i] != 0; i++)
	{
		g_files[g_file_count][i] = name[i];
	}
	g_files[g_file_count][i] = 0;
	g_file_count++;
	return 0;
}

static int parse_num(const char *s, unsigned int *out)
{
	unsigned long v;

	if (s == 0 || s[0] == 0)
	{
		return -1;
	}
	v = (unsigned long)atoi(s);
	*out = (unsigned int)v;
	return 0;
}

static unsigned char is_quote_ch(unsigned char c)
{
	return (c == '"' || c == '\'');
}

/* Some NedoOS shells may pass tokens with leading/trailing quotes unchanged.
 * Trim them so `grep "foo" file` works like in unix. */
static unsigned char *token_trim_quotes(const char *in)
{
	unsigned int len;
	unsigned char q;
	unsigned int j;

	len = 0;
	while (in[len] != 0 && len < GREP_PATH_LEN)
	{
		g_tokbuf[len] = (unsigned char)in[len];
		len++;
	}
	g_tokbuf[len] = 0;

	if (len >= 2)
	{
		q = g_tokbuf[0];
		if (is_quote_ch(q) && g_tokbuf[len - 1] == q)
		{
			for (j = 0; j < (len - 2); j++)
			{
				g_tokbuf[j] = g_tokbuf[j + 1];
			}
			g_tokbuf[len - 2] = 0;
		}
	}

	return g_tokbuf;
}

static int parse_args(int argc, char *argv[])
{
	int i;
	char *a;
	char c;
	unsigned int num;
	unsigned char need_pat;
	unsigned char seen_e;

	need_pat = 1;
	seen_e = 0;
	memset(&g_opts, 0, sizeof(g_opts));
	g_opts.regex_mode = GREP_MODE_BASIC;

	for (i = 1; i < argc; i++)
	{
		a = argv[i];
		if (a == 0)
		{
			continue;
		}
		if (strcmp(a, "--") == 0)
		{
			for (i++; i < argc; i++)
			{
				if (add_file_arg(token_trim_quotes(argv[i])) != 0)
				{
					return -1;
				}
			}
			break;
		}
		if (a[0] != '-' && a[0] != '/')
		{
			unsigned char *t;
			t = token_trim_quotes(a);
			if (need_pat && !seen_e && g_pat_count == 0)
			{
				if (grep_add_pattern(t) != 0)
				{
					return -1;
				}
				need_pat = 0;
			}
			else
			{
				if (add_file_arg(t) != 0)
				{
					return -1;
				}
			}
			continue;
		}
		a++;
		if (*a == 0)
		{
			return -1;
		}
		while (*a)
		{
			c = *a++;
			switch (c)
			{
			case 'E':
				g_opts.regex_mode = GREP_MODE_EXTENDED;
				break;
			case 'F':
				g_opts.regex_mode = GREP_MODE_FIXED;
				break;
			case 'G':
				g_opts.regex_mode = GREP_MODE_BASIC;
				break;
			case 'H':
				g_opts.force_name = 1;
				break;
			case 'L':
				g_opts.list_nomatch = 1;
				break;
			case 'R':
				g_opts.recursive = 1;
				break;
			case 'A':
			case 'B':
			case 'C':
				if (*a == 0)
				{
					if (++i >= argc || parse_num(argv[i], &num) != 0)
					{
						return -1;
					}
				}
				else
				{
					if (parse_num(a, &num) != 0)
					{
						return -1;
					}
					a = "";
				}
				if (num > GREP_CTX_MAX)
				{
					num = GREP_CTX_MAX;
				}
				if (c == 'A')
				{
					g_opts.ctx_after = num;
				}
				else if (c == 'B')
				{
					g_opts.ctx_before = num;
				}
				else
				{
					g_opts.ctx_before = num;
					g_opts.ctx_after = num;
				}
				break;
			case 'e':
				if (*a == 0)
				{
					if (++i >= argc)
					{
						return -1;
					}
					if (grep_add_pattern(token_trim_quotes(argv[i])) != 0)
					{
						return -1;
					}
				}
				else
				{
					if (grep_add_pattern(token_trim_quotes(a)) != 0)
					{
						return -1;
					}
					a = "";
				}
				seen_e = 1;
				need_pat = 0;
				break;
			case 'f':
				if (*a == 0)
				{
					if (++i >= argc)
					{
						return -1;
					}
					if (grep_load_patterns_file(token_trim_quotes(argv[i])) != 0)
					{
						return -1;
					}
				}
				else
				{
					if (grep_load_patterns_file(token_trim_quotes(a)) != 0)
					{
						return -1;
					}
					a = "";
				}
				need_pat = 0;
				break;
			case 'm':
				if (*a == 0)
				{
					if (++i >= argc || parse_num(argv[i], &num) != 0)
					{
						return -1;
					}
				}
				else
				{
					if (parse_num(a, &num) != 0)
					{
						return -1;
					}
					a = "";
				}
				g_opts.max_match = num;
				break;
			case 'a':
				g_opts.text_binary = 1;
				break;
			case 'b':
				g_opts.byte_offset = 1;
				break;
			case 'c':
				g_opts.count_only = 1;
				break;
			case 'h':
				g_opts.no_name = 1;
				break;
			case 'i':
				g_opts.ignore_case = 1;
				break;
			case 'l':
				g_opts.list_match = 1;
				break;
			case 'n':
				g_opts.line_num = 1;
				break;
			case 'N':
				g_opts.no_color = 1;
				break;
			case 'o':
				g_opts.only_match = 1;
				break;
			case 'q':
				g_opts.quiet = 1;
				break;
			case 'r':
				g_opts.recursive = 1;
				break;
			case 's':
				g_opts.silent = 1;
				break;
			case 'v':
				g_opts.invert = 1;
				break;
			case 'w':
				g_opts.whole_word = 1;
				break;
			case 'x':
				g_opts.whole_line = 1;
				break;
			default:
				return -1;
			}
		}
	}
	if (g_pat_count == 0)
	{
		return -1;
	}
	return 0;
}

static void ctx_reset(void)
{
	g_ctx_pos = 0;
	g_ctx_fill = 0;
	g_after_left = 0;
	g_need_sep = 0;
}

static void ctx_push(const unsigned char *line, unsigned int len)
{
	unsigned int i;
	unsigned int slot;

	if (g_opts.ctx_before == 0)
	{
		return;
	}
	slot = g_ctx_pos % GREP_CTX_MAX;
	if (len > GREP_LINE_LEN)
	{
		len = GREP_LINE_LEN;
	}
	for (i = 0; i < len; i++)
	{
		g_ctx_buf[slot][i] = line[i];
	}
	g_ctx_buf[slot][len] = 0;
	g_ctx_len[slot] = (unsigned char)len;
	g_ctx_pos++;
	if (g_ctx_fill < GREP_CTX_MAX)
	{
		g_ctx_fill++;
	}
}

void TSETCOLOR(unsigned char fg, unsigned char bg)
{
	unsigned char fgc;
	unsigned char bgc;

	if (g_opts.no_color)
	{
		return;
	}
	if (fg < 8)
	{
		fgc = (unsigned char)(30 + fg);
	}
	else
	{
		fgc = (unsigned char)(90 + (fg & 7));
	}
	bgc = (unsigned char)(40 + (bg & 7));
	putchar(27);
	putchar('[');
	putchar('0' + (char)(fgc / 10));
	putchar('0' + (char)(fgc % 10));
	putchar(';');
	putchar('0' + (char)(bgc / 10));
	putchar('0' + (char)(bgc % 10));
	putchar('m');
}

static void print_prefix(const unsigned char *fname, unsigned long line_no, unsigned long byte_off)
{
	if (g_show_name && fname != 0)
	{
		printf("%s:", fname);
	}
	if (g_opts.byte_offset)
	{
		printf("%lu:", byte_off);
	}
	if (g_opts.line_num)
	{
		printf("%lu:", line_no);
	}
}

static void print_chars(const unsigned char *p, unsigned int n)
{
	unsigned int i;

	for (i = 0; i < n; i++)
	{
		putchar((char)p[i]);
	}
}

static void print_line_body(const unsigned char *line, unsigned int len)
{
	print_chars(line, len);
	printf("\r\n");
}

/* White line text, yellow match spans (all occurrences). No-op colors with -N. */
static void print_line_highlighted(const unsigned char *line, unsigned int len)
{
	unsigned int pos;
	grep_span_t span;

	if (g_opts.no_color || g_opts.invert || len == 0)
	{
		print_line_body(line, len);
		return;
	}

	pos = 0;
	TSETCOLOR(WHITE, BLACK);
	while (grep_find_match(line, len, pos, &span))
	{
		if (span.start < pos || span.start > len)
		{
			break;
		}
		if (span.start > pos)
		{
			print_chars(line + pos, span.start - pos);
		}
		if (span.len > 0 && span.start + span.len <= len)
		{
			TSETCOLOR(BRYELLOW, BLACK);
			print_chars(line + span.start, span.len);
			TSETCOLOR(WHITE, BLACK);
			pos = span.start + span.len;
		}
		else
		{
			/* empty match: advance one char to avoid infinite loop */
			if (span.start < len)
			{
				print_chars(line + span.start, 1);
			}
			pos = span.start + 1;
		}
		if (pos >= len)
		{
			break;
		}
	}
	if (pos < len)
	{
		print_chars(line + pos, len - pos);
	}
	printf("\r\n");
}

static void print_ctx_before(unsigned long line_no)
{
	unsigned int i;
	unsigned int start;
	unsigned int slot;

	if (g_opts.ctx_before == 0)
	{
		return;
	}
	if (g_need_sep)
	{
		printf("--\r\n");
	}
	start = 0;
	if (g_ctx_fill > g_opts.ctx_before)
	{
		start = g_ctx_fill - g_opts.ctx_before;
	}
	for (i = start; i < g_ctx_fill; i++)
	{
		slot = (g_ctx_pos - g_ctx_fill + i) % GREP_CTX_MAX;
		print_prefix(0, 0, 0);
		if (g_show_name)
		{
			printf("-");
		}
		if (g_opts.line_num)
		{
			printf("%lu-", line_no > (unsigned long)(i + 1) ? line_no - (g_ctx_fill - i) : 1UL);
		}
		print_line_body(g_ctx_buf[slot], g_ctx_len[slot]);
	}
}

static void print_match_line(const unsigned char *fname, const unsigned char *line,
                             unsigned int len, unsigned long line_no, unsigned long byte_off)
{
	grep_span_t span;
	unsigned int pos;

	if (g_opts.quiet || g_opts.list_match || g_opts.list_nomatch)
	{
		return;
	}
	if (g_opts.count_only)
	{
		return;
	}
	if (g_opts.only_match)
	{
		pos = 0;
		while (grep_find_match(line, len, pos, &span))
		{
			print_prefix(fname, line_no, byte_off + span.start);
			if (!g_opts.no_color)
			{
				TSETCOLOR(BRYELLOW, BLACK);
			}
			print_line_body(line + span.start, span.len);
			if (!g_opts.no_color)
			{
				TSETCOLOR(WHITE, BLACK);
			}
			pos = span.start + span.len;
			if (pos >= len || span.len == 0)
			{
				break;
			}
		}
		return;
	}
	print_ctx_before(line_no);
	print_prefix(fname, line_no, byte_off);
	print_line_highlighted(line, len);
	if (g_opts.ctx_after > 0)
	{
		g_after_left = g_opts.ctx_after;
	}
	g_need_sep = 1;
}

static int grep_stream(FILE *fp, const unsigned char *fname, unsigned char *binary)
{
	unsigned int pos;
	unsigned int got;
	unsigned long line_no;
	unsigned long byte_off;
	unsigned long match_count;
	unsigned char hit;
	unsigned char carry;
	unsigned char empty_spins;
	static unsigned char chunk[GREP_READ_CHUNK];

	pos = 0;
	line_no = 0;
	byte_off = 0;
	match_count = 0;
	carry = 0;
	empty_spins = 0;
	ctx_reset();

	for (;;)
	{
		got = OS_READHANDLE_STATUS(chunk, fp, GREP_READ_CHUNK);
		if (got == 0xffffu)
		{
			/* BDOS EOF/error (pipe writer closed, or real file EOF). */
			break;
		}
		if (got == 0)
		{
			/*
			 * Empty pipe, writer still open.
			 * Busy-retry like more.com (preemption runs the writer);
			 * YIELD every so often to avoid starving the system.
			 */
			if (++empty_spins >= 32)
			{
				empty_spins = 0;
				YIELD();
			}
			continue;
		}
		empty_spins = 0;
		{
			unsigned int i;
			for (i = 0; i < got; i++)
			{
				unsigned char c;

				c = chunk[i];
				if (!g_opts.text_binary && c == 0)
				{
					*binary = 1;
				}
				if (c == '\n')
				{
					g_line[pos] = 0;
					line_no++;
					hit = (unsigned char)grep_find_match(g_line, pos, 0, 0);
					if (g_opts.invert)
					{
						hit = (unsigned char)!hit;
					}
					if (hit)
					{
						match_count++;
						print_match_line(fname, g_line, pos, line_no, byte_off);
						g_any_match = 1;
						if (g_opts.max_match != 0 && match_count >= g_opts.max_match)
						{
							return 1;
						}
					}
					else if (g_after_left > 0)
					{
						if (!g_opts.quiet && !g_opts.count_only && !g_opts.list_match)
						{
							print_prefix(fname, line_no, byte_off);
							if (g_show_name)
							{
								printf("-");
							}
							print_line_body(g_line, pos);
						}
						g_after_left--;
					}
					else
					{
						ctx_push(g_line, pos);
					}
					byte_off += (unsigned long)pos + 1;
					if (carry && c == '\n')
					{
						byte_off++;
					}
					carry = 0;
					pos = 0;
					continue;
				}
				if (c == '\r')
				{
					carry = 1;
					continue;
				}
				if (pos < GREP_LINE_LEN)
				{
					g_line[pos++] = c;
				}
			}
		}
	}
	if (pos > 0 || carry)
	{
		g_line[pos] = 0;
		line_no++;
		hit = (unsigned char)grep_find_match(g_line, pos, 0, 0);
		if (g_opts.invert)
		{
			hit = (unsigned char)!hit;
		}
		if (hit)
		{
			match_count++;
			print_match_line(fname, g_line, pos, line_no, byte_off);
			g_any_match = 1;
		}
	}
	if (!g_opts.quiet)
	{
		if (g_opts.count_only)
		{
			if (g_show_name && fname != 0)
			{
				printf("%s:", fname);
			}
			printf("%lu\r\n", match_count);
		}
	}
	return (match_count > 0);
}

static int grep_file(const unsigned char *path)
{
	FILE *fp;
	unsigned char binary;
	int matched;

	fp = OS_OPENHANDLE((unsigned char *)path, FS_OPEN);
	if (((int)fp) & 0xff)
	{
		if (!g_opts.silent)
		{
			printf("grep: %s: cannot open\r\n", path);
		}
		g_any_error = 1;
		return -1;
	}
	binary = 0;
	matched = grep_stream(fp, path, &binary);
	OS_CLOSEHANDLE(fp);

	if (binary && !g_opts.text_binary && matched)
	{
		if (!g_opts.quiet && !g_opts.count_only && g_opts.list_match)
		{
			printf("grep: %s: binary file matches\r\n", path);
		}
	}
	if (g_opts.list_match && matched)
	{
		if (!g_opts.quiet)
		{
			printf("%s\r\n", path);
		}
		g_any_match = 1;
	}
	if (g_opts.list_nomatch && !matched)
	{
		if (!g_opts.quiet)
		{
			printf("%s\r\n", path);
		}
	}
	return matched;
}

/* stdin = app handle already remapped by cmd/term (| or <). */
static int grep_stdin(void)
{
	unsigned int hs;
	unsigned char hin;
	FILE *fp;
	unsigned char binary;
	int matched;

	hs = OS_GETSTDINOUT();
	hin = (unsigned char)hs;
	/* Same packing as OS_OPENHANDLE: handle in high byte, error 0 in low. */
	fp = (FILE *)(((unsigned int)hin) << 8);

	binary = 0;
	matched = grep_stream(fp, 0, &binary);
	OS_CLOSEHANDLE(fp);

	if (g_opts.list_match && matched)
	{
		if (!g_opts.quiet)
		{
			printf("(standard input)\r\n");
		}
		g_any_match = 1;
	}
	if (g_opts.list_nomatch && !matched)
	{
		if (!g_opts.quiet)
		{
			printf("(standard input)\r\n");
		}
	}
	return matched;
}

static unsigned char path_is_dir(const unsigned char *path)
{
	if (OS_GETFILINFO((unsigned char *)path, (FILINFO *)&g_finfo) != 0)
	{
		return 0;
	}
	return (g_finfo.fattrib & 0x10) ? 1 : 0;
}

static int grep_dir_recursive(const unsigned char *dir)
{
	unsigned char local[64];
	unsigned char result;
	unsigned char is_dir;
	unsigned int plen;
	unsigned int dlen;

	if (OS_CHDIR((unsigned char *)dir) != 0)
	{
		if (!g_opts.silent)
		{
			printf("grep: %s: cannot chdir\r\n", dir);
		}
		g_any_error = 1;
		return -1;
	}
	OS_OPENDIR("");
	while (1)
	{
		result = OS_READDIR(&g_finfo);
		if (result == 4 || result != 0)
		{
			break;
		}
		if (g_finfo.fname[0] == '.')
		{
			if (g_finfo.fname[1] == 0 || (g_finfo.fname[1] == '.' && g_finfo.fname[2] == 0))
			{
				continue;
			}
		}
		if (g_finfo.lfname[0] != 0)
		{
			strcpy((char *)local, (char *)g_finfo.lfname);
		}
		else
		{
			strcpy((char *)local, (char *)g_finfo.fname);
		}
		is_dir = (g_finfo.fattrib & 0x10) ? 1 : 0;
		plen = (unsigned int)strlen((char *)g_pathbuf);
		dlen = (unsigned int)strlen((char *)local);
		if (plen > 0 && g_pathbuf[plen - 1] != '/' && g_pathbuf[plen - 1] != '\\')
		{
			if (plen + 1 < GREP_PATH_LEN)
			{
				g_pathbuf[plen++] = '/';
				g_pathbuf[plen] = 0;
			}
		}
		if (plen + dlen >= GREP_PATH_LEN)
		{
			continue;
		}
		strcat((char *)g_pathbuf, (char *)local);
		if (is_dir)
		{
			grep_dir_recursive(local);
			OS_CHDIR((unsigned char *)"..");
			OS_CHDIR((unsigned char *)dir);
		}
		else
		{
			g_files_total++;
			grep_file(g_pathbuf);
		}
		g_pathbuf[plen] = 0;
	}
	OS_CHDIR((unsigned char *)"..");
	return 0;
}

static int grep_path(const unsigned char *path)
{
	if (path_is_dir(path))
	{
		if (g_opts.recursive)
		{
			strcpy((char *)g_pathbuf, (char *)path);
			return grep_dir_recursive(path);
		}
		if (!g_opts.silent)
		{
			printf("grep: %s: is a directory\r\n", path);
		}
		g_any_error = 1;
		return -1;
	}
	g_files_total++;
	return grep_file(path);
}

C_task main(int argc, char *argv[])
{
	unsigned char i;
	int rc;

	os_initstdio();
	g_any_match = 0;
	g_any_error = 0;
	g_file_count = 0;
	g_files_total = 0;
	g_pathbuf[0] = 0;

	if (parse_args(argc, argv) != 0)
	{
		usage();
		exit(2);
	}
	grep_prepare();

	if (g_file_count == 0)
	{
		g_file_count = 1;
		g_files[0][0] = 0;
	}
	g_show_name = 0;
	if (!g_opts.no_name)
	{
		if (g_opts.force_name || g_opts.recursive || g_file_count > 1)
		{
			g_show_name = 1;
		}
	}

	for (i = 0; i < g_file_count; i++)
	{
		if (g_files[i][0] == 0)
		{
			grep_stdin();
			continue;
		}
		grep_path(g_files[i]);
	}

	if (g_any_error)
	{
		rc = 2;
	}
	else if (g_any_match)
	{
		rc = 0;
	}
	else
	{
		rc = 1;
	}
	exit(rc);
	return 0;
}
