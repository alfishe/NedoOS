#ifndef DEFLATE_H
#define DEFLATE_H

#include <osfs.h>

/* Compression profiles (fixed Huffman DEFLATE). */
#define DEFL_FAST 0 /* default: chain1, no lazy */
#define DEFL_RLE  1 /* distance-1 runs only */

/* Old names kept for call sites. */
#define DEFL_L0 DEFL_FAST
#define DEFL_L1 DEFL_FAST

void deflate_set_level(int level);

/*
 * Returns 0 ok, -1 I/O error.
 * If *csize_out >= usize (or early abort), caller should store.
 * *crc_out is always the full uncompressed CRC-32.
 */
int deflate_to_handle(
	FILE *in,
	FILE *out,
	unsigned long usize,
	unsigned long *csize_out,
	unsigned long *crc_out);

#endif
