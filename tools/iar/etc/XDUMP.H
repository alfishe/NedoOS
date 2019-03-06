/*                              - xdump.h -

  Header for XDUMP.

  Created 961104 by Grzm.

  (c) Copyright IAR Systems 1996.

  $Id: xdump.h 1.6 1997/08/06 11:44:25 Grzm Exp $
  $Log: xdump.h $
  Revision 1.6  1997/08/06 11:44:25  Grzm
  Useless NEAR/FAR/HUGE memory types removed.
  Revision 1.5  1997/04/02 11:39:25  Grzm
  SIMPLE version 2 adds start address.
  Revision 1.4  1996/12/02 13:09:24  Grzm
  A little more cleanup.
  Revision 1.3  1996/11/05 13:15:06  Grzm
  Minor mods to the comments.
  Revision 1.2  1996/11/05 11:54:07  Grzm
  Clean up a little.
  Revision 1.1  1996/11/05 09:41:40  Grzm
  Initial revision
                                                                              */

/*

The SIMPLE absolute object file format:

All integers in the file are represented as 4 bytes, in big-endian order;
that is, the most significant byte first.  In this description, they are
called Int32.

Strings are represented as an integer length, followed by the characters in
the string, one per byte.

The file has the following structure:

  Segment info section:
  ---------------------

    Magic number          Int32       Must be 0x18167829.
    Format version        Int32       Currently version 2.

    The next two fields only exist in version 2 of SIMPLE.

    Start address valid   Int32       Non-zero if the next field is valid.
    Start address         Int32       The start address of the program.

    Number of segments    Int32

      For each segment:

      Name                String
      Type                Int32       See below for the memory types.
      Address             Int32       The logical (program visible) address of
                                      the segment.
      Size                Int32       The length of the segment.
      Number of blocks    Int32       The number of blocks of raw data for this
                                      segment.

        For each block:

        Address           Int32       The address at which to put the raw data.
        Offset            Int32       The offset into the raw data bytes at
                                      which the raw data for this block starts.
                                      Offset 0 is the first raw data byte.
        Size              Int32       The number of bytes of raw data for this
                                      block.

  Raw data section:
  -----------------

    Size of raw data      Int32       The total number of bytes of raw data.
    Raw data                          The raw data bytes.


The defined memory types are:

   0   UNTYPED
   1   CODE
   2   DATA             IDATA0 for 65000
   3   XDATA            NPAGE for 740, 6502
   4   IDATA            IDATA1 for 65000
   5   BIT
   7   CONST

These are the identifiers given within parentheses to XLINK in the -Z, -b
and -P command line options, except that FARCODE, HUGECODE and NEARCODE are
all mapped to CODE, and similarly for CONST and DATA.

*/

#define TRUE  1
#define FALSE 0
typedef int BOOL;

#define SIMPLE_MAGIC 0x18167829

struct start_address_info
  {
    BOOL valid;               /* FALSE if the start address is not valid. */
    unsigned long address;    /* The actual address, if valid is not FALSE. */
  };

/* Information about one segment. */
struct segment_info
  {
    char *name;
    unsigned long type;       /* See above. */
    unsigned long addr;       /* The address in memory of the segment. */
    unsigned long adr_size;   /* The size of the segment. */
    unsigned long nraw;       /* The number of raw_offset structs. */
    struct raw_offset
      {
        unsigned long addr;   /* Raw data for this address */
        unsigned long offs;   /* is at this offset in the raw data, */
        unsigned long size;   /* and has this size. */
      } *raw;                 /* A pointer to an array of raw_offset structs. */
  };

/* Args like printf.  Print a message and then die. */
extern void fatal(const char *fmt, ...);

/* A library routine has just failed.  Use perror and then die. */
extern void syserr(const char *msg);

/* "Safe" malloc.  Die rather than return NULL. */
extern void *salloc(size_t size);

/* Do the dumping. */
extern void dump(struct start_address_info *start,
                 struct segment_info *segs,
                 unsigned long nsegs,
                 char *data,
                 unsigned long nbytes);
