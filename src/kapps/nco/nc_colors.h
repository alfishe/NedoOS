#ifndef NC_COLORS_H
#define NC_COLORS_H

/*
 * nvfast (PRSTDIO=0): single Speccy attribute byte in E for OS_SETCOLOR.
 * Literals from nv.asm else-branch (_PANELCOLOR=0x4F, etc.).
 * Layout: bit6=bright, bits5..3=paper, bits2..0=ink (bit7=flash, unused).
 */
#define NC_BR 0x40u

#define NC_MAKE_COLOR(bright, paper, ink) \
	((unsigned char)((unsigned char)(bright) | ((unsigned char)(paper) << 3) | (unsigned char)(ink)))

#define NC_COLOR_PANEL          0x4Fu /* _PANELCOLOR / _PANELDIRCOLOR */
#define NC_COLOR_PANEL_EXEC     0x4Cu /* _PANELEXECOLOR */
#define NC_COLOR_PANEL_FILE     0x0Fu /* _PANELFILECOLOR */
#define NC_COLOR_PANEL_MARK     0x4Eu /* _PANELSELECTCOLOR */
#define NC_COLOR_CURSOR         0x28u /* _CURSORCOLOR / _FILECURSORCOLOR / _HINTCOLOR0 */
#define NC_COLOR_HINT           0x28u /* _HINTCOLOR0 = 5*8 */
#define NC_COLOR_HINT_KEY       0x07u /* _HINTCOLOR1 = 7 */
#define NC_COLOR_CMDLINE        NC_MAKE_COLOR(NC_BR, 0u, 7u) /* white on black, like cmd line */
#define NC_COLOR_DIALOG         0x30u /* _COLOR_DIALOG */
#define NC_COLOR_RED            0x17u /* _COLOR_RED */

#define NC_COLOR_MENU_NORM      NC_COLOR_HINT
#define NC_COLOR_MENU_HILITE    NC_MAKE_COLOR(NC_BR, 0u, 5u) /* bright cyan on black */
#define NC_COLOR_COPY_UI        NC_COLOR_DIALOG
#define NC_COLOR_COPY_BAR       NC_COLOR_DIALOG
#define NC_COLOR_OVERWRITE_UI   NC_COLOR_RED

/* nvfast PRSTDIO=0: OS_SETCOLOR (E=Speccy attr byte). */
#define NC_SETCOLOR OS_SETCOLOR

#endif
