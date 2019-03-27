
;LAST UPDATE: 29.01.2019 savelij

;[‘’€ˆ–› VIDEO RAM]
VMODE7_0	EQU LOW (-0X08)-1;0XF7		;‘’€ˆ–€ Ž„Ž‘’€ˆ—ŽƒŽ ’…Š‘’ŒŽ„€ 0 Š€
VMODE7_1	EQU LOW (-0X0A)-1;0XF5		;‘’€ˆ–€ Ž„Ž‘’€ˆ—ŽƒŽ ’…Š‘’ŒŽ„€ 1 Š€
VMODE6_0M	EQU LOW (-0X05)-1;0XFA		;‘’€ˆ–€ ATM ’…Š‘’ŒŽ„€ ŒŽŽ•ŽŒ 0 Š€
VMODE6_0C	EQU LOW (-0X01)-1;0XFE		;‘’€ˆ–€ ATM ’…Š‘’ŒŽ„€ –‚…’ 0 Š€
VMODE6_1M	EQU LOW (-0X07)-1;0XF8		;‘’€ˆ–€ ATM ’…Š‘’ŒŽ„€ ŒŽŽ•ŽŒ 1 Š€
VMODE6_1C	EQU LOW (-0X03)-1;0XFC		;‘’€ˆ–€ ATM ’…Š‘’ŒŽ„€ –‚…’ 1 Š€
ZXSCR_0		EQU LOW (-0X05)-1;0XFA		;‘’€ˆ–€ ZX Š€€ 0
ZXSCR_1		EQU LOW (-0X07)-1;0XF8		;‘’€ˆ–€ ZX Š€€ 1

;[‘’€ˆ–› RAM]
RAM_EVODOS	EQU 1				;‘’€ˆ–€ ŠŽˆˆ EVO-DOS „‹Ÿ ……•‚€’€
RAM_FATVARS	EQU 2				;‘’€ˆ–€ „‹Ÿ ……Œ…›• FAT
RAM_BASIC	EQU 3				;‘’€ˆ–€ BASIC ‘’€„€’€Ÿ ‚…‘ˆŸ
RAM_PROFROM	EQU 4				;‘’€ˆ–€ ……Œ…›• PROFROM
RAM_MOUNTER	EQU 5				;‘’€ˆ–€ „‹Ÿ ŒŽ’ˆŽ‚€ˆŸ Ž€‡Ž‚
RAM_STS		EQU 6				;‘’€ˆ–€ „‹Ÿ Ž’‹€„—ˆŠ€ STS
RAM_ADDSTS	EQU 7				;‘’€ˆ–€ „‹Ÿ Ž’‹€„Šˆ ROM
RAM_SCR_FONT	EQU 8				;‘’€ˆ–€ ‘Ž•€…›• Š€Ž‚ ˆ ”Ž’Ž‚
RAM_TEMP	EQU 9				;‘’€ˆ–€ ‚‘ŸŠˆ• ‚…Œ…›• ……Œ…›•
RAM_RAMDISK	EQU 0X0A			;‘’€ˆ–€ €—€‹€ €Œ„ˆ‘Š€
RAM_DATARAMD	EQU 0X0B			;‘’€ˆ–€ €—€‹€ „€›• €Œ„ˆ‘Š€
RAM_TEMP2	EQU 0X3F			;‘’€ˆ–€ ‘Ž’ˆŽ‚Šˆ ”€‰‹Ž‚ ˆ Ž‘ŒŽ’€ ‘Ž„…†ˆŒŽƒŽ Ž€‡Ž‚
RAM_FLASHER	EQU 0X40			;‘’€ˆ–€ €—€‹€ ‡€ƒ“‡Šˆ Ž˜ˆ‚Šˆ
RAM_TAPE	EQU 0X60			;‘’€ˆ–€ „‹Ÿ ‡€ƒ“‡Šˆ TAP ”€‰‹€

;[‘’€ˆ–› ROM]
ROM_ERS		EQU 0				;ŽŒ… ‘’€ˆ–› ROM EVO RESET SERVICE
ROM_BAS128	EQU 1				;ŽŒ… ‘’€ˆ–› ROM BASIC 128
ROM_DOS		EQU 2				;ŽŒ… ‘’€ˆ–› ROM EVO-DOS „‹Ÿ …€‹œŽ‰ „ˆ‘Š…’›
ROM_BAS48	EQU 3				;ŽŒ… ‘’€ˆ–› ROM BASIC 48

ROM_MAINMENU	EQU 5				;ŽŒ… ‘’€ˆ–› “€ŠŽ‚€ŽƒŽ ƒ‹€‚Ž… Œ…ž
ROM_RST80	EQU 6				;ŽŒ… ‘’€ˆ–› ROM RST 8
ROM_RST81	EQU 7				;ŽŒ… ‘’€ˆ–› ROM RST 8
ROM_RST82	EQU 8				;ŽŒ… ‘’€ˆ–› ROM RST 8
ROM_RST83	EQU 9				;ŽŒ… ‘’€ˆ–› ROM RST 8
ROM_ADD_DOS	EQU 0X0A			;ŽŒ… ‘’€ˆ–› ROM EVO-DOS „‹Ÿ Œ“‹Ÿ–ˆˆ
ROM_ADD_BAS48	EQU 0X0B			;ŽŒ… ‘’€ˆ–› ROM BASIC 48
ROM_BAS48_STD	EQU 0X18			;ŽŒ… ‘’€ˆ–› ROM BASIC 48 (‘’€„€’€Ÿ ‚…‘ˆŸ)
ROM_BAS128_STD	EQU 0X19			;ŽŒ… ‘’€ˆ–› ROM BASIC 128 (‘’€„€’€Ÿ ‚…‘ˆŸ)
ROM_BAS48_128	EQU 0X1A			;ŽŒ… ‘’€ˆ–› ROM BASIC 48 (‘’€„€’€Ÿ ‚…‘ˆŸ „‹Ÿ BASIC128)
ROM_ATMCPM	EQU 0X1B			;ŽŒ… ‘’€ˆ–› ROM €’Œ CP/M

CONF4PROF	EQU 0X90			;‘’€’Ž‚€Ÿ ‘’€ˆ–€ „‹Ÿ EVO PROFROM 128K
CONF4GLUK	EQU 0X94			;‘’€’Ž‚€Ÿ ‘’€ˆ–€ „‹Ÿ GLUK 64K
CONF4CUSTOM	EQU 0X9C			;‘’€’Ž‚€Ÿ ‘’€ˆ–€ „‹Ÿ Ž‹œ‡Ž‚€’…‹œ‘ŠŽ‰ Ž˜ˆ‚Šˆ 64Š

CPU0		EQU 0X0000			;€—€‹Ž ŽŠ€ Ž…–ˆŽ‚€ˆŸ 0
CPU1		EQU 0X4000			;€—€‹Ž ŽŠ€ Ž…–ˆŽ‚€ˆŸ 1
CPU2		EQU 0X8000			;€—€‹Ž ŽŠ€ Ž…–ˆŽ‚€ˆŸ 2
CPU3		EQU 0XC000			;€—€‹Ž ŽŠ€ Ž…–ˆŽ‚€ˆŸ 3

;[Ž’›]
WIN_P0		EQU 0X37F7			;€„…‘ 0 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ PENTEVO
WIN_P1		EQU 0X77F7			;€„…‘ 1 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ PENTEVO
WIN_P2		EQU 0XB7F7			;€„…‘ 2 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ PENTEVO
WIN_P3		EQU 0XF7F7			;€„…‘ 3 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ PENTEVO
WIN_R0		EQU 0X3BF7			;€„…‘ ‡€™ˆ’› Ž’ ‡€ˆ‘ˆ ‚ ŽŠ… 0
WIN_R1		EQU 0X7BF7			;€„…‘ ‡€™ˆ’› Ž’ ‡€ˆ‘ˆ ‚ ŽŠ… 1
WIN_R2		EQU 0XBBF7			;€„…‘ ‡€™ˆ’› Ž’ ‡€ˆ‘ˆ ‚ ŽŠ… 2
WIN_R3		EQU 0XFBF7			;€„…‘ ‡€™ˆ’› Ž’ ‡€ˆ‘ˆ ‚ ŽŠ… 3
WIN_A0		EQU 0X3FF7			;€„…‘ 0 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ ATM
WIN_A1		EQU 0X7FF7			;€„…‘ 1 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ ATM
WIN_A2		EQU 0XBFF7			;€„…‘ 2 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ ATM
WIN_A3		EQU 0XFFF7			;€„…‘ 3 ‘’€ˆ–› Ž…–ˆŽ‚€ˆŸ ATM
PEVO_CONF	EQU 0XBF			;€„…‘ Ž’€ ŠŽ”ˆƒ€ PENTEVO
CMOSD_SET_ADR	EQU 0XDEF7			;€„…‘ Ž’€ “‘’€Ž‚Šˆ €„…‘€ CMOS Ÿ—…‰Šˆ ˆ‡ DOS
CMOSD_RD_WR	EQU 0XBEF7			;€„…‘ Ž’€ —’…ˆŸ/‡€ˆ‘ˆ €‰’ CMOS ˆ‡ „Ž‘€
CMOS_SET_ADR	EQU 0XDFF7			;€„…‘ Ž’€ “‘’€Ž‚Šˆ €„…‘€ CMOS Ÿ—…‰Šˆ
CMOS_RD_WR	EQU 0XBFF7			;€„…‘ Ž’€ —’…ˆŸ/‡€ˆ‘ˆ €‰’ CMOS
PENT_CONF	EQU 0XEFF7			;€„…‘ Ž’€ ŠŽ”ˆƒ€ …†ˆŒ€ …’€ƒŽ€
CONF_128	EQU 0X7FFD			;€„…‘ Ž’€ ŠŽ”ˆƒ€ 128 €ŒŸ’ˆ
MOUSE_X		EQU 0XFBDF			;€„…‘ Ž’€ X ŠŽŽ„ˆ€’› Œ›˜ˆ
MOUSE_Y		EQU 0XFFDF			;€„…‘ Ž’€ Y ŠŽŽ„ˆ€’› Œ›˜ˆ
MOUSE_KEYS	EQU 0XFADF			;€„…‘ Ž’€ ŠŽŽŠ Œ›˜ˆ

;[Œ€‘Š€ ŠŽŽŠ Œ›˜ˆ]
 ;BITMASK MOUSE_M_KEY,	2
 ;BITMASK MOUSE_R_KEY,	1
 ;BITMASK MOUSE_L_KEY,	0
_MOUSE_WHEEL	EQU %11110000

;[Ž’› RS232]
RS232_IO	EQU 0XF8EF
RS232_DIV_L	EQU 0XF8EF
RS232_IRQ_ENA	EQU 0XF9EF
RS232_DIV_H	EQU 0XF9EF
RS232_IRQ_ID	EQU 0XFAEF
RS232_LINE_CTRL	EQU 0XFBEF
RS232_MDM_CTRL	EQU 0XFCEF
RS232_LINE_STAT	EQU 0XFDEF
RS232_MDM_STAT	EQU 0XFEEF
RS232_WORK_REG	EQU 0XFFEF

;[‘ŠŽŽ‘’ˆ RS232]
BAUD110		EQU 115200/110
BAUD150		EQU 115200/150
BAUD300		EQU 115200/300
BAUD600		EQU 115200/600
BAUD1200	EQU 115200/1200
BAUD2400	EQU 115200/2400
BAUD4800	EQU 115200/4800
BAUD9600	EQU 115200/9600
BAUD19200	EQU 115200/19200
BAUD38400	EQU 115200/38400
BAUD57600	EQU 115200/57600
BAUD115200	EQU 115200/115200

;[Ž’› „‹Ÿ —’…ˆŸ Ž’Ž‚ ŠŽ”ˆƒ“€–ˆˆ]
EXIT_PORT	EQU 0XBE
RD_0WINA0	EQU 0X00BE			;€„…‘ Ž’€ 0 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 0 Œ€…€
RD_0WINA1	EQU 0X01BE			;€„…‘ Ž’€ 1 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 0 Œ€…€
RD_0WINA2	EQU 0X02BE			;€„…‘ Ž’€ 2 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 0 Œ€…€
RD_0WINA3	EQU 0X03BE			;€„…‘ Ž’€ 3 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 0 Œ€…€
RD_1WINA0	EQU 0X04BE			;€„…‘ Ž’€ 0 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 1 Œ€…€
RD_1WINA1	EQU 0X05BE			;€„…‘ Ž’€ 1 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 1 Œ€…€
RD_1WINA2	EQU 0X06BE			;€„…‘ Ž’€ 2 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 1 Œ€…€
RD_1WINA3	EQU 0X07BE			;€„…‘ Ž’€ 3 ŽŠ€ Ž…–ˆŽ‚€ˆŸ 1 Œ€…€
RD_RAMNROM	EQU 0X08BE			;€„…‘ Ž’€ ˆ’Ž‚ RAM & ROM
RD_DOS7FFD	EQU 0X09BE			;€„…‘ Ž’€ ˆ’Ž‚ DOS & 7FFD
RD_7FFD		EQU 0X0ABE			;€„…‘ Ž’€ 7FFD
RD_EFF7		EQU 0X0BBE			;€„…‘ Ž’€ EFF7
RD_77		EQU 0X0CBE			;€„…‘ Ž’€ xx77
RD_PALITRA	EQU 0X0DBE			;€„…‘ Ž’€ €‹ˆ’›
BREAK_LOW_RD	EQU 0X10BE			;Œ‹€„˜ˆ‰ €‰’ €„…‘€ Ž’€ € —’…ˆ… €„…‘€ BREAK
BREAK_HIGH_RD	EQU 0X11BE			;‘’€˜ˆ‰ €‰’ €„…‘€ Ž’€ € —’…ˆ… €„…‘€ BREAK
NUM_LINE	EQU 0X13BE			;ŽŒ… ‘’ŽŠˆ €‘’€ (0-159)

BREAK_LOW_WR	EQU 0X00BD			;Œ‹€„˜ˆ‰ €‰’ €„…‘€ Ž’€ € ‡€ˆ‘œ €„…‘€ BREAK
BREAK_HIGH_WR	EQU 0X01BD			;‘’€˜ˆ‰ €‰’ €„…‘€ Ž’€ € ‡€ˆ‘œ €„…‘€ BREAK

;[Ž’› ‚ƒ93 ˆ Œ“‹Ÿ’Ž€]
;	IF DELVAR
;VG_RW_1F	EQU 0X1F
;VG_RD_1F	EQU 0X2F
;VG_RW_3F	EQU 0X3F
;VG_RD_3F	EQU 0X4F
;VG_RW_5F	EQU 0X5F
;VG_RD_5F	EQU 0X6F
;VG_RW_7F	EQU 0X7F
;VG_RD_7F	EQU 0X8F
;VG_MEM		EQU VG_RD_1F;0XAF
;VG_RW_FF	EQU 0XFF

;RW_PORT0	EQU 0X2F
;RW_PORT1	EQU 0X4F
;RW_PORT2	EQU 0X6F
;RW_PORT3	EQU 0X8F
;	ENDIF

;[Ž„Ž‘’€ˆ—›‰ ’…Š‘’ŒŽ„]
LSYM		EQU 0X01C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ ‹…‚›• ‘ˆŒ‚Ž‹Ž‚ ’…Š‘’ŒŽ„€
LATTR		EQU 0X31C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ ‹…‚›• €’ˆ“’Ž‚ ‘ˆŒ‚Ž‹Ž‚
RSYM		EQU 0X11C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ €‚›• ‘ˆŒ‚Ž‹Ž‚ ’…Š‘’ŒŽ„€
RATTR		EQU 0X21C1			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ €‚›• €’ˆ“’Ž‚ ‘ˆŒ‚Ž‹Ž‚ 

;[ATM ’…‘’ŒŽ„]
ALSYM		EQU 0X01C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ ‹…‚›• ‘ˆŒ‚Ž‹Ž‚ ’…Š‘’ŒŽ„€
ALATTR		EQU 0X21C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ ‹…‚›• €’ˆ“’Ž‚ ‘ˆŒ‚Ž‹Ž‚
ARSYM		EQU 0X21C0			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ €‚›• ‘ˆŒ‚Ž‹Ž‚ ’…Š‘’ŒŽ„€
ARATTR		EQU 0X01C1			;‘Œ…™…ˆ… ‚ ‘’€ˆ–… €—€‹€ €‚›• €’ˆ“’Ž‚ ‘ˆŒ‚Ž‹Ž‚

;[–‚…’€ ˆ ŸŠŽ‘’ˆ]
BLACK		EQU 0
BLUE		EQU 1
RED		EQU 2
MAGENTA		EQU 3
GREEN		EQU 4
CYAN		EQU 5
YELLOW		EQU 6
WHITE		EQU 7
BR_INK		EQU 0X40
BR_PAPER	EQU 0X80

;[–‚…’€ „‹Ÿ ATM ‚ˆ„…Ž…†ˆŒŽ‚]
G_L		EQU %10000000
G_H		EQU %00010000
R_L		EQU %01000000
R_H		EQU %00000010
B_L		EQU %00100000
B_H		EQU %00000001

;[Œ€‘Š€ Ž’€ 7FFD]
ZX_SCREEN	EQU %00001000
ZX_ROM		EQU %00010000

;[Œ€‘Š€ Ž’€ 0XBF]
 ;BITMASK RST8_BF,	6
RST8_BF=1<<6
 ;BITMASK EMUVG_BF,	5	
EMUVG_BF=1<<6
 ;BITMASK BREAK_BF,	4			;ˆ’ €‡…˜…ˆŸ ‘€€’›‚€ˆŸ BREAK € €„…‘…
BREAK_BF=1<<6
 ;BITMASK NMI_BF,	3			;ˆ’ ƒ……€–ˆˆ NMI
NMI_BF=1<<6
 ;BITMASK FONT_BF,	2			;ˆ’ €‡…˜…ˆŸ ˆ‡Œ……ˆŸ ˜ˆ”’€
FONT_BF=1<<6
 ;BITMASK FLASH_BF,	1			;ˆ’ €‡…˜…ˆŸ Žƒ€ŒŒˆŽ‚€ˆŸ FLASH
FLASH_BF=1<<6
 ;BITMASK SHADOW_BF,	0			;ˆ’ €‡…˜…ˆŸ „Ž‘’“€ Š ’……‚›Œ Ž’€Œ
SHADOW_BF=1<<6

;[Œ€‘Š€ Ž’€ 0XEFF7]
 ;BITMASK PENT_CMOS,	7			;ˆ’ €‡…˜…ˆŸ „Ž‘’“€ Š ŠŒŽ‘“
PENT_CMOS=1<<7
 ;BITMASK PENT_TURBO,	4			;’“Ž…†ˆŒ …’€ƒŽ€
PENT_TURBO=1<<4

;[Œ€‘Šˆ …†ˆŒŽ‚]
ZXSCR_MODE	EQU 1				;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ ZX SCREEN MODE
TXTSCR_MODE	EQU 2				;ŽŒ… Ž„Ž‘’€ˆ—ŽƒŽ ’…Š‘’Ž‚ŽƒŽ …†ˆŒ€
MEMORY_ALL	EQU 0X10			;„Ž‘’“ Š …‚ŽŒ“ Œ…ƒ€€‰’“ —……‡ Ž’ EFF7
MEMORY_48	EQU 0X20			;„Ž‘’“… ’Ž‹œŠŽ 48Kb €ŒŸ’ˆ
MEMORY_128	EQU 0X30			;„Ž‘’“Ž ’Ž‹œŠŽ 128Kb €ŒŸ’ˆ
TURBO_3		EQU 0X40			;—€‘’Ž’€ Ž–…‘‘Ž€ 3,5 Œƒæ 
TURBO_7		EQU 0X80			;—€‘’Ž’€ Ž–…‘‘Ž€ 7 Œƒæ
TURBO_14	EQU 0XC0			;—€‘’Ž’€ Ž–…‘‘Ž€ 14 Œƒæ
NUM_EGA		EQU %00000000			;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ „‹Ÿ ATM Ž’€ (EGA ŒŽ„ 320*200)
NUM_APPMULTI	EQU %00000010			;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ „‹Ÿ ATM Ž’€ (€€€’›‰ Œ“‹œ’ˆŠŽ‹Ž 640*200)
NUM_ZXSCR	EQU %00000011			;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ „‹Ÿ ATM Ž’€ (ZX SCREEN 6912)
NUM_TXTATM	EQU %00000110			;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ „‹Ÿ ATM Ž’€ (ATM ’…Š‘’ŒŽ„ 80*25)
NUM_TXTSCR	EQU %00000111			;ŽŒ… ‚ˆ„…Ž…†ˆŒ€ „‹Ÿ ATM Ž’€ (Ž„Ž‘’€ˆ—›‰ ’…Š‘’ŒŽ„ 80*25)

;[ŽŒ…€ ‚ˆ„…Ž…†ˆŒŽ‚ ‘ Œ€‘ŠŽ‰ „‹Ÿ ‡€ˆ‘ˆ ‚ Ž’]
V_EGA		EQU NUM_EGA	| 0XA0
V_APPMULTI	EQU NUM_APPMULTI| 0XA0
V_ZXSCR		EQU NUM_ZXSCR	| 0XA0
V_TXTATM	EQU NUM_TXTATM	| 0XA0
V_TXT1PAGE	EQU NUM_TXTSCR	| 0XA0

;[Œ€‘Šˆ Ž’‹€„—ˆŠ€]
 ;BITMASK DBG_ACTIV,	7			;€Š’ˆ‚… Ž’‹€„—ˆŠ
 ;BITMASK TRACE_DBG,	6			;’€‘‘ˆŽ‚Š€
 ;BITMASK STEP_DBG,	5			;Ž˜€ƒŽ‚€Ÿ Ž’‹€„Š€
; BITMASK CASH_INST,	4			;“‘’€Ž‚‹… CASH REMEMBER
; BITMASK CASH_ACTIV,	3			;€Š’ˆ‚… CASH REMEMBER

;[‘Œ…™…ˆŸ FDI Ž€‡€]
FDI_TABLE_CYL	EQU 0X4000			;€„…‘ ’€‹ˆ–› €—€‹ „ŽŽ†…Š ‚ Ž€‡…
FDI_PAGE_START	EQU 0X40FF			;‘Œ…™…ˆ… ‚ ‘’€ˆ–€• €—€‹€ ‘…Š’ŽŽ‚ Ž€‡€
FDI_BYTE_SMESH	EQU 0X41FE			;‘Œ…™…ˆ… ‚ €‰’€• €—€‹€ Ž€‡€ ‡€ƒ“†…ŽƒŽ ‚ €Œ„ˆ‘Š
FDI_BLOCK_SMESH	EQU 0X41FF			;‘Œ…™…ˆ… ‚ ‹ŽŠ€• (Ž 256 €‰’) €—€‹€ ‘…Š’ŽŽ‚ Ž€‡€
FDI_IMAGE1SECT	EQU 0X4400			;€„…‘ ‡€ƒ“‡Šˆ …‚ŽƒŽ ‘…Š’Ž€ „‹Ÿ Ž…„…‹…ˆŸ ‘Œ…™…ˆŸ

;Ÿ—…‰Šˆ ‚ CMOS
_CMOS_SECOND	EQU 0				;‘…Š“„›
_CMOS_SECOND_AL	EQU 1				;‘…Š“„› “„ˆ‹œˆŠ€
_CMOS_MINUTE	EQU 2				;Œˆ“’›
_CMOS_MINUTE_AL	EQU 3				;Œˆ“’› “„ˆ‹œˆŠ€
_CMOS_HOUR	EQU 4				;—€‘›
_CMOS_HOUR_AL	EQU 5				;—€‘› “„ˆ‹œˆŠ€
_CMOS_DAY	EQU 6				;„…œ …„…‹ˆ
_CMOS_DAY_MONTH	EQU 7				;„…œ Œ…‘Ÿ–€
_CMOS_MONTH	EQU 8				;Œ…‘Ÿ–
_CMOS_YEAR	EQU 9				;ƒŽ„

;[ŽŒ…€ Ÿ—……Š CMOS ˆ ˆ• ‘Ž„…†ˆŒŽ…]
CRCCMOSHIGH	EQU 0XEF			;‘’€˜ˆ‰ €‰’ CRC CMOS
CRCCMOSLOW	EQU 0XEE			;Œ‹€„˜ˆ‰ €‰’ CRC CMOS
CMOS_BYTE_00	EQU 0XED			;€„…‘ •€…ˆŸ ‚ CMOS
CMOS_BYTE_01	EQU 0XEC			;€„…‘ •€…ˆŸ ‚ CMOS
VIRT_REAL_DRIVE	EQU 0XEB			;•€…ˆ… ŽŒ…€ …€‹œŽƒŽ ˆ ‚ˆ’“€‹œŽƒŽ „ˆ‘ŠŽ‚Ž„€, ’ˆ DOS
HDD_TIMEOUT	EQU 0XEA			;‡€„…†Š€ Ž…„…ˆŸ €‹ˆ—ˆŸ ‚ˆ’€ Ž‘‹… ‚Š‹ž—…ˆŸ ˆ’€ˆŸ
CMOS_BYTE_02	EQU 0XE9			;€„…‘ •€…ˆŸ ‚ CMOS

;[Ÿ—…‰Š€ CMOS 0XED CMOS_BYTE_00]
 ;BITMASK TURBO14,	7			;€‡…˜…ˆ… ‚Š‹ž—…ˆŸ TURBO 14MHZ
 ;BITMASK EMUL_TAPE,	6			;€‡…˜…ˆ… Œ“‹Ÿ–ˆˆ ‡€ƒ“‡Šˆ ‘ ‹…’›
 ;BITMASK PRINTER_AY,	5			;€‡…˜…ˆ… Ž„Œ…› „€‰‚…€ …—€’ˆ ‚ BASIC48
 ;BITMASK RELOAD_FONT,	4			;€‡…˜…ˆ… ……‡€ƒ“‡Šˆ ˜ˆ”’€ ˆ ‘Ž‘…
 ;BITMASK TYPE_FONT,	3			;‚›Ž ŠŽ„ˆŽ‚Šˆ ˜ˆ”’€
 ;BITMASK AUTO_TAPE,	2			;€‚’Ž‡€“‘Š TAP ”€‰‹Ž‚

;[ŽŒ…€ ‘Ž‘Ž‚, ˆ’› 1-0 Ÿ—…‰Šˆ 0XED (CMOS_BYTE_00)]
RESET2CUSTOM	EQU 3				;‘Ž‘ ‚ CUSTOM ROM
RESET2PROFROM	EQU 2				;‘Ž‘ ‚ PROFROM
RESET2GLUK	EQU 1				;‘Ž‘ ‚ GLUK SERVICE
RESET2EVOSERV	EQU 0				;‘Ž‘ ‚ EVO SERVICE

;[Ÿ—…‰Š€ CMOS 0XEC CMOS_BYTE_01]
 ;BITMASK TURBO357,	7			;’“Ž …†ˆŒ 3,5 ˆ‹ˆ 7 Œƒ–
TURBO357=1<<7
 ;BITMASK AUTOMOUNT,	5			;‚Š‹/‚›Š‹ €‚’ŽŒŽ’ˆŽ‚€ˆŸ ˆ‡ ”€‰‹€
AUTOMOUNT=1<<5
 ;BITMASK CLOCK_VIEW,	4			;•€…ˆ… Ž’Ž€†…ˆ… —€‘Ž‚
CLOCK_VIEW=1<<4
 ;BITMASK SOUNDKEYS,	3			;€‡…˜…ˆ… Ž‡‚“—ˆ‚€ˆŸ €†€’›• Š‹€‚ˆ˜
SOUNDKEYS=1<<3
 ;BITMASK REZIDENT,	2			;€‡…˜…ˆ… Ž‚…Šˆ €‹ˆ—ˆŸ …‡ˆ„…’€
REZIDENT=1<<2

;[ŽŒ…€ ŒŽ„…‹…‰ €ŒŸ’ˆ, ˆ’› 1-0 Ÿ—…‰Šˆ 0XEC (CMOS_BYTE_01)]
_128K		EQU 2				;€ŒŸ’œ 128 Š¡
_48K		EQU 1				;€ŒŸ’œ 48 Š¡
_1MB		EQU 0				;€ŒŸ’œ 1 Œ¡

KOL_MODES	EQU 4				;ŠŽ‹ˆ—…‘’‚Ž …†ˆŒŽ‚ ‘Ž‘€
MKOL_MODES	EQU 3				;Œ€‘Š€ „‹Ÿ ŠŽ‹ˆ—…‘’‚€ …†ˆŒŽ‚ ‘Ž‘€

;[Ÿ—…‰Š€ CMOS 0XEB]
 ;BITMASK ACCESSZCSD,	7			;€‡…˜…ˆ… „Ž‘’“€ Š ZC SD CARD
ACCESSZCSD=1<<7
 ;BITMASK ACCESSSDG,	6			;€‡…˜…ˆŸ „Ž‘’“€ Š SD Š€’… NEOGS
ACCESSSDG=1<<6
 ;BITMASK ACCESSHDDM,	5			;€‡…˜…ˆ… „Ž‘’“€ Š HDD MASTER
ACCESSHDDM=1<<5
 ;BITMASK ACCESSHDDS,	4			;€‡…˜…ˆ… „Ž‘’“€ Š HDD SLAVE
ACCESSHDDS=1<<4
_REAL_DRIVE	EQU %00001100			;Œ€‘Š€ ŽŒ…€ …€‹œŽƒŽ „ˆ‘ŠŽ‚Ž„€
_VIRT_DRIVE	EQU %00000011			;Œ€‘Š€ ŽŒ…€ ‚ˆ’“€‹œŽƒŽ „ˆ‘ŠŽ‚Ž„€

;[Ÿ—…‰Š€ CMOS 0XE9]
 ;BITMASK AUTOBOOT,	7			;€‚’Ž‘’€’ ‡€ƒ“†€…ŒŽƒŽ “‘’Ž‰‘’‚€
AUTOBOOT=1<<7
BOOTDEVICE	EQU %00000011			;ŽŒ… ‡€ƒ“†€…ŒŽƒŽ “‘’Ž‰‘’‚€

;[ŽŒ…€ ‡€ƒ“†€…Œ›• “‘’Ž‰‘’‚]
_SD		EQU 2				;SD Š€’€
_HDD		EQU 1				;‚ˆ—…‘’…
_FDD		EQU 0				;„ˆ‘ŠŽ‚Ž„

_SD_NONE	EQU 0X80			;ˆ‡€Š … ‚‘’€‚‹…Ž‰ Š€’›

;[……Œ…›… „‹Ÿ 0 ŽŠ€ Ž…–ˆŽ‚€ˆŸ]
DEBUG_ONOFF	EQU 0X0013			;‚Š‹/‚›Š‹ Ž’‹€„—ˆŠ€
ADR_SEL_ROM	EQU 0X0014			;€„…‘ ……Š‹ž—…ˆŸ ‘’€ˆ– ROM
CONT_RST8	EQU 0X002C			;€„…‘ Ž„Ž‹†…ˆŸ Ž€Ž’Šˆ RST 8
CONTINUE_MAGIC	EQU 0X0034			;€„…‘ ……•Ž„€ Ž„Ž‹†…ˆŸ Ž€Ž’—ˆŠ€ MAGIC
ADR_PERFECT	EQU 0X0036			;€„…‘ €‘Ž‹Ž†…ˆŸ PERFECT COMANDER
EI_RET		EQU 0X003E			;€„…‘ €‘Ž‹Ž†…ˆŸ EI:RET
UNP_DOS_FE	EQU 0X0040			;€„…‘ €‘€ŠŽ‚™ˆŠ€ DOS FE
UNPACK		EQU 0X0080			;€„…‘ €‘€ŠŽ‚™ˆŠ€
_BIOS_JUMPS	EQU 0X0100			;€„…‘ €—€‹€ ’€‹ˆ–› ……•Ž„Ž‚ ‚ „€‰‚…› „…‚€‰‘Ž‚
ADRBRK_EMUTAP	EQU 0X0569			;€„…‘ “‘’€Ž‚Šˆ ŸŠ€ „‹Ÿ Œ“‹Ÿ–ˆˆ ‡€ƒ“‡Šˆ TAP
START_STS	EQU 0XC000			;€„…‘ ‚•Ž„€ ‚ Ž’‹€„—ˆŠ
ADR_RST8END	EQU 0X3CE8			;€„…‘ ‚Ž‡‚€’€ ˆ‡ RST 8
ICALL2PAGE	EQU 0X8000			;€„…‘ ‚›‡›‚Ž‚ ŠŽ„€ ˆ‡ ‡“ƒŽ‰ ‘’€ˆ–›

OFFSET_FNTSAVE	EQU 0				;800 ‘Œ…™…ˆ… ‚ ‘’€ˆ–… „‹Ÿ ‘Ž•€…ˆŸ ‘—ˆ’€ŽƒŽ ˜ˆ”’€
OFFSET_BUFSYM	EQU OFFSET_FNTSAVE+0X800	;800 ‘Œ…™…ˆ… ‚ ‘’€ˆ–… ’…Š“™…ƒŽ ˜ˆ”’€
OFFSET_SCRSAVE	EQU OFFSET_BUFSYM+0X800		;1B00 ‘Œ…™…ˆ… ‚ ‘’€ˆ–… „‹Ÿ ‘Ž•€…ˆŸ Š€€

BUF_512		EQU CPU3-0X200			;200 “”… ‘…Š’Ž€
BUF_TABLVOL	EQU BUF_512-0X100		;100 “”… ’€‹ˆ–› €‰„…›• €‡„…‹Ž‚
BUF_TEKVOL	EQU BUF_TABLVOL-0X100		;100 “”… ‚›€ŽƒŽ €‡„…‹€
BUF_TDIRCLS	EQU BUF_TEKVOL-0X800		;800 “”… Š‹€‘’…Ž‚ ’…Š“™…‰ „ˆ…Š’Žˆˆ
BUF_256		EQU BUF_TDIRCLS-0X100		;100 “”… 256 €‰’ „‹Ÿ ……Ž‘Ž‚
BUF_PATH	EQU BUF_256-0X100		;100 “”… ’…Š“™…ƒŽ “’ˆ
MOUNT_DRIVES	EQU BUF_PATH-0X100		;100 “”… Žˆ‘€’…‹…‰ ˆŒŽ’ˆŽ‚€›• ”€‰‹Ž‚
BUF_LEVELDIR	EQU MOUNT_DRIVES-0X100		;200 “”… ‘Ž•€…ˆŸ Ž‡ˆ–ˆ‰ ŽŠŽ ˆ ……•Ž„€• Ž „ˆ…Š’ŽˆŸŒ
BUF_WINPATH	EQU BUF_LEVELDIR-0X400		;400 “”… ‘Ž•€…ˆŸ Ž‡ˆ–ˆ‰ ‚ ŽŠ… ˆ •Ž†„…ˆˆ Ž „ˆ…Š’ŽˆŸŒ

;[……Œ…›… „‹Ÿ Œ……„†…€ “‘’Ž‰‘’‚]
DEVICES		EQU BUF_TABLVOL+0XE0		;10 ‘ˆ‘ŽŠ Ž€“†…›• „…‚€‰‘Ž‚
GO_DEV		EQU DEVICES+0X10		;2 €„…‘ ‚›‡Ž‚€ „€‰‚…€ “‘’Ž‰‘’‚€
KOLDVOL		EQU GO_DEV+2			;1 ŠŽ‹ˆ—…‘’‚Ž €‰„…›• €‡„…‹Ž‚
SETDVOL		EQU KOLDVOL+1			;1 ŽŒ… ‚›€ŽƒŽ €‡„…‹€
ADRTEKV		EQU SETDVOL+1			;2 €„…‘ Žˆ‘€’…‹Ÿ ’…Š“™…ƒŽ €‡„…‹€
SAVE_TEK_VOL	EQU ADRTEKV+2			;1 ‚…Œ…Ž… ‘Ž•€…ˆ… ’…Š“™…ƒŽ €‡„…‹€
TEK_TYPE	EQU SAVE_TEK_VOL+1		;1 ‚…Œ…Ž… •€…ˆ… ’ˆ€ ’…Š“™…ƒŽ “‘’Ž‰‘’‚€
FLAGS_DRV	EQU TEK_TYPE+1			;1 ”‹€ƒŽ‚›‰ €‰’ „€‰‚…Ž‚
;7 =0-„€‰‚… SD Š€’› NEOGS … “‘’€Ž‚‹…, =1-“‘’€Ž‚‹…
;6
;5
;4
;3
;2
;1 =0-SD ZC Š€’€ … Ž€“†…€, 1-Ž€“†…€
;0 =0-SD NeoGS … Ž€“†…€, 1-Ž€“†…€
CRC_DRVS	EQU BUF_TABLVOL+0XFE		;2 ŠŽ’Ž‹œ€Ÿ ‘“ŒŒ€ ’€‹ˆ–› €‰„…›• €‡„…‹Ž‚

;[……Œ…›… „‹Ÿ 1 ŽŠ€ Ž…–ˆŽ‚€ˆŸ]
BUF_ALLVOL	EQU 0				;1000 “”… ……Œ…›• „‹Ÿ ‚‘…• €‡„…‹Ž‚ (16 MAX)
MOUNT_CLS	EQU BUF_ALLVOL+0X1000		;1000 “”… Š‹€‘’…Ž‚ ˆŒŽ’ˆŽ‚€›• ”€‰‹Ž‚
TEK_BUFPATH	EQU MOUNT_CLS+0X1000		;1000 “”… ’…Š“™ˆ• “’…‰ € €‡„…‹€•
BUF_PATHMOUNT	EQU TEK_BUFPATH+0X1000		;400 “”… “’…‰ „‹Ÿ Žˆ‘Š€ ˆŒŽ’ˆŽ‚€›• ”€‰‹Ž‚
BUF_DIRCEP	EQU BUF_PATHMOUNT+0X400		;100 “”… –…Ž—Šˆ ’…Š“™…‰ „ˆ…Š’Žˆˆ
BUF_TEMPSEC	EQU BUF_DIRCEP+0X100		;200 “”… ‘…Š’Ž€ „‹Ÿ ‡€ƒ“‡Šˆ Ž€‡Ž‚
