	DEVICE ZXSPECTRUM128

	include "../../_sdk/sys_h.asm"
	define G9K_DISABLE_DIRECT_EXPORT
        include	"g9klib/g9klib.inc"
	include "g9klib/macros.inc"

	org PROGSTART

mainbegin
	ld sp,0
	OS_HIDEFROMPARENT
	ld e,6 ;textmode
	OS_SETGFX
	ld e,7
	OS_CLS

;detect V9990
	ld hl,detectstr
	call print_hl
	call G9k.Detect
	ld hl,failedstr
	jr nz,.printandexit
	ld hl,okstr
	call print_hl

;reset chip
	CALL G9k.Reset

;test RAM
	ld hl,ramteststr
	call print_hl
	call testcontrolreg
	call testram
	ld hl,failedstr
	jr nz,.printandexit
	ld hl,okstr
	call print_hl

;test control register
	ld hl,testcontrolregstr
	call print_hl
	call testcontrolreg
	ld hl,failedstr
	jr nz,.printandexit
	ld hl,okstr
	call print_hl

;show graphics test
	ld hl,g9kteststr
	call print_hl
	call UseG9k
	ld hl,failedstr
	jr nz,.printandexit
	ld hl,okstr

.printandexit
	call print_hl
	ld hl,pressanykeystr
	call print_hl
	YIELDGETKEYLOOP

	QUIT

testcontrolreg
	xor a
	out (ZX_EVA_CTRL),a

	in a,(ZX_EVA_CTRL)
	and 0x0c
	ret nz

	ld a,0x0c
	out (ZX_EVA_CTRL),a

	in a,(ZX_EVA_CTRL)
	and 0x0c
	cp 0x0c
	ret

testram
	ld de,0x0800
	ld hl,0x0000
	push de
	push hl
	call G9k.SetVramWrite
.fillloop
	ld a,l
	out (G9K_VRAM),a
	inc l
	jr nz,.fillloop
	inc h
	jr nz,.fillloop
	inc e
	dec d
	jr nz,.fillloop

	pop hl
	pop de
	call G9k.SetVramRead
.checkloop
	in a,(G9K_VRAM)
	cp l
	ret nz
	inc l
	jr nz,.checkloop
	inc h
	jr nz,.checkloop
	inc e
	dec d
	jr nz,.checkloop
	ret

UseG9k:
	LD      A,G9K_MODE_B3
	LD      BC,G9K_SCR0_16BIT*256 + G9K_SCR0_XIM512 
	LD      DE,256 * 1 + 0
	CALL    G9k.SetScreenMode
  
	; Set default blitter settings
	G9kWriteReg G9K_ARG,0
	G9kWriteReg G9K_LOP,G9K_LOP_WCSC
	LD      HL,#FFFF
	CALL    G9k.SetCmdWriteMask
           
	; Clear screen
	LD      HL,BOX_SETTINGS
	LD	DE,0x0ff0
	CALL    G9k.DrawFilledBox  
	
	; Wait for G9kDrawFilledBox to finish
	G9kCmdWait 

	; Load vff file, if command line is empty ANTIQUE.VFF is loaded 
	LD	HL,DATA_BUFFER	     
	LD	DE,FONT_NAME0
             
	; load font file
        CALL	LoadFonts
        RET	NZ		; Return if error loading font

	LD	IX,font0
	CALL	G9k.SetFont      ; Set font

	CALL	LoadPicture
	ret nz
	
	CALL    G9k.DisplayEnable
	LD      HL,7 * G9K_RED + 0 * G9K_GREEN + 0 * G9K_BLUE 
	CALL    G9k.SetCmdWriteMask
	LD	DE,7 * G9K_RED + 0 * G9K_GREEN + 0* G9K_BLUE 
	LD	HL,BOX_SETTINGS2
	CALL    G9k.DrawFilledBox
	; Wait for G9k.DrawFilledBox to finish
	G9kCmdWait
		
	LD      HL,#FFFF
	CALL    G9k.SetCmdWriteMask
		
	LD      HL,0 * G9K_RED + 0 * G9K_GREEN + 0 * G9K_BLUE 
	CALL 	G9k.SetCmdBackColor
	LD      HL,31 * G9K_RED + 31 * G9K_GREEN + 31 * G9K_BLUE 
	CALL    G9k.SetCmdColor
	G9kWriteReg G9K_LOP,G9K_LOP_WCSC+G9K_LOP_TP
	LD 	IX,150
	LD	IY,50
	LD	DE,WELCOME_TXT
	CALL	G9k.PrintString
	G9kCmdWait

	; Print loaded font
	LD 	IX,110
	LD	IY,50
	LD	BC,(font1.height)
	ADD	IY,BC

	LD	DE,FONT_NAME0
	CALL	G9k.PrintString

	LD	IX,font1
	CALL	G9k.SetFont      ; Set font
	        
	LD	DE,FONT_NAME1
	LD 	IX,110
	LD	IY,100
	CALL	G9k.PrintString

	LD	IX,font2
	CALL	G9k.SetFont      ; Set font

	LD	DE,.fontInRam	
	LD 	IX,110
	LD	IY,140
	CALL	G9k.PrintString 

	RET

.fontInRam	DB	"Font data in ram",0            
	        
LoadFonts:
; Input DE=pointer to file name

	LD	IX,font0
	XOR	A,A	; Font in vram
	CALL    G9k.OpenVff
	RET	NZ	; Return if error loading font
	
	LD	IY,FONT_OFFSET_TABLE
	LD	IX,font0
	LD	HL,DATA_BUFFER
	LD	BC,0
	CALL    G9k.LoadFont 
	RET	NZ	; Return if error loading font
	
	LD	IX,font0
	CALL	G9k.Close
	
	LD	DE,FONT_NAME1
	LD	IX,font1
	XOR	A,A	; Font in vram
	CALL    G9k.OpenVff
	RET	NZ	; Return if error loading font
              
	LD	BC,(font0.dataSize)               
	LD	IY,FONT_OFFSET_TABLE ; Point to same offset table as font0
	LD	IX,font1
	LD	HL,DATA_BUFFER
	CALL    G9k.LoadFont 
	RET	NZ	; Return if error loading font
	
	LD	IX,font1
	CALL	G9k.Close

	LD	DE,FONT_NAME2
	LD	IX,font2
	LD	A,1	; Font in ram
	CALL    G9k.OpenVff
	RET	NZ	; Return if error loading font
	           	         
	LD	IY,FONT_OFFSET_TABLE2 
	LD	IX,font2
	LD	HL,FONT_DATA2
	CALL    G9k.LoadFont 
	RET	NZ	; Return if error loading font 
		
	LD	IX,font2
	call	G9k.Close

	xor a
	ret
		
LoadPicture:               
; Open a G9B file
	LD	DE,G9B_FILE
	LD	HL,g9bObject
	CALL	G9k.OpenG9B
	ret nz
		             
	LD	IX,g9bObject   ; Pointer to G9B object
	LD	DE,DATA_BUFFER ; Pointer to buffer 
	LD	BC,30000       ; Buffer size
	LD	HL,0	       ; X
	LD	IY,0           ; Y
	LD	A,0	       ; Palette pointer
	CALL	G9k.ReadG9B 
	
	LD	IX,g9bObject
	call	G9k.Close

	xor a
	ret

BOX_SETTINGS
	DW      0,0
	DW      512,212
BOX_SETTINGS2			
	DW      100,50
	DW      312,100

WELCOME_TXT	  DB	"Gfx9000 Library v0.70",0
FONT_NAME0	  DB	"ANTIQUE.VFF",0
FONT_NAME1	  DB	"COMPUTER.VFF",0
FONT_NAME2        DB    "CP111.VFF",0
G9B_FILE	  DB	"LAKE.G9B",0

	include "file.asm"
	include "g9klib/g9klib.asm"
	include "g9klib/string.asm"
	include "g9klib/bitbuster.asm"	
	include "g9klib/math.asm"

print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR
	pop hl
	inc hl
	jp print_hl

detectstr
	db "Detecting V9990...",0
g9kteststr
	db "Showing G9k Test...",0
testcontrolregstr
	db "Testing Eva Control Register...",0
ramteststr
	db "Testing RAM...",0
okstr
	db "OK!\r\n",0
failedstr
	db "Failed!\r\n",0
pressanykeystr
	db "Press any key...\r\n",0

mainend

g9bObject	  G9B_OBJECT
font0		  VFF_OBJECT	; Font data in vram
font1		  VFF_OBJECT	; Font data in vram
font2 		  VFF_OBJECT	; Font data in ram

FONT_OFFSET_TABLE  DS	512,0
FONT_OFFSET_TABLE2 DS	512,0
FONT_DATA2	   DS   5000,0

DATA_BUFFER ; Load routines need a buffer. This is declared here

	savebin "testV9990.com",mainbegin,mainend-mainbegin
