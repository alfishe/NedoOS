/*                              - xdump.c -

  Read the SIMPLE format.

  Created 961104 by Grzm.

  (c) Copyright IAR Systems 1996.

  $Id: xdump.c 1.4 1997/04/02 11:39:25 Grzm Exp $
  $Log: xdump.c $
  Revision 1.4  1997/04/02 11:39:25  Grzm
  SIMPLE version 2 adds start address.
  Revision 1.3  1996/12/02 13:09:23  Grzm
  A little more cleanup.
  Revision 1.2  1996/11/05 13:15:06  Grzm
  Minor mods to the comments.
  Revision 1.1  1996/11/05 09:41:37  Grzm
  Initial revision
                                                                              */

#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include "xdump.h"

void
fatal(const char *fmt, ...)
  {
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    fputc('\n', stderr);
    exit(EXIT_FAILURE);
  }

void
syserr(const char *msg)
  {
    perror(msg);
    exit(EXIT_FAILURE);
  }

void *
salloc(size_t size)
  {
    void *ptr = malloc(size);
    if (!ptr)
      fatal("Out of memory");
    return ptr;
  }

/* Read `n' bytes into `buf' from the file `in'. Die if it didn't work. */
static
void
read_bytes(char *buf, unsigned long n, FILE *in)
  {
    size_t nin = fread(buf, 1, n, in);

    if (nin != n)
      if (feof(in))
        fatal("Unexpected end of file");
      else
        syserr("Error reading input file");
  }

/* Get four bytes from the file `in' and make a 32-bit unsigned integer. */
static
unsigned long
get_long(FILE *in)
  {
    unsigned char buf[4];
    unsigned long res;
    read_bytes((char *) buf, sizeof(buf), in);
    res =              buf[0];
    res = (res << 8) | buf[1];
    res = (res << 8) | buf[2];
    res = (res << 8) | buf[3];
    return res;
  }

/* Get a string from the file `in'.  The string is preceded by a
   4-byte length. */
static
char *
get_string(FILE *in)
  {
    unsigned long len = get_long(in);
    char *str = salloc(len + 1);
    read_bytes(str, len, in);
    str[len] = '\0';
    return str;
  }

/* Read information about start address. */
static
void
read_start_address(FILE *in,
                   struct start_address_info *start)
  {
    start->valid   = !!get_long(in);  /* Boolean */
    start->address = get_long(in);
  }

/* Get the segment information from the file. */
static
void
read_segment_info(FILE *in,
                  struct segment_info **segs,
                  unsigned long *nsegs)
  {
    unsigned long n = get_long(in);
    struct segment_info *sp = salloc(sizeof(struct segment_info) * n);
    unsigned long i;

    *nsegs = n;
    *segs = sp;

    for (i = 0; i < n; ++i, ++sp)
      {
        unsigned long j;

        sp->name       = get_string(in);
        sp->type       = get_long(in);
        sp->addr       = get_long(in);
        sp->adr_size   = get_long(in);
        sp->nraw       = get_long(in);
        sp->raw        = salloc(sizeof(struct raw_offset) * sp->nraw);
        for (j = 0; j < sp->nraw; ++j)
          {
            sp->raw[j].addr = get_long(in);
            sp->raw[j].offs = get_long(in);
            sp->raw[j].size = get_long(in);
          }
      }
  }

/* Read the raw data from the file.  All the raw data for all the
   segment is in one block. */
static
void
read_raw_data(FILE *in, char **data, unsigned long *nbytes)
  {
    unsigned long size = get_long(in);
    char *raw_data = salloc(size);
    read_bytes(raw_data, size, in);
    *data = raw_data;
    *nbytes = size;
  }

static
void
read_file(FILE *in,
          struct start_address_info *start,
          struct segment_info **segs,
          unsigned long *nsegs,
          char **data,
          unsigned long *nbytes)
  {
    unsigned long magic;
    unsigned long version;

    magic = get_long(in);
    if (magic != SIMPLE_MAGIC)
      fatal("This is not a SIMPLE file.");
    version = get_long(in);
    switch (version)
      {
      case 2:
        read_start_address(in, start);
        break;
      case 1:
        start->valid = FALSE;
        break;
      default:
        fatal("Unsupported file format version: %lu.", version);
      }
    read_segment_info(in, segs, nsegs);
    read_raw_data(in, data, nbytes);
  }

static
void
usage(void)
  {
    fatal("Usage: xdump infile");
  }

int
main(int argc, char *argv[])
  {
    struct start_address_info start;
    struct segment_info *segs;
    unsigned long nsegs;
    char *data;
    unsigned long nbytes;
    FILE *fin;

    if (argc != 2)
      usage();
    fin = fopen(argv[1], "rb");
    if (!fin)
      fatal("Couldn't open file '%s'", argv[1]);
    read_file(fin, &start, &segs, &nsegs, &data, &nbytes);
    dump(&start, segs, nsegs, data, nbytes);

    return 0;
  }
