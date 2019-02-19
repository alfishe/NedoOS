/*			-  io80182.h -

	This files defines the internal register addresses
	for z80182

	File version:   $Revision: 1.4 $


*/

#pragma language=extended

/* ==================================== */
/* 					*/
/*	ASCI Channel Control Registers 	*/
/* 					*/
/* ==================================== */

sfr CNTLA0	= 0x00;		/* ASCI Ctrl Reg A, Ch 0 */
sfr CNTLA1	= 0x01;		/* ASCI Ctrl Reg A, Ch 1 */
sfr CNTLB0	= 0x02;		/* ASCI Ctrl Reg B, Ch 0 */
sfr CNTLB1	= 0x03;		/* ASCI Ctrl Reg B, Ch 1 */
/*------------------------------------------------------------------------- */
sfr STAT0	= 0x04;		/* ASCI Status Reg, Ch 0 */
sfr STAT1	= 0x05;		/* ASCI Status Reg, Ch 1 */
/*------------------------------------------------------------------------- */
sfr TDR0	= 0x06;		/* ASCI Transmit Data Reg, Ch 0 */
sfr TDR1	= 0x07;		/* ASCI Transmit Data Reg, Ch 1 */
sfr TSR0	= 0x08;		/* ASCI Receive Data Reg, Ch 0 */
sfr TSR1	= 0x09;		/* ASCI Receive Data Reg, Ch 1 */

/* ==================================== */
/* 					*/
/*	CSI/O Registers 		*/
/* 					*/
/* ==================================== */

sfr CNTR	= 0x0A;		/* CSI/O Ctrl Reg */
sfr TRDR	= 0x0B;		/* CSI/O Trans/Rec Data Reg */

/* ==================================== */
/* 					*/
/*	Timer Registers 		*/
/* 					*/
/* ==================================== */

sfr TMDR0L	= 0x0C;			/* Timer 0 Data Reg L */
sfr TMDR0H	= 0x0D;			/* Timer 0 Data Reg H */
sfr TMDR1L	= 0x014;		/* Timer 1 Data Reg L */
sfr TMDR1H	= 0x015;		/* Timer 1 Data Reg H */
/*------------------------------------------------------------------------- */
sfr RLDR0L	= 0x0E;			/* Timer 0 Reload Reg L */
sfr RLDR0H	= 0x0F;			/* Timer 0 Reload Reg H */
sfr RLDR1L	= 0x016;		/* Timer 1 Reload Reg L */
sfr RLDR1H	= 0x017;		/* Timer 1 Reload Reg H */
/*------------------------------------------------------------------------- */
sfr TCR		= 0x010;		/* Timer Ctrl Reg */

/* ==================================== */
/* 					*/
/*	Free Running Counter 		*/
/* 					*/
/* ==================================== */

sfr FRC		= 0x018;		/* Free Running Counter */

/* ==================================== */
/* 					*/
/*	CPU Control Register 		*/
/* 					*/
/* ==================================== */

sfr CCR		= 0x01F;		/* CPU Ctrl Reg */

/* ==================================== */
/* 					*/
/*	DMA Registers 			*/
/* 					*/
/* ==================================== */

sfr SAR0L	= 0x020;		/* DMA 0 Source Addr Reg */
sfr SAR0H	= 0x021;		/* DMA 0 Source Addr Reg */
sfr SAR0B	= 0x022;		/* DMA 0 Source Addr Reg */
/*------------------------------------------------------------------------- */
sfr DAR0L	= 0x023;		/* DMA 0 Destination Addr Reg */
sfr DAR0H	= 0x024;		/* DMA 0 Destination Addr Reg */
sfr DAR0B	= 0x025;		/* DMA 0 Destination Addr Reg */
/*------------------------------------------------------------------------- */
sfr BCR0L	= 0x026;		/* DMA 0 Counter Reg */
sfr BCR0H	= 0x027;		/* DMA 0 Counter Reg */
/*------------------------------------------------------------------------- */
sfr MAR1L	= 0x028;		/* DMA 1 Memory Addr Reg */
sfr MAR1H	= 0x029;		/* DMA 1 Memory Addr Reg */
sfr MAR1B	= 0x02A;		/* DMA 1 Memory Addr Reg */
/*------------------------------------------------------------------------- */
sfr IAR1L	= 0x02B;		/* DMA I/O Addr Reg */
sfr IAR1H	= 0x02C;		/* DMA I/O Addr Reg */
/*------------------------------------------------------------------------- */
sfr BCR1L	= 0x02E;		/* DMA 1 Byte Count Reg */
sfr BCR1H	= 0x02F;		/* DMA 1 Byte Count Reg */
/*------------------------------------------------------------------------- */
sfr DSTAT	= 0x030;		/* DMA Status Reg */
sfr DMODE	= 0x031;		/* DMA Mode Reg */
sfr DCNTL	= 0x032;		/* DMA/WAIT Ctrl Reg */

/* ==================================== */
/* 					*/
/*	MMU Registers 			*/
/* 					*/
/* ==================================== */

sfr CBR_location     = 0x038;		/* MMU Common Base Reg */
sfr BBR_location     = 0x039;		/* MMU Bank Base Reg */
sfr CBAR_location    = 0x03A;		/* MMU Bank/Common Area Reg */
#define CBR  CBR_location
#define BBR  BBR_location
#define CBAR  CBAR_location

/* ==================================== */
/* 					*/
/*	System Control Registers 	*/
/* 					*/
/* ==================================== */

sfr IL		= 0x033;		/* Int Vect Low Reg */
sfr ITC		= 0x034;		/* Int/Trap Ctrl Reg */
sfr RCR		= 0x036;		/* Refresh Ctrl Reg */
sfr OMCR	= 0x03E;		/* Operation Mode Ctrl Reg */
sfr ICR		= 0x03F;		/* I/O Ctrl Reg */

/* ==================================== */
/* 					*/
/*	MIMIC Register Map 		*/
/* 					*/
/* ==================================== */

sfr MMC		= 0x0FF;		/* MIMIC Master Ctrl Reg */
sfr IUS		= 0x0FE;		/* Interrupt Pending */
sfr IE		= 0x0FD;		/* Interrupt Enable */
sfr IVEC	= 0x0FC;		/* Interrupt Vector */
sfr TTCR	= 0x0FA;		/* Transmit Time Constant */
sfr RTCR	= 0x0FB;		/* Receive Time Constant */
sfr FSCR	= 0x0EC;		/* FIFO Status and Ctrl */
sfr RTTC	= 0x0EA;		/* Receive Timeout Time Const */
sfr TTTC	= 0x0EB;		/* Transmit Timeout Time Const */
sfr RBR		= 0x0F0;		/* Receive Buffer Reg */
sfr THR		= 0x0F0;		/* Transmit Holding Reg */
sfr IER		= 0x0F1;		/* Interrupt Enable Reg */
/*------------------------------------------------------------------------- */
sfr FCR		= 0x0E9;		/* FIFO Ctrl Reg */
sfr LCR		= 0x0F3;		/* Line Ctrl Reg */
sfr MCR		= 0x0F4;		/* Modem Ctrl Reg */
sfr LSR		= 0x0F5;		/* Line Status Reg */
sfr MSR		= 0x0F6;		/* Modem Status Reg */
sfr SCR		= 0x0F7;		/* Scratch Reg */
sfr DLL		= 0x0F8;		/* Divisor Latch (LSByte) */
sfr DLM		= 0x0F9;		/* Divisor Latch (MSByte) */

/* ==================================== */
/* 					*/
/*	ESCC, PIA and MISC Registers 	*/
/* 					*/
/* ==================================== */

sfr PDDR	= 0x0DD;		/* PC Data Direction Reg */
sfr PDR		= 0x0DE;		/* PC Data Reg */
sfr PMC		= 0x0DF;		/* Interrupt Edge/Pin MUX Ctrl */
sfr ECACR	= 0x0E0;		/* ESCC Chan A Ctrl Reg */
sfr ECADR	= 0x0E1;		/* ESCC Chan A Data Reg */
sfr ECBCR	= 0x0E2;		/* ESCC Chan B Ctrl Reg */
sfr ECBDR	= 0x0E3;		/* ESCC Chan B Data Reg */
sfr PBDDR	= 0x0E4;		/* PB Data Direction Reg */
sfr PBDR	= 0x0E5;		/* PB Data Reg */
sfr RAMUBR	= 0x0E6;		/* RAM Upper Boundry Reg */
sfr RAMLBR	= 0x0E7;		/* RAM Lower Boundary Reg */
sfr ROMABR	= 0x0E8;		/* ROM Addr Boundary Reg */
sfr PADDR	= 0x0ED;		/* PA Data Direction Reg */
sfr PADR	= 0x0EE;		/* PA Data Reg */
sfr SYSCR	= 0x0EF;		/* System Configuration Reg */
