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

	struct GPSETTINGS
sharedpages ds 3
usemp3 dw 0
usemwm dw 0
usept3 dw 0
usevgm dw 0
usemoonmod dw 0
moonmoddefaultpanning dw 0
moonsoundstatus ds 1 ; 0 - no device, 1 - MoonSound with old firmware (wave ports not working), 2 - MoonSound OK
	ends
