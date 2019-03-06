/*			-  io80180.h -

	This files defines the internal register addresses
	for z80180

	File version:   $Revision: 1.4 $


*/

#pragma language=extended


/* ==================================== */
/*					*/
/*	ASCI Channel Control Registers	*/
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
/*					*/
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

sfr TMDR0L	= 0x0C;		/* Timer 0 Data Reg L */
sfr TMDR0H	= 0x0D;		/* Timer 0 Data Reg H */
sfr TMDR1L	= 0x014;	/* Timer 1 Data Reg L */
sfr TMDR1H	= 0x015;	/* Timer 1 Data Reg H */
/*------------------------------------------------------------------------- */
sfr RLDR0L	= 0x0E;		/* Timer 0 Reload Reg L */
sfr RLDR0H	= 0x0F;		/* Timer 0 Reload Reg H */
sfr RLDR1L	= 0x016;	/* Timer 1 Reload Reg L */
sfr RLDR1H	= 0x017;	/* Timer 1 Reload Reg H */
/*------------------------------------------------------------------------- */
sfr TCR		= 0x010;	/* Timer Ctrl Reg */

/* ==================================== */
/*					*/
/*	Free Running Counter 		*/
/* 					*/
/* ==================================== */

sfr FRC		= 0x018;	/* Free Running Counter */

/* ==================================== */
/*					*/
/*	CPU Control Register 		*/
/* 					*/
/* ==================================== */

sfr CCR		= 0x01F;	/* CPU Ctrl Reg */

/* ==================================== */
/*					*/
/*	DMA Registers 			*/
/* 					*/
/* ==================================== */

sfr SAR0L	= 0x020;	/* DMA 0 Source Addr Reg */
sfr SAR0H	= 0x021;	/* DMA 0 Source Addr Reg */
sfr SAR0B	= 0x022;	/* DMA 0 Source Addr Reg */
/*------------------------------------------------------------------------- */
sfr DAR0L	= 0x023;	/* DMA 0 Destination Addr Reg */
sfr DAR0H	= 0x024;	/* DMA 0 Destination Addr Reg */
sfr DAR0B	= 0x025;	/* DMA 0 Destination Addr Reg */
/*------------------------------------------------------------------------- */
sfr BCR0L	= 0x026;	/* DMA 0 Counter Reg */
sfr BCR0H	= 0x027;	/* DMA 0 Counter Reg */
/*------------------------------------------------------------------------- */
sfr MAR1L	= 0x028;	/* DMA 1 Memory Addr Reg */
sfr MAR1H	= 0x029;	/* DMA 1 Memory Addr Reg */
sfr MAR1B	= 0x02A;	/* DMA 1 Memory Addr Reg */
/*------------------------------------------------------------------------- */
sfr IAR1L	= 0x02B;	/* DMA I/O Addr Reg */
sfr IAR1H	= 0x02C;	/* DMA I/O Addr Reg */
/*------------------------------------------------------------------------- */
sfr BCR1L	= 0x02E;	/* DMA 1 Byte Count Reg */
sfr BCR1H	= 0x02F;	/* DMA 1 Byte Count Reg */
/*------------------------------------------------------------------------- */
sfr DSTAT	= 0x030;	/* DMA Status Reg */
sfr DMODE	= 0x031;	/* DMA Mode Reg */
sfr DCNTL	= 0x032;	/* DMA/WAIT Ctrl Reg */

/* ==================================== */
/*					*/
/*	MMU Registers 			*/
/* 					*/
/* ==================================== */

sfr CBR_location     = 0x038;   /* MMU Common Base Reg */
sfr BBR_location     = 0x039;   /* MMU Bank Base Reg */
sfr CBAR_location    = 0x03A;   /* MMU Bank/Common Area Reg */
#define CBR  CBR_location
#define BBR  BBR_location
#define CBAR  CBAR_location

/* ==================================== */
/*					*/
/*	System Control Registers 	*/
/* 					*/
/* ==================================== */

sfr IL		= 0x033;	/* Int Vect Low Reg */
sfr ITC		= 0x034;	/* Int/Trap Ctrl Reg */
sfr RCR		= 0x036;	/* Refresh Ctrl Reg */
sfr OMCR	= 0x03E;	/* Operation Mode Ctrl Reg */
sfr ICR		= 0x03F;	/* I/O Ctrl Reg */
