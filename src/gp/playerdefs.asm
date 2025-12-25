PLAYERSTART = 0x4000
PLAYEREND   = 0x8000

	macro PLAYERHEADER
	db 0xc3 : dw playerinit      ;called once, should check if sound device is available (if possible)
	db 0xc3 : dw playerdeinit    ;called once when the application is exiting
	db 0xc3 : dw musicload       ;function that loads the file allocating all required resources
	db 0xc3 : dw musicunload     ;function that frees all resources allocated in musicload and mutes the sound device
	db 0xc3 : dw musicplay       ;function called in the main loop, should update progress variable
	db 0xc3 : dw isfilesupported ;function to determine if this player can handle the file
	dw playernamestr ;player name string
	dw 0 ;address of the song title, zero means the title is unavailable and file name should be displayed instead
	dw 0 ;address of play progress variable, setting this to zero disables progress bar
	dw 0 ;address of error string
	dw 0 ;address of custom UI elements
	endm

PLAYERINITPROCADDR      = PLAYERSTART+0x01
PLAYERDEINITPROCADDR    = PLAYERSTART+0x04
MUSICLOADPROCADDR       = PLAYERSTART+0x07
MUSICUNLOADPROCADDR     = PLAYERSTART+0x0a
MUSICPLAYPROCADDR       = PLAYERSTART+0x0d
ISFILESUPPORTEDPROCADDR = PLAYERSTART+0x10
PLAYERNAMESTRADDR       = PLAYERSTART+0x12
MUSICTITLEADDR          = PLAYERSTART+0x14
MUSICPROGRESSADDR       = PLAYERSTART+0x16
ERRORSTRINGADDR         = PLAYERSTART+0x18
CUSTOMUIADDR            = PLAYERSTART+0x1a

	struct GPSETTINGS
sharedpages ds 3
usemp3 dw 0
usemwm dw 0
usept3 dw 0
usevgm dw 0
usemoonmod dw 0
usemoonmid dw 0
moonmoddefaultpanning dw 0
midiuartdelayoverride dw 0
mididevice dw 0
moddevice dw 0
slowtfm dw 0
framelength dw 0 ;in 42 t-states units
moonsoundstatus ds 1 ; 0 - no device, 1 - BomgeMoon or MoonSound with old firmware (wave ports not working), 2 - MoonSound OK
tfmstatus ds 1 ; 0 - no device, 1 - found TFM
opmstatus ds 1 ; 0 - no device, 1 - single YM2151, 2 - dual YM2151
opnastatus ds 1 ; 0 - no device, 1 - found YM2608
	ends

DEVICE_AY_BIT         = 0
DEVICE_TURBOSOUND_BIT = 1
DEVICE_TFM_BIT        = 2
DEVICE_MOONSOUND_BIT  = 3
DEVICE_GS_BIT         = 4
DEVICE_NEOGS_BIT      = 5
DEVICE_MIDI_UART_BIT  = 6
DEVICE_OPM_BIT        = 7
DEVICE_DUAL_OPM_BIT   = 8
DEVICE_OPNA_BIT       = 9

DEVICE_AY_MASK         = 1<<DEVICE_AY_BIT
DEVICE_TURBOSOUND_MASK = 1<<DEVICE_TURBOSOUND_BIT
DEVICE_TFM_MASK        = 1<<DEVICE_TFM_BIT
DEVICE_MOONSOUND_MASK  = 1<<DEVICE_MOONSOUND_BIT
DEVICE_GS_MASK         = 1<<DEVICE_GS_BIT
DEVICE_NEOGS_MASK      = 1<<DEVICE_NEOGS_BIT
DEVICE_MIDI_UART_MASK  = 1<<DEVICE_MIDI_UART_BIT
DEVICE_OPM_MASK        = 1<<DEVICE_OPM_BIT
DEVICE_DUAL_OPM_MASK   = 1<<DEVICE_DUAL_OPM_BIT
DEVICE_OPNA_MASK       = 1<<DEVICE_OPNA_BIT

MIN_FRAME_LENGTH_FPGA  = 18000000/49/42
MIN_FRAME_LENGTH_ZXEVO = 10000000/49/42

COLOR_DEFAULT = 0x07
COLOR_PANEL = 0x4f
COLOR_CURSOR = 0x28
COLOR_PANEL_FILE = 0x0f
COLOR_PANEL_DIR = 0x4f
COLOR_PANEL_DRIVE = 0x4b
COLOR_ERROR_WINDOW = 0x17

CUSTOM_UI_CMD_DRAW_WINDOW = 0
CUSTOM_UI_CMD_PRINT_TEXT  = 1
CUSTOM_UI_CMD_SET_COLOR   = 2
CUSTOM_UI_CMD_COUNT       = 3

	struct CUSTOMUIDRAWEND
cmd db CUSTOM_UI_CMD_COUNT
	ends

	struct CUSTOMUIDRAWWINDOW
cmd db CUSTOM_UI_CMD_DRAW_WINDOW
topleftx db 0
toplefty db 0
clientwidth db 0
clientheight db 0
	ends

	struct CUSTOMUIPRINTTEXT
cmd db CUSTOM_UI_CMD_PRINT_TEXT
posx db 0
posy db 0
straddr dw 0
	ends

	struct CUSTOMUISETCOLOR
cmd db CUSTOM_UI_CMD_SET_COLOR
color db 0
	ends
