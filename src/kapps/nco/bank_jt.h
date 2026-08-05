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
#define MB_JT_INIT                       0u
#define MB_JT_INIT_PANELS                1u
#define MB_JT_NC_INI_LOAD                2u
#define MB_JT_NC_INI_SAVE                3u
#define MB_JT_NC_CAPTURE_STARTUP_PATH    4u
#define MB_JT_UI_BEGIN_FULL_REDRAW       5u
#define MB_JT_UI_DRAW_STATUS_BAR         6u
#define MB_JT_UI_CLOCK_REDRAW            7u
#define MB_JT_UI_NC_CLOCK_DRAW           8u
#define MB_JT_DRAW_PANEL_BACKGROUND      9u
#define MB_JT_DRAW_BOTTOM_INFO          10u
#define MB_JT_PANEL_SORT_NOTICE_SHOW    11u
#define MB_JT_FILEOP_PROGRESS_BEGIN     12u
#define MB_JT_FILEOP_PROGRESS_TITLE     13u
#define MB_JT_FILEOP_PROGRESS_RESTORE   14u
#define MB_JT_FILEOP_PROGRESS_NAME      15u
#define MB_JT_COPY_PROGRESS_BAR         16u
#define MB_JT_COPY_PROGRESS_NAME        17u
#define MB_JT_PANEL_DRIVE_OPEN          18u
#define MB_JT_PANEL_DRIVE_REDRAW        19u
#define MB_JT_PANEL_DRIVE_HANDLE_KEY    20u
#define MB_JT_UI_DIALOG_INPUT           21u
#define MB_JT_UI_DIALOG_RENAME          22u
#define MB_JT_UI_DIALOG_DELETE          23u
#define MB_JT_UI_ALERT_DIALOG           24u
#define MB_JT_UI_ERROR_DIALOG           25u
#define MB_JT_COPY_DEST_EXISTS          26u
#define MB_JT_COPY_DIR_EXISTS           27u
#define MB_JT_COPY_OVERWRITE_RESOLVE    28u
#define MB_JT_PANEL_DRAW_FOOTER         29u

#define MB_JT_ADDR(slot) \
	((unsigned int)(MB_CODE_ADDR + (unsigned int)(slot) * MB_JT_SLOT_SIZE))

/* Slots in bank_jt2.asm only. */
#define MB_JT2_READ_PANEL_DIR_AT       0u
#define MB_JT2_DRAW_PANEL              1u
#define MB_JT2_PANELS_REMAP_WINDOW     2u
#define MB_JT2_PANELS_RELOAD_BOTH      3u
#define MB_JT2_PANELS_PAINT_BOTH       4u
#define MB_JT2_PANELS_DRAW_ALL         5u
#define MB_JT2_SWITCH_FILE_PAGE        6u
#define MB_JT2_FILL_BOTTOM_SNAP        7u
#define MB_JT2_PANEL_NAV_KEY           8u
#define MB_JT2_PANEL_MENU_APPLY        9u

/* Slots in bank_jt3.asm only. */
#define MB_JT3_ACTION_COPY             0u
#define MB_JT3_ACTION_DELETE           1u
#define MB_JT3_ACTION_RENAME           2u
#define MB_JT3_ACTION_MKDIR            3u
#define MB_JT3_ACTION_MOVE             4u

/* Slots in bank_jt4.asm only. */
#define MB_JT4_ACTION_VIEW             0u
#define MB_JT4_ACTION_EDIT             1u
#define MB_JT4_RUN_SELECTED            2u
#define MB_JT4_NVEXT_LOAD              3u
#define MB_JT4_NVEXT_FIND              4u
#define MB_JT4_MENU_OPEN               5u
#define MB_JT4_MENU_HANDLE_KEY         6u
#define MB_JT4_MENU_DRAW_OVERLAY       7u

#endif
