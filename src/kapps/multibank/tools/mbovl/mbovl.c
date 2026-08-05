/*
 * mbovl ? IAR overlay helpers for NedoOS kapps (no Python).
 *
 *   mbovl extract <in.com> <out.bin> [--root-hash <file>]
 *   mbovl check   <root_cout.html> <ovl_cout.html> <sym> [sym...]
 *
 * COM is IAR RAW-BINARY with base address 0x0100; bank window starts at 0x8000.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define COM_BASE  0x0100u
#define BANK_ADDR 0x8000u
#define BANK_OFF  (BANK_ADDR - COM_BASE) /* 0x7F00 */

static void die(const char *msg)
{
	fprintf(stderr, "mbovl: %s\n", msg);
	exit(1);
}

static unsigned char *read_file(const char *path, size_t *out_len)
{
	FILE *f;
	long sz;
	unsigned char *buf;

	f = fopen(path, "rb");
	if (!f)
		die("cannot open input");
	if (fseek(f, 0, SEEK_END) != 0)
		die("seek failed");
	sz = ftell(f);
	if (sz < 0)
		die("ftell failed");
	if (fseek(f, 0, SEEK_SET) != 0)
		die("seek failed");
	buf = (unsigned char *)malloc((size_t)sz + 1u);
	if (!buf)
		die("out of memory");
	if (sz > 0 && fread(buf, 1, (size_t)sz, f) != (size_t)sz)
		die("read failed");
	fclose(f);
	buf[sz] = 0;
	*out_len = (size_t)sz;
	return buf;
}

/* FNV-1a 64-bit fingerprint of root (0100..7FFF) ? detects layout drift. */
static void fnv64_hex(const unsigned char *data, size_t len, char out[17])
{
	unsigned long long h = 14695981039346656037ull;
	size_t i;
	static const char *hexd = "0123456789abcdef";

	for (i = 0; i < len; i++) {
		h ^= (unsigned long long)data[i];
		h *= 1099511628211ull;
	}
	for (i = 0; i < 16; i++) {
		unsigned shift = (unsigned)((15u - (unsigned)i) * 4u);
		out[i] = hexd[(h >> shift) & 0xfull];
	}
	out[16] = 0;
}

static int cmd_extract(int argc, char **argv)
{
	const char *inp;
	const char *outp;
	const char *hash_path = NULL;
	unsigned char *data;
	size_t len, root_len, bank_len;
	unsigned char *bank;
	char digest[17];
	FILE *fo;

	if (argc < 2)
		die("usage: mbovl extract <in.com> <out.bin> [--root-hash <file>]");
	inp = argv[0];
	outp = argv[1];
	if (argc >= 4 && strcmp(argv[2], "--root-hash") == 0)
		hash_path = argv[3];

	data = read_file(inp, &len);
	if (len <= BANK_OFF) {
		fprintf(stderr, "mbovl: COM too small for bank window: %s (%u bytes)\n",
			inp, (unsigned)len);
		return 1;
	}

	root_len = BANK_OFF;
	bank = data + BANK_OFF;
	bank_len = len - BANK_OFF;
	while (bank_len > 1u && bank[bank_len - 1u] == 0)
		bank_len--;

	if (hash_path) {
		char prev[64];
		FILE *hf;

		fnv64_hex(data, root_len, digest);
		prev[0] = 0;
		hf = fopen(hash_path, "r");
		if (hf) {
			if (fgets(prev, (int)sizeof(prev), hf)) {
				char *nl = strchr(prev, '\n');
				if (nl)
					*nl = 0;
				nl = strchr(prev, '\r');
				if (nl)
					*nl = 0;
			}
			fclose(hf);
		}
		if (prev[0] && strcmp(prev, digest) != 0) {
			fprintf(stderr, "ROOT LAYOUT MISMATCH vs %s\n", hash_path);
			fprintf(stderr, "  prev %s\n", prev);
			fprintf(stderr, "  now  %s\n", digest);
			fprintf(stderr, "Bank overlays must not emit data into 0100-7FFF.\n");
			free(data);
			return 1;
		}
		hf = fopen(hash_path, "w");
		if (!hf)
			die("cannot write root-hash file");
		fprintf(hf, "%s\n", digest);
		fclose(hf);
	}

	fo = fopen(outp, "wb");
	if (!fo)
		die("cannot create output");
	if (bank_len && fwrite(bank, 1, bank_len, fo) != bank_len)
		die("write failed");
	fclose(fo);
	printf("%s: %u bytes (root %u + bank from %s)\n",
	       outp, (unsigned)bank_len, (unsigned)root_len, inp);
	free(data);
	return 0;
}

/*
 * Find first ENTRY-LIST style address for symbol name in XLINK HTML map:
 *   <td ...>SYM</td>
 *   <td ...>&nbsp;ABCD&nbsp;</td>
 */
static int find_sym_addr(const char *html, const char *sym, char addr_out[8])
{
	const char *p = html;
	size_t slen = strlen(sym);

	addr_out[0] = 0;
	while ((p = strstr(p, sym)) != NULL) {
		const char *gt;
		const char *nbsp;
		const char *a;
		size_t i;

		/* ensure tag text equals sym (not a longer name) */
		if (p > html && (isalnum((unsigned char)p[-1]) || p[-1] == '_')) {
			p += slen;
			continue;
		}
		gt = strchr(p + slen, '<');
		if (!gt || gt != p + slen) {
			p += slen;
			continue;
		}
		/* next cell with &nbsp;HEX&nbsp; */
		nbsp = strstr(p, "&nbsp;");
		if (!nbsp || nbsp - p > 200) {
			p += slen;
			continue;
		}
		a = nbsp + 6;
		for (i = 0; i < 4 && isxdigit((unsigned char)a[i]); i++)
			addr_out[i] = (char)toupper((unsigned char)a[i]);
		if (i == 4 && strncmp(a + 4, "&nbsp;", 6) == 0) {
			addr_out[4] = 0;
			return 1;
		}
		p += slen;
	}
	return 0;
}

static int cmd_check(int argc, char **argv)
{
	const char *root_path;
	const char *ovl_path;
	unsigned char *root_html;
	unsigned char *ovl_html;
	size_t n1, n2;
	int i, bad = 0;

	if (argc < 3)
		die("usage: mbovl check <root.html> <ovl.html> <sym> [sym...]");
	root_path = argv[0];
	ovl_path = argv[1];

	root_html = read_file(root_path, &n1);
	ovl_html = read_file(ovl_path, &n2);

	for (i = 2; i < argc; i++) {
		char a[8], b[8];
		const char *sym = argv[i];

		if (!find_sym_addr((char *)root_html, sym, a)) {
			fprintf(stderr, "MISSING %s in %s\n", sym, root_path);
			bad = 1;
			continue;
		}
		if (!find_sym_addr((char *)ovl_html, sym, b)) {
			fprintf(stderr, "MISSING %s in %s\n", sym, ovl_path);
			bad = 1;
			continue;
		}
		if (strcmp(a, b) != 0) {
			fprintf(stderr,
				"ADDR DRIFT %s: com=%s ovl=%s (bank CALL would jump wrong)\n",
				sym, a, b);
			bad = 1;
		} else {
			printf("OK %s @ %s\n", sym, a);
		}
	}

	free(root_html);
	free(ovl_html);
	return bad;
}

static int cmd_gen_h(int argc, char **argv)
{
	FILE *fo;
	unsigned n;

	if (argc < 2)
		die("usage: mbovl gen-h <count> <out.h>");
	n = (unsigned)atoi(argv[0]);
	if (n == 0 || n > 99)
		die("bank count must be 1..99");
	fo = fopen(argv[1], "w");
	if (!fo)
		die("cannot write header");
	fprintf(fo, "/* Auto-generated by mbovl from Makefile BANKS - do not edit. */\n");
	fprintf(fo, "#define MB_BANK_COUNT %uu\n", n);
	fclose(fo);
	printf("%s: MB_BANK_COUNT %u\n", argv[1], n);
	return 0;
}

static void usage(void)
{
	fprintf(stderr,
		"mbovl - IAR overlay helpers\n"
		"  mbovl extract <in.com> <out.bin> [--root-hash <file>]\n"
		"  mbovl check   <root.html> <ovl.html> <sym> [sym...]\n"
		"  mbovl gen-h   <count> <out.h>\n");
}

int main(int argc, char **argv)
{
	if (argc < 2) {
		usage();
		return 2;
	}
	if (strcmp(argv[1], "extract") == 0)
		return cmd_extract(argc - 2, argv + 2);
	if (strcmp(argv[1], "check") == 0)
		return cmd_check(argc - 2, argv + 2);
	if (strcmp(argv[1], "gen-h") == 0)
		return cmd_gen_h(argc - 2, argv + 2);
	usage();
	return 2;
}
