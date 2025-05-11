PLAYERSTART = 0x4000
PLAYEREND   = 0x8000

	macro PLAYERHEADER
	dw playerinit      ;called once, should check if sound device is available (if possible)
	dw playerdeinit    ;called once when the application is exiting
	dw musicload       ;function that loads the file allocating all required resources
	dw musicunload     ;function that frees all resources allocated in musicload and mutes the sound device
	dw musicplay       ;function called in the main loop, should update progress variable
	dw isfilesupported ;function to determine if this player can handle the file
	dw playernamestr   ;player name string
	dw 0 ;address of the song title, zero means the title is unavailable and file name should be displayed instead
	dw 0 ;address of play progress variable, setting this to zero disables progress bar
	dw 0 ;address of error string
	endm

PLAYERINITPROCADDR      = PLAYERSTART+0x00
PLAYERDEINITPROCADDR    = PLAYERSTART+0x02
MUSICLOADPROCADDR       = PLAYERSTART+0x04
MUSICUNLOADPROCADDR     = PLAYERSTART+0x06
MUSICPLAYPROCADDR       = PLAYERSTART+0x08
ISFILESUPPORTEDPROCADDR = PLAYERSTART+0x0a
PLAYERNAMESTRADDR       = PLAYERSTART+0x0c
MUSICTITLEADDR          = PLAYERSTART+0x0e
MUSICPROGRESSADDR       = PLAYERSTART+0x10
ERRORSTRINGADDR         = PLAYERSTART+0x12

	struct GPSETTINGS
sharedpages ds 3
usemp3 dw 0
usemwm dw 0
usept3 dw 0
usevgm dw 0
usemoonmod dw 0
framelength dw 0 ;in 42 t-states units
moonmoddefaultpanning dw 0
midiuartdelayoverride dw 0
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
DEVICE_OPNA_BIT       = 10

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
