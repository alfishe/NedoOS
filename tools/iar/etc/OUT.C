/*                              - out.c -

  Output in human readable format.

  Replace this file to do output some other way.

  Created 961104 by Grzm.

  (c) Copyright IAR Systems 1996.

  $Id: out.c 1.4 1997/04/02 11:39:24 Grzm Exp $
  $Log: out.c $
  Revision 1.4  1997/04/02 11:39:24  Grzm
  SIMPLE version 2 adds start address.
  Revision 1.3  1996/12/02 13:09:23  Grzm
  A little more cleanup.
  Revision 1.2  1996/11/05 11:54:05  Grzm
  Clean up a little.
  Revision 1.1  1996/11/05 09:41:36  Grzm
  Initial revision
                                                                              */

#include <stdio.h>
#include "xdump.h"

void
dump(struct start_address_info *start,
     struct segment_info *segs,
     unsigned long nsegs,
     char *data,
     unsigned long nbytes)
  {
    unsigned long i, j, k;

    /* First give the start address, if any. */
    if (start->valid)
      printf("Start address: %lx\n\n", start->address);

    /* Then output information about the segments. */

    printf("%-10s %4s  %8s %8s  %8s\n",
           "Segment", "Type", "Start", "Size", "Offset(Addr,Bytes)");

    for (i = 0; i < nsegs; ++i)
      {
        printf("%-10s %4u  %8lx %8lx  ",
               segs[i].name,       segs[i].type,
               segs[i].addr,       segs[i].adr_size);
        if (segs[i].nraw == 0)
          /* No output. */;
        else if (segs[i].nraw == 1
                 && segs[i].raw->addr == segs[i].addr
                 && segs[i].raw->size == segs[i].adr_size)
          {
            /* Simple case: One block of raw data for the entire segment. */
            printf("%8lx", segs[i].raw->offs);
          }
        else
          {
            /* Complex case: Output a list of blocks. */
            for (k = 0; k < segs[i].nraw; ++k)
              printf("%c%lx(%lx,%lx)",
                     k == 0 ? '[' : ' ',
                     segs[i].raw[k].offs,
                     segs[i].raw[k].addr,
                     segs[i].raw[k].size);
            putchar(']');
          }
        putchar('\n');
      }

    /* Then output the actual raw data bytes. */

    printf("\n%ld bytes of raw data.\n", nbytes);
    for (i = 0; i < nsegs; ++i)
      {
        if (segs[i].nraw != 0)
          {
            printf("\nSegment %s (%lu):", segs[i].name, i);
            for (k = 0; k < segs[i].nraw; ++k)
              {
                printf("\n    %lx bytes at %lx",
                       segs[i].raw[k].size,
                       segs[i].raw[k].addr);
                for (j = 0; j < segs[i].raw[k].size; ++j)
                  {
                    if (j % 16 == 0)
                      printf("\n       ");
                    printf(" %02x",\
                           (unsigned char) data[segs[i].raw[k].offs + j]);
                  }
                putchar('\n');
              }
          }
      }
  }
