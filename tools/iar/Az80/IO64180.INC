;			-  64180.inc -
;
;	This files defines the internal register addresses
;	for HD64180
;
;	Version: 1.0   7/Apr/94 IERH



; ========================================
;
;	ASCI Channel Control Registers
;
; ========================================

sfrtype CNTLA0	byte,read,write		= 00h	; ASCI Ctrl Reg A, Ch 0
sfrtype CNTLA1	byte,read,write		= 01h	; ASCI Ctrl Reg A, Ch 1
sfrtype CNTLB0	byte,read,write		= 02h	; ASCI Ctrl Reg B, Ch 0
sfrtype CNTLB1	byte,read,write		= 03h	; ASCI Ctrl Reg B, Ch 1
;---------------------------------------------------------------------------
sfrtype STAT0	byte,read,write		= 04h	; ASCI Status Reg, Ch 0
sfrtype STAT1	byte,read,write		= 05h	; ASCI Status Reg, Ch 1
;---------------------------------------------------------------------------
sfrtype TDR0	byte,write		= 06h	; ASCI Transmit Data Reg, Ch 0
sfrtype TDR1	byte,write		= 07h	; ASCI Transmit Data Reg, Ch 1
sfrtype RDR0	byte,read		= 08h	; ASCI Receive Data Reg, Ch 0
sfrtype RDR1	byte,read		= 09h	; ASCI Receive Data Reg, Ch 1

; ========================================
;
;	CSI/O Registers
;
; ========================================

sfrtype CNTR	byte,read,write		= 0Ah	; CSI/O Ctrl Reg
sfrtype TRDR	byte,read,write		= 0Bh	; CSI/O Trans/Rec Data Reg

; ========================================
;
;	Timer Registers
;
; ========================================

sfrtype TMDR0L	byte,read,write		= 0Ch	; Timer 0 Data Reg L
sfrtype TMDR0H	byte,read,write		= 0Dh	; Timer 0 Data Reg H
sfrtype TMDR1L	byte,read,write		= 014h	; Timer 1 Data Reg L
sfrtype TMDR1H	byte,read,write		= 015h	; Timer 1 Data Reg H
;---------------------------------------------------------------------------
sfrtype RLDR0L	byte,read,write		= 0Eh	; Timer 0 Reload Reg L
sfrtype RLDR0H	byte,read,write		= 0Fh	; Timer 0 Reload Reg H
sfrtype RLDR1L	byte,read,write		= 016h	; Timer 1 Reload Reg L
sfrtype RLDR1H	byte,read,write		= 017h	; Timer 1 Reload Reg H
;---------------------------------------------------------------------------
sfrtype TCR	byte,read,write		= 010h	; Timer Ctrl Reg

; ========================================
;
;	Free Running Counter
;
; ========================================

sfrtype FRC	byte,read		= 018h	; Free Running Counter

; ========================================
;
;	DMA Registers
;
; ========================================

sfrtype SAR0L	byte,read,write		= 020h	; DMA 0 Source Addr Reg
sfrtype SAR0H	byte,read,write		= 021h	; DMA 0 Source Addr Reg
sfrtype SAR0B	byte,read,write		= 022h	; DMA 0 Source Addr Reg
;---------------------------------------------------------------------------
sfrtype DAR0L	byte,read,write		= 023h	; DMA 0 Destination Addr Reg
sfrtype DAR0H	byte,read,write		= 024h	; DMA 0 Destination Addr Reg
sfrtype DAR0B	byte,read,write		= 025h	; DMA 0 Destination Addr Reg
;---------------------------------------------------------------------------
sfrtype BCR0L	byte,read,write		= 026h	; DMA 0 Counter Reg
sfrtype BCR0H	byte,read,write		= 027h	; DMA 0 Counter Reg
;---------------------------------------------------------------------------
sfrtype MAR1L	byte,read,write		= 028h	; DMA 1 Memory Addr Reg
sfrtype MAR1H	byte,read,write		= 029h	; DMA 1 Memory Addr Reg
sfrtype MAR1B	byte,read,write		= 02Ah	; DMA 1 Memory Addr Reg
;---------------------------------------------------------------------------
sfrtype IAR1L	byte,read,write		= 02Bh	; DMA I/O Addr Reg
sfrtype IAR1H	byte,read,write		= 02Ch	; DMA I/O Addr Reg
;---------------------------------------------------------------------------
sfrtype BCR1L	byte,read,write		= 02Eh	; DMA 1 Byte Count Reg
sfrtype BCR1H	byte,read,write		= 02Fh	; DMA 1 Byte Count Reg
;---------------------------------------------------------------------------
sfrtype DSTAT	byte,read,write		= 030h	; DMA Status Reg
sfrtype DMODE	byte,read,write		= 031h	; DMA Mode Reg
sfrtype DCNTL	byte,read,write		= 032h	; DMA/WAIT Ctrl Reg

; ========================================
;
;	MMU Registers
;
; ========================================

sfrtype CBR	byte,read,write		= 038h	; MMU Common Base Reg
sfrtype BBR	byte,read,write		= 039h	; MMU Bank Base Reg
sfrtype CBAR	byte,read,write		= 03Ah	; MMU Bank/Common Area Reg

; ========================================
;
;	Interrupt Registers
;
; ========================================

sfrtype IL	byte,read,write		= 033h	; Int Vect Low Reg
sfrtype ITC	byte,read,write		= 034h	; Int/Trap Ctrl Reg

; ========================================
;
;	Refresh Registers
;
; ========================================

sfrtype RCR	byte,read,write		= 036h	; Refresh Ctrl Reg

; ========================================
;
;	I/O Registers
;
; ========================================
sfrtype OMCR    byte,read,write         = 03Eh  ; Operation Mode Control Register

sfrtype ICR	byte,read,write		= 03Fh	; I/O Ctrl Reg

