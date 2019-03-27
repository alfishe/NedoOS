;			-  z80182.inc -
;
;	This files defines the internal register addresses
;	for z80182
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
sfrtype TSR0	byte,read		= 08h	; ASCI Receive Data Reg, Ch 0
sfrtype TSR1	byte,read		= 09h	; ASCI Receive Data Reg, Ch 1

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
;	CPU Control Register
;
; ========================================

sfrtype CCR	byte,read,write		= 01Fh	; CPU Ctrl Reg

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
;	System Control Registers
;
; ========================================

sfrtype IL	byte,read,write		= 033h	; Int Vect Low Reg
sfrtype ITC	byte,read,write		= 034h	; Int/Trap Ctrl Reg
sfrtype RCR	byte,read,write		= 036h	; Refresh Ctrl Reg
sfrtype OMCR	byte,read,write		= 03Eh	; Operation Mode Ctrl Reg
sfrtype ICR	byte,read,write		= 03Fh	; I/O Ctrl Reg

; ========================================
;
;	MIMIC Register Map
;
; ========================================

sfrtype MMC	byte,read,write		= 0FFh	; MIMIC Master Ctrl Reg
sfrtype IUS	byte,read,write		= 0FEh	; Interrupt Pending
sfrtype IE	byte,read,write		= 0FDh	; Interrupt Enable
sfrtype IVEC	byte,read,write		= 0FCh	; Interrupt Vector
sfrtype TTCR	byte,read,write		= 0FAh	; Transmit Time Constant
sfrtype RTCR	byte,read,write		= 0FBh	; Receive Time Constant
sfrtype FSCR	byte,read,write		= 0ECh	; FIFO Status and Ctrl
sfrtype RTTC	byte,read,write		= 0EAh	; Receive Timeout Time Const
sfrtype TTTC	byte,read,write		= 0EBh	; Transmit Timeout Time Const
sfrtype RBR	byte,write		= 0F0h	; Receive Buffer Reg
sfrtype THR	byte,read		= 0F0h	; Transmit Holding Reg
sfrtype IER	byte,read,write		= 0F1h	; Interrupt Enable Reg
;---------------------------------------------------------------------------
sfrtype FCR	byte,read		= 0E9h	; FIFO Ctrl Reg
sfrtype LCR	byte,read		= 0F3h	; Line Ctrl Reg
sfrtype MCR	byte,read		= 0F4h	; Modem Ctrl Reg
sfrtype LSR	byte,read,write		= 0F5h	; Line Status Reg
sfrtype MSR	byte,read,write		= 0F6h	; Modem Status Reg
sfrtype SCR	byte,read		= 0F7h	; Scratch Reg
sfrtype DLL	byte,read		= 0F8h	; Divisor Latch (LSByte)
sfrtype DLM	byte,read		= 0F9h	; Divisor Latch (MSByte)

; ========================================
;
;	ESCC, PIA and MISC Registers
;
; ========================================

sfrtype PDDR	byte,read,write		= 0DDh	; PC Data Direction Reg
sfrtype PDR	byte,read,write		= 0DEh	; PC Data Reg
sfrtype PMC	byte,read,write		= 0DFh	; Interrupt Edge/Pin MUX Ctrl
sfrtype ECACR	byte,read,write		= 0E0h	; ESCC Chan A Ctrl Reg
sfrtype ECADR	byte,read,write		= 0E1h	; ESCC Chan A Data Reg
sfrtype ECBCR	byte,read,write		= 0E2h	; ESCC Chan B Ctrl Reg
sfrtype ECBDR	byte,read,write		= 0E3h	; ESCC Chan B Data Reg
sfrtype PBDDR	byte,read,write		= 0E4h	; PB Data Direction Reg
sfrtype PBDR	byte,read,write		= 0E5h	; PB Data Reg
sfrtype RAMUBR	byte,read,write		= 0E6h	; RAM Upper Boundry Reg
sfrtype RAMLBR	byte,read,write		= 0E7h	; RAM Lower Boundary Reg
sfrtype ROMABR	byte,read,write		= 0E8h	; ROM Addr Boundary Reg
sfrtype PADDR	byte,read,write		= 0EDh	; PA Data Direction Reg
sfrtype PADR	byte,read,write		= 0EEh	; PA Data Reg
sfrtype SYSCR	byte,read,write		= 0EFh	; System Configuration Reg
