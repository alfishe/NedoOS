#ifndef GREP_H
#define GREP_H

#define GREP_MAX_PATTERNS  16
#define GREP_PATTERN_LEN   128
#define GREP_LINE_LEN        512
#define GREP_PATH_LEN        128
#define GREP_CTX_MAX          32
#define GREP_READ_CHUNK      256

#define GREP_MODE_BASIC      0
#define GREP_MODE_EXTENDED   1
#define GREP_MODE_FIXED      2

/* TTY SGR color indices for TSETCOLOR(fg, bg). BR* = bright ink (90-97). */
#define BLACK       0
#define RED         1
#define GREEN       2
#define YELLOW      3
#define BLUE        4
#define MAGENTA     5
#define CYAN        6
#define WHITE       7
#define BRBLACK     8
#define BRRED       9
#define BRGREEN    10
#define BRYELLOW   11
#define BRBLUE     12
#define BRMAGENTA  13
#define BRCYAN     14
#define BRWHITE    15

typedef struct
{
	unsigned char invert;       /* -v */
	unsigned char ignore_case;  /* -i */
	unsigned char whole_line;   /* -x */
	unsigned char whole_word;   /* -w */
	unsigned char line_num;     /* -n */
	unsigned char count_only;   /* -c */
	unsigned char force_name;   /* -H */
	unsigned char no_name;      /* -h */
	unsigned char quiet;        /* -q */
	unsigned char silent;       /* -s */
	unsigned char list_match;   /* -l */
	unsigned char list_nomatch; /* -L */
	unsigned char only_match;   /* -o */
	unsigned char text_binary;  /* -a */
	unsigned char byte_offset;  /* -b */
	unsigned char recursive;    /* -r / -R */
	unsigned char no_color;     /* -N: disable ESC color sequences */
	unsigned char regex_mode;   /* GREP_MODE_* */
	unsigned int  max_match;    /* -m, 0 = unlimited */
	unsigned int  ctx_before;   /* -B */
	unsigned int  ctx_after;    /* -A */
} grep_opts_t;

typedef struct
{
	unsigned int start;
	unsigned int len;
} grep_span_t;

/* Compiled pattern (filled by grep_prepare after argv parse). */
typedef struct
{
	unsigned char text[GREP_PATTERN_LEN + 1];
	unsigned char len;
	unsigned char literal;   /* 1 = byte search, no regex engine */
	unsigned char first;     /* text[0], folded if -i */
	unsigned char first2;    /* other case of first, or 0 if none / not -i */
	unsigned char has_dol;   /* regex: pattern contains '$' */
} grep_pat_t;

extern grep_opts_t g_opts;
extern grep_pat_t g_pats[GREP_MAX_PATTERNS];
extern unsigned char g_pat_count;
extern unsigned char g_any_match;
extern unsigned char g_any_error;
extern unsigned int  g_files_total;

int  grep_add_pattern(const unsigned char *pat);
void grep_prepare(void);
int  grep_load_patterns_file(const unsigned char *path);
int  grep_line_matches(const unsigned char *line, unsigned int len);
int  grep_find_match(const unsigned char *line, unsigned int len,
                     unsigned int from, grep_span_t *out);
unsigned char grep_is_word_char(unsigned char c);

/* Emit ESC[fg;bgm for NedoOS TTY (no-op if g_opts.no_color). */
void TSETCOLOR(unsigned char fg, unsigned char bg);

#endif
