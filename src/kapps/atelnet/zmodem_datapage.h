#ifndef ZMODEM_DATAPAGE_H
#define ZMODEM_DATAPAGE_H

/*
 * Zmodem bulk buffers in g_dataPg @ C000 while that page is mapped.
 *
 * Offset   Size     Symbol / use
 * ------   ----     ------------
 * 0000     4096     Cpmbuf  (grabmem, file write staging)
 * 1000     1025     Secbuf  (alloc KSIZE+1, sector/header RX)
 */

#include "app_bank.h"
#include "zmodem.h"

#define ZM_DP_CPMBUF_OFF   0u
#define ZM_DP_CPMBUF_SIZE  4096u
#define ZM_DP_SECBUF_OFF   4096u
#define ZM_DP_SECBUF_SIZE  (KSIZE + 1u)
#define ZM_DP_USED         (ZM_DP_SECBUF_OFF + ZM_DP_SECBUF_SIZE)

#endif /* ZMODEM_DATAPAGE_H */
