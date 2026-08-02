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

extern grep_opts_t g_opts;
extern unsigned char g_patterns[GREP_MAX_PATTERNS][GREP_PATTERN_LEN + 1];
extern unsigned char g_pat_count;
extern unsigned char g_any_match;
extern unsigned char g_any_error;
extern unsigned int  g_files_total;

int  grep_add_pattern(const unsigned char *pat);
int  grep_load_patterns_file(const unsigned char *path);
int  grep_line_matches(const unsigned char *line, unsigned int len);
int  grep_find_match(const unsigned char *line, unsigned int len,
                     unsigned int from, grep_span_t *out);
unsigned char grep_is_word_char(unsigned char c);

#endif
