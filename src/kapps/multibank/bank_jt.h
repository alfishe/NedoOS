#ifndef BANK_JT_H
#define BANK_JT_H

#include "mb_plug.h"

/*
 * Jump table at 0x8000 (per-bank bank_jtN.asm). Each slot = JP nn (3 bytes).
 * Root maps g_bankPg[i] then CALL MB_JT_ADDR(slot).
 *
 * Slot indices are PER BANK (bank02 slot1 != bank01 slot1).
 * codebank_01.c -> bank_jt.asm ; codebank_02.c -> bank_jt2.asm ; ?
 */
#define MB_JT_SLOT_SIZE  3u
#define MB_JT_ENTRY      0u

#define MB_JT_ADDR(slot) \
	((unsigned int)(MB_CODE_ADDR + (unsigned int)(slot) * MB_JT_SLOT_SIZE))

#endif
